extends "res://canh.gd"
# Tư Quá Nhai: vách đá phủ tuyết trên Hoa Sơn. Một chỗ, bốn kiểu dựng theo arg.m:
#   k06 — máy tia từ đỉnh vách xuống; gõ vách thủng lỗ; mống mắt khép vào lỗ, mở ra trong hang khắc chiêu
#   k07 — khung đứng yên kiểu tranh hài: đánh – thua – chui hang lặp, vạch đếm trận khắc trên vách
#   k08 — đêm trăng: ông già áo xám, đỉnh núi của Độc Cô Cầu Bại, mộ kiếm, chín nét trên phiến đá
#   k10 — lửa trại trên tuyết, máy thấp: ngồi bệt, cụng hồ lô, vẽ lên tuyết; CTA chừa góc trên phải

const SNOW := Color("#eef2f7")
const SNOW_SH := Color("#c3cfe0")
const ROCK := Color("#8c93a6")
const ROCK_HI := Color("#aab2c4")
const CAVE := Color("#2c2d38")
const CARVE := Color("#d9d2c0")
const OCHRE := Color("#c0503a")
const GOLD := Color("#ffc860")
const MOUTH := Vector2(420, 860)
const HOLE := Vector2(470, 690)

var m := "k06"
var lhx: Dictionary
var dien: Dictionary
var phong: Dictionary
var ls: Dictionary
var bg: Dictionary
var kiem: Dictionary
var dao: Dictionary
var ho_l: Dictionary
var ho_d: Dictionary
var inside := false
var did := {}


func _palette() -> void:
	m = arg.get("m", "k06")
	ground_y = 860.0
	wind_base = 0.5
	wind_gust = 0.9
	match m:
		"k08":
			sky_top = Color("#2a3a6a")
			sky_bot = Color("#7d93bf")
			haze = Color("#93a6c8")
			char_tint = Color(0.86, 0.92, 1.08)
			vign_a = 0.45
			wind_base = 0.25
		"k10":
			sky_top = Color("#232c55")
			sky_bot = Color("#6a7aa3")
			haze = Color("#7d8bb0")
			char_tint = Color(0.97, 0.94, 0.92)
			vign_a = 0.4
			wind_base = 0.15
			wind_gust = 0.3
		_:
			sky_top = Color("#7f94b8")
			sky_bot = Color("#e4eaf1")
			haze = Color("#dde5ee")
			char_tint = Color(0.93, 0.97, 1.05)
			vign_a = 0.3


func _build() -> void:
	match m:
		"k06":
			lhx = actor("lenh-ho-xung", Vector2(980, ground_y), -1.0)
			kiem = prop(lhx, "kiem", "hong", "F")
			ls = actor("nhac-linh-san", Vector2(2350, ground_y), -1.0)
		"k07":
			lhx = actor("lenh-ho-xung", Vector2(860, ground_y), 1.0)
			kiem = prop(lhx, "kiem", "hong", "F")
			dien = actor("dien-ba-quang", Vector2(2500, ground_y), -1.0)
			dao = prop(dien, "dao", "tay", "F")
			bg = actor("bat-gioi", Vector2(1560, 600), -1.0)
			bg.size = 0.55
			bg.show = 0.0
		"k08":
			lhx = actor("lenh-ho-xung", Vector2(980, ground_y), 1.0)
			kiem = prop(lhx, "kiem", "tay", "F")
			dien = actor("dien-ba-quang", Vector2(1380, ground_y), -1.0)
			dao = prop(dien, "dao", "tay", "F")
			phong = actor("phong-thanh-duong", Vector2(470, ground_y), 1.0)
			phong.show = 0.0
		"k10":
			lhx = actor("lenh-ho-xung", Vector2(700, ground_y), 1.0)
			kiem = prop(lhx, "kiem", "tay", "F")
			ho_l = prop(lhx, "ho_lo", "hong", "B")
			dien = actor("dien-ba-quang", Vector2(1160, ground_y), -1.0)
			dao = prop(dien, "dao", "tay", "F")
			ho_d = prop(dien, "ho_lo", "hong", "B")
			bg = actor("bat-gioi", Vector2(2500, ground_y), -1.0)
			ls = actor("nhac-linh-san", Vector2(-500, ground_y), 1.0)


func _story(dt: float) -> void:
	if not inside and m != "k10":
		rain_of("snow", 70.0 if m != "k08" else 30.0, Rect2(-500, -700, 2900, 80))
		rain_of("drift", 4.0 if m != "k08" else 1.0, Rect2(-500, ground_y - 30, 400, 30))
	if m == "k10":
		rain_of("snow", 14.0, Rect2(-500, -700, 2900, 80))
	if t < 0.0:
		return
	match m:
		"k06":
			_s06(dt)
		"k07":
			_s07(dt)
		"k08":
			_s08(dt)
		"k10":
			_s10(dt)


func _cam() -> Array:
	match m:
		"k06":
			return _c06()
		"k07":
			return _c07()
		"k08":
			return _c08()
		"k10":
			return _c10()
	return [CENTER, 1.0]


func _once(k: String) -> bool:
	if did.has(k):
		return false
	did[k] = true
	return true


# bóng chân: bỏ người đang ẩn (Bất Giới trong bong bóng nghĩ, người trong hang)
func _d_shadow(c: Node2D) -> void:
	for a in actors:
		if float(a.get("show", 1.0)) < 0.5 or float(a.get("size", 1.0)) < 0.8:
			continue
		var p: Vector2 = a.pos
		flat_blob(c, Vector2(p.x, maxf(p.y, ground_y)) + Vector2(0, 4), 120.0, 0.16, Color(ink, 0.35))


# ---------------------------------------------------------------- nền chung

func _sky(c: Node2D) -> void:
	if m == "k08":
		c.draw_circle(Vector2(1460, 230), 150.0, Color(1, 1, 0.9, 0.06))
		c.draw_circle(Vector2(1460, 230), 96.0, Color(1, 1, 0.9, 0.12))
		c.draw_circle(Vector2(1460, 230), 70.0, Color("#f4efd8"))
		c.draw_circle(Vector2(1440, 214), 16.0, Color("#e0d9bf"))
		c.draw_circle(Vector2(1482, 248), 10.0, Color("#e0d9bf"))
	if m == "k10" or m == "k08":
		var r := RandomNumberGenerator.new()
		r.seed = 77
		for i in 90:
			var p := Vector2(r.randf_range(-200, W + 200), r.randf_range(-200, 620))
			var tw := 0.5 + 0.5 * sin(t * r.randf_range(1.0, 3.0) + i)
			c.draw_circle(p, r.randf_range(1.0, 2.6), Color(1, 1, 0.95, 0.35 + 0.5 * tw))


func _far(c: Node2D) -> void:
	var col := air(Color("#8b9bb5"), 0.5) if m != "k10" and m != "k08" else Color("#5c6a92")
	shape(c, mountain_pts([Vector2(-100, 520), Vector2(260, 330), Vector2(520, 470), Vector2(900, 260), Vector2(1250, 450), Vector2(1600, 300), Vector2(2000, 480)], 700.0), col, 0.0)
	var cap := PackedVector2Array([Vector2(820, 320), Vector2(900, 260), Vector2(980, 318), Vector2(940, 330), Vector2(900, 300), Vector2(860, 334)])
	c.draw_colored_polygon(cap, Color(SNOW, 0.7 if m != "k10" else 0.25))


func _mid(c: Node2D) -> void:
	var col := Color("#8593ad") if m != "k10" and m != "k08" else Color("#46557c")
	shape(c, mountain_pts([Vector2(-200, 700), Vector2(300, 560), Vector2(700, 660), Vector2(1100, 590), Vector2(1500, 690), Vector2(2100, 600)], 860.0), col, 0.0)
	var xs := [-150.0, 40.0, 210.0, 1500.0, 1640.0, 1820.0, 2000.0]
	if m == "k10":
		xs = [-150.0, 40.0, 210.0, 380.0, 560.0]
	for i in xs.size():
		var x: float = xs[i]
		pine(c, Vector2(x, 760 + (i % 3) * 20), 260.0 + (i % 2) * 70.0, 120.0, col.lightened(0.12), 0.8, 0.0, i)


func _ground(c: Node2D) -> void:
	if inside:
		_hang(c)
		return
	_vach(c)
	_tuyet(c)
	match m:
		"k07":
			_g07(c)
		"k08":
			_g08(c)
		"k10":
			_g10(c)


func _near(c: Node2D) -> void:
	match m:
		"k06":
			_n06(c)
		"k07":
			_n07(c)
		"k08":
			_n08(c)
		"k10":
			_n10(c)


func _glow(c: Node2D) -> void:
	match m:
		"k06":
			_gl06(c)
		"k07":
			_gl07(c)
		"k08":
			_gl08(c)
		"k10":
			_gl10(c)


func _d_screen(c: Node2D) -> void:
	super._d_screen(c)
	match m:
		"k06":
			_sc06(c)
		"k07":
			_sc07(c)


# vách đá dựng sau lưng người (mặt vách quay ra máy), mép phải đổ xuống
func _vach(c: Node2D) -> void:
	var pts := PackedVector2Array([Vector2(-1200, ground_y + 2), Vector2(-1200, -900), Vector2(-500, -980), Vector2(-120, -760),
		Vector2(160, -820), Vector2(420, -540), Vector2(560, -300), Vector2(640, 20), Vector2(700, 380), Vector2(770, 640), Vector2(820, ground_y + 2)])
	shape(c, pts, ROCK, 5.0)
	hatch(c, pts, 1.2, 26.0, Color(ink, 0.22))
	# mảng sáng phía trên + vết nứt dọc
	clip_fill(c, pts, PackedVector2Array([Vector2(-1200, -1000), Vector2(500, -1000), Vector2(200, 200), Vector2(-1200, 300)]), Color(ROCK_HI, 0.35))
	var r := RandomNumberGenerator.new()
	r.seed = 11
	for i in 16:
		var x := r.randf_range(-1100, 620)
		var y := r.randf_range(-700, 760)
		cut(c, Vector2(x, y), Vector2(x + r.randf_range(-30, 30), y + r.randf_range(60, 160)), 3.0, Color(ink, 0.5))
	# gờ tuyết trên vách
	for i in 6:
		var y := -600.0 + i * 230.0
		var x0 := -1100.0 + (i % 3) * 140.0
		var ln := 380.0 + (i % 2) * 220.0
		var sh := PackedVector2Array([Vector2(x0, y), Vector2(x0 + ln, y - 6), Vector2(x0 + ln - 20, y + 16), Vector2(x0 + 30, y + 22)])
		shape(c, round_pts(sh), SNOW, 3.0, Color(SNOW_SH))
	# cửa hang (k07 trở đi), hoặc lỗ thủng (k06 sau cú gõ)
	if m != "k06":
		_cua_hang(c, 1.0)


