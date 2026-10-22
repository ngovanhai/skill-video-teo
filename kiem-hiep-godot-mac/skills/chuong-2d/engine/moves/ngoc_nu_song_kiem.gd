extends "res://engine.gd"
# NGỌC NỮ TỐ TÂM KIẾM PHÁP (12.5 s): rừng trúc sau núi Chung Nam lúc sương sớm, nền đá trắng.
# Thẻ chiêu:
#   người dùng   Dương Quá (kiếm Toàn Chân) + Tiểu Long Nữ (kiếm Ngọc Nữ), song kiếm hợp bích
#   đối thủ      Kim Luân Pháp Vương (Kim Luân Quốc Sư), bánh xe vàng ném xoay
#   cơ chế       mỗi nhịp một bánh xe vàng bay tới; hai kiếm chém hai cung NGƯỢC CHIỀU nhau (một xuống, một lên)
#                cắt thành chữ X đúng chỗ bánh xe -> bánh xe bật đi, chỗ X để lại một ô lục giác (lam/hồng)
#                ô lục giác ghép dần thành tấm lưới tổ ong che trước hai người. Đỉnh: năm bánh xe cùng lao tới,
#                hai vệt kiếm XOẮN KÉP vào nhau thành một mũi, lưới tổ ong bừng sáng, năm bánh xe vỡ vụn thành bụi vàng.
#   cặp màu      lam Toàn Chân + hồng ngọc Ngọc Nữ (hợp lại trắng ngọc) vs vàng kim của bánh xe
#   bối cảnh     rừng trúc xanh thẫm, sương sớm trắng lục, nền đá trắng (khác hổ phách / hoàng hôn đỏ / tuyết đêm)
#   đỉnh         slowmo, xoắn kép chạm năm bánh xe giữa không trung -> vỡ, Kim Luân trượt lùi quỳ một gối (không máu)

const COL_D := Color(0.45, 0.9, 1.6)      # kiếm Toàn Chân (Dương Quá)
const HOT_D := Color(1.1, 1.8, 2.3)
const COL_N := Color(1.6, 1.05, 1.3)      # kiếm Ngọc Nữ (Tiểu Long Nữ)
const HOT_N := Color(2.3, 1.75, 2.0)
const HOT := Color(2.0, 1.95, 2.2)        # hợp bích
const FOE_COL := Color(1.8, 1.3, 0.3)     # vàng kim
const FOE_HOT := Color(2.4, 1.9, 0.8)
const GOLD := Color("#d9a833")
const GOLD_D := Color("#8a5a14")
const STEEL := Color(0.9, 0.92, 0.9)
const BEATS := [2.6, 3.6, 4.6]
const FLY := 0.55                         # bánh xe bay mất 0.55 s
const XP := Vector2(990, 610)             # chỗ hai cung cắt nhau
const PEAK := 6.1
const KNEEL_X := 1490.0
const SL := 170.0                         # dài kiếm

const LUNGE := {"uaF": -84, "faF": -4, "uaB": 50, "faB": -40, "torso": 8, "head": -4, "thF": -58, "shF": 52, "thB": 46, "shB": -12, "all": [0, 0, 34]}
const KNEEL := {"uaF": -20, "faF": -50, "uaB": 30, "faB": -40, "torso": 14, "head": 6, "thF": -80, "shF": 84, "thB": 20, "shB": 70, "all": [0, 0, 62]}
const THROW_UP := {"uaF": -160, "faF": -20, "uaB": 40, "faB": -50, "torso": -8, "head": -6}
const RAISE2 := {"uaF": -150, "faF": -30, "uaB": -150, "faB": -30, "torso": -6, "head": -10}

var tln := {}
var hit := false
var beat_i := 0
var x_hit := 0.0
var cells: Array = []        # [tâm, t sinh, màu 0/1]
var stalks: Array = []
var slabs: Array = []
var leaves: Array = []
var trail_d: Array = []
var trail_n: Array = []
var ad := 0.0                # góc kiếm DQ
var an := 0.0                # góc kiếm TLN
var thrust := 0.0


