extends "res://engine.gd"
# Lăng Ba Vi Bộ — sáu mươi tư bước quẻ né kéo cá sấu (tap-13 Tứ Đại Ác Nhân, 2026-10-24)
# Thẻ chiêu: Đoàn Dự (thư sinh không nội công) · Nhạc Lão Tam / Nam Hải Ngạc Thần, ngạc chủy tiễn (kéo mỏ cá sấu) ·
# BƯỚC QUẺ: dưới sân trải lưới 64 ô, mỗi ô khắc một quẻ sáu hào; mỗi lần kéo đớp, Dự đã nhảy sang ô khác — ô mới sáng
# ngọc lam, quẻ của ô bay lên, chỗ cũ chỉ còn bóng mờ để hàm kéo cắn vào khoảng không; đường bước nối các ô thành nét
# quẻ đứt nối · ngọc lam vs đỏ cam đồng · sân phủ Trấn Nam Vương đêm chàm, gạch đỏ, đèn lồng, mái cong ·
# đỉnh: lần đớp thứ tư (slowmo) khép vào bóng mờ, Dự đã ở sau lưng, một sợi chỉ vàng (Nhất Dương Chỉ của cha) chạm
# vào lưng Dự, Dự điểm huyệt; Ngạc Thần xoay mấy vòng chóng mặt rồi ngồi phịch xuống, sao quay quanh đầu.

const COL := Color(0.35, 1.25, 1.1)         # ngọc lam bước quẻ
const HOT := Color(1.1, 2.1, 1.9)
const FOE_COL := Color(1.55, 0.55, 0.2)     # đỏ cam đồng
const GOLD := Color(2.0, 1.55, 0.55)
const PEAK := 6.1
# [giờ bước, x mới] — Dự rời chỗ đúng lúc hàm kéo khép
const STEPS := [[2.45, 1090.0], [3.45, 520.0], [4.45, 1130.0]]
# Ngạc Thần lao tới: [giờ bắt đầu, giờ tới, x tới]
# [bắt đầu, tới, x tới, x Dự lúc đó (đích cắn)]
const LUNGE := [[2.0, 2.4, 785.0, 600.0], [3.0, 3.4, 905.0, 1090.0], [4.0, 4.4, 705.0, 520.0], [5.55, 6.05, 945.0, 1130.0]]
const REACH := 185.0
const GY0 := 760.0
const ROWS := 8
const COLS := 8
const NGOI := {"thF": -92.0, "shF": 84.0, "thB": -84.0, "shB": 76.0, "torso": 8.0, "head": 10.0, "uaF": -40.0, "faF": -30.0, "uaB": 40.0, "faB": -20.0, "all": [0.0, 0.0, 118.0]}
const DO_KEO := {"uaF": -96.0, "faF": -6.0, "uaB": 30.0, "faB": -60.0, "torso": -14.0, "head": -6.0, "thF": -40.0, "shF": 30.0, "thB": 30.0, "shB": -10.0, "all": [0.0, 10.0, 18.0]}
const CHAP_SAU := {"uaF": 40.0, "faF": -50.0, "uaB": 50.0, "faB": -60.0, "torso": -3.0, "head": -4.0}
const BUOC := {"thF": -50.0, "shF": 60.0, "thB": 40.0, "shB": 30.0, "uaF": -60.0, "faF": -30.0, "uaB": 60.0, "faB": -30.0, "torso": 8.0, "all": [0.0, 0.0, 6.0]}

var ghost: Node2D
var lit: Array = []          # [ô, giờ sáng]
var glyphs: Array = []       # [ô, giờ]
var ghosts: Array = []       # [x, giờ, mặt]
var step_i := 0
var peaked := false
var sat_x := 0.0
var lanterns: Array = []