func _cua_hang(c: Node2D, k: float) -> void:
	var w := 210.0 * k
	var h := 320.0 * k
	var p := MOUTH
	var r := w * 0.5
	var arch := PackedVector2Array([p + Vector2(-r, 0)])
	for i in 13:
		var an := PI + PI * i / 12.0
		var j := sin(i * 2.7) * 7.0
		arch.append(p + Vector2(cos(an) * (r + j), -(h - r) + sin(an) * (r + j)))
	arch.append(p + Vector2(r, 0))
	shape(c, arch, CAVE, 6.0, Color("#3a3c48"))
	c.draw_colored_polygon(PackedVector2Array([p + Vector2(-r * 0.7, 0), p + Vector2(r * 0.7, 0), p + Vector2(r * 0.4, -h * 0.35), p + Vector2(-r * 0.4, -h * 0.35)]), Color(0.05, 0.05, 0.08, 0.5))


func _tuyet(c: Node2D) -> void:
	var pts := PackedVector2Array([Vector2(-1200, ground_y), Vector2(-200, ground_y - 8), Vector2(600, ground_y + 4), Vector2(1400, ground_y - 6), Vector2(3600, ground_y + 2), Vector2(3600, 1500), Vector2(-1200, 1500)])
	shape(c, round_pts(pts, true, 4), SNOW, 4.0, Color(SNOW_SH))
	for i in 18:
		var x := -900.0 + i * 190.0
		var y := ground_y + 40.0 + (i % 4) * 34.0
		c.draw_line(Vector2(x, y), Vector2(x + 90, y + 4), Color(SNOW_SH, 0.6), 3.0, true)
	for i in 7:
		var x := -700.0 + i * 460.0
		var dr := PackedVector2Array([Vector2(x - 120, ground_y + 6), Vector2(x - 40, ground_y - 22), Vector2(x + 60, ground_y - 30), Vector2(x + 170, ground_y - 8), Vector2(x + 230, ground_y + 8)])
		shape(c, round_pts(dr, true, 5), SNOW, 3.0, Color(SNOW_SH))


# hình người khắc (que): k = kiểu thế, prog = phần nét đã khắc
func _fig(c: Node2D, p: Vector2, s: float, k: int, col: Color, w: float, prog: float) -> void:
	if prog <= 0.01:
		return
	var r := RandomNumberGenerator.new()
	r.seed = k * 13 + 5
	var hip := p
	var neck := p + Vector2(r.randf_range(-12, 12), -0.55 * s)
	var head := neck + Vector2(0, -0.2 * s)
	var segs := [[hip, neck]]
	var la := r.randf_range(-2.6, -0.4)
	var ra := r.randf_range(-1.6, 0.6)
	var hand := neck + Vector2.from_angle(ra) * 0.42 * s
	segs.append([neck, neck + Vector2.from_angle(la) * 0.38 * s])
	segs.append([neck, hand])
	segs.append([hip, hip + Vector2(-0.25 * s, 0.45 * s + r.randf_range(-10, 10))])
	segs.append([hip, hip + Vector2(0.28 * s, 0.42 * s)])
	segs.append([hand, hand + Vector2.from_angle(ra + r.randf_range(-0.9, 0.9)) * 0.75 * s])
	var n := segs.size() + 1
	var shown := prog * n
	if shown > 0.0:
		c.draw_arc(head, 0.12 * s, 0.0, TAU * clampf(shown, 0.0, 1.0), 14, col, w, true)
	for i in segs.size():
		var f := clampf(shown - 1.0 - i, 0.0, 1.0)
		if f <= 0.0:
			break
		var sg: Array = segs[i]
		var a: Vector2 = sg[0]
		var b: Vector2 = sg[1]
		c.draw_line(a, a.lerp(b, f), col, w if i < 5 else w * 0.7, true)


func _line_part(c: Node2D, pts: PackedVector2Array, prog: float, col: Color, w: float) -> Vector2:
	if prog <= 0.0 or pts.size() < 2:
		return pts[0]
	var n := pts.size() - 1
	var u := prog * n
	var k := mini(int(u), n - 1)
	var out := PackedVector2Array()
	for i in k + 1:
		out.append(pts[i])
	var e := pts[k].lerp(pts[k + 1], u - k)
	out.append(e)
	c.draw_polyline(out, col, w, true)
	return e


# ================================================================ k06: vách sám hối → hang khắc chiêu

func _s06(_dt: float) -> void:
	var a4 := L("k06-04")
	var a5 := L("k06-05")
	var a6 := L("k06-06")
	var a6b := L("k06-06b")
	var a7 := L("k06-07")
	if t >= a6 - 0.1 and not inside:
		inside = true
		var keep: Array = []
		for q in parts:
			if q.k != "snow" and q.k != "drift":
				keep.append(q)
		parts = keep
		lhx.pos = Vector2(560, ground_y)
		lhx.go = Vector2.INF
		lhx.face = 1.0
		ls.pos = Vector2(2600, ground_y)
		ls.go = Vector2.INF
		vign_a = 0.55
	if inside:
		# trong hang: đứng ngẩng nhìn vách; chỉ tay theo từng cột khắc; cuối cùng toát mồ hôi
		var pt := bump(a6 + 1.0, a6 + 1.4, a6 + 4.4, a6 + 4.9) + bump(a7 + 0.2, a7 + 0.6, a7 + 2.6, a7 + 3.0)
		var shake := sin(t * 40.0) * 1.2 * smooth(a7 + 2.8, a7 + 3.2, t)
		lhx.extra = [["rest", 1.0], [{"head": -16.0 + shake, "torso": -4.0}, 1.0 - smooth(a7 + 2.6, a7 + 3.2, t)], ["point", pt * 0.9],
			[{"head": 6.0 + shake, "uaB": -40.0, "faB": -90.0, "all": [0.0, shake, 0.0]}, smooth(a7 + 2.6, a7 + 3.2, t)]]
		lhx.expr = "soc" if t > a7 + 2.6 or (t > a6b + 1.0 and t < a6b + 3.0) else ("quyet-tam" if t > a6 + 1.0 else "binh")
		return
	# ngoài vách: ngồi ôm gối giữa gió → tiểu sư muội lên → đứng dậy → ra gõ vách
	var up := smooth(a4 + 0.4, a4 + 1.1, t)
	var hug := {"head": 18.0 + sin(t * 0.8) * 2.0, "torso": 16.0, "uaF": -20.0, "faF": -30.0}
	lhx.extra = [[SIT_GROUND, 1.0 - up], [hug, 1.0 - up]]
	lhx.expr = "buon" if t < a4 else "vui"
	if t > a4 + 0.4 and t < a5:
		lhx.face = 1.0
	# Linh San: xách giỏ cơm lên, đứng nói, quay về
	if t > a4 - 1.4 and t < a5 - 0.6:
		ls.go = Vector2(1240, ground_y)
		ls.speed = 300.0
	elif t >= a5 - 0.6:
		ls.go = Vector2(2600, ground_y)
		ls.speed = 280.0
	ls.hold = {"F": [Vector2(40, -20), 1.0]}
	ls.expr = "vui"
	ls.talk = bump(a4 + 1.2, a4 + 1.5, a5 - 1.2, a5 - 0.9) * 0.6
	# gõ vách
	if t >= a5 - 0.3:
		lhx.go = Vector2(580, ground_y)
		lhx.speed = 240.0
		var kn := 0.0
		for k in 3:
			var h := a5 + 1.4 + k * 0.6
			kn += bump(h - 0.2, h - 0.05, h + 0.05, h + 0.25)
		lhx.extra.append([{"uaF": -100.0, "faF": -40.0, "torso": -4.0}, kn])
		lhx.expr = "soc" if t > a5 + 2.8 else "binh"


func _crack() -> float:
	var a5 := L("k06-05")
	return smooth(a5 + 2.6, a5 + 3.4, t)


func _c06() -> Array:
	var a3 := L("k06-03")
	var a4 := L("k06-04")
	var a5 := L("k06-05")
	var a6 := L("k06-06")
	var a6b := L("k06-06b")
	var a7 := L("k06-07")
	if inside:
		if t < a6b:
			return [Vector2(lerpf(620.0, 1350.0, smooth(a6 + 0.6, a6b - 0.4, t)), 520.0), 1.05]
		if t < a7:
			return [Vector2(960, 540), 0.92]
		var hp := head_of(lhx)
		var k := smooth(a7 + 2.4, a7 + 3.6, t)
		return [Vector2(1050, 480).lerp(hp + Vector2(40, 40), k), lerpf(1.0, 1.9, k)]
	if t < a3:
		var k := smooth(1.0, 10.0, t)
		return [Vector2(600, -260).lerp(Vector2(860, 560), k), lerpf(0.95, 1.0, k)]
	if t < a4 - 0.8:
		var k := smooth(a3, a4 - 0.8, t)
		return [Vector2(860, 560).lerp(Vector2(960, 660), k), lerpf(1.0, 1.35, k)]
	if t < a5 + 0.2:
		return [Vector2(1100, 640), 1.12]
	var k2 := smooth(a5 + 0.2, a5 + 1.4, t)
	var z := lerpf(1.12, 1.4, k2) + smooth(a5 + 2.6, a6 - 0.2, t) * 0.5
	return [Vector2(1100, 640).lerp(Vector2(560, 650), k2), z]


