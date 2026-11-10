extends "res://engine.gd"
# SƯ TỬ HỐNG (12.5 s): hội Dương Đao Lập Uy trên đảo Vương Bàn Sơn, giữa trưa, đá trắng, biển chàm, cờ đỏ.
# Thẻ chiêu:
#   người dùng   Tạ Tốn "Kim Mao Sư Vương" (tóc vàng, sau này mù), đến cướp Đồ Long đao
#   đối thủ      hảo hán phái Hải Sa có mặt ở hội (quần hùng trên đảo đều trúng tiếng gầm)
#   cơ chế       SÓNG ÂM: hít căng ngực -> gầm; vòng cung âm thanh đồng tâm lan từ miệng, đập vào vách đá trắng
#                rồi DỘI NGƯỢC lại (tiếng vọng), mặt biển gợn theo từng vòng. Hai tiếng gầm nhỏ (đối thủ bịt tai, lùi,
#                tái mặt) rồi tiếng gầm đỉnh: vòng âm dày đặc, vách đá rơi đá vụn, cờ rách phần phật.
#   cặp màu      sóng âm đồng thau + lõi bạch kim  vs  khí lục biển của đối thủ
#   bối cảnh     giữa trưa, trời xanh sáng, vách đá vôi trắng, biển chàm, nền đá trắng, cờ đỏ son của Thiên Ưng giáo
#   đỉnh         slowmo khi vòng âm lớn chạm người: đối thủ bị hất văng theo cung, đáp nằm choáng,
#                vòng âm nhỏ còn xoay trên đầu (ù tai), Tạ Tốn khép miệng đắc ý.

const COL := Color(1.55, 1.1, 0.42)       # sóng âm đồng thau
const HOT := Color(2.1, 2.0, 1.8)         # lõi bạch kim
const FOE_COL := Color(0.25, 1.35, 1.05)  # khí lục biển
const RED := Color("#b8261c")
const CLIFF_X := 1760.0                   # vách đá dội âm (toạ độ world)
const BEATS := [2.6, 3.95]                # hai tiếng gầm nhỏ (miệng mở)
const ROAR := 5.75                        # tiếng gầm đỉnh bắt đầu
const PEAK := 6.1                         # vòng âm lớn chạm đối thủ
const LAND_X := 1500.0

# hít căng ngực: ngửa người, hai tay mở rộng ra sau
const INHALE := {"uaF": 40, "faF": -30, "uaB": -40, "faB": 30, "torso": 12, "head": 10, "thF": -16, "shF": 18, "thB": 16, "shB": -18, "all": [0, 0, 6]}
# gầm: rướn người tới, hai tay dang ngang về sau, gồng
const ROARP := {"uaF": 70, "faF": -20, "uaB": -70, "faB": 20, "torso": -14, "head": -10, "thF": -34, "shF": 30, "thB": 30, "shB": -12, "all": [0, 0, 18]}
# bịt tai: hai tay ôm lên đầu
const COVER := {"uaF": -150, "faF": -120, "uaB": 150, "faB": 120, "torso": 10, "head": 10, "thF": -14, "shF": 22, "thB": 16, "shB": -10, "all": [0, 0, 20]}

var waves: Array = []      # {o: tâm, t0, v: tốc độ, dir: 1/-1, n: số vòng, w: nét, a: alpha, refl: đã dội?}
var beat_i := 0
var hit := false
var x_hit := 0.0
var rocks_done := false
var flags: Array = []
var sea_lines: Array = []


