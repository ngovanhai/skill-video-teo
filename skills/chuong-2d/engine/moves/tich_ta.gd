extends "res://engine.gd"
# TỊCH TÀ KIẾM PHÁP (tap-15 Nhạc Bất Quần, 2026-10-24)
# Thẻ chiêu: Nhạc Bất Quần ("Quân Tử Kiếm") · Tả Lãnh Thiền (minh chủ, Hàn Băng chân khí) · tỷ võ đoạt chức chưởng môn
# Ngũ Nhạc phái trên Phong Thiện Đài đỉnh Tung Sơn · CƠ CHẾ: NBQ thành vệt mờ đỏ thẫm, chớp hiện lần lượt ở 8 điểm trên vòng
# quanh Tả; mỗi lần hiện để lại một mũi kim sáng đỏ treo lơ lửng và một sợi chỉ đỏ nối về điểm trước — chỉ "khâu" thành lưới
# sao tám cánh quanh Tả; chưởng Hàn Băng trắng sương của Tả chỉ chém trúng tàn ảnh (vệt sương trong khoảng không) ·
# đỏ thẫm vs trắng sương · trời sớm lạnh nhạt (lam thép → hồng tro), biển mây, đài đá vôi xám ngà, lan can đá, 5 cờ Ngũ Nhạc ·
# đỉnh: 8 mũi kim trượt theo chỉ thắt lại thành 2 chấm sáng trắng trước hai mắt Tả → flash (slowmo) → Tả một tay ôm mắt,
# tay kia quờ vào khoảng không, sương giá vỡ khỏi người, lảo đảo lùi rồi quỳ một gối. Không máu, không văng.

const COL := Color(1.45, 0.16, 0.24)       # kiếm khí đỏ thẫm (cộng)
const HOT := Color(2.2, 0.6, 0.66)
const THREAD := Color(0.7, 0.04, 0.12)     # chỉ đỏ vẽ thường (nền sáng, cộng sẽ bạc màu)
const FOE_COL := Color(1.1, 1.45, 1.8)     # Hàn Băng trắng sương
const ICE := Color(0.7, 0.86, 1.0)
const ICE_D := Color(0.3, 0.48, 0.72)
const STEEL := Color(0.86, 0.88, 0.9)
const FX := 1200.0                         # chỗ Tả đứng
const RX := 285.0
const RY := 140.0
const ORDER := [0, 3, 6, 1, 4, 7, 2, 5]    # thứ tự chớp: nối thành sao tám cánh
const B0 := 2.3
const BSTEP := 0.36
const CLOSE := 5.18                        # B0 + 8*BSTEP: chỉ khép vòng
const STRIKES := [3.0, 3.72, 4.44]         # Tả xuất Hàn Băng chưởng vào tàn ảnh
const PEAK := 6.2
const SW := 150.0                          # dài kiếm

const OM_MAT := {"uaF": -150.0, "faF": -128.0, "uaB": -72.0, "faB": -20.0, "head": 14.0, "torso": 12.0, "all": [0.0, 0.0, 18.0]}
const KIEM_DUNG := {"uaF": -20.0, "faF": -120.0, "uaB": 30.0, "faB": -60.0, "head": -2.0}     # dựng kiếm trước mặt
const THU_KIEM := {"uaF": 20.0, "faF": -20.0, "uaB": -10.0, "faB": -70.0, "torso": -3.0}      # kiếm chúc xuống

var C := Vector2(FX, GROUND - 200)
var last_n := -1
var pts: Array = []          # mũi kim: {p, t0}
var threads: Array = []      # [i, j, t0] chỉ số trong pts
var streaks: Array = []      # vệt chớp đỏ: {a, b, t0}
var frosts: Array = []       # vệt Hàn Băng: {a, b, t0}
var ghosts: Array = []       # {node, t0, struck, pos}
var strike_i := 0
var sw_dir := Vector2(1, 0.3)
var sw_tip := Vector2.ZERO
var hit := false
var x_hit := 0.0
var conv := 0.0
var flags: Array = []


