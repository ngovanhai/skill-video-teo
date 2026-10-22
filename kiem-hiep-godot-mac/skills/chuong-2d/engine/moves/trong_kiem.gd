extends "res://engine.gd"
# HUYỀN THIẾT TRỌNG KIẾM (12.5 s): sân đá đỉnh núi giữa trưa, bụi đá vôi, nắng trắng.
# Thẻ chiêu:
#   người dùng   Dương Quá (một tay, thanh kiếm sắt đen nặng, hai mép cùn, mũi tròn)
#   đối thủ      Kim Luân Pháp Vương, năm chiếc luân kim loại (vàng, bạc, đồng, sắt, chì)
#   cơ chế       SỨC NẶNG: quanh thanh kiếm trọng lực dày lên. Bụi rơi xuống thay vì bay lên, đá lát lún nứt theo từng bước.
#                Luân ném tới lọt vào vùng sóng ép (vòng sóng lam lạnh) thì chậm lại, bị đè cong quỹ đạo, cắm xuống đá.
#   cặp màu      sóng ép thép lam lạnh vs luân vàng kim
#   bối cảnh     trưa nắng trắng, núi đá vôi xám, thông thấp, sân lát đá vôi, bụi ngà lơ lửng
#   đỉnh         một nhát quét ngang chậm và nặng (không lưỡi, không chém): sóng ép hình cung dập vào hai luân chắn,
#                luân bẹp văng tung; Kim Luân bị đẩy trượt lùi, chân cày hai rãnh trên đá, rồi quỳ một gối (không máu)

const COL := Color(0.55, 0.75, 1.5)       # sóng ép thép lam
const HOT := Color(1.3, 1.6, 2.3)
const GOLD := Color(1.9, 1.45, 0.35)      # luân vàng
const GOLD_HOT := Color(2.4, 2.0, 0.9)
const METALS := [Color("#e8b830"), Color("#c8ccd4"), Color("#c07a3a"), Color("#6a6e76"), Color("#8a8a90")]
const BEATS := [2.5, 3.5, 4.5]            # ba lần ném luân / ba bước nặng
const PEAK := 6.2                         # nhát quét ngang chạm hai luân chắn
const HX0 := 520.0
const STEP := 70.0
const KNEEL_X := 1460.0

const DRAG := {"uaF": 34, "faF": 48, "torso": 4, "head": 4, "thF": -10, "shF": 14, "thB": 12, "shB": -14, "all": [0, 0, 14]}
const HEAVE := {"uaF": -70, "faF": -40, "torso": 12, "head": 6, "thF": -30, "shF": 34, "thB": 26, "shB": -20, "all": [0, 0, 30]}
const SWEEP := {"uaF": -100, "faF": 4, "torso": -18, "head": -8, "thF": -50, "shF": 40, "thB": 34, "shB": -10, "all": [0, 30, 30]}
const PLANT := {"uaF": -36, "faF": -60, "torso": 6, "head": 4, "thF": -14, "shF": 18, "thB": 14, "shB": -18, "all": [0, 0, 10]}
const THROW := {"uaF": -110, "faF": 10, "uaB": 40, "faB": -60, "torso": -14, "head": -6, "thF": -36, "shF": 30, "thB": 24, "shB": -8, "all": [0, 20, 16]}
const SHIELD := {"uaF": -80, "faF": -100, "uaB": -60, "faB": -110, "torso": 10, "head": 8, "thF": -26, "shF": 30, "thB": 20, "shB": -26, "all": [0, 0, 26]}

var hit := false
var landed := false
var beat_i := 0
var x_hit := 0.0
var wheels: Array = []      # {p, v, a, w, m, st: "orbit"|"held"|"fly"|"bent"|"stuck", r, k}
var motes: Array = []       # bụi ngà lơ lửng
var cracks: Array = []      # [tâm, t sinh, tia]
var pebbles: Array = []
var stones: Array = []      # ô đá lát
var furrow_x0 := 0.0