func _setup() -> void:
	sky_cols = [Color("#0d2119"), Color("#2b4c3c"), Color("#a3bcab")]
	moon_on = false
	n_stars = 0
	far_col = Color("#2a4636")
	near_col = Color("#183126")
	mist_col = Color(0.85, 0.97, 0.9, 0.22)
	ground_cols = [Color("#cfd4c8"), Color("#6d786e"), Color("#eef1e8")]
	slowmo = [6.0, 6.65, 0.3]
	title = "NGỌC NỮ TỐ TÂM KIẾM PHÁP"
	subtitle = "Thần Điêu Hiệp Lữ · Dương Quá & Tiểu Long Nữ"
	title_at = 8.4
	title_col = HOT_N
	set_char(hero, "duong-qua-nho")
	set_char(foe, "kim-luan-phap-vuong")
	hero.pos = Vector2(360, GROUND)
	foe.pos = Vector2(1370, GROUND)
	hero.col = COL_D
	foe.col = FOE_COL
	hero.base = "stance"
	hero.node.hand_form = {"F": "nam", "B": "chi"}
	foe.node.hand_form = {"F": "nam", "B": "nam"}
	tln = fighter("tieu-long-nu", Vector2(590, GROUND), 1.0, COL_N)
	tln.node.hand_form = {"F": "nam", "B": "chi"}
	tln.base = "stance"
	cue(1.0, "lib-riser", 0.75)
	for b in BEATS:
		cue(b - FLY, "lib-whoosh-short", 0.55)
		cue(b - 0.08, "lib-whoosh-short", 0.5)
	cue(5.0, "lib-glitch-1", 0.4)
	cue(5.3, "lib-glitch-1", 0.35)
	cue(5.75, "lib-whoosh-cinematic", 0.9)
	cue(6.5, "lib-sparkle", 0.45)
	for i in 22:
		var far_k := rng.randf()
		stalks.append([rng.randf_range(-300, 2250), rng.randf_range(16, 30) * (0.6 + far_k * 0.5), far_k, rng.randf() * TAU, rng.randf_range(-0.05, 0.05)])
	stalks.sort_custom(func(a, b): return a[2] < b[2])
	for i in 18:
		slabs.append([Vector2(rng.randf_range(-500, 2400), rng.randf_range(GROUND + 20, H + 200)), rng.randf_range(120, 320)])
	for i in 60:
		leaves.append([Vector2(rng.randf_range(-200, 2200), rng.randf_range(-100, GROUND)), rng.randf() * TAU, rng.randf_range(0.6, 1.3)])


func _dir(f: Dictionary, a: float) -> Vector2:
	return Vector2(cos(a) * f.face, sin(a))


func _wheel_pos(i: int) -> Vector2:
	# bánh xe nhịp i: bay từ tay Kim Luân tới XP, rồi bật đi theo cung
	var b: float = BEATS[i]
	var src := Vector2(foe.pos.x - 70, GROUND - 230)
	if t < b:
		var k := clampf((t - (b - FLY)) / FLY, 0.0, 1.0)
		var p := src.lerp(XP + Vector2(0, -20 if i != 1 else 30), k)
		p.y -= sin(k * PI) * 70.0
		return p
	var u := t - b
	var vs := [Vector2(-520, -1100), Vector2(380, -1250), Vector2(-260, -1350)]
	var v: Vector2 = vs[i]
	return XP + v * u + Vector2(0, 1500.0 * u * u)


func _wheel2_pos() -> Vector2:
	# nhịp 3 thêm một bánh xe bay thấp
	var b: float = BEATS[2]
	var src := Vector2(foe.pos.x - 40, GROUND - 120)
	if t < b:
		var k := clampf((t - (b - FLY)) / FLY, 0.0, 1.0)
		return src.lerp(XP + Vector2(10, 60), k)
	var u := t - b
	return XP + Vector2(10, 60) + Vector2(560, -500) * u + Vector2(0, 1600.0 * u * u)


