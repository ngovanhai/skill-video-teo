extends "res://engine.gd"
# Hàng Long Thập Bát Chưởng (13 s): Tiêu Phong tụ khí -> chưởng vàng (bàn tay khí + 2 rồng) đấu hắc chưởng tím
# của Lão Ma -> dồn lực -> nổ lớn, đối thủ văng.

const HX := 470.0
const FX := 1450.0
const GOLD := Color(1.5, 0.95, 0.25)
const GOLD_HOT := Color(2.0, 1.7, 1.05)
const PURP := Color(0.85, 0.2, 1.45)
const PURP_HOT := Color(1.6, 1.0, 2.1)

var cracks: Array = []
var rocks: Array = []
var bolts: Array = []
var g_head := Vector2.ZERO
var p_head := Vector2.ZERO
var g_on := false
var p_on := false
var clash := Vector2(990, 0)
var clash_on := false
var boom_done := false
var fired_g := false
var fired_p := false
var g_trail: Array = []
var beam_y := 640.0


func _setup() -> void:
	slowmo = [7.6, 8.3, 0.28]
	title = "HÀNG LONG THẬP BÁT CHƯỞNG"
	title_at = 8.9
	cue(1.3, "lib-riser", 0.8)
	cue(3.75, "lib-whoosh-cinematic", 0.9)
	cue(4.0, "lib-impact-bass-1", 1.0)
	cue(4.62, "lib-impact-bass-2", 1.0)
	cue(5.3, "lib-glitch-1", 0.35)
	cue(6.4, "lib-glitch-1", 0.35)
	cue(6.95, "lib-whoosh", 0.8)
	cue(7.6, "lib-impact-bass-1", 1.0)
	cue(7.614, "lib-impact-bass-2", 1.0)
	cue(8.596, "lib-impact-bass-2", 0.5)
	hero.both = 1.0
	foe.both = 1.0
	for k in 9:
		var a := PI + rng.randf_range(-0.2, 0.2) + (k - 4) * 0.38
		var pts := PackedVector2Array([Vector2(HX, GROUND + 6)])
		var p := pts[0]
		var seg_len := rng.randf_range(160, 330)
		for s in 9:
			a += rng.randf_range(-0.5, 0.5)
			var d := Vector2(cos(a), absf(sin(a)) * 0.22 + 0.05) * (seg_len / 9.0)
			p += Vector2(d.x if k % 2 == 0 else -d.x, d.y)
			pts.append(p)
		cracks.append(pts)
	for k in 16:
		var poly := PackedVector2Array()
		var n := rng.randi_range(5, 7)
		var r := rng.randf_range(9, 24)
		for j in n:
			var aa := TAU * j / n
			poly.append(Vector2(cos(aa), sin(aa)) * r * rng.randf_range(0.7, 1.2))
		rocks.append({"base": Vector2(HX + rng.randf_range(-260, 260), GROUND + rng.randf_range(0, 30)),
			"h": rng.randf_range(120, 360), "poly": poly, "ph": rng.randf() * TAU, "rot": rng.randf() * TAU,
			"delay": rng.randf_range(0, 0.9), "flung": false})


