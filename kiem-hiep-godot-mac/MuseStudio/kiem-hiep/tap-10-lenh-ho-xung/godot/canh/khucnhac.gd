extends "res://canh.gd"
# Khúc Tiếu Ngạo Giang Hồ. Hai kiểu dựng theo arg.m:
#   rung (k05) — rừng đêm Hành Sơn: một dải khuông nhạc uốn bay ngang rừng; nốt tiêu (ngọc) và nốt cầm (vàng) chảy ngược chiều rồi hoà
#   song (k20) — sông trăng: thuyền nhỏ, hai chén rượu, Doanh Doanh gảy cầm, Lệnh Hồ Xung thổi tiêu; nốt bay lên thành tên truyện

const JADE := Color("#8fe0c0")
const GOLD := Color("#f0c060")
const PALE := Color("#e8f0ff")
const BAMBOO := Color("#c9a35a")
const WINE := [Color("#d9a441"), Color("#f3ecd8"), Color("#e8b65a"), Color("#d98a3a"), Color("#6b4a2a"), Color("#e89ab0"),
	Color("#7fb8a8"), Color("#e6e2c8"), Color("#5a2a22"), Color("#e0a040")]
const TITLE := "TIẾU NGẠO GIANG HỒ"
const TITLE_SZ := 104

var m := "rung"
var lan := 2
var lhx: Dictionary
var luu: Dictionary
var khuc: Dictionary
var dd: Dictionary
var huong: Dictionary
var ho: Dictionary
var tip_l := Vector2.ZERO        # đầu ống tiêu (nguồn nốt ngọc)
var tip_k := Vector2.ZERO        # giữa mặt đàn (nguồn nốt vàng)
var bx := 740.0                  # thuyền: tâm x, mặt sàn y
var by := 770.0
var ROCK := Vector2(1170, 830)   # tảng đá Khúc Dương ngồi


func _palette() -> void:
	m = arg.get("m", "rung")
	lan = int(arg.get("lan", 2))
	wind_base = 0.12
	wind_gust = 0.15
	if m == "rung":
		sky_top = Color("#0b1626")
		sky_bot = Color("#21414a")
		char_tint = Color(0.82, 0.9, 1.0)
		ground_y = 880.0
		vign_a = 0.45
	else:
		sky_top = Color("#0c0f2e")
		sky_bot = Color("#33417a")
		char_tint = Color(0.86, 0.9, 1.05)
		ground_y = 900.0
		vign_a = 0.4


func _build() -> void:
	if m == "rung":
		luu = actor("luu-chinh-phong", Vector2(720, ground_y), 1.0)
		khuc = actor("khuc-duong", ROCK, -1.0)
		lhx = actor("lenh-ho-xung", Vector2(2350, ground_y), -1.0)
		ho = prop(lhx, "ho_lo", "hong", "F")
	else:
		huong = actor("huong-van-thien", Vector2(330, 770), 1.0)
		huong.show = 0.0
		luu = actor("luu-chinh-phong", Vector2(1110, 470), 1.0)
		khuc = actor("khuc-duong", Vector2(1290, 470), -1.0)
		for g in [luu, khuc]:
			g.size = 0.85
			g.tint = Color(1.25, 1.35, 1.6)
			g.show = 0.0
		lhx = actor("lenh-ho-xung", Vector2(bx - 110, by), 1.0)
		dd = actor("doanh-doanh", Vector2(bx + 110, by), -1.0)


func _story(dt: float) -> void:
	if t < 0.0:
		return
	if m == "rung":
		_s_rung(dt)
	else:
		_s_song(dt)


func _cam() -> Array:
	return _c_rung() if m == "rung" else _c_song()


func _sky(c: Node2D) -> void:
	vgrad(c, Rect2(-3000, -1500, 8000, 4200), sky_top, sky_bot)
	if m == "song":
		var rr := RandomNumberGenerator.new()
		rr.seed = 9
		for i in 140:
			var p := Vector2(rr.randf_range(-1500, 3400), rr.randf_range(-600, 560))
			c.draw_circle(p, rr.randf_range(1.0, 2.6), Color(1, 1, 0.9, 0.35 + 0.3 * sin(t * 2.0 + i)))


func _far(c: Node2D) -> void:
	if m == "rung":
		c.draw_circle(Vector2(1460, 190), 96.0, Color(1, 0.96, 0.8, 0.12))
		c.draw_circle(Vector2(1460, 190), 70.0, Color("#f4ecd0"))
		c.draw_circle(Vector2(1440, 176), 16.0, Color("#e2d6b0"))
		var pk := mountain_pts([Vector2(-200, 520), Vector2(200, 300), Vector2(600, 470), Vector2(1000, 260), Vector2(1500, 430), Vector2(1900, 280), Vector2(2150, 500)], 760.0)
		shape(c, pk, Color("#16283a"), 3.0)
	else:
		_moon(c, Vector2(1320, 250), 92.0)
		var pk := mountain_pts([Vector2(-200, 600), Vector2(200, 470), Vector2(600, 560), Vector2(900, 430), Vector2(1400, 540), Vector2(1900, 450), Vector2(2150, 590)], 700.0)
		shape(c, pk, Color("#1a2148"), 3.0)


func _mid(c: Node2D) -> void:
	if m == "rung":
		for i in 18:
			pine(c, Vector2(-700 + i * 210, 820), 300.0 + (i * 53) % 140, 120.0, Color("#1c3a3a"), 0.0, 3.0, i)


func _back(c: Node2D) -> void:
	if m == "rung":
		for i in 9:
			pine(c, Vector2(-500 + i * 380 + (i % 2) * 90, 900), 520.0 + (i * 71) % 160, 190.0, Color("#244a44"), 0.0, 4.0, 40 + i)


func _ground(c: Node2D) -> void:
	if m == "rung":
		_g_rung(c)
	else:
		_g_song(c)


func _near(c: Node2D) -> void:
	if m == "rung":
		_n_rung(c)
	else:
		_n_song(c)


func _glow(c: Node2D) -> void:
	if m == "rung":
		_torch_glow(c)
	else:
		_glow_song(c)


func _front(c: Node2D) -> void:
	if m == "rung":
		var k := bump(L("k05-06b") + 0.5, L("k05-06b") + 2.0, LE("k05-06b"), LE("k05-06b") + 1.5)
		for i in 5:
			var y := 700.0 + i * 70.0
			var x := fmod(t * (20.0 + i * 6.0) + i * 400.0, 600.0)
			for j in 6:
				flat_blob(c, Vector2(-600 + j * 600 + x, y), 420.0, 0.22, Color(0.75, 0.85, 0.95, 0.06 + 0.12 * k))


