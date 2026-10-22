extends "res://engine.gd"
# VÔ HÌNH KHÍ TƯỜNG (Tảo Địa Tăng, Thiên Long Bát Bộ, hồi Tàng Kinh Các).
# Thẻ chiêu: Tảo Địa Tăng · Tiêu Phong (dồn Hàng Long vào người sau lưng sư) · bức tường khí vô hình chỉ hiện khi bị chạm,
# gợn như mặt hồ dựng đứng, chưởng vàng tan thành lá vàng thếp rơi, KHÔNG dội ngược · ngọc lục nhạt vs vàng kim ·
# nội thất Tàng Kinh Các đêm: đen sơn mài, viền vàng thếp, cột son · đỉnh: Kiến Long Tại Điền mười thành, cả bức tường hiện vòng gợn.
# Kết: Tiêu Phong trượt lùi rồi quỳ một gối thủ lễ (không văng ngã), sư ông chắp tay, mỉm cười.

const COL := Color(0.62, 1.15, 1.0)      # khí tường: ngọc lục nhạt
const HOT := Color(1.7, 2.05, 1.9)       # lõi gợn
const FOE_COL := Color(1.65, 0.95, 0.25) # Hàng Long vàng kim
const FOE_HOT := Color(2.2, 1.6, 0.55)
const LEAF := Color(0.98, 0.76, 0.3)     # vàng thếp (vật thể, blend thường)
const BEATS := [2.6, 3.6, 4.6]           # ba chưởng thử
const PEAK := 6.1                        # Kiến Long Tại Điền chạm tường
const WALL_X := 905.0                    # mặt tường (vô hình)
const FLY := 0.32                        # thời gian chưởng bay tới tường

const CHAP := {"uaF": -30, "faF": -118, "uaB": 14, "faB": -20, "torso": 2, "head": 4, "thF": -6, "shF": 8, "thB": 6, "shB": -8, "all": [0, 0, 4]}
const DUNG := {"uaF": -78, "faF": -30, "uaB": 14, "faB": -20, "torso": -2, "head": 0, "thF": -14, "shF": 18, "thB": 14, "shB": -16, "all": [0, 0, 8]}
const LE := {"uaF": -64, "faF": -78, "uaB": -54, "faB": -84, "torso": 14, "head": 10, "thF": -84, "shF": 84, "thB": 44, "shB": 52, "all": [0, 0, 70]}

var beat_i := 0
var shots: Array = []     # [t phóng, y, cỡ, đã chạm]
var ripples: Array = []   # [p, t0, r max, mạnh]
var hit := false
var x_hit := 0.0
var shelf_rng := RandomNumberGenerator.new()
var scrolls: Array = []


func _setup() -> void:
	sky_cols = [Color("#090605"), Color("#160d0a"), Color("#24140e")]
	far_col = Color("#150c09")
	near_col = Color("#100907")
	mist_col = Color(0.55, 0.36, 0.2, 0.05)
	ground_cols = [Color("#2b1a12"), Color("#0c0705"), Color("#b38d3e")]
	moon_on = false
	n_stars = 0
	slowmo = [PEAK - 0.05, PEAK + 0.62, 0.3]
	title = "VÔ HÌNH KHÍ TƯỜNG"
	subtitle = "Tảo Địa Tăng · Tàng Kinh Các · Thiên Long Bát Bộ"
	title_at = 8.5
	title_col = Color(1.9, 1.5, 0.7)
	set_char(hero, "tao-dia-tang")
	set_char(foe, "tieu-phong")
	hero.pos = Vector2(1240, GROUND)
	hero.face = -1.0
	foe.pos = Vector2(470, GROUND)
	foe.face = 1.0
	hero.col = COL
	foe.col = FOE_COL
	hero.base = "rest"
	shelf_rng.seed = 606
	for i in 70:
		scrolls.append([shelf_rng.randi_range(0, 9), shelf_rng.randi_range(0, 4), shelf_rng.randf_range(0.1, 0.9), shelf_rng.randi_range(0, 2)])
	cue(1.0, "lib-riser", 0.7)
	for b in BEATS:
		cue(b - FLY - 0.05, "lib-whoosh-short", 0.6)
	cue(5.2, "lib-riser", 0.6)
	cue(PEAK - 0.3, "lib-whoosh-cinematic", 0.9)


func _shot_x(s: Array) -> float:
	var k := clampf((t - float(s[0])) / FLY, 0.0, 1.0)
	return lerpf(foe.pos.x + 90.0, WALL_X, k)