func _setup() -> void:
	sky_cols = [Color("#9aa3ad"), Color("#d9d6cc"), Color("#f2eee2")]
	moon = Vector2(1500, 150)
	moon_on = true
	moon_craters = false
	moon_col = Color(1.6, 1.55, 1.4)
	moon_glow = Color(1.0, 0.98, 0.9, 0.3)
	n_stars = 0
	far_col = Color("#8d939a")
	near_col = Color("#4b4d47")
	mist_col = Color(0.95, 0.92, 0.85, 0.2)
	ground_cols = [Color("#b3ab9b"), Color("#5e584e"), Color("#ece5d4")]
	slowmo = [PEAK - 0.12, PEAK + 0.5, 0.3]
	title = "HUYỀN THIẾT TRỌNG KIẾM"
	subtitle = "Thần Điêu Hiệp Lữ · Dương Quá"
	title_at = 8.5
	title_col = HOT
	set_char(hero, "duong-qua")
	set_char(foe, "kim-luan-phap-vuong")
	hero.pos = Vector2(HX0, GROUND)
	foe.pos = Vector2(1300, GROUND)
	hero.node.hand_form = {"F": "nam", "B": "nam"}
	foe.node.hand_form = {"F": "nam", "B": "nam"}
	hero.col = COL
	foe.col = GOLD
	hero.base = "rest"
	foe.base = "stance"
	cue(1.0, "lib-riser", 0.8)
	for b in BEATS:
		cue(b - 0.25, "lib-whoosh", 0.6)
	cue(5.2, "lib-whoosh-short", 0.6)
	cue(PEAK - 0.3, "lib-whoosh-cinematic", 0.9)
	for i in 5:
		wheels.append({"p": foe.pos, "v": Vector2.ZERO, "a": rng.randf() * TAU, "w": 6.0, "m": i, "st": "orbit", "r": 34.0, "k": 0.0})
	wheels[0].st = "held"
	wheels[1].st = "held"
	for i in 160:
		motes.append({"p": Vector2(rng.randf_range(-200, 2200), rng.randf_range(80, GROUND)), "v": Vector2(rng.randf_range(-12, 12), rng.randf_range(-10, 6)), "s": rng.randf_range(1.5, 3.6), "ph": rng.randf() * TAU})
	for i in 40:
		stones.append([rng.randf_range(-300, 2300), rng.randf_range(0.0, 1.0), rng.randf_range(80, 200)])


# tâm thân và mũi kiếm (lưỡi chạy theo -y của khớp wpF)
func _tip() -> Vector2:
	return joint_pos(hero, "wpF", Vector2(0, -184))


func _mid() -> Vector2:
	return joint_pos(hero, "wpF", Vector2(0, -100))


# cường độ vùng nặng quanh kiếm
func _weight() -> float:
	var w := smooth(1.0, 2.0, t) * 0.7
	for b in BEATS:
		w += pulse(b - 0.05, b + 0.1, 0.5, t) * 0.4
	w += smooth(5.0, 5.9, t) * 0.6
	return w * (1.0 - smooth(7.4, 9.0, t) * 0.7)


func _stomp(x: float, big: float) -> void:
	var p := Vector2(x, GROUND + 6)
	cracks.append([p, t, 5 + int(big * 4), big])
	add_ring(p, 260 + big * 300, COL, 6 + big * 6, 0.45, 0.22)
	for i in int(18 + big * 30):
		emit("smoke", p + Vector2(rng.randf_range(-90, 90), 0), Vector2(rng.randf_range(-260, 260), -rng.randf_range(60, 240)), 1.2, rng.randf_range(16, 40), Color(0.86, 0.82, 0.74, 0.5), 520.0, 2.0)
	shake = maxf(shake, 10.0 + big * 4.0)
	sfx("lib-impact-bass-2", 0.55 + big * 0.15)