func _setup() -> void:
	sky_cols = [Color("#8a96b0"), Color("#e2d4d2"), Color("#f4ebe4")]
	moon_on = true
	moon = Vector2(300, 320)
	moon_col = Color(1.3, 1.15, 0.98)
	moon_glow = Color(1.0, 0.8, 0.65, 0.4)
	moon_craters = false
	n_stars = 0
	far_col = Color("#9a93ab")
	near_col = Color("#e6dcdc")
	mist_col = Color(1.0, 0.97, 0.96, 0.5)
	ground_cols = [Color("#b3ada3"), Color("#77726b"), Color("#d8d1c4")]
	slowmo = [PEAK - 0.05, PEAK + 0.6, 0.3]
	title = "TỊCH TÀ KIẾM PHÁP"
	subtitle = "Nhạc Bất Quần · Phong Thiện Đài"
	title_at = 8.4
	title_col = HOT
	set_char(hero, "nhac-bat-quan")
	set_char(foe, "ta-lanh-thien")
	hero.pos = Vector2(600, GROUND)
	foe.pos = Vector2(FX, GROUND)
	hero.col = COL
	foe.col = FOE_COL
	for i in 5:
		var g: Node2D = Chibi.new()
		l_chars.add_child(g)
		l_chars.move_child(g, 0)
		g.setup("nhac-bat-quan")
		g.visible = false
		ghosts.append({"node": g, "t0": -9.0, "struck": true, "pos": Vector2.ZERO})
	# 5 cờ Ngũ Nhạc: Thái, Hành, Hoa, Hằng, Tung
	var fx := [90.0, 280.0, 470.0, 1640.0, 1830.0]
	var fc := [Color("#7a2e2e"), Color("#4e6a3a"), Color("#3d4e6e"), Color("#6e6e70"), Color("#b8892e")]
	for i in 5:
		flags.append([fx[i], fc[i], rng.randf() * TAU])
	cue(0.2, "lib-whoosh", 0.35)
	cue(1.0, "lib-riser", 0.75)
	cue(5.55, "lib-glitch-1", 0.35)
	cue(PEAK - 0.3, "lib-whoosh-cinematic", 0.9)


func ring_pt(k: int) -> Vector2:
	var a := -PI * 0.5 + k * TAU / 8.0
	return C + Vector2(cos(a) * RX, sin(a) * RY)


func _sdir(k: int) -> Vector2:
	var p := ring_pt(k)
	var dx := C.x - p.x
	if absf(dx) < 1.0:
		dx = 1.0 if k == 0 else -1.0
	var dy := (C.y - p.y) / RY * 0.55
	if k == 4:
		dy = -0.15
	return Vector2(signf(dx), dy).normalized()


# đặt NBQ sao cho mũi kiếm chạm p theo hướng d (chạm đất thì giữ chân trên đất, kiếm tự xoay về p)
func _place(p: Vector2, d: Vector2, base_extra: Array) -> void:
	hero.face = signf(d.x)
	hero.extra = base_extra
	hero.pos = Vector2(p.x, GROUND)
	pose(hero, 0.0)
	var off: Vector2 = hero.handF - hero.pos
	var pos: Vector2 = p - d * SW - off
	hero.crouch = 0.0
	if pos.y > GROUND:
		hero.crouch = clampf((pos.y - GROUND) / 40.0, 0.0, 1.0)
		pos.y = GROUND
	hero.pos = pos


func _spawn_ghost() -> void:
	var g: Dictionary = ghosts[0]
	for q in ghosts:
		if q.t0 < g.t0:
			g = q
	g.t0 = t
	g.struck = false
	g.pos = hero.pos
	var n: Node2D = g.node
	n.position = hero.pos
	n.rotation = 0.0
	n.scale = Vector2(hero.face, 1.0) * CS
	n.apply(pose_of(hero), 0.0)
	n.set_expr(hero.expr)


