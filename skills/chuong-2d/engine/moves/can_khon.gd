extends "res://engine.gd"
# Càn Khôn Đại Na Di (12 s): hoàng hôn Quang Minh Đỉnh. Thành Côn liên tiếp đánh Hỗn Nguyên chưởng (cầu tím),
# Trương Vô Kỵ không đánh mà mở vòng bát quái quanh tay: nhịp 1 hất cầu lên trời, nhịp 2 dập xuống đất, nhịp 3 xoay một vòng trả về.
# Đỉnh: cầu Hỗn Nguyên khổng lồ bị bắt, xoay quanh người, hoá lam, dội ngược -> Thành Côn trúng chính chưởng mình, văng xoáy lộn.
# Thẻ chiêu: Trương Vô Kỵ · Thành Côn · mượn lực xoay trả · lam ngọc vs tím · hoàng hôn đỉnh núi · cầu khổng lồ đổi màu dội ngược

const COL := Color(0.3, 1.25, 1.35)
const HOT := Color(1.2, 2.2, 2.2)
const FOE_COL := Color(1.1, 0.2, 1.3)
const FOE_HOT := Color(2.0, 0.9, 2.1)
const HX := 470.0
const FIRES := [[2.2, "up"], [3.4, "ground"], [3.95, "back"]]
const BIG_FIRE := 5.7

var balls: Array = []
var fire_i := 0
var big_fired := false
var hit := false
var x_hit := 0.0
var x_hit_t := 0.0
var ring_spin := 0.0
var scorch: Array = []


func _setup() -> void:
	sky_cols = [Color("#3a1e4e"), Color("#e07a4a"), Color("#f6b060")]
	moon = Vector2(1380, 400)
	moon_col = Color(1.9, 0.95, 0.5)
	moon_glow = Color(1.0, 0.5, 0.25, 0.5)
	moon_craters = false
	n_stars = 0
	far_col = Color("#7a3a50")
	near_col = Color("#4a2236")
	mist_col = Color(1.0, 0.65, 0.5, 0.28)
	ground_cols = [Color("#6a3a36"), Color("#22100f"), Color("#a05a40")]
	slowmo = [7.12, 7.75, 0.3]
	title = "CÀN KHÔN ĐẠI NA DI"
	title_at = 8.7
	title_col = HOT
	set_char(hero, "truong-vo-ky")
	set_char(foe, "thanh-con")
	hero.pos = Vector2(HX, GROUND)
	foe.pos = Vector2(1440, GROUND)
	hero.col = COL
	foe.col = FOE_COL
	cue(1.0, "lib-riser", 0.6)
	cue(4.4, "lib-riser", 0.9)
	cue(BIG_FIRE, "lib-whoosh-cinematic", 0.9)


func _center() -> Vector2:
	return hero.pos + Vector2(165, -195)


func _ring_k() -> float:
	return smooth(1.5, 2.1, t) * (1.0 - smooth(7.4, 8.4, t))


func _big_k() -> float:
	return smooth(5.6, 6.1, t) * (1.0 - smooth(7.1, 7.5, t))


func _spinning() -> bool:
	for b in balls:
		if b.state == "spin":
			return true
	return false


