extends "res://canh.gd"
# Đỉnh tuyết lộng gió: tuyết quất xiên theo cơn giật, tuyết cuốn sát mặt đất, biển mây trôi dưới chân, cờ quất phần phật,
# thông oằn tuyết lắc, hơi thở phả khói, tóc/áo nhân vật bay mạnh. Hai người đứng thế đối đầu, camera đẩy dần vào.

var a: Dictionary
var b: Dictionary
var breath := 0.0


func _palette() -> void:
	sky_top = Color("#5a86cf")
	sky_bot = Color("#dcebfb")
	haze = Color("#cddff3")
	ink = Color("#17203a")
	char_tint = Color(0.94, 0.97, 1.06)
	ground_y = 880.0
	wind_base = 0.85
	wind_gust = 1.0
	vign_a = 0.38
	caption = "Đỉnh tuyết · gió lộng"


func _build() -> void:
	a = actor("tieu-phong", Vector2(650, ground_y), 1.0)
	a.base = "stance"
	a.expr = "quyet-tam"
	a.sway = 1.5
	b = actor("diet-tuyet", Vector2(1290, ground_y), -1.0)
	b.base = "stance"
	b.expr = "gian"
	b.sway = 1.5


func _story(dt: float) -> void:
	_weather()
	if a.is_empty() or t < 0.0:
		return
	_breath(dt, [a, b])
	if t > 5.5:
		b.expr = "soc" if t < 6.5 else "gian"


func _weather() -> void:
	rain_of("snow", 60.0, Rect2(-900, -200, 2700, 120), {"col": Color(1, 1, 1), "life": 12.0, "s": rng.randf_range(0.7, 1.4)})
	rain_of("snow", 25.0, Rect2(-700, -100, 200, 1000), {"col": Color(1, 1, 1), "life": 12.0, "s": rng.randf_range(0.7, 1.4)})
	rain_of("drift", 9.0, Rect2(-500, ground_y - 70, 400, 160), {"life": 4.0, "z": rng.randf_range(0.8, 1.3)})


func _breath(dt: float, who_list: Array) -> void:
	breath += dt
	if breath > 1.7:
		breath = 0.0
		for who in who_list:
			var hp := head_of(who)
			var face: float = who.face
			spawn("smoke", hp + Vector2(face * 60.0, 40.0), {"col": Color(1, 1, 1), "max": 1.4, "life": 1.4, "s": 0.35, "z": 1.1})


func _cam() -> Array:
	return [Vector2(970.0, lerpf(620.0, 640.0, smooth(0.0, 8.0, t))), lerpf(1.08, 1.24, smooth(0.0, 8.0, t))]


func _sky(c: Node2D) -> void:
	blob(c, Vector2(1600, 120), 380.0, Color(1.0, 1.0, 0.95, 0.6))
	c.draw_circle(Vector2(1600, 120), 54.0, Color(1.4, 1.38, 1.25), true, -1.0, true)
	for i in 5:
		var x := fposmod(i * 520.0 + t * 90.0, 2700.0) - 400.0
		var y := 90.0 + i * 55.0
		c.draw_line(Vector2(x, y), Vector2(x + 260, y), Color(1, 1, 1, 0.35), 10.0, true)
		c.draw_line(Vector2(x + 80, y + 14), Vector2(x + 300, y + 14), Color(1, 1, 1, 0.22), 6.0, true)


func _peaks(c: Node2D, peaks: Array, base: float, col: Color, snow_y: float) -> void:
	var mp := mountain_pts(peaks, base)
	shape(c, mp, col, 0.0)
	# mảng bóng: nửa phải mỗi đỉnh
	for pk in peaks:
		var p: Vector2 = pk
		clip_fill(c, mp, PackedVector2Array([p, p + Vector2(500, 700), p + Vector2(40, 700)]), col.darkened(0.18))
	# mũ tuyết: phần trên một đường lượn
	var cap := PackedVector2Array([Vector2(-400, -200), Vector2(W + 400, -200)])
	for i in range(24, -1, -1):
		var x := -400.0 + i * 113.0
		cap.append(Vector2(x, snow_y + sin(i * 2.1) * 26.0 + (35.0 if i % 2 == 0 else 0.0)))
	clip_fill(c, mp, cap, air(Color("#f4f8ff"), 0.15))
	for pk in peaks:
		var p: Vector2 = pk
		clip_fill(c, mp, PackedVector2Array([p, p + Vector2(400, 600), p + Vector2(30, 600)]), Color(0.55, 0.65, 0.9, 0.35))