func _story(dt: float) -> void:
	var gat := smooth(1.2, 2.0, t) * (1.0 - smooth(3.85, 4.0, t))
	hero.gather = gat
	hero.crouch = gat * 0.8 + smooth(4.0, 4.1, t) * 0.4 * (1.0 - smooth(8.6, 9.6, t))
	hero.push = ease_out((t - 3.95) / 0.16) * (1.0 - smooth(8.8, 9.8, t))
	hero.lean = hero.push * 0.35 - gat * 0.15 + smooth(7.0, 7.3, t) * 0.25 * (1.0 - smooth(8.4, 9.4, t))
	hero.aura = smooth(1.3, 3.6, t) * (1.0 - smooth(4.2, 4.8, t)) + (0.45 + smooth(7.0, 7.25, t) * 0.9) * smooth(4.5, 5.0, t) * (1.0 - smooth(8.2, 9.5, t))
	hero.expr = "quyet-tam" if t > 1.2 and t < 9.6 else ("vui" if t >= 9.6 else "binh")
	var fg := smooth(2.3, 3.0, t) * (1.0 - smooth(4.05, 4.2, t))
	foe.gather = fg
	foe.crouch = fg * 0.6 + smooth(4.15, 4.3, t) * 0.4
	foe.push = ease_out((t - 4.1) / 0.16) * (1.0 - smooth(7.62, 7.7, t))
	foe.lean = foe.push * 0.35 - fg * 0.1 - smooth(6.9, 7.6, t) * 0.4
	foe.aura = smooth(2.4, 3.8, t) * (1.0 - smooth(4.3, 4.7, t)) + 0.5 * smooth(4.5, 5.0, t) * (1.0 - smooth(7.0, 7.6, t))
	foe.expr = "ko" if boom_done else ("soc" if t > 6.9 else ("gian" if t > 2.3 else "binh"))
	pose(hero, 0.0)
	pose(foe, 0.0)
	var hp: Vector2 = hero.hand
	var fp: Vector2 = foe.hand

	if t > 1.3 and t < 3.95:
		for i in int(3 + hero.aura * 7):
			orbit(hero, rng.randf_range(160, 460), rng.randf_range(2.0, 4.0), rng.randf_range(220, 420), rng.randf_range(3, 8), GOLD if rng.randf() < 0.8 else GOLD_HOT, 3.95)
	if t > 2.4 and t < 4.1:
		for i in int(2 + foe.aura * 5):
			orbit(foe, rng.randf_range(140, 380), -rng.randf_range(2.0, 4.0), rng.randf_range(220, 380), rng.randf_range(3, 7), PURP, 4.1)
	for f in [hero, foe]:
		if f.aura > 0.05:
			for i in int(f.aura * 4):
				var p: Vector2 = f.pos + Vector2(rng.randf_range(-75, 75), -rng.randf_range(0, 260))
				emit("add", p, Vector2(rng.randf_range(-20, 20), -rng.randf_range(120, 300) * (0.6 + f.aura)), rng.randf_range(0.4, 0.8), rng.randf_range(14, 34) * (0.6 + f.aura * 0.6), f.col * Color(1, 1, 1, 0.12))
	if t > 1.6 and t < 4.0:
		shake = maxf(shake, hero.aura * 5.0)
		if rng.randf() < 0.25:
			emit("smoke", Vector2(HX + rng.randf_range(-240, 240), GROUND + 10), Vector2(rng.randf_range(-40, 40), -rng.randf_range(10, 40)), 1.6, rng.randf_range(30, 60), Color(0.55, 0.5, 0.48, 0.25))

	if t >= 4.0 and not fired_g:
		fired_g = true
		g_on = true
		g_head = hp
		beam_y = hp.y
		flash = 0.55
		flash_col = Color(1.0, 0.9, 0.6)
		shake = 22.0
		add_ring(hp, 380, GOLD_HOT, 18, 0.5)
		add_ring(Vector2(HX, GROUND), 520, GOLD, 10, 0.7, 0.25)
		burst(hp, 70, 500, 1400, GOLD_HOT, GOLD_HOT, 600.0, 1.5, -0.9, 0.9)
		for r in rocks:
			r.flung = true
			r.v = Vector2(rng.randf_range(-300, 700), -rng.randf_range(300, 800))
	if t >= 4.15 and not fired_p:
		fired_p = true
		p_on = true
		p_head = fp
		shake = maxf(shake, 14.0)
		add_ring(fp, 300, PURP_HOT, 14, 0.5)

	if g_on and not clash_on:
		g_head.x += 700.0 * dt
		g_head.y = lerpf(g_head.y, beam_y, 0.15)
	if p_on and not clash_on:
		p_head.x -= 480.0 * dt
		p_head.y = lerpf(p_head.y, beam_y, 0.15)
	if g_on and p_on and not clash_on and g_head.x >= p_head.x - 40:
		clash_on = true
		clash = Vector2((g_head.x + p_head.x) * 0.5, beam_y)
		flash = 0.45
		flash_col = Color(1, 1, 1)
		shake = 30.0
		add_ring(clash, 600, Color(1.8, 1.6, 1.9), 22, 0.6)
		add_ring(Vector2(clash.x, GROUND), 700, GOLD, 12, 0.8, 0.22)
		burst(clash, 120, 400, 1500, GOLD_HOT, PURP_HOT)

	if clash_on and not boom_done:
		var base := 1010.0 + sin(t * 3.1) * 45.0 + sin(t * 7.3) * 12.0
		var push := ease_out((t - 7.05) / 0.55)
		clash.x = lerpf(base, fp.x - 30, push)
		clash.y = beam_y + sin(t * 9.0) * 8.0
		g_head = clash
		p_head = clash
		shake = maxf(shake, 7.0 + push * 14.0)
		for i in 10:
			var a := rng.randf_range(-1.6, 1.6) + (0.0 if i % 2 == 0 else PI)
			emit("spark", clash, Vector2(cos(a), sin(a) - 0.4) * rng.randf_range(300, 1100), rng.randf_range(0.2, 0.6), rng.randf_range(1.5, 4), GOLD_HOT if i % 2 == 0 else PURP_HOT, 1100.0, 1.0)
		emit("add", clash, Vector2(rng.randf_range(-60, 60), rng.randf_range(-60, 60)), 0.35, rng.randf_range(40, 90), Color(1.4, 1.1, 1.3, 0.12))
		if int(t * 30) % 12 == 0:
			add_ring(clash, 260, GOLD_HOT if int(t * 30) % 24 == 0 else PURP_HOT, 8, 0.4)
		if rng.randf() < 0.35:
			emit("rock", Vector2(clash.x + rng.randf_range(-80, 80), GROUND), Vector2(rng.randf_range(-250, 250), -rng.randf_range(300, 700)), 1.4, rng.randf_range(6, 14), Color("#4a4048"), 1400.0)
		if t > 7.0 and t < 7.1:
			flash = maxf(flash, 0.3)
			add_ring(hp, 300, GOLD_HOT, 14, 0.4)
		if int(rt * 30) % 2 == 0:
			bolts.clear()
			for b in 3:
				bolts.append(bolt(clash, clash + Vector2(rng.randf_range(-260, 80), rng.randf_range(-220, 220)), 9))
		if t >= 7.6:
			_boom(fp)

	if boom_done:
		var k := clampf((t - 7.6) / 1.0, 0.0, 1.0)
		var fy := GROUND - sin(k * PI) * 160.0
		foe.pos = Vector2(lerpf(FX, 1520.0, ease_out(k)), fy if k < 1.0 else GROUND)
		foe.rot = ease_out(k) * PI * 0.5
		foe.hurt = 1.0
		foe.crouch = 0.0
		foe.push = 0.0
		if k >= 1.0 and not foe.has("landed"):
			foe.landed = true
			shake = maxf(shake, 16.0)
			for i in 26:
				emit("smoke", Vector2(1520 + rng.randf_range(-60, 260), GROUND), Vector2(rng.randf_range(-160, 220), -rng.randf_range(20, 140)), 2.2, rng.randf_range(40, 90), Color(0.5, 0.45, 0.45, 0.4))
	if g_on and boom_done:
		g_on = false
	if g_on:
		g_trail.push_front(g_head)
		if g_trail.size() > 40:
			g_trail.pop_back()
		if not clash_on:
			for i in 6:
				emit("add", g_head + Vector2(rng.randf_range(-30, 0), rng.randf_range(-50, 50)), Vector2(-rng.randf_range(100, 300), rng.randf_range(-60, 60)), 0.5, rng.randf_range(16, 40), GOLD * Color(1, 1, 1, 0.2))
	if t > 8.3 and rng.randf() < 0.6:
		emit("ember", Vector2(rng.randf_range(700, 1900), GROUND + 20), Vector2(rng.randf_range(-20, 30), -rng.randf_range(40, 120)), rng.randf_range(2.0, 3.5), rng.randf_range(2, 4), GOLD)
	for r in rocks:
		if r.flung:
			r.v.y += 1500.0 * dt
			r.base += r.v * dt
			r.rot += dt * 8.0


