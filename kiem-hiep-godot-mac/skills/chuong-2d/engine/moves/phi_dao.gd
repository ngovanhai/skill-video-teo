extends "res://engine.gd"
# TIỂU LÝ PHI ĐAO (12.5 s): gian phòng gỗ tối, đèn dầu cam, cửa song gỗ dán giấy.
# Thẻ chiêu:
#   người dùng   Lý Tầm Hoan (Đa Tình Kiếm Khách Vô Tình Kiếm), hạng 3 Binh Khí Phổ
#   đối thủ      Thượng Quan Kim Hồng, Long Phượng Song Hoàn, hạng 2
#   cơ chế       Thượng Quan tung đôi vòng vàng thành bánh xe 3 nhịp; Lý chỉ nghiêng người, vòng cày vệt vàng xuống sàn rồi quay về.
#                Đỉnh: mọi thứ khựng lại, một chấm lóe nhỏ ở tay Lý — KHÔNG thấy đao — rồi chỉ thấy kết quả.
#   cặp màu      lóe bạc lạnh (tay Lý) vs vàng kim (song hoàn)
#   bối cảnh     phòng gỗ tối, đèn dầu cam, bụi lơ lửng trong ánh đèn
#   đỉnh         slowmo, chấm bạc ở tay Lý -> chấm bạc ở cổ áo đối thủ; đôi vòng rơi lăn, đối thủ cứng người đổ ngửa chậm (không máu)

const COL := Color(1.0, 1.15, 1.45)       # lóe bạc
const HOT := Color(2.0, 2.2, 2.6)
const FOE_COL := Color(1.7, 1.15, 0.25)   # vàng kim song hoàn
const FOE_HOT := Color(2.4, 1.9, 0.8)
const GOLD := Color(0.9, 0.68, 0.2)
const GOLD_DK := Color(0.45, 0.3, 0.06)
const LAMP := Color(1.9, 1.05, 0.35)
const BEATS := [2.45, 3.45, 4.45]          # 3 nhịp tung vòng
const FLICK := 5.93                        # tay Lý khẽ động
const PEAK := 6.0                          # kết quả hiện ra
const HX := 600.0
const FX := 1270.0
const LEANB := {"torso": -16, "head": -10, "uaF": 14, "faF": -8, "uaB": -20, "faB": -10, "thF": -8, "shF": 8, "thB": 10, "shB": -6}
const STIFF := {"uaF": 4, "faF": 0, "uaB": -4, "faB": 0, "torso": 0, "head": -6, "thF": 0, "shF": 0, "thB": 0, "shB": 0}
const OVER := {"uaF": -170, "faF": -10, "uaB": 170, "faB": 10, "torso": -4, "head": -8}

var hit := false
var beat_i := 0
var motes: Array = []
var gouges: Array = []      # [điểm đầu, điểm cuối, t sinh]
var drop: Array = []        # vòng rơi: {p, v, a, w, rest}
var planks: Array = []
var fall_k := 0.0


func _setup() -> void:
	sky_cols = [Color("#120a06"), Color("#1e120a"), Color("#2a180c")]
	moon_on = false
	n_stars = 0
	far_col = Color(0, 0, 0, 0)
	near_col = Color(0, 0, 0, 0)
	mist_col = Color(0.9, 0.6, 0.3, 0.0)
	ground_cols = [Color("#4a2e18"), Color("#1a0e06"), Color("#6a4424")]
	slowmo = [5.86, 6.5, 0.3]
	title = "TIỂU LÝ PHI ĐAO"
	subtitle = "LỆ BẤT HƯ PHÁT"
	title_at = 8.3
	title_col = HOT
	set_char(hero, "ly-tam-hoan")
	set_char(foe, "thuong-quan-kim-hong")
	hero.pos = Vector2(HX, GROUND)
	foe.pos = Vector2(FX, GROUND)
	hero.base = "rest"
	foe.base = "stance"
	hero.col = COL
	foe.col = FOE_COL
	hero.node.hand_form = {"F": "tha", "B": "tha"}
	foe.node.hand_form = {"F": "nam", "B": "nam"}
	cue(1.0, "lib-riser", 0.65)
	for b in BEATS:
		cue(b, "lib-whoosh-short", 0.7)
	cue(5.3, "lib-whoosh", 0.6)
	cue(5.85, "lib-whoosh-cinematic", 0.85)
	cue(FLICK + 0.02, "lib-chime", 0.4)
	for i in 70:
		motes.append([Vector2(rng.randf_range(120, 1100), rng.randf_range(260, 820)), rng.randf_range(1.2, 3.0), rng.randf() * TAU])
	for i in 18:
		planks.append([rng.randf_range(-500, 2400), rng.randf_range(60, 320)])


