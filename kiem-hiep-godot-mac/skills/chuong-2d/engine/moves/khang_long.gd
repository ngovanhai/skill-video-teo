extends "res://engine.gd"
# KHÁNG LONG HỮU HỐI (12.5 s): sân trước chùa Thiếu Lâm, núi Thiếu Thất, trưa đầu thu trời xanh trong, rừng phong đỏ.
# Thẻ chiêu:
#   người dùng   Tiêu Phong (Thiên Long Bát Bộ, hồi Thiếu Thất sơn), Hàng Long Thập Bát Chưởng
#   đối thủ      Đinh Xuân Thu (Tinh Tú lão quái), độc công, khói độc tím lục
#   cơ chế       "chưởng sau đẩy chưởng trước": mỗi chưởng là một bức sóng cong; sóng sau chạy nhanh hơn, đuổi kịp
#                và nhập vào sóng trước thành sóng dày gấp đôi; sóng thổi tan các đám khói độc.
#                Đỉnh: đánh ra "mười phần" (một bức sóng dày), còn "hai mươi phần" hiện thành bóng chưởng lớn
#                sau lưng Tiêu Phong nhưng KHÔNG phóng ra (giữ lại = "hối"), rồi lặng xuống.
#   cặp màu      vàng nghệ / chàm (Tiêu Phong) vs tím lục độc (Đinh Xuân Thu)
#   bối cảnh     trưa thu trời xanh, núi lam, rừng phong đỏ, mái chùa, đất đỏ son
#   đỉnh         slowmo, bức sóng dày đập vào Đinh Xuân Thu; hậu quả: lão trượt lùi cày hai rãnh đất, đứng khựng (không ngã)

const COL := Color(1.6, 1.05, 0.3)        # vàng nghệ
const HOT := Color(2.4, 1.9, 1.0)
const INDIGO := Color(0.45, 0.6, 1.5)     # chàm: bóng chưởng giữ lại
const FOE_COL := Color(0.75, 0.35, 1.3)   # tím độc
const GREEN := Color(0.55, 1.25, 0.45)    # lục độc
const PEAK := 6.1
const SLIDE_END := 1488.0

var waves: Array = []        # {x, v, s, y, alive, born}
var launched := [false, false, false, false]
var clouds: Array = []       # {p, r, v, a, dis, seed}
var leaves: Array = []
var hit := false
var hit_i := 0
var x_hit := 0.0
var groove_x0 := 0.0


func _setup() -> void:
	sky_cols = [Color("#3f78b4"), Color("#9cc6e4"), Color("#efe2c0")]
	moon_on = false
	n_stars = 0
	far_col = Color("#5f7392")
	near_col = Color("#9a3a22")
	mist_col = Color(1.0, 0.97, 0.9, 0.16)
	ground_cols = [Color("#a2643a"), Color("#4a2a16"), Color("#d8a06a")]
	slowmo = [PEAK - 0.08, PEAK + 0.55, 0.3]
	title = "KHÁNG LONG HỮU HỐI"
	subtitle = "Thiên Long Bát Bộ · Tiêu Phong"
	title_at = 8.4
	title_col = HOT
	set_char(hero, "tieu-phong")
	set_char(foe, "dinh-xuan-thu")
	hero.pos = Vector2(470, GROUND)
	foe.pos = Vector2(1250, GROUND)
	hero.col = COL
	foe.col = FOE_COL
	for i in 26:
		leaves.append({"p": Vector2(rng.randf_range(-200, W + 200), rng.randf_range(-200, 800)), "s": rng.randf_range(5, 10),
			"v": Vector2(rng.randf_range(40, 110), rng.randf_range(50, 110)), "ph": rng.randf() * TAU})
	cue(1.0, "lib-riser", 0.75)
	cue(2.5, "lib-whoosh", 0.6)
	cue(3.1, "lib-whoosh-short", 0.7)
	cue(4.2, "lib-whoosh", 0.7)
	cue(5.2, "lib-riser", 0.5)
	cue(PEAK - 0.3, "lib-whoosh-cinematic", 0.9)
	cue(8.0, "lib-chime", 0.35)


