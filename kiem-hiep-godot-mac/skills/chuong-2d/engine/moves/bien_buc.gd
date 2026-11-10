extends "res://engine.gd"
# Phi Thiên Biển Bức — thiết lăng nghe tiếng vọng (tap-12 Giang Nam Thất Quái, 2026-10-24)
# Thẻ chiêu: Kha Trấn Ác (mù, gậy sắt) · Mai Siêu Phong (Hắc Phong Song Sát) · TIẾNG VỌNG KIỂU DƠI: gậy gõ đất toả sóng âm
# lam bạc; sóng chạm đối thủ thì dội ngược thành viền sáng vẽ ra hình đối thủ giữa bóng tối, thiết lăng bốn cạnh bay theo đúng
# đường sóng dội về · lam bạc + đỏ son (lăng) vs tím đen · đêm mây đặc che trăng trên đồi hoang Mông Cổ, đất xám nâu ·
# đỉnh: ba nhát gõ liền, ba vòng sóng cùng lúc, viền đối thủ sáng rõ nhất, ba viên lăng hội tụ, mây rách để lộ trăng.

const COL := Color(0.65, 0.95, 1.45)       # sóng tiếng vọng lam bạc
const HOT := Color(1.5, 1.9, 2.2)
const LANG := Color(1.6, 0.42, 0.3)        # thiết lăng: sắt nung đỏ son
const FOE_COL := Color(0.75, 0.3, 1.1)
const TAPS := [2.5, 3.6, 4.7]              # mỗi nhịp: gõ gậy → sóng lan → chạm → dội → lăng bay
const PEAK := 6.2
const ECHO_V := 1150.0                     # px/s (thời gian truyện)
const STAFF_UP := {"uaF": -150.0, "faF": -20.0, "uaB": 30.0, "faB": -70.0, "torso": 4.0, "head": -10.0, "all": [0.0, 0.0, 10.0]}
const STAFF_TAP := {"uaF": -40.0, "faF": 10.0, "uaB": 34.0, "faB": -80.0, "torso": -10.0, "head": -4.0, "thF": -24.0, "shF": 28.0, "all": [0.0, 6.0, 18.0]}
const NGHE := {"head": 18.0, "torso": 2.0}                      # nghiêng đầu nghe
const PHONG := {"uaB": -100.0, "faB": -10.0, "torso": -12.0, "uaF": 20.0, "faF": -50.0}   # tay B vung phóng lăng
const OM_MAT := {"uaF": -150.0, "faF": -120.0, "uaB": -140.0, "faB": -125.0, "head": 12.0, "torso": 14.0, "all": [0.0, 0.0, 24.0]}

var waves: Array = []       # {o, t0}  sóng từ chỗ gõ
var echoes: Array = []      # {t0, k}   viền đối thủ sáng lên khi sóng chạm
var lang: Array = []        # {a, b, t0, dur, ctrl}
var tap_i := 0
var hit := false
var x_hit := 0.0
var clouds: Array = []


func _setup() -> void:
	sky_cols = [Color("#0d1222"), Color("#26304a"), Color("#4a4a52")]
	far_col = Color("#2a2f40")
	near_col = Color("#3a362f")
	mist_col = Color(0.45, 0.5, 0.6, 0.16)
	ground_cols = [Color("#5a5244"), Color("#2a251e"), Color("#7a6e5c")]
	moon_on = true
	moon = Vector2(1180, 200)
	moon_col = Color(1.15, 1.12, 1.05)
	moon_glow = Color(0.7, 0.75, 0.9, 0.2)
	n_stars = 40
	slowmo = [PEAK - 0.08, PEAK + 0.6, 0.3]
	title = "Phi Thiên Biển Bức"
	subtitle = "Kha Trấn Ác · nghe tiếng vọng mà phóng thiết lăng"
	title_at = 8.4
	title_col = HOT
	set_char(hero, "kha-tran-ac")
	set_char(foe, "mai-sieu-phong")
	hero.pos = Vector2(560, GROUND)
	foe.pos = Vector2(1360, GROUND)
	hero.col = COL
	foe.col = FOE_COL
	for i in 7:
		clouds.append([Vector2(rng.randf_range(600, 1800), rng.randf_range(90, 330)), rng.randf_range(220, 420), rng.randf_range(-1, 1)])
	cue(1.0, "lib-riser", 0.7)
	cue(PEAK - 0.35, "lib-whoosh-cinematic", 0.9)