# vị trí vòng thứ i của nhịp b: đi -> lướt sát đầu Lý -> cắm sàn sau lưng -> cày -> bay về tay
func _ring_path(b: float, hand: Vector2) -> Array:
	var u := t - b
	var head: Vector2 = Vector2(HX + 40, GROUND - 330)
	var dig_a := Vector2(HX - 120, GROUND - 4)
	var dig_b := Vector2(HX - 330, GROUND - 4)
	if u < 0.0 or u > 1.05:
		return []
	if u < 0.32:
		var k := u / 0.32
		var c := hand.lerp(head, 0.5) + Vector2(0, -160)
		return [hand.lerp(c, k).lerp(c.lerp(head, k), k), 1.0]
	if u < 0.42:
		return [head.lerp(dig_a, (u - 0.32) / 0.1), 1.0]
	if u < 0.6:
		return [dig_a.lerp(dig_b, ease_out((u - 0.42) / 0.18)), 0.6]
	var k2 := smooth(0.6, 1.05, u)
	var c2 := dig_b.lerp(hand, 0.5) + Vector2(0, -420)
	return [dig_b.lerp(c2, k2).lerp(c2.lerp(hand, k2), k2), 1.0]


func _story(dt: float) -> void:
	var s := _still()
	for m in motes:
		m[0] += Vector2(sin(rt * 0.7 + m[2]) * 6.0, -4.0) * dt * (1.0 - s)
		if m[0].y < 240:
			m[0].y = 820
	# ---- Lý Tầm Hoan: gần như không động
	var g := smooth(1.0, 1.7, t) * (1.0 - smooth(2.2, 2.5, t))
	var dodge := 0.0
	for b in BEATS:
		dodge = maxf(dodge, pulse(b + 0.12, b + 0.38, 0.22, t))
	var flick := pulse(FLICK - 0.05, FLICK + 0.03, 0.5, t) * (1.0 - smooth(7.5, 8.4, t))
	hero.gather = g * 0.35
	hero.extra = [[LEANB, dodge], ["point", flick * 0.55]]
	hero.lean = -dodge * 0.15
	hero.aura = g * 0.35 + smooth(5.6, 5.9, t) * 0.25 * (1.0 - smooth(6.6, 7.4, t))
	hero.expr = "ngai" if t > 8.0 else ("quyet-tam" if t > 1.0 else "binh")
	if flick > 0.3:
		hero.node.hand_form = {"F": "chi", "B": "tha"}
	elif t > 7.5:
		hero.node.hand_form = {"F": "tha", "B": "tha"}
	# ---- Thượng Quan Kim Hồng
	if not hit:
		var thr := 0.0
		for b in BEATS:
			thr = maxf(thr, pulse(b - 0.15, b + 0.02, 0.25, t))
		var big := smooth(5.15, 5.75, t)
		foe.extra = [["windup", thr * (1.0 - big)], [OVER, big]]
		foe.aura = big * 0.85 + thr * 0.25
		foe.expr = "soc" if (t > 4.6 and t < 5.1) else ("gian" if t > 0.0 else "binh")
		foe.pos.x = FX + smooth(4.6, 5.0, t) * 30.0 - smooth(5.0, 5.6, t) * 60.0
	pose(hero, 0.0)
	pose(foe, 0.0)

	if g > 0.05:
		orbit(hero, rng.randf_range(90, 200), rng.randf_range(1.6, 2.6), 200, rng.randf_range(1.5, 3.0), COL * Color(1, 1, 1, 0.6), 2.4)

	# ---- 3 nhịp: vòng cắm sàn sau lưng Lý -> vệt vàng + tia lửa
	if beat_i < BEATS.size() and t >= BEATS[beat_i] + 0.42:
		var at := Vector2(HX - 120, GROUND - 6)
		gouges.append([at, Vector2(HX - 330, GROUND - 4), t])
		add_ring(at, 170, FOE_HOT, 6, 0.35, 0.3)
		burst(at, 34, 300, 950, FOE_HOT, Color(1.8, 1.4, 0.7), 1400.0, 1.6, -PI * 0.95, -PI * 0.05)
		shake = maxf(shake, 11.0 + beat_i)
		sfx("lib-impact-bass-2", 0.6)
		beat_i += 1

	# ---- đỉnh: kết quả
	if t >= PEAK and not hit:
		hit = true
		foe.expr = "ko"
		flash = 0.45
		flash_col = Color(0.85, 0.9, 1.0)
		shake = 24.0
		var at := _throat()
		add_ring(at, 120, HOT, 4, 0.35)
		add_ring(at, 520, COL, 10, 0.7, 1.0, 0.05)
		add_ring(Vector2(foe.pos.x, GROUND), 640, FOE_COL, 6, 0.8, 0.18)
		burst(at, 70, 200, 900, HOT, COL, 300.0, 2.0)
		burst(foe.pos + Vector2(0, -470), 40, 300, 1100, FOE_HOT, FOE_COL, 900.0, 1.4, -PI, 0.0)
		sfx("lib-impact-bass-1", 1.0)
		sfx("lib-impact-bass-2", 1.0)
		for side in ["F", "B"]:
			var hp: Vector2 = foe["hand" + side]
			drop.append({"p": hp, "v": Vector2(rng.randf_range(-160, 60) if side == "F" else rng.randf_range(80, 240), -rng.randf_range(80, 220)), "a": 0.0, "w": rng.randf_range(-6, 6), "rest": false, "bounced": 0})
	if hit:
		for d in drop:
			if d.rest:
				continue
			d.v.y += 1800.0 * dt
			d.p += d.v * dt
			d.a += d.w * dt
			if d.p.y > GROUND - 40 and d.v.y > 0:
				d.p.y = GROUND - 40
				d.bounced += 1
				d.v.y = -d.v.y * 0.35
				d.v.x *= 0.85
				if d.bounced == 1:
					sfx("lib-chime", 0.35)
					for i in 6:
						emit("smoke", Vector2(d.p.x, GROUND), Vector2(rng.randf_range(-90, 90), -rng.randf_range(10, 60)), 1.2, rng.randf_range(16, 30), Color(0.5, 0.36, 0.22, 0.4))
				if absf(d.v.y) < 60.0:
					d.v.y = 0.0
					d.w = d.v.x / 40.0
					d.v.x *= 0.96
					if absf(d.v.x) < 8.0:
						d.rest = true
		# cứng người, đứng thêm một nhịp, rồi đổ ngửa chậm
		fall_k = smooth(PEAK + 0.55, PEAK + 1.55, t)
		foe.extra = [[STIFF, 1.0]]
		foe.aura = 0.0
		foe.lean = 0.0
		foe.rot = pow(fall_k, 2.2) * PI * 0.5
		foe.hurt = 0.0
		if fall_k >= 1.0 and not foe.has("landed"):
			foe.landed = true
			shake = maxf(shake, 14.0)
			sfx("lib-impact-bass-2", 0.5)
			for i in 22:
				emit("smoke", Vector2(foe.pos.x + rng.randf_range(0, 380), GROUND), Vector2(rng.randf_range(-160, 220), -rng.randf_range(20, 120)), 1.8, rng.randf_range(30, 70), Color(0.45, 0.32, 0.2, 0.45))


