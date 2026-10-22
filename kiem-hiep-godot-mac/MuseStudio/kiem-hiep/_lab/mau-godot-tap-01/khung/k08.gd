# k08 bếp lửa: Hồng Thất Công đeo hồ lô, chín vạch ngón tay; Hoàng Dung nấu, món ăn bay sang, mỗi món rơi một ô chưởng (15 rồi 3); Dung cầm gậy trúc xanh.
extends Khung

func _init() -> void:
	X = -12000.0; ben = -1.0

func cam(t: float) -> Array:
	return Khung.keycam([[-9.0, Vector2(400, 0), 1.0], [L(1), Vector2(360, -60), 1.25], [L(3), Vector2(-150, 0), 1.0], [L(5), Vector2(80, -80), 0.85],
		[L(7), Vector2(80, -60), 0.95], [L(8), Vector2(-300, 0), 1.1], [L(9), Vector2(0, -40), 0.85]], t, 2.0)

func sfx() -> Array:
	return [[L(1) + 4.0, "impact-bass-2", -12.0], [L(2), "click", -8.0], [L(4), "pop", -10.0], [L(5), "whoosh-short", -10.0], [L(7), "sparkle", -8.0], [L(9), "chime", -8.0]]

func teo(t: float) -> Dictionary:
	return teo_mac("soc" if t > L(1) + 3.5 and t < L(2) else ("vui" if t > L(4) and t < L(7) else "dac-y" if t > L(9) else "binh"))