func _story(dt: float) -> void:
	var w := _weight()
	# ---- Dương Quá: kéo kiếm, nhấc nặng, ba bước, quét, cắm kiếm
	var step_k := 0.0
	for b in BEATS:
		step_k += smooth(b - 0.35, b, t)
	hero.pos.x = HX0 + step_k * STEP
	hero.pos.y = GROUND
	for b in BEATS:
		hero.pos.y -= pulse(b - 0.35, b - 0.02, 0.15, t) * 14.0
	var heave := smooth(1.0, 2.1, t) * (1.0 - smooth(4.9, 5.3, t))
	var wind := smooth(5.0, 5.85, t) * (1.0 - smooth(5.95, 6.22, t))
	var sweep := smooth(5.95, 6.22, t) * (1.0 - smooth(7.6, 8.4, t))
	var plant := smooth(7.6, 8.4, t)
	hero.extra = [[DRAG, 1.0 - heave], [HEAVE, heave], ["windup", wind], [SWEEP, sweep], [PLANT, plant]]
	hero.crouch = heave * 0.3 + w * 0.15
	hero.aura = w * 0.4
	hero.expr = "ngai" if t > 8.2 else ("quyet-tam" if t > 1.0 else "binh")
	# run rẩy khi nhấc nặng
	hero.rot = sin(t * 38.0) * 0.006 * heave * (1.0 - smooth(2.2, 2.6, t))

	# ---- Kim Luân: ném ba luân, rồi hai luân chắn, rồi trượt lùi quỳ
	if not hit:
		var thr := 0.0
		for b in BEATS:
			thr = maxf(thr, pulse(b - 0.35, b - 0.15, 0.25, t))
		var sh := smooth(5.2, 5.8, t)
		foe.extra = [[THROW, thr], [SHIELD, sh]]
		foe.pos.x = 1300.0 - smooth(5.1, 5.6, t) * 130.0 + smooth(3.6, 4.0, t) * 30.0 + smooth(4.6, 5.0, t) * 30.0
		foe.expr = "soc" if t > 3.7 else "gian"
		foe.aura = 0.3 + sh * 0.4
	pose(hero, 0.0)
	pose(foe, 0.0)

	# ---- bụi: gần kiếm thì RƠI (nặng), xa thì lơ lửng
	var mid := _mid()
	for m in motes:
		var d: float = m.p.distance_to(mid)
		var g: float = w * clampf(1.0 - d / 620.0, 0.0, 1.0) * 380.0
		m.v.y += g * dt
		m.v *= 1.0 - 0.6 * dt
		m.p += (m.v + Vector2(sin(t * 0.8 + m.ph) * 8.0, 0)) * dt
		if m.p.y > GROUND:
			m.p = Vector2(rng.randf_range(-200, 2200), rng.randf_range(60, 200))
			m.v = Vector2(rng.randf_range(-12, 12), 0)
	if heave > 0.05 and t < 2.4:
		if rng.randf() < 0.5:
			emit("smoke", Vector2(hero.pos.x + rng.randf_range(-120, 160), GROUND - rng.randf_range(160, 380)), Vector2(0, rng.randf_range(80, 200)), 1.0, rng.randf_range(4, 9), Color(0.9, 0.86, 0.78, 0.7), 600.0, 0.5)
	if t >= 1.9 and cracks.is_empty():
		_stomp(hero.pos.x + 30, 0.4)

	# ---- ném luân
	if beat_i < BEATS.size() and t >= BEATS[beat_i] - 0.18:
		var wh: Dictionary = wheels[2 + beat_i]
		wh.st = "fly"
		wh.p = foe.handF + Vector2(-20, 0)
		wh.v = Vector2(-1250, -60 + beat_i * 40)
		wh.w = 26.0
		beat_i += 1
	for i in wheels.size():
		var wh: Dictionary = wheels[i]
		match wh.st:
			"orbit":
				var a := t * 2.2 + i * TAU / 3.0
				wh.p = foe.pos + Vector2(-20, -150) + Vector2(cos(a) * 120, sin(a) * 40)
				wh.a += dt * 5.0
			"held":
				wh.p = (foe.handF if i == 0 else foe.handB) + Vector2(-8 * (1 if i == 0 else -1), 0)
				wh.a += dt * 2.0
			"fly":
				var d: float = wh.p.distance_to(mid)
				var inside: float = clampf(1.0 - (d - 120.0) / 360.0, 0.0, 1.0) * w
				wh.v *= 1.0 - inside * 4.0 * dt
				wh.v.y += (60.0 + inside * 3400.0) * dt
				wh.p += wh.v * dt
				wh.a += wh.w * dt * (1.0 - inside * 0.8)
				wh.k = inside
				if wh.p.y >= GROUND - 6:
					wh.p.y = GROUND - 6
					wh.st = "stuck"
					var at: Vector2 = wh.p
					add_ring(at + Vector2(0, -20), 200, GOLD_HOT, 7, 0.35)
					burst(at + Vector2(0, -20), 30, 200, 700, GOLD_HOT, GOLD, 900.0, 1.4, -PI * 0.95, -PI * 0.05)
					_stomp(hero.pos.x + 20, 0.6)
					cracks.append([at, t, 4, 0.5])
					sfx("lib-glitch-1", 0.35)
			"bent":
				wh.v.y += 1500.0 * dt
				wh.p += wh.v * dt
				wh.a += wh.w * dt
				if wh.p.y >= GROUND - 4:
					wh.p.y = GROUND - 4
					wh.v = Vector2.ZERO
					wh.w = 0.0
					wh.st = "stuck"
					emit("smoke", wh.p, Vector2(0, -80), 1.0, 40, Color(0.86, 0.82, 0.74, 0.45), 200.0, 2.0)
	if heave > 0.1:
		orbit(hero, rng.randf_range(160, 300), rng.randf_range(-1.5, -2.6), 0, rng.randf_range(2, 4), COL, 2.3)

	# ---- đỉnh: nhát quét ngang chạm hai luân chắn
	if t >= PEAK and not hit:
		hit = true
		x_hit = foe.pos.x
		furrow_x0 = foe.pos.x
		foe.expr = "ko"
		flash = 0.6
		flash_col = Color(0.9, 0.95, 1.1)
		shake = 34.0
		var at: Vector2 = foe.pos + Vector2(-60, -170)
		add_ring(at, 720, HOT, 18, 0.7)
		add_ring(Vector2(at.x - 200, GROUND), 900, COL, 10, 0.9, 0.2)
		burst(at, 150, 300, 1500, GOLD_HOT, HOT, 900.0, 1.0, -PI * 0.9, PI * 0.3)
		for i in 2:
			var wh: Dictionary = wheels[i]
			wh.st = "bent"
			wh.v = Vector2(rng.randf_range(300, 700), -rng.randf_range(700, 1000))
			wh.w = rng.randf_range(14, 22) * (1 if i == 0 else -1)
		for i in range(2, 5):
			cracks.append([wheels[i].p, t, 3, 0.3])
		_stomp(hero.pos.x + 60, 1.0)
		sfx("lib-impact-bass-1", 1.0)
		sfx("lib-impact-bass-2", 1.0)
	# ---- hậu quả: trượt lùi cày rãnh rồi quỳ một gối
	if hit:
		var k := clampf((t - PEAK) / 1.3, 0.0, 1.0)
		foe.pos.x = lerpf(x_hit, KNEEL_X, ease_out(k))
		foe.pos.y = GROUND
		var kn := smooth(PEAK + 0.9, PEAK + 1.4, t)
		foe.extra = [[SHIELD, (1.0 - k) * 0.8], ["kneel", kn]]
		foe.lean = -0.6 * (1.0 - kn)
		foe.hurt = 0.0
		foe.aura = 0.0
		if k < 0.9 and rng.randf() < 0.8:
			emit("smoke", Vector2(foe.pos.x - 10, GROUND), Vector2(rng.randf_range(-200, 40), -rng.randf_range(30, 120)), 1.0, rng.randf_range(20, 40), Color(0.84, 0.8, 0.72, 0.45), 300.0, 2.0)
		if kn >= 1.0 and not landed:
			landed = true
			shake = maxf(shake, 14.0)
			sfx("lib-impact-bass-2", 0.5)
			for i in 20:
				emit("smoke", Vector2(KNEEL_X + rng.randf_range(-60, 200), GROUND), Vector2(rng.randf_range(-160, 220), -rng.randf_range(20, 140)), 2.0, rng.randf_range(40, 90), Color(0.8, 0.76, 0.68, 0.45))
	if t >= 8.0 and cracks.size() < 40 and not hero.has("planted"):
		hero.planted = true
		_stomp(_tip().x, 0.5)


