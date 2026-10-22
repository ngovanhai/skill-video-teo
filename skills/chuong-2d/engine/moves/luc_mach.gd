extends "res://engine.gd"
# Lục Mạch Thần Kiếm (11.5 s): Cưu Ma Trí chém Hỏa Diệm Đao (đao khí lửa lưỡi liềm), Đoàn Dự chỉ một ngón,
# sáu mạch sáng dọc cánh tay, kiếm khí xé đôi từng lưỡi lửa -> sáu thanh kiếm khí xoè sau lưng -> phóng liên hoàn,
# chém đôi đại đao lửa, đánh văng đối thủ.

const SWORD := Color(0.55, 1.25, 1.8)
const SWORD_HOT := Color(1.7, 2.1, 2.4)
const FIRE := Color(1.9, 0.6, 0.12)
const FIRE_HOT := Color(2.4, 1.5, 0.5)
const SHOTS := [2.25, 2.7, 3.15, 3.55, 3.85, 4.1]
const SLASHES := [1.85, 2.3, 2.75]
const LAUNCH := 6.0

var flames: Array = []      # đao khí lửa đang bay
var halves: Array = []      # nửa lưỡi lửa bị chém
var shots: Array = []       # kiếm khí ngón tay
var cuts: Array = []        # vệt chém còn lưu trên không
var swords: Array = []      # 6 thanh kiếm khí xoè sau lưng
var big_fire := {}
var shot_i := 0
var slash_i := 0
var hit_done := false
var mer := []               # màu 6 mạch


func _setup() -> void:
	sky_cols = [Color("#0b1626"), Color("#28405f"), Color("#b0705a")]
	moon_on = false
	n_stars = 50
	far_col = Color("#26364f")
	near_col = Color("#172235")
	mist_col = Color(0.7, 0.8, 0.95, 0.2)
	ground_cols = [Color("#232a36"), Color("#0d1117"), Color("#3c4a5c")]
	slowmo = [6.05, 6.75, 0.3]
	title = "LỤC MẠCH THẦN KIẾM"
	title_at = 8.1
	cue(1.85, "lib-whoosh", 0.5)
	cue(2.3, "lib-whoosh", 0.5)
	cue(2.75, "lib-whoosh", 0.5)
	cue(4.6, "lib-riser", 0.8)
	cue(LAUNCH, "lib-whoosh-cinematic", 0.9)
	for s in SHOTS:
		cue(s, "lib-glitch-1", 0.3)
	title_col = Color(1.0, 1.8, 2.2)
	set_char(hero, "doan-du")
	set_char(foe, "cuu-ma-tri")
	hero.pos = Vector2(480, GROUND)
	foe.pos = Vector2(1440, GROUND)
	hero.col = SWORD
	foe.col = FIRE
	for i in 6:
		mer.append(Color.from_hsv(0.45 + i * 0.045, 0.55, 1.0) * Color(1.9, 1.9, 1.9, 1))


func _finger() -> Vector2:
	return joint_pos(hero, "hdF", Vector2(0, 30))


func _foe_body() -> Vector2:
	return foe.pos + Vector2(0, -150)


