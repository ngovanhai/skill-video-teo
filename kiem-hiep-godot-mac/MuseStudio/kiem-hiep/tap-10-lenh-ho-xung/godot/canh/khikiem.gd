extends "res://canh.gd"
# k04 — sân khấu tách đôi. Trái: Khí tông (ngọc bích, đồng hồ cát, ngồi thở). Phải: Kiếm tông (hổ phách, mũi kiếm khổng lồ).
# Vết sẹo nứt giữa sân khấu; trận đấu ở đường chia; phe kiếm bị đẩy lùi ra cánh gà; năm tấm núi; đèn rọi ông già phe thua.

const GY := 880.0
const STG := Rect2(150, 110, 1620, 770)   # khung phông sau
var m := ""
var nhac: Dictionary
var phong: Dictionary
var lhx: Dictionary
var kiem: Dictionary
var kiem_at := "tay"
const SPLIT0 := 960.0


func _palette() -> void:
	m = arg.get("m", "")
	ground_y = GY
	sky_top = Color("#1a1216")
	sky_bot = Color("#2e1e1c")
	haze = Color("#3a2a26")
	char_tint = Color(1.0, 0.97, 0.92)
	wind_base = 0.0
	wind_gust = 0.1
	vign_a = 0.42


func _build() -> void:
	nhac = actor("nhac-bat-quan", Vector2(620, GY), 1.0)
	phong = actor("phong-thanh-duong", Vector2(1330, GY), -1.0)
	phong.tint = Color(0.16, 0.12, 0.13)
	kiem = prop(phong, "kiem", "tay", "F")
	lhx = actor("lenh-ho-xung", Vector2(820, GY), -1.0)
	lhx.size = 0.82


# ---------------------------------------------------------------- nhịp

func _split() -> float:
	return lerpf(SPLIT0, 1640.0, smooth(L("k04-06") - 0.2, L("k04-06") + 1.4, t))


func _lit_l() -> float:
	var a := smooth(L("k04-02"), L("k04-02") + 0.7, t)
	return a * (1.0 - 0.75 * bump(L("k04-06b") - 0.3, L("k04-06b") + 0.4, LE("k04-06b"), LE("k04-06b") + 0.5)) * (1.0 - 0.8 * smooth(L("k04-07") - 0.2, L("k04-07") + 0.8, t))


func _lit_r() -> float:
	var a := smooth(L("k04-03"), L("k04-03") + 0.7, t)
	a *= 1.0 - 0.7 * smooth(L("k04-05") + 1.0, L("k04-05") + 2.2, t)
	return a * (1.0 - smooth(L("k04-06b") - 0.3, L("k04-06b") + 0.4, t))


func _clashes() -> Array:
	var l4 := L("k04-04")
	return [l4 + 2.4, l4 + 3.1, l4 + 3.8, L("k04-05") + 0.5]