func _tap_t(i: int) -> float:
	return TAPS[i] if i < TAPS.size() else PEAK - 0.55


func _story(_dt: float) -> void:
	# ---- Kha: nghe, giơ gậy, gõ
	var up := smooth(1.0, 1.8, t) * (1.0 - smooth(2.2, 2.45, t))
	var tapk := 0.0
	for b in TAPS + [PEAK - 0.55]:
		tapk = maxf(tapk, pulse(b - 0.18, b + 0.05, 0.22, t))
	var throw_k := 0.0
	for b in TAPS:
		throw_k = maxf(throw_k, pulse(b + 0.35, b + 0.5, 0.2, t))
	throw_k = maxf(throw_k, smooth(PEAK - 0.25, PEAK - 0.1, t) * (1.0 - smooth(PEAK + 0.5, PEAK + 1.2, t)))
	hero.base = "stance"
	hero.extra = [[NGHE, smooth(0.3, 1.0, t) * (1.0 - smooth(1.0, 1.4, t))], [STAFF_UP, up], [STAFF_TAP, tapk], [PHONG, throw_k]]
	hero.aura = smooth(1.0, 1.8, t) * 0.4 + smooth(5.3, 5.9, t) * 0.5 - smooth(7.2, 9.0, t) * 0.9
	hero.expr = "dac-y" if t > 8.2 else ("quyet-tam" if t > 1.0 else "binh")
	# ---- Mai Siêu Phong: rình trong bóng tối, gạt lăng
	if not hit:
		var dodge := 0.0
		for b in TAPS:
			dodge = maxf(dodge, pulse(b + 0.55, b + 0.75, 0.25, t))
		foe.extra = [["guard", dodge], [{"uaF": -112.0, "faF": -28.0, "torso": -10.0, "all": [0.0, 8.0, 22.0]}, 1.0 - dodge]]
		foe.expr = "soc" if t > 4.2 else "gian"
		foe.aura = 0.25
	moon_on = t > PEAK + 0.3
	pose(hero, 0.0)
	pose(foe, 0.0)
	var tip: Vector2 = joint_pos(hero, "hdF", Vector2(0, 150)) if hero.node.J.has("hdF") else hero.hand
	tip.y = GROUND
	if hero.gather > 0.05 or up > 0.05:
		orbit(hero, rng.randf_range(110, 260), rng.randf_range(2.0, 3.2), 260, rng.randf_range(2, 4), COL, 2.4)

	# ---- mỗi nhịp gõ: sinh sóng; sóng chạm đối thủ: viền sáng + lăng bay
	if tap_i < TAPS.size() and t >= TAPS[tap_i]:
		var o := Vector2(hero.pos.x + 70, GROUND)
		waves.append({"o": o, "t0": t, "big": false})
		add_ring(o, 140, HOT, 6, 0.3, 0.25)
		shake = maxf(shake, 10.0)
		sfx("lib-impact-bass-2", 0.55)
		var arrive: float = t + (foe.pos.x - o.x) / ECHO_V
		echoes.append({"t0": arrive, "big": false})
		lang.append({"a": hero.handB, "b": foe.pos + Vector2(-40, -150 - tap_i * 30), "t0": t + 0.45, "dur": 0.32, "c": -120.0 + tap_i * 80.0, "done": false})
		tap_i += 1
	# lăng chạm: gạt văng, đối thủ lùi
	for l in lang:
		if not l.done and t >= l.t0 + l.dur and not l.get("big", false):
			l.done = true
			var p: Vector2 = l.b
			burst(p, 26, 260, 800, LANG, HOT, 700.0, 1.4, -PI * 0.9, -PI * 0.1)
			add_ring(p, 120, LANG, 5, 0.25)
			shake = maxf(shake, 12.0)
			sfx("lib-impact-bass-2", 0.6)
			sfx("lib-sparkle", 0.35)
			foe.pos.x += 22.0
	# ---- đỉnh: ba sóng cùng lúc + ba lăng hội tụ
	if t >= PEAK - 0.55 and not hero.has("peaked"):
		hero.peaked = true
		for i in 3:
			waves.append({"o": Vector2(hero.pos.x + 70, GROUND), "t0": t + i * 0.06, "big": true})
		echoes.append({"t0": t + (foe.pos.x - hero.pos.x) / ECHO_V, "big": true})
		for i in 3:
			lang.append({"a": hero.handB + Vector2(0, -20 + i * 20), "b": foe.pos + Vector2(-30, -170), "t0": PEAK - 0.28, "dur": 0.28, "c": -220.0 + i * 220.0, "done": false, "big": true})
		sfx("lib-glitch-1", 0.35)
	if t >= PEAK and not hit:
		hit = true
		x_hit = foe.pos.x
		foe.expr = "ko"
		flash = 0.32
		flash_col = Color(0.85, 0.92, 1.0)
		shake = 30.0
		var at: Vector2 = foe.pos + Vector2(-20, -170)
		add_ring(at, 560, HOT, 16, 0.7)
		add_ring(Vector2(at.x, GROUND), 760, COL, 9, 0.9, 0.2)
		burst(at, 90, 300, 1400, LANG, COL, 800.0, 1.0)
		sfx("lib-impact-bass-1", 1.0)
		sfx("lib-impact-bass-2", 1.0)
	# ---- hậu quả: lảo đảo lùi ba bước, ôm mặt khuỵu xuống (không văng, không máu)
	if hit:
		var k := clampf((t - PEAK) / 1.4, 0.0, 1.0)
		var stag := sin(k * PI * 3.0) * (1.0 - k)
		foe.pos = Vector2(lerpf(x_hit, 1470.0, ease_out(k)), GROUND)
		foe.rot = stag * 0.12
		foe.hurt = 0.0
		foe.aura = 0.0
		foe.extra = [[OM_MAT, smooth(0.0, 0.25, k)], ["kneel", smooth(0.55, 1.0, k) * 0.55]]
		foe.expr = "ko" if k < 0.7 else "soc"
		if k >= 1.0 and not foe.has("landed"):
			foe.landed = true
			shake = maxf(shake, 10.0)
			sfx("lib-impact-bass-2", 0.45)
			for i in 14:
				emit("smoke", Vector2(1470 + rng.randf_range(-80, 120), GROUND), Vector2(rng.randf_range(-120, 160), -rng.randf_range(20, 110)), 1.8, rng.randf_range(40, 80), Color(0.42, 0.4, 0.42, 0.4))