func _five(i: int) -> Vector2:
	# năm bánh xe: xoay quanh đầu Kim Luân rồi cùng lao tới
	var head: Vector2 = foe.pos + Vector2(-20, -330)
	var a := rt * 4.0 + i * TAU / 5.0
	var ring := head + Vector2(cos(a) * 150.0, sin(a) * 46.0)
	var k := smooth(5.72, PEAK, t)
	var meet := Vector2(1130 + (i - 2) * 22.0, 560 + (i - 2) * 30.0)
	return ring.lerp(meet, k * k)


func _story(dt: float) -> void:
	# ---------- Kim Luân
	if not hit:
		var up := 0.0
		var rel := 0.0
		for b in BEATS:
			up = maxf(up, pulse(b - FLY - 0.4, b - FLY - 0.05, 0.1, t))
			rel = maxf(rel, pulse(b - FLY - 0.05, b - FLY + 0.05, 0.3, t))
		var lift := smooth(4.95, 5.4, t)
		var launch := smooth(5.68, 5.8, t)
		foe.extra = [["windup", up * (1.0 - lift)], ["palm", rel * (1.0 - lift)], [RAISE2, lift * (1.0 - launch)], ["palm", launch]]
		foe.aura = smooth(1.5, 2.0, t) * 0.25 + lift * 0.6
		foe.lean = launch * 0.3
		foe.expr = "soc" if t > 4.0 else "gian"
		# lùi nửa bước mỗi nhịp bị gạt
		var back := 0.0
		for b in BEATS:
			back += smooth(b, b + 0.25, t) * 14.0
		foe.pos.x = 1370.0 + back
		foe.extra.append(["guard", pulse(BEATS[0], BEATS[2] + 0.3, 0.2, t) * 0.0])

	# ---------- Dương Quá (kiếm chém xuống) và Tiểu Long Nữ (kiếm hất lên): cung ngược chiều
	var g := smooth(1.0, 1.7, t) * (1.0 - smooth(2.15, 2.4, t))
	var rdy := smooth(2.1, 2.4, t)
	var sd := 0.0
	var sn := 0.0
	for b in BEATS:
		sd = maxf(sd, smooth(b - 0.1, b + 0.04, t) * (1.0 - smooth(b + 0.2, b + 0.5, t)))
	sn = sd
	var gp := smooth(5.0, 5.6, t) * (1.0 - smooth(5.8, 5.9, t))     # tụ khí lần hai
	thrust = smooth(5.82, 6.02, t) * (1.0 - smooth(7.4, 8.2, t))
	var rest_k := smooth(7.6, 8.4, t)
	hero.gather = g * 0.8 + gp * 0.6
	tln.gather = g * 0.6 + gp * 0.6
	var up_d := pulse(BEATS[0] - 0.35, BEATS[0] - 0.1, 0.1, t) + pulse(BEATS[1] - 0.35, BEATS[1] - 0.1, 0.1, t) + pulse(BEATS[2] - 0.35, BEATS[2] - 0.1, 0.1, t)
	hero.extra = [["guard", rdy * 0.5 * (1.0 - thrust)], ["windup", minf(1.0, up_d) * 0.7], ["slash", sd * 0.8], [LUNGE, thrust], ["rest", rest_k * 0.6]]
	tln.extra = [["guard", rdy * 0.4 * (1.0 - thrust)], ["slash", minf(1.0, up_d) * 0.5], ["windup", sn * 0.6], [LUNGE, thrust * 0.9], ["rest", rest_k * 0.6]]
	hero.aura = g * 0.55 + gp * 0.7 - rest_k * 0.6
	hero.lean = thrust * 0.2
	tln.lean = thrust * 0.2
	hero.expr = "dac-y" if t > 7.9 else ("quyet-tam" if t > 1.0 else "binh")
	tln.expr = "vui" if t > 7.9 else ("quyet-tam" if t > 1.0 else "binh")
	# bước tới nhẹ khi đâm
	hero.pos.x = 360.0 + 40.0 * rdy + 70.0 * thrust
	tln.pos.x = 590.0 + 30.0 * rdy + 60.0 * thrust
	# góc kiếm: DQ từ trên (-1.5) chém xuống (0.9); TLN từ dưới (0.9) hất lên (-1.5)
	ad = lerpf(0.8, -1.3, g)
	ad = lerpf(ad, -0.5, rdy)
	an = lerpf(0.9, -1.0, g)
	an = lerpf(an, 0.3, rdy)
	for b in BEATS:
		if t > b - 0.4 and t < b + 0.55:
			var w := smooth(b - 0.35, b - 0.12, t) * (1.0 - smooth(b + 0.2, b + 0.5, t))
			var s := smooth(b - 0.1, b + 0.05, t)
			ad = lerpf(ad, lerpf(-1.6, 1.0, s), w)
			an = lerpf(an, lerpf(1.0, -1.6, s), w)
	ad = lerpf(ad, -0.05, thrust)
	an = lerpf(an, 0.05, thrust)
	ad = lerpf(ad, 1.0, rest_k)
	an = lerpf(an, 1.1, rest_k)

	pose(hero, 0.0)
	pose(foe, 0.0)
	pose(tln, dt)

	var tip_d: Vector2 = hero.hand + _dir(hero, ad) * SL
	var tip_n: Vector2 = tln.hand + _dir(tln, an) * SL
	trail_d.push_front(tip_d)
	trail_n.push_front(tip_n)
	while trail_d.size() > 7:
		trail_d.pop_back()
	while trail_n.size() > 7:
		trail_n.pop_back()

	if g > 0.05 or gp > 0.05:
		orbit(hero, rng.randf_range(110, 260), rng.randf_range(2.0, 3.2), 240, rng.randf_range(2, 4), HOT_D, 2.3 if t < 3.0 else 5.95)
		orbit(tln, rng.randf_range(110, 260), -rng.randf_range(2.0, 3.2), 240, rng.randf_range(2, 4), HOT_N, 2.3 if t < 3.0 else 5.95)
	# lá trúc rơi chậm
	for lf in leaves:
		lf[0] += Vector2(-40.0 + sin(rt + lf[1]) * 30.0, 60.0 * lf[2]) * dt
		lf[1] += dt * 1.5
		if lf[0].y > GROUND + 40:
			lf[0] = Vector2(rng.randf_range(-100, 2200), -60)

	# ---------- biểu diễn: chữ X gạt bánh xe, để lại ô lục giác
	if beat_i < BEATS.size() and t >= BEATS[beat_i]:
		var b: float = BEATS[beat_i]
		var hx := 74.0
		var news: Array = [[Vector2.ZERO]]
		if beat_i == 1:
			news = [[Vector2(0, -hx * 1.5)], [Vector2(0, hx * 1.5)]]
		elif beat_i == 2:
			news = [[Vector2(hx * 1.3, -hx * 0.75)], [Vector2(hx * 1.3, hx * 0.75)], [Vector2(-hx * 1.3, 0)]]
		for nw in news:
			cells.append([XP + nw[0] * Vector2(1.0, 1.0), t, cells.size() % 2])
		add_ring(XP, 210, HOT, 8, 0.35)
		burst(XP, 34, 300, 1000, FOE_HOT, HOT, 800.0, 1.3)
		shake = maxf(shake, 11.0 + beat_i * 1.5)
		sfx("lib-impact-bass-2", 0.6)
		sfx("lib-chime", 0.35)
		beat_i += 1

	# ---------- đỉnh: xoắn kép chạm năm bánh xe
	if t >= PEAK and not hit:
		hit = true
		x_hit = foe.pos.x
		foe.expr = "ko"
		flash = 0.6
		flash_col = Color(1.0, 0.94, 0.97)
		shake = 32.0
		var at := Vector2(1130, 560)
		add_ring(at, 640, HOT, 18, 0.7)
		add_ring(at, 380, FOE_HOT, 10, 0.5, 1.0, 0.06)
		add_ring(Vector2(at.x, GROUND), 780, COL_N, 9, 0.9, 0.2)
		burst(at, 140, 300, 1500, FOE_HOT, HOT, 900.0, 1.0)
		for i in 60:
			emit("ember", at + Vector2(rng.randf_range(-160, 160), rng.randf_range(-120, 120)), Vector2(rng.randf_range(-260, 260), rng.randf_range(-320, 60)), rng.randf_range(1.6, 3.0), rng.randf_range(2, 4), FOE_COL * Color(1, 1, 1, 0.55), 120.0, 0.8)
		sfx("lib-impact-bass-1", 1.0)
		sfx("lib-impact-bass-2", 1.0)
	# ---------- hậu quả: trượt lùi theo cung thấp, quỳ một gối
	if hit:
		var k := clampf((t - PEAK) / 0.95, 0.0, 1.0)
		foe.pos = Vector2(lerpf(x_hit, KNEEL_X, ease_out(k)), GROUND - sin(k * PI) * 110.0)
		foe.rot = sin(k * PI) * 0.5
		foe.hurt = (1.0 - smooth(0.5, 1.0, k))
		foe.extra = [[KNEEL, smooth(0.45, 1.0, k)]]
		foe.aura = 0.0
		foe.lean = 0.0
		if k >= 1.0 and not foe.has("landed"):
			foe.landed = true
			shake = maxf(shake, 14.0)
			sfx("lib-impact-bass-2", 0.5)
			for i in 22:
				emit("smoke", Vector2(KNEEL_X + rng.randf_range(-140, 160), GROUND), Vector2(rng.randf_range(-220, 220), -rng.randf_range(20, 140)), 2.0, rng.randf_range(36, 80), Color(0.9, 0.93, 0.88, 0.42))


