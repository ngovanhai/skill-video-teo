extends "res://canh.gd"
# Thử vật phẩm: CẦM ĐÈN LỒNG ĐI ĐÊM. Lối mòn trong rừng thông dưới trăng; đèn treo đầu cán đung đưa theo bước chân (dây mềm),
# quầng sáng ấm lan xuống mặt đất đi theo người, thiêu thân bay quanh đèn, đom đóm lác đác.
# Giữa cảnh dừng lại, giơ đèn lên cao soi quanh (đèn lắc mạnh), ngoái lại phía sau, rồi đi tiếp.

var stars: Array = []
var pines: Array = []
var a: Dictionary
var den: Dictionary
var moths := false


func _palette() -> void:
	sky_top = Color("#0b0f2e")
	sky_bot = Color("#3d3d78")
	haze = Color("#25264c")
	ink = Color("#0b0816")
	char_tint = Color(0.8, 0.82, 1.0)
	ground_y = 880.0
	wind_base = 0.15
	wind_gust = 0.4
	vign_a = 0.42
	caption = "Lối rừng · đêm"


func _build() -> void:
	for i in 160:
		stars.append([Vector2(rng.randf() * 2600 - 300, rng.randf() * 560), rng.randf_range(0.8, 2.4), rng.randf() * TAU])
	var x := -500.0
	while x < 3000.0:
		pines.append([x, rng.randf_range(380, 560), rng.randf_range(200, 280), rng.randi()])
		x += rng.randf_range(150, 260)
	a = actor("doan-du", Vector2(320, ground_y), 1.0)
	a.go = Vector2(900, ground_y)
	a.speed = 110.0
	a.hold["F"] = [Vector2(66, -40), 1.0]
	den = prop(a, "den", "tay", "F", {"lcol": Color(1.45, 0.86, 0.48)})


func _story(_dt: float) -> void:
	rain_of("firefly", 1.2, Rect2(-200, 450, 2800, 400), {"col": Color(0.85, 1.0, 0.45), "life": 9.0})
	if a.is_empty() or t < 0.0:
		return
	if not moths:
		moths = true
		for i in 3:
			spawn("moth", den.lw, {"o": den, "s": rng.randf_range(0.6, 1.2), "life": 9999.0, "z": 1.1, "col": Color(1, 1, 1)})
	# dừng, giơ đèn soi quanh, ngoái lại, đi tiếp
	var raise := smooth(5.1, 5.6, t) * (1.0 - smooth(6.6, 7.0, t))
	a.hold["F"] = [Vector2(66, -40).lerp(Vector2(62, -170), raise), 1.0]
	a.extra = [[{"head": -8.0, "torso": -4.0}, raise]]
	if t > 5.9 and t < 6.5:
		a.face = -1.0
	elif t >= 6.5:
		a.face = 1.0
	if t > 6.9 and a.go == Vector2.INF and a.pos.x < 1000.0:
		a.go = Vector2(1600, ground_y)
	a.expr = "binh" if t < 5.2 else ("soc" if t < 6.5 else "vui")


func _cam() -> Array:
	var ax: float = a.pos.x if not a.is_empty() else 320.0
	return [Vector2(clampf(ax + 140.0, 600.0, 2000.0), 610.0), 1.28]


func _sky(c: Node2D) -> void:
	for s in stars:
		var tw := 0.5 + 0.5 * sin(t * 2.0 + s[2])
		c.draw_circle(s[0], s[1], Color(1.0, 0.95, 0.85, tw), true, -1.0, true)
	var m := Vector2(1500, 170)
	blob(c, m, 380.0, Color(0.7, 0.75, 1.0, 0.3))
	c.draw_colored_polygon(crescent(m, 70.0, Vector2(26, -12), 62.0), Color(1.3, 1.28, 1.1))   # trăng khuyết: hình thật, không vẽ đè
	for i in 3:
		var x := fposmod(300.0 + i * 760.0 + t * 18.0, 2700.0) - 400.0
		cloud(c, Vector2(x, 160.0 + i * 70.0), 1.1 - i * 0.2, Color("#2c2c5c"), 0.0)


