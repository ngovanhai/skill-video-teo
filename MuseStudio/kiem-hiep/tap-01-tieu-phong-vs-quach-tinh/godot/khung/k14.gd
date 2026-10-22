# k14 lều lớn của Đại Hãn: trao kim đao, tấm bản đồ với mũi tên chỉ xuống nam, Quách Tĩnh đặt đao xuống;
# tấm gương: "bị đẩy ra" / "tự bước qua", nét biên giới son ở giữa.
extends Khung

func _init() -> void:
	X = -4800.0; ben = -1.0

func cam(t: float) -> Array:
	return Khung.keycam([[-9.0, Vector2(0, -40), 0.85], [L(0), Vector2(-120, 20), 1.2], [L(1), Vector2(0, 0), 0.95], [L(2), Vector2(450, -100), 1.15],
		[L(3), Vector2(-150, 80), 1.3], [L(4), Vector2(0, -150), 0.85], [L(5), Vector2(0, -200), 1.0]], t, 2.0)

func sfx() -> Array:
	return [[L(0) + 2.0, "sparkle", -10.0], [L(2) + 1.5, "whoosh-short", -8.0], [L(3) + 1.0, "click", -4.0], [L(3) + 1.2, "impact-bass-2", -8.0], [L(5), "chime", -8.0]]

func teo(t: float) -> Dictionary:
	return teo_mac("vui" if t < L(2) else ("soc" if t < L(3) else ("quyet-tam" if t < L(4) else "ngai")))