func _story(_dt: float) -> void:
	# ================= Nhạc Bất Quần
	hero.tint = Color(1, 1, 1, 1)
	hero.rot = 0.0
	if t < B0:
		hero.pos = Vector2(600, GROUND)
		hero.face = 1.0
		var g := smooth(1.0, 1.7, t)
		hero.extra = [[THU_KIEM, 1.0 - g], [KIEM_DUNG, g]]
		hero.aura = g * 0.5
		sw_dir = Vector2(0.55, 0.8).normalized().lerp(Vector2(0.05, -1.0), g).normalized()
		hero.expr = "quyet-tam" if t > 1.0 else "binh"
		pose(hero, 0.0)
		sw_tip = hero.handF + sw_dir * SW
		if g > 0.05 and t < 2.2:
			orbit(hero, rng.randf_range(110, 260), rng.randf_range(2.2, 3.4), 260, rng.randf_range(2, 4), HOT, 2.25)
	elif t < CLOSE:
		# ---- 8 lần chớp quanh vòng
		var n := int((t - B0) / BSTEP)
		var local := t - (B0 + n * BSTEP)
		var k: int = ORDER[n]
		var p := ring_pt(k)
		if n != last_n:
			if last_n >= 0:
				_spawn_ghost()
			streaks.append({"a": hero.pos + Vector2(0, -170), "t0": t, "b": Vector2.ZERO, "k": k})
		sw_dir = _sdir(k)
		_place(p, sw_dir, [["point", 1.0]])
		hero.aura = 0.3
		hero.expr = "quyet-tam"
		pose(hero, 0.0)
		sw_tip = p
		if n != last_n:
			streaks[-1].b = hero.pos + Vector2(0, -170)
			pts.append({"p": p, "t0": t})
			if pts.size() >= 2:
				threads.append([pts.size() - 2, pts.size() - 1, t])
			add_ring(p, 90, HOT, 4, 0.3)
			burst(p, 18, 200, 600, HOT, COL, 300.0, 1.6)
			shake = maxf(shake, 10.0)
			sfx("lib-whoosh-short", 0.5)
			sfx("lib-sparkle", 0.2)
			last_n = n
		# chớp tắt trong lúc di chuyển: thân mờ đi, nhấp nháy đỏ
		var vis := 1.0 - smooth(BSTEP - 0.1, BSTEP - 0.04, local)
		var fl := 0.5 + 0.5 * sin(t * 70.0)
		hero.tint = Color(1.0 + 0.25 * fl, 0.82 + 0.1 * (1.0 - fl), 0.86, vis)
	else:
		# ---- khép lưới, rồi đâm
		if not hero.has("closed"):
			hero.closed = true
			_spawn_ghost()
			threads.append([pts.size() - 1, 0, t])
			add_ring(pts[0].p, 120, HOT, 5, 0.35)
			shake = maxf(shake, 12.0)
			sfx("lib-whoosh-short", 0.55)
		var lunge := smooth(5.85, PEAK, t)
		var back := smooth(PEAK + 0.25, PEAK + 0.7, t)
		var eye_mid: Vector2 = _eyes()[0].lerp(_eyes()[1], 0.5)
		if back < 0.02:
			# đứng trước mặt Tả, kiếm dựng → phóng tới mũi kiếm điểm giữa hai mắt
			var d := Vector2(1.0, -0.08).normalized()
			var ground_p := Vector2(FX - 360.0, GROUND)
			hero.face = 1.0
			hero.extra = [[KIEM_DUNG, 1.0 - lunge], ["point", lunge], [{"torso": -14.0, "all": [0.0, 0.0, 6.0]}, lunge]]
			hero.pos = ground_p
			hero.crouch = 0.5 * (1.0 - lunge)
			pose(hero, 0.0)
			var off: Vector2 = hero.handF - hero.pos
			var tgt: Vector2 = eye_mid - Vector2(14, 0) - d * SW - off
			tgt.y = minf(tgt.y, GROUND)
			hero.pos = ground_p.lerp(tgt, ease_out(lunge))
			sw_dir = Vector2(0.05, -1.0).lerp(d, lunge).normalized()
			hero.aura = 0.6
			hero.expr = "quyet-tam"
			var vis := smooth(CLOSE, CLOSE + 0.12, t)
			hero.tint = Color(1, 1, 1, vis)
		else:
			# chớp về chỗ cũ, thu kiếm
			var gone := smooth(PEAK + 0.25, PEAK + 0.32, t) * (1.0 - smooth(PEAK + 0.6, PEAK + 0.7, t))
			if back > 0.5 and not hero.has("home"):
				hero.home = true
				streaks.append({"a": Vector2(FX - 230, GROUND - 260), "b": Vector2(620, GROUND - 170), "t0": t, "k": -1})
				sfx("lib-whoosh", 0.5)
			hero.pos = Vector2(620, GROUND) if back > 0.5 else hero.pos
			hero.face = 1.0
			hero.crouch = 0.0
			hero.extra = [[THU_KIEM, 1.0]]
			sw_dir = Vector2(0.55, 0.8).normalized()
			hero.aura = maxf(0.0, 0.4 - smooth(7.0, 8.2, t) * 0.4)
			hero.expr = "dac-y" if t > 7.3 else "binh"
			hero.tint = Color(1, 1, 1, 1.0 - gone)
		pose(hero, 0.0)
		sw_tip = hero.handF + sw_dir * SW

	# ================= Tả Lãnh Thiền
	var eyes := _eyes()
	if not hit:
		foe.tint = Color(0.88, 0.95, 1.12)
		foe.aura = 0.25 + smooth(5.2, 5.8, t) * 0.3
		var sp := 0.0
		for s in STRIKES:
			sp = maxf(sp, pulse(s - 0.12, s + 0.06, 0.22, t))
		foe.push = sp
		foe.lean = sp * 0.35
		foe.extra = [["guard", smooth(5.3, 5.8, t) * 0.7]]
		foe.expr = "gian" if t < 3.3 else "soc"
		if t < 2.9:
			foe.face = -1.0
		if t > CLOSE:
			foe.face = -1.0
		# xuất Hàn Băng chưởng vào tàn ảnh mới nhất
		if strike_i < STRIKES.size() and t >= STRIKES[strike_i]:
			var g: Dictionary = ghosts[0]
			for q in ghosts:
				if not q.struck and (g.struck or q.t0 > g.t0):
					g = q
			var tg: Vector2 = g.pos + Vector2(0, -170)
			foe.face = signf(tg.x - foe.pos.x) if absf(tg.x - foe.pos.x) > 10.0 else -foe.face
			pose(foe, 0.0)
			var a0: Vector2 = foe.handF
			var dir := (tg - a0).normalized()
			frosts.append({"a": a0, "b": tg + dir * 420.0, "t0": t})
			g.struck = true
			burst(tg, 26, 200, 700, FOE_COL, HOT, 400.0, 1.6)
			for i in 16:
				emit("frost", tg + Vector2(rng.randf_range(-60, 60), rng.randf_range(-90, 90)), dir * rng.randf_range(60, 260) + Vector2(0, -rng.randf_range(0, 120)), rng.randf_range(0.8, 1.4), rng.randf_range(5, 10), ICE, 260.0, 1.2)
			add_ring(tg, 140, FOE_COL, 5, 0.3)
			shake = maxf(shake, 12.0)
			sfx("lib-whoosh", 0.5)
			sfx("lib-chime", 0.35)
			sfx("lib-impact-bass-2", 0.5)
			strike_i += 1
	# ---- đỉnh
	if t >= PEAK and not hit:
		hit = true
		x_hit = foe.pos.x
		foe.expr = "ko"
		flash = 0.75
		flash_col = Color(1, 1, 1)
		shake = 28.0
		var at: Vector2 = eyes[0].lerp(eyes[1], 0.5)
		add_ring(at, 520, HOT, 14, 0.7)
		add_ring(at, 300, Color(2, 2, 2), 8, 0.5, 1.0, 0.05)
		add_ring(Vector2(FX, GROUND), 700, COL, 8, 0.9, 0.2)
		burst(at, 110, 300, 1400, Color(2, 2, 2), HOT, 500.0, 1.2)
		for i in 70:
			var p: Vector2 = foe.pos + Vector2(rng.randf_range(-70, 70), -rng.randf_range(20, 330))
			var v: Vector2 = (p - (foe.pos + Vector2(0, -170))).normalized() * rng.randf_range(150, 520) + Vector2(0, -120)
			emit("frost", p, v, rng.randf_range(0.9, 1.7), rng.randf_range(6, 13), ICE, 700.0, 0.8)
		sfx("lib-impact-bass-1", 1.0)
		sfx("lib-impact-bass-2", 1.0)
		sfx("lib-sparkle", 0.45)
	# ---- hậu quả: ôm mắt, quờ quạng, lảo đảo lùi, quỳ một gối
	if hit:
		var k := clampf((t - PEAK) / 1.4, 0.0, 1.0)
		var stag := sin(k * PI * 3.0) * (1.0 - k)
		foe.face = -1.0
		foe.pos = Vector2(lerpf(x_hit, x_hit + 170.0, ease_out(k)), GROUND)
		foe.rot = stag * 0.1
		foe.push = 0.0
		foe.lean = 0.0
		foe.hurt = 0.0
		foe.aura = 0.0
		var grope := {"uaB": -80.0 + sin(t * 9.0) * 22.0, "faB": -20.0 + sin(t * 7.0) * 18.0}
		foe.extra = [[OM_MAT, smooth(0.0, 0.15, k)], [grope, smooth(0.1, 0.3, k)], ["kneel", smooth(0.55, 1.0, k) * 0.85]]
		foe.tint = Color(0.88, 0.95, 1.12).lerp(Color(1, 1, 1), smooth(0.0, 0.5, k))
		if k > 0.05 and k < 0.6 and int(t * 30.0) % 2 == 0:
			emit("frost", foe.pos + Vector2(rng.randf_range(-60, 60), -rng.randf_range(60, 300)), Vector2(rng.randf_range(-80, 80), rng.randf_range(-40, 40)), 1.0, rng.randf_range(4, 8), ICE, 500.0, 0.5)
		if k >= 1.0 and not foe.has("landed"):
			foe.landed = true
			shake = maxf(shake, 9.0)
			sfx("lib-impact-bass-2", 0.45)
			for i in 14:
				emit("smoke", Vector2(foe.pos.x + rng.randf_range(-90, 90), GROUND), Vector2(rng.randf_range(-130, 130), -rng.randf_range(20, 100)), 1.8, rng.randf_range(36, 70), Color(0.78, 0.76, 0.74, 0.45))
	pose(foe, 0.0)

	# ---- mũi kim thắt lại theo chỉ về hai mắt
	conv = smooth(5.55, 6.12, t)
	# ---- tàn ảnh
	for g in ghosts:
		var n: Node2D = g.node
		var age: float = t - g.t0
		var a := 0.0
		if not g.struck:
			a = 0.5 * (1.0 - smooth(0.2, 1.1, age))
		n.visible = a > 0.02
		if n.visible:
			n.modulate = Color(1.35, 0.42, 0.48, a)
	if hero.tint.a < 0.9 and t > B0 and t < PEAK:
		emit("add", hero.pos + Vector2(rng.randf_range(-40, 40), -rng.randf_range(60, 300)), Vector2.ZERO, 0.25, 18, Color(COL.r, COL.g, COL.b, 0.35))


