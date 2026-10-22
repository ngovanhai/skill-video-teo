extends "res://canh.gd"
# Sheet thử 6 kiểu ngồi riêng (ngồi v2): mỗi người một dáng ngồi theo tính cách + một cử động nhỏ lặp lại.

const WOOD := Color("#a8743e")
const FLOOR := Color("#5a3c22")
const Y1 := 470.0
const Y2 := 1010.0
var lhx: Dictionary
var dien: Dictionary
var nl: Dictionary
var teo: Dictionary
var nhac: Dictionary
var phong: Dictionary
var g_lhx: Dictionary
var g_dien: Dictionary
var g_nl: Dictionary
var g_nhac: Dictionary
var ho: Dictionary
var dao: Dictionary


func _palette() -> void:
	sky_top = Color("#2e2118")
	sky_bot = Color("#5e4129")
	char_tint = Color(1.0, 0.96, 0.9)
	vign_a = 0.2


func _build() -> void:
	g_lhx = ghe_moi(Vector2(360, Y1), 1.0, WOOD)
	lhx = actor("lenh-ho-xung", g_lhx.p, 1.0)
	ho = prop(lhx, "ho_lo", "tay", "F")
	g_dien = ghe_moi(Vector2(930, Y1), -1.0, WOOD.darkened(0.12))
	dien = actor("dien-ba-quang", g_dien.p, -1.0)
	dien.expr = "gian"
	dao = prop(dien, "dao", "tay", "F")
	dao.lock = 1.0
	g_nl = ghe_moi(Vector2(1560, Y1), -1.0, WOOD.lightened(0.08), 96.0)
	nl = actor("nghi-lam", g_nl.p, -1.0)
	teo = actor("teo-tieu-nhi", Vector2(330, Y2), 1.0)
	teo.expr = "soc"
	g_nhac = ghe_moi(Vector2(990, Y2 - 46.0), 1.0, Color("#6b3a24"), 190.0)
	nhac = actor("nhac-bat-quan", g_nhac.p, 1.0)
	phong = actor("phong-thanh-duong", Vector2(1580, Y2 - 62.0), -1.0)
	phong.sway = 2.2


func _story(_dt: float) -> void:
	var tt := maxf(t, 0.0)
	# Lệnh Hồ Xung: bập bênh ghế trên 2 chân sau, hồ lô lủng lẳng ở ngón tay, đầu gật theo nhịp
	g_lhx.rock = 0.13 + 0.08 * sin(tt * 1.7)
	ngoi(lhx, g_lhx)
	lhx.extra = [[NGOI_BAP_BENH, 1.0], [{"head": sin(tt * 3.4) * 4.0, "shB": 34.0 + sin(tt * 1.7) * 10.0}, 1.0]]
	lhx.expr = "vui" if fmod(tt, 4.0) < 2.6 else "dac-y"
	# Điền: chồm tới, đao chống mũi xuống sàn, bàn chân F gõ nhịp sốt ruột
	ngoi(dien, g_dien)
	var tap := maxf(0.0, sin(tt * 9.0))
	dien.extra = [[NGOI_CHOM, 1.0], [{"ftF": -6.0 - tap * 18.0, "shF": 110.0 - tap * 6.0}, 1.0]]
	dao.lockdir = Vector2(-0.08, 1.0).normalized()
	var dt_: Node2D = dien.node.J["torso"]
	dien.hold["F"] = [from_w(dt_, Vector2(g_dien.p.x - 96.0, Y1 - 150.0 + tap * 3.0)), 1.0]
	# Nghi Lâm: nửa mông ở mép ghế, cúi đầu, thỉnh thoảng ngước lên rồi cúi vội
	ngoi(nl, g_nl, 26.0)
	var peek := smooth(1.4, 1.7, fmod(tt, 3.6)) * (1.0 - smooth(2.2, 2.4, fmod(tt, 3.6)))
	nl.extra = [[NGOI_MEP, 1.0], [{"head": 12.0 - peek * 14.0, "torso": 7.0 - peek * 3.0}, 1.0]]
	nl.expr = "ngai" if peek > 0.5 else "binh"
	nl.hold["F"] = [Vector2(66, -84), 1.0]
	nl.hold["B"] = [Vector2(60, -80), 1.0]
	# Tèo: ngồi xổm ôm vò, run lẩy bẩy, nhổm lên ngó rồi thụp xuống
	var up := smooth(1.0, 1.4, fmod(tt, 3.2)) * (1.0 - smooth(2.0, 2.2, fmod(tt, 3.2)))
	teo.extra = [[NGOI_XOM, 1.0], [{"all": [0.0, sin(tt * 47.0) * 1.6, 52.0 - up * 30.0], "head": -6.0 - up * 6.0}, 1.0]]
	# Nhạc Bất Quần: thẳng như tượng, chỉ có râu và tay áo khẽ lay; nụ cười cố định
	ngoi(nhac, g_nhac)
	nhac.extra = [[NGOI_TUONG, 1.0]]
	var nt: Node2D = nhac.node.J["torso"]
	nhac.hold["F"] = [from_w(nt, to_w(nhac.node.J["shF"], Vector2(0, -8))), 1.0]
	nhac.hold["B"] = [from_w(nt, to_w(nhac.node.J["shB"], Vector2(0, -8))), 1.0]
	nhac.sway = 0.25
	nhac.expr = "dac-y" if fmod(tt, 5.0) > 3.0 else "binh"
	# Phong Thanh Dương: xếp bằng trên đá, thở chậm, tóc râu bay theo gió núi
	phong.extra = [[NGOI_XEP_BANG, 1.0], [{"all": [0.0, 0.0, 92.0 - (sin(tt * 1.1) * 0.5 + 0.5) * 4.0], "head": sin(tt * 0.7) * 3.0}, 1.0]]