func _setup() -> void:
	sky_cols = [Color("#070a1e"), Color("#18204a"), Color("#3a2c4a")]
	far_col = Color("#120f22")
	near_col = Color("#24162a")
	mist_col = Color(0.5, 0.45, 0.75, 0.12)
	ground_cols = [Color("#7a3a2e"), Color("#3a1a18"), Color("#a0584a")]
	moon_on = true
	moon = Vector2(1500, 170)
	moon_col = Color(1.2, 1.15, 1.0)
	moon_glow = Color(0.8, 0.8, 1.0, 0.18)
	n_stars = 70
	slowmo = [PEAK - 0.12, PEAK + 0.55, 0.3]
	title = "Lăng Ba Vi Bộ"
	subtitle = "Đoàn Dự · sáu mươi tư bước quẻ né kéo cá sấu"
	title_at = 8.4
	title_col = HOT
	set_char(hero, "doan-du")
	set_char(foe, "nhac-lao-tam")
	hero.pos = Vector2(600, GROUND)
	foe.pos = Vector2(1350, GROUND)
	hero.col = COL
	foe.col = FOE_COL
	hero.base = "stance"
	foe.base = "stance"
	ghost = Chibi.new()
	l_chars.add_child(ghost)
	l_chars.move_child(ghost, 0)
	ghost.setup("doan-du")
	for i in 6:
		lanterns.append(Vector2(220 + i * 300 + rng.randf_range(-40, 40), 300 + rng.randf_range(-20, 30)))
	cue(1.0, "lib-riser", 0.7)
	for s in STEPS:
		cue(s[0] - 0.3, "lib-whoosh-short", 0.6)
	cue(PEAK - 0.45, "lib-whoosh-cinematic", 0.9)
	cue(PEAK + 0.9, "lib-whoosh", 0.5)


# ---- lưới quẻ: góc ô (hàng r, cột c) trên sân phối cảnh
func _gp(r: float, c: float) -> Vector2:
	var y := GY0 + r * 36.0 + r * r * 1.6
	var half := 640.0 + r * 70.0
	return Vector2(960.0 - half + c * (2.0 * half / COLS), y)


func _tile_at(x: float) -> Vector2i:
	var r := 2
	var y0 := _gp(r, 0).y
	var best := 0
	var bd := 1e9
	for c in COLS:
		var cx := (_gp(r + 0.5, c).x + _gp(r + 0.5, c + 1).x) * 0.5
		if absf(cx - x) < bd:
			bd = absf(cx - x)
			best = c
	return Vector2i(r, best)


func _tile_center(tl: Vector2i) -> Vector2:
	return (_gp(tl.x, tl.y) + _gp(tl.x + 1, tl.y + 1)) * 0.5


func _hexa(c: Node2D, p: Vector2, w: float, idx: int, col: Color, sy := 1.0) -> void:
	for k in 6:
		var y := p.y + (2.5 - k) * w * 0.22 * sy
		var hw := w * 0.5
		if (idx >> k) & 1:
			c.draw_line(Vector2(p.x - hw, y), Vector2(p.x + hw, y), col, maxf(1.5, w * 0.09 * sy))
		else:
			c.draw_line(Vector2(p.x - hw, y), Vector2(p.x - w * 0.09, y), col, maxf(1.5, w * 0.09 * sy))
			c.draw_line(Vector2(p.x + w * 0.09, y), Vector2(p.x + hw, y), col, maxf(1.5, w * 0.09 * sy))


func _keyed(keys: Array, x0: float) -> float:
	var x := x0
	for k in keys:
		if t >= k[0]:
			x = k[1]
	return x


