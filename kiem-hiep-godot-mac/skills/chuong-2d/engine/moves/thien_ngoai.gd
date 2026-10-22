extends "res://engine.gd"
# THIÊN NGOẠI PHI TIÊN (12.5 s): đêm trăng tròn, nóc Tử Cấm Thành (Quyết Chiến Tiền Hậu, hệ liệt Lục Tiểu Phụng).
# Thẻ chiêu:
#   người dùng   Diệp Cô Thành ra Thiên Ngoại Phi Tiên (foe); Tây Môn Xuy Tuyết đỡ và thắng (hero, đứng trái)
#   cơ chế       Diệp vọt lên trước vầng trăng, thành bóng nhỏ; hai nhát kiếm quang lưỡi liềm từ trời bổ xuống nóc ngói (2 nhịp),
#                Tây Môn không nhúc nhích, chỉ nghiêng lưỡi kiếm, ánh trăng dồn lên lưỡi. Rồi Diệp hóa vệt sao chổi trắng
#                lao từ trăng xuống, tách ba vệt ảo rồi gộp một. Tây Môn đâm một nhát ngược lên: hai đường kiếm thành chữ thập sáng.
#   cặp màu      kiếm lam lạnh (Tây Môn) vs bạch kim ánh trăng (Diệp)
#   bối cảnh     đêm xanh đen, trăng tròn lớn vàng nhạt, nóc ngói lưu ly, mái cong xa
#   đỉnh         slowmo, chữ thập sáng giữa không trung; kiếm Diệp tuột tay trượt dọc mái ngói kéo ngói rơi;
#                Diệp đáp xuống nóc, quỳ một gối, cúi đầu (không máu)

const COL := Color(0.5, 0.95, 1.75)       # kiếm lam lạnh
const HOT := Color(1.4, 2.0, 2.7)
const FOE_COL := Color(1.75, 1.5, 0.75)   # bạch kim ánh trăng
const FOE_HOT := Color(2.6, 2.3, 1.5)
const STEEL := Color(0.88, 0.9, 0.94)
const TILE := Color("#6b5a22")
const TILE_DK := Color("#2e2610")
const MOON := Vector2(1180, 250)
const MOON_R := 215.0
const HX := 600.0
const FX := 1330.0
const BEATS := [3.3, 4.25]                # hai nhát kiếm quang từ trời
const DIVE := 5.15                        # bắt đầu lao xuống
const PEAK := 6.0
const M := Vector2(880, 600)             # điểm gặp nhau
const LAND := Vector2(1360, 840)

const TUCK := {"uaF": -60, "faF": -80, "uaB": 40, "faB": -70, "torso": 20, "head": 10, "thF": -90, "shF": 110, "thB": -60, "shB": 100, "all": [0, 0, 0]}
const SKYPOSE := {"uaF": -150, "faF": -20, "uaB": 60, "faB": -30, "torso": -6, "head": -10, "thF": -10, "shF": 30, "thB": 20, "shB": 40, "all": [0, 0, 0]}
const DIVEPOSE := {"uaF": -96, "faF": -4, "uaB": 70, "faB": -10, "torso": 10, "head": -4, "thF": 20, "shF": 20, "thB": 34, "shB": 30, "all": [0, 0, 0]}
const THRUST := {"uaF": -120, "faF": -6, "uaB": 50, "faB": -40, "torso": -8, "head": -12, "thF": -40, "shF": 36, "thB": 40, "shB": -10, "all": [0, 0, 22]}
const KNEEL1 := {"uaF": -10, "faF": -40, "uaB": 20, "faB": -30, "torso": 24, "head": 22, "thF": -84, "shF": 84, "thB": 30, "shB": 62, "all": [0, 0, 74]}

var hit := false
var beat_i := 0
var stars2: Array = []
var tiles: Array = []        # ngói văng: {p, v, a, w}
var qi: Array = []           # kiếm quang lưỡi liềm: [t0, từ, tới]
var csword := {"free": false, "p": Vector2.ZERO, "v": Vector2.ZERO, "a": 0.0, "w": 0.0}
var hsw_a := 0.0
var fsw_a := 0.0
var land_from := Vector2.ZERO