func _eyes() -> Array:
	var h: Vector2 = foe.head
	return [h + Vector2(-26, 6), h + Vector2(26, 6)]


func _pt_pos(i: int) -> Vector2:
	var p: Vector2 = pts[i].p
	if conv <= 0.0:
		return p
	var e: Array = _eyes()
	var tg: Vector2 = e[0] if p.x < C.x or (absf(p.x - C.x) < 1.0 and i % 2 == 0) else e[1]
	return p.lerp(tg, ease_out(conv))


func _net_alpha() -> float:
	return 1.0 - smooth(PEAK + 0.05, PEAK + 0.5, t)


func _cam() -> Array:
	var c := Vector2(900, 590)
	var z := 1.0
	var k1 := smooth(0.9, 1.7, t) * (1.0 - smooth(2.1, 2.4, t))
	c = c.lerp(hero.pos + Vector2(130, -230), k1)
	z = lerpf(z, 1.35, k1)
	var k2 := smooth(2.1, 2.5, t) * (1.0 - smooth(5.5, 5.9, t))
	c = c.lerp(Vector2(FX + 120 + sin(t * 1.3) * 30.0, 560), k2)
	z = lerpf(z, 1.0, k2)
	var k3 := smooth(5.6, 6.1, t) * (1.0 - smooth(PEAK + 0.5, 7.4, t))
	c = c.lerp(Vector2(FX - 120, GROUND - 300), k3)
	z = lerpf(z, 1.55, k3)
	c = c.lerp(Vector2(980, 590), smooth(7.0, 8.2, t) * (1.0 - k3))
	return [c, z]


