extends "res://engine.gd"
# Cửu Âm Bạch Cốt Trảo (tap-04 Cửu Dương vs Cửu Âm, 2026-10-22)
# Thẻ chiêu: Mai Siêu Phong (mù) · Quách Tĩnh trẻ (chỉ né, lùi) · NGHE TIẾNG mà ra đòn: mỗi bước chân đối thủ
# toả vòng âm thanh, đầu bà giật về phía đó, bóng vuốt đen năm móng chụp đúng chỗ, để lại 5 rãnh cào xanh xương trên đất ·
# xanh xương + đen tím vs cam ấm · đêm trăng khuyết thảo nguyên cỏ khô xám lục (vách đá Mông Cổ) ·
# đỉnh: bà vọt lên, bóng vuốt khổng lồ chụp từ trên xuống, năm vệt cào xé chéo cả khung.

const COL := Color(0.75, 1.25, 0.85)      # xanh xương
const HOT := Color(1.55, 2.0, 1.45)
const SHADE := Color(0.07, 0.03, 0.10, 0.88)   # bóng vuốt (vật thể đặc, blend thường)
const FOE_COL := Color(1.5, 0.95, 0.35)
const BEATS := [2.6, 3.7, 4.75]           # mỗi nhịp: bước chân -> vòng âm -> vuốt chụp
const PEAK := 6.15
const LAND_X := 1470.0

const TRAO := {"uaF": -112.0, "faF": -28.0, "uaB": 34.0, "faB": -96.0, "torso": -12.0, "head": -6.0,
	"thF": -40.0, "shF": 40.0, "thB": 30.0, "shB": -10.0, "all": [0.0, 10.0, 26.0]}
const NGHE := {"head": 16.0, "torso": 4.0, "uaF": -60.0, "faF": -70.0, "uaB": 20.0, "faB": -60.0}
const NE := {"torso": 14.0, "head": 8.0, "thF": 20.0, "shF": 30.0, "thB": -30.0, "shB": 40.0, "uaF": -80.0, "faF": -100.0,
	"uaB": 30.0, "faB": -80.0, "all": [0.0, 0.0, 30.0]}

var beat_i := 0
var hit := false
var x_hit := 0.0
var grooves: Array = []       # {p, ang, len, t0, big}
var claws: Array = []         # {a, b, t0, dur, s}
var steps: Array = []         # mốc bước chân để vẽ vòng âm


func _setup() -> void:
	sky_cols = [Color("#1d3a33"), Color("#4f6f5f"), Color("#93a487")]
	far_col = Color("#3f5a4c")
	near_col = Color("#5a6a4a")
	mist_col = Color(0.75, 0.85, 0.75, 0.18)
	ground_cols = [Color("#7a7652"), Color("#3b3a26"), Color("#a29d6c")]
	moon_on = false
	n_stars = 90
	slowmo = [PEAK - 0.06, PEAK + 0.62, 0.3]
	title = "Cửu Âm Bạch Cốt Trảo"
	subtitle = "Mai Siêu Phong · nghe tiếng gió mà ra đòn"
	title_at = 8.4
	title_col = HOT
	flash_col = Color(0.85, 1.0, 0.85)
	set_char(hero, "mai-sieu-phong")
	set_char(foe, "quach-tinh")
	hero.pos = Vector2(470, GROUND)
	foe.pos = Vector2(1330, GROUND)
	hero.col = COL
	foe.col = FOE_COL
	foe.base = "stance"
	cue(1.0, "lib-riser", 0.75)
	for b in BEATS:
		cue(b - 0.32, "lib-whoosh-short", 0.6)
	cue(PEAK - 0.35, "lib-whoosh-cinematic", 0.9)