func _setup() -> void:
	sky_cols = [Color("#03060f"), Color("#0b1630"), Color("#16264a")]
	moon_on = false
	n_stars = 120
	far_col = Color("#0a1226")
	near_col = Color(0, 0, 0, 0)
	mist_col = Color(0.5, 0.6, 0.9, 0.12)
	ground_cols = [TILE, TILE_DK, Color("#c9a64a")]
	slowmo = [5.86, 6.5, 0.3]
	title = "THIÊN NGOẠI PHI TIÊN"
	subtitle = "Diệp Cô Thành · Tây Môn Xuy Tuyết"
	title_at = 8.4
	title_col = FOE_HOT
	set_char(hero, "tay-mon-xuy-tuyet")
	set_char(foe, "diep-co-thanh")
	hero.pos = Vector2(HX, GROUND)
	foe.pos = Vector2(FX, GROUND)
	hero.base = "rest"
	foe.base = "rest"
	hero.col = COL
	foe.col = FOE_COL
	hero.node.hand_form = {"F": "nam", "B": "tha"}
	foe.node.hand_form = {"F": "nam", "B": "chi"}
	cue(1.0, "lib-riser", 0.7)
	cue(2.2, "lib-whoosh", 0.75)
	for b in BEATS:
		cue(b - 0.1, "lib-whoosh-short", 0.6)
	cue(DIVE, "lib-riser", 0.5)
	cue(5.6, "lib-whoosh-cinematic", 0.9)
	cue(2.9, "lib-sparkle", 0.35)
	for i in 30:
		tiles.append(null)
	tiles.clear()


func _wdir(f: Dictionary, a: float) -> Vector2:
	return Vector2(cos(a) * f.face, sin(a))


# đường lao của Diệp: từ trước trăng xuống điểm gặp (cong nhẹ)
func _dive_pos(k: float) -> Vector2:
	var a := MOON + Vector2(30, 40)
	var c := Vector2(1150, 520)
	return a.lerp(c, k).lerp(c.lerp(M + Vector2(70, -40), k), k)


