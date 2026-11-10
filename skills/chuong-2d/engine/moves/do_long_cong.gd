extends "res://engine.gd"
# Ỷ THIÊN ĐỒ LONG CÔNG (12.5 s): đảo Vương Bàn Sơn, chiều gió, vách đá ấm bên biển xám lục.
# Thẻ chiêu:
#   người dùng   Trương Thuý Sơn "Ngân Câu Thiết Hoạch" (đệ ngũ Võ Đang): móc bạc đầu hổ tay trái, bút sắt phán quan tay phải
#   đối thủ      Tạ Tốn (Kim Mao Sư Vương, lúc này còn sáng mắt) thách đấu trên đảo
#   cơ chế       THƯ PHÁP KHẮC VÁCH: mỗi đường quét của móc + bút cắt một nét sáng bạc vào vách đá, chữ hiện TỪNG NÉT
#                (ngang → sổ trái → phẩy phải), đá vụn bắn theo mỗi nét; nét mới loé bạc rồi nguội thành mực sắt có viền bạc.
#                24 chữ 武林至尊，寶刀屠龍，號令天下，莫敢不從，倚天不出，誰與爭鋒 khắc dọc, phải sang trái, mỗi cột nhanh hơn.
#   cặp màu      bạc trắng + mực sắt  vs  vàng đất / hổ phách của Tạ Tốn
#   bối cảnh     chiều gió, trời xám chì, mặt trời đồng sau mây thấp, biển xám lục, vách đá nâu vàng ấm, gờ đá bazan
#   đỉnh         slowmo hai chữ cuối 爭鋒 chém xuống, cả 24 chữ bừng sáng; Tạ Tốn lùi ba bước, ngồi xuống, chắp tay nhận thua.

const COL := Color(1.15, 1.25, 1.6)        # bạc lam
const HOT := Color(1.9, 1.95, 2.1)         # lõi bạc trắng
const FOE_COL := Color(1.55, 1.05, 0.35)   # vàng đất hổ phách
const INK := Color(0.07, 0.065, 0.075)     # mực sắt
const RIM := Color(0.86, 0.9, 1.0)         # viền bạc nét khắc
const STONE := Color("#9c7a58")
const TEXT := ["武林至尊", "寶刀屠龍", "號令天下", "莫敢不從", "倚天不出", "誰與爭鋒"]
const COLS := [[2.45, 3.5], [3.55, 4.25], [4.3, 4.8], [4.85, 5.25], [5.3, 5.75], [5.84, 6.125]]
const PEAK := 6.125           # nét cuối chữ 鋒 xong, cả vách bừng sáng
const GS := 104               # cỡ chữ
const HERO_X := 330.0
const FOE_X := 1430.0
const LAND_X := 1500.0

const AIR := {"thF": -60, "shF": 70, "thB": 20, "shB": 60, "all": [0, 0, 0]}
const CUT_UP := {"uaF": -150, "faF": -20, "uaB": -30, "faB": -40, "torso": 6, "head": 2}   # móc vung lên, bút thấp
const CUT_DN := {"uaF": -60, "faF": 10, "uaB": -100, "faB": -10, "torso": -10, "head": -4}  # móc chém xuống, bút đâm tới
const SIT := {"uaF": -30, "faF": -40, "uaB": 40, "faB": -30, "torso": -6, "head": -10, "thF": -88, "shF": 70, "thB": -80, "shB": 74, "all": [0, 0, 108]}
const CLASP := {"uaF": -62, "faF": -98, "uaB": -40, "faB": -112, "torso": 6, "head": -14}
const ROAR := {"uaF": -150, "faF": -40, "uaB": 50, "faB": -60, "torso": -10, "head": -12, "all": [0, 0, 14]}

var cfont: FontFile
var glyphs: Array = []        # {ch, c: tâm, cs, ce, mask: Node2D, ink: Node2D, done}
var beat_i := 0
var hit := false
var x_back := 0.0
var sat := false
var hook_tip := Vector2.ZERO
var brush_tip := Vector2.ZERO
var keys: Array = []          # [t, pos, cung nhảy]
var fronts: Array = []        # điểm nét đang khắc (khung này)
var sea_lines: Array = []


