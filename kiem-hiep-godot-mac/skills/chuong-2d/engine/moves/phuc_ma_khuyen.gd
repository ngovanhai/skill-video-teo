extends "res://engine.gd"
# KIM CƯƠNG PHỤC MA KHUYÊN (12 s): đêm trăng trên đỉnh đồi sau chùa Thiếu Lâm, đất đỏ son, trời xanh chàm sáng trăng.
# Ba lão tăng Độ Ách, Độ Kiếp, Độ Nạn ngồi thành tam giác, mỗi người một roi đen dài.
# Trương Vô Kỵ ba lần phóng chưởng, mỗi lần một ngọn roi quất ra đỡ và đầu roi ở lại thành một cung vàng;
# đủ ba cung thì khép thành chiếc vòng kim cương. Đỉnh: Vô Kỵ dồn toàn lực, vòng thắt lại nuốt quả chưởng rồi bung
# thành sóng vòng, Vô Kỵ bị đẩy trượt lùi trên đất đỏ, quỳ một gối thở (không văng, không thương tích).
# Thẻ chiêu: ba lão tăng · Trương Vô Kỵ · ba roi ba cung khép thành vòng kín, nuốt chưởng rồi dội · vàng kim vs tím lam ·
#            đỉnh đồi đất đỏ dưới trăng tròn lớn · vòng thắt nuốt chưởng, sóng vòng đẩy trượt lùi

const COL := Color(1.6, 1.15, 0.3)
const HOT := Color(2.3, 1.9, 0.85)
const FOE_COL := Color(0.6, 0.45, 1.6)
const FOE_HOT := Color(1.3, 1.1, 2.3)
const BEATS := [2.5, 3.5, 4.5]
const BIG := 5.85
const PEAK := 6.15
const RC := Vector2(1000, 500)
const RR := 150.0
const WHIP := Color("#16100c")

var mb := {}
var mc := {}
var monks: Array = []
var beat_i := 0
var hit := false
var knelt := false
var x_hit := 0.0
var pines: Array = []


func _setup() -> void:
	sky_cols = [Color("#0b2230"), Color("#2a5866"), Color("#7aa39e")]
	moon = Vector2(1420, 250)
	moon_col = Color(1.45, 1.38, 1.15)
	moon_glow = Color(0.9, 0.95, 0.85, 0.32)
	moon_craters = true
	n_stars = 60
	far_col = Color("#1f4450")
	near_col = Color("#2a2f36")
	mist_col = Color(0.75, 0.85, 0.85, 0.2)
	ground_cols = [Color("#8a3f2c"), Color("#2e120c"), Color("#c46a48")]
	slowmo = [PEAK - 0.05, PEAK + 0.62, 0.3]
	title = "KIM CƯƠNG PHỤC MA KHUYÊN"
	subtitle = "Độ Ách · Độ Kiếp · Độ Nạn"
	title_at = 8.6
	title_col = HOT
	set_char(foe, "truong-vo-ky")
	set_char(hero, "do-ach")
	mb = fighter("do-kiep", Vector2(1480, GROUND - 70), -1.0, COL)
	mc = fighter("do-nan", Vector2(1690, GROUND), -1.0, COL)
	l_chars.move_child(mb.node, 0)
	hero.pos = Vector2(1250, GROUND)
	hero.face = -1.0
	foe.pos = Vector2(520, GROUND)
	foe.face = 1.0
	mb.scale = 0.84
	monks = [hero, mb, mc]
	for m in monks:
		m.base = "kneel"
		m.col = COL
	foe.col = FOE_COL
	var r := RandomNumberGenerator.new()
	r.seed = 31
	for x in [1180.0, 1560.0, 1860.0]:
		pines.append([x + r.randf_range(-30, 30), r.randf_range(380, 470), r.randf_range(0, TAU)])
	cue(1.0, "lib-riser", 0.75)
	cue(BIG - 0.5, "lib-riser", 0.5)
	cue(PEAK - 0.3, "lib-whoosh-cinematic", 0.9)


func _spin() -> float:
	return t * 1.6


# đầu roi thứ i
func _tip(i: int) -> Vector2:
	var m: Dictionary = monks[i]
	var b: float = BEATS[i]
	var hand: Vector2 = m.handF
	var mpos: Vector2 = m.pos
	var msc: float = m.scale
	var rest := hand + Vector2(-120.0 - 30.0 * i, 160.0 - (mpos.y - GROUND) * 0.3)
	var lift := mpos + Vector2(-60, -330 * msc) + Vector2(cos(t * 5.0 + i * 2.0), sin(t * 5.0 + i * 2.0)) * 60.0
	var ring := RC + Vector2(cos(_spin() + i * TAU / 3.0), sin(_spin() + i * TAU / 3.0)) * RR
	var strike := RC + Vector2(-RR, 0)
	var p := rest.lerp(lift, smooth(1.0, 1.9, t))
	p = p.lerp(strike, smooth(b - 0.15, b + 0.02, t))
	p = p.lerp(ring, smooth(b + 0.25, b + 0.7, t))
	p = p.lerp(rest, smooth(8.6, 9.8, t))
	return p


