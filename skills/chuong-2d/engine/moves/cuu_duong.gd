extends "res://engine.gd"
# Cửu Dương Thần Công (tap-04 Cửu Dương vs Cửu Âm, 2026-10-22)
# Thẻ chiêu: Trương Vô Kỵ · Hạc Bút Ông (Huyền Minh nhị lão, người phủ sương giá của chính Huyền Minh Thần Chưởng) ·
# CHÍN MẶT TRỜI NHỎ sáng lần lượt dọc kinh mạch Vô Kỵ (đan điền -> ngực -> cánh tay); mỗi điểm sáng rút một sợi hàn khí
# lam ra khỏi thân đối thủ, sợi chạm lòng bàn tay thì hoá hơi trắng bốc lên · vàng nghệ nóng vs lam băng ·
# sân đá Thiếu Lâm ban ngày, tường đỏ son mái ngói, nắng gắt · đỉnh: chín điểm nối thành vòng, cuộn hàn khí lớn bị kéo bật ra,
# sương trên người và quanh chân đối thủ bốc thành cột hơi; đối thủ bị đẩy lùi, đáp quỳ một gối, hết run.

const COL := Color(1.6, 1.05, 0.3)        # vàng nghệ
const HOT := Color(2.3, 1.8, 0.9)
const ICE := Color(0.55, 0.9, 1.7)        # hàn khí Huyền Minh
const ICE_HOT := Color(1.3, 1.8, 2.2)
const BEATS := [2.5, 3.5, 4.5]            # mỗi nhịp sáng thêm 3 mặt trời, rút 3 sợi
const PEAK := 6.1
const LAND_X := 1490.0

var beat_i := 0
var hit := false
var x_hit := 0.0
var lit := 0.0                 # số mặt trời đã sáng (0..9, liên tục)
var threads: Array = []        # {t0, dur, ph, big}
var frost := 1.0               # lượng sương trên người đối thủ
var frost_pts: Array = []      # tinh thể sương quanh chân đối thủ


func _setup() -> void:
	sky_cols = [Color("#5d9bd1"), Color("#a9d0e8"), Color("#e9dcb6")]
	far_col = Color("#7f9a86")
	near_col = Color("#9c3b2a")
	mist_col = Color(1.0, 0.97, 0.9, 0.16)
	ground_cols = [Color("#cbbf9f"), Color("#8b7f63"), Color("#e6dcc0")]
	moon = Vector2(380, 170)
	moon_col = Color(2.0, 1.75, 1.1)
	moon_glow = Color(1.0, 0.9, 0.6, 0.3)
	moon_craters = false
	n_stars = 0
	slowmo = [PEAK - 0.05, PEAK + 0.62, 0.3]
	title = "Cửu Dương Thần Công"
	subtitle = "Trương Vô Kỵ · rút hàn khí Huyền Minh"
	title_at = 8.4
	title_col = HOT
	flash_col = Color(1.0, 0.95, 0.8)
	set_char(hero, "truong-vo-ky")
	set_char(foe, "hac-but-ong")
	hero.pos = Vector2(560, GROUND)
	foe.pos = Vector2(1300, GROUND)
	hero.col = COL
	foe.col = ICE
	for i in 26:
		frost_pts.append([Vector2(rng.randf_range(-170, 170), rng.randf_range(-6, 40)), rng.randf_range(8, 20), rng.randf() * TAU])
	cue(1.0, "lib-riser", 0.8)
	for b in BEATS:
		cue(b - 0.1, "lib-chime", 0.4)
	cue(PEAK - 0.3, "lib-whoosh-cinematic", 0.9)


