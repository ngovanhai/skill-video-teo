extends Node2D
# Bộ cảnh hợp nhân vật chibi: nét viền mực, màu phẳng 2–3 tông (cel), hình tròn trịa, đạo cụ "dễ thương".
# Mỗi cảnh = canh/<id>.gd kế thừa file này: điền bảng màu + _build() (hình tĩnh) + _story() (diễn) + các móc vẽ theo lớp.
# Mọi chuyển động phụ đọc chung gió wind(x) và thời gian t → cây, trúc, cỏ, đèn, cờ, hạt cùng lay một nhịp.
# Chạy tất định: DT cố định, rng seed 2026; t bắt đầu ở -PREWARM để hạt đã phủ kín màn hình ở khung đầu.

const Chibi := preload("res://chibi.gd")
const W := 1920.0
const H := 1080.0
const CENTER := Vector2(960, 540)
const DT := 1.0 / 30.0
const CS := 0.74
const PREWARM := 6.0

var t := -PREWARM
var rng := RandomNumberGenerator.new()
var soft: GradientTexture2D
var vign: GradientTexture2D
var font: SystemFont

# ---- bảng màu (cảnh đè trong _palette)
var sky_top := Color("#8fd3e8")
var sky_bot := Color("#fdf1cf")
var haze := Color("#cfe9e0")          # màu không khí: lớp xa ngả về màu này
var ink := Color("#2b1d2e")           # mực viền chung (pha vào viền mọi vật)
var char_tint := Color(1, 1, 1)       # ánh sáng cảnh hắt lên nhân vật
var vign_a := 0.35
var ground_y := 860.0
var wind_base := 0.3                  # gió nền (dương = thổi sang phải)
var wind_gust := 0.6                  # độ mạnh cơn gió giật
var caption := ""

# ---- camera + lớp
var cam := CENTER
var zoom := 1.0
var layers: Array = []                # [node, hệ số parallax]
var world: Node2D
var l_chars: Node2D
var actors: Array = []
var parts: Array = []
var acc := {}


func _ready() -> void:
	rng.seed = 2026
	soft = _radial([[0.0, Color(1, 1, 1, 1)], [0.35, Color(1, 1, 1, 0.55)], [1.0, Color(1, 1, 1, 0)]])
	vign = _radial([[0.0, Color(0, 0, 0, 0)], [0.6, Color(0, 0, 0, 0)], [1.0, Color(0, 0, 0, 1)]])
	font = SystemFont.new()
	font.font_names = PackedStringArray(["Segoe UI Black", "Segoe UI"])
	font.font_weight = 900
	_palette()

	var we := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_CANVAS
	env.glow_enabled = true
	env.glow_intensity = 0.5
	env.glow_strength = 0.9
	env.glow_hdr_threshold = 1.0
	env.glow_blend_mode = Environment.GLOW_BLEND_MODE_SCREEN
	for i in range(1, 7):
		env.set_glow_level(i, 1.0 if i >= 2 and i <= 5 else 0.0)
	we.environment = env
	add_child(we)

	_lay(_d_sky, 0.02)
	_lay(_d_far, 0.15)
	_lay(_d_mid, 0.4)
	_lay(_d_back, 0.7)
	world = Node2D.new()
	add_child(world)
	layers.append([world, 1.0])
	_on(world, _d_ground)
	_on(world, _d_shadow)
	_on(world, _d_air_back)
	l_chars = Node2D.new()
	l_chars.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR_WITH_MIPMAPS
	world.add_child(l_chars)
	_on(world, _d_near)
	_on(world, _d_air_front)
	_on(world, _d_glow, true)
	_lay(_d_front, 1.3)
	var cl := CanvasLayer.new()
	cl.layer = 5
	add_child(cl)
	_on(cl, _d_screen)

	_build()
	while t < 0.0:               # chạy trước cho hạt phủ màn hình
		_step()
	t = 0.0
	_step_actors(0.0)


func _radial(stops: Array) -> GradientTexture2D:
	var gr := Gradient.new()
	gr.offsets = PackedFloat32Array(stops.map(func(s): return s[0]))
	gr.colors = PackedColorArray(stops.map(func(s): return s[1]))
	var tx := GradientTexture2D.new()
	tx.gradient = gr
	tx.fill = GradientTexture2D.FILL_RADIAL
	tx.fill_from = Vector2(0.5, 0.5)
	tx.fill_to = Vector2(0.5, 0.0)
	tx.width = 256
	tx.height = 256
	return tx


func _on(parent: Node, cb: Callable, additive := false) -> Node2D:
	var n := Node2D.new()
	if additive:
		var m := CanvasItemMaterial.new()
		m.blend_mode = CanvasItemMaterial.BLEND_MODE_ADD
		n.material = m
	parent.add_child(n)
	n.draw.connect(cb.bind(n))
	return n


func _lay(cb: Callable, f: float) -> void:
	var n := _on(self, cb)
	layers.append([n, f])


# ---------------------------------------------------------------- móc cho từng cảnh

func _palette() -> void:
	pass


func _build() -> void:
	pass


func _story(_dt: float) -> void:
	pass


func _cam() -> Array:
	return [CENTER + Vector2(sin(t * 0.18) * 30.0, 0), 1.03]


func _sky(_c: Node2D) -> void:
	pass


func _far(_c: Node2D) -> void:
	pass


func _mid(_c: Node2D) -> void:
	pass


func _back(_c: Node2D) -> void:
	pass


func _ground(_c: Node2D) -> void:
	pass


func _near(_c: Node2D) -> void:     # trước nhân vật, cùng lớp thế giới (cỏ cao, rào)
	pass


func _glow(_c: Node2D) -> void:     # blend cộng: quầng đèn, nắng, đom đóm
	pass


func _front(_c: Node2D) -> void:    # tiền cảnh sát ống kính (parallax 1.3)
	pass


# ---------------------------------------------------------------- vòng lặp

func _process(_d: float) -> void:
	_step()
	_step_actors(DT)
	var cz := _cam()
	cam = cz[0]
	zoom = cz[1]
	for L in layers:
		var f: float = L[1]
		var zf := 1.0 + (zoom - 1.0) * f
		var cf := CENTER + (cam - CENTER) * f
		L[0].transform = Transform2D(0.0, Vector2(zf, zf), 0.0, CENTER - cf * zf)
	_redraw(self)


func _redraw(n: Node) -> void:
	for ch in n.get_children():
		if ch is Node2D and ch != l_chars:
			ch.queue_redraw()
			if ch == world:
				_redraw(ch)
		elif ch is CanvasLayer:
			_redraw(ch)


func _step() -> void:
	t += DT
	_story(DT)
	_update_parts(DT)


# gió tại hoành độ x: nền + sóng chậm + cơn giật ~ mỗi 5 s (lan từ trái sang phải)
func wind(x := 960.0) -> float:
	var g := pow(maxf(0.0, sin(t * 1.25 - x * 0.0015)), 6.0) * wind_gust
	return wind_base + sin(t * 0.9 + x * 0.003) * 0.25 + sin(t * 2.3 + x * 0.011) * 0.08 + g


func smooth(a: float, b: float, x: float) -> float:
	return smoothstep(a, b, x)


# ---------------------------------------------------------------- nhân vật

func actor(id: String, pos: Vector2, face := 1.0) -> Dictionary:
	var n: Node2D = Chibi.new()
	l_chars.add_child(n)
	n.setup(id)
	var a := {"node": n, "pos": pos, "face": face, "base": "rest", "go": Vector2.INF, "speed": 220.0, "ph": 0.0,
		"walk": 0.0, "talk": 0.0, "expr": "binh", "extra": [], "sway": 1.0, "breath": -1.0, "hold": {}}
	actors.append(a)
	return a


# Chu kỳ đi 4 nhịp × 2 bước: chạm gót → nhún (đỡ lực) → lướt qua (chân sau co cao) → nhấc (đẩy mũi chân, người lên cao nhất).
# 8 khoá Catmull-Rom vòng; tay đánh ngược chân, trễ nửa nhịp. ph: 2π = 2 bước. STRIDE: px/rad để bàn chân không trượt.
const STRIDE := 17.0
const WALK_KEYS := [
	# thF, shF, ftF, thB, shB, ftB, uaF, uaB, faF, faB, torso, head, bob
	[-28, 4, -12, 22, 18, 24, 22, -22, -12, -32, 4, 1, 4],       # chạm gót (F trước)
	[-18, 16, 0, 16, 42, 30, 26, -26, -12, -36, 7, -1, 11],      # nhún
	[-2, 6, 0, -12, 62, 12, 4, -4, -20, -24, 5, 1, 4],           # lướt qua
	[14, 4, 12, -26, 30, -6, -14, 14, -30, -16, 4, 2, -3],       # nhấc
]
const WALK_JN := ["thF", "shF", "ftF", "thB", "shB", "ftB", "uaF", "uaB", "faF", "faB", "torso", "head"]


func _walk_key(i: int) -> Array:
	var k: Array = WALK_KEYS[i % 4]
	if i % 8 < 4:
		return k
	# bước sau: đổi vai F ↔ B
	return [k[3], k[4], k[5], k[0], k[1], k[2], k[7], k[6], k[9], k[8], k[10], k[11], k[12]]


