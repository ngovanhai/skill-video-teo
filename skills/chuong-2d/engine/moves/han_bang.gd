extends "res://engine.gd"
# Hàn Băng Miên Chưởng (11.5 s): đêm tuyết, Vi Nhất Tiếu tụ hàn khí (bông tuyết xoay trên tay, băng lan dưới chân)
# -> khinh công lướt tới để lại tàn ảnh, ba chưởng liên hoàn phủ sương lên đối thủ -> lướt về, kết đại băng hoa
# -> đẩy song chưởng: hàng cột băng mọc dọc mặt đất, đóng băng đối thủ -> khối băng vỡ, đối thủ văng.

const ICE := Color(0.55, 1.15, 1.8)
const ICE_HOT := Color(1.5, 1.95, 2.4)
const RED := Color(1.7, 0.45, 0.2)
const HX := 480.0
const HITS := [2.55, 2.9, 3.25]
const WAVE := 5.6
const SHATTER := 7.3

var snow: Array = []
var ghosts: Array = []
var hist: Array = []
var spikes: Array = []
var frozen_at := -1.0
var shattered := false
var hit_i := 0
var spike_x := 0.0
var x_hit := 0.0
var block := PackedVector2Array()


func _setup() -> void:
	sky_cols = [Color("#081020"), Color("#20324c"), Color("#5f7088")]
	moon = Vector2(1480, 200)
	far_col = Color("#3a4a64")
	near_col = Color("#2b3a54")
	mist_col = Color(0.85, 0.9, 1.0, 0.22)
	ground_cols = [Color("#a9b8cc"), Color("#56667e"), Color("#e2eaf4")]
	slowmo = [6.15, 6.75, 0.3]
	title = "HÀN BĂNG MIÊN CHƯỞNG"
	title_at = 8.4
	title_col = Color(1.2, 1.8, 2.3)
	cue(1.0, "lib-riser", 0.6)
	cue(2.0, "lib-whoosh", 0.8)
	cue(3.45, "lib-whoosh", 0.7)
	cue(4.1, "lib-riser", 0.9)
	cue(WAVE, "lib-whoosh-cinematic", 0.9)
	cue(WAVE, "lib-impact-bass-1", 0.9)
	set_char(hero, "vi-nhat-tieu")
	set_char(foe, "hiep-khach")
	hero.pos = Vector2(HX, GROUND)
	foe.pos = Vector2(1430, GROUND)
	hero.col = ICE
	foe.col = RED
	for i in 4:
		var g: Node2D = Chibi.new()
		l_chars.add_child(g)
		l_chars.move_child(g, 0)
		g.setup("vi-nhat-tieu")
		g.visible = false
		ghosts.append(g)
	for i in 170:
		snow.append({"p": Vector2(rng.randf_range(-300, W + 300), rng.randf_range(-100, H)), "s": rng.randf_range(1.5, 4.5), "v": rng.randf_range(40, 110), "ph": rng.randf() * TAU})
	# khối băng quanh đối thủ (toạ độ tương đối chân)
	for q in [[-120, 10], [-140, -120], [-105, -300], [-40, -400], [60, -390], [130, -280], [150, -110], [115, 12]]:
		block.append(Vector2(q[0], q[1]))


