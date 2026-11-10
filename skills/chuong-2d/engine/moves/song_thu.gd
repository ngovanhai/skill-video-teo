extends "res://engine.gd"
# SONG THỦ HỖ BÁC (12.5 s): bãi cát đảo Đào Hoa buổi sớm, biển ngọc lam, hoa đào rơi.
# Thẻ chiêu:
#   người dùng   Quách Tĩnh (Xạ Điêu), học Song Thủ Hỗ Bác (Tả Hữu Hỗ Bác) của Chu Bá Thông trên đảo Đào Hoa
#   đối thủ      Chu Bá Thông, Lão Ngoan Đồng, người nghĩ ra môn này (cùng đấu chơi, không thù oán)
#   cơ chế       "tay trái vẽ vuông, tay phải vẽ tròn" CÙNG LÚC: một tay vạch hình vuông ngọc lam, tay kia vạch
#                vòng tròn hồng đào; vẽ xong hai hình bay ra thành hai đòn khác nhau (vuông trượt như bức tường,
#                tròn lăn như bánh xe). Chu Bá Thông thử bắt chước, tay vẽ nguệch ngoạc. Đỉnh: vuông và tròn
#                lồng vào nhau thành dấu "quy củ" (tròn trong vuông) rồi đánh ra.
#   cặp màu      ngọc lam (vuông) + hồng đào (tròn) vs tím nhạt bạc (Chu Bá Thông)
#   bối cảnh     sớm mai, trời hồng đào nhạt, biển ngọc lam, cát vàng sáng, cành đào bên trái
#   đỉnh         slowmo, dấu quy củ đập vào Chu Bá Thông; hậu quả: lão lăn tròn như bánh xe rồi bật dậy, cười vỗ tay

const COL := Color(0.3, 1.35, 1.2)        # ngọc lam (vuông)
const HOT := Color(1.1, 2.2, 1.9)
const PEACH := Color(1.7, 0.6, 0.75)      # hồng đào (tròn)
const PEACH_HOT := Color(2.3, 1.3, 1.4)
const FOE_COL := Color(0.9, 0.85, 1.4)    # tím nhạt bạc
const TRACE := [[2.35, 3.05], [3.75, 4.45], [5.2, 5.9]]   # ba lần vẽ
const FLY := 0.55                                          # thời gian hình bay tới đối thủ
const PEAK := 6.1
const ROLL_END := 1470.0

const DRAWP := {"uaF": -70, "faF": -20, "uaB": -120, "faB": -15, "torso": -4, "head": -2, "thF": -26, "shF": 28, "thB": 26, "shB": -14, "all": [0, 0, 18]}
const TUCK := {"uaF": -40, "faF": -110, "uaB": -40, "faB": -110, "torso": 40, "head": 30, "thF": -110, "shF": 130, "thB": -100, "shB": 130, "all": [0, 0, 60]}
const CLAP := {"uaF": -95, "faF": -40, "uaB": -95, "faB": -40, "torso": -6, "head": -10, "thF": -14, "shF": 14, "thB": 14, "shB": -14, "all": [0, 0, 4]}
const SCRIB := {"uaF": -100, "faF": -30, "uaB": -130, "faB": -20, "torso": 4, "head": 6, "all": [0, 0, 10]}

var shots: Array = []        # {kind "sq"/"ci"/"qc", p0, t0, s, done}
var fired := [false, false, false]
var hit := false
var x_hit := 0.0
var petals: Array = []
var hops := 0
var up_done := false