func _story(_dt: float) -> void:
	# ---- sư ông: đứng chắp tay, tụ khí rất nhẹ, giơ một bàn tay dựng tường
	var g := smooth(1.0, 1.9, t) * (1.0 - smooth(2.2, 2.5, t))
	var up := smooth(2.0, 2.4, t) * (1.0 - smooth(7.6, 8.6, t))
	hero.extra = [[CHAP, 1.0 - up], [DUNG, up]]
	hero.gather = g * 0.35
	hero.crouch = g * 0.2
	hero.aura = g * 0.35 + pulse(PEAK - 0.1, PEAK + 0.1, 0.5, t) * 0.5
	if t > 8.2:
		hero.expr = "vui"
	elif t > 1.0:
		hero.expr = "quyet-tam" if t < 2.4 else "binh"
	else:
		hero.expr = "binh"
	# ---- Tiêu Phong: ba chưởng thử, rồi Kiến Long Tại Điền
	var bp := 0.0
	for b in BEATS:
		bp = maxf(bp, pulse(b - FLY - 0.12, b - FLY + 0.05, 0.3, t))
	var wind := smooth(4.9, 5.7, t) * (1.0 - smooth(PEAK - FLY - 0.08, PEAK - FLY, t))
	if not hit:
		foe.gather = smooth(1.2, 2.0, t) * 0.5 * (1.0 - smooth(2.1, 2.3, t))
		foe.push = bp + smooth(PEAK - FLY - 0.08, PEAK - FLY, t)
		foe.extra = [["windup", wind]]
		foe.both = smooth(PEAK - FLY - 0.1, PEAK - FLY, t)
		foe.lean = foe.push * 0.35
		foe.aura = 0.3 + wind * 0.9
		foe.expr = "soc" if t > 4.8 else ("quyet-tam" if t > 1.2 else "gian")
	pose(hero, 0.0)
	pose(foe, 0.0)

	if g > 0.05:
		orbit(hero, rng.randf_range(110, 240), rng.randf_range(1.2, 2.2), 160, rng.randf_range(2, 4), COL, 2.4)
	if wind > 0.1:
		orbit(foe, rng.randf_range(140, 300), rng.randf_range(2.5, 4.0), 300, rng.randf_range(3, 6), FOE_HOT, PEAK - FLY)

	# ---- phóng chưởng
	if beat_i < BEATS.size() and t >= float(BEATS[beat_i]) - FLY:
		var y: float = [GROUND - 200.0, GROUND - 300.0, GROUND - 150.0][beat_i]
		shots.append([float(BEATS[beat_i]) - FLY, y, 1.0, false])
		beat_i += 1
		sfx("lib-glitch-1", 0.35)
	if shots.size() == BEATS.size() and t >= PEAK - FLY:
		shots.append([PEAK - FLY, GROUND - 230.0, 2.6, false])
	# ---- chạm tường: gợn, tan thành lá vàng (không dội ngược)
	for s in shots:
		if s[3] or t < float(s[0]) + FLY:
			continue
		s[3] = true
		var p := Vector2(WALL_X, float(s[1]))
		var big: bool = float(s[2]) > 2.0
		if big:
			_peak(p)
		else:
			ripples.append([p, t, 260.0, 1.0])
			add_ring(p, 160, HOT, 5, 0.4, 2.6)
			burst(p, 26, 200, 600, FOE_HOT, HOT, 300.0, 2.0, PI * 0.55, PI * 1.45)
			_leaves(p, 40, 1.0)
			shake = maxf(shake, 11.0)
			sfx("lib-impact-bass-2", 0.6)
			sfx("lib-chime", 0.35)
			foe.pos.x -= 18.0

	# ---- hậu quả: trượt lùi, quỳ một gối thủ lễ
	if hit:
		var k := clampf((t - PEAK) / 1.1, 0.0, 1.0)
		var kk := smooth(PEAK + 0.9, PEAK + 1.6, t)
		foe.pos = Vector2(lerpf(x_hit, x_hit - 170.0, ease_out(k)), GROUND)
		foe.push = (1.0 - kk) * (1.0 - smooth(PEAK + 0.2, PEAK + 0.8, t))
		foe.both = 1.0 - kk
		foe.extra = [["guard", (1.0 - kk) * smooth(PEAK + 0.2, PEAK + 0.6, t)], [LE, kk]]
		foe.lean = -0.4 * (1.0 - kk) * k
		foe.aura = maxf(0.0, 0.6 - k)
		foe.expr = "soc" if kk < 0.5 else "binh"
		if k > 0.1 and k < 0.9 and int(t * 30) % 2 == 0:
			emit("smoke", Vector2(foe.pos.x + 40, GROUND), Vector2(rng.randf_range(20, 120), -rng.randf_range(10, 60)), 1.4, rng.randf_range(24, 46), Color(0.35, 0.24, 0.16, 0.35))
		if kk >= 0.98 and not foe.has("landed"):
			foe.landed = true
			shake = maxf(shake, 8.0)
			sfx("lib-impact-bass-2", 0.5)
			for i in 14:
				emit("smoke", Vector2(foe.pos.x + rng.randf_range(-60, 80), GROUND), Vector2(rng.randf_range(-120, 120), -rng.randf_range(20, 90)), 1.8, rng.randf_range(30, 70), Color(0.38, 0.26, 0.18, 0.4))