func _throat() -> Vector2:
	return foe.head + Vector2(0, 92)


func _still() -> float:
	return smooth(5.84, 5.88, t) * (1.0 - smooth(6.15, 6.5, t))


func _cam() -> Array:
	var c := Vector2(960, 600)
	var z := 1.0
	var k1 := smooth(0.9, 1.7, t) * (1.0 - smooth(2.1, 2.45, t))       # tụ khí: đẩy vào Lý
	c = c.lerp(Vector2(HX + 80, 560), k1)
	z = lerpf(z, 1.36, k1)
	var k2 := smooth(2.1, 2.5, t) * (1.0 - smooth(5.0, 5.4, t))        # hai người, cận vừa, nghiêng về phía Lý
	c = c.lerp(Vector2(860, 610), k2)
	z = lerpf(z, 1.12, k2)
	var k3 := smooth(5.0, 5.5, t) * (1.0 - smooth(5.84, 5.88, t))      # Thượng Quan giơ đôi vòng
	c = c.lerp(Vector2(1180, 520), k3)
	z = lerpf(z, 1.25, k3)
	var k4 := smooth(5.84, 5.88, t) * (1.0 - smooth(5.955, 5.975, t))    # cắt sát tay Lý
	c = c.lerp(hero.hand + Vector2(30, -40), k4)
	z = lerpf(z, 1.9, k4)
	var k5 := smooth(5.955, 5.975, t) * (1.0 - smooth(6.5, 7.6, t))      # cắt sát cổ đối thủ
	c = c.lerp(_throat() + Vector2(-40, 40), k5)
	z = lerpf(z, 1.7, k5)
	var k6 := smooth(7.4, 8.4, t)                                      # kết: thấy cả hai
	c = c.lerp(Vector2(1000, 600), k6)
	return [c, z]