func _setup() -> void:
	sky_cols = [Color("#e8a9a0"), Color("#f6d6c4"), Color("#f8ecd8")]
	moon_on = true
	moon = Vector2(1520, 300)
	moon_col = Color(1.3, 1.05, 0.85)
	moon_glow = Color(1.0, 0.8, 0.6, 0.35)
	moon_craters = false
	n_stars = 0
	far_col = Color("#6aa9b0")
	near_col = Color("#2f8c96")
	mist_col = Color(1.0, 0.95, 0.92, 0.2)
	ground_cols = [Color("#e9d29a"), Color("#c49a5e"), Color("#fff4d8")]
	slowmo = [PEAK - 0.08, PEAK + 0.55, 0.3]
	title = "SONG THỦ HỖ BÁC"
	subtitle = "Xạ Điêu Anh Hùng Truyện · Quách Tĩnh"
	title_at = 8.5
	title_col = HOT
	set_char(hero, "quach-tinh")
	set_char(foe, "chu-ba-thong")
	hero.pos = Vector2(520, GROUND)
	foe.pos = Vector2(1290, GROUND)
	hero.col = COL
	foe.col = FOE_COL
	hero.node.hand_form = {"F": "chi", "B": "chi"}
	for i in 34:
		petals.append({"p": Vector2(rng.randf_range(-200, W), rng.randf_range(-300, 800)), "s": rng.randf_range(5, 9),
			"v": Vector2(rng.randf_range(30, 80), rng.randf_range(40, 90)), "ph": rng.randf() * TAU})
	cue(1.0, "lib-riser", 0.7)
	for tr in TRACE:
		cue(tr[0], "lib-sparkle", 0.4)
	cue(3.05, "lib-whoosh", 0.6)
	cue(4.45, "lib-whoosh", 0.7)
	cue(5.75, "lib-chime", 0.45)
	cue(PEAK - 0.3, "lib-whoosh-cinematic", 0.9)


# tâm hình vuông / tròn trước mặt Quách Tĩnh (vẽ ở lần i)
func _sq_c(i: int) -> Vector2:
	return hero.pos + Vector2(245, -300) if i < 2 else hero.pos + Vector2(285, -220)


func _ci_c(i: int) -> Vector2:
	return hero.pos + Vector2(250, -130) if i < 2 else hero.pos + Vector2(285, -220)


func _sz(i: int) -> float:
	return [62.0, 74.0, 118.0][i]


func _trace_k(i: int) -> float:
	var tr: Array = TRACE[i]
	return clampf((t - tr[0]) / (tr[1] - tr[0]), 0.0, 1.0)


# điểm trên chu vi hình vuông (k 0..1), bắt đầu góc trên trái, chạy thuận chiều
func _sq_pt(c: Vector2, s: float, k: float) -> Vector2:
	var corners := [Vector2(-s, -s), Vector2(s, -s), Vector2(s, s), Vector2(-s, s), Vector2(-s, -s)]
	var e := clampf(k, 0.0, 0.9999) * 4.0
	var i := int(e)
	var a: Vector2 = corners[i]
	var b: Vector2 = corners[i + 1]
	return c + a.lerp(b, e - i)


func _ci_pt(c: Vector2, r: float, k: float) -> Vector2:
	var a := -PI * 0.5 + k * TAU
	return c + Vector2(cos(a), sin(a)) * r


