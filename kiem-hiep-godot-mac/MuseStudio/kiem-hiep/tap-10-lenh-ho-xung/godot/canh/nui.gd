extends "res://canh.gd"
# Núi Hoa Sơn. Ba kiểu dựng theo arg.m:
#   chieu (k03)  — sân nhà tranh lúc chiều tà: diorama một sân, máy quay đi giữa các trạm; hồi tưởng tuổi thơ ngả nâu
#   sang  (k03b) — sân tập trên vách sáng sương: người tới sau, đôi kiếm tập, hồ lô treo cành thông
#   mua   (k14)  — cổng núi trong mưa: cổng đóng, thư bay, bóng đi xuống bậc đá chéo màn hình

const GY := 860.0
var m := "chieu"
var lhx: Dictionary
var tre: Dictionary
var nhac: Dictionary
var san: Dictionary
var lam: Dictionary
var teo: Dictionary
var ho: Dictionary
var ma: Dictionary
var kiem_san: Dictionary
var kiem_lam: Dictionary
var ho_at := "hong"
var kiem_at := "hong"
const HUT := Vector2(1300, GY)
const PINE_X := 1520.0
const GATE := Vector2(470, 560)
const TEO_X := 4300.0


func _palette() -> void:
	m = arg.get("m", "chieu")
	ground_y = GY
	match m:
		"chieu":
			sky_top = Color("#6e4a6a")
			sky_bot = Color("#f4b062")
			haze = Color("#e9a978")
			char_tint = Color(1.0, 0.92, 0.82)
			wind_base = 0.25
			wind_gust = 0.4
			vign_a = 0.3
		"sang":
			sky_top = Color("#8fb8bc")
			sky_bot = Color("#f6ecd2")
			haze = Color("#e6eadc")
			char_tint = Color(1.0, 0.99, 0.95)
			wind_base = 0.35
			wind_gust = 0.5
			vign_a = 0.22
		"mua":
			sky_top = Color("#3a4e60")
			sky_bot = Color("#8a9aa2")
			haze = Color("#8c9aa0")
			char_tint = Color(0.9, 0.93, 0.98)
			wind_base = -0.3
			wind_gust = 0.5
			vign_a = 0.34


func _build() -> void:
	match m:
		"chieu":
			tre = actor("lenh-ho-xung", Vector2(700, GY), 1.0)
			tre.size = 0.68
			lhx = actor("lenh-ho-xung", Vector2(760, GY), 1.0)
			ho = prop(lhx, "ho_lo", "hong", "F")
			ma = prop(lhx, "ma_do", "mat", "F", {"cheek": Vector2(62, -54)})
			nhac = actor("nhac-bat-quan", HUT + Vector2(0, 0), -1.0)
			san = actor("nhac-linh-san", Vector2(300, GY), 1.0)
			san.size = 0.66
		"sang":
			nhac = actor("nhac-bat-quan", Vector2(980, GY), -1.0)
			san = actor("nhac-linh-san", Vector2(1120, GY), -1.0)
			lam = actor("lam-binh-chi", Vector2(-160, GY), 1.0)
			lhx = actor("lenh-ho-xung", Vector2(1290, GY), -1.0)
			ho = prop(lhx, "ho_lo", "hong", "F")
			kiem_san = prop(san, "kiem", "hong", "F", {"vo": true})
			kiem_lam = prop(lam, "kiem", "hong", "F", {"vo": true})
		"mua":
			lhx = actor("lenh-ho-xung", GATE + Vector2(300, 0), -1.0)
			ho = prop(lhx, "ho_lo", "hong", "F")
			nhac = actor("nhac-bat-quan", GATE + Vector2(-10, 0), 1.0)
			teo = actor("teo-tieu-nhi", Vector2(TEO_X, GY), 1.0)


func _story(dt: float) -> void:
	if t < 0.0:
		return
	match m:
		"chieu":
			_s_chieu(dt)
		"sang":
			_s_sang(dt)
		"mua":
			_s_mua(dt)


func _cam() -> Array:
	match m:
		"chieu":
			return _c_chieu()
		"sang":
			return _c_sang()
		"mua":
			return _c_mua()
	return [CENTER, 1.0]


# ---------------------------------------------------------------- công cụ chung của file

# máy quay theo khoá [giờ, tâm, zoom, (thời gian chuyển; 0 = cắt)]
func _ck(keys: Array) -> Array:
	var k0: Array = keys[0]
	var p: Vector2 = k0[1]
	var z: float = k0[2]
	for k in keys:
		var kt: float = k[0]
		var bl: float = k[3] if k.size() > 3 else 1.2
		var w := 0.0
		if bl <= 0.0:
			w = 1.0 if t >= kt else 0.0
		else:
			w = smooth(kt, kt + bl, t)
		var kp: Vector2 = k[1]
		var kz: float = k[2]
		p = p.lerp(kp, w)
		z = lerpf(z, kz, w)
	return [p, z]


# đi từ p0 tới p1 trong [t0, t1]: chân bước tại chỗ theo tốc độ thật
func _di(a: Dictionary, p0: Vector2, p1: Vector2, t0: float, t1: float) -> void:
	var k := clampf((t - t0) / maxf(t1 - t0, 0.01), 0.0, 1.0)
	a.pos = p0.lerp(p1, k)
	var moving := t > t0 and t < t1
	a.inplace = (p1 - p0).length() / maxf(t1 - t0, 0.01) if moving else 0.0
	if moving and absf(p1.x - p0.x) > 1.0:
		a.face = signf(p1.x - p0.x)


func _lips(a: Dictionary, off: Vector2) -> Vector2:
	var to: Node2D = a.node.J["torso"]
	return from_w(to, to_w(a.node.J["head"], Vector2(0, -30))) + off


# uống hồ lô: tip 0..1 đưa lên môi
func _uong(a: Dictionary, v: Dictionary, tip: float, pour_on: bool) -> void:
	a.hold["F"] = [Vector2(54, -30).lerp(_lips(a, Vector2(12, -12)), tip), tip]
	v.lock = tip
	v.lockdir = Vector2.DOWN.lerp(Vector2(0.75, -0.66), tip).normalized()
	v.aim = Vector2(0, -30)
	v.pour = tip if pour_on and tip > 0.8 else 0.0


func _ho_den(at: String) -> void:
	if ho_at != at:
		ho_at = at
		prop_to(ho, at, "F")


# đỉnh Hoa Sơn: cột đá dựng như lưỡi kiếm, vết nứt dọc, thông bám đỉnh
func _hoa_son(c: Node2D, base_y: float, col: Color, seed: int, n: int, x0: float, step: float, hmin: float, hmax: float, snow := 0.0) -> void:
	var rr := RandomNumberGenerator.new()
	rr.seed = seed
	for i in n:
		var x := x0 + i * step + rr.randf_range(-60, 60)
		var h := rr.randf_range(hmin, hmax)
		var wd := rr.randf_range(150, 260)
		var lean := rr.randf_range(-30, 30)
		var tip := Vector2(x + lean, base_y - h)
		var pts := PackedVector2Array([Vector2(x - wd, base_y + 40), Vector2(x - wd * 0.55, base_y - h * 0.45), Vector2(x - wd * 0.2 + lean * 0.8, base_y - h * 0.9),
			tip + Vector2(-18, 6), tip + Vector2(20, 0), Vector2(x + wd * 0.25 + lean * 0.7, base_y - h * 0.82), Vector2(x + wd * 0.6, base_y - h * 0.4), Vector2(x + wd, base_y + 40)])
		var rp := round_pts(pts, true, 3)
		shape(c, rp, col, 3.0, inkof(col, 0.35))
		clip_fill(c, rp, PackedVector2Array([tip + Vector2(10, -40), Vector2(x + wd * 1.2, base_y + 60), Vector2(x + 10, base_y + 60)]), Color(col.darkened(0.18), 0.85))
		for k in 4:
			var cx := x + rr.randf_range(-wd * 0.4, wd * 0.4)
			var cy := base_y - rr.randf_range(h * 0.15, h * 0.75)
			cut(c, Vector2(cx, cy), Vector2(cx + rr.randf_range(-12, 12), cy + rr.randf_range(60, 140)), 3.0, Color(inkof(col, 0.5), 0.5))
		if snow > 0.0:
			clip_fill(c, rp, PackedVector2Array([tip + Vector2(-80, -20), tip + Vector2(80, -20), tip + Vector2(60, h * 0.18), tip + Vector2(-60, h * 0.12)]), Color(1, 1, 1, snow))
		pine(c, tip + Vector2(-8, 10), 70.0, 46.0, col.lerp(Color("#2f4a36"), 0.6), 0.0, 2.5, i)


