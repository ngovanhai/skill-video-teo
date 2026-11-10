#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
review-kich-ban-v2.py
Static editorial diagnostics shared by HyperFrames video.json and Godot loi.txt.

This tool checks structure and measurable writing signals only. It cannot verify
historical facts, judge emotional impact, or replace a human/editorial review.
Warnings are advisory; only unreadable/invalid input is a hard failure.
"""
from __future__ import annotations

import argparse
import json
import re
import sys
import unicodedata
from pathlib import Path
from collections import Counter

CTA_COMMENT = ("bình luận", "comment", "gợi ý", "đề xuất", "muốn tèo làm")
CTA_SUBSCRIBE = ("đăng ký", "theo dõi", "subscribe", "like")
WORD_RE = re.compile(r"[\wÀ-ỹ]+", re.UNICODE)


def words(text: str) -> list[str]:
    return WORD_RE.findall(text or "")


def norm(text: str) -> str:
    text = unicodedata.normalize("NFKC", text or "").lower()
    return re.sub(r"[^\wÀ-ỹ]+", " ", text).strip()


def load_project(root: Path):
    """Return (format, narration scenes, frame, errors)."""
    errors = []
    video_json = root / "video.json"
    if video_json.exists():
        try:
            data = json.loads(video_json.read_text(encoding="utf-8"))
            scenes = list(data.get("scenes") or [])
            if not scenes:
                for chapter_file in sorted((root / "chapters").glob("*.json")):
                    chapter = json.loads(chapter_file.read_text(encoding="utf-8"))
                    scenes.extend(chapter.get("scenes") or [])
            narration = [
                {"id": str(i + 1), "text": str(s.get("say", "")), "kind": s.get("type", ""),
                 "hook": bool(s.get("hook")) or s.get("type") == "hook",
                 "cta": bool(s.get("cta"))}
                for i, s in enumerate(scenes) if isinstance(s, dict) and s.get("say")
            ]
            return "HyperFrames", narration, (data.get("creative") or {}).get("frame"), errors
        except (OSError, json.JSONDecodeError, AttributeError, TypeError) as exc:
            errors.append(f"Không đọc được video.json/chapters: {exc}")
            return "HyperFrames", [], None, errors

    loi = root / "loi.txt"
    if not loi.exists() and (root / "godot").is_dir():
        loi = root / "godot" / "loi.txt"
    if loi.exists():
        try:
            lines = loi.read_text(encoding="utf-8-sig").splitlines()
            narration = []
            current = "opening"
            for line in lines:
                value = line.strip()
                if not value or value.startswith("#"):
                    if value.startswith("##"):
                        current = value.lstrip("# ").strip() or current
                    continue
                # Remove optional [line-id] prefix used by the Godot voice pipeline.
                value = re.sub(r"^\[[^\]]+\]\s*", "", value)
                if value:
                    narration.append({"id": current, "text": value, "kind": "", "hook": False, "cta": False})
            # Godot tap metadata is normally stored beside godot/ or in the tap root.
            candidates = [root / "tap.json", root / "godot" / "tap.json", root.parent / "tap.json"]
            frame = None
            for candidate in candidates:
                if candidate.exists():
                    try:
                        frame = (json.loads(candidate.read_text(encoding="utf-8")) .get("story") or {}).get("frame")
                        break
                    except (OSError, json.JSONDecodeError, AttributeError):
                        pass
            return "Godot", narration, frame, errors
        except OSError as exc:
            errors.append(f"Không đọc được loi.txt: {exc}")
            return "Godot", [], None, errors

    errors.append("Không tìm thấy video.json hoặc loi.txt trong thư mục tập.")
    return "unknown", [], None, errors


def main():
    parser = argparse.ArgumentParser(description="Review tĩnh kịch bản HyperFrames/Godot")
    parser.add_argument("project", type=Path, help="Thư mục video/tập")
    parser.add_argument("--target-minutes", type=float, default=20.0)
    parser.add_argument("--words-per-minute", type=float, default=240.0,
                        help="Chỉ dùng để ước tính; thời lượng TTS thực tế mới là chuẩn cuối")
    parser.add_argument("--min-words", type=int, default=0,
                        help="Ngưỡng từ tuỳ chọn; mặc định không ép mọi thể loại cùng một số từ")
    parser.add_argument("--json", action="store_true", help="In kết quả JSON")
    args = parser.parse_args()

    root = args.project.expanduser().resolve()
    fmt, scenes, frame, errors = load_project(root)
    warnings = []
    if errors:
        for error in errors:
            print(f"FAIL: {error}", file=sys.stderr)
        return 2

    text = [s["text"] for s in scenes if s["text"].strip()]
    if not text:
        print("FAIL: Không tìm thấy lời dẫn trong dự án.", file=sys.stderr)
        return 2

    full = "\n".join(text)
    total_words = len(words(full))
    estimated = total_words / args.words_per_minute if args.words_per_minute > 0 else 0

    if args.min_words and total_words < args.min_words:
        warnings.append(f"Ít hơn ngưỡng tuỳ chọn: {total_words}/{args.min_words} từ.")
    if estimated < args.target_minutes:
        warnings.append(
            f"Ước tính {estimated:.1f} phút, thấp hơn mục tiêu {args.target_minutes:g} phút; "
            "hãy xác nhận bằng thời lượng ZeroTTS thực tế."
        )

    # Frame is a useful creative contract, but older episodes remain reviewable.
    if frame is None:
        warnings.append("Chưa có creative.frame/story.frame; tập cũ vẫn được review nhưng nên bổ sung.")
    elif isinstance(frame, dict):
        required = ("name", "analysis", "axis", "open", "close", "segments")
        missing = [key for key in required if not frame.get(key)]
        if missing:
            warnings.append("Frame thiếu trường: " + ", ".join(missing))
        segments = frame.get("segments")
        if isinstance(segments, list) and not (6 <= len(segments) <= 10):
            warnings.append(f"Frame có {len(segments)} segments; khuyến nghị 6–10 (điều chỉnh theo format).")
        if len(words(str(frame.get("analysis", "")))) < 25:
            warnings.append("Phân tích frame ngắn hơn 25 từ; cần giải thích vì sao góc kể phù hợp.")
    else:
        warnings.append("Frame không phải object; kiểm tra lại creative.frame/story.frame.")

    # Hook: use explicitly marked HyperFrames scenes when available.
    hook_scenes = [s for s in scenes if s["hook"]]
    if hook_scenes:
        hook_words = sum(len(words(s["text"])) for s in hook_scenes)
        hook_seconds = hook_words / (args.words_per_minute / 60) if args.words_per_minute > 0 else 0
        if hook_seconds > 15:
            warnings.append(f"Hook được đánh dấu ước tính {hook_seconds:.1f}s (>15s).")
    else:
        warnings.append("Không đánh dấu cảnh hook rõ ràng (type=hook hoặc hook=true); không thể đo hook tự động.")

    # First CTA: locate an early scene/section containing both requested actions.
    early_words = 0
    early_text = []
    first_cta_found = False
    for scene in scenes:
        early_words += len(words(scene["text"]))
        early_text.append(scene["text"].lower())
        joined = " ".join(early_text)
        if any(k in joined for k in CTA_COMMENT) and any(k in joined for k in CTA_SUBSCRIBE):
            first_cta_found = True
            break
        if early_words >= 180:
            break
    if not first_cta_found:
        warnings.append("Chưa thấy lời mời bình luận + like/đăng ký trong khoảng 180 từ đầu.")
    elif early_words > 70:
        warnings.append(f"Lời mời tương tác đầu video chỉ được tìm thấy sau khoảng {early_words} từ; kiểm tra có làm chậm diễn biến không.")

    # Repeated long sentences/lines: a signal for manual editing, not an automatic rewrite.
    sentence_list = []
    for paragraph in text:
        sentence_list.extend(re.split(r"(?<=[.!?…])\s+", paragraph))
    normalized = [norm(s) for s in sentence_list if len(words(s)) >= 8]
    duplicates = [s for s, n in Counter(normalized).items() if n > 1]
    if duplicates:
        warnings.append(f"Có {len(duplicates)} câu dài bị lặp nguyên văn; kiểm tra lặp ý/câu.")
    long_sentences = [s for s in sentence_list if len(words(s)) > 35]
    if long_sentences:
        warnings.append(f"Có {len(long_sentences)} câu trên 35 từ; đọc thử bằng TTS để kiểm tra nhịp.")

    result = {
        "format": fmt,
        "project": str(root),
        "narration_units": len(text),
        "word_count": total_words,
        "estimated_minutes": round(estimated, 2),
        "duration_note": "Ước tính theo words-per-minute; thời lượng TTS/audio thực tế là nguồn chuẩn.",
        "warnings": warnings,
        "status": "REVIEW" if warnings else "PASS_STATIC",
        "limitations": [
            "Không xác minh sự thật hoặc độ tin cậy của nguồn.",
            "Không đánh giá được cảm xúc, logic nhân quả hay retention như biên tập viên.",
            "Không thay thế việc nghe audio TTS và xem video render."
        ]
    }
    if args.json:
        print(json.dumps(result, ensure_ascii=False, indent=2))
    else:
        print(f"\nSCRIPT REVIEW V2 — {fmt}: {root.name}")
        print(f"- Đơn vị lời dẫn: {len(text)}")
        print(f"- Số từ: {total_words}")
        print(f"- Thời lượng ước tính: {estimated:.1f} phút")
        print(f"- Trạng thái: {result['status']}")
        for warning in warnings:
            print(f"⚠ {warning}")
        print("\nGiới hạn: công cụ không xác minh dữ kiện, không chấm cảm xúc/logic, "
              "và không thay thế nghe TTS hoặc xem bản render.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
