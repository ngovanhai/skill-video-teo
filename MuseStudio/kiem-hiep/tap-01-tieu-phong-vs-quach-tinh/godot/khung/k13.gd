# k13 hang đá đảo Đào Hoa: Chu Bá Thông khắc 15 năm lên vách, tay trái đấu tay phải, Quách Tĩnh bắt chước; trang Cửu Âm bay;
# rồi mọi người thầy thành từng viên gạch xếp lên một bức tường.
extends Khung

const THAY := ["Giang Nam Thất Quái", "Triết Biệt", "Mã Ngọc", "Hồng Thất Công", "Chu Bá Thông", "Cửu Âm Chân Kinh", "Hoàng Dung", "thảo nguyên"]

func _init() -> void:
	X = -7200.0; ben = -1.0

func cam(t: float) -> Array:
	return Khung.keycam([[-9.0, Vector2(0, -40), 0.85], [L(1), Vector2(-250, 0), 1.0], [L(3), Vector2(-300, 40), 1.3], [L(5), Vector2(-100, 40), 1.05],
		[L(6), Vector2(200, -150), 1.0], [L(7), Vector2(520, -40), 0.95], [L(8), Vector2(520, -100), 0.85]], t, 2.0)

func sfx() -> Array:
	return [[L(1) + 2.0, "click", -10.0], [L(3), "whoosh-short", -10.0], [L(4), "pop", -10.0], [L(6), "sparkle", -10.0], [L(7), "pop", -12.0], [L(8), "impact-bass-2", -10.0]]

func teo(t: float) -> Dictionary:
	return teo_mac("vui" if t > L(3) and t < L(6) else ("ngai" if t < L(1) else ("dac-y" if t > L(7) else "binh")))