func _story(dt: float) -> void:
	# ---- Tây Môn: gần như bất động; ánh trăng dồn lên lưỡi kiếm
	var g := smooth(1.0, 1.7, t) * (1.0 - smooth(2.2, 2.5, t))
	var tilt := 0.0
	for b in BEATS:
		tilt = maxf(tilt, pulse(b + 0.15, b + 0.35, 0.3, t))
	var th := smooth(5.9, PEAK, t) * (1.0 - smooth(7.4, 8.3, t))
	var ready := smooth(0.3, 1.0, t)
	hero.gather = g * 0.4
	hero.extra = [["guard", ready * 0.45 * (1.0 - th)], [THRUST, th]]
	hero.aura = g * 0.5 + smooth(5.3, 5.9, t) * 0.5 * (1.0 - smooth(6.6, 7.6, t))
	hero.expr = "ngai" if t > 8.2 else ("quyet-tam" if t > 1.0 else "binh")
	hsw_a = lerpf(1.1, -0.35, ready) + tilt * -0.35
	if th > 0.001 and not hit:
		var aim: float = atan2(M.y - hero.hand.y, M.x - hero.hand.x)
		hsw_a = lerpf(hsw_a, aim, th)
	elif hit:
		hsw_a = lerpf(-0.75, 1.0, smooth(7.4, 8.3, t))
	hero.pos.x = HX + th * 70.0

	# ---- Diệp Cô Thành
	if not hit:
		var crouch := pulse(1.7, 2.15, 0.15, t)
		var up := smooth(2.15, 2.95, t)
		var sky := smooth(2.15, 2.6, t)
		var dk := smooth(DIVE + 0.25, PEAK, t)
		var p0 := Vector2(FX, GROUND)
		var p1 := MOON + Vector2(30, 40)
		var p := p0.lerp(p1, ease_out(up))
		p.y -= sin(up * PI) * 60.0
		p += Vector2(sin(rt * 1.5) * 8.0, sin(rt * 2.1) * 10.0) * smooth(2.9, 3.2, t)
		if t > DIVE:
			p = p.lerp(p1 + Vector2(20, -70), smooth(DIVE, DIVE + 0.25, t) * (1.0 - dk))
			if dk > 0.0:
				p = _dive_pos(dk)
		foe.pos = p
		var slash := 0.0
		for b in BEATS:
			slash = maxf(slash, pulse(b - 0.12, b, 0.2, t))
		foe.extra = [["windup", crouch], [TUCK, sky * (1.0 - smooth(2.7, 3.0, t))], [SKYPOSE, smooth(2.7, 3.0, t) * (1.0 - slash) * (1.0 - dk)], ["slash", slash * (1.0 - dk)], [DIVEPOSE, dk]]
		foe.crouch = crouch * 0.6
		foe.scale = lerpf(1.0, 0.62, smooth(2.3, 2.95, t)) + dk * 0.38
		foe.rot = -dk * 0.55
		foe.aura = smooth(2.9, 3.3, t) * 0.4 + smooth(DIVE, PEAK, t) * 0.7
		foe.expr = "quyet-tam" if t > 1.5 else "binh"
		fsw_a = lerpf(1.2, -1.3, smooth(2.6, 3.0, t))
		for b in BEATS:
			fsw_a = lerpf(fsw_a, 0.9, pulse(b - 0.12, b, 0.2, t))
		if dk > 0.0:
			fsw_a = lerpf(fsw_a, atan2(M.y - foe.pos.y, -(M.x - foe.pos.x)), smooth(0.0, 0.3, dk))
	pose(hero, 0.0)
	pose(foe, 0.0)

	if g > 0.05:
		orbit(hero, rng.randf_range(90, 220), rng.randf_range(1.8, 3.0), 220, rng.randf_range(1.5, 3.5), HOT * Color(1, 1, 1, 0.7), 2.4)

	# ---- 2 nhịp: kiếm quang lưỡi liềm từ trời bổ xuống nóc ngói cạnh Tây Môn
	for i in BEATS.size():
		if qi.size() <= i and t >= BEATS[i]:
			qi.append([t, foe.hand, Vector2(HX + (180.0 if i == 0 else -150.0), GROUND - 10)])
	if beat_i < BEATS.size() and t >= BEATS[beat_i] + 0.3:
		var at: Vector2 = qi[beat_i][2]
		add_ring(at, 200, FOE_HOT, 7, 0.35, 0.3)
		burst(at, 30, 300, 900, FOE_HOT, Color(1.6, 1.5, 1.2), 1300.0, 1.5, -PI * 0.95, -PI * 0.05)
		_kick_tiles(at, 7)
		shake = maxf(shake, 12.0 + beat_i * 2.0)
		sfx("lib-impact-bass-2", 0.65)
		beat_i += 1

	# ---- đỉnh: chữ thập sáng
	if t >= PEAK and not hit:
		hit = true
		land_from = foe.pos
		foe.expr = "soc"
		flash = 0.6
		flash_col = Color(0.92, 0.95, 1.0)
		shake = 32.0
		add_ring(M, 640, HOT, 16, 0.7)
		add_ring(M, 360, FOE_HOT, 9, 0.5, 1.0, 0.06)
		add_ring(Vector2(M.x, GROUND), 760, COL, 8, 0.85, 0.18)
		burst(M, 130, 300, 1500, HOT, FOE_HOT, 600.0, 1.1)
		sfx("lib-impact-bass-1", 1.0)
		sfx("lib-impact-bass-2", 1.0)
		csword.free = true
		csword.p = foe.hand
		csword.a = fsw_a
		csword.v = Vector2(380, -900)
		csword.w = 13.0
	if csword.free:
		csword.v.y += 1700.0 * dt
		csword.p += csword.v * dt
		csword.a += csword.w * dt
		var roof_y := _roof_y(csword.p.x) - 10.0
		if csword.p.y > roof_y and csword.v.y > 0:
			# chạm mái: trượt dọc dốc ngói, kéo ngói rơi
			csword.p.y = roof_y
			csword.v = Vector2(maxf(csword.v.x, 260.0), 60.0)
			csword.w = 0.0
			csword.a = 0.42
			if not csword.has("slid"):
				csword.slid = true
				sfx("lib-chime", 0.45)
			if rng.randf() < 0.35:
				_kick_tiles(Vector2(csword.p.x, roof_y), 1)
	# ---- hậu quả: Diệp đáp nóc, quỳ một gối
	if hit:
		var k := clampf((t - PEAK) / 0.9, 0.0, 1.0)
		foe.pos = land_from.lerp(LAND, ease_out(k)) + Vector2(0, -sin(k * PI) * 120.0)
		foe.scale = 1.0
		foe.rot = lerpf(-0.55, 0.0, smooth(0.0, 0.7, k)) + sin(k * PI) * 0.4
		foe.extra = [[DIVEPOSE, 1.0 - smooth(0.2, 0.8, k)], [KNEEL1, smooth(0.5, 1.0, k)]]
		foe.aura = 0.0
		foe.node.hand_form = {"F": "tha", "B": "tha"}
		foe.expr = "ko" if k > 0.3 else "soc"
		if k >= 1.0 and not foe.has("landed"):
			foe.landed = true
			shake = maxf(shake, 14.0)
			sfx("lib-impact-bass-2", 0.5)
			_kick_tiles(LAND, 6)
			for i in 18:
				emit("smoke", Vector2(LAND.x + rng.randf_range(-120, 140), GROUND), Vector2(rng.randf_range(-200, 220), -rng.randf_range(20, 130)), 1.8, rng.randf_range(30, 70), Color(0.55, 0.6, 0.75, 0.35))
	for tl in tiles:
		tl.v.y += 1500.0 * dt
		tl.p += tl.v * dt
		tl.a += tl.w * dt