func _story(_dt: float) -> void:
	# ---- Đoàn Dự: vị trí theo bước quẻ, bước = nhảy cung ngắn 0.16 s
	var dx := 600.0
	var hop := 0.0
	var prev := 600.0
	for s in STEPS:
		var a: float = s[0]
		if t >= a:
			var k := smooth(a, a + 0.24, t)
			dx = lerpf(prev, s[1], k)
			hop = maxf(hop, sin(clampf((t - a) / 0.24, 0.0, 1.0) * PI) * 4.6)
		if t >= a:
			prev = float(s[1])
	# đỉnh: lướt vòng ra sau lưng Ngạc Thần
	var back_x := 690.0
	if t >= PEAK - 0.14:
		var k2 := smooth(PEAK - 0.14, PEAK + 0.16, t)
		dx = lerpf(1130.0, back_x, k2)
		hop = maxf(hop, sin(clampf((t - PEAK + 0.14) / 0.3, 0.0, 1.0) * PI) * 5.6)
	hero.pos = Vector2(dx, GROUND - hop * 46.0)
	# ---- Ngạc Thần: lao tới, há kéo
	var fx := 1350.0
	var lunge := 0.0
	var px := 1350.0
	for l in LUNGE:
		var a: float = l[0]
		var b: float = l[1]
		if t >= a:
			fx = lerpf(px, l[2], ease_out(clampf((t - a) / (b - a), 0.0, 1.0)))
			lunge = maxf(lunge, smooth(a, a + 0.12, t) * (1.0 - smooth(b + 0.1, b + 0.45, t)))
		if t >= b:
			px = l[2]
	var after := t > PEAK + 0.15
	if not after:
		foe.pos = Vector2(fx, GROUND)
		var aim := 600.0
		for l in LUNGE:
			if t >= float(l[0]) - 0.45:
				aim = l[3]
		foe.face = signf(aim - foe.pos.x)
		hero.face = -foe.face if t < PEAK else 1.0
		foe.extra = [[DO_KEO, lunge]]
		foe.aura = 0.2 + lunge * 0.4
		foe.expr = "gian" if t < 3.0 else ("soc" if t < PEAK - 0.6 else "quyet-tam")
	else:
		# xoay chóng mặt rồi ngồi phịch
		var e := t - PEAK - 0.15
		var spin := clampf(e / 0.9, 0.0, 1.0)
		foe.face = 1.0 if int(e / 0.11) % 2 == 0 or spin >= 1.0 else -1.0
		var sit := smooth(PEAK + 1.0, PEAK + 1.35, t)
		foe.rot = sin(e * 9.0) * 0.12 * (1.0 - sit)
		foe.extra = [[DO_KEO, 1.0 - smooth(PEAK + 0.15, PEAK + 0.4, t)], [NGOI, sit]]
		foe.expr = "ko"
		foe.aura = 0.0
		if sit > 0.99 and not foe.has("landed"):
			foe.landed = true
			shake = maxf(shake, 10.0)
			sfx("lib-impact-bass-2", 0.45)
			for i in 14:
				emit("smoke", Vector2(foe.pos.x + rng.randf_range(-90, 90), GROUND), Vector2(rng.randf_range(-150, 150), -rng.randf_range(20, 90)), 1.6, rng.randf_range(30, 60), Color(0.55, 0.35, 0.3, 0.4))
	# ---- Dự: thế, biểu cảm
	var gath := smooth(1.0, 1.7, t) * (1.0 - smooth(2.1, 2.4, t))
	hero.gather = gath * 0.6
	var hopk := minf(1.0, hop)
	var point := smooth(PEAK + 0.12, PEAK + 0.22, t) * (1.0 - smooth(PEAK + 1.0, PEAK + 1.5, t))
	var calm := smooth(PEAK + 1.4, PEAK + 2.0, t)
	hero.extra = [[BUOC, hopk], ["point", point], [CHAP_SAU, calm]]
	hero.aura = gath * 0.7 + hop * 0.4 + point * 0.5
	hero.expr = "binh" if t < 1.0 else ("quyet-tam" if t < PEAK + 0.4 else ("dac-y" if t < 9.0 else "vui"))
	pose(hero, 0.0)
	pose(foe, 0.0)
	if gath > 0.05:
		orbit(hero, rng.randf_range(100, 220), rng.randf_range(2.2, 3.4), 240, rng.randf_range(2, 4), HOT, 2.2)
	# ---- mỗi bước: bóng mờ ở chỗ cũ, ô mới sáng, quẻ bay lên, hàm kéo khép vào bóng
	if step_i < STEPS.size() and t >= STEPS[step_i][0]:
		var s: Array = STEPS[step_i]
		var oldx: float = 600.0 if step_i == 0 else STEPS[step_i - 1][1]
		ghosts.append([oldx, t, hero.face])
		var tl := _tile_at(s[1])
		lit.append([tl, t])
		glyphs.append([tl, t])
		var snap := Vector2(oldx, GROUND - 170)
		add_ring(snap, 160, FOE_COL, 6, 0.3)
		burst(snap, 26, 240, 760, FOE_COL, Color(2.0, 1.4, 0.6), 700.0, 1.4)
		add_ring(_tile_center(tl), 220, HOT, 5, 0.4, 0.25)
		shake = maxf(shake, 11.0)
		sfx("lib-impact-bass-2", 0.55)
		sfx("lib-chime", 0.35)
		step_i += 1
	if t >= 1.2 and lit.is_empty():
		lit.append([_tile_at(600.0), 1.2])
	# ---- đỉnh
	if t >= PEAK and not peaked:
		peaked = true
		ghosts.append([1130.0, t, -1.0])
		var tl2 := _tile_at(back_x)
		lit.append([tl2, t])
		glyphs.append([tl2, t])
		flash = 0.55
		flash_col = Color(0.85, 1.0, 0.95)
		shake = 26.0
		var snap2 := Vector2(1130.0, GROUND - 175)
		add_ring(snap2, 520, FOE_COL, 14, 0.6)
		add_ring(Vector2(back_x, GROUND), 760, HOT, 9, 0.8, 0.22)
		burst(snap2, 110, 300, 1400, Color(2.0, 1.3, 0.5), FOE_COL, 800.0, 1.0)
		sfx("lib-impact-bass-1", 1.0)
		sfx("lib-impact-bass-2", 1.0)
	if t >= PEAK + 0.18 and not hero.has("diem"):
		hero.diem = true
		var hp: Vector2 = hero.handF
		add_ring(hp, 200, GOLD, 6, 0.35)
		burst(hp, 40, 200, 700, GOLD, HOT, 300.0, 1.6)
		sfx("lib-sparkle", 0.45)