func ve() -> void:
	Canh.dat(self, -1250, 1250, 300, pg(-2.0, 2.0), 8.0)
	But.nui(self, -1250, 1250, 300, 180, 41.0, Color("9a9c88"), pg(-2.0, 2.0) * 0.8, 3.0)
	Canh.cay(self, Vector2(1000, 300), 1.2, pg(-1.5, 1.5), 9.0, Color("5f7a3c"))
	Canh.cay(self, Vector2(-1150, 300), 0.9, pg(-1.2, 1.5), 10.0, Color("6f8a4a"))
	# Hồng Thất Công
	var ph := pg(-0.5, 1.2)
	var eat := lt > L(4) and lt < L(8)
	nguoi("hong", Vector2(420, 300), 1.0, {"face": -1, "prop": "ho-lo", "aF": 0.6 + (0.5 + 0.3 * sin(tt * 6.0) if eat else 0.0), "eF": 0.8, "aB": 0.2, "lean": 0.04}, "vui" if eat else "dac-y", ph)
	Canh.nhan(self, "Hồng Thất Công", Vector2(420, 400), ph, 36, "bang chủ Cái Bang thời Quách Tĩnh")
	# chín vạch: mười ngón, một ngón bị gạch
	var pf := ap(1, 1.0, 3.0) * (1.0 - ap(4, 1.0))
	if pf > 0.0:
		for i in 10:
			var x := 220.0 + i * 44.0
			var cut := i == 9 and ap(1, 0.4, 5.0) > 0.0
			But.net(self, PackedVector2Array([Vector2(x, -430), Vector2(x + 4, -340)]), 14, But.ca(But.SON if cut else But.MUC, 0.85), ap(1, 0.3, 3.0 + i * 0.15) * pf, 0.2, 0.3)
			if cut:
				But.net(self, PackedVector2Array([Vector2(x - 26, -370), Vector2(x + 30, -400)]), 6, But.SON, ap(1, 0.3, 5.0) * pf, 0.1, 0.1)
		But.chu(self, "CỬU CHỈ THẦN CÁI", Vector2(420, -270), 52, But.MUC, 1, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(2, 1.0) * pf)
		But.chu(self, "ông ăn mày thần chín ngón tay", Vector2(420, -225), 28, But.ca(But.MUC, 0.7), 2, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(2, 1.0, 1.0) * pf)
	# bếp lửa + Hoàng Dung + Quách Tĩnh
	var pd := ap(3, 1.0)
	if pd > 0.0:
		var fire := Vector2(-260, 300)
		Canh.lua(self, fire, 1.0, tt, pd)
		# nồi + hơi
		draw_colored_polygon(But.blob_pts(fire + Vector2(0, -70), 70, 40, 3.0, 0.05, 24), But.ca(Color("2a2622"), pd))
		for i in 4:
			var u := fposmod(tt * 0.4 + i * 0.25, 1.0)
			var y := -120.0 - u * 220.0
			But.net(self, But.qd(fire + Vector2(-20 + i * 14, y), fire + Vector2(10 + 30 * sin(tt + i), y - 40), fire + Vector2(-10 + i * 14, y - 80)), 7, But.ca(But.MUC, 0.3 * (1.0 - u) * pd), 1.0, 0.3, 0.3, 0.2, i)
		nguoi("dung", Vector2(-480, 300), 0.85, {"face": 1, "aF": 1.0 + 0.3 * sin(tt * 3.0), "eF": 0.5, "prop": "gay-xanh" if lt > L(8) else ""}, "vui" if lt < L(9) else "dac-y", pd)
		Canh.nhan(self, "Hoàng Dung", Vector2(-480, 400), pd, 34)
		nguoi("quach", Vector2(-800, 300), 0.9, {"face": 1, "aF": 0.4 + (0.9 * absf(sin(tt * 2.0)) if lt > L(5) and lt < L(8) else 0.0), "eF": 0.3, "palmF": true}, "ko" if lt < L(6) else "quyet-tam", ap(3, 1.0, 1.0))
		Canh.nhan(self, "Quách Tĩnh", Vector2(-800, 400), ap(3, 1.0, 1.0), 32)
	# món ăn bay từ bếp sang ông già
	var pf2 := ap(4, 1.0) * (1.0 - ap(7, 1.0))
	if pf2 > 0.0:
		for i in 3:
			var u := fposmod(tt * 0.35 + i / 3.0, 1.0)
			var at := Vector2(-260, 200).lerp(Vector2(380, 160), u) + Vector2(0, -180 * sin(u * PI))
			draw_colored_polygon(But.blob_pts(at, 34, 14, i + 1.0, 0.05, 18), But.ca(Color("f2ead8"), pf2))
			draw_colored_polygon(But.blob_pts(at + Vector2(0, -8), 22, 9, i + 4.0, 0.2, 14), But.ca([Color("c96a2a"), Color("6a8a3a"), Color("b8322a")][i], pf2))
		But.chu(self, "món mới mỗi bữa", Vector2(60, -150), 36, But.ca(But.MUC, 0.8), 2, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(4, 1.0, 1.5) * pf2)
	# lưới 18 ô: đầy dần 15, rồi 3
	var pgr := ap(5, 1.0)
	if pgr > 0.0:
		var base := Vector2(-560, -470)
		var n15 := int(15 * But.ez(ap(5, ld[5] if ld.size() > 5 else 6.0)))
		var n3 := int(3 * ap(7, 2.0))
		for i in 18:
			var at := base + Vector2((i % 9) * 72, (i / 9) * 72)
			draw_rect(Rect2(at, Vector2(60, 60)), But.ca(But.MUC, 0.6 * pgr), false, 3.0)
			var filled := i < n15 or (i >= 15 and i - 15 < n3)
			if filled:
				draw_rect(Rect2(at + Vector2(6, 6), Vector2(48, 48)), But.ca(But.MUC if i < 15 else But.SON, 0.85 * pgr))
		But.chu(self, "%d / 18" % (n15 + n3), base + Vector2(700, 60), 52, But.MUC, 1, HORIZONTAL_ALIGNMENT_LEFT, -1, pgr)
		var p6 := ap(6, 1.0) * (1.0 - ap(7, 1.0))
		if p6 > 0.0:
			But.chu(self, "đệ tử Cái Bang: lập công lớn » 1 chiêu", Vector2(-240, -240), 30, But.MUC, 2, HORIZONTAL_ALIGNMENT_CENTER, -1, p6)
			But.chu(self, "Quách Tĩnh: 15 món ăn » 15 chiêu", Vector2(-240, -195), 30, But.SON, 2, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(6, 1.0, 2.0) * p6)
	# Dung: không học chưởng, học gậy
	var p8 := ap(8, 1.0)
	if p8 > 0.0:
		But.chu(self, "ĐẢ CẨU BỔNG PHÁP", Vector2(-480, -150), 44, Color("2f6a3a"), 1, HORIZONTAL_ALIGNMENT_CENTER, -1, p8)
		But.chu(self, "chưởng + gậy", Vector2(-640, -100), 34, But.ca(But.MUC, 0.8), 2, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(8, 1.0, 3.0))
	# câu 10: Dung thành bang chủ
	var p9 := ap(9, 1.2)
	if p9 > 0.0:
		But.dau(self, Vector2(-480, 40), 120, ["BANG", "CHỦ"], p9, -0.06, 12.0)