func _roof_y(x: float) -> float:
	# nóc phẳng ở giữa, mái dốc xuống hai bên ngoài khung
	return GROUND + maxf(0.0, x - 1700.0) * 0.55 + maxf(0.0, 150.0 - x) * 0.55


func _kick_tiles(at: Vector2, n: int) -> void:
	for i in n:
		tiles.append({"p": at + Vector2(rng.randf_range(-40, 40), -6), "v": Vector2(rng.randf_range(-300, 300), -rng.randf_range(300, 700)), "a": rng.randf() * TAU, "w": rng.randf_range(-12, 12)})


func _slow() -> float:
	return smooth(5.84, 5.9, t) * (1.0 - smooth(6.15, 6.5, t))


func _cam() -> Array:
	var c := Vector2(960, 560)
	var z := 1.0
	var k1 := smooth(0.9, 1.7, t) * (1.0 - smooth(2.1, 2.4, t))       # tụ: ánh trăng trên lưỡi kiếm Tây Môn
	c = c.lerp(hero.pos + Vector2(110, -230), k1)
	z = lerpf(z, 1.38, k1)
	var k2 := smooth(2.2, 2.9, t) * (1.0 - smooth(5.0, 5.4, t))       # ngửa lên: trăng + bóng Diệp + Tây Môn dưới
	c = c.lerp(Vector2(980, 470), k2)
	z = lerpf(z, 0.94, k2)
	var k3 := smooth(5.2, 5.7, t) * (1.0 - smooth(6.5, 7.5, t))       # điểm gặp
	c = c.lerp(M + Vector2(20, 20), k3)
	z = lerpf(z, 1.3, k3)
	var k4 := smooth(7.4, 8.4, t)
	c = c.lerp(Vector2(990, 590), k4)
	return [c, z]