# ---------------------------------------------------------------- vẽ

func _fx_ground(c: Node2D) -> void:
	# đài đá: mạch lát
	for i in 9:
		var y := GROUND + 18.0 + i * i * 6.0
		c.draw_line(Vector2(-600, y), Vector2(W + 600, y), Color(0.45, 0.43, 0.4, 0.35), 2.0)
	for i in 22:
		var x := -400.0 + i * 140.0
		c.draw_line(Vector2(x, GROUND + 4), Vector2(x + (x - 960.0) * 0.5, H + 300), Color(0.45, 0.43, 0.4, 0.22), 2.0)
	# cờ Ngũ Nhạc (sau lan can)
	for f in flags:
		var x: float = f[0]
		var top := GROUND - 430.0
		c.draw_line(Vector2(x, GROUND - 40), Vector2(x, top), Color("#4a3a2a"), 6.0)
		var pl := PackedVector2Array()
		var col: Color = f[1]
		for j in 9:
			var u := j / 8.0
			pl.append(Vector2(x + u * 110.0, top + 8 + sin(rt * 3.0 + f[2] + u * 4.0) * 8.0 * u))
		for j in range(8, -1, -1):
			var u := j / 8.0
			pl.append(Vector2(x + u * 110.0, top + 150 + sin(rt * 3.0 + f[2] + u * 4.0) * 8.0 * u - u * 12.0))
		c.draw_colored_polygon(pl, col)
	# bia đá Phong Thiện
	c.draw_rect(Rect2(870, GROUND - 330, 70, 290), Color("#8f8a82"))
	c.draw_rect(Rect2(860, GROUND - 345, 90, 22), Color("#6e6a64"))
	c.draw_rect(Rect2(884, GROUND - 300, 42, 220), Color("#a39e95"))
	# lan can đá
	c.draw_rect(Rect2(-600, GROUND - 74, W + 1200, 14), Color("#c9c2b5"))
	c.draw_line(Vector2(-600, GROUND - 60), Vector2(W + 600, GROUND - 60), Color("#8d877d"), 3.0)
	for i in 26:
		var x := -300.0 + i * 100.0
		c.draw_rect(Rect2(x - 9, GROUND - 92, 18, 92), Color("#bdb6a9"))
		c.draw_rect(Rect2(x - 12, GROUND - 100, 24, 12), Color("#9a948a"))
	# quầng đỏ dưới chân NBQ khi tụ khí, sương lạnh dưới chân Tả
	var g := smooth(1.0, 1.7, t) * (1.0 - smooth(2.2, 2.4, t))
	if g > 0.01:
		flat_blob(c, Vector2(hero.pos.x, GROUND + 8), 300, 0.15, Color(0.75, 0.06, 0.14, 0.3 * g))
	var fr := 1.0 - smooth(PEAK, PEAK + 1.2, t)
	if fr > 0.01:
		flat_blob(c, Vector2(foe.pos.x, GROUND + 8), 260, 0.15, Color(0.55, 0.75, 0.98, 0.35 * fr))


