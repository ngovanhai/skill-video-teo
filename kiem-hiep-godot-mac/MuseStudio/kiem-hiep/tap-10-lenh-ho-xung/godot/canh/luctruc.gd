extends "res://canh.gd"
# Lục Trúc Hạng, Lạc Dương. Một bối cảnh, hai kiểu dựng theo arg.m (= kid):
#   k12 — sân khấu bóng: người sau rèm trúc chỉ là một cái bóng; mọi điều chàng tưởng hiện thành bong bóng nghĩ
#   k13 — rèm cuốn lên: bóng hoá người thật, máy quay áp sát mặt chàng; chính tà đối chiếu hai bên khung

const WALL0 := 900.0
const WALL1 := 1720.0
const DOOR0 := 1000.0
const DOOR1 := 1430.0
const DOOR_TOP := 430.0
const GOLD := Color("#f0c060")
const JADE := Color("#8fe0c0")
const WINE5 := Color("#e89ab0")
const SHADOW := Color(0.16, 0.13, 0.16)

var m := "k12"
var lhx: Dictionary
var ong: Dictionary
var dd: Dictionary
var ho: Dictionary
var ma: Dictionary
var DP := Vector2(1230, 860)     # chỗ cô ngồi sau rèm
var LP := Vector2(820, 860)      # chỗ chàng ngồi học đàn
var gifts := []                  # quà tặng: [x đích, y đích, kiểu, lúc bay, bên]


func _palette() -> void:
	m = arg.get("m", "k12")
	sky_top = Color("#bcd9c0")
	sky_bot = Color("#f4ecd0")
	char_tint = Color(1.0, 1.0, 0.97)
	ground_y = 860.0
	vign_a = 0.25
	wind_base = 0.25
	wind_gust = 0.35


func _build() -> void:
	if m == "k12":
		lhx = actor("lenh-ho-xung", Vector2(-300, ground_y), 1.0)
		ong = actor("luc-truc-ong", Vector2(760, ground_y), -1.0)
		dd = actor("doanh-doanh", DP, -1.0)
		dd.tint = SHADOW
		var rr := RandomNumberGenerator.new()
		rr.seed = 12
		for i in 14:
			var sd := -1 if i % 2 == 0 else 1
			gifts.append([LP.x + sd * rr.randf_range(100, 280), ground_y - (i / 6) * 40.0, i % 4, L("k12-09") + 0.3 + i * 0.32, sd])
	else:
		lhx = actor("lenh-ho-xung", LP, 1.0)
		dd = actor("doanh-doanh", DP, -1.0)
		ma = prop(lhx, "ma_do", "mat", "F", {"cheek": Vector2(62, -54)})
	ho = prop(lhx, "ho_lo", "hong", "F")


func _story(dt: float) -> void:
	if t < 0.0:
		return
	if m == "k12":
		_s12(dt)
	else:
		_s13(dt)


func _cam() -> Array:
	return _c12() if m == "k12" else _c13()


# ---------------------------------------------------------------- bối cảnh chung

func _far(c: Node2D) -> void:
	# mái nhà Lạc Dương xa xa
	for i in 9:
		var x := -200.0 + i * 280.0
		var y := 600.0 - (i * 37) % 60
		var col := Color("#9fb7a4")
		shape(c, PackedVector2Array([Vector2(x - 130, y + 20), Vector2(x - 100, y - 10), Vector2(x + 100, y - 10), Vector2(x + 130, y + 20)]), col, 2.0)
		c.draw_rect(Rect2(x - 90, y + 20, 180, 140), Color("#b9c9b2"))


func _mid(c: Node2D) -> void:
	for i in 26:
		bamboo(c, -600.0 + i * 120.0 + (i * 31) % 50, 900.0, 640.0 + (i * 47) % 160, 14.0, Color("#86ad7a"), i, 3.0, true)


func _back(c: Node2D) -> void:
	for i in 12:
		var x := -700.0 + i * 140.0 + (i * 17) % 40
		if x > 600.0:
			x += 1500.0
		bamboo(c, x, 960.0, 900.0, 22.0, Color("#5f8f58"), 30 + i, 3.0, true)