func _cam() -> Array:
	var c := CENTER
	var z := 1.0
	var k1 := smooth(0.9, 1.7, t) * (1.0 - smooth(2.2, 2.7, t))
	c = c.lerp(hero.pos + Vector2(140, -230), k1)
	z = lerpf(z, 1.35, k1)
	var k2 := smooth(5.3, 5.9, t) * (1.0 - smooth(PEAK + 0.8, 9.0, t))
	c = c.lerp(Vector2(1080, 600), k2)
	z = lerpf(z, 1.18, k2)
	c = c.lerp(Vector2(980, 590), smooth(8.4, 10.2, t))
	return [c, z]


# mây dày che trăng; đỉnh thì mây rách
func _fx_back(c: Node2D) -> void:
	pass


func _dark() -> float:
	return 0.24 * smooth(0.6, 2.0, t) * (1.0 - smooth(PEAK, PEAK + 1.6, t)) + 0.08


func _fx_norm(c: Node2D) -> void:
	# mây (toạ độ world, vẽ trên trời nhưng dưới bóng tối)
	var open := smooth(PEAK, PEAK + 1.8, t)
	for cl in clouds:
		var p: Vector2 = cl[0] + Vector2(rt * 14.0 * cl[2] + (cl[0].x - 1180.0) * open * 0.8, 0)
		flat_blob(c, p, cl[1], 0.3, Color(0.09, 0.09, 0.12, 0.85 * (1.0 - open * 0.7)))
	# bóng tối: phủ đều, chừa quầng mờ quanh Kha (người xem vẫn thấy ông), đối thủ chìm cho tới khi sóng dội
	var d := _dark()
	c.draw_rect(Rect2(-800, -600, W + 1600, H + 1200), Color(0.02, 0.025, 0.05, d))
	blob(c, hero.pos + Vector2(0, -150), 260, Color(0.55, 0.62, 0.75, 0.22 * d))


