extends "res://canh.gd"
# Hồ thu hoàng hôn: lá phong rơi (rơi xuống nước thì gợn vòng), mặt hồ lấp lánh + bóng núi, thuyền nhấp nhô, sương trôi, sậy lay, đàn chim.

const LAKE := 640.0
const SHORE := 800.0
var a: Dictionary
var b: Dictionary
var fallen: Array = []
var MAPLE := [Color("#e2452b"), Color("#f08a24"), Color("#f6c445"), Color("#c7302a")]


func _palette() -> void:
	sky_top = Color("#5d4f9c")
	sky_bot = Color("#ffb067")
	haze = Color("#f0a07c")
	ink = Color("#2a1426")
	char_tint = Color(1.0, 0.93, 0.86)
	ground_y = 900.0
	wind_base = 0.22
	wind_gust = 0.5
	vign_a = 0.4
	caption = "Hồ thu · hoàng hôn"


func _build() -> void:
	_bg()
	a = actor("truong-vo-ky", Vector2(380, ground_y), 1.0)
	a.go = Vector2(760, ground_y)
	a.speed = 120.0
	b = actor("nham-nga-hanh", Vector2(2150, ground_y), -1.0)


func _story(_dt: float) -> void:
	rain_of("maple", 5.0, Rect2(-600, -150, 2600, 200), {"col": MAPLE[rng.randi() % 4], "land": rng.randf_range(LAKE + 20, ground_y + 150), "life": 16.0, "on_land": _landed})
	if a.is_empty():
		return
	if t > 3.0 and b.go == Vector2.INF and b.pos.x > 1400:
		b.go = Vector2(1300, ground_y)
		b.speed = 230.0
	a.expr = "binh" if t < 5.0 else "soc"
	if t > 5.0:
		a.face = -1.0
	b.expr = "gian"
	b.talk = smooth(6.0, 6.3, t)


func _bg() -> void:
	for i in 40:
		fallen.append([Vector2(rng.randf_range(-200, 2100), rng.randf_range(SHORE + 30, H + 60)), rng.randf() * TAU, MAPLE[rng.randi() % 4], rng.randf_range(0.8, 1.3)])


# lá rơi xuống mặt hồ (trên bờ) thì nổi gợn và chìm
func _landed(q: Dictionary) -> void:
	var p: Vector2 = q.p
	if p.y < SHORE - 10:
		spawn("ripple", p, {"col": Color(1.0, 0.85, 0.75), "life": 1.6, "s": 0.0, "z": 0.8})
		q.life = 0.6


func _cam() -> Array:
	return [Vector2(lerpf(900.0, 1000.0, smooth(0.0, 8.0, t)), 600.0), 1.16]


func _sky(c: Node2D) -> void:
	var sun := Vector2(1150, 560)
	blob(c, sun, 600.0, Color(1.0, 0.75, 0.45, 0.55))
	c.draw_circle(sun, 92.0, Color(1.7, 1.15, 0.55), true, -1.0, true)
	for i in 4:
		var x := fposmod(100.0 + i * 620.0 + t * 10.0, 2500.0) - 300.0
		var col: Color = [Color("#ffc9a6"), Color("#f59a8f"), Color("#e7869f"), Color("#ffd7b0")][i]
		cloud(c, Vector2(x, 160.0 + (i % 2) * 120.0), 1.1 - (i % 2) * 0.3, col, 3.0)


func _mount(c: Node2D, flip: bool) -> void:
	var r1 := mountain_pts([Vector2(-100, 500), Vector2(260, 380), Vector2(560, 470), Vector2(820, 400), Vector2(1350, 500), Vector2(1700, 390), Vector2(2050, 470)], LAKE)
	var r2 := mountain_pts([Vector2(-200, 560), Vector2(300, 520), Vector2(700, 570), Vector2(1500, 540), Vector2(2100, 560)], LAKE)
	if flip:
		c.draw_set_transform(Vector2(0, LAKE * 2.0), 0.0, Vector2(1, -1))
	shape(c, r1, air(Color("#7b4c86"), 0.3), 0.0)
	shape(c, r2, air(Color("#5a356d"), 0.15), 0.0)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _far(c: Node2D) -> void:
	_mount(c, false)
	vgrad(c, Rect2(-300, LAKE, W + 600, 700), Color("#d98a8c"), Color("#5e4a8a"))
	# bóng núi dưới nước (mờ, gợn)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var mod := Color(1, 1, 1, 0.3)
	c.draw_set_transform(Vector2(sin(t * 1.3) * 3.0, LAKE * 2.0), 0.0, Vector2(1, -1))
	shape(c, mountain_pts([Vector2(-100, 500), Vector2(260, 380), Vector2(560, 470), Vector2(820, 400), Vector2(1350, 500), Vector2(1700, 390), Vector2(2050, 470)], LAKE), Color(air(Color("#7b4c86"), 0.3), mod.a), 0.0)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	# cột nắng phản chiếu + lấp lánh
	for i in 26:
		var y := LAKE + 8.0 + i * 9.0
		var wd := 30.0 + i * 7.0 + sin(t * 3.0 + i * 1.7) * 14.0
		var x := 1150.0 + sin(t * 1.4 + i * 0.9) * 10.0
		c.draw_line(Vector2(x - wd, y), Vector2(x + wd, y), Color(1.5, 1.05, 0.6, 0.55 - i * 0.015), 4.0, true)
	var rr := RandomNumberGenerator.new()
	rr.seed = 5
	for i in 70:
		var y := rr.randf_range(LAKE + 10, 900)
		var x := fposmod(rr.randf_range(-200, 2100) + t * 8.0 * (y - LAKE) / 100.0, 2300.0) - 200.0
		var al := (0.5 + 0.5 * sin(t * 2.5 + i)) * 0.5
		var l := 10.0 + (y - LAKE) * 0.12
		c.draw_line(Vector2(x - l, y), Vector2(x + l, y), Color(1.0, 0.85, 0.85, al), 2.5, true)
	# thuyền câu
	var bp := Vector2(560 + t * 6.0, 700 + sin(t * 1.6) * 4.0)
	var ang := sin(t * 1.3) * 0.04
	c.draw_set_transform(bp, ang, Vector2.ONE)
	shape(c, round_pts(PackedVector2Array([Vector2(-90, -8), Vector2(90, -8), Vector2(60, 16), Vector2(-60, 16)]), true, 3), Color("#4a2b2e"), 3.0)
	puff(c, [[Vector2(10, -30), 15.0]], Color("#3a2236"), 3.0, 0.0)
	shape(c, PackedVector2Array([Vector2(-20, -40), Vector2(10, -66), Vector2(40, -40)]), Color("#c79a52"), 3.0)
	c.draw_line(Vector2(25, -30), Vector2(130, -95), Color("#2a1426"), 2.5, true)
	c.draw_line(Vector2(130, -95), Vector2(150, 12), Color(0.2, 0.1, 0.15, 0.6), 1.5, true)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	for i in 3:
		var x := fposmod(i * 800.0 + t * 30.0, 2600.0) - 400.0
		flat_blob(c, Vector2(x, LAKE + 30 + i * 20), 520.0, 0.12, Color(1.0, 0.85, 0.85, 0.3))


