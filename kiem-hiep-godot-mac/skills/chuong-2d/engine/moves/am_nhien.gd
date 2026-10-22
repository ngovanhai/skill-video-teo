extends "res://engine.gd"
# ẢM NHIÊN TIÊU HỒN CHƯỞNG (12.5 s): chân tường thành chiều mưa, trời xanh rêu, đá ướt có vũng nước.
# Thẻ chiêu:
#   người dùng   Dương Quá (một tay, không cầm kiếm: chưởng tự sáng trong mười sáu năm chờ đợi, buồn thì mạnh)
#   đối thủ      Kim Luân Pháp Vương, nội công rực lửa cam (Long Tượng), luân vàng
#   cơ chế       NỖI BUỒN LÀM PHAI MÀU: mỗi chưởng chậm, nặng như thở dài, đẩy ra một dấu bàn tay xám trong mưa.
#                Chưởng đi tới đâu màu thế giới phai tới đó (nền xám dần), lửa cam của đối thủ nhạt và tắt từng nấc;
#                mặt vũng nước loang vòng xám như mực.
#   cặp màu      xám lam buồn (lạnh) vs lửa cam Long Tượng (nóng)
#   bối cảnh     chiều mưa, trời xanh rêu, tường thành đá, đá ướt phản chiếu, vũng nước
#   đỉnh         mưa đứng lại giữa không trung, cả cảnh gần như mất màu; một chưởng duy nhất chạm hai tay chắn,
#                giọt mưa treo bắn toả ra; Kim Luân văng theo cung, rơi ngửa xuống vũng nước, nước tung; rồi mưa rơi lại

const COL := Color(0.75, 0.82, 1.15)      # xám lam buồn
const HOT := Color(1.55, 1.65, 2.1)
const FIRE := Color(1.9, 0.62, 0.22)      # lửa Long Tượng
const FIRE_HOT := Color(2.4, 1.3, 0.6)
const GREY := Color(0.56, 0.58, 0.6)
const BEATS := [2.4, 3.5, 4.6]
const PEAK := 6.3
const LAND_X := 1480.0

var hit := false
var beat_i := 0
var x_hit := 0.0
var drops: Array = []
var puddles: Array = []
var prints: Array = []      # dấu bàn tay xám: {p0, t0, dur, big}
var ripples: Array = []     # [tâm, t0, r]
var bricks: Array = []
var fade := 0.0             # độ phai màu thế giới


func _setup() -> void:
	sky_cols = [Color("#1f2a26"), Color("#3f524a"), Color("#6f8278")]
	moon_on = false
	n_stars = 0
	far_col = Color("#34443d")
	near_col = Color("#26302c")
	mist_col = Color(0.7, 0.78, 0.74, 0.22)
	ground_cols = [Color("#3b4643"), Color("#161c1b"), Color("#7f8f8a")]
	slowmo = [PEAK - 0.12, PEAK + 0.55, 0.3]
	title = "ẢM NHIÊN TIÊU HỒN CHƯỞNG"
	subtitle = "Thần Điêu Hiệp Lữ · Dương Quá"
	title_at = 8.6
	title_col = HOT
	set_char(hero, "duong-qua")
	set_char(foe, "kim-luan-phap-vuong")
	hero.pos = Vector2(600, GROUND)
	foe.pos = Vector2(1260, GROUND)
	hero.node.hand_form = {"F": "xoe", "B": "xoe"}
	foe.node.hand_form = {"F": "xoe", "B": "xoe"}
	hero.col = COL
	foe.col = FIRE
	hero.base = "rest"
	foe.base = "stance"
	cue(1.0, "lib-riser", 0.65)
	for b in BEATS:
		cue(b - 0.45, "lib-whoosh", 0.5)
	cue(PEAK - 0.35, "lib-whoosh-cinematic", 0.85)
	cue(PEAK - 0.6, "lib-chime", 0.4)
	for i in 700:
		drops.append(_drop(true))
	for i in 9:
		puddles.append([Vector2(rng.randf_range(-200, 2100), rng.randf_range(GROUND + 30, H + 150)), rng.randf_range(120, 300)])
	for i in 70:
		bricks.append([rng.randf_range(0, 1), rng.randf_range(0, 1)])


func _drop(anywhere: bool) -> Dictionary:
	var y := rng.randf_range(-200, GROUND) if anywhere else rng.randf_range(-260, -40)
	return {"p": Vector2(rng.randf_range(-300, 2300), y), "v": Vector2(-90, rng.randf_range(1300, 1700)), "s": rng.randf_range(0.6, 1.0), "front": rng.randf() < 0.35}