func _story(dt: float) -> void:
	# ---- Vi Nhất Tiếu: vị trí theo khinh công
	var d1 := smooth(2.05, 2.45, t)
	var d2 := smooth(3.5, 3.9, t)
	var near_x: float = foe.pos.x - 250.0
	hero.pos.x = lerpf(lerpf(HX, near_x, d1), HX, d2)
	var dashing := pulse(2.0, 2.45, 0.1, t) + pulse(3.45, 3.9, 0.1, t)
	var hitp := 0.0
	for h in HITS:
		hitp = maxf(hitp, pulse(h - 0.08, h + 0.08, 0.18, t))
	hero.gather = smooth(1.0, 1.6, t) * (1.0 - smooth(2.0, 2.1, t))
	hero.push = hitp + smooth(WAVE - 0.1, WAVE + 0.05, t) * (1.0 - smooth(8.0, 9.0, t))
	hero.both = 1.0 if t > 4.0 else (float(hit_i % 2) if t > 2.4 else 1.0)
	var big := smooth(4.1, 4.7, t) * (1.0 - smooth(WAVE - 0.15, WAVE, t))
	hero.extra = [["run", minf(1.0, dashing)], [{"uaF": -130, "faF": -60, "uaB": 130, "faB": 60, "torso": 4, "head": 4}, big]]
	hero.lean = dashing * 0.5 + hitp * 0.3 + hero.push * 0.2
	hero.aura = smooth(1.0, 1.8, t) * 0.5 * (1.0 - smooth(2.0, 2.4, t)) + big * 1.0 + smooth(WAVE, WAVE + 0.2, t) * 0.8 * (1.0 - smooth(6.6, 8.0, t))
	hero.expr = "dac-y" if t > 8.2 else ("quyet-tam" if t > 1.0 else "binh")
	# ---- đối thủ
	var fg: float = smooth(4.3, 5.0, t) * (1.0 - smooth(5.9, 6.1, t))
	if frozen_at < 0.0 and not shattered:
		foe.gather = fg
		foe.aura = fg * 0.8
		foe.extra = [["guard", pulse(2.4, 3.4, 0.4, t)]]
		foe.lean = -pulse(2.5, 3.4, 0.5, t) * 0.4
		foe.expr = "soc" if t > 2.5 and t < 3.8 else "gian"
	var frost := clampf(hit_i / 3.0 * 0.5, 0.0, 0.5) * (1.0 - smooth(3.8, 5.0, t) * 0.6)
	if frozen_at >= 0.0:
		frost = 1.0 - smooth(SHATTER + 0.3, SHATTER + 2.0, t) * 0.6
	foe.tint = Color(1, 1, 1).lerp(Color(0.62, 0.85, 1.25), frost)
	pose(hero, 0.0)
	pose(foe, 0.0)
	var hp: Vector2 = hero.hand

	# tàn ảnh khinh công
	hist.push_front([hero.pos, pose_of(hero), hero.lean])
	if hist.size() > 12:
		hist.pop_back()
	for i in ghosts.size():
		var g: Node2D = ghosts[i]
		var h: Array = hist[mini((i + 1) * 2, hist.size() - 1)]
		var a := minf(1.0, dashing) * (0.5 - i * 0.1)
		g.visible = a > 0.02
		if g.visible:
			g.position = h[0]
			g.scale = Vector2(CS, CS)
			g.apply(h[1], 0.0)
			g.modulate = Color(0.55, 0.85, 1.4, a)
	if dashing > 0.1:
		for i in 3:
			emit("smoke", Vector2(hero.pos.x + rng.randf_range(-40, 40), GROUND), Vector2(rng.randf_range(-80, 80), -rng.randf_range(20, 80)), 1.0, rng.randf_range(20, 40), Color(0.92, 0.96, 1.0, 0.35))

	# hơi lạnh
	if hero.aura > 0.05:
		for i in int(hero.aura * 4):
			emit("add", hero.pos + Vector2(rng.randf_range(-70, 70), -rng.randf_range(0, 260)), Vector2(rng.randf_range(-20, 20), -rng.randf_range(60, 160)), 0.8, rng.randf_range(12, 28), ICE * Color(1, 1, 1, 0.1))
	if hero.gather > 0.05 or big > 0.05:
		for i in 3:
			orbit(hero, rng.randf_range(120, 320), rng.randf_range(2.0, 3.5), rng.randf_range(200, 320), rng.randf_range(2, 5), ICE_HOT, 2.0 if t < 3.0 else WAVE)
	if foe.aura > 0.05:
		for i in int(foe.aura * 4):
			emit("add", foe.pos + Vector2(rng.randf_range(-70, 70), -rng.randf_range(0, 260)), Vector2(0, -rng.randf_range(100, 240)), 0.6, rng.randf_range(14, 30), RED * Color(1, 1, 1, 0.12))
	if int(rt * 30) % 40 == 0:
		emit("smoke", hero.head + Vector2(hero.face * 30, 40), Vector2(hero.face * 40, -10), 1.2, 14, Color(1, 1, 1, 0.25))

	# ba chưởng liên hoàn
	if hit_i < HITS.size() and t >= HITS[hit_i]:
		var at: Vector2 = foe.pos + Vector2(-20, -170 + hit_i * 30 - 30)
		_ice_burst(at, 1.0)
		foe.pos.x += 26.0
		hit_i += 1

	# đại băng hoa -> sóng cột băng
	if t >= WAVE and spike_x == 0.0:
		spike_x = hero.pos.x + 90.0
		flash = 0.4
		flash_col = Color(0.85, 0.95, 1.0)
		shake = 20.0
		add_ring(hp, 420, ICE_HOT, 16, 0.5)
		add_ring(Vector2(hero.pos.x, GROUND), 600, ICE, 10, 0.7, 0.22)
		burst(hp, 60, 400, 1300, ICE_HOT, ICE, 300.0, 1.5, -0.8, 0.8)
	if spike_x > 0.0 and frozen_at < 0.0:
		var step := 1500.0 * dt
		var x0 := spike_x
		spike_x += step
		var x := x0
		while x < spike_x:
			var hgt := rng.randf_range(70, 190) * (0.7 + 0.5 * clampf((x - HX) / 900.0, 0.0, 1.0))
			spikes.append({"x": x + rng.randf_range(-12, 12), "t0": t, "h": hgt, "w": rng.randf_range(22, 40), "lean": rng.randf_range(-0.35, 0.15)})
			emit("smoke", Vector2(x, GROUND), Vector2(rng.randf_range(-40, 80), -rng.randf_range(40, 140)), 0.9, rng.randf_range(20, 40), Color(0.9, 0.96, 1.0, 0.4))
			x += 34.0
		shake = maxf(shake, 9.0)
		for i in 4:
			emit("add", hp.lerp(Vector2(spike_x, hp.y), rng.randf()), Vector2(rng.randf_range(300, 700), rng.randf_range(-60, 60)), 0.4, rng.randf_range(10, 24), ICE * Color(1, 1, 1, 0.25))
		if spike_x >= foe.pos.x - 60:
			_freeze()
	if frozen_at >= 0.0 and not shattered:
		shake = maxf(shake, 2.0)
		if t >= SHATTER:
			_shatter()
	if shattered:
		var k := clampf((t - SHATTER) / 0.9, 0.0, 1.0)
		foe.pos = Vector2(lerpf(x_hit, 1490.0, ease_out(k)), GROUND - sin(k * PI) * 130.0 if k < 1.0 else GROUND)
		foe.rot = ease_out(k) * PI * 0.5
		foe.hurt = 1.0
		foe.extra = []
		if k >= 1.0 and not foe.has("landed"):
			foe.landed = true
			sfx("lib-impact-bass-2", 0.5)
			shake = maxf(shake, 14.0)
			for i in 22:
				emit("smoke", Vector2(1490 + rng.randf_range(-40, 260), GROUND), Vector2(rng.randf_range(-160, 220), -rng.randf_range(20, 140)), 2.2, rng.randf_range(40, 90), Color(0.9, 0.95, 1.0, 0.45))
	# tuyết rơi (gió mạnh lên khi lướt / sóng băng)
	var wind := 30.0 + 500.0 * minf(1.0, dashing) + 300.0 * pulse(WAVE, 6.2, 0.6, t)
	for s in snow:
		s.p += Vector2(wind * (s.s / 4.5) + sin(rt * 1.3 + s.ph) * 20.0, s.v) * dt
		if s.p.y > H + 40:
			s.p.y -= H + 160
		if s.p.x > W + 320:
			s.p.x -= W + 640