func _story(dt: float) -> void:
	var rk := _ring_k()
	var spin := _spinning()
	ring_spin += dt * (5.0 if spin else 0.8)
	# ---- Trương Vô Kỵ: hai tay vẽ vòng tròn, không ra đòn
	var ph := ring_spin * 1.6
	var circ := {"uaF": -55 + 40 * sin(ph), "faF": -50 + 30 * cos(ph), "uaB": -20 - 40 * sin(ph), "faB": -70 - 30 * cos(ph), "torso": 3 * sin(ph), "head": -2}
	hero.extra = [["charge", 0.4 * rk], [circ, rk]]
	hero.lean = 0.15 * rk + _big_k() * 0.2
	hero.crouch = 0.3 * rk
	hero.aura = rk * 0.35 + _big_k() * 0.8
	hero.expr = "ngai" if t > 8.4 else ("quyet-tam" if t > 5.8 else "binh")
	# ---- Thành Côn
	if not hit:
		var shot := 0.0
		for f in FIRES:
			shot = maxf(shot, pulse(f[0] - 0.12, f[0] + 0.05, 0.3, t))
		var bg := smooth(4.4, 5.4, t) * (1.0 - smooth(BIG_FIRE - 0.05, BIG_FIRE + 0.05, t))
		foe.gather = smooth(1.0, 1.8, t) * (1.0 - smooth(2.1, 2.2, t)) + bg
		foe.push = shot + smooth(BIG_FIRE - 0.1, BIG_FIRE, t) * (1.0 - smooth(6.3, 6.8, t))
		foe.extra = [["raise", bg * 0.6], ["guard", pulse(4.95, 5.25, 0.3, t)]]
		foe.lean = foe.push * 0.3 - pulse(4.95, 5.25, 0.3, t) * 0.4
		foe.aura = foe.gather * 0.8 + 0.25
		foe.expr = "soc" if t > 6.2 else ("dac-y" if t > 4.8 else "gian")
	pose(hero, 0.0)
	pose(foe, 0.0)
	var C := _center()

	if foe.gather > 0.05:
		for i in 2:
			var a := rng.randf() * TAU
			var p: Vector2 = foe.hand + Vector2.from_angle(a) * rng.randf_range(90, 200)
			emit("add", p, (foe.hand - p) * 3.0, 0.3, rng.randf_range(6, 14), FOE_COL * Color(1, 1, 1, 0.5))
	if rk > 0.3 and int(rt * 30) % 3 == 0:
		emit("ember", Vector2(rng.randf_range(0, W), GROUND + rng.randf_range(0, 60)), Vector2(rng.randf_range(-20, 40), -rng.randf_range(40, 120)), 2.5, rng.randf_range(2, 4), Color(1.6, 0.9, 0.4))

	# ---- phóng chưởng
	if fire_i < FIRES.size() and t >= FIRES[fire_i][0]:
		_fire(FIRES[fire_i][1], 26.0, 1900.0)
		fire_i += 1
	if not big_fired and t >= BIG_FIRE:
		big_fired = true
		_fire("big", 95.0, 1300.0)
		shake = maxf(shake, 14.0)

	# ---- cầu Hỗn Nguyên
	for b in balls:
		var p: Vector2 = b.p
		match b.state:
			"fly":
				b.p = p + b.v * dt
				if b.p.distance_to(C) < (260.0 if b.plan == "big" else 150.0):
					_catch(b, C)
			"spin":
				b.a += b.w * dt
				b.rad = lerpf(b.rad, b.rs, 1.0 - exp(-10.0 * dt))
				b.p = C + Vector2.from_angle(b.a) * b.rad
				if b.plan == "back" or b.plan == "big":
					b.ck = minf(1.0, b.ck + dt * 1.6)
				if b.plan == "big":
					b.r = lerpf(95.0, 125.0, b.ck)
				if t >= b.until:
					_release(b)
			"out":
				b.p = p + b.v * dt
				if b.plan == "up" and b.p.y < 150:
					_pop_sky(b)
				elif b.plan == "ground" and b.p.y > GROUND - 5:
					_pop_ground(b)
				elif (b.plan == "back" or b.plan == "big") and b.p.x > foe.pos.x - 60:
					_pop_foe(b)
		if b.state != "dead":
			var col: Color = FOE_COL.lerp(COL, b.ck)
			emit("add", b.p + Vector2(rng.randf_range(-8, 8), rng.randf_range(-8, 8)), -b.v * 0.05, 0.35, b.r * rng.randf_range(0.5, 0.9), col * Color(1, 1, 1, 0.3))
	balls = balls.filter(func(b): return b.state != "dead")

	# ---- hậu quả: văng xoáy lộn
	if hit:
		var k := clampf((t - x_hit_t) / 1.1, 0.0, 1.0)
		foe.pos = Vector2(lerpf(x_hit, 1490.0, ease_out(k)), GROUND - sin(k * PI) * 230.0)
		foe.rot = ease_out(k) * PI * 2.5
		foe.hurt = 1.0
		foe.extra = []
		foe.aura = 0.0
		foe.gather = 0.0
		foe.push = 0.0
		if k >= 1.0 and not foe.has("landed"):
			foe.landed = true
			shake = maxf(shake, 14.0)
			sfx("lib-impact-bass-2", 0.5)
			for i in 22:
				emit("smoke", Vector2(1490 + rng.randf_range(-60, 240), GROUND), Vector2(rng.randf_range(-160, 220), -rng.randf_range(20, 140)), 2.2, rng.randf_range(40, 90), Color(0.55, 0.35, 0.32, 0.45))