func _spawn_cloud(t0: float) -> void:
	var p: Vector2 = foe.pos + Vector2(-70, -rng.randf_range(120, 260))
	clouds.append({"p": p, "r": rng.randf_range(60, 90), "v": Vector2(-rng.randf_range(130, 200), rng.randf_range(-20, 10)),
		"a": 0.0, "dis": -1.0, "seed": rng.randf() * TAU, "t0": t0})


func _launch(i: int, v: float, s: float) -> void:
	launched[i] = true
	var hp: Vector2 = hero.hand
	waves.append({"x": hp.x + 40.0, "v": v, "s": s, "y": hp.y, "alive": true, "born": t})
	add_ring(hp, 140, HOT, 6, 0.3)
	burst(hp, 18, 200, 700, HOT, COL, 300.0, 1.6, -0.6, 0.6)


func _story(dt: float) -> void:
	# ---- Tiêu Phong
	var g := smooth(1.0, 1.8, t) * (1.0 - smooth(2.3, 2.5, t))
	var bp := 0.0
	for b in [2.5, 3.1, 4.2]:
		bp = maxf(bp, pulse(b - 0.12, b + 0.08, 0.3, t))
	var big := smooth(5.0, 5.7, t) * (1.0 - smooth(PEAK - 0.15, PEAK - 0.05, t))
	var strike := smooth(PEAK - 0.15, PEAK - 0.02, t) * (1.0 - smooth(8.6, 9.6, t))
	hero.gather = g + big * 0.8
	hero.push = maxf(bp, strike)
	hero.both = strike
	hero.lean = hero.push * 0.35
	hero.crouch = g * 0.4 + big * 0.5
	hero.aura = g * 0.6 + big * 0.7 + strike * 0.4 - smooth(7.2, 9.0, t) * 0.9
	hero.aura = maxf(hero.aura, 0.0)
	hero.expr = "dac-y" if t > 8.4 else ("quyet-tam" if t > 1.0 else "binh")
	# ---- Đinh Xuân Thu: phẩy tay áo tung khói độc, sau đó đỡ
	if not hit:
		var fan := pulse(1.3, 1.6, 0.3, t) + pulse(2.0, 2.3, 0.3, t) + pulse(3.9, 4.15, 0.3, t)
		var grd := smooth(3.5, 3.8, t) * 0.6 + smooth(5.2, 5.6, t) * 0.5
		foe.extra = [["palm", fan * 0.7], ["guard", minf(1.0, grd)]]
		foe.aura = 0.35 + fan * 0.3
		foe.expr = "soc" if t > 4.9 else "gian"
		foe.lean = -grd * 0.25
	pose(hero, 0.0)
	pose(foe, 0.0)

	if g > 0.05 or big > 0.05:
		orbit(hero, rng.randf_range(120, 300), rng.randf_range(2.0, 3.5), 260, rng.randf_range(2, 5), HOT if rng.randf() < 0.6 else INDIGO, 6.0)

	# khói độc: mỗi lần phẩy tay áo bắn ra 2–3 đám
	for st in [1.4, 2.1, 4.0]:
		var n_before := 0
		for cl in clouds:
			if is_equal_approx(cl.t0, st):
				n_before += 1
		if t >= st and n_before < 3:
			_spawn_cloud(st)
	for cl in clouds:
		cl.p += cl.v * dt
		cl.a = minf(1.0, cl.a + dt * 2.0)
		if cl.dis >= 0.0:
			cl.dis += dt
			cl.v = cl.v.lerp(Vector2(700, -160), minf(1.0, dt * 3.0))
			cl.r += 90.0 * dt

	# ---- sóng chưởng: sóng sau nhanh hơn, đuổi kịp và nhập vào sóng trước
	if t >= 2.5 and not launched[0]:
		_launch(0, 520.0, 1.0)
	if t >= 3.1 and not launched[1]:
		_launch(1, 1150.0, 1.0)
	if t >= 4.2 and not launched[2]:
		_launch(2, 900.0, 1.2)
	if t >= PEAK - 0.12 and not launched[3]:
		_launch(3, 4200.0, 2.6)
	for w in waves:
		if not w.alive:
			continue
		w.x += w.v * dt
		for cl in clouds:
			if cl.dis < 0.0 and absf(cl.p.x - w.x) < 50.0:
				cl.dis = 0.0
				for i in 8:
					emit("add", cl.p, Vector2(rng.randf_range(100, 500), rng.randf_range(-200, 200)), 0.5, rng.randf_range(10, 20), GREEN * Color(1, 1, 1, 0.3))
	for i in waves.size():
		var a: Dictionary = waves[i]
		if not a.alive:
			continue
		for j in waves.size():
			var b: Dictionary = waves[j]
			if j == i or not b.alive or b.born >= a.born:
				continue
			if a.x >= b.x - 10.0:
				# sóng sau đẩy sóng trước: nhập làm một, dày gấp đôi
				b.s += a.s
				b.v = maxf(a.v, b.v)
				a.alive = false
				add_ring(Vector2(b.x, b.y), 200, HOT, 8, 0.35)
				add_ring(Vector2(b.x, b.y), 120, INDIGO, 5, 0.3, 1.0, 0.06)
				burst(Vector2(b.x, b.y), 30, 300, 900, HOT, COL, 300.0, 1.4)
				shake = maxf(shake, 10.0)
				sfx("lib-glitch-1", 0.4)
				sfx("lib-impact-bass-2", 0.5)
	for w in waves:
		if not w.alive:
			continue
		if w.x >= foe.pos.x - 70.0:
			w.alive = false
			var at: Vector2 = foe.pos + Vector2(-40, -170)
			if w.s < 2.5:
				# nhịp nhỏ: lão đỡ, lùi
				add_ring(at, 200 + 60.0 * w.s, HOT, 7, 0.35)
				burst(at, 34, 300, 950, HOT, GREEN, 600.0, 1.4, -PI * 0.6, PI * 0.6)
				shake = maxf(shake, 11.0 + w.s)
				sfx("lib-impact-bass-2", 0.6)
				foe.pos.x += 16.0 * w.s
				foe.tint = Color(1.25, 1.15, 0.95)
				hit_i += 1
			elif not hit:
				hit = true
				x_hit = foe.pos.x
				groove_x0 = foe.pos.x
				foe.expr = "ko"
				flash = 0.62
				flash_col = Color(1.0, 0.92, 0.7)
				shake = 32.0
				add_ring(at, 720, HOT, 18, 0.7)
				add_ring(at, 420, INDIGO, 10, 0.55, 1.0, 0.05)
				add_ring(Vector2(at.x, GROUND), 820, COL, 10, 0.9, 0.2)
				burst(at, 150, 300, 1600, HOT, Color(2, 2, 1.8), 800.0, 1.0)
				for cl in clouds:
					if cl.dis < 0.0:
						cl.dis = 0.0
				sfx("lib-impact-bass-1", 1.0)
				sfx("lib-impact-bass-2", 1.0)
	foe.tint = foe.tint.lerp(Color(1, 1, 1), minf(1.0, dt * 4.0))

	# ---- hậu quả: trượt lùi cày rãnh, đứng khựng
	if hit:
		var k := clampf((t - PEAK) / 1.2, 0.0, 1.0)
		foe.pos = Vector2(lerpf(x_hit, SLIDE_END, ease_out(k)), GROUND)
		foe.extra = [["guard", 1.0 - smooth(0.6, 1.0, k) * 0.6]]
		foe.lean = -0.9 * (1.0 - smooth(0.5, 1.0, k)) - 0.15
		foe.crouch = 0.6 * (1.0 - smooth(0.6, 1.0, k))
		foe.hurt = pulse(0.0, 0.2, 0.4, k) * 0.35
		foe.aura = 0.0
		if t > PEAK + 1.25:
			foe.expr = "soc"
		if k < 0.9 and fmod(rt, 0.07) < DT:
			for i in 3:
				emit("rock", Vector2(foe.pos.x + rng.randf_range(-30, 30), GROUND + 4), Vector2(rng.randf_range(-260, 60), -rng.randf_range(120, 380)), 0.9, rng.randf_range(4, 9), Color("#6e3e20"), 1500.0, 0.5)
			emit("smoke", Vector2(foe.pos.x - 20, GROUND), Vector2(rng.randf_range(-120, 0), -rng.randf_range(20, 90)), 1.6, rng.randf_range(30, 60), Color(0.82, 0.62, 0.45, 0.38))
		if k >= 1.0 and not foe.has("landed"):
			foe.landed = true
			shake = maxf(shake, 12.0)
			sfx("lib-impact-bass-2", 0.5)
			for i in 16:
				emit("smoke", Vector2(SLIDE_END + rng.randf_range(-60, 120), GROUND), Vector2(rng.randf_range(-160, 200), -rng.randf_range(20, 120)), 2.0, rng.randf_range(40, 80), Color(0.85, 0.66, 0.48, 0.4))

	# lá phong
	for lf in leaves:
		lf.p += lf.v * dt * (1.0 + hero.aura * 0.5)
		lf.p.x += sin(rt * 1.7 + lf.ph) * 30.0 * dt
		if lf.p.y > GROUND + 40:
			lf.p = Vector2(lf.p.x - 900.0, -60.0)
		if lf.p.x > W + 300:
			lf.p.x -= W + 600