func _n06(c: Node2D) -> void:
	if inside:
		var a7 := L("k06-07")
		if t > a7 + 2.6:
			var hp := head_of(lhx)
			for k in 7:
				var ph := fmod(t * 0.9 + k * 0.37, 1.0)
				var p := hp + Vector2(-60.0 + k * 22.0, -40.0 + ph * 120.0 + (k % 2) * 12.0)
				var a := (1.0 - ph) * smooth(a7 + 2.6, a7 + 3.0, t)
				c.draw_circle(p, 7.0, Color(Color("#9fd4ff"), a), true, -1.0, true)
				c.draw_colored_polygon(PackedVector2Array([p + Vector2(-6, 0), p + Vector2(0, -16), p + Vector2(6, 0)]), Color(Color("#9fd4ff"), a))
		return
	# giỏ cơm + bình rượu nhỏ của Linh San
	var hd: Node2D = ls.node.J["hdF"]
	var bp := to_w(hd, Vector2(0, 30))
	shape(c, PackedVector2Array([bp + Vector2(-34, 0), bp + Vector2(34, 0), bp + Vector2(26, 40), bp + Vector2(-26, 40)]), Color("#b0803c"), 3.0)
	c.draw_arc(bp, 30.0, PI, TAU, 10, inkof(Color("#b0803c")), 4.0, true)
	holo(c, bp + Vector2(14, -6), 0.42, Color("#e8b65a"), 0.8)
	# lỗ thủng sau cú gõ thứ ba + đá vụn rơi
	var cr := _crack()
	var a5 := L("k06-05")
	if t > a5 + 1.4:
		for k in 3:
			var h := a5 + 1.4 + k * 0.6
			if t > h:
				for i in 4:
					var an := i * 1.6 + k
					cut(c, HOLE, HOLE + Vector2.from_angle(an) * (30.0 + k * 22.0), 3.0, Color(ink, 0.8))
	if cr > 0.0:
		var hole := PackedVector2Array()
		for i in 14:
			var an := TAU * i / 14.0
			var rr := (60.0 + sin(i * 3.1) * 16.0) * cr
			hole.append(HOLE + Vector2(cos(an) * rr, sin(an) * rr * 1.2))
		shape(c, hole, CAVE, 4.0, Color("#2a2c36"))
		var e := t - (a5 + 2.6)
		for i in 9:
			var r := RandomNumberGenerator.new()
			r.seed = 300 + i
			var v := Vector2(r.randf_range(-160, 220), r.randf_range(-260, -60))
			var p := HOLE + v * e + Vector2(0, 900.0 * e * e)
			if p.y < ground_y - 6.0:
				c.draw_rect(Rect2(p, Vector2(10, 8) * r.randf_range(0.8, 1.6)), ROCK_HI)


func _gl06(c: Node2D) -> void:
	if inside:
		blob(c, Vector2(300, 260), 520.0, Color(1.0, 0.62, 0.3, 0.16))
		blob(c, Vector2(300, 260), 90.0, Color(1.4, 0.9, 0.5, 0.35))
		return
	var cr := _crack()
	if cr > 0.0:
		blob(c, HOLE, 160.0 * cr, Color(1.0, 0.8, 0.5, 0.28 * cr))


# trong hang: vách đá sẫm, đuốc, năm cột chiêu của năm phái + cách phá; mười bóng trưởng lão khắc vách
func _hang(c: Node2D) -> void:
	var a6 := L("k06-06")
	var a6b := L("k06-06b")
	var a7 := L("k06-07")
	c.draw_rect(Rect2(-600, -400, 3000, 1300), Color("#575866"))
	hatch(c, PackedVector2Array([Vector2(-600, -400), Vector2(2400, -400), Vector2(2400, ground_y), Vector2(-600, ground_y)]), 0.9, 30.0, Color(0, 0, 0, 0.25))
	var r := RandomNumberGenerator.new()
	r.seed = 5
	for i in 40:
		var p := Vector2(r.randf_range(-500, 2300), r.randf_range(-300, 800))
		c.draw_circle(p, r.randf_range(8, 30), Color("#626372"))
	c.draw_rect(Rect2(-600, ground_y, 3000, 600), Color("#43434f"))
	c.draw_line(Vector2(-600, ground_y), Vector2(2400, ground_y), Color("#3a3a46"), 4.0)
	# đuốc
	c.draw_line(Vector2(300, 300), Vector2(300, 420), Color("#5a3a22"), 12.0)
	var fl := sin(t * 13.0) * 6.0
	shape(c, PackedVector2Array([Vector2(282, 300), Vector2(300 + fl, 220), Vector2(318, 300)]), Color("#ffb040"), 0.0)
	# năm cột: trên = chiêu của phái (nét trắng ngà), dưới = cách phá (nét son)
	for i in 5:
		var x := 520.0 + i * 300.0
		c.draw_rect(Rect2(x - 120, 150, 240, 640), Color(0, 0, 0, 0.18))
		c.draw_rect(Rect2(x - 120, 150, 240, 640), Color("#77788a"), false, 3.0)
		var p1 := smooth(a6 + 0.6 + i * 0.7, a6 + 1.4 + i * 0.7, t)
		var p2 := smooth(a6 + 2.8 + i * 0.4, a6 + 3.6 + i * 0.4, t)
		_fig(c, Vector2(x, 330), 200.0, i * 2, CARVE, 6.0, p1)
		_fig(c, Vector2(x, 640), 200.0, i * 2 + 1, OCHRE, 6.0, p2)
		if p2 > 0.5:
			cut(c, Vector2(x - 60, 470), Vector2(x + 60, 470), 3.0, Color(OCHRE, 0.6))
			c.draw_colored_polygon(PackedVector2Array([Vector2(x - 8, 456), Vector2(x + 8, 456), Vector2(x, 476)]), OCHRE)
		var xk := smooth(a7 + 0.4 + i * 0.35, a7 + 0.6 + i * 0.35, t)
		if xk > 0.0:
			cut(c, Vector2(x - 80, 230), Vector2(x - 80, 230).lerp(Vector2(x + 80, 410), xk), 9.0, Color("#e04a3a"))
			cut(c, Vector2(x + 80, 230), Vector2(x + 80, 230).lerp(Vector2(x - 80, 410), xk), 9.0, Color("#e04a3a"))
	# mười bóng trưởng lão (nhạt như hồi ức), tay cầm đục, tia đá
	var ga := bump(a6b + 0.3, a6b + 1.4, LE("k06-06b") - 0.6, LE("k06-06b") + 0.2)
	if ga > 0.01:
		for i in 10:
			var p := Vector2(260.0 + i * 165.0, ground_y)
			var col := Color(Color("#9fb4d8"), 0.32 * ga)
			c.draw_colored_polygon(PackedVector2Array([p + Vector2(-50, 0), p + Vector2(50, 0), p + Vector2(30, -90), p + Vector2(-30, -90)]), col)
			c.draw_circle(p + Vector2(0, -120), 34.0, col, true, -1.0, true)
			var ch := p + Vector2(42, -150 - sin(t * 9.0 + i) * 10.0)
			c.draw_line(p + Vector2(20, -80), ch, Color(Color("#9fb4d8"), 0.5 * ga), 5.0, true)
			if sin(t * 9.0 + i) > 0.6:
				for k in 3:
					c.draw_line(ch, ch + Vector2.from_angle(-1.2 + k * 0.6) * 22.0, Color(1.0, 0.9, 0.6, 0.8 * ga), 2.0, true)


# mống mắt: khép vào lỗ thủng → mở ra trong hang
func _sc06(c: Node2D) -> void:
	var a6 := L("k06-06")
	var r := 3000.0
	var ctr := CENTER
	if t > a6 - 1.1 and t < a6 - 0.1:
		r = lerpf(2400.0, 0.0, smooth(a6 - 1.1, a6 - 0.1, t))
		ctr = CENTER + (HOLE - cam) * zoom
	elif t >= a6 - 0.1 and t < a6 + 1.0:
		r = lerpf(0.0, 2400.0, smooth(a6 - 0.1, a6 + 1.0, t))
	if r >= 2400.0:
		return
	var ring := PackedVector2Array()
	for i in 41:
		var an := TAU * i / 40.0
		var j := 1.0 + sin(i * 2.2) * 0.06
		ring.append(ctr + Vector2(cos(an), sin(an) * 1.15) * r * j)
	var big := PackedVector2Array([Vector2(-200, -200), Vector2(W + 200, -200), Vector2(W + 200, H + 200), Vector2(-200, H + 200)])
	var outs := Geometry2D.clip_polygons(big, ring)
	for poly in outs:
		if Geometry2D.is_polygon_clockwise(poly):
			continue
		c.draw_colored_polygon(poly, Color("#08080b"))
	if outs.size() != 1:
		# đa giác có lỗ: vẽ vành bằng dải dày thay thế
		for i in 40:
			var a: Vector2 = ring[i]
			var b: Vector2 = ring[i + 1]
			var da := (a - ctr).normalized() * 2600.0
			var db := (b - ctr).normalized() * 2600.0
			c.draw_colored_polygon(PackedVector2Array([a, b, b + db, a + da]), Color("#08080b"))
	c.draw_polyline(ring, Color("#3a3a46"), 6.0, true)


# ================================================================ k07: đánh – thua – vào hang (lặp)

const HOME_L := 860.0
const HOME_D := 1260.0


func _hits07() -> Array:
	var b4 := L("k07-04")
	var o := []
	for k in 4:
		o.append(b4 + 0.6 + k * 1.1)
	return o


# thời điểm thua (mỗi lần thua một vạch đếm trên vách)
func _losses() -> Array:
	var b4 := L("k07-04")
	var b6 := L("k07-06")
	var b7 := L("k07-07")
	var b8 := L("k07-08")
	var o := [b4 + 4.1, L("k07-05") + 3.6]
	var P := 1.25
	var s := b6 + 1.0 - 0.3 * P
	var k := 0
	while s + 0.3 * P + k * P < b7:
		o.append(s + 0.3 * P + k * P)
		k += 1
	while o.size() < 12:
		o.append(b8 + 0.6 + (o.size() - 6) * 0.25)
	return o