func _ground(c: Node2D) -> void:
	var gy := ground_y
	c.draw_rect(Rect2(-3000, gy, 7000, 500), Color("#c9b98a"))
	for i in 40:
		c.draw_line(Vector2(-1500 + i * 120, gy + 30 + (i % 3) * 40), Vector2(-1440 + i * 120, gy + 30 + (i % 3) * 40), Color("#a8976a"), 3.0)
	# nhà: tường, mái, ô cửa sáng ấm
	c.draw_rect(Rect2(WALL0, 380, WALL1 - WALL0, gy - 380), Color("#e6d6b0"))
	c.draw_rect(Rect2(WALL0, 380, WALL1 - WALL0, gy - 380), Color(ink, 0.8), false, 4.0)
	shape(c, PackedVector2Array([Vector2(WALL0 - 90, 390), Vector2(WALL0 - 20, 300), Vector2(WALL1 + 20, 300), Vector2(WALL1 + 90, 390)]), Color("#5a6a5a"), 4.0)
	for i in 14:
		var x := WALL0 - 60.0 + i * 65.0
		c.draw_line(Vector2(x, 384), Vector2(x + 20, 306), Color("#3e4a3e"), 3.0)
	var lit := 1.0
	vgrad(c, Rect2(DOOR0, DOOR_TOP, DOOR1 - DOOR0, gy - DOOR_TOP), Color("#f6c87a").lerp(Color("#e8d2a6"), 0.2), Color("#d89a4a"))
	c.draw_rect(Rect2(DOOR0, DOOR_TOP, DOOR1 - DOOR0, gy - DOOR_TOP), Color(ink, 0.9), false, 5.0)
	# trong nhà: kệ sách, bình hoa
	c.draw_rect(Rect2(1320, 520, 90, 220), Color("#8a5e38", lit))
	for j in 4:
		c.draw_line(Vector2(1320, 560 + j * 50), Vector2(1410, 560 + j * 50), Color(ink, 0.7), 3.0)
	# k13: huy hiệu nhật nguyệt hiện trên vách khi cô đứng dậy
	if m == "k13":
		var em := smooth(L("k13-02") + 0.3, L("k13-02") + 1.6, t)
		if em > 0.01:
			var ec := Vector2(1130, 560)
			c.draw_circle(ec, 62.0, Color(ink, em))
			c.draw_circle(ec, 56.0, Color("#c8322c", em))
			c.draw_circle(ec + Vector2(34, -14), 34.0, Color("#efe6d2", em))
			c.draw_circle(ec + Vector2(44, -20), 28.0, Color("#c8322c", em))
	# cột cửa trái
	c.draw_rect(Rect2(WALL0 + 70, DOOR_TOP - 40, 30, ground_y - DOOR_TOP + 40), Color("#7a3a22"))
	c.draw_rect(Rect2(WALL0 + 70, DOOR_TOP - 40, 30, ground_y - DOOR_TOP + 40), Color(ink), false, 3.0)
	# vạch đếm ngày trên cột cửa (k12-07b)
	if m == "k12":
		var b7 := L("k12-07b")
		var n := int(clampf((t - b7 - 0.6) / 0.55, 0.0, 12.0))
		for i in n:
			var x := WALL0 + 20.0 + (i % 5) * 9.0 + (i / 5) * 60.0
			if i % 5 == 4:
				c.draw_line(Vector2(x - 40, 650 + (i / 5) * 0), Vector2(x + 4, 610), Color("#5a2e1c"), 4.0)
			else:
				c.draw_line(Vector2(x, 600), Vector2(x, 660), Color("#5a2e1c"), 4.0)
	# k13: bóng kiếm "chính phái" chĩa vào từ trái
	if m == "k13":
		var sk := bump(L("k13-04") - 0.2, L("k13-04") + 1.0, LE("k13-04") - 0.6, LE("k13-04") + 0.4)
		if sk > 0.01:
			for i in 5:
				var y := 480.0 + i * 70.0
				var x := -260.0 + sk * 300.0 + (i % 2) * 60.0
				var ang := -0.12 + i * 0.06
				var d := Vector2(cos(ang), sin(ang))
				c.draw_line(Vector2(x, y), Vector2(x, y) + d * 240.0, Color(0.12, 0.12, 0.16, 0.8 * sk), 10.0)
				c.draw_line(Vector2(x, y) - d.orthogonal() * 22.0, Vector2(x, y) + d.orthogonal() * 22.0, Color(0.12, 0.12, 0.16, 0.8 * sk), 8.0)


# rèm trúc: chỉ phủ ô cửa; đáy rèm kéo lên trong k13
func _blind_bottom() -> float:
	if m == "k12":
		return ground_y
	var l1 := L("k13-01")
	return lerpf(ground_y, DOOR_TOP + 20.0, smooth(l1 + 0.3, l1 + 2.4, t))


func _near(c: Node2D) -> void:
	_dan_draw(c)
	# rèm
	var bb := _blind_bottom()
	var y := DOOR_TOP + 14.0
	while y < bb - 6.0:
		c.draw_rect(Rect2(DOOR0 + 6, y, DOOR1 - DOOR0 - 12, 9), Color("#c9a35a", 0.82))
		c.draw_line(Vector2(DOOR0 + 6, y + 9), Vector2(DOOR1 - 6, y + 9), Color("#8a6a32", 0.6), 2.0)
		y += 14.0
	for sx: float in [DOOR0 + 90.0, DOOR1 - 90.0]:
		c.draw_line(Vector2(sx, DOOR_TOP), Vector2(sx, bb), Color("#7a3a22", 0.8), 3.0)
	c.draw_rect(Rect2(DOOR0, bb - 8, DOOR1 - DOOR0, 14), Color("#7a5a2a"))
	c.draw_rect(Rect2(DOOR0, bb - 8, DOOR1 - DOOR0, 14), Color(ink), false, 3.0)
	var roll := 18.0 + (ground_y - bb) * 0.06
	c.draw_rect(Rect2(DOOR0 - 10, DOOR_TOP - roll * 0.5, DOOR1 - DOOR0 + 20, roll + 6), Color("#b88a42"))
	c.draw_rect(Rect2(DOOR0 - 10, DOOR_TOP - roll * 0.5, DOOR1 - DOOR0 + 20, roll + 6), Color(ink), false, 3.0)
	if m == "k12":
		_n12(c)
	else:
		_n13(c)


