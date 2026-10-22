extends "res://canh.gd"
# Rừng trúc buổi sớm: gió lùa trúc nghiêng từng đợt, lá trúc bay, tia nắng xiên có bụi, chim bay ngang, cỏ rạp theo gió.

var far_x: Array = []
var mid_x: Array = []
var hero: Dictionary
var ban: Dictionary


func _palette() -> void:
	sky_top = Color("#9fd8c8")
	sky_bot = Color("#fbf1cc")
	haze = Color("#d6ecd2")
	ink = Color("#1d2b20")
	char_tint = Color(1.0, 1.0, 0.96)
	ground_y = 870.0
	wind_base = 0.3
	wind_gust = 0.75
	vign_a = 0.3
	caption = "Rừng trúc · buổi sớm"


func _build() -> void:
	_bg()
	hero = actor("doan-du", Vector2(-160, ground_y), 1.0)
	hero.go = Vector2(700, ground_y)
	hero.speed = 210.0
	hero.expr = "vui"
	ban = actor("tieu-phong", Vector2(1260, ground_y), -1.0)


func _bg() -> void:
	for i in 34:
		far_x.append([-200.0 + i * 70.0 + rng.randf_range(-20, 20), rng.randf_range(0.8, 1.2), rng.randi()])
	for i in 10:
		mid_x.append([-150.0 + i * 235.0 + rng.randf_range(-40, 40), rng.randf_range(0.85, 1.15), rng.randi()])


func _story(_dt: float) -> void:
	_weather()
	if hero.is_empty():
		return
	if t > 4.4:
		ban.talk = smooth(4.4, 4.8, t) * (1.0 - smooth(7.0, 7.3, t))
		ban.expr = "vui"
	if t > 5.0:
		hero.expr = "binh" if t < 6.2 else "vui"


func _weather() -> void:
	rain_of("leaf", 7.0, Rect2(-500, -150, 1500, 300),
		{"col": [Color("#7cc05a"), Color("#a7cf5c"), Color("#d9c25a")][rng.randi() % 3], "land": ground_y + rng.randf_range(-10, 160), "life": 14.0})
	rain_of("dust", 6.0, Rect2(200, 100, 900, 700), {"col": Color(1.4, 1.3, 0.9), "life": 5.0})


func _cam() -> Array:
	return [Vector2(lerpf(860.0, 1000.0, smooth(0.0, 7.5, t)), 600.0), 1.2]


func _sky(c: Node2D) -> void:
	blob(c, Vector2(330, 150), 560.0, Color(1.0, 0.92, 0.6, 0.75))
	c.draw_circle(Vector2(330, 150), 66.0, Color(1.6, 1.25, 0.6), true, -1.0, true)
	for i in 3:
		var x := fposmod(300.0 + i * 700.0 + t * 12.0, 2400.0) - 300.0
		cloud(c, Vector2(x, 120.0 + i * 50.0), 0.9 - i * 0.15, Color("#ffffff").lerp(sky_top, 0.15), 3.0)


func _far(c: Node2D) -> void:
	var hill1 := mountain_pts([Vector2(100, 560), Vector2(500, 470), Vector2(900, 540), Vector2(1350, 450), Vector2(1800, 520)], 600)
	shape(c, hill1, air(Color("#7fb497"), 0.6), 0.0)
	for f in far_x:
		bamboo(c, f[0], 720.0, 620.0 * f[1], 9.0, air(Color("#79b36a"), 0.62), f[2], 0.0, false)
	var hill2 := mountain_pts([Vector2(-100, 640), Vector2(400, 600), Vector2(1000, 650), Vector2(1600, 590), Vector2(2100, 640)], 700)
	shape(c, hill2, air(Color("#6aa77a"), 0.45), 0.0)


func _mid(c: Node2D) -> void:
	for m in mid_x:
		bamboo(c, m[0], 800.0, 860.0 * m[1], 13.0, air(Color("#8cc46a"), 0.4), m[2], 2.0)
	if t > 0.8:
		for i in 5:
			var p := Vector2(-200.0 + (t - 0.8) * 230.0 - i * 45.0, 260.0 + i * 18.0 + sin(t * 1.5 + i) * 8.0)
			bird(c, p, 14.0, i * 1.3, inkof(Color("#557a60"), 0.3))


func _back(c: Node2D) -> void:
	for x in [60.0, 300.0, 1030.0, 1600.0, 1840.0]:
		bamboo(c, x, 900.0, 1150.0, 28.0, Color("#4f9a3e"), int(x), 4.0)


func _ground(c: Node2D) -> void:
	var g := ground_y
	var top := PackedVector2Array()
	for i in 21:
		var x := -300.0 + i * 130.0
		top.append(Vector2(x, g - 40.0 + sin(i * 1.7) * 10.0))
	var poly := round_pts(top, false, 4)
	poly.append(Vector2(W + 300, H + 300))
	poly.append(Vector2(-300, H + 300))
	shape(c, poly, Color("#8cc463"), 4.0)
	# lối mòn đất
	var path := PackedVector2Array([Vector2(-300, g - 18), Vector2(500, g - 26), Vector2(1100, g - 20), Vector2(2200, g - 28),
		Vector2(2200, g + 60), Vector2(1200, g + 72), Vector2(400, g + 64), Vector2(-300, g + 70)])
	shape(c, round_pts(path, true, 4), Color("#d9c08a"), 3.5)
	for s in [[Vector2(220, g + 120), 26.0], [Vector2(1480, g + 30), 18.0], [Vector2(1010, g + 150), 34.0], [Vector2(1720, g + 140), 22.0]]:
		puff(c, [[s[0], s[1]], [s[0] + Vector2(s[1] * 0.9, 6), s[1] * 0.7]], Color("#a7a9a0"), 3.0, 0.3)
	grass(c, -300, 2200, g - 34, 34.0, 46.0, Color("#79b552"), 11)


func _near(c: Node2D) -> void:
	grass(c, -300, 2200, H + 10, 26.0, 90.0, Color("#6aa848"), 12)
	for i in 9:
		var p := Vector2(80.0 + i * 230.0, H - 30.0 + sin(i * 3.0) * 20.0)
		var sw := wind(p.x) * 10.0
		c.draw_line(p, p + Vector2(sw, -70), Color("#4f8a3a"), 3.0, true)
		puff(c, [[p + Vector2(sw, -74), 9.0]], [Color("#ffffff"), Color("#ffd75e"), Color("#ff9fb0")][i % 3], 2.0, 0.2)


func _glow(c: Node2D) -> void:
	rays(c, Vector2(240, -200), 1.05, 0.7, 7, 1700.0, Color(1.0, 0.95, 0.7, 0.16), 3)


func _front(c: Node2D) -> void:
	bamboo(c, -60, 1200, 1600, 70.0, Color("#3e7a35"), 77, 5.0, false)
	for i in 6:
		var a := PI * 0.62 + i * 0.13 + sin(t * 2.0 + i) * 0.06 - wind(1800) * 0.12
		var p := Vector2(1860, -40)
		leaf(c, p + Vector2.from_angle(a) * 120.0, a, 210.0, 46.0, Color("#3f7a35"), 4.0)