func _s07(_dt: float) -> void:
	var b1 := L("k07-01")
	var b1b := L("k07-01b")
	var b2 := L("k07-02")
	var b3 := L("k07-03")
	var b4 := L("k07-04")
	var b5 := L("k07-05")
	var b6 := L("k07-06")
	var b7 := L("k07-07")
	var b8 := L("k07-08")
	# --- Điền phóng tới (khinh công), khoe hai cú nhảy
	if t >= b1 and t < b4:
		dien.go = Vector2(HOME_D, ground_y)
		dien.speed = 1500.0 if t < b1 + 1.5 else 300.0
	var hop := 0.0
	for k in 2:
		var h0 := b1b + 1.2 + k * 1.3
		var e := clampf((t - h0) / 0.9, 0.0, 1.0)
		hop += sin(e * PI) * 230.0
	dien.pos.y = ground_y - hop
	if t > b1b + 1.2 and t < b1b + 3.4:
		dien.pos.x = HOME_D + sin(clampf((t - b1b - 1.2) / 2.2, 0.0, 1.0) * TAU) * 160.0
	dien.expr = "dac-y" if t < b2 else ("ngai" if t < b3 else "gian")
	var flour := bump(b1b + 0.2, b1b + 0.5, b1b + 1.0, b1b + 1.2)
	dien.extra = [["stance", smooth(b1 + 1.0, b1 + 1.4, t)], ["windup", flour], [{"torso": 14.0, "head": 10.0, "all": [0.0, 0.0, 30.0]}, smooth(b1, b1 + 0.2, t) * (1.0 - smooth(b1 + 0.9, b1 + 1.3, t))]]
	# --- bong bóng nghĩ: Bất Giới chỉ tay ra lệnh
	var ba := bump(b2 + 0.3, b2 + 0.8, LE("k07-02") - 0.2, LE("k07-02") + 0.3)
	bg.show = ba
	bg.pos = Vector2(1560, 600)
	bg.extra = [["point", 0.8 + 0.2 * sin(t * 9.0)], [{"head": sin(t * 7.0) * 6.0}, 1.0]]
	bg.expr = "gian"
	# --- Lệnh Hồ Xung: lắc đầu, rút kiếm
	var no := on("k07-03", 0.0, -2.0)
	lhx.expr = "vui" if t < b3 else "quyet-tam"
	if t > b3 + 1.6 and _once("rut"):
		prop_to(kiem, "tay", "F")
	lhx.extra = [[{"head": sin(t * 10.0) * 10.0}, no], ["stance", smooth(b3 + 1.6, b3 + 2.0, t)]]
	# --- bốn nhát: bị dí lùi tới vách
	var hs := _hits07()
	var dx := 0.0
	var sl := 0.0
	var gd := 0.0
	for h: float in hs:
		dx -= 80.0 * smooth(h - 0.02, h + 0.2, t)
		sl += bump(h - 0.18, h - 0.05, h + 0.12, h + 0.3)
		gd += bump(h - 0.2, h - 0.05, h + 0.2, h + 0.4)
	if t >= b4 and t < b5 + 0.6:
		lhx.go = Vector2.INF
		lhx.pos.x = HOME_L - 300.0 + dx + 300.0 + (-20.0 if t > b4 + 4.0 else 0.0)
		dien.go = Vector2.INF
		dien.pos.x = lhx.pos.x + 400.0 - sl * 30.0
		lhx.extra.append(["guard", gd])
		lhx.extra.append([{"torso": -18.0, "head": -10.0}, gd * 0.6])
		dien.extra.append(["windup", bump(hs[0] - 0.5, hs[0] - 0.2, hs[3] + 0.4, hs[3] + 0.6) * (1.0 - sl)])
		dien.extra.append(["slash", sl])
		lhx.expr = "soc" if gd > 0.4 else "quyet-tam"
		dao.trail_on = sl > 0.4
	# --- xin nghỉ, chui vào hang, đi ra
	if t >= b5 and t < b6:
		var palm := bump(b5 + 0.2, b5 + 0.5, b5 + 1.0, b5 + 1.2)
		lhx.extra.append([{"uaB": -90.0, "faB": -20.0}, palm])
		lhx.expr = "vui"
		if t > b5 + 1.0 and t < b5 + 2.6:
			lhx.go = Vector2(MOUTH.x, ground_y)
			lhx.speed = 300.0
		elif t >= b5 + 2.6:
			lhx.go = Vector2(HOME_L - 120.0, ground_y)
			lhx.speed = 320.0
		var crossed := {"uaF": -40.0, "faF": -110.0, "uaB": -30.0, "faB": -115.0, "ftF": -8.0 - maxf(0.0, sin(t * 9.0)) * 16.0}
		dien.extra = [[crossed, 1.0]]
		dien.expr = "ngai"
		dien.go = Vector2(HOME_D - 160.0, ground_y)
		dien.speed = 200.0
	# --- vòng lặp nhanh: đánh (0–.3) bị đẩy (.3–.45) vào hang (.45–.75) ra (.75–1)
	var P := 1.25
	var s := b6 + 1.0 - 0.3 * P
	if t >= b6 and t < b7:
		var u := (t - s) / P
		var ph := fposmod(u, 1.0)
		if u < 0.0:
			ph = 0.9
		lhx.go = Vector2.INF
		dien.go = Vector2.INF
		dien.pos.x = 1080.0
		var x := 700.0
		var vis := 1.0
		if ph < 0.3:
			x = 700.0
		elif ph < 0.45:
			x = lerpf(700.0, 560.0, smooth(0.3, 0.42, ph))
		elif ph < 0.75:
			x = lerpf(560.0, MOUTH.x, smooth(0.45, 0.6, ph))
			vis = 1.0 - smooth(0.55, 0.62, ph)
		else:
			x = lerpf(MOUTH.x, 700.0, smooth(0.75, 0.98, ph))
			vis = smooth(0.75, 0.8, ph)
		lhx.pos.x = x
		lhx.show = vis
		lhx.face = -1.0 if ph > 0.45 and ph < 0.75 else 1.0
		lhx.walk = 1.0 if ph > 0.45 else 0.0
		lhx.ph = t * 22.0
		var clash := bump(0.08, 0.15, 0.22, 0.3) if ph < 0.3 else 0.0
		var push := bump(0.3, 0.33, 0.4, 0.45) if ph >= 0.3 and ph < 0.45 else 0.0
		dien.extra = [["stance", 1.0], ["slash", clash + push]]
		lhx.extra = [["stance", 1.0 if ph < 0.45 else 0.0], ["guard", clash], [{"torso": -24.0, "head": -14.0}, push]]
		lhx.expr = "soc" if push > 0.2 else "vui"
		dien.expr = "gian"
		dao.trail_on = clash + push > 0.4
	# --- Điền rón rén ngó vào hang; trong hang lóe hai đốm mắt
	if t >= b7:
		lhx.show = 1.0
		lhx.go = Vector2(1180, ground_y)
		lhx.speed = 300.0
		lhx.expr = "vui"
		dien.go = Vector2(MOUTH.x + 170.0, ground_y)
		dien.speed = 320.0
		var lean := smooth(b7 + 1.6, b7 + 2.2, t) * (1.0 - smooth(b8 - 0.2, b8 + 0.3, t))
		dien.extra = [[{"torso": -26.0, "head": -18.0, "uaF": 30.0, "uaB": -20.0, "all": [0.0, 0.0, 12.0]}, lean]]
		dien.expr = "ngai" if t < b8 else "ngai"
		lhx.extra = [[{"head": sin(t * 3.0) * 6.0, "uaF": -150.0, "faF": -10.0}, bump(b8 + 0.4, b8 + 0.8, b8 + 4.0, b8 + 4.5)]]
		lhx.talk = bump(b8, b8 + 0.3, b8 + 4.4, b8 + 4.8) * 0.6
		if t > b8 + 0.4:
			lhx.go = Vector2(980, ground_y)
			lhx.face = -1.0
			dien.face = 1.0
	if t < b4 and t > b1 + 1.6 and hop <= 0.0:
		dien.face = -1.0


func _c07() -> Array:
	var b2 := L("k07-02")
	var b4 := L("k07-04")
	var b7 := L("k07-07")
	var b8 := L("k07-08")
	var base := Vector2(900, 620)
	var z := 1.0
	var bb := bump(b2 + 0.2, b2 + 0.9, LE("k07-02") - 0.3, LE("k07-02") + 0.4)
	base = base.lerp(Vector2(1320, 560), bb)
	z = lerpf(z, 1.15, bb)
	for h: float in _hits07():
		z += 0.06 * bump(h - 0.05, h, h + 0.1, h + 0.4)
	if t >= b4 + 0.2 and t < L("k07-06"):
		base = base.lerp(Vector2(760, 640), smooth(b4, b4 + 1.0, t))
		z += 0.1
	var pk := smooth(b7 + 0.5, b7 + 2.0, t) * (1.0 - smooth(b8 - 0.3, b8 + 0.6, t))
	base = base.lerp(Vector2(560, 680), pk)
	z = lerpf(z, 1.45, pk)
	var fin := smooth(b8, b8 + 1.0, t)
	base = base.lerp(Vector2(820, 680), fin)
	z = lerpf(z, 1.3, fin)
	return [base, z]