# sân đất trên mỏm núi, mép vực đá phía trước
func _san_dat(c: Node2D, col: Color) -> void:
	var poly := PackedVector2Array([Vector2(-600, GY), Vector2(2600, GY), Vector2(2600, 1500), Vector2(-600, 1500)])
	c.draw_colored_polygon(poly, col)
	hatch(c, poly, 0.25, 26.0, Color(ink, 0.22))
	c.draw_line(Vector2(-600, GY), Vector2(2600, GY), inkof(col, 0.4), 4.0)
	var rr := RandomNumberGenerator.new()
	rr.seed = 7
	for i in 30:
		var p := Vector2(rr.randf_range(-500, 2500), GY + rr.randf_range(20, 200))
		flat_blob(c, p, rr.randf_range(12, 30), 0.35, Color(col.darkened(0.25), 0.5))


# nhà tranh vách đất: p = giữa chân tường; lit 0..1 cửa sáng
func _nha_tranh(c: Node2D, p: Vector2, lit: float) -> void:
	var wd := 420.0
	var ht := 200.0
	var x0 := p.x - wd * 0.5
	var x1 := p.x + wd * 0.5
	var top := p.y - ht
	shape(c, PackedVector2Array([Vector2(x0 - 24, p.y + 8), Vector2(x0 - 16, p.y - 22), Vector2(x1 + 16, p.y - 22), Vector2(x1 + 24, p.y + 8)]), Color("#8c8478"), 3.0)
	var wall := PackedVector2Array([Vector2(x0, p.y - 20), Vector2(x0, top), Vector2(x1, top), Vector2(x1, p.y - 20)])
	shape(c, wall, Color("#c49563"), 4.0)
	hatch(c, wall, 0.95, 15.0, Color(ink, 0.22))
	for xx: float in [x0 + 10, p.x - 70, p.x + 70, x1 - 10]:
		shape(c, PackedVector2Array([Vector2(xx - 8, p.y - 20), Vector2(xx - 8, top), Vector2(xx + 8, top), Vector2(xx + 8, p.y - 20)]), Color("#7a5232"), 3.0)
	var door := Rect2(p.x - 46, p.y - 168, 92, 148)
	var dc := Color("#2a1810").lerp(Color(1.5, 1.0, 0.5), lit * 0.75)
	shape(c, PackedVector2Array([door.position, door.position + Vector2(door.size.x, 0), door.end, door.position + Vector2(0, door.size.y)]), dc, 4.0, inkof(Color("#7a5232")))
	for sx: float in [-1.0, 1.0]:
		var wc := Vector2(p.x + sx * 140, p.y - 120)
		c.draw_circle(wc, 34.0, inkof(Color("#7a5232")))
		c.draw_circle(wc, 29.0, Color("#3a2416").lerp(Color(1.4, 0.95, 0.5), lit * 0.6))
		c.draw_line(wc + Vector2(-29, 0), wc + Vector2(29, 0), inkof(Color("#7a5232")), 3.0)
		c.draw_line(wc + Vector2(0, -29), wc + Vector2(0, 29), inkof(Color("#7a5232")), 3.0)
	# mái tranh: khối dày, sợi rơm chải xuống, mép tua răng cưa
	var thatch := Color("#c9a35a")
	var ridge := Vector2(p.x, top - 170)
	var roof := PackedVector2Array([Vector2(x0 - 80, top + 26), Vector2(x0 - 40, top - 40), ridge + Vector2(-60, 0), ridge + Vector2(60, 0), Vector2(x1 + 40, top - 40), Vector2(x1 + 80, top + 26)])
	var rp := round_pts(roof, true, 4)
	shape(c, rp, thatch, 4.0)
	clip_fill(c, rp, PackedVector2Array([ridge + Vector2(0, -20), Vector2(x1 + 120, top + 40), Vector2(p.x, top + 40)]), Color(thatch.darkened(0.15), 0.9))
	var rr := RandomNumberGenerator.new()
	rr.seed = 31
	for i in 46:
		var k := float(i) / 45.0
		var a := ridge + Vector2(lerpf(-60, 60, k), rr.randf_range(4, 30))
		var b := Vector2(lerpf(x0 - 72, x1 + 72, k), top + 18 + rr.randf_range(-6, 6))
		c.draw_line(a.lerp(b, rr.randf_range(0.1, 0.4)), b, Color(inkof(thatch, 0.45), 0.55), 2.0)
	for i in 30:
		var k := float(i) / 29.0
		var bx := lerpf(x0 - 76, x1 + 76, k)
		c.draw_colored_polygon(PackedVector2Array([Vector2(bx - 9, top + 16), Vector2(bx + 9, top + 16), Vector2(bx + 1, top + 34 + (i % 3) * 5)]), thatch.darkened(0.08))
	c.draw_line(ridge + Vector2(-70, 4), ridge + Vector2(70, 4), Color("#6b4a2a"), 10.0)


func _roof_y(x: float) -> float:
	var top := HUT.y - 200.0
	var dx := absf(x - HUT.x)
	return lerpf(top - 168.0, top + 20.0, clampf((dx - 60.0) / 230.0, 0.0, 1.0))


# bóng sư nương (không có rig): dáng chibi đầu to, búi tóc, áo dài, viền nắng
func _bong_nu(c: Node2D, p: Vector2, face: float, a: float) -> void:
	if a <= 0.01:
		return
	var col := Color(Color("#4a2e40"), a)
	var rim := Color(Color("#ffcf8a"), 0.7 * a)
	var head := p + Vector2(0, -158)
	var robe := PackedVector2Array([p + Vector2(-34, -112), p + Vector2(34, -112), p + Vector2(58, -4), p + Vector2(-58, -4)])
	c.draw_colored_polygon(robe, col)
	c.draw_polyline(PackedVector2Array([robe[1], robe[2]]), rim, 3.0)
	c.draw_circle(head, 50.0, col)
	c.draw_circle(head + Vector2(-face * 14, -50), 20.0, col)
	c.draw_line(head + Vector2(-face * 14, -60), head + Vector2(-face * 40, -76), Color(Color("#c8a040"), a), 4.0)
	c.draw_arc(head, 50.0, -PI * 0.5 + face * 0.3, PI * 0.4 * face, 16, rim, 3.0)
	for sx: float in [-1.0, 1.0]:
		c.draw_colored_polygon(PackedVector2Array([p + Vector2(sx * 30, -108), p + Vector2(sx * 66, -60), p + Vector2(sx * 44, -52)]), col)