func _glow(c: Node2D) -> void:
	blob(c, Vector2((DOOR0 + DOOR1) * 0.5, 640), 300.0, Color(1.0, 0.75, 0.4, 0.12))
	if m == "k12":
		var hk := bump(L("k12-06") + 0.3, L("k12-06") + 1.2, LE("k12-06") - 0.5, LE("k12-06") + 0.6)
		if hk > 0.01:
			blob(c, to_w(lhx.node.J["torso"], Vector2(0, -60)), 140.0, Color(0.5, 1.0, 0.7, 0.3 * hk))
	else:
		var wk := smooth(L("k13-05") + 1.5, L("k13-05") + 2.5, t)
		if wk > 0.01:
			blob(c, head_of(lhx), 180.0, Color(WINE5, 0.3 * wk))


func _d_screen(c: Node2D) -> void:
	super._d_screen(c)
	if m == "k12":
		# ngày đêm nối nhau (k12-07b)
		var b7 := L("k12-07b")
		var k := smooth(b7 + 0.2, b7 + 0.8, t) * (1.0 - smooth(LE("k12-07b") - 0.4, LE("k12-07b") + 0.3, t))
		if k > 0.01:
			var ph := (t - b7 - 0.2) * 0.9
			var night := (0.5 - 0.5 * cos(ph * TAU)) * k
			c.draw_rect(Rect2(0, 0, W, H), Color(0.05, 0.07, 0.2, 0.5 * night))
			var u := fmod(ph, 1.0)
			var p := Vector2(1880 - u * 520, 330 - sin(u * PI) * 110)
			if u < 0.5:
				c.draw_circle(p, 34.0, Color("#ffd65a", k))
			else:
				c.draw_circle(p, 30.0, Color("#f4ecd0", k))
				c.draw_circle(p + Vector2(12, -8), 26.0, Color(0.2, 0.25, 0.45, k * night * 2.0))


# ---------------------------------------------------------------- đàn, nốt, bong bóng

func _cam_pts(p: Vector2, f: float) -> Array:
	return [p + Vector2(f * -36.0, -26.0), p + Vector2(f * 150.0, -18.0)]


func _dan(c: Node2D, p: Vector2, f: float, col := Color("#4a2a1a"), al := 1.0) -> Vector2:
	var e: Array = _cam_pts(p, f)
	var a: Vector2 = e[0]
	var b: Vector2 = e[1]
	var n := (b - a).normalized().orthogonal() * f
	shape(c, PackedVector2Array([a + n * 10, b + n * 8, b - n * 6, a - n * 9]), Color(col, al), 3.0)
	for i in 5:
		var o := n * (8.0 - i * 2.4)
		c.draw_line(a + o, b + o, Color(1, 0.95, 0.8, 0.7 * al), 1.2, true)
	return a.lerp(b, 0.55)


func _dan_hold(a: Dictionary, p: Vector2, f: float, k: float, ph := 0.0) -> void:
	var e: Array = _cam_pts(p, f)
	var aa: Vector2 = e[0]
	var bb: Vector2 = e[1]
	var to: Node2D = a.node.J["torso"]
	var pl := 0.6 + 0.14 * sin(t * 3.1 + ph)
	a.hold["F"] = [from_w(to, aa.lerp(bb, pl) + Vector2(0, -12.0 - absf(sin(t * 10.0 + ph)) * 9.0)), k]
	a.hold["B"] = [from_w(to, aa.lerp(bb, 0.2) + Vector2(0, -8)), k]


func _note(c: Node2D, p: Vector2, s: float, col: Color, al: float) -> void:
	if al <= 0.01:
		return
	var ln := Color(inkof(col, 0.5), al)
	c.draw_circle(p, 12.0 * s, ln)
	c.draw_circle(p, 9.0 * s, Color(col, al))
	c.draw_line(p + Vector2(8, 0) * s, p + Vector2(8, -34) * s, ln, 4.0 * s)
	c.draw_line(p + Vector2(8, -34) * s, p + Vector2(22, -24) * s, ln, 4.0 * s)


func _bubble(c: Node2D, from: Vector2, ctr: Vector2, r: Vector2, al: float) -> void:
	for i in 3:
		var p := from.lerp(ctr, 0.25 + i * 0.18)
		c.draw_circle(p, 8.0 + i * 5.0 + 3.0, Color(ink, al))
		c.draw_circle(p, 8.0 + i * 5.0, Color(1, 1, 1, al))
	var pts := PackedVector2Array()
	for i in 24:
		var a := i * TAU / 24.0
		pts.append(ctr + Vector2(cos(a) * r.x, sin(a) * r.y) * (1.0 + 0.05 * sin(a * 5.0)))
	shape(c, pts, Color(1, 1, 1, al), 4.0)


