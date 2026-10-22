extends "res://engine.gd"
# ĐỘC CÔ CỬU KIẾM (12.5 s): Tư Quá Nhai, Hoa Sơn, chạng vạng hổ phách, tuyết bay ngang.
# Thẻ chiêu:
#   người dùng   Lệnh Hồ Xung (kiếm, vừa học Độc Cô Cửu Kiếm của Phong Thanh Dương)
#   đối thủ      Điền Bá Quang "Vạn Lý Độc Hành", khoái đao
#   cơ chế       Điền lướt tới chém liên hoàn 4 nhịp (mỗi nhịp 2 đao), LHX chỉ khẽ gạt; mỗi đao lộ một sơ hở (dấu hổ phách mờ).
#                Thời gian chậm (tuyết gần đứng), các dấu sơ hở bừng sáng, chọn một (sườn dưới nách khi Điền giơ đao) -> MỘT nhát đâm thẳng.
#   cặp màu      kiếm ý ngọc đêm (jade) vs đao quang son (vermilion); sơ hở hổ phách
#   bối cảnh     chạng vạng hổ phách, núi gỗ sẫm, sườn ngọc đêm, đất gỗ phủ tuyết mỏng, thông khắc gỗ, gió tuyết ngang
#   đỉnh         slowmo, mũi kiếm điểm đúng sơ hở -> đao văng cắm tuyết, Điền bật lùi ngồi phịch xuống tuyết (không máu)

const COL := Color(0.35, 1.4, 1.0)        # kiếm ý ngọc đêm
const HOT := Color(1.2, 2.1, 1.6)
const FOE_COL := Color(1.8, 0.38, 0.18)   # đao quang son
const FOE_HOT := Color(2.3, 1.0, 0.5)
const AMBER := Color(1.9, 1.25, 0.35)     # dấu sơ hở
const AMBER_HOT := Color(2.4, 1.9, 0.9)
const STEEL := Color(0.86, 0.88, 0.84)
const WOOD := Color("#3a2414")
const BEATS := [2.55, 3.25, 3.95, 4.65]   # 4 nhịp khoái đao (mỗi nhịp 2 đao: b, b+0.16)
const READ := [5.5, 5.65, 5.8]            # các dấu sơ hở bừng sáng
const PEAK := 6.1                         # mũi kiếm chạm sơ hở
const SIT_X := 1390.0
const SPOTS := [Vector2(-44, -150), Vector2(-50, -98), Vector2(-32, -128), Vector2(-20, -45)]

const LUNGE := {"uaF": -84, "faF": -4, "uaB": 50, "faB": -40, "torso": 8, "head": -4, "thF": -58, "shF": 52, "thB": 46, "shB": -12, "all": [0, 0, 34]}
const SIT := {"uaF": -30, "faF": -40, "uaB": 40, "faB": -30, "torso": -10, "head": -4, "thF": -82, "shF": 40, "thB": -70, "shB": 48, "all": [0, 0, 92]}
const LOW := {"uaF": 10, "faF": -20, "uaB": -8, "faB": 0, "torso": 2, "head": 3}

var hit := false
var parry_i := 0
var x_hit := 0.0
var flakes: Array = []
var strokes: Array = []
var patches: Array = []
var marks: Array = []       # [vị trí, t sinh]
var slashes: Array = []     # [tâm, rot, t0, sweep dấu]
var saber := {"free": false, "p": Vector2.ZERO, "v": Vector2.ZERO, "a": 0.0, "w": 0.0, "stuck": false}
var hsw_a := 0.0            # góc kiếm LHX (cục bộ: 0 = hướng đối thủ, dương = chúc xuống)
var fsw_a := 0.0            # góc đao Điền (cục bộ)
var thrust_k := 0.0


