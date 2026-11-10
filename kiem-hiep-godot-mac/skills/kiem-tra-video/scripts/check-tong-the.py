#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
check-tong-the.py
Kiểm tra toàn diện tập video hoạt hình 2D Tèo (Kiếm Hiệp & Lịch Sử):
1. Review kịch bản (Hook, CTA, từ ngữ cấm, độ dài >= 20 phút).
2. Kiểm tra hình ảnh & hoạt cảnh (Chibi rig2, tranh.gd/scenes, chống bẫy slide chữ tĩnh, Thumbnail).
3. Kiểm tra âm thanh (Thời lượng video >= 20 phút, LUFS giọng ~ -20, True Peak <= -0.5, nhạc <= -35 LUFS).
4. Kiểm tra gói xuất bản YouTube (MP4, Thumbnail, Tiêu đề, Mô tả, Tags).
"""

import sys
import os
import json
import datetime as dt
import subprocess
import argparse
from pathlib import Path

CURRENT_DIR = Path(__file__).parent.resolve()

def run_script(script_name, tap_path, extra_args=None):
    script_path = CURRENT_DIR / script_name
    cmd = [sys.executable, str(script_path), str(tap_path)]
    if extra_args:
        cmd.extend(extra_args)
    res = subprocess.run(cmd)
    return res.returncode == 0

def check_youtube_package(tap_path):
    print("=" * 60)
    print(f"📦 KIỂM TRA GÓI XUẤT BẢN YOUTUBE: {tap_path.name}")
    print("=" * 60)
    
    yt_dir = tap_path / "youtube"
    if not yt_dir.exists():
        print("⚠️ Chưa có thư mục youtube/ để xuất bản.")
        return True # Không làm fail nếu đang ở bước dựng
        
    errors = []
    successes = []
    
    # 1. File MP4
    mp4s = list(yt_dir.glob("*.mp4"))
    if not mp4s:
        errors.append("❌ Thiếu file .mp4 trong youtube/")
    else:
        successes.append(f"✅ Video YouTube: {mp4s[0].name} ({mp4s[0].stat().st_size / (1024*1024):.1f} MB)")
        
    # 2. Thumbnail
    thumbs = list(yt_dir.glob("*thumb*.png")) + list(yt_dir.glob("*thumb*.jpg"))
    if not thumbs:
        errors.append("❌ Thiếu thumbnail trong youtube/")
    else:
        successes.append(f"✅ Thumbnail YouTube: {thumbs[0].name}")
        
    # 3. Tiêu đề
    title_file = yt_dir / "tieu-de.txt"
    if not title_file.exists():
        title_file = yt_dir / "tieude.txt"
    if not title_file.exists():
        errors.append("❌ Thiếu file tieu-de.txt (hoặc tieude.txt)")
    else:
        title = title_file.read_text(encoding="utf-8").strip()
        length = len(title)
        if length > 100:
            errors.append(f"❌ Tiêu đề vượt quá 100 ký tự YouTube: {length} ký tự")
        elif length > 60:
            successes.append(f"⚠️ Tiêu đề hơi dài ({length} ký tự): '{title}' (khuyến nghị <= 60 để hiển thị trọn vẹn)")
        else:
            successes.append(f"✅ Tiêu đề chuẩn SEO ({length} ký tự): '{title}'")
            
        if not ("Tèo Kể" in title or "Tèo Tửu Lâu" in title or "Lại Là Tèo Đây" in title):
            errors.append("❌ Tiêu đề chưa có đuôi thương hiệu kênh ('| Tèo Kể', '| Tèo Tửu Lâu', '| Lại Là Tèo Đây')")
            
    # 4. Mô tả
    desc_file = yt_dir / "mo-ta.txt"
    if not desc_file.exists():
        desc_file = yt_dir / "mota.txt"
    if not desc_file.exists():
        errors.append("❌ Thiếu file mo-ta.txt (hoặc mota.txt)")
    else:
        desc = desc_file.read_text(encoding="utf-8").strip()
        if len(desc) < 50:
            errors.append("❌ Nội dung mô tả quá ngắn")
        else:
            successes.append("✅ File mota.txt đầy đủ")
            
    # 5. Tags
    tags_file = yt_dir / "tags.txt"
    if not tags_file.exists():
        errors.append("❌ Thiếu file tags.txt")
    else:
        tags = tags_file.read_text(encoding="utf-8").strip()
        tag_list = [t.strip() for t in tags.split(",") if t.strip()]
        if len(tag_list) < 5:
            errors.append(f"❌ Quá ít tags: chỉ có {len(tag_list)} tags")
        else:
            successes.append(f"✅ Tags phong phú: {len(tag_list)} từ khóa")
            
    for s in successes:
        print(s)
    for e in errors:
        print(e)
        
    passed = len(errors) == 0
    print("-" * 60)
    if passed:
        print("🎉 GÓI XUẤT BẢN YOUTUBE HOÀN TOÀN ĐẠT CHUẨN!")
    else:
        print("❌ GÓI YOUTUBE CHƯA HOÀN CHỈNH!")
    print("=" * 60)
    return passed

def check_all(tap_dir, skip_sheet=False):
    tap_path = Path(tap_dir).resolve()
    
    print("\n" + "#" * 65)
    print(f"🚀 BẮT ĐẦU KIỂM TRA TOÀN DIỆN TẬP PHIM: {tap_path.name}")
    print("#" * 65 + "\n")
    
    results = {}
    
    # 1. Kịch bản
    print("[BƯỚC 1/4] REVIEW KỊCH BẢN...")
    results["kich_ban"] = run_script("review-kich-ban.py", tap_path)
    print("\n")
    
    # 2. Hình ảnh & Hoạt cảnh
    print("[BƯỚC 2/4] KIỂM TRA HÌNH ẢNH & CHIBI...")
    extra = ["--no-sheet"] if skip_sheet else []
    results["hinh_anh"] = run_script("check-hinh-anh.py", tap_path, extra)
    print("\n")
    
    # 3. Âm thanh
    print("[BƯỚC 3/4] KIỂM TRA ÂM THANH...")
    results["am_thanh"] = run_script("check-am-thanh.py", tap_path)
    print("\n")
    
    # 4. Gói YouTube
    print("[BƯỚC 4/4] KIỂM TRA GÓI YOUTUBE...")
    results["youtube"] = check_youtube_package(tap_path)
    print("\n")
    
    # TỔNG KẾT
    print("#" * 65)
    print(f"📋 BẢNG TỔNG KẾT CHẤT LƯỢNG: {tap_path.name}")
    print("#" * 65)
    
    status_map = {True: "✅ ĐẠT (PASS)", False: "❌ KHÔNG ĐẠT (FAIL)"}
    print(f"1. Kịch bản & Ngữ liệu:        {status_map[results['kich_ban']]}")
    print(f"2. Hình ảnh, Chibi & Hoạt cảnh: {status_map[results['hinh_anh']]}")
    print(f"3. Âm thanh & Độ dài:           {status_map[results['am_thanh']]}")
    print(f"4. Gói YouTube xuất bản:        {status_map[results['youtube']]}")
    print("-" * 65)
    
    final_pass = all(results.values())
    if final_pass:
        print("🌟 TẬP PHIM XUẤT SẮC! ĐỦ TIÊU CHUẨN XUẤT BẢN HOẶC ĐỒNG BỘ GOOGLE DRIVE.")
        yt_folder = tap_path / "youtube"
        if yt_folder.exists():
            import datetime as dt
            ready_file = yt_folder / ".READY_TO_UPLOAD"
            cert = {
                "verified_at": dt.datetime.now().isoformat(),
                "tap": tap_path.name,
                "status": "PASSED_100%",
                "qa_gate": "PASSED"
            }
            ready_file.write_text(json.dumps(cert, indent=2), encoding="utf-8")
            print(f"🔒 ĐÃ CẤP CHỨNG CHỈ XUẤT BẢN: {ready_file}")
    else:
        print("⚠️ CÓ HẠNG MỤC CHƯA ĐẠT. Vui lòng khắc phục các mục đánh dấu đỏ trước khi đăng.")
    print("#" * 65 + "\n")
    return final_pass

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Kiểm tra toàn diện tập video")
    parser.add_argument("tap_dir", help="Đường dẫn thư mục tập video")
    parser.add_argument("--no-sheet", action="store_true", help="Không tạo contact sheet để chạy nhanh hơn")
    args = parser.parse_args()
    
    ok = check_all(args.tap_dir, skip_sheet=args.no_sheet)
    sys.exit(0 if ok else 1)