func _story(dt: float) -> void:
	# ---- Cưu Ma Trí
	var wind := smooth(0.8, 1.5, t) * (1.0 - smooth(3.2, 3.6, t))
	var sl := 0.0
	for s in SLASHES:
		sl = maxf(sl, pulse(s - 0.05, s + 0.12, 0.25, t))
	var big_w := smooth(4.6, 5.4, t) * (1.0 - smooth(5.75, 5.85, t))
	var big_s := pulse(5.75, 6.2, 0.6, t) * (1.0 - smooth(6.3, 6.4, t))
	foe.extra = [["windup", maxf(wind * (1.0 - sl), big_w)], ["slash", maxf(sl, big_s)], ["guard", pulse(3.5, 4.4, 0.4, t)]]
	foe.aura = wind * 0.7 + big_w * 1.0
	foe.lean = -pulse(3.55, 4.3, 0.5, t) * 0.3
	foe.expr = "ko" if hit_done else ("soc" if t > 3.5 and t < 4.6 else ("gian" if t > 0.8 else "binh"))
	# ---- Đoàn Dự
	var pt := smooth(1.3, 1.8, t) * (1.0 - smooth(4.4, 4.7, t))
	var rs := smooth(4.5, 5.0, t) * (1.0 - smooth(5.85, 5.95, t))
	var thrust := smooth(5.85, 5.95, t) * (1.0 - smooth(7.6, 8.4, t))
	hero.extra = [["point", maxf(pt, thrust)], [{"uaF": -150, "faF": -25, "uaB": 35, "faB": -70, "head": -6, "torso": -3}, rs]]
	hero.aura = smooth(1.4, 2.2, t) * 0.4 * (1.0 - smooth(4.3, 4.6, t)) + smooth(4.5, 5.3, t) * 0.9 * (1.0 - smooth(7.0, 8.0, t))
	hero.lean = thrust * 0.25
	hero.expr = "ngai" if t > 8.2 else ("quyet-tam" if t > 1.3 else "binh")
	pose(hero, 0.0)
	pose(foe, 0.0)
	var fh: Vector2 = foe.hand
	var tip := _finger()

	# lửa tụ trên tay Cưu Ma Trí
	if foe.aura > 0.05:
		for i in int(1 + foe.aura * 4):
			emit("add", fh + Vector2(rng.randf_range(-20, 20), rng.randf_range(-20, 20)), Vector2(rng.randf_range(-40, 40), -rng.randf_range(80, 260)), rng.randf_range(0.3, 0.6), rng.randf_range(10, 26), FIRE * Color(1, 1, 1, 0.3))
		for i in int(foe.aura * 3):
			emit("add", foe.pos + Vector2(rng.randf_range(-70, 70), -rng.randf_range(0, 260)), Vector2(0, -rng.randf_range(120, 280)), 0.6, rng.randf_range(16, 34), FIRE * Color(1, 1, 1, 0.1))
	if hero.aura > 0.05:
		for i in int(hero.aura * 3):
			emit("add", hero.pos + Vector2(rng.randf_range(-60, 60), -rng.randf_range(0, 260)), Vector2(rng.randf_range(-10, 10), -rng.randf_range(100, 220)), 0.7, rng.randf_range(10, 26), SWORD * Color(1, 1, 1, 0.1))

	# chém đao lửa
	if slash_i < SLASHES.size() and t >= SLASHES[slash_i]:
		var y: float = [0.0, -50.0, 35.0][slash_i]
		flames.append({"p": fh + Vector2(-40, 0), "v": Vector2(-950, y * 1.2), "r": 95.0, "rot": PI})
		add_ring(fh, 220, FIRE_HOT, 10, 0.35)
		shake = maxf(shake, 8.0)
		slash_i += 1
	# đại đao lửa
	if t >= 6.15 and big_fire.is_empty():
		big_fire = {"p": fh + Vector2(-60, -20), "v": Vector2(-700, 0), "r": 230.0, "rot": PI}
		flames.append(big_fire)
		add_ring(fh, 400, FIRE_HOT, 18, 0.5)
		shake = 18.0
	for f in flames:
		f.p += f.v * dt
		for i in 3:
			var a := rng.randf_range(-1.1, 1.1)
			emit("add", f.p + Vector2(cos(a + PI), sin(a + PI)) * f.r * 0.9, Vector2(rng.randf_range(80, 260), rng.randf_range(-60, 60)), 0.4, rng.randf_range(12, 26) * f.r / 95.0, FIRE * Color(1, 1, 1, 0.25))

	# kiếm khí ngón tay
	if shot_i < SHOTS.size() and t >= SHOTS[shot_i]:
		var target := _foe_body() + Vector2(0, rng.randf_range(-60, 40))
		for f in flames:
			if not f.has("aimed") and f != big_fire:
				f.aimed = true
				target = f.p + f.v * 0.12
				break
		var dir := (target - tip).normalized()
		shots.append({"p": tip, "dir": dir, "col": mer[shot_i], "len": 0.0})
		add_ring(tip, 120, SWORD_HOT, 6, 0.25)
		burst(tip, 14, 300, 900, SWORD_HOT, mer[shot_i], 0.0, 3.0, dir.angle() - 0.5, dir.angle() + 0.5)
		shake = maxf(shake, 6.0)
		shot_i += 1
	for s in shots:
		s.p += s.dir * 3400.0 * dt
		s.len = minf(s.len + 3400.0 * dt, 420.0)
	# va chạm kiếm khí với đao lửa / thân đối thủ
	var keep: Array = []
	for s in shots:
		var alive := true
		for f in flames:
			if f != big_fire and s.p.distance_to(f.p) < f.r * 1.1:
				_split(f, s.dir)
				flames.erase(f)
				break
		if s.p.x > foe.pos.x - 40:
			alive = false
			cuts.append({"a": s.p - s.dir * 600, "b": s.p + s.dir * 140, "t0": t, "col": s.col})
			burst(s.p, 30, 300, 1100, SWORD_HOT, s.col, 600.0, 1.5, PI * 0.5, PI * 1.5)
			add_ring(s.p, 160, SWORD_HOT, 8, 0.3)
			foe.pos.x += 18.0
			shake = maxf(shake, 12.0)
			flash = maxf(flash, 0.12)
			flash_col = Color(0.8, 0.95, 1.0)
		if s.p.x > W + 200:
			alive = false
		if alive:
			keep.append(s)
	shots = keep
	# đao lửa trúng Đoàn Dự (không xảy ra vì bị chém hết) — dọn cái bay khỏi khung
	flames = flames.filter(func(f): return f.p.x > -400)

	# sáu thanh kiếm khí xoè sau lưng
	if t >= 4.6 and swords.is_empty():
		for i in 6:
			swords.append({"i": i, "p": Vector2.ZERO, "dir": Vector2.UP, "t0": 4.6 + i * 0.12, "launched": false, "done": false, "v": Vector2.ZERO})
	for sw in swords:
		var a := lerpf(-1.05, 1.05, sw.i / 5.0)
		var home: Vector2 = hero.pos + Vector2(-30, -300) + Vector2(sin(a), -cos(a)) * 250.0 + Vector2(0, sin(rt * 3.0 + sw.i) * 8.0)
		var aim := (_foe_body() - home).normalized()
		if t >= sw.t0 and not sw.has("born"):
			sw.born = true
			add_ring(home, 90, mer[sw.i], 5, 0.3)
			burst(home, 10, 150, 500, SWORD_HOT, mer[sw.i], 0.0, 3.0)
		if not sw.launched:
			sw.p = home
			sw.dir = Vector2(sin(a), -cos(a)).lerp(aim, smooth(5.3, 5.85, t)).normalized()
			if t >= LAUNCH + sw.i * 0.07:
				sw.launched = true
				sw.v = sw.dir * 2700.0
				add_ring(home, 140, SWORD_HOT, 6, 0.25)
		elif not sw.done:
			sw.p += sw.v * dt
			for i in 2:
				emit("add", sw.p - sw.dir * rng.randf_range(40, 200), -sw.v * 0.05, 0.3, rng.randf_range(10, 22), mer[sw.i] * Color(1, 1, 1, 0.3))
			if not big_fire.is_empty() and flames.has(big_fire) and sw.p.x > big_fire.p.x - big_fire.r * 0.6:
				_split(big_fire, sw.dir)
				flames.erase(big_fire)
				flash = 0.4
				flash_col = Color(1.0, 0.85, 0.6)
				shake = 26.0
			if sw.p.x >= _foe_body().x - 30:
				sw.done = true
				cuts.append({"a": sw.p - sw.dir * 700, "b": sw.p + sw.dir * 260, "t0": t, "col": mer[sw.i], "big": true})
				burst(sw.p, 40, 400, 1500, SWORD_HOT, mer[sw.i], 700.0, 1.2)
				add_ring(sw.p, 260, mer[sw.i], 10, 0.4)
				shake = maxf(shake, 20.0)
				if sw.i == 5:
					_hit()

	if hit_done:
		var k := clampf((t - foe.t_hit) / 0.9, 0.0, 1.0)
		foe.pos = Vector2(lerpf(foe.x_hit, 1560.0, ease_out(k)), GROUND - sin(k * PI) * 130.0 if k < 1.0 else GROUND)
		foe.rot = ease_out(k) * PI * 0.5
		foe.hurt = 1.0
		foe.extra = []
		if k >= 1.0 and not foe.has("landed"):
			foe.landed = true
			sfx("lib-impact-bass-2", 0.5)
			shake = maxf(shake, 14.0)
			for i in 22:
				emit("smoke", Vector2(1560 + rng.randf_range(-40, 260), GROUND), Vector2(rng.randf_range(-160, 220), -rng.randf_range(20, 140)), 2.2, rng.randf_range(40, 90), Color(0.45, 0.5, 0.55, 0.4))
	for h in halves:
		h.p += h.v * dt
		h.v.y += 900.0 * dt
		h.rot += h.w * dt
		h.life -= dt
	halves = halves.filter(func(h): return h.life > 0.0)
	if t > 7.8 and rng.randf() < 0.5:
		emit("ember", Vector2(rng.randf_range(600, 1900), GROUND + 20), Vector2(rng.randf_range(-20, 30), -rng.randf_range(40, 120)), rng.randf_range(2.0, 3.5), rng.randf_range(2, 4), SWORD)