func _cam() -> Array:
	var c := Vector2(960, 600)
	var z := 1.0
	var k1 := smooth(0.9, 1.6, t) * (1.0 - smooth(2.1, 2.5, t))
	c = c.lerp(Vector2(520, 520), k1)
	z = lerpf(z, 1.35, k1)
	var k2 := smooth(2.1, 2.6, t) * (1.0 - smooth(4.9, 5.3, t))
	var punch := 0.0
	for b in BEATS:
		punch = maxf(punch, pulse(b, b + 0.05, 0.25, t))
	c = c.lerp(Vector2(950, 600), k2)
	z = lerpf(z, 1.12 + punch * 0.05, k2)
	var k3 := smooth(4.9, 5.4, t) * (1.0 - smooth(5.7, 5.9, t))
	c = c.lerp(Vector2(1250, 520), k3)
	z = lerpf(z, 1.22, k3)
	var k4 := smooth(5.7, 6.0, t) * (1.0 - smooth(6.6, 7.6, t))
	c = c.lerp(Vector2(1000, 590), k4)
	z = lerpf(z, 1.15, k4)
	var k5 := smooth(7.6, 8.5, t)
	c = c.lerp(Vector2(990, 590), k5)
	return [c, z]


func _hex(c: Node2D, p: Vector2, r: float, col: Color, w: float) -> void:
	var pts := PackedVector2Array()
	for i in 7:
		var a := PI / 6.0 + i * TAU / 6.0
		pts.append(p + Vector2(cos(a), sin(a)) * r)
	c.draw_polyline(pts, col, w)


