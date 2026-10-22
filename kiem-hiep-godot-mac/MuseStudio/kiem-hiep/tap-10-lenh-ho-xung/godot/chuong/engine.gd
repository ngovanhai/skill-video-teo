extends Node2D
# Engine chung cho các cảnh chưởng 2D: nền núi + trời, hạt (add/spark/smoke/rock/ember/orbit), vòng xung kích,
# chớp màn, rung, camera, 2 nhân vật chibi rig2 (chibi.gd). Mỗi chiêu (moves/*.gd) kế thừa và viết _story/_cam/_fx_*.
# Thời gian cộng DT cố định + rng có seed nên render lại ra y hệt.

const Chibi := preload("res://chuong/chibi.gd")

const W := 1920.0
const H := 1080.0
const CENTER := Vector2(960, 540)
const GROUND := 840.0
const DT := 1.0 / 30.0
const CS := 0.74          # tỉ lệ nhân vật chibi

var t := 0.0      # thời gian truyện (chậm lại theo slowmo)
var rt := 0.0     # thời gian thật
var rng := RandomNumberGenerator.new()
var soft: GradientTexture2D
var font: SystemFont

var sky: Node2D
var far: Node2D
var near: Node2D
var world: Node2D
var l_ground: Node2D
var l_back: Node2D
var l_chars: Node2D
var l_norm: Node2D
var l_add: Node2D
var ui: Node2D

var cam_pos := CENTER
var zoom := 1.0
var shake := 0.0
var flash := 0.0
var flash_col := Color(1, 1, 1)

var hero := {}
var foe := {}
var parts: Array = []
var rings: Array = []
var stars: Array = []
var far_pts := PackedVector2Array()
var near_pts := PackedVector2Array()

# ---- tham số cảnh (chiêu đặt trong _setup)
var sky_cols := [Color("#070512"), Color("#1b1440"), Color("#4a2a4e")]
var moon := Vector2(1450, 230)
var moon_on := true
var moon_col := Color(1.25, 1.2, 1.1)     # đổi thành mặt trời: màu nóng + moon_craters = false
var moon_glow := Color(0.9, 0.85, 1.0, 0.25)
var moon_craters := true
var n_stars := 160
var far_col := Color("#2a2050")
var near_col := Color("#1a1530")
var mist_col := Color(0.6, 0.55, 0.8, 0.22)
var ground_cols := [Color("#2b2230"), Color("#120e16"), Color("#4a3d52")]
var slowmo := [-1.0, -1.0, 1.0]     # [rt bắt đầu, rt kết thúc, hệ số]
var title := ""
var subtitle := "thử hiệu ứng chưởng · Godot 2D"
var title_at := 99.0
var title_col := Color(2.2, 1.6, 0.6)


func _ready() -> void:
	rng.seed = 2026
	var gr := Gradient.new()
	gr.set_color(0, Color(1, 1, 1, 1))
	gr.set_color(1, Color(1, 1, 1, 0))
	gr.add_point(0.35, Color(1, 1, 1, 0.55))
	soft = GradientTexture2D.new()
	soft.gradient = gr
	soft.fill = GradientTexture2D.FILL_RADIAL
	soft.fill_from = Vector2(0.5, 0.5)
	soft.fill_to = Vector2(0.5, 0.0)
	soft.width = 128
	soft.height = 128
	font = SystemFont.new()
	font.font_names = PackedStringArray(["Segoe UI Black", "Segoe UI"])
	font.font_weight = 900

	var we := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_CANVAS
	env.glow_enabled = true
	env.glow_intensity = 0.45
	env.glow_strength = 0.9
	env.glow_bloom = 0.0
	env.glow_hdr_threshold = 1.0
	env.glow_blend_mode = Environment.GLOW_BLEND_MODE_SCREEN
	for i in range(1, 7):
		env.set_glow_level(i, 1.0 if i >= 2 and i <= 5 else 0.0)
	we.environment = env
	add_child(we)

	sky = _layer(self, _draw_sky)
	far = _layer(self, _draw_far)
	near = _layer(self, _draw_near)
	world = Node2D.new()
	add_child(world)
	l_ground = _layer(world, _draw_ground)
	l_back = _layer(world, _draw_back, true)
	l_chars = Node2D.new()
	l_chars.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	world.add_child(l_chars)
	l_norm = _layer(world, _draw_norm)
	l_add = _layer(world, _draw_add, true)
	var cl := CanvasLayer.new()
	cl.layer = 5
	add_child(cl)
	ui = _layer(cl, _draw_ui)

	hero = fighter("tieu-phong", Vector2(470, GROUND), 1.0, Color(1.5, 0.95, 0.25))
	foe = fighter("lao-ma", Vector2(1450, GROUND), -1.0, Color(0.85, 0.2, 1.45))
	_setup()
	for i in n_stars:
		stars.append([Vector2(rng.randf() * W * 1.3 - W * 0.15, rng.randf() * 560), rng.randf_range(0.6, 2.2), rng.randf() * TAU])
	far_pts = _ridge(rng, 520.0, 140.0, 26)
	near_pts = _ridge(rng, 680.0, 120.0, 18)
	_pose_all(0.0)