func _setup() -> void:
	sky_cols = [Color("#46525f"), Color("#8d949a"), Color("#c8b294")]
	moon = Vector2(1640, 470)
	moon_col = Color(1.35, 1.0, 0.62)
	moon_glow = Color(1.0, 0.72, 0.4, 0.3)
	moon_craters = false
	n_stars = 0
	far_col = Color("#56606a")
	near_col = Color(0, 0, 0, 0)
	mist_col = Color(0.85, 0.82, 0.78, 0.16)
	ground_cols = [Color("#4c3c30"), Color("#211814"), Color("#8c7258")]
	slowmo = [5.975, 6.675, 0.3]
	title = "Ỷ Thiên Đồ Long Công"
	subtitle = "Ỷ Thiên Đồ Long Ký · Trương Thuý Sơn"
	title_at = 8.4
	title_col = Color(1.55, 1.6, 1.85)
	set_char(hero, "truong-thuy-son")
	set_char(foe, "ta-ton-sang")
	hero.pos = Vector2(HERO_X, GROUND)
	foe.pos = Vector2(FOE_X, GROUND)
	hero.col = COL
	foe.col = FOE_COL
	hero.node.hand_form = {"F": "nam", "B": "nam"}
	cfont = FontFile.new()
	cfont.data = Marshalls.base64_to_raw(SONGTI_B64)   # Songti TC Bold, chỉ 22 chữ của câu (nhúng sẵn: chép sang tập vẫn chạy)
	# 24 chữ: cột dọc, phải sang trái
	var gi := 0
	for c in 6:
		var a: float = COLS[c][0]
		var b: float = COLS[c][1]
		var span := (b - a) / 4.0
		for r in 4:
			var g := {"ch": TEXT[c].substr(r, 1), "c": Vector2(1150.0 - c * 135.0, 236.0 + r * 112.0),
				"cs": a + r * span, "ce": a + r * span + span * 0.9, "col": c, "row": r}
			var m := Node2D.new()
			m.clip_children = CanvasItem.CLIP_CHILDREN_ONLY
			world.add_child(m)
			world.move_child(m, l_ground.get_index() + 1 + gi)
			var ink := Node2D.new()
			m.add_child(ink)
			m.draw.connect(_draw_mask.bind(m, g))
			ink.draw.connect(_draw_glyph.bind(ink, g))
			g.mask = m
			g.ink = ink
			glyphs.append(g)
			gi += 1
			if c < 4:
				cue(g.cs, "lib-whoosh-short", 0.4 if r == 0 else 0.3)
	# đường bay của Thuý Sơn: đứng → vọt lên cột 1 → xuống dần từng chữ → nhảy sang cột sau → đáp
	keys.append([2.15, Vector2(HERO_X, GROUND), 0.0])
	for g in glyphs:
		var p: Vector2 = g.c + Vector2(-150, 300)
		p.y = minf(p.y, GROUND)
		keys.append([g.cs - 0.02, p, 160.0 if g.row == 0 else 0.0])
		keys.append([g.ce, p + Vector2(0, 16 if p.y < GROUND else 0), 0.0])
	keys.append([PEAK + 0.12, keys[keys.size() - 1][1], 0.0])
	keys.append([PEAK + 0.55, Vector2(HERO_X + 20, GROUND), 60.0])
	for i in 30:
		sea_lines.append([rng.randf_range(1200, 2400), rng.randf_range(0.0, 1.0), rng.randf_range(40, 130)])
	cue(1.0, "lib-riser", 0.8)
	cue(5.3, "lib-whoosh", 0.6)
	cue(5.55, "lib-riser", 0.5)
	cue(5.82, "lib-whoosh-cinematic", 0.9)


func _carved(g: Dictionary) -> float:
	return clampf((t - g.cs) / (g.ce - g.cs), 0.0, 1.0)