func _setup() -> void:
	sky_cols = [Color("#1f2a22"), Color("#b07a34"), Color("#e2ab5a")]
	moon_on = false
	n_stars = 0
	far_col = Color("#4b3421")
	near_col = Color("#203429")
	mist_col = Color(0.95, 0.75, 0.45, 0.16)
	ground_cols = [Color("#5a3e27"), Color("#120b06"), Color("#e4d8c2")]
	slowmo = [5.95, 6.6, 0.3]
	title = "ĐỘC CÔ CỬU KIẾM"
	subtitle = "Tiếu Ngạo Giang Hồ · Lệnh Hồ Xung"
	title_at = 8.4
	title_col = HOT
	set_char(hero, "lenh-ho-xung")
	set_char(foe, "dien-ba-quang")
	hero.pos = Vector2(560, GROUND)
	foe.pos = Vector2(1320, GROUND)
	hero.node.hand_form = {"F": "nam", "B": "chi"}   # tay F nắm chuôi kiếm, tay B bắt kiếm chỉ
	foe.node.hand_form = {"F": "nam", "B": "nam"}
	hero.col = COL
	foe.col = FOE_COL
	hero.base = "rest"
	cue(1.0, "lib-riser", 0.75)
	cue(2.2, "lib-whoosh", 0.7)
	for b in BEATS:
		cue(b - 0.04, "lib-whoosh-short", 0.55)
		cue(b + 0.12, "lib-whoosh-short", 0.5)
	cue(READ[0], "lib-sparkle", 0.4)
	for r in READ:
		cue(r, "lib-glitch-1", 0.35)
	cue(5.82, "lib-whoosh-cinematic", 0.9)
	# tuyết
	for i in 520:
		flakes.append(_flake(true))
	# nét khắc gỗ + vệt tuyết trên đất
	for i in 46:
		strokes.append([Vector2(rng.randf_range(-500, 2400), rng.randf_range(GROUND + 14, H + 240)), rng.randf_range(40, 220), rng.randf_range(1.5, 3.5)])
	for i in 14:
		patches.append([Vector2(rng.randf_range(-400, 2300), rng.randf_range(GROUND + 10, H + 120)), rng.randf_range(90, 260)])


func _flake(anywhere: bool) -> Dictionary:
	var p := Vector2(rng.randf_range(-300, 2500), rng.randf_range(-200, GROUND + 100) if anywhere else rng.randf_range(-260, -20))
	if not anywhere and rng.randf() < 0.4:
		p = Vector2(rng.randf_range(2150, 2500), rng.randf_range(-100, GROUND))
	return {"p": p, "v": Vector2(-rng.randf_range(260, 520), rng.randf_range(70, 170)), "s": rng.randf_range(1.6, 4.2), "ph": rng.randf() * TAU, "front": rng.randf() < 0.45}


func _wdir(f: Dictionary, a: float) -> Vector2:
	return Vector2(cos(a) * f.face, sin(a))


func _slow() -> float:
	return smooth(5.45, 5.75, t) * (1.0 - smooth(6.2, 6.7, t))


func _opening() -> Vector2:
	return foe.pos + SPOTS[2]