# ---------------------------------------------------------------- móc cho từng chiêu

func _setup() -> void:
	pass


func _story(_dt: float) -> void:
	pass


func _cam() -> Array:
	return [CENTER, 1.0]


func _fx_ground(_c: Node2D) -> void:
	pass


func _fx_back(_c: Node2D) -> void:
	pass


func _fx_norm(_c: Node2D) -> void:
	pass


func _fx_add(_c: Node2D) -> void:
	pass


func _fx_ui(_c: Node2D) -> void:
	pass


# ---------------------------------------------------------------- nhân vật

# f.extra: [[tên tư thế hoặc dict, trọng số], ...] trộn sau charge/palm; f.both: 0 = tay F, 1 = giữa hai tay
func fighter(id: String, pos: Vector2, face: float, aura_col: Color) -> Dictionary:
	var f := {"id": id, "pos": pos, "face": face, "rot": 0.0, "scale": 1.0, "gather": 0.0, "push": 0.0, "crouch": 0.0,
		"lean": 0.0, "aura": 0.0, "hurt": 0.0, "extra": [], "both": 0.0, "expr": "binh", "col": aura_col,
		"tint": Color(1, 1, 1), "base": "stance", "hand": pos, "handF": pos, "handB": pos, "head": pos}
	var n: Node2D = Chibi.new()
	l_chars.add_child(n)
	n.setup(id)
	f.node = n
	return f


func set_char(f: Dictionary, id: String) -> void:
	f.node.queue_free()
	var n: Node2D = Chibi.new()
	l_chars.add_child(n)
	n.setup(id)
	f.node = n
	f.id = id


func pose_of(f: Dictionary) -> Dictionary:
	var p := Chibi.P(f.base)
	p = Chibi.mix(p, Chibi.POSES.charge, f.gather)
	p = Chibi.mix(p, Chibi.POSES.palm, f.push)
	for e in f.extra:
		var d: Dictionary = e[0] if e[0] is Dictionary else Chibi.POSES[e[0]]
		p = Chibi.mix(p, d, e[1])
	if f.hurt > 0.0:
		p = Chibi.mix(p, Chibi.POSES.fly, f.hurt)
	var a: Array = p.get("all", [0, 0, 0])
	p["all"] = [a[0], a[1], a[2] + f.crouch * 40.0]
	p["torso"] = p.get("torso", 0.0) + f.lean * 22.0
	p["head"] = p.get("head", 0.0) - f.lean * 6.0
	return p


func pose(f: Dictionary, dt: float) -> void:
	var n: Node2D = f.node
	n.position = f.pos
	n.rotation = f.rot
	n.scale = Vector2(f.face, 1.0) * CS * f.scale
	var frozen: bool = f.get("frozen", false)
	n.sway = 0.0 if frozen else 1.0 + f.aura * 1.5
	n.apply(pose_of(f), 0.0 if frozen else dt)
	n.set_expr(f.expr)
	n.modulate = f.tint
	f.handF = n.hand(world, "F")
	f.handB = n.hand(world, "B")
	f.hand = f.handF.lerp(f.handB, f.both * 0.5) + Vector2(f.face * 12.0 * CS, 0)
	f.head = n.head_pos(world)


