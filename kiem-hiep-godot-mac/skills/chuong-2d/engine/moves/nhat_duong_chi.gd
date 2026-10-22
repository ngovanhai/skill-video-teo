extends "res://engine.gd"
# NHẤT DƯƠNG CHỈ (12.5 s): linh đường Trùng Dương cung trong đêm, nến trắng, màn tang, quan tài gỗ.
# Thẻ chiêu:
#   người dùng   Vương Trùng Dương (Xạ Điêu): giả chết nằm trong quan tài, bật dậy dùng Nhất Dương Chỉ vừa học của Đoàn Trí Hưng
#   đối thủ      Âu Dương Phong lẻn vào linh đường cướp kinh, ngồi thế cóc Cáp Mô Công
#   cơ chế       HUYỆT ĐIỂM TRÊN VÒM CÓC: Cáp Mô Công là một vòm khí lục phồng xẹp theo nhịp thở quanh người ngồi xổm.
#                Mỗi nhịp một tia chỉ mảnh (không phải chùm chưởng) điểm một huyệt trên vòm: huyệt sáng thành chấm son,
#                vân nứt toả ra từ huyệt, vòm co lại. Đỉnh: ba huyệt nối thành một tam giác về giữa trán (ấn đường),
#                tia thứ tư điểm thẳng trán, vòm khí xì hơi qua ba lỗ huyệt và xẹp như bóng thủng.
#   cặp màu      thuần dương vàng son (ngón tay) vs độc khí lục ngọc (vòm cóc)
#   bối cảnh     linh đường đêm mòng két, cột gỗ son sẫm, màn tang trắng ngà, bàn thờ hai ngọn nến, sàn gạch
#   đỉnh         slowmo khi tia thứ tư chạm trán; vòm xẹp, đối thủ văng theo cung, nằm ngang trên sàn gạch (không máu)

const COL := Color(1.7, 0.85, 0.3)       # thuần dương vàng son
const HOT := Color(2.4, 1.9, 1.1)
const FOE_COL := Color(0.3, 1.35, 0.85)  # độc khí lục ngọc
const BEATS := [2.6, 3.6, 4.6]
const PEAK := 6.1
const LID_T := 0.35
const COF := Rect2(330, 690, 470, 150)   # quan tài: thân trước
const FOE_X := 1330.0
const LAND_X := 1490.0
const TOAD := {"all": [0, 0, 96], "torso": 20, "head": -16, "thF": -100, "shF": 118, "thB": -64, "shB": 96,
	"uaF": -38, "faF": -12, "uaB": -26, "faB": -14, "ftF": 0, "ftB": 0}
const POINT_UP := {"uaF": -150, "faF": -10, "uaB": 30, "faB": -70, "torso": -2, "head": -6}

var beat_i := 0
var hit := false
var x_hit := 0.0
var holes: Array = []        # [vị trí trên vòm (tương đối tâm vòm), giờ điểm]
var cracks: Array = []       # [điểm đầu, điểm cuối] (tương đối tâm vòm)
var lid := {"p": Vector2(565, 680), "r": 0.0, "v": Vector2.ZERO, "w": 0.0, "free": false, "rest": false}
var dome_c := Vector2.ZERO
var dome_r := 0.0
var tri := 0.0


