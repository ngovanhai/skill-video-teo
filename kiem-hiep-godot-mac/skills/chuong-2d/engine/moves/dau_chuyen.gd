extends "res://engine.gd"
# ĐẨU CHUYỂN TINH DI (Thiên Long Bát Bộ): gia truyền Cô Tô Mộ Dung, "lấy đạo của người trả lại người".
# Thẻ chiêu: Mộ Dung Phục · một cao thủ áo đen giang hồ (minh hoạ, không phải trận cụ thể; chưởng lửa hình lưỡi đao) · bảy sao Bắc Đẩu mọc quanh người,
#   lưỡi lửa của địch rơi vào lòng gáo, chòm sao XOAY một vòng (đẩu chuyển) rồi nhả lưỡi lửa bay ngược về chủ;
#   đỉnh: hiện một bóng mờ của chính đối thủ đứng cạnh Mộ Dung, ra đúng thế chưởng của hắn, đánh hắn bằng võ của hắn
# · bạc lam ánh sao vs cam lửa · đêm hồ Giang Nam (Yến Tử Ổ): nước đen lục phản chiếu sao, lá sen, thuỷ tạ xa
# · khoảnh khắc đỉnh: bóng Cưu Ma Trí màu lửa giơ đúng tay của hắn, lưỡi lửa khổng lồ quay đầu.

const COL := Color(0.75, 0.95, 1.6)      # bạc lam ánh sao
const HOT := Color(1.6, 1.9, 2.5)
const FIRE := Color(1.8, 0.75, 0.22)     # Hoả Diễm Đao
const FIRE_HOT := Color(2.4, 1.5, 0.6)
const HX := 560.0
const FX := 1380.0
# mỗi nhịp: lưỡi lửa bay tới (b-0.55 → b), chòm sao xoay (b → b+0.55), bay ngược về (b+0.55 → b+0.9)
const BEATS := [2.75, 4.15]
const BIG := 5.75                         # lưỡi lửa lớn tới lòng gáo
const PEAK := BIG + 0.55 + 0.3            # lưỡi lửa lớn quay về trúng chủ

# bảy sao (hướng mặt phải): 4 sao lòng gáo phía đối thủ + 3 sao cán vòng ra sau đầu
const STARS := [Vector2(190, -40), Vector2(205, 60), Vector2(300, 66), Vector2(292, -36), Vector2(110, -140), Vector2(10, -200), Vector2(-100, -214)]

var beat_i := 0
var hit := false
var x_hit := 0.0
var ghost: Node2D
var reflect: Array = []
var pads: Array = []


func _setup() -> void:
	sky_cols = [Color("#050d16"), Color("#0f2a33"), Color("#1d4642")]
	moon_on = false
	n_stars = 0
	far_col = Color("#10282b")
	near_col = Color("#081416")
	mist_col = Color(0.45, 0.7, 0.72, 0.14)
	ground_cols = [Color("#0d2624"), Color("#040b0c"), Color("#2e5a54")]
	slowmo = [PEAK - 0.12, PEAK + 0.5, 0.3]
	title = "ĐẨU CHUYỂN TINH DI"
	subtitle = "Mộ Dung Phục · lấy đạo của người, trả lại cho người"
	title_at = 8.4
	title_col = HOT
	set_char(hero, "mo-dung-phuc")
	set_char(foe, "cao-thu")
	hero.pos = Vector2(HX, GROUND)
	foe.pos = Vector2(FX, GROUND)
	hero.col = COL
	foe.col = FIRE
	ghost = Chibi.new()
	l_chars.add_child(ghost)
	ghost.setup("cao-thu")
	ghost.visible = false
	for i in 220:
		stars.append([Vector2(rng.randf_range(0, W), rng.randf_range(0, 520)), rng.randf_range(0.8, 2.4), rng.randf() * TAU])
	for i in 90:
		reflect.append([rng.randf_range(-200, W + 200), rng.randf_range(GROUND + 20, H + 60), rng.randf_range(20, 120), rng.randf() * TAU])
	for q in [[180, 905, 70], [420, 990, 54], [1640, 930, 80], [1820, 1010, 60], [1010, 1040, 48], [80, 1050, 64]]:
		pads.append(Vector3(q[0], q[1], q[2]))
	cue(1.0, "lib-riser", 0.8)
	for b in BEATS:
		cue(b - 0.55, "lib-whoosh", 0.6)
		cue(b, "lib-sparkle", 0.45)
		cue(b + 0.55, "lib-whoosh-short", 0.6)
	cue(BIG - 0.9, "lib-riser", 0.7)
	cue(BIG, "lib-chime", 0.45)
	cue(PEAK - 0.3, "lib-whoosh-cinematic", 0.9)


