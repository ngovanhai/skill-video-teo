extends "res://canh/ho_thu.gd"
# Thử vật phẩm: CẦM Ô TRONG MƯA. Mưa xiên theo gió; hạt trúng tán ô bật tung, mép ô nhỏ giọt; tán nghiêng theo gió/quán tính.
# Mặt hồ gợn vòng, bờ đất bắn tóe, bước chân lép nhép. Cuối cảnh dừng lại, ngửa mặt, chìa tay hứng mưa.

var o: Dictionary
var racc := 0.0
var dacc := 0.0
var step_ph := 0.0


func _palette() -> void:
	super._palette()
	sky_top = Color("#4d5270")
	sky_bot = Color("#a6a3b8")
	haze = Color("#8e8ca6")
	ink = Color("#1d1a2a")
	char_tint = Color(0.86, 0.88, 0.97)
	wind_base = 0.35
	wind_gust = 0.7
	vign_a = 0.5
	caption = "Hồ thu · mưa"


func _build() -> void:
	_bg()
	a = actor("truong-vo-ky", Vector2(420, ground_y), 1.0)
	a.go = Vector2(1000, ground_y)
	a.speed = 95.0
	a.hold["F"] = [Vector2(72, -50), 1.0]   # cán ô trước mặt, nghiêng ra trước: không cắt ngang mặt
	o = prop(a, "o", "tay", "F", {"col": Color("#e0a640"), "shaft": 410.0, "tilt": 0.2})


func _story(dt: float) -> void:
	# mưa: mỗi hạt một điểm rơi riêng (mặt hồ → gợn, bờ → tóe)
	racc += 300.0 * dt
	while racc >= 1.0:
		racc -= 1.0
		var land := rng.randf_range(LAKE + 10.0, ground_y + 170.0)
		spawn("rain", Vector2(rng.randf_range(-700, 2500), rng.randf_range(-500, -200)), {"col": Color(0.85, 0.9, 1.0), "life": 3.0, "land": land, "on_land": _rain_land})
	rain_of("maple", 1.2, Rect2(-600, -150, 2600, 200), {"col": MAPLE[rng.randi() % 4], "land": rng.randf_range(LAKE + 20, ground_y + 150), "life": 16.0, "on_land": _landed})
	if a.is_empty() or t < 0.0:
		return
	# nước nhỏ giọt từ mép ô
	var rim: Array = o.rim
	if rim.size() == 2:
		dacc += 9.0 * dt
		while dacc >= 1.0:
			dacc -= 1.0
			var rp: Vector2 = rim[rng.randi() % 2]
			spawn("drop", rp + Vector2(rng.randf_range(-6, 6), 2), {"z": 1.1, "life": 1.5, "col": Color(0.85, 0.9, 1.0), "land": ground_y + rng.randf_range(0, 30), "v": Vector2(0, 40)})
	# bước chân tóe nước
	var wk: float = a.walk
	var ph: float = a.ph
	if wk > 0.5 and floori(ph / PI) != floori(step_ph / PI):
		for i in 2:
			spawn("splash", a.pos + Vector2(rng.randf_range(-30, 30), 6), {"z": 1.2, "s": 0.0, "life": 0.3, "col": Color(0.85, 0.9, 1.0)})
	step_ph = ph
	# dừng: ngửa mặt nhìn trời, chìa tay B hứng mưa
	var k := smooth(6.4, 7.0, t)
	a.extra = [[{"head": -14.0, "torso": -3.0}, k]]
	a.hold["B"] = [Vector2(36, -64), k]
	a.expr = "binh" if t < 6.4 else ("soc" if t < 7.0 else "vui")
	if k > 0.5 and rng.randf() < 0.25:
		var hp: Vector2 = a.node.hand(world, "B")
		spawn("splash", hp + Vector2(rng.randf_range(-12, 12), -4), {"z": 1.1, "s": 0.0, "life": 0.3, "col": Color(0.85, 0.9, 1.0)})


func _rain_land(q: Dictionary) -> void:
	var p: Vector2 = q.p
	var land: float = q.land
	if land < SHORE - 6.0:
		spawn("ripple", Vector2(p.x, land), {"col": Color(0.9, 0.92, 1.0), "life": 0.7, "s": 0.0, "z": 0.45})
	else:
		spawn("splash", Vector2(p.x, land), {"z": q.z, "s": 0.0, "life": 0.3, "col": q.col})


func _cam() -> Array:
	return [Vector2(lerpf(820.0, 1060.0, smooth(0.0, 7.0, t)), 620.0), 1.22]


func _sky(c: Node2D) -> void:
	for i in 6:
		var x := fposmod(100.0 + i * 420.0 + t * 30.0, 2600.0) - 300.0
		cloud(c, Vector2(x, 120.0 + (i % 3) * 70.0), 1.5 - (i % 3) * 0.25, Color("#6b6c88").lerp(Color("#8c8aa2"), (i % 3) * 0.3), 0.0)


func _far(c: Node2D) -> void:
	super._far(c)
	c.draw_rect(Rect2(-400, -200, W + 800, H + 600), Color(0.38, 0.4, 0.55, 0.5))
	# màn mưa xa
	for i in 60:
		var x := fposmod(i * 47.0 + t * 260.0, 2400.0) - 300.0
		var y := fposmod(i * 131.0 + t * 900.0, 700.0)
		c.draw_line(Vector2(x, y), Vector2(x - 10, y + 60), Color(0.85, 0.88, 1.0, 0.18), 1.5, true)


func _back(c: Node2D) -> void:
	super._back(c)
	c.draw_rect(Rect2(-400, -200, W + 800, H + 600), Color(0.38, 0.4, 0.55, 0.3))


func _glow(_c: Node2D) -> void:
	pass