# ba nét (ngang, sổ trái, phẩy phải): trả [p0, p1, p2]
func _strokes(g: Dictionary) -> Array:
	var k := _carved(g) * 3.0
	return [clampf(k, 0.0, 1.0), clampf(k - 1.0, 0.0, 1.0), clampf(k - 2.0, 0.0, 1.0)]


func _front(g: Dictionary) -> Vector2:
	var s := _strokes(g)
	var o: Vector2 = g.c - Vector2(64, 64)
	if s[0] < 1.0:
		return o + Vector2(128.0 * s[0], 28)
	if s[1] < 1.0:
		return o + Vector2(36, 52 + 76.0 * s[1])
	return o + Vector2(64 + 64.0 * s[2], 52 + 76.0 * s[2])


func _draw_mask(c: Node2D, g: Dictionary) -> void:
	if t < g.cs:
		return
	var o: Vector2 = g.c - Vector2(66, 70)
	var s := _strokes(g)
	if s[2] >= 1.0:
		c.draw_rect(Rect2(o - Vector2(10, 10), Vector2(152, 160)), Color.WHITE)
		return
	c.draw_rect(Rect2(o + Vector2(-10, -10), Vector2(152.0 * s[0], 68)), Color.WHITE)
	if s[1] > 0.0:
		c.draw_rect(Rect2(o + Vector2(-10, 54), Vector2(80, 96.0 * s[1])), Color.WHITE)
	if s[2] > 0.0:
		c.draw_rect(Rect2(o + Vector2(66, 54), Vector2(76.0 * s[2], 96.0 * s[2])), Color.WHITE)


func _draw_glyph(c: Node2D, g: Dictionary) -> void:
	if t < g.cs:
		return
	var sz := cfont.get_string_size(g.ch, HORIZONTAL_ALIGNMENT_LEFT, -1, GS)
	var base: Vector2 = g.c + Vector2(-sz.x * 0.5, (cfont.get_ascent(GS) - cfont.get_descent(GS)) * 0.5)
	var fresh := 1.0 - smooth(0.0, 0.45, t - g.ce) if t >= g.ce else 1.0
	var blaze := smooth(PEAK - 0.01, PEAK + 0.02, t) * (1.0 - smooth(PEAK + 0.5, PEAK + 1.6, t))
	var glow := maxf(fresh, blaze)
	var settled := smooth(PEAK + 0.5, PEAK + 1.6, t)
	# rãnh đá: bóng tối lệch xuống, viền bạc, lòng mực sắt (nét mới loé bạc)
	c.draw_string(cfont, base + Vector2(3, 4), g.ch, HORIZONTAL_ALIGNMENT_LEFT, -1, GS, Color(0.2, 0.13, 0.09, 0.75))
	var rim := RIM.lerp(Color(1.25, 1.3, 1.5), glow * 0.8 + settled * 0.3)
	c.draw_string_outline(cfont, base, g.ch, HORIZONTAL_ALIGNMENT_LEFT, -1, GS, 5, rim)
	c.draw_string(cfont, base, g.ch, HORIZONTAL_ALIGNMENT_LEFT, -1, GS, INK.lerp(Color(1.2, 1.24, 1.38), glow))


func _key_pos() -> Vector2:
	if t <= keys[0][0]:
		return keys[0][1]
	for i in range(1, keys.size()):
		var a: Array = keys[i - 1]
		var b: Array = keys[i]
		if t < b[0]:
			var k := smooth(a[0], b[0], t)
			var p: Vector2 = (a[1] as Vector2).lerp(b[1], k)
			p.y -= sin(k * PI) * float(b[2])
			return p
	return keys[keys.size() - 1][1]


func _cur() -> int:
	for i in glyphs.size():
		if t < glyphs[i].ce:
			return i if t >= glyphs[i].cs - 0.06 else -1
	return -1


