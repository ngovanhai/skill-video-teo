#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
gen-hoat-anh.py
Sinh mã hoạt cảnh Godot (tranh.gd và phim.gd) từ storyboard.json:
- Nhúng Hệ Thống Vũ Đạo Hành Động Chibi 2D (hanh_dong.gd):
  + Chém kiếm có vệt sáng hình cung & tia lửa (chem_kiem)
  + Đối đầu đao kiếm va chạm tóe lửa chớp nháy (doi_dau_kiem_dao)
  + Giương cung kéo căng dây bắn tên đạn đạo (ban_cung)
  + Cưỡi tuấn mã phi nước đại bụi mù tung bay (cuoi_ngua_phi)
  + Đập bàn đứng dậy tuốt gươm chém góc bàn (dap_ban_dung_day)
  + Ôm ngực ho khụ khụ thổ huyết gục ngã (hoc_mau_guc_nga)
  + Quỳ gối dâng cuộn chiếu thư phát sáng (quy_goi_dang_thu)
  + Nâng chén rượu cạn ly mỉm cười sảng khoái (nhap_ruou_can_ly)
  + Vung quạt lông hạc tạo lốc xoáy gió (quat_long_tao_gio)
  + Phất cờ lệnh xuất quân (phat_co_lenh)
  + Gảy đàn phát sóng âm kiếm khí (gay_dan_song_am)
  + Tụ khí phóng chưởng nội công (tu_khi_chuong)
- Mascot Tèo di động, diễn xuất biểu cảm theo từng beat thoại.
- Hoạt cảnh động phong phú: Mưa tên lửa Xích Bích, sóng nước Trường Giang, 
  rèm lụa đàn tranh thư phòng, sương mù thuyền cỏ, mưa rơi Ba Khâu, sa bàn chiến lược.