func _fx_add(c: Node2D) -> void:
	# sóng tiếng vọng: các cung đồng tâm nửa trên từ chỗ gõ, lan sang phải
	for w in waves:
		var age: float = t - w.t0
		if age < 0.0 or age > 1.3:
			continue
		var big: bool = w.big
		for j in 3:
			var r: float = ECHO_V * age - j * 38.0
			if r < 10.0:
				continue
			var a := (1.0 - age / 1.3) * (0.9 - j * 0.25) * (1.3 if big else 1.0)
			c.draw_arc(w.o, r, -PI * 0.92, -PI * 0.04, 72, Color(COL.r, COL.g, COL.b, clampf(a, 0.0, 1.0) * 0.55), 3.0 + (2.0 if big else 0.0))
	# sóng dội: viền sáng vẽ lại hình đối thủ (đầu tròn + thân + hai tay), rồi cung sóng nhỏ quay về phía Kha
	for e in echoes:
		var age: float = t - e.t0
		if age < 0.0 or age > 1.1:
			continue
		var big: bool = e.big
		var a := (1.0 - smooth(0.35, 1.1, age)) * (1.0 if big else 0.75)
		var hc: Vector2 = foe.head + Vector2(0, -8)
		var col := Color(HOT.r, HOT.g, HOT.b, a)
		c.draw_arc(hc, 82.0, 0, TAU, 56, col, 3.5)
		var body := PackedVector2Array([hc + Vector2(-48, 80), foe.pos + Vector2(-66, -20), foe.pos + Vector2(-40, 0), foe.pos + Vector2(40, 0), foe.pos + Vector2(66, -20), hc + Vector2(48, 80)])
		c.draw_polyline(body, Color(col, a * 0.85), 3.0, true)
		c.draw_line(foe.handF, hc + Vector2(40, 90), Color(col, a * 0.7), 3.0)
		c.draw_line(foe.handB, hc + Vector2(-40, 90), Color(col, a * 0.7), 3.0)
		blob(c, hc, 120, Color(COL.r, COL.g, COL.b, 0.10 * a))
		var back: float = 900.0 * age
		c.draw_arc(foe.pos + Vector2(-40, -120), back, PI * 0.82, PI * 1.18, 24, Color(COL.r, COL.g, COL.b, a * 0.4), 2.0)
	# thiết lăng bốn cạnh bay theo cung, vệt đỏ son
	for l in lang:
		var k: float = (t - l.t0) / l.dur
		if k < 0.0 or k > 1.0:
			continue
		var a: Vector2 = l.a
		var b: Vector2 = l.b
		var mid := a.lerp(b, 0.5) + Vector2(0, l.c)
		var p := a.lerp(mid, k).lerp(mid.lerp(b, k), k)
		var p2 := a.lerp(mid, k - 0.12).lerp(mid.lerp(b, k - 0.12), k - 0.12)
		c.draw_line(p2, p, Color(LANG.r, LANG.g, LANG.b, 0.5), 4.0)
		var s := 18.0
		var rot := t * 30.0
		var q := PackedVector2Array()
		for i in 4:
			var ang := rot + i * PI * 0.5
			q.append(p + Vector2(cos(ang), sin(ang)) * (s if i % 2 == 0 else s * 0.55))
		c.draw_colored_polygon(q, LANG)
		blob(c, p, 26, Color(LANG.r, LANG.g, LANG.b, 0.25))
	# quầng gậy khi giơ
	var up := smooth(1.0, 1.8, t) * (1.0 - smooth(2.2, 2.45, t)) + smooth(5.4, 5.8, t) * (1.0 - smooth(PEAK - 0.6, PEAK - 0.5, t))
	if up > 0.02:
		blob(c, hero.handF, 80 * up, Color(COL.r, COL.g, COL.b, 0.3))