func _pose_all(dt: float) -> void:
	pose(foe, dt)
	pose(hero, dt)


# ---------------------------------------------------------------- vòng lặp

func _layer(parent: Node, cb: Callable, additive := false) -> Node2D:
	var n := Node2D.new()
	if additive:
		var m := CanvasItemMaterial.new()
		m.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		n.material = m
	parent.add_child(n)
	n.draw.connect(cb.bind(n))
	return n


func _ridge(r: RandomNumberGenerator, base: float, amp: float, n: int) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var h1 := r.randf()
	for i in n + 1:
		var x := lerpf(-500.0, W + 500.0, float(i) / n)
		h1 = clampf(h1 + r.randf_range(-0.55, 0.55), 0.0, 1.0)
		pts.append(Vector2(x, base - h1 * amp - (amp * 0.5 if i % 3 == 0 else 0.0)))
	return pts


# ---- SFX: ghi mốc (giây thật) ra work/<move>.sfx cho mix.sh
var sfx_log: PackedStringArray = []
var cues: Array = []
var sfx_hook := Callable()     # chạy nhúng trong tập (teo-kiem-hiep-godot chieu.gd): nhận (tên, rt, vol), không ghi file


func sfx(n: String, v := 1.0) -> void:
	if sfx_hook.is_valid():
		sfx_hook.call(n, rt, v)
		return
	sfx_log.append("%s %.3f %.2f" % [n, rt, v])
	var mv := "hang_long"
	var a := OS.get_cmdline_user_args()
	var i := a.find("--move")
	if i >= 0 and i + 1 < a.size():
		mv = a[i + 1]
	var f := FileAccess.open("res://work/%s.sfx" % mv, FileAccess.WRITE)
	f.store_string(String.chr(10).join(sfx_log) + String.chr(10))


# mốc theo thời gian truyện
func cue(at: float, n: String, v := 1.0) -> void:
	cues.append([at, n, v])


func _run_cues() -> void:
	for c in cues:
		if c[0] >= 0.0 and t >= c[0]:
			sfx(c[1], c[2])
			c[0] = -1.0


func ease_out(x: float) -> float:
	x = clampf(x, 0.0, 1.0)
	return 1.0 - pow(1.0 - x, 3.0)


func smooth(a: float, b: float, x: float) -> float:
	return smoothstep(a, b, x)


# xung: lên nhanh ở a, giữ tới b, tắt dần trong d giây
func pulse(a: float, b: float, d: float, x: float) -> float:
	return smooth(a, a + 0.12, x) * (1.0 - smooth(b, b + d, x))


func _process(_d: float) -> void:
	var ts := 1.0
	if rt > slowmo[0] and rt < slowmo[1]:
		ts = slowmo[2]
	var dt := DT * ts
	t += dt
	rt += DT
	_pose_all(0.0)
	_story(dt)
	_run_cues()
	_pose_all(dt)
	_update_parts(dt)
	_camera()
	for n in [sky, far, near, l_ground, l_back, l_norm, l_add, ui]:
		n.queue_redraw()


func emit(k: String, p: Vector2, v: Vector2, life: float, size: float, col: Color, grav := 0.0, drag := 0.0) -> Dictionary:
	var q := {"k": k, "p": p, "v": v, "life": life, "max": life, "size": size, "col": col, "g": grav, "drag": drag, "rot": rng.randf() * TAU}
	parts.append(q)
	return q


# hạt xoáy hút vào tay của f (k = "orbit")
func orbit(f: Dictionary, r: float, w: float, rs: float, size: float, col: Color, until: float) -> void:
	parts.append({"k": "orbit", "who": f, "a": rng.randf() * TAU, "r": r, "w": w, "rs": rs, "life": 3.0, "max": 3.0,
		"size": size, "col": col, "p": f.hand, "until": until})