func _setup() -> void:
	sky_cols = [Color("#5e93bd"), Color("#cfe2ea"), Color("#eef3ef")]
	moon = Vector2(1180, 120)
	moon_col = Color(1.6, 1.55, 1.35)
	moon_glow = Color(1.0, 0.98, 0.85, 0.35)
	moon_craters = false
	n_stars = 0
	far_col = Color("#e4ddcc")
	near_col = Color("#1d3566")
	mist_col = Color(1.0, 1.0, 1.0, 0.18)
	ground_cols = [Color("#ece5d4"), Color("#b4a88e"), Color("#7a6e58")]
	slowmo = [PEAK - 0.08, PEAK + 0.57, 0.3]
	title = "SƯ TỬ HỐNG"
	subtitle = "Ỷ Thiên Đồ Long Ký · Tạ Tốn"
	title_at = 8.3
	title_col = Color(1.75, 1.3, 0.55)
	set_char(hero, "ta-ton")
	set_char(foe, "hao-han-hai-sa")
	hero.pos = Vector2(520, GROUND)
	foe.pos = Vector2(1300, GROUND)
	hero.col = COL
	foe.col = FOE_COL
	cue(1.0, "lib-riser", 0.8)
	for b in BEATS:
		cue(b - 0.05, "lib-whoosh", 0.7)
		cue(b + 0.25, "lib-glitch-1", 0.45)
	cue(5.0, "lib-riser", 0.6)
	cue(ROAR, "lib-whoosh-cinematic", 0.9)
	flags = [[Vector2(250, GROUND), 330.0], [Vector2(1620, GROUND), 300.0]]
	for i in 34:
		sea_lines.append([rng.randf_range(-300, 2300), rng.randf_range(0.0, 1.0), rng.randf_range(40, 140)])


# miệng Tạ Tốn (world)
func _mouth() -> Vector2:
	return hero.head + Vector2(hero.face * 46.0, 68.0)


func _roar_k() -> float:
	var k := 0.0
	for b in BEATS:
		k = maxf(k, pulse(b, b + 0.55, 0.2, t))
	return maxf(k, pulse(ROAR, ROAR + 1.3, 0.4, t))