func _story(_dt: float) -> void:
	fronts = []
	for g in glyphs:
		g.mask.queue_redraw()
		g.ink.queue_redraw()
	# ---- Trương Thuý Sơn
	var carving := smooth(2.2, 2.45, t) * (1.0 - smooth(PEAK + 0.12, PEAK + 0.4, t))
	hero.pos = _key_pos()
	hero.gather = smooth(1.0, 1.8, t) * (1.0 - smooth(2.15, 2.4, t))
	var sw := 0.0
	var ci := _cur()
	if ci >= 0:
		var gg: Dictionary = glyphs[ci]
		sw = 0.5 - 0.5 * cos(_carved(gg) * 3.0 * PI)     # mỗi nét một lần vung
	var air := clampf((GROUND - hero.pos.y) / 60.0, 0.0, 1.0)
	hero.extra = [[AIR, air * 0.8], [CUT_UP, carving * (1.0 - sw)], [CUT_DN, carving * sw],
		["point", smooth(PEAK + 0.6, PEAK + 1.0, t) * 0.7]]
	hero.lean = carving * 0.15
	hero.aura = smooth(1.0, 1.8, t) * 0.55 + carving * 0.25 - smooth(PEAK + 0.6, PEAK + 2.0, t) * 0.8
	hero.expr = "dac-y" if t > PEAK + 1.3 else ("quyet-tam" if t > 1.0 else "binh")
	# ---- Tạ Tốn: gầm thách → lùi mỗi cột → bừng sáng → lùi ba bước, ngồi, chắp tay
	if not hit:
		var roar := (1.0 - smooth(2.0, 2.4, t)) * (0.6 + 0.4 * sin(t * 5.0))
		var gd := 0.0
		for c in 4:
			gd = maxf(gd, pulse(COLS[c][1] - 0.05, COLS[c][1] + 0.12, 0.3, t))
		foe.extra = [[ROAR, roar], ["guard", gd + smooth(5.3, 5.8, t) * 0.6]]
		var back := 0.0
		for c in 4:
			back += 8.0 * smooth(COLS[c][1], COLS[c][1] + 0.2, t)
		foe.pos.x = FOE_X + back
		foe.aura = 0.55 * (1.0 - smooth(4.0, 5.5, t)) + roar * 0.3
		foe.expr = "soc" if t > 4.3 else "gian"
		foe.lean = -gd * 0.25
	pose(hero, 0.0)
	pose(foe, 0.0)
	_weapons()

	if hero.gather > 0.05:
		orbit(hero, rng.randf_range(120, 280), rng.randf_range(2.0, 3.5), 260, rng.randf_range(2, 4), COL, 2.3)
	# ---- nét đang khắc: đá vụn + tia bạc tại đầu nét
	if ci >= 0 and t >= glyphs[ci].cs and t < PEAK:
		var g: Dictionary = glyphs[ci]
		var fp := _front(g)
		fronts.append(fp)
		for i in 2:
			emit("rock", fp, Vector2(rng.randf_range(-260, 260), rng.randf_range(-320, -60)), rng.randf_range(0.5, 0.9), rng.randf_range(3, 7), STONE.darkened(rng.randf_range(0.0, 0.35)), 1300.0, 0.4)
		for i in 3:
			var a := rng.randf_range(0, TAU)
			emit("spark", fp, Vector2(cos(a), sin(a)) * rng.randf_range(200, 520), rng.randf_range(0.15, 0.35), rng.randf_range(2, 3.5), HOT if i == 0 else COL, 700.0, 1.5)
		if rng.randf() < 0.35:
			emit("smoke", fp, Vector2(rng.randf_range(-40, 40), rng.randf_range(-60, 10)), 0.9, rng.randf_range(14, 26), Color(0.62, 0.52, 0.42, 0.35))
	# ---- hết mỗi cột (4 cột đầu): một nhịp tác động, Tạ Tốn lùi
	if beat_i < 4 and t >= COLS[beat_i][1]:
		var cx := 1150.0 - beat_i * 135.0
		var at := Vector2(cx, 400)
		add_ring(at, 260, COL, 7, 0.4, 1.4)
		burst(at, 34, 300, 900, HOT, COL, 700.0, 1.4)
		for i in 10:
			emit("rock", at + Vector2(rng.randf_range(-40, 40), rng.randf_range(-200, 200)), Vector2(rng.randf_range(-200, 420), rng.randf_range(-300, 0)), 1.0, rng.randf_range(4, 9), STONE.darkened(rng.randf_range(0.1, 0.4)), 1300.0, 0.3)
		shake = maxf(shake, 12.0)
		sfx("lib-impact-bass-2", 0.6)
		sfx("lib-glitch-1", 0.3)
		beat_i += 1
	# ---- đỉnh: 24 chữ bừng sáng
	if t >= PEAK and not hit:
		hit = true
		x_back = foe.pos.x
		flash = 0.6
		flash_col = Color(0.92, 0.95, 1.0)
		shake = 30.0
		var at := Vector2(812, 404)
		add_ring(at, 760, COL, 7, 0.8, 0.8)
		add_ring(at, 1100, COL * Color(1, 1, 1, 0.7), 5, 1.1, 0.8, 0.06)
		add_ring(Vector2(at.x, GROUND), 900, COL, 8, 0.9, 0.2)
		for g in glyphs:
			burst(g.c, 5, 300, 1100, HOT, COL, 700.0, 1.4)
			for i in 3:
				emit("rock", g.c + Vector2(rng.randf_range(-50, 50), rng.randf_range(-50, 50)), Vector2(rng.randf_range(-260, 260), rng.randf_range(-360, -40)), 1.1, rng.randf_range(4, 8), STONE.darkened(rng.randf_range(0.0, 0.4)), 1300.0, 0.3)
		sfx("lib-impact-bass-1", 1.0)
		sfx("lib-impact-bass-2", 1.0)
		sfx("lib-sparkle", 0.45)
	# ---- hậu quả: lùi ba bước, ngồi xuống, chắp tay nhận thua (không văng, không máu)
	if hit:
		var k := clampf((t - (PEAK + 0.15)) / 1.0, 0.0, 1.0)
		var sitk := smooth(PEAK + 1.15, PEAK + 1.5, t)
		var clk := smooth(PEAK + 1.9, PEAK + 2.3, t)
		foe.pos = Vector2(lerpf(x_back, LAND_X, ease_out(k)), GROUND - absf(sin(k * 3.0 * PI)) * 14.0 * (1.0 - sitk))
		foe.lean = -0.45 * smooth(PEAK + 0.1, PEAK + 0.3, t) * (1.0 - sitk)
		foe.extra = [["guard", (1.0 - sitk) * 0.8], [SIT, sitk], [CLASP, clk]]
		foe.aura = 0.0
		foe.expr = "ngai" if t > PEAK + 2.2 else "soc"
		if sitk > 0.99 and not sat:
			sat = true
			shake = maxf(shake, 8.0)
			sfx("lib-impact-bass-2", 0.5)
			for i in 14:
				emit("smoke", Vector2(LAND_X + rng.randf_range(-90, 90), GROUND), Vector2(rng.randf_range(-140, 140), -rng.randf_range(10, 90)), 1.6, rng.randf_range(30, 60), Color(0.5, 0.42, 0.36, 0.4))
		if clk > 0.0 and not foe.has("clasped"):
			foe.clasped = true
			sfx("lib-chime", 0.35)
	pose(foe, 0.0)