func _center() -> Vector2:
	return hero.pos + Vector2(20, -230)


func _spin() -> float:
	var s := 0.0
	for b in BEATS:
		s += TAU * smooth(b, b + 0.55, t)
	s += TAU * smooth(BIG, BIG + 0.55, t)
	return s


func _star(i: int) -> Vector2:
	var v: Vector2 = STARS[i]
	return _center() + v.rotated(_spin())


func _bowl() -> Vector2:
	return (_star(0) + _star(1) + _star(2) + _star(3)) * 0.25


func _dipper() -> float:
	return smooth(1.1, 2.0, t) * (1.0 - smooth(7.4, 8.6, t))


# vị trí lưỡi lửa của nhịp bắt đầu ở b (độ lớn sc); trả [pos, hướng, alpha]
func _blade_at(b: float, sc: float) -> Array:
	var src: Vector2 = foe.pos + Vector2(-150, -230)
	if t < b - 0.55 or t > b + 0.55 + 0.3 * sc + 0.05:
		return [Vector2.ZERO, 0.0, 0.0]
	if t < b:
		var k := smooth(b - 0.55, b, t)
		return [src.lerp(_bowl(), k), PI, 1.0]
	if t < b + 0.55:
		var a := _spin() + PI * 0.5
		return [_bowl(), a, 1.0]
	var k2 := smooth(b + 0.55, b + 0.55 + 0.3 * sc, t)
	return [_bowl().lerp(foe.pos + Vector2(-40, -200), k2), 0.0, 1.0]