func _setup() -> void:
	sky_cols = [Color("#05181b"), Color("#0b2a2d"), Color("#163a3a")]
	moon_on = false
	n_stars = 0
	far_col = Color("#0c2426")
	near_col = Color("#0f2b2c")
	mist_col = Color(0.4, 0.7, 0.68, 0.1)
	ground_cols = [Color("#22383a"), Color("#0b1617"), Color("#46625f")]
	slowmo = [PEAK - 0.05, PEAK + 0.62, 0.3]
	title = "NHẤT DƯƠNG CHỈ"
	subtitle = "Vương Trùng Dương · phá Cáp Mô Công"
	title_at = 8.4
	title_col = HOT
	set_char(hero, "vuong-trung-duong")
	set_char(foe, "au-duong-phong")
	hero.col = COL
	foe.col = FOE_COL
	hero.pos = Vector2(560, 1060)
	hero.base = "rest"
	foe.pos = Vector2(FOE_X, GROUND)
	foe.base = "rest"
	foe.extra = [[TOAD, 1.0]]
	hero.node.hand_form = {"F": "chi", "B": "tha"}
	foe.node.hand_form = {"F": "xoe", "B": "xoe"}
	hero.node.visible = false
	cue(LID_T, "lib-impact-bass-2", 0.8)
	cue(LID_T, "lib-whoosh", 0.7)
	cue(1.0, "lib-riser", 0.8)
	cue(5.35, "lib-whoosh", 0.7)
	cue(PEAK - 0.3, "lib-whoosh-cinematic", 0.9)


func _breath() -> float:
	return sin(t * 3.4) * 0.5 + 0.5