func _cam() -> Array:
	var c := Vector2(900, 590)
	var z := 1.0
	var k1 := smooth(0.9, 1.6, t) * (1.0 - smooth(2.2, 2.6, t))       # tụ khí
	c = c.lerp(hero.pos + Vector2(130, -230), k1)
	z = lerpf(z, 1.35, k1)
	var k2 := smooth(2.3, 2.8, t) * (1.0 - smooth(5.0, 5.4, t))       # sóng chạy: rộng, thấp
	c = c.lerp(Vector2(880, 620), k2)
	z = lerpf(z, 1.1, k2)
	var k3 := smooth(5.0, 5.6, t) * (1.0 - smooth(PEAK + 0.3, 7.6, t))  # đỉnh: thấy bóng chưởng sau lưng + đối thủ
	c = c.lerp(Vector2(860, 560), k3)
	z = lerpf(z, 1.12, k3)
	var k4 := smooth(7.6, 9.0, t)                                       # kết
	c = c.lerp(Vector2(980, 590), k4)
	z = lerpf(z, 1.0, k4)
	return [c, z]


func _reserve() -> float:
	# "hai mươi phần" giữ lại: lớn dần khi dồn khí, KHÔNG phóng ra, lặng dần sau đỉnh
	return smooth(1.4, 2.2, t) * 0.35 + smooth(5.0, 5.9, t) * 0.65 - smooth(7.4, 9.4, t) * 0.85