func _fx_ground(c: Node2D) -> void:
	# trăng lớn (trong lớp thế giới để máy quay ngửa lên thấy rõ)
	blob(c, MOON, MOON_R * 2.4, Color(1.0, 0.95, 0.7, 0.16))
	c.draw_circle(MOON, MOON_R, Color(1.0, 0.96, 0.78))
	c.draw_circle(MOON + Vector2(-60, -40), 34, Color(0.94, 0.9, 0.72))
	c.draw_circle(MOON + Vector2(70, 60), 22, Color(0.94, 0.9, 0.72))
	c.draw_circle(MOON + Vector2(30, -90), 16, Color(0.94, 0.9, 0.72))
	# mái cong xa: bóng xanh đen, đầu đao vểnh
	for i in 4:
		var bx := -200.0 + i * 640.0
		var by := 640.0 + (i % 2) * 40.0
		var pts := PackedVector2Array([Vector2(bx - 80, by + 20), Vector2(bx, by - 30), Vector2(bx + 120, by - 70), Vector2(bx + 400, by - 70), Vector2(bx + 520, by - 30), Vector2(bx + 600, by + 20), Vector2(bx + 600, GROUND), Vector2(bx - 80, GROUND)])
		c.draw_colored_polygon(pts, Color("#0e1a34"))
		c.draw_line(Vector2(bx + 120, by - 70), Vector2(bx + 400, by - 70), Color(0.6, 0.6, 0.45, 0.35), 3.0)
	# nóc ngói: bờ nóc + hàng ngói ống, dốc hai bên
	var roof := PackedVector2Array([Vector2(-600, _roof_y(-600)), Vector2(150, GROUND), Vector2(1700, GROUND), Vector2(W + 600, _roof_y(W + 600)), Vector2(W + 600, H + 400), Vector2(-600, H + 400)])
	c.draw_colored_polygon(roof, TILE)
	for i in 40:
		var x := -400.0 + i * 70.0
		c.draw_line(Vector2(x, GROUND + 20), Vector2(x - 40, H + 200), TILE_DK, 8.0)
		c.draw_line(Vector2(x + 6, GROUND + 20), Vector2(x - 34, H + 200), Color(0.86, 0.72, 0.32, 0.35), 2.0)
	c.draw_rect(Rect2(-600, GROUND - 12, W + 1200, 26), Color("#8a7430"))
	c.draw_line(Vector2(-600, GROUND - 12), Vector2(W + 600, GROUND - 12), Color(1.0, 0.92, 0.6, 0.6), 3.0)
	# thú nóc hai đầu
	for x in [120.0, 1760.0]:
		var s := -1.0 if x < 960 else 1.0
		c.draw_colored_polygon(PackedVector2Array([Vector2(x - 30 * s, GROUND - 12), Vector2(x - 10 * s, GROUND - 120), Vector2(x + 40 * s, GROUND - 150), Vector2(x + 30 * s, GROUND - 90), Vector2(x + 50 * s, GROUND - 12)]), Color("#3a3014"))


func _draw_sword(c: Node2D, hp: Vector2, d: Vector2, len: float, guard: Color) -> void:
	var n := d.orthogonal()
	var tip := hp + d * len
	var base := hp + d * 16.0
	c.draw_line(hp - d * 24.0, hp + d * 10.0, Color("#1a1a20"), 7.0)
	c.draw_line(hp + d * 12.0 + n * 13.0, hp + d * 12.0 - n * 13.0, guard, 6.0)
	c.draw_colored_polygon(PackedVector2Array([base + n * 4.0, tip - d * 12.0 + n * 2.0, tip, tip - d * 12.0 - n * 2.0, base - n * 4.0]), STEEL)