func _story(dt: float) -> void:
	# ---- Vô Kỵ: tụ khí đan điền, mỗi nhịp đẩy chưởng rồi kéo về (rút)
	var gk := smooth(1.0, 1.8, t)
	hero.gather = gk * (1.0 - smooth(2.2, 2.45, t)) * 0.8
	var bp := 0.0
	var pull := 0.0
	for b in BEATS:
		bp = maxf(bp, pulse(b - 0.12, b + 0.08, 0.25, t))
		pull = maxf(pull, pulse(b + 0.15, b + 0.45, 0.3, t))
	var big := smooth(5.1, 5.8, t) * (1.0 - smooth(PEAK - 0.1, PEAK, t))
	hero.push = maxf(bp, smooth(2.2, 2.5, t) * 0.35) * (1.0 - big) + smooth(PEAK - 0.12, PEAK, t) * (1.0 - smooth(8.2, 9.4, t))
	hero.both = smooth(5.0, 5.6, t)
	hero.extra = [["charge", big * 0.9], [{"torso": 10.0, "head": 4.0, "all": [0.0, 0.0, 18.0]}, pull]]
	hero.lean = hero.push * 0.25 - pull * 0.2
	hero.aura = gk * 0.45 + big * 0.7 - smooth(7.2, 9.2, t) * 0.9
	hero.expr = "vui" if t > 8.0 else ("quyet-tam" if t > 1.0 else "binh")
	lit = clampf(smooth(1.3, 1.9, t) + 3.0 * smooth(BEATS[0] - 0.1, BEATS[0] + 0.3, t) + 3.0 * smooth(BEATS[1] - 0.1, BEATS[1] + 0.3, t)
		+ 2.0 * smooth(BEATS[2] - 0.1, BEATS[2] + 0.3, t), 0.0, 9.0)

	# ---- Hạc Bút Ông: run vì lạnh, người phủ sương lam; mỗi sợi bị rút thì giật về trước một chút
	if not hit:
		var tug := 0.0
		for b in BEATS:
			tug = maxf(tug, pulse(b + 0.1, b + 0.3, 0.35, t))
		foe.pos = Vector2(1300.0 - 22.0 * (smooth(2.6, 2.9, t) + smooth(3.6, 3.9, t) + smooth(4.6, 4.9, t)) + sin(rt * 47.0) * 2.0 * frost, GROUND)
		foe.extra = [[{"torso": -14.0, "head": -10.0, "uaF": -70.0, "faF": -20.0, "uaB": -40.0, "faB": -20.0}, tug], ["guard", smooth(4.7, 5.3, t)]]
		foe.gather = smooth(0.4, 1.0, t) * 0.4 * frost
		foe.aura = (0.35 + foe.gather) * frost
		foe.expr = "soc" if t > 2.6 else "gian"
	frost = 1.0 - 0.18 * (smooth(2.6, 3.0, t) + smooth(3.6, 4.0, t) + smooth(4.6, 5.0, t)) - 0.46 * smooth(PEAK, PEAK + 0.5, t)
	foe.tint = Color(0.8, 0.9, 1.18).lerp(Color(1, 1, 1), 1.0 - frost)
	pose(hero, 0.0)
	pose(foe, 0.0)

	if hero.gather > 0.05:
		orbit(hero, rng.randf_range(110, 260), rng.randf_range(2.0, 3.4), 240, rng.randf_range(2, 4), COL, 2.3)

	# ---- [CƠ CHẾ] nhịp: 3 sợi hàn khí bị kéo ra, chạm tay thì hoá hơi
	if beat_i < BEATS.size() and t >= BEATS[beat_i]:
		for j in 3:
			threads.append({"t0": t + j * 0.08, "dur": 0.55, "ph": rng.randf() * TAU, "big": false})
		var at: Vector2 = foe.pos + Vector2(-10, -170)
		add_ring(at, 200, ICE_HOT, 6, 0.35)
		add_ring(hero.hand, 160, HOT, 6, 0.35, 1.0, 0.45)
		burst(at, 24, 250, 700, ICE_HOT, Color(1.6, 1.8, 2.0), 300.0, 1.6)
		shake = maxf(shake, 11.0)
		sfx("lib-impact-bass-2", 0.55)
		beat_i += 1
	# hơi trắng bốc lên ở tay (sợi đã tới)
	for th in threads:
		var k: float = (t - th.t0) / th.dur
		if k > 0.85 and k < 1.6 and rng.randf() < 0.6:
			emit("smoke", hero.hand + Vector2(rng.randf_range(-20, 20), -10), Vector2(rng.randf_range(-40, 40), -rng.randf_range(120, 220)), 1.4, rng.randf_range(16, 30), Color(1, 1, 1, 0.5), -40.0, 0.6)

	# ---- đỉnh
	if t >= PEAK - 0.2 and threads.size() == 9:
		threads.append({"t0": t, "dur": 0.4, "ph": 0.0, "big": true})
	if t >= PEAK and not hit:
		hit = true
		x_hit = foe.pos.x
		flash = 0.55
		shake = 28.0
		var at: Vector2 = foe.pos + Vector2(0, -180)
		add_ring(at, 700, ICE_HOT, 18, 0.7)
		add_ring(hero.hand, 600, HOT, 16, 0.7, 1.0, 0.1)
		add_ring(Vector2(at.x, GROUND), 800, COL, 10, 0.9, 0.2)
		burst(at, 140, 300, 1500, ICE_HOT, HOT, 600.0, 1.0)
		sfx("lib-impact-bass-1", 1.0)
		sfx("lib-impact-bass-2", 1.0)
		sfx("lib-sparkle", 0.5)
	# cột hơi trắng: sương trên người và quanh chân đối thủ bốc lên
	if t > PEAK and t < PEAK + 1.6:
		for i in 3:
			emit("smoke", Vector2(x_hit + rng.randf_range(-160, 160), GROUND - rng.randf_range(0, 200)), Vector2(rng.randf_range(-30, 30), -rng.randf_range(220, 420)), 1.6, rng.randf_range(30, 60), Color(0.95, 0.98, 1.0, 0.42), -60.0, 0.5)
	# ---- hậu quả: bị hơi đẩy lùi theo cung thấp, đáp quỳ một gối, hết run
	if hit:
		var k := clampf((t - PEAK) / 0.85, 0.0, 1.0)
		foe.pos = Vector2(lerpf(x_hit, LAND_X, ease_out(k)), GROUND - sin(k * PI) * 95.0)
		foe.rot = sin(k * PI) * 0.45
		foe.hurt = sin(k * PI) * 0.7
		foe.extra = [["kneel", smooth(0.7, 1.0, k)]]
		foe.gather = 0.0
		foe.aura = 0.0
		foe.expr = "soc" if k < 1.0 else ("binh" if t > PEAK + 1.4 else "soc")
		if k >= 1.0 and not foe.has("landed"):
			foe.landed = true
			shake = maxf(shake, 13.0)
			sfx("lib-impact-bass-2", 0.5)
			for i in 16:
				emit("smoke", Vector2(LAND_X + rng.randf_range(-60, 200), GROUND), Vector2(rng.randf_range(-160, 220), -rng.randf_range(20, 120)), 2.0, rng.randf_range(40, 80), Color(0.8, 0.75, 0.62, 0.45))