func _fx_ground(c: Node2D) -> void:
	# mái chùa Thiếu Lâm phía sau bên phải + bậc đá
	var bx := 1640.0
	c.draw_colored_polygon(PackedVector2Array([Vector2(bx - 150, GROUND), Vector2(bx - 150, 640), Vector2(bx + 230, 640), Vector2(bx + 230, GROUND)]), Color("#7a3a26"))
	c.draw_colored_polygon(PackedVector2Array([Vector2(bx - 230, 650), Vector2(bx - 120, 590), Vector2(bx + 200, 590), Vector2(bx + 320, 650), Vector2(bx + 300, 662), Vector2(bx - 210, 662)]), Color("#3a2a24"))
	c.draw_colored_polygon(PackedVector2Array([Vector2(bx - 170, 585), Vector2(bx - 80, 540), Vector2(bx + 160, 540), Vector2(bx + 250, 585), Vector2(bx + 240, 594), Vector2(bx - 160, 594)]), Color("#3a2a24"))
	for i in 4:
		c.draw_rect(Rect2(bx - 110 + i * 95, 670, 22, GROUND - 670), Color("#5a2618"))
	c.draw_rect(Rect2(bx - 20, 700, 90, 140), Color("#2a1810"))
	for i in 3:
		c.draw_rect(Rect2(bx - 200 - i * 30, GROUND - 14 - i * 0.0, 420 + i * 60, 14), Color("#9a8a7a").darkened(i * 0.1))
	# vân đá sân
	for i in 12:
		var x := -100.0 + i * 190.0
		c.draw_line(Vector2(x, GROUND + 30), Vector2(x + 90, GROUND + 30), Color(0.3, 0.16, 0.08, 0.35), 3)
		c.draw_line(Vector2(x + 60, GROUND + 90), Vector2(x + 170, GROUND + 90), Color(0.3, 0.16, 0.08, 0.3), 3)
	# rãnh cày
	if hit:
		var x1: float = foe.pos.x
		for dy in [6.0, 22.0]:
			c.draw_line(Vector2(groove_x0 - 20, GROUND + dy), Vector2(x1 + 10, GROUND + dy), Color("#3a1e0e"), 7)
			c.draw_line(Vector2(groove_x0 - 20, GROUND + dy - 5), Vector2(x1 + 10, GROUND + dy - 5), Color("#e0aa74"), 2)
		c.draw_colored_polygon(PackedVector2Array([Vector2(x1 + 16, GROUND + 26), Vector2(x1 + 40, GROUND - 10), Vector2(x1 + 66, GROUND + 26)]), Color("#7a4426"))
	# quầng sàn khi tụ / đỉnh
	var gk := smooth(1.0, 1.6, t) * (1.0 - smooth(2.2, 2.6, t)) + smooth(5.2, 5.9, t) * (1.0 - smooth(6.8, 7.8, t))
	if gk > 0.01:
		flat_blob(c, Vector2(hero.pos.x, GROUND + 8), 320, 0.14, COL * Color(1, 1, 1, 0.3 * gk))