- Chống tuyệt đối bẫy slide chữ tĩnh.
"""

import sys
import os
import shutil
import json
from pathlib import Path

def generate_dynamic_tranh_code():
    """Tạo mã GDScript cực kỳ sinh động cho tranh.gd tích hợp hanh_dong.gd"""
    code = '''extends Node2D
# tranh.gd — HỆ THỐNG HOẠT CẢNH ĐIỆN ẢNH ĐỘNG & VŨ ĐẠO HÀNH ĐỘNG CHIBI 2D
# Sinh bởi skill hoat-anh-kich-ban: Tự động biến hóa hoạt cảnh theo từng kịch bản.

const B := preload("res://but.gd")
const Ng := preload("res://nguoi.gd")
const HD := preload("res://hanh_dong.gd")

const CX := 880.0
const CY := 410.0

var T := 0.0
var F := 1.0
var canh := ""
var lt := 0.0
var mode := "lua"
var phim_ref: Node = null

# Dữ liệu hạt mưa tên, tàn lửa, lá rơi
var arrows := []
var embers := []
var rain_drops := []

func _init() -> void:
	# Khởi tạo 24 mũi tên bay Xích Bích
	for i in 24:
		arrows.append({
			"x": float((i * 97) % 1800),
			"y": float(100 + (i * 37) % 500),
			"sp": float(650 + (i * 43) % 400),
			"seed": float(i * 1.618)
		})
	# Khởi tạo 40 tàn lửa hỏa công
	for i in 40:
		embers.append({
			"x": float(700 + (i * 31) % 900),
			"y": float(400 + (i * 29) % 350),
			"sp_y": float(80 + (i * 19) % 120),
			"r": float(2.0 + (i % 4)),
			"seed": float(i * 3.14)
		})
	# Khởi tạo 50 giọt mưa Ba Khâu
	for i in 50:
		rain_drops.append({
			"x": float((i * 47) % 1760),
			"y": float((i * 61) % 800),
			"sp": float(700 + (i * 23) % 300)
		})

func ve(p: Node, t: float, c: String, l_time: float, m: String) -> void:
	phim_ref = p
	T = t
	canh = c
	lt = l_time
	mode = m
	queue_redraw()

func _draw() -> void:
	match canh:
		"hook": c_hook()
		"quay_bien_kinh": c_doi_dau_sach_su()
		"chu_du_that": c_thu_phong_dan_tranh()
		"an_1_troi_sinh_du": c_an_1_troi_sinh_du()
		"an_2_xich_bich": c_xich_bich_hoa_cong()
		"an_2_mu_gio_thuyen_co": c_thuyen_co_muon_ten()
		"an_3_ba_khau": c_bi_kich_ba_khau()
		"an_4_chai_chi": c_hon_su_thuong_huong()
		"an_5_nhi_phan_thien_ha": c_sa_ban_nhi_phan()
		"vi_sao_dim_chu_du": c_la_quan_trung_viet_su()
		"tra_lai_cong_bang": c_khai_hoan_giai_oan()
		"ket_oi": c_ket_thuc_cta()
		_: c_xich_bich_hoa_cong()

# -------------------------------------------------------------
# 1. HOOK: VẠN CỔ KỲ OAN — CHU DU GIÁP BẠC TUỐT GƯƠM VUNG KIẾM KHÍ
# -------------------------------------------------------------
func c_hook() -> void:
	# Bầu trời đêm rực lửa chiến trận
	troi_dem_lua()
	ve_song_nuoc(Color("162436"), 0.5)
	
	# Hào quang công lý
	var p_pulse := sin(T * 4.0) * 15.0
	draw_circle(Vector2(CX, CY - 20), 160 + p_pulse, Color("ffe082", 0.15))
	draw_circle(Vector2(CX, CY - 20), 110, Color("fff8e1", 0.25))
	
	# Chu Du đứng oai nghiêm tuốt kiếm chém ra vệt sáng hình cung (HD.chem_kiem)
	HD.chem_kiem(self, Vector2(CX, CY + 140), 1.0, T, {"vai": "chudu", "F": 135.0, "col": Color("ff8f00"), "hot": Color("fff9c4")})
	
	# Gia Cát Lượng mờ ảo phía sau
	Ng.ve(self, "khongminh", Vector2(CX + 380, CY + 120), 110, "dung", "cuoi", T, -1.0, false, 0.0, 0.6)
	# Tào Tháo bên kia chiến tuyến
	Ng.ve(self, "taothao", Vector2(CX - 380, CY + 120), 115, "dung", "gian", T, 1.0, false, 0.0, 0.7)
	
	# Tiêu đề dồn dập
	B.chu(self, "CHU DU BỊ DÌM OAN HAY HẸP HÒI TỨC CHẾT?", Vector2(CX, 110), 46, Color("fff8e1"), 2, 1.0, Color("b71c1c"), 5)
	B.chu(self, "BÓC TÁCH TOÀN BỘ SỰ THẬT LỊCH SỬ TAM QUỐC", Vector2(CX, 165), 24, Color("ffe082"), 1)

# -------------------------------------------------------------
# 2. ĐỐI ĐẦU: TIỂU THUYẾT (LA QUÁN TRUNG) VS CHÍNH SỬ (TRẦN THỌ)
# -------------------------------------------------------------
func c_doi_dau_sach_su() -> void:
	draw_rect(Rect2(0, 0, 1760, 820), Color("f5edd6"))
	B.nhu(self, Rect2(40, 40, 1680, 740), 80, 1.0, 0.3)
	
	# Nửa trái: Tam Quốc Diễn Nghĩa (Màu đỏ son)
	draw_rect(Rect2(80, 80, 680, 660), Color("8c2d19", 0.12))
	draw_rect(Rect2(80, 80, 680, 660), Color("8c2d19"), false, 3.0)
	B.chu(self, "TAM QUỐC DIỄN NGHĨA", Vector2(420, 140), 32, Color("8c2d19"), 2)
	B.chu(self, "(TIỂU THUYẾT 7 THỰC 3 HƯ)", Vector2(420, 180), 20, Color("5c2214"), 1)
	B.chu(self, "• Khắc họa Chu Du hẹp hòi, đố kỵ\\n• 3 lần bị Gia Cát Lượng chọc tức\\n• Uất ức than trời rồi thổ huyết chết", Vector2(420, 630), 22, Color("2b1810"), 1)

	# Nửa phải: Tam Quốc Chí (Chính Sử Trần Thọ)
	draw_rect(Rect2(1000, 80, 680, 660), Color("214d35", 0.12))
	draw_rect(Rect2(1000, 80, 680, 660), Color("214d35"), false, 3.0)
	B.chu(self, "TAM QUỐC CHÍ (CHÍNH SỬ)", Vector2(1340, 140), 32, Color("214d35"), 2)
	B.chu(self, "(TRẦN THỌ SOẠN — BÙI TÙNG CHI CHÚ)", Vector2(1340, 180), 20, Color("143323"), 1)
	B.chu(self, "• Tính tình hào sảng, độ lượng bậc nhất\\n• Tổng tư lệnh đại thắng Xích Bích\\n• Mất vì bạo bệnh trên đường phạt Thục", Vector2(1340, 630), 22, Color("14241b"), 1)
	
	# Vũ đạo đối đầu đao kiếm tóe lửa ở giữa hai đại sử gia (HD.doi_dau_kiem_dao)
	HD.doi_dau_kiem_dao(self, Vector2(420, 480), Vector2(1340, 480), T, {"vai1": "khongminh", "vai2": "chudu", "F1": 115.0, "F2": 120.0})
	
	# Biểu tượng VS rực lửa ở giữa
	var pulse := sin(T * 6.0) * 4.0
	draw_circle(Vector2(CX, 380), 55 + pulse, Color("d32f2f"))
	draw_circle(Vector2(CX, 380), 48, Color("ffebee"))
	B.chu(self, "VS", Vector2(CX, 382), 40, Color("b71c1c"), 2)

# -------------------------------------------------------------
# 3. THƯ PHÒNG GIANG ĐÔNG: KHÚC HỮU NGỘ CHU LANG CỐ
# -------------------------------------------------------------
func c_thu_phong_dan_tranh() -> void:
	# Nền thư phòng ấm áp, rèm lụa bồng bềnh
	draw_rect(Rect2(0, 0, 1760, 820), Color("fbf5e8"))
	
	# Rèm lụa đung đưa hai bên
	var rem_sw := sin(T * 2.0) * 12.0
	draw_rect(Rect2(40 + rem_sw, 0, 180, 820), Color("b8352a", 0.15))
	draw_rect(Rect2(1540 - rem_sw, 0, 180, 820), Color("b8352a", 0.15))
	
	B.chu(self, "“KHÚC HỮU NGỘ, CHU LANG CỐ”", Vector2(CX, 100), 40, Color("8c2d19"), 2)
	B.chu(self, "Khúc nhạc dẫu sai một nốt nhỏ, Chu Lang cũng ngoảnh lại mỉm cười", Vector2(CX, 150), 22, Color("6b4c35"), 1)
	
	# Tiểu Kiều ngồi gảy đàn phát sóng âm kiếm khí (HD.gay_dan_song_am)
	HD.gay_dan_song_am(self, Vector2(550, 500), T, {"vai": "tieukieu", "F": 105.0})
	
	# Chu Du ngồi nâng chén rượu cạn ly mỉm cười (HD.nhap_ruou_can_ly)
	HD.nhap_ruou_can_ly(self, Vector2(1000, 500), T, {"vai": "chudu", "F": 115.0})
	
	# Tôn Sách đứng sau vỗ tay tán thưởng
	Ng.ve(self, "tonsach", Vector2(1320, 520), 120, "votay", "tu-tin", T, -1.0, false)
	
	# Thẻ thông tin tài năng
	draw_rect(Rect2(780, 580, 680, 140), Color("fff8e1"))
	draw_rect(Rect2(780, 580, 680, 140), Color("c9a24a"), false, 2.5)
	B.chu(self, "• Xuất thân đại danh môn Lư Giang, tinh thông âm luật tuyệt đỉnh\\n• Cùng Tôn Sách bình định Giang Đông, được tôn xưng “Chu Lang”\\n• Di ngôn Tôn Sách: “Việc ngoài không quyết, ắt phải hỏi Chu Du!”", Vector2(1120, 645), 20, Color("2b1d14"), 1)

# -------------------------------------------------------------
# 3b. ĐẠI ÁN 1: CÂU THAN “TRỜI SINH DU SAO CÒN SINH LƯỢNG”
# -------------------------------------------------------------
func c_an_1_troi_sinh_du() -> void:
	draw_rect(Rect2(0, 0, 1760, 820), Color("1a2430"))
	troi_dem_lua()
	
	B.chu(self, "ĐẠI ÁN THỨ NHẤT: CÂU THAN “TRỜI SINH DU SAO CÒN SINH LƯỢNG”", Vector2(CX, 95), 36, Color("ffe082"), 2, 1.0, Color("b71c1c"), 4)
	
	# Chu Du tuốt kiếm chém vệt sáng thanh lam (HD.chem_kiem)
	HD.chem_kiem(self, Vector2(CX - 280, 510), 1.0, T, {"vai": "chudu", "F": 125.0, "col": Color("00e5ff"), "hot": Color("ffffff")})
	
	# Gia Cát Lượng vung quạt lông hạc tạo lốc xoáy (HD.quat_long_tao_gio)
	HD.quat_long_tao_gio(self, Vector2(CX + 280, 510), -1.0, T, {"vai": "khongminh", "F": 120.0})
	
	# Bảng vạch trần sự thật
	draw_rect(Rect2(200, 610, 1360, 135), Color("000000", 0.85))
	draw_rect(Rect2(200, 610, 1360, 135), Color("ffd54f"), false, 2.5)
	B.chu(self, "SỰ THẬT CHÍNH SỬ: CÂU NÓI HƯ CẤU 100% CỦA TIỂU THUYẾT!\\n• Chu Du hơn Khổng Minh 6 tuổi. Thời Xích Bích, Chu Du đã là Đô đốc thống soái danh chấn Hoa Hạ.\\n• Khổng Minh lúc đó chỉ là quân sư ngoại giao mới xuất sơn — hai người chưa từng đối đầu ghen ghét!\\n• Tam Quốc Chí khẳng định: Chu Du tính tình độ lượng hào sảng, ai ai cũng mến phục kính trọng!", Vector2(CX, 675), 21, Color("fff8e1"), 1)

# -------------------------------------------------------------
# 4. ĐẠI CHIẾN XÍCH BÍCH: HỎA CÔNG LIÊN HOÀN VẠN THUYỀN BỐC CHÁY
# -------------------------------------------------------------
func c_xich_bich_hoa_cong() -> void:
	troi_dem_lua()
	ve_song_nuoc(Color("1a2e3b"), 1.0)
	
	# Hạm đội Tào Tháo bên phải (bốc cháy ngùn ngụt)
	for b in 3:
		var bx := 1150.0 + b * 190.0
		var by := 420.0 + (b % 2) * 50.0
		ve_thuyen_chien(bx, by, -1.0, Color("3e2723"), true)
		
	# Mưa tên lửa bay vút từ trái sang phải
	ve_mua_ten_lua()
	
	# Chiến thuyền Đông Ngô bên trái dẫn đầu xông tới
	var ship_bob := sin(T * 3.5) * 8.0
	ve_thuyen_chien(460.0, 520.0 + ship_bob, 1.0, Color("5d4037"), false)
	
	# Hoàng Cái giương cung bắn tên lửa tiên phong (HD.ban_cung)
	HD.ban_cung(self, Vector2(300, 510 + ship_bob), 1.0, T, {"vai": "hoangcai", "F": 105.0})
	
	# Chu Du đứng đài chỉ huy phất cờ lệnh xuất quân (HD.phat_co_lenh)
	HD.phat_co_lenh(self, Vector2(560, 480 + ship_bob), 1.0, T, {"vai": "chudu", "F": 115.0})
	
	# Tào Tháo tháo chạy hoảng loạn ở góc xa
	Ng.ve(self, "taothao", Vector2(1580, 390), 95, "chay", "hoang-hot", T, 1.0, false)

	# Bảng chỉ huy thực sự
	B.chu(self, "ĐẠI ÁN THỨ HAI: AI LÀ TỔNG TƯ LỆNH HỎA CÔNG XÍCH BÍCH?", Vector2(CX, 80), 38, Color("fff8e1"), 2, 1.0, Color("b71c1c"), 5)
	draw_rect(Rect2(240, 660, 1280, 85), Color("000000", 0.7))
	draw_rect(Rect2(240, 660, 1280, 85), Color("ff6f00"), false, 2.0)
	B.chu(self, "SỰ THẬT CHÍNH SỬ: Kế sách hỏa công do Hoàng Cái hiến dâng & Chu Du phê duyệt chỉ huy!\\n3 vạn quân Giang Đông đánh tan 20 vạn quân Tào — Lưu Bị & Khổng Minh chỉ tham gia truy kích tàn quân!", Vector2(CX, 700), 21, Color("ffe082"), 1)

# -------------------------------------------------------------
# 5. BÓC TÁCH THUYỀN CỎ MƯỢN TÊN & GIÓ ĐÔNG NAM
# -------------------------------------------------------------
func c_thuyen_co_muon_ten() -> void:
	# Nền sông Trường Giang sáng sớm mù mịt sương
	draw_rect(Rect2(0, 0, 1760, 820), Color("1e2a38"))
	ve_song_nuoc(Color("16222e"), 0.4)
	
	# Lớp sương mù dày đặc cuộn trôi
	for s in 5:
		var sx := fmod(T * 40.0 + s * 400.0, 2200.0) - 200.0
		var sy := 150.0 + s * 90.0
		draw_circle(Vector2(sx, sy), 180, Color("cfd8dc", 0.12))
		
	# Khổng Minh đứng đầu thuyền vung quạt lông hạc tạo lốc xoáy (HD.quat_long_tao_gio)
	HD.quat_long_tao_gio(self, Vector2(380, 480), 1.0, T, {"vai": "khongminh", "F": 120.0})
	
	# Thuyền rơm hứng tên của Tôn Quyền (Nhu Tu Khẩu năm 213)
	var rot_tilt := sin(T * 2.0) * 0.06
	var tx := CX + 180.0
	var ty := 480.0
	draw_set_transform(Vector2(tx, ty), rot_tilt, Vector2.ONE)
	
	var hull := PackedVector2Array([Vector2(-240, 40), Vector2(240, 40), Vector2(280, -30), Vector2(-280, -30)])
	draw_colored_polygon(hull, Color("4e342e"))
	for r in 10:
		var rx := -200 + r * 45
		draw_rect(Rect2(rx, -70, 36, 45), Color("8d6e63"))
		for a in 3:
			draw_line(Vector2(rx + 10 + a * 8, -60), Vector2(rx + a * 8 - 25, -95), Color("d7ccc8"), 2.0)
			
	# Tôn Quyền bình tĩnh chỉ huy quay thuyền
	Ng.ve(self, "tonquyen", Vector2(0, -30), 115, "chi", "tu-tin", T, 1.0, false)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	
	B.chu(self, "SỰ THẬT: “THUYỀN CỎ MƯỢN TÊN” LÀ CỦA TÔN QUYỀN NĂM 213!", Vector2(CX, 85), 36, Color("fff8e1"), 2, 1.0, Color("0277bd"), 4)
	
	# Bảng phân tích so sánh
	draw_rect(Rect2(200, 620, 1360, 120), Color("0d1b2a", 0.85))
	draw_rect(Rect2(200, 620, 1360, 120), Color("29b6f6"), false, 2.5)
	B.chu(self, "• Diễn ra tại Nhu Tu Khẩu (5 năm sau Xích Bích): Tôn Quyền đi thị sát bị quân Tào bắn tên nghiêng thuyền.\\n• Tôn Quyền bình tĩnh cho quay ngược mạn thuyền để tên bắn đều hai bên lấy lại thăng bằng rồi rút lui an toàn!\\n• La Quán Trung đã đem trọn vẹn sự kiện này gắn vào nhân vật Gia Cát Lượng hư cấu!", Vector2(CX, 675), 21, Color("e1f5fe"), 1)

# -------------------------------------------------------------
# 6. BI KỊCH BA KHÂU: ÔM NGỰC THỔ HUYẾT GỤC NGÃ
# -------------------------------------------------------------
func c_bi_kich_ba_khau() -> void:
	# Không gian ảm đạm u uất, mưa phùn rơi
	draw_rect(Rect2(0, 0, 1760, 820), Color("1a181b"))
	
	# Mưa rơi Ba Khâu
	for p in rain_drops:
		var py = fmod(float(p["y"]) + T * float(p["sp"]), 820.0)
		var px = fmod(float(p["x"]) - T * 120.0, 1760.0)
		if px < 0: px += 1760.0
		draw_line(Vector2(px, py), Vector2(px - 8, py + 22), Color("78909c", 0.45), 1.5)
		
	B.chu(self, "ĐẠI ÁN THỨ BA: CHU DU THỰC SỰ MẤT VÌ BẠO BỆNH TẠI BA KHÂU", Vector2(CX, 85), 36, Color("eceff1"), 2, 1.0, Color("37474f"), 4)
	
	# Giường bệnh Ba Khâu
	draw_rect(Rect2(320, 480, 520, 70), Color("3e2723"))
	draw_rect(Rect2(310, 460, 540, 25), Color("cfd8dc"))
	
	# Chu Du ôm ngực ho khụ khụ thổ huyết gục ngã (HD.hoc_mau_guc_nga)
	HD.hoc_mau_guc_nga(self, Vector2(580, 470), T, {"vai": "chudu", "F": 110.0})
	
	# Tôn Quyền mặc tang phục quỳ gục ôm đầu khóc than thảm thiết
	Ng.ve(self, "tonquyen", Vector2(980, 510), 120, "cui", "khoc", T, -1.0, false)
	# Trình Phổ và Hoàng Cái đau đớn phía sau
	Ng.ve(self, "trinhpho", Vector2(1240, 500), 115, "omdau", "buon", T, -1.0, false)
	
	# Khung trích dẫn lịch sử đẫm nước mắt của Tôn Quyền
	draw_rect(Rect2(240, 610, 1280, 140), Color("000000", 0.8))
	draw_rect(Rect2(240, 610, 1280, 140), Color("ef5350"), false, 2.5)
	B.chu(self, "TÔN QUYỀN MẶC TANG PHỤC KHÓC THAN XÉ LÒNG TRƯỚC VĂN VÕ:\\n“CÔNG CẨN CÓ TÀI THỐNG SOÁI AN BANG, KHÔNG CÓ CÔNG CẨN, TA SAO CÓ THỂ XƯNG ĐẾ!”\\n• Chu Du hy sinh ở tuổi 36 vì vết thương cũ tái phát và bạo bệnh trên đường chuẩn bị phạt Thục — trọn đời tận trung!", Vector2(CX, 675), 21, Color("ffebee"), 1)

# -------------------------------------------------------------
# 7. HÔN SỰ TÔN THƯỢNG HƯƠNG & TÔN QUYỀN ĐẬP BÀN
# -------------------------------------------------------------
func c_hon_su_thuong_huong() -> void:
	draw_rect(Rect2(0, 0, 1760, 820), Color("fbf3e4"))
	B.chu(self, "ĐẠI ÁN THỨ TƯ: VỤ ÁN HÔN SỰ TÔN THƯỢNG HƯƠNG", Vector2(CX, 85), 38, Color("6a1b9a"), 2)
	
	# Tôn Quyền tức giận đập mạnh tay xuống bàn, đứng dậy chém góc bàn (HD.dap_ban_dung_day)
	HD.dap_ban_dung_day(self, Vector2(500, 500), T, {"vai": "tonquyen", "F": 120.0})
	
	# Tôn Thượng Hương quận chúa tuốt kiếm uy phong chặn hậu
	Ng.ve(self, "tieukieu", Vector2(980, 490), 115, "dangdao", "quyet-tam", T, -1.0, false)
	
	# Chu Du dẫn kỵ binh truy kích dừng lại tôn trọng
	Ng.ve(self, "chudu", Vector2(1360, 490), 125, "dung", "tram-ngam", T, -1.0, false)
	
	draw_rect(Rect2(240, 610, 1280, 130), Color("ffffff", 0.9))
	draw_rect(Rect2(240, 610, 1280, 130), Color("8e24aa"), false, 2.5)
	B.chu(self, "SỰ THẬT: Kế sách gả em gái là do đích thân TÔN QUYỀN chủ trương để gắn kết liên minh!\\n• Chu Du chỉ hiến kế giữ Lưu Bị tại Kiến Nghiệp, cung cấp mỹ nữ cung điện để kiềm chế dã tâm.\\n• Hoàn toàn không có chuyện Chu Du “mất cả chì lẫn chài” như La Quán Trung thêm thắt để châm biếm!", Vector2(CX, 670), 21, Color("212121"), 1)

# -------------------------------------------------------------
# 8. SA BÀN CHIẾN LƯỢC: CƯỠI TUẤN MÃ PHI NƯỚC ĐẠI
# -------------------------------------------------------------
func c_sa_ban_nhi_phan() -> void:
	# Sa bàn da dê cổ phong
	draw_rect(Rect2(0, 0, 1760, 820), Color("e8d8b8"))
	draw_rect(Rect2(60, 60, 1640, 700), Color("4e342e"), false, 4.0)
	
	B.chu(self, "ĐẠI ÁN THỨ NĂM: CHIẾN LƯỢC THIÊN TÀI “NHỊ PHÂN THIÊN HẠ”", Vector2(CX, 95), 38, Color("1a237e"), 2)
	
	# Cứ điểm Tào Tháo và Tây Thục
	draw_circle(Vector2(CX, 260), 45, Color("c62828"))
	B.chu(self, "TRUNG NGUYÊN\\n(TÀO THÁO)", Vector2(CX, 255), 18, Color("ffffff"), 2)
	
	draw_circle(Vector2(420, 440), 42, Color("2e7d32"))
	B.chu(self, "ÍCH CHÂU\\n(LƯU CHƯƠNG)", Vector2(420, 435), 17, Color("ffffff"), 2)
	
	# Chu Du cưỡi tuấn mã phi nước đại dẫn quân phạt Thục (HD.cuoi_ngua_phi)
	HD.cuoi_ngua_phi(self, Vector2(1080, 500), -1.0, T, {"vai": "chudu", "F": 115.0})
	
	draw_rect(Rect2(200, 610, 1360, 130), Color("ffffff", 0.92))
	draw_rect(Rect2(200, 610, 1360, 130), Color("283593"), false, 2.5)
	B.chu(self, "TẦM NHÌN VƯỢT TRƯỚC THỜI ĐẠI CỦA CHU DU:\\n• Chiếm Ích Châu, sáp nhập Tây Thục, liên minh Mã Siêu để hình thành thế cục Hai Nước chia đôi giang sơn!\\n• Khác với “Tam Phân” của Khổng Minh để Thục thế yếu, Nhị Phân của Chu Du tạo sức mạnh tuyệt đối đánh sập Tào Tháo!", Vector2(CX, 670), 21, Color("0d1b2a"), 1)

# -------------------------------------------------------------
# 9. VÌ SAO LA QUÁN TRUNG BUỘC PHẢI DÌM HÀNG CHU DU?
# -------------------------------------------------------------
func c_la_quan_trung_viet_su() -> void:
	draw_rect(Rect2(0, 0, 1760, 820), Color("f4ebd6"))
	B.chu(self, "VÌ SAO LA QUÁN TRUNG BUỘC PHẢI DÌM HÀNG CHU DU?", Vector2(CX, 85), 38, Color("b71c1c"), 2)
	
	Ng.ve(self, "khongminh", Vector2(440, 460), 130, "noi", "tram-ngam", T, 1.0, true)
	
	draw_rect(Rect2(720, 180, 920, 520), Color("ffffff", 0.95))
	draw_rect(Rect2(720, 180, 920, 520), Color("8d6e63"), false, 3.0)
	B.chu(self, "BỐC TÁCH BA ĐỘNG CƠ CỦA LA QUÁN TRUNG:", Vector2(1180, 230), 26, Color("b71c1c"), 2)
	B.chu(self, "1. Tư tưởng “Ủng Lưu Phản Tào” thời Nguyên - Minh:\\n   Lưu Bị họ Lưu được tôn làm chính thống, buộc phải tôn sùng Gia Cát Lượng thành thần thánh.\\n\\n2. Quy luật nghệ thuật sân khấu & tiểu thuyết:\\n   Để đẩy Khổng Minh lên tột đỉnh trí tuệ thần thánh, tác giả buộc phải hạ bệ một thiên tài đối trọng\\n   — và Chu Du đại đô đốc Giang Đông đã trở thành nạn nhân lớn nhất!\\n\\n3. Văn hóa dân gian chuộng kịch tính mâu thuẫn:\\n   Câu than “Trời sinh Du sao còn sinh Lượng” tạo kịch tính kịch liệt cho các gánh hát Tuồng Chèo!", Vector2(1180, 440), 21, Color("263238"), 1)

# -------------------------------------------------------------
# 10. KHẢI HOÀN GIẢI OAN: QUỲ GỐI DÂNG CHIẾU THƯ PHÁT SÁNG
# -------------------------------------------------------------
func c_khai_hoan_giai_oan() -> void:
	var top := Color("1565c0")
	var bot := Color("ffb300")
	for i in 12: draw_rect(Rect2(0, i * 68, 1760, 70), top.lerp(bot, i / 11.0))
	
	# Hào quang rực rỡ tỏa rộng
	draw_circle(Vector2(CX, 380), 220, Color("ffffff", 0.3))
	
	# Chu Du quỳ gối hai tay dâng cuộn chiếu thư phát sáng (HD.quy_goi_dang_thu)
	HD.quy_goi_dang_thu(self, Vector2(CX, 510), 1.0, T, {"vai": "chudu", "F": 135.0})
	
	# Hai bên: Gia Cát Lượng và Tào Tháo cúi mình kính cẩn
	Ng.ve(self, "khongminh", Vector2(CX - 420, 520), 115, "cui", "kinh-phuc", T, 1.0, false)
	Ng.ve(self, "taothao", Vector2(CX + 420, 520), 115, "cui", "kinh-phuc", T, -1.0, false)
	
	B.chu(self, "“DAO TƯỞNG CÔNG CẨN ĐƯƠNG NIÊN — HÙNG TƯ ANH PHÁT!”", Vector2(CX, 95), 38, Color("fff8e1"), 2, 1.0, Color("b71c1c"), 5)
	B.chu(self, "— Đại thi hào Tô Đông Pha (Niệm Nô Kiều - Xích Bích Hoài Cổ) —", Vector2(CX, 145), 22, Color("fff9c4"), 1)

# -------------------------------------------------------------
# 11. KẾT THÚC: NÂNG CHÉN RƯỢU CẠN LY & MỜI ĐĂNG KÝ
# -------------------------------------------------------------
func c_ket_thuc_cta() -> void:
	draw_rect(Rect2(0, 0, 1760, 820), Color("1a202c"))
	B.nhu(self, Rect2(40, 40, 1680, 740), 120, 1.5, 0.5)
	
	# Chu Du nâng chén rượu cạn ly mỉm cười sảng khoái (HD.nhap_ruou_can_ly)
	HD.nhap_ruou_can_ly(self, Vector2(CX, 470), T, {"vai": "chudu", "F": 130.0})
	
	B.chu(self, "TÈO TỬU LÂU — CẢM ƠN QUÝ KHÁN GIẢ ĐÃ LẮNG NGHE!", Vector2(CX, 110), 40, Color("ffe082"), 2)
	
	# Bảng kêu gọi hành động nổi bật
	draw_rect(Rect2(240, 580, 1280, 140), Color("b71c1c"))
	draw_rect(Rect2(240, 580, 1280, 140), Color("ffe082"), false, 4.0)
	B.chu(self, "BẠN NGHĨ GÌ VỀ NỖI OAN CỦA CHU LANG? HÃY ĐỂ LẠI BÌNH LUẬN BÊN DƯỚI!\\nĐỪNG QUÊN BẤM LIKE & ĐĂNG KÝ KÊNH ĐỂ ĐÓN XEM NHỮNG TẬP GIẢI MÃ TIẾP THEO!", Vector2(CX, 645), 26, Color("ffffff"), 2)

# =============================================================
# CÁC HÀM TIỆN ÍCH HOẠT HỌA MÔI TRƯỜNG
# =============================================================
func troi_dem_lua() -> void:
	var top := Color("0b1320")
	var bot := Color("5c1d11")
	for i in 12: draw_rect(Rect2(0, i * 68, 1760, 70), top.lerp(bot, i / 11.0))

func ve_song_nuoc(col: Color, alpha: float) -> void:
	for layer in 3:
		var sy := 520.0 + layer * 70.0
		var pts := PackedVector2Array()
		pts.append(Vector2(0, 820))
		for x in 30:
			var px := x * 65.0
			var wave := sin(T * (3.0 + layer) + x * 0.4) * (8.0 + layer * 4.0)
			pts.append(Vector2(px, sy + wave))
		pts.append(Vector2(1760, 820))
		draw_colored_polygon(pts, Color(col, alpha * (0.4 + layer * 0.25)))

func ve_thuyen_chien(bx: float, by: float, dir: float, col: Color, bop_chay: bool) -> void:
	draw_set_transform(Vector2(bx, by), 0.0, Vector2(dir, 1.0))
	var hull := PackedVector2Array([Vector2(-120, 30), Vector2(120, 30), Vector2(150, -25), Vector2(-140, -25)])
	draw_colored_polygon(hull, col)
	draw_polyline(hull, Color("1a0e08"), 2.5)
	draw_line(Vector2(0, -25), Vector2(0, -140), Color("3e2723"), 5.0)
	draw_colored_polygon(PackedVector2Array([Vector2(0, -130), Vector2(80, -90), Vector2(0, -50)]), Color("d7ccc8"))
	
	if bop_chay:
		for f in 5:
			var fx := -80.0 + f * 35.0 + sin(T * 8.0 + f) * 6.0
			var fy := -30.0 - (fmod(T * 60.0 + f * 20.0, 70.0))
			draw_circle(Vector2(fx, fy), 18.0 + sin(T * 10.0 + f) * 5.0, Color("ff3d00", 0.8))
			draw_circle(Vector2(fx, fy), 8.0, Color("ffea00", 0.9))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func ve_mua_ten_lua() -> void:
	for a in arrows:
		var px = fmod(float(a["x"]) + T * float(a["sp"]), 2000.0) - 200.0
		var py = float(a["y"]) + sin(px * 0.005) * 40.0
		draw_line(Vector2(px, py), Vector2(px - 35, py - 12), Color("fff9c4"), 2.5)
		draw_circle(Vector2(px, py), 4.5, Color("ff6d00", 0.9))
		draw_circle(Vector2(px - 10, py - 4), 3.0, Color("ffab00", 0.6))
'''
    return code

def generate_dynamic_phim_code():
    """Tạo mã GDScript cho phim.gd điều phối camera và Mascot Tèo di động tích hợp hanh_dong.gd"""
    code = '''extends Node2D
# phim.gd — ĐIỀU PHỐI ĐIỆN ẢNH & MASCOT TÈO TỬU LÂU
const B := preload("res://but.gd")
const Ng := preload("res://nguoi.gd")
const Tranh := preload("res://tranh.gd")
const HD := preload("res://hanh_dong.gd")

var M: Node
var T := 0.0
var tmap := {}
var lich: Array = []
var vq: SubViewport
var tq: Node2D

# 5 Chén rượu đồng Đông Ngô giải oan
var chen_pos := [
	Vector2(580, 930), Vector2(780, 915), Vector2(980, 910), Vector2(1180, 915), Vector2(1380, 930)
]
var chen_state := [1, 0, 0, 0, 0]

# Lịch phân cảnh khớp chính xác timeline
const LICH := [
	["k01-01", "hook", "lua"],
	["k02-01", "quay_bien_kinh", "lua"],
	["k03-01", "chu_du_that", "lua"],
	["k04-01", "an_1_troi_sinh_du", "lua"],
	["k05-01", "an_2_xich_bich", "lua"],
	["k06-01", "an_2_mu_gio_thuyen_co", "lua"],
	["k07-01", "an_3_ba_khau", "lua"],
	["k08-01", "an_4_chai_chi", "lua"],
	["k09-01", "an_5_nhi_phan_thien_ha", "lua"],
	["k10-01", "vi_sao_dim_chu_du", "lua"],
	["k11-01", "tra_lai_cong_bang", "lua"],
	["k12-01", "ket_oi", "lua"]
]

func setup(main: Node) -> void:
	M = main
	for l in M.lines: tmap[l.id] = [l.t0, l.dur]
	lich.clear()
	for p in LICH:
		var id: String = p[0]
		if tmap.has(id): lich.append([tmap[id][0], p[1], p[2]])
	lich.sort_custom(func(a, b): return a[0] < b[0])
	
	vq = SubViewport.new()
	vq.size = Vector2i(1760, 820)
	vq.disable_3d = true
	add_child(vq)
	tq = Tranh.new()
	vq.add_child(tq)

func tl(id: String) -> float: return tmap[id][0] if tmap.has(id) else 0.0

func sfx() -> Array: return []

func muc(t: float) -> int:
	var idx := 0
	for i in lich.size():
		if t >= lich[i][0]: idx = i
	return idx

func at(t: float, seg: Dictionary, line: Dictionary) -> void:
	T = t
	if vq == null or lich.is_empty(): return
	var idx := muc(t)
	var canh_ten: String = lich[idx][1]
	var mode: String = lich[idx][2]
	
	# Cập nhật chén rượu giải oan
	if t >= tl("k04-11"): chen_state[0] = 3
	elif t >= tl("k04-01"): chen_state[0] = 1
	
	if t >= tl("k06-11"): chen_state[1] = 3
	elif t >= tl("k05-01"): chen_state[1] = 1
	
	if t >= tl("k07-12"): chen_state[2] = 3
	elif t >= tl("k07-01"): chen_state[2] = 1
	
	if t >= tl("k08-12"): chen_state[3] = 3
	elif t >= tl("k08-01"): chen_state[3] = 1
	
	if t >= tl("k09-10"): chen_state[4] = 3
	elif t >= tl("k09-01"): chen_state[4] = 1

	var lt: float = t - float(lich[idx][0])
	tq.ve(self, t, canh_ten, lt, mode)
	queue_redraw()

func _draw() -> void:
	# Nền quầy Biện Kinh
	troi()
	
	# Bàn gỗ mun thuyết thư
	var mat_ban := Rect2(0, 820, 1920, 260)
	draw_rect(mat_ban, Color("1a120c"))
	draw_line(Vector2(0, 820), Vector2(1920, 820), Color("4a3322"), 5.0)
	draw_line(Vector2(0, 825), Vector2(1920, 825), Color("2b1a10"), 2.0)
	
	# Cuộn tranh chính
	if vq and vq.get_texture():
		var tex := vq.get_texture()
		var r_khung := Rect2(80, 24, 1760, 786)
		draw_texture_rect(tex, r_khung, false)
		
		# Khung viền cuộn lụa cổ phong
		draw_rect(r_khung.grow(6), Color("2d1c14"), false, 6.0)
		draw_rect(r_khung.grow(3), Color("c9a24a"), false, 2.5)
		draw_rect(r_khung, Color("5c3a21"), false, 1.5)
		
		# Trục cuốn lụa hai đầu
		draw_rect(Rect2(66, 14, 14, 806), Color("3d2616"))
		draw_rect(Rect2(1840, 14, 14, 806), Color("3d2616"))
		draw_circle(Vector2(73, 14), 10, Color("c9a24a"))
		draw_circle(Vector2(73, 820), 10, Color("c9a24a"))
		draw_circle(Vector2(1847, 14), 10, Color("c9a24a"))
		draw_circle(Vector2(1847, 820), 10, Color("c9a24a"))

	# Năm chén rượu đồng Đông Ngô
	ve_nam_chen_ruou()

	# Chibi Tèo thuyết thư di động
	ve_teo_di_dong()

func troi() -> void:
	var top := Color("0e141f")
	var bot := Color("261a15")
	for i in 12: draw_rect(Rect2(0, i * 70, 1920, 72), top.lerp(bot, i / 11.0))
	draw_circle(Vector2(120, 80), 45, Color("e6a135", 0.12))
	draw_circle(Vector2(120, 80), 24, Color("f0b848", 0.28))
	draw_circle(Vector2(1800, 90), 45, Color("e6a135", 0.12))
	draw_circle(Vector2(1800, 90), 24, Color("f0b848", 0.28))

func ve_nam_chen_ruou() -> void:
	var ten_an := ["Án 1: Trời sinh Du", "Án 2: Hỏa công", "Án 3: Ba Khâu", "Án 4: Hôn sự", "Án 5: Nhị Phân"]
	for i in 5:
		var pos: Vector2 = chen_pos[i]
		var st: int = chen_state[i]
		
		draw_rect(Rect2(pos.x - 26, pos.y + 14, 52, 16), Color("2f4935"))
		draw_line(Vector2(pos.x - 20, pos.y + 30), Vector2(pos.x - 24, pos.y + 44), Color("1e3023"), 4.0)
		draw_line(Vector2(pos.x, pos.y + 30), Vector2(pos.x, pos.y + 46), Color("1e3023"), 4.0)
		draw_line(Vector2(pos.x + 20, pos.y + 30), Vector2(pos.x + 24, pos.y + 44), Color("1e3023"), 4.0)
		
		var cup := PackedVector2Array([
			Vector2(pos.x - 30, pos.y - 16),
			Vector2(pos.x + 30, pos.y - 16),
			Vector2(pos.x + 22, pos.y + 14),
			Vector2(pos.x - 22, pos.y + 14)
		])
		draw_colored_polygon(cup, Color("3d5a45"))
		draw_polyline(cup, Color("7e9f85"), 2.0)
		B.chu(self, ten_an[i], Vector2(pos.x, pos.y + 60), 16, Color("c8d6ca"), 1)
		
		if st >= 1:
			var flick := sin(T * 4.0 + i) * 1.5
			draw_circle(Vector2(pos.x, pos.y - 12 + flick), 14, Color("e89b27", 0.8))
			draw_circle(Vector2(pos.x, pos.y - 12 + flick), 7, Color("ffe082"))
		if st == 3:
			var r_glow := 28.0 + sin(T * 5.0 + i) * 4.0
			draw_circle(Vector2(pos.x, pos.y - 16), r_glow, Color("ffe082", 0.35))
			draw_circle(Vector2(pos.x, pos.y - 16), 12, Color("fff8e1", 0.9))
			var off_y := fmod(T * 30.0 + i * 20.0, 50.0)
			draw_circle(Vector2(pos.x + sin(T * 3.0 + i) * 6.0, pos.y - 25 - off_y), 3.0, Color("ffffff", 0.4 * (1.0 - off_y / 50.0)))

func ve_teo_di_dong() -> void:
	# Mascot Tèo di động linh hoạt theo từng giai đoạn của tập phim
	var dang_noi := false
	var text_cau := ""
	if M and not M.lines.is_empty():
		for l in M.lines:
			if T >= l.t0 and T < l.t0 + l.dur:
				dang_noi = true
				text_cau = l.text.to_lower()
				break

	# Tọa độ X và pose của Tèo biến đổi sinh động
	var pos_x := 240.0
	var pose := "dung"
	var expr := "binh"

	# 1. Đoạn mở đầu (10 giây đầu): Tèo bước từ bên phải vào quầy
	if T < 7.0:
		pos_x = lerpf(800.0, 240.0, clampf(T / 7.0, 0.0, 1.0))
		pose = "di"
		expr = "vui"
	elif "bình luận" in text_cau or "like" in text_cau or "đăng ký" in text_cau:
		# 2. Khi kêu gọi tương tác: Tèo vỗ tay nhiệt liệt
		pos_x = 300.0
		pose = "votay"
		expr = "vui"
	elif "oan" in text_cau or "uất" in text_cau:
		# 3. Khi nói về nỗi oan: Tèo lắc đầu ôm trán
		pos_x = 240.0
		pose = "omdau"
		expr = "buon"
	elif "rượu" in text_cau or "chén" in text_cau or "cạn ly" in text_cau:
		# 4. Tèo nâng chén rượu cạn ly cùng khách quan
		pos_x = 260.0
		HD.nhap_ruou_can_ly(self, Vector2(pos_x, 960), T, {"vai": "teo", "F": 105.0})
		return
	elif dang_noi:
		# 5. Khi đang nói: đổi giữa chỉ tay, gõ kinh đường mộc và cầm chén rượu
		var phase := int(fmod(T, 12.0) / 4.0)
		if phase == 0:
			pose = "chi"
			expr = "tu-tin"
		elif phase == 1:
			pose = "noi"
			expr = "vui"
		else:
			pose = "cam"
			expr = "binh"
	else:
		pose = "dung"
		expr = "binh"

	var pos := Vector2(pos_x, 960)
	Ng.ve(self, "teo", pos, 105, pose, expr, T, 1.0, dang_noi)
'''
    return code

def apply_to_tap(tap_dir):
    tap_path = Path(tap_dir).resolve()
    godot_dir = tap_path / "godot"
    if not godot_dir.exists():
        godot_dir = tap_path
        
    hanh_dong_src = Path(__file__).parent / "hanh_dong.gd"
    hanh_dong_dst = godot_dir / "hanh_dong.gd"
    
    print(f"🚀 Đang cập nhật hệ thống vũ đạo hành động Chibi 2D cho {tap_path.name}...")
    
    # 1. Sao chép hanh_dong.gd vào thư mục godot của tập phim
    if hanh_dong_src.exists():
        shutil.copy2(hanh_dong_src, hanh_dong_dst)
        print(f"✅ Đã triển khai module vũ đạo: {hanh_dong_dst}")
    else:
        print(f"⚠️ Không tìm thấy nguồn hanh_dong.gd tại {hanh_dong_src}")
        
    # 2. Ghi đè tranh.gd tích hợp hanh_dong.gd
    tranh_file = godot_dir / "tranh.gd"
    tranh_code = generate_dynamic_tranh_code()
    tranh_file.write_text(tranh_code, encoding="utf-8")
    print(f"✅ Đã ghi đè tranh.gd: {tranh_file}")
    
    # 3. Ghi đè phim.gd tích hợp hanh_dong.gd
    phim_file = godot_dir / "phim.gd"
    phim_code = generate_dynamic_phim_code()
    phim_file.write_text(phim_code, encoding="utf-8")
    print(f"✅ Đã ghi đè phim.gd: {phim_file}")

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Sử dụng: python3 gen-hoat-anh.py <đường_dẫn_tập>")
        sys.exit(1)
    apply_to_tap(sys.argv[1])