func _far(c: Node2D) -> void:
	shape(c, mountain_pts([Vector2(-400, 560), Vector2(100, 430), Vector2(600, 540), Vector2(1100, 420), Vector2(1700, 520), Vector2(2300, 440), Vector2(2900, 540)], 800), air(Color("#1e2148"), 0.35), 0.0)
	shape(c, mountain_pts([Vector2(-400, 640), Vector2(300, 590), Vector2(900, 650), Vector2(1600, 580), Vector2(2400, 640), Vector2(3000, 600)], 820), air(Color("#171a3a"), 0.2), 0.0)


func _mid(c: Node2D) -> void:
	for p in pines:
		pine(c, Vector2(p[0], 790), p[1] * 0.75, p[2] * 0.7, Color("#1d2a4a"), 0.0, 0.0, p[3])


func _back(c: Node2D) -> void:
	for i in 9:
		var x := -300.0 + i * 360.0 + sin(i * 2.3) * 60.0
		pine(c, Vector2(x, 860), 620.0 + sin(i * 1.7) * 90.0, 330.0, Color("#18363a"), 0.0, 4.0, i * 13)


func _ground(c: Node2D) -> void:
	var g := ground_y
	var top := PackedVector2Array()
	for i in 30:
		top.append(Vector2(-600.0 + i * 130.0, g - 40.0 + sin(i * 1.7) * 10.0))
	var poly := round_pts(top, false, 4)
	poly.append(Vector2(3400, H + 300))
	poly.append(Vector2(-600, H + 300))
	shape(c, poly, Color("#1f3a36"), 4.0)
	var path := PackedVector2Array([Vector2(-600, g - 18), Vector2(600, g - 26), Vector2(1500, g - 20), Vector2(3400, g - 28),
		Vector2(3400, g + 60), Vector2(1600, g + 72), Vector2(500, g + 64), Vector2(-600, g + 70)])
	shape(c, round_pts(path, true, 4), Color("#4a4566"), 3.5)
	for s in [[Vector2(220, g + 120), 26.0], [Vector2(1180, g + 30), 18.0], [Vector2(1010, g + 150), 34.0], [Vector2(1720, g + 140), 22.0], [Vector2(2300, g + 110), 30.0]]:
		puff(c, [[s[0], s[1]], [s[0] + Vector2(s[1] * 0.9, 6), s[1] * 0.7]], Color("#3d4058"), 3.0, 0.2)
	grass(c, -600, 3400, g - 34, 34.0, 46.0, Color("#244a3c"), 11)


func _near(c: Node2D) -> void:
	grass(c, -600, 3400, H + 10, 26.0, 90.0, Color("#16302a"), 12)


func _front(c: Node2D) -> void:
	var sw := Vector2(sin(t * 1.2) * 6.0 + wind(0) * 10.0, 0)
	c.draw_polyline(round_pts(PackedVector2Array([Vector2(-200, -40), Vector2(160, 30), Vector2(420, 10) + sw]), false, 5), Color("#07060e"), 26.0, true)
	for i in 7:
		var p := Vector2(60.0 + i * 60.0, 20.0 + sin(i * 2.0) * 20.0) + sw * (i / 7.0)
		pine(c, p + Vector2(0, 120), 140.0, 90.0, Color("#07060e"), 0.0, 0.0, i)


# trăng khuyết = cung ngoài (tâm c, r1) trừ đường tròn lệch d (r2): đi cung ngoài P+→P−, quay về theo cung trong
func crescent(c: Vector2, r1: float, d: Vector2, r2: float) -> PackedVector2Array:
	var L := d.length()
	var a := (r1 * r1 - r2 * r2 + L * L) / (2.0 * L)
	var h := sqrt(maxf(r1 * r1 - a * a, 0.0))
	var td := d.angle()
	var al := atan2(h, a)
	var be := atan2(h, a - L)
	var q := PackedVector2Array()
	for i in 33:
		var th := lerpf(td + al, td + TAU - al, i / 32.0)
		q.append(c + Vector2(cos(th), sin(th)) * r1)
	for i in range(1, 32):      # bỏ 2 mũi trùng với cung ngoài (điểm trùng làm tam giác hoá hỏng)
		var th := lerpf(td + TAU - be, td + be, i / 32.0)
		q.append(c + d + Vector2(cos(th), sin(th)) * r2)
	return q
