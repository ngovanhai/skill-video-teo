extends "res://engine.gd"
# THÁI CỰC QUYỀN (12 s): rừng trúc sau núi Võ Đang lúc rạng sáng, sương lục xám.
# A Tam (Đại Lực Kim Cương Chỉ) liên tiếp phóng chỉ lực cam đỏ. Trương Vô Kỵ mới học Thái Cực, tay vẽ vòng tròn:
# mỗi luồng chỉ lực bị dính tay, dẫn đi theo đường chữ S âm dương rồi cuộn thành vòng tơ quanh hai bàn tay (mượn lực).
# Đỉnh: A Tam dồn toàn lực, Vô Kỵ chỉ đẩy nhẹ, cuộn tơ bung ngược quấn quanh người A Tam, A Tam xoay như con quay lùi xa
# rồi đứng lảo đảo chóng mặt (không ngã nằm, không thương tích).
# Thẻ chiêu: Trương Vô Kỵ · A Tam · dính tay dẫn lực theo chữ S, cuộn tơ rồi trả ngược · ngọc lam vs cam đỏ ·
#            rừng trúc rạng sáng sương lục · đẩy nhẹ, tơ bung, đối thủ xoay con quay

const COL := Color(0.35, 1.3, 1.1)
const HOT := Color(1.3, 2.2, 1.9)
const FOE_COL := Color(1.6, 0.45, 0.15)
const FOE_HOT := Color(2.2, 1.15, 0.5)
const BEATS := [2.4, 3.4, 4.4]
const BIG := 5.35
const PEAK := 6.2
const HX := 520.0
const FX := 1380.0
const R := 108.0

var beat_i := 0
var caught_i := 0
var big_caught := false
var hit := false
var landed := false
var x_hit := 0.0
var bamboo: Array = []


func _setup() -> void:
	sky_cols = [Color("#24443e"), Color("#5f8c7a"), Color("#d2dfb6")]
	moon = Vector2(1620, 210)
	moon_col = Color(1.35, 1.3, 1.05)
	moon_glow = Color(0.85, 1.0, 0.8, 0.22)
	moon_craters = false
	n_stars = 0
	far_col = Color("#4c7466")
	near_col = Color("#2f5446")
	mist_col = Color(0.7, 0.9, 0.8, 0.26)
	ground_cols = [Color("#7d8a80"), Color("#3a4440"), Color("#b9c6b8")]
	slowmo = [PEAK - 0.05, PEAK + 0.6, 0.3]
	title = "THÁI CỰC QUYỀN"
	subtitle = "Trương Vô Kỵ · lấy nhu khắc cương"
	title_at = 8.5
	title_col = HOT
	set_char(hero, "truong-vo-ky")
	set_char(foe, "a-tam")
	hero.pos = Vector2(HX, GROUND)
	foe.pos = Vector2(FX, GROUND)
	hero.col = COL
	foe.col = FOE_COL
	var r := RandomNumberGenerator.new()
	r.seed = 88
	for i in 9:
		var x := -360.0 + i * 330.0 + r.randf_range(-60, 60)
		bamboo.append([x, r.randf_range(12, 18), r.randf_range(0.0, TAU), r.randf_range(0.35, 0.75)])
	cue(1.0, "lib-riser", 0.7)
	cue(BIG - 0.25, "lib-riser", 0.5)
	cue(PEAK - 0.3, "lib-whoosh-cinematic", 0.9)


# ---------------------------------------------------------------- đường tơ

func _loop(c: Vector2, rr: float, rot: float, times := 1) -> PackedVector2Array:
	# vòng âm dương: nửa vòng ngoài bên trái (trên -> dưới), rồi chữ S qua tâm về lại đỉnh
	var pts := PackedVector2Array()
	for k in times:
		for i in 25:
			var a := -PI * 0.5 - PI * float(i) / 24.0
			pts.append(c + Vector2(cos(a), sin(a)).rotated(rot) * rr)
		for i in 13:
			var a := PI * 0.5 - PI * float(i) / 12.0
			pts.append(c + (Vector2(0, rr * 0.5) + Vector2(cos(a), sin(a)) * rr * 0.5).rotated(rot))
		for i in 13:
			var a := PI * 0.5 + PI * float(i) / 12.0
			pts.append(c + (Vector2(0, -rr * 0.5) + Vector2(cos(a), sin(a)) * rr * 0.5).rotated(rot))
	return pts