func _story(dt: float) -> void:
	# ---- tuyết: chậm gần đứng khi "đọc" sơ hở
	var sdt := dt * (1.0 - 0.9 * _slow())
	for fl in flakes:
		fl.p += (fl.v + Vector2(0, sin(rt * 2.0 + fl.ph) * 40.0)) * sdt
		if fl.p.y > GROUND + 140 or fl.p.x < -350:
			var n := _flake(false)
			fl.p = n.p
			fl.v = n.v

	# ---- Điền Bá Quang
	var dash := smooth(2.15, 2.42, t)
	if not hit:
		foe.pos.x = lerpf(1320.0, 1090.0, dash)
		var sl := 0.0
		var up := 0.0
		for b in BEATS:
			up = maxf(up, pulse(b - 0.16, b - 0.02, 0.06, t) + pulse(b + 0.08, b + 0.12, 0.05, t))
			sl = maxf(sl, pulse(b - 0.02, b + 0.06, 0.08, t) + pulse(b + 0.14, b + 0.2, 0.1, t))
		var big := smooth(5.3, 5.9, t)
		foe.extra = [["windup", up * (1.0 - sl) * (1.0 - big)], [{"uaF": -168, "faF": -18, "uaB": 40, "faB": -60, "torso": -6, "head": -4}, big], ["slash", sl * (1.0 - big)], ["guard", smooth(0.0, 0.5, t) * 0.4 * (1.0 - dash)]]
		foe.lean = -pulse(4.75, 5.1, 0.3, t) * 0.25
		foe.aura = smooth(2.0, 2.4, t) * 0.3 + big * 0.4
		foe.expr = "soc" if t > 3.6 else "gian"
		# góc đao: giơ lên (-1.7) -> chém xuống (0.9); nhịp sau chém ngược
		fsw_a = lerpf(-0.5, -1.0, smooth(0.0, 0.6, t))
		for i in BEATS.size():
			var b: float = BEATS[i]
			var s1 := smooth(b - 0.04, b + 0.06, t) * (1.0 - smooth(b + 0.1, b + 0.13, t))
			var s2 := smooth(b + 0.12, b + 0.22, t) * (1.0 - smooth(b + 0.4, b + 0.6, t))
			if t > b - 0.2 and t < b + 0.65:
				fsw_a = lerpf(-1.7, 0.9, s1) if t < b + 0.12 else lerpf(0.9, -0.6, s2)
		fsw_a = lerpf(fsw_a, -2.3, big)
	# ---- Lệnh Hồ Xung: vô chiêu, động tác tối thiểu
	var g := smooth(1.0, 1.6, t) * (1.0 - smooth(2.1, 2.4, t))
	var guard := smooth(2.1, 2.4, t) * (1.0 - smooth(6.0, 6.1, t))
	var flick := 0.0
	for b in BEATS:
		flick = maxf(flick, pulse(b, b + 0.05, 0.1, t) + pulse(b + 0.16, b + 0.2, 0.1, t))
	thrust_k = smooth(5.95, 6.08, t) * (1.0 - smooth(7.3, 8.0, t))
	var rest_k := smooth(7.3, 8.0, t)
	hero.gather = g * 0.7
	hero.extra = [["guard", guard * 0.55], ["point", flick * 0.35 * guard], [LUNGE, thrust_k], [LOW, rest_k]]
	hero.aura = g * 0.5 + guard * 0.15 + smooth(5.4, 5.9, t) * 0.55 * (1.0 - smooth(6.6, 7.8, t))
	hero.expr = "vui" if t > 7.6 else ("quyet-tam" if t > 1.0 else "binh")
	hsw_a = lerpf(0.9, -1.45, g)                         # kiếm chúc xuống -> dựng đứng khi tụ
	hsw_a = lerpf(hsw_a, -0.55 - flick * 0.45, guard)    # gạt nhẹ
	# lùi nửa bước mỗi nhịp
	var back := 0.0
	for b in BEATS:
		back += smooth(b, b + 0.2, t) * 8.0
	hero.pos.x = 560.0 + 60.0 * smooth(2.1, 2.4, t) - back

	pose(hero, 0.0)
	pose(foe, 0.0)

	# một nhát đâm thẳng: tính vị trí để mũi kiếm chạm đúng sơ hở
	if thrust_k > 0.001:
		var target := _opening()
		var a_aim: float = atan2(target.y - hero.hand.y, (target.x - hero.hand.x))
		hsw_a = lerpf(hsw_a, a_aim, smooth(5.9, 6.0, t))
		var d := _wdir(hero, hsw_a)
		var need: float = target.x - 6.0 - d.x * 175.0 - (hero.hand.x - hero.pos.x)
		var x0: float = hero.pos.x
		hero.pos.x = lerpf(x0, need, smooth(5.95, PEAK, t) * (1.0 - smooth(7.3, 8.2, t) * 0.4))
		pose(hero, 0.0)
	hsw_a = lerpf(hsw_a, 1.0, rest_k)

	var hp: Vector2 = hero.hand
	var htip: Vector2 = hp + _wdir(hero, hsw_a) * 175.0
	var fp: Vector2 = foe.hand
	var ftip: Vector2 = fp + _wdir(foe, fsw_a) * 165.0

	if g > 0.05:
		orbit(hero, rng.randf_range(110, 260), rng.randf_range(2.0, 3.2), 240, rng.randf_range(2, 4), HOT, 2.3)
	# Vạn Lý Độc Hành: lướt tới để vệt
	if t > 2.15 and t < 2.5:
		for i in 6:
			emit("add", foe.pos + Vector2(rng.randf_range(0, 220), -rng.randf_range(20, 300)), Vector2(rng.randf_range(300, 700), 0), 0.25, rng.randf_range(10, 22), FOE_COL * Color(1, 1, 1, 0.18))

	# ---- biểu diễn: mỗi nhịp đao son -> gạt nhẹ, lộ một sơ hở
	if parry_i < BEATS.size() * 2:
		var b: float = BEATS[parry_i / 2] + (0.16 if parry_i % 2 == 1 else 0.0)
		if t >= b:
			var down := parry_i % 2 == 0
			slashes.append([fp, (PI + 0.2) if down else (PI - 0.2), t, 1.0 if down else -1.0])
			var at: Vector2 = (htip + ftip) * 0.5
			at = htip
			add_ring(at, 150 if down else 110, HOT, 6, 0.3)
			burst(at, 26, 300, 900, FOE_HOT, Color(1.6, 1.6, 1.4), 900.0, 1.4)
			shake = maxf(shake, 12.0 if down else 10.0)
			sfx("lib-impact-bass-2", 0.6 if down else 0.45)
			foe.pos.x += 10.0
			if down:
				marks.append([SPOTS[parry_i / 2], t])
			parry_i += 1

	# ---- đỉnh: mũi kiếm điểm sơ hở
	if t >= PEAK and not hit:
		hit = true
		x_hit = foe.pos.x
		foe.expr = "ko"
		flash = 0.55
		flash_col = Color(1.0, 0.93, 0.78)
		shake = 30.0
		var at := _opening()
		add_ring(at, 520, AMBER_HOT, 14, 0.6)
		add_ring(at, 300, HOT, 8, 0.45, 1.0, 0.05)
		add_ring(Vector2(at.x, GROUND), 700, COL, 8, 0.8, 0.18)
		burst(at, 120, 300, 1500, AMBER_HOT, HOT, 700.0, 1.1, -PI * 0.8, PI * 0.8)
		sfx("lib-impact-bass-1", 1.0)
		sfx("lib-impact-bass-2", 1.0)
		saber.free = true
		saber.p = fp
		saber.a = fsw_a
		saber.v = Vector2(520, -1150)
		saber.w = 14.0
	if saber.free and not saber.stuck:
		saber.v.y += 1900.0 * dt
		saber.p += saber.v * dt
		saber.a += saber.w * dt
		if saber.v.y > 0 and saber.p.y > GROUND - 145:
			saber.stuck = true
			saber.a = 1.2   # mũi cắm xuống tuyết, chuôi trên
			saber.p = Vector2(saber.p.x, GROUND - 145)
			sfx("lib-chime", 0.45)
			for i in 10:
				emit("smoke", Vector2(saber.p.x + 20, GROUND), Vector2(rng.randf_range(-120, 160), -rng.randf_range(20, 110)), 1.4, rng.randf_range(24, 46), Color(0.92, 0.88, 0.8, 0.4))

	# ---- hậu quả: bật lùi theo cung, ngồi phịch xuống tuyết
	if hit:
		var k := clampf((t - PEAK) / 0.9, 0.0, 1.0)
		foe.pos = Vector2(lerpf(x_hit, SIT_X, ease_out(k)), GROUND - sin(k * PI) * 70.0)
		foe.extra = [[SIT, smooth(0.3, 0.9, k)]]
		foe.hurt = pulse(0.0, 0.25, 0.4, k) * 0.6
		foe.rot = -sin(k * PI) * 0.25
		foe.lean = 0.0
		foe.aura = 0.0
		if k >= 1.0 and not foe.has("landed"):
			foe.landed = true
			shake = maxf(shake, 14.0)
			sfx("lib-impact-bass-2", 0.5)
			for i in 22:
				emit("smoke", Vector2(SIT_X + rng.randf_range(-120, 160), GROUND), Vector2(rng.randf_range(-200, 220), -rng.randf_range(20, 150)), 2.0, rng.randf_range(36, 80), Color(0.9, 0.86, 0.78, 0.42))