func _peak(p: Vector2) -> void:
	hit = true
	x_hit = foe.pos.x
	flash = 0.55
	flash_col = Color(0.9, 1.0, 0.92)
	shake = 30.0
	for i in 6:
		ripples.append([p, t + i * 0.06, 520.0 + i * 60.0, 1.4])
	add_ring(p, 520, HOT, 16, 0.7, 2.4)
	add_ring(Vector2(WALL_X, GROUND), 600, FOE_COL, 8, 0.9, 0.18)
	burst(p, 120, 300, 1400, FOE_HOT, HOT, 260.0, 1.6, PI * 0.5, PI * 1.5)
	_leaves(p, 260, 2.2)
	sfx("lib-impact-bass-1", 1.0)
	sfx("lib-impact-bass-2", 1.0)
	sfx("lib-sparkle", 0.5)


func _leaves(p: Vector2, n: int, power: float) -> void:
	for i in n:
		var a := rng.randf_range(PI * 0.55, PI * 1.45)
		var v := Vector2(cos(a), sin(a)) * rng.randf_range(80, 420) * power
		var col := LEAF.lerp(Color(1.2, 0.95, 0.45), rng.randf() * 0.6)
		emit("leaf", p + Vector2(rng.randf_range(-10, 10), rng.randf_range(-90, 90) * power * 0.5), v, rng.randf_range(2.2, 4.5), rng.randf_range(5, 11), col, 140.0, 2.4)


func _cam() -> Array:
	var c := CENTER
	var z := 1.0
	var k1 := smooth(0.9, 1.7, t) * (1.0 - smooth(2.2, 2.6, t))      # tụ khí: đẩy vào sư ông
	c = c.lerp(hero.pos + Vector2(-110, -230), k1)
	z = lerpf(z, 1.36, k1)
	var k2 := smooth(5.3, 5.95, t) * (1.0 - smooth(PEAK + 0.9, 8.6, t)) # đỉnh: ngay mặt tường
	c = c.lerp(Vector2(WALL_X - 60, 610), k2)
	z = lerpf(z, 1.22, k2)
	var k3 := smooth(8.4, 10.2, t)
	c = c.lerp(Vector2(900, 580), k3)
	return [c, z]


# ---- nền: gác kinh đêm (tủ sơn mài đen viền vàng thếp, cột son, sàn gỗ bóng)
func _fx_ground(c: Node2D) -> void:
	var lac := Color("#120a07")
	var gilt := Color("#9a7834")
	var cin := Color("#7a2318")
	for i in 10:
		var x0 := -260.0 + i * 250.0
		c.draw_rect(Rect2(x0, 210, 220, GROUND - 210), lac)
		c.draw_rect(Rect2(x0, 210, 220, GROUND - 210), gilt * Color(1, 1, 1, 0.55), false, 2.0)
		for r in 5:
			var y := 250.0 + r * 118.0
			c.draw_line(Vector2(x0 + 6, y + 104), Vector2(x0 + 214, y + 104), gilt * Color(1, 1, 1, 0.45), 2.0)
	for s in scrolls:
		var x0: float = -260.0 + int(s[0]) * 250.0 + 14.0 + float(s[2]) * 170.0
		var y0: float = 250.0 + int(s[1]) * 118.0 + 70.0
		var cc: Color = [Color("#d9cfb4"), cin, Color("#4d5a3a")][int(s[3])]
		c.draw_rect(Rect2(x0, y0, 30, 34), cc * Color(0.55, 0.55, 0.55))
		c.draw_circle(Vector2(x0 + 15, y0 + 17), 9, cc * Color(0.8, 0.8, 0.8))
		c.draw_circle(Vector2(x0 + 15, y0 + 17), 3, gilt)
	for px in [120.0, 1800.0]:
		c.draw_rect(Rect2(px - 34, 120, 68, GROUND - 120), cin)
		c.draw_rect(Rect2(px - 34, 120, 12, GROUND - 120), Color("#a5402c"))
		c.draw_rect(Rect2(px - 44, GROUND - 40, 88, 40), Color("#2a1a12"))
	c.draw_rect(Rect2(-600, 110, W + 1200, 26), lac)
	c.draw_line(Vector2(-600, 136), Vector2(W + 600, 136), gilt, 3.0)
	for i in 40:
		var x := -400.0 + i * 75.0
		c.draw_line(Vector2(x, GROUND + 4), Vector2(x - 180.0 + (x - 960.0) * 0.4, H + 300), Color(0.6, 0.45, 0.2, 0.08), 2.0)
	flat_blob(c, Vector2(WALL_X, GROUND + 6), 260, 0.12, Color(COL.r, COL.g, COL.b, 0.08 + 0.25 * _wall_k()))