func _g07(c: Node2D) -> void:
	# vạch đếm trận thua khắc trên vách cạnh cửa hang
	var n := 0
	for lt: float in _losses():
		if t >= lt:
			n += 1
	var base := Vector2(560, 560)
	for i in n:
		var g := i / 5
		var j := i % 5
		var x := base.x + g * 70.0
		if j < 4:
			cut(c, Vector2(x + j * 12.0, base.y), Vector2(x + j * 12.0 + 3.0, base.y + 56.0), 5.0, Color(CARVE, 0.9))
		else:
			cut(c, Vector2(x - 6.0, base.y + 44.0), Vector2(x + 48.0, base.y + 8.0), 5.0, Color(CARVE, 0.9))
	# bong bóng nghĩ của Điền
	var ba := bump(L("k07-02") + 0.3, L("k07-02") + 0.8, LE("k07-02") - 0.2, LE("k07-02") + 0.3)
	if ba > 0.01:
		var col := Color(1, 1, 1, 0.92 * ba)
		puff(c, [[Vector2(1560, 470), 150.0], [Vector2(1450, 520), 90.0], [Vector2(1680, 510), 100.0], [Vector2(1560, 600), 90.0]], col, 4.0, 0.0, Color(ink, ba))
		for k in 3:
			c.draw_circle(dien.pos + Vector2(30 + k * 40, -330 - k * 50), 10.0 + k * 6.0, col)


func _n07(c: Node2D) -> void:
	# vệt khinh công sau lưng Điền
	var b1 := L("k07-01")
	var sp := bump(b1, b1 + 0.1, b1 + 0.9, b1 + 1.3)
	if sp > 0.01:
		for k in 6:
			var y: float = dien.pos.y - 60.0 - k * 34.0
			c.draw_line(Vector2(dien.pos.x + 90, y), Vector2(dien.pos.x + 420 + k * 40, y), Color(1, 1, 1, 0.55 * sp), 5.0, true)
	# dấu "?" trên đầu Điền khi ngó hang
	var b7 := L("k07-07")
	var q := bump(b7 + 2.0, b7 + 2.3, b7 + 4.4, b7 + 4.8)
	if q > 0.01:
		var hp := head_of(dien) + Vector2(0, -150 + sin(t * 6.0) * 6.0)
		c.draw_string(font, hp + Vector2(-20, 0), "?", HORIZONTAL_ALIGNMENT_LEFT, -1, 96, Color(Color("#ffe08a"), q))


func _gl07(c: Node2D) -> void:
	# tia lửa khi đao chạm kiếm
	for h: float in _hits07():
		var e := t - h
		if e > 0.0 and e < 0.35:
			var p: Vector2 = lhx.pos + Vector2(110, -190)
			rays(c, p, PI, TAU, 9, 120.0 * (1.0 - e / 0.35) + 30.0, Color(1.4, 1.2, 0.8, 0.9))
			blob(c, p, 90.0, Color(1.2, 1.0, 0.7, 0.4 * (1.0 - e / 0.35)))
	var b6 := L("k07-06")
	var e2 := t - (b6 + 1.0)
	if e2 > 0.0 and e2 < 0.5:
		blob(c, lhx.pos + Vector2(60, -150), 220.0, Color(1.2, 1.1, 0.9, 0.5 * (1.0 - e2 / 0.5)))
	# hai đốm mắt trong hang
	var b7 := L("k07-07")
	var gl := bump(b7 + 2.6, b7 + 2.8, b7 + 3.6, b7 + 3.9)
	if gl > 0.01:
		for sx: float in [-18.0, 18.0]:
			blob(c, MOUTH + Vector2(sx, -200), 26.0, Color(1.4, 1.4, 1.0, 0.8 * gl))


# biểu tượng vòng lặp ở góc (đọc được không cần chữ)
func _sc07(c: Node2D) -> void:
	var b6 := L("k07-06")
	var a := bump(b6, b6 + 0.4, L("k07-07") - 0.3, L("k07-07"))
	if a <= 0.01:
		return
	var o := Vector2(170, 170)
	var an := -t * 5.0
	c.draw_circle(o, 92.0, Color(0, 0, 0, 0.35 * a))
	c.draw_arc(o, 62.0, an, an + 4.8, 30, Color(Color("#ffe08a"), a), 12.0, true)
	var tip := o + Vector2.from_angle(an + 4.8) * 62.0
	var d := Vector2.from_angle(an + 4.8 + PI * 0.5)
	c.draw_colored_polygon(PackedVector2Array([tip + d * 26.0, tip + d.orthogonal() * 22.0, tip - d.orthogonal() * 22.0]), Color(Color("#ffe08a"), a))


# ================================================================ k08: ông già áo xám, chín nét trên đá

const PHONG_ROCK := Vector2(640, 860)
const SLAB := Rect2(-440, 420, 440, 420)
const TOMB := Vector2(2750, 860)
const PEAK := Vector2(1150, -820)


func _strokes() -> Array:
	var c := SLAB.get_center() + Vector2(0, -10)
	var o := []
	var ring := PackedVector2Array()
	for i in 25:
		var an := -PI * 0.5 + TAU * i / 24.0
		ring.append(c + Vector2(cos(an), sin(an)) * 70.0)
	o.append(ring)
	for k in 8:
		var an := -PI * 0.5 + TAU * k / 8.0
		var d := Vector2.from_angle(an)
		var n := d.orthogonal()
		var p0 := c + d * 100.0
		var pts := PackedVector2Array([p0, p0 + d * 40.0 + n * (14.0 if k % 2 == 0 else -14.0), p0 + d * 80.0 + n * (k % 3 - 1) * 18.0, p0 + d * 110.0])
		o.append(round_pts(pts, false, 4))
	return o


func _stroke_t() -> Array:
	var o := [L("k08-05") + 1.6]
	var c6 := L("k08-06")
	for k in 8:
		o.append(c6 + 0.7 + k * 0.62)
	return o


func _s08(_dt: float) -> void:
	var c1 := L("k08-01")
	var c2 := L("k08-02")
	var c3 := L("k08-03")
	var c4 := L("k08-04")
	var c7 := L("k08-07")
	var c8 := L("k08-08")
	var c9 := L("k08-09")
	# --- đang đánh dở (đầu đoạn) → Điền ra tảng đá ngồi ngủ gật
	var spar := 1.0 - smooth(c2, c2 + 0.5, t)
	var sw := fposmod(t, 1.1)
	var cl := bump(0.3, 0.45, 0.55, 0.8, ) if true else 0.0
	cl = smoothstep(0.3, 0.45, sw) * (1.0 - smoothstep(0.55, 0.8, sw))
	if t < c2 + 0.5:
		lhx.extra = [["stance", spar], ["guard", cl * spar]]
		dien.extra = [["stance", spar], ["slash", cl * spar]]
		lhx.expr = "quyet-tam"
		dien.expr = "gian"
	# --- Phong hiện ra ở cửa hang
	var ph_in := smooth(c1 + 0.5, c1 + 1.4, t)
	phong.show = ph_in
	phong.sway = 2.0
	var shake := on("k08-01", -1.5, 0.0)
	phong.extra = [[{"torso": 10.0, "head": sin(t * 8.0) * 9.0 * shake, "uaB": 30.0, "faB": -70.0}, 1.0]]
	phong.expr = "binh"
	if t > c2 and t < c3 + 0.4:
		phong.go = PHONG_ROCK + Vector2(-10, 0)
		phong.speed = 130.0
	# --- Phong ngồi xếp bằng trên đá
	var sit := smooth(c3 + 0.4, c3 + 0.9, t)
	if t > c3 + 0.4:
		phong.go = Vector2.INF
		phong.pos = PHONG_ROCK + Vector2(0, -62.0 * sit)
		phong.face = 1.0
		var br := (sin(t * 1.1) * 0.5 + 0.5) * 4.0
		var trace := bump(c4 + 0.4, c4 + 0.9, c4 + 4.0, c4 + 4.6)
		var wave := bump(c8 + 0.3, c8 + 0.7, c8 + 2.4, c8 + 2.9)
		var poke := bump(L("k08-05") + 1.0, L("k08-05") + 1.4, L("k08-06") + 5.6, L("k08-06") + 6.2)
		phong.extra = [[NGOI_XEP_BANG, sit], [{"all": [0.0, 0.0, 92.0 - br], "head": sin(t * 0.7) * 3.0}, sit],
			[arms_of("point"), maxf(trace, poke)], [{"uaF": -120.0 + sin(t * 6.0) * 30.0, "faF": -20.0}, wave]]
		phong.expr = "dac-y" if t < c4 else "binh"
	# --- Lệnh Hồ Xung quay lại, quỳ nghe
	if t > c2:
		lhx.face = -1.0
		var kn := smooth(c2 + 1.2, c2 + 1.8, t) * (1.0 - smooth(c7 - 0.6, c7, t))
		lhx.extra = [["kneel", kn * 0.8], [{"head": -6.0}, kn]]
		lhx.expr = "binh"
		dien.go = Vector2(1750, ground_y)
		dien.speed = 240.0
		if dien.pos.x > 1700.0 and t < c7:
			dien.extra = [[SIT_GROUND, 1.0], [{"head": 18.0 + sin(t * 1.5) * 6.0, "torso": 8.0}, 1.0]]
			dien.face = -1.0
			dien.expr = "binh"
	# --- chỗ hở: Điền tỉnh dậy, chém chậm; vòng đỏ hiện trên sườn; một nhát đâm trúng
	if t >= c7:
		var rise := smooth(c7, c7 + 0.6, t)
		dien.go = Vector2(1460, ground_y)
		dien.speed = 300.0
		var poke := bump(c7 + 3.6, c7 + 3.8, c7 + 4.6, c7 + 5.0)
		var slow := smooth(c7 + 1.0, c7 + 3.4, t) * (1.0 - poke)
		var back := smooth(c7 + 3.7, c7 + 4.0, t) * (1.0 - smooth(c8, c8 + 0.3, t))
		dien.extra = [[SIT_GROUND, 1.0 - rise], ["windup", slow], [{"torso": -24.0, "head": -12.0}, back]]
		dien.expr = "soc" if back > 0.2 else "gian"
		lhx.face = 1.0
		lhx.go = Vector2(1180, ground_y)
		lhx.speed = 260.0
		lhx.extra = [["stance", 1.0 - poke], ["point", poke]]
		lhx.expr = "quyet-tam"
		kiem.trail_on = poke > 0.3
	# --- quên kiếm phổ: nhắm mắt, kiếm đi tự do
	if t >= c8 and t < c9:
		var u := fposmod(t - c8, 1.4) / 1.4
		lhx.extra = [["stance", 1.0], ["windup", smooth(0.0, 0.35, u) * (1.0 - smooth(0.4, 0.55, u))], ["slash", smooth(0.4, 0.55, u) * (1.0 - smooth(0.8, 1.0, u))]]
		lhx.expr = "binh"
		kiem.trail_on = true
		dien.extra = [[{"uaF": -40.0, "faF": -110.0, "uaB": -30.0, "faB": -115.0}, 1.0]]
		dien.expr = "soc"
	# --- bước ra khỏi hang: Điền toát mồ hôi
	if t >= c9:
		kiem.trail_on = false
		if _once("ra"):
			lhx.pos = Vector2(MOUTH.x, ground_y)
			lhx.go = Vector2.INF
		lhx.show = smooth(c9, c9 + 0.4, t)
		lhx.go = Vector2(1100, ground_y)
		lhx.speed = 170.0
		lhx.extra = [[{"uaF": 20.0, "faF": -20.0, "head": -4.0}, 1.0]]
		lhx.expr = "binh"
		dien.go = Vector2(1560, ground_y)
		dien.speed = 120.0
		dien.face = -1.0
		var sh := sin(t * 38.0) * 1.5
		dien.extra = [["guard", 0.45], [{"torso": -12.0, "all": [sh, 0.0, 6.0]}, 1.0]]
		dien.expr = "soc"