func _story(_dt: float) -> void:
	# ---- Mai Siêu Phong: tụ khí cúi thấp, tay vuốt; mỗi nhịp lao tới một quãng
	var gk := smooth(1.0, 1.9, t)
	hero.gather = gk * (1.0 - smooth(2.1, 2.4, t)) * 0.7
	var lunge := 0.0
	var hear := 0.0
	for b in BEATS:
		lunge = maxf(lunge, pulse(b - 0.05, b + 0.22, 0.35, t))
		hear = maxf(hear, pulse(b - 0.45, b - 0.12, 0.12, t))
	var leap := smooth(5.35, 5.85, t) * (1.0 - smooth(PEAK + 0.3, PEAK + 1.1, t))
	hero.extra = [[NGHE, hear * (1.0 - leap)], [TRAO, maxf(lunge, smooth(2.2, 2.5, t) * 0.55) * (1.0 - leap)], ["fly", leap * 0.8],
		[TRAO, smooth(PEAK - 0.15, PEAK, t) * (1.0 - smooth(PEAK + 0.9, 8.6, t))]]
	var hx := 470.0 + 70.0 * smooth(2.5, 2.9, t) + 80.0 * smooth(3.6, 4.0, t) + 70.0 * smooth(4.65, 5.05, t)
	hx += 260.0 * smooth(5.4, PEAK, t) - 120.0 * smooth(PEAK + 0.6, 8.4, t)
	hero.pos = Vector2(hx, GROUND - sin(clampf((t - 5.4) / (PEAK + 0.5 - 5.4), 0.0, 1.0) * PI) * 230.0)
	hero.lean = lunge * 0.5
	hero.aura = gk * 0.45 + leap * 0.6 - smooth(7.2, 9.0, t) * 0.9
	hero.expr = "dac-y" if t > 8.2 else ("gian" if t > 1.0 else "binh")

	# ---- Quách Tĩnh: bước né (mỗi bước = một tiếng động), lùi dần; không bị hạ nhục
	if not hit:
		var fx := 1330.0
		for i in BEATS.size():
			var b: float = BEATS[i]
			fx += [70.0, -40.0, 60.0][i] * smooth(b - 0.5, b - 0.3, t)     # bước tránh
			fx += 30.0 * smooth(b + 0.02, b + 0.25, t)                     # bị khí vuốt đẩy lùi
		foe.pos = Vector2(fx, GROUND)
		var dodge := 0.0
		for b in BEATS:
			dodge = maxf(dodge, pulse(b - 0.08, b + 0.18, 0.3, t))
		foe.extra = [[NE, dodge], ["guard", smooth(4.9, 5.4, t)]]
		foe.gather = smooth(5.2, 5.8, t) * 0.5
		foe.aura = foe.gather * 0.7
		foe.expr = "soc" if t > 3.6 else ("quyet-tam" if t > 1.4 else "binh")
	pose(hero, 0.0)
	pose(foe, 0.0)

	if hero.gather > 0.05:
		orbit(hero, rng.randf_range(120, 280), rng.randf_range(2.0, 3.2), 240, rng.randf_range(2, 4), COL, 2.3)

	# ---- [CƠ CHẾ] bước chân -> vòng âm -> đầu giật -> bóng vuốt chụp -> 5 rãnh
	if beat_i < BEATS.size():
		var b: float = BEATS[beat_i]
		if t >= b - 0.42 and steps.size() <= beat_i:
			var fp: Vector2 = foe.pos + Vector2(0, 4)
			steps.append(fp)
			add_ring(fp, 170, Color(0.9, 1.0, 0.95, 0.9), 3, 0.55, 0.28)
			add_ring(fp, 260, Color(0.9, 1.0, 0.95, 0.6), 2, 0.7, 0.28, 0.1)
			add_ring(fp, 360, Color(0.9, 1.0, 0.95, 0.4), 2, 0.8, 0.28, 0.2)
			sfx("lib-glitch-1", 0.35)
		if t >= b - 0.1 and claws.size() <= beat_i:
			var tg: Vector2 = steps[beat_i] + Vector2(-40, -150)
			claws.append({"a": hero.handF, "b": tg, "t0": t, "dur": 0.22, "s": 1.25})
		if t >= b + 0.12:
			var at: Vector2 = steps[beat_i]
			_rake(at + Vector2(-90, 0), 0.0, 170.0, false)
			add_ring(at + Vector2(-60, -120), 200, HOT, 6, 0.35)
			burst(at + Vector2(-60, -60), 26, 300, 900, HOT, COL, 700.0, 1.4, -PI * 0.95, -PI * 0.05)
			for i in 6:
				emit("rock", at + Vector2(rng.randf_range(-120, 40), -6), Vector2(rng.randf_range(-200, 200), -rng.randf_range(200, 520)), 1.2, rng.randf_range(5, 10), Color("#5a5638"), 1400.0)
			shake = maxf(shake, 12.0)
			sfx("lib-impact-bass-2", 0.6)
			beat_i += 1

	# ---- đỉnh: bóng vuốt khổng lồ từ trên chụp xuống + 5 vệt cào chéo
	if t >= PEAK - 0.12 and claws.size() == BEATS.size():
		claws.append({"a": Vector2(foe.pos.x - 260, -200), "b": foe.pos + Vector2(-30, -200), "t0": t, "dur": 0.16, "s": 3.2})
	if t >= PEAK and not hit:
		hit = true
		x_hit = foe.pos.x
		foe.expr = "soc"
		flash = 0.6
		shake = 30.0
		var at: Vector2 = foe.pos + Vector2(-40, -180)
		for i in 5:
			_rake(Vector2(foe.pos.x - 420 + i * 70, GROUND - 6), -0.18, 300.0, true)
		add_ring(at, 720, HOT, 18, 0.7)
		add_ring(Vector2(at.x, GROUND), 820, COL, 10, 0.9, 0.2)
		burst(at, 150, 300, 1600, HOT, Color(1.8, 2.0, 1.8), 800.0, 1.0)
		sfx("lib-impact-bass-1", 1.0)
		sfx("lib-impact-bass-2", 1.0)
	# ---- hậu quả: bị khí vuốt hất theo cung, đáp quỳ một gối, vẫn tỉnh
	if hit:
		var k := clampf((t - PEAK) / 0.9, 0.0, 1.0)
		foe.pos = Vector2(lerpf(x_hit, LAND_X, ease_out(k)), GROUND - sin(k * PI) * 120.0)
		foe.rot = sin(k * PI) * 0.6
		foe.hurt = sin(k * PI) * 0.8
		foe.extra = [["kneel", smooth(0.75, 1.0, k)], ["guard", smooth(0.85, 1.0, k) * 0.6]]
		foe.gather = 0.0
		foe.aura = 0.0
		if k >= 1.0 and not foe.has("landed"):
			foe.landed = true
			shake = maxf(shake, 14.0)
			sfx("lib-impact-bass-2", 0.5)
			for i in 18:
				emit("smoke", Vector2(LAND_X + rng.randf_range(-60, 200), GROUND), Vector2(rng.randf_range(-160, 220), -rng.randf_range(20, 130)), 2.0, rng.randf_range(40, 90), Color(0.62, 0.6, 0.45, 0.45))