func _wall_k() -> float:
	var k := 0.0
	for r in ripples:
		var a: float = t - float(r[1])
		if a > 0.0:
			k = maxf(k, (1.0 - clampf(a / 1.4, 0.0, 1.0)) * float(r[3]))
	return clampf(k, 0.0, 1.0)


# ---- lá vàng thếp rơi (vật thể đặc)
func _fx_norm(c: Node2D) -> void:
	for q in parts:
		if q.k != "leaf":
			continue
		var a: float = q.life / q.max
		var s: float = q.size
		var flip := sin(rt * 6.0 + q.rot * 3.0)
		var p: Vector2 = q.p + Vector2(sin(rt * 2.5 + q.rot) * 16.0, 0)
		var col: Color = q.col
		col.a = minf(1.0, a * 2.0)
		c.draw_set_transform(p, q.rot + rt * 1.3, Vector2(1.0, maxf(0.15, absf(flip))))
		c.draw_colored_polygon(PackedVector2Array([Vector2(-s, 0), Vector2(0, -s * 0.7), Vector2(s, 0), Vector2(0, s * 0.7)]), col)
		c.draw_line(Vector2(-s * 0.6, 0), Vector2(s * 0.6, 0), col * Color(0.7, 0.55, 0.3), 1.0)
		c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _fx_add(c: Node2D) -> void:
	# đèn dầu treo
	blob(c, Vector2(1520, 300), 140, Color(1.0, 0.6, 0.25, 0.16))
	blob(c, Vector2(1520, 300), 22, Color(1.8, 1.2, 0.5))
	blob(c, Vector2(330, 280), 120, Color(1.0, 0.6, 0.25, 0.12))
	blob(c, Vector2(330, 280), 18, Color(1.6, 1.1, 0.45))
	# chưởng bay: sóng vàng hình trăng khuyết
	for s in shots:
		if s[3] or t < float(s[0]):
			continue
		var x := _shot_x(s)
		var sz: float = s[2]
		var p := Vector2(x, float(s[1]))
		blob(c, p, 70 * sz, FOE_COL * Color(1, 1, 1, 0.3))
		crescent(c, p, 52 * sz, -1.2, 1.2, 0.0, FOE_COL * Color(1, 1, 1, 0.8), FOE_HOT)
		for j in 4:
			blob(c, p - Vector2(40 + j * 34, 0) * sz, (26 - j * 5) * sz, FOE_COL * Color(1, 1, 1, 0.25))
	# tụ chưởng lớn ở tay
	var wind := smooth(4.9, 5.7, t) * (1.0 - smooth(PEAK - FLY - 0.08, PEAK - FLY, t))
	if wind > 0.0:
		blob(c, foe.hand, 110 * wind, FOE_COL * Color(1, 1, 1, 0.3))
		blob(c, foe.hand, 40 * wind, FOE_HOT)
	# bức tường: chỉ hiện quanh chỗ bị chạm, gợn như mặt hồ dựng đứng (vòng elip hẹp theo x)
	var wk := _wall_k()
	if wk > 0.01:
		var top := GROUND - 560.0
		for i in 22:
			var y := lerpf(top, GROUND, float(i) / 21.0)
			var wob := sin(y * 0.03 + rt * 9.0) * 6.0 * wk
			c.draw_line(Vector2(WALL_X + wob, y), Vector2(WALL_X + wob, y + 18), COL * Color(1, 1, 1, 0.18 * wk), 3.0)
	for r in ripples:
		var a: float = t - float(r[1])
		if a < 0.0 or a > 1.4:
			continue
		var p: Vector2 = r[0]
		var mx: float = r[2]
		var st: float = r[3]
		c.draw_set_transform(p, 0.0, Vector2(0.26, 1.0))
		for j in 3:
			var k := clampf((a - j * 0.12) / 1.2, 0.0, 1.0)
			if k <= 0.0 or k >= 1.0:
				continue
			var rr := mx * ease_out(k)
			var al := (1.0 - k) * 0.75 * minf(1.0, st)
			c.draw_arc(Vector2.ZERO, rr, 0, TAU, 72, HOT * Color(1, 1, 1, al), 5.0 * (1.0 - k) + 1.5)
			c.draw_arc(Vector2.ZERO, rr * 0.92, 0, TAU, 72, COL * Color(1, 1, 1, al * 0.4), 10.0 * (1.0 - k))
		c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		blob(c, p, 60 * (1.0 - clampf(a / 0.4, 0.0, 1.0)) * st, HOT * Color(1, 1, 1, 0.5))