func _boom(at: Vector2) -> void:
	boom_done = true
	clash_on = false
	p_on = false
	bolts.clear()
	flash = 1.0
	flash_col = Color(1, 0.95, 0.8)
	shake = 48.0
	var c := at + Vector2(10, -20)
	add_ring(c, 900, GOLD_HOT, 30, 0.9)
	add_ring(c, 620, Color(2, 2, 2), 14, 0.6, 1.0, 0.08)
	add_ring(Vector2(c.x, GROUND), 1100, GOLD, 16, 1.1, 0.2)
	for i in 260:
		var a := rng.randf() * TAU
		emit("spark", c, Vector2(cos(a), sin(a)) * rng.randf_range(300, 2200), rng.randf_range(0.4, 1.2), rng.randf_range(2, 6), GOLD_HOT if i % 3 else Color(3, 3, 3), 900.0, 0.9)
	for i in 24:
		var a := rng.randf() * TAU
		emit("add", c, Vector2(cos(a), sin(a)) * rng.randf_range(80, 600), rng.randf_range(0.5, 1.2), rng.randf_range(60, 160), GOLD * Color(1, 1, 1, 0.22), 0.0, 2.0)
	for i in 40:
		var a := rng.randf() * TAU
		emit("smoke", c, Vector2(cos(a), sin(a) * 0.6) * rng.randf_range(100, 500), rng.randf_range(2.0, 3.5), rng.randf_range(60, 140), Color(0.35, 0.3, 0.32, 0.55), -40.0, 1.6)
	for i in 30:
		emit("rock", c + Vector2(0, 60), Vector2(rng.randf_range(-700, 900), -rng.randf_range(300, 1000)), 2.0, rng.randf_range(8, 20), Color("#3d3438"), 1500.0)