func _mid(c: Node2D) -> void:
	if t > 1.5:
		for i in 7:
			var row := absi(i - 3)
			var p := Vector2(2100.0 - (t - 1.5) * 170.0 + row * 50.0, 300.0 + row * 28.0 * (1 if i > 3 else -1) * 0.0 + row * 22.0)
			bird(c, p, 15.0, i * 1.1, inkof(Color("#6a3a5a"), 0.3))


func _back(c: Node2D) -> void:
	tree(c, Vector2(120, 880), 360.0, 280.0, Color("#e2512e"), Color("#5a2e2a"), 3, 5.0)
	tree(c, Vector2(1830, 870), 330.0, 250.0, Color("#f08a2a"), Color("#5a2e2a"), 8, 5.0)
	tree(c, Vector2(1620, 860), 250.0, 170.0, Color("#f3b33a"), Color("#5a2e2a"), 13, 4.5)


func _ground(c: Node2D) -> void:
	var top := PackedVector2Array()
	for i in 21:
		top.append(Vector2(-300.0 + i * 130.0, SHORE + sin(i * 1.3) * 14.0))
	var poly := round_pts(top, false, 4)
	poly.append(Vector2(W + 300, H + 300))
	poly.append(Vector2(-300, H + 300))
	shape(c, poly, Color("#b59a52"), 4.0)
	vgrad(c, Rect2(-300, SHORE + 60, W + 600, 400), Color(0.55, 0.38, 0.25, 0.0), Color(0.45, 0.28, 0.2, 0.55))
	for f in fallen:
		maple(c, f[0], f[1], 14.0 * f[3], 0.55, f[2])
	# sậy ven bờ
	for i in 26:
		var x := -100.0 + i * 85.0 + sin(i * 2.7) * 20.0
		if x > 500 and x < 1500 and i % 3 != 0:
			continue
		var hh := 120.0 + sin(i * 1.9) * 40.0
		var sw := wind(x) * 30.0 + sin(t * 2.4 + i) * 6.0
		var base := Vector2(x, SHORE + 10)
		var tip := base + Vector2(sw, -hh)
		c.draw_polyline(round_pts(PackedVector2Array([base, base.lerp(tip, 0.5) + Vector2(sw * 0.2, 0), tip]), false, 3), Color("#6b5a2e"), 4.0, true)
		c.draw_set_transform(tip, sw * 0.01, Vector2.ONE)
		shape(c, round_pts(PackedVector2Array([Vector2(-6, -2), Vector2(0, -26), Vector2(6, -2), Vector2(0, 8)]), true, 3), Color("#7a4a2a"), 2.5)
		c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	grass(c, -300, 2200, SHORE + 8, 30.0, 40.0, Color("#c4a650"), 21)


func _near(c: Node2D) -> void:
	grass(c, -300, 2200, H + 20, 30.0, 80.0, Color("#a8873e"), 22)


func _glow(c: Node2D) -> void:
	blob(c, Vector2(1150, 600), 380.0, Color(1.0, 0.6, 0.3, 0.12))


func _front(c: Node2D) -> void:
	# cành phong sà từ góc phải trên
	var sw := Vector2(sin(t * 1.4) * 8.0 + wind(1800) * 14.0, sin(t * 1.1) * 5.0)
	var br := PackedVector2Array([Vector2(2200, -60), Vector2(1900, 40), Vector2(1640, 70) + sw])
	c.draw_polyline(round_pts(br, false, 5), Color("#3a1d1e"), 22.0, true)
	puff(c, [[Vector2(1640, 90) + sw, 70.0], [Vector2(1740, 40) + sw * 0.8, 90.0], [Vector2(1880, 60) + sw * 0.5, 80.0],
		[Vector2(2000, -10), 100.0], [Vector2(1560, 40) + sw, 55.0]], Color("#c93a25"), 6.0, 0.25)