# bà lão chống gậy trong trí tưởng tượng của chàng
func _ba_lao(c: Node2D, p: Vector2, al: float) -> void:
	var col := Color("#6a5a6a", al)
	shape(c, round_pts(PackedVector2Array([p + Vector2(-30, 60), p + Vector2(-34, 0), p + Vector2(-10, -30), p + Vector2(26, -26), p + Vector2(34, 60)])), col, 3.0)
	c.draw_circle(p + Vector2(26, -40), 22.0, Color("#e8d0b0", al))
	c.draw_circle(p + Vector2(10, -56), 14.0, Color("#d8d8d8", al))
	c.draw_line(p + Vector2(48, -6), p + Vector2(62, 64), Color("#5a2e1c", al), 5.0)
	c.draw_line(p + Vector2(30, -4), p + Vector2(50, -6), col, 8.0)
	for i in 3:
		c.draw_line(p + Vector2(18 + i * 7, -36), p + Vector2(24 + i * 7, -34), Color(ink, al * 0.7), 2.0)


func _heart(c: Node2D, p: Vector2, s: float, al: float, crack: float) -> void:
	for side: float in [-1.0, 1.0]:
		var o := Vector2(side * crack * 10.0, 0)
		var pts := PackedVector2Array()
		for i in 13:
			var a := PI * 0.5 + side * i * PI / 12.0
			var x := 16.0 * pow(sin(a), 3.0)
			var y := -(13.0 * cos(a) - 5.0 * cos(2 * a) - 2.0 * cos(3 * a) - cos(4 * a))
			pts.append(p + o + Vector2(x, y) * s)
		pts.append(p + o + Vector2(0, -5) * s)
		shape(c, pts, Color("#d0404a", al), 3.0)
	if crack > 0.01:
		var z := PackedVector2Array([p + Vector2(0, -5) * s, p + Vector2(-3, 0) * s, p + Vector2(3, 5) * s, p + Vector2(-2, 10) * s, p + Vector2(0, 16) * s])
		c.draw_polyline(z, Color(ink, al), 3.0, true)


func _lip(a: Dictionary) -> Vector2:
	var to: Node2D = a.node.J["torso"]
	return from_w(to, to_w(a.node.J["head"], Vector2(0, -30)))


func _face_cover(a: Dictionary, k: float) -> void:
	var to: Node2D = a.node.J["torso"]
	var hp := from_w(to, to_w(a.node.J["head"], Vector2(0, -60)))
	a.hold["F"] = [hp + Vector2(40, 8), k]
	a.hold["B"] = [hp + Vector2(-20, 12), k]


func _dan_draw(c: Node2D) -> void:
	# đàn của cô (sau rèm, vẽ trước rèm để bị rèm che)
	if m == "k12" or t < L("k13-02") + 0.6:
		_dan(c, dd.pos, -1.0, Color("#3a2218") if m == "k12" else Color("#4a2a1a"))
	# đàn của Lục Trúc Ông / của chàng
	if m == "k12":
		var l3 := L("k12-03")
		var ok := bump(l3 - 0.3, l3 + 0.2, L("k12-07") - 0.2, L("k12-07") + 0.4)
		if ok > 0.01:
			_dan(c, ong.pos, 1.0, Color("#6a3a22"), ok)
			# dây đứt bật lên
			var sn := bump(l3 + 2.6, l3 + 2.8, l3 + 3.6, l3 + 4.4)
			if sn > 0.01:
				var e: Array = _cam_pts(ong.pos, 1.0)
				var a0: Vector2 = e[0]
				var a1: Vector2 = e[1]
				var mid := a0.lerp(a1, 0.6)
				c.draw_line(mid, mid + Vector2(30, -70) * sn, Color(1, 0.95, 0.8), 2.0)
				c.draw_line(mid, mid + Vector2(-40, -50) * sn, Color(1, 0.95, 0.8), 2.0)
		var lk := smooth(L("k12-07") + 2.0, L("k12-07") + 3.0, t)
		if lk > 0.01:
			_dan(c, LP, 1.0, Color("#6a3a22"), lk)


# ================================================================ k12