func _whip_pts(i: int) -> PackedVector2Array:
	var m: Dictionary = monks[i]
	var a: Vector2 = m.handF
	var b := _tip(i)
	var mid := (a + b) * 0.5 + Vector2(0, 70) + (b - a).orthogonal().normalized() * sin(t * 7.0 + i) * 30.0
	var pts := PackedVector2Array()
	for k in 25:
		var u := float(k) / 24.0
		pts.append(a.lerp(mid, u).lerp(mid.lerp(b, u), u))
	return pts


func _arcs() -> int:
	var n := 0
	for b in BEATS:
		if t >= b + 0.7:
			n += 1
	return n


func _story(_dt: float) -> void:
	# ---- ba lão tăng
	for i in 3:
		var m: Dictionary = monks[i]
		var b: float = BEATS[i]
		var up := smooth(1.0, 1.8, t) * (1.0 - smooth(8.6, 9.6, t))
		var crack := pulse(b - 0.15, b + 0.05, 0.25, t) + pulse(PEAK - 0.1, PEAK + 0.1, 0.4, t)
		m.extra = [[{"uaF": -150, "faF": -30, "uaB": 30, "faB": -110, "head": -4}, up * (1.0 - crack)],
			[{"uaF": -88, "faF": 4, "uaB": 30, "faB": -100, "torso": -8}, minf(1.0, crack)]]
		m.aura = up * 0.35 + smooth(BIG - 0.4, PEAK, t) * 0.45 - smooth(7.2, 9.0, t) * 0.8
		m.expr = "ngai" if t > 8.6 else ("quyet-tam" if t > 1.0 else "binh")
		if i > 0:
			pose(m, DT)
	# ---- Vô Kỵ
	if not hit:
		var bp := 0.0
		for b in BEATS:
			bp = maxf(bp, pulse(b - 0.2, b + 0.05, 0.3, t))
		var big := smooth(BIG - 0.7, BIG - 0.15, t)
		foe.gather = smooth(1.0, 1.7, t) * (1.0 - smooth(2.2, 2.4, t)) * 0.6 + big * (1.0 - smooth(BIG - 0.1, BIG, t))
		foe.push = bp + smooth(BIG - 0.1, BIG, t)
		foe.both = smooth(BIG - 0.8, BIG - 0.3, t)
		foe.lean = foe.push * 0.35
		foe.aura = 0.3 + big * 0.6
		foe.expr = "soc" if t > 4.7 else ("quyet-tam" if t > 1.0 else "binh")
		var back := 0.0
		for b in BEATS:
			back += 34.0 * smooth(b + 0.02, b + 0.3, t)
		foe.pos.x = 560.0 - back + 190.0 * smooth(BIG - 0.6, BIG - 0.1, t)
	pose(hero, 0.0)
	pose(foe, 0.0)

	for m in monks:
		if m.aura > 0.1 and t < 2.4 and rng.randf() < 0.5:
			orbit(m, rng.randf_range(80, 180), 2.6, 180, 3.0, HOT, 2.4)

	# ---- mỗi nhịp: một roi quất đỡ chưởng, đầu roi ở lại thành một cung
	if beat_i < BEATS.size() and t >= BEATS[beat_i]:
		var at := RC + Vector2(-RR, 0)
		add_ring(at, 200, HOT, 7, 0.35)
		burst(at, 34, 300, 900, HOT, FOE_HOT, 500.0, 1.4, PI * 0.6, PI * 1.4)
		shake = maxf(shake, 12.0)
		sfx("lib-whoosh-short", 0.6)
		sfx("lib-impact-bass-2", 0.6)
		beat_i += 1
	# ---- đỉnh
	if t >= PEAK and not hit:
		hit = true
		x_hit = foe.pos.x
		foe.expr = "ko"
		flash = 0.6
		flash_col = Color(1.0, 0.95, 0.8)
		shake = 30.0
		add_ring(RC, 720, HOT, 18, 0.75)
		add_ring(Vector2(RC.x, GROUND), 900, COL, 10, 0.9, 0.2)
		burst(RC, 140, 300, 1500, HOT, FOE_HOT, 700.0, 1.0)
		sfx("lib-impact-bass-1", 1.0)
		sfx("lib-impact-bass-2", 1.0)
	# ---- hậu quả: trượt lùi trên đất đỏ, quỳ một gối
	if hit:
		var k := clampf((t - PEAK - 0.12) / 1.1, 0.0, 1.0)
		foe.pos = Vector2(lerpf(x_hit, 330.0, ease_out(k)), GROUND)
		foe.push = 0.0
		foe.gather = 0.0
		foe.both = 0.0
		foe.aura = 0.0
		foe.hurt = 0.35 * (1.0 - k)
		foe.crouch = 0.5 * k
		foe.lean = -0.5 * (1.0 - k) + 0.2 * k
		foe.extra = [["guard", 0.7 * (1.0 - k)], ["kneel", smooth(0.6, 1.0, k)]]
		foe.expr = "soc" if t > 9.8 else "ko"
		if k > 0.02 and k < 0.95:
			emit("smoke", Vector2(foe.pos.x + 40, GROUND), Vector2(rng.randf_range(40, 200), -rng.randf_range(10, 60)), 1.2, rng.randf_range(20, 40), Color(0.7, 0.4, 0.3, 0.45))
		if k >= 1.0 and not knelt:
			knelt = true
			shake = maxf(shake, 12.0)
			sfx("lib-impact-bass-2", 0.5)
			for i in 16:
				emit("smoke", Vector2(330 + rng.randf_range(-80, 120), GROUND), Vector2(rng.randf_range(-140, 160), -rng.randf_range(20, 100)), 1.8, rng.randf_range(36, 66), Color(0.72, 0.42, 0.32, 0.42))


