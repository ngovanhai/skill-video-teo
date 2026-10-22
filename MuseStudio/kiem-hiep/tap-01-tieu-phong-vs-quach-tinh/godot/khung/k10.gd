# k10 Hạnh Tử Lâm: rừng hạnh hồng, đám đông bóng người; lá thư mở ra, đầu sói xanh trên ngực; gậy trúc đặt xuống đất;
# chữ KIỀU bị gạch thành TIÊU; anh đi một mình giữa hoa rơi.
extends Khung

func _init() -> void:
	X = 7200.0; travel = 2.2

func cam(t: float) -> Array:
	return Khung.keycam([[-9.0, Vector2(0, -60), 0.85], [L(1), Vector2(-300, -120), 1.1], [L(2), Vector2(0, 70), 2.6, 2.5], [L(3), Vector2(0, 0), 0.9],
		[L(4), Vector2(60, 140), 1.4], [L(5), Vector2(0, -260), 1.2], [L(6), Vector2(-420, 0), 0.95, 4.0]], t, 2.0)

func sfx() -> Array:
	return [[L(1), "whoosh-short", -10.0], [L(2) + 1.0, "impact-bass-2", -6.0], [L(3), "glitch-1", -16.0], [L(4) + 2.5, "click", -4.0], [L(5) + 1.5, "impact-bass-1", -10.0]]

func teo(t: float) -> Dictionary:
	return teo_mac("ngai" if t < L(2) else ("soc" if t < L(3) else "buon"))

func ve() -> void:
	Canh.dat(self, -1250, 1250, 300, pg(-2.0, 2.0), 10.0)
	# rừng hạnh
	for i in 9:
		var x := -1150.0 + i * 290.0 + But.h1(i + 40) * 60.0
		Canh.cay(self, Vector2(x, 290 - (i % 2) * 20), 0.9 + But.h1(i) * 0.4, pg(-1.5 + i * 0.1, 1.5), 60.0 + i, Color("e3a2a6"))
	Canh.nhan(self, "Hạnh Tử Lâm", Vector2(-900, 410), pg(0.5, 1.0), 40, "rừng cây hạnh · đại hội Cái Bang")
	# đám đông: vòng bóng người hai bên
	var turn := ap(3, 1.5)
	for i in 14:
		var side := -1.0 if i % 2 == 0 else 1.0
		var x := side * (330.0 + (i / 2) * 110.0)
		Canh.bong(self, Vector2(x, 306 + (i % 3) * 10), 0.7, (0.55 + 0.25 * turn) * pg(-0.5, 1.5), 100 + i, tt * (1.0 - turn), 1 if turn > 0.5 and i % 4 == 0 else 0)
	# Tiêu Phong giữa đám đông
	var pt := pg(-0.5, 1.0) * (1.0 - ap(6, 1.5) * 0.0)
	var wx := lerpf(0.0, -1100.0, But.ez(ap(6, 6.0, 1.5)))
	var drop := ap(4, 1.5, 1.5)
	nguoi("tieu", Vector2(wx, 300), 1.0, {"face": -1 if lt > L(6) else 1, "prop": "gay-xanh" if drop < 0.5 else "", "aF": 0.9 - 0.9 * drop, "eF": 0.3 + drop, "crouch": 0.4 * sin(drop * PI), "stride": 0.4 * absf(sin(tt * 4.0)) * ap(6, 1.0, 1.5)}, "buon" if lt > L(2) else "binh", pt)
	# gậy nằm dưới đất
	if drop >= 0.5:
		But.net(self, PackedVector2Array([Vector2(-60, 312), Vector2(200, 300)]), 12, Color("4f8a3c"), 1.0, 0.05, 0.05, 0.05)
	# tên: KIỀU PHONG → gạch → TIÊU PHONG
	var nm := ap(5, 1.0, 1.0)
	But.chu(self, "KIỀU PHONG", Vector2(0, -330), 80, But.MUC, 1, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(0, 1.0, 2.0) * (1.0 - ap(6, 1.0) * 0.6))
	if nm > 0.0:
		But.net(self, PackedVector2Array([Vector2(-260, -350), Vector2(-60, -365)]), 12, But.SON, nm, 0.1, 0.1)
		But.chu(self, "TIÊU", Vector2(-160, -440), 80, But.SON, 1, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(5, 1.0, 2.0))
	# lá thư
	var pl := ap(1, 1.0) * (1.0 - ap(2, 1.0, 1.0))
	if pl > 0.0:
		var w := 120.0 + 460.0 * But.ez(ap(1, 2.0, 0.5))
		Canh.to_giay(self, Vector2(-420, -120), Vector2(w, 300), pl, -0.03, 7)
		But.chu(self, "Kiều Phong là người Khiết Đan", Vector2(-420, -110), 34, But.MUC, 2, HORIZONTAL_ALIGNMENT_CENTER, w - 40, ap(1, 1.0, 3.0) * pl)
		But.chu(self, "— Uông Kiếm Thông", Vector2(-360, 0), 26, But.ca(But.MUC, 0.7), 2, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(1, 1.0, 4.5) * pl)
	# đầu sói xanh trên ngực
	var pw := ap(2, 1.5, 1.0)
	if pw > 0.0:
		var c := Vector2(wx + 4, 300 - 230)
		var blue := Color("2f5f9a")
		var pts := PackedVector2Array([c + Vector2(-26, -20), c + Vector2(-18, -44), c + Vector2(-6, -22), c + Vector2(6, -22), c + Vector2(18, -44), c + Vector2(26, -20), c + Vector2(20, 6), c + Vector2(0, 30), c + Vector2(-20, 6)])
		draw_colored_polygon(pts, But.ca(blue, 0.85 * pw))
		draw_circle(c + Vector2(-9, -8), 3.5, But.ca(But.GIAY, pw)); draw_circle(c + Vector2(9, -8), 3.5, But.ca(But.GIAY, pw))
		But.chu(self, "hình xăm đầu sói", c + Vector2(130, -10), 22, But.ca(blue, 0.9), 2, HORIZONTAL_ALIGNMENT_LEFT, -1, ap(2, 1.0, 2.5) * (1.0 - ap(3, 1.0)))
	# kẻ thù: hai vế
	var p3 := ap(3, 1.0) * (1.0 - ap(5, 1.0))
	if p3 > 0.0:
		But.chu(self, "người Tống thời ấy: Khiết Đan = kẻ thù", Vector2(0, -470), 40, But.ca(But.MUC, 0.85), 2, HORIZONTAL_ALIGNMENT_CENTER, -1, p3)
	# câu 7: hoa rơi, người đi một mình
	var p6 := ap(6, 2.0)
	if p6 > 0.0:
		for i in 26:
			var u := fposmod(tt * (0.05 + But.h1(i) * 0.05) + But.h1(i + 9), 1.0)
			var at := Vector2(-1200 + But.h1(i + 2) * 2400 + sin(tt + i) * 40, -560 + u * 880)
			draw_colored_polygon(But.blob_pts(at, 9, 5, i, 0.2, 8), Color("e8a8b0", 0.75 * p6 * (1.0 - u * 0.5)))
		But.chu(self, "yêu một đất nước · bị gọi là người ngoài", Vector2(-420, -180), 40, But.MUC, 2, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(6, 1.5, 3.0))