func _walk_pose(ph: float, gait := "v2") -> Dictionary:
	if gait != "v2":
		return _walk_pose_v1(ph)
	var u := fposmod(ph / TAU * 8.0, 8.0)
	var i := int(u)
	var f := u - i
	var p0 := _walk_key(i + 7)
	var p1 := _walk_key(i)
	var p2 := _walk_key(i + 1)
	var p3 := _walk_key(i + 2)
	var v := []
	for j in 13:
		var a: float = p0[j]
		var b: float = p1[j]
		var c: float = p2[j]
		var d: float = p3[j]
		v.append(0.5 * (2.0 * b + (c - a) * f + (2.0 * a - 5.0 * b + 4.0 * c - d) * f * f + (3.0 * b - a - 3.0 * c + d) * f * f * f))
	var o := {"all": [0, 0, v[12]]}
	for j in 12:
		o[WALK_JN[j]] = v[j]
	return o


func _walk_pose_v1(ph: float) -> Dictionary:
	var s := sin(ph)
	return {"thF": -s * 26.0, "shF": s * 18.0 + 6.0, "thB": s * 26.0, "shB": -s * 18.0 + 6.0,
		"uaF": s * 24.0, "faF": -25.0, "uaB": -s * 24.0, "faB": -25.0, "torso": 5.0, "head": 2.0,
		"all": [0, 0, -absf(cos(ph)) * 10.0]}


func _step_actors(dt: float) -> void:
	for a in actors:
		var go: Vector2 = a.go
		var moving := false
		if go != Vector2.INF:
			var d: Vector2 = go - a.pos
			var sp: float = a.speed
			if d.length() > 2.0:
				a.face = signf(d.x) if absf(d.x) > 1.0 else a.face
				a.pos += d.limit_length(sp * dt)
				a.ph += dt * sp / (STRIDE if a.get("gait", "v2") == "v2" else 26.0)
				moving = true
			else:
				a.go = Vector2.INF
		var ip: float = a.get("inplace", 0.0)      # đi tại chỗ (cảnh thử): nền tự trôi
		if ip > 0.0:
			a.ph += dt * ip / (STRIDE if a.get("gait", "v2") == "v2" else 26.0)
			moving = true
		var wk: float = a.walk
		a.walk = move_toward(wk, 1.0 if moving else 0.0, dt * 6.0)
		var p := Chibi.P(a.base)
		for e in a.extra:
			var dd: Dictionary = e[0] if e[0] is Dictionary else Chibi.POSES[e[0]]
			p = Chibi.mix(p, dd, e[1])
		p = Chibi.mix(p, _walk_pose(a.ph, a.get("gait", "v2")), a.walk)
		var tk: float = a.talk
		if tk > 0.0:
			p = Chibi.mix(p, {"uaF": -55.0 + sin(t * 3.1) * 18.0, "faF": -70.0 + sin(t * 4.3) * 15.0,
				"head": sin(t * 6.5) * 4.0}, tk)
		# tay cầm vật: IK đưa lòng bàn tay tới điểm (toạ độ thân), trọng số 0..1
		var hold: Dictionary = a.hold
		for side in hold:
			var hv: Array = hold[side]
			var hw: float = hv[1]
			if hw > 0.0:
				p = Chibi.mix(p, ik_arm(side, hv[0], a.node), hw)
		var n: Node2D = a.node
		n.position = a.pos
		n.scale = Vector2(a.face, 1.0) * CS
		n.sway = a.sway * (0.6 + wind(a.pos.x) * 0.8)
		n.move_v = float(a.walk) * (ip if ip > 0.0 else float(a.speed))
		_hand_forms(a, n)
		n.apply(p, dt)
		n.set_expr(a.expr)
		n.modulate = char_tint
	_step_props(dt)


# dạng bàn tay: a.hands ghi đè > đang cầm vật (nắm) > theo pose (palm → xoè, point → chỉ, thế võ → nắm) > thả lỏng
const FORM_OF := {"palm": ["xoe", "xoe"], "point": ["chi", "tha"], "charge": ["nam", "nam"], "windup": ["nam", "tha"],
	"slash": ["nam", "tha"], "guard": ["nam", "nam"], "stance": ["nam", "tha"], "run": ["nam", "nam"], "raise": ["xoe", "xoe"]}


func _hand_forms(a: Dictionary, n: Node2D) -> void:
	var fm := ["tha", "tha"]
	var b: String = a.base
	if FORM_OF.has(b):
		fm = FORM_OF[b].duplicate()
	for e in a.extra:
		if e[0] is String and FORM_OF.has(e[0]) and float(e[1]) > 0.5:
			fm = FORM_OF[e[0]].duplicate()
	for v in props:
		if v.a == a and v.at == "tay":
			fm[0 if v.side == "F" else 1] = "nam"
	var ov: Dictionary = a.get("hands", {})
	n.hand_form["F"] = ov.get("F", fm[0])
	n.hand_form["B"] = ov.get("B", fm[1])


func head_of(a: Dictionary) -> Vector2:
	var n: Node2D = a.node
	return n.head_pos(world)


func _d_shadow(c: Node2D) -> void:
	for a in actors:
		var p: Vector2 = a.pos
		flat_blob(c, p + Vector2(0, 4), 120.0, 0.16, Color(ink, 0.45))


# ---------------------------------------------------------------- hạt môi trường
# loại: leaf (lá dài), petal (cánh hoa), maple (lá phong), snow, firefly, dust, smoke, ripple, drift (tuyết cuốn sát đất)

func spawn(k: String, p: Vector2, extra := {}) -> Dictionary:
	var q := {"k": k, "p": p, "v": Vector2.ZERO, "life": 12.0, "age": 0.0, "z": rng.randf_range(0.7, 1.35),
		"rot": rng.randf() * TAU, "rs": rng.randf_range(-3.0, 3.0), "ph": rng.randf() * TAU,
		"fs": rng.randf_range(1.5, 3.5), "s": 1.0, "col": Color.WHITE, "land": INF, "wf": 1.0}
	q.merge(extra, true)
	parts.append(q)
	return q


# rơi đều `rate` hạt/giây trong vùng `r`
func rain_of(k: String, rate: float, r: Rect2, extra := {}) -> void:
	acc[k] = acc.get(k, 0.0) + rate * DT
	while acc[k] >= 1.0:
		acc[k] -= 1.0
		spawn(k, r.position + Vector2(rng.randf() * r.size.x, rng.randf() * r.size.y), extra)


func _update_parts(dt: float) -> void:
	var keep: Array = []
	var cur := parts
	parts = []                    # hạt sinh ra trong vòng lặp (gợn, bắn tung) vào mảng mới
	for q in cur:
		q.age += dt
		q.life -= dt
		var z: float = q.z
		var p: Vector2 = q.p
		var wnd := wind(p.x)
		match q.k:
			"leaf", "petal", "maple":
				if p.y < q.land:
					var fl := sin(t * q.fs + q.ph)
					q.v = Vector2(wnd * 160.0 * q.wf + fl * 60.0, 55.0 + cos(t * q.fs * 1.3 + q.ph) * 30.0) * z
					q.rot += q.rs * dt * (0.5 + absf(wnd))
				else:
					q.v = Vector2.ZERO
					q.life = minf(q.life, 2.0)
					if q.has("on_land"):
						q.on_land.call(q)
						q.erase("on_land")
			"snow":
				q.v = Vector2(wnd * 220.0 + sin(t * q.fs + q.ph) * 25.0, 120.0) * z
			"drift":
				q.v = Vector2(wnd * 520.0 + 80.0, sin(t * 3.0 + q.ph) * 12.0)
			"firefly":
				q.v = Vector2(sin(t * 0.7 + q.ph) * 40.0 + wnd * 20.0, cos(t * 0.9 + q.ph * 1.7) * 30.0)
			"dust":
				q.v = Vector2(wnd * 25.0 + sin(t * 0.5 + q.ph) * 8.0, -6.0 + cos(t * 0.6 + q.ph) * 6.0)
			"smoke":
				q.v = Vector2(wnd * 90.0 * minf(1.0, q.age), -55.0)
				q.s += dt * 0.55
			"ripple":
				q.s += dt
			"rain":
				q.v = Vector2(wnd * 160.0, 1500.0) * z
			"drop":
				q.v += Vector2(wnd * 60.0, 1900.0) * dt
			"splash":
				q.s += dt
			"bubble":
				q.s += dt
				q.v = Vector2(sin(t * 3.0 + q.ph) * 25.0 + wnd * 30.0, -70.0)
			"moth":
				var o: Dictionary = q.o
				var lw: Vector2 = o.lw
				var r: float = q.s
				var tg := lw + Vector2(cos(t * q.fs * 1.7 + q.ph) * 75.0, sin(t * q.fs * 2.3 + q.ph) * 50.0 - 10.0) * r
				q.v = (tg - p) / maxf(dt, 0.001)
		q.p = p + q.v * dt
		var pp: Vector2 = q.p
		if q.k == "rain" or q.k == "drop":
			if pp.y >= q.land:
				if q.has("on_land"):
					q.on_land.call(q)
				else:
					spawn("splash", Vector2(pp.x, q.land), {"z": z, "s": 0.0, "life": 0.3, "col": q.col})
				q.life = 0.0
			elif q.k == "rain" and _umbrella_hit(pp):
				for sd in [-1.0, 1.0]:
					spawn("drop", pp, {"z": z, "life": 0.5, "col": q.col, "land": pp.y + 60.0, "v": Vector2(sd * rng.randf_range(60, 160), -rng.randf_range(120, 260))})
				q.life = 0.0
		if q.life > 0.0 and pp.y < ground_y + 400.0 and pp.x > -500.0 and pp.x < W + 500.0:
			keep.append(q)
	parts = keep + parts