func _cam() -> Array:
	var c := Vector2(960, 600)
	var z := 1.0
	var k1 := smooth(0.9, 1.7, t) * (1.0 - smooth(2.2, 2.7, t))      # tụ khí: sát đất, ngang tầm kiếm
	c = c.lerp(hero.pos + Vector2(170, -200), k1)
	z = lerpf(z, 1.38, k1)
	var k2 := smooth(5.3, 6.0, t) * (1.0 - smooth(PEAK + 0.9, 8.6, t))  # đỉnh: thấp, nhìn chéo theo nhát quét
	c = c.lerp(Vector2(980, 660), k2)
	z = lerpf(z, 1.22, k2)
	var k3 := smooth(8.4, 10.2, t)
	c = c.lerp(Vector2(980, 580), k3)
	z = lerpf(z, 1.0, k3)
	return [c, z]


func _fx_ground(c: Node2D) -> void:
	# mạch đá lát
	for s in stones:
		var x: float = s[0]
		var y: float = GROUND + 12 + s[1] * 220
		c.draw_line(Vector2(x, y), Vector2(x + s[2], y + 4), Color(0.36, 0.33, 0.28, 0.35), 2.0)
	# chỗ lún quanh chân Dương Quá
	var w := _weight()
	flat_blob(c, Vector2(hero.pos.x + 20, GROUND + 8), 200 + w * 60, 0.16, Color(0.2, 0.18, 0.15, 0.25 * w))
	# vết nứt
	for cr in cracks:
		var p: Vector2 = cr[0]
		var age: float = t - cr[1]
		var grow := clampf(age / 0.25, 0.0, 1.0)
		var n: int = cr[2]
		var big: float = cr[3]
		var r2 := RandomNumberGenerator.new()
		r2.seed = int(p.x * 7.0 + p.y)
		for i in n:
			var a := r2.randf_range(-PI, 0.0) if i % 2 == 0 else r2.randf_range(0.0, PI)
			var q := p
			var ln := (60.0 + big * 160.0) * grow
			for j in 4:
				var q2 := q + Vector2(cos(a), sin(a) * 0.22) * ln * 0.25 + Vector2(r2.randf_range(-8, 8), r2.randf_range(-3, 3))
				c.draw_line(q, q2, Color(0.16, 0.14, 0.12, 0.85), 3.0 - j * 0.5)
				q = q2
	# hai rãnh cày dưới chân Kim Luân
	if hit:
		for dy in [4.0, 22.0]:
			c.draw_line(Vector2(furrow_x0 - 40, GROUND + dy), Vector2(foe.pos.x - 30, GROUND + dy), Color(0.2, 0.18, 0.15, 0.8), 7.0)
			c.draw_line(Vector2(furrow_x0 - 40, GROUND + dy + 5), Vector2(foe.pos.x - 30, GROUND + dy + 5), Color(0.95, 0.92, 0.84, 0.6), 2.0)