func _story(dt: float) -> void:
	if t < 0.0:
		return
	var l2 := L("k04-02")
	var l3 := L("k04-03")
	var l4 := L("k04-04")
	var l5 := L("k04-05")
	var l6 := L("k04-06")
	var l6b := L("k04-06b")
	var l7 := L("k04-07")
	nhac.hold = {}
	phong.hold = {}
	nhac.inplace = 0.0
	phong.inplace = 0.0
	lhx.inplace = 0.0
	nhac.talk = 0.0
	phong.talk = 0.0
	# --- Khí tông: ngồi xếp bằng thở trước đồng hồ cát
	nhac.show = smooth(l2 + 0.2, l2 + 0.8, t) * (1.0 - smooth(l6b - 0.3, l6b + 0.2, t))
	phong.show = smooth(l3 + 0.2, l3 + 0.8, t) * (1.0 - smooth(l5 + 4.0, l5 + 4.6, t))
	lhx.show = smooth(l6 + 0.8, l6 + 1.4, t) * (1.0 - smooth(l6b - 0.3, l6b + 0.2, t))
	if t >= l7:
		phong.show = smooth(l7 + 0.6, l7 + 1.6, t)
		lhx.show = smooth(l7 + 0.2, l7 + 0.8, t)
	var br := sin((t - l2) * 1.6)
	if t < l4:
		nhac.pos = Vector2(620, GY)
		nhac.face = 1.0
		nhac.extra = [[NGOI_XEP_BANG, 1.0], [{"uaF": -10.0, "faF": -110.0, "uaB": -14.0, "faB": -110.0, "head": 4.0 - br * 3.0, "torso": -br * 2.0}, 1.0]]
		nhac.expr = "binh"
	elif t < l5:
		# hai phe cãi nhau, rồi bước ra đường chia giao đấu
		var up := smooth(l4 + 0.1, l4 + 0.6, t)
		_di(nhac, Vector2(620, GY), Vector2(800, GY), l4 + 0.6, l4 + 1.8)
		nhac.face = 1.0
		var arg2 := bump(l4 + 0.4, l4 + 0.7, l4 + 1.6, l4 + 1.9)
		var fight := smooth(l4 + 1.8, l4 + 2.2, t)
		var pulse := 0.0
		for ct: float in _clashes():
			pulse = maxf(pulse, bump(ct - 0.25, ct - 0.05, ct + 0.05, ct + 0.3))
		nhac.extra = [[NGOI_XEP_BANG, 1.0 - up], ["stance", fight], ["point", arg2], [arms_of("palm"), fight * (0.4 + 0.6 * pulse)]]
		nhac.talk = arg2
		nhac.expr = "gian" if arg2 > 0.3 else "quyet-tam"
	elif t < l6:
		# chưởng đẩy: phe kiếm bật lùi
		nhac.pos = Vector2(800, GY)
		nhac.face = 1.0
		var push := bump(l5 + 0.2, l5 + 0.5, l5 + 1.4, l5 + 2.0)
		nhac.extra = [["stance", 1.0 - smooth(l5 + 2.0, l5 + 2.8, t)], ["palm", push], [{"torso": 8.0 * push}, 1.0]]
		nhac.expr = "quyet-tam" if push > 0.3 else "dac-y"
	else:
		# thầy dạy trò: ngồi thở trước, nội công làm gốc
		_di(nhac, Vector2(800, GY), Vector2(560, GY), l6 - 0.4, l6 + 0.8)
		if t >= l6 + 0.8:
			nhac.face = 1.0
		var dem := smooth(l6 + 1.0, l6 + 1.4, t)
		nhac.extra = [[{"uaF": -100.0, "faF": -30.0, "head": 8.0}, dem * (0.6 + 0.4 * sin(t * 2.0))], [{"uaB": -150.0, "faB": -60.0}, dem]]
		nhac.talk = dem
		nhac.expr = "dac-y"
	# --- Kiếm tông: bóng đen múa kiếm, mũi kiếm vẽ vệt
	if t < l4:
		phong.pos = Vector2(1330, GY)
		phong.face = -1.0
		var ph := (t - l3) * 2.4
		var s1 := maxf(0.0, sin(ph))
		var s2 := maxf(0.0, -sin(ph))
		phong.extra = [["stance", 1.0], [arms_of("slash"), s1], [arms_of("windup"), s2]]
		kiem.trail_on = s1 > 0.4 and t > l3
	elif t < l5:
		_di(phong, Vector2(1330, GY), Vector2(1120, GY), l4 + 0.6, l4 + 1.8)
		phong.face = -1.0
		var arg3 := bump(l4 + 0.2, l4 + 0.5, l4 + 1.3, l4 + 1.6)
		var pulse2 := 0.0
		for ct: float in _clashes():
			pulse2 = maxf(pulse2, bump(ct - 0.3, ct - 0.08, ct + 0.02, ct + 0.3))
		var fight2 := smooth(l4 + 1.8, l4 + 2.2, t)
		phong.extra = [["stance", 1.0], ["point", arg3], [arms_of("windup"), fight2 * (1.0 - pulse2)], [arms_of("slash"), fight2 * pulse2]]
		phong.talk = arg3
		kiem.trail_on = pulse2 > 0.3
	else:
		# bị đẩy lùi, chống kiếm đứng lại, rồi quay đi về cánh gà — không gục
		var e := t - (l5 + 0.5)
		var back := 1.0 - exp(-4.0 * maxf(e, 0.0))
		var x := 1120.0 + 300.0 * back if e > 0.0 else 1120.0
		var leave := smooth(l5 + 2.4, l5 + 4.6, t)
		phong.pos = Vector2(lerpf(x, 2150.0, leave), GY)
		phong.face = -1.0 if t < l5 + 2.4 else 1.0
		phong.inplace = 160.0 if t > l5 + 2.4 and t < l5 + 4.6 else 0.0
		var reel := bump(l5 + 0.45, l5 + 0.6, l5 + 1.0, l5 + 1.8)
		phong.extra = [["stance", 1.0 - leave], ["guard", reel], [{"torso": -22.0 * reel, "head": -16.0 * reel}, 1.0], [{"head": 14.0}, leave]]
		kiem.trail_on = false
	if not kiem.trail_on:
		kiem.trail.clear()
	if t >= l7:
		# ông già phe thua đứng trong vệt đèn, kiếm sau lưng, tay chắp sau
		if kiem_at != "lung":
			kiem_at = "lung"
			prop_to(kiem, "lung", "F")
		phong.pos = Vector2(1420, GY)
		phong.face = -1.0
		phong.inplace = 0.0
		phong.tint = Color(0.2, 0.17, 0.18).lerp(Color(0.5, 0.45, 0.42), smooth(l7 + 2.6, l7 + 4.0, t))
		phong.extra = [[{"uaF": 30.0, "faF": 40.0, "uaB": 34.0, "faB": 44.0, "torso": 10.0, "head": 6.0}, 1.0]]
	# --- trò nhỏ ngồi thở theo thầy; cuối cảnh đứng nhìn về phía vệt đèn
	if t < l6b:
		lhx.pos = Vector2(820, GY)
		lhx.face = -1.0
		var fol := smooth(l6 + 1.8, l6 + 2.6, t)
		lhx.extra = [[NGOI_XEP_BANG, 1.0], [{"uaF": -10.0, "faF": -110.0, "uaB": -14.0, "faB": -110.0}, fol], [{"head": -10.0 + sin(t * 3.0) * 6.0 * (1.0 - fol)}, 1.0]]
		lhx.expr = "ngai" if fol < 0.5 else "binh"
	else:
		lhx.pos = Vector2(560, GY)
		lhx.face = 1.0
		lhx.size = 0.9
		lhx.extra = [[{"head": -4.0}, 1.0]]
		lhx.expr = "ngai" if t < l7 + 3.0 else "soc"