func _wheel(c: Node2D, p: Vector2, r: float, a: float) -> void:
	c.draw_circle(p, r + 3.0, GOLD_D)
	c.draw_arc(p, r - 4.0, 0, TAU, 32, GOLD, 8.0)
	for i in 8:
		var aa := a + i * TAU / 8.0
		var d := Vector2(cos(aa), sin(aa))
		c.draw_line(p + d * 6.0, p + d * (r - 6.0), GOLD, 3.0)
		c.draw_colored_polygon(PackedVector2Array([p + d * r, p + d.rotated(0.18) * (r + 10.0), p + d.rotated(0.36) * r]), GOLD)
	c.draw_circle(p, 8.0, GOLD_D)
	c.draw_circle(p, 4.0, Color("#f3d77a"))


func _fx_ground(c: Node2D) -> void:
	# rừng trúc: xa nhạt (sương), gần thẫm
	for s in stalks:
		var x: float = s[0]
		var w: float = s[1]
		var fk: float = s[2]
		var col := Color("#3d6450").lerp(Color("#132a1e"), fk)
		col = col.lerp(Color(0.66, 0.78, 0.7), (1.0 - fk) * 0.45)
		# giữa sân đấu thì nhạt và mảnh để nhân vật nổi
		if x > 380 and x < 1560:
			col = col.lerp(Color(0.6, 0.74, 0.66), 0.35)
			w *= 0.7
		var sway := sin(rt * 0.9 + s[3]) * 10.0
		var top := Vector2(x + sway + s[4] * 900.0, -200)
		var bot := Vector2(x, GROUND + 2)
		c.draw_line(bot, top, col, w)
		var seg := 120.0 + fk * 40.0
		var y := GROUND - seg
		while y > -150:
			var k := (GROUND - y) / (GROUND + 200.0)
			var px := bot.lerp(top, k)
			c.draw_line(px - Vector2(w * 0.6, 0), px + Vector2(w * 0.6, 0), col.darkened(0.3), 3.0)
			if int(y) % 3 == 0:
				var la: float = s[3] + y * 0.01
				var lp := px + Vector2(w * 0.5, 0)
				c.draw_colored_polygon(PackedVector2Array([lp, lp + Vector2(70, -10).rotated(sin(la) * 0.4 + sway * 0.01), lp + Vector2(40, 8).rotated(sin(la) * 0.4)]), col.darkened(0.1))
			y -= seg
	# sương sớm vắt ngang
	for i in 3:
		var my := 560.0 + i * 90.0
		var mx := fmod(rt * (20.0 + i * 8.0) + i * 600.0, 2400.0) - 300.0
		flat_blob(c, Vector2(mx, my), 900, 0.12, Color(0.9, 0.97, 0.93, 0.16))
	# nền đá trắng: mạch phiến đá
	for sb in slabs:
		var p: Vector2 = sb[0]
		c.draw_line(p, p + Vector2(sb[1], 3), Color(0.42, 0.48, 0.43, 0.5), 2.0)
		c.draw_line(p + Vector2(sb[1] * 0.3, 0), p + Vector2(sb[1] * 0.25, 40), Color(0.42, 0.48, 0.43, 0.35), 2.0)
	# bóng sàn lục giác dưới chân hai người khi tụ khí / hợp bích
	var gk := smooth(1.0, 1.6, t) * (1.0 - smooth(2.2, 2.6, t)) * 0.7 + smooth(5.0, 5.7, t) * (1.0 - smooth(6.8, 7.8, t))
	if gk > 0.01:
		flat_blob(c, Vector2(tln.pos.x, GROUND + 8), 260, 0.14, COL_N * Color(1, 1, 1, 0.26 * gk))
		flat_blob(c, Vector2(hero.pos.x, GROUND + 8), 260, 0.14, COL_D * Color(1, 1, 1, 0.26 * gk))
	# bóng bánh xe trên sàn
	for i in BEATS.size():
		var b: float = BEATS[i]
		if t > b - FLY and t < b + 1.0:
			var p := _wheel_pos(i)
			flat_blob(c, Vector2(p.x, GROUND + 6), 50, 0.2, Color(0.1, 0.12, 0.1, 0.25))