func _wheel(c: Node2D, wh: Dictionary) -> void:
	var p: Vector2 = wh.p
	var col: Color = METALS[wh.m]
	var r: float = wh.r
	var sq := 1.0
	if wh.st == "stuck":
		sq = 0.35      # cắm nghiêng xuống đá: thấy dẹt
	if wh.st == "bent":
		sq = 0.6
	var pts := PackedVector2Array()
	for i in 24:
		var a := float(i) / 24.0 * TAU
		var rr := r * (1.0 + 0.16 * (1 if i % 2 == 0 else 0))
		pts.append(p + Vector2(cos(a + wh.a) * rr, sin(a + wh.a) * rr * sq))
	c.draw_colored_polygon(pts, col)
	pts.append(pts[0])
	c.draw_polyline(pts, Color("#2a1e10"), 3.0)
	var inner := PackedVector2Array()
	for i in 17:
		var a := float(i) / 16.0 * TAU
		inner.append(p + Vector2(cos(a) * r * 0.45, sin(a) * r * 0.45 * sq))
	c.draw_polyline(inner, Color("#2a1e10"), 2.5)


func _fx_norm(c: Node2D) -> void:
	_heavy(c)
	for wh in wheels:
		_wheel(c, wh)
	# bụi ngà
	for m in motes:
		c.draw_circle(m.p, m.s, Color(0.98, 0.95, 0.86, 0.55))


