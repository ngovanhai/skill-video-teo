#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
review-kich-ban.py — Soát và chấm điểm kịch bản video hoạt hình 2D
Tuân thủ Bản Phán Quyết & Quy Chuẩn Sản Xuất Tối Cao (Executive Production Directive):
1. Kiểm tra Header Metadata Hợp Đồng (# GENRE, # HOOK_TYPE, # TEO_SKIN, # TEO_SOCKET, # TEO_ROLE).
2. Chống trùng lặp 5 tập (Anti-Collision Sliding Window qua history.json).
3. Đếm từ & thời lượng (≥ 4.500 từ cho video dài ≥ 20 phút).
4. Kiểm tra Paradox Hook 45s & CTA Vàng (mời bình luận + like/đăng ký ở phút 1:00 - 1:30).
5. Đo Chỉ số Mật độ Hành động Thị giác (Visual Action Density Score - ADS) kích hoạt hanh_dong.gd.
"""

import sys
import os
import re
import json
from pathlib import Path

def log_err(msg):
    print(f"  ❌ LỖI: {msg}")

def log_warn(msg):
    print(f"  ⚠️ CẢNH BÁO: {msg}")

def log_ok(msg):
    print(f"  ✅ ĐẠT: {msg}")

VALID_GENRES = {
    "VO_DAI_SO_KEO": "Võ Đài So Kèo",
    "TRINH_THAM_KY_AN": "Trinh Thám Kỳ Án",
    "LAT_NGUOC_DINH_KIEN": "Lật Ngược Định Kiến",
    "HO_SO_MAT": "Hồ Sơ Mật",
    "HUNG_CA_BI_TRANG": "Hùng Ca Bi Tráng"
}

# Alias map cho GENRE
GENRE_ALIASES = {
    "vo_dai": "VO_DAI_SO_KEO",
    "võ đài": "VO_DAI_SO_KEO",
    "võ đài so kèo": "VO_DAI_SO_KEO",
    "vo_dai_so_keo": "VO_DAI_SO_KEO",
    "trinh_tham": "TRINH_THAM_KY_AN",
    "trinh thám": "TRINH_THAM_KY_AN",
    "trinh thám kỳ án": "TRINH_THAM_KY_AN",
    "trinh_tham_ky_an": "TRINH_THAM_KY_AN",
    "lat_su": "LAT_NGUOC_DINH_KIEN",
    "lật sử": "LAT_NGUOC_DINH_KIEN",
    "lật ngược định kiến": "LAT_NGUOC_DINH_KIEN",
    "lat_nguoc_dinh_kien": "LAT_NGUOC_DINH_KIEN",
    "ho_so_mat": "HO_SO_MAT",
    "hồ sơ mật": "HO_SO_MAT",
    "hung_ca": "HUNG_CA_BI_TRANG",
    "hùng ca": "HUNG_CA_BI_TRANG",
    "hùng ca bi tráng": "HUNG_CA_BI_TRANG",
    "hung_ca_bi_trang": "HUNG_CA_BI_TRANG"
}

VALID_HOOKS = {
    "PARADOX": "Nghịch lý gây sốc",
    "CONFLICT": "Trận chiến giữa chừng (In Media Res)",
    "INVERTED": "Đảo ngược góc nhìn định kiến",
    "SECRET": "Bí mật / Hiện vật cổ",
    "PROPHECY": "Lời sấm truyền / Lựa chọn sinh tử"
}

VALID_SKINS = {
    "teo_tieu_nhi": "Tiểu nhị quán rượu (mặc định)",
    "teo_thu_sinh": "Thư sinh áo dài xanh",
    "teo_hiep_khach": "Hiệp khách võ phục",
    "teo_lao_gia": "Quân sư / Lão gia áo giáp"
}

# Alias map cho TEO_SKIN
SKIN_ALIASES = {
    "teo_tuu_lau_base": "teo_tieu_nhi",
    "teo_ao_dai_xanh": "teo_thu_sinh",
    "teo_quan_vo": "teo_hiep_khach",
    "teo_ao_giap_chien": "teo_lao_gia",
    "teo_ao_toi_non_la": "teo_hiep_khach"
}

VALID_SOCKETS = ["none", "kinh_lup", "but_long", "gay_truc", "ho_lo_ruou", "the_bai", "quat_long_vu", "chen_ruou"]

def parse_header_metadata(lines):
    metadata = {}
    for line in lines[:30]:
        line_s = line.strip()
        if not line_s.startswith("#"):
            if line_s.startswith("##") or (line_s and not line_s.startswith("#")):
                break
            continue
        # Check patterns like # GENRE: ...
        match = re.match(r"^#\s*([A-Z_]+)\s*:\s*(.+)$", line_s, re.IGNORECASE)
        if match:
            k = match.group(1).upper()
            v = match.group(2).strip()
            metadata[k] = v
    return metadata

def check_metadata_contract(metadata):
    errors = 0
    print("\n🔍 KIỂM TRA HEADER METADATA HỢP ĐỒNG (Executive Directive):")
    
    # 1. GENRE
    genre_raw = metadata.get("GENRE", "").lower().strip()
    norm_genre = GENRE_ALIASES.get(genre_raw) or GENRE_ALIASES.get(genre_raw.replace("-", "_"))
    if not norm_genre and metadata.get("GENRE", "").upper() in VALID_GENRES:
        norm_genre = metadata.get("GENRE", "").upper()
        
    if not norm_genre:
        log_err(f"Thiếu hoặc sai # GENRE: '{metadata.get('GENRE', '')}'. Hợp lệ: {list(VALID_GENRES.keys())}")
        errors += 1
    else:
        log_ok(f"Trường phái (GENRE): {norm_genre} ({VALID_GENRES[norm_genre]})")
        metadata["_NORM_GENRE"] = norm_genre

    # 2. HOOK_TYPE
    hook_raw = metadata.get("HOOK_TYPE", "").upper().strip()
    if hook_raw not in VALID_HOOKS:
        # Check aliases
        alias_map = {"IN_MEDIA_RES": "CONFLICT", "NGHICH_LY": "PARADOX", "BI_MAT": "SECRET"}
        hook_raw = alias_map.get(hook_raw, hook_raw)
    if hook_raw not in VALID_HOOKS:
        log_err(f"Thiếu hoặc sai # HOOK_TYPE: '{metadata.get('HOOK_TYPE', '')}'. Hợp lệ: {list(VALID_HOOKS.keys())}")
        errors += 1
    else:
        log_ok(f"Kiểu mở đầu (HOOK_TYPE): {hook_raw} ({VALID_HOOKS[hook_raw]})")
        metadata["_NORM_HOOK"] = hook_raw

    # 3. TEO_SKIN
    skin_raw = metadata.get("TEO_SKIN", "").lower().strip()
    norm_skin = SKIN_ALIASES.get(skin_raw, skin_raw)
    if norm_skin not in VALID_SKINS:
        log_err(f"Thiếu hoặc sai # TEO_SKIN: '{skin_raw}'. Hợp lệ: {list(VALID_SKINS.keys())}")
        errors += 1
    else:
        log_ok(f"Trang phục Chibi Tèo (TEO_SKIN): {norm_skin} ({VALID_SKINS[norm_skin]})")
        metadata["_NORM_SKIN"] = norm_skin

    # 4. TEO_SOCKET
    socket_raw = metadata.get("TEO_SOCKET", "none").lower().strip()
    if socket_raw not in VALID_SOCKETS:
        log_warn(f"# TEO_SOCKET '{socket_raw}' chưa đăng ký trong danh mục chuẩn {VALID_SOCKETS}. Sẽ dùng mặc định.")
    else:
        log_ok(f"Đạo cụ gắn Socket (TEO_SOCKET): {socket_raw}")

    # 5. TEO_ROLE
    role_raw = metadata.get("TEO_ROLE", "").strip()
    if not role_raw:
        log_warn("Thiếu # TEO_ROLE (Vai trò của Tèo trong tập). Nên khai báo rõ để định hình lời dẫn.")
    else:
        log_ok(f"Vai trò Tèo (TEO_ROLE): {role_raw}")

    return errors == 0, metadata

def check_anti_collision(metadata):
    history_paths = [
        os.path.expanduser("__SKILLS_DIR__/teo-kiem-hiep/data/history.json"),
        os.path.expanduser("__SKILLS_DIR__/teo-kiem-hiep-godot/data/history.json"),
        os.path.expanduser("~/MuseStudio/kiem-hiep/_data/history.json")
    ]
    history_file = None
    for p in history_paths:
        if os.path.exists(p):
            history_file = p
            break

    if not history_file:
        return True

    try:
        with open(history_file, "r", encoding="utf-8") as f:
            history = json.load(f)
    except Exception:
        return True

    if not isinstance(history, list) or len(history) == 0:
        return True

    recent_5 = history[-5:]
    cur_genre = metadata.get("_NORM_GENRE")
    cur_hook = metadata.get("_NORM_HOOK")
    cur_skin = metadata.get("_NORM_SKIN")

    print("\n🔍 KIỂM TRA CHỐNG TRÙNG LẶP (Anti-Collision 5 Tập gần nhất):")
    # Check genre in last 2
    if len(recent_5) >= 1:
        last_item = recent_5[-1]
        last_genre = last_item.get("narrative", {}).get("genre")
        if last_genre and last_genre == cur_genre:
            if cur_genre != "VO_DAI_SO_KEO":
                log_warn(f"Thể loại '{cur_genre}' trùng với tập liền trước ({last_item.get('slug')}). Khuyến nghị đổi thể loại!")
            else:
                log_ok(f"Thể loại nòng cốt '{cur_genre}' được phép tối đa 2 tập liên tiếp.")
        else:
            log_ok("Thể loại kịch bản không bị trùng lặp với tập liền trước.")

    # Check hook in last 3
    if len(recent_5) >= 2:
        hooks_in_recent = [it.get("narrative", {}).get("hook_type") for it in recent_5[-2:] if it.get("narrative", {}).get("hook_type")]
        if cur_hook in hooks_in_recent:
            log_warn(f"Kiểu mở đầu '{cur_hook}' đã xuất hiện trong 2 tập gần đây. Khuyến nghị đổi sang kiểu Hook khác để tạo bất ngờ.")
        else:
            log_ok("Kiểu Hook mở đầu đảm bảo độ tươi mới so với các tập gần nhất.")

    return True

def check_action_density(raw_lines):
    full_text = " ".join(raw_lines).lower()
    
    action_keywords = {
        "chem_kiem": ["chém", "rút kiếm", "tuốt kiếm", "vung kiếm", "kiếm quang", "lưỡi thép", "đao kiếm", "đâm", "đỡ", "trảm", "tóe lửa"],
        "dap_ban": ["đập bàn", "đập nát", "đứng phắt", "chém đứt góc bàn", "vỡ tan", "thịnh nộ", "quát lớn"],
        "hoc_mau": ["thổ huyết", "hộc máu", "ôm ngực", "quỵ ngã", "kinh mạch", "trọng thương", "gục ngã"],
        "ban_cung": ["giương cung", "bắn tên", "mưa tên", "loạn tiễn", "xuyên tâm", "mũi tên", "cung nỏ"],
        "cuoi_ngua": ["cưỡi ngựa", "phi ngựa", "chiến mã", "kỵ binh", "phi nước đại", "thúc ngựa"],
        "chuong_phap": ["chưởng lực", "tụ khí", "kình lực", "chấn động", "cuồng phong", "vung quạt", "bão lốc"]
    }

    found_triggers = {}
    total_triggers = 0
    for cat, kws in action_keywords.items():
        count = sum(len(re.findall(r"\b" + re.escape(kw) + r"\b", full_text)) for kw in kws)
        if count > 0:
            found_triggers[cat] = count
            total_triggers += count

    print(f"\n⚔️ CHỈ SỐ MẬT ĐỘ HÀNH ĐỘNG THỊ GIÁC (Visual Action Density - ADS):")
    print(f"   • Tổng số động từ kích hoạt võ đạo: {total_triggers} điểm")
    for cat, cnt in found_triggers.items():
        print(f"     - Nhóm {cat}: {cnt} lần")

    if total_triggers < 12:
        log_warn(f"Mật độ hành động ({total_triggers} điểm) hơi thấp (khuyến nghị ≥ 15 điểm để Chibi liên tục diễn xuất).")
    else:
        log_ok(f"Mật độ hành động ({total_triggers} điểm) đạt chuẩn kích hoạt hoạt cảnh Chibi sống động.")

    return True

def review_godot(tap_dir):
    loi_path = os.path.join(tap_dir, "godot", "loi.txt")
    if not os.path.exists(loi_path):
        loi_path = os.path.join(tap_dir, "loi.txt")
    
    if not os.path.exists(loi_path):
        log_err(f"Không tìm thấy loi.txt trong {tap_dir}")
        return False

    with open(loi_path, "r", encoding="utf-8") as f:
        lines = f.readlines()

    errors = 0
    warnings = 0
    
    # 0. Kiểm tra Header Metadata Hợp đồng
    metadata = parse_header_metadata(lines)
    meta_ok, meta_data = check_metadata_contract(metadata)
    if not meta_ok:
        errors += 1
    else:
        check_anti_collision(meta_data)

    segments = [] # list of (ten_doan, list of cau)
    current_seg = "khoi_dau"
    current_lines = []
    raw_lines = []
    
    for line in lines:
        line_s = line.strip()
        if not line_s:
            continue
        if line_s.startswith("##"):
            if current_lines:
                segments.append((current_seg, current_lines))
                current_lines = []
            current_seg = line_s
        elif line_s.startswith("#"):
            continue
        else:
            current_lines.append(line_s)
            raw_lines.append(line_s)
            
    if current_lines:
        segments.append((current_seg, current_lines))

    print(f"\n📋 ĐÁNH GIÁ NỘI DUNG KỊCH BẢN GODOT: {os.path.basename(tap_dir)}")
    print(f"   • Số phân đoạn: {len(segments)}")
    print(f"   • Tổng số câu thoại: {len(raw_lines)}")

    # 1. Đếm từ và ước tính thời lượng
    total_words = sum(len(c.split()) for c in raw_lines)
    est_dur_min = total_words / 240.0
    print(f"   • Tổng số từ: {total_words} từ (~{est_dur_min:.1f} phút)")

    if total_words < 4500:
        log_err(f"Tổng số từ ({total_words}) quá ít, khó đạt thời lượng ≥ 20 phút (yêu cầu ≥ 4.500 từ).")
        errors += 1
    else:
        log_ok(f"Số lượng từ ({total_words} từ) đáp ứng tiêu chuẩn video dài ≥ 20 phút.")

    # 2. Kiểm tra từ cấm / gượng gạo
    forbidden = ["chương 1", "chương 2", "chương 3", "chương một", "chương hai", "chào mừng các bạn đến với video"]
    for idx, c in enumerate(raw_lines):
        cl = c.lower()
        for f_word in forbidden:
            if f_word in cl:
                log_err(f"Câu {idx+1} chứa cụm từ không tự nhiên: '{f_word}'")
                errors += 1

    # 3. Kiểm tra Hook (phân đoạn đầu tiên k01)
    if segments:
        hook_seg = segments[0]
        hook_lines = hook_seg[1]
        print(f"\n🔍 SOÁT PARADOX HOOK (Đoạn đầu {hook_seg[0]}):")
        if len(hook_lines) > 6:
            log_warn(f"Đoạn hook có {len(hook_lines)} câu (khuyến nghị ≤ 5 câu để giữ chân người xem trong 35s đầu).")
            warnings += 1
        else:
            log_ok(f"Số câu đoạn hook ({len(hook_lines)} câu) đạt chuẩn súc tích.")

        for i, hl in enumerate(hook_lines[:5]):
            words = len(hl.split())
            if words > 22:
                log_warn(f"Câu hook {i+1} dài {words} từ (khuyến nghị ≤ 18 từ/câu để nhịp dồn dập).")
                warnings += 1

    # 4. Kiểm tra Lời mời tương tác (bình luận đề tài, like, đăng ký kênh sau hook)
    if len(segments) >= 2:
        k02_lines = segments[1][1]
        k02_text = " ".join(k02_lines[:6]).lower()
        print("\n🔍 SOÁT LỜI MỜI TƯƠNG TÁC ĐẦU VIDEO (CTA VÀNG):")
        has_comment = any(k in k02_text for k in ["bình luận", "comment", "gợi ý", "ý kiến", "đánh giá"])
        has_sub = any(k in k02_text for k in ["đăng ký", "theo dõi", "subscribe", "bật chuông", "like"])
        
        if has_comment and has_sub:
            log_ok("Đã có đầy đủ lời mời bình luận đề tài + like/đăng ký kênh ngay sau hook.")
        else:
            missing = []
            if not has_comment: missing.append("mời bình luận nhân vật/đề tài")
            if not has_sub: missing.append("kêu gọi like/đăng ký kênh")
            log_err(f"Đoạn ngay sau hook thiếu: {', '.join(missing)}!")
            errors += 1

    # 5. Kiểm tra Mật độ hành động thị giác
    check_action_density(raw_lines)

    # 6. Kiểm tra CTA cuối video
    if segments:
        last_lines = segments[-1][1]
        last_text = " ".join(last_lines).lower()
        if any(k in last_text for k in ["đăng ký", "theo dõi", "bình luận", "hẹn gặp lại", "cạn ly", "nâng chén"]):
            log_ok("Đoạn kết có CTA kêu gọi tương tác và chào tạm biệt chuẩn vị Tèo Tửu Lâu.")
        else:
            log_warn("Đoạn kết chưa có CTA kêu gọi đăng ký/bình luận rõ ràng.")
            warnings += 1

    return errors == 0

def review_hyperframes(tap_dir):
    vjson_path = os.path.join(tap_dir, "video.json")
    if not os.path.exists(vjson_path):
        log_err(f"Không tìm thấy video.json trong {tap_dir}")
        return False

    with open(vjson_path, "r", encoding="utf-8") as f:
        vdata = json.load(f)

    errors = 0
    warnings = 0
    print(f"\n📋 ĐÁNH GIÁ KỊCH BẢN HYPERFRAMES: {os.path.basename(tap_dir)}")

    # Check narrative metadata
    narrative = vdata.get("narrative", {})
    if not narrative:
        log_warn("File video.json chưa có trường 'narrative' để định hình thể loại và skin Chibi.")
    else:
        log_ok(f"Thể loại: {narrative.get('genre', 'chưa rõ')} | Skin Tèo: {narrative.get('teo_skin', 'mặc định')}")

    scenes = vdata.get("scenes", [])
    if not scenes and os.path.exists(os.path.join(tap_dir, "chapters")):
        import glob
        for ch_file in sorted(glob.glob(os.path.join(tap_dir, "chapters", "*.json"))):
            with open(ch_file, "r", encoding="utf-8") as cf:
                ch_data = json.load(cf)
                scenes.extend(ch_data.get("scenes", []))
    total_scenes = len(scenes)
    print(f"   • Tổng số scenes: {total_scenes}")

    all_text = []
    for sc in scenes:
        if isinstance(sc, dict) and "say" in sc:
            all_text.append(sc["say"])
    
    total_words = sum(len(t.split()) for t in all_text)
    est_dur_min = total_words / 240.0
    print(f"   • Tổng số từ: {total_words} từ (~{est_dur_min:.1f} phút)")

    if total_words < 4500:
        log_err(f"Tổng số từ ({total_words}) quá ít, khó đạt thời lượng ≥ 20 phút.")
        errors += 1
    else:
        log_ok(f"Số lượng từ ({total_words} từ) đáp ứng tiêu chuẩn video dài ≥ 20 phút.")

    early_text = " ".join(all_text[:8]).lower()
    if any(k in early_text for k in ["bình luận", "comment"]) and any(k in early_text for k in ["đăng ký", "theo dõi", "like"]):
        log_ok("Đã có lời mời bình luận và like/đăng ký trong các scene đầu.")
    else:
        log_err("Các scene đầu (sau hook) thiếu lời mời bình luận hoặc kêu gọi like/đăng ký kênh!")
        errors += 1

    check_action_density(all_text)

    return errors == 0

def main():
    if len(sys.argv) < 2:
        print("Cách dùng: python3 review-kich-ban.py <thư-mục-tập>")
        sys.exit(1)
        
    target_dir = os.path.abspath(sys.argv[1])
    if os.path.exists(os.path.join(target_dir, "godot")) or os.path.exists(os.path.join(target_dir, "loi.txt")):
        ok = review_godot(target_dir)
    elif os.path.exists(os.path.join(target_dir, "video.json")):
        ok = review_hyperframes(target_dir)
    else:
        print(f"❌ Không nhận diện được dự án Godot hoặc HyperFrames tại {target_dir}")
        sys.exit(1)

    if ok:
        print("\n🎉 KẾT QUẢ: KỊCH BẢN ĐẠT CHUẨN ĐỂ SẢN XUẤT!")
        sys.exit(0)
    else:
        print("\n⚠️ KẾT QUẢ: KỊCH BẢN CẦN SỬA LẠI CÁC MỤC LỖI TRƯỚC KHI BẮT ĐẦU THU ÂM!")
        sys.exit(1)

if __name__ == "__main__":
    main()