func add_ring(p: Vector2, r: float, col: Color, w: float, dur: float, sy := 1.0, delay := 0.0) -> void:
	rings.append({"p": p, "r": r, "col": col, "w": w, "dur": dur, "t0": t + delay, "sy": sy})


func burst(p: Vector2, n: int, vmin: float, vmax: float, col: Color, col2: Color, grav := 900.0, drag := 1.2, a0 := 0.0, a1 := TAU) -> void:
	for i in n:
		var a := rng.randf_range(a0, a1)
		emit("spark", p, Vector2(cos(a), sin(a)) * rng.randf_range(vmin, vmax), rng.randf_range(0.3, 0.8), rng.randf_range(2, 5), col if i % 2 == 0 else col2, grav, drag)


func _update_parts(dt: float) -> void:
	var keep: Array = []
	for q in parts:
		q.life -= dt
		if q.k == "orbit":
			var who: Dictionary = q.who
			q.r -= q.rs * dt
			q.rs += 300.0 * dt
			q.a += q.w * dt
			q.p = who.hand + Vector2(cos(q.a), sin(q.a)) * q.r
			if q.r < 10.0 or t > q.until:
				continue
		else:
			q.v.y += q.g * dt
			if q.drag > 0.0:
				q.v *= maxf(0.0, 1.0 - q.drag * dt)
			q.p += q.v * dt
			q.rot += dt * 3.0
			if q.k == "smoke":
				q.size += 40.0 * dt
			if (q.k == "rock" or q.k == "shard") and q.p.y > GROUND + 20 and q.v.y > 0:
				q.v.y *= -0.3
				q.v.x *= 0.6
		if q.life > 0.0:
			keep.append(q)
	parts = keep
	var kr: Array = []
	for r in rings:
		if t - r.t0 < r.dur:
			kr.append(r)
	rings = kr
	shake *= pow(0.02, DT)
	flash *= pow(0.004, DT)


func _camera() -> void:
	var cz := _cam()
	var c: Vector2 = cz[0]
	var z: float = cz[1]
	cam_pos = c
	zoom = z
	var sh := Vector2(sin(rt * 61.0) + sin(rt * 37.0) * 0.6, cos(rt * 53.0) + sin(rt * 29.0) * 0.6) * shake * 0.6
	world.transform = Transform2D(0.0, Vector2(z, z), 0.0, CENTER - c * z + sh)
	for pair in [[far, 0.2], [near, 0.5]]:
		var f: float = pair[1]
		var zf := 1.0 + (z - 1.0) * f
		var cf := CENTER + (c - CENTER) * f
		pair[0].transform = Transform2D(0.0, Vector2(zf, zf), 0.0, CENTER - cf * zf + sh * f)


# ---------------------------------------------------------------- vẽ

func blob(c: Node2D, p: Vector2, r: float, col: Color) -> void:
	c.draw_texture_rect(soft, Rect2(p - Vector2(r, r), Vector2(r * 2, r * 2)), false, col)


# đốm mềm dẹt (bóng sáng hắt xuống đất, sương)
func flat_blob(c: Node2D, p: Vector2, r: float, sy: float, col: Color) -> void:
	c.draw_set_transform(p, 0.0, Vector2(1.0, sy))
	c.draw_texture_rect(soft, Rect2(Vector2(-r, -r), Vector2(r * 2, r * 2)), false, col)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


# chùm tia 3 lớp gợn sóng từ a tới b
func beam(c: Node2D, a: Vector2, b: Vector2, col: Color, hot: Color, width: float, wob := 8.0, freq := 14.0, speed := 26.0) -> void:
	var segs := 28
	var nrm := (b - a).orthogonal().normalized()
	for layer in 3:
		var w: float = [1.0, 0.48, 0.16][layer] * width
		var cl: Color = [col * Color(1, 1, 1, 0.15), col * Color(1, 1, 1, 0.8), hot][layer]
		var pts := PackedVector2Array()
		for i in segs + 1:
			var k := float(i) / segs
			pts.append(a.lerp(b, k) + nrm * sin(k * freq - rt * speed) * (wob - layer * wob * 0.25) * sin(k * PI))
		c.draw_polyline(pts, cl, w * (0.9 + 0.1 * sin(rt * 37.0)))