func _s12(_dt: float) -> void:
	var l1 := L("k12-01")
	var l2 := L("k12-02")
	var l3 := L("k12-03")
	var l4 := L("k12-04")
	var l5 := L("k12-05")
	var l6 := L("k12-06")
	var l7 := L("k12-07")
	var b7 := L("k12-07b")
	var l8 := L("k12-08")
	var l9 := L("k12-09")
	var l10 := L("k12-10")
	rain_of("leaf", 0.8, Rect2(-300, 200, 2400, 200), {"col": Color("#8fbf6a")})
	# chàng đi vào hẻm trúc
	if t > l1 and t < l7 and lhx.go == Vector2.INF and lhx.pos.x < 400.0:
		lhx.speed = 230.0
		lhx.go = Vector2(500, ground_y)
	# Lục Trúc Ông: đứng đón, ngồi gảy (03), rồi bỏ đi (07)
	var sit_o := smooth(l3 - 0.4, l3 + 0.2, t) * (1.0 - smooth(l7 - 0.4, l7, t))
	var oplay := sit_o * (1.0 - smooth(l3 + 2.6, l3 + 2.8, t))
	var obow := bump(l3 + 3.6, l3 + 4.0, l4 - 0.6, l4)
	ong.face = 1.0 if t > l3 - 0.4 and t < l7 else -1.0
	ong.extra = [[NGOI_XEP_BANG, sit_o], [{"torso": 26.0, "head": 16.0}, obow], [{"head": 10.0}, oplay]]
	ong.expr = "soc" if t > l3 + 2.7 and t < l3 + 4.0 else ("vui" if t < l3 else "binh")
	_dan_hold(ong, ong.pos, 1.0, oplay)
	if t > l7 and ong.go == Vector2.INF and ong.pos.x > -200.0:
		ong.speed = 160.0
		ong.go = Vector2(-400, ground_y)
	# chàng chìa cuốn phổ (02)
	var give := bump(l2 + 0.3, l2 + 0.9, l3 - 0.8, l3 - 0.3)
	var shock := bump(l5 + 0.2, l5 + 0.6, l5 + 2.0, l5 + 3.0)
	var heal := bump(l6 + 0.3, l6 + 1.0, LE("k12-06") - 0.5, LE("k12-06") + 0.3)
	var sit_l := smooth(l7 + 1.6, l7 + 2.2, t)
	var talk := smooth(l8, l8 + 0.4, t) * (1.0 - smooth(LE("k12-08") - 0.3, LE("k12-08"), t))
	var shrug := smooth(l10 + 0.4, l10 + 1.0, t)
	if t > l7 + 0.2 and t < l7 + 1.8 and lhx.go == Vector2.INF and lhx.pos.x < LP.x - 10.0:
		lhx.speed = 200.0
		lhx.go = LP
	lhx.extra = [[NGOI_XEP_BANG, sit_l], [{"uaF": -80.0, "faF": -10.0}, give], [{"torso": -10.0, "head": -10.0}, shock],
		[{"torso": -6.0, "head": -16.0, "uaF": -40.0, "uaB": -40.0}, heal],
		[{"head": sin(t * 3.0) * 4.0 * talk, "torso": 8.0}, talk], [{"uaF": 50.0, "faF": -120.0, "uaB": 50.0, "faB": -120.0, "head": 12.0, "torso": -4.0}, shrug]]
	var lplay := sit_l * (1.0 - talk) * (1.0 - smooth(l9 - 0.2, l9 + 0.3, t)) * (1.0 - smooth(b7, b7 + 0.1, t) * 0.0)
	_dan_hold(lhx, LP, 1.0, lplay * (1.0 - shrug), 1.3)
	lhx.talk = talk
	if t < l7:
		lhx.expr = "soc" if shock > 0.4 else ("vui" if heal > 0.3 or t > l5 + 2.0 else ("ngai" if t > l4 else "binh"))
	else:
		lhx.expr = "buon" if talk > 0.3 else ("soc" if t > l9 and t < l10 else ("ngai" if shrug > 0.3 else "vui"))
	# cái bóng sau rèm
	var dplay := smooth(l5 - 0.3, l5 + 0.3, t) * (1.0 - smooth(l8, l8 + 0.5, t)) + bump(l7 + 2.0, l7 + 2.4, l8, l8 + 0.5) * 0.0
	var lean := smooth(l8 + 0.8, l8 + 2.0, t) * (1.0 - smooth(l9, l9 + 0.6, t))
	var cover := smooth(l10 + 1.0, l10 + 1.6, t)
	dd.extra = [[NGOI_XEP_BANG, 1.0], [{"torso": 18.0, "head": 14.0}, lean], [{"head": 8.0 + sin(t * 1.4) * 3.0}, dplay]]
	_dan_hold(dd, DP, -1.0, maxf(dplay, 0.3) * (1.0 - cover))
	if cover > 0.01:
		_face_cover(dd, cover)


func _c12() -> Array:
	var l1 := L("k12-01")
	var l2 := L("k12-02")
	var l3 := L("k12-03")
	var l4 := L("k12-04")
	var l5 := L("k12-05")
	var l6 := L("k12-06")
	var l7 := L("k12-07")
	var b7 := L("k12-07b")
	var l8 := L("k12-08")
	var l9 := L("k12-09")
	var l10 := L("k12-10")
	if t < l2:
		return [Vector2(lerpf(360.0, 860.0, smooth(l1, l2, t)), 540.0), 1.0]
	if t < l3:
		return [Vector2(640, 640), 1.5]
	if t < l4:
		return [Vector2(lerpf(820.0, 1000.0, smooth(l3 + 2.6, l3 + 3.8, t)), 620.0), 1.3]
	if t < l5:
		return [Vector2(620, 560), 1.4]
	if t < l6:
		return [Vector2(880, 620), 1.15]
	if t < l7:
		return [Vector2(560, 640), 1.6]
	if t < b7:
		return [Vector2(1000, 600), 1.1]
	if t < l8:
		return [Vector2(960, 540), 1.0]
	if t < l9:
		return [Vector2(1000, 640), 1.35]
	if t < l10:
		return [Vector2(820, 580), 1.05]
	return [Vector2(1000, 620), 1.25]