func _d_screen(c: Node2D) -> void:
	super._d_screen(c)
	if m == "rung":
		_sc_rung(c)


# ---------------------------------------------------------------- nhạc cụ, nốt nhạc (dùng chung hai kiểu)

# điểm môi trong toạ độ thân
func _lip(a: Dictionary) -> Vector2:
	var to: Node2D = a.node.J["torso"]
	return from_w(to, to_w(a.node.J["head"], Vector2(0, -30)))


# hai tay nâng ống tiêu ngang miệng; ngón nhấp theo nhịp
func _tieu_hold(a: Dictionary, k: float) -> void:
	var lp := _lip(a)
	var f := sin(t * 9.0) * 2.5
	a.hold["F"] = [lp + Vector2(84, 22 + f), k]
	a.hold["B"] = [lp + Vector2(34, 10 - f), k]


func _tieu(c: Node2D, a: Dictionary, k: float) -> Vector2:
	var to: Node2D = a.node.J["torso"]
	var lp := _lip(a)
	var p0 := to_w(to, lp + Vector2(2, 2))
	var p1 := to_w(to, lp + Vector2(136, 34))
	if k < 0.5:
		return p1
	var al := float(a.get("show", 1.0))
	c.draw_line(p0, p1, Color(inkof(BAMBOO), al), 12.0, true)
	c.draw_line(p0, p1, Color(BAMBOO, al), 7.0, true)
	for i in 5:
		c.draw_circle(p0.lerp(p1, 0.3 + i * 0.12), 1.8, Color(ink, al))
	c.draw_line(p0.lerp(p1, 0.08), p0.lerp(p1, 0.12), Color("#b8322c"), 8.0)
	return p1


# đàn cầm đặt ngang lòng người ngồi xếp bằng (pos = chân, f = hướng mặt); trả về tâm mặt đàn
func _cam_pts(p: Vector2, f: float) -> Array:
	return [p + Vector2(f * -36.0, -26.0), p + Vector2(f * 150.0, -18.0)]


func _dan(c: Node2D, p: Vector2, f: float, al := 1.0) -> Vector2:
	var e: Array = _cam_pts(p, f)
	var a: Vector2 = e[0]
	var b: Vector2 = e[1]
	var n := (b - a).normalized().orthogonal() * f
	var wood := Color("#5a2e1c")
	shape(c, PackedVector2Array([a + n * 10, b + n * 8, b - n * 6, a - n * 9]), Color(wood, al), 3.0)
	shape(c, PackedVector2Array([a + n * 10, b + n * 8, b + n * 3, a + n * 4]), Color(wood.lightened(0.25), al), 2.0)
	for i in 5:
		var o := n * (8.0 - i * 2.4)
		c.draw_line(a + o + (b - a) * 0.05, b + o - (b - a) * 0.05, Color(1, 0.95, 0.8, 0.7 * al), 1.2, true)
	for i in 7:
		c.draw_circle(a.lerp(b, 0.25 + i * 0.09) + n * 9.0, 2.0, Color(1, 1, 0.9, 0.8 * al))
	return a.lerp(b, 0.55)


# hai tay trên dây đàn: tay F gảy chạy dọc dây, tay B nhấn phím
func _dan_hold(a: Dictionary, p: Vector2, f: float, k: float) -> void:
	var e: Array = _cam_pts(p, f)
	var aa: Vector2 = e[0]
	var bb: Vector2 = e[1]
	var to: Node2D = a.node.J["torso"]
	var pl := 0.62 + 0.12 * sin(t * 3.3) + absf(sin(t * 11.0)) * 0.03
	a.hold["F"] = [from_w(to, aa.lerp(bb, pl) + Vector2(0, -10.0 - absf(sin(t * 11.0)) * 8.0)), k]
	a.hold["B"] = [from_w(to, aa.lerp(bb, 0.22 + 0.04 * sin(t * 1.7)) + Vector2(0, -8)), k]


func _note(c: Node2D, p: Vector2, s: float, col: Color, al: float, kind := 0) -> void:
	if al <= 0.01:
		return
	var ln := Color(inkof(col, 0.5), al)
	c.draw_set_transform(p, -0.35, Vector2(1.0, 0.72))
	c.draw_circle(Vector2.ZERO, 11.0 * s + 2.5, ln)
	c.draw_circle(Vector2.ZERO, 11.0 * s, Color(col, al))
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	var st := p + Vector2(9.0 * s, -2.0 * s)
	c.draw_line(st, st + Vector2(0, -38.0 * s), ln, 4.0 * s, true)
	if kind == 1:
		c.draw_line(st + Vector2(0, -38.0 * s), st + Vector2(16.0 * s, -26.0 * s), ln, 4.0 * s, true)
	elif kind == 2:
		c.draw_line(st + Vector2(0, -38.0 * s), st + Vector2(26.0 * s, -32.0 * s), ln, 5.0 * s, true)
		c.draw_line(st + Vector2(0, -28.0 * s), st + Vector2(26.0 * s, -22.0 * s), ln, 5.0 * s, true)


func _cuon(c: Node2D, p: Vector2, ang: float, col: Color, al := 1.0) -> void:
	c.draw_set_transform(p, ang, Vector2.ONE)
	c.draw_rect(Rect2(-30, -9, 60, 18), Color(ink, al))
	c.draw_rect(Rect2(-28, -7, 56, 14), Color("#efe2bf", al))
	c.draw_rect(Rect2(-6, -8, 12, 16), Color(col, al))
	c.draw_rect(Rect2(-34, -11, 6, 22), Color("#5a2e1c", al))
	c.draw_rect(Rect2(28, -11, 6, 22), Color("#5a2e1c", al))
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


# ================================================================ k05: rừng đêm, dải khuông nhạc

func _staff_y(x: float) -> float:
	return 420.0 + sin(x * 0.0034 + t * 0.5) * 58.0 + sin(x * 0.009 - t * 0.3) * 14.0


func _wins() -> Array:
	return [[L("k05-02") + 1.2, L("k05-04") + 2.5], [L("k05-05") + 0.6, L("k05-06") + 0.6]]