func _rake(p: Vector2, ang: float, ln: float, big: bool) -> void:
	for i in 5:
		var off := Vector2((i - 2) * (26.0 if not big else 10.0), (i - 2) * (12.0 if not big else 0.0))
		grooves.append({"p": p + off, "ang": ang, "len": ln * (0.85 + 0.15 * sin(i * 1.7)), "t0": t, "big": big, "i": i})


func _cam() -> Array:
	var c := CENTER
	var z := 1.0
	var k1 := smooth(0.9, 1.7, t) * (1.0 - smooth(2.2, 2.7, t))
	c = c.lerp(hero.pos + Vector2(140, -230), k1)
	z = lerpf(z, 1.38, k1)
	var k2 := smooth(5.3, 5.9, t) * (1.0 - smooth(PEAK + 0.8, 9.0, t))
	c = c.lerp(Vector2(1120, 560), k2)
	z = lerpf(z, 1.2, k2)
	var k3 := smooth(8.4, 10.4, t)
	c = c.lerp(Vector2(980, 580), k3)
	return [c, z]


# ---------------------------------------------------------------- vẽ

func _draw_sky(c: Node2D) -> void:
	super._draw_sky(c)
	# trăng khuyết bạc: đa giác thật giữa hai cung
	var m := Vector2(1480, 210)
	var outer := PackedVector2Array()
	var inner := PackedVector2Array()
	for i in 25:
		var a := lerpf(-PI * 0.5, PI * 0.5, i / 24.0)
		outer.append(m + Vector2(cos(a), sin(a)) * 78.0)
	for i in range(1, 24):
		var a := lerpf(PI * 0.5, -PI * 0.5, i / 24.0)
		inner.append(m + Vector2(cos(a) * 30.0, sin(a) * 76.0))
	outer.append_array(inner)
	c.draw_texture_rect(soft, Rect2(m - Vector2(240, 240), Vector2(480, 480)), false, Color(0.85, 1.0, 0.9, 0.18))
	c.draw_colored_polygon(outer, Color(1.1, 1.15, 1.05))