func _story(dt: float) -> void:
	# ---- Quách Tĩnh
	var g := smooth(1.0, 1.8, t) * (1.0 - smooth(2.2, 2.4, t))
	var drawing := 0.0
	var tk := 0.0
	var cur := -1
	for i in TRACE.size():
		var tr: Array = TRACE[i]
		var d := smooth(tr[0] - 0.12, tr[0], t) * (1.0 - smooth(tr[1], tr[1] + 0.15, t))
		if d > drawing:
			drawing = d
			cur = i
	if cur >= 0:
		tk = _trace_k(cur)
	var throw := 0.0
	for tr in TRACE:
		throw = maxf(throw, pulse(tr[1], tr[1] + 0.08, 0.3, t))
	var strike := smooth(PEAK - 0.15, PEAK - 0.02, t) * (1.0 - smooth(8.4, 9.4, t))
	# tay vạch hình: hai cánh tay lắc theo nhịp vẽ, một bên gãy góc (vuông), một bên tròn đều
	var sq_w: float = floorf(tk * 4.0)
	var draw_pose := DRAWP.duplicate()
	draw_pose["uaB"] = -120.0 + 18.0 * (1.0 if int(sq_w) % 2 == 0 else -1.0)
	draw_pose["faB"] = -15.0 + 14.0 * (1.0 if int(sq_w) % 3 == 0 else -1.0)
	draw_pose["uaF"] = -70.0 + 16.0 * sin(tk * TAU)
	draw_pose["faF"] = -20.0 + 14.0 * cos(tk * TAU)
	hero.gather = g
	hero.push = maxf(throw * 0.8, strike)
	hero.both = strike
	hero.extra = [[draw_pose, drawing * (1.0 - strike)]]
	hero.lean = hero.push * 0.25
	hero.aura = g * 0.6 + drawing * 0.3 + strike * 0.5 - smooth(7.2, 9.0, t) * 0.9
	hero.aura = maxf(hero.aura, 0.0)
	hero.expr = "vui" if t > 8.3 else ("quyet-tam" if t > 1.0 else "binh")

	# ---- Chu Bá Thông: nhảy nhót, thử bắt chước vẽ (nguệch ngoạc), rồi đỡ
	if not hit:
		var bob := absf(sin(t * 6.0)) * 18.0 * (1.0 - smooth(3.6, 3.8, t))
		var copy := smooth(3.8, 4.0, t) * (1.0 - smooth(4.6, 4.8, t))
		var scrib := SCRIB.duplicate()
		scrib["uaF"] = -100.0 + 30.0 * sin(t * 23.0)
		scrib["faF"] = -30.0 + 40.0 * sin(t * 31.0)
		scrib["uaB"] = -130.0 + 30.0 * cos(t * 19.0)
		scrib["faB"] = -20.0 + 40.0 * cos(t * 27.0)
		var grd := pulse(3.5, 3.65, 0.25, t) + pulse(4.95, 5.1, 0.3, t) + smooth(5.6, 5.9, t)
		foe.extra = [[scrib, copy], ["guard", minf(1.0, grd)]]
		foe.pos.y = GROUND - bob
		foe.aura = 0.3 + copy * 0.4
		foe.expr = "soc" if t > 5.4 else ("vui" if t < 3.5 else "gian")
		foe.lean = -minf(1.0, grd) * 0.2
	pose(hero, 0.0)
	pose(foe, 0.0)

	if g > 0.05:
		orbit(hero, rng.randf_range(110, 280), rng.randf_range(2.0, 3.4), 250, rng.randf_range(2, 5), HOT if rng.randf() < 0.5 else PEACH_HOT, 2.4)
	# tia bụi sáng theo đầu nét vẽ
	if cur >= 0 and drawing > 0.5 and tk < 1.0:
		var s := _sz(cur)
		var ps := _sq_pt(_sq_c(cur), s, tk)
		var pc := _ci_pt(_ci_c(cur), s * 0.9 if cur == 2 else s, tk)
		emit("add", ps, Vector2(rng.randf_range(-60, 60), rng.randf_range(-60, 60)), 0.4, 12, HOT * Color(1, 1, 1, 0.35))
		emit("add", pc, Vector2(rng.randf_range(-60, 60), rng.randf_range(-60, 60)), 0.4, 12, PEACH_HOT * Color(1, 1, 1, 0.35))

	# ---- vẽ xong: hai hình bay ra thành hai đòn
	for i in 2:
		var tr: Array = TRACE[i]
		if t >= tr[1] and not fired[i]:
			fired[i] = true
			shots.append({"kind": "sq", "p0": _sq_c(i), "t0": t, "s": _sz(i), "done": false})
			shots.append({"kind": "ci", "p0": _ci_c(i), "t0": t + 0.12, "s": _sz(i), "done": false})
	if t >= TRACE[2][1] and not fired[2]:
		fired[2] = true
		shots.append({"kind": "qc", "p0": _sq_c(2), "t0": PEAK - FLY * 0.36, "s": _sz(2), "done": false})
	for sh in shots:
		if sh.done or t < sh.t0:
			continue
		var fl: float = FLY if sh.kind != "qc" else FLY * 0.36
		if t - sh.t0 >= fl:
			sh.done = true
			var at := _shot_pos(sh)
			if sh.kind != "qc":
				var col: Color = HOT if sh.kind == "sq" else PEACH_HOT
				add_ring(at, 190, col, 7, 0.32)
				burst(at, 28, 300, 900, col, FOE_COL, 700.0, 1.4, -PI * 0.7, PI * 0.7)
				shake = maxf(shake, 12.0)
				sfx("lib-impact-bass-2", 0.6)
				foe.pos.x += 14.0
				hops += 1
			elif not hit:
				hit = true
				x_hit = foe.pos.x
				foe.expr = "ko"
				flash = 0.6
				flash_col = Color(1.0, 0.95, 0.92)
				shake = 30.0
				add_ring(at, 700, HOT, 16, 0.7)
				add_ring(at, 460, PEACH_HOT, 12, 0.6, 1.0, 0.05)
				add_ring(Vector2(at.x, GROUND), 800, COL, 10, 0.9, 0.2)
				burst(at, 80, 300, 1500, HOT, Color(2, 2, 2), 800.0, 1.0)
				burst(at, 70, 300, 1400, PEACH_HOT, PEACH, 800.0, 1.0)
				sfx("lib-impact-bass-1", 1.0)
				sfx("lib-impact-bass-2", 1.0)

	# ---- hậu quả: lăn tròn như bánh xe, rồi bật dậy cười vỗ tay
	if hit:
		var k := clampf((t - PEAK) / 1.25, 0.0, 1.0)
		var R := 78.0
		var x := lerpf(x_hit, ROLL_END, ease_out(k))
		var turn := ease_out(k) * TAU * 2.0
		var pop := smooth(PEAK + 1.25, PEAK + 1.55, t)
		var cc := Vector2(x, GROUND - R)
		foe.rot = turn * (1.0 - pop)
		foe.pos = cc + Vector2(0, R).rotated(foe.rot)
		foe.pos = foe.pos.lerp(Vector2(x, GROUND - sin(pop * PI) * 90.0), pop)
		foe.hurt = 0.0
		foe.lean = 0.0
		foe.aura = 0.0
		var clap := smooth(PEAK + 1.6, PEAK + 1.8, t)
		var cl_pose := CLAP.duplicate()
		var beat := absf(sin((t - PEAK) * 13.0))
		cl_pose["uaF"] = -95.0 + 22.0 * beat
		cl_pose["uaB"] = -95.0 - 22.0 * beat
		foe.extra = [[TUCK, (1.0 - pop) * smooth(0.0, 0.12, k)], [cl_pose, clap], ["raise", pop * (1.0 - clap)]]
		foe.expr = "ko" if t < PEAK + 0.9 else ("soc" if t < PEAK + 1.5 else "vui")
		if k < 0.95 and fmod(rt, 0.08) < DT:
			emit("smoke", Vector2(x, GROUND), Vector2(rng.randf_range(-140, 40), -rng.randf_range(20, 90)), 1.4, rng.randf_range(26, 50), Color(0.95, 0.85, 0.62, 0.4))
		if pop >= 1.0 and not up_done:
			up_done = true
			sfx("lib-impact-bass-2", 0.5)
			sfx("lib-pop", 0.5)
			for i in 14:
				emit("smoke", Vector2(ROLL_END + rng.randf_range(-80, 100), GROUND), Vector2(rng.randf_range(-160, 200), -rng.randf_range(20, 120)), 1.8, rng.randf_range(36, 70), Color(0.95, 0.86, 0.64, 0.42))
		if clap > 0.5 and fmod(t - PEAK, 0.24) < DT and t < PEAK + 3.4:
			sfx("lib-pop", 0.25)

	for pt in petals:
		pt.p += pt.v * dt
		pt.p.x += sin(rt * 1.5 + pt.ph) * 26.0 * dt
		if pt.p.y > GROUND + 60:
			pt.p = Vector2(pt.p.x - 700.0, -40.0)
		if pt.p.x > W + 200:
			pt.p.x -= W + 400