func _draw_sword(c: Node2D, hp: Vector2, tip: Vector2, a: float) -> void:
	var d := (tip - hp)
	if d.length() < 1.0:
		return
	d = d.normalized()
	var n := d.orthogonal()
	var base := hp + d * 14.0
	c.draw_line(hp - d * 22.0, hp + d * 8.0, Color(0.18, 0.12, 0.1, a), 6.0)
	c.draw_line(hp + d * 10.0 + n * 12.0, hp + d * 10.0 - n * 12.0, Color(0.6, 0.48, 0.2, a), 5.0)
	c.draw_colored_polygon(PackedVector2Array([base + n * 3.0, tip - d * 10.0 + n * 1.5, tip, tip - d * 10.0 - n * 1.5, base - n * 3.0]), Color(STEEL, a))
	c.draw_line(base, tip, Color(0.55, 0.05, 0.12, 0.7 * a), 1.2)


func _fx_norm(c: Node2D) -> void:
	var na := _net_alpha()
	# vệt chớp đỏ giữa hai điểm
	for s in streaks:
		var age: float = t - s.t0
		if age > 0.3 or s.b == Vector2.ZERO:
			continue
		var a := 1.0 - age / 0.3
		c.draw_line(s.a, s.b, Color(0.72, 0.06, 0.14, 0.55 * a), 14.0 * a + 2.0)
		c.draw_line(s.a, s.b, Color(0.95, 0.4, 0.45, 0.6 * a), 3.0)
	# chỉ đỏ khâu lưới
	if na > 0.01:
		for th in threads:
			var k := smooth(th[2], th[2] + 0.1, t)
			var a: Vector2 = _pt_pos(th[0])
			var b: Vector2 = _pt_pos(th[1])
			c.draw_line(a, a.lerp(b, k), Color(THREAD, 0.9 * na), 3.0)
		for i in pts.size():
			var p := _pt_pos(i)
			var s := 9.0 + 2.0 * sin(t * 12.0 + i)
			c.draw_colored_polygon(PackedVector2Array([p + Vector2(0, -s * 1.8), p + Vector2(s * 0.45, 0), p + Vector2(0, s * 1.8), p + Vector2(-s * 0.45, 0)]), Color(THREAD, na))
	# Hàn Băng: vệt sương trắng trong khoảng không
	for f in frosts:
		var age: float = t - f.t0
		if age > 1.2:
			continue
		var a := 1.0 - smooth(0.5, 1.2, age)
		var grow := ease_out(age / 0.15)
		var A: Vector2 = f.a
		var B: Vector2 = A.lerp(f.b, grow)
		var d := (B - A).normalized()
		var n := d.orthogonal()
		var w := 30.0
		c.draw_colored_polygon(PackedVector2Array([A + n * 8.0, A.lerp(B, 0.6) + n * w, B, A.lerp(B, 0.6) - n * w, A - n * 8.0]), Color(ICE, 0.55 * a))
		c.draw_polyline(PackedVector2Array([A + n * 8.0, A.lerp(B, 0.6) + n * w, B, A.lerp(B, 0.6) - n * w, A - n * 8.0]), Color(ICE_D, 0.7 * a), 2.0)
		for j in 6:
			var q := A.lerp(B, 0.3 + j * 0.12) + n * sin(j * 2.3) * 18.0
			var s := 10.0 + (j % 3) * 4.0
			c.draw_colored_polygon(PackedVector2Array([q + Vector2(0, -s), q + Vector2(s * 0.5, 0), q + Vector2(0, s), q + Vector2(-s * 0.5, 0)]), Color(0.92, 0.97, 1.0, 0.85 * a))
	# mảnh sương giá
	for q in parts:
		if q.k != "frost":
			continue
		var a: float = q.life / q.max
		var s: float = q.size
		var r: float = q.rot
		var poly := PackedVector2Array()
		for i in 4:
			var ang := r + i * PI * 0.5
			poly.append(q.p + Vector2(cos(ang), sin(ang)) * (s if i % 2 == 0 else s * 0.45))
		c.draw_colored_polygon(poly, Color(0.86, 0.94, 1.0, a))
		c.draw_polyline(poly + PackedVector2Array([poly[0]]), Color(ICE_D, a * 0.8), 1.2)
	# kiếm
	var ha: float = hero.tint.a
	if ha > 0.05:
		_draw_sword(c, hero.handF, sw_tip if (t >= B0 and t < CLOSE) else hero.handF + sw_dir * SW, ha)