func _s_rung(_dt: float) -> void:
	var l5 := L("k05-05")
	var l6 := L("k05-06")
	var b6 := L("k05-06b")
	var l8 := L("k05-08")
	var four := L("k05-04")
	rain_of("firefly", 1.2, Rect2(-200, 500, 2400, 360), {"col": Color(0.8, 1.0, 0.6), "life": 7.0})
	# Lưu Chính Phong đứng thổi tiêu; lúc phái Tung Sơn tới thì quay lại nhìn, lúc trao sách thì cúi
	var play := smooth(L("k05-02") - 0.2, L("k05-02") + 0.8, t) * (1.0 - smooth(four + 0.2, four + 0.8, t)) + bump(l5 + 0.2, l5 + 0.8, l6 + 0.2, l6 + 0.6)
	var give := bump(l6 + 0.4, l6 + 0.9, l6 + 1.8, l6 + 2.4)
	var bow := bump(l6 + 2.4, l6 + 2.8, l6 + 4.2, l6 + 4.8)
	var turn := bump(four + 0.3, four + 0.8, l5 - 0.6, l5 - 0.1)
	luu.face = -1.0 if turn > 0.5 else 1.0
	luu.extra = [[{"head": sin(t * 1.6) * 3.0, "torso": -4.0 + sin(t * 1.6) * 2.0}, play], [{"uaF": -80.0, "faF": -10.0}, give],
		[{"torso": 24.0, "head": 14.0, "uaF": -30.0, "faF": -100.0, "uaB": -30.0, "faB": -100.0}, bow]]
	luu.expr = "soc" if turn > 0.5 else ("buon" if t > l5 else "binh")
	_tieu_hold(luu, play)
	# 06b: Lưu đi vào sương rồi nhạt dần
	if t > b6 + 0.8 and luu.go == Vector2.INF and luu.pos.x > 420.0:
		luu.speed = 70.0
		luu.go = Vector2(300, ground_y)
	luu.show = 1.0 - smooth(b6 + 1.5, b6 + 4.5, t)
	# Khúc Dương xếp bằng trên đá, đàn trên gối
	khuc.extra = [[NGOI_XEP_BANG, 1.0], [{"head": 6.0 + sin(t * 1.3) * 3.0, "torso": 5.0}, play],
		[{"torso": 22.0, "head": 16.0}, bow], [{"head": -14.0}, turn]]
	khuc.expr = "soc" if turn > 0.5 else ("buon" if t > l5 else "vui")
	_dan_hold(khuc, ROCK, -1.0, maxf(play, 0.4) * (1.0 - give))
	if give > 0.01:
		khuc.hold["B"] = [Vector2(70, -70), give]
	khuc.show = 1.0 - smooth(b6 + 2.0, b6 + 5.0, t)
	# Lệnh Hồ Xung: tới nấp sau gốc cây (k05-05), bước ra nhận sách (k05-06), nhét sách vào ngực (k05-08)
	if t > l5 - 1.0 and t < l6 and lhx.go == Vector2.INF and lhx.pos.x > 1800.0:
		lhx.speed = 240.0
		lhx.go = Vector2(1760, ground_y)
	if t > l6 and lhx.go == Vector2.INF and lhx.pos.x > 1500.0:
		lhx.speed = 200.0
		lhx.go = Vector2(1450, ground_y)
	var peek := smooth(l5 + 3.0, l5 + 3.5, t) * (1.0 - smooth(l6 - 0.3, l6, t))
	var recv := smooth(l6 + 2.0, l6 + 2.6, t) * (1.0 - smooth(l8 + 0.6, l8 + 1.6, t))
	var tuck := smooth(l8 + 0.4, l8 + 1.4, t)
	var bow2 := bump(l6 + 4.6, l6 + 5.0, l6 + 5.8, l6 + 6.3)
	var puzz := smooth(l8 + 2.0, l8 + 2.6, t)
	lhx.extra = [[{"torso": -10.0, "head": -18.0}, peek], [{"torso": 22.0, "head": 12.0}, bow2],
		[{"head": 14.0 * sin(t * 2.0) * puzz, "uaB": -150.0, "faB": -60.0}, puzz]]
	lhx.hold["F"] = [Vector2(92, -66).lerp(Vector2(20, -60), tuck), maxf(recv, tuck * (1.0 - smooth(l8 + 1.6, l8 + 2.2, t)))]
	lhx.expr = "soc" if peek > 0.5 or (t > l6 + 2.0 and t < l6 + 4.0) else ("ngai" if puzz > 0.3 else ("binh" if t < l5 else "buon"))


func _c_rung() -> Array:
	var l2 := L("k05-02")
	var l3 := L("k05-03")
	var l3b := L("k05-03b")
	var l4 := L("k05-04")
	var l5 := L("k05-05")
	var l6 := L("k05-06")
	var b6 := L("k05-06b")
	var l7 := L("k05-07")
	var l8 := L("k05-08")
	if t < l2:
		return [Vector2(lerpf(1300.0, 1000.0, smooth(0.0, l2, t)), 520.0), 1.0]
	if t < l3:
		return [Vector2(940, 600), lerpf(1.0, 1.3, smooth(l2, l2 + 2.0, t))]
	if t < l3b:
		return [Vector2(950, 520), lerpf(1.3, 1.05, smooth(l3, l3 + 1.5, t))]
	if t < l4:
		var hf := l3b + (l4 - l3b) * 0.5
		return [Vector2(760, 640) if t < hf else Vector2(1170, 690), 1.75]
	if t < l5:
		return [Vector2(lerpf(900.0, 640.0, smooth(l4, l4 + 3.0, t)), 540.0), 1.0]
	if t < l6:
		return [Vector2(1200, 600), 1.12]
	if t < b6:
		return [Vector2(1180, 640), lerpf(1.12, 1.35, smooth(l6, l6 + 2.0, t))]
	if t < l8:
		return [Vector2(lerpf(1100.0, 960.0, smooth(b6, l7, t)), 540.0), 1.0]
	return [Vector2(1440, 650), lerpf(1.2, 1.85, smooth(l8, l8 + 2.0, t))]