# chín huyệt dọc kinh mạch: 6 điểm đan điền -> cổ, 3 điểm vai -> lòng bàn tay
func sun_pts() -> Array:
	var o: Array = []
	var p: Vector2 = hero.pos
	var hd: Vector2 = hero.head
	var neck := p.lerp(hd, 0.62)
	for i in 6:
		o.append(p.lerp(neck, 0.42 + i * 0.115) + Vector2(4, 0))
	var sh := neck + Vector2(hero.face * 26.0, 12.0)
	var hn: Vector2 = hero.handF
	for i in 3:
		o.append(sh.lerp(hn, 0.2 + i * 0.4))
	return o


func _cam() -> Array:
	var c := CENTER
	var z := 1.0
	var k1 := smooth(0.9, 1.7, t) * (1.0 - smooth(2.2, 2.7, t))
	c = c.lerp(hero.pos + Vector2(120, -210), k1)
	z = lerpf(z, 1.36, k1)
	var k2 := smooth(5.2, 5.9, t) * (1.0 - smooth(PEAK + 0.8, 9.0, t))
	c = c.lerp(Vector2(980, 560), k2)
	z = lerpf(z, 1.16, k2)
	var k3 := smooth(8.4, 10.4, t)
	c = c.lerp(Vector2(1010, 585), k3)
	return [c, z]


# ---------------------------------------------------------------- vẽ

func _draw_near(c: Node2D) -> void:
	# tường đỏ son Thiếu Lâm + mái ngói, nắng gắt
	c.draw_rect(Rect2(-600, 560, W + 1200, 300), near_col)
	c.draw_rect(Rect2(-600, 560, W + 1200, 26), Color("#7e2c20"))
	c.draw_colored_polygon(PackedVector2Array([Vector2(-600, 560), Vector2(W + 600, 560), Vector2(W + 560, 520), Vector2(-560, 520)]), Color("#3c3a3d"))
	for i in 70:
		var x := -600.0 + i * 46.0
		c.draw_line(Vector2(x, 522), Vector2(x - 4, 560), Color("#545155"), 3.0)
	for i in 8:
		var x := -200.0 + i * 330.0
		c.draw_rect(Rect2(x, 610, 70, 120), Color("#7e2c20"))
		c.draw_rect(Rect2(x + 8, 618, 54, 104), Color("#c9a24a", 0.35))
	c.draw_rect(Rect2(-600, 836, W + 1200, 30), Color("#6f6553"))