func _shot_pos(sh: Dictionary) -> Vector2:
	var fl: float = FLY if sh.kind != "qc" else FLY * 0.36
	var k := clampf((t - sh.t0) / fl, 0.0, 1.0)
	var p0: Vector2 = sh.p0
	var tgt: Vector2 = foe.pos + Vector2(-60, -200)
	if sh.kind == "ci":
		tgt = Vector2(foe.pos.x - 70, GROUND - sh.s)
	elif sh.kind == "qc":
		tgt = foe.pos + Vector2(-50, -170)
	return p0.lerp(tgt, k * k * (3.0 - 2.0 * k) if sh.kind != "qc" else k)


func _cam() -> Array:
	var c := Vector2(930, 590)
	var z := 1.0
	var k1 := smooth(0.9, 1.6, t) * (1.0 - smooth(2.1, 2.4, t))       # tụ khí
	c = c.lerp(hero.pos + Vector2(140, -230), k1)
	z = lerpf(z, 1.35, k1)
	var k2 := smooth(2.1, 2.5, t) * (1.0 - smooth(5.0, 5.3, t))       # hai người, cận vừa
	c = c.lerp(Vector2(900, 600), k2)
	z = lerpf(z, 1.15, k2)
	var k3 := smooth(5.0, 5.4, t) * (1.0 - smooth(PEAK + 0.2, 7.4, t))  # đỉnh: dấu quy củ
	c = c.lerp(Vector2(840, 590), k3)
	z = lerpf(z, 1.25, k3)
	var k4 := smooth(7.2, 8.6, t)                                       # kết
	c = c.lerp(Vector2(980, 590), k4)
	z = lerpf(z, 1.0, k4)
	return [c, z]