func _weapons() -> void:
	var a := joint_pos(hero, "hdF", Vector2(0, 10))
	var b := joint_pos(hero, "hdF", Vector2(0, 100))
	hook_tip = a + (b - a).normalized() * 120.0
	a = joint_pos(hero, "hdB", Vector2(0, 10))
	b = joint_pos(hero, "hdB", Vector2(0, 100))
	brush_tip = a + (b - a).normalized() * 110.0


func _cam() -> Array:
	var c := CENTER
	var z := 1.0
	var k1 := smooth(0.9, 1.7, t) * (1.0 - smooth(2.15, 2.6, t))
	c = c.lerp(Vector2(HERO_X + 120, GROUND - 230), k1)
	z = lerpf(z, 1.35, k1)
	var k2 := smooth(2.3, 2.8, t) * (1.0 - smooth(PEAK + 0.5, PEAK + 1.8, t))
	var prog := clampf((t - 2.45) / (PEAK - 2.45), 0.0, 1.0)
	c = c.lerp(Vector2(lerpf(1080, 800, prog), 470), k2)
	z = lerpf(z, lerpf(1.15, 1.22, smooth(5.6, PEAK, t)), k2)
	return [c, z]


func _fx_ground(c: Node2D) -> void:
	# biển xám lục bên phải + sóng
	c.draw_polygon(PackedVector2Array([Vector2(-600, 600), Vector2(W + 600, 600), Vector2(W + 600, GROUND), Vector2(-600, GROUND)]),
		PackedColorArray([Color("#6f8a8c"), Color("#6f8a8c"), Color("#3e5a60"), Color("#3e5a60")]))
	for s in sea_lines:
		var y: float = 612.0 + s[1] * 220.0
		var x: float = fmod(s[0] + rt * (20.0 + s[1] * 30.0), 1400.0) + 1150.0
		c.draw_line(Vector2(x, y), Vector2(x + s[2] * (0.5 + s[1]), y), Color(0.85, 0.9, 0.88, 0.25 + s[1] * 0.2), 2.0 + s[1] * 2.0)
	flat_blob(c, Vector2(1640, 612), 360, 0.08, Color(1.0, 0.75, 0.45, 0.3))
	# vách đá
	var top := PackedVector2Array([Vector2(-600, 120), Vector2(140, 96), Vector2(260, 60), Vector2(420, 86), Vector2(560, 40),
		Vector2(760, 70), Vector2(930, 30), Vector2(1110, 74), Vector2(1250, 110), Vector2(1330, 260), Vector2(1350, 520), Vector2(1310, GROUND)])
	var poly := top.duplicate()
	poly.append(Vector2(-600, GROUND))
	var cols := PackedColorArray()
	for p in poly:
		var k := clampf((p.y - 30.0) / (GROUND - 30.0), 0.0, 1.0)
		cols.append(Color("#b48e66").lerp(Color("#6a4e38"), k))
	c.draw_polygon(poly, cols)
	c.draw_polyline(top, Color("#d2b088"), 4.0)
	# mặt vách đã đẽo phẳng (nơi khắc chữ)
	c.draw_colored_polygon(PackedVector2Array([Vector2(392, 168), Vector2(700, 150), Vector2(1228, 162), Vector2(1238, 450), Vector2(1222, 690), Vector2(800, 700), Vector2(400, 688), Vector2(384, 420)]), Color(0.78, 0.64, 0.48, 0.2))
	# vân đá, khe nứt
	var rr := RandomNumberGenerator.new()
	rr.seed = 77
	for i in 16:
		var y := rr.randf_range(110, 820)
		var x := rr.randf_range(-100, 1250)
		var pts := PackedVector2Array()
		for j in 6:
			pts.append(Vector2(x + j * rr.randf_range(30, 60), y + rr.randf_range(-10, 10)))
		c.draw_polyline(pts, Color(0.32, 0.22, 0.15, 0.4), rr.randf_range(1.5, 3.0))
	# gờ chân vách bên phải (đối thủ đứng trên đá bazan)
	c.draw_colored_polygon(PackedVector2Array([Vector2(1310, GROUND), Vector2(1350, 800), Vector2(1560, 790), Vector2(1780, 810), Vector2(1900, GROUND)]), Color("#3a2e26"))
	for f in [hero, foe]:
		flat_blob(c, Vector2(f.pos.x, GROUND + 4), 90, 0.18, Color(0, 0, 0, 0.35))