func _cam() -> Array:
	var c := Vector2(940, 600)
	var z := 1.0
	var k1 := smooth(0.9, 1.6, t) * (1.0 - smooth(2.05, 2.45, t))      # tụ khí: đẩy vào LHX
	c = c.lerp(hero.pos + Vector2(110, -230), k1)
	z = lerpf(z, 1.35, k1)
	var k2 := smooth(2.05, 2.6, t) * (1.0 - smooth(5.3, 5.6, t))       # hai người, cận vừa
	var punch := 0.0
	for b in BEATS:
		punch = maxf(punch, pulse(b, b + 0.05, 0.25, t))
	c = c.lerp(Vector2(870, 610), k2)
	z = lerpf(z, 1.18 + punch * 0.04, k2)
	var k3 := smooth(5.3, 5.7, t) * (1.0 - smooth(6.25, 7.4, t))       # đọc sơ hở: thấp, sát
	c = c.lerp(Vector2(960, 640), k3)
	z = lerpf(z, 1.45, k3)
	var k4 := smooth(7.4, 8.4, t)                                      # kết: thấy cả hai
	c = c.lerp(Vector2(990, 590), k4)
	return [c, z]


func _fx_ground(c: Node2D) -> void:
	# nét khắc gỗ + mảng tuyết mỏng
	for p in patches:
		flat_blob(c, p[0], p[1], 0.14, Color(0.92, 0.88, 0.8, 0.22))
	for s in strokes:
		var p: Vector2 = s[0]
		c.draw_line(p, p + Vector2(s[1], -2), Color(0.06, 0.035, 0.02, 0.55), s[2])
	c.draw_line(Vector2(-600, GROUND + 4), Vector2(W + 600, GROUND + 4), Color(0.85, 0.8, 0.7, 0.35), 6)
	# thông khắc gỗ bên vách trái: tầng lá lệch, mũ tuyết dày
	var tx := 150.0
	c.draw_colored_polygon(PackedVector2Array([Vector2(tx - 26, GROUND + 4), Vector2(tx - 10, 560), Vector2(tx - 30, 420), Vector2(tx + 6, 300), Vector2(tx + 12, 540), Vector2(tx + 28, GROUND + 4)]), Color("#24160c"))
	for i in 5:
		var y := 330.0 + i * 82.0
		var w := 110.0 + i * 34.0
		var sx := tx + (i % 2) * 30.0 - 10.0 + sin(rt * 1.3 + i) * 3.0
		var lean := 22.0 if i % 2 == 0 else -18.0
		c.draw_colored_polygon(PackedVector2Array([Vector2(sx - w, y + 46), Vector2(sx - w * 0.45, y + 8), Vector2(sx + lean, y - 34), Vector2(sx + w * 0.5, y + 4), Vector2(sx + w * 1.1, y + 40), Vector2(sx + w * 0.3, y + 56), Vector2(sx - w * 0.4, y + 52)]), Color("#132019"))
		c.draw_colored_polygon(PackedVector2Array([Vector2(sx - w * 0.85, y + 34), Vector2(sx - w * 0.4, y + 4), Vector2(sx + lean, y - 34), Vector2(sx + w * 0.45, y), Vector2(sx + w * 0.95, y + 30), Vector2(sx + w * 0.4, y + 14), Vector2(sx - w * 0.3, y + 20)]), Color(0.9, 0.86, 0.78))
	# quầng ngọc dưới chân khi tụ / đâm
	var gk := smooth(1.0, 1.6, t) * (1.0 - smooth(2.2, 2.6, t)) + smooth(5.5, 6.0, t) * (1.0 - smooth(6.6, 7.6, t))
	if gk > 0.01:
		flat_blob(c, Vector2(hero.pos.x, GROUND + 8), 300, 0.14, COL * Color(1, 1, 1, 0.3 * gk))