# đệ tử nhỏ tập kiếm (bóng phẳng): ph = pha động tác
func _de_tu(c: Node2D, p: Vector2, ph: float, a: float) -> void:
	if a <= 0.01:
		return
	var col := Color(Color("#5a4660"), a)
	var ln := Color(ink, a)
	var bob := absf(sin(ph)) * 6.0
	var body := PackedVector2Array([p + Vector2(-20, -60 + bob), p + Vector2(20, -60 + bob), p + Vector2(30, 0), p + Vector2(-30, 0)])
	shape(c, body, col, 2.5, ln)
	c.draw_circle(p + Vector2(0, -88 + bob), 30.0, ln)
	c.draw_circle(p + Vector2(0, -88 + bob), 27.0, col)
	var sh := p + Vector2(14, -50 + bob)
	var an := -0.9 + sin(ph) * 0.9
	var hand := sh + Vector2.from_angle(an) * 34.0
	c.draw_line(sh, hand, ln, 6.0)
	c.draw_line(hand, hand + Vector2.from_angle(an - 0.6) * 62.0, Color(Color("#e8e4d4"), a), 3.0)


# ================================================================ k03: chiều trên Hoa Sơn

func _s_chieu(dt: float) -> void:
	var l1 := L("k03-01")
	var l2 := L("k03-02")
	var l3 := L("k03-03")
	var l4 := L("k03-04")
	var l4b := L("k03-04b")
	var l5 := L("k03-05")
	var l6 := L("k03-06")
	var l7 := L("k03-07")
	var l8 := L("k03-08")
	rain_of("maple", 1.2, Rect2(-200, -100, 2400, 200), {"col": Color("#d8703a"), "land": GY + 30.0})
	var flash := t >= l7 and t < l8
	var kid_on := t < l4 or flash
	tre.show = 1.0 if kid_on else 0.0
	lhx.show = 0.0 if kid_on else 1.0
	san.show = 1.0 if flash else 0.0
	char_tint = Color(1.0, 0.86, 0.7) if flash else Color(1.0, 0.92, 0.82)
	nhac.show = 0.0 if flash else 1.0
	nhac.talk = 0.0
	nhac.hold = {}
	lhx.hold = {}
	lhx.inplace = 0.0
	nhac.inplace = 0.0
	if t < l4:
		# đứa trẻ mồ côi ngồi bệt trên tảng đá; thầy bước ra từ nhà tranh, chìa tay; trẻ đứng dậy rồi quỳ lạy
		var st := smooth(l2 + 4.0, l2 + 4.6, t)
		var kn := smooth(l3 + 0.3, l3 + 0.9, t)
		var bw := bump(l3 + 1.0, l3 + 1.4, l3 + 1.8, l3 + 2.2) + bump(l3 + 2.4, l3 + 2.8, l3 + 3.2, l3 + 3.5)
		tre.pos = Vector2(700, GY)
		tre.face = 1.0
		tre.extra = [[SIT_GROUND, 1.0 - st], [{"head": 14.0, "torso": 8.0}, (1.0 - st) * (1.0 - smooth(l2 + 2.6, l2 + 3.2, t))],
			["kneel", kn], [{"torso": 40.0, "head": 24.0}, bw * kn]]
		tre.expr = "buon" if t < l2 + 3.0 else ("soc" if t < l2 + 4.6 else "vui")
		_di(nhac, HUT + Vector2(0, 0), Vector2(900, GY), l2 + 0.2, l2 + 2.8)
		if t >= l2 + 2.8:
			nhac.face = -1.0
		var reach := bump(l2 + 2.9, l2 + 3.4, l3 + 0.2, l3 + 0.6)
		nhac.extra = [[{"uaF": -62.0, "faF": -14.0, "torso": 6.0, "head": 6.0}, reach], [{"head": 8.0}, 1.0]]
		nhac.expr = "binh" if t < l2 + 2.8 else "vui"
		nhac.show = 1.0 if t >= l2 + 0.2 else 0.0
	elif t < l7:
		nhac.show = 1.0
		if t < l4b:
			# đại sư huynh múa mẫu, đám đệ tử nhỏ tập theo
			lhx.pos = Vector2(760, GY)
			lhx.face = 1.0
			var dem := pow(absf(sin((t - l4) * 2.2)), 2.0)
			lhx.extra = [["stance", 1.0], [arms_of("point"), dem], [{"head": -6.0}, 1.0]]
			lhx.expr = "dac-y"
			nhac.pos = Vector2(1780, GY)
			nhac.face = -1.0
			nhac.extra = [[{"uaF": 4.0, "faF": -88.0, "uaB": 0.0, "faB": -86.0}, 1.0]]
			nhac.expr = "binh"
		elif t < l5:
			# thầy nổi giận chỉ mặt; sư nương bước ra đứng giữa nói đỡ
			lhx.pos = Vector2(680, GY)
			lhx.face = 1.0
			var kn2 := smooth(l4b + 0.4, l4b + 1.0, t)
			lhx.extra = [["kneel", kn2], [{"head": 16.0, "torso": 10.0}, kn2]]
			lhx.expr = "buon"
			_di(nhac, Vector2(1780, GY), Vector2(1140, GY), l4b - 0.4, l4b + 1.4)
			if t >= l4b + 1.4:
				nhac.face = -1.0
			var pt := smooth(l4b + 1.2, l4b + 1.6, t) * (1.0 - smooth(l4b + 3.8, l4b + 4.4, t))
			nhac.extra = [["point", pt], [{"torso": -6.0, "head": -4.0}, pt]]
			nhac.expr = "gian" if pt > 0.4 else "binh"
		elif t < l6:
			# Quân Tử Kiếm: đứng thẳng như tượng, tay chắp trước ngực, nói đạo nghĩa
			lhx.pos = Vector2(700, GY)
			lhx.face = 1.0
			lhx.extra = [[{"uaB": -150.0, "faB": -60.0, "head": 8.0}, smooth(l5 + 0.3, l5 + 0.9, t)]]
			lhx.expr = "ngai"
			nhac.pos = Vector2(1060, GY)
			nhac.face = -1.0
			var nt: Node2D = nhac.node.J["torso"]
			nhac.hold["F"] = [Vector2(36, -96), 1.0]
			nhac.hold["B"] = [Vector2(30, -92), 1.0]
			nhac.extra = [[{"torso": -3.0, "head": -7.0}, 1.0]]
			nhac.talk = 0.0
			nhac.sway = 0.25
			nhac.expr = "dac-y"
			var _u := nt
		else:
			# trò leo lên mái tranh ngồi uống rượu; thầy dưới sân vẫn giảng
			var rx := HUT.x + 70.0
			lhx.pos = Vector2(rx, _roof_y(rx) + 6.0)
			lhx.face = 1.0
			var tip := bump(l6 + 0.6, l6 + 1.1, l6 + 2.4, l6 + 2.8) + bump(l6 + 4.0, l6 + 4.4, l6 + 5.2, l6 + 5.6)
			var lg := bump(l6 + 2.9, l6 + 3.1, l6 + 3.8, l6 + 4.0)
			lhx.extra = [[SIT_GROUND, 1.0], [{"torso": -8.0 - lg * 10.0, "head": -10.0 + sin(t * 15.0) * 5.0 * lg}, 1.0]]
			_ho_den("tay")
			_uong(lhx, ho, tip, true)
			ma.amount = smooth(l6 + 1.0, l6 + 5.0, t)
			lhx.expr = "vui"
			nhac.pos = Vector2(1000, GY)
			nhac.face = 1.0
			nhac.extra = [[{"head": -16.0, "torso": -4.0}, 1.0]]
			nhac.talk = 1.0
			nhac.sway = 0.25
			nhac.expr = "binh"
	elif t < l8:
		# hồi tưởng: hai đứa trẻ đuổi nhau quanh gốc thông
		var an := (t - l7) * 1.5
		var cx := 470.0
		tre.pos = Vector2(cx + cos(an) * 190.0, GY + sin(an) * 12.0)
		tre.face = signf(-sin(an)) if absf(sin(an)) > 0.05 else tre.face
		tre.inplace = 285.0
		tre.extra = [["run", 0.4]]
		tre.expr = "vui"
		var an2 := an - 1.1
		san.pos = Vector2(cx + cos(an2) * 190.0, GY + sin(an2) * 12.0)
		san.face = signf(-sin(an2)) if absf(sin(an2)) > 0.05 else san.face
		san.inplace = 285.0
		san.extra = [["run", 0.4], [{"uaF": -120.0, "faF": -20.0}, 0.6]]
		san.expr = "vui"
	else:
		tre.inplace = 0.0
		san.inplace = 0.0
		# uống lén sau góc nhà, thầy quay lưng; thầy ngoảnh lại thì giấu hồ lô
		lhx.pos = Vector2(1600, GY)
		lhx.face = 1.0
		var turn := smooth(l8 + 3.6, l8 + 3.8, t)
		var tip := bump(l8 + 0.5, l8 + 1.0, l8 + 3.2, l8 + 3.6) * (1.0 - turn)
		_ho_den("tay")
		_uong(lhx, ho, tip, true)
		if turn > 0.0:
			lhx.hold["F"] = [Vector2(-40, -20), turn]
			ho.lock = 0.0
		lhx.extra = [[{"torso": -4.0 - turn * 6.0, "head": turn * -8.0}, 1.0]]
		ma.amount = 0.6 + smooth(l8 + 1.0, l8 + 3.0, t) * 0.4
		lhx.expr = "ngai" if turn > 0.5 else "vui"
		nhac.pos = Vector2(1020, GY)
		nhac.face = 1.0 if turn > 0.5 else -1.0
		nhac.talk = 1.0 - turn
		nhac.extra = [[{"head": 0.0}, 1.0]]
		nhac.expr = "binh"
	if t < l6:
		_ho_den("hong")