func _c08() -> Array:
	var c1 := L("k08-01")
	var c2 := L("k08-02")
	var c4 := L("k08-04")
	var c4b := L("k08-04b")
	var c4d := L("k08-04d")
	var c5 := L("k08-05")
	var c7 := L("k08-07")
	var c8 := L("k08-08")
	var c9 := L("k08-09")
	var cp := Vector2(1000, 640)
	var z := 1.0
	if t < c2:
		var k := smooth(c1 + 0.3, c1 + 1.5, t)
		cp = Vector2(1100, 640).lerp(Vector2(760, 660), k)
		z = lerpf(1.0, 1.25, k)
	elif t < c4b - 0.6:
		var k := smooth(c4 - 0.5, c4 + 0.5, t)
		cp = Vector2(800, 650).lerp(Vector2(720, 620), k)
		z = lerpf(1.2, 1.35, k)
	elif t < c4d - 0.6:
		var k := smooth(c4b - 0.8, c4b + 0.8, t)
		cp = Vector2(720, 620).lerp(PEAK + Vector2(0, 140), k)
		z = lerpf(1.35, 1.1, k)
	elif t < c5 - 0.6:
		var k := smooth(c4d - 0.8, c4d + 0.8, t)
		cp = (PEAK + Vector2(0, 140)).lerp(TOMB + Vector2(0, -200), k)
		z = lerpf(1.1, 1.3, k)
	elif t < c7 - 0.4:
		var k := smooth(c5 - 0.8, c5 + 0.4, t)
		cp = (TOMB + Vector2(0, -200)).lerp(SLAB.get_center() + Vector2(-60, 20), k)
		z = lerpf(1.3, 1.5, k)
	elif t < c9:
		var k := smooth(c7 - 0.4, c7 + 0.6, t)
		cp = (SLAB.get_center() + Vector2(-60, 20)).lerp(Vector2(1200, 640), k)
		z = lerpf(1.5, 1.2, k)
		if t > c8:
			cp = cp.lerp(Vector2(1050, 620), smooth(c8, c8 + 1.0, t))
	else:
		var mid: Vector2 = (lhx.pos + dien.pos) * 0.5 + Vector2(0, -230)
		var k := smooth(c9 + 2.2, c9 + 4.2, t)
		cp = Vector2(1300, 620).lerp(mid, smooth(c9, c9 + 1.0, t))
		z = lerpf(1.15, 1.45, k)
	return [cp, z]


func _g08(c: Node2D) -> void:
	# tảng đá của Phong
	var rp := PHONG_ROCK
	var rk := round_pts(PackedVector2Array([rp + Vector2(-120, 0), rp + Vector2(-110, -50), rp + Vector2(-40, -70), rp + Vector2(70, -66), rp + Vector2(120, -30), rp + Vector2(130, 0)]))
	shape(c, rk, ROCK_HI, 4.0)
	hatch(c, rk, 0.9, 14.0, Color(ink, 0.3))
	# phiến đá dựng: chín nét
	var sp := round_pts(PackedVector2Array([SLAB.position + Vector2(0, SLAB.size.y), SLAB.position + Vector2(20, 40), SLAB.position + Vector2(140, -10),
		SLAB.position + Vector2(330, 0), SLAB.end + Vector2(-10, -SLAB.size.y + 50), SLAB.end]), true, 4)
	shape(c, sp, Color("#9aa2b4"), 5.0)
	hatch(c, sp, 1.4, 22.0, Color(ink, 0.18))
	var st := _strokes()
	var tt := _stroke_t()
	var c8 := L("k08-08")
	var forget := smooth(c8 + 0.6, c8 + 3.0, t)
	for i in st.size():
		var t0: float = tt[i]
		var pr := smooth(t0, t0 + 0.35, t)
		if pr <= 0.0:
			continue
		var pts: PackedVector2Array = st[i]
		var fa := 1.0 - forget
		_line_part(c, pts, pr, Color(0.1, 0.1, 0.14, 0.9 * fa), 15.0 if i == 0 else 12.0)
		_line_part(c, pts, pr, Color(Color("#c9c2b0"), 0.5 * fa), 4.0)
	# tuyết phủ lấp nét
	if forget > 0.0:
		c.draw_colored_polygon(sp, Color(SNOW, 0.35 * forget))
	# đỉnh núi xa của Độc Cô Cầu Bại (trên mây)
	var pk := PEAK
	var spire := round_pts(PackedVector2Array([pk + Vector2(-260, 300), pk + Vector2(-120, 40), pk + Vector2(-30, 0), pk + Vector2(40, 10), pk + Vector2(150, 80), pk + Vector2(280, 300)]), true, 4)
	shape(c, spire, Color("#66739a"), 4.0)
	c.draw_colored_polygon(PackedVector2Array([pk + Vector2(-50, 4), pk + Vector2(40, 10), pk + Vector2(70, 34), pk + Vector2(-80, 30)]), Color(SNOW, 0.8))
	for i in 5:
		cloud(c, pk + Vector2(-500 + i * 250, 290 + (i % 2) * 30), 1.4, Color("#c6cfe2"), 3.0)
	_dccb(c, pk + Vector2(0, 6))
	# mộ kiếm
	_mo_kiem(c)


# Độc Cô Cầu Bại: bóng mực đứng một mình, áo choàng bay; người tới thách bị gió kiếm đẩy lùi
func _dccb(c: Node2D, p: Vector2) -> void:
	var col := Color("#0c0e16")
	var wn := sin(t * 3.0) * 10.0
	c.draw_colored_polygon(PackedVector2Array([p + Vector2(-34, 0), p + Vector2(30, 0), p + Vector2(22, -110), p + Vector2(-20, -110)]), col)
	c.draw_colored_polygon(PackedVector2Array([p + Vector2(-20, -104), p + Vector2(-150 - wn, -80), p + Vector2(-110 - wn, -40), p + Vector2(-30, -20)]), col)
	c.draw_circle(p + Vector2(0, -140), 36.0, col)
	c.draw_line(p + Vector2(-20, -60), p + Vector2(50, -170), col, 6.0, true)
	var c4c := L("k08-04c")
	for k in 4:
		var t0 := c4c + 0.5 + k * 0.8
		var e := clampf(t - t0, 0.0, 2.0)
		if t < t0 - 1.2:
			continue
		var sd := -1.0 if k % 2 == 0 else 1.0
		var x := sd * (260.0 - smooth(t0 - 1.2, t0, t) * 120.0 + e * 70.0)
		var q := p + Vector2(x, 60 + k * 14)
		var fc := Color(0.08, 0.09, 0.14, 0.85)
		c.draw_circle(q + Vector2(0, -60), 18.0, fc)
		c.draw_colored_polygon(PackedVector2Array([q + Vector2(-16, 0), q + Vector2(16, 0), q + Vector2(10, -44), q + Vector2(-10, -44)]), fc)
		if e > 0.0 and e < 0.5:
			c.draw_arc(q + Vector2(-sd * 30, -40), 30.0 + e * 80.0, 0.0, TAU, 20, Color(1, 1, 1, 0.6 * (1.0 - e / 0.5)), 3.0, true)


func _mo_kiem(c: Node2D) -> void:
	var p := TOMB
	var mound := round_pts(PackedVector2Array([p + Vector2(-330, 0), p + Vector2(-220, -70), p + Vector2(0, -100), p + Vector2(220, -70), p + Vector2(330, 0)]), true, 4)
	shape(c, mound, Color("#a6acba"), 4.0)
	c.draw_colored_polygon(PackedVector2Array([p + Vector2(-220, -70), p + Vector2(0, -100), p + Vector2(220, -70), p + Vector2(120, -60), p + Vector2(-120, -60)]), Color(SNOW, 0.85))
	var c4e := L("k08-04e")
	var at := [0.6, 1.9, 3.2, 4.6, 5.8]
	for i in 5:
		var x := p.x - 240.0 + i * 120.0
		var base := Vector2(x, p.y - 80.0 + absf(i - 2) * 10.0)
		var t0: float = c4e + float(at[i])
		var up := smooth(t0, t0 + 0.4, t)
		if i == 4:
			c.draw_line(base, base + Vector2(0, -200), Color(1, 1, 1, 0.25 * up), 3.0, true)
			c.draw_line(base + Vector2(-26, -40), base + Vector2(26, -40), Color(1, 1, 1, 0.25 * up), 3.0, true)
			continue
		if up <= 0.0:
			c.draw_rect(Rect2(base + Vector2(-8, -4), Vector2(16, 8)), Color(ink, 0.6))
			continue
		var top := base + Vector2(0, -210.0 * up)
		match i:
			0:
				c.draw_line(base, top, Color("#e8eff7"), 10.0, true)
				c.draw_line(base, top, Color("#9aaabd"), 2.0, true)
			1:
				var pts := PackedVector2Array()
				for k in 9:
					var f := k / 8.0
					pts.append(base.lerp(top, f) + Vector2(sin(f * 7.0 + t * 2.0) * 14.0 * f, 0))
				c.draw_polyline(pts, Color("#d8e0ea"), 7.0, true)
			2:
				c.draw_rect(Rect2(top + Vector2(-16, 0), Vector2(32, base.y - top.y)), Color("#20232c"))
				c.draw_rect(Rect2(top + Vector2(-16, 0), Vector2(32, base.y - top.y)), Color("#3a3e4a"), false, 3.0)
			3:
				c.draw_line(base, top, Color("#a8743e"), 12.0, true)
				c.draw_line(base, top, Color("#c89a62"), 3.0, true)
		c.draw_line(top.lerp(base, 0.0) + Vector2(-24, 40.0 * up) + Vector2(0, (base.y - top.y) * 0.0), top + Vector2(24, 40.0 * up), Color("#d9a43a"), 6.0, true)
	# con điêu đứng trên gò (gợi Thần Điêu)
	var d4 := L("k08-04d")
	var ea := smooth(d4 + 1.0, d4 + 1.6, t)
	if ea > 0.0:
		var e := p + Vector2(230, -110)
		var col := Color(0.2, 0.15, 0.12, ea)
		c.draw_colored_polygon(PackedVector2Array([e + Vector2(-26, 0), e + Vector2(30, 0), e + Vector2(20, -70), e + Vector2(-20, -66)]), col)
		c.draw_circle(e + Vector2(10, -84), 18.0, col)
		c.draw_colored_polygon(PackedVector2Array([e + Vector2(26, -86), e + Vector2(46, -78), e + Vector2(26, -76)]), Color(0.9, 0.7, 0.2, ea))