func _rain_speed() -> float:
	return 1.0 - 0.97 * smooth(PEAK - 0.5, PEAK - 0.15, t) * (1.0 - smooth(PEAK + 0.25, PEAK + 1.0, t))


func _story(dt: float) -> void:
	# ---- màu phai theo từng chưởng
	fade = 0.0
	for b in BEATS:
		fade += smooth(b, b + 0.6, t) * 0.2
	fade += smooth(PEAK - 0.5, PEAK, t) * 0.32
	fade *= 1.0 - smooth(8.2, 11.0, t) * 0.8

	# ---- Dương Quá: chưởng chậm như thở dài
	var push := 0.0
	for b in BEATS:
		push = maxf(push, smooth(b - 0.6, b, t) * (1.0 - smooth(b + 0.25, b + 0.75, t)))
	var big := smooth(PEAK - 0.9, PEAK - 0.1, t) * (1.0 - smooth(PEAK + 1.6, PEAK + 2.4, t))
	hero.gather = smooth(1.0, 1.9, t) * (1.0 - smooth(2.0, 2.3, t))
	hero.push = maxf(push, big)
	hero.lean = hero.push * 0.25
	hero.crouch = big * 0.25
	hero.pos.x = 600.0 + smooth(2.0, 4.8, t) * 90.0 + smooth(PEAK - 0.9, PEAK - 0.1, t) * 60.0
	hero.aura = smooth(1.0, 1.9, t) * 0.5 + big * 0.4 - smooth(8.0, 10.0, t) * 0.8
	hero.expr = "ngai" if t > 8.3 else ("quyet-tam" if t > 1.0 and t < 2.3 else "binh")

	# ---- Kim Luân: lửa cam tắt dần
	if not hit:
		var gd := 0.0
		for b in BEATS:
			gd = maxf(gd, pulse(b + 0.1, b + 0.7, 0.2, t))
		foe.extra = [["guard", maxf(gd, smooth(PEAK - 0.8, PEAK - 0.3, t))]]
		foe.gather = smooth(0.6, 1.4, t) * (1.0 - smooth(2.0, 2.4, t))
		foe.pos.x = 1260.0 - smooth(1.3, 2.0, t) * 40.0 + smooth(2.7, 3.0, t) * 25.0 + smooth(3.8, 4.1, t) * 25.0 + smooth(4.9, 5.2, t) * 25.0
		foe.aura = 0.9 - fade * 1.2
		foe.col = FIRE.lerp(GREY, clampf(fade * 1.4, 0.0, 1.0))
		foe.expr = "soc" if t > 3.6 else "gian"
	pose(hero, 0.0)
	pose(foe, 0.0)

	# ---- mưa (chậm dần tới đứng ở đỉnh; sóng chưởng đẩy giọt treo toả ra)
	var rs := _rain_speed()
	for d in drops:
		var v: Vector2 = d.v
		if hit and t < PEAK + 0.8:
			var away: Vector2 = d.p - (foe.pos + Vector2(-40, -150))
			var dist := away.length()
			if dist < 900.0:
				d.p += away.normalized() * (1.0 - dist / 900.0) * 900.0 * dt
		d.p += v * dt * rs
		if d.p.y > GROUND + 40 or d.p.x < -350:
			if rs > 0.5 and rng.randf() < 0.08:
				ripples.append([Vector2(d.p.x, GROUND + rng.randf_range(10, 160)), t, rng.randf_range(14, 30)])
			var n := _drop(false)
			d.p = n.p
			d.v = n.v
	if ripples.size() > 160:
		ripples = ripples.slice(ripples.size() - 160)

	# ---- mỗi nhịp một chưởng: dấu bàn tay xám trôi chậm sang, chạm thì lửa nhạt đi
	if beat_i < BEATS.size() and t >= BEATS[beat_i] - 0.05:
		prints.append({"p0": hero.handF, "t0": t, "dur": 0.42, "big": 0.0})
		beat_i += 1
	for pr in prints:
		var k: float = (t - pr.t0) / pr.dur
		if k >= 1.0 and not pr.has("done"):
			pr.done = true
			var at: Vector2 = foe.pos + Vector2(-50, -160)
			if pr.big > 0.0:
				continue
			add_ring(at, 230, COL, 8, 0.5)
			add_ring(Vector2(at.x, GROUND + 20), 420, COL, 6, 0.9, 0.2)
			burst(at, 30, 200, 650, HOT, COL, 700.0, 1.4)
			ripples.append([Vector2(foe.pos.x - 60, GROUND + 40), t, 220.0])
			shake = maxf(shake, 11.0)
			foe.pos.x += 22.0
			sfx("lib-impact-bass-2", 0.55)
	if hero.gather > 0.05:
		orbit(hero, rng.randf_range(130, 280), rng.randf_range(1.0, 1.8), 200, rng.randf_range(2, 4), COL, 2.3)

	# ---- đỉnh
	if t >= PEAK - 0.12 and prints.size() == BEATS.size():
		prints.append({"p0": hero.handF, "t0": t, "dur": 0.12, "big": 1.0})
	if t >= PEAK and not hit:
		hit = true
		x_hit = foe.pos.x
		foe.expr = "ko"
		flash = 0.55
		flash_col = Color(0.9, 0.93, 1.0)
		shake = 30.0
		var at: Vector2 = foe.pos + Vector2(-40, -160)
		add_ring(at, 760, HOT, 18, 0.75)
		add_ring(Vector2(at.x, GROUND + 20), 980, COL, 9, 1.0, 0.2)
		burst(at, 160, 300, 1500, HOT, Color(1.6, 1.6, 1.7), 700.0, 1.0)
		ripples.append([Vector2(foe.pos.x - 80, GROUND + 50), t, 520.0])
		sfx("lib-impact-bass-1", 1.0)
		sfx("lib-impact-bass-2", 1.0)
	# ---- hậu quả: văng cung, rơi ngửa vào vũng nước
	if hit:
		var k := clampf((t - PEAK) / 1.0, 0.0, 1.0)
		foe.pos = Vector2(lerpf(x_hit, LAND_X, ease_out(k)), GROUND - sin(k * PI) * 150.0)
		foe.rot = ease_out(k) * PI * 0.5
		foe.hurt = 1.0
		foe.extra = []
		foe.aura = 0.0
		foe.col = GREY
		if k >= 1.0 and not foe.has("landed"):
			foe.landed = true
			shake = maxf(shake, 14.0)
			sfx("lib-impact-bass-2", 0.5)
			ripples.append([Vector2(LAND_X + 60, GROUND + 30), t, 360.0])
			for i in 46:
				emit("spark", Vector2(LAND_X + rng.randf_range(-40, 200), GROUND), Vector2(rng.randf_range(-380, 380), -rng.randf_range(300, 900)), 0.9, 2.5, Color(0.85, 0.9, 1.0, 0.8), 1800.0, 0.3)
			for i in 14:
				emit("smoke", Vector2(LAND_X + rng.randf_range(-40, 220), GROUND), Vector2(rng.randf_range(-120, 160), -rng.randf_range(20, 90)), 1.6, rng.randf_range(40, 80), Color(0.7, 0.75, 0.76, 0.35))