func _d_air_back(c: Node2D) -> void:
	_draw_parts(c, false)


func _d_air_front(c: Node2D) -> void:
	_draw_parts(c, true)


func _draw_parts(c: Node2D, front: bool) -> void:
	for q in parts:
		var z: float = q.z
		if (z >= 1.0) != front:
			continue
		var p: Vector2 = q.p
		var fade := minf(1.0, q.life / 1.5) * minf(1.0, q.age / 0.4)
		var col: Color = q.col
		match q.k:
			"leaf":
				var fl := absf(sin(t * q.fs * 1.4 + q.ph)) * 0.8 + 0.2
				leaf(c, p, q.rot, 26.0 * z * q.s, 7.0 * z * q.s * fl, Color(col, fade), 1.5)
			"petal":
				var fl := absf(sin(t * q.fs * 1.4 + q.ph)) * 0.7 + 0.3
				leaf(c, p, q.rot, 13.0 * z, 9.0 * z * fl, Color(col, fade), 1.2)
			"maple":
				var fl := absf(sin(t * q.fs * 1.2 + q.ph)) * 0.6 + 0.4
				maple(c, p, q.rot, 16.0 * z * q.s, fl, Color(col, fade))
			"snow":
				var r: float = 3.2 * z * q.s
				if z > 1.25:
					blob(c, p, r * 4.0, Color(1, 1, 1, 0.5 * fade))
				else:
					c.draw_circle(p, r, Color(col, 0.95 * fade), true, -1.0, true)
			"drift":
				var a := 0.28 * fade * minf(1.0, q.life)
				c.draw_line(p, p - Vector2(60.0 + wind(p.x) * 80.0, 0), Color(1, 1, 1, a), 3.0 * z, true)
			"smoke":
				var r: float = 20.0 * q.s
				var a := clampf(1.0 - q.age / q.max, 0.0, 1.0) * 0.75
				c.draw_circle(p, r + 2.5, Color(ink, a * 0.35), true, -1.0, true)
				c.draw_circle(p, r, Color(col, a), true, -1.0, true)
				c.draw_circle(p + Vector2(-r * 0.25, -r * 0.3), r * 0.45, Color(col.lightened(0.3), a), true, -1.0, true)
			"ripple":
				var r: float = 6.0 + q.s * 50.0
				var a := clampf(1.0 - q.s / 1.6, 0.0, 1.0) * 0.8
				c.draw_set_transform(p, 0.0, Vector2(1.0, 0.28))
				c.draw_arc(Vector2.ZERO, r, 0.0, TAU, 40, Color(col, a), 3.0, true)
				c.draw_arc(Vector2.ZERO, r * 0.6, 0.0, TAU, 32, Color(col, a * 0.6), 2.0, true)
				c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
			"rain":
				c.draw_line(p, p - q.v * 0.024, Color(col, 0.45 * fade), 1.8 * z, true)
			"drop":
				c.draw_circle(p, 3.2 * z, Color(col, 0.9 * fade), true, -1.0, true)
			"splash":
				var r: float = 5.0 + q.s * 70.0 * z
				var a := clampf(1.0 - q.s / 0.3, 0.0, 1.0) * 0.75
				c.draw_arc(p, r, PI * 1.15, PI * 1.85, 8, Color(col, a), 2.0 * z, true)
				c.draw_circle(p + Vector2(-r * 0.9, -r * 0.9), 2.2 * z, Color(col, a), true, -1.0, true)
				c.draw_circle(p + Vector2(r * 0.9, -r * 0.9), 2.2 * z, Color(col, a), true, -1.0, true)
			"bubble":
				var a := clampf(1.0 - q.s / 1.2, 0.0, 1.0)
				c.draw_arc(p, 7.0 * z + q.s * 4.0, 0.0, TAU, 16, Color(col, a), 2.5, true)
				c.draw_circle(p + Vector2(-2.5, -2.5), 2.0, Color(1, 1, 1, a), true, -1.0, true)
			"moth":
				var fl := absf(sin(t * 38.0 + q.ph))
				var wc := Color(ink, 0.85)
				c.draw_line(p, p + Vector2(-7, -6 * fl), wc, 3.0, true)
				c.draw_line(p, p + Vector2(7, -6 * fl), wc, 3.0, true)


# đom đóm / bụi nắng vẽ ở lớp cộng
func _d_glow(c: Node2D) -> void:
	for q in parts:
		var p: Vector2 = q.p
		var col: Color = q.col
		if q.k == "firefly":
			var b := pow(0.5 + 0.5 * sin(t * q.fs * 1.6 + q.ph), 3.0) * minf(1.0, q.age)
			blob(c, p, 26.0 * q.z, Color(col, 0.35 * b))
			c.draw_circle(p, 3.0 * q.z, Color(col * 2.2, b), true, -1.0, true)
		elif q.k == "dust":
			var b := (0.5 + 0.5 * sin(t * q.fs + q.ph)) * minf(1.0, q.age) * minf(1.0, q.life)
			c.draw_circle(p, 2.2 * q.z, Color(col, 0.5 * b), true, -1.0, true)
	_glow_props(c)
	_glow(c)


func _d_sky(c: Node2D) -> void:
	vgrad(c, Rect2(-200, -200, W + 400, H + 400), sky_top, sky_bot)
	_sky(c)


func _d_far(c: Node2D) -> void:
	_far(c)


func _d_mid(c: Node2D) -> void:
	_mid(c)


func _d_back(c: Node2D) -> void:
	_back(c)


func _d_ground(c: Node2D) -> void:
	_ground(c)


func _d_near(c: Node2D) -> void:
	_near(c)


func _d_front(c: Node2D) -> void:
	_front(c)


func _d_screen(c: Node2D) -> void:
	c.draw_texture_rect(vign, Rect2(-260, -300, W + 520, H + 600), false, Color(ink, vign_a))
	if caption != "":
		c.draw_string(font, Vector2(48, H - 44), caption, HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color(1, 1, 1, 0.85))


# ---------------------------------------------------------------- công cụ vẽ phong cách chibi

# viền của một màu: tối đi và ngả về mực chung
func inkof(col: Color, k := 0.62) -> Color:
	return col.darkened(k).lerp(ink, 0.4)


# đẩy màu về không khí theo độ xa (0 = gần, 1 = tan vào haze)
func air(col: Color, far: float) -> Color:
	return col.lerp(haze, far)


func blob(c: Node2D, p: Vector2, r: float, col: Color) -> void:
	c.draw_texture_rect(soft, Rect2(p - Vector2(r, r), Vector2(r * 2, r * 2)), false, col)


func flat_blob(c: Node2D, p: Vector2, r: float, sy: float, col: Color) -> void:
	c.draw_set_transform(p, 0.0, Vector2(1.0, sy))
	c.draw_texture_rect(soft, Rect2(Vector2(-r, -r), Vector2(r * 2, r * 2)), false, col)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func vgrad(c: Node2D, r: Rect2, a: Color, b: Color) -> void:
	var p := PackedVector2Array([r.position, r.position + Vector2(r.size.x, 0), r.end, r.position + Vector2(0, r.size.y)])
	c.draw_polygon(p, PackedColorArray([a, a, b, b]))


