extends "res://engine.gd"
# __TITLE__: file mẫu theo nhịp 5 đoạn (SKILL.md Rule 1). Chạy được ngay, thay phần [CƠ CHẾ] bằng cơ chế đặc trưng của chiêu.
# Thẻ chiêu: người dùng · đối thủ · cơ chế · màu · bối cảnh · khoảnh khắc đỉnh

const COL := Color(1.4, 0.9, 0.3)        # màu chủ đạo
const HOT := Color(2.2, 1.7, 0.9)        # lõi nóng (>1.5 để bloom)
const FOE_COL := Color(0.5, 0.4, 1.6)    # màu đối thủ, tương phản
const BEATS := [2.6, 3.6, 4.6]           # nhịp biểu diễn
const PEAK := 6.1                        # va chạm lớn

var beat_i := 0
var hit := false
var x_hit := 0.0


func _setup() -> void:
	# nền: tương phản với áo người ra chiêu, khác 3 chiêu gần nhất
	sky_cols = [Color("#0a0814"), Color("#241a3a"), Color("#5a3a4e")]
	far_col = Color("#2e2448")
	near_col = Color("#1e1830")
	ground_cols = [Color("#30283a"), Color("#141018"), Color("#54465e")]
	slowmo = [PEAK - 0.05, PEAK + 0.6, 0.3]
	title = "__TITLE__"
	title_at = 8.5
	title_col = HOT
	set_char(hero, "tieu-phong")
	set_char(foe, "lao-ma")
	hero.col = COL
	foe.col = FOE_COL
	cue(1.0, "lib-riser", 0.7)
	cue(PEAK - 0.3, "lib-whoosh-cinematic", 0.9)


func _story(dt: float) -> void:
	# ---- người ra chiêu
	hero.gather = smooth(1.0, 1.8, t) * (1.0 - smooth(2.3, 2.5, t))
	var bp := 0.0
	for b in BEATS:
		bp = maxf(bp, pulse(b - 0.1, b + 0.1, 0.25, t))
	var big := smooth(5.0, 5.8, t) * (1.0 - smooth(PEAK - 0.1, PEAK, t))
	hero.push = bp + smooth(PEAK - 0.1, PEAK, t) * (1.0 - smooth(8.5, 9.5, t))
	hero.extra = [["windup", big]]
	hero.lean = hero.push * 0.3
	hero.aura = smooth(1.0, 1.8, t) * 0.6 + big * 0.6 - smooth(7.0, 9.0, t) * 0.8
	hero.expr = "dac-y" if t > 8.3 else ("quyet-tam" if t > 1.0 else "binh")
	# ---- đối thủ
	if not hit:
		foe.gather = smooth(4.8, 5.6, t)
		foe.aura = foe.gather * 0.8
		foe.extra = [["guard", pulse(2.5, 4.8, 0.3, t)]]
		foe.expr = "soc" if t > 4.0 else "gian"
	pose(hero, 0.0)
	pose(foe, 0.0)
	var hp: Vector2 = hero.hand

	if hero.gather > 0.05:
		orbit(hero, rng.randf_range(120, 300), rng.randf_range(2.0, 3.5), 260, rng.randf_range(2, 5), HOT, 2.5)

	# ---- [CƠ CHẾ] mỗi nhịp một tác động nhỏ (thay bằng cơ chế đặc trưng)
	if beat_i < BEATS.size() and t >= BEATS[beat_i]:
		var at: Vector2 = foe.pos + Vector2(-30, -180)
		add_ring(at, 220, HOT, 8, 0.35)
		burst(at, 30, 300, 900, HOT, COL, 600.0, 1.4, -PI * 0.6, PI * 0.6)
		shake = maxf(shake, 12.0)
		sfx("lib-impact-bass-2", 0.6)
		foe.pos.x += 20.0
		beat_i += 1

	# ---- đỉnh
	if t >= PEAK and not hit:
		hit = true
		x_hit = foe.pos.x
		foe.expr = "ko"
		flash = 0.7
		shake = 32.0
		var at: Vector2 = foe.pos + Vector2(0, -180)
		add_ring(at, 700, HOT, 20, 0.7)
		add_ring(Vector2(at.x, GROUND), 800, COL, 10, 0.9, 0.2)
		burst(at, 140, 300, 1600, HOT, Color(2, 2, 2), 800.0, 1.0)
		sfx("lib-impact-bass-1", 1.0)
		sfx("lib-impact-bass-2", 1.0)
	# ---- hậu quả: văng theo cung, đáp trong khung
	if hit:
		var k := clampf((t - PEAK) / 0.9, 0.0, 1.0)
		foe.pos = Vector2(lerpf(x_hit, 1490.0, ease_out(k)), GROUND - sin(k * PI) * 130.0)
		foe.rot = ease_out(k) * PI * 0.5
		foe.hurt = 1.0
		foe.extra = []
		foe.aura = 0.0
		if k >= 1.0 and not foe.has("landed"):
			foe.landed = true
			shake = maxf(shake, 14.0)
			sfx("lib-impact-bass-2", 0.5)
			for i in 20:
				emit("smoke", Vector2(1490 + rng.randf_range(-40, 240), GROUND), Vector2(rng.randf_range(-160, 220), -rng.randf_range(20, 140)), 2.0, rng.randf_range(40, 90), Color(0.5, 0.45, 0.55, 0.45))


func _cam() -> Array:
	var c := CENTER
	var z := 1.0
	var k1 := smooth(0.9, 1.7, t) * (1.0 - smooth(2.2, 2.6, t))      # tụ khí
	c = c.lerp(hero.pos + Vector2(120, -220), k1)
	z = lerpf(z, 1.35, k1)
	var k2 := smooth(5.4, 6.0, t) * (1.0 - smooth(PEAK + 0.8, 9.0, t))  # đỉnh
	c = c.lerp(Vector2(1150, 600), k2)
	z = lerpf(z, 1.2, k2)
	var k3 := smooth(8.5, 10.5, t)                                     # kết: zoom 1.0 thấy cả hai
	c = c.lerp(Vector2(1000, 590), k3)
	return [c, z]


func _fx_add(c: Node2D) -> void:
	var big := smooth(5.0, 5.8, t) * (1.0 - smooth(PEAK, PEAK + 0.3, t))
	if big > 0.0:
		blob(c, hero.hand, 120 * big, COL * Color(1, 1, 1, 0.35))
		blob(c, hero.hand, 50 * big, HOT)
	if t > PEAK - 0.1 and t < PEAK + 0.25:
		beam(c, hero.hand, foe.pos + Vector2(0, -180), COL, HOT, 60.0)