func _g_rung(c: Node2D) -> void:
	var gy := ground_y
	c.draw_rect(Rect2(-3000, gy, 7000, 600), Color("#1d3330"))
	hatch(c, PackedVector2Array([Vector2(-3000, gy), Vector2(4000, gy), Vector2(4000, gy + 600), Vector2(-3000, gy + 600)]), 0.5, 26.0, Color(ink, 0.4))
	grass(c, -800, 2700, gy + 4, 46.0, 30.0, Color("#3a6a52"), 3)
	# đuốc phái Tung Sơn tràn tới từ trái
	var k4 := smooth(L("k05-04") + 0.5, L("k05-04") + 4.0, t) * (1.0 - smooth(L("k05-05") - 0.8, L("k05-05") + 0.8, t))
	if k4 > 0.01:
		for i in 9:
			var x := -500.0 + i * 80.0 + k4 * 300.0
			var y := gy - 6.0 - (i % 3) * 14.0
			c.draw_line(Vector2(x, y), Vector2(x + 6, y - 150), Color("#8a6a6a", k4), 6.0)
			c.draw_line(Vector2(x + 30, y), Vector2(x + 44, y - 210), Color("#8a6a6a", k4), 3.0)
			c.draw_colored_polygon(PackedVector2Array([Vector2(x + 44, y - 210), Vector2(x + 52, y - 236), Vector2(x + 36, y - 214)]), Color("#8a6a6a", k4))
			c.draw_circle(Vector2(x + 6, y - 158) + Vector2(sin(t * 13.0 + i), 0) * 3.0, 11.0, Color("#ff9a3a", k4))
	# tảng đá
	var r := ROCK
	shape(c, round_pts(PackedVector2Array([r + Vector2(-150, 50), r + Vector2(-140, -4), r + Vector2(-60, -22), r + Vector2(80, -16), r + Vector2(140, 10), r + Vector2(150, 50)])), Color("#5d6466"), 4.0)
	hatch(c, PackedVector2Array([r + Vector2(-140, 10), r + Vector2(140, 14), r + Vector2(150, 50), r + Vector2(-150, 50)]), 0.9, 14.0, Color(ink, 0.4))
	# dải khuông nhạc
	var sa := smooth(L("k05-02"), L("k05-02") + 1.5, t) * (1.0 - smooth(L("k05-06b") + 2.0, L("k05-06b") + 4.5, t))
	if sa > 0.01:
		var brk := smooth(L("k05-04") + 0.5, L("k05-04") + 2.0, t) * (1.0 - smooth(L("k05-05"), L("k05-05") + 1.5, t))
		var col := PALE.lerp(Color("#d0503a"), brk)
		for li in 5:
			var seg := PackedVector2Array()
			for i in 81:
				var x := -700.0 + i * 45.0
				var gap := brk > 0.05 and sin(x * 0.021 + li * 1.7) > 1.0 - brk * 0.9
				if gap:
					if seg.size() > 1:
						c.draw_polyline(seg, Color(col, 0.55 * sa), 2.5, true)
					seg = PackedVector2Array()
					continue
				seg.append(Vector2(x, _staff_y(x) + (li - 2) * 15.0 + sin(x * 0.05 + t * 8.0) * 6.0 * brk))
			if seg.size() > 1:
				c.draw_polyline(seg, Color(col, 0.55 * sa), 2.5, true)


func _note_flow(c: Node2D) -> void:
	var brk := smooth(L("k05-04") + 0.5, L("k05-04") + 2.0, t)
	var pale := smooth(L("k05-05"), L("k05-05") + 1.0, t)
	var wins := _wins()
	for wi in wins.size():
		var w: Array = wins[wi]
		var w0: float = w[0]
		var w1: float = w[1]
		var b := w0
		var i := 0
		while b < minf(w1, t):
			var age := t - b
			if age < 7.0:
				var src := tip_l if i % 2 == 0 else tip_k
				var dir := 1.0 if i % 2 == 0 else -1.0
				var x := src.x + dir * age * 165.0
				var ty := _staff_y(x) + (i % 5 - 2) * 15.0
				var y := lerpf(src.y, ty, smooth(0.0, 1.3, age)) + sin(i * 13.0 + t * 20.0) * 12.0 * brk * (1.0 - pale)
				var col := JADE if i % 2 == 0 else GOLD
				col = col.lerp(Color("#c0402e"), brk * (1.0 - pale)).lerp(PALE, pale)
				var al := smooth(0.0, 0.25, age) * (1.0 - smooth(5.8, 7.0, age))
				_note(c, Vector2(x, y), 1.0, col, al, i % 3)
			b += 0.4
			i += 1


func _n_rung(c: Node2D) -> void:
	tip_l = _tieu(c, luu, 1.0 if float(luu.show) > 0.02 else 0.0)
	if float(khuc.show) > 0.02:
		tip_k = _dan(c, ROCK, -1.0, float(khuc.show))
	_note_flow(c)
	# gốc cây Lệnh Hồ Xung nấp
	var tx := 1830.0
	shape(c, PackedVector2Array([Vector2(tx - 60, ground_y + 10), Vector2(tx - 40, -200), Vector2(tx + 50, -200), Vector2(tx + 70, ground_y + 10)]), Color("#1e2c2a"), 4.0)
	hatch(c, PackedVector2Array([Vector2(tx - 50, ground_y), Vector2(tx - 40, -200), Vector2(tx + 50, -200), Vector2(tx + 60, ground_y)]), 1.4, 18.0, Color(ink, 0.5))
	# hai cuốn phổ bay từ tay hai người sang tay chàng, rồi vào ngực áo
	var l6 := L("k05-06")
	var l8 := L("k05-08")
	if t > l6 + 0.5 and t < l8 + 1.8:
		var hand := to_w(lhx.node.J["hdF"], Vector2.ZERO)
		var srcs := [to_w(luu.node.J["hdF"], Vector2.ZERO), to_w(khuc.node.J["hdB"], Vector2.ZERO)]
		for k in 2:
			var u := smooth(l6 + 0.9 + k * 0.3, l6 + 2.4 + k * 0.3, t)
			var s0: Vector2 = srcs[k]
			var mid := (s0 + hand) * 0.5 + Vector2(0, -160)
			var p := s0.lerp(mid, u).lerp(mid.lerp(hand, u), u) + Vector2(0, -8.0 * k)
			_cuon(c, p, -0.3 + u * 0.3 + k * 0.25, Color("#b8322c") if k == 0 else Color("#3a8a6a"), 1.0 - smooth(l8 + 1.2, l8 + 1.8, t))
	# chữ "?" quanh đầu chàng lúc ngó cuốn nhạc
	var pz := smooth(L("k05-08") + 2.0, L("k05-08") + 2.6, t)
	if pz > 0.01:
		var hp := head_of(lhx)
		for i in 3:
			var an := t * 1.6 + i * TAU / 3.0
			var p := hp + Vector2(cos(an) * 90.0, sin(an) * 30.0 - 10.0)
			if i == 1:
				_note(c, p, 0.7, PALE, pz, 1)
			else:
				c.draw_string(font, p, "?", HORIZONTAL_ALIGNMENT_LEFT, -1, 46, Color(PALE, pz))