func _fx_ground(c: Node2D) -> void:
	# mép sóng vỗ bờ
	for i in 3:
		var y := GROUND - 6.0 + i * 3.0
		var pts := PackedVector2Array()
		for j in 41:
			var x := -400.0 + j * 70.0
			pts.append(Vector2(x, y + sin(x * 0.01 + rt * 1.6 + i) * 4.0))
		c.draw_polyline(pts, Color(1, 1, 1, 0.45 - i * 0.12), 3.0)
	# vết cát
	for i in 14:
		var x := -80.0 + i * 150.0
		c.draw_line(Vector2(x, GROUND + 40 + (i % 3) * 30), Vector2(x + 60, GROUND + 40 + (i % 3) * 30), Color(0.7, 0.52, 0.3, 0.35), 3)
	# cành đào bên trái
	var b := PackedVector2Array([Vector2(-40, 170), Vector2(110, 220), Vector2(230, 200), Vector2(330, 250)])
	c.draw_polyline(b, Color("#4a2e22"), 14.0)
	c.draw_polyline(PackedVector2Array([Vector2(110, 220), Vector2(170, 300), Vector2(150, 360)]), Color("#4a2e22"), 8.0)
	for i in 16:
		var p := Vector2(20 + (i * 53) % 330, 180 + (i * 37) % 170)
		for k in 5:
			var a := k * TAU / 5.0 + i
			c.draw_circle(p + Vector2(cos(a), sin(a)) * 9.0, 8.0, Color("#f4a8b8"))
		c.draw_circle(p, 4.0, Color("#c2405a"))
	var gk := smooth(1.0, 1.6, t) * (1.0 - smooth(2.2, 2.6, t)) + smooth(5.2, 5.9, t) * (1.0 - smooth(6.6, 7.6, t))
	if gk > 0.01:
		flat_blob(c, Vector2(hero.pos.x, GROUND + 8), 300, 0.14, COL * Color(1, 1, 1, 0.3 * gk))


func _fx_norm(c: Node2D) -> void:
	for pt in petals:
		var p: Vector2 = pt.p
		var s: float = pt.s
		c.draw_set_transform(p, rt * 1.6 + pt.ph, Vector2(1.0, 0.55 + 0.45 * sin(rt * 2.6 + pt.ph)))
		c.draw_circle(Vector2.ZERO, s, Color("#f6b2c0"))
		c.draw_circle(Vector2(s * 0.3, 0), s * 0.45, Color("#fbd4dc"))
		c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _sq_poly(c: Node2D, ctr: Vector2, s: float, rot: float, k: float, col: Color, hot: Color) -> void:
	# hình vuông vạch dần tới k (0..1)
	var pts := PackedVector2Array()
	var n := 40
	for i in n + 1:
		var kk := k * float(i) / n
		pts.append(ctr + (_sq_pt(Vector2.ZERO, s, kk)).rotated(rot))
	if pts.size() > 1:
		c.draw_polyline(pts, col * Color(1, 1, 1, 0.18), 22.0)
		c.draw_polyline(pts, col * Color(1, 1, 1, 0.85), 7.0)
		c.draw_polyline(pts, hot, 2.5)