func _di(a: Dictionary, p0: Vector2, p1: Vector2, t0: float, t1: float) -> void:
	var k := clampf((t - t0) / maxf(t1 - t0, 0.01), 0.0, 1.0)
	a.pos = p0.lerp(p1, k)
	var moving := t > t0 and t < t1
	a.inplace = (p1 - p0).length() / maxf(t1 - t0, 0.01) if moving else 0.0
	if moving and absf(p1.x - p0.x) > 1.0:
		a.face = signf(p1.x - p0.x)


func _cam() -> Array:
	var keys := [[0.0, Vector2(960, 500), 1.0],
		[L("k04-01") + 0.5, Vector2(960, 520), 1.06, 3.0],
		[L("k04-02"), Vector2(700, 560), 1.18, 1.0],
		[L("k04-03"), Vector2(1220, 560), 1.18, 1.0],
		[L("k04-04"), Vector2(960, 560), 1.12, 1.0],
		[L("k04-04") + 2.0, Vector2(960, 600), 1.32, 0.6],
		[L("k04-05") + 1.0, Vector2(1060, 560), 1.08, 1.0],
		[L("k04-06"), Vector2(860, 590), 1.2, 1.2],
		[L("k04-06b"), Vector2(960, 520), 1.0, 1.0],
		[L("k04-07"), Vector2(1050, 600), 1.15, 0.8],
		[L("k04-07") + 2.5, Vector2(1300, 640), 1.42, 3.0]]
	var p: Vector2 = keys[0][1]
	var z: float = keys[0][2]
	for k in keys:
		var kt: float = k[0]
		var bl: float = k[3] if k.size() > 3 else 1.0
		var w := smooth(kt, kt + bl, t)
		var kp: Vector2 = k[1]
		var kz: float = k[2]
		p = p.lerp(kp, w)
		z = lerpf(z, kz, w)
	var big := L("k04-05") + 0.5
	var e := t - big
	if e > 0.0 and e < 0.7:
		p += Vector2(sin(t * 80.0), cos(t * 61.0)) * 14.0 * exp(-6.0 * e)
	return [p, z]


# ---------------------------------------------------------------- vẽ sân khấu

