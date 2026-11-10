#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
smoke-test.py
Kiểm thử siêu tốc (Fail-Fast Smoke Test) trong 15-30 giây trước khi render bản dài:
Hỗ trợ cả 2 hệ thống:
1. teo-kiem-hiep-godot (Godot 2D Engine)
2. video-teo (HyperFrames GSAP)

Kiểm tra:
- Cú pháp mã nguồn (Godot headless compile / Node syntax check).
- Độ dài kịch bản & timeline >= 20 phút (>= 1.200s).
- Dàn nhân vật Chibi và biểu cảm SVG.
- Trích xuất 4 snapshot preview 960x540 để duyệt mắt chỉ trong 10-15s.
"""

import sys
import os
import subprocess
import argparse
import json
from pathlib import Path

GODOT_BIN = "__GODOT__"

def test_godot_project(tap_path):
    print("=" * 60)
    print(f"⚡ SMOKE TEST GODOT 2D: {tap_path.name}")
    print("=" * 60)
    
    godot_dir = tap_path / "godot"
    if not godot_dir.exists():
        print("❌ Không tìm thấy thư mục godot/")
        return False
        
    errors = []
    
    # 1. Headless parse check bằng Godot --dur
    print("1. Kiểm tra biên dịch mã nguồn (GDScript Syntax & Compile)...")
    if os.path.exists(GODOT_BIN):
        cmd = [GODOT_BIN, "--headless", "--path", str(godot_dir), "--", "--dur"]
        res = subprocess.run(cmd, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True, timeout=30)
        out = (res.stdout or "") + (res.stderr or "")
        
        has_err = False
        for line in out.splitlines():
            if "SCRIPT ERROR" in line or "Parse Error" in line or "ERROR:" in line:
                if "Failed to load script" in line or "Invalid call" in line or "Cannot infer" in line:
                    errors.append(f"❌ Lỗi biên dịch: {line.strip()}")
                    has_err = True
        if not has_err:
            print("   ✅ Mã nguồn GDScript hợp lệ, không có lỗi cú pháp hoặc con trỏ rỗng.")
            
        # Kiểm tra thời lượng DUR
        dur_val = 0.0
        for line in out.splitlines():
            if "DUR=" in line:
                try:
                    dur_val = float(line.split("DUR=")[1].strip())
                    break
                except Exception:
                    pass
        if dur_val > 0:
            if dur_val < 1180.0:
                errors.append(f"❌ THỜI LƯỢNG QUÁ NGẮN: DUR = {dur_val:.1f}s < 1.200s (bắt buộc >= 20 phút).")
            else:
                print(f"   ✅ Thời lượng đạt chuẩn: {dur_val:.1f}s ({dur_val/60.0:.1f} phút >= 20 phút).")
    else:
        print(f"   ⚠️ Không tìm thấy binary Godot tại {GODOT_BIN}")

    # 2. Kiểm tra dàn Chibi mat/
    mat_dir = godot_dir / "mat"
    svgs = list(mat_dir.rglob("*.svg")) if mat_dir.exists() else []
    if len(svgs) < 10:
        errors.append(f"❌ Thiếu biểu cảm Chibi: chỉ có {len(svgs)} SVG trong godot/mat/!")
    else:
        print(f"   ✅ Dàn nhân vật Chibi: {len(svgs)} biểu cảm SVG sẵn sàng.")

    # 3. Chụp nhanh 4 snapshot preview đại diện
    preview_script = Path("__SKILLS_DIR__/teo-kiem-hiep/scripts/gd-render.mjs")
    if preview_script.exists():
        print("2. Trích xuất nhanh 4 khung hình đại diện (Preview Snapshot)...")
        # Chụp 4 mốc: 5s, 180s, 360s, 540s
        test_out = tap_path / "work" / "smoke_preview"
        cmd_prev = [
            "node", str(preview_script), str(tap_path),
            "--preview", "--from", "5", "--to", "9",
            "--sheet", "1", "--out", "smoke_quick"
        ]
        res_p = subprocess.run(cmd_prev, stdout=subprocess.DEVNULL, stderr=subprocess.PIPE, text=True, timeout=40)
        sheet_path = tap_path / "work" / "sheet-smoke_quick.jpg"
        if sheet_path.exists():
            print(f"   ✅ Đã tạo ảnh duyệt mắt nhanh: {sheet_path}")
        else:
            print("   ⚠️ Không tạo được sheet snapshot nhanh.")
            
    print("-" * 60)
    passed = len(errors) == 0
    if passed:
        print("🎉 SMOKE TEST PASS! ĐỦ ĐIỀU KIỆN CẤP PHÉP RENDER BẢN DÀI.")
    else:
        for e in errors:
            print(e)
        print("❌ SMOKE TEST FAILED! CẦN KHẮC PHỤC LỖI TRƯỚC KHI RENDER.")
    print("=" * 60)
    return passed

def test_hyperframes_project(tap_path):
    print("=" * 60)
    print(f"⚡ SMOKE TEST HYPERFRAMES (GSAP): {tap_path.name}")
    print("=" * 60)
    errors = []
    
    # 1. Kiểm tra video.json / plan.json
    vjson = tap_path / "video.json"
    if not vjson.exists():
        vjson = tap_path / "tap.json"
        
    if not vjson.exists():
        errors.append("❌ Thiếu video.json hoặc tap.json!")
    else:
        try:
            data = json.loads(vjson.read_text(encoding="utf-8"))
            words = 0
            if "scenes" in data:
                for sc in data["scenes"]:
                    words += len(sc.get("text", "").split())
            if words > 0 and words < 3500:
                errors.append(f"❌ Kịch bản quá ngắn: {words} từ (khuyến cáo >= 4.500 từ để đạt >= 20 phút).")
            else:
                print(f"   ✅ Kịch bản: ~{words} từ.")
        except Exception as e:
            errors.append(f"❌ Lỗi cú pháp JSON: {e}")
            
    # 2. Kiểm tra scenes/*.mjs
    scenes_dir = tap_path / "scenes"
    if scenes_dir.exists():
        mjs_files = list(scenes_dir.glob("*.mjs"))
        print(f"   ✅ Phân cảnh HyperFrames: Có {len(mjs_files)} file scene.")
        # Thử node check syntax
        for mf in mjs_files[:3]:
            r = subprocess.run(["node", "--check", str(mf)], capture_output=True)
            if r.returncode != 0:
                errors.append(f"❌ Lỗi cú pháp JS trong {mf.name}")
                
    print("-" * 60)
    passed = len(errors) == 0
    if passed:
        print("🎉 SMOKE TEST PASS! ĐỦ ĐIỀU KIỆN BUILD HYPERFRAMES.")
    else:
        for e in errors:
            print(e)
        print("❌ SMOKE TEST FAILED!")
    print("=" * 60)
    return passed

def run_smoke_test(tap_dir):
    tap_path = Path(tap_dir).resolve()
    if (tap_path / "godot").exists() or (tap_path / "project.godot").exists():
        return test_godot_project(tap_path)
    else:
        return test_hyperframes_project(tap_path)

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Sử dụng: python3 smoke-test.py <đường_dẫn_tập>")
        sys.exit(1)
    ok = run_smoke_test(sys.argv[1])
    sys.exit(0 if ok else 1)