func _ice_burst(at: Vector2, s: float) -> void:
	sfx("lib-impact-bass-2", 0.7 * s)
	add_ring(at, 260 * s, ICE_HOT, 10, 0.35)
	add_ring(at, 170 * s, Color(2, 2, 2), 5, 0.25, 1.0, 0.05)
	burst(at, int(40 * s), 300, 1100, ICE_HOT, ICE, 700.0, 1.4, -PI * 0.6, PI * 0.6)
	for i in int(14 * s):
		var a := rng.randf_range(-1.2, 1.2)
		emit("shard", at, Vector2(cos(a), sin(a) - 0.4) * rng.randf_range(300, 800), rng.randf_range(0.6, 1.1), rng.randf_range(8, 18), ICE_HOT, 1400.0)
	shake = maxf(shake, 14.0 * s)
	flash = maxf(flash, 0.15)
	flash_col = Color(0.85, 0.95, 1.0)


func _freeze() -> void:
	sfx("lib-glitch-1", 0.5)
	sfx("lib-impact-bass-1", 0.8)
	frozen_at = t
	foe.frozen = true
	foe.expr = "soc"
	foe.aura = 0.0
	foe.gather = 0.0
	flash = 0.5
	flash_col = Color(0.85, 0.95, 1.0)
	shake = 26.0
	var c: Vector2 = foe.pos + Vector2(0, -190)
	add_ring(c, 520, ICE_HOT, 18, 0.6)
	burst(c, 80, 300, 1200, ICE_HOT, Color(2, 2, 2), 500.0, 1.5)