func _story(dt: float) -> void:
	# ---- quan tài bật nắp, người "đã chết" đứng dậy
	if t >= LID_T and not lid.free:
		lid.free = true
		lid.v = Vector2(-520, -1250)
		lid.w = -5.5
		hero.node.visible = true
		shake = maxf(shake, 16.0)
		burst(Vector2(565, 690), 40, 200, 700, Color(0.75, 0.62, 0.5), HOT, 900.0, 1.2, -PI, 0.0)
		for i in 14:
			emit("smoke", Vector2(rng.randf_range(360, 770), 690), Vector2(rng.randf_range(-120, 120), -rng.randf_range(40, 160)), 1.6, rng.randf_range(30, 60), Color(0.55, 0.62, 0.6, 0.4))
	if lid.free and not lid.rest:
		lid.v.y += 2600.0 * dt
		lid.p += lid.v * dt
		lid.r += lid.w * dt
		if lid.p.y > GROUND - 30 and lid.v.y > 0:
			lid.rest = true
			lid.p = Vector2(lid.p.x, GROUND - 30)
			lid.r = -PI * 0.5 + 0.18
			shake = maxf(shake, 10.0)
			sfx("lib-impact-bass-2", 0.5)
			for i in 10:
				emit("smoke", Vector2(lid.p.x + rng.randf_range(-60, 60), GROUND), Vector2(rng.randf_range(-140, 140), -rng.randf_range(10, 80)), 1.4, rng.randf_range(30, 60), Color(0.45, 0.55, 0.55, 0.4))

	# ---- người ra chiêu
	var rise := ease_out((t - LID_T) / 0.55)
	var jump := clampf((t - 5.35) / 0.6, 0.0, 1.0)
	if t < 5.35:
		hero.pos = Vector2(560, lerpf(1060.0, 800.0, rise))
	else:
		hero.pos = Vector2(lerpf(560.0, 880.0, ease_out(jump)), lerpf(800.0, GROUND, jump) - sin(jump * PI) * 150.0)
	hero.gather = smooth(1.0, 1.8, t) * (1.0 - smooth(2.2, 2.45, t))
	var up := smooth(1.1, 1.9, t) * (1.0 - smooth(2.3, 2.6, t))
	var bp := 0.0
	for b in BEATS:
		bp = maxf(bp, pulse(b - 0.12, b + 0.08, 0.3, t))
	var aim := smooth(2.3, 2.6, t) * (1.0 - smooth(5.3, 5.45, t))
	var lunge := smooth(5.8, PEAK, t) * (1.0 - smooth(9.0, 10.0, t))
	hero.push = 0.0
	hero.extra = [[POINT_UP, up], ["point", maxf(aim * (0.75 + 0.25 * bp), lunge)], ["fly", jump * (1.0 - jump) * 2.2]]
	hero.lean = bp * 0.25 + lunge * 0.35
	hero.aura = smooth(1.0, 1.8, t) * 0.55 + bp * 0.2 + lunge * 0.5 - smooth(7.2, 9.0, t) * 0.9
	if t > 8.6:
		hero.expr = "dac-y"
	elif t > 1.0:
		hero.expr = "quyet-tam"
	elif t > LID_T:
		hero.expr = "binh"

	# ---- đối thủ: thế cóc, vòm khí phồng xẹp theo nhịp thở
	if not hit:
		var shrink := 1.0 - 0.07 * holes.size()
		dome_r = (205.0 + 25.0 * _breath() + 30.0 * smooth(1.2, 2.2, t)) * shrink
		foe.aura = 0.35 + 0.25 * _breath()
		foe.expr = "soc" if (t > LID_T and t < 1.3) or holes.size() >= 2 else "gian"
		var flinch := 0.0
		for h in holes:
			flinch = maxf(flinch, pulse(h[1], h[1] + 0.08, 0.35, t))
		foe.pos.x = FOE_X + flinch * 26.0 + holes.size() * 10.0
		foe.tint = Color(1, 1, 1).lerp(Color(0.8, 1.15, 0.9), flinch * 0.6)
		foe.extra = [[TOAD, 1.0]]
	pose(hero, 0.0)
	pose(foe, 0.0)
	dome_c = foe.pos + Vector2(-10, -150)
	var tip: Vector2 = hero.handF + Vector2(hero.face * 26.0, -4)

	if hero.gather > 0.05 or up > 0.2:
		orbit(hero, rng.randf_range(110, 260), rng.randf_range(2.0, 3.4), 240, rng.randf_range(2, 4), HOT, 2.3)

	# ---- [CƠ CHẾ] mỗi nhịp một tia mảnh điểm một huyệt trên vòm cóc
	if beat_i < BEATS.size() and t >= BEATS[beat_i]:
		var ang: float = [PI * 1.12, PI * 0.9, PI * 1.32][beat_i]
		var hp := Vector2(cos(ang), sin(ang)) * dome_r
		holes.append([hp, t])
		var r2 := RandomNumberGenerator.new()
		r2.seed = 77 + beat_i
		for k in 4:
			var a := ang + PI + r2.randf_range(-0.9, 0.9)
			var p0 := hp
			var p1 := hp + Vector2(cos(a), sin(a)) * r2.randf_range(50, 95)
			var p2 := p1 + Vector2(cos(a + r2.randf_range(-0.6, 0.6)), sin(a + r2.randf_range(-0.6, 0.6))) * r2.randf_range(30, 55)
			cracks.append([p0 / dome_r, p1 / dome_r])
			cracks.append([p1 / dome_r, p2 / dome_r])
		var at := dome_c + hp
		add_ring(at, 120, HOT, 6, 0.35)
		burst(at, 26, 250, 750, HOT, FOE_COL, 500.0, 1.5, ang - 0.9, ang + 0.9)
		shake = maxf(shake, 11.0)
		sfx("lib-glitch-1", 0.4)
		sfx("lib-impact-bass-2", 0.6)
		beat_i += 1

	# ---- đỉnh: ba huyệt nối về ấn đường, tia thứ tư điểm thẳng trán
	tri = smooth(5.7, 6.0, t) * (1.0 - smooth(PEAK + 0.5, PEAK + 0.9, t))
	if t >= PEAK and not hit:
		hit = true
		x_hit = foe.pos.x
		foe.expr = "ko"
		flash = 0.6
		flash_col = Color(1.0, 0.92, 0.75)
		shake = 30.0
		var at: Vector2 = foe.head + Vector2(0, 70)
		add_ring(at, 620, HOT, 18, 0.7)
		add_ring(Vector2(dome_c.x, GROUND), 760, FOE_COL, 10, 0.9, 0.2)
		burst(at, 120, 300, 1500, HOT, Color(2, 2, 2), 800.0, 1.0)
		sfx("lib-impact-bass-1", 1.0)
		sfx("lib-impact-bass-2", 1.0)
		sfx("lib-pop", 0.7)
		for h in holes:
			for i in 8:
				var hv: Vector2 = h[0]
				emit("smoke", dome_c + hv, hv.normalized() * rng.randf_range(200, 420), 1.3, rng.randf_range(24, 50), Color(0.35, 0.8, 0.55, 0.35))
	# vòm xì hơi xẹp
	if hit:
		var kd := clampf((t - PEAK) / 0.7, 0.0, 1.0)
		dome_r = lerpf(dome_r, 0.0, kd) if kd < 1.0 else 0.0
		var k := clampf((t - PEAK - 0.1) / 0.9, 0.0, 1.0)
		foe.pos = Vector2(lerpf(x_hit, LAND_X, ease_out(k)), GROUND - sin(k * PI) * 120.0)
		foe.rot = ease_out(k) * PI * 0.5
		foe.hurt = 1.0
		foe.extra = []
		foe.aura = 0.0
		foe.tint = Color(1, 1, 1)
		if k >= 1.0 and not foe.has("landed"):
			foe.landed = true
			shake = maxf(shake, 14.0)
			sfx("lib-impact-bass-2", 0.5)
			for i in 20:
				emit("smoke", Vector2(LAND_X + rng.randf_range(-40, 220), GROUND), Vector2(rng.randf_range(-160, 220), -rng.randf_range(20, 130)), 2.0, rng.randf_range(40, 85), Color(0.45, 0.55, 0.55, 0.42))
	if tip.x > 0.0 and lunge > 0.5 and not hit:
		emit("add", tip, Vector2.ZERO, 0.25, 18.0, HOT * Color(1, 1, 1, 0.5))