func _fire(plan: String, r: float, spd: float) -> void:
	var p: Vector2 = foe.hand + Vector2(-20, 0)
	var dir := (_center() - p).normalized()
	balls.append({"p": p, "v": dir * spd, "r": r, "ck": 0.0, "state": "fly", "plan": plan, "a": 0.0, "rad": 0.0, "rs": 0.0, "w": 0.0, "until": 0.0})
	add_ring(p, 120 if plan != "big" else 260, FOE_HOT, 6, 0.3)
	sfx("lib-whoosh-short" if plan != "big" else "lib-whoosh", 0.6)


func _catch(b: Dictionary, C: Vector2) -> void:
	var d: Vector2 = b.p - C
	b.state = "spin"
	b.a = d.angle()
	b.rad = d.length()
	# [quỹ đạo xoay, vận tốc góc, thời gian]: up = vòng ngược lên đỉnh, ground = xuôi xuống đất, back/big = trọn một vòng
	var cfg: Array = {"up": [130.0, -7.0, 0.22], "ground": [130.0, 7.0, 0.16], "back": [140.0, -9.0, 0.70], "big": [230.0, -7.0, 0.90]}[b.plan]
	b.rs = cfg[0]
	b.w = cfg[1]
	b.until = t + cfg[2]
	add_ring(b.p, 140 if b.plan != "big" else 320, HOT, 6, 0.3)
	burst(b.p, 16 if b.plan != "big" else 60, 200, 700, HOT, FOE_HOT, 200.0, 2.0)
	shake = maxf(shake, 6.0 if b.plan != "big" else 18.0)
	sfx("lib-glitch-1", 0.35 if b.plan != "big" else 0.55)
	if b.plan == "big":
		flash = 0.25
		flash_col = Color(0.7, 1.0, 1.0)
		sfx("lib-chime", 0.5)


func _release(b: Dictionary) -> void:
	b.state = "out"
	var tgt: Vector2 = foe.pos + Vector2(0, -170)
	match b.plan:
		"up":
			b.v = Vector2(0.35, -1.0).normalized() * 2100.0
		"ground":
			b.v = Vector2(0.45, 1.0).normalized() * 2100.0
		"back":
			b.v = (tgt - b.p).normalized() * 2600.0
		"big":
			b.v = (tgt - b.p).normalized() * 2800.0
			sfx("lib-whoosh-cinematic", 0.8)
	sfx("lib-whoosh-short", 0.5)


func _pop_sky(b: Dictionary) -> void:
	b.state = "dead"
	add_ring(b.p, 260, FOE_HOT, 8, 0.5)
	burst(b.p, 50, 200, 900, FOE_HOT, FOE_COL, 300.0, 1.2)
	shake = maxf(shake, 8.0)
	sfx("lib-impact-bass-2", 0.4)
	sfx("lib-sparkle", 0.4)