func _fx_back(c: Node2D) -> void:
	# bóng chưởng giữ lại (chàm + vàng) sau lưng Tiêu Phong
	var r := _reserve()
	if r <= 0.01:
		return
	var p: Vector2 = hero.pos + Vector2(-60, -230)
	var rr := 230.0 + 120.0 * r + sin(rt * 3.0) * 6.0
	c.draw_texture_rect(soft, Rect2(p - Vector2(rr, rr), Vector2(rr * 2, rr * 2)), false, INDIGO * Color(1, 1, 1, 0.18 * r))
	for k in 3:
		var rk := rr * (0.75 + 0.15 * k)
		c.draw_arc(p, rk, -1.1, 1.1, 40, INDIGO * Color(1, 1, 1, 0.16 * r), 26.0 - k * 6.0)
		c.draw_arc(p, rk, -1.1, 1.1, 40, COL * Color(1, 1, 1, 0.55 * r), 3.0)
	# hai mươi vảy rồng: chấm sáng xếp trên cung ngoài, quay chậm
	for i in 20:
		var a := -1.05 + 2.1 * float(i) / 19.0
		var q := p + Vector2(cos(a), sin(a)) * (rr * 1.05)
		c.draw_circle(q, 5.0 + 2.0 * sin(rt * 4.0 + i), HOT * Color(1, 1, 1, 0.6 * r))


