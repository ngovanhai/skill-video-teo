extends "res://canh.gd"
# Ảnh bìa tập 10: quầy Hồi Nhạn lâu, Tèo (tiểu nhị) nghiêng vò rót bên trái, Lệnh Hồ Xung ngửa cổ dốc hồ lô bên phải,
# chín hồ lô treo trên vách đã đầy, chữ to ở dải trên (không đè mặt). Bút khắc gỗ mực nâu như cả tập.

const WALL := Color("#4a2e1a")
const WINE := Color("#e0a040")
var teo: Dictionary
var lhx: Dictionary
var ho: Dictionary
var ma: Dictionary


func _palette() -> void:
	sky_top = Color("#3a2414")
	sky_bot = Color("#6a4424")
	char_tint = Color(1.0, 0.96, 0.88)
	ground_y = 1010.0
	vign_a = 0.3


func _build() -> void:
	teo = actor("teo-tieu-nhi", Vector2(440, ground_y), 1.0)
	teo.size = 1.55
	teo.expr = "vui"
	lhx = actor("lenh-ho-xung", Vector2(1450, ground_y), -1.0)
	lhx.size = 1.6
	lhx.expr = "vui"
	ho = prop(lhx, "ho_lo", "tay", "F")
	ma = prop(lhx, "ma_do", "mat", "F", {"cheek": Vector2(62, -54)})
	ma.amount = 1.0


func _story(_dt: float) -> void:
	teo.hold["F"] = [Vector2(84, -150), 1.0]
	teo.hold["B"] = [Vector2(62, -126), 1.0]
	teo.extra = [[{"torso": 8.0, "head": 6.0}, 1.0]]
	lhx.extra = [[{"head": -24.0, "torso": -10.0, "uaB": -40.0, "faB": -70.0}, 1.0]]
	var to: Node2D = lhx.node.J["torso"]
	var lip := from_w(to, to_w(lhx.node.J["head"], Vector2(0, -30)))
	lhx.hold["F"] = [lip + Vector2(46, -150), 1.0]
	ho.lock = 1.0
	ho.lockdir = Vector2(-0.55, -0.83)
	ho.aim = Vector2(0, -30)
	ho.pour = 1.0


func _cam() -> Array:
	return [CENTER, 1.0]


func _sky(c: Node2D) -> void:
	for i in 22:
		var x := -40.0 + i * 92.0
		c.draw_rect(Rect2(x, -20, 88, 1120), WALL.lightened(0.05 * (i % 3)))
		cut(c, Vector2(x + 18, 120 + (i * 53) % 500), Vector2(x + 66, 128 + (i * 53) % 500), 3.0, Color(ink, 0.5))
	grain(c, Rect2(0, 0, 1920, 1080), 700, Color(ink, 0.08), 3)
	# quầng đèn ấm sau hai người
	for p: Vector2 in [Vector2(440, 560), Vector2(1450, 540)]:
		for k in 6:
			c.draw_circle(p, 520.0 - k * 70.0, Color(1.0, 0.72, 0.38, 0.05))
	# thanh kệ + chín hồ lô treo, đã đầy
	c.draw_rect(Rect2(0, 444, 1920, 16), Color("#2a1a10"))
	for i in 9:
		holo(c, Vector2(400 + i * 140, 402), 0.85, Color("#c8322c") if i == 8 else WINE, 1.0)


func _near(c: Node2D) -> void:
	# vò trong tay Tèo nghiêng, dòng rượu cong rơi vào bát trên quầy
	var vp := to_w(teo.node.J["torso"], Vector2(52, -96))
	var mouth := _vo(c, vp, 46.0, 1.05)
	var bowl := Vector2(820, 850)
	var pts := PackedVector2Array()
	for i in 13:
		var k := i / 12.0
		var e := bowl + Vector2(0, -24)
		pts.append(Vector2(lerpf(mouth.x, e.x, k), mouth.y + (e.y - mouth.y) * k * k - 70.0 * k * (1.0 - k)))
	c.draw_polyline(pts, Color(WINE, 0.95), 14.0, true)
	c.draw_polyline(pts, Color(1, 1, 0.9, 0.7), 4.0, true)
	# quầy gỗ phía trước
	var top := 870.0
	shape(c, PackedVector2Array([Vector2(-40, top), Vector2(1960, top), Vector2(1960, top + 34), Vector2(-40, top + 34)]), PLANK.lightened(0.1), 4.0)
	van_mang(c, Rect2(-40, top + 34, 2000, 70), 3)
	van_mang(c, Rect2(-40, top + 104, 2000, 70), 9)
	nhan(c, Vector2(960, top + 110), "HỒI NHẠN LÂU", 40)
	# bát rượu
	shape(c, PackedVector2Array([bowl + Vector2(-64, -30), bowl + Vector2(64, -30), bowl + Vector2(40, 18), bowl + Vector2(-40, 18)]), Color("#e8e0cc"), 4.0)
	c.draw_line(bowl + Vector2(-56, -22), bowl + Vector2(56, -22), Color(WINE), 8.0)
	for j in 5:
		var a := TAU * j / 5.0
		c.draw_circle(bowl + Vector2(cos(a) * 40.0, -40 - absf(sin(a)) * 26.0), 5.0, Color(1, 0.9, 0.6, 0.8))


func _vo(c: Node2D, p: Vector2, r: float, rot: float) -> Vector2:
	c.draw_set_transform(p, rot, Vector2.ONE)
	var body := Color("#8a5a2a")
	c.draw_circle(Vector2.ZERO, r + 4.0, inkof(body))
	c.draw_circle(Vector2.ZERO, r, body)
	c.draw_circle(Vector2(-r * 0.35, -r * 0.3), r * 0.28, Color(1, 0.9, 0.7, 0.18))
	c.draw_rect(Rect2(-r * 0.4, -r * 1.25, r * 0.8, r * 0.42), Color("#6b4426"))
	c.draw_rect(Rect2(-r * 0.5, -r * 0.2, r, r * 0.62), Color("#b8322c"))
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	return p + Vector2(0, -r * 1.25).rotated(rot)


func _d_screen(c: Node2D) -> void:
	super(c)
	# chữ lớn dải trên: viền mực dày, ruột vàng rượu
	var big := "CHÍN LẦN RÓT"
	var sz := 150
	var w := font.get_string_size(big, HORIZONTAL_ALIGNMENT_LEFT, -1, sz).x
	var p := Vector2(960 - w * 0.5, 210)
	for d in 16:
		var a := TAU * d / 16.0
		c.draw_string(font, p + Vector2(cos(a), sin(a)) * 9.0, big, HORIZONTAL_ALIGNMENT_LEFT, -1, sz, Color("#1a0d06"))
	c.draw_string(font, p + Vector2(0, 8), big, HORIZONTAL_ALIGNMENT_LEFT, -1, sz, Color("#7a3a10"))
	c.draw_string(font, p, big, HORIZONTAL_ALIGNMENT_LEFT, -1, sz, Color("#ffd88a"))
	var sub := "LỆNH HỒ XUNG"
	var s2 := 72
	var w2 := font.get_string_size(sub, HORIZONTAL_ALIGNMENT_LEFT, -1, s2).x
	var r := Rect2(960 - w2 * 0.5 - 30, 252, w2 + 60, 96)
	c.draw_rect(r.grow(5), Color("#1a0d06"))
	c.draw_rect(r, Color("#b8322c"))
	c.draw_string(font, Vector2(960 - w2 * 0.5, 326), sub, HORIZONTAL_ALIGNMENT_LEFT, -1, s2, Color("#fff4dc"))