func _story(dt: float) -> void:
	# ---- Tạ Tốn: hít -> gầm, hai lần nhỏ rồi một lần lớn
	var inh := smooth(1.0, 2.0, t) * (1.0 - smooth(2.45, 2.6, t)) + pulse(3.4, 3.8, 0.15, t) + smooth(4.9, 5.6, t) * (1.0 - smooth(ROAR - 0.1, ROAR, t))
	var rk := _roar_k()
	hero.extra = [[INHALE, clampf(inh, 0.0, 1.0)], [ROARP, rk]]
	hero.lean = -0.4 * inh + 0.5 * rk
	hero.scale = 1.0 + 0.05 * inh
	hero.aura = smooth(1.0, 1.8, t) * 0.5 + rk * 0.5 + smooth(4.9, 5.6, t) * 0.4 - smooth(7.0, 9.0, t) * 1.2
	if t < 1.0:
		hero.expr = "binh"
	elif t > 8.0:
		hero.expr = "dac-y"
	elif rk > 0.3:
		hero.expr = "soc"     # miệng tròn mở = gầm
	else:
		hero.expr = "quyet-tam"
	# ---- đối thủ
	if not hit:
		var cov := smooth(BEATS[0] + 0.2, BEATS[0] + 0.4, t)
		foe.extra = [["stance", 1.0 - cov], [COVER, cov]]
		foe.aura = smooth(0.4, 1.0, t) * 0.5 * (1.0 - smooth(4.0, 5.0, t))
		foe.crouch = cov * 0.3 + smooth(BEATS[1] + 0.2, BEATS[1] + 0.5, t) * 0.25
		var pale := smooth(BEATS[0] + 0.3, 5.5, t)
		foe.tint = Color(1, 1, 1).lerp(Color(0.82, 1.0, 0.92), pale)
		foe.expr = "gian" if t < BEATS[0] + 0.25 else ("soc" if t < BEATS[1] + 0.3 else "ngai")
	pose(hero, 0.0)
	pose(foe, 0.0)
	var m := _mouth()

	# tụ khí: hạt đồng thau hút về miệng
	if inh > 0.15:
		for i in 3:
			var a := rng.randf() * TAU
			var r := rng.randf_range(200, 340)
			var p0 := m + Vector2(cos(a), sin(a)) * r
			emit("add", p0, (m - p0) * 2.4, 0.4, rng.randf_range(4, 8), COL * Color(1, 1, 1, 0.5))

	# ---- hai tiếng gầm nhỏ: phát vòng âm, chạm đối thủ, dội vách
	if beat_i < BEATS.size() and t >= BEATS[beat_i]:
		waves.append({"o": m, "t0": t, "v": 1250.0, "dir": 1.0, "n": 4, "w": 7.0, "a": 0.9, "refl": false, "hit": false})
		beat_i += 1
	var add: Array = []
	for wv in waves:
		var r: float = (t - wv.t0) * wv.v
		# chạm đối thủ (chỉ vòng đi tới)
		if wv.dir > 0.0 and not wv.hit and wv.o.x + r >= foe.pos.x - 40.0 and wv.t0 < ROAR:
			wv.hit = true
			var at: Vector2 = foe.head + Vector2(0, 40)
			add_ring(at, 200, HOT, 8, 0.35)
			burst(at, 26, 300, 800, COL, HOT, 500.0, 1.4, -PI * 0.5, PI * 0.5)
			shake = maxf(shake, 12.0)
			sfx("lib-impact-bass-2", 0.6)
			if not hit:
				foe.pos.x += 34.0
		# dội vách: sinh vòng đi ngược từ điểm đối xứng
		if wv.dir > 0.0 and not wv.refl and wv.o.x + r >= CLIFF_X:
			wv.refl = true
			add.append({"o": Vector2(2.0 * CLIFF_X - wv.o.x, wv.o.y), "t0": wv.t0, "v": wv.v, "dir": -1.0, "n": wv.n - 1, "w": wv.w * 0.6, "a": wv.a * 0.5, "refl": true, "hit": true})
			sfx("lib-impact-bass-2", 0.35)
	waves.append_array(add)

	# ---- tiếng gầm đỉnh
	if t >= ROAR and not waves.any(func(x): return x.t0 >= ROAR - 0.01):
		waves.append({"o": m, "t0": t, "v": 2200.0, "dir": 1.0, "n": 9, "w": 12.0, "a": 1.0, "refl": false, "hit": true})
		shake = maxf(shake, 16.0)
	if t >= PEAK and not hit:
		hit = true
		x_hit = foe.pos.x
		foe.expr = "ko"
		flash = 0.6
		flash_col = Color(1.0, 0.97, 0.88)
		shake = 34.0
		var at: Vector2 = foe.head + Vector2(0, 40)
		add_ring(at, 650, HOT, 18, 0.7)
		add_ring(Vector2(at.x, GROUND), 820, COL, 10, 0.9, 0.18)
		burst(at, 150, 300, 1700, HOT, COL, 700.0, 1.0)
		sfx("lib-impact-bass-1", 1.0)
		sfx("lib-impact-bass-2", 1.0)
	# đá vụn rơi khỏi vách khi vòng âm lớn dội
	if t >= PEAK + 0.15 and not rocks_done:
		rocks_done = true
		for i in 26:
			emit("rock", Vector2(CLIFF_X + rng.randf_range(-60, 160), rng.randf_range(260, 520)), Vector2(rng.randf_range(-260, 40), rng.randf_range(-120, 60)), 2.2, rng.randf_range(8, 22), Color("#cfc6b2"), 1100.0)
		sfx("lib-impact-bass-2", 0.6)
	# ---- hậu quả: văng theo cung, đáp nằm trong khung, ù tai
	if hit:
		var k := clampf((t - PEAK) / 1.0, 0.0, 1.0)
		foe.pos = Vector2(lerpf(x_hit, LAND_X, ease_out(k)), GROUND - sin(k * PI) * 150.0)
		foe.rot = ease_out(k) * PI * 0.5
		foe.hurt = 1.0
		foe.extra = []
		foe.crouch = 0.0
		foe.aura = 0.0
		if k >= 1.0 and not foe.has("landed"):
			foe.landed = true
			shake = maxf(shake, 14.0)
			sfx("lib-impact-bass-2", 0.5)
			for i in 22:
				emit("smoke", Vector2(LAND_X + rng.randf_range(-60, 220), GROUND), Vector2(rng.randf_range(-160, 220), -rng.randf_range(20, 140)), 2.0, rng.randf_range(40, 90), Color(0.85, 0.82, 0.74, 0.5))