func _fx_add(c: Node2D) -> void:
	var na := _net_alpha()
	# lõi sáng của chỉ + mũi kim
	if na > 0.01:
		for th in threads:
			var k := smooth(th[2], th[2] + 0.1, t)
			var a: Vector2 = _pt_pos(th[0])
			var b: Vector2 = _pt_pos(th[1])
			c.draw_line(a, a.lerp(b, k), Color(COL.r, COL.g, COL.b, 0.35 * na), 1.5)
		for i in pts.size():
			var p := _pt_pos(i)
			var age: float = t - pts[i].t0
			blob(c, p, 34 + 30 * (1.0 - smooth(0.0, 0.3, age)), Color(COL.r, COL.g, COL.b, 0.4 * na))
	# hai chấm sáng trắng trước mắt
	var pin := smooth(5.95, 6.12, t) * (1.0 - smooth(PEAK + 0.1, PEAK + 0.6, t))
	if pin > 0.01:
		for e in _eyes():
			blob(c, e, 20 * pin, Color(2.0, 1.9, 1.9, 0.9 * pin))
			c.draw_line(e - Vector2(30, 0) * pin, e + Vector2(30, 0) * pin, Color(2, 2, 2, 0.2 * pin), 2.0)
			c.draw_line(e - Vector2(0, 30) * pin, e + Vector2(0, 30) * pin, Color(2, 2, 2, 0.2 * pin), 2.0)
	# kiếm khí tụ ở mũi kiếm
	var g := smooth(1.0, 1.7, t) * (1.0 - smooth(2.2, 2.4, t))
	if g > 0.01:
		blob(c, hero.handF + sw_dir * SW, 70 * g, Color(COL.r, COL.g, COL.b, 0.45 * g))
		blob(c, hero.handF + sw_dir * SW, 22 * g, HOT)
	if t >= B0 and t < PEAK + 0.2 and hero.tint.a > 0.3:
		blob(c, sw_tip, 26, Color(HOT.r, HOT.g, HOT.b, 0.5))
	# sương lạnh quanh tay Tả khi ra chưởng
	for f in frosts:
		var age: float = t - f.t0
		if age < 0.35:
			blob(c, f.a, 80 * (1.0 - age / 0.35), Color(FOE_COL.r, FOE_COL.g, FOE_COL.b, 0.3))