func ve() -> void:
	# biển + đá
	var pb := pg(-2.0, 2.0)
	for i in 5:
		var y := 330.0 + i * 40.0
		var pts := PackedVector2Array()
		for k in 40:
			var x := -1250.0 + k * 64.0
			pts.append(Vector2(x, y + sin(x * 0.01 + tt * 0.8 + i) * 8.0))
		But.net(self, pts, 5, But.ca(Color("4f6a7a"), 0.5 - i * 0.08), pb, 0.1, 0.1, 0.2, i)
	Canh.cay(self, Vector2(1150, 300), 1.0, pb, 15.0, Color("e3a2a6"))
	Canh.cay(self, Vector2(980, 300), 0.8, pb, 16.0, Color("e8b0b4"))
	Canh.nhan(self, "đảo Đào Hoa", Vector2(1060, 410), pg(0.3, 1.0), 34)
	# hang đá: vòm tối
	var pc := pg(-1.5, 2.0)
	var cave := PackedVector2Array()
	for i in 25:
		var ang := PI + PI * i / 24.0
		cave.append(Vector2(-300, 310) + Vector2(cos(ang) * 620, sin(ang) * 520) * pc)
	draw_colored_polygon(cave, But.ca(Color("4a4a52"), 0.85 * pc))
	var inner := PackedVector2Array()
	for i in 25:
		var ang := PI + PI * i / 24.0
		inner.append(Vector2(-300, 310) + Vector2(cos(ang) * 520, sin(ang) * 430) * pc)
	draw_colored_polygon(inner, But.ca(Color("d8ccb0"), 0.9 * pc))
	# Chu Bá Thông
	var pz := ap(1, 1.0)
	var duel := ap(3, 1.0)
	var aL := 0.8 + 0.8 * sin(tt * 5.0) * duel
	var aR := 0.8 + 0.8 * sin(tt * 5.0 + PI) * duel
	if pz > 0.0:
		nguoi("chu", Vector2(-480, 300), 0.95, {"face": 1, "aF": aL, "eF": 0.6, "aB": aR, "eB": 0.6, "palmF": true, "palmB": true, "lift": 6.0 * absf(sin(tt * 3.0)) * duel}, "vui", pz)
		Canh.nhan(self, "Chu Bá Thông", Vector2(-480, 400), pz, 32, "Lão Ngoan Đồng · ông già trẻ con")
		# 15 vạch năm khắc trên vách
		Canh.vach(self, Vector2(-760, -120), int(15 * ap(1, 3.0, 3.0)), 1.0, 0.8 * pz)
		But.chu(self, "15 năm", Vector2(-640, -170), 36, But.MUC, 2, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(1, 1.0, 6.0))
	# sư đệ Vương Trùng Dương
	var p2 := ap(2, 1.0) * (1.0 - ap(3, 1.0))
	if p2 > 0.0:
		Canh.bong(self, Vector2(-80, 300), 0.95, 0.4 * p2, 161.0, tt, 0)
		Canh.nhan(self, "Vương Trùng Dương", Vector2(-80, 400), p2, 28, "sáng lập phái Toàn Chân")
		But.net(self, But.qd(Vector2(-440, 60), Vector2(-260, -20), Vector2(-110, 60)), 4, But.ca(But.MUC, 0.6), p2, 0.1, 0.1)
		But.chu(self, "sư đệ", Vector2(-260, -40), 30, But.ca(But.MUC, 0.8), 2, HORIZONTAL_ALIGNMENT_CENTER, -1, p2)
	# Song Thủ Hỗ Bác: hai nửa vòng trái/phải
	var p4 := ap(4, 1.0)
	if p4 > 0.0:
		var c := Vector2(-480, -260)
		for k in 2:
			var pts := PackedVector2Array()
			for i in 13:
				var ang := PI * 0.5 + PI * i / 12.0 + (PI if k == 1 else 0.0) + tt * 0.6
				pts.append(c + Vector2(cos(ang), sin(ang)) * 90)
			But.net(self, pts, 10, [But.MUC, But.SON][k], p4, 0.05, 0.3, 0.2, k)
		But.chu(self, "SONG THỦ HỖ BÁC", c + Vector2(0, -130), 46, But.MUC, 1, HORIZONTAL_ALIGNMENT_CENTER, -1, p4)
	# Quách Tĩnh bắt chước
	var p5 := ap(5, 1.0)
	if p5 > 0.0:
		var d2 := ap(5, 1.0, 2.0)
		nguoi("quach", Vector2(-120, 300), 0.9, {"face": -1, "aF": 0.8 + 0.8 * sin(tt * 5.0 + 0.3) * d2, "eF": 0.6, "aB": 0.8 + 0.8 * sin(tt * 5.0 + PI + 0.3) * d2, "eB": 0.6, "palmF": true, "palmB": true}, "ko" if lt < L(5) + 4.0 else "vui", p5)
		Canh.nhan(self, "Quách Tĩnh", Vector2(-120, 400), p5, 30, "không nghĩ nhiều · hai tay không cãi nhau")
	# Cửu Âm: trang giấy bay ra
	var p6 := ap(6, 1.0)
	if p6 > 0.0:
		for i in 6:
			var u := But.ez(ap(6, 3.0, i * 0.4))
			var at := Vector2(-480, 100).lerp(Vector2(-60 + i * 110, -380 + (i % 2) * 70), u)
			Canh.to_giay(self, at, Vector2(90, 120), p6 * (1.0 - ap(7, 1.0) * 0.6), sin(tt + i) * 0.15, 4)
		But.chu(self, "CỬU ÂM CHÂN KINH", Vector2(240, -470), 46, But.MUC, 1, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(6, 1.0, 1.5) * (1.0 - ap(7, 1.0)))
	# bức tường gạch: mỗi thầy một viên
	var p7 := ap(7, 1.0)
	if p7 > 0.0:
		var b := Vector2(260, 290)
		for i in THAY.size():
			var row := i / 3
			var col := i % 3
			var q := But.eo(ap(7, 0.8, 2.5 + i * 0.7))
			var at := b + Vector2(col * 240 + (row % 2) * 120, -row * 100 - 70) + Vector2(0, -260 * (1.0 - q))
			if q <= 0.0: continue
			draw_rect(Rect2(at, Vector2(230, 90)), But.ca(Color("a8644a"), 0.9 * q))
			draw_rect(Rect2(at, Vector2(230, 90)), But.ca(But.MUC, 0.7 * q), false, 3.0)
			But.chu(self, THAY[i], at + Vector2(115, 54), 22 if THAY[i].length() > 14 else 26, But.ca(But.GIAY, q), 1, HORIZONTAL_ALIGNMENT_CENTER, -1, q)
		But.chu(self, "Tiêu Phong: ít thứ, luyện tới tận cùng", Vector2(620, -470), 30, But.MUC, 2, HORIZONTAL_ALIGNMENT_CENTER, -1, p7)
		But.chu(self, "Quách Tĩnh: 7, 8 người thầy, mỗi người một viên gạch", Vector2(620, -425), 30, Color("2b3a4a"), 2, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(7, 1.0, 1.5))
		var p8 := ap(8, 1.0)
		if p8 > 0.0:
			But.chu(self, "xây chậm · khó đổ", Vector2(620, -260), 52, But.SON, 1, HORIZONTAL_ALIGNMENT_CENTER, -1, p8)