func bolt(a: Vector2, b: Vector2, n: int, amp := 28.0) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var nrm := (b - a).orthogonal().normalized()
	for i in n + 1:
		var k := float(i) / n
		var off := 0.0 if i == 0 or i == n else rng.randf_range(-amp, amp)
		pts.append(a.lerp(b, k) + nrm * off)
	return pts


func speed_lines(c: Node2D, x0: float, dir: float, k: float, col: Color) -> void:
	if k <= 0.0:
		return
	var rr := RandomNumberGenerator.new()
	rr.seed = int(rt * 30)
	for i in 26:
		var y := rr.randf_range(380, 860)
		var x := x0 + dir * rr.randf_range(0, 1100)
		c.draw_line(Vector2(x, y), Vector2(x + dir * rr.randf_range(150, 400), y), col * Color(1, 1, 1, 0.4 * k), rr.randf_range(2, 5))


func _draw_sky(c: Node2D) -> void:
	var top: Color = sky_cols[0]
	var mid: Color = sky_cols[1]
	var bot: Color = sky_cols[2]
	c.draw_polygon(PackedVector2Array([Vector2(0, 0), Vector2(W, 0), Vector2(W, 560), Vector2(0, 560)]), PackedColorArray([top, top, mid, mid]))
	c.draw_polygon(PackedVector2Array([Vector2(0, 560), Vector2(W, 560), Vector2(W, H), Vector2(0, H)]), PackedColorArray([mid, mid, bot, bot]))
	for s in stars:
		var tw: float = 0.55 + 0.45 * sin(rt * 2.0 + s[2])
		c.draw_circle(s[0], s[1], Color(1, 1, 1, tw * 0.8))
	if moon_on:
		c.draw_texture_rect(soft, Rect2(moon - Vector2(260, 260), Vector2(520, 520)), false, moon_glow)
		c.draw_circle(moon, 92, moon_col)
		if moon_craters:
			c.draw_circle(moon + Vector2(-26, -14), 16, Color(1.05, 1.0, 0.95))
			c.draw_circle(moon + Vector2(30, 26), 11, Color(1.05, 1.0, 0.95))
	for i in 4:
		var x := fmod(i * 620.0 + rt * 22.0, W + 800.0) - 400.0
		c.draw_set_transform(Vector2(x, 210 + i * 70), 0.0, Vector2(1.0, 0.22))
		c.draw_texture_rect(soft, Rect2(Vector2(-320, -320), Vector2(640, 640)), false, Color(mist_col.r, mist_col.g * 0.85, mist_col.b, 0.35))
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_far(c: Node2D) -> void:
	var pts := far_pts.duplicate()
	pts.append(Vector2(W + 500, H + 200))
	pts.append(Vector2(-500, H + 200))
	c.draw_colored_polygon(pts, far_col)


func _draw_near(c: Node2D) -> void:
	var pts := near_pts.duplicate()
	pts.append(Vector2(W + 500, H + 200))
	pts.append(Vector2(-500, H + 200))
	c.draw_colored_polygon(pts, near_col)
	for i in 5:
		var x := fmod(i * 520.0 - rt * 35.0, W + 1000.0) - 300.0
		c.draw_set_transform(Vector2(x, 700 + (i % 2) * 40), 0.0, Vector2(1.6, 0.18))
		c.draw_texture_rect(soft, Rect2(Vector2(-300, -300), Vector2(600, 600)), false, mist_col)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _draw_ground(c: Node2D) -> void:
	var g1: Color = ground_cols[0]
	var g2: Color = ground_cols[1]
	c.draw_polygon(PackedVector2Array([Vector2(-600, GROUND), Vector2(W + 600, GROUND), Vector2(W + 600, H + 400), Vector2(-600, H + 400)]),
		PackedColorArray([g1, g1, g2, g2]))
	c.draw_line(Vector2(-600, GROUND), Vector2(W + 600, GROUND), ground_cols[2], 3)
	for f in [hero, foe]:
		if f.aura > 0.05:
			var col: Color = f.col
			flat_blob(c, Vector2(f.pos.x, GROUND + 10), 400, 0.16, Color(col.r, col.g, col.b, 0.3 * minf(1.0, f.aura)))
	_fx_ground(c)