func _ground(c: Node2D) -> void:
	var sx := _split()
	var ll := _lit_l()
	var lr := _lit_r()
	# phông chung: núi in mộc bản mờ
	var bg := PackedVector2Array([STG.position, Vector2(STG.end.x, STG.position.y), STG.end, Vector2(STG.position.x, STG.end.y)])
	c.draw_colored_polygon(bg, Color("#4a3a30"))
	_nui_phong(c, Color("#5c4a3c"), 0.0)
	# nửa trái ngọc bích
	var lpoly := PackedVector2Array([STG.position, Vector2(sx, STG.position.y), Vector2(sx, STG.end.y), Vector2(STG.position.x, STG.end.y)])
	c.draw_colored_polygon(lpoly, Color(Color("#2f6a62"), ll))
	if ll > 0.01:
		var ctr := Vector2(620, 600)
		for i in 7:
			var r := fmod((t - L("k04-02")) * 40.0 + i * 70.0, 490.0)
			c.draw_arc(ctr, r, 0.0, TAU, 64, Color(Color("#a8e0cc"), ll * 0.35 * (1.0 - r / 490.0)), 4.0)
		hatch(c, lpoly, 0.8, 30.0, Color(Color("#1e4a44"), 0.4 * ll))
	# nửa phải hổ phách
	var rpoly := PackedVector2Array([Vector2(sx, STG.position.y), Vector2(STG.end.x, STG.position.y), STG.end, Vector2(sx, STG.end.y)])
	c.draw_colored_polygon(rpoly, Color(Color("#b0582a"), lr))
	if lr > 0.01:
		var rr := RandomNumberGenerator.new()
		rr.seed = 12
		for i in 9:
			var y0 := rr.randf_range(160, 820)
			var x0 := sx + rr.randf_range(40, 700)
			cut(c, Vector2(x0, y0), Vector2(x0 + 180, y0 - 90), 5.0, Color(Color("#f0b060"), 0.4 * lr))
		hatch(c, rpoly, -0.8, 30.0, Color(Color("#6a2a14"), 0.4 * lr))
	# vết sẹo nứt giữa phông
	_seo(c, sx)
	_dong_ho_cat(c, Vector2(330, GY), ll)
	_mui_kiem(c, lr)
	# sàn gỗ
	var fl := PackedVector2Array([Vector2(60, GY - 4), Vector2(1860, GY - 4), Vector2(2100, 1200), Vector2(-180, 1200)])
	c.draw_colored_polygon(fl, Color("#6a4628"))
	for i in 14:
		var x := 60.0 + i * 138.0
		c.draw_line(Vector2(x, GY - 4), Vector2(lerpf(-180, 2100, i / 13.0), 1200), Color(ink, 0.35), 3.0)
	c.draw_line(Vector2(60, GY - 4), Vector2(1860, GY - 4), inkof(Color("#6a4628")), 5.0)
	# nửa sàn trái/phải nhuốm màu đèn
	c.draw_colored_polygon(PackedVector2Array([Vector2(60, GY - 4), Vector2(sx, GY - 4), Vector2(sx, 1200), Vector2(-180, 1200)]), Color(Color("#3a8a7a"), 0.18 * ll))
	c.draw_colored_polygon(PackedVector2Array([Vector2(sx, GY - 4), Vector2(1860, GY - 4), Vector2(2100, 1200), Vector2(sx, 1200)]), Color(Color("#e08040"), 0.18 * lr))
	_the_nui(c)


func _nui_phong(c: Node2D, col: Color, _a: float) -> void:
	var pts := PackedVector2Array([Vector2(STG.position.x, 700), Vector2(380, 420), Vector2(520, 520), Vector2(760, 260), Vector2(960, 200), Vector2(1160, 300), Vector2(1380, 480), Vector2(1560, 360), Vector2(STG.end.x, 640), STG.end, Vector2(STG.position.x, STG.end.y)])
	shape(c, pts, col, 3.0, Color(ink, 0.4))


func _seo(c: Node2D, sx: float) -> void:
	var k := smooth(L("k04-01") + 0.6, L("k04-01") + 2.6, t)
	if k <= 0.0:
		return
	var rr := RandomNumberGenerator.new()
	rr.seed = 44
	var pts := PackedVector2Array()
	var n := 18
	for i in n + 1:
		var y := lerpf(STG.position.y, GY, float(i) / n)
		if float(i) / n > k:
			break
		pts.append(Vector2(sx + rr.randf_range(-22, 22) * (1.0 if i % 2 == 0 else -1.0), y))
	if pts.size() >= 2:
		c.draw_polyline(pts, Color("#1a0e0a"), 12.0)
		c.draw_polyline(pts, Color("#d8463a"), 4.0)