func _cam() -> Array:
	var c := CENTER
	var z := 1.0
	var k1 := smooth(1.2, 3.2, t) * (1.0 - smooth(3.9, 4.15, t))
	c = c.lerp(Vector2(560, 620), k1)
	z = lerpf(z, 1.45, k1)
	var k2 := smooth(6.6, 7.4, t) * (1.0 - smooth(8.6, 9.6, t))
	c = c.lerp(Vector2(1220, 620), k2)
	z = lerpf(z, 1.18, k2)
	var k3 := smooth(9.4, 12.5, t)
	c = c.lerp(Vector2(1060, 580), k3)
	z = lerpf(z, 1.0, k3)
	z += 0.04 * smooth(0.0, 1.2, t) * (1.0 - k1)
	return [c, z]


func _fx_ground(c: Node2D) -> void:
	var glow_at := Vector2(-9999, 0)
	if clash_on:
		glow_at = clash
	elif g_on:
		glow_at = g_head
	if glow_at.x > -999:
		flat_blob(c, Vector2(glow_at.x, GROUND + 20), 520, 0.16, Color(1.0, 0.75, 0.35, 0.5))
	var ck := smooth(1.8, 3.6, t)
	if ck > 0.0:
		var glow := smooth(1.8, 2.5, t) * (1.0 - smooth(5.0, 8.0, t)) * 0.8 + 0.2
		for pts in cracks:
			var n := int(ceil(pts.size() * ck))
			if n >= 2:
				var sub: PackedVector2Array = pts.slice(0, n)
				c.draw_polyline(sub, Color("#0a070c"), 6.0)
				c.draw_polyline(sub, Color(2.2, 1.3, 0.35, glow), 2.5)
	for r in rocks:
		var k := smooth(1.8 + r.delay, 3.0 + r.delay, t)
		if k <= 0.0 and not r.flung:
			continue
		var p: Vector2 = r.base
		if not r.flung:
			p = r.base + Vector2(sin(rt * 20.0 + r.ph) * 2.0, -r.h * k + sin(rt * 2.5 + r.ph) * 8.0 * k)
			r.cur = p
		elif r.has("cur"):
			if not r.has("started"):
				r.started = true
				r.base = r.cur
			p = r.base
		c.draw_set_transform(p, r.rot + rt * 0.6, Vector2.ONE)
		c.draw_colored_polygon(r.poly, Color("#3e3442"))
		c.draw_polyline(r.poly + PackedVector2Array([r.poly[0]]), Color("#1a141e"), 2.5)
		c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _palm_print(c: Node2D, p: Vector2, s: float, col: Color, rot: float) -> void:
	c.draw_set_transform(p, rot, Vector2(s, s))
	c.draw_circle(Vector2(0, 10), 46, col)
	c.draw_rect(Rect2(Vector2(-44, -20), Vector2(88, 50)), col)
	for i in 4:
		var x := -33.0 + i * 22.0
		var ln: float = [62.0, 76.0, 72.0, 56.0][i]
		c.draw_line(Vector2(x, -18), Vector2(x, -18 - ln), col, 18)
		c.draw_circle(Vector2(x, -18 - ln), 9, col)
	c.draw_line(Vector2(-40, 20), Vector2(-78, -20), col, 20)
	c.draw_circle(Vector2(-78, -20), 10, col)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _fx_add(c: Node2D) -> void:
	var hp: Vector2 = hero.hand
	var fp: Vector2 = foe.hand
	if hero.gather > 0.05 and t < 4.05:
		var r: float = 30.0 + 60.0 * hero.aura + sin(rt * 30.0) * 6.0
		blob(c, hp, r * 2.0, GOLD * Color(1, 1, 1, 0.25))
		blob(c, hp, r * 0.6, GOLD_HOT)
	if foe.gather > 0.05 and t < 4.2:
		var r: float = 24.0 + 45.0 * foe.aura + sin(rt * 27.0) * 5.0
		blob(c, fp, r * 2.0, PURP * Color(1, 1, 1, 0.25))
		blob(c, fp, r * 0.6, PURP_HOT)
	if p_on:
		beam(c, fp, p_head, PURP, PURP_HOT, 70.0, 10.0, 18.0, 30.0)
		blob(c, p_head, 110, PURP * Color(1, 1, 1, 0.3))
		blob(c, p_head, 40, PURP_HOT)
		for bl in bolts:
			c.draw_polyline(bl, PURP_HOT, 3.0)
			c.draw_polyline(bl, PURP * Color(1, 1, 1, 0.4), 9.0)
	if g_on:
		var a := hp
		var b := g_head
		var blen := maxf(1.0, a.distance_to(b))
		var thick := 1.0 + smooth(7.0, 7.3, t) * 0.8
		beam(c, a, b, GOLD, GOLD_HOT, 110.0 * thick)
		for side in [1.0, -1.0]:
			var body := PackedVector2Array()
			var n := 46
			for i in n + 1:
				var k := float(i) / n
				var amp := (95.0 + 40.0 * thick) * sin(minf(k * 1.4, 1.0) * PI * 0.5 + 0.2) * (1.0 - k * 0.6)
				body.append(Vector2(lerpf(b.x, a.x, k), lerpf(b.y, a.y, k) + sin(k * blen / 90.0 - rt * 12.0 + (0.0 if side > 0 else PI)) * amp))
			for i in n:
				var k := float(i) / n
				var w := lerpf(26.0, 5.0, k) * thick
				c.draw_line(body[i], body[i + 1], GOLD * Color(1, 1, 1, 0.25), w * 2.0)
				c.draw_line(body[i], body[i + 1], GOLD_HOT, w * 0.7)
				if i % 4 == 2:
					var nrm := (body[i + 1] - body[i]).orthogonal().normalized()
					c.draw_line(body[i], body[i] + nrm * w * 1.6 * side, GOLD, 3.0)
			var hd := body[0]
			var dir := (body[0] - body[3]).normalized()
			blob(c, hd, 45 * thick, GOLD * Color(1, 1, 1, 0.35))
			c.draw_circle(hd + dir * 10 + dir.orthogonal() * 10 * side, 6, Color(4, 1.2, 0.4))
			for wsk in 2:
				var bs := hd + dir * 20
				c.draw_polyline(PackedVector2Array([bs, bs + dir * 40 + dir.orthogonal() * (20 + wsk * 18) * side + Vector2(0, sin(rt * 9.0 + wsk) * 10), bs + dir * 70 + dir.orthogonal() * (50 + wsk * 22) * side]), GOLD_HOT, 3.0)
		var pl := 1.0 + 0.06 * sin(rt * 25.0)
		blob(c, b, 150 * thick * pl, GOLD * Color(1, 1, 1, 0.22))
		_palm_print(c, b, 1.25 * thick * pl, GOLD * Color(1, 1, 1, 0.3), PI * 0.5)
		_palm_print(c, b, 0.95 * thick * pl, GOLD_HOT, PI * 0.5)
		if not clash_on and g_trail.size() > 2:
			for i in range(1, g_trail.size()):
				var k := float(i) / g_trail.size()
				c.draw_line(g_trail[i - 1], g_trail[i], GOLD * Color(1, 1, 1, 0.25 * (1.0 - k)), 50.0 * (1.0 - k))
	if clash_on:
		var r := 150.0 + sin(rt * 33.0) * 20.0
		blob(c, clash, r * 1.1, Color(1.4, 1.1, 1.4, 0.18))
		blob(c, clash, r * 0.3, Color(2.4, 2.2, 2.1))
		for i in 4:
			var a := rt * 0.8 + i * PI * 0.25
			var d := Vector2(cos(a), sin(a)) * (320.0 + 80.0 * sin(rt * 20.0 + i))
			c.draw_line(clash - d, clash + d, Color(1.8, 1.6, 1.5, 0.35), 5.0)
			c.draw_line(clash - d * 0.6, clash + d * 0.6, Color(3, 3, 3, 0.8), 2.0)
	speed_lines(c, hp.x, 1.0, smooth(3.98, 4.05, t) * (1.0 - smooth(4.2, 4.6, t)), Color(1.6, 1.4, 1.0))