func _sky(c: Node2D) -> void:
	vgrad(c, Rect2(-200, -200, 2320, 1480), sky_top, sky_bot)


func _ground(c: Node2D) -> void:
	for row: float in [Y1, Y2]:
		c.draw_rect(Rect2(-200, row, 2320, 70), FLOOR)
		hatch(c, PackedVector2Array([Vector2(-200, row), Vector2(2120, row), Vector2(2120, row + 70), Vector2(-200, row + 70)]), 0.3, 22.0, Color(ink, 0.35))
	for x: float in [640.0, 1280.0]:
		c.draw_line(Vector2(x, 0), Vector2(x, H), Color(ink, 0.8), 6.0)
	c.draw_line(Vector2(0, 540), Vector2(W, 540), Color(ink, 0.8), 6.0)
	ghe_ve(c, g_lhx)
	ghe_ve(c, g_dien)
	ghe_ve(c, g_nl)
	# quầy sau lưng Tèo
	shape(c, PackedVector2Array([Vector2(120, Y2 - 230), Vector2(560, Y2 - 230), Vector2(560, Y2), Vector2(120, Y2)]), Color("#6e4a2a"), 4.0)
	hatch(c, PackedVector2Array([Vector2(120, Y2 - 230), Vector2(560, Y2 - 230), Vector2(560, Y2), Vector2(120, Y2)]), 1.1, 18.0, Color(ink, 0.3))
	# bục + ghế cao của Nhạc Bất Quần
	shape(c, PackedVector2Array([Vector2(820, Y2 - 46), Vector2(1150, Y2 - 46), Vector2(1170, Y2), Vector2(800, Y2)]), Color("#4a2c1c"), 4.0)
	ghe_ve(c, g_nhac)
	# tảng đá của Phong Thanh Dương
	shape(c, round_pts(PackedVector2Array([Vector2(1440, Y2), Vector2(1450, Y2 - 52), Vector2(1530, Y2 - 70), Vector2(1660, Y2 - 66), Vector2(1720, Y2 - 30), Vector2(1730, Y2)])), Color("#7d7a6e"), 4.0)
	hatch(c, PackedVector2Array([Vector2(1450, Y2 - 40), Vector2(1700, Y2 - 40), Vector2(1720, Y2), Vector2(1440, Y2)]), 0.9, 14.0, Color(ink, 0.35))


func _near(c: Node2D) -> void:
	# vò rượu trong vòng tay Tèo
	var vp := to_w(teo.node.J["torso"], Vector2(40, -34))
	c.draw_circle(vp, 36.0, inkof(Color("#8a5a2a")))
	c.draw_circle(vp, 32.0, Color("#8a5a2a"))
	c.draw_rect(Rect2(vp + Vector2(-14, -44), Vector2(28, 14)), Color("#6b4426"))
	c.draw_rect(Rect2(vp + Vector2(-18, -6), Vector2(36, 22)), Color("#b8322c"))
	var labels := [[Vector2(320, 60), "Lệnh Hồ Xung · bập bênh"], [Vector2(960, 60), "Điền · chồm tới"], [Vector2(1600, 60), "Nghi Lâm · mép ghế"],
		[Vector2(320, 600), "Tèo · ngồi xổm"], [Vector2(960, 600), "Nhạc Bất Quần · tượng"], [Vector2(1600, 600), "Phong Thanh Dương · xếp bằng"]]
	for lb in labels:
		nhan(c, lb[0], lb[1], 22)