func _story(dt: float) -> void:
	# ---- Mộ Dung Phục: tụ khí, một tay dựng trước ngực như cầm cán gáo, tay kia xoay theo chòm sao
	hero.gather = smooth(1.0, 1.8, t) * (1.0 - smooth(2.2, 2.5, t))
	var turning := 0.0
	for b in BEATS + [BIG]:
		turning = maxf(turning, pulse(b - 0.05, b + 0.6, 0.12, t))
	hero.extra = [["guard", 0.35 + turning * 0.4], ["raise", turning * 0.35]]
	hero.push = pulse(PEAK - 0.6, PEAK + 0.6, 0.2, t) * 0.6
	hero.lean = -turning * 0.15
	hero.aura = smooth(1.0, 1.8, t) * 0.5 + turning * 0.3 - smooth(7.5, 9.0, t) * 0.8
	hero.expr = "dac-y" if t > 8.0 else ("quyet-tam" if t > 1.0 else "binh")
	# ---- Cưu Ma Trí: chém Hoả Diễm Đao (tay F chém xuống trước mỗi nhịp)
	if not hit:
		var chem := 0.0
		for b in BEATS + [BIG]:
			chem = maxf(chem, pulse(b - 0.75, b - 0.5, 0.12, t))
		var gom := smooth(BIG - 1.4, BIG - 0.75, t) * (1.0 - smooth(BIG - 0.6, BIG - 0.5, t))
		foe.extra = [["windup", gom], ["slash", chem], ["guard", pulse(BEATS[0] + 0.75, BEATS[0] + 1.1, 0.12, t) + pulse(BEATS[1] + 0.75, BEATS[1] + 1.1, 0.12, t)]]
		foe.gather = gom * 0.6
		foe.aura = 0.4 + gom * 0.6
		foe.expr = "soc" if t > BIG + 0.3 else ("gian" if t < BEATS[1] + 0.8 else "quyet-tam")
	pose(hero, 0.0)
	pose(foe, 0.0)

	if hero.gather > 0.05:
		orbit(hero, rng.randf_range(140, 300), rng.randf_range(2.0, 3.2), 240, rng.randf_range(2, 4), HOT, 2.4)
	# lửa cháy trên tay Cưu Ma Trí
	if not hit and foe.aura > 0.1:
		for i in 2:
			emit("add", foe.handF + Vector2(rng.randf_range(-14, 14), rng.randf_range(-10, 10)), Vector2(rng.randf_range(-30, 30), -rng.randf_range(80, 200)), 0.5, rng.randf_range(10, 22), FIRE * Color(1, 1, 1, 0.35))
	# vệt sao rơi khi chòm sao xoay
	if _dipper() > 0.3 and turning > 0.3:
		for i in 7:
			emit("add", _star(i), Vector2(rng.randf_range(-40, 40), rng.randf_range(-40, 40)), 0.45, rng.randf_range(5, 10), COL * Color(1, 1, 1, 0.5))

	# ---- nhịp nhỏ: lửa quay về trúng chủ
	if beat_i < BEATS.size() and t >= BEATS[beat_i] + 0.85:
		var at: Vector2 = foe.pos + Vector2(-40, -200)
		add_ring(at, 200, FIRE_HOT, 8, 0.35)
		burst(at, 34, 300, 900, FIRE_HOT, FIRE, 500.0, 1.4, -PI * 0.7, PI * 0.7)
		shake = maxf(shake, 12.0)
		sfx("lib-impact-bass-2", 0.6)
		foe.pos.x += 30.0
		foe.tint = Color(1.4, 0.85, 0.6)
		beat_i += 1
	foe.tint = foe.tint.lerp(Color(1, 1, 1), 0.08)

	# ---- bóng mờ của chính đối thủ, ra đúng thế chém của hắn
	var gk := smooth(BIG - 0.1, BIG + 0.35, t) * (1.0 - smooth(PEAK + 0.4, PEAK + 1.1, t))
	ghost.visible = gk > 0.02
	if ghost.visible:
		ghost.position = hero.pos + Vector2(250, -26)
		ghost.scale = Vector2(-1.0 * -1.0, 1.0) * CS * 1.12     # quay mặt về phía Cưu Ma Trí
		var sl := smooth(PEAK - 0.45, PEAK - 0.3, t)
		var gp := Chibi.mix(Chibi.P("stance"), Chibi.POSES.windup, 1.0 - sl)
		gp = Chibi.mix(gp, Chibi.POSES.slash, sl)
		ghost.apply(gp, dt)
		ghost.set_expr("gian")
		ghost.modulate = Color(1.7, 0.9, 0.45, 0.55 * gk)

	# ---- đỉnh
	if t >= PEAK and not hit:
		hit = true
		x_hit = foe.pos.x
		foe.expr = "ko"
		flash = 0.6
		flash_col = Color(1.0, 0.9, 0.8)
		shake = 30.0
		var at: Vector2 = foe.pos + Vector2(0, -200)
		add_ring(at, 680, FIRE_HOT, 20, 0.7)
		add_ring(at, 420, HOT, 10, 0.6, 1.0, 0.08)
		add_ring(Vector2(at.x, GROUND), 760, COL, 10, 0.9, 0.2)
		burst(at, 150, 300, 1500, FIRE_HOT, HOT, 700.0, 1.0)
		sfx("lib-impact-bass-1", 1.0)
		sfx("lib-impact-bass-2", 1.0)
	# ---- hậu quả: bị chính lửa mình hất, xoay một vòng theo chòm sao, đáp đứng lảo đảo, sao quay quanh đầu
	if hit:
		var k := clampf((t - PEAK) / 1.0, 0.0, 1.0)
		foe.pos = Vector2(lerpf(x_hit, 1480.0, ease_out(k)), GROUND - sin(k * PI) * 150.0)
		foe.rot = ease_out(k) * TAU
		foe.hurt = (1.0 - k) * 0.9
		foe.crouch = k * 0.5 + pulse(PEAK + 1.0, PEAK + 1.4, 0.15, t) * 0.4
		foe.extra = [["guard", k * 0.4]]
		foe.aura = 0.0
		foe.expr = "ko" if t < PEAK + 2.4 else "soc"
		if k >= 1.0 and not foe.has("landed"):
			foe.landed = true
			shake = maxf(shake, 12.0)
			sfx("lib-impact-bass-2", 0.5)
			for i in 18:
				emit("smoke", Vector2(1480 + rng.randf_range(-60, 160), GROUND), Vector2(rng.randf_range(-160, 200), -rng.randf_range(20, 120)), 2.0, rng.randf_range(40, 90), Color(0.35, 0.5, 0.5, 0.4))


func _cam() -> Array:
	var c := CENTER
	var z := 1.0
	var k1 := smooth(0.9, 1.7, t) * (1.0 - smooth(2.2, 2.7, t))
	c = c.lerp(hero.pos + Vector2(140, -230), k1)
	z = lerpf(z, 1.35, k1)
	var k2 := smooth(BIG - 0.5, BIG, t) * (1.0 - smooth(PEAK + 0.8, 9.0, t))
	c = c.lerp(Vector2(1000, 600), k2)
	z = lerpf(z, 1.18, k2)
	var k3 := smooth(8.5, 10.5, t)
	c = c.lerp(Vector2(1000, 590), k3)
	return [c, z]