func _fx_back(c: Node2D) -> void:
	for lf in leaves:
		var p: Vector2 = lf[0]
		var la2: float = lf[1]
		var sc: float = lf[2]
		var d := Vector2(cos(la2), sin(la2)) * 10.0 * sc
		c.draw_line(p - d, p + d, Color(0.45, 0.7, 0.5, 0.28), 3.0)


func _draw_sword(c: Node2D, hp: Vector2, d: Vector2, tassel: Color, slim: float) -> void:
	var n := d.orthogonal()
	var tip := hp + d * SL
	var base := hp + d * 16.0
	c.draw_line(hp - d * 24.0, hp + d * 10.0, Color("#2a2422"), 7.0)
	c.draw_line(hp + d * 12.0 + n * 13.0, hp + d * 12.0 - n * 13.0, Color("#8a7a5a"), 5.0)
	c.draw_colored_polygon(PackedVector2Array([base + n * 4.0 * slim, tip - d * 12.0 + n * 2.0, tip, tip - d * 12.0 - n * 2.0, base - n * 4.0 * slim]), STEEL)
	c.draw_line(base, tip - d * 6.0, Color(0.62, 0.66, 0.64), 1.5)
	var tas := hp - d * 28.0
	c.draw_line(tas, tas + Vector2(-14 + sin(rt * 8.0) * 6.0, 26), tassel, 4.0)