func _cam() -> Array:
	var c := Vector2(960, 560)
	var z := 1.0
	var k1 := smooth(0.9, 1.8, t) * (1.0 - smooth(2.2, 2.8, t))      # tụ khí: nhìn ngang mặt Dương Quá
	c = c.lerp(hero.pos + Vector2(140, -260), k1)
	z = lerpf(z, 1.32, k1)
	var k2 := smooth(5.4, 6.1, t) * (1.0 - smooth(PEAK + 0.9, 8.8, t))  # đỉnh: giữa hai người, hơi cao
	c = c.lerp(Vector2(1040, 520), k2)
	z = lerpf(z, 1.28, k2)
	var k3 := smooth(8.6, 10.4, t)
	c = c.lerp(Vector2(1000, 570), k3)
	return [c, z]


func _fx_ground(c: Node2D) -> void:
	# tường thành đá sau lưng (vẽ ở world để có parallax 1.0 với đất)
	var wall_top := GROUND - 470.0
	c.draw_rect(Rect2(-600, wall_top, 3200, 470), Color("#4a5a54"))
	for i in 9:
		var y := wall_top + i * 52.0
		c.draw_line(Vector2(-600, y), Vector2(2600, y), Color("#36443f"), 3.0)
		for j in 22:
			var x := -600.0 + j * 150.0 + (75.0 if i % 2 == 1 else 0.0)
			c.draw_line(Vector2(x, y), Vector2(x, y + 52), Color("#36443f"), 3.0)
	for j in 18:
		c.draw_rect(Rect2(-560 + j * 180.0, wall_top - 60, 110, 62), Color("#4a5a54"))
	c.draw_rect(Rect2(-600, wall_top - 4, 3200, 10), Color(0, 0, 0, 0.18))
	# vũng nước phản chiếu
	for pd in puddles:
		flat_blob(c, pd[0], pd[1], 0.14, Color(0.62, 0.72, 0.7, 0.28))
		flat_blob(c, pd[0] + Vector2(10, -2), pd[1] * 0.6, 0.1, Color(0.85, 0.9, 0.9, 0.12))
	# vòng loang như mực trên mặt nước
	for rp in ripples:
		var age: float = t - rp[1]
		var big: float = rp[2]
		var life := 0.6 + big / 300.0
		if age < 0.0 or age > life:
			continue
		var k := age / life
		var col := Color(0.22, 0.24, 0.26, 0.55 * (1.0 - k)) if big > 100.0 else Color(0.85, 0.9, 0.92, 0.35 * (1.0 - k))
		c.draw_set_transform(rp[0], 0.0, Vector2(1.0, 0.2))
		c.draw_arc(Vector2.ZERO, big * (0.3 + k), 0, TAU, 40, col, (5.0 if big > 100.0 else 2.0) / 0.2 * 0.2)
		c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	# màu phai: một màn xám phủ lên toàn bộ nền (dưới nhân vật)
	if fade > 0.0:
		c.draw_rect(Rect2(-800, -800, 3600, 2600), Color(0.5, 0.52, 0.54, clampf(fade, 0.0, 0.85)))