func _line(a: Vector2, b: Vector2, bow: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var n := maxi(4, int(a.distance_to(b) / 14.0))
	var nrm := (b - a).orthogonal().normalized()
	for i in n + 1:
		var k := float(i) / n
		pts.append(a.lerp(b, k) + nrm * sin(k * PI) * bow)
	return pts


func _cum(pts: PackedVector2Array) -> PackedFloat32Array:
	var c := PackedFloat32Array([0.0])
	for i in range(1, pts.size()):
		c.append(c[i - 1] + pts[i].distance_to(pts[i - 1]))
	return c


func _sub(pts: PackedVector2Array, s0: float, s1: float) -> PackedVector2Array:
	var c := _cum(pts)
	var out := PackedVector2Array()
	if s1 <= s0:
		return out
	for i in pts.size():
		if c[i] >= s0 and c[i] <= s1:
			out.append(pts[i])
	return out


func _center() -> Vector2:
	return (hero.handF + hero.handB) * 0.5 + Vector2(46, -6)


func _spin() -> float:
	return t * 2.2


# tơ của nhịp i (cả đường đi): đoạn thẳng từ ngón tay A Tam tới đỉnh vòng, rồi vòng âm dương
func _path(src: Vector2, times: int) -> Array:
	var c := _center()
	var loop := _loop(c, R, _spin(), times)
	var st := _line(src, loop[0], -40.0)
	var lst: float = _cum(st)[st.size() - 1]
	var all := st.duplicate()
	all.append_array(loop)
	var ltot: float = _cum(all)[all.size() - 1]
	return [all, lst, ltot]


func _thread(c: Node2D, pts: PackedVector2Array, col: Color, hot: Color, w: float) -> void:
	if pts.size() < 2:
		return
	c.draw_polyline(pts, col * Color(1, 1, 1, 0.18), w * 3.2)
	c.draw_polyline(pts, col, w)
	c.draw_polyline(pts, hot, w * 0.35)


# ---------------------------------------------------------------- truyện

func _story(_dt: float) -> void:
	# ---- Vô Kỵ: vân thủ, hai tay vẽ vòng
	var g := smooth(1.0, 1.8, t)
	var ph := t * 3.1
	var cloud := {"uaF": -62.0 + 34.0 * sin(ph), "faF": -84.0 + 26.0 * cos(ph), "uaB": -30.0 + 34.0 * sin(ph + PI), "faB": -96.0 + 26.0 * cos(ph + PI),
		"torso": 4.0 * sin(ph * 0.5), "head": 2.0, "thF": -24, "shF": 28, "thB": 24, "shB": -28, "all": [0, 0, 26]}
	var settle := smooth(9.0, 10.0, t)
	hero.gather = 0.0
	hero.push = smooth(PEAK - 0.12, PEAK, t) * (1.0 - smooth(7.6, 9.0, t)) * 0.8
	hero.extra = [[cloud, g * (1.0 - hero.push) * (1.0 - settle)]]
	hero.lean = hero.push * 0.25
	hero.crouch = g * 0.35 * (1.0 - settle)
	hero.aura = g * 0.35 + smooth(BIG, PEAK, t) * 0.4 - smooth(7.0, 9.0, t) * 0.75
	hero.expr = "ngai" if t > 8.4 else ("quyet-tam" if t > 1.0 else "binh")

	# ---- A Tam: chỉ lực
	if not hit:
		var jab := 0.0
		for b in BEATS:
			jab = maxf(jab, pulse(b - 0.12, b + 0.12, 0.3, t))
		var big := smooth(BIG - 0.6, BIG - 0.1, t)
		foe.extra = [["point", maxf(jab, smooth(BIG - 0.1, BIG, t))]]
		foe.gather = big * (1.0 - smooth(BIG - 0.1, BIG, t))
		foe.lean = jab * 0.4 + smooth(BIG - 0.1, BIG, t) * 0.5
		foe.aura = 0.35 + big * 0.6
		foe.expr = "soc" if t > 4.6 else ("gian" if t < 3.2 else "quyet-tam")
		# bị kéo nhẹ về phía Vô Kỵ sau mỗi lần bị dẫn lực
		foe.pos.x = FX - 22.0 * caught_i - (40.0 if big_caught else 0.0)
	pose(hero, 0.0)
	pose(foe, 0.0)

	if g > 0.05 and t < 2.3:
		orbit(hero, rng.randf_range(90, 220), rng.randf_range(2.0, 3.2), 200, rng.randf_range(2, 4), HOT, 2.3)

	# ---- mỗi nhịp: chỉ lực bắn ra, bị dính tay ở đỉnh vòng
	if beat_i < BEATS.size() and t >= BEATS[beat_i]:
		sfx("lib-whoosh-short", 0.6)
		beat_i += 1
	if caught_i < BEATS.size() and t >= BEATS[caught_i] + 0.22:
		var at := _center() + Vector2(0, -R).rotated(_spin())
		add_ring(at, 150, HOT, 6, 0.35)
		burst(at, 26, 200, 700, FOE_HOT, HOT, 300.0, 1.6, -PI, 0.0)
		shake = maxf(shake, 11.0)
		sfx("lib-impact-bass-2", 0.55)
		sfx("lib-glitch-1", 0.35)
		caught_i += 1
	if not big_caught and t >= BIG + 0.2:
		big_caught = true
		add_ring(_center(), 260, HOT, 8, 0.5)
		add_ring(Vector2(hero.pos.x, GROUND), 420, COL, 6, 0.7, 0.2)
		shake = maxf(shake, 14.0)
		sfx("lib-impact-bass-2", 0.7)
		sfx("lib-chime", 0.4)

	# ---- đỉnh: đẩy nhẹ, cuộn tơ bung ngược
	if t >= PEAK and not hit:
		hit = true
		x_hit = foe.pos.x
		foe.expr = "soc"
		flash = 0.42
		flash_col = Color(0.85, 1.0, 0.95)
		shake = 26.0
		var at: Vector2 = foe.pos + Vector2(0, -170)
		add_ring(_center(), 560, HOT, 16, 0.7)
		add_ring(at, 420, FOE_HOT, 12, 0.6)
		add_ring(Vector2(at.x, GROUND), 700, COL, 9, 0.9, 0.2)
		burst(at, 120, 300, 1400, HOT, FOE_HOT, 500.0, 1.1)
		sfx("lib-impact-bass-1", 1.0)
		sfx("lib-impact-bass-2", 1.0)
		for i in 40:
			var p := Vector2(rng.randf_range(200, 1700), rng.randf_range(80, 500))
			emit("leaf", p, Vector2(rng.randf_range(250, 700), rng.randf_range(-80, 120)), rng.randf_range(2.5, 4.0), rng.randf_range(10, 16), Color("#9cbf6a"), 60.0, 0.6)
	# ---- hậu quả: xoay như con quay lùi xa, rồi đứng lảo đảo
	if hit:
		var k := clampf((t - PEAK - 0.15) / 1.7, 0.0, 1.0)
		var sp := 30.0 * ease_out(k)
		var fc := cos(sp)
		foe.face = -1.0 * signf(fc) * maxf(0.12, absf(fc)) if absf(fc) > 0.001 else -0.12
		foe.pos = Vector2(lerpf(x_hit, 1470.0, ease_out(k)), GROUND - sin(k * PI) * 26.0)
		var dz := smooth(PEAK + 1.7, PEAK + 2.2, t) * (1.0 - smooth(10.6, 11.6, t))
		foe.rot = sin(t * 4.2) * 0.13 * dz + sin(sp * 2.0) * 0.06 * (1.0 - k)
		foe.extra = [["raise", 0.55 * (1.0 - k) + 0.25 * dz]]
		foe.gather = 0.0
		foe.push = 0.0
		foe.lean = -0.3 * dz
		foe.hurt = 0.25 * (1.0 - k)
		foe.aura = 0.0
		foe.expr = "ko" if t > PEAK + 0.5 else "soc"
		if k >= 1.0 and not landed:
			landed = true
			foe.face = -1.0
			shake = maxf(shake, 12.0)
			sfx("lib-impact-bass-2", 0.5)
			for i in 18:
				emit("smoke", Vector2(1470 + rng.randf_range(-90, 120), GROUND), Vector2(rng.randf_range(-150, 160), -rng.randf_range(20, 110)), 1.8, rng.randf_range(36, 70), Color(0.55, 0.62, 0.58, 0.4))
		if landed:
			foe.face = -1.0
	# lá trúc rơi nhẹ suốt cảnh
	if int(rt * 30.0) % 4 == 0:
		emit("leaf", Vector2(rng.randf_range(-100, 2000), -30), Vector2(rng.randf_range(-40, 60), rng.randf_range(60, 120)), 7.0, rng.randf_range(8, 13), Color("#7fa65a"), 0.0, 0.0)


func _cam() -> Array:
	var c := CENTER + Vector2(0, 20)
	var z := 1.0
	var k1 := smooth(0.9, 1.8, t) * (1.0 - smooth(2.2, 2.7, t))
	c = c.lerp(hero.pos + Vector2(170, -230), k1)
	z = lerpf(z, 1.38, k1)
	var k2 := smooth(2.7, 3.3, t) * (1.0 - smooth(5.0, 5.4, t))       # dõi theo luồng chỉ lực: lia ngang thấp
	c = c.lerp(Vector2(lerpf(1040.0, 860.0, smooth(2.7, 5.0, t)), 610), k2)
	z = lerpf(z, 1.12, k2)
	var k3 := smooth(5.1, 5.6, t) * (1.0 - smooth(PEAK - 0.05, PEAK + 0.25, t))  # sát cuộn tơ
	c = c.lerp(_center() + Vector2(60, 20), k3)
	z = lerpf(z, 1.42, k3)
	var k4 := smooth(PEAK - 0.05, PEAK + 0.4, t) * (1.0 - smooth(8.0, 9.4, t))   # theo con quay
	c = c.lerp(Vector2(lerpf(1150.0, 1240.0, smooth(PEAK, 8.0, t)), 590), k4)
	z = lerpf(z, 1.18, k4)
	var k5 := smooth(8.2, 10.0, t)
	c = c.lerp(Vector2(990, 580), k5)
	return [c, z]


# ---------------------------------------------------------------- vẽ

func _fx_ground(c: Node2D) -> void:
	# thân trúc sau lưng hai người
	for b in bamboo:
		var x: float = b[0] + sin(rt * 0.7 + b[2]) * 6.0
		var w: float = b[1]
		var col := Color("#3f6a52").lerp(Color("#6f9a74"), b[3])
		c.draw_rect(Rect2(x - w * 0.5, -400, w, GROUND + 400), col)
		for j in 9:
			var y := GROUND - 60.0 - j * 130.0 - fmod(b[2] * 40.0, 60.0)
			c.draw_line(Vector2(x - w * 0.6, y), Vector2(x + w * 0.6, y), col.darkened(0.35), 3.0)
	c.draw_rect(Rect2(-600, GROUND - 6, W + 1200, 8), Color(0.55, 0.65, 0.6, 0.25))
	# vòng âm dương trên sân đá dưới chân Vô Kỵ
	var g := smooth(1.0, 2.0, t) * (1.0 - smooth(9.0, 10.5, t))
	if g > 0.0:
		var p := Vector2(hero.pos.x + 20, GROUND + 14)
		c.draw_set_transform(p, 0.0, Vector2(1.0, 0.18))
		var rr := 260.0
		c.draw_arc(Vector2.ZERO, rr, 0, TAU, 72, Color(0.75, 1.0, 0.9, 0.35 * g), 10.0)
		var s := _loop(Vector2.ZERO, rr, -_spin() * 0.4)
		c.draw_polyline(s, Color(0.75, 1.0, 0.9, 0.3 * g), 7.0)
		c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _fx_norm(c: Node2D) -> void:
	for q in parts:
		if q.k == "leaf":
			var a: float = minf(1.0, q.life / q.max * 3.0)
			var col: Color = q.col
			col.a = 0.85 * a
			var s: float = q.size
			c.draw_set_transform(q.p, q.rot * 1.3, Vector2(1.0, 0.32))
			c.draw_colored_polygon(PackedVector2Array([Vector2(-s, 0), Vector2(0, -s * 0.9), Vector2(s * 1.4, 0), Vector2(0, s * 0.9)]), col)
			c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _fx_add(c: Node2D) -> void:
	var cc := _center()
	# đĩa âm dương mờ giữa hai bàn tay
	var dk := smooth(1.4, 2.4, t) * (1.0 - smooth(PEAK, PEAK + 0.3, t))
	if dk > 0.0:
		var rd := R * (1.0 + 0.18 * float(caught_i) + (0.35 if big_caught else 0.0))
		var half := _loop(cc, rd, _spin())
		half.resize(25 + 13 + 13)
		c.draw_colored_polygon(half, COL * Color(1, 1, 1, 0.22 * dk))
		c.draw_arc(cc, rd, 0, TAU, 64, COL * Color(1, 1, 1, 0.75 * dk), 3.0)
		c.draw_circle(cc + Vector2(0, -rd * 0.5).rotated(_spin()), rd * 0.12, Color(1.6, 1.0, 0.6, 0.6 * dk))
		c.draw_circle(cc + Vector2(0, rd * 0.5).rotated(_spin()), rd * 0.12, HOT * Color(1, 1, 1, 0.6 * dk))
	# các luồng chỉ lực đang bị dẫn
	for i in BEATS.size():
		var b: float = BEATS[i]
		var age := t - b
		if age < 0.0 or age > 0.85:
			continue
		var pa: Array = _path(foe.handF, 1)
		var pts: PackedVector2Array = pa[0]
		var lst: float = pa[1]
		var ltot: float = pa[2]
		var sh := lst * clampf(age / 0.22, 0.0, 1.0) + (ltot - lst) * smooth(0.22, 0.75, age)
		var stl := lst * smooth(0.25, 0.5, age) + (ltot - lst) * smooth(0.5, 0.85, age)
		var col := FOE_COL.lerp(COL, smooth(0.3, 0.8, age))
		_thread(c, _sub(pts, stl, sh), col, FOE_HOT.lerp(HOT, smooth(0.3, 0.8, age)), 5.0)
	# luồng toàn lực: cuộn hai vòng
	var ab := t - BIG
	if ab >= 0.0 and ab < PEAK - BIG:
		var pa2: Array = _path(foe.handF if not hit else foe.pos, 2)
		var p2: PackedVector2Array = pa2[0]
		var l2: float = pa2[1]
		var lt2: float = pa2[2]
		var sh2 := l2 * clampf(ab / 0.2, 0.0, 1.0) + (lt2 - l2) * smooth(0.2, 0.7, ab)
		var st2 := l2 * smooth(0.25, 0.6, ab)
		_thread(c, _sub(p2, st2, sh2), FOE_COL.lerp(COL, smooth(0.4, 0.8, ab)), FOE_HOT, 7.0)
	# cuộn tơ quanh tay: mỗi nhịp thêm một vòng
	var wound := caught_i + (3 if big_caught else 0)
	var wk := 1.0 - smooth(PEAK, PEAK + 0.2, t)
	if wound > 0 and wk > 0.0:
		for i in wound:
			var rr := R * (0.42 + 0.09 * i)
			var rot := _spin() * (1.0 + 0.25 * i) + i * 0.9
			c.draw_set_transform(cc, rot, Vector2(1.0, 0.45))
			var mix := float(i) / maxf(1.0, float(wound))
			c.draw_arc(Vector2.ZERO, rr, 0, TAU, 48, FOE_COL.lerp(COL, mix) * Color(1, 1, 1, 0.9 * wk), 4.0)
			c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		blob(c, cc, 70.0 + 14.0 * wound, HOT * Color(1, 1, 1, 0.12 * wk))
	# đỉnh: tơ bung ngược, quấn xoắn quanh A Tam
	if hit:
		var ku := smooth(PEAK, PEAK + 0.3, t)
		var kt := smooth(PEAK + 0.3, PEAK + 1.8, t)
		var fpos: Vector2 = foe.pos
		var pts := _line(cc, fpos + Vector2(-40, -190), 30.0)
		var sp := 30.0 * ease_out(clampf((t - PEAK - 0.15) / 1.7, 0.0, 1.0))
		for j in 60:
			var a := j * 0.32 + sp
			pts.append(fpos + Vector2(cos(a) * 78.0, -300.0 + j * 4.6 + sin(a) * 18.0))
		var L: float = _cum(pts)[pts.size() - 1]
		var fade := 1.0 - smooth(PEAK + 1.4, PEAK + 2.0, t)
		if fade > 0.0:
			_thread(c, _sub(pts, L * kt, L * ku), COL.lerp(FOE_COL, 0.35) * Color(1, 1, 1, fade), HOT * Color(1, 1, 1, fade), 6.0)
		if t < PEAK + 0.25:
			blob(c, cc, 150.0, HOT * Color(1, 1, 1, 0.3))
	# sao chóng mặt quanh đầu A Tam
	var dz := smooth(PEAK + 1.6, PEAK + 2.1, t) * (1.0 - smooth(10.8, 11.8, t))
	if dz > 0.0:
		var hp: Vector2 = foe.head + Vector2(0, -110)
		for i in 3:
			var a := rt * 4.0 + i * TAU / 3.0
			var p := hp + Vector2(cos(a) * 70.0, sin(a) * 18.0)
			_star(c, p, 13.0, Color(2.0, 1.6, 0.6, dz))
		c.draw_set_transform(hp, 0.0, Vector2(1.0, 0.26))
		c.draw_arc(Vector2.ZERO, 70.0, 0, TAU, 40, Color(1.4, 1.1, 0.5, 0.35 * dz), 2.5)
		c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _star(c: Node2D, p: Vector2, r: float, col: Color) -> void:
	var pts := PackedVector2Array()
	for i in 10:
		var a := -PI * 0.5 + i * PI / 5.0
		pts.append(p + Vector2(cos(a), sin(a)) * (r if i % 2 == 0 else r * 0.45))
	c.draw_colored_polygon(pts, col)