func _pop_ground(b: Dictionary) -> void:
	b.state = "dead"
	var p := Vector2(b.p.x, GROUND)
	scorch.append(p)
	add_ring(p, 360, FOE_HOT, 10, 0.5, 0.22)
	burst(p, 40, 300, 1100, FOE_HOT, Color(1.6, 0.8, 0.4), 1200.0, 1.0, -PI, 0.0)
	for i in 14:
		emit("rock", p, Vector2(rng.randf_range(-400, 500), -rng.randf_range(300, 800)), 1.6, rng.randf_range(6, 14), Color("#3a2220"), 1600.0)
	for i in 10:
		emit("smoke", p + Vector2(rng.randf_range(-60, 60), 0), Vector2(rng.randf_range(-120, 160), -rng.randf_range(40, 160)), 1.6, rng.randf_range(40, 80), Color(0.4, 0.25, 0.25, 0.5))
	shake = maxf(shake, 13.0)
	sfx("lib-impact-bass-2", 0.7)


func _pop_foe(b: Dictionary) -> void:
	b.state = "dead"
	var p: Vector2 = b.p
	if b.plan == "back":
		add_ring(p, 240, HOT, 8, 0.35)
		burst(p, 40, 300, 1000, HOT, COL, 600.0, 1.4, -PI * 0.6, PI * 0.6)
		foe.pos.x += 40.0
		shake = maxf(shake, 12.0)
		sfx("lib-impact-bass-2", 0.6)
		return
	hit = true
	x_hit = foe.pos.x
	x_hit_t = t
	foe.expr = "ko"
	flash = 0.5
	flash_col = Color(0.8, 1.0, 1.0)
	shake = 36.0
	add_ring(p, 760, HOT, 22, 0.8)
	add_ring(Vector2(p.x, GROUND), 900, COL, 12, 1.0, 0.2)
	burst(p, 170, 300, 1800, HOT, Color(2.2, 2.2, 2.2), 800.0, 0.9)
	burst(p, 60, 200, 900, FOE_HOT, FOE_COL, 600.0, 1.2)
	sfx("lib-impact-bass-1", 1.0)
	sfx("lib-impact-bass-2", 1.0)


func _cam() -> Array:
	var c := CENTER
	var z := 1.0
	var k1 := smooth(0.9, 1.8, t) * (1.0 - smooth(2.1, 2.5, t))
	c = c.lerp(Vector2(900, 620), k1)
	z = lerpf(z, 1.22, k1)
	var k3 := smooth(4.3, 5.2, t) * (1.0 - smooth(5.6, 5.95, t))
	c = c.lerp(Vector2(1230, 600), k3)
	z = lerpf(z, 1.32, k3)
	var k4 := smooth(5.75, 6.2, t) * (1.0 - smooth(6.95, 7.25, t))
	c = c.lerp(Vector2(720, 590), k4)
	z = lerpf(z, 1.3, k4)
	var k5 := smooth(7.0, 7.4, t) * (1.0 - smooth(8.4, 10.0, t))
	c = c.lerp(Vector2(1150, 560), k5)
	z = lerpf(z, 1.15, k5)
	var k6 := smooth(8.4, 10.6, t)
	c = c.lerp(Vector2(1000, 590), k6)
	return [c, z]


# quẻ bát quái: 1 = vạch liền, 0 = vạch đứt (từ trong ra ngoài), Càn ở đỉnh, Khôn ở đáy
const TRIGRAMS := [[1, 1, 1], [0, 1, 1], [1, 0, 1], [0, 0, 1], [0, 0, 0], [1, 1, 0], [0, 1, 0], [1, 0, 0]]


func _bagua(c: Node2D, C: Vector2, R: float, rot: float, col: Color, w: float, sy := 1.0) -> void:
	for i in 8:
		var a := rot - PI * 0.5 + i * TAU / 8.0
		var d := Vector2.from_angle(a)
		var tg := d.orthogonal()
		var tri: Array = TRIGRAMS[i]
		var hl := 1.6 if i == 0 or i == 4 else 1.0
		for j in 3:
			var m := C + d * (R + 14.0 + j * 9.0)
			var hw := 13.0 + j * 1.5
			var cc := col * Color(hl, hl, hl, 1.0)
			if tri[j] == 1:
				c.draw_line(_sq(m - tg * hw, C, sy), _sq(m + tg * hw, C, sy), cc, w)
			else:
				c.draw_line(_sq(m - tg * hw, C, sy), _sq(m - tg * 3.5, C, sy), cc, w)
				c.draw_line(_sq(m + tg * 3.5, C, sy), _sq(m + tg * hw, C, sy), cc, w)