func _cam() -> Array:
	var c := Vector2(960, 560)
	var z := 1.0
	var k1 := smooth(0.9, 1.6, t) * (1.0 - smooth(2.2, 2.7, t))
	c = c.lerp(Vector2(620, 470), k1)
	z = lerpf(z, 1.38, k1)
	var k2 := smooth(2.4, 3.0, t) * (1.0 - smooth(5.2, 5.6, t))
	c = c.lerp(Vector2(960, 560), k2)
	z = lerpf(z, 1.08, k2)
	var k3 := smooth(5.5, 6.0, t) * (1.0 - smooth(PEAK + 0.8, 9.0, t))
	c = c.lerp(Vector2(1120, 600), k3)
	z = lerpf(z, 1.24, k3)
	var k4 := smooth(8.6, 10.4, t)
	c = c.lerp(Vector2(1000, 590), k4)
	return [c, z]


# ---- linh đường (sau nhân vật)
func _fx_ground(c: Node2D) -> void:
	var wall_t := Color("#0f2a2c")
	var wall_b := Color("#1a3a3a")
	c.draw_polygon(PackedVector2Array([Vector2(-600, -400), Vector2(W + 600, -400), Vector2(W + 600, GROUND), Vector2(-600, GROUND)]),
		PackedColorArray([wall_t, wall_t, wall_b, wall_b]))
	# gạch sàn
	for i in 22:
		var x := -500.0 + i * 140.0
		c.draw_line(Vector2(x, GROUND), Vector2(960 + (x - 960) * 1.9, H + 300), Color(0.3, 0.45, 0.45, 0.35), 2)
	for y in [880.0, 940.0, 1020.0]:
		c.draw_line(Vector2(-600, y), Vector2(W + 600, y), Color(0.3, 0.45, 0.45, 0.25), 2)
	# cột gỗ son sẫm
	for x in [150.0, 1770.0]:
		c.draw_rect(Rect2(x - 46, -400, 92, GROUND + 400), Color("#4a1f1a"))
		c.draw_rect(Rect2(x - 46, -400, 18, GROUND + 400), Color("#5f2a22"))
		c.draw_rect(Rect2(x - 60, GROUND - 40, 120, 40), Color("#2e1612"))
	# màn tang: diềm trắng ngà rủ
	var drape := Color(0.78, 0.8, 0.74, 0.55)
	var pts := PackedVector2Array([Vector2(-600, -400), Vector2(W + 600, -400)])
	for i in range(27, -1, -1):
		var x := -400.0 + i * 100.0
		pts.append(Vector2(x + 50, 150 + sin(rt * 0.8 + i) * 4.0))
		pts.append(Vector2(x, 100))
	c.draw_colored_polygon(pts, drape)
	for x in [430.0, 1490.0]:
		c.draw_colored_polygon(PackedVector2Array([Vector2(x - 70, 80), Vector2(x + 70, 80), Vector2(x + 30 + sin(rt * 0.7) * 6.0, 520), Vector2(x - 30 + sin(rt * 0.7) * 6.0, 520)]), Color(0.78, 0.8, 0.74, 0.32))
	# bàn thờ + bài vị + hai nến
	var ax := 960.0
	c.draw_rect(Rect2(ax - 190, 560, 380, 26), Color("#3a1a15"))
	c.draw_rect(Rect2(ax - 170, 586, 22, 254), Color("#2b1310"))
	c.draw_rect(Rect2(ax + 148, 586, 22, 254), Color("#2b1310"))
	c.draw_rect(Rect2(ax - 40, 440, 80, 120), Color("#3d1d16"))
	c.draw_rect(Rect2(ax - 30, 452, 60, 100), Color("#c8a35a"))
	for dx in [-130.0, 130.0]:
		c.draw_rect(Rect2(ax + dx - 11, 480, 22, 80), Color(0.92, 0.9, 0.84))
	# lòng quan tài (phía sau người)
	c.draw_colored_polygon(PackedVector2Array([Vector2(COF.position.x + 20, COF.position.y - 30), Vector2(COF.end.x - 20, COF.position.y - 30), Vector2(COF.end.x, COF.position.y), Vector2(COF.position.x, COF.position.y)]), Color("#1c0d0a"))


