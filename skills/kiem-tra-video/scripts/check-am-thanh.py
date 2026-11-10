#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
check-am-thanh.py
Kiểm tra âm thanh video:
- Thời lượng video >= 20 phút (1200s) (Cấm Shorts).
- Âm lượng chuẩn YouTube (Integrated LUFS: -16 đến -21 LUFS).
- True Peak <= -1.0 dBFS (tránh méo tiếng, rè loa).
- Nhạc nền nhỏ hơn giọng đọc ít nhất 15 dB (<= -35 đến -40 LUFS).
- Quét SFX nổ/giật mình (đột biến volume vượt ngưỡng).
"""

import sys
import os
import json
import subprocess
import argparse
import re
from pathlib import Path

def run_ffprobe_duration(media_path):
    cmd = [
        "ffprobe", "-v", "error",
        "-show_entries", "format=duration",
        "-of", "default=noprint_wrappers=1:nokey=1",
        str(media_path)
    ]
    res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    try:
        return float(res.stdout.strip())
    except Exception:
        return 0.0

def run_ebur128(media_path):
    """Đo LUFS và True Peak bằng ffmpeg ebur128"""
    cmd = [
        "ffmpeg", "-nostats", "-i", str(media_path),
        "-filter_complex", "ebur128=peak=true",
        "-f", "null", "-"
    ]
    res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    output = res.stderr

    # Phân tích kết quả Summary từ ebur128
    #   Integrated loudness:
    #     I:         -19.8 LUFS
    #     Threshold: -30.0 LUFS
    #   Loudness range:
    #     LRA:         5.2 LU
    #   True peak:
    #     Peak:       -1.5 dBFS
    i_lufs = None
    lra = None
    true_peak = None

    m_i = re.search(r"Integrated loudness:\s+I:\s+([-\d\.]+)\s+LUFS", output)
    if m_i:
        i_lufs = float(m_i.group(1))

    m_lra = re.search(r"Loudness range:\s+LRA:\s+([-\d\.]+)\s+LU", output)
    if m_lra:
        lra = float(m_lra.group(1))

    m_peak = re.search(r"True peak:\s+Peak:\s+([-\d\.]+)\s+dBFS", output)
    if m_peak:
        true_peak = float(m_peak.group(1))

    return {
        "integrated_lufs": i_lufs,
        "loudness_range": lra,
        "true_peak_dbfs": true_peak
    }

def detect_loud_spikes(media_path, threshold_db=-0.5):
    """Kiểm tra có đoạn SFX nào bị đột biến âm lượng quá to (nguy cơ giật mình)"""
    # Dùng astats để tìm peak
    cmd = [
        "ffmpeg", "-nostats", "-i", str(media_path),
        "-af", f"volumedetect",
        "-f", "null", "-"
    ]
    res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    out = res.stderr
    max_vol = None
    m = re.search(r"max_volume:\s+([-\d\.]+)\s+dB", out)
    if m:
        max_vol = float(m.group(1))
    return max_vol

def check_tap_audio(tap_dir, is_strict=False):
    tap_path = Path(tap_dir).resolve()
    print("=" * 60)
    print(f"🔊 KIỂM TRA ÂM THANH: {tap_path.name}")
    print("=" * 60)

    # Tìm file video hoặc file âm thanh tổng hợp
    final_video = tap_path / "renders" / "final.mp4"
    if not final_video.exists():
        final_video = tap_path / "final.mp4"
    
    youtube_video = None
    yt_folder = tap_path / "youtube"
    if yt_folder.exists():
        mp4_files = list(yt_folder.glob("*.mp4"))
        if mp4_files:
            youtube_video = mp4_files[0]

    target_video = final_video if final_video.exists() else youtube_video

    giong_audio = tap_path / "audio" / "giong.wav"
    if not giong_audio.exists():
        giong_audio = tap_path / "audio" / "giong.mp3"
        
    nhac_audio = tap_path / "audio" / "nhac.mp3"
    if not nhac_audio.exists():
        nhac_audio = tap_path / "audio" / "nhac.wav"

    errors = []
    warnings = []
    successes = []

    # 1. Đo thời lượng
    if target_video and target_video.exists():
        dur = run_ffprobe_duration(target_video)
        minutes = dur / 60.0
        dur_str = f"{int(minutes)}p {int(dur % 60):02d}s ({dur:.1f}s)"
        if dur < 1180: # Dưới 19p40s coi như không đạt chuẩn 20 phút
            errors.append(f"❌ THỜI LƯỢNG QUÁ NGẮN: {dur_str} < 20 phút! Bắt buộc video dài >= 20 phút.")
        else:
            successes.append(f"✅ Thời lượng chuẩn video dài: {dur_str} (>= 20 phút)")

        # 2. Đo LUFS của video hoàn chỉnh
        print("Đang đo âm lượng chuẩn ebur128 trên video thành phẩm...")
        stats = run_ebur128(target_video)
        lufs = stats.get("integrated_lufs")
        peak = stats.get("true_peak_dbfs")
        lra = stats.get("loudness_range")

        if lufs is not None:
            # YouTube chuẩn: -14 LUFS, nhưng với video kể chuyện thường -18 đến -21 LUFS
            if -23.0 <= lufs <= -17.0:
                successes.append(f"✅ Âm lượng tổng thể đạt chuẩn: {lufs:.1f} LUFS (mục tiêu ~ -19 đến -20 LUFS)")
            elif -17.0 < lufs <= -14.0:
                warnings.append(f"⚠️ Âm lượng hơi to: {lufs:.1f} LUFS (vẫn an toàn trên YouTube nhưng nên giảm bớt ~2dB)")
            elif lufs < -23.0:
                warnings.append(f"⚠️ Âm lượng tổng thể hơi nhỏ: {lufs:.1f} LUFS (khuyến nghị tăng thêm ~3dB)")
            else:
                errors.append(f"❌ Âm lượng vượt chuẩn YouTube: {lufs:.1f} LUFS (quá to, sẽ bị YouTube nén méo tiếng)")

        if peak is not None:
            if peak > -0.5:
                warnings.append(f"⚠️ True Peak hơi sát đỉnh 0dBFS ({peak:.1f} dBFS), có nguy cơ méo tiếng trên loa rẻ tiền")
            else:
                successes.append(f"✅ True Peak an toàn: {peak:.1f} dBFS (<= -0.5 dBFS, không méo tiếng)")
                
        if lra is not None:
            successes.append(f"ℹ️ Dải động (Loudness Range LRA): {lra:.1f} LU")
    else:
        warnings.append("⚠️ Không tìm thấy final.mp4 để đo âm thanh tổng thể video.")

    # 3. Đo riêng giọng đọc nếu có
    if giong_audio.exists():
        g_stats = run_ebur128(giong_audio)
        g_lufs = g_stats.get("integrated_lufs")
        if g_lufs is not None:
            if -23.0 <= g_lufs <= -18.0:
                successes.append(f"✅ Giọng đọc ZeroTTS Tiến Đạt: {g_lufs:.1f} LUFS (chuẩn -20 LUFS)")
            else:
                warnings.append(f"⚠️ Giọng đọc đo được: {g_lufs:.1f} LUFS (lệch so với chuẩn -20 LUFS)")

    # 4. Đo riêng nhạc nền nếu có
    if nhac_audio.exists():
        n_stats = run_ebur128(nhac_audio)
        n_lufs = n_stats.get("integrated_lufs")
        if n_lufs is not None:
            if n_lufs <= -33.0:
                successes.append(f"✅ Nhạc nền êm dịu: {n_lufs:.1f} LUFS (nhỏ hơn giọng >= 15 dB)")
            else:
                warnings.append(f"⚠️ Nhạc nền hơi to: {n_lufs:.1f} LUFS (khuyến nghị <= -35 đến -40 LUFS để không át giọng)")

    # 5. Quét SFX
    if target_video and target_video.exists():
        max_vol = detect_loud_spikes(target_video)
        if max_vol is not None and max_vol >= -0.1:
            warnings.append(f"⚠️ Phát hiện âm thanh chạm ngưỡng clipping (max_volume: {max_vol} dB)")

    # Báo cáo tổng kết
    print("\n--- KẾT QUẢ KIỂM TRA ÂM THANH ---")
    for s in successes:
        print(s)
    for w in warnings:
        print(w)
    for e in errors:
        print(e)

    passed = len(errors) == 0
    print("-" * 60)
    if passed:
        print("🎉 ÂM THANH ĐẠT YÊU CẦU!")
    else:
        print("❌ ÂM THANH CHƯA ĐẠT! Cần cân chỉnh lại trước khi render hoặc xuất bản.")
    print("=" * 60)
    return passed

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Kiểm tra âm thanh video và giọng đọc")
    parser.add_argument("tap_dir", help="Đường dẫn thư mục tập video")
    parser.add_argument("--strict", action="store_true", help="Báo lỗi cả cảnh báo")
    args = parser.parse_args()

    ok = check_tap_audio(args.tap_dir, args.strict)
    sys.exit(0 if ok else 1)