func _torch_glow(c: Node2D) -> void:
	var k4 := smooth(L("k05-04") + 0.5, L("k05-04") + 4.0, t) * (1.0 - smooth(L("k05-05") - 0.8, L("k05-05") + 0.8, t))
	if k4 > 0.01:
		for i in 9:
			var x := -500.0 + i * 80.0 + k4 * 300.0
			var y := ground_y - 6.0 - (i % 3) * 14.0
			blob(c, Vector2(x + 6, y - 158), 90.0, Color(1.0, 0.45, 0.15, 0.25 * k4))
	var mo := smooth(L("k05-02"), L("k05-02") + 1.0, t) * (1.0 - smooth(L("k05-06b") + 2.0, L("k05-06b") + 4.0, t))
	blob(c, tip_l, 70.0, Color(JADE, 0.18 * mo))
	blob(c, tip_k, 80.0, Color(GOLD, 0.16 * mo))


# Quảng Lăng Tán: cuộn sách cổ mở ra giữa trời (bản truyện cũ)
func _sc_rung(c: Node2D) -> void:
	var l7 := L("k05-07")
	var k := smooth(l7 + 0.1, l7 + 1.3, t) * (1.0 - smooth(LE("k05-07") + 0.2, LE("k05-07") + 0.8, t))
	if k <= 0.01:
		return
	c.draw_rect(Rect2(0, 0, W, H), Color(0.02, 0.03, 0.06, 0.45 * k))
	var ctr := Vector2(960, 520)
	var hw := 470.0 * k
	var hh := 170.0
	c.draw_rect(Rect2(ctr.x - hw - 6, ctr.y - hh - 6, hw * 2 + 12, hh * 2 + 12), Color(ink, 0.9))
	c.draw_rect(Rect2(ctr.x - hw, ctr.y - hh, hw * 2, hh * 2), Color("#e3cf9e"))
	grain(c, Rect2(ctr.x - hw, ctr.y - hh, hw * 2, hh * 2), 40, Color("#b89a62", 0.4), 7)
	var rr := RandomNumberGenerator.new()
	rr.seed = 51
	var cols := int(hw * 2.0 / 46.0)
	for ci in cols:
		var x := ctr.x + hw - 30.0 - ci * 46.0
		for j in 7:
			var y := ctr.y - hh + 30.0 + j * 44.0
			var w := rr.randf_range(10, 22)
			c.draw_line(Vector2(x - w * 0.5, y), Vector2(x + w * 0.5, y + rr.randf_range(-4, 4)), Color("#3a2416", 0.8), 4.0)
			if rr.randf() < 0.5:
				c.draw_line(Vector2(x, y - 10), Vector2(x + rr.randf_range(-4, 4), y + 12), Color("#3a2416", 0.7), 3.0)
	for sx: float in [-1.0, 1.0]:
		var x := ctr.x + sx * (hw + 14.0)
		c.draw_rect(Rect2(x - 14, ctr.y - hh - 24, 28, hh * 2 + 48), Color("#5a2e1c"))
		c.draw_rect(Rect2(x - 14, ctr.y - hh - 24, 28, hh * 2 + 48), Color(ink), false, 3.0)
	# vết thời gian: góc cháy sém
	c.draw_colored_polygon(PackedVector2Array([Vector2(ctr.x + hw, ctr.y + hh), Vector2(ctr.x + hw - 90 * k, ctr.y + hh), Vector2(ctr.x + hw, ctr.y + hh - 70 * k)]), Color("#6b4a2a", 0.7))


# ================================================================ k20: sông trăng, hai chén, thành tên truyện

func _moon(c: Node2D, p: Vector2, r: float) -> void:
	for i in 4:
		c.draw_circle(p, r * (1.5 - i * 0.12), Color(1, 0.97, 0.85, 0.05))
	c.draw_circle(p, r, Color("#f6efd6"))
	c.draw_circle(p + Vector2(-26, -14), r * 0.2, Color("#e6dcbc"))
	c.draw_circle(p + Vector2(30, 24), r * 0.13, Color("#e6dcbc"))
	# ba năm: trăng tròn khuyết ba vòng
	var l3 := L("k20-03")
	var u := smooth(l3, l3 + 3.6, t)
	if u > 0.0 and u < 1.0:
		var ph := u * 3.0 * TAU
		c.draw_circle(p + Vector2(cos(ph) * r * 2.0, 0), r * 1.02, sky_top.lerp(sky_bot, 0.25))


func _s_song(_dt: float) -> void:
	var l1 := L("k20-01")
	var l3 := L("k20-03")
	var l4 := L("k20-04")
	var l5 := L("k20-05")
	var l6 := L("k20-06")
	var b6 := L("k20-06b")
	# thuyền rời bến khi ba năm qua
	bx = lerpf(740.0, 1000.0, smooth(l3 + 2.0, l3 + 6.0, t))
	by = 770.0 + sin(t * 1.25) * 5.0
	var roll := sin(t * 1.25 + 0.6) * 0.02
	lhx.pos = Vector2(bx - 120, by + roll * -120.0)
	dd.pos = Vector2(bx + 120, by + roll * 120.0)
	var play := smooth(l5 - 0.6, l5 + 0.4, t)
	var scroll := bump(l4 + 0.3, l4 + 1.0, l5 - 0.8, l5 - 0.2)
	lhx.extra = [[NGOI_XEP_BANG, 1.0], [{"head": sin(t * 1.5) * 3.0 * play, "torso": -3.0}, 1.0]]
	_tieu_hold(lhx, play)
	if scroll > 0.01:
		lhx.hold["F"] = [Vector2(96, -60), scroll]
		lhx.hold["B"] = [Vector2(40, -56), scroll]
	lhx.expr = "vui" if t > b6 or t < l1 + 4.0 else "binh"
	dd.extra = [[NGOI_XEP_BANG, 1.0], [{"head": 8.0 + sin(t * 1.2) * 3.0, "torso": 6.0}, 1.0]]
	_dan_hold(dd, dd.pos, -1.0, play)
	dd.expr = "vui" if t > b6 else ("binh" if play < 0.5 else "dac-y")
	# Hướng Vấn Thiên trên bến nhận cờ giáo, vái tiễn
	huong.show = smooth(l3 - 0.6, l3, t) * (1.0 - smooth(l4 + 0.5, l4 + 1.5, t))
	huong.hold["F"] = [Vector2(60, -40), 1.0]
	huong.extra = [[{"torso": 20.0, "head": 12.0}, bump(l3 + 2.5, l3 + 3.0, l3 + 4.0, l3 + 4.5)]]
	# bóng hai ông bạn năm xưa trên trăng
	var gh := bump(l6 + 0.4, l6 + 1.6, LE("k20-06") - 0.6, LE("k20-06") + 0.4) * 0.7
	luu.show = gh
	khuc.show = gh
	_tieu_hold(luu, 1.0)
	khuc.extra = [[{"uaF": -40.0, "faF": -100.0, "uaB": -40.0, "faB": -100.0, "torso": 10.0, "head": 8.0}, 1.0]]
	luu.expr = "vui"
	khuc.expr = "vui"