func _ninh() -> Array:
	# [vị trí, alpha] của bóng sư nương
	var l2 := L("k03-02")
	var l4b := L("k03-04b")
	var l5 := L("k03-05")
	var a := smooth(l2 + 2.4, l2 + 3.2, t) * (1.0 - smooth(L("k03-04") - 0.3, L("k03-04"), t))
	var x := HUT.x
	if t >= l4b and t < l5 + 0.6:
		a = smooth(l4b + 1.4, l4b + 1.9, t) * (1.0 - smooth(l5, l5 + 0.6, t))
		x = lerpf(HUT.x, 910.0, smooth(l4b + 1.6, l4b + 3.4, t))
	return [Vector2(x, GY - (20.0 if x == HUT.x else 0.0)), a]


func _c_chieu() -> Array:
	var keys := [[0.0, Vector2(980, 330), 1.0],
		[L("k03-01") + 0.6, Vector2(1000, 640), 1.0, 3.6],
		[L("k03-02") + 2.4, Vector2(900, 680), 1.25, 1.6],
		[L("k03-03"), Vector2(820, 700), 1.5, 1.0],
		[L("k03-04"), Vector2(1180, 620), 1.0, 0.0],
		[L("k03-04b"), Vector2(920, 660), 1.3, 1.2],
		[L("k03-05"), Vector2(1020, 610), 1.55, 1.0],
		[L("k03-06"), Vector2(1150, 520), 1.15, 1.4],
		[L("k03-07"), Vector2(480, 660), 1.35, 0.0],
		[L("k03-08"), Vector2(1330, 650), 1.2, 0.0],
		[L("k03-08") + 3.4, Vector2(1380, 660), 1.45, 0.6]]
	return _ck(keys)


func _sky(c: Node2D) -> void:
	match m:
		"chieu":
			var sp := Vector2(1380, 560)
			for i in 6:
				c.draw_circle(sp, 260.0 - i * 36.0, Color(1.0, 0.85, 0.5, 0.06))
			c.draw_circle(sp, 92.0, Color("#ffe2a0"))
			for i in 5:
				cloud(c, Vector2(-100 + i * 520, 180 + (i % 2) * 90), 0.9, Color("#e89a7a"), 3.0)
		"sang":
			for i in 4:
				cloud(c, Vector2(100 + i * 600, 160 + (i % 2) * 70), 1.0, Color("#ffffff"), 3.0)
		"mua":
			for i in 6:
				cloud(c, Vector2(-200 + i * 480, 120 + (i % 3) * 60), 1.4, Color("#4a5a68"), 3.0)


func _far(c: Node2D) -> void:
	match m:
		"chieu":
			_hoa_son(c, 760.0, air(Color("#8a6a72"), 0.5), 3, 8, -500.0, 420.0, 380.0, 620.0)
		"sang":
			_hoa_son(c, 760.0, air(Color("#7c8f8c"), 0.55), 5, 8, -450.0, 410.0, 400.0, 640.0, 0.0)
		"mua":
			_hoa_son(c, 700.0, Color("#5a6a76"), 9, 8, -500.0, 420.0, 360.0, 560.0)


func _mid(c: Node2D) -> void:
	match m:
		"chieu":
			_hoa_son(c, 840.0, Color("#9a6e5e"), 11, 6, -300.0, 560.0, 260.0, 420.0)
			for i in 5:
				var y := 700.0 + i * 24.0
				c.draw_rect(Rect2(-600, y, 3200, 16), Color(1.0, 0.8, 0.6, 0.12))
		"sang":
			_hoa_son(c, 860.0, Color("#88a092"), 13, 6, -260.0, 560.0, 260.0, 440.0)
			for i in 7:
				var y := 640.0 + i * 30.0
				var dx := sin(t * 0.2 + i) * 60.0
				c.draw_rect(Rect2(-600 + dx, y, 3200, 22), Color(1, 1, 1, 0.16))
		"mua":
			for i in 5:
				var y := 560.0 + i * 50.0
				c.draw_rect(Rect2(-600 + sin(t * 0.15 + i) * 80.0, y, 3200, 30), Color(0.7, 0.75, 0.8, 0.1))


func _ground(c: Node2D) -> void:
	match m:
		"chieu":
			_g_chieu(c)
		"sang":
			_g_sang(c)
		"mua":
			_g_mua(c)


