#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
check-hinh-anh.py
Kiểm tra hình ảnh, hoạt cảnh và phát hiện bẫy slide chữ tĩnh:
- Kiểm tra dàn nhân vật Chibi rig2 (godot/mat/*.svg hoặc assets/svg/).
- Quét mã nguồn (tranh.gd, phim.gd hoặc scenes/*.mjs) chống bẫy slide chữ tĩnh:
  + Cảnh phải có nhân vật diễn xuất.
  + Phải có chuyển động hoạt cảnh (tween, biến số thời gian, biến đổi tọa độ).
- Trích xuất Contact Sheet 12 khung hình đại diện (sheet-qa.jpg) qua ffmpeg để soi nhanh.
- Soát ảnh bìa Thumbnail YouTube (1280x720, < 2MB, tỷ lệ 16:9).
"""

import sys
import os
import re
import subprocess
import argparse
from pathlib import Path

def check_chibi_assets(tap_path):
    """Kiểm tra tài nguyên nhân vật Chibi rig2"""
    results = {"pass": True, "messages": []}
    
    godot_mat = tap_path / "godot" / "mat"
    svg_assets = tap_path / "assets" / "svg"
    
    mat_count = 0
    if godot_mat.exists():
        mat_count = len(list(godot_mat.rglob("*.svg")))
    elif svg_assets.exists():
        mat_count = len(list(svg_assets.rglob("*.svg")))
        
    if mat_count >= 10:
        results["messages"].append(f"✅ Dàn nhân vật Chibi phong phú: {mat_count} biểu cảm SVG đã sẵn sàng")
    elif mat_count > 0:
        results["messages"].append(f"⚠️ Dàn nhân vật Chibi hơi ít biểu cảm: {mat_count} SVG")
    else:
        results["pass"] = False
        results["messages"].append("❌ THIẾU TÀI NGUYÊN CHIBI: Không tìm thấy SVG biểu cảm trong godot/mat/! Nhân vật sẽ không hiển thị.")
        
    return results

def detect_static_slide_trap(tap_path):
    """Phát hiện bẫy slide chữ tĩnh và lỗi chữ tràn màn hình trong code hoạt cảnh"""
    results = {"pass": True, "messages": []}
    
    # Kiểm tra but.gd xem đã có hỗ trợ đa dòng (\n) chưa
    but_gd = tap_path / "godot" / "but.gd"
    if not but_gd.exists():
        but_gd = tap_path / "godot" / "chung" / "but.gd"
    if but_gd.exists():
        but_code = but_gd.read_text(encoding="utf-8", errors="ignore")
        if 's.split("\\n")' not in but_code and "s.split('\n')" not in but_code:
            results["pass"] = False
            results["messages"].append("❌ LỖI VẼ CHỮ TRÀN MÀN HÌNH: Hàm but.gd::chu() chưa hỗ trợ ngắt dòng s.split('\\n')! Sẽ làm toàn bộ chữ dồn thành 1 hàng ngang cắt ngang màn hình.")
        else:
            results["messages"].append("✅ Hệ thống vẽ chữ (but.gd): Đã hỗ trợ xuống dòng tự động s.split('\\n') an toàn.")

    # Kiểm tra Godot tranh.gd / phim.gd
    tranh_gd = tap_path / "godot" / "tranh.gd"
    phim_gd = tap_path / "godot" / "phim.gd"
    
    if tranh_gd.exists():
        content = tranh_gd.read_text(encoding="utf-8", errors="ignore")
        
        # 1. Kiểm tra gọi vẽ nhân vật
        chibi_calls = len(re.findall(r"(?:N|Ng|Nguoi)\.ve\(", content))
        if chibi_calls == 0:
            results["pass"] = False
            results["messages"].append("❌ BẪY SLIDE CHỮ TĨNH: Trong tranh.gd KHÔNG CÓ lệnh vẽ nhân vật Chibi (N.ve / Ng.ve)!")
        else:
            results["messages"].append(f"✅ Hoạt cảnh có diễn xuất Chibi: {chibi_calls} lượt gọi vẽ nhân vật trong tranh.gd")
            
        # 2. Kiểm tra các hiệu ứng động (thời gian, dao động, tween, rung, xoay)
        motion_tokens = ["sin(", "cos(", "fmod(", "clamp(", "lerp(", "tuyen_tinh", "rung", "xoay", "alpha", "scale"]
        motion_found = [tok for tok in motion_tokens if tok in content]
        if len(motion_found) >= 3:
            results["messages"].append(f"✅ Chuyển động đa dạng: Sử dụng các hiệu ứng động ({', '.join(motion_found[:4])}...)")
        else:
            results["messages"].append("⚠️ Hoạt cảnh có nguy cơ cứng/tĩnh: Ít hàm toán học tạo chuyển động mềm mại.")
            
        # 3. Tỷ lệ chữ trên màn hình
        draw_string_calls = len(re.findall(r"draw_string\(", content))
        if draw_string_calls > 15 and chibi_calls < 5:
            results["messages"].append("⚠️ CẢNH BÁO NHIỀU CHỮ: Quá nhiều draw_string so với số nhân vật Chibi, coi chừng biến thành bài thuyết trình PowerPoint!")
            
    # Kiểm tra HyperFrames / GSAP scenes
    scenes_dir = tap_path / "scenes"
    if scenes_dir.exists():
        scene_files = list(scenes_dir.glob("*.mjs"))
        if scene_files:
            results["messages"].append(f"ℹ️ Dự án HyperFrames: Có {len(scene_files)} cảnh hoạt hình")
            
    return results

def generate_contact_sheet(target_video, output_sheet, dur):
    """Trích xuất 12 khung hình đại diện trải đều chiều dài và ghép lưới 4x3"""
    if not target_video.exists() or dur <= 10:
        return False
        
    # Lấy 12 mốc thời gian cách đều
    step = dur / 13.0
    timestamps = [step * (i + 1) for i in range(12)]
    
    tmp_dir = output_sheet.parent / ".qa_frames"
    tmp_dir.mkdir(parents=True, exist_ok=True)
    frame_files = []
    
    for idx, ts in enumerate(timestamps):
        frame_file = tmp_dir / f"f_{idx:02d}.jpg"
        cmd = [
            "ffmpeg", "-y", "-ss", f"{ts:.1f}",
            "-i", str(target_video),
            "-vframes", "1",
            "-q:v", "3",
            "-vf", "scale=480:-1",
            str(frame_file)
        ]
        subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        if frame_file.exists():
            frame_files.append(frame_file)
            
    if len(frame_files) >= 12:
        # Ghép lưới 4x3 bằng ffmpeg xstack
        # [0][1][2][3]
        # [4][5][6][7]
        # [8][9][10][11]
        inputs = []
        for f in frame_files[:12]:
            inputs.extend(["-i", str(f)])
            
        layout = (
            "0_0|w0_0|w0+w1_0|w0+w1+w2_0|"
            "0_h0|w0_h0|w0+w1_h0|w0+w1+w2_h0|"
            "0_h0+h4|w0_h0+h4|w0+w1_h0+h4|w0+w1+w2_h0+h4"
        )
        filter_str = f"xstack=inputs=12:layout={layout}"
        cmd_stack = ["ffmpeg", "-y"] + inputs + ["-filter_complex", filter_str, str(output_sheet)]
        subprocess.run(cmd_stack, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
        
    # Dọn dẹp frame tạm
    for f in frame_files:
        try:
            f.unlink()
        except Exception:
            pass
    try:
        tmp_dir.rmdir()
    except Exception:
        pass
        
    return output_sheet.exists()

def check_thumbnail(tap_path):
    """Kiểm tra file thumbnail"""
    results = {"pass": True, "messages": []}
    
    thumb_paths = [
        tap_path / "thumb" / "thumb-godot.png",
        tap_path / "thumb" / "thumb.png",
        tap_path / "thumb.png"
    ]
    yt_dir = tap_path / "youtube"
    if yt_dir.exists():
        thumb_paths.extend(list(yt_dir.glob("*thumb*.png")))
        thumb_paths.extend(list(yt_dir.glob("*thumb*.jpg")))
        
    thumb = None
    for p in thumb_paths:
        if p.exists():
            thumb = p
            break
            
    if not thumb:
        results["pass"] = False
        results["messages"].append("❌ THIẾU THUMBNAIL: Chưa có ảnh bìa video!")
        return results
        
    size_mb = thumb.stat().st_size / (1024 * 1024)
    # Lấy độ phân giải bằng sips trên macOS
    cmd = ["sips", "-g", "pixelWidth", "-g", "pixelHeight", str(thumb)]
    res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    out = res.stdout
    w_m = re.search(r"pixelWidth:\s*(\d+)", out)
    h_m = re.search(r"pixelHeight:\s*(\d+)", out)
    
    w, h = 0, 0
    if w_m and h_m:
        w, h = int(w_m.group(1)), int(h_m.group(1))
        
    if w == 1280 and h == 720:
        results["messages"].append(f"✅ Ảnh bìa chuẩn nét YouTube: 1280x720 ({size_mb:.2f} MB, {thumb.name})")
    elif w == 1920 and h == 1080:
        results["messages"].append(f"✅ Ảnh bìa Full HD: 1920x1080 ({size_mb:.2f} MB, {thumb.name})")
    elif w > 0 and abs((w / h) - (16 / 9)) < 0.05:
        results["messages"].append(f"✅ Ảnh bìa chuẩn tỷ lệ 16:9: {w}x{h} ({size_mb:.2f} MB)")
    else:
        results["pass"] = False
        results["messages"].append(f"❌ KÍCH THƯỚC BÌA SAI: {w}x{h} (phải là 1280x720 hoặc 1920x1080 tỷ lệ 16:9)")
        
    if size_mb > 2.0:
        results["pass"] = False
        results["messages"].append(f"❌ DUNG LƯỢNG BÌA VƯỢT QUÁ 2MB: {size_mb:.2f} MB (YouTube chỉ chấp nhận < 2MB)")
        
    return results

def check_tap_visual(tap_dir, make_sheet=True):
    tap_path = Path(tap_dir).resolve()
    print("=" * 60)
    print(f"🎨 KIỂM TRA HÌNH ẢNH & HOẠT CẢNH: {tap_path.name}")
    print("=" * 60)
    
    all_passed = True
    
    # 1. Soát dàn Chibi
    chibi_res = check_chibi_assets(tap_path)
    if not chibi_res["pass"]:
        all_passed = False
    for m in chibi_res["messages"]:
        print(m)
        
    # 2. Phát hiện bẫy slide chữ tĩnh
    slide_res = detect_static_slide_trap(tap_path)
    if not slide_res["pass"]:
        all_passed = False
    for m in slide_res["messages"]:
        print(m)
        
    # 3. Soát Thumbnail
    thumb_res = check_thumbnail(tap_path)
    if not thumb_res["pass"]:
        all_passed = False
    for m in thumb_res["messages"]:
        print(m)
        
    # 4. Xuất Contact Sheet nếu có video
    final_video = tap_path / "renders" / "final.mp4"
    if not final_video.exists():
        final_video = tap_path / "final.mp4"
        
    if make_sheet and final_video.exists():
        # Lấy duration
        cmd = ["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "default=noprint_wrappers=1:nokey=1", str(final_video)]
        res = subprocess.run(cmd, stdout=subprocess.PIPE, text=True)
        try:
            dur = float(res.stdout.strip())
        except Exception:
            dur = 0.0
            
        sheet_out = tap_path / "sheet-qa.jpg"
        print("Đang trích xuất Contact Sheet 12 khung hình đại diện (sheet-qa.jpg)...")
        if generate_contact_sheet(final_video, sheet_out, dur):
            print(f"✅ Đã tạo bảng soi QA trực quan: {sheet_out}")
        else:
            print("⚠️ Không thể tạo Contact Sheet")
            
    print("-" * 60)
    if all_passed:
        print("🎉 HÌNH ẢNH & HOẠT CẢNH ĐẠT YÊU CẦU!")
    else:
        print("❌ HÌNH ẢNH CHƯA ĐẠT! Cần sửa lỗi trước khi xuất bản.")
    print("=" * 60)
    return all_passed

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Kiểm tra hình ảnh và hoạt cảnh video")
    parser.add_argument("tap_dir", help="Đường dẫn thư mục tập video")
    parser.add_argument("--no-sheet", action="store_true", help="Không tạo contact sheet")
    args = parser.parse_args()
    
    ok = check_tap_visual(args.tap_dir, make_sheet=not args.no_sheet)
    sys.exit(0 if ok else 1)