func _sq(p: Vector2, C: Vector2, sy: float) -> Vector2:
	return Vector2(p.x, C.y + (p.y - C.y) * sy)


func _fx_ground(c: Node2D) -> void:
	var rk := _ring_k()
	var G := Vector2(hero.pos.x + 40, GROUND + 10)
	if rk > 0.0:
		var R := 220.0 * rk + 120.0 * _big_k()
		flat_blob(c, G, R * 1.4, 0.16, COL * Color(1, 1, 1, 0.25 * rk))
		c.draw_set_transform(G, 0.0, Vector2(1.0, 0.2))
		c.draw_arc(Vector2.ZERO, R, 0, TAU, 72, COL * Color(1, 1, 1, 0.6 * rk), 4.0)
		c.draw_arc(Vector2.ZERO, R * 0.7, 0, TAU, 72, COL * Color(1, 1, 1, 0.4 * rk), 2.0)
		c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		_bagua(c, G, R * 0.72, -ring_spin * 0.4, COL * Color(1, 1, 1, 0.5 * rk), 3.0, 0.2)
	for s in scorch:
		flat_blob(c, s, 160, 0.14, Color(0.1, 0.04, 0.05, 0.7))


func _fx_add(c: Node2D) -> void:
	var rk := _ring_k()
	var C := _center()
	# vòng Càn Khôn quanh tay
	if rk > 0.02:
		var spin := _spinning()
		var R := lerpf(110.0, 250.0, _big_k()) * (0.6 + 0.4 * rk)
		var a := rk * (1.0 if spin else 0.7)
		blob(c, C, R * 1.2, COL * Color(1, 1, 1, 0.12 * a))
		for k in 3:
			var s := ring_spin * (1.0 if k % 2 == 0 else -1.3) + k
			var rr := R * (1.0 - k * 0.14)
			for g in 3:
				var a0 := s + g * TAU / 3.0
				c.draw_arc(C, rr, a0, a0 + TAU / 3.0 - 0.5, 24, (HOT if k == 0 else COL) * Color(1, 1, 1, 0.7 * a), 3.0 if k == 0 else 2.0)
		_bagua(c, C, R, ring_spin * 0.5, COL * Color(1, 1, 1, 0.85 * a), 3.0)
	# cầu Hỗn Nguyên
	for b in balls:
		var p: Vector2 = b.p
		var r: float = b.r
		var col: Color = FOE_COL.lerp(COL, b.ck)
		var hot: Color = FOE_HOT.lerp(HOT, b.ck)
		blob(c, p, r * 2.4, col * Color(1, 1, 1, 0.3))
		blob(c, p, r * 1.1, hot * Color(1, 1, 1, 0.5))
		c.draw_circle(p, r * 0.42, hot)
		for k in 3:
			var a0 := rt * 9.0 + k * TAU / 3.0
			c.draw_arc(p, r * 0.85, a0, a0 + 1.6, 16, hot * Color(1, 1, 1, 0.8), 3.0)
		if b.state == "spin":
			c.draw_arc(C, b.rad, b.a - b.w * 0.12, b.a, 16, col * Color(1, 1, 1, 0.6), r * 0.5)
	# tụ cầu lớn trên tay Thành Côn
	var bg := smooth(4.4, 5.5, t) * (1.0 - smooth(BIG_FIRE - 0.05, BIG_FIRE, t))
	if bg > 0.0:
		var p: Vector2 = foe.hand + Vector2(-30, -20)
		blob(c, p, 220 * bg, FOE_COL * Color(1, 1, 1, 0.3))
		blob(c, p, 100 * bg, FOE_HOT * Color(1, 1, 1, 0.8))
		c.draw_circle(p, 38 * bg, FOE_HOT)
	elif foe.gather > 0.05 and not hit:
		blob(c, foe.hand, 70 * foe.gather, FOE_HOT * Color(1, 1, 1, 0.6))