func _n12(c: Node2D) -> void:
	var l2 := L("k12-02")
	var l3 := L("k12-03")
	var l4 := L("k12-04")
	var l5 := L("k12-05")
	var l6 := L("k12-06")
	var l7 := L("k12-07")
	var l8 := L("k12-08")
	var l9 := L("k12-09")
	var l10 := L("k12-10")
	# cuốn phổ trong tay chàng (02) → sang Lục Trúc Ông
	var sc := bump(l2 + 0.3, l2 + 0.9, l3 + 0.5, l3 + 1.0)
	if sc > 0.01:
		var hp := to_w(lhx.node.J["hdF"], Vector2.ZERO)
		var op := to_w(ong.node.J["hdF"], Vector2.ZERO)
		var p := hp.lerp(op, smooth(l3 - 0.9, l3 - 0.3, t))
		c.draw_rect(Rect2(p + Vector2(-26, -10), Vector2(52, 20)), Color("#efe2bf", sc))
		c.draw_rect(Rect2(p + Vector2(-26, -10), Vector2(52, 20)), Color(ink, sc), false, 3.0)
	# bong bóng nghĩ: bà lão chống gậy (04)
	var tb := bump(l4 + 0.3, l4 + 0.9, l5 - 0.4, l5 + 0.1)
	if tb > 0.01:
		var hd := head_of(lhx)
		var ctr := hd + Vector2(150, -190)
		_bubble(c, hd + Vector2(40, -60), ctr, Vector2(110, 90), tb)
		_ba_lao(c, ctr + Vector2(-10, -10), tb)
	# nốt nhạc lọt qua khe rèm bay sang chàng (05) — luân phiên chàng và rèm khi học (07)
	var bstart := l5 + 0.2
	var b := bstart
	var i := 0
	while b < minf(t, l8):
		var age := t - b
		if age < 3.2:
			var in_lesson := b > l7 + 2.5
			var from_l := in_lesson and i % 2 == 1
			var src := Vector2(DP.x - 40, 700) if not from_l else Vector2(LP.x + 60, 790)
			var dst := head_of(lhx) + Vector2(20, -20) if not from_l else Vector2(DOOR0 + 60, 650)
			var u := age / 3.2
			var p := src.lerp(dst, u) + Vector2(0, -sin(u * PI) * 120.0)
			_note(c, p, 1.0, GOLD if not from_l else JADE, smooth(0.0, 0.3, age) * (1.0 - smooth(2.6, 3.2, age)))
		if b < l6 or b > l7 + 2.5:
			b += 0.45
		else:
			b += 9.0
		i += 1
	# vòng sóng xanh dịu bọc lấy chàng (06)
	var hk := bump(l6 + 0.3, l6 + 1.0, LE("k12-06") - 0.5, LE("k12-06") + 0.3)
	if hk > 0.01:
		var cp := to_w(lhx.node.J["torso"], Vector2(0, -60))
		for j in 4:
			var r := fmod(t * 60.0 + j * 50.0, 200.0)
			c.draw_arc(cp, 40.0 + r, 0.0, TAU, 48, Color(0.5, 1.0, 0.75, hk * (1.0 - r / 200.0)), 5.0, true)
	# tim vỡ trong bong bóng nghĩ (08)
	var hb := bump(l8 + 1.0, l8 + 1.6, LE("k12-08") - 0.4, LE("k12-08") + 0.2)
	if hb > 0.01:
		var hd := head_of(lhx)
		var ctr := hd + Vector2(-60, -200)
		_bubble(c, hd + Vector2(-10, -70), ctr, Vector2(90, 76), hb)
		_heart(c, ctr + Vector2(0, -6), 3.2, hb, smooth(l8 + 2.4, l8 + 3.4, t))
	# quà bay tới từ hai phía rồi chất quanh chàng (09)
	for g: Array in gifts:
		var tb0: float = g[3]
		if t < tb0:
			continue
		var gx: float = g[0]
		var gy: float = g[1]
		var kind: int = g[2]
		var sd: int = g[4]
		var u := smooth(tb0, tb0 + 0.9, t)
		var src := Vector2(-200.0 if sd < 0 else 2000.0, 300.0)
		var dst := Vector2(gx, gy)
		var mid := (src + dst) * 0.5 + Vector2(0, -260)
		var p := src.lerp(mid, u).lerp(mid.lerp(dst, u), u)
		_gift(c, p, kind, (1.0 - u) * 6.0 * sd)
	# "?" trên đầu chàng (10)
	var qk := smooth(l10 + 0.8, l10 + 1.4, t)
	if qk > 0.01:
		var hd := head_of(lhx) + Vector2(0, -150)
		c.draw_string_outline(font, hd + Vector2(-20, 0), "?", HORIZONTAL_ALIGNMENT_LEFT, -1, 110, 10, Color(ink, qk))
		c.draw_string(font, hd + Vector2(-20, 0), "?", HORIZONTAL_ALIGNMENT_LEFT, -1, 110, Color("#c8322c", qk))