func _draw_back(c: Node2D) -> void:
	# quầng khí + lưỡi lửa sau lưng
	for f in [hero, foe]:
		if f.aura > 0.02:
			var col: Color = f.col
			var a := minf(1.0, f.aura)
			var p: Vector2 = f.pos + Vector2(0, -170 * f.scale)
			var r: float = (170.0 + 90.0 * f.aura + sin(rt * 14.0) * 10.0) * f.scale
			c.draw_texture_rect(soft, Rect2(p - Vector2(r, r * 1.3), Vector2(r * 2, r * 2.6)), false, col * Color(1, 1, 1, 0.1 * a))
			for i in 9:
				var x: float = (-80.0 + i * 20.0) * f.scale
				var hgt: float = ((120.0 + 110.0 * sin(rt * 11.0 + i * 1.7)) * f.aura + 60.0 * f.aura) * f.scale
				var base: Vector2 = f.pos + Vector2(x, -10)
				var tip := base + Vector2(sin(rt * 7.0 + i) * 20.0, -hgt - 180.0 * f.aura * f.scale)
				c.draw_colored_polygon(PackedVector2Array([base + Vector2(-26, 0), tip, base + Vector2(26, 0)]), col * Color(1, 1, 1, 0.07 * a))
	_fx_back(c)


func _draw_norm(c: Node2D) -> void:
	for q in parts:
		var a: float = q.life / q.max
		if q.k == "smoke":
			var col: Color = q.col
			col.a *= a
			blob(c, q.p, q.size, col)
		elif q.k == "rock":
			c.draw_set_transform(q.p, q.rot * 3.0, Vector2.ONE)
			var s: float = q.size
			c.draw_colored_polygon(PackedVector2Array([Vector2(-s, -s * 0.4), Vector2(-s * 0.2, -s), Vector2(s, -s * 0.3), Vector2(s * 0.6, s * 0.8), Vector2(-s * 0.7, s * 0.6)]), q.col)
			c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	_fx_norm(c)


func _draw_add(c: Node2D) -> void:
	_fx_add(c)
	for rg in rings:
		if t < rg.t0:
			continue
		var k: float = clampf((t - rg.t0) / rg.dur, 0.0, 1.0)
		var rr: float = rg.r * ease_out(k)
		var col: Color = rg.col
		col.a = (1.0 - k)
		c.draw_set_transform(rg.p, 0.0, Vector2(1.0, rg.sy))
		c.draw_arc(Vector2.ZERO, maxf(1.0, rr), 0, TAU, 64, col, rg.w * (1.0 - k * 0.7) / maxf(0.2, rg.sy))
		c.draw_arc(Vector2.ZERO, maxf(1.0, rr * 0.85), 0, TAU, 64, col * Color(1, 1, 1, 0.3), rg.w * 2.5 * (1.0 - k))
		c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	for q in parts:
		var a: float = q.life / q.max
		var col: Color = q.col
		match q.k:
			"add":
				col.a *= a
				blob(c, q.p, q.size * (0.6 + 0.4 * a), col)
			"orbit":
				var tail: Vector2 = q.p - Vector2(cos(q.a + PI * 0.5), sin(q.a + PI * 0.5)) * q.w * 6.0
				c.draw_line(q.p, tail, col, q.size * 0.6)
				blob(c, q.p, q.size * 1.6, col * Color(1, 1, 1, 0.25))
			"spark":
				col.a *= minf(1.0, a * 1.6)
				var v: Vector2 = q.v
				c.draw_line(q.p, q.p - v * 0.035, col, q.size)
			"ember":
				col.a *= sin(a * PI)
				blob(c, q.p + Vector2(sin(rt * 3.0 + q.rot) * 12.0, 0), q.size * 3.0, col)