func _fx_back(c: Node2D) -> void:
	for fl in flakes:
		if not fl.front:
			c.draw_circle(fl.p, fl.s * 0.8, Color(0.85, 0.85, 0.82, 0.45))


func _draw_sword(c: Node2D, hp: Vector2, d: Vector2) -> void:
	var n := d.orthogonal()
	var tip := hp + d * 175.0
	var base := hp + d * 16.0
	c.draw_line(hp - d * 26.0, hp + d * 10.0, WOOD, 7.0)
	c.draw_line(hp + d * 12.0 + n * 14.0, hp + d * 12.0 - n * 14.0, Color("#6a4a22"), 6.0)
	c.draw_colored_polygon(PackedVector2Array([base + n * 4.0, tip - d * 12.0 + n * 2.0, tip, tip - d * 12.0 - n * 2.0, base - n * 4.0]), STEEL)
	c.draw_line(base, tip - d * 6.0, Color(0.6, 0.62, 0.6), 1.5)
	# tua đỏ
	var tas := hp - d * 30.0
	c.draw_line(tas, tas + Vector2(-16 + sin(rt * 9.0) * 6.0, 24), Color("#b8322c"), 4.0)


func _draw_saber(c: Node2D, hp: Vector2, d: Vector2) -> void:
	var n := d.orthogonal()
	var pts := PackedVector2Array()
	var back := PackedVector2Array()
	for i in 9:
		var k := i / 8.0
		var p := hp + d * (18.0 + 147.0 * k) + n * (sin(k * PI * 0.5) * 14.0)
		var w := lerpf(6.0, 13.0, k) * (1.0 - smoothstep(0.85, 1.0, k) * 0.9)
		pts.append(p + n * w)
		back.append(p - n * w * 0.5)
	back.reverse()
	var poly := pts.duplicate()
	poly.append_array(back)
	c.draw_line(hp - d * 22.0, hp + d * 12.0, Color("#1e1a1a"), 8.0)
	c.draw_colored_polygon(poly, Color(0.8, 0.76, 0.72))
	c.draw_polyline(pts, Color(0.55, 0.16, 0.1), 3.0)
	c.draw_circle(hp - d * 26.0, 7.0, Color("#b8322c"))