func _split(f: Dictionary, dir: Vector2) -> void:
	sfx("lib-impact-bass-2", 0.5)
	var s: float = f.r / 95.0
	for side in [-1.0, 1.0]:
		halves.append({"p": f.p, "v": f.v * 0.3 + Vector2(-120, side * 380 * s) + dir * 120, "r": f.r, "rot": f.rot, "w": side * 3.0,
			"a0": -1.2 if side < 0 else 0.0, "a1": 0.0 if side < 0 else 1.2, "life": 0.6, "max": 0.6})
	burst(f.p, int(40 * s), 300, 1200, FIRE_HOT, SWORD_HOT, 800.0, 1.2)
	add_ring(f.p, 200 * s, FIRE_HOT, 8, 0.3)
	cuts.append({"a": f.p - dir * 260 * s, "b": f.p + dir * 260 * s, "t0": t, "col": SWORD_HOT})
	shake = maxf(shake, 10.0 * s)


func _hit() -> void:
	sfx("lib-impact-bass-1", 1.0)
	sfx("lib-impact-bass-2", 1.0)
	hit_done = true
	foe.t_hit = t
	foe.x_hit = foe.pos.x
	flash = 0.9
	flash_col = Color(0.85, 0.95, 1.0)
	shake = 40.0
	var c := _foe_body()
	add_ring(c, 800, SWORD_HOT, 26, 0.8)
	add_ring(c, 520, Color(2, 2, 2), 12, 0.5, 1.0, 0.06)
	add_ring(Vector2(c.x, GROUND), 900, SWORD, 14, 1.0, 0.2)
	for i in 200:
		var a := rng.randf() * TAU
		emit("spark", c, Vector2(cos(a), sin(a)) * rng.randf_range(300, 2000), rng.randf_range(0.4, 1.1), rng.randf_range(2, 5), mer[i % 6], 900.0, 0.9)
	for i in 30:
		var a := rng.randf() * TAU
		emit("smoke", c, Vector2(cos(a), sin(a) * 0.6) * rng.randf_range(100, 450), rng.randf_range(1.8, 3.0), rng.randf_range(50, 120), Color(0.35, 0.4, 0.45, 0.5), -40.0, 1.6)