func _cam() -> Array:
	var c := CENTER
	var z := 1.0
	var k1 := smooth(0.9, 1.7, t) * (1.0 - smooth(2.1, 2.5, t))       # tụ khí: tam giác ba lão tăng
	c = c.lerp(Vector2(1450, 560), k1)
	z = lerpf(z, 1.32, k1)
	var k2 := smooth(2.3, 2.7, t) * (1.0 - smooth(5.1, 5.5, t))       # biểu diễn: thấy cả chưởng và vòng
	c = c.lerp(Vector2(1010, 560), k2)
	z = lerpf(z, 1.08, k2)
	var k3 := smooth(5.3, 5.9, t) * (1.0 - smooth(PEAK + 0.3, 8.0, t))  # đỉnh: sát vòng
	c = c.lerp(RC + Vector2(-60, 40), k3)
	z = lerpf(z, 1.3, k3)
	var k4 := smooth(PEAK + 0.3, 7.6, t) * (1.0 - smooth(8.3, 9.6, t))  # theo Vô Kỵ trượt lùi
	c = c.lerp(Vector2(700, 600), k4)
	z = lerpf(z, 1.12, k4)
	var k5 := smooth(8.4, 10.2, t)
	c = c.lerp(Vector2(1000, 580), k5)
	return [c, z]


# ---------------------------------------------------------------- vẽ

func _fx_ground(c: Node2D) -> void:
	# ba cây tùng sau lưng ba lão tăng
	for p in pines:
		var x: float = p[0]
		var h: float = p[1]
		var sw := sin(rt * 0.8 + p[2]) * 5.0
		c.draw_line(Vector2(x, GROUND), Vector2(x + sw, GROUND - h), Color("#2a1a14"), 16.0)
		for j in 4:
			var y := GROUND - h * (0.45 + j * 0.17)
			var w := 170.0 - j * 34.0
			c.draw_colored_polygon(PackedVector2Array([Vector2(x + sw - w, y + 30), Vector2(x + sw + w * 0.9, y + 26), Vector2(x + sw + 10, y - 50)]), Color("#183028").lerp(Color("#28463a"), j * 0.25))
	# vết roi kéo trên đất và quầng vàng dưới tam giác
	var g := smooth(1.0, 2.0, t) * (1.0 - smooth(9.0, 10.5, t))
	if g > 0.0:
		flat_blob(c, Vector2(1480, GROUND + 6), 420, 0.14, Color(1.0, 0.75, 0.3, 0.3 * g))
		c.draw_set_transform(Vector2(1480, GROUND - 30), 0.0, Vector2(1.0, 0.2))
		var pts := PackedVector2Array([Vector2(-260, 150), Vector2(0, -240), Vector2(260, 150), Vector2(-260, 150)])
		c.draw_polyline(pts, Color(1.0, 0.8, 0.4, 0.4 * g), 8.0)
		c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	# vết trượt của Vô Kỵ
	if hit:
		var x0 := x_hit
		var x1: float = foe.pos.x
		c.draw_line(Vector2(x1, GROUND + 4), Vector2(x0, GROUND + 4), Color("#4a1a10"), 7.0)
		c.draw_line(Vector2(x1 + 30, GROUND + 14), Vector2(x0 + 30, GROUND + 14), Color("#4a1a10"), 5.0)