# ---- vật đặc trước nhân vật: thân quan tài, bệ, nắp, vòm cóc
func _fx_norm(c: Node2D) -> void:
	# bệ đá dưới quan tài
	c.draw_rect(Rect2(COF.position.x - 40, COF.end.y, COF.size.x + 80, 400), Color("#1d2c2c"))
	c.draw_rect(Rect2(COF.position.x - 40, COF.end.y, COF.size.x + 80, 10), Color("#3a5250"))
	# thân quan tài gỗ son sẫm
	var cp := PackedVector2Array([COF.position, Vector2(COF.end.x, COF.position.y), Vector2(COF.end.x - 18, COF.end.y), Vector2(COF.position.x + 18, COF.end.y)])
	c.draw_colored_polygon(cp, Color("#4d2018"))
	c.draw_rect(Rect2(COF.position.x, COF.position.y, COF.size.x, 14), Color("#6b2e22"))
	c.draw_circle(COF.get_center() + Vector2(0, 10), 30, Color("#c8a35a"))
	c.draw_circle(COF.get_center() + Vector2(0, 10), 22, Color("#4d2018"))
	# nắp
	c.draw_set_transform(lid.p, lid.r, Vector2.ONE)
	c.draw_rect(Rect2(-250, -22, 500, 44), Color("#5a261c"))
	c.draw_rect(Rect2(-250, -22, 500, 10), Color("#74352a"))
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	# vòm khí cóc (lục, mờ)
	if dome_r > 4.0:
		var poly := _dome_pts(dome_r)
		c.draw_colored_polygon(poly, Color(0.25, 0.7, 0.5, 0.16))