func _cam() -> Array:
	var c := Vector2(930, 600)
	var z := 1.0
	var k1 := smooth(0.9, 1.6, t) * (1.0 - smooth(2.1, 2.5, t))
	c = c.lerp(hero.pos + Vector2(60, -200), k1)
	z = lerpf(z, 1.32, k1)
	var k2 := smooth(5.5, 6.0, t) * (1.0 - smooth(PEAK + 0.9, 8.6, t))
	c = c.lerp(Vector2(950, 640), k2)
	z = lerpf(z, 1.22, k2)
	var k3 := smooth(8.6, 10.2, t)
	c = c.lerp(Vector2(900, 600), k3)
	return [c, z]


# ---- nền: mái cong phủ vương + đèn lồng (đè lên dãy núi của engine)
func _draw_far(c: Node2D) -> void:
	c.draw_rect(Rect2(-400, 560, W + 800, 300), far_col)
	for i in 4:
		var x0 := -200.0 + i * 620.0
		var y0 := 470.0 + (i % 2) * 30.0
		var roof := PackedVector2Array([Vector2(x0 - 40, y0 + 40), Vector2(x0 + 60, y0), Vector2(x0 + 440, y0), Vector2(x0 + 540, y0 + 40),
			Vector2(x0 + 500, y0 + 52), Vector2(x0 + 20, y0 + 52)])
		c.draw_colored_polygon(roof, Color("#0c0a18"))
		c.draw_rect(Rect2(x0 + 40, y0 + 52, 440, 320), Color("#1a1428"))
		for j in 5:
			c.draw_rect(Rect2(x0 + 70 + j * 84, y0 + 90, 46, 70), Color(0.9, 0.55, 0.25, 0.22))
	for lp in lanterns:
		var sw := sin(rt * 1.4 + lp.x) * 4.0
		var p: Vector2 = lp + Vector2(sw, 0)
		c.draw_line(Vector2(lp.x, 230), p - Vector2(0, 30), Color(0.1, 0.08, 0.1), 2.0)
		c.draw_texture_rect(soft, Rect2(p - Vector2(70, 70), Vector2(140, 140)), false, Color(1.4, 0.5, 0.25, 0.35))
		c.draw_colored_polygon(_oval(p, Vector2(24, 30)), Color(1.25, 0.35, 0.2))
		c.draw_rect(Rect2(p.x - 14, p.y - 34, 28, 6), Color(0.25, 0.12, 0.08))
		c.draw_rect(Rect2(p.x - 14, p.y + 28, 28, 6), Color(0.25, 0.12, 0.08))