func _g_chieu(c: Node2D) -> void:
	_san_dat(c, Color("#8a6844"))
	pine(c, Vector2(470, GY), 380.0, 230.0, Color("#3f5a3a"), 0.0, 4.0, 4)
	_nha_tranh(c, HUT, smooth(L("k03-02") + 1.6, L("k03-02") + 2.4, t))
	# cuộn thư pháp treo vách: chữ kiếm
	var sc := HUT + Vector2(-150, -190)
	if t >= L("k03-05") - 0.5 and t < L("k03-06") + 0.5:
		var sa := smooth(L("k03-05") - 0.5, L("k03-05"), t)
		c.draw_rect(Rect2(sc + Vector2(-26, -10), Vector2(52, 120 * sa)), Color("#efe4c8"))
		c.draw_rect(Rect2(sc + Vector2(-32, -16), Vector2(64, 10)), Color("#5a3a22"))
		if sa > 0.8:
			var a0 := sc + Vector2(-12, 92)
			var a1 := sc + Vector2(12, 18)
			var dn := (a1 - a0).normalized()
			var nn := Vector2(-dn.y, dn.x)
			c.draw_line(a0, a1 - dn * 10.0, ink, 4.0)
			c.draw_colored_polygon(PackedVector2Array([a1 - dn * 12.0 + nn * 3.0, a1, a1 - dn * 12.0 - nn * 3.0]), ink)
			c.draw_line(a0 + dn * 16.0 + nn * 9.0, a0 + dn * 16.0 - nn * 9.0, Color("#b8322c"), 4.0)
	# tảng đá đứa trẻ ngồi
	if t < L("k03-04"):
		shape(c, round_pts(PackedVector2Array([Vector2(610, GY + 6), Vector2(630, GY - 30), Vector2(700, GY - 44), Vector2(780, GY - 28), Vector2(800, GY + 6)])), Color("#8d857a"), 3.0)
	var nn := _ninh()
	var np: Vector2 = nn[0]
	var na: float = nn[1]
	_bong_nu(c, np, -1.0 if np.x > 900.0 else 1.0, na)
	# đám đệ tử nhỏ tập theo đại sư huynh
	var da := smooth(L("k03-04") - 0.1, L("k03-04") + 0.4, t) * (1.0 - smooth(L("k03-04b"), L("k03-04b") + 0.6, t))
	for i in 5:
		var dp := Vector2(930 + i * 125, GY + 70 - (i % 2) * 26)
		_de_tu(c, dp, (t - L("k03-04")) * 2.2 - 0.35 - i * 0.12, da)


func _glow(c: Node2D) -> void:
	match m:
		"chieu":
			var lit := smooth(L("k03-02") + 1.6, L("k03-02") + 2.4, t)
			flat_blob(c, HUT + Vector2(0, 10), 160.0, 0.25, Color(1.0, 0.7, 0.35, 0.25 * lit))
			if t >= L("k03-06"):
				var mw: Vector2 = ho.get("mouthw", Vector2.ZERO)
				if ho_at == "tay" and lhx.show > 0.5:
					blob(c, mw, 60.0, Color(1.3, 0.8, 0.35, 0.25))
		"sang":
			rays(c, Vector2(1900, -200), 2.2, 0.6, 7, 1600.0, Color(1.0, 0.95, 0.75, 0.18))
		"mua":
			_glow_mua(c)


func _near(c: Node2D) -> void:
	match m:
		"chieu":
			grass(c, -400, 2400, GY + 60.0, 34.0, 36.0, Color("#6e7a3a"), 3)
		"sang":
			_n_sang(c)
		"mua":
			_n_mua(c)


func _d_screen(c: Node2D) -> void:
	match m:
		"chieu":
			if t >= L("k03-07") and t < L("k03-08"):
				c.draw_rect(Rect2(0, 0, W, H), Color(0.55, 0.35, 0.15, 0.16))
				for i in 40:
					var y := fmod(i * 97.0 + t * 30.0, H)
					c.draw_line(Vector2(0, y), Vector2(W, y), Color(1, 0.9, 0.7, 0.03), 2.0)
			var la := bump(L("k03-03") + 0.3, L("k03-03") + 0.7, LE("k03-03") + 0.2, LE("k03-03") + 0.6)
			nhan(c, Vector2(W * 0.5, 140), "SƯ PHỤ · SƯ NƯƠNG", 46, Color("#b8322c"), la)
			var lb := bump(L("k03-04") + 0.6, L("k03-04") + 1.0, LE("k03-04"), LE("k03-04") + 0.4)
			nhan(c, Vector2(W * 0.3, 140), "ĐẠI SƯ HUYNH", 50, Color("#b8322c"), lb, -0.03)
			var lc := bump(L("k03-05") + 0.8, L("k03-05") + 1.2, LE("k03-05"), LE("k03-05") + 0.4)
			nhan(c, Vector2(W * 0.5, 130), "QUÂN TỬ KIẾM", 54, Color("#3a5a6a"), lc, 0.02)
		"sang":
			_sc_sang(c)
		"mua":
			_sc_mua(c)
	super._d_screen(c)


# ================================================================ k03b: sân tập buổi sáng, người tới sau

func _s_sang(dt: float) -> void:
	var b1 := L("k03b-01")
	var b2 := L("k03b-02")
	var b3 := L("k03b-03")
	var b4 := L("k03b-04")
	var b5 := L("k03b-05")
	var b6 := L("k03b-06")
	rain_of("leaf", 0.8, Rect2(-200, -100, 2400, 200), {"col": Color("#7a9a5a"), "land": GY + 30.0})
	lam.hold = {}
	nhac.hold = {}
	lhx.hold = {}
	# Lâm Bình Chi lên bậc đá, ôm tay nải; cúi đầu nhớ nhà; quỳ bái sư; tập kiếm với sư tỷ
	if t < b3:
		_di(lam, Vector2(-160, GY), Vector2(720, GY), b1, b1 + 4.6)
		lam.extra = [[{"uaF": -40.0, "faF": -90.0, "uaB": -30.0, "faB": -96.0}, 1.0], [{"head": 14.0, "torso": 6.0}, smooth(b2, b2 + 0.6, t)]]
		lam.expr = "binh" if t < b2 else "buon"
		if t >= b1 + 4.6:
			lam.face = 1.0
	elif t < b4:
		lam.inplace = 0.0
		lam.pos = Vector2(760, GY)
		lam.face = 1.0
		var kn := smooth(b3 + 0.3, b3 + 0.9, t)
		lam.extra = [["kneel", kn], [{"head": 18.0, "torso": 14.0}, kn]]
		lam.expr = "buon" if t < b3 + 2.5 else "vui"
	if t < b4:
		nhac.pos = Vector2(980, GY)
		nhac.face = -1.0
		var tay := smooth(b3 + 1.4, b3 + 2.0, t) * (1.0 - smooth(b4 - 0.6, b4 - 0.1, t))
		if tay > 0.0:
			var nt: Node2D = nhac.node.J["torso"]
			nhac.hold["F"] = [from_w(nt, head_of(lam) + Vector2(0, -50)), tay]
		nhac.extra = [[{"head": 10.0, "torso": 4.0}, 1.0]]
		nhac.expr = "vui" if t >= b3 else "binh"
		nhac.show = 1.0
		san.pos = Vector2(1120, GY)
		san.face = -1.0
		san.extra = [[{"head": 6.0}, 1.0]]
		san.expr = "vui"
		lhx.pos = Vector2(1300, GY)
		lhx.face = -1.0
		lhx.extra = [[{"uaB": -150.0, "faB": -60.0}, 0.4]]
		lhx.expr = "vui"
	else:
		nhac.show = 1.0 - smooth(b4, b4 + 0.6, t)
		_di(nhac, Vector2(980, GY), Vector2(-200, GY), b4, b4 + 5.0)
		if kiem_at != "tay":
			kiem_at = "tay"
			prop_to(kiem_san, "tay", "F")
			prop_to(kiem_lam, "tay", "F")
		lam.inplace = 0.0
		var lx := 520.0 - smooth(b5, b5 + 1.2, t) * 120.0
		lam.pos = Vector2(lx, GY)
		lam.face = 1.0
		san.pos = Vector2(lx + 260.0, GY)
		san.face = -1.0
		var ph := (t - b4) * 2.6
		var s1 := maxf(0.0, sin(ph))
		var s2 := maxf(0.0, -sin(ph))
		san.extra = [["stance", 1.0], [arms_of("slash"), s1], [arms_of("windup"), s2 * 0.6]]
		lam.extra = [["stance", 1.0], [arms_of("guard"), s1], [arms_of("slash"), s2 * 0.5]]
		kiem_san.trail_on = s1 > 0.5
		kiem_lam.trail_on = false
		if not kiem_san.trail_on:
			kiem_san.trail.clear()
		san.expr = "vui"
		lam.expr = "ngai" if fmod(t, 3.0) < 1.6 else "vui"
		# đại sư huynh ngồi gốc thông, uống một ngụm, cười cho qua; rồi treo hồ lô lên cành và đi
		if t < b6:
			lhx.pos = Vector2(PINE_X - 190.0, GY)
			lhx.face = -1.0
			lhx.extra = [[SIT_GROUND, 1.0], [{"head": 6.0}, 1.0]]
			var tip := bump(b5 + 0.6, b5 + 1.1, b5 + 2.4, b5 + 2.8)
			_ho_den("tay")
			_uong(lhx, ho, tip, true)
			lhx.expr = "buon" if t < b5 + 2.9 else "vui"
			if t < b5:
				lhx.expr = "binh"
				_uong(lhx, ho, 0.0, false)
		else:
			var up := smooth(b6 + 0.2, b6 + 0.8, t)
			lhx.face = 1.0
			lhx.pos = Vector2(PINE_X - 190.0, GY)
			lhx.extra = [[SIT_GROUND, 1.0 - up]]
			var hang := bump(b6 + 1.0, b6 + 1.6, b6 + 2.2, b6 + 2.6)
			if t < b6 + 2.0:
				_ho_den("tay")
				var lt: Node2D = lhx.node.J["torso"]
				lhx.hold["F"] = [from_w(lt, _branch_tip()), hang]
				ho.lock = 0.0
				ho.node.visible = true
			else:
				ho.node.visible = false
			_di(lhx, Vector2(PINE_X - 190.0, GY), Vector2(2500, GY), b6 + 2.6, b6 + 8.6)
			lhx.expr = "binh"