func _fx_norm(c: Node2D) -> void:
	var s := _slow()
	if s > 0.01:
		c.draw_rect(Rect2(-800, -600, W + 1600, H + 1200), Color(0.01, 0.02, 0.06, 0.38 * s))
	_draw_sword(c, hero.hand, _wdir(hero, hsw_a), 180.0, Color("#2a2e3a"))
	if csword.free:
		_draw_sword(c, csword.p, Vector2(cos(csword.a), sin(csword.a)), 170.0 * 1.0, Color("#c9a23a"))
	else:
		_draw_sword(c, foe.hand, _wdir(foe, fsw_a), 170.0 * foe.scale, Color("#c9a23a"))
	for tl in tiles:
		c.draw_set_transform(tl.p, tl.a, Vector2.ONE)
		c.draw_rect(Rect2(-14, -6, 28, 12), TILE)
		c.draw_rect(Rect2(-14, -6, 28, 4), Color(0.85, 0.72, 0.32))
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _fx_add(c: Node2D) -> void:
	# ánh trăng trên lưỡi kiếm Tây Môn
	var d := _wdir(hero, hsw_a)
	var tip: Vector2 = hero.hand + d * 180.0
	var gl := smooth(1.1, 1.7, t) * (1.0 - smooth(2.2, 2.6, t)) * 0.8 + smooth(5.4, 5.9, t) * (1.0 - smooth(6.6, 7.4, t))
	for b in BEATS:
		gl = maxf(gl, pulse(b + 0.15, b + 0.35, 0.3, t) * 0.7)
	if gl > 0.01:
		c.draw_line(hero.hand + d * 20.0, tip, HOT * Color(1, 1, 1, 0.55 * gl), 3.0)
		blob(c, tip, 46.0 * gl, COL * Color(1, 1, 1, 0.55 * gl))
		var sp: Vector2 = hero.hand + d * (40.0 + fmod(rt * 260.0, 140.0))
		blob(c, sp, 22.0 * gl, HOT * Color(1, 1, 1, 0.5 * gl))
	# kiếm quang lưỡi liềm từ trời
	for q in qi:
		var age: float = t - q[0]
		if age < 0.45:
			var k := clampf(age / 0.3, 0.0, 1.0)
			var a: Vector2 = q[1]
			var b: Vector2 = q[2]
			var p := a.lerp(b, ease_out(k))
			var dir := (b - a).normalized()
			var fade := 1.0 - smooth(0.3, 0.45, age)
			crescent(c, p, 120.0, -1.1, 1.1, dir.angle(), FOE_COL * Color(1, 1, 1, 0.45 * fade), FOE_HOT * Color(1, 1, 1, fade))
			c.draw_line(a.lerp(p, 0.4), p, FOE_COL * Color(1, 1, 1, 0.15 * fade), 6.0)
	# sao chổi: ba vệt ảo hội tụ về một
	if not hit and t > DIVE + 0.2:
		var dk := smooth(DIVE + 0.25, PEAK, t)
		var head: Vector2 = foe.pos + Vector2(0, -160) * foe.scale
		var back := (MOON - M).normalized()
		var perp := back.orthogonal()
		for i in 3:
			var off := float(i - 1) * 150.0 * (1.0 - smooth(0.55, 1.0, dk))
			var hp := head + perp * off
			var tail := hp + back * (260.0 + 380.0 * dk)
			var a := (0.5 if i == 1 else 0.28) * smooth(DIVE + 0.2, DIVE + 0.45, t)
			c.draw_colored_polygon(PackedVector2Array([hp + perp * 26.0, tail, hp - perp * 26.0]), FOE_COL * Color(1, 1, 1, 0.22 * a))
			c.draw_line(hp, hp + back * (180.0 + 200.0 * dk), FOE_HOT * Color(1, 1, 1, 0.5 * a), 3.0)
			blob(c, hp, 60.0, FOE_COL * Color(1, 1, 1, 0.4 * a))
	# chữ thập sáng
	if t > PEAK - 0.02 and t < PEAK + 0.9:
		var k := 1.0 - smooth(PEAK + 0.15, PEAK + 0.9, t)
		var L := 520.0 * smooth(PEAK - 0.02, PEAK + 0.08, t)
		var hd: Vector2 = (M - hero.hand).normalized()
		var fd: Vector2 = hd.orthogonal()
		c.draw_line(M - hd * L, M + hd * L, COL * Color(1, 1, 1, 0.18 * k), 10.0)
		c.draw_line(M - hd * L, M + hd * L, HOT * Color(1, 1, 1, 0.8 * k), 2.5)
		c.draw_line(M - fd * L, M + fd * L, FOE_COL * Color(1, 1, 1, 0.18 * k), 10.0)
		c.draw_line(M - fd * L, M + fd * L, FOE_HOT * Color(1, 1, 1, 0.8 * k), 2.5)
		blob(c, M, 120.0 * k, Color(1.4, 1.5, 1.7, 0.3 * k))
	# vệt sáng của kiếm đang trượt
	if csword.has("slid") and csword.p.x < W + 200:
		blob(c, csword.p + Vector2(60, 0), 40.0, FOE_COL * Color(1, 1, 1, 0.25))


func _fx_ui(c: Node2D) -> void:
	# khựng: hai vạch sáng chéo mảnh ở góc (khác letterbox)
	var s := _slow()
	if s > 0.01:
		c.draw_rect(Rect2(0, 0, W, H), Color(0.02, 0.04, 0.1, 0.12 * s), false, 40.0)