func _fx_norm(c: Node2D) -> void:
	for i in 3:
		var pts := _whip_pts(i)
		c.draw_polyline(pts, WHIP, 6.0)
		c.draw_polyline(pts, Color("#4a3a2a"), 2.0)
		c.draw_circle(pts[pts.size() - 1], 6.0, WHIP)


func _fx_add(c: Node2D) -> void:
	var on := smooth(1.0, 1.8, t) * (1.0 - smooth(8.6, 9.6, t))
	# roi tích kim cương lực: viền sáng mảnh
	for i in 3:
		if on > 0.0:
			c.draw_polyline(_whip_pts(i), COL * Color(1, 1, 1, 0.35 * on), 3.0)
	# các cung vàng: mỗi roi một cung, đủ ba thành vòng khép kín
	var n := _arcs()
	var fade := 1.0 - smooth(8.6, 9.6, t)
	var pinch := 1.0 - 0.45 * pulse(BIG + 0.05, PEAK, 0.2, t)
	var r := RR * pinch
	for i in n:
		var a0 := _spin() + i * TAU / 3.0
		c.draw_arc(RC, r, a0, a0 + TAU / 3.0, 32, COL * Color(1, 1, 1, 0.9 * fade), 7.0)
		c.draw_arc(RC, r, a0, a0 + TAU / 3.0, 32, HOT * Color(1, 1, 1, 0.8 * fade), 2.5)
		c.draw_arc(RC, r + 16.0, a0, a0 + TAU / 3.0, 32, COL * Color(1, 1, 1, 0.18 * fade), 14.0)
	if n == 3:
		# chữ vạn nhỏ ở mấu nối (dấu khép vòng)
		for i in 3:
			var p := RC + Vector2(cos(_spin() + i * TAU / 3.0), sin(_spin() + i * TAU / 3.0)) * r
			c.draw_circle(p, 9.0, HOT * Color(1, 1, 1, fade))
		blob(c, RC, r * 1.1, COL * Color(1, 1, 1, 0.14 * fade))
	# chưởng của Vô Kỵ ở mỗi nhịp: phóng tới mép vòng rồi bị dội
	for b in BEATS:
		var age: float = t - b + 0.2
		if age > 0.0 and age < 0.5:
			var a: Vector2 = foe.hand
			var e := RC + Vector2(-RR, 0)
			var head := a.lerp(e, clampf(age / 0.2, 0.0, 1.0))
			var tail := a.lerp(e, smooth(0.2, 0.5, age))
			beam(c, tail, head, FOE_COL, FOE_HOT, 34.0)
	# toàn lực: quả chưởng bay vào vòng, bị vòng thắt nuốt
	var ab := t - (BIG - 0.05)
	if ab > -0.5 and t < PEAK + 0.05:
		var p0: Vector2 = foe.hand
		if ab < 0.0:
			var s := smooth(-0.5, 0.0, ab)
			blob(c, p0, 60.0 * s, FOE_COL * Color(1, 1, 1, 0.35))
			blob(c, p0, 26.0 * s, FOE_HOT)
		else:
			var k := clampf(ab / (PEAK - BIG + 0.05), 0.0, 1.0)
			var p := p0.lerp(RC, ease_out(k))
			var s2 := 1.0 - 0.6 * smooth(0.6, 1.0, k)
			blob(c, p, 90.0 * s2, FOE_COL * Color(1, 1, 1, 0.35))
			blob(c, p, 38.0 * s2, FOE_HOT)
	if hit and t < PEAK + 0.3:
		blob(c, RC, 140.0, HOT * Color(1, 1, 1, 0.3))
	# sóng vòng đẩy về phía Vô Kỵ
	if hit:
		var k := clampf((t - PEAK) / 0.7, 0.0, 1.0)
		if k < 1.0:
			var x := lerpf(RC.x - RR, foe.pos.x + 120.0, ease_out(k))
			c.draw_set_transform(Vector2(x, 560), 0.0, Vector2(0.35, 1.0))
			c.draw_arc(Vector2.ZERO, 260.0, -PI * 0.5, PI * 0.5, 40, HOT * Color(1, 1, 1, 0.6 * (1.0 - k)), 9.0)
			c.draw_arc(Vector2.ZERO, 230.0, -PI * 0.5, PI * 0.5, 40, COL * Color(1, 1, 1, 0.2 * (1.0 - k)), 24.0)
			c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