func _shatter() -> void:
	sfx("lib-impact-bass-1", 1.0)
	sfx("lib-impact-bass-2", 1.0)
	sfx("lib-glitch-1", 0.4)
	shattered = true
	foe.frozen = false
	foe.expr = "ko"
	x_hit = foe.pos.x
	flash = 0.85
	flash_col = Color(0.9, 0.97, 1.0)
	shake = 40.0
	var c: Vector2 = foe.pos + Vector2(0, -190)
	add_ring(c, 800, ICE_HOT, 24, 0.8)
	add_ring(Vector2(c.x, GROUND), 900, ICE, 12, 1.0, 0.2)
	for i in 70:
		var a := rng.randf() * TAU
		emit("shard", c + Vector2(rng.randf_range(-100, 100), rng.randf_range(-160, 160)), Vector2(cos(a), sin(a) - 0.3) * rng.randf_range(300, 1300), rng.randf_range(0.8, 1.6), rng.randf_range(10, 30), ICE_HOT, 1300.0)
	burst(c, 160, 300, 1800, ICE_HOT, Color(2.2, 2.2, 2.2), 900.0, 0.9)
	for sp in spikes:
		if rng.randf() < 0.5:
			emit("shard", Vector2(sp.x, GROUND - sp.h * 0.5), Vector2(rng.randf_range(-300, 500), -rng.randf_range(200, 700)), rng.randf_range(0.6, 1.2), rng.randf_range(8, 20), ICE_HOT, 1400.0)
	spikes.clear()


func _cam() -> Array:
	var c := CENTER
	var z := 1.0
	var k1 := smooth(0.9, 1.6, t) * (1.0 - smooth(1.95, 2.15, t))
	c = c.lerp(Vector2(560, 620), k1)
	z = lerpf(z, 1.4, k1)
	var k2 := smooth(2.1, 2.5, t) * (1.0 - smooth(3.45, 3.8, t))
	c = c.lerp(Vector2(1180, 620), k2)
	z = lerpf(z, 1.3, k2)
	var k3 := smooth(4.0, 4.7, t) * (1.0 - smooth(WAVE, WAVE + 0.4, t))
	c = c.lerp(Vector2(640, 560), k3)
	z = lerpf(z, 1.2, k3)
	var k4 := smooth(6.0, 6.5, t) * (1.0 - smooth(SHATTER + 0.5, 9.5, t))
	c = c.lerp(Vector2(1220, 600), k4)
	z = lerpf(z, 1.2, k4)
	var k5 := smooth(8.6, 11.0, t)
	c = c.lerp(Vector2(1040, 590), k5)
	z = lerpf(z, 1.0, k5)
	return [c, z]


func _flake(c: Node2D, p: Vector2, r: float, rot: float, col: Color, w: float) -> void:
	for i in 6:
		var d := Vector2.from_angle(rot + i * TAU / 6.0)
		c.draw_line(p, p + d * r, col, w)
		for b in [0.45, 0.7]:
			var q: Vector2 = p + d * r * b
			c.draw_line(q, q + d.rotated(0.8) * r * 0.28, col, w * 0.8)
			c.draw_line(q, q + d.rotated(-0.8) * r * 0.28, col, w * 0.8)
	c.draw_circle(p, w * 1.6, col)


func _fx_ground(c: Node2D) -> void:
	# sương băng lan dưới chân
	var fr := smooth(1.0, 2.0, t) * 0.5 + smooth(4.1, 5.5, t) * 0.5
	if fr > 0.0:
		flat_blob(c, Vector2(HX, GROUND + 8), 300 + 300 * fr, 0.12, Color(0.85, 0.97, 1.0, 0.6 * fr))
		for i in 10:
			var a := i * TAU / 10.0 + 0.3
			var ln := (120.0 + 80.0 * sin(i * 2.7)) * fr * 2.0
			var p0 := Vector2(HX, GROUND + 6)
			var p1 := p0 + Vector2(cos(a) * ln, absf(sin(a)) * ln * 0.12)
			c.draw_line(p0, p1, Color(1, 1, 1, 0.7 * fr), 2.5)
	if spike_x > 0.0 and not shattered:
		flat_blob(c, Vector2((HX + spike_x) * 0.5, GROUND + 8), (spike_x - HX) * 0.6 + 100, 0.08, Color(0.8, 0.95, 1.0, 0.5))