func _gift(c: Node2D, p: Vector2, kind: int, rot: float) -> void:
	c.draw_set_transform(p, rot, Vector2(1.5, 1.5))
	if kind == 0:
		shape(c, round_pts(PackedVector2Array([Vector2(-22, 0), Vector2(-26, -30), Vector2(-12, -44), Vector2(12, -44), Vector2(26, -30), Vector2(22, 0)])), Color("#a8743e"), 3.0)
		c.draw_rect(Rect2(-16, -54, 32, 10), Color("#c8322c"))
	elif kind == 1:
		c.draw_rect(Rect2(-30, -34, 60, 34), Color("#c8322c"))
		c.draw_rect(Rect2(-30, -34, 60, 34), Color(ink), false, 3.0)
		c.draw_line(Vector2(0, -34), Vector2(0, 0), Color("#f0c060"), 5.0)
	elif kind == 2:
		for j in 5:
			c.draw_line(Vector2(-6 + j * 3, 0), Vector2(-20 + j * 9, -46), Color("#5a8a3a"), 4.0)
		c.draw_rect(Rect2(-10, -16, 20, 8), Color("#c9a35a"))
	else:
		c.draw_circle(Vector2(0, -18), 18.0, Color("#e6e2c8"))
		c.draw_arc(Vector2(0, -18), 18.0, 0.0, TAU, 24, Color(ink), 3.0)
		c.draw_rect(Rect2(-6, -42, 12, 8), Color("#5a2e1c"))
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


# ================================================================ k13

func _s13(_dt: float) -> void:
	var l1 := L("k13-01")
	var l2 := L("k13-02")
	var l3 := L("k13-03")
	var b3 := L("k13-03b")
	var l4 := L("k13-04")
	var l5 := L("k13-05")
	# bóng hoá người
	var reveal := smooth(l1 + 0.9, l1 + 3.0, t)
	dd.tint = SHADOW.lerp(Color.WHITE, reveal)
	var stand := smooth(l2 + 0.2, l2 + 0.9, t)
	var shy := bump(b3 + 0.2, b3 + 0.7, b3 + 2.6, b3 + 3.0)
	var order := bump(b3 + 3.0, b3 + 3.5, LE("k13-03b") - 0.4, LE("k13-03b") + 0.2)
	dd.extra = [[NGOI_XEP_BANG, 1.0 - stand], [{"head": 8.0}, 1.0 - stand], [{"torso": 14.0, "head": 18.0}, shy], ["point", order]]
	dd.face = 1.0 if shy > 0.5 else -1.0
	if stand < 0.5:
		_dan_hold(dd, DP, -1.0, 0.6 * (1.0 - smooth(l1 + 0.5, l1 + 1.0, t)))
	if shy > 0.01:
		_face_cover(dd, shy)
	dd.expr = "ngai" if shy > 0.3 else ("quyet-tam" if order > 0.3 else ("vui" if t > l4 else "binh"))
	# mang bát thuốc đến (04)
	if t > l4 + 0.5 and t < l5 and dd.go == Vector2.INF and dd.pos.x > 960.0:
		dd.speed = 170.0
		dd.go = Vector2(955, ground_y)
	var bowl := smooth(l4, l4 + 0.4, t) * (1.0 - smooth(l4 + 3.6, l4 + 4.0, t))
	if bowl > 0.01:
		dd.hold["F"] = [Vector2(70, -70), bowl]
	# chàng: sững sờ, đỏ mặt ôm má, nhận bát, uống rượu
	var blush := smooth(l3 + 0.2, l3 + 1.2, t)
	var hands := bump(l3 + 0.4, l3 + 1.0, b3 - 0.4, b3 + 0.2)
	var take := bump(l4 + 3.4, l4 + 3.8, l5 - 0.3, l5)
	var drink := smooth(l5 + 1.0, l5 + 1.6, t)
	lhx.extra = [[NGOI_XEP_BANG, 1.0], [{"torso": -12.0, "head": -10.0}, bump(l1 + 2.0, l1 + 2.6, l3, l3 + 0.5)],
		[{"head": 10.0, "torso": 6.0}, hands], [{"head": -20.0, "torso": -8.0}, drink]]
	lhx.hold.clear()
	if hands > 0.01:
		_face_cover(lhx, hands)
	if take > 0.01:
		lhx.hold["F"] = [Vector2(76, -66), take]
	if t > l5 + 0.4 and ho.at != "tay":
		prop_to(ho, "tay", "F")
	var lip := _lip(lhx)
	if t > l5 + 0.4:
		lhx.hold["F"] = [Vector2(70, -60).lerp(lip + Vector2(12, -12), drink), 1.0]
	ho.lock = drink
	ho.lockdir = Vector2(0.75, -0.66)
	ho.aim = Vector2(0, -30)
	ho.pour = bump(l5 + 1.6, l5 + 1.8, l5 + 3.6, l5 + 3.8)
	ma.amount = maxf(blush * (1.0 - smooth(l4, l4 + 1.5, t) * 0.6), smooth(l5 + 2.0, l5 + 3.0, t))
	lhx.expr = "soc" if t > l1 + 2.0 and t < l3 else ("ngai" if hands > 0.3 else ("vui" if t > l5 + 1.0 else "binh"))
	if t > l5 + 2.0:
		rain_of("petal", 6.0, Rect2(500, 200, 900, 100), {"col": WINE5})