func _n08(c: Node2D) -> void:
	# sương mù quanh chỗ Phong hiện ra
	var c1 := L("k08-01")
	var ms := bump(c1 + 0.2, c1 + 0.8, c1 + 2.0, c1 + 3.2)
	if ms > 0.01:
		for k in 5:
			var p := Vector2(470 + sin(k * 2.1 + t) * 90.0, ground_y - 40 - k * 50)
			blob(c, p, 120.0, Color(0.85, 0.9, 1.0, 0.35 * ms))
	# vòng đỏ: chỗ hở trên sườn Điền
	var c7 := L("k08-07")
	var rg := bump(c7 + 2.4, c7 + 2.7, c7 + 4.0, c7 + 4.3)
	if rg > 0.01:
		var p := body_w(dien, Vector2(-20, -80))
		c.draw_arc(p, 40.0 + sin(t * 10.0) * 4.0, 0.0, TAU, 28, Color(Color("#ff4a3a"), rg), 6.0, true)
		c.draw_arc(p, 14.0, 0.0, TAU, 16, Color(Color("#ff4a3a"), rg), 4.0, true)
	# mồ hôi Điền
	var c9 := L("k08-09")
	if t > c9 + 0.8:
		var hp := head_of(dien)
		for k in 5:
			var ph := fmod(t * 0.8 + k * 0.29, 1.0)
			var p := hp + Vector2(-50.0 + k * 26.0, -30.0 + ph * 110.0)
			c.draw_circle(p, 7.0, Color(Color("#9fd4ff"), 1.0 - ph), true, -1.0, true)


func _gl08(c: Node2D) -> void:
	var c1 := L("k08-01")
	var sk := bump(c1 + 0.4, c1 + 0.6, c1 + 1.3, c1 + 1.8)
	if sk > 0.01:
		for k in 6:
			var p := Vector2(470, ground_y - 160) + Vector2.from_angle(k * 1.05 + t) * (60.0 + k * 12.0)
			c.draw_line(p - Vector2(12, 0), p + Vector2(12, 0), Color(1.6, 1.6, 1.8, sk), 3.0, true)
			c.draw_line(p - Vector2(0, 12), p + Vector2(0, 12), Color(1.6, 1.6, 1.8, sk), 3.0, true)
	# nét khí Phong vẽ trên không
	var c4 := L("k08-04")
	var tr := bump(c4 + 0.6, c4 + 1.0, c4 + 4.4, c4 + 5.0)
	if tr > 0.01:
		var pts := PackedVector2Array()
		var pr := smooth(c4 + 0.8, c4 + 4.0, t)
		for i in 40:
			var f := i / 39.0 * pr
			pts.append(PHONG_ROCK + Vector2(160 + f * 300.0, -240 + sin(f * 9.0) * 70.0 - f * 60.0))
		if pts.size() > 1:
			c.draw_polyline(pts, Color(1.3, 1.25, 1.0, 0.6 * tr), 6.0, true)
	# nét khắc mới: sáng vàng rồi nguội
	var st := _strokes()
	var tt := _stroke_t()
	for i in st.size():
		var t0: float = tt[i]
		var hot := bump(t0, t0 + 0.1, t0 + 0.35, t0 + 1.0)
		if hot > 0.01:
			var pts: PackedVector2Array = st[i]
			var e := _line_part(c, pts, smooth(t0, t0 + 0.35, t), Color(1.6, 1.2, 0.5, 0.8 * hot), 8.0)
			blob(c, e, 70.0, Color(1.4, 1.0, 0.4, 0.5 * hot))


# ================================================================ k10: lửa trại sau trận, cụng hồ lô

const FIRE := Vector2(990, 872)
const CLINK := Vector2(1000, 700)


func _curve_pts() -> PackedVector2Array:
	var o := PackedVector2Array()
	for i in 60:
		var f := i / 59.0
		o.append(Vector2(1180 + f * 420.0, 950 + sin(f * 11.0) * 30.0 + sin(f * 4.0) * 18.0))
	return o


func _s10(_dt: float) -> void:
	var d1 := L("k10-01")
	var d2 := L("k10-02")
	var d2b := L("k10-02b")
	var d3 := L("k10-03")
	var d4 := L("k10-04")
	var d5 := L("k10-05")
	var d6 := L("k10-06")
	var d7 := L("k10-07")
	var d8 := L("k10-08")
	var d9 := L("k10-09")
	# --- Điền ngồi bệt nhìn thanh đao
	var dt_: Node2D = dien.node.J["torso"]
	var look := 1.0 - smooth(d2 + 0.2, d2 + 0.6, t)
	dien.hold["F"] = [Vector2(70, -150), look]
	dao.lock = look
	dao.lockdir = Vector2(0.2, -1.0).normalized()
	if t > d2 + 0.5 and _once("dat-dao"):
		prop_to(dao, "dat")
		dao.node.position = Vector2(1330, ground_y - 6)
		dao.sheath = Vector2(1.0, 0.05).normalized()
	var laugh := bump(d2 + 0.4, d2 + 0.8, d2 + 3.2, d2 + 3.6)
	var s15 := sin(t * 15.0)
	dien.extra = [[SIT_GROUND, 1.0], [{"head": 10.0 * look - 8.0 * laugh + s15 * 4.0 * laugh, "torso": 6.0 * look + s15 * 3.0 * laugh}, 1.0]]
	dien.expr = "soc" if t < d2 else ("vui" if t < d2b + 1.5 else "ngai")
	# --- Lệnh Hồ Xung tra kiếm, ngồi xuống; nhóm lửa
	if t > d1 + 3.0 and _once("tra"):
		prop_to(kiem, "hong", "F")
	if t > d2 + 0.8 and t < d7:
		lhx.go = Vector2(820, ground_y)
		lhx.speed = 200.0
	var sit := smooth(d2 + 1.9, d2 + 2.4, t) * (1.0 - smooth(d7 + 0.5, d7 + 1.0, t))
	lhx.extra = [[SIT_GROUND, sit]]
	lhx.expr = "vui"
	# cụng hồ lô
	if t > d2 + 2.4 and _once("holo"):
		prop_to(ho_l, "tay", "F")
		prop_to(ho_d, "tay", "F")
	var ck := bump(d2 + 2.8, d2 + 3.5, d2 + 4.4, d2 + 4.9)
	if t > d2 + 2.4:
		var lt: Node2D = lhx.node.J["torso"]
		lhx.hold["F"] = [from_w(lt, CLINK + Vector2(-30, 40)).lerp(Vector2(60, -40), 1.0 - ck), 1.0]
		dien.hold["F"] = [from_w(dt_, CLINK + Vector2(30, 40)).lerp(Vector2(60, -40), 1.0 - ck), 1.0]
		ho_l.lock = 1.0
		ho_d.lock = 1.0
		ho_l.lockdir = Vector2(0.4, 1.0).normalized()
		ho_d.lockdir = Vector2(-0.4, 1.0).normalized()
	# --- Bất Giới tới cạo đầu
	if t > d2b - 0.6 and t < LE("k10-02b") - 0.4:
		bg.go = Vector2(1340, ground_y)
		bg.speed = 380.0
	elif t >= LE("k10-02b") - 0.4:
		bg.go = Vector2(2500, ground_y)
		bg.speed = 340.0
	var shave := smooth(d2b + 1.6, d2b + 2.0, t) * (1.0 - smooth(LE("k10-02b") - 0.8, LE("k10-02b") - 0.4, t))
	var bt: Node2D = bg.node.J["torso"]
	bg.hold["F"] = [from_w(bt, head_of(dien) + Vector2(10, -60) + Vector2(sin(t * 12.0) * 14.0, 0)), shave]
	bg.expr = "vui"
	if t > d2b + 1.0 and t < LE("k10-02b"):
		bg.face = -1.0
		lhx.extra.append([{"head": s15 * 4.0, "torso": -8.0 + s15 * 3.0}, bump(d2b + 2.0, d2b + 2.4, d2b + 6.0, d2b + 6.5)])
	# --- vẽ lên tuyết: chấm kiếm khí; nhún vai; uống
	var shrug := bump(d4 + 0.3, d4 + 0.6, d4 + 1.6, d4 + 1.9)
	var drink := bump(d4 + 2.4, d4 + 2.9, d4 + 4.4, d4 + 4.8) + bump(d6 + 1.0, d6 + 1.5, d6 + 3.2, d6 + 3.6)
	lhx.extra.append([{"uaF": -60.0, "faF": -100.0, "uaB": -60.0, "faB": -100.0, "head": 8.0}, shrug])
	if drink > 0.01:
		var hd: Vector2 = to_w(lhx.node.J["head"], Vector2(10, -30))
		var lt2: Node2D = lhx.node.J["torso"]
		lhx.hold["F"] = [from_w(lt2, hd + Vector2(16, 0)), drink]
		ho_l.lockdir = Vector2(0.4, 1.0).normalized().lerp(Vector2(0.7, -0.7), drink).normalized()
		lhx.extra.append([{"head": -18.0}, drink])
	var flick := bump(d3 + 0.2, d3 + 0.5, d3 + 4.3, d3 + 4.7) + bump(d5 + 2.6, d5 + 2.9, d5 + 4.2, d5 + 4.6)
	lhx.extra.append([{"uaB": -70.0, "faB": -10.0}, flick])
	# --- Linh San lên núi, ngoái nhìn đường xuống
	if t > d7 - 0.4 and t < LE("k10-07") - 0.6:
		ls.go = Vector2(400, ground_y)
		ls.speed = 240.0
	elif t >= LE("k10-07") - 0.6:
		ls.go = Vector2(-500, ground_y)
		ls.speed = 260.0
	ls.hold = {"F": [Vector2(40, -20), 1.0]}
	var turn := smooth(d7 + 2.6, d7 + 3.0, t)
	if ls.go == Vector2.INF and t > d7 + 2.6:
		ls.face = -1.0
	ls.expr = "vui" if turn < 0.5 else "binh"
	if t > d7 + 2.8 and t < d8:
		lhx.expr = "buon"
		lhx.face = -1.0
	if t > d7 + 1.0 and t < d8:
		lhx.go = Vector2(760, ground_y)
		lhx.speed = 160.0
	# --- CTA: nâng hồ lô mời khách; Điền ngủ gật
	if t > d8:
		lhx.face = 1.0
		lhx.go = Vector2(820, ground_y)
		lhx.speed = 160.0
		var sit2 := smooth(d8 + 0.6, d8 + 1.2, t)
		lhx.extra = [[SIT_GROUND, sit2]]
		var toast := bump(d8 + 1.4, d8 + 1.9, d9 + 3.0, d9 + 3.5)
		var lt3: Node2D = lhx.node.J["torso"]
		lhx.hold["F"] = [Vector2(80, -170).lerp(Vector2(60, -40), 1.0 - toast), maxf(toast, 0.6)]
		ho_l.lockdir = Vector2(0.2, 1.0).normalized()
		lhx.expr = "vui"
		dien.extra = [[SIT_GROUND, 1.0], [{"head": 20.0 + sin(t * 1.3) * 6.0, "torso": 10.0}, 1.0]]
		dien.hold["F"] = [Vector2(60, -40), 1.0]
		dien.expr = "binh"
		if lt3 == null:
			pass