func ve() -> void:
	Canh.dat(self, -1250, 1250, 300, pg(-2.0, 2.0), 14.0)
	# lều lớn: mái vòm vải + cột + cờ
	var ph := pg(-1.5, 2.0)
	var tent := PackedVector2Array()
	for i in 25:
		var ang := PI + PI * i / 24.0
		tent.append(Vector2(-150, 300) + Vector2(cos(ang) * 900, sin(ang) * 620) * ph)
	draw_colored_polygon(tent, But.ca(Color("e6dcc4"), 0.85 * ph))
	But.net(self, tent, 8, But.ca(But.MUC, 0.8), ph, 0.0, 0.0, 0.15, 3.0)
	for i in 5:
		var x := -900.0 + i * 375.0
		But.net(self, PackedVector2Array([Vector2(-150, 300 - 620 * ph), Vector2(x, 300)]), 3, But.ca(Color("8a6a3a"), 0.5), ph, 0.0, 0.0, 0.1, i)
	draw_rect(Rect2(-160, -390, 8, 70), But.ca(But.MUC, ph))
	var flag := PackedVector2Array([Vector2(-152, -390), Vector2(-60 + sin(tt * 3.0) * 10, -375), Vector2(-152, -350)])
	draw_colored_polygon(flag, But.ca(Color("b8322a"), ph))
	# Đại Hãn
	var pd := pg(-0.5, 1.0)
	var point := ap(2, 1.0, 0.5)
	nguoi("daihan", Vector2(250, 300), 1.05, {"face": -1 if point < 0.5 else 1, "aF": 0.8 + 0.6 * point, "eF": 0.4 - 0.3 * point, "prop": "kim-dao" if lt < L(0) + 2.0 else ""}, "dac-y" if lt < L(3) else "gian", pd)
	Canh.nhan(self, "Thành Cát Tư Hãn", Vector2(250, 400), pd, 34, "Đại Hãn")
	# Quách Tĩnh
	var give := ap(0, 1.0, 2.0)
	var down := But.ez(ap(3, 1.5, 1.0))
	var hasblade := give >= 0.5 and down < 0.5
	nguoi("quach", Vector2(-260, 300), 1.0, {"face": 1, "aF": 0.9 - 0.7 * down, "eF": 0.4, "prop": "kim-dao" if hasblade else "", "crouch": 0.5 * sin(down * PI)}, "vui" if lt < L(2) else ("buon" if lt < L(3) else "quyet-tam"), pg(-0.3, 1.0))
	Canh.nhan(self, "Quách Tĩnh", Vector2(-260, 400), pg(-0.3, 1.0), 34, "kim đao phò mã" if give > 0.5 else "")
	if down >= 0.5:
		var blade := PackedVector2Array([Vector2(-140, 312), Vector2(20, 300)])
		But.net(self, blade, 14, Color("c99a3a"), 1.0, 0.05, 0.4, 0.05)
	# chữ: kim đao phò mã
	var p0 := ap(0, 1.0, 3.0) * (1.0 - ap(2, 1.0))
	if p0 > 0.0:
		But.chu(self, "KIM ĐAO PHÒ MÃ", Vector2(-150, -230), 56, Color("8a6a1a"), 1, HORIZONTAL_ALIGNMENT_CENTER, -1, p0)
		But.chu(self, "con rể của Đại Hãn", Vector2(-150, -180), 30, But.ca(But.MUC, 0.7), 2, HORIZONTAL_ALIGNMENT_CENTER, -1, p0)
	# bản đồ: thảo nguyên ở trên, đất Tống ở dưới, mũi tên đỏ chỉ xuống
	var pm := ap(2, 1.0) * (1.0 - ap(4, 1.0))
	if pm > 0.0:
		var c := Vector2(650, -150)
		Canh.to_giay(self, c, Vector2(380, 420), pm, 0.04, 0)
		But.chu(self, "thảo nguyên", c + Vector2(0, -150), 30, But.MUC, 2, HORIZONTAL_ALIGNMENT_CENTER, -1, pm)
		But.net(self, PackedVector2Array([c + Vector2(-170, -10), c + Vector2(170, 10)]), 4, But.ca(But.SON, 0.8), pm, 0.1, 0.1, 0.3)
		But.chu(self, "đất Tống", c + Vector2(0, 160), 30, But.MUC, 2, HORIZONTAL_ALIGNMENT_CENTER, -1, pm)
		var ar := ap(2, 1.5, 2.0)
		But.net(self, PackedVector2Array([c + Vector2(0, -110), c + Vector2(10, 110)]), 14, But.SON, ar, 0.05, 0.05, 0.1)
		if ar >= 1.0:
			draw_colored_polygon(PackedVector2Array([c + Vector2(-26, 96), c + Vector2(38, 96), c + Vector2(10, 140)]), But.SON)
		# từ chối: dấu gạch chéo lên mũi tên
		var no := ap(3, 0.6, 1.0)
		if no > 0.0:
			But.net(self, PackedVector2Array([c + Vector2(-90, -40), c + Vector2(100, 60)]), 18, But.MUC, no, 0.1, 0.1)
			But.net(self, PackedVector2Array([c + Vector2(100, -40), c + Vector2(-90, 60)]), 18, But.MUC, ap(3, 0.6, 1.4), 0.1, 0.1)
	# câu 4: những gì mất đi
	var p3 := ap(3, 1.0, 3.0) * (1.0 - ap(4, 1.0))
	if p3 > 0.0:
		var lost := ["ân tình", "chức tước", "hôn ước với Hoa Tranh"]
		for i in 3:
			But.chu(self, lost[i], Vector2(-700, -260 + i * 60), 36, But.ca(But.MUC, 0.8), 2, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(3, 0.8, 3.0 + i * 1.0) * p3)
			But.net(self, PackedVector2Array([Vector2(-860, -270 + i * 60), Vector2(-540, -270 + i * 60)]), 4, But.SON, ap(3, 0.5, 3.6 + i * 1.0) * p3, 0.1, 0.1)
	# tấm gương soi
	var p4 := ap(4, 1.0)
	if p4 > 0.0:
		for k in 8:
			draw_rect(Rect2(-6, -560 + k * 120, 12, 70), But.ca(But.SON, 0.85 * ap(4, 0.3, k * 0.1)))
		But.chu(self, "Tiêu Phong", Vector2(380, -470), 44, But.MUC, 1, HORIZONTAL_ALIGNMENT_CENTER, -1, p4)
		But.chu(self, "Quách Tĩnh", Vector2(-380, -470), 44, Color("2b3a4a"), 1, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(4, 1.0, 2.5))
		var p5 := ap(5, 1.0)
		But.chu(self, "bị đẩy ra", Vector2(380, -390), 54, But.SON, 2, HORIZONTAL_ALIGNMENT_CENTER, -1, p5)
		But.chu(self, "tự bước qua", Vector2(-380, -390), 54, But.SON, 2, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(5, 1.0, 2.0))
		# hai mũi bước chân băng qua vạch
		var st := ap(5, 3.0, 2.0)
		for k in 6:
			var u := k / 5.0
			if u < st:
				draw_circle(Vector2(lerpf(-300, 200, u), -300 + (k % 2) * 18), 9, But.ca(Color("2b3a4a"), 0.7))