func _fx_ground(c: Node2D) -> void:
	# cỏ khô thảo nguyên lay theo gió
	var rr := RandomNumberGenerator.new()
	rr.seed = 77
	for i in 90:
		var x := rr.randf_range(-300, W + 300)
		var y := GROUND + rr.randf_range(4, 200)
		var h := rr.randf_range(14, 34) * (0.6 + (y - GROUND) / 260.0)
		var sw := sin(rt * 2.0 + x * 0.01) * 6.0
		c.draw_line(Vector2(x, y), Vector2(x + sw, y - h), Color("#8f8a5c"), 2.0)
		c.draw_line(Vector2(x + 5, y), Vector2(x + 9 + sw, y - h * 0.8), Color("#5f5b3c"), 2.0)
	# rãnh cào: khoét đất (sẫm) + mép đất bật
	for g in grooves:
		var k := clampf((t - g.t0) / 0.12, 0.0, 1.0)
		var d := Vector2(cos(g.ang), sin(g.ang) * 0.35)
		var a: Vector2 = g.p
		var b: Vector2 = a + d * g.len * k
		var w: float = 9.0 if g.big else 6.0
		c.draw_colored_polygon(PackedVector2Array([a, a.lerp(b, 0.3) + Vector2(0, -w), b, a.lerp(b, 0.6) + Vector2(0, w * 0.6)]), Color("#1e1c12"))
		c.draw_line(a.lerp(b, 0.25) + Vector2(0, -w - 2), b + Vector2(0, -3), Color("#b8b07a"), 2.0)


func _fx_norm(c: Node2D) -> void:
	# bóng vuốt đen bay từ tay tới chỗ phát ra tiếng
	for cl in claws:
		var k := clampf((t - cl.t0) / cl.dur, 0.0, 1.0)
		var fade := 1.0 - smooth(0.15, 0.6, t - cl.t0 - cl.dur)
		if fade <= 0.0:
			continue
		var a: Vector2 = cl.a
		var b: Vector2 = cl.b
		var p := a.lerp(b, ease_out(k))
		var dir := (b - a).normalized()
		# vệt bóng kéo dài phía sau
		for j in 4:
			var q := a.lerp(b, ease_out(maxf(0.0, k - 0.08 * (j + 1))))
			_claw(c, q, dir, cl.s * (1.0 - j * 0.12), Color(SHADE.r, SHADE.g, SHADE.b, SHADE.a * 0.18 * fade), 1.0 - k)
		_claw(c, p, dir, cl.s * 1.12, Color(0.86, 0.95, 0.84, 0.95 * fade), 1.0 - k)   # viền xương trắng
		_claw(c, p, dir, cl.s, Color(SHADE.r, SHADE.g, SHADE.b, SHADE.a * fade), 1.0 - k)