func _c10() -> Array:
	var d2 := L("k10-02")
	var d2b := L("k10-02b")
	var d3 := L("k10-03")
	var d5 := L("k10-05")
	var d6 := L("k10-06")
	var d7 := L("k10-07")
	var d8 := L("k10-08")
	if t < d2:
		return [Vector2(1080, 700).lerp(Vector2(1120, 680), smooth(0.0, 5.0, t)), 1.45]
	if t < d2b - 0.5:
		var k := smooth(d2 + 2.4, d2 + 3.5, t)
		return [Vector2(1060, 680).lerp(CLINK + Vector2(0, 40), k), lerpf(1.2, 1.6, k)]
	if t < d3 - 0.4:
		return [Vector2(1160, 660), 1.15]
	if t < d6 - 0.4:
		var k := smooth(d3 - 0.4, d3 + 0.8, t)
		var k5 := smooth(d5 - 0.3, d5 + 0.8, t)
		return [Vector2(1160, 660).lerp(Vector2(1080, 800), k).lerp(Vector2(980, 820), k5), lerpf(1.15, 1.3, k)]
	if t < d7:
		var k := smooth(d6 - 0.4, d6 + 4.0, t)
		return [Vector2(980, 800).lerp(Vector2(1000, 520), k), lerpf(1.3, 0.85, k)]
	if t < d8:
		var k := smooth(d7, d7 + 1.4, t)
		return [Vector2(1000, 520).lerp(Vector2(700, 640), k), lerpf(0.85, 1.2, k)]
	var k2 := smooth(d8, d8 + 1.4, t)
	return [Vector2(700, 640).lerp(Vector2(1330, 560), k2), lerpf(1.2, 1.0, k2)]


func _fire() -> float:
	return smooth(L("k10-02") + 1.8, L("k10-02") + 2.8, t)


func _g10(c: Node2D) -> void:
	# lõm tuyết chỗ Điền ngã
	flat_blob(c, Vector2(1160, ground_y + 6), 170.0, 0.18, Color(SNOW_SH, 0.7))
	# củi
	for k in 3:
		var a := -0.5 + k * 0.5
		c.draw_line(FIRE + Vector2.from_angle(a + PI) * 50.0 + Vector2(0, 6), FIRE + Vector2.from_angle(a) * 50.0, Color("#4a2e1a"), 12.0, true)
	# hai hình vẽ trên tuyết: lưới vuông ngay hàng (sống đúng bài) và đường cong tự do (quên bài)
	var d3 := L("k10-03")
	var d5 := L("k10-05")
	var pr := smooth(d3 + 0.5, d3 + 4.4, t)
	if pr > 0.0:
		var pts := _curve_pts()
		_line_part(c, pts, pr, Color("#7d8fae"), 9.0)
		_line_part(c, pts, pr, Color(1, 1, 1, 0.6), 3.0)
	for i in 12:
		var g := smooth(d5 + 0.2 + i * 0.14, d5 + 0.4 + i * 0.14, t)
		if g <= 0.0:
			continue
		var p := Vector2(560 + (i % 6) * 66.0, 905 + (i / 6) * 60.0)
		c.draw_rect(Rect2(p, Vector2(52, 44) * g), Color("#7d8fae"), false, 6.0)


func _n10(c: Node2D) -> void:
	var f := _fire()
	if f > 0.01:
		for k in 4:
			var h := (90.0 + sin(t * 9.0 + k * 1.7) * 20.0) * f * (1.0 - k * 0.18)
			var x := FIRE.x - 30.0 + k * 20.0
			shape(c, round_pts(PackedVector2Array([Vector2(x - 22, FIRE.y), Vector2(x + sin(t * 7.0 + k) * 10.0, FIRE.y - h), Vector2(x + 22, FIRE.y)]), true, 3),
				Color("#ff9a2e").lerp(Color("#ffe07a"), k * 0.25), 0.0)
	# tóc rơi khi Bất Giới cạo
	var d2b := L("k10-02b")
	if t > d2b + 2.0 and t < LE("k10-02b"):
		var hp := head_of(dien)
		for k in 10:
			var ph := fmod(t * 0.7 + k * 0.13, 1.0)
			var p := hp + Vector2(-60.0 + k * 13.0 + sin(ph * 6.0 + k) * 10.0, -60.0 + ph * 200.0)
			c.draw_line(p, p + Vector2(8, 5), Color(0.1, 0.08, 0.08, 1.0 - ph), 3.0, true)
		# dao cạo
		var hd: Vector2 = to_w(bg.node.J["hdF"], Vector2(0, 0))
		c.draw_rect(Rect2(hd + Vector2(-4, -30), Vector2(8, 30)), Color("#5a3a22"))
		c.draw_rect(Rect2(hd + Vector2(-14, -48), Vector2(28, 18)), Color("#dfe4e8"))
	# hơi rượu ấm bốc lên
	var d6 := L("k10-06")
	var st := smooth(d6, d6 + 1.0, t)
	if st > 0.01:
		for v: Dictionary in [ho_l, ho_d]:
			var mw: Vector2 = v.get("mouthw", Vector2.ZERO)
			if mw == Vector2.ZERO:
				continue
			for k in 3:
				var ph := fmod(t * 0.5 + k * 0.33, 1.0)
				var p := mw + Vector2(sin(ph * 6.0 + k) * 12.0, -ph * 90.0)
				c.draw_circle(p, 8.0 + ph * 14.0, Color(1, 1, 1, 0.25 * st * (1.0 - ph)), true, -1.0, true)


func _gl10(c: Node2D) -> void:
	var f := _fire()
	if f > 0.01:
		var fl := 0.9 + 0.1 * sin(t * 11.0) * sin(t * 6.3)
		blob(c, FIRE + Vector2(0, -50), 520.0 * fl * f, Color(1.0, 0.55, 0.25, 0.22))
		blob(c, FIRE + Vector2(0, -40), 140.0 * f, Color(1.3, 0.8, 0.4, 0.4))
		flat_blob(c, FIRE + Vector2(0, 8), 420.0 * f, 0.2, Color(1.0, 0.6, 0.3, 0.35))
	# lóe sáng khi hai hồ lô chạm
	var d2 := L("k10-02")
	var e := t - (d2 + 3.5)
	if e > 0.0 and e < 0.5:
		var k := 1.0 - e / 0.5
		rays(c, CLINK + Vector2(0, 40), 0.0, TAU, 10, 160.0 * k + 30.0, Color(1.5, 1.3, 0.8, 0.9 * k))
		blob(c, CLINK + Vector2(0, 40), 120.0, Color(1.3, 1.1, 0.7, 0.5 * k))
	# chấm kiếm khí vẽ đường cong
	var d3 := L("k10-03")
	var pr := smooth(d3 + 0.5, d3 + 4.4, t)
	if pr > 0.0 and pr < 1.0:
		var pts := _curve_pts()
		var u := pr * (pts.size() - 1)
		var p := pts[int(u)].lerp(pts[mini(int(u) + 1, pts.size() - 1)], u - int(u))
		blob(c, p, 50.0, Color(1.2, 1.3, 1.6, 0.6))
		c.draw_circle(p, 6.0, Color(1.6, 1.7, 2.0), true, -1.0, true)