func _fx_norm(c: Node2D) -> void:
	_draw_hook(c)
	_draw_brush(c)


func _draw_hook(c: Node2D) -> void:
	var a := joint_pos(hero, "hdF", Vector2(0, 10))
	var d := (hook_tip - a).normalized()
	var n := d.orthogonal()
	var silver := Color(0.86, 0.9, 0.96)
	c.draw_line(a - d * 22.0, a + d * 6.0, Color("#3a2a20"), 7.0)          # chuôi
	c.draw_line(a + d * 8.0 + n * 16.0, a + d * 8.0 - n * 16.0, Color("#c9a24a"), 6.0)  # đốc đầu hổ
	c.draw_circle(a + d * 8.0, 7.0, Color("#c9a24a"))
	c.draw_line(a + d * 10.0, hook_tip - d * 6.0, silver, 6.0)
	var pts := PackedVector2Array()
	for i in 10:
		var ang := PI * float(i) / 9.0
		pts.append(hook_tip + n * 18.0 + (-n * cos(ang) + d * sin(ang)) * 18.0)
	c.draw_polyline(pts, silver, 5.0)
	c.draw_line(a + d * 12.0 + n * 2.0, hook_tip, Color(1.1, 1.15, 1.25), 1.5)


func _draw_brush(c: Node2D) -> void:
	var a := joint_pos(hero, "hdB", Vector2(0, 10))
	var d := (brush_tip - a).normalized()
	var n := d.orthogonal()
	var iron := Color("#2a2a30")
	c.draw_line(a - d * 26.0, brush_tip - d * 22.0, iron, 7.0)
	c.draw_line(a - d * 26.0 + n * 1.5, brush_tip - d * 22.0 + n * 1.5, Color(0.6, 0.62, 0.7), 1.5)
	c.draw_colored_polygon(PackedVector2Array([brush_tip - d * 24.0 + n * 6.0, brush_tip, brush_tip - d * 24.0 - n * 6.0]), Color("#15151a"))
	c.draw_circle(a - d * 28.0, 5.0, Color("#5a5a64"))