# một bàn vuốt: lòng bàn tay + 5 móng cong (mở dần khi grip -> 0)
func _claw(c: Node2D, p: Vector2, dir: Vector2, s: float, col: Color, open: float) -> void:
	var n := dir.orthogonal()
	var palm := PackedVector2Array()
	for i in 12:
		var a := TAU * i / 12.0
		palm.append(p + (dir * cos(a) * 30.0 + n * sin(a) * 26.0) * s)
	c.draw_colored_polygon(palm, col)
	for i in 5:
		var sp := (i - 2) * (0.32 + 0.18 * open)
		var base := p + (dir * 18.0 + n * (i - 2) * 14.0) * s
		var pts := PackedVector2Array()
		var pts2 := PackedVector2Array()
		for j in 7:
			var u := j / 6.0
			var dd := dir.rotated(sp * (1.0 - u * 0.4) + u * 0.9 * (0.4 if i != 0 else -0.4))
			var tip := base + dd * (70.0 * u) * s * (0.8 if i == 0 else 1.0)
			var wv := (9.0 * (1.0 - u) + 1.0) * s
			pts.append(tip + dd.orthogonal() * wv)
			pts2.append(tip - dd.orthogonal() * wv)
		pts2.reverse()
		pts.append_array(pts2)
		c.draw_colored_polygon(pts, col)


func _fx_add(c: Node2D) -> void:
	# lõi rãnh cào phát sáng xanh xương rồi tắt dần
	for g in grooves:
		var k := clampf((t - g.t0) / 0.12, 0.0, 1.0)
		var life := 1.0 - smooth(1.2, 3.2, t - g.t0)
		if life <= 0.0:
			continue
		var d := Vector2(cos(g.ang), sin(g.ang) * 0.35)
		var a: Vector2 = g.p
		var b: Vector2 = a + d * g.len * k
		c.draw_line(a, b, COL * Color(1, 1, 1, 0.5 * life), 7.0 if g.big else 5.0)
		c.draw_line(a, b, HOT * Color(1, 1, 1, life), 2.5)
	# vệt cào chéo khổng lồ lúc đỉnh (5 cung, mảnh, sáng)
	var pk := t - PEAK + 0.1
	if pk > 0.0 and pk < 0.9:
		var e := ease_out(pk / 0.18)
		var fade := 1.0 - smooth(0.35, 0.9, pk)
		for i in 5:
			var a := Vector2(foe.pos.x - 520 + i * 70, 120)
			var b := Vector2(foe.pos.x + 60 + i * 70, GROUND - 40)
			var pts := PackedVector2Array()
			for j in 21:
				var u := j / 20.0 * e
				pts.append(a.lerp(b, u) + Vector2(-sin(u * PI) * 70.0, 0))
			if pts.size() >= 2:
				c.draw_polyline(pts, COL * Color(1, 1, 1, 0.22 * fade), 16.0)
				c.draw_polyline(pts, HOT * Color(1, 1, 1, fade), 3.0)
	# viền sáng quanh bóng vuốt
	for cl in claws:
		var k := clampf((t - cl.t0) / cl.dur, 0.0, 1.0)
		var fade := 1.0 - smooth(0.0, 0.3, t - cl.t0 - cl.dur)
		if fade > 0.0:
			var p: Vector2 = Vector2(cl.a).lerp(cl.b, ease_out(k))
			blob(c, p, 90.0 * cl.s, COL * Color(1, 1, 1, 0.16 * fade))
	# khí vuốt quanh tay khi tụ
	var g2 := smooth(1.2, 2.0, t) * (1.0 - smooth(2.3, 2.6, t))
	if g2 > 0.0:
		blob(c, hero.handF, 70.0 * g2, COL * Color(1, 1, 1, 0.35))
		blob(c, hero.handF, 26.0 * g2, HOT * Color(1, 1, 1, 0.8))
