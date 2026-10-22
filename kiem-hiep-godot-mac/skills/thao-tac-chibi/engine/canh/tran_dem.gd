extends "res://canh.gd"
# Phố trấn ban đêm: đèn lồng đung đưa hắt quầng ấm xuống đường đá, cửa sổ chập chờn, khói bếp, đom đóm, trăng có mây trôi qua.

var stars: Array = []
var far_roofs: Array = []
var lamps: Array = []         # tâm đèn trong khung hiện tại (vẽ quầng ở _glow)
var a: Dictionary
var b: Dictionary


func _palette() -> void:
	sky_top = Color("#11163a")
	sky_bot = Color("#4b3a74")
	haze = Color("#3b3468")
	ink = Color("#120b1c")
	char_tint = Color(0.86, 0.84, 1.0)
	ground_y = 900.0
	wind_base = 0.12
	wind_gust = 0.35
	vign_a = 0.55
	caption = "Phố trấn · đêm đèn lồng"


func _build() -> void:
	for i in 140:
		stars.append([Vector2(rng.randf() * 2300 - 200, rng.randf() * 520), rng.randf_range(0.8, 2.4), rng.randf() * TAU])
	var x := -250.0
	while x < 2200.0:
		var wd := rng.randf_range(150, 260)
		far_roofs.append([x + wd * 0.5, wd, rng.randf_range(90, 170), rng.randi() % 3, rng.randf() * TAU])
		x += wd + rng.randf_range(-20, 30)
	a = actor("vi-nhat-tieu", Vector2(720, ground_y), 1.0)
	b = actor("hiep-khach", Vector2(1230, ground_y), -1.0)


func _story(_dt: float) -> void:
	rain_of("firefly", 1.6, Rect2(-100, 350, 2100, 500), {"col": Color(1.0, 0.85, 0.35), "life": 9.0})
	rain_of("smoke", 2.2, Rect2(1668, 160, 24, 6), {"col": Color(0.5, 0.5, 0.66), "max": 4.5, "life": 4.5, "s": 0.6})
	if a.is_empty():
		return
	a.talk = smooth(0.4, 0.7, t) * (1.0 - smooth(3.3, 3.6, t))
	a.expr = "vui" if t < 3.6 else ("soc" if t < 5.5 else "binh")
	b.talk = smooth(3.8, 4.1, t) * (1.0 - smooth(7.0, 7.3, t))
	b.expr = "gian" if t > 3.8 else "binh"


func _cam() -> Array:
	return [Vector2(960.0 + sin(t * 0.25) * 25.0, 610.0), lerpf(1.12, 1.2, smooth(0.0, 8.0, t))]


func _sky(c: Node2D) -> void:
	for s in stars:
		var tw := 0.55 + 0.45 * sin(t * 2.0 + s[2])
		c.draw_circle(s[0], s[1], Color(1.0, 0.95, 0.8, tw), true, -1.0, true)
	var m := Vector2(1480, 190)
	blob(c, m, 420.0, Color(0.75, 0.7, 1.0, 0.35))
	c.draw_circle(m, 84.0, inkof(Color("#fff3c4"), 0.5), true, -1.0, true)
	c.draw_circle(m, 80.0, Color(1.35, 1.3, 1.05), true, -1.0, true)
	for q in [[Vector2(-25, -20), 16.0], [Vector2(28, 14), 11.0], [Vector2(-10, 35), 8.0]]:
		c.draw_circle(m + q[0], q[1], Color(1.0, 0.95, 0.75, 0.9), true, -1.0, true)
	for i in 3:
		var x := fposmod(200.0 + i * 800.0 + t * 22.0, 2600.0) - 400.0
		cloud(c, Vector2(x, 170.0 + i * 60.0), 1.0 - i * 0.2, Color("#3a3870"), 3.0)


func _far(c: Node2D) -> void:
	for r in far_roofs:
		var cx: float = r[0]
		var wd: float = r[1]
		var ht: float = r[2]
		var y := 760.0
		var col := air(Color("#2a2752"), 0.25)
		c.draw_rect(Rect2(cx - wd * 0.42, y - ht, wd * 0.84, ht + 200), col)
		var roof := round_pts(PackedVector2Array([Vector2(cx - wd * 0.55, y - ht - 6), Vector2(cx, y - ht + 4), Vector2(cx + wd * 0.55, y - ht - 6),
			Vector2(cx + wd * 0.3, y - ht - 50), Vector2(cx - wd * 0.3, y - ht - 50)]), true, 4)
		shape(c, roof, col.darkened(0.25), 0.0)
		var fl := 0.8 + 0.2 * sin(t * 6.0 + float(r[4]) * 3.0)
		if int(r[3]) != 0:
			c.draw_rect(Rect2(cx - 16, y - ht * 0.6, 32, 26), Color(1.4, 0.95, 0.45) * fl)