func _cam() -> Array:
	var c := CENTER
	var z := 1.0
	var k1 := smooth(1.2, 1.9, t) * (1.0 - smooth(2.2, 2.6, t))
	c = c.lerp(Vector2(640, 600), k1)
	z = lerpf(z, 1.45, k1)
	var k2 := smooth(4.3, 5.0, t) * (1.0 - smooth(5.9, 6.3, t))
	c = c.lerp(Vector2(640, 520), k2)
	z = lerpf(z, 1.22, k2)
	var k3 := smooth(6.1, 6.6, t) * (1.0 - smooth(8.0, 9.5, t))
	c = c.lerp(Vector2(1200, 600), k3)
	z = lerpf(z, 1.15, k3)
	var k4 := smooth(8.6, 11.0, t)
	c = c.lerp(Vector2(1030, 580), k4)
	z = lerpf(z, 1.02, k4)
	z += 0.03 * smooth(0.0, 1.2, t) * (1.0 - k1)
	return [c, z]


func _fx_ground(c: Node2D) -> void:
	for f in flames:
		flat_blob(c, Vector2(f.p.x, GROUND + 14), f.r * 2.2, 0.15, Color(1.0, 0.5, 0.2, 0.4))


func _fx_add(c: Node2D) -> void:
	var tip := _finger()
	# sáu mạch sáng dọc cánh tay: vai -> khuỷu -> cổ tay -> đầu ngón
	var mk := smooth(1.5, 2.2, t) * (1.0 - smooth(4.4, 4.8, t)) + smooth(5.7, 5.9, t) * (1.0 - smooth(7.4, 8.0, t))
	if mk > 0.0:
		var path := [joint_pos(hero, "uaF"), joint_pos(hero, "faF"), joint_pos(hero, "hdF"), tip]
		for i in 6:
			var on := smooth(1.5 + i * 0.1, 1.6 + i * 0.1, t) * mk
			if on <= 0.0:
				continue
			var u := (i + 0.5) / 6.0 * 3.0
			var seg := mini(int(u), 2)
			var p: Vector2 = path[seg].lerp(path[seg + 1], u - seg)
			var pl := 1.0 + 0.3 * sin(rt * 20.0 + i)
			blob(c, p, 44.0 * pl, mer[i] * Color(1, 1, 1, 0.45 * on))
			c.draw_circle(p, 8.0 * on, mer[i] * 1.4)
		# đường kinh mạch nối các điểm
		c.draw_polyline(PackedVector2Array(path), SWORD * Color(1, 1, 1, 0.35 * mk), 3.0)
		blob(c, tip, 34 + 8 * sin(rt * 30.0), SWORD_HOT * Color(1, 1, 1, 0.6 * mk))
	# lửa trên tay Cưu Ma Trí
	if foe.aura > 0.05:
		var fh: Vector2 = foe.hand
		blob(c, fh, 60 + 50 * foe.aura, FIRE * Color(1, 1, 1, 0.3))
		blob(c, fh, 18 + 14 * foe.aura, FIRE_HOT)
	# đao lửa
	for f in flames:
		var r: float = f.r * (1.0 + 0.05 * sin(rt * 30.0))
		crescent(c, f.p + Vector2(18, 0), r * 1.12, -1.2, 1.2, f.rot, FIRE * Color(1, 1, 1, 0.2), FIRE * Color(1, 1, 1, 0.3))
		crescent(c, f.p, r, -1.2, 1.2, f.rot, FIRE * Color(1, 1, 1, 0.75), FIRE_HOT)
		blob(c, f.p + Vector2(-r * 0.8, 0), r * 0.6, FIRE * Color(1, 1, 1, 0.3))
	for h in halves:
		var a: float = h.life / h.max
		crescent(c, h.p, h.r, h.a0, h.a1, h.rot, FIRE * Color(1, 1, 1, 0.7 * a), FIRE_HOT * Color(1, 1, 1, a))
	# kiếm khí ngón tay: vệt dài + lưỡi sáng ở đầu
	for s in shots:
		var tail: Vector2 = s.p - s.dir * s.len
		c.draw_line(tail, s.p, s.col * Color(1, 1, 1, 0.25), 22.0)
		c.draw_line(tail.lerp(s.p, 0.4), s.p, s.col, 6.0)
		blade(c, s.p, s.dir, 130.0, 9.0, s.col, SWORD_HOT)
		blob(c, s.p, 50, s.col * Color(1, 1, 1, 0.4))
	# vệt chém còn đọng
	for ct in cuts:
		var k: float = clampf((t - ct.t0) / (0.5 if ct.has("big") else 0.3), 0.0, 1.0)
		if k >= 1.0:
			continue
		var w: float = (14.0 if ct.has("big") else 7.0) * (1.0 - k)
		c.draw_line(ct.a, ct.b, ct.col * Color(1, 1, 1, 0.3 * (1.0 - k)), w * 3.0)
		c.draw_line(ct.a, ct.b, SWORD_HOT * Color(1, 1, 1, 1.0 - k), w)
	# sáu thanh kiếm khí
	for sw in swords:
		if not sw.has("born") or sw.done:
			continue
		var grow := smooth(sw.t0, sw.t0 + 0.25, t)
		var col: Color = mer[sw.i]
		blob(c, sw.p, 90 * grow, col * Color(1, 1, 1, 0.22))
		blade(c, sw.p + sw.dir * 120 * grow, sw.dir, 240.0 * grow, 13.0 * grow, col, SWORD_HOT)
		if sw.launched:
			c.draw_line(sw.p - sw.dir * 600, sw.p - sw.dir * 120, col * Color(1, 1, 1, 0.3), 26.0)
	speed_lines(c, tip.x, 1.0, pulse(6.0, 6.3, 0.4, t), SWORD_HOT)