func _branch_tip() -> Vector2:
	return Vector2(PINE_X - 90.0, GY - 290.0)


func _c_sang() -> Array:
	var keys := [[0.0, Vector2(560, 620), 1.1],
		[L("k03b-01") + 1.0, Vector2(760, 630), 1.1, 3.6],
		[L("k03b-02"), Vector2(600, 640), 1.5, 1.0],
		[L("k03b-03"), Vector2(860, 640), 1.3, 1.0],
		[L("k03b-04"), Vector2(660, 640), 1.25, 1.2],
		[L("k03b-05"), Vector2(1220, 650), 1.35, 1.6],
		[L("k03b-06") + 1.8, Vector2(PINE_X - 90, 580), 1.5, 2.0]]
	return _ck(keys)


func _g_sang(c: Node2D) -> void:
	_san_dat(c, Color("#a49a82"))
	# sân lát đá
	for i in 26:
		var x := -500.0 + i * 120.0
		c.draw_line(Vector2(x, GY), Vector2(x - 160.0, 1400), Color(ink, 0.25), 3.0)
	for j in 5:
		c.draw_line(Vector2(-600, GY + 40 + j * 60), Vector2(2600, GY + 40 + j * 60), Color(ink, 0.18), 3.0)
	# bậc đá bên trái đi lên
	for i in 5:
		var y := GY + 60.0 - i * 12.0
		shape(c, PackedVector2Array([Vector2(-300 + i * 60, y), Vector2(-160 + i * 60, y), Vector2(-150 + i * 60, y + 14), Vector2(-310 + i * 60, y + 14)]), Color("#8d8678"), 2.5)
	# cọc gỗ tập kiếm
	for x: float in [260.0, 1080.0]:
		shape(c, PackedVector2Array([Vector2(x - 12, GY), Vector2(x - 12, GY - 150), Vector2(x + 12, GY - 150), Vector2(x + 12, GY)]), Color("#7a5232"), 3.0)
	# cây thông nghiêng có cành ngang
	var base := Vector2(PINE_X + 60.0, GY)
	pine(c, base, 460.0, 260.0, Color("#3d5e44"), 0.0, 4.0, 2)
	var bt := _branch_tip()
	c.draw_line(base + Vector2(0, -330), bt + Vector2(-30, 6), Color("#5a3a22"), 14.0)
	c.draw_line(base + Vector2(0, -330), bt + Vector2(-30, 6), Color("#7a5232"), 8.0)
	leaf(c, bt + Vector2(-34, 0), -2.6, 40.0, 18.0, Color("#3d5e44"))


func _n_sang(c: Node2D) -> void:
	if t >= L("k03b-06") + 2.0:
		var bt := _branch_tip()
		var sw := sin(t * 1.6) * 0.3
		var hp := bt + Vector2(sin(sw) * 50.0, 70.0)
		c.draw_line(bt, hp + Vector2(0, -40), Color("#b8322c"), 3.0)
		holo(c, hp, 0.9, Color("#e8b65a"), 0.15)
	grass(c, -400, 2400, GY + 70.0, 40.0, 30.0, Color("#7a9a5a"), 5)
	# cánh hoa giữa đôi kiếm tập
	if t >= L("k03b-04") and t < L("k03b-05") + 2.0:
		var a := smooth(L("k03b-04") + 1.0, L("k03b-04") + 2.0, t) * (1.0 - smooth(L("k03b-05"), L("k03b-05") + 2.0, t))
		var lp: Vector2 = lam.pos
		var sp2: Vector2 = san.pos
		var mid := (lp + sp2) * 0.5 + Vector2(0, -260)
		for i in 5:
			var p := mid + Vector2(sin(t * 1.3 + i * 1.7) * 60.0, -fmod(t * 30.0 + i * 24.0, 100.0))
			leaf(c, p, t * 2.0 + i, 16.0, 11.0, Color(Color("#e89ab0"), a), 1.5)


func _sc_sang(c: Node2D) -> void:
	var b1 := L("k03b-01")
	var b2 := L("k03b-02")
	var b6 := L("k03b-06")
	nhan(c, Vector2(W * 0.5, 130), "LÂM BÌNH CHI", 50, Color("#3a5a6a"), bump(b1 + 0.8, b1 + 1.2, LE("k03b-01"), LE("k03b-01") + 0.4))
	# ô hồi ức tròn: biển tiêu cục Phúc Uy nứt đôi, rồi cuốn bí kíp
	var ia := bump(b2 - 0.2, b2 + 0.3, LE("k03b-02") - 0.2, LE("k03b-02") + 0.3)
	if ia > 0.01:
		var ctr := Vector2(440, 330)
		var r := 220.0
		c.draw_circle(ctr, r + 12.0, Color(ink, ia))
		c.draw_circle(ctr, r, Color(Color("#5a4048"), ia))
		c.draw_circle(ctr + Vector2(0, 90), r * 0.7, Color(Color("#8a4a2a"), 0.45 * ia))
		var cr := smooth(b2 + 1.6, b2 + 2.2, t)
		var words := ["PHÚC", "UY"]
		for i in 2:
			var sd := -1.0 if i == 0 else 1.0
			var off := Vector2(sd * cr * 34.0, cr * cr * 50.0)
			c.draw_set_transform(ctr + Vector2(sd * 72.0, -50) + off, sd * cr * 0.25, Vector2.ONE)
			c.draw_rect(Rect2(-72, -42, 144, 84), Color(Color("#a0522d"), ia))
			c.draw_rect(Rect2(-72, -42, 144, 84), Color(ink, ia), false, 4.0)
			var wd: String = words[i]
			var tw := font.get_string_size(wd, HORIZONTAL_ALIGNMENT_LEFT, -1, 44).x
			c.draw_string(font, Vector2(-tw * 0.5, 16), wd, HORIZONTAL_ALIGNMENT_LEFT, -1, 44, Color(Color("#f6d070"), ia))
			c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		var sa := smooth(b2 + 2.8, b2 + 3.4, t)
		if sa > 0.01:
			var sp := ctr + Vector2(0, 100)
			c.draw_rect(Rect2(sp + Vector2(-120, -34), Vector2(240 * sa, 68)), Color(Color("#e8dcc0"), ia))
			c.draw_rect(Rect2(sp + Vector2(-134, -40), Vector2(16, 80)), Color(Color("#5a3a22"), ia))
			c.draw_rect(Rect2(sp + Vector2(-120 + 240 * sa, -40), Vector2(16, 80)), Color(Color("#5a3a22"), ia))
		nhan(c, ctr + Vector2(0, 190), "TỊCH TÀ KIẾM PHỔ", 36, Color("#5a2a22"), sa * ia)
	var la := bump(b6 + 0.4, b6 + 0.8, LE("k03b-06") - 0.2, LE("k03b-06") + 0.3)
	nhan(c, Vector2(W * 0.5, 130), "TỊCH TÀ KIẾM PHỔ", 50, Color("#5a2a22"), la, -0.02)