func _dong_ho_cat(c: Node2D, base: Vector2, a: float) -> void:
	if a <= 0.01:
		return
	var rise := smooth(L("k04-02") + 0.2, L("k04-02") + 1.2, t)
	var b := base + Vector2(0, (1.0 - rise) * 520.0)
	var ht := 470.0
	var wd := 150.0
	var top := b.y - ht
	var mid := Vector2(b.x, b.y - ht * 0.5)
	var wood := Color(Color("#5a3a22"), a)
	# cát chảy theo thời gian của cả cảnh
	var k := clampf((t - L("k04-02")) / (LE("k04-06") - L("k04-02")), 0.0, 1.0)
	var sand := Color(Color("#f0d080"), a)
	var tl := lerpf(0.0, 1.0, 1.0 - k)
	var up := PackedVector2Array([mid + Vector2(-wd * tl, -ht * 0.45 * tl), mid + Vector2(wd * tl, -ht * 0.45 * tl), mid])
	if tl > 0.02:
		c.draw_colored_polygon(up, sand)
	var bl := k
	var dn := PackedVector2Array([Vector2(b.x - wd, b.y - 14), Vector2(b.x + wd, b.y - 14), Vector2(b.x + wd * (1.0 - bl * 0.7), b.y - 14 - ht * 0.42 * bl), Vector2(b.x - wd * (1.0 - bl * 0.7), b.y - 14 - ht * 0.42 * bl)])
	if bl > 0.02:
		c.draw_colored_polygon(dn, sand)
	if tl > 0.02:
		c.draw_line(mid, Vector2(b.x, b.y - 14 - ht * 0.42 * bl), sand, 4.0)
	# thuỷ tinh
	var glass := PackedVector2Array([Vector2(b.x - wd, top + 14), Vector2(b.x + wd, top + 14), mid + Vector2(10, 0), Vector2(b.x + wd, b.y - 14), Vector2(b.x - wd, b.y - 14), mid + Vector2(-10, 0)])
	c.draw_colored_polygon(glass, Color(0.8, 1.0, 0.95, 0.12 * a))
	glass.append(glass[0])
	c.draw_polyline(glass, Color(Color("#d8f0e8"), 0.8 * a), 4.0)
	c.draw_line(Vector2(b.x - wd * 0.7, top + 40), mid + Vector2(-26, -30), Color(1, 1, 1, 0.45 * a), 5.0)
	for yy: float in [top, b.y - 18]:
		c.draw_rect(Rect2(b.x - wd - 26, yy, wd * 2 + 52, 22), wood)
		c.draw_rect(Rect2(b.x - wd - 26, yy, wd * 2 + 52, 22), Color(ink, a), false, 3.0)
	for sx: float in [-1.0, 1.0]:
		c.draw_line(Vector2(b.x + sx * (wd + 14), top + 20), Vector2(b.x + sx * (wd + 14), b.y - 18), wood, 9.0)