# ---------------------------------------------------------------- phòng gỗ
func _fx_ground(c: Node2D) -> void:
	# vách gỗ sau (phủ lên trời)
	c.draw_rect(Rect2(-600, -500, W + 1200, GROUND + 500), Color("#2a180c"))
	for p in planks:
		c.draw_line(Vector2(p[0], -500), Vector2(p[0], GROUND), Color(0.1, 0.05, 0.02, 0.8), 3.0)
	# xà ngang + cột
	c.draw_rect(Rect2(-600, 150, W + 1200, 36), Color("#1a0d05"))
	for x in [-80.0, 980.0, 2020.0]:
		c.draw_rect(Rect2(x - 34, -500, 68, GROUND + 500), Color("#1c0f06"))
		c.draw_rect(Rect2(x - 34, -500, 10, GROUND + 500), Color("#3e2412"))
	# cửa song gỗ dán giấy: đèn ngoài hắt vào
	var dr := Rect2(1360, 250, 470, 520)
	c.draw_rect(dr, Color(0.86, 0.74, 0.55))
	for i in range(1, 6):
		var x := dr.position.x + dr.size.x * i / 6.0
		c.draw_line(Vector2(x, dr.position.y), Vector2(x, dr.end.y), Color("#3a2212"), 7.0)
	for j in range(1, 7):
		var y := dr.position.y + dr.size.y * j / 7.0
		c.draw_line(Vector2(dr.position.x, y), Vector2(dr.end.x, y), Color("#3a2212"), 6.0)
	c.draw_rect(dr, Color("#24140a"), false, 16.0)
	# bàn + đèn dầu bên trái
	c.draw_rect(Rect2(200, 700, 240, 24), Color("#3a2010"))
	c.draw_rect(Rect2(220, 724, 18, 116), Color("#2a160a"))
	c.draw_rect(Rect2(402, 724, 18, 116), Color("#2a160a"))
	c.draw_colored_polygon(PackedVector2Array([Vector2(296, 700), Vector2(344, 700), Vector2(334, 672), Vector2(306, 672)]), Color("#6a4a2a"))
	c.draw_rect(Rect2(316, 650, 8, 22), Color("#d8c8a0"))
	# sàn ván: đường mạch
	for i in 9:
		var y := GROUND + 18.0 + i * i * 6.0
		c.draw_line(Vector2(-600, y), Vector2(W + 600, y), Color(0.12, 0.06, 0.02, 0.6), 2.0)
	# vệt cày của song hoàn: rãnh tối + mép vàng nguội dần
	for gq in gouges:
		var age: float = t - gq[2]
		var a: Vector2 = gq[0]
		var b: Vector2 = gq[1]
		c.draw_line(a + Vector2(0, 6), b + Vector2(0, 6), Color(0.06, 0.03, 0.01, 0.9), 9.0)
		c.draw_line(a + Vector2(0, 2), b + Vector2(0, 2), GOLD.lerp(Color(0.25, 0.14, 0.05), smooth(0.0, 1.5, age)), 3.0)


func _draw_ring(c: Node2D, p: Vector2, r: float, sx: float, rot: float, phoenix: bool) -> void:
	c.draw_set_transform(p, rot, Vector2(sx, 1.0))
	c.draw_arc(Vector2.ZERO, r, 0, TAU, 40, GOLD_DK, 13.0)
	c.draw_arc(Vector2.ZERO, r, 0, TAU, 40, GOLD, 8.0)
	# đầu rồng / đầu phượng: một mấu nhọn trên vành
	var a := -0.6 if phoenix else 2.4
	var q := Vector2(cos(a), sin(a)) * r
	c.draw_colored_polygon(PackedVector2Array([q * 0.8, q * 1.35, q.rotated(0.35) * 0.95]), GOLD)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _fx_norm(c: Node2D) -> void:
	var s := _still()
	if s > 0.01:
		c.draw_rect(Rect2(-800, -600, W + 1600, H + 1200), Color(0.02, 0.015, 0.03, 0.42 * s))
	# song hoàn trong tay / đang bay / rơi lăn
	var hands := [foe.handF, foe.handB]
	if hit:
		for i in drop.size():
			var d: Dictionary = drop[i]
			var sx := 1.0 if not d.rest else 0.3
			_draw_ring(c, d.p, 40.0, lerpf(1.0, 0.32, smooth(0.0, 0.4, float(d.bounced))), d.a, i == 1)
	else:
		for i in 2:
			var hp: Vector2 = hands[i]
			var flying: Array = []
			for bi in BEATS.size():
				if bi % 2 == i:
					var pth := _ring_path(BEATS[bi], hp)
					if not pth.is_empty():
						flying = pth
			if flying.is_empty():
				var big := smooth(5.15, 5.75, t)
				_draw_ring(c, hp + Vector2(0, 6), 40.0 + big * 8.0, 1.0, rt * (10.0 * big), i == 1)
			else:
				_draw_ring(c, flying[0], 40.0, flying[1], rt * 30.0, i == 1)