func _c_song() -> Array:
	var l1 := L("k20-01")
	var l2 := L("k20-02")
	var l1b := L("k20-01b")
	var l3 := L("k20-03")
	var l4 := L("k20-04")
	var l5 := L("k20-05")
	var l6 := L("k20-06")
	var b6 := L("k20-06b")
	var l7 := L("k20-07")
	var l8 := L("k20-08")
	if t < l2:
		return [Vector2(bx, 690), lerpf(2.1, 1.7, smooth(l1, l2, t))]
	if t < l1b:
		return [Vector2(960, 540), lerpf(1.3, 1.0, smooth(l2, l2 + 1.5, t))]
	if t < l3:
		return [Vector2(1520, 600), 1.45]
	if t < l4:
		return [Vector2(lerpf(620.0, 860.0, smooth(l3 + 2.0, l3 + 6.0, t)), 600.0), 1.15]
	if t < l5:
		return [Vector2(bx - 100, 650), 1.8]
	if t < l6:
		return [Vector2(bx, 640), 1.35]
	if t < b6:
		return [Vector2(1180, 470), 1.0]
	if t < l7 - 1.4:
		return [Vector2(bx, 620), 1.35]
	if t < l8:
		return [Vector2(960, 470), lerpf(1.25, 1.0, smooth(l7 - 1.4, l7 - 0.4, t))]
	return [Vector2(960, 500), lerpf(1.0, 0.82, smooth(l8, l8 + 4.0, t))]


func _g_song(c: Node2D) -> void:
	var wy := 640.0
	# bờ xa
	shape(c, PackedVector2Array([Vector2(-2500, wy), Vector2(-2500, 600), Vector2(400, 596), Vector2(1100, 606), Vector2(4400, 598), Vector2(4400, wy)]), Color("#141a38"), 3.0)
	# mặt sông
	vgrad(c, Rect2(-2500, wy, 6900, 900), Color("#1e2a5a"), Color("#0b1030"))
	var rr := RandomNumberGenerator.new()
	rr.seed = 3
	for i in 90:
		var y := wy + 10.0 + pow(rr.randf(), 1.6) * 620.0
		var x := rr.randf_range(-1500, 3400) + sin(t * 0.8 + i) * 20.0
		var w := 30.0 + (y - wy) * 0.25
		c.draw_line(Vector2(x, y), Vector2(x + w, y), Color(0.7, 0.8, 1.0, 0.12), 2.0)
	# cột sáng trăng trên mặt nước
	for i in 26:
		var y := wy + 8.0 + i * 22.0
		var w := 30.0 + i * 5.0 + sin(t * 2.0 + i * 1.3) * 18.0
		var x := 1320.0 + sin(t * 1.4 + i * 0.7) * 14.0
		c.draw_line(Vector2(x - w, y), Vector2(x + w, y), Color(1, 0.95, 0.8, 0.35 - i * 0.01), 4.0)
	# cờ hai phe trên bờ xa nghiêng vào nhau (giảng hoà)
	var l2 := L("k20-02")
	var fk := bump(l2 - 0.3, l2 + 0.5, LE("k20-02") + 0.2, LE("k20-02") + 1.0)
	if fk > 0.01:
		var lean := smooth(l2 + 1.5, l2 + 3.5, t) * 0.38
		_co(c, Vector2(700, 604), lean, Color("#1a1418"), true, fk)
		_co(c, Vector2(1220, 604), -lean, Color("#efe6d2"), false, fk)
	# ngai vàng trống trên bờ, ngọn đèn tắt
	var l1b := L("k20-01b")
	var tk := bump(l1b - 0.3, l1b + 0.5, LE("k20-01b") + 0.3, LE("k20-01b") + 1.0)
	if tk > 0.01:
		var p := Vector2(1520, 606)
		flat_blob(c, p + Vector2(0, 6), 150.0, 0.22, Color("#e8c070", 0.22 * tk))
		blob(c, p + Vector2(0, -90), 150.0, Color("#ffd27a", 0.10 * tk))
		shape(c, PackedVector2Array([p + Vector2(-46, 0), p + Vector2(-46, -150), p + Vector2(-36, -170), p + Vector2(36, -170), p + Vector2(46, -150), p + Vector2(46, 0)]), Color("#b8872e", tk), 4.0)
		shape(c, PackedVector2Array([p + Vector2(-30, -60), p + Vector2(-30, -140), p + Vector2(30, -140), p + Vector2(30, -60)]), Color("#c8322c", tk), 3.0)
		shape(c, PackedVector2Array([p + Vector2(-60, -50), p + Vector2(60, -50), p + Vector2(60, -30), p + Vector2(-60, -30)]), Color("#e0b04a", tk), 3.0)
		for sx: float in [-1.0, 1.0]:
			c.draw_circle(p + Vector2(sx * 40, -172), 9.0, Color("#f0c860", tk))
		var lit := 1.0 - smooth(l1b + 2.5, l1b + 3.5, t)
		c.draw_line(p + Vector2(90, 0), p + Vector2(90, -120), Color(ink, tk), 4.0)
		c.draw_circle(p + Vector2(90, -132), 14.0, Color(Color("#ffb04a").lerp(Color("#3a2a2a"), 1.0 - lit), tk))
		if lit < 1.0:
			for j in 4:
				var a := smooth(l1b + 2.5, l1b + 5.0, t)
				c.draw_circle(p + Vector2(90 + sin(t * 2.0 + j) * 8.0, -150 - j * 18.0 * a), 6.0 + j * 2.0, Color(0.6, 0.6, 0.7, 0.25 * tk * (1.0 - a * 0.6)))
	# hàng ghế cao đời nào cũng có người tranh
	var l9 := L("k20-09")
	var gk := smooth(l9 - 0.4, l9 + 1.2, t)
	if gk > 0.01:
		for i in 6:
			var p := Vector2(1380 + i * 140, 606)
			ghe(c, p, -1.0, Color("#b09090", gk))
	# bến gỗ bên trái
	var pk := 1.0
	for i in 6:
		c.draw_line(Vector2(40 + i * 90, 780), Vector2(40 + i * 90, 900), Color("#2a1a12", pk), 8.0)
	shape(c, PackedVector2Array([Vector2(-600, 770), Vector2(540, 770), Vector2(540, 786), Vector2(-600, 786)]), Color("#6b4a2a"), 3.0)
	# cột, mái thuyền phía sau người
	for sx: float in [-1.0, 1.0]:
		c.draw_line(Vector2(bx + sx * 230, by), Vector2(bx + sx * 220, by - 300), Color("#3a2416"), 7.0)
	var rope := PackedVector2Array()
	for i in 21:
		var k := i / 20.0
		rope.append(Vector2(bx - 220 + 440 * k, by - 294 + sin(k * PI) * 46.0))
	var wd := smooth(L("k20-06b") - 0.3, L("k20-06b") + 0.8, t)
	c.draw_polyline(rope, Color("#c8322c", 0.3 + 0.7 * wd), 4.0 + wd * 4.0, true)