func _fx_norm(c: Node2D) -> void:
	_draw_sword(c, hero.hand, _dir(hero, ad), Color("#3a6ab0"), 1.0)
	_draw_sword(c, tln.hand, _dir(tln, an), Color("#f2f0ea"), 0.75)
	# bánh xe Kim Luân: cầm tay -> ném
	for i in BEATS.size():
		var b: float = BEATS[i]
		if t > b - FLY and t < b + 1.2:
			_wheel(c, _wheel_pos(i), 36.0, rt * 14.0 + i)
	if t > BEATS[2] - FLY and t < BEATS[2] + 1.2:
		_wheel(c, _wheel2_pos(), 30.0, -rt * 16.0)
	var held := 1.0 - smooth(4.95, 5.1, t)
	var in_flight := false
	for b in BEATS:
		if t > b - FLY - 0.02 and t < b - FLY + 0.6:
			in_flight = true
	if held > 0.5 and not in_flight and not hit:
		_wheel(c, foe.hand + Vector2(-6, -10), 32.0, rt * 3.0)
	if t > 4.95 and t < PEAK and not hit:
		var appear := smooth(4.95, 5.35, t)
		for i in 5:
			_wheel(c, _five(i), 30.0 * appear, rt * 18.0 + i)


func _fx_add(c: Node2D) -> void:
	# vệt kiếm (mảnh, mờ)
	var on := 0.0
	for b in BEATS:
		on = maxf(on, smooth(b - 0.15, b - 0.08, t) * (1.0 - smooth(b + 0.1, b + 0.3, t)))
	on = maxf(on, smooth(5.85, 5.95, t) * (1.0 - smooth(6.4, 6.8, t)))
	if on > 0.01:
		for i in trail_d.size() - 1:
			var a := (1.0 - float(i) / trail_d.size()) * on
			c.draw_line(trail_d[i], trail_d[i + 1], HOT_D * Color(1, 1, 1, 0.5 * a), 6.0 - i * 0.6)
			c.draw_line(trail_n[i], trail_n[i + 1], HOT_N * Color(1, 1, 1, 0.5 * a), 6.0 - i * 0.6)
	# chữ X: hai cung ngược chiều cắt nhau đúng chỗ bánh xe
	for b in BEATS:
		var age: float = t - b + 0.06
		if age > 0.0 and age < 0.32:
			var k := age / 0.32
			var e := ease_out(minf(1.0, k * 2.5))
			var a1 := XP + Vector2(-170, -170)
			var b1 := XP + Vector2(170, 170)
			var a2 := XP + Vector2(-170, 170)
			var b2 := XP + Vector2(170, -170)
			crescent(c, XP + Vector2(-60, 0), 230.0, -1.0, lerpf(-1.0, 1.0, e), 0.0, COL_D * Color(1, 1, 1, 0.35 * (1.0 - k)), HOT_D * Color(1, 1, 1, 0.8 * (1.0 - k)))
			crescent(c, XP + Vector2(-60, 0), 230.0, 1.0, lerpf(1.0, -1.0, e), 0.0, COL_N * Color(1, 1, 1, 0.35 * (1.0 - k)), HOT_N * Color(1, 1, 1, 0.8 * (1.0 - k)))
			c.draw_line(a1, a1.lerp(b1, e), HOT_D * Color(1, 1, 1, 0.9 * (1.0 - k)), 5.0)
			c.draw_line(a2, a2.lerp(b2, e), HOT_N * Color(1, 1, 1, 0.9 * (1.0 - k)), 5.0)
			blob(c, XP, 70.0 * (1.0 - k), HOT * Color(1, 1, 1, 0.5))
	# lưới tổ ong ghép dần
	var bloom := smooth(5.6, 6.0, t) * (1.0 - smooth(PEAK + 0.05, PEAK + 0.45, t))
	var gone := smooth(PEAK + 0.05, PEAK + 0.5, t)
	for cl in cells:
		var age: float = t - cl[1]
		if age < 0.0:
			continue
		var grow := ease_out(minf(1.0, age / 0.25))
		var lit := 0.38 + pulse(cl[1], cl[1] + 0.05, 0.35, t) * 0.6 + bloom * 0.7
		lit *= 1.0 - gone
		if lit <= 0.01:
			continue
		var col: Color = HOT_D if cl[2] == 0 else HOT_N
		var p: Vector2 = cl[0]
		_hex(c, p, 72.0 * grow, col * Color(1, 1, 1, minf(1.0, lit)), 4.0)
		_hex(c, p, 60.0 * grow, col * Color(1, 1, 1, 0.3 * lit), 2.0)
		blob(c, p, 60.0 * grow, col * Color(1, 1, 1, 0.08 * lit))
	# đỉnh: hai vệt xoắn kép thành một mũi
	if t > 5.82 and t < PEAK + 0.4:
		var o: Vector2 = (hero.hand + tln.hand) * 0.5 + Vector2(120, -10)
		var reach := smooth(5.85, PEAK, t)
		var ex := lerpf(o.x, 1150.0, reach)
		var fade := 1.0 - smooth(PEAK + 0.05, PEAK + 0.4, t)
		var amp := 46.0 * (1.0 - smooth(5.95, PEAK, t) * 0.5)
		var pd := PackedVector2Array()
		var pn := PackedVector2Array()
		var steps := 40
		for i in steps + 1:
			var x := lerpf(o.x, ex, float(i) / steps)
			var yb: float = lerpf(o.y, 560.0, float(i) / steps)
			var ph := (x - o.x) / 55.0 - rt * 22.0
			pd.append(Vector2(x, yb + sin(ph) * amp))
			pn.append(Vector2(x, yb + sin(ph + PI) * amp))
		c.draw_polyline(pd, HOT_D * Color(1, 1, 1, 0.75 * fade), 5.0)
		c.draw_polyline(pn, HOT_N * Color(1, 1, 1, 0.75 * fade), 5.0)
		c.draw_polyline(pd, COL_D * Color(1, 1, 1, 0.18 * fade), 16.0)
		c.draw_polyline(pn, COL_N * Color(1, 1, 1, 0.18 * fade), 16.0)
		blob(c, Vector2(ex, 560), 60.0 * fade, HOT * Color(1, 1, 1, 0.6))
	# quầng vàng của năm bánh xe lúc tụ
	if t > 5.0 and t < PEAK:
		blob(c, foe.pos + Vector2(-20, -330), 160.0 * smooth(5.0, 5.5, t), FOE_COL * Color(1, 1, 1, 0.22))