func _fx_norm(c: Node2D) -> void:
	# cột băng
	for sp in spikes:
		var k := ease_out((t - sp.t0) / 0.14)
		var h: float = sp.h * k
		var b := Vector2(sp.x, GROUND + 12)
		var tip := b + Vector2(sp.lean * h, -h)
		var w: float = sp.w
		c.draw_colored_polygon(PackedVector2Array([b + Vector2(-w, 0), tip, b + Vector2(0, 4)]), Color(0.55, 0.75, 0.95, 0.85))
		c.draw_colored_polygon(PackedVector2Array([b + Vector2(0, 4), tip, b + Vector2(w, 0)]), Color(0.82, 0.94, 1.0, 0.85))
		c.draw_polyline(PackedVector2Array([b + Vector2(-w, 0), tip, b + Vector2(w, 0)]), Color(1, 1, 1, 0.9), 2.0)
	# khối băng bọc đối thủ
	if frozen_at >= 0.0 and not shattered:
		var k := ease_out((t - frozen_at) / 0.25)
		var o: Vector2 = foe.pos
		var poly := PackedVector2Array()
		for q in block:
			poly.append(o + Vector2(q.x, q.y * k))
		c.draw_colored_polygon(poly, Color(0.7, 0.9, 1.0, 0.38))
		c.draw_polyline(poly + PackedVector2Array([poly[0]]), Color(0.95, 1.0, 1.0, 0.9), 3.0)
		for e in [[0, 4], [2, 6], [1, 5], [3, 7]]:
			c.draw_line(poly[e[0]], poly[e[1]], Color(1, 1, 1, 0.25), 2.0)
		# vết nứt lan dần trước khi vỡ
		var ck := smooth(SHATTER - 0.7, SHATTER, t)
		if ck > 0.0:
			var rr := RandomNumberGenerator.new()
			rr.seed = 77
			for j in 6:
				var p := o + Vector2(0, -200)
				var a := rr.randf() * TAU
				var pts := PackedVector2Array([p])
				for s in 5:
					a += rr.randf_range(-0.6, 0.6)
					p += Vector2.from_angle(a) * 30.0 * ck
					pts.append(p)
				c.draw_polyline(pts, Color(1, 1, 1, 0.9), 2.0)
	# tuyết
	for s in snow:
		c.draw_circle(s.p, s.s, Color(1, 1, 1, 0.75))


func _fx_add(c: Node2D) -> void:
	var hp: Vector2 = hero.hand
	# bông tuyết xoay trên tay lúc tụ khí
	var fk: float = hero.gather + pulse(1.0, 2.0, 0.2, t) * 0.3
	if fk > 0.05:
		for side in ["F", "B"]:
			var p: Vector2 = hero.handF if side == "F" else hero.handB
			blob(c, p, 60 * fk, ICE * Color(1, 1, 1, 0.3))
			_flake(c, p, 38 * fk, rt * 2.5, ICE_HOT, 3.0)
	# đại băng hoa trước ngực
	var big := smooth(4.1, 4.9, t) * (1.0 - smooth(WAVE, WAVE + 0.35, t))
	if big > 0.0:
		var p: Vector2 = hero.pos + Vector2(110, -200)
		var r := 210.0 * ease_out(big) * (1.0 + smooth(WAVE, WAVE + 0.35, t) * 0.8)
		blob(c, p, r * 1.4, ICE * Color(1, 1, 1, 0.25 * big))
		_flake(c, p, r, rt * 0.8, ICE * Color(1, 1, 1, 0.8 * big), 6.0)
		_flake(c, p, r * 0.55, -rt * 1.4, ICE_HOT * Color(1, 1, 1, big), 3.0)
		c.draw_arc(p, r * 1.05, 0, TAU, 72, ICE_HOT * Color(1, 1, 1, 0.6 * big), 3.0)
		c.draw_arc(p, r * 0.75, 0, TAU, 72, ICE * Color(1, 1, 1, 0.5 * big), 2.0)
	# luồng hàn khí theo sóng băng
	if spike_x > 0.0 and frozen_at < 0.0:
		beam(c, hp, Vector2(spike_x, hp.y + 40), ICE, ICE_HOT, 60.0, 10.0)
	if hero.push > 0.5 and t > 2.4 and t < 3.5:
		blob(c, hp, 70, ICE * Color(1, 1, 1, 0.4))
	if foe.aura > 0.05:
		blob(c, foe.hand, 70 * foe.aura, RED * Color(1, 1, 1, 0.3))
	# lóe sáng trên khối băng
	if frozen_at >= 0.0 and not shattered:
		var gl := fmod(t - frozen_at, 1.2) / 1.2
		var o: Vector2 = foe.pos
		c.draw_line(o + Vector2(-90 + gl * 200, -360), o + Vector2(-150 + gl * 200, -20), Color(0.6, 0.85, 1.1, 0.18), 9.0)
	# mảnh băng
	for q in parts:
		if q.k == "shard":
			var a: float = q.life / q.max
			var d := Vector2.from_angle(q.rot * 2.0)
			var s: float = q.size
			c.draw_colored_polygon(PackedVector2Array([q.p + d * s, q.p + d.orthogonal() * s * 0.3, q.p - d * s, q.p - d.orthogonal() * s * 0.3]), ICE_HOT * Color(1, 1, 1, minf(1.0, a * 2.0)))