func _palm(c: Node2D, p: Vector2, s: float, col: Color) -> void:
	# dấu bàn tay: lòng + 4 ngón + ngón cái
	blob(c, p, 70 * s, col * Color(1, 1, 1, 0.5))
	var lp := PackedVector2Array()
	for i in 20:
		var a := float(i) / 20.0 * TAU
		lp.append(p + Vector2(cos(a) * 34 * s, sin(a) * 40 * s))
	c.draw_colored_polygon(lp, col)
	for i in 4:
		var x := (-22.0 + i * 14.5) * s
		c.draw_line(p + Vector2(x, -30 * s), p + Vector2(x * 1.15, (-80.0 + absf(i - 1.5) * 9.0) * s), col, 13.0 * s)
	c.draw_line(p + Vector2(30 * s, -4 * s), p + Vector2(58 * s, -30 * s), col, 13.0 * s)


func _fx_norm(c: Node2D) -> void:
	# mưa: vệt mảnh (chậm thì thành giọt treo)
	var rs := _rain_speed()
	for d in drops:
		var p: Vector2 = d.p
		var ln: float = (8.0 + 30.0 * rs) * d.s
		var a := 0.35 + 0.2 * (1.0 - rs)
		c.draw_line(p, p - Vector2(-0.06, 1.0) * ln, Color(0.82, 0.88, 0.9, a), 1.6 + (1.0 - rs) * 1.2)


func _fx_add(c: Node2D) -> void:
	for pr in prints:
		var k: float = clampf((t - pr.t0) / pr.dur, 0.0, 1.0)
		var big: float = pr.big
		var end: Vector2 = foe.pos + Vector2(-60, -170) if not hit else Vector2(x_hit - 60, GROUND - 170)
		var p: Vector2 = Vector2(pr.p0).lerp(end, ease_out(k))
		var fadeout := 1.0 - smooth(1.0, 1.6, (t - pr.t0) / pr.dur)
		if fadeout <= 0.0:
			continue
		var s := 0.9 + k * 0.5 + big * 0.9
		_palm(c, p, s, COL * Color(1, 1, 1, 0.22 * fadeout))
		blob(c, p, 26 * s, HOT * Color(1, 1, 1, 0.3 * fadeout))
	# lửa cam quanh Kim Luân còn bao nhiêu
	if not hit:
		var fire := clampf(0.9 - fade * 1.3, 0.0, 1.0)
		if fire > 0.0:
			blob(c, foe.pos + Vector2(0, -160), 150, FIRE * Color(1, 1, 1, 0.16 * fire))
	if t > PEAK - 0.15 and t < PEAK + 0.3:
		var k := smooth(PEAK - 0.15, PEAK + 0.3, t)
		blob(c, foe.pos + Vector2(-50, -160), 200 * (1.0 - k) + 40, HOT * Color(1, 1, 1, 0.25 * (1.0 - k)))