func _draw_ui(c: Node2D) -> void:
	_fx_ui(c)
	if flash > 0.01:
		var col := flash_col
		col.a = clampf(flash, 0.0, 1.0)
		c.draw_rect(Rect2(0, 0, W, H), col)
	var k := smooth(title_at, title_at + 0.8, rt)
	if k > 0.0 and title != "":
		var size := 96
		var sw := font.get_string_size(title, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
		var y := 930.0 + (1.0 - ease_out((rt - title_at) / 0.8)) * 40.0
		var p := Vector2((W - sw) * 0.5, y)
		c.draw_string_outline(font, p, title, HORIZONTAL_ALIGNMENT_LEFT, -1, size, 18, Color(0.04, 0.02, 0.03, 0.85 * k))
		c.draw_string(font, p, title, HORIZONTAL_ALIGNMENT_LEFT, -1, size, title_col * Color(1, 1, 1, k))
		var ss := font.get_string_size(subtitle, HORIZONTAL_ALIGNMENT_LEFT, -1, 34).x
		var k2 := smooth(title_at + 0.6, title_at + 1.3, rt)
		c.draw_string_outline(font, Vector2((W - ss) * 0.5, y + 62), subtitle, HORIZONTAL_ALIGNMENT_LEFT, -1, 34, 8, Color(0, 0, 0, 0.8 * k2))
		c.draw_string(font, Vector2((W - ss) * 0.5, y + 62), subtitle, HORIZONTAL_ALIGNMENT_LEFT, -1, 34, Color(1, 0.95, 0.9, k2))


# vị trí một khớp chibi của f (toạ độ world), local = điểm trong hệ khớp
func joint_pos(f: Dictionary, name: String, local := Vector2.ZERO) -> Vector2:
	var j: Node2D = f.node.J[name]
	return world.get_global_transform().affine_inverse() * (j.get_global_transform() * local)


# lưỡi khí hình thoi dài: mũi ở p, hướng dir
func blade(c: Node2D, p: Vector2, dir: Vector2, ln: float, w: float, col: Color, hot: Color) -> void:
	var n := dir.orthogonal()
	var tail := p - dir * ln
	var mid := p - dir * ln * 0.22
	c.draw_colored_polygon(PackedVector2Array([p + dir * 10, mid + n * w * 2.2, tail, mid - n * w * 2.2]), col * Color(1, 1, 1, 0.25))
	c.draw_colored_polygon(PackedVector2Array([p, mid + n * w, tail, mid - n * w]), col)
	c.draw_colored_polygon(PackedVector2Array([p, mid + n * w * 0.4, p - dir * ln * 0.8, mid - n * w * 0.4]), hot)


# trăng lưỡi liềm (đao khí) tâm p, mở về phía +x của rot; a0..a1 là đoạn cung (cắt đôi thì vẽ nửa)
func crescent(c: Node2D, p: Vector2, r: float, a0: float, a1: float, rot: float, col: Color, hot: Color) -> void:
	var outer := PackedVector2Array()
	var inner := PackedVector2Array()
	var n := 18
	for i in n + 1:
		var a := lerpf(a0, a1, float(i) / n)
		var th := sin(clampf((a + 1.2) / 2.4, 0.0, 1.0) * PI)   # cung đầy đủ là -1.2..1.2
		outer.append(p + Vector2(cos(a), sin(a)).rotated(rot) * r)
		inner.append(p + Vector2(cos(a), sin(a)).rotated(rot) * (r * (1.0 - 0.32 * th)) + Vector2(-r * 0.12 * th, 0).rotated(rot))
	var poly := outer.duplicate()
	inner.reverse()
	poly.append_array(inner)
	c.draw_colored_polygon(poly, col)
	c.draw_polyline(outer, hot, 4.0)