func _c13() -> Array:
	var l1 := L("k13-01")
	var l2 := L("k13-02")
	var l3 := L("k13-03")
	var b3 := L("k13-03b")
	var l4 := L("k13-04")
	var l5 := L("k13-05")
	if t < l2:
		return [Vector2(1040, 620), lerpf(1.1, 1.35, smooth(l1, l1 + 3.0, t))]
	if t < l3:
		return [Vector2(1130, 600), 1.3]
	if t < b3:
		return [Vector2(840, 650), lerpf(1.4, 1.75, smooth(l3, l3 + 1.5, t))]
	if t < l4:
		return [Vector2(760, 580), 1.0]
	if t < l5:
		return [Vector2(820, 560), 1.0]
	return [Vector2(880, 640), lerpf(1.2, 1.6, smooth(l5, l5 + 2.5, t))]


func _n13(c: Node2D) -> void:
	var l3 := L("k13-03")
	var b3 := L("k13-03b")
	var l4 := L("k13-04")
	var l5 := L("k13-05")
	# những bong bóng lời tâm sự bay ngược vào đầu chàng (03)
	var bk := bump(l3 + 1.0, l3 + 1.4, b3 - 0.4, b3)
	if bk > 0.01:
		var hd := head_of(lhx)
		for i in 5:
			var u := fmod((t - l3 - 1.0) * 0.45 + i * 0.2, 1.0)
			var src := hd + Vector2(260 + i * 30, -260 + i * 50)
			var p := src.lerp(hd + Vector2(0, -40), u)
			var s := 1.0 - u * 0.8
			c.draw_set_transform(p, 0.0, Vector2(s, s))
			shape(c, round_pts(PackedVector2Array([Vector2(-40, -24), Vector2(40, -24), Vector2(40, 18), Vector2(-10, 18), Vector2(-26, 34), Vector2(-22, 18), Vector2(-40, 18)])), Color(1, 1, 1, bk), 3.0)
			for j in 3:
				c.draw_circle(Vector2(-18 + j * 18, -3), 5.0, Color(ink, bk))
			c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	# mũ người giang hồ thập thò trong trúc rồi thụt xuống (03b)
	var hk := smooth(b3 - 0.2, b3 + 0.5, t) * (1.0 - smooth(l4 + 0.5, l4 + 1.0, t))
	if hk > 0.01:
		var duck := smooth(b3 + 3.4, b3 + 4.0, t)
		for i in 5:
			var p := Vector2(130 + i * 80, ground_y - 170 + duck * 110.0 + (i % 2) * 14.0)
			c.draw_circle(p, 26.0, Color("#e8c8a0", hk))
			c.draw_arc(p, 26.0, 0.0, TAU, 24, Color(ink, hk), 3.0)
			shape(c, PackedVector2Array([p + Vector2(-50, -14), p + Vector2(0, -50), p + Vector2(50, -14)]), Color("#c9a35a", hk), 3.0)
			if duck < 0.5:
				c.draw_circle(p + Vector2(8, -2), 4.0, Color(ink, hk))
		# bụi cây che
		for i in 6:
			c.draw_circle(Vector2(110 + i * 75, ground_y - 50), 70.0, Color("#4f7f48", hk))
			c.draw_arc(Vector2(110 + i * 75, ground_y - 50), 70.0, PI, TAU, 18, Color(ink, hk * 0.6), 3.0)
	# bát thuốc
	var bowl := smooth(l4, l4 + 0.4, t) * (1.0 - smooth(l5 - 0.2, l5 + 0.2, t))
	if bowl > 0.01:
		var hp := to_w(dd.node.J["hdF"], Vector2.ZERO).lerp(to_w(lhx.node.J["hdF"], Vector2.ZERO), smooth(l4 + 3.4, l4 + 3.9, t))
		shape(c, PackedVector2Array([hp + Vector2(-30, -16), hp + Vector2(30, -16), hp + Vector2(20, 6), hp + Vector2(-20, 6)]), Color("#e6e2c8", bowl), 3.0)
		c.draw_rect(Rect2(hp + Vector2(-26, -18), Vector2(52, 4)), Color("#5a3a22", bowl))
		for j in 3:
			var sy := fmod(t * 30.0 + j * 14.0, 40.0)
			c.draw_circle(hp + Vector2(-12 + j * 12, -24 - sy), 5.0, Color(1, 1, 1, 0.4 * bowl * (1.0 - sy / 40.0)))