func _dome_pts(r: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	var wob := 0.0
	if hit:
		wob = 18.0 * (1.0 - clampf((t - PEAK) / 0.7, 0.0, 1.0))
	for i in 49:
		var a := PI + PI * float(i) / 48.0
		var rr := r * (1.0 + 0.04 * sin(a * 5.0 + t * 4.0)) + sin(a * 9.0 + t * 30.0) * wob
		rr = maxf(rr, r * 0.6)
		pts.append(dome_c + Vector2(cos(a) * rr * 1.08, sin(a) * rr))
	pts.append(Vector2(dome_c.x + r * 1.08, GROUND))
	pts.append(Vector2(dome_c.x - r * 1.08, GROUND))
	return pts


func _fx_add(c: Node2D) -> void:
	# nến
	for dx in [-130.0, 130.0]:
		var fp := Vector2(960 + dx, 466 + sin(rt * 9.0 + dx) * 2.0)
		blob(c, fp, 60, Color(1.0, 0.6, 0.25, 0.25))
		c.draw_circle(fp, 7, Color(1.6, 1.2, 0.6))
	# vành vòm
	if dome_r > 4.0:
		var pts := _dome_pts(dome_r)
		var rim := pts.slice(0, 49)
		c.draw_polyline(rim, FOE_COL * Color(1, 1, 1, 0.55), 5.0)
		c.draw_polyline(rim, Color(0.7, 1.6, 1.1, 0.35), 2.0)
		for cr in cracks:
			var c0: Vector2 = cr[0]
			var c1: Vector2 = cr[1]
			c.draw_line(dome_c + Vector2(c0.x * 1.08, c0.y) * dome_r, dome_c + Vector2(c1.x * 1.08, c1.y) * dome_r, COL * Color(1, 1, 1, 0.7), 2.5)
		for h in holes:
			var hv: Vector2 = h[0]
			var hn := hv.normalized()
			var hp: Vector2 = dome_c + Vector2(hn.x * 1.08, hn.y) * dome_r
			blob(c, hp, 34, COL * Color(1, 1, 1, 0.5))
			c.draw_circle(hp, 7, HOT)
	# tia chỉ mảnh mỗi nhịp
	var tip: Vector2 = hero.handF + Vector2(hero.face * 26.0, -4)
	for h in holes:
		var k: float = t - float(h[1])
		if k > -0.01 and k < 0.22:
			var hv: Vector2 = h[0]
			var tgt: Vector2 = dome_c + Vector2(hv.normalized().x * 1.08, hv.normalized().y) * dome_r
			var a := 1.0 - k / 0.22
			c.draw_line(tip, tgt, COL * Color(1, 1, 1, 0.35 * a), 9.0)
			c.draw_line(tip, tgt, HOT * Color(1, 1, 1, a), 3.0)
	if t > 1.0 and t < 2.4:
		var g := smooth(1.0, 1.8, t) * (1.0 - smooth(2.2, 2.4, t))
		blob(c, tip, 70 * g, COL * Color(1, 1, 1, 0.3))
		c.draw_circle(tip, 6 + 6 * g, HOT)
	# đỉnh: tam giác ba huyệt về ấn đường, tia thứ tư
	var brow: Vector2 = foe.head + Vector2(0, 70)
	if tri > 0.01 and holes.size() == 3:
		for h in holes:
			var hv: Vector2 = h[0]
			var hp: Vector2 = dome_c + Vector2(hv.normalized().x * 1.08, hv.normalized().y) * maxf(dome_r, 40.0)
			c.draw_line(hp, brow, HOT * Color(1, 1, 1, 0.6 * tri), 2.5)
		blob(c, brow, 60 * tri, COL * Color(1, 1, 1, 0.4))
	if t > PEAK - 0.12 and t < PEAK + 0.3:
		var a := 1.0 - clampf((t - PEAK) / 0.3, 0.0, 1.0)
		c.draw_line(tip, brow, COL * Color(1, 1, 1, 0.3 * a), 12.0)
		c.draw_line(tip, brow, HOT * Color(1, 1, 1, a), 4.0)
		blob(c, brow, 90 * a, HOT * Color(1, 1, 1, 0.5))