# ================================================================ k14: trục xuất, mưa trên bậc đá

func _stair(k: float) -> Vector2:
	# bậc đá từ chân cổng chéo xuống phải
	return Vector2(760, GATE.y).lerp(Vector2(2050, 1010), k)


func _s_mua(dt: float) -> void:
	var m1 := L("k14-01")
	var m2 := L("k14-02")
	var m3 := L("k14-03")
	var m4 := L("k14-04")
	var m4b := L("k14-04b")
	var m5 := L("k14-05")
	var rate := 160.0 + smooth(m3, m3 + 2.0, t) * 260.0
	rain_of("rain", rate, Rect2(-400, -300, 2800, 200), {"col": Color("#c8d8e8"), "land": 1250.0})
	lhx.hold = {}
	lhx.inplace = 0.0
	nhac.extra = []
	var shut := smooth(m3, m3 + 1.3, t)
	nhac.show = 1.0 - smooth(m3 + 0.7, m3 + 1.1, t)
	nhac.pos = GATE + Vector2(-10, 0)
	nhac.face = 1.0
	var pt := smooth(m2 + 0.2, m2 + 0.6, t) * (1.0 - smooth(m3 - 0.4, m3, t))
	nhac.extra = [["point", pt], [{"head": -6.0, "torso": -4.0}, 1.0]]
	nhac.expr = "gian" if t < m3 else "binh"
	if t < m4b:
		lhx.pos = GATE + Vector2(300, 0)
		lhx.face = -1.0
		var sh := smooth(m2 + 0.9, m2 + 1.1, t) * (1.0 - smooth(m2 + 1.6, m2 + 2.4, t))
		lhx.extra = [[{"torso": 10.0 * sh - 8.0 * (1.0 - sh), "head": -12.0 * sh}, 1.0], [{"head": 14.0, "torso": 6.0}, shut]]
		lhx.expr = "soc" if t < m3 + 0.4 and t >= m2 + 0.9 else ("buon" if t >= m3 else "binh")
		if t < m2:
			lhx.extra.append([{"head": sin(t * 2.4) * 8.0}, 1.0])
	else:
		# vái về hướng núi ba lần, rồi đi xuống bậc đá
		var kn := smooth(m4b + 0.2, m4b + 0.7, t) * (1.0 - smooth(m4b + 3.6, m4b + 4.1, t))
		var bw := 0.0
		for i in 3:
			var b0 := m4b + 0.9 + i * 0.9
			bw += bump(b0, b0 + 0.3, b0 + 0.5, b0 + 0.8)
		lhx.extra = [["kneel", kn], [{"torso": 46.0, "head": 26.0, "uaF": -50.0, "faF": -100.0, "uaB": -50.0, "faB": -100.0}, bw * kn]]
		lhx.expr = "buon"
		if t < m4b + 4.2:
			lhx.pos = GATE + Vector2(300, 0)
			lhx.face = -1.0
		else:
			var k0 := 0.0
			var p0 := GATE + Vector2(300, 0)
			var p1 := _stair(0.25)
			if t < m5:
				_di(lhx, p0, p1, m4b + 4.4, m5)
			else:
				_di(lhx, p1, _stair(1.0), m5, m5 + 7.0)
			lhx.speed = 140.0
			var _k := k0
	if t >= m4 and t < m4b:
		teo.pos = Vector2(TEO_X, GY)
		teo.face = 1.0
		teo.extra = [[SIT, 1.0], [{"torso": 12.0, "head": 16.0 + sin(t * 0.8) * 3.0}, 1.0]]
		var tt: Node2D = teo.node.J["torso"]
		teo.hold["F"] = [Vector2(48, -150), 1.0]
		teo.expr = "buon"
		var _q := tt


func _gate_shut() -> float:
	return smooth(L("k14-03"), L("k14-03") + 1.3, t)


func _c_mua() -> Array:
	var m2 := L("k14-02")
	var keys := [[0.0, Vector2(640, 470), 1.2],
		[L("k14-01") + 1.0, Vector2(620, 460), 1.3, 5.0],
		[m2, Vector2(560, 430), 1.1, 0.8],
		[L("k14-03"), Vector2(820, 560), 1.0, 1.6],
		[L("k14-04"), Vector2(TEO_X + 40, 640), 1.35, 0.0],
		[L("k14-04b"), Vector2(700, 470), 1.35, 0.0],
		[L("k14-05"), Vector2(1100, 640), 1.0, 2.0],
		[L("k14-05") + 2.5, Vector2(1500, 800), 1.15, 4.0]]
	var cz := _ck(keys)
	var e := t - (m2 + 1.0)
	if e > 0.0 and e < 0.8:
		var p: Vector2 = cz[0]
		cz[0] = p + Vector2(sin(t * 70.0), cos(t * 53.0)) * 16.0 * exp(-5.0 * e)
	return cz