# Catmull-Rom: biến đa giác góc cạnh thành đường tròn trịa
func round_pts(pts: PackedVector2Array, closed := true, n := 6) -> PackedVector2Array:
	var out := PackedVector2Array()
	var m := pts.size()
	var segs := m if closed else m - 1
	for i in segs:
		var p0 := pts[(i - 1 + m) % m] if closed or i > 0 else pts[0]
		var p1 := pts[i]
		var p2 := pts[(i + 1) % m]
		var p3 := pts[(i + 2) % m] if closed or i + 2 < m else pts[m - 1]
		for j in n:
			var u := float(j) / n
			var u2 := u * u
			var u3 := u2 * u
			out.append(0.5 * ((2.0 * p1) + (-p0 + p2) * u + (2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * u2 + (-p0 + 3.0 * p1 - 3.0 * p2 + p3) * u3))
	if not closed:
		out.append(pts[m - 1])
	return out


# mảng màu phẳng có viền mực (w = 0: không viền, dùng cho lớp xa)
func shape(c: Node2D, pts: PackedVector2Array, fill: Color, w := 4.0, line := Color(0, 0, 0, 0)) -> void:
	if pts.size() < 3:
		return
	c.draw_colored_polygon(pts, fill)
	if w > 0.0:
		var cl := pts.duplicate()
		cl.append(pts[0])
		c.draw_polyline(cl, line if line.a > 0.0 else inkof(fill), w, true)


# cắt đa giác bằng đa giác (dùng cho mảng bóng/sáng cel và mũ tuyết)
func clip_fill(c: Node2D, a: PackedVector2Array, b: PackedVector2Array, col: Color) -> void:
	for poly in Geometry2D.intersect_polygons(a, b):
		c.draw_colored_polygon(poly, col)


# cụm tròn (mây, tán cây, bụi, khói đặc): viền mực bao ngoài, tông bóng dưới, tông chính lệch lên, chấm sáng
func puff(c: Node2D, circles: Array, fill: Color, w := 4.0, hl := 0.25, line := Color(0, 0, 0, 0)) -> void:
	var ln := line if line.a > 0.0 else inkof(fill)
	if w > 0.0:
		for q in circles:
			c.draw_circle(q[0], q[1] + w, ln, true, -1.0, true)
	var sh := fill.darkened(0.2).lerp(ink, 0.08)
	for q in circles:
		c.draw_circle(q[0], q[1], sh, true, -1.0, true)
	for q in circles:
		var r: float = q[1]
		c.draw_circle(q[0] + Vector2(-r * 0.1, -r * 0.14), r * 0.84, fill, true, -1.0, true)
	if hl > 0.0:
		var lc := Color(fill.lightened(0.35), hl * 2.0)
		for q in circles:
			var r: float = q[1]
			c.draw_circle(q[0] + Vector2(-r * 0.32, -r * 0.38), r * 0.3, lc, true, -1.0, true)


func cloud(c: Node2D, p: Vector2, s: float, fill: Color, w := 4.0) -> void:
	puff(c, [[p + Vector2(-70, 8) * s, 42.0 * s], [p + Vector2(-25, -22) * s, 55.0 * s], [p + Vector2(30, -12) * s, 48.0 * s],
		[p + Vector2(72, 10) * s, 36.0 * s], [p + Vector2(10, 18) * s, 44.0 * s]], fill, w, 0.2)


# lá hình thấu kính quanh tâm p
func leaf_pts(p: Vector2, ang: float, l: float, wd: float) -> PackedVector2Array:
	var out := PackedVector2Array()
	var d := Vector2.from_angle(ang)
	var nn := d.orthogonal()
	for i in 9:
		var k := float(i) / 8.0
		out.append(p + d * (k - 0.5) * l + nn * sin(k * PI) * wd * 0.5)
	for i in range(7, 0, -1):
		var k := float(i) / 8.0
		out.append(p + d * (k - 0.5) * l - nn * sin(k * PI) * wd * 0.5)
	return out


func leaf(c: Node2D, p: Vector2, ang: float, l: float, wd: float, col: Color, w := 2.0) -> void:
	var pts := leaf_pts(p, ang, l, maxf(wd, 1.0))
	shape(c, pts, col, w, Color(inkof(col), col.a))


# lá phong 5 thuỳ
func maple(c: Node2D, p: Vector2, ang: float, r: float, flip: float, col: Color) -> void:
	var pts := PackedVector2Array()
	for i in 10:
		var a := ang + i * TAU / 10.0
		var rr := r if i % 2 == 0 else r * 0.45
		var v := Vector2.from_angle(a) * rr
		pts.append(p + Vector2(v.x, v.y * flip))
	shape(c, pts, col, 1.5, Color(inkof(col), col.a))


# cây tán tròn: thân cong theo gió, tán là cụm tròn lắc lệch pha
func tree(c: Node2D, base: Vector2, h: float, r: float, leafc: Color, bark: Color, seed: int, w := 4.0) -> void:
	var sw := (wind(base.x) - wind_base * 0.5) * h * 0.035
	var top := base + Vector2(sw * 0.6, -h)
	var tw := r * 0.16
	var trunk := PackedVector2Array([base + Vector2(-tw * 1.4, 0), base.lerp(top, 0.5) + Vector2(-tw, 0), top + Vector2(-tw * 0.6, 0),
		top + Vector2(tw * 0.6, 0), base.lerp(top, 0.5) + Vector2(tw, 0), base + Vector2(tw * 1.4, 0)])
	shape(c, round_pts(trunk, true, 3), bark, w)
	var rr := RandomNumberGenerator.new()
	rr.seed = seed
	var cs: Array = []
	for i in 7:
		var a := -PI * 0.5 + (i - 3) * 0.55
		var d := r * (0.5 if i != 3 else 0.15)
		var ph := rr.randf() * TAU
		var jig := Vector2(sin(t * 2.2 + ph), cos(t * 1.7 + ph)) * r * 0.025 * (0.5 + wind(base.x))
		cs.append([top + Vector2.from_angle(a) * d + Vector2(sw, r * 0.1) + jig, r * rr.randf_range(0.42, 0.58)])
	puff(c, cs, leafc, w, 0.22)


# cây thông tầng tròn (có thể phủ tuyết)
func pine(c: Node2D, base: Vector2, h: float, wd: float, col: Color, snow := 0.0, w := 4.0, seed := 0) -> void:
	var sw := (wind(base.x) - wind_base * 0.5) * h * 0.03
	var tiers := 4
	c.draw_rect(Rect2(base.x - wd * 0.06, base.y - h * 0.2, wd * 0.12, h * 0.2), inkof(col, 0.4))
	for i in tiers:
		var k := float(i) / tiers
		var y0 := base.y - h * 0.12 - k * h * 0.72
		var tw := wd * (1.0 - k * 0.62) * 0.5
		var off := sw * (k + 0.25)
		var tip := Vector2(base.x + off + sw * 0.3, y0 - h * 0.34)
		var tri := PackedVector2Array([Vector2(base.x - tw + off, y0), tip, Vector2(base.x + tw + off, y0),
			Vector2(base.x + off, y0 + h * 0.04)])
		var rp := round_pts(tri, true, 4)
		shape(c, rp, col, w)
		# mảng bóng nửa phải
		var half := PackedVector2Array([tip, Vector2(base.x + tw + off + 20, y0 + 30), Vector2(base.x + off, y0 + 30)])
		clip_fill(c, rp, half, Color(col.darkened(0.22), 0.9))
		if snow > 0.0:
			var cap := PackedVector2Array([tip + Vector2(0, -10), Vector2(base.x + tw + off + 10, y0 - h * 0.08),
				Vector2(base.x + off + tw * 0.4, y0 - h * 0.12 + sin(seed + i) * 6.0), Vector2(base.x + off, y0 - h * 0.06),
				Vector2(base.x - tw * 0.5 + off, y0 - h * 0.13), Vector2(base.x - tw + off - 10, y0 - h * 0.08)])
			clip_fill(c, rp, cap, Color(0.97, 0.98, 1.0) * snow)


# cây trúc: cong theo gió, đốt, lá thon rung
func bamboo(c: Node2D, x: float, y0: float, h: float, wd: float, col: Color, seed: int, w := 3.0, leaves := true) -> void:
	var bend := (wind(x) * 0.07 + sin(t * 1.9 + seed) * 0.01) * h
	var pts := PackedVector2Array()
	for i in 13:
		var k := float(i) / 12.0
		pts.append(Vector2(x + bend * k * k, y0 - h * k))
	var ln := inkof(col)
	c.draw_polyline(pts, ln, wd + w * 2.0, true)
	c.draw_polyline(pts, col, wd, true)
	var hlp := PackedVector2Array()
	for p in pts:
		hlp.append(p + Vector2(-wd * 0.22, 0))
	c.draw_polyline(hlp, Color(col.lightened(0.3), 0.8), wd * 0.22, true)
	for i in range(1, 12, 2):
		var p := pts[i]
		c.draw_line(p + Vector2(-wd * 0.6, 0), p + Vector2(wd * 0.6, 0), ln, w, true)
	if not leaves:
		return
	var rr := RandomNumberGenerator.new()
	rr.seed = seed
	var lc := col.lerp(Color("#5fae4e"), 0.35)
	for i in [7, 9, 11, 12]:
		var p := pts[i]
		for j in 3:
			var side := -1.0 if (i + j) % 2 == 0 else 1.0
			var a := PI * 0.5 - side * rr.randf_range(0.6, 1.3) + sin(t * 3.0 + rr.randf() * 6.0) * 0.12 - wind(x) * 0.3
			var l := rr.randf_range(46, 70)
			leaf(c, p + Vector2.from_angle(a) * l * 0.5, a, l, l * 0.22, lc, 2.0)


# nhà mái cong: p = giữa chân tường
func house(c: Node2D, p: Vector2, wd: float, ht: float, wall: Color, roof: Color, wood: Color, lit := 0.0, w := 4.0, seed := 0) -> Array:
	var x0 := p.x - wd * 0.5
	var x1 := p.x + wd * 0.5
	var top := p.y - ht
	shape(c, PackedVector2Array([Vector2(x0, p.y), Vector2(x0, top), Vector2(x1, top), Vector2(x1, p.y)]), wall, w)
	# mảng bóng dưới mái
	c.draw_rect(Rect2(x0 + w * 0.5, top, wd - w, ht * 0.12), Color(inkof(wall, 0.3), 0.55))
	for xx in [x0 + wd * 0.06, x1 - wd * 0.06]:
		shape(c, PackedVector2Array([Vector2(xx - 9, p.y), Vector2(xx - 9, top), Vector2(xx + 9, top), Vector2(xx + 9, p.y)]), wood, w * 0.75)
	# cửa + cửa sổ
	var dw := wd * 0.2
	shape(c, PackedVector2Array([Vector2(p.x - dw * 0.5, p.y), Vector2(p.x - dw * 0.5, p.y - ht * 0.62), Vector2(p.x + dw * 0.5, p.y - ht * 0.62), Vector2(p.x + dw * 0.5, p.y)]), wood.darkened(0.25), w * 0.75)
	var wins: Array = []
	var fl := 0.85 + 0.15 * sin(t * 7.0 + seed) * sin(t * 3.1 + seed * 2.0)
	for sx in [-1.0, 1.0]:
		var cx: float = p.x + sx * wd * 0.29
		var r := Rect2(cx - wd * 0.1, p.y - ht * 0.7, wd * 0.2, ht * 0.32)
		var glass := wall.darkened(0.45) if lit <= 0.0 else Color(1.8, 1.15, 0.5) * lit * fl
		shape(c, PackedVector2Array([r.position, r.position + Vector2(r.size.x, 0), r.end, r.position + Vector2(0, r.size.y)]), glass, w * 0.75, inkof(wood))
		for k in [0.33, 0.66]:
			c.draw_line(r.position + Vector2(r.size.x * k, 0), r.position + Vector2(r.size.x * k, r.size.y), inkof(wood), 3.0, true)
		c.draw_line(r.position + Vector2(0, r.size.y * 0.5), r.position + Vector2(r.size.x, r.size.y * 0.5), inkof(wood), 3.0, true)
		wins.append(r.get_center())
	# mái cong vểnh hai đầu
	var ov := wd * 0.16
	var rh := ht * 0.42
	var roofp := PackedVector2Array([Vector2(x0 - ov, top - rh * 0.28), Vector2(x0 - ov * 0.4, top + 4), Vector2(p.x, top + rh * 0.08),
		Vector2(x1 + ov * 0.4, top + 4), Vector2(x1 + ov, top - rh * 0.28), Vector2(x1 - wd * 0.12, top - rh * 0.75),
		Vector2(p.x, top - rh * 0.82), Vector2(x0 + wd * 0.12, top - rh * 0.75)])
	var rp := round_pts(roofp, true, 5)
	shape(c, rp, roof, w)
	clip_fill(c, rp, PackedVector2Array([Vector2(x0 - ov * 2, top - rh * 0.1), Vector2(x1 + ov * 2, top - rh * 0.1), Vector2(x1 + ov * 2, top + 40), Vector2(x0 - ov * 2, top + 40)]), roof.darkened(0.28))
	for i in 9:
		var k := (i + 1) / 10.0
		var xx := lerpf(x0 + wd * 0.05, x1 - wd * 0.05, k)
		c.draw_line(Vector2(xx, top - rh * 0.72), Vector2(xx + (k - 0.5) * 30.0, top - rh * 0.08), Color(inkof(roof), 0.6), 2.5, true)
	c.draw_line(Vector2(x0 + wd * 0.1, top - rh * 0.78), Vector2(x1 - wd * 0.1, top - rh * 0.78), inkof(roof), w * 2.2, true)
	for sx in [-1.0, 1.0]:
		c.draw_circle(Vector2(p.x + sx * wd * 0.42, top - rh * 0.86), 11.0, inkof(roof), true, -1.0, true)
	return wins


# đèn lồng treo từ `top`, đung đưa theo gió; trả về tâm thân đèn (vẽ quầng ở _glow)
func lantern(c: Node2D, top: Vector2, ln: float, r: float, col: Color, seed: int, w := 3.0) -> Vector2:
	var ang := sin(t * 1.7 + seed) * 0.1 + (wind(top.x) - wind_base) * 0.25
	var ctr := top + Vector2(sin(-ang), cos(ang)) * ln
	c.draw_line(top, ctr, ink, 2.0, true)
	var body := PackedVector2Array()
	for i in 24:
		var a := i * TAU / 24.0
		body.append(ctr + Vector2(cos(a) * r, sin(a) * r * 1.15).rotated(-ang))
	var fl := 0.9 + 0.1 * sin(t * 9.0 + seed * 3.0)
	shape(c, body, col * fl, w, inkof(Color(col.r * 0.6, col.g * 0.3, col.b * 0.3)))
	for k in [-0.45, 0.0, 0.45]:
		var a0 := ctr + Vector2(k * r, -r * 1.05).rotated(-ang)
		var a1 := ctr + Vector2(k * r * 1.25, 0).rotated(-ang)
		var a2 := ctr + Vector2(k * r, r * 1.05).rotated(-ang)
		c.draw_polyline(PackedVector2Array([a0, a1, a2]), Color(0.5, 0.15, 0.1, 0.6), 2.0, true)
	for sy in [-1.0, 1.0]:
		var cp := ctr + Vector2(0, sy * r * 1.12).rotated(-ang)
		c.draw_set_transform(cp, -ang, Vector2.ONE)
		c.draw_rect(Rect2(-r * 0.45, -5, r * 0.9, 10), Color("#2a1a12"))
		c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var tb := ctr + Vector2(0, r * 1.2).rotated(-ang)
	c.draw_line(tb, tb + Vector2(sin(t * 2.5 + seed) * 4.0 - ang * 20.0, r * 0.8), Color("#e8b030"), 3.0, true)
	return ctr


# cỏ: búi 3 lá nghiêng theo gió (2 tông, không viền để đỡ rối)
func grass(c: Node2D, x0: float, x1: float, y: float, step: float, h: float, col: Color, seed: int) -> void:
	var rr := RandomNumberGenerator.new()
	rr.seed = seed
	var dark := col.darkened(0.25).lerp(ink, 0.1)
	var x := x0
	while x < x1:
		var hh := h * rr.randf_range(0.6, 1.2)
		var yy := y + rr.randf_range(-6, 6)
		var wv := wind(x) * hh * 0.45 + sin(t * 3.0 + x * 0.05) * hh * 0.06
		for j in 3:
			var bx := x + (j - 1) * 7.0
			var lean := (j - 1) * hh * 0.3
			var tip := Vector2(bx + lean + wv, yy - hh * (1.0 - absf(j - 1) * 0.2))
			c.draw_colored_polygon(PackedVector2Array([Vector2(bx - 5, yy), tip, Vector2(bx + 5, yy)]), dark if j != 1 else col)
		x += step * rr.randf_range(0.6, 1.4)


# núi tròn đỉnh: trả về đa giác (để vẽ phản chiếu / mũ tuyết)
func mountain_pts(peaks: Array, base_y: float) -> PackedVector2Array:
	var pts := PackedVector2Array([Vector2(-300, base_y)])
	for pk in peaks:
		pts.append(pk)
	pts.append(Vector2(W + 300, base_y))
	var rp := round_pts(pts, false, 6)
	rp.append(Vector2(W + 300, H + 300))
	rp.append(Vector2(-300, H + 300))
	return rp


func bird(c: Node2D, p: Vector2, s: float, ph: float, col: Color) -> void:
	var f := sin(t * 10.0 + ph)
	var pts := PackedVector2Array([p + Vector2(-s, -s * 0.5 * f), p + Vector2(-s * 0.4, -s * 0.15 * f - s * 0.1), p,
		p + Vector2(s * 0.4, -s * 0.15 * f - s * 0.1), p + Vector2(s, -s * 0.5 * f)])
	c.draw_polyline(round_pts(pts, false, 3), col, maxf(2.0, s * 0.2), true)


# tia nắng xiên (vẽ ở lớp cộng)
func rays(c: Node2D, o: Vector2, ang: float, spread: float, n: int, len: float, col: Color, seed := 0) -> void:
	for i in n:
		var k := float(i) / maxf(1.0, n - 1.0)
		var a := ang + (k - 0.5) * spread + sin(t * 0.3 + i * 1.7 + seed) * 0.02
		var wd := 0.035 + 0.03 * sin(i * 2.3 + seed)
		var al := col.a * (0.6 + 0.4 * sin(t * 0.8 + i * 1.3))
		var p1 := o + Vector2.from_angle(a - wd) * len
		var p2 := o + Vector2.from_angle(a + wd) * len
		c.draw_polygon(PackedVector2Array([o, p1, p2]), PackedColorArray([Color(col, al), Color(col, 0), Color(col, 0)]))


# cờ / băng vải vẫy gió: gốc trên ở p
func flag(c: Node2D, p: Vector2, l: float, hgt: float, col: Color, w := 3.0) -> void:
	var wn := clampf(wind(p.x), 0.1, 2.0)
	var top := PackedVector2Array()
	var bot := PackedVector2Array()
	for i in 11:
		var k := float(i) / 10.0
		var dx := k * l * (0.55 + wn * 0.3)
		var wave := sin(k * 7.0 - t * (5.0 + wn * 4.0)) * hgt * 0.22 * k
		var droop := (1.0 - minf(wn, 1.0)) * k * k * l * 0.6
		top.append(p + Vector2(dx, wave + droop))
		bot.append(p + Vector2(dx - k * 6.0, hgt * (1.0 - k * 0.25) + wave + droop))
	var poly := top.duplicate()
	for i in range(bot.size() - 1, -1, -1):
		poly.append(bot[i])
	shape(c, poly, col, w)


# ================================================================ VẬT PHẨM TÁCH RỜI
# Vật phẩm vẽ bằng code, gắn vào khớp của chibi lúc chạy, đổi chỗ được giữa cảnh:
#   "tay" (lòng bàn tay F/B) · "hong" (thắt lưng) · "lung" (sau lưng) · "mat" (phủ lên mặt) · "dat" (đặt ở pos, toạ độ thế giới)
# Toạ độ vẽ = toạ độ cục bộ của khớp (đơn vị chibi, chưa nhân CS). Hướng thật của thế giới (trọng lực, gió) đổi về cục bộ
# bằng wdir(); nên đèn treo, hồ lô, tua kiếm luôn rủ xuống và ô luôn dựng đứng dù tay xoay hay nhân vật quay mặt.
# Loại có sẵn: kiem (+vỏ, tua), o (ô giấy dầu, chặn mưa), ho_lo (hồ lô rượu), den (đèn lồng cán), ma_do (má đỏ khi say).

const ARM_L1 := 56.0
const ARM_L2 := 58.0              # cẳng tay 48 + lòng bàn tay 10
const BLADE := 200.0

var props: Array = []


func prop(a: Dictionary, k: String, at := "tay", side := "F", extra := {}) -> Dictionary:
	var v := {"a": a, "k": k, "at": "", "side": side, "grip": -90.0, "lock": 0.0, "lockdir": Vector2.DOWN,
		"ang": 0.0, "angv": 0.0, "pour": 0.0, "glint": -9.0, "trail": [], "trail_on": false, "pw": Vector2.INF,
		"lw": Vector2.ZERO, "tipw": Vector2.ZERO, "midw": Vector2.ZERO, "guardw": Vector2.ZERO, "can": [], "rim": [],
		"amount": 0.0, "since": 0.0, "out": BLADE, "col": Color("#e2a23a"), "sheath": Vector2(-0.8, 0.6).normalized(),
		"hong": Vector2(30, -12), "shaft": 330.0}
	v.merge(extra, true)
	var n := Node2D.new()
	n.draw.connect(_d_prop.bind(n, v))
	v.node = n
	if k == "kiem" and v.get("vo", false):
		var vo := Node2D.new()
		vo.draw.connect(_d_vo.bind(vo, v))
		var to: Node2D = a.node.J["torso"]
		to.add_child(vo)
		to.move_child(vo, 1)
		vo.position = v.hong
		v.vo_node = vo
	props.append(v)
	prop_to(v, at, side)
	return v


func prop_to(v: Dictionary, at: String, side := "") -> void:
	if side != "":
		v.side = side
	var n: Node2D = v.node
	var ch: Node2D = v.a.node
	if n.get_parent():
		n.get_parent().remove_child(n)
	v.at = at
	v.since = t
	v.erase("rope")
	n.scale = Vector2.ONE
	match at:
		"tay":
			var hd: Node2D = ch.J["hd" + v.side]
			hd.add_child(n)
			hd.move_child(n, ch.prop_slot(v.side))   # trên lòng bàn tay, dưới ngón tay: ngón ôm qua chuôi
			n.position = Vector2(0, 10)
		"hong":
			var to: Node2D = ch.J["torso"]
			to.add_child(n)
			to.move_child(n, 1)            # ngay trên thân, dưới tay
			n.position = v.hong
			if v.has("vo_node"):
				to.move_child(v.vo_node, 2)  # vỏ phủ lên lưỡi kiếm
		"lung":
			var to: Node2D = ch.J["torso"]
			to.add_child(n)
			to.move_child(n, 0)
			n.position = Vector2(-20, -70)
		"mat":
			ch.J["head"].add_child(n)
			n.position = Vector2.ZERO
		_:
			l_chars.add_child(n)
			l_chars.move_child(n, 0)
			n.position = v.get("pos", Vector2.ZERO)
			n.scale = Vector2(CS, CS)


func to_w(n: Node2D, lp: Vector2) -> Vector2:
	return world.get_global_transform().affine_inverse() * (n.get_global_transform() * lp)


func from_w(n: Node2D, wp: Vector2) -> Vector2:
	return n.get_global_transform().affine_inverse() * (world.get_global_transform() * wp)


# hướng thế giới → hướng cục bộ của node (và ngược lại)
func wdir(n: Node2D, wd: Vector2) -> Vector2:
	return (n.get_global_transform().affine_inverse() * world.get_global_transform()).basis_xform(wd).normalized()


func ldir(n: Node2D, ld: Vector2) -> Vector2:
	return (world.get_global_transform().affine_inverse() * n.get_global_transform()).basis_xform(ld).normalized()


# điểm toạ độ thân (torso) của nhân vật → thế giới
func body_w(a: Dictionary, bp: Vector2) -> Vector2:
	return to_w(a.node.J["torso"], bp)


# góc khớp tay (độ) để lòng bàn tay tới điểm tg (toạ độ thân, đơn vị chibi); khuỷu luôn chọn phía dưới
func ik_arm(side: String, tg: Vector2, n: Node2D = null) -> Dictionary:
	var s := Vector2(58.0 if side == "F" else -58.0, -98.0)
	var l1 := ARM_L1
	var l2 := ARM_L2
	if n != null:
		s = n.shoulder(side)
		var al2: Vector2 = n.arm_len()
		l1 = al2.x
		l2 = al2.y
	var d := tg - s
	var st := 0.0                        # với quá tầm: tay giãn (chỉ v2)
	if n != null and n.v2 and d.length() > l1 + l2:
		st = minf(d.length() / (l1 + l2) - 1.0, Chibi.MAX_STR)
		l1 *= 1.0 + st
		l2 *= 1.0 + st
	var L := clampf(d.length(), 10.0, l1 + l2 - 0.5)
	d = d.normalized() * L
	var base := atan2(-d.x, d.y)
	var al := acos(clampf((l1 * l1 + L * L - l2 * l2) / (2.0 * l1 * L), -1.0, 1.0))
	var best := {}
	var by := -INF
	for sg: float in [1.0, -1.0]:
		var ua: float = base + sg * al
		var e := Vector2(0, l1).rotated(ua)
		var f := d - e
		var fa := wrapf(atan2(-f.x, f.y) - ua, -PI, PI)
		if e.y > by:
			by = e.y
			best = {"ua" + side: rad_to_deg(wrapf(ua, -PI, PI)), "fa" + side: rad_to_deg(fa), "str" + side: st}
	return best


# dây mềm (Verlet) trong toạ độ thế giới: tua kiếm, dây đèn, dây hồ lô
func _rope(v: Dictionary, anchor: Vector2, n: int, seg: float, dt: float, wk := 900.0) -> Array:
	if not v.has("rope"):
		var init := []
		for i in n + 1:
			init.append(anchor + Vector2(0, seg * i))
		v.rope = init
		v.rope_o = init.duplicate()
	var pts: Array = v.rope
	var old: Array = v.rope_o
	pts[0] = anchor
	old[0] = anchor
	if dt > 0.0:
		for i in range(1, n + 1):
			var p: Vector2 = pts[i]
			var o: Vector2 = old[i]
			var vel: Vector2 = (p - o) * 0.965
			old[i] = p
			pts[i] = p + vel + Vector2((wind(p.x) - wind_base * 0.4) * wk, 2200.0) * dt * dt
	for _it in 6:
		for i in range(1, n + 1):
			var a: Vector2 = pts[i - 1]
			var b: Vector2 = pts[i]
			var d := b - a
			var l := d.length()
			if l < 0.001:
				continue
			var corr := d * (1.0 - seg / l)
			if i == 1:
				pts[i] = b - corr
			else:
				pts[i - 1] = a + corr * 0.5
				pts[i] = b - corr * 0.5
	return pts


func _step_props(dt: float) -> void:
	for v in props:
		var n: Node2D = v.node
		n.queue_redraw()
		if v.has("vo_node"):
			v.vo_node.queue_redraw()
		var pw := to_w(n, Vector2.ZERO)
		var p0: Vector2 = v.pw
		var vel := Vector2.ZERO if (p0 == Vector2.INF or dt <= 0.0) else (pw - p0) / dt
		v.pw = pw
		match v.k:
			"kiem":
				var g := _sword_geo(n, v)
				var gp: Vector2 = g[0]
				var gd: Vector2 = g[1]
				v.tipw = to_w(n, gp + gd * BLADE)
				v.midw = to_w(n, gp + gd * 70.0)
				v.guardw = to_w(n, gp)
				if v.has("vo_node"):
					if v.at == "tay":
						var mw := to_w(v.vo_node, Vector2.ZERO)
						v.out = clampf(maxf(float(v.out), (v.guardw - mw).length() / CS * float(v.get("pull_k", 1.0))), 0.0, BLADE)
					else:
						v.out = 0.0
				_rope(v, to_w(n, gp - gd * 62.0), 3, 13.0, dt, 1400.0)
				var tr: Array = v.trail
				tr.push_front([v.tipw, v.midw])
				if tr.size() > 7:
					tr.pop_back()
			"o":
				var ang: float = v.ang
				var tg := (wind(pw.x) - wind_base) * 0.16 - clampf(vel.x, -500.0, 500.0) * 0.0003 + float(v.get("tilt", 0.0)) * float(v.a.face)
				var av: float = v.angv
				av += ((tg - ang) * 70.0 - av * 8.0) * dt
				v.angv = av
				v.ang = ang + av * dt
				var og := _o_geo(n, v)
				var rc: Vector2 = og.rimc
				var rt: Vector2 = og.rt
				var top: Vector2 = og.top
				var cw := to_w(n, rc)
				var rw := (to_w(n, rc + rt * 250.0) - cw).length()
				var hw := (to_w(n, top) - cw).length()
				v.can = [cw, rw, hw]
				v.rim = [to_w(n, rc - rt * 250.0), to_w(n, rc + rt * 250.0)]
			"den":
				var face: float = v.a.face
				var bob := sin(t * 2.0) * 0.04
				v.lockdir = Vector2(face * 0.86, -0.5).rotated(bob * face).normalized()
				var sd := wdir(n, v.lockdir)
				_rope(v, to_w(n, sd * 150.0), 2, 18.0, dt, 500.0)
				var pts: Array = v.rope
				var e: Vector2 = pts[2]
				var e1: Vector2 = pts[1]
				v.lw = e + (e - e1).normalized() * 30.0
			"ho_lo":
				if v.at == "hong":
					_rope(v, pw, 1, 16.0, dt, 300.0)
				var ax := _gourd_axis(n, v)
				v.mouthw = to_w(n, -ax * 20.0)


func _umbrella_hit(p: Vector2) -> bool:
	for v in props:
		if v.k != "o" or v.can.is_empty():
			continue
		var c: Vector2 = v.can[0]
		var r: float = v.can[1]
		var h: float = v.can[2]
		var x := p.x - c.x
		if absf(x) < r and p.y > c.y - h * (1.0 - pow(x / r, 2.0)) - 6.0 and p.y < c.y + 14.0:
			return true
	return false


# ---------------------------------------------------------------- vẽ từng loại

func _d_prop(c: Node2D, v: Dictionary) -> void:
	match v.k:
		"kiem":
			var g := _sword_geo(c, v)
			_draw_sword(c, g[0], g[1], v)
		"o":
			_draw_umbrella(c, v)
		"den":
			_draw_lantern_stick(c, v)
		"ho_lo":
			_draw_gourd(c, v)
		"ma_do":
			var k: float = v.amount
			if k > 0.01:
				var ck: Vector2 = v.get("cheek", Vector2(62, -40))
				for sx: float in [-1.0, 1.0]:
					var p := ck * Vector2(sx, 1.0)
					c.draw_set_transform(p, 0.0, Vector2(1.0, 0.55))
					c.draw_circle(Vector2.ZERO, 30.0, Color(1.0, 0.25, 0.3, 0.45 * k), true, -1.0, true)
					c.draw_circle(Vector2.ZERO, 18.0, Color(1.0, 0.2, 0.25, 0.4 * k), true, -1.0, true)
					c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
					for i in 3:
						var q := p + Vector2(-14 + i * 14, -2)
						c.draw_line(q + Vector2(-4, -6), q + Vector2(4, 6), Color(0.7, 0.1, 0.15, 0.55 * k), 2.5, true)


# kiếm: [tâm chắn kiếm, hướng lưỡi] trong toạ độ node
func _sword_geo(n: Node2D, v: Dictionary) -> Array:
	if v.at != "tay":
		return [Vector2.ZERO, v.sheath]
	var d := Vector2(0, 1).rotated(deg_to_rad(v.grip))
	var lk: float = v.lock
	if lk > 0.0:
		d = d.lerp(wdir(n, v.lockdir), lk).normalized()
	return [d * 22.0, d]


func _draw_sword(c: Node2D, g: Vector2, d: Vector2, v: Dictionary) -> void:
	var nr := Vector2(-d.y, d.x)
	var bw := 11.0
	var L: float = v.get("out", BLADE) if v.at == "tay" else BLADE   # đang rút: chỉ phần lưỡi đã ra khỏi vỏ
	if L > 4.0:
		var blade := PackedVector2Array([g + nr * bw, g + d * (L - 28) + nr * bw, g + d * L, g + d * (L - 28) - nr * bw, g - nr * bw])
		if L < BLADE:
			blade = PackedVector2Array([g + nr * bw, g + d * L + nr * bw, g + d * L - nr * bw, g - nr * bw])
		shape(c, blade, Color("#e8eff7"), 4.0, inkof(Color("#7f95ae"), 0.25))
		c.draw_line(g + d * minf(10.0, L), g + d * maxf(L - 30.0, minf(10.0, L)), Color("#aebfd2"), 3.0, true)
		c.draw_line(g + d * minf(12.0, L) + nr * bw * 0.55, g + d * maxf(L - 34.0, minf(12.0, L)) + nr * bw * 0.55, Color(1.15, 1.15, 1.2), 2.5, true)
	# tua kiếm (dây mềm) buộc ở đốc
	if v.has("rope"):
		var pts := PackedVector2Array()
		for wp in v.rope:
			pts.append(from_w(c, wp))
		c.draw_polyline(pts, inkof(Color("#c8322a")), 7.0, true)
		c.draw_polyline(pts, Color("#d8392e"), 4.0, true)
		var e := pts[pts.size() - 1]
		var ed := (e - pts[pts.size() - 2]).normalized()
		var en := Vector2(-ed.y, ed.x)
		shape(c, PackedVector2Array([e - en * 5.0, e + en * 5.0, e + ed * 30.0 + en * 11.0, e + ed * 34.0, e + ed * 30.0 - en * 11.0]), Color("#e04434"), 3.0)
	var gd := round_pts(PackedVector2Array([g + nr * 26 - d * 5, g + nr * 31 + d * 7, g + d * 9, g - nr * 31 + d * 7, g - nr * 26 - d * 5, g - d * 8]), true, 3)
	shape(c, gd, Color("#d9a43a"), 3.5)
	c.draw_line(g - d * 6, g - d * 56, inkof(Color("#6a2a22")), 19.0, true)
	c.draw_line(g - d * 6, g - d * 56, Color("#7c3026"), 12.0, true)
	for i in 4:
		var q := g - d * (14.0 + i * 11.0)
		c.draw_line(q + nr * 6, q - nr * 6 - d * 5, Color("#4a1a16"), 2.5, true)
	c.draw_circle(g - d * 61, 11.0, inkof(Color("#d9a43a")), true, -1.0, true)
	c.draw_circle(g - d * 61, 7.5, Color("#e8b84a"), true, -1.0, true)


# vỏ kiếm ở hông (luôn ở lại khi rút kiếm)
func _d_vo(c: Node2D, v: Dictionary) -> void:
	var d: Vector2 = v.sheath
	var nr := Vector2(-d.y, d.x)
	var L := BLADE + 8.0
	var body := PackedVector2Array([nr * 15, d * (L - 10) + nr * 13, d * L, d * (L - 10) - nr * 13, -nr * 15])
	shape(c, round_pts(body, true, 3), Color("#3b2a4a"), 4.0)
	c.draw_line(d * 12 + nr * 7, d * (L - 22) + nr * 7, Color(0.55, 0.42, 0.65, 0.7), 3.0, true)
	for k: float in [0.0, 0.55]:
		var q := d * (L * k + 4.0)
		shape(c, PackedVector2Array([q + nr * 17, q + nr * 17 + d * 16, q - nr * 17 + d * 16, q - nr * 17]), Color("#d9a43a"), 3.0)
	shape(c, round_pts(PackedVector2Array([d * (L - 26) + nr * 14, d * (L - 4), d * (L - 26) - nr * 14]), true, 3), Color("#d9a43a"), 3.0)


# ô giấy dầu: cán dựng theo phương thẳng đứng thật (nghiêng theo gió + quán tính), tán phủ trên đầu
func _o_geo(n: Node2D, v: Dictionary) -> Dictionary:
	var ang: float = v.ang
	var up := wdir(n, Vector2.UP.rotated(ang))
	var rt := wdir(n, Vector2.RIGHT.rotated(ang))
	var sh: float = v.shaft
	var top := up * sh
	return {"up": up, "rt": rt, "top": top, "rimc": top - up * 78.0}


func _draw_umbrella(c: Node2D, v: Dictionary) -> void:
	var g := _o_geo(c, v)
	var up: Vector2 = g.up
	var rt: Vector2 = g.rt
	var top: Vector2 = g.top
	var rc: Vector2 = g.rimc
	var R := 250.0
	var col: Color = v.col
	# cán + móc cầm
	c.draw_line(-up * 40.0, top, inkof(Color("#6b3e1f")), 11.0, true)
	c.draw_line(-up * 40.0, top, Color("#9a6232"), 6.0, true)
	var hook := PackedVector2Array()
	for i in 9:
		var a := PI * float(i) / 8.0
		hook.append(-up * 40.0 - rt * (cos(a) - 1.0) * 14.0 - up * sin(a) * 14.0)
	c.draw_polyline(hook, inkof(Color("#6b3e1f")), 10.0, true)
	c.draw_polyline(hook, Color("#9a6232"), 5.0, true)
	# tán: vòm + mép lượn sóng giữa 8 nan
	var poly := PackedVector2Array()
	for i in 21:
		var k := -1.0 + 2.0 * float(i) / 20.0
		poly.append(rc + rt * R * k + up * 78.0 * (1.0 - k * k * 0.92))
	for i in range(16, -1, -1):
		var k := -1.0 + 2.0 * float(i) / 16.0
		var sc := absf(sin(float(i) * PI / 2.0))
		poly.append(rc + rt * R * k + up * sc * 12.0)
	shape(c, poly, col, 5.0)
	clip_fill(c, poly, PackedVector2Array([top, rc + rt * R * 1.3 - up * 20.0, rc + rt * R * 1.3 + up * 120.0]), col.darkened(0.16))
	clip_fill(c, poly, PackedVector2Array([rc - rt * R * 1.2 + up * 26.0, rc + rt * R * 1.2 + up * 26.0, rc + rt * R * 1.2 + up * 40.0, rc - rt * R * 1.2 + up * 40.0]), Color("#c8372d"))
	for i in 9:
		var k := -1.0 + 2.0 * float(i) / 8.0
		c.draw_line(top, rc + rt * R * k + up * (1.0 - absf(k)) * 8.0, Color(inkof(col), 0.55), 2.5, true)
	puff(c, [[top + up * 6.0, 10.0]], Color("#9a6232"), 3.0, 0.3)


func _draw_lantern_stick(c: Node2D, v: Dictionary) -> void:
	var sd := wdir(c, v.lockdir)
	var tip := sd * 150.0
	c.draw_line(-sd * 30.0, tip, inkof(Color("#6b4a2a")), 11.0, true)
	c.draw_line(-sd * 30.0, tip, Color("#8a6236"), 6.0, true)
	if not v.has("rope"):
		return
	var pts := PackedVector2Array()
	for wp in v.rope:
		pts.append(from_w(c, wp))
	c.draw_polyline(pts, ink, 2.5, true)
	var e := pts[pts.size() - 1]
	var ax := (e - pts[pts.size() - 2]).normalized()
	var nr := Vector2(-ax.y, ax.x)
	var r := 40.0
	var ctr := e + ax * r
	var col: Color = v.get("lcol", Color(1.55, 0.5, 0.24))
	var fl := 0.9 + 0.1 * sin(t * 11.0) * sin(t * 7.3)
	var body := PackedVector2Array()
	for i in 24:
		var a := i * TAU / 24.0
		body.append(ctr + nr * cos(a) * r * 1.05 + ax * sin(a) * r * 1.15)
	shape(c, body, col * fl, 4.0, Color("#3a1410"))
	var core := PackedVector2Array()       # lõi sáng (nến bên trong) — giấy sáng dần vào giữa, nan vẫn đọc được
	for i in 24:
		var a := i * TAU / 24.0
		core.append(ctr + nr * cos(a) * r * 0.62 + ax * (sin(a) * r * 0.78 + r * 0.1))
	c.draw_colored_polygon(core, Color(col.lerp(Color(1.6, 1.35, 0.85), 0.55) * fl, 0.75))
	for k: float in [-0.75, -0.38, 0.0, 0.38, 0.75]:
		var q := PackedVector2Array([ctr - ax * r * 1.1, ctr + nr * k * r * 1.08, ctr + ax * r * 1.1])
		c.draw_polyline(round_pts(q, false, 3), Color(0.42, 0.1, 0.05, 0.8), 2.2, true)
	for sy: float in [-1.0, 1.0]:
		var cp := ctr + ax * sy * r * 1.12
		shape(c, PackedVector2Array([cp + nr * r * 0.5 - ax * 6, cp + nr * r * 0.5 + ax * 6, cp - nr * r * 0.5 + ax * 6, cp - nr * r * 0.5 - ax * 6]), Color("#2a1a12"), 0.0)
	var tb := ctr + ax * r * 1.2
	c.draw_line(tb, tb + ax * 26.0 + nr * sin(t * 3.0) * 4.0, Color("#e8b030"), 4.0, true)


# hồ lô: trục từ cổ xuống đáy
func _gourd_axis(n: Node2D, v: Dictionary) -> Vector2:
	if v.at == "hong" and v.has("rope"):
		var pts: Array = v.rope
		var a: Vector2 = pts[0]
		var b: Vector2 = pts[1]
		return wdir(n, (b - a).normalized())
	var ax := Vector2(0, 1).rotated(deg_to_rad(v.grip))
	var lk: float = v.lock
	if lk > 0.0:
		ax = ax.lerp(wdir(n, v.lockdir), lk).normalized()
	return ax


func _draw_gourd(c: Node2D, v: Dictionary) -> void:
	var ax := _gourd_axis(c, v)
	var nr := Vector2(-ax.y, ax.x)
	var o := Vector2.ZERO
	if v.at == "hong" and v.has("rope"):
		var pts: Array = v.rope
		o = from_w(c, pts[1])
		c.draw_line(Vector2.ZERO, o, Color("#b8322c"), 3.5, true)
	var col := Color("#d89a3a")
	puff(c, [[o + ax * 70.0, 34.0], [o + ax * 20.0, 21.0]], col, 4.0, 0.35)
	c.draw_line(o + ax * 40.0 + nr * 14.0, o + ax * 40.0 - nr * 14.0, Color("#b8322c"), 6.0, true)
	c.draw_line(o + ax * 42.0, o + ax * 62.0 + nr * 6.0, Color("#b8322c"), 3.5, true)
	var mouth := o - ax * 4.0
	shape(c, PackedVector2Array([mouth + nr * 7, mouth + nr * 6 - ax * 14, mouth - nr * 6 - ax * 14, mouth - nr * 7]), Color("#8a5a2a"), 3.0)
	var pr: float = v.pour
	if pr > 0.01 and v.has("aim"):
		var tgt := from_w(c, to_w(v.a.node.J["head"], v.aim))   # aim: toạ độ đầu (miệng ≈ (0,-30))
		var m0 := mouth - ax * 14.0
		var mid := (m0 + tgt) * 0.5 + nr * 6.0
		var st := round_pts(PackedVector2Array([m0, mid, tgt]), false, 4)
		c.draw_polyline(st, Color(0.95, 0.72, 0.3, 0.85 * pr), 6.0, true)
		c.draw_polyline(st, Color(1.0, 0.92, 0.6, 0.7 * pr), 2.0, true)


func _glow_props(c: Node2D) -> void:
	for v in props:
		match v.k:
			"kiem":
				var tr: Array = v.trail
				if v.trail_on and tr.size() > 2:
					for i in range(tr.size() - 1):
						var a: Array = tr[i]
						var b: Array = tr[i + 1]
						var al := 0.42 * (1.0 - float(i) / tr.size())
						var q := PackedVector2Array([a[0], b[0], b[1], a[1]])
						c.draw_colored_polygon(q, Color(1.1, 1.2, 1.5, al))
				var gk: float = (t - float(v.glint)) / 0.35
				if gk >= 0.0 and gk <= 1.0:
					var gw: Vector2 = v.guardw
					var tw: Vector2 = v.tipw
					var p := gw.lerp(tw, gk)
					var s := 34.0 * sin(gk * PI)
					blob(c, p, s * 3.0, Color(1.0, 1.0, 1.0, 0.45))
					c.draw_line(p - Vector2(s, 0), p + Vector2(s, 0), Color(1.8, 1.8, 2.0), 3.0, true)
					c.draw_line(p - Vector2(0, s * 1.4), p + Vector2(0, s * 1.4), Color(1.8, 1.8, 2.0), 3.0, true)
			"den":
				var lw: Vector2 = v.lw
				var fl := 0.92 + 0.08 * sin(t * 11.0) * sin(t * 7.3)
				blob(c, lw, 420.0 * fl, Color(1.0, 0.65, 0.35, 0.2))
				blob(c, lw, 110.0, Color(1.2, 0.8, 0.45, 0.22))
				var gy := ground_y + 10.0
				var dist := clampf((gy - lw.y) / 400.0, 0.0, 1.0)
				flat_blob(c, Vector2(lw.x, gy), 380.0, 0.2, Color(1.0, 0.6, 0.3, 0.32 * (1.0 - dist * 0.5)))
