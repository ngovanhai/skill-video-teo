#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
tao-storyboard.py
Tự động đọc kịch bản loi.txt, phân tích ngữ cảnh điện ảnh và sinh storyboard.json:
- Không cố định một khung hình, biến hóa linh hoạt theo nội dung câu chuyện.
- 7 phong cách bố cục điện ảnh: Chiến trận, Đối kháng tranh luận, Thư phòng/Giai thoại, 
  Sa bàn bản đồ động, Bi kịch/Bạo bệnh, Mở đầu/Thuyết thư, Khải hoàn giải oan.
- Hệ thống Vũ đạo Hành động Chibi 2D (Combat & Action Choreography):
  Tự động quét động từ hành động tiếng Việt: chém, đâm, đỡ, rút gươm, bắn tên, cưỡi ngựa,
  đập bàn, quỳ dâng thư, hộc máu thổ huyết, gục ngã, uống rượu, quạt gió lốc, phất cờ, gảy đàn.
- Điều phối chuyển động Chibi, Mascot Tèo, hiệu ứng môi trường (mưa tên, sóng nước, khói lửa).
"""

import sys
import os
import json
import re
from pathlib import Path

# Thư viện phân loại ngữ cảnh dựa trên từ khóa tiếng Việt
SCENE_TYPES = {
    "chien_tran": {
        "keywords": ["chiến", "trận", "xích bích", "thuyền", "hỏa công", "cháy", "lửa", "đánh", "quân", "cung", "tên", "tiến công", "phá tan", "đại quân", "thủy binh", "đại chiến", "truy kích", "đoạt mệnh"],
        "layout": "chien_tran",
        "cam_zoom": 1.05,
        "env": ["song_nuoc", "mua_ten", "khoi_lua"],
        "default_action": "chem_kiem"
    },
    "doi_dau": {
        "keywords": ["so sánh", "tranh luận", "la quán trung", "trần thọ", "tiểu thuyết", "chính sử", "sự thật", "dìm", "bóc tách", "đối chiếu", "ai hơn ai", "khổng minh", "mâu thuẫn", "đối lập"],
        "layout": "doi_dau",
        "cam_zoom": 1.0,
        "env": ["anh_sang_doi_lap"],
        "default_action": "doi_dau_kiem_dao"
    },
    "thu_phong": {
        "keywords": ["đàn", "khúc", "âm luật", "tiểu kiều", "thơ", "nhạc", "phong lưu", "mỉm cười", "giai thoại", "thư phòng", "phu thê", "tôn sách", "nhã nhặn", "tri âm"],
        "layout": "thu_phong",
        "cam_zoom": 1.0,
        "env": ["dan_tranh", "tram_huong", "canh_hoa_roi"],
        "default_action": "gay_dan_song_am"
    },
    "bi_kich": {
        "keywords": ["chết", "mất", "bạo bệnh", "ba khâu", "vắn số", "khóc", "tang", "thương tiếc", "nỗi đau", "di ngôn", "tuyệt mệnh", "oan", "thổ huyết", "hộc máu", "gục ngã"],
        "layout": "bi_kich",
        "cam_zoom": 1.1,
        "env": ["mua_roi", "khong_khi_u_am"],
        "default_action": "hoc_mau_guc_nga"
    },
    "sa_ban": {
        "keywords": ["nhị phân", "thiên hạ", "chiến lược", "ích châu", "kinh châu", "tây thục", "bản đồ", "địa lý", "liên minh", "phạt thục", "mã siêu", "hành quân", "bố trí"],
        "layout": "sa_ban",
        "cam_zoom": 1.0,
        "env": ["mui_ten_hanh_quan", "ban_do_co"],
        "default_action": "cuoi_ngua_phi"
    },
    "thuyen_co": {
        "keywords": ["thuyền cỏ", "mượn tên", "gió đông", "sương mù", "nhu tu khẩu", "tôn quyền", "cân bằng", "đông nam", "khổng minh vung quạt"],
        "layout": "thuyen_co",
        "cam_zoom": 1.02,
        "env": ["suong_mu_day", "ten_cam_thuyen", "quay_thuyen"],
        "default_action": "quat_long_tao_gio"
    },
    "thuyet_thu": {
        "keywords": ["tèo tửu lâu", "quý vị", "bằng hữu", "bình luận", "like", "đăng ký", "chào mừng", "tập hôm nay", "hẹn gặp lại", "chén rượu", "uống rượu"],
        "layout": "thuyet_thu",
        "cam_zoom": 1.0,
        "env": ["kinh_duong_moc", "chen_ruou_dong"],
        "default_action": "nhap_ruou_can_ly"
    }
}

# Bảng quy tắc nhận diện động từ vũ đạo hành động Chibi 2D (Chibi Action Library Rules)
ACTION_RULES = [
    {
        "type": "chem_kiem",
        "keywords": ["chém", "đâm", "đỡ", "rút gươm", "tuốt kiếm", "vung kiếm", "vung gươm", "lưỡi kiếm", "đoạt mệnh", "trảm", "kiếm quang", "thanh gươm", "gươm báu", "hạ gục", "chém đứt"],
        "shake": 4.0,
        "zoom": 1.14
    },
    {
        "type": "doi_dau_kiem_dao",
        "keywords": ["đối đầu", "giao tranh", "chạm kiếm", "so tài", "quyết đấu", "đánh nhau", "khiêu chiến", "đao kiếm", "đao quang", "giáp lá cà", "va chạm", "đối kháng", "huyết chiến"],
        "shake": 5.0,
        "zoom": 1.18
    },
    {
        "type": "ban_cung",
        "keywords": ["bắn tên", "giương cung", "mũi tên", "loạn tiễn", "mưa tên", "xạ thủ", "phóng tên", "cung thủ", "cung nỏ", "tên độc", "cung tên"],
        "shake": 2.5,
        "zoom": 1.08
    },
    {
        "type": "cuoi_ngua_phi",
        "keywords": ["cưỡi ngựa", "phi ngựa", "tuấn mã", "thúc ngựa", "kỵ binh", "xung phong", "phi nước đại", "chiến mã", "yên ngựa", "ngựa chiến", "thần mã", "đoàn kỵ"],
        "shake": 3.0,
        "zoom": 1.12
    },
    {
        "type": "dap_ban_dung_day",
        "keywords": ["đập bàn", "tức giận", "thịnh nộ", "đứng phắt dậy", "chém góc bàn", "chém bàn", "phẫn nộ", "nổi trận lôi đình", "bật dậy", "quát lớn", "đứng dậy tuốt gươm"],
        "shake": 5.5,
        "zoom": 1.2
    },
    {
        "type": "hoc_mau_guc_nga",
        "keywords": ["hộc máu", "thổ huyết", "ngã", "gục", "bạo bệnh", "chết", "ngất", "uất ức", "hận", "vắn số", "qua đời", "truy điệu", "hóa vàng", "ngã quỵ", "thảm kịch", "tuyệt mệnh"],
        "shake": 2.2,
        "zoom": 1.16
    },
    {
        "type": "quy_goi_dang_thu",
        "keywords": ["quỳ", "dâng thư", "chiếu chỉ", "thánh chỉ", "xin tha", "cầu xin", "bái tạ", "kính cẩn", "nguyện", "tấu", "dâng sớ", "phụng chỉ", "quỳ gối"],
        "shake": 0.0,
        "zoom": 1.06
    },
    {
        "type": "nhap_ruou_can_ly",
        "keywords": ["rượu", "uống rượu", "nâng chén", "cạn ly", "nhấp rượu", "chén rượu", "say", "chúc mừng", "ly biệt", "chén thù", "rượu mừng", "đại yến", "thưởng rượu"],
        "shake": 0.0,
        "zoom": 1.05
    },
    {
        "type": "quat_long_tao_gio",
        "keywords": ["quạt", "gió đông", "lốc xoáy", "phong lôi", "hô phong hoán vũ", "vung quạt", "quạt lông", "vũ phiến", "cơn gió", "cầu phong", "mượn gió"],
        "shake": 3.5,
        "zoom": 1.1
    },
    {
        "type": "phat_co_lenh",
        "keywords": ["phất cờ", "hiệu lệnh", "lệnh bài", "xuất quân", "tiến quân", "cầm quân", "điều binh", "cờ lệnh", "đại quân", "lệnh tướng", "hạ lệnh"],
        "shake": 2.8,
        "zoom": 1.1
    },
    {
        "type": "gay_dan_song_am",
        "keywords": ["đàn", "khúc", "gảy đàn", "âm luật", "tiếng đàn", "cầm thi", "cổ cầm", "khúc ngộ", "chu lang cố", "đàn tranh", "gảy khúc"],
        "shake": 0.0,
        "zoom": 1.05
    },
    {
        "type": "tu_khi_chuong",
        "keywords": ["chưởng", "nội công", "tụ khí", "phóng chưởng", "kình lực", "chấn động", "nội lực", "chưởng phong", "phát lực"],
        "shake": 4.5,
        "zoom": 1.18
    }
]

# Nhân vật chính được nhận diện tự động từ kịch bản
CHAR_MAP = {
    "chudu": ["chu du", "chu lang", "đô đốc", "công cẩn"],
    "khongminh": ["khổng minh", "gia cát lượng", "ngọa long", "thừa tướng"],
    "taothao": ["tào tháo", "mạnh đức", "tào man", "ngụy vương"],
    "tonquyen": ["tôn quyền", "trọng mưu", "ngô vương", "chúa công"],
    "tonsach": ["tôn sách", "bá phù", "tiểu bá vương"],
    "hoangcai": ["hoàng cái", "công phúc"],
    "tieukieu": ["tiểu kiều", "nhị kiều", "mỹ nhân"],
    "luubi": ["lưu bị", "huyền đức", "hán trung vương"],
    "quanvu": ["quan vũ", "vân trường", "quan công"],
    "truongphi": ["trương phi", "dực đức"],
    "laquantrung": ["la quán trung", "tiểu thuyết gia"],
    "trantho": ["trần thọ", "sử gia"],
    "teo": ["tèo", "tèo tửu lâu", "quán chủ"]
}

def analyze_segment_context(text, seg_id):
    """Phân tích văn bản để tìm ngữ cảnh điện ảnh phù hợp nhất"""
    text_lower = text.lower()
    scores = {}
    for stype, cfg in SCENE_TYPES.items():
        score = 0
        for kw in cfg["keywords"]:
            if kw in text_lower:
                score += 1
        scores[stype] = score
        
    best_type = max(scores, key=scores.get)
    if scores[best_type] == 0:
        # Mặc định theo mã phân đoạn
        if "k01" in seg_id or "k02" in seg_id or "k12" in seg_id:
            best_type = "thuyet_thu"
        elif "k05" in seg_id:
            best_type = "chien_tran"
        elif "k06" in seg_id:
            best_type = "thuyen_co"
        elif "k07" in seg_id:
            best_type = "bi_kich"
        elif "k09" in seg_id:
            best_type = "sa_ban"
        elif "k03" in seg_id:
            best_type = "thu_phong"
        else:
            best_type = "doi_dau"
            
    return best_type

def detect_actors_in_text(text, default_actor="chudu"):
    """Nhận diện nhân vật xuất hiện trong câu thoại"""
    text_lower = text.lower()
    detected = []
    for cid, names in CHAR_MAP.items():
        for n in names:
            if n in text_lower:
                if cid not in detected:
                    detected.append(cid)
                break
    if not detected:
        detected = [default_actor]
    return detected

def analyze_action_type(text, context_type, default_actor="chudu"):
    """Quét động từ hành động tiếng Việt và gán thông số camera / hiệu ứng"""
    text_lower = text.lower()
    
    # Quét theo danh sách quy tắc vũ đạo hành động
    for rule in ACTION_RULES:
        for kw in rule["keywords"]:
            if kw in text_lower:
                actors = detect_actors_in_text(text, default_actor)
                opt = {
                    "vai": actors[0] if actors else default_actor,
                    "vai1": actors[0] if actors else default_actor,
                    "vai2": actors[1] if len(actors) > 1 else ("taothao" if actors[0] != "taothao" else "chudu")
                }
                return rule["type"], opt, rule["shake"], rule["zoom"], actors
                
    # Nếu không khớp động từ rõ ràng, rơi về hành động mặc định của phân cảnh
    cfg = SCENE_TYPES.get(context_type, SCENE_TYPES["doi_dau"])
    def_type = cfg.get("default_action", "chem_kiem")
    actors = detect_actors_in_text(text, default_actor)
    opt = {
        "vai": actors[0] if actors else default_actor,
        "vai1": actors[0] if actors else default_actor,
        "vai2": actors[1] if len(actors) > 1 else ("taothao" if actors[0] != "taothao" else "chudu")
    }
    shake = 1.5 if ("hỏa công" in text_lower or "đánh tan" in text_lower or "thất bại" in text_lower) else 0.0
    zoom = cfg.get("cam_zoom", 1.0)
    return def_type, opt, shake, zoom, actors

def build_storyboard(tap_dir):
    tap_path = Path(tap_dir).resolve()
    loi_file = tap_path / "godot" / "loi.txt"
    if not loi_file.exists():
        loi_file = tap_path / "loi.txt"
        
    if not loi_file.exists():
        print(f"❌ Không tìm thấy loi.txt tại {tap_path}")
        return None
        
    voice_json_file = tap_path / "godot" / "voice" / "voice.json"
    voice_durations = {}
    if voice_json_file.exists():
        try:
            vdata = json.loads(voice_json_file.read_text(encoding="utf-8"))
            voice_durations = {k: v.get("dur", 3.0) for k, v in vdata.get("lines", {}).items()}
        except Exception:
            pass
            
    # Đọc loi.txt
    lines_raw = loi_file.read_text(encoding="utf-8").split("\n")
    segments = []
    current_seg = {"id": "k01", "name": "Mở đầu", "lines": []}
    
    for line in lines_raw:
        line_s = line.strip()
        if not line_s:
            continue
        if line_s.startswith("## "):
            if current_seg["lines"]:
                segments.append(current_seg)
            parts = line_s[3:].split("|")
            name_part = parts[0].strip()
            name_tokens = name_part.split()
            seg_id = name_tokens[0] if name_tokens else "k00"
            seg_name = " ".join(name_tokens[1:]) if len(name_tokens) > 1 else name_part
            current_seg = {"id": seg_id, "name": seg_name, "lines": []}
        elif line_s.startswith("["):
            m = re.match(r"\[([a-zA-Z0-9_-]+)\]\s*(.*)", line_s)
            if m:
                lid = m.group(1)
                ltext = m.group(2)
                current_seg["lines"].append({"id": lid, "text": ltext, "dur": voice_durations.get(lid, len(ltext.split()) / 4.1)})
                
    if current_seg["lines"]:
        segments.append(current_seg)
        
    print(f"🎬 Đã nạp {len(segments)} phân đoạn kịch bản.")
    
    # Parse Header Metadata Hợp Đồng (Executive Directive)
    metadata = {
        "GENRE": "LAT_NGUOC_DINH_KIEN",
        "HOOK_TYPE": "PARADOX",
        "TEO_SKIN": "teo_tieu_nhi",
        "TEO_SOCKET": "none",
        "TEO_ROLE": "Chưởng quầy Tèo Tửu Lâu"
    }
    for line in lines_raw[:30]:
        line_s = line.strip()
        m = re.match(r"^#\s*([A-Z_]+)\s*:\s*(.+)$", line_s, re.IGNORECASE)
        if m:
            metadata[m.group(1).upper()] = m.group(2).strip()

    # Tạo Storyboard chi tiết với hệ thống vũ đạo hành động Chibi 2D
    storyboard = {
        "title": tap_path.name,
        "metadata": metadata,
        "segments": []
    }
    
    total_time = 0.0
    for seg_idx, seg in enumerate(segments):
        seg_text = " ".join(l["text"] for l in seg["lines"])
        ctx_type = analyze_segment_context(seg_text, seg["id"])
        cfg = SCENE_TYPES[ctx_type]
        
        seg_dur = sum(l["dur"] + 0.7 for l in seg["lines"]) + 1.6
        t_start = total_time
        t_end = t_start + seg_dur
        total_time = t_end
        
        # Thiết kế các shot (cảnh quay nhỏ) trong phân đoạn
        shots = []
        shot_time = t_start
        for l_idx, line in enumerate(seg["lines"]):
            l_dur = line["dur"] + 0.7
            
            # Chọn hành động Mascot Tèo
            if l_idx == 0:
                teo_action = "di" if seg_idx == 0 else "chem" # gõ kinh đường mộc
            elif "bình luận" in line["text"].lower() or "like" in line["text"].lower() or "đăng ký" in line["text"].lower():
                teo_action = "votay"
            elif "oan" in line["text"].lower() or "thực sự" in line["text"].lower():
                teo_action = "omdau"
            elif "chiến" in line["text"].lower() or "thuyền" in line["text"].lower() or "trận" in line["text"].lower():
                teo_action = "chi"
            else:
                teo_action = "chi" if l_idx % 2 == 1 else "cam"
                
            # Phân tích vũ đạo hành động Chibi cho nhân vật trong shot
            act_type, act_opt, cam_shake, cam_zoom, actors = analyze_action_type(line["text"], ctx_type)
            
            shot = {
                "line_id": line["id"],
                "text": line["text"],
                "t0": round(shot_time, 2),
                "dur": round(l_dur, 2),
                "action_type": act_type,
                "action_opt": act_opt,
                "actors": actors,
                "teo_action": teo_action,
                "camera": {
                    "zoom": round(cam_zoom + (0.04 if l_idx % 3 == 1 else 0.0), 2),
                    "shake": round(cam_shake, 2)
                }
            }
            shots.append(shot)
            shot_time += l_dur
            
        storyboard["segments"].append({
            "seg_id": seg["id"],
            "name": seg["name"],
            "context": ctx_type,
            "layout": cfg["layout"],
            "t0": round(t_start, 2),
            "t1": round(t_end, 2),
            "dur": round(seg_dur, 2),
            "env_effects": cfg["env"],
            "shots": shots
        })
        
    out_file = tap_path / "godot" / "storyboard.json"
    out_file.write_text(json.dumps(storyboard, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"✅ Đã tạo storyboard điện ảnh kèm vũ đạo hành động Chibi: {out_file}")
    return storyboard

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Sử dụng: python3 tao-storyboard.py <đường_dẫn_tập>")
        sys.exit(1)
    build_storyboard(sys.argv[1])