func _fx_ground(c: Node2D) -> void:
	# mặt hồ: sao phản chiếu lăn tăn + lá sen
	for r in reflect:
		var x: float = r[0] + sin(rt * 0.7 + r[3]) * 12.0
		var a := 0.12 + 0.1 * sin(rt * 2.0 + r[3])
		c.draw_line(Vector2(x - r[2] * 0.5, r[1]), Vector2(x + r[2] * 0.5, r[1]), Color(0.6, 0.85, 0.9, a), 2.0)
	var d := _dipper()
	if d > 0.0:
		for i in 7:
			var s := _star(i)
			var m := Vector2(s.x, GROUND + (GROUND - s.y) * 0.35 + 10.0)
			flat_blob(c, m, 26.0, 0.3, Color(0.7, 0.9, 1.0, 0.2 * d))
	for p in pads:
		c.draw_set_transform(Vector2(p.x, p.y), 0.0, Vector2(1.0, 0.36))
		c.draw_circle(Vector2.ZERO, p.z, Color("#163a2c"))
		c.draw_circle(Vector2.ZERO, p.z * 0.92, Color("#1f4a36"))
		c.draw_line(Vector2.ZERO, Vector2(p.z * 0.9, -p.z * 0.2), Color("#0d2a20"), 3.0)
		c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _fx_add(c: Node2D) -> void:
	var d := _dipper()
	if d > 0.0:
		# đường nối chòm sao
		var order := [[0, 1], [1, 2], [2, 3], [3, 0], [0, 4], [4, 5], [5, 6]]
		for e in order:
			c.draw_line(_star(e[0]), _star(e[1]), COL * Color(1, 1, 1, 0.35 * d), 3.0)
		# vòng quỹ đạo mờ
		var ctr := _center()
		c.draw_arc(ctr, 300.0, 0.0, TAU, 72, COL * Color(1, 1, 1, 0.08 * d), 2.0)
		for i in 7:
			var s := _star(i)
			var tw := 0.8 + 0.2 * sin(rt * 9.0 + i)
			blob(c, s, 34.0 * d, COL * Color(1, 1, 1, 0.25))
			blob(c, s, 12.0 * d * tw, HOT)
			c.draw_line(s - Vector2(18, 0) * d, s + Vector2(18, 0) * d, HOT * Color(1, 1, 1, 0.5), 2.0)
			c.draw_line(s - Vector2(0, 18) * d, s + Vector2(0, 18) * d, HOT * Color(1, 1, 1, 0.5), 2.0)
	# lưỡi lửa
	for b in BEATS:
		_draw_blade(c, _blade_at(b, 1.0), 1.0)
	_draw_blade(c, _blade_at(BIG, 1.0), 2.2)
	if t > BIG + 0.55 and t < PEAK + 0.05:
		speed_lines(c, _bowl().x, 1.0, 1.0, FIRE * Color(1, 1, 1, 0.3))


func _draw_blade(c: Node2D, st: Array, sc: float) -> void:
	var a: float = st[2]
	if a <= 0.0:
		return
	var p: Vector2 = st[0]
	var ang: float = st[1]
	var n := 14
	var outer := PackedVector2Array()
	var inner := PackedVector2Array()
	for i in n + 1:
		var u := -0.9 + 1.8 * float(i) / n
		outer.append(p + Vector2(cos(u) * 70.0, sin(u) * 95.0).rotated(ang) * sc)
	for i in n + 1:
		var u := 0.9 - 1.8 * float(i) / n
		inner.append(p + Vector2(cos(u) * 40.0 + 6.0, sin(u) * 70.0).rotated(ang) * sc)
	var poly := outer.duplicate()
	poly.append_array(inner)
	c.draw_colored_polygon(poly, FIRE * Color(1, 1, 1, 0.55 * a))
	blob(c, p, 60.0 * sc, FIRE * Color(1, 1, 1, 0.22))
	blob(c, p + Vector2(50, 0).rotated(ang) * sc, 18.0 * sc, FIRE_HOT * Color(1, 1, 1, 0.8))
	for i in 2:
		emit("add", p + Vector2(rng.randf_range(-30, 30), rng.randf_range(-40, 40)) * sc, Vector2(rng.randf_range(-60, 60), -rng.randf_range(40, 140)), 0.35, rng.randf_range(8, 16) * sc, FIRE * Color(1, 1, 1, 0.3))


func _fx_ui(c: Node2D) -> void:
	# sao quay quanh đầu đối thủ lúc choáng
	if hit and t > PEAK + 1.0:
		var hp: Vector2 = foe.head + Vector2(0, -40)
		var k := smooth(PEAK + 1.0, PEAK + 1.3, t) * (1.0 - smooth(PEAK + 3.2, PEAK + 3.6, t))
		var sp := world.get_global_transform() * hp
		for i in 3:
			var a := rt * 5.0 + i * TAU / 3.0
			var q := sp + Vector2(cos(a) * 70.0, sin(a) * 18.0)
			c.draw_circle(q, 9.0 * k, Color(1.0, 0.95, 0.6, k))
			c.draw_circle(q, 4.0 * k, Color(1, 1, 1, k))