func _fx_add(c: Node2D) -> void:
	# tụ khí: bạc ánh trên móc và bút
	var g1 := smooth(1.0, 1.8, t) * (1.0 - smooth(2.2, 2.5, t))
	if g1 > 0.0:
		blob(c, hook_tip, 50 * g1, COL * Color(1, 1, 1, 0.4))
		blob(c, brush_tip, 50 * g1, COL * Color(1, 1, 1, 0.4))
	# đầu nét: kiếm khí mảnh từ móc / bút tới nét đang cắt, lõi nóng nhỏ
	for fp in fronts:
		var tip: Vector2 = hook_tip if int(t * 12.0) % 2 == 0 else brush_tip
		c.draw_line(tip, fp, HOT * Color(1, 1, 1, 0.55), 2.5)
		c.draw_line(tip, fp, COL * Color(1, 1, 1, 0.18), 9.0)
		blob(c, fp, 46, COL * Color(1, 1, 1, 0.45))
		blob(c, fp, 16, HOT)
	# nét vừa khắc còn nóng: quầng nhẹ
	for g in glyphs:
		if t >= g.cs and t < g.ce + 0.45:
			var k := 1.0 - clampf((t - g.ce) / 0.45, 0.0, 1.0)
			blob(c, g.c, 80, COL * Color(1, 1, 1, 0.14 * k))
	# đỉnh: cả vách bừng sáng rồi dịu thành ánh bạc
	var bl := smooth(PEAK - 0.01, PEAK + 0.03, t) * (1.0 - smooth(PEAK + 0.6, PEAK + 1.8, t))
	var rest := smooth(PEAK + 0.6, PEAK + 1.8, t)
	if bl > 0.0 or rest > 0.0:
		blob(c, Vector2(812, 404), 640, COL * Color(1, 1, 1, 0.3 * bl))
		for g in glyphs:
			blob(c, g.c, 82, COL * Color(1, 1, 1, 0.24 * bl + 0.07 * rest))
	if t > PEAK - 0.02 and t < PEAK + 0.25:
		var k := 1.0 - clampf((t - PEAK) / 0.25, 0.0, 1.0)
		c.draw_line(glyphs[23].c + Vector2(-70, -70), glyphs[23].c + Vector2(80, 80), HOT * Color(1, 1, 1, 0.8 * k), 6.0)


# Songti TC Bold (macOS Supplemental/Songti.ttc, mặt 2), cắt còn 22 chữ của câu 24 chữ bằng fontTools
const SONGTI_B64 := "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"