func _fx_norm(c: Node2D) -> void:
	# khói độc tím lục
	for cl in clouds:
		var fade := 1.0
		if cl.dis >= 0.0:
			fade = 1.0 - clampf(cl.dis / 0.7, 0.0, 1.0)
		if fade <= 0.0:
			continue
		var a: float = cl.a * fade
		var p: Vector2 = cl.p
		var r: float = cl.r
		for k in 4:
			var o := Vector2(cos(cl.seed + k * 1.7 + rt * 0.8), sin(cl.seed + k * 2.3 + rt * 0.6)) * r * 0.45
			blob(c, p + o, r * 0.85, Color(0.42, 0.2, 0.55, 0.33 * a))
		blob(c, p, r * 0.6, Color(0.35, 0.62, 0.3, 0.3 * a))
	# lá phong
	for lf in leaves:
		var p: Vector2 = lf.p
		var s: float = lf.s
		var a: float = rt * 2.0 + lf.ph
		c.draw_set_transform(p, a, Vector2(1.0, 0.6 + 0.4 * sin(rt * 3.0 + lf.ph)))
		c.draw_colored_polygon(PackedVector2Array([Vector2(0, -s), Vector2(s * 0.4, -s * 0.2), Vector2(s, -s * 0.3), Vector2(s * 0.5, s * 0.3), Vector2(0, s), Vector2(-s * 0.5, s * 0.3), Vector2(-s, -s * 0.3), Vector2(-s * 0.4, -s * 0.2)]), Color("#d0462a"))
		c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_wave(c: Node2D, x: float, y: float, s: float, age: float) -> void:
	var R := 240.0 + 40.0 * s
	var ctr := Vector2(x - R, y + 10)
	var span := 0.55 + 0.12 * minf(s, 2.6)
	var open := minf(1.0, age / 0.15)
	var a0 := -span * open
	var a1 := span * open
	c.draw_arc(ctr, R, a0, a1, 40, COL * Color(1, 1, 1, 0.16), 24.0 + 14.0 * s)
	c.draw_arc(ctr, R - 10.0, a0, a1, 40, COL * Color(1, 1, 1, 0.8), 6.0 + 2.0 * s)
	c.draw_arc(ctr, R, a0, a1, 40, HOT, 2.5 + s)
	for k in int(2 + s * 2.0):
		var rk := R - 26.0 - k * 22.0
		c.draw_arc(ctr, rk, a0 * 0.85, a1 * 0.85, 30, COL * Color(1, 1, 1, 0.35 - k * 0.06), 3.0)
	# vảy rồng: nét chữ V dọc mép sóng
	for i in 7:
		var aa := lerpf(a0, a1, (i + 0.5) / 7.0)
		var q := ctr + Vector2(cos(aa), sin(aa)) * (R + 6.0)
		var d := Vector2(cos(aa), sin(aa))
		var n := d.orthogonal()
		c.draw_polyline(PackedVector2Array([q - d * 14.0 + n * 9.0, q + d * 4.0, q - d * 14.0 - n * 9.0]), HOT * Color(1, 1, 1, 0.7), 2.5)
	blob(c, Vector2(x - 20, y), 70.0 + 20.0 * s, COL * Color(1, 1, 1, 0.22))


func _fx_add(c: Node2D) -> void:
	for w in waves:
		if w.alive:
			_draw_wave(c, w.x, w.y, w.s, t - w.born)
	var big := smooth(5.0, 5.7, t) * (1.0 - smooth(PEAK - 0.1, PEAK + 0.1, t))
	if big > 0.0:
		blob(c, hero.hand, 120.0 * big, COL * Color(1, 1, 1, 0.33))
		blob(c, hero.hand, 46.0 * big, HOT)
	if hit and t < PEAK + 0.4:
		var k := smooth(PEAK, PEAK + 0.4, t)
		blob(c, foe.pos + Vector2(-40, -170), 140.0 * (1.0 - k), HOT * Color(1, 1, 1, 0.3))
	speed_lines(c, 300.0, 1.0, smooth(PEAK - 0.12, PEAK, t) * (1.0 - smooth(PEAK + 0.1, PEAK + 0.5, t)), HOT)