func _cam() -> Array:
	var c := Vector2(960, 590)
	var z := 1.0
	var k1 := smooth(0.9, 1.7, t) * (1.0 - smooth(2.3, 2.7, t))          # hít: đẩy vào Tạ Tốn
	c = c.lerp(hero.pos + Vector2(140, -230), k1)
	z = lerpf(z, 1.38, k1)
	var k2 := smooth(2.3, 2.8, t) * (1.0 - smooth(4.8, 5.3, t))          # hai người + vách
	c = c.lerp(Vector2(1050, 600), k2)
	z = lerpf(z, 1.12, k2)
	var k3 := smooth(4.8, 5.4, t) * (1.0 - smooth(ROAR, ROAR + 0.2, t))  # hít lần cuối, sát mặt
	c = c.lerp(hero.pos + Vector2(110, -260), k3)
	z = lerpf(z, 1.5, k3)
	var k4 := smooth(ROAR, ROAR + 0.25, t) * (1.0 - smooth(7.4, 8.4, t)) # gầm: lùi rộng theo sóng
	c = c.lerp(Vector2(1120, 600), k4)
	z = lerpf(z, 1.08, k4)
	var k5 := smooth(7.4, 8.4, t)
	c = c.lerp(Vector2(990, 590), k5)
	return [c, z]


# vách đá vôi trắng bên phải + đảo xa
func _draw_far(c: Node2D) -> void:
	c.draw_colored_polygon(PackedVector2Array([Vector2(-400, 600), Vector2(80, 560), Vector2(260, 575), Vector2(420, 548), Vector2(640, 600)]), Color("#b9c3c4"))
	c.draw_colored_polygon(PackedVector2Array([Vector2(700, 600), Vector2(860, 572), Vector2(980, 584), Vector2(1080, 600)]), Color("#c3cbca"))
	var cl := PackedVector2Array([Vector2(1560, 620), Vector2(1610, 330), Vector2(1700, 230), Vector2(1830, 180), Vector2(1990, 200), Vector2(2200, 160), Vector2(2500, 180), Vector2(2500, 620)])
	c.draw_colored_polygon(cl, far_col)
	c.draw_colored_polygon(PackedVector2Array([Vector2(1560, 620), Vector2(1610, 330), Vector2(1700, 230), Vector2(1660, 420), Vector2(1640, 620)]), Color("#c4bba6"))
	for i in 9:
		var y := 250.0 + i * 40.0
		c.draw_line(Vector2(1680 + i * 6, y), Vector2(1900 + i * 4, y + 10), Color(0.62, 0.58, 0.5, 0.35), 2.0)


# biển chàm: vạch sóng, gợn lên khi vòng âm đi qua
func _draw_near(c: Node2D) -> void:
	c.draw_polygon(PackedVector2Array([Vector2(-600, 600), Vector2(W + 600, 600), Vector2(W + 600, H + 200), Vector2(-600, H + 200)]),
		PackedColorArray([Color("#3a5c8c"), Color("#3a5c8c"), near_col, near_col]))
	for s in sea_lines:
		var y: float = lerpf(612.0, 830.0, s[1])
		var x: float = fmod(s[0] + rt * 14.0, W + 800.0) - 300.0
		var amp := 0.0
		for wv in waves:
			var r: float = (t - wv.t0) * wv.v
			var front: float = wv.o.x + wv.dir * r
			amp += exp(-pow((x - front) / 120.0, 2.0)) * 14.0 * wv.a
		var pts := PackedVector2Array()
		for i in 7:
			var px: float = x + i * s[2] / 6.0
			pts.append(Vector2(px, y + sin(px * 0.05 + rt * 3.0) * (1.5 + amp)))
		c.draw_polyline(pts, Color(0.85, 0.92, 1.0, 0.35 + 0.4 * minf(1.0, amp / 10.0)), 2.0 + s[1] * 1.5)