func _fx_ground(c: Node2D) -> void:
	# lát đá sân chùa
	for i in 16:
		var y := GROUND + 18.0 + i * i * 2.4
		c.draw_line(Vector2(-600, y), Vector2(W + 600, y), Color("#9f9378", 0.6), 2.0)
	for i in 30:
		var x := -300.0 + i * 90.0
		c.draw_line(Vector2(x, GROUND + 4), Vector2(960 + (x - 960) * 1.9, H + 200), Color("#9f9378", 0.45), 2.0)
	# sương giá quanh chân đối thủ: tan dần theo frost
	var base := Vector2(foe.pos.x if not hit else x_hit, GROUND)
	flat_blob(c, base + Vector2(0, 10), 260, 0.14, Color(0.85, 0.95, 1.0, 0.5 * frost))
	for f in frost_pts:
		var p: Vector2 = base + f[0]
		var s: float = f[1] * frost
		if s < 1.0:
			continue
		for a in 3:
			var d := Vector2.from_angle(f[2] + a * PI / 3.0) * s
			c.draw_line(p - d, p + d, Color(0.92, 0.97, 1.0, 0.9), 2.0)


func _fx_norm(c: Node2D) -> void:
	# tinh thể sương bám trên người Hạc Bút Ông
	if frost > 0.05:
		var rr := RandomNumberGenerator.new()
		rr.seed = 9
		var cen: Vector2 = foe.pos + Vector2(0, -150)
		for i in 22:
			var p := cen + Vector2(rr.randf_range(-70, 70), rr.randf_range(-130, 120))
			var s := rr.randf_range(5, 11) * frost
			var a0 := rr.randf() * TAU
			for a in 3:
				var d := Vector2.from_angle(a0 + a * PI / 3.0) * s
				c.draw_line(p - d, p + d, Color(0.9, 0.97, 1.0, 0.85 * frost), 2.0)


func _fx_add(c: Node2D) -> void:
	# chín mặt trời dọc kinh mạch
	var sp := sun_pts()
	for i in 9:
		var on := clampf(lit - i, 0.0, 1.0)
		if on <= 0.0:
			continue
		var p: Vector2 = sp[i]
		var pul := 0.85 + 0.15 * sin(rt * 9.0 + i)
		blob(c, p, 34.0 * on * pul, COL * Color(1, 1, 1, 0.35))
		c.draw_circle(p, 7.0 * on, HOT)
		for r in 8:
			var d := Vector2.from_angle(r * TAU / 8.0 + rt * 1.5)
			c.draw_line(p + d * 10.0, p + d * (16.0 + 6.0 * on), HOT * Color(1, 1, 1, 0.7 * on), 2.0)
		if i > 0 and lit > i:
			c.draw_line(sp[i - 1], p, COL * Color(1, 1, 1, 0.35), 3.0)
	# vòng nối chín điểm lúc đỉnh
	var rk := smooth(PEAK - 0.4, PEAK, t) * (1.0 - smooth(PEAK + 0.5, 8.0, t))
	if rk > 0.0:
		var cen: Vector2 = (sp[0] + sp[5]) * 0.5
		c.draw_arc(cen, 150.0 * rk, 0, TAU, 64, HOT * Color(1, 1, 1, 0.8 * rk), 4.0)
		c.draw_arc(cen, 170.0 * rk, 0, TAU, 64, COL * Color(1, 1, 1, 0.25 * rk), 10.0)
	# sợi hàn khí: từ thân đối thủ cong về lòng bàn tay, đầu sợi lam -> đuôi tan
	for th in threads:
		var k: float = (t - th.t0) / th.dur
		if k <= 0.0 or k > 1.4:
			continue
		var a: Vector2 = (foe.pos if not hit else Vector2(x_hit, GROUND)) + Vector2(-20, -160 + sin(th.ph) * 50.0)
		var b: Vector2 = hero.hand
		var head := clampf(k, 0.0, 1.0)
		var tail := clampf(k - 0.45, 0.0, 1.0)
		var pts := PackedVector2Array()
		for j in 21:
			var u := lerpf(tail, head, j / 20.0)
			var nrm := (b - a).orthogonal().normalized()
			pts.append(a.lerp(b, u) + nrm * sin(u * PI) * (60.0 + 40.0 * sin(th.ph)) + nrm * sin(u * 14.0 - rt * 20.0) * 6.0)
		if head - tail > 0.01:
			var w: float = 22.0 if th.big else 9.0
			c.draw_polyline(pts, ICE * Color(1, 1, 1, 0.25), w * 1.6)
			c.draw_polyline(pts, ICE_HOT * Color(1, 1, 1, 0.9), 3.0 if not th.big else 5.0)
	# quầng nắng ở tay khi rút
	var g := smooth(1.2, 2.0, t) * 0.6 + smooth(5.1, 5.8, t) * (1.0 - smooth(PEAK + 0.3, 8.0, t))
	if g > 0.0:
		blob(c, hero.hand, 80.0 * g, COL * Color(1, 1, 1, 0.3))
		blob(c, hero.hand, 28.0 * g, HOT * Color(1, 1, 1, 0.8))