func _mui_kiem(c: Node2D, a: float) -> void:
	if a <= 0.01 and t < L("k04-05"):
		return
	var down := smooth(L("k04-03") + 0.1, L("k04-03") + 1.0, t)
	var x := 1500.0
	var tip_y := lerpf(-200.0, 560.0, down)
	var wd := 70.0
	var col := Color("#e8dcc0").lerp(Color("#7a6a5a"), smooth(L("k04-05") + 1.0, L("k04-05") + 2.2, t))
	var aa := maxf(a, 0.3 * smooth(L("k04-05"), L("k04-05") + 0.3, t) * (1.0 - smooth(L("k04-06b") - 0.3, L("k04-06b") + 0.3, t)))
	if aa <= 0.01:
		return
	var crack := smooth(L("k04-05") + 0.6, L("k04-05") + 0.9, t)
	var fall := smooth(L("k04-05") + 1.0, L("k04-05") + 2.4, t)
	# phần trên (gắn trần)
	var cy := tip_y - 170.0
	var upper := PackedVector2Array([Vector2(x - wd, STG.position.y - 40), Vector2(x + wd, STG.position.y - 40), Vector2(x + wd, cy + 12), Vector2(x - wd, cy - 12)])
	shape(c, upper, Color(col, aa), 4.0)
	c.draw_line(Vector2(x, STG.position.y - 40), Vector2(x, cy), Color(inkof(col), 0.6 * aa), 5.0)
	# mũi: gãy rơi khi phe kiếm thua
	var off := Vector2(fall * 30.0, fall * fall * 420.0)
	var rot := fall * 0.6
	c.draw_set_transform(Vector2(x, cy) + off * crack, rot * crack, Vector2.ONE)
	var lower := PackedVector2Array([Vector2(-wd, -12), Vector2(wd, 12), Vector2(0, tip_y - cy)])
	shape(c, lower, Color(col, aa * (1.0 - fall * 0.8)), 4.0)
	c.draw_line(Vector2(0, 0), Vector2(0, (tip_y - cy) * 0.7), Color(inkof(col), 0.6 * aa * (1.0 - fall)), 5.0)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	if crack > 0.0 and fall < 0.5:
		cut(c, Vector2(x - wd, cy - 12), Vector2(x + wd, cy + 12), 6.0, Color("#1a0e0a"))


# năm tấm núi trồi lên khi kể Ngũ Nhạc
const NUI5 := ["THÁI SƠN", "HOA SƠN", "HÀNH SƠN", "TUNG SƠN", "HẰNG SƠN"]
const NUI5_COL := [Color("#6a7a4a"), Color("#c08a3a"), Color("#4a6a7a"), Color("#7a4a5a"), Color("#5a5a7a")]