func _ci_poly(c: Node2D, ctr: Vector2, r: float, spin: float, k: float, col: Color, hot: Color) -> void:
	var a0 := -PI * 0.5 + spin
	c.draw_arc(ctr, r, a0, a0 + TAU * k, 48, col * Color(1, 1, 1, 0.18), 22.0)
	c.draw_arc(ctr, r, a0, a0 + TAU * k, 48, col * Color(1, 1, 1, 0.85), 7.0)
	c.draw_arc(ctr, r, a0, a0 + TAU * k, 48, hot, 2.5)
	if k >= 1.0:
		for i in 6:
			var a := spin + i * TAU / 6.0
			c.draw_line(ctr + Vector2(cos(a), sin(a)) * r * 0.2, ctr + Vector2(cos(a), sin(a)) * r * 0.85, col * Color(1, 1, 1, 0.5), 2.0)


func _fx_add(c: Node2D) -> void:
	# hình đang vẽ (chưa bay)
	for i in TRACE.size():
		var tr: Array = TRACE[i]
		if t < tr[0] or fired[i]:
			continue
		var k := _trace_k(i)
		var s := _sz(i)
		_sq_poly(c, _sq_c(i), s, 0.0, k, COL, HOT)
		_ci_poly(c, _ci_c(i), s * 0.9 if i == 2 else s, 0.0, k, PEACH, PEACH_HOT)
		# sợi sáng nối đầu ngón tay với đầu nét
		var ps := _sq_pt(_sq_c(i), s, k)
		var pc := _ci_pt(_ci_c(i), s * 0.9 if i == 2 else s, k)
		c.draw_line(hero.handB, ps, HOT * Color(1, 1, 1, 0.4), 2.0)
		c.draw_line(hero.handF, pc, PEACH_HOT * Color(1, 1, 1, 0.4), 2.0)
		blob(c, ps, 26.0, COL * Color(1, 1, 1, 0.5))
		blob(c, pc, 26.0, PEACH * Color(1, 1, 1, 0.5))
		if i == 2 and k >= 1.0:
			# vuông và tròn lồng làm một: dấu quy củ
			var glow := smooth(tr[1], tr[1] + 0.2, t)
			blob(c, _sq_c(2), 150.0, Color(1.0, 1.0, 1.0, 0.25 * glow))
	# hình đang bay
	for sh in shots:
		if sh.done or t < sh.t0:
			continue
		var p := _shot_pos(sh)
		var age: float = t - sh.t0
		var s: float = sh.s
		if sh.kind == "sq":
			_sq_poly(c, p, s * (1.0 + age * 0.4), 0.0, 1.0, COL, HOT)
			blob(c, p, s * 1.2, COL * Color(1, 1, 1, 0.2))
		elif sh.kind == "ci":
			_ci_poly(c, p, s, age * 14.0, 1.0, PEACH, PEACH_HOT)
			blob(c, p, s * 1.2, PEACH * Color(1, 1, 1, 0.2))
		else:
			_sq_poly(c, p, s * (1.0 + age * 0.8), 0.0, 1.0, COL, HOT)
			_ci_poly(c, p, s * 0.9 * (1.0 + age * 0.8), age * 10.0, 1.0, PEACH, PEACH_HOT)
			blob(c, p, s * 1.4, Color(1.2, 1.2, 1.2, 0.3))
	# Chu Bá Thông bắt chước: nét nguệch ngoạc
	var copy := smooth(3.8, 4.0, t) * (1.0 - smooth(4.6, 4.9, t))
	if copy > 0.01 and not hit:
		var pts := PackedVector2Array()
		var ctr: Vector2 = foe.pos + Vector2(-150, -250)
		for i in 30:
			var a := i * 0.55 + t * 3.0
			pts.append(ctr + Vector2(cos(a) * (40.0 + 20.0 * sin(i * 1.3)), sin(a * 1.4) * (36.0 + 18.0 * cos(i * 0.9))))
		c.draw_polyline(pts, FOE_COL * Color(1, 1, 1, 0.7 * copy), 3.0)
	if hit and t < PEAK + 0.4:
		var k := smooth(PEAK, PEAK + 0.4, t)
		var at: Vector2 = Vector2(x_hit - 50, GROUND - 170)
		_sq_poly(c, at, 160.0 + 260.0 * k, k * 0.6, 1.0, COL * Color(1, 1, 1, 1.0 - k), HOT * Color(1, 1, 1, 1.0 - k))
	speed_lines(c, 350.0, 1.0, smooth(PEAK - 0.15, PEAK, t) * (1.0 - smooth(PEAK + 0.1, PEAK + 0.5, t)), HOT)