func _co(c: Node2D, p: Vector2, lean: float, col: Color, giao: bool, al: float) -> void:
	c.draw_set_transform(p, lean, Vector2.ONE)
	c.draw_line(Vector2.ZERO, Vector2(0, -260), Color("#2a1a12", al), 6.0)
	var cl := PackedVector2Array()
	for i in 9:
		var k := i / 8.0
		cl.append(Vector2((1.0 if not giao else -1.0) * k * 130.0, -250 + sin(k * 5.0 - t * 4.0) * 8.0 * k))
	for i in range(8, -1, -1):
		var k := i / 8.0
		cl.append(Vector2((1.0 if not giao else -1.0) * k * 120.0, -170 + sin(k * 5.0 - t * 4.0) * 8.0 * k))
	shape(c, cl, Color(col, al), 3.0)
	var cc := Vector2((1.0 if not giao else -1.0) * 62.0, -210)
	if giao:
		c.draw_circle(cc, 22.0, Color("#c8322c", al))
		c.draw_circle(cc + Vector2(26, -6), 14.0, Color("#efe6d2", al))
		c.draw_circle(cc + Vector2(32, -9), 12.0, Color(col, al))
	else:
		c.draw_line(cc + Vector2(-40, 0), cc + Vector2(40, 0), Color("#3a5a8a", al), 8.0)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _title_pos() -> Array:
	var tw := font.get_string_size(TITLE, HORIZONTAL_ALIGNMENT_LEFT, -1, TITLE_SZ).x
	var x0 := 960.0 - tw * 0.5
	var out := []
	for i in TITLE.length():
		var ch := TITLE.substr(i, 1)
		var x := x0 + font.get_string_size(TITLE.substr(0, i), HORIZONTAL_ALIGNMENT_LEFT, -1, TITLE_SZ).x
		out.append([ch, Vector2(x, 330), font.get_string_size(ch, HORIZONTAL_ALIGNMENT_LEFT, -1, TITLE_SZ).x])
	return out