func _fx_norm(c: Node2D) -> void:
	# màn tối khi thời gian chậm (dấu sơ hở vẽ cộng đè lên)
	var s := _slow()
	if s > 0.01:
		c.draw_rect(Rect2(-800, -600, W + 1600, H + 1200), Color(0.03, 0.06, 0.05, 0.34 * s))
	_draw_sword(c, hero.hand, _wdir(hero, hsw_a))
	if saber.free:
		_draw_saber(c, saber.p, Vector2(cos(saber.a), sin(saber.a)))
	else:
		_draw_saber(c, foe.hand, _wdir(foe, fsw_a))
	for fl in flakes:
		if fl.front:
			c.draw_circle(fl.p, fl.s * 1.25, Color(0.95, 0.94, 0.9, 0.85))
	# vệt gió
	for i in 5:
		var y := 300.0 + i * 120.0
		var x := fmod(2600.0 - rt * 900.0 * (1.0 - 0.9 * s) - i * 470.0, 3000.0) - 500.0
		c.draw_line(Vector2(x, y), Vector2(x + 260, y + 50), Color(0.95, 0.92, 0.85, 0.12), 2.0)


func _fx_add(c: Node2D) -> void:
	# đao quang son: lưỡi liềm quét
	for sl in slashes:
		var age: float = t - sl[2]
		if age < 0.22:
			var k := age / 0.22
			var p: Vector2 = sl[0]
			var a0: float = -1.2 if sl[3] > 0 else -1.2
			crescent(c, p, 190.0, a0, lerpf(-1.2, 1.2, ease_out(k * 2.0)), sl[1] + (0.5 if sl[3] > 0 else -0.5) * (1.0 - k) * sl[3],
				FOE_COL * Color(1, 1, 1, 0.5 * (1.0 - k)), FOE_HOT * Color(1, 1, 1, 1.0 - k))
	# kiếm ý ngọc dọc lưỡi kiếm
	var d := _wdir(hero, hsw_a)
	var tip: Vector2 = hero.hand + d * 175.0
	var gl := smooth(1.2, 1.7, t) * (1.0 - smooth(2.1, 2.4, t)) * 0.6 + smooth(5.7, 6.0, t) * (1.0 - smooth(6.6, 7.4, t))
	if gl > 0.01:
		c.draw_line(hero.hand + d * 20.0, tip, HOT * Color(1, 1, 1, 0.5 * gl), 3.0)
		blob(c, tip, 40.0 * gl, COL * Color(1, 1, 1, 0.6 * gl))
	# dấu sơ hở: mờ lúc đọc từng đao, bừng sáng khi chậm
	var s := _slow()
	for i in marks.size():
		var m: Array = marks[i]
		var p: Vector2 = foe.pos + m[0] if not hit else foe.pos + m[0] * Vector2(1, 0.7)
		var age: float = t - m[1]
		var lit := pulse(m[1], m[1] + 0.1, 0.35, t) * 0.9 + 0.28
		if i < READ.size():
			lit = maxf(lit, smooth(READ[i], READ[i] + 0.08, t) * 1.2)
		if i == 2:
			lit = maxf(lit, smooth(READ[0], READ[0] + 0.1, t) * 0.8)
		lit *= 1.0 - smooth(PEAK + 0.05, PEAK + 0.4, t)
		if lit <= 0.01 or age < 0.0:
			continue
		blob(c, p, 34.0, AMBER * Color(1, 1, 1, 0.45 * lit))
		var r := 11.0
		c.draw_polyline(PackedVector2Array([p + Vector2(0, -r), p + Vector2(r, 0), p + Vector2(0, r), p + Vector2(-r, 0), p + Vector2(0, -r)]), AMBER_HOT * Color(1, 1, 1, minf(1.0, lit)), 3.0)
	# sơ hở được chọn: vòng ngắm + đường của nhát duy nhất
	if not hit and t > READ[2]:
		var op := _opening()
		var k := smooth(READ[2], READ[2] + 0.12, t)
		var rr := lerpf(80.0, 26.0, k)
		c.draw_arc(op, rr, rt * 2.0, rt * 2.0 + TAU * 0.8, 40, AMBER_HOT * Color(1, 1, 1, k), 3.0)
		c.draw_arc(op, rr + 12.0, -rt * 3.0, -rt * 3.0 + PI, 24, AMBER * Color(1, 1, 1, 0.6 * k), 2.0)
		var steps := 14
		for i in steps:
			var a := tip.lerp(op, float(i) / steps)
			var b := tip.lerp(op, (i + 0.5) / steps)
			c.draw_line(a, b, AMBER_HOT * Color(1, 1, 1, 0.55 * k), 2.0)
	# vệt nhát đâm (mảnh, mờ)
	if thrust_k > 0.05 and t < PEAK + 0.5:
		var fade := 1.0 - smooth(PEAK + 0.1, PEAK + 0.5, t)
		c.draw_line(tip - d * 520.0, tip, COL * Color(1, 1, 1, 0.18 * fade), 8.0)
		c.draw_line(tip - d * 380.0, tip, HOT * Color(1, 1, 1, 0.6 * fade), 2.0)
	if hit and t < PEAK + 0.35:
		blob(c, _opening(), 70.0 * (1.0 - smooth(PEAK, PEAK + 0.35, t)), AMBER * Color(1, 1, 1, 0.35))


func _fx_ui(c: Node2D) -> void:
	var s := _slow()
	if s > 0.01:
		var h := 92.0 * s
		c.draw_rect(Rect2(0, 0, W, h), Color(0.02, 0.015, 0.01))
		c.draw_rect(Rect2(0, H - h, W, h), Color(0.02, 0.015, 0.01))