func _g_mua(c: Node2D) -> void:
	if t >= L("k14-04") and t < L("k14-04b"):
		_quan_mua(c)
		return
	# vách núi và nền bậc
	var cliff := PackedVector2Array([Vector2(-600, GATE.y), Vector2(760, GATE.y), Vector2(2050, 1010), Vector2(2600, 1010), Vector2(2600, 1500), Vector2(-600, 1500)])
	c.draw_colored_polygon(cliff, Color("#5a6470"))
	hatch(c, cliff, 0.6, 22.0, Color(ink, 0.3))
	for i in 28:
		var k := float(i) / 27.0
		var p := _stair(k)
		var q := _stair(k + 1.0 / 27.0)
		shape(c, PackedVector2Array([Vector2(p.x - 30, p.y), Vector2(q.x + 30, p.y), Vector2(q.x + 30, q.y + 6), Vector2(p.x - 30, q.y + 6)]), Color("#6a7278"), 2.5, Color("#262c30"))
		c.draw_line(Vector2(p.x - 26, p.y + 2), Vector2(q.x + 24, p.y + 2), Color(1, 1, 1, 0.12), 2.0)
	pine(c, Vector2(1180, 760), 300.0, 170.0, Color("#2c3e34"), 0.0, 3.0, 8)
	# cổng sơn môn: hai cột, mái ngói, biển gỗ, hai cánh cửa
	var g := GATE
	shape(c, PackedVector2Array([Vector2(g.x - 300, g.y + 4), Vector2(g.x + 300, g.y + 4), Vector2(g.x + 300, g.y + 40), Vector2(g.x - 300, g.y + 40)]), Color("#5a6066"), 3.0)
	for sx: float in [-1.0, 1.0]:
		shape(c, PackedVector2Array([Vector2(g.x + sx * 250 - 20, g.y), Vector2(g.x + sx * 250 - 20, g.y - 420), Vector2(g.x + sx * 250 + 20, g.y - 420), Vector2(g.x + sx * 250 + 20, g.y)]), Color("#6b2a22"), 3.0)
	var shut := _gate_shut()
	c.draw_rect(Rect2(g.x - 230, g.y - 410, 460, 410), Color("#1a1410"))
	for sx: float in [-1.0, 1.0]:
		var wdd := 230.0 * lerpf(0.18, 1.0, shut)
		var x0 := g.x + sx * 230.0
		var x1 := x0 - sx * wdd
		var door := PackedVector2Array([Vector2(x0, g.y), Vector2(x0, g.y - 410), Vector2(x1, g.y - 410), Vector2(x1, g.y)])
		shape(c, door, Color("#7a3a26"), 3.0)
		for j in 4:
			for k in 3:
				var bx := lerpf(x0, x1, (k + 1) / 4.0)
				c.draw_circle(Vector2(bx, g.y - 70 - j * 90), 5.0, Color("#c8a040"))
	var roof := PackedVector2Array([Vector2(g.x - 300, g.y - 410), Vector2(g.x + 300, g.y - 410), Vector2(g.x + 240, g.y - 390), Vector2(g.x - 240, g.y - 390)])
	shape(c, round_pts(roof, true, 3), Color("#2c3036"), 4.0)
	for i in 16:
		var x := g.x - 340 + i * 45.0
		c.draw_line(Vector2(x, g.y - 494), Vector2(x - 6, g.y - 414), Color(0, 0, 0, 0.4), 3.0)
	nhan(c, Vector2(g.x, g.y - 370), "HOA SƠN", 40, Color("#1e2a36"))


func _quan_mua(c: Node2D) -> void:
	# Tèo ngồi tì cằm bên cửa sổ quán, mưa ngoài song
	var x := TEO_X
	van_mang(c, Rect2(x - 1300, 100, 2600, GY - 100), 2, Color("#5e4028"))
	var wr := Rect2(x - 120, 300, 520, 330)
	c.draw_rect(wr, Color("#24323e"))
	for i in 34:
		var rx := wr.position.x + fmod(i * 61.0 + t * 90.0, wr.size.x)
		var ry := wr.position.y + fmod(i * 47.0 + t * 900.0, wr.size.y - 40.0)
		c.draw_line(Vector2(rx, ry), Vector2(rx - 6, ry + 30), Color(0.8, 0.88, 1.0, 0.5), 2.0)
	for k in 5:
		var xx := wr.position.x + k * wr.size.x / 4.0
		c.draw_line(Vector2(xx, wr.position.y), Vector2(xx, wr.end.y), Color("#3a2618"), 8.0)
	c.draw_rect(wr, Color("#3a2618"), false, 14.0)
	c.draw_rect(Rect2(x - 1300, GY, 2600, 400), Color("#4a3020"))
	# ghế đẩu dưới Tèo
	shape(c, PackedVector2Array([Vector2(x - 60, GY - SEAT_H * CS - 8), Vector2(x + 40, GY - SEAT_H * CS - 8), Vector2(x + 36, GY), Vector2(x - 56, GY)]), Color("#7a5232"), 3.0)
	holo(c, Vector2(x + 300, 690), 0.9, Color("#f3ecd8"), 0.0)


func _n_mua(c: Node2D) -> void:
	# giấy đồn đại bay quanh người
	var m1 := L("k14-01")
	var pa := bump(m1 + 0.8, m1 + 1.6, L("k14-02"), L("k14-02") + 0.6)
	if pa > 0.01:
		var hp := head_of(lhx)
		for i in 7:
			var an := t * 1.2 + i * 0.9
			var p := hp + Vector2(cos(an) * 170.0, sin(an) * 70.0 - 10.0)
			c.draw_set_transform(p, an * 0.7, Vector2.ONE)
			c.draw_rect(Rect2(-22, -15, 44, 30), Color(Color("#e8e0cc"), pa))
			for j in 3:
				c.draw_line(Vector2(-14, -7 + j * 7), Vector2(14, -7 + j * 7), Color(ink, 0.7 * pa), 2.0)
			c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	# thư báo khắp giang hồ: cánh thư gấp bay khỏi cổng
	var m2 := L("k14-02")
	if t > m2 + 1.6 and t < L("k14-03") + 1.5:
		for i in 6:
			var e := t - (m2 + 1.6 + i * 0.25)
			if e <= 0.0:
				continue
			var p := GATE + Vector2(0, -360) + Vector2(e * (220.0 + i * 50.0), -e * (160.0 + i * 30.0) + sin(e * 5.0 + i) * 20.0)
			var f := sin(t * 14.0 + i) * 0.8
			var wc := Color(Color("#f0e8d4"), clampf(2.4 - e * 0.6, 0.0, 1.0))
			c.draw_colored_polygon(PackedVector2Array([p, p + Vector2(-26, -20 * f - 6), p + Vector2(-10, 4)]), wc)
			c.draw_colored_polygon(PackedVector2Array([p, p + Vector2(26, -20 * f - 6), p + Vector2(10, 4)]), wc)
	# hồ lô gần cạn: giọt cuối nhỏ ra từ miệng
	if t >= L("k14-05"):
		var mw: Vector2 = ho.get("mouthw", Vector2.ZERO)
		var e2 := fmod(t - L("k14-05"), 1.4)
		c.draw_circle(mw + Vector2(0, e2 * e2 * 160.0), 4.0, Color(Color("#e8b65a"), 1.0 - e2 / 1.4))


func _glow_mua(c: Node2D) -> void:
	if t >= L("k14-04") and t < L("k14-04b"):
		blob(c, Vector2(TEO_X - 300, 360), 220.0, Color(1.0, 0.7, 0.35, 0.18))


func _sc_mua(c: Node2D) -> void:
	var m2 := L("k14-02")
	# thư trục xuất + triện đỏ đóng xuống đúng tiếng va
	var la := bump(m2 + 0.2, m2 + 0.5, L("k14-03") + 0.6, L("k14-03") + 1.2)
	if la > 0.01:
		var ctr := Vector2(W * 0.5, 230)
		c.draw_rect(Rect2(ctr + Vector2(-260, -110), Vector2(520, 220)), Color(Color("#ece2c8"), la))
		c.draw_rect(Rect2(ctr + Vector2(-260, -110), Vector2(520, 220)), Color(ink, la), false, 4.0)
		for j in 4:
			c.draw_line(ctr + Vector2(-220, -70 + j * 34), ctr + Vector2(60, -70 + j * 34), Color(ink, 0.5 * la), 4.0)
		var e := t - (m2 + 1.0)
		if e > 0.0:
			var pop := 1.0 + 0.6 * exp(-9.0 * e)
			nhan(c, ctr + Vector2(80, 20), "TRỤC XUẤT", int(56.0 * pop), Color("#b8322c"), la, -0.12)
	if t >= L("k14-04") and t < L("k14-04b"):
		c.draw_rect(Rect2(0, 0, W, H), Color(0.1, 0.15, 0.25, 0.12))