func _n_song(c: Node2D) -> void:
	# thân thuyền trước chân hai người
	var hull := PackedVector2Array()
	for i in 17:
		var k := i / 16.0
		hull.append(Vector2(bx - 330 + 660 * k, by + 4 - sin(k * PI) * 4.0 - pow(absf(k - 0.5) * 2.0, 3.0) * 40.0))
	for i in range(16, -1, -1):
		var k := i / 16.0
		hull.append(Vector2(bx - 280 + 560 * k, by + 70 + sin(k * PI) * 10.0))
	shape(c, hull, Color("#5a3a22"), 4.0)
	hatch(c, hull, 0.4, 16.0, Color(ink, 0.35))
	c.draw_line(Vector2(bx - 320, by + 10), Vector2(bx + 320, by + 10), Color("#8a5e38"), 5.0)
	var l1 := L("k20-01")
	var wc: Color = WINE[mini(lan, 9)]
	# hồ lô rót từ trên xuống, lần lượt hai chén
	var pk := bump(l1 + 0.2, l1 + 0.7, l1 + 4.0, l1 + 4.6)
	if pk > 0.01:
		var to := 0 if t < l1 + 2.2 else 1
		var cp := Vector2(bx - 26 + to * 52, by - 56)
		var gp := Vector2(bx - 60 + to * 52, by - 230 - (1.0 - pk) * 120.0)
		c.draw_set_transform(gp, 2.2, Vector2.ONE)
		holo(c, Vector2.ZERO, 1.1, wc, 0.6)
		c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		var mouth := gp + Vector2(0, -50).rotated(2.2)
		var pour := bump(l1 + 0.7, l1 + 0.9, l1 + 3.7, l1 + 3.9)
		if pour > 0.01:
			var pts := PackedVector2Array()
			for i in 9:
				var k := i / 8.0
				pts.append(mouth.lerp(cp, k) + Vector2(sin(k * PI) * 18.0, 0))
			c.draw_polyline(pts, Color(wc, 0.9 * pour), 6.0, true)
	# nhạc cụ
	tip_l = _tieu(c, lhx, smooth(L("k20-05") - 0.6, L("k20-05") + 0.4, t))
	tip_k = _dan(c, dd.pos, -1.0)
	# khay nhỏ
	shape(c, PackedVector2Array([Vector2(bx - 62, by - 34), Vector2(bx + 62, by - 34), Vector2(bx + 52, by - 22), Vector2(bx - 52, by - 22)]), Color("#8a5e38"), 3.0)
	# hai chén rượu giữa hai người
	for k in 2:
		var cp := Vector2(bx - 26 + k * 52, by - 34)
		var fill := smooth(l1 + 0.8 + k * 1.4, l1 + 1.9 + k * 1.4, t)
		shape(c, PackedVector2Array([cp + Vector2(-16, -22), cp + Vector2(16, -22), cp + Vector2(10, 0), cp + Vector2(-10, 0)]), Color("#e6e2c8"), 3.0)
		if fill > 0.01:
			c.draw_rect(Rect2(cp + Vector2(-13, -22 + 18 * (1.0 - fill) + 2), Vector2(26, 3)), wc)
	# bóng hai ông bạn cầm tiêu trên trăng
	if float(luu.show) > 0.02:
		_tieu(c, luu, 1.0)
	# cuộn nhạc phổ mở trong tay chàng
	var l4 := L("k20-04")
	var sk := bump(l4 + 0.6, l4 + 1.4, L("k20-05") - 0.8, L("k20-05") - 0.2)
	if sk > 0.01:
		var a := to_w(lhx.node.J["hdB"], Vector2.ZERO)
		var b := to_w(lhx.node.J["hdF"], Vector2.ZERO)
		var mid := (a + b) * 0.5
		var hw := maxf(8.0, (b - a).length() * 0.5 + 20.0) * sk
		c.draw_rect(Rect2(mid.x - hw, mid.y - 46, hw * 2, 80), Color("#efe2bf"))
		c.draw_rect(Rect2(mid.x - hw, mid.y - 46, hw * 2, 80), Color(ink), false, 3.0)
		for i in int(hw / 14.0):
			var x := mid.x - hw + 10 + i * 28
			_note(c, Vector2(x, mid.y - 4 + sin(i * 2.1) * 14.0), 0.45, Color("#3a2416"), sk, i % 3)
	# nốt tiêu, nốt cầm xoắn lên trời
	var l5 := L("k20-05")
	var l7 := L("k20-07")
	var b := l5 + 0.4
	var i := 0
	while b < minf(t, l7 - 1.4):
		var age := t - b
		if age < 5.0:
			var src := tip_l if i % 2 == 0 else tip_k
			var sd := -1.0 if i % 2 == 0 else 1.0
			var p := src + Vector2(sd * sin(age * 2.2) * 50.0 * age * 0.5 + sd * age * 30.0, -age * 110.0)
			_note(c, p, 0.9, JADE if i % 2 == 0 else GOLD, smooth(0.0, 0.2, age) * (1.0 - smooth(3.8, 5.0, age)), i % 3)
		b += 0.32
		i += 1
	# nốt bay thành tên truyện
	var tp := _title_pos()
	for j in tp.size():
		var e: Array = tp[j]
		var ch: String = e[0]
		if ch == " ":
			continue
		var bj := l7 - 1.1 + j * 0.06
		var u := smooth(bj, bj + 1.3, t)
		if u <= 0.0:
			continue
		var cw: float = e[2]
		var dst: Vector2 = e[1]
		var dc := dst + Vector2(cw * 0.5, -TITLE_SZ * 0.35)
		var src := tip_l if j % 2 == 0 else tip_k
		var mid := (src + dc) * 0.5 + Vector2((j - 8) * 30.0, -220)
		var p := src.lerp(mid, u).lerp(mid.lerp(dc, u), u)
		var lt := smooth(0.85, 1.0, u)
		_note(c, p, 1.0, JADE if j % 2 == 0 else GOLD, 1.0 - lt, j % 3)
		if lt > 0.01:
			var col := Color("#fff4d6")
			c.draw_string(font, dst + Vector2(4, 4), ch, HORIZONTAL_ALIGNMENT_LEFT, -1, TITLE_SZ, Color(0.05, 0.05, 0.15, 0.7 * lt))
			c.draw_string_outline(font, dst, ch, HORIZONTAL_ALIGNMENT_LEFT, -1, TITLE_SZ, 10, Color("#3a2416", lt))
			c.draw_string(font, dst, ch, HORIZONTAL_ALIGNMENT_LEFT, -1, TITLE_SZ, Color(col, lt))
	# Hướng Vấn Thiên cầm cờ giáo
	if float(huong.show) > 0.02:
		var hp := to_w(huong.node.J["hdF"], Vector2.ZERO)
		c.draw_set_transform(hp, 0.0, Vector2(0.6, 0.6))
		_co(c, Vector2(0, 160), 0.05, Color("#2a2028"), true, float(huong.show))
		c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _glow_song(c: Node2D) -> void:
	var wd := smooth(L("k20-06b") - 0.3, L("k20-06b") + 0.8, t)
	for sx: float in [-1.0, 1.0]:
		var top := Vector2(bx + sx * 220, by - 300)
		var lp := lantern(c, top, 40.0, 26.0 + 6.0 * wd, Color("#e8483a").lerp(Color("#ff6a4a"), wd), int(sx + 3))
		blob(c, lp, 70.0 + 70.0 * wd, Color(1.0, 0.35, 0.2, 0.1 + 0.25 * wd))
	var mo := smooth(L("k20-05") - 0.2, L("k20-05") + 0.8, t)
	blob(c, tip_l, 60.0, Color(JADE, 0.18 * mo))
	blob(c, tip_k, 70.0, Color(GOLD, 0.16 * mo))
	# lấp lánh khi chữ thành hình (sfx sparkle ở L(k20-07) + 0.2)
	var l7 := L("k20-07")
	var sp := bump(l7 + 0.1, l7 + 0.3, l7 + 1.6, l7 + 2.6)
	if sp > 0.01:
		var rr := RandomNumberGenerator.new()
		rr.seed = 77
		for i in 26:
			var p := Vector2(rr.randf_range(380, 1540), rr.randf_range(210, 360))
			var ph := rr.randf() * TAU
			var s := (0.5 + 0.5 * sin(t * 9.0 + ph)) * sp * rr.randf_range(10, 26)
			c.draw_line(p - Vector2(s, 0), p + Vector2(s, 0), Color(1.4, 1.3, 1.0, 0.8 * sp), 2.0)
			c.draw_line(p - Vector2(0, s), p + Vector2(0, s), Color(1.4, 1.3, 1.0, 0.8 * sp), 2.0)
		blob(c, Vector2(960, 300), 520.0, Color(1.0, 0.9, 0.6, 0.12 * sp))
	var tl := smooth(l7 + 0.2, l7 + 1.4, t)
	if tl > 0.01:
		blob(c, Vector2(960, 300), 420.0, Color(1.0, 0.85, 0.55, 0.06 * tl))