func _oval(p: Vector2, r: Vector2) -> PackedVector2Array:
	var o := PackedVector2Array()
	for i in 24:
		var a := TAU * i / 24.0
		o.append(p + Vector2(cos(a) * r.x, sin(a) * r.y))
	return o


func _fx_ground(c: Node2D) -> void:
	# lưới 64 ô quẻ hiện dần theo sóng lúc tụ khí
	var wave := smooth(1.0, 2.2, t)
	for r in ROWS:
		for col in COLS:
			var a := _gp(r, col)
			var b := _gp(r, col + 1)
			var d := _gp(r + 1, col + 1)
			var e := _gp(r + 1, col)
			var idx := r * COLS + col
			var ctr := (a + d) * 0.5
			var on := clampf(wave * 1.6 - absf(ctr.x - 600.0) / 1500.0, 0.0, 1.0)
			var tile_col := Color("#8a4234") if (r + col) % 2 == 0 else Color("#6e3228")
			c.draw_colored_polygon(PackedVector2Array([a, b, d, e]), tile_col)
			c.draw_polyline(PackedVector2Array([a, b, d, e, a]), Color(0.25, 0.1, 0.08, 0.8), 2.0)
			if on > 0.01:
				var w := (b.x - a.x) * 0.36
				_hexa(c, ctr, w, (idx * 37 + 11) % 64, Color(0.9, 0.75, 0.55, 0.28 * on), 0.45)


func _fx_back(c: Node2D) -> void:
	# đường bước nối các ô đã đặt chân (nét quẻ đứt nối)
	if lit.size() >= 2:
		for i in range(1, lit.size()):
			var a: Vector2 = _tile_center(lit[i - 1][0])
			var b: Vector2 = _tile_center(lit[i][0])
			var k := clampf((t - float(lit[i][1])) / 0.25, 0.0, 1.0)
			var e := a.lerp(b, k)
			var n := 12
			for j in n:
				if j % 2 == 1 and i % 2 == 0:
					continue
				var p0 := a.lerp(e, float(j) / n)
				var p1 := a.lerp(e, float(j + 0.8) / n)
				c.draw_line(p0 - Vector2(0, 8), p1 - Vector2(0, 8), COL * Color(1, 1, 1, 0.55), 5.0)


func _fx_norm(c: Node2D) -> void:
	# bóng mờ của Dự ở chỗ cũ (bị kéo cắn vào)
	var g_on := false
	for gh in ghosts:
		var age := t - float(gh[1])
		if age >= 0.0 and age < 0.75:
			g_on = true
			ghost.visible = true
			ghost.position = Vector2(gh[0], GROUND)
			ghost.scale = Vector2(gh[2], 1.0) * CS
			ghost.apply(Chibi.P("stance"), 0.0)
			ghost.set_expr("binh")
			ghost.modulate = Color(0.45, 1.3, 1.2, 0.5 * (1.0 - age / 0.75))
	if not g_on:
		ghost.visible = false
	# kéo mỏ cá sấu ở tay F của Ngạc Thần
	var hp: Vector2 = foe.handF
	var dir := Vector2(foe.face, 0).rotated(-0.12 * foe.face)
	var open := 0.08
	for l in LUNGE:
		var a: float = l[0]
		var b: float = l[1]
		open = maxf(open, smooth(a, a + 0.15, t) * (1.0 - smooth(b - 0.04, b + 0.02, t)) * 1.1)
	if t > PEAK + 0.3:
		open = 0.25 + sin(t * 5.0) * 0.1
	_keo(c, hp, dir, open)