func _mid(c: Node2D) -> void:
	# tháp chùa xa
	var col := air(Color("#3b3570"), 0.15)
	for i in 4:
		var y := 760.0 - i * 110.0
		var wd := 260.0 - i * 45.0
		c.draw_rect(Rect2(380 - wd * 0.35, y - 90, wd * 0.7, 92), col)
		var rp := round_pts(PackedVector2Array([Vector2(380 - wd * 0.62, y - 78), Vector2(380, y - 70), Vector2(380 + wd * 0.62, y - 78),
			Vector2(380 + wd * 0.3, y - 120), Vector2(380 - wd * 0.3, y - 120)]), true, 4)
		shape(c, rp, col.darkened(0.3), 0.0)
		c.draw_rect(Rect2(370, y - 60, 20, 26), Color(1.5, 1.0, 0.45) * (0.85 + 0.15 * sin(t * 5.0 + i)))
	c.draw_line(Vector2(380, 330), Vector2(380, 270), col.darkened(0.3), 6.0)


func _ground(c: Node2D) -> void:
	var g := ground_y
	lamps.clear()
	# nền đường đá
	vgrad(c, Rect2(-300, g - 60, W + 600, H), Color("#3b3760"), Color("#221f3c"))
	for row in 5:
		var y := g - 50.0 + row * 34.0 + row * row * 6.0
		c.draw_line(Vector2(-300, y), Vector2(W + 300, y), Color(ink, 0.45), 2.5, true)
		var off := 60.0 if row % 2 == 0 else 0.0
		var x := -300.0 + off
		while x < W + 300:
			c.draw_line(Vector2(x, y), Vector2(x - 6, y + 34 + row * 8), Color(ink, 0.35), 2.0, true)
			x += 130.0 + row * 20.0
	var w1 := house(c, Vector2(330, g - 60), 660, 520, Color("#8c7fa8"), Color("#3a3f7c"), Color("#5c3b3f"), 1.0, 5.0, 1)
	var w2 := house(c, Vector2(1620, g - 60), 640, 500, Color("#857aa3"), Color("#47306e"), Color("#5c3b3f"), 1.0, 5.0, 2)
	# ống khói
	shape(c, PackedVector2Array([Vector2(1660, 190), Vector2(1660, 150), Vector2(1700, 150), Vector2(1700, 190)]), Color("#5c3b3f"), 4.0)
	# biển hiệu quán
	var sp := Vector2(330, g - 520 + 40)
	shape(c, PackedVector2Array([sp + Vector2(-120, -5), sp + Vector2(120, -5), sp + Vector2(120, 55), sp + Vector2(-120, 55)]), Color("#2e1d16"), 4.0)
	c.draw_string(font, sp + Vector2(-90, 40), "KHÁCH ĐIẾM", HORIZONTAL_ALIGNMENT_LEFT, -1, 36, Color(1.6, 1.15, 0.5))
	# dây đèn lồng giữa hai mái (dây võng)
	var p0 := Vector2(700, 380)
	var p1 := Vector2(1290, 370)
	var rope := PackedVector2Array()
	for i in 21:
		var k := float(i) / 20.0
		rope.append(p0.lerp(p1, k) + Vector2(0, sin(k * PI) * (70.0 + sin(t * 1.2) * 6.0)))
	c.draw_polyline(rope, ink, 3.0, true)
	for i in 5:
		var k := (i + 1) / 6.0
		var top := p0.lerp(p1, k) + Vector2(0, sin(k * PI) * (70.0 + sin(t * 1.2) * 6.0))
		var col: Color = [Color(1.5, 0.35, 0.2), Color(1.6, 0.9, 0.3)][i % 2]
		lamps.append([lantern(c, top, 30.0, 30.0, col, i * 7), col])
	for q in [[Vector2(690, 400), 60.0], [Vector2(1300, 390), 60.0]]:
		var col := Color(1.5, 0.35, 0.2)
		lamps.append([lantern(c, q[0], q[1], 38.0, col, int(q[0].x)), col])
	for wv in w1 + w2:
		lamps.append([wv, Color(1.2, 0.75, 0.3, 0.5)])


func _near(c: Node2D) -> void:
	# chum rượu + giỏ trước quán
	puff(c, [[Vector2(120, ground_y + 40), 50.0], [Vector2(120, ground_y - 10), 38.0]], Color("#7a4a35"), 4.0, 0.2)
	puff(c, [[Vector2(220, ground_y + 60), 34.0]], Color("#8a5a3c"), 4.0, 0.2)


func _glow(c: Node2D) -> void:
	for L in lamps:
		var p: Vector2 = L[0]
		var col: Color = L[1]
		var fl := 0.85 + 0.15 * sin(t * 8.0 + p.x)
		blob(c, p, 170.0 * fl, Color(col, 0.22 * col.a))
		flat_blob(c, Vector2(p.x, ground_y + 20), 200.0, 0.22, Color(col, 0.06 * col.a))


func _front(c: Node2D) -> void:
	# mái hiên sát ống kính góc trên + đèn lồng lớn mờ
	var rp := round_pts(PackedVector2Array([Vector2(1500, -100), Vector2(2300, -100), Vector2(2300, 60), Vector2(1900, 30), Vector2(1560, 70)]), true, 4)
	shape(c, rp, Color("#1d1636"), 6.0)
	var lp := lantern(c, Vector2(140, -60), 150.0, 70.0, Color(1.3, 0.3, 0.18), 99, 6.0)
	blob(c, lp, 260.0, Color(1.0, 0.4, 0.2, 0.25))