# thanh trọng kiếm vẽ đè lên sprite (sprite xám tối chìm vào áo đen): bản to, đen ánh đỏ, viền ngà sáng để đọc được trên áo tối
func _heavy(c: Node2D) -> void:
	var g := joint_pos(hero, "wpF", Vector2(0, -14))
	var tip := _tip()
	var d := (tip - g).normalized()
	var n := d.orthogonal()
	var L := g.distance_to(tip)
	var wd := 17.0
	var body := PackedVector2Array([g + n * wd, g + d * (L - 14) + n * wd, g + d * L + n * 6, g + d * L - n * 6, g + d * (L - 14) - n * wd, g - n * wd])
	c.draw_colored_polygon(body, Color("#17151a"))
	c.draw_polyline(body + PackedVector2Array([body[0]]), Color(0.93, 0.88, 0.78, 0.9), 2.5, true)
	c.draw_line(g + d * 8 + n * 7, g + d * (L - 18) + n * 7, Color("#6a2a24"), 4.0, true)
	c.draw_line(g + d * 8 - n * 4, g + d * (L - 18) - n * 4, Color("#3a3f48"), 3.0, true)
	c.draw_line(g - n * 30, g + n * 30, Color("#2a2f36"), 11.0, true)
	c.draw_line(g - n * 30, g + n * 30, Color(0.93, 0.88, 0.78, 0.6), 1.5, true)


func _fx_add(c: Node2D) -> void:
	var w := _weight()
	var mid := _mid()
	var tip := _tip()
	# sóng ép: các vòng lam lạnh đồng tâm dập xuống, méo theo trọng lực (dẹt về phía đất)
	if w > 0.05:
		for i in 4:
			var ph := fmod(t * 0.9 + i * 0.25, 1.0)
			var r := 90.0 + ph * 380.0
			var pts := PackedVector2Array()
			for j in 33:
				var a := float(j) / 32.0 * TAU
				var sag := 1.0 + 0.35 * maxf(sin(a), 0.0)
				pts.append(mid + Vector2(cos(a) * r, sin(a) * r * 0.7 * sag) + Vector2(0, ph * 40.0))
			c.draw_polyline(pts, COL * Color(1, 1, 1, 0.16 * w * (1.0 - ph)), 3.0)
		blob(c, mid, 130 * w, COL * Color(1, 1, 1, 0.12))
		# ánh đỏ sẫm dọc thân kiếm (đen ánh đỏ)
		c.draw_line(joint_pos(hero, "wpF", Vector2(0, -24)), tip, Color(1.2, 0.3, 0.18, 0.18 * w), 6.0)
	# luân lọt vùng nặng: vệt chậm lại
	for wh in wheels:
		if wh.st == "fly":
			blob(c, wh.p, 50, GOLD * Color(1, 1, 1, 0.3))
			c.draw_line(wh.p, wh.p - wh.v.normalized() * (40 + wh.v.length() * 0.06), GOLD * Color(1, 1, 1, 0.25), 6.0)
			if wh.k > 0.1:
				c.draw_arc(wh.p, 60, 0, TAU, 24, COL * Color(1, 1, 1, 0.3 * wh.k), 3.0)
	# nhát quét: cung sóng ép to, chậm
	var sw := smooth(5.95, PEAK, t) * (1.0 - smooth(PEAK + 0.25, PEAK + 0.8, t))
	if sw > 0.0:
		var span := lerpf(-1.1, 1.1, smooth(5.95, PEAK + 0.1, t))
		var r := 260.0 + smooth(PEAK - 0.05, PEAK + 0.8, t) * 520.0
		crescent(c, hero.pos + Vector2(80, -170), r, -1.1, span, 0.0, COL * Color(1, 1, 1, 0.45 * sw), HOT * Color(1, 1, 1, 0.6 * sw))
	if t > PEAK - 0.1 and t < PEAK + 0.6:
		var k := smooth(PEAK - 0.1, PEAK + 0.6, t)
		speed_lines(c, hero.pos.x + 200, 1.0, (1.0 - k), COL * Color(1, 1, 1, 0.5))


func _fx_ui(c: Node2D) -> void:
	pass