func _keo(c: Node2D, p: Vector2, dir: Vector2, open: float) -> void:
	var n := dir.orthogonal()
	var ln := 150.0
	for s: float in [-1.0, 1.0]:
		var d := dir.rotated(s * open * 0.5 * signf(dir.x))
		var nn: Vector2 = d.orthogonal() * s * signf(dir.x)
		var tip := p + d * ln
		var poly := PackedVector2Array([p - nn * 10, p + d * 40 - nn * 34, p + d * 110 - nn * 26, tip - nn * 8, tip + nn * 6, p + d * 20 + nn * 6])
		c.draw_colored_polygon(poly, Color("#5e6a3a"))
		c.draw_polyline(PackedVector2Array([p - nn * 10, p + d * 40 - nn * 34, p + d * 110 - nn * 26, tip - nn * 8, tip + nn * 6]), Color("#2a2a18"), 3.0)
		c.draw_circle(p + d * 50 - nn * 20, 5, Color("#e8c040"))
		for k in 6:
			var q: Vector2 = p + d * (40 + k * 18) + nn * 2
			c.draw_colored_polygon(PackedVector2Array([q, q + d * 9, q + d * 4 + nn * 9]), Color("#f0e6c8"))
	c.draw_circle(p, 12, Color("#c9a03a"))
	c.draw_circle(p - dir * 22 + n * 10, 10, Color("#3a3018"))
	c.draw_circle(p - dir * 22 - n * 10, 10, Color("#3a3018"))


func _fx_add(c: Node2D) -> void:
	# ô đã đặt chân sáng ngọc lam
	for L in lit:
		var tl: Vector2i = L[0]
		var age := t - float(L[1])
		var a := _gp(tl.x, tl.y)
		var b := _gp(tl.x, tl.y + 1)
		var d := _gp(tl.x + 1, tl.y + 1)
		var e := _gp(tl.x + 1, tl.y)
		var k := clampf(age / 0.2, 0.0, 1.0) * (0.55 + 0.45 * exp(-age * 2.0))
		c.draw_colored_polygon(PackedVector2Array([a, b, d, e]), COL * Color(1, 1, 1, 0.35 * k))
		c.draw_polyline(PackedVector2Array([a, b, d, e, a]), HOT * Color(1, 1, 1, 0.6 * k), 3.0)
	# quẻ bay lên khỏi ô
	for G in glyphs:
		var age := t - float(G[1])
		if age < 0.0 or age > 1.3:
			continue
		var tl: Vector2i = G[0]
		var p := _tile_center(tl) - Vector2(0, 380 + age * 120)
		var al := sin(clampf(age / 1.3, 0.0, 1.0) * PI)
		_hexa(c, p, 120, (tl.x * COLS + tl.y) * 23 % 64, HOT * Color(1, 1, 1, 0.75 * al))
	# sợi chỉ vàng Nhất Dương Chỉ của cha chạm lưng Dự
	var gk := smooth(PEAK + 0.05, PEAK + 0.16, t) * (1.0 - smooth(PEAK + 0.6, PEAK + 1.0, t))
	if gk > 0.01:
		var back: Vector2 = hero.pos + Vector2(-30 * hero.face, -150)
		var src := Vector2(-60, 380)
		c.draw_line(src, back, GOLD * Color(1, 1, 1, 0.18 * gk), 9.0)
		c.draw_line(src, back, GOLD * Color(1, 1, 1, 0.7 * gk), 2.5)
		blob(c, back, 34 * gk, GOLD * Color(1, 1, 1, 0.6))
	# điểm huyệt: chấm vàng trên lưng Ngạc Thần
	var dk := smooth(PEAK + 0.15, PEAK + 0.25, t) * (1.0 - smooth(PEAK + 1.2, PEAK + 1.8, t))
	if dk > 0.01:
		blob(c, hero.handF, 26 * dk, GOLD)
	# sao chóng mặt quanh đầu
	var sk := smooth(PEAK + 0.5, PEAK + 0.9, t)
	if sk > 0.01:
		for i in 3:
			var ang := t * 4.0 + i * TAU / 3.0
			var sp: Vector2 = foe.head + Vector2(cos(ang) * 70, -60 + sin(ang) * 18)
			_star(c, sp, 14 * sk, Color(1.9, 1.6, 0.5, sk))


func _star(c: Node2D, p: Vector2, r: float, col: Color) -> void:
	var pts := PackedVector2Array()
	for i in 10:
		var a := -PI * 0.5 + i * PI / 5.0
		var rr := r if i % 2 == 0 else r * 0.45
		pts.append(p + Vector2(cos(a), sin(a)) * rr)
	c.draw_colored_polygon(pts, col)