func _the_nui(c: Node2D) -> void:
	var l := L("k04-06b")
	var out := 1.0 - smooth(LE("k04-06b") + 0.2, LE("k04-06b") + 0.8, t)
	for i in 5:
		var t0 := l + 2.5 + i * 0.75
		var up := smooth(t0, t0 + 0.4, t) * out
		if up <= 0.0:
			continue
		var x := 330.0 + i * 315.0
		var hh := 300.0 + (40.0 if i == 1 else 0.0)
		var by := GY + 10.0
		var y := by - hh * (up * 1.08 - 0.08 * bump(t0 + 0.3, t0 + 0.4, t0 + 0.45, t0 + 0.6))
		var col: Color = NUI5_COL[i]
		var card := PackedVector2Array([Vector2(x - 120, by), Vector2(x - 120, y + 40), Vector2(x, y - 60), Vector2(x + 120, y + 40), Vector2(x + 120, by)])
		shape(c, card, col, 5.0, ink)
		hatch(c, card, 0.7, 18.0, Color(ink, 0.25))
		var peak := PackedVector2Array([Vector2(x - 80, y + 160), Vector2(x - 20, y + 40), Vector2(x + 10, y + 80), Vector2(x + 50, y + 20), Vector2(x + 90, y + 160)])
		shape(c, peak, col.lightened(0.25), 3.0, Color(ink, 0.6))
		var nm: String = NUI5[i]
		var fs := 34
		var tw := font.get_string_size(nm, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		c.draw_rect(Rect2(x - tw * 0.5 - 12, y + 190, tw + 24, 52), Color("#efe4c8"))
		c.draw_rect(Rect2(x - tw * 0.5 - 12, y + 190, tw + 24, 52), ink, false, 3.0)
		c.draw_string(font, Vector2(x - tw * 0.5, y + 228), nm, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color("#b8322c") if i == 1 else ink)


func _near(c: Node2D) -> void:
	# khung vòm sân khấu + màn nhung đỏ
	var op := smooth(L("k04-01") - 0.6, L("k04-01") + 1.6, t)
	var cl := Color("#8a1e1a")
	for sd: float in [-1.0, 1.0]:
		var edge := 960.0 + sd * lerpf(40.0, 900.0, op)
		var outer := 960.0 + sd * 1400.0
		var cur := PackedVector2Array()
		var n := 10
		for i in n + 1:
			var y := lerpf(0.0, 1100.0, float(i) / n)
			cur.append(Vector2(edge + sd * sin(y * 0.02 + t * 0.5) * 10.0 * (float(i) / n), y))
		cur.append(Vector2(outer, 1100))
		cur.append(Vector2(outer, 0))
		c.draw_colored_polygon(cur, cl)
		for k in 6:
			var fx := lerpf(edge, outer, (k + 0.5) / 6.0)
			c.draw_line(Vector2(fx, 0), Vector2(fx + sd * 8.0, 1100), Color(0, 0, 0, 0.3), 10.0)
		c.draw_polyline(cur.slice(0, n + 1), Color("#3a0a08"), 6.0)
	# diềm trên
	c.draw_rect(Rect2(-400, 40, 2720, 70), Color("#6a1612"))
	for i in 34:
		var x := -380.0 + i * 80.0
		c.draw_colored_polygon(PackedVector2Array([Vector2(x, 110), Vector2(x + 80, 110), Vector2(x + 40, 146)]), Color("#6a1612"))
		c.draw_circle(Vector2(x + 40, 150), 6.0, Color("#d8a840"))
	c.draw_line(Vector2(-400, 108), Vector2(2320, 108), Color("#d8a840"), 4.0)


func _glow(c: Node2D) -> void:
	var sx := _split()
	# tia lửa ở đường chia mỗi lần chạm kiếm
	for ct: float in _clashes():
		var e := t - ct
		if e < 0.0 or e > 0.6:
			continue
		var big := 1.6 if ct == _clashes()[3] else 1.0
		var p := Vector2(sx, GY - 210)
		var a := (1.0 - e / 0.6)
		blob(c, p, 90.0 * big * (0.6 + e), Color(1.2, 0.9, 0.5, 0.5 * a))
		for i in 10:
			var an := i * TAU / 10.0 + ct
			var d := Vector2.from_angle(an)
			c.draw_line(p + d * (20.0 + e * 300.0 * big), p + d * (60.0 + e * 420.0 * big), Color(1.3, 1.0, 0.6, a), 4.0)
	# đèn rọi ông già cuối cảnh
	var sp := smooth(L("k04-07") + 0.4, L("k04-07") + 1.4, t)
	if sp > 0.0:
		var o := Vector2(1500, -100)
		c.draw_colored_polygon(PackedVector2Array([o + Vector2(-40, 0), o + Vector2(40, 0), Vector2(1600, GY + 20), Vector2(1240, GY + 20)]), Color(1.0, 0.9, 0.7, 0.16 * sp))
		flat_blob(c, Vector2(1420, GY + 10), 200.0, 0.18, Color(1.0, 0.9, 0.7, 0.3 * sp))
	# quầng nội công quanh người ngồi thở
	var ll := _lit_l()
	if ll > 0.01 and t < L("k04-04"):
		blob(c, nhac.pos + Vector2(0, -150), 150.0 + sin((t - L("k04-02")) * 1.6) * 20.0, Color(0.5, 1.0, 0.85, 0.16 * ll))


func _d_screen(c: Node2D) -> void:
	var l2 := L("k04-02")
	var l3 := L("k04-03")
	nhan(c, Vector2(W * 0.3, 200), "KHÍ TÔNG", 60, Color("#2f6a62"), bump(l2 + 0.5, l2 + 0.9, LE("k04-02") - 0.2, LE("k04-02") + 0.3), -0.03)
	nhan(c, Vector2(W * 0.7, 200), "KIẾM TÔNG", 60, Color("#b8322c"), bump(l3 + 0.3, l3 + 0.7, LE("k04-03") - 0.2, LE("k04-03") + 0.3), 0.03)
	var l5 := L("k04-05")
	nhan(c, Vector2(W * 0.5, 190), "25 NĂM TRƯỚC", 54, Color("#5a2a22"), bump(l5 + 2.6, l5 + 3.0, LE("k04-05") + 0.2, LE("k04-05") + 0.6))
	var l6 := L("k04-06")
	nhan(c, Vector2(W * 0.32, 200), "NỘI CÔNG", 54, Color("#2f6a62"), bump(l6 + 2.0, l6 + 2.4, LE("k04-06"), LE("k04-06") + 0.3))
	var l6b := L("k04-06b")
	nhan(c, Vector2(W * 0.5, 190), "NGŨ NHẠC KIẾM PHÁI", 58, Color("#b8322c"), bump(l6b + 6.3, l6b + 6.7, LE("k04-06b") + 0.1, LE("k04-06b") + 0.5))
	super._d_screen(c)