func _fx_ground(c: Node2D) -> void:
	# mép nền đá + vạch đá
	for i in 14:
		var x := -300.0 + i * 180.0
		c.draw_line(Vector2(x, GROUND + 30 + (i % 3) * 40), Vector2(x + 120, GROUND + 34 + (i % 3) * 40), Color(0.55, 0.5, 0.4, 0.4), 3)
	# cờ đỏ: cán gỗ, vải phần phật mạnh dần theo tiếng gầm
	var gust := 0.25 + _roar_k() * 1.2
	for fl in flags:
		var b: Vector2 = fl[0]
		var hgt: float = fl[1]
		var top := b + Vector2(0, -hgt)
		c.draw_line(b, top, Color("#4a3020"), 7)
		var pts := PackedVector2Array()
		var low := PackedVector2Array()
		for i in 9:
			var k := float(i) / 8.0
			var x := top.x + k * 150.0
			var wy := sin(k * 5.0 - rt * (5.0 + gust * 9.0)) * (6.0 + gust * 16.0) * k
			pts.append(Vector2(x, top.y + 4 + wy))
			low.append(Vector2(x, top.y + 86 + wy - k * 14.0))
		low.reverse()
		pts.append_array(low)
		c.draw_colored_polygon(pts, RED)
	var gk := smooth(1.0, 1.6, t) * (1.0 - smooth(2.6, 3.0, t)) + smooth(4.9, 5.6, t) * (1.0 - smooth(6.5, 7.5, t))
	if gk > 0.01:
		flat_blob(c, Vector2(hero.pos.x, GROUND + 8), 320, 0.14, COL * Color(1, 1, 1, 0.32 * gk))


func _fx_add(c: Node2D) -> void:
	# vòng cung âm thanh: nhiều cung đồng tâm mở về hướng dir
	for wv in waves:
		var r: float = (t - wv.t0) * wv.v
		if r <= 0.0:
			continue
		var life: float = clampf(1.0 - r / 2600.0, 0.0, 1.0)
		var base := 0.0 if wv.dir > 0.0 else PI
		for i in wv.n:
			var rr: float = r - i * 46.0
			if rr < 20.0:
				continue
			var a: float = wv.a * life * (1.0 - float(i) / wv.n)
			var span := 0.62 + 0.1 * sin(float(i))
			var col := HOT if i == 0 else COL
			c.draw_arc(wv.o, rr, base - span, base + span, 40, col * Color(1, 1, 1, 0.75 * a), maxf(1.5, wv.w * (1.0 - i * 0.08)))
			if i == 0:
				c.draw_arc(wv.o, rr + 10.0, base - span, base + span, 40, COL * Color(1, 1, 1, 0.18 * a), wv.w * 2.2)
	# miệng phát sáng khi gầm
	var rk := _roar_k()
	if rk > 0.05:
		var m := _mouth()
		blob(c, m, 70.0 * rk, COL * Color(1, 1, 1, 0.35))
		blob(c, m, 24.0 * rk, HOT * Color(1, 1, 1, 0.8))
	# ù tai: vòng âm nhỏ xoay trên đầu đối thủ sau khi đáp
	if foe.has("landed"):
		var hp: Vector2 = foe.head
		var ctr := Vector2(hp.x + 70.0, GROUND - 120.0)
		for i in 3:
			var a := rt * 4.0 + i * TAU / 3.0
			var p := ctr + Vector2(cos(a) * 60.0, sin(a) * 18.0)
			c.draw_arc(p, 12.0, -0.9, 0.9, 10, COL * Color(1, 1, 1, 0.6), 3.0)
			c.draw_arc(p, 20.0, -0.8, 0.8, 10, COL * Color(1, 1, 1, 0.35), 2.5)


func _fx_norm(c: Node2D) -> void:
	# méo không khí: vạch nén đậm nhạt trên nền khi gầm đỉnh
	var k := pulse(ROAR, ROAR + 0.9, 0.5, t)
	if k > 0.01:
		var m := _mouth()
		for i in 5:
			var rr := fmod((t - ROAR) * 1600.0 + i * 160.0, 1400.0)
			c.draw_arc(m, rr, -0.5, 0.5, 30, Color(0.25, 0.22, 0.18, 0.1 * k), 3.0)