func _fx_add(c: Node2D) -> void:
	var s := _still()
	# đèn dầu: lửa đứng yên khi khựng
	var fl := 1.0 + (sin(rt * 17.0) * 0.08 + sin(rt * 7.3) * 0.06) * (1.0 - s)
	blob(c, Vector2(320, 640), 240.0 * fl, LAMP * Color(1, 1, 1, 0.22))
	c.draw_colored_polygon(PackedVector2Array([Vector2(312, 652), Vector2(320, 622 - 6 * fl), Vector2(328, 652)]), LAMP)
	blob(c, Vector2(1595, 510), 330.0, Color(0.9, 0.55, 0.25, 0.12))
	for m in motes:
		var tw: float = 0.5 + 0.5 * sin(rt * 1.7 + m[2]) * (1.0 - s)
		c.draw_circle(m[0], m[1], Color(1.3, 0.9, 0.5, 0.35 * tw))
	# vòng đang bay: vệt quét vàng
	if not hit:
		var hands := [foe.handF, foe.handB]
		for bi in BEATS.size():
			var pth := _ring_path(BEATS[bi], hands[bi % 2])
			if pth.is_empty():
				continue
			var p: Vector2 = pth[0]
			blob(c, p, 70.0, FOE_COL * Color(1, 1, 1, 0.35))
			c.draw_arc(p, 48.0, rt * 30.0, rt * 30.0 + 2.2, 16, FOE_HOT * Color(1, 1, 1, 0.6), 4.0)
		var big := smooth(5.15, 5.75, t)
		if big > 0.01:
			for hp in hands:
				blob(c, hp, 90.0 * big, FOE_COL * Color(1, 1, 1, 0.3 * big))
				c.draw_arc(hp, 56.0, rt * 14.0, rt * 14.0 + 4.0, 24, FOE_HOT * Color(1, 1, 1, big * 0.8), 3.0)
	# chấm lóe ở tay Lý: nhỏ, chỉ một khoảnh khắc — không có đao, không có vệt bay
	var g1 := pulse(FLICK - 0.01, FLICK + 0.02, 0.12, t)
	if g1 > 0.01:
		_glint(c, hero.hand + Vector2(14, -6), 26.0 * g1, g1)
	# kết quả: chấm bạc nhỏ ở cổ áo đối thủ, tắt dần
	if hit:
		var g2 := 1.0 - smooth(PEAK + 0.2, PEAK + 1.4, t)
		if g2 > 0.01:
			_glint(c, _throat(), 18.0 * g2 + 6.0, g2)


func _glint(c: Node2D, p: Vector2, r: float, a: float) -> void:
	blob(c, p, r * 2.2, COL * Color(1, 1, 1, 0.3 * a))
	c.draw_colored_polygon(PackedVector2Array([p + Vector2(0, -r), p + Vector2(r * 0.16, 0), p + Vector2(0, r), p + Vector2(-r * 0.16, 0)]), HOT * Color(1, 1, 1, a))
	c.draw_colored_polygon(PackedVector2Array([p + Vector2(-r * 0.7, 0), p + Vector2(0, r * 0.12), p + Vector2(r * 0.7, 0), p + Vector2(0, -r * 0.12)]), HOT * Color(1, 1, 1, a))


func _fx_ui(c: Node2D) -> void:
	# khựng: viền tối mỏng quanh khung (không letterbox), như ảnh dừng
	var s := _still()
	if s > 0.01:
		for i in 6:
			var w := 18.0 + i * 16.0
			c.draw_rect(Rect2(w * 0.5, w * 0.5, W - w, H - w), Color(0, 0, 0, 0.09 * s), false, 16.0)