func _far(c: Node2D) -> void:
	_peaks(c, [Vector2(-50, 420), Vector2(330, 250), Vector2(640, 420), Vector2(960, 300), Vector2(1350, 210), Vector2(1700, 380), Vector2(2050, 300)], 760, air(Color("#7d8fc4"), 0.45), 400)
	_peaks(c, [Vector2(-150, 560), Vector2(420, 430), Vector2(900, 560), Vector2(1550, 450), Vector2(2100, 560)], 800, air(Color("#6377b0"), 0.25), 510)


func _mid(c: Node2D) -> void:
	# biển mây trôi phủ chân núi
	for row in 3:
		var y := 600.0 + row * 55.0
		var sp := 14.0 + row * 10.0
		for i in 9:
			var x := fposmod(i * 300.0 + row * 140.0 + t * sp, 2700.0) - 400.0
			cloud(c, Vector2(x, y), 1.1 + row * 0.15, Color("#ffffff").lerp(Color("#c4d4f0"), 0.35 - row * 0.12), 3.0)


func _back(c: Node2D) -> void:
	for q in [[Vector2(80, 900), 420.0, 230.0], [Vector2(250, 910), 330.0, 190.0], [Vector2(1720, 900), 400.0, 220.0], [Vector2(1880, 910), 300.0, 180.0]]:
		pine(c, q[0], q[1], q[2], Color("#2f6d5e"), 1.0, 4.5, int(q[0].x))


func _ground(c: Node2D) -> void:
	var top := PackedVector2Array()
	for i in 21:
		top.append(Vector2(-300.0 + i * 130.0, ground_y - 50.0 + sin(i * 1.1) * 18.0 + (20.0 if i % 3 == 0 else 0.0)))
	var poly := round_pts(top, false, 4)
	poly.append(Vector2(W + 300, H + 300))
	poly.append(Vector2(-300, H + 300))
	shape(c, poly, Color("#eef4ff"), 4.0, Color("#7d8fc4"))
	vgrad(c, Rect2(-300, ground_y + 40, W + 600, 400), Color(0.6, 0.7, 0.95, 0.0), Color(0.55, 0.65, 0.92, 0.5))
	# đá phủ tuyết
	for s in [[Vector2(260, ground_y + 70), 40.0], [Vector2(1560, ground_y + 40), 30.0], [Vector2(980, ground_y + 150), 26.0]]:
		var p: Vector2 = s[0]
		var r: float = s[1]
		puff(c, [[p, r], [p + Vector2(r, 8), r * 0.75]], Color("#7a7f98"), 3.5, 0.15)
		c.draw_set_transform(p + Vector2(r * 0.3, -r * 0.62), 0.0, Vector2(1.0, 0.38))
		c.draw_circle(Vector2.ZERO, r * 1.25, Color("#f4f8ff"), true, -1.0, true)
		c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	# vết chân
	for i in 8:
		var p := Vector2(150.0 + i * 60.0, ground_y + 10.0 + (i % 2) * 18.0)
		c.draw_set_transform(p, 0.0, Vector2(1.0, 0.4))
		c.draw_circle(Vector2.ZERO, 12.0, Color(0.6, 0.7, 0.95, 0.6), true, -1.0, true)
		c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	# cột cờ
	var pole := Vector2(1560, ground_y - 30)
	shape(c, PackedVector2Array([pole + Vector2(-7, 0), pole + Vector2(-5, -520), pole + Vector2(5, -520), pole + Vector2(7, 0)]), Color("#5a3a2a"), 3.5)
	flag(c, pole + Vector2(4, -510), 300.0, 120.0, Color("#d8352a"), 4.0)
	c.draw_circle(pole + Vector2(0, -526), 10.0, Color("#e8b030"), true, -1.0, true)


func _near(c: Node2D) -> void:
	pass


func _front(c: Node2D) -> void:
	pine(c, Vector2(-80, 1250), 700.0, 480.0, Color("#204d43"), 1.0, 6.0, 5)
