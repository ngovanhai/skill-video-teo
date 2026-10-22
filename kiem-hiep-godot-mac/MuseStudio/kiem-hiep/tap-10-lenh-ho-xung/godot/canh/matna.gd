extends "res://canh.gd"
# Lần rót thứ tám, đắng: sân khấu tối, một luồng đèn rọi, Nhạc Bất Quần ngồi ghế cao đeo mặt nạ trắng "quân tử".
# Bên trái là tấm màn giấy: âm mưu diễn bằng bóng. Mặt nạ rạn dần theo từng âm mưu rồi vỡ đôi.
# Cuối cảnh Nhạc tối đi; Lệnh Hồ Xung hạ mũi kiếm, ngồi mép sân khấu uống một mình.

const BITTER := Color("#5a2a22")
const CURTAIN := Color("#5a1a1e")
const PAPER := Color("#e8d6a8")
const SCR := Rect2(170, 250, 760, 520)    # màn giấy chiếu bóng
const DAIS := Vector2(1380, 900)          # chân bục ghế cao
const DAIS_H := 70.0

var nbq: Dictionary
var lhx: Dictionary
var kiem: Dictionary
var ho: Dictionary
var ghe_cao: Dictionary
var flags := {}
var shake := 0.0
var shook := {}


func _palette() -> void:
	sky_top = Color("#0c0a10")
	sky_bot = Color("#1a1218")
	char_tint = Color(0.92, 0.88, 0.9)
	ground_y = 900.0
	vign_a = 0.5
	wind_base = 0.0
	wind_gust = 0.0


func _build() -> void:
	ghe_cao = ghe_moi(Vector2(DAIS.x, DAIS.y - DAIS_H), -1.0, Color("#2a1416"), 190.0)
	nbq = actor("nhac-bat-quan", ghe_cao.p, -1.0)
	lhx = actor("lenh-ho-xung", Vector2(150, ground_y), 1.0)
	kiem = prop(lhx, "kiem", "tay", "F")
	ho = prop(lhx, "ho_lo", "hong", "F")
	lhx.show = 0.0


func _once(k: String) -> bool:
	if flags.has(k):
		return false
	flags[k] = true
	return true


func _lips(a: Dictionary, off: Vector2) -> Vector2:
	var to: Node2D = a.node.J["torso"]
	return from_w(to, to_w(a.node.J["head"], Vector2(0, -30))) + off


func _hit(k: String, at: float, amt: float) -> void:
	if t >= at and t < at + 0.3 and not shook.has(k):
		shook[k] = true
		shake = maxf(shake, amt)


# ---------------------------------------------------------------- nhịp mặt nạ

func _glitch_t() -> float:
	return L("k18-02") + 1.2


func _crack() -> float:
	# độ rạn 0..1: vết đầu (+1.6), lan theo từng âm mưu, toác khi bị gọi tên
	var a := _glitch_t() + 0.4
	var r := 0.3 * smooth(a, a + 0.12, t)
	r += 0.2 * smooth(L("k18-03") + 3.0, L("k18-03") + 3.4, t)
	r += 0.2 * smooth(L("k18-04c") + 3.6, L("k18-04c") + 4.0, t)
	r += 0.3 * smooth(L("k18-04d") + 2.0, L("k18-04d") + 2.6, t)
	return r


func _split() -> float:
	return smooth(L("k18-05") + 0.3, L("k18-05") + 2.4, t)


func _story(dt: float) -> void:
	if t < 0.0:
		return
	shake = maxf(0.0, shake - dt * 2.5)
	var g2 := _glitch_t()
	_hit("nut", g2 + 0.4, 0.7)
	_hit("doi", L("k18-04c") + 3.6, 0.5)
	_hit("vo", L("k18-05") + 0.3, 1.0)
	rain_of("dust", 3.0, Rect2(1100, 120, 560, 700), {"col": Color(1, 0.95, 0.8, 0.5)})
	# --- Nhạc Bất Quần: ngồi thẳng như tượng trên ghế cao
	ngoi(nbq, ghe_cao)
	var a3 := L("k18-03")
	var a4c := L("k18-04c")
	var a5 := L("k18-05")
	var a6 := L("k18-06")
	var a7 := L("k18-07")
	var ve := bump(a3 + 0.6, a3 + 1.0, a3 + 4.6, a3 + 5.0)          # với tay lấy kiếm phổ
	var chi := bump(a3 + 3.4, a3 + 3.8, LE("k18-03"), LE("k18-03") + 0.4)
	var kiemchi := bump(a4c + 1.0, a4c + 1.3, a4c + 4.0, a4c + 4.4)  # kiếm chỉ nhanh như kim
	var nga := bump(a5 + 0.2, a5 + 0.5, a5 + 1.4, a5 + 2.0)          # giật đầu khi mặt nạ vỡ
	var cuoi := bump(a6 + 0.4, a6 + 1.0, a7 - 0.4, a7)
	nbq.extra = [[NGOI_TUONG, 1.0], [{"head": -4.0}, 1.0], [arms_of("raise"), ve * 0.5], [arms_of("point"), chi],
		[arms_of("point"), kiemchi], [{"head": -14.0, "torso": -6.0}, nga], [{"head": 8.0, "torso": 4.0}, cuoi]]
	nbq.expr = "binh"
	if t > a5 + 0.4:
		nbq.expr = "gian" if t < a6 else ("dac-y" if t < a7 else "binh")
	nbq.talk = 0.0
	var mo := smooth(a7 + 0.2, a7 + 2.4, t)
	nbq.tint = Color(1, 1, 1).lerp(Color(0.25, 0.25, 0.32), mo)
	if t > a6 and t < a7:
		nbq.tint = Color(0.75, 0.85, 1.1)
	# --- Lệnh Hồ Xung: bước vào, kiếm giơ rồi hạ, ngồi mép sân khấu
	var a8 := L("k18-08")
	var a9 := L("k18-09")
	lhx.show = smooth(a7 + 0.4, a7 + 1.0, t)
	if t > a7 + 0.4 and _once("vao"):
		lhx.speed = 170.0
		lhx.go = Vector2(860, ground_y)
	var gio := bump(a7 + 2.8, a7 + 3.3, a7 + 4.6, a7 + 5.2)
	var ha := smooth(a7 + 4.8, a7 + 5.8, t)
	kiem.lock = maxf(gio, ha) * (1.0 - smooth(L("k18-08") - 1.0, L("k18-08") - 0.6, t))
	kiem.lockdir = Vector2(1.0, -0.25).normalized().lerp(Vector2(0.2, 1.0).normalized(), ha).normalized()
	lhx.extra = [[arms_of("guard"), gio], [{"head": 10.0, "torso": 6.0}, ha]]
	lhx.expr = "quyet-tam" if gio > 0.4 else "buon"
	if t > a8 - 0.6 and _once("cat_kiem"):
		kiem.node.visible = false
		prop_to(ho, "tay", "F")
	# ngồi mép sân khấu, chân buông xuống hố nhạc
	var ngoi_k := smooth(a8 - 0.4, a8 + 0.2, t)
	if t > a8 - 0.4:
		lhx.go = Vector2.INF
		lhx.pos = Vector2(820, ground_y + SEAT_H * CS)
		lhx.face = 1.0
		var uong := bump(a8 + 1.6, a8 + 2.2, a8 + 4.6, a8 + 5.2) + bump(a9 - 2.6, a9 - 2.1, a9 - 0.9, a9 - 0.4)
		var ngam := smooth(a9 + 0.4, a9 + 1.4, t)
		lhx.extra = [[SIT, ngoi_k], [{"head": 14.0, "torso": 10.0}, ngoi_k * (1.0 - uong)], [{"head": -16.0, "torso": -6.0}, uong],
			[{"head": 22.0}, ngam]]
		lhx.hold["F"] = [Vector2(40, -10).lerp(_lips(lhx, Vector2(12, -10)), uong), maxf(uong, ngoi_k * 0.6)]
		ho.lock = uong
		ho.lockdir = Vector2.DOWN.lerp(Vector2(0.75, -0.66), uong).normalized()
		ho.aim = Vector2(0, -30)
		lhx.expr = "buon" if t < a9 + 2.4 else "binh"


func _cam() -> Array:
	var a1 := L("k18-01")
	var a2 := L("k18-02")
	var a3 := L("k18-03")
	var a5 := L("k18-05")
	var a6 := L("k18-06")
	var a7 := L("k18-07")
	var a8 := L("k18-08")
	var a9 := L("k18-09")
	var hd := head_of(nbq)
	var wide := Vector2(960, 560)
	var r: Array
	if t < a2:
		var k := smooth(a1, a2, t)
		r = [Vector2(1200, 560).lerp(Vector2(hd.x - 40.0, hd.y + 110.0), k), lerpf(1.0, 1.5, k)]
	elif t < a3:
		var k := smooth(a2, a2 + 1.0, t)
		r = [Vector2(hd.x - 40.0, hd.y + 110.0).lerp(Vector2(hd.x - 20.0, hd.y + 60.0), k), lerpf(1.5, 2.2, k)]
	elif t < a5:
		var k := smooth(a3, a3 + 1.6, t)
		var drift := sin((t - a3) * 0.15) * 30.0
		r = [Vector2(hd.x - 20.0, hd.y + 60.0).lerp(wide + Vector2(drift, 0), k), lerpf(2.2, 1.0, k)]
	elif t < a6:
		var k := smooth(a5, a5 + 1.2, t)
		r = [wide.lerp(Vector2(hd.x - 20.0, hd.y + 50.0), k), lerpf(1.0, 2.3, k)]
	elif t < a7:
		var k := smooth(a6, a6 + 2.0, t)
		r = [Vector2(hd.x - 20.0, hd.y + 50.0).lerp(Vector2(hd.x - 60.0, hd.y + 160.0), k), lerpf(2.3, 1.5, k)]
	elif t < a8:
		var k := smooth(a7, a7 + 2.0, t)
		r = [Vector2(hd.x - 60.0, hd.y + 160.0).lerp(Vector2(900, 620), k), lerpf(1.5, 1.05, k)]
	elif t < a9:
		var k := smooth(a8, a8 + 1.6, t)
		r = [Vector2(900, 620).lerp(Vector2(860, 720), k), lerpf(1.05, 1.6, k)]
	else:
		var k := smooth(a9, LE("k18-09") + 0.8, t)
		r = [Vector2(860, 720).lerp(Vector2(980, 600), k), lerpf(1.6, 0.95, k)]
	if shake > 0.0:
		r[0] = r[0] + Vector2(sin(t * 67.0), cos(t * 53.0)) * shake * 12.0
	return r


# ---------------------------------------------------------------- sân khấu

func _sky(c: Node2D) -> void:
	vgrad(c, Rect2(-2000, -1200, 6000, 3400), sky_top, sky_bot)


func _back(c: Node2D) -> void:
	# màn nhung đỏ thẫm treo nếp dọc, khung gỗ sân khấu
	for i in 34:
		var x := -500.0 + i * 90.0
		var sw := sin(t * 0.4 + i * 0.9) * 4.0
		var pts := PackedVector2Array([Vector2(x, -200), Vector2(x + 90, -200), Vector2(x + 90 + sw, ground_y), Vector2(x + sw, ground_y)])
		c.draw_colored_polygon(pts, CURTAIN.darkened(0.25 + 0.2 * (i % 2)))
		c.draw_line(Vector2(x + 45 + sw * 0.5, -200), Vector2(x + 45 + sw, ground_y), Color(0, 0, 0, 0.35), 6.0)
	# lambrequin trên cùng
	var top := PackedVector2Array()
	top.append(Vector2(-600, 40))
	for i in 40:
		top.append(Vector2(-600 + i * 90, 110 + (i % 2) * 34))
	top.append(Vector2(3000, 40))
	top.append(Vector2(3000, -300))
	top.append(Vector2(-600, -300))
	shape(c, top, CURTAIN.darkened(0.1), 4.0)
	for i in 39:
		c.draw_circle(Vector2(-555 + i * 90, 118 + ((i + 1) % 2) * 34), 7.0, Color("#b8902e"))
	_man_giay(c)


func _ground(c: Node2D) -> void:
	var gy := ground_y
	# sàn sân khấu ván dọc + mép trước và hố tối
	var fl := PackedVector2Array([Vector2(-800, gy), Vector2(2800, gy), Vector2(2800, gy + 60), Vector2(-800, gy + 60)])
	shape(c, fl, Color("#3a2a20"), 4.0)
	for i in 50:
		var x := -800.0 + i * 76.0
		c.draw_line(Vector2(x, gy), Vector2(x - 8, gy + 60), Color(0, 0, 0, 0.4), 2.0)
	c.draw_rect(Rect2(-800, gy + 60, 3600, 14), Color("#b8902e"))
	c.draw_rect(Rect2(-800, gy + 74, 3600, 600), Color("#08060a"))
	# bục ghế cao
	var d := PackedVector2Array([Vector2(DAIS.x - 170, DAIS.y), Vector2(DAIS.x - 150, DAIS.y - DAIS_H), Vector2(DAIS.x + 150, DAIS.y - DAIS_H), Vector2(DAIS.x + 170, DAIS.y)])
	shape(c, d, Color("#2a1416"), 4.0)
	c.draw_line(Vector2(DAIS.x - 150, DAIS.y - DAIS_H + 10), Vector2(DAIS.x + 150, DAIS.y - DAIS_H + 10), Color("#b8902e"), 3.0)
	# luồng đèn rọi xuống ghế (dưới người), vũng sáng trên sàn
	var on_ := 1.0 - smooth(L("k18-07") + 0.2, L("k18-07") + 2.4, t) * 0.75
	flat_blob(c, Vector2(DAIS.x, DAIS.y + 6), 260.0, 0.18, Color(1, 0.9, 0.7, 0.18 * on_))
	ghe_ve(c, ghe_cao)
	# biển "Quân Tử Kiếm" trên bục
	var a2 := L("k18-02")
	var pa := smooth(a2 + 0.2, a2 + 0.6, t) * (1.0 - smooth(L("k18-05") + 0.3, L("k18-05") + 0.8, t))
	if pa > 0.01:
		var sp := Vector2(DAIS.x, DAIS.y - 30.0)
		var drop := smooth(L("k18-05") + 0.3, L("k18-05") + 0.8, t) * 40.0
		shape(c, PackedVector2Array([sp + Vector2(-120, -24 + drop), sp + Vector2(120, -24 + drop), sp + Vector2(120, 24 + drop), sp + Vector2(-120, 24 + drop)]), Color(0.12, 0.08, 0.06, pa), 3.0)
		var txt := "QUÂN TỬ KIẾM"
		var tw := font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 30).x
		c.draw_string(font, sp + Vector2(-tw * 0.5, 11 + drop), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 30, Color(0.92, 0.76, 0.36, pa))
	# vết đèn sau màn giấy chiếu qua sàn
	flat_blob(c, Vector2(SCR.get_center().x, gy + 8), 380.0, 0.12, Color(1, 0.8, 0.5, 0.12 * _scr_on()))


func _scr_on() -> float:
	return smooth(L("k18-03") - 0.6, L("k18-03") + 0.2, t) * (1.0 - smooth(L("k18-05") - 0.4, L("k18-05") + 0.6, t))


# ---------------------------------------------------------------- màn giấy: âm mưu diễn bằng bóng

func _man_giay(c: Node2D) -> void:
	var on_ := _scr_on()
	var r := SCR
	# khung gỗ + giấy (tối khi tắt đèn sau)
	c.draw_rect(r.grow(16), Color("#2a1810"))
	c.draw_rect(r, Color(0.16, 0.12, 0.1).lerp(PAPER, on_))
	for i in 4:
		c.draw_rect(Rect2(r.position + Vector2(0, i * r.size.y / 4.0), Vector2(r.size.x, 2)), Color(0, 0, 0, 0.12))
	if on_ < 0.02:
		return
	# quầng đèn dầu sau giấy
	for i in 5:
		c.draw_circle(r.get_center() + Vector2(0, 60), 120.0 + i * 60.0, Color(1, 0.75, 0.4, 0.05 * on_))
	var sh := Color(0.12, 0.07, 0.06, 0.9 * on_)
	var gy := r.end.y - 20.0
	var a3 := L("k18-03")
	var a4 := L("k18-04")
	var a4b := L("k18-04b")
	var a4c := L("k18-04c")
	var a4d := L("k18-04d")
	# k18-03: bàn tay bóng chộp cuộn kiếm phổ, ngón tay chỉ sang đệ tử
	var s3 := bump(a3 - 0.4, a3 + 0.2, a4 - 0.4, a4)
	if s3 > 0.01:
		var col := Color(sh, sh.a * s3)
		var grab := smooth(a3 + 0.8, a3 + 2.0, t)
		var sc := Vector2(r.position.x + 260, r.position.y + 230)
		_cuon(c, sc + Vector2(0, -grab * 40.0), col, 1.0)
		var hp := Vector2(r.end.x + 40, r.position.y + 120).lerp(sc + Vector2(40, -70), grab)
		_tay_bong(c, hp, col, grab)
		var lb := bump(a3 + 1.4, a3 + 1.8, a4 - 0.4, a4)
		nhan(c, sc + Vector2(0, 110), "Tịch Tà Kiếm Phổ", 30, Color("#8a1e1a"), lb * on_)
		# đệ tử nhỏ bị chỉ mặt
		var ch := smooth(a3 + 3.4, a3 + 4.0, t)
		if ch > 0.01:
			var dp := Vector2(r.position.x + 120, gy)
			_nguoi_bong(c, dp, 0.8, Color(col, col.a * ch), 0.0, 0.25)
			var fp := Vector2(r.end.x - 60, r.position.y + 200)
			var tip := fp.lerp(dp + Vector2(30, -170), ch)
			c.draw_line(fp, tip, Color(col, col.a * ch), 16.0, true)
			c.draw_circle(tip, 10.0, Color(col, col.a * ch))
	# k18-04: năm ngọn núi, chiếc ghế nhỏ trên đỉnh cao nhất, một bóng người leo lên
	# k18-04b: bóng Tả Lãnh Thiền to lớn ôm năm núi gom lại
	# k18-04c: kim đỏ xuyên qua, bóng Tả bị đẩy lùi
	var s4 := bump(a4 - 0.3, a4 + 0.3, a4d - 0.3, a4d + 0.2)
	if s4 > 0.01:
		var col := Color(sh, sh.a * s4)
		var gom := smooth(a4b + 1.0, a4b + 4.0, t) * (1.0 - smooth(a4c + 2.4, a4c + 3.6, t))
		var xs := [-300.0, -150.0, 0.0, 150.0, 300.0]
		var hs := [150.0, 220.0, 300.0, 210.0, 160.0]
		var cx := r.get_center().x
		for i in 5:
			var x: float = cx + float(xs[i]) * (1.0 - gom * 0.45)
			var h: float = hs[i]
			c.draw_colored_polygon(PackedVector2Array([Vector2(x - 110, gy), Vector2(x - 10, gy - h), Vector2(x + 10, gy - h), Vector2(x + 110, gy)]), Color(col, col.a * 0.8))
		# ghế nhỏ trên đỉnh giữa
		var ct := Vector2(cx, gy - 300.0)
		c.draw_rect(Rect2(ct + Vector2(-22, -26), Vector2(44, 8)), col)
		c.draw_rect(Rect2(ct + Vector2(-22, -26), Vector2(6, 26)), col)
		c.draw_rect(Rect2(ct + Vector2(16, -26), Vector2(6, 26)), col)
		c.draw_rect(Rect2(ct + Vector2(16, -70), Vector2(6, 46)), col)
		# người leo: từ chân núi lên đỉnh
		var leo := smooth(a4 + 0.6, a4b - 0.2, t)
		var lp := Vector2(cx - 260, gy - 20).lerp(Vector2(cx - 40, gy - 280), leo)
		_nguoi_bong(c, lp, 0.45, col, sin(t * 8.0) * 0.4 * (1.0 - leo), 0.0)
		# bóng Tả Lãnh Thiền
		var ta := smooth(a4b - 0.2, a4b + 0.8, t)
		if ta > 0.01:
			var lui := smooth(a4c + 1.2, a4c + 3.6, t)
			var tp := Vector2(r.end.x + 60.0 - ta * 220.0 + lui * 260.0, gy + 40.0)
			_nguoi_bong(c, tp, 2.1, Color(col, col.a * ta * (1.0 - lui * 0.6)), 0.0, -0.6 * gom)
		# kim đỏ của kiếm pháp nhanh không tưởng
		var kim := bump(a4c + 1.0, a4c + 1.2, a4c + 3.4, a4c + 3.8)
		if kim > 0.01:
			for i in 9:
				var y := r.position.y + 80.0 + i * 46.0
				var ph := fmod(t * 6.0 + i * 0.37, 1.0)
				var x0 := lerpf(r.position.x, r.end.x, ph)
				c.draw_line(Vector2(x0, y), Vector2(x0 + 140, y - 10), Color(0.75, 0.08, 0.08, 0.9 * kim * on_), 4.0, true)
	# k18-04d: cuộn kiếm phổ hiện lại, đỏ rực
	var s5 := bump(a4d - 0.2, a4d + 0.4, L("k18-05") - 0.6, L("k18-05"))
	if s5 > 0.01:
		var ctr := r.get_center()
		_cuon(c, ctr, Color(sh, sh.a * s5), 1.6)
		nhan(c, ctr + Vector2(0, 150), "Tịch Tà", 44, Color("#8a1e1a"), s5 * on_)


func _cuon(c: Node2D, p: Vector2, col: Color, s: float) -> void:
	c.draw_rect(Rect2(p + Vector2(-70, -26) * s, Vector2(140, 52) * s), col)
	c.draw_circle(p + Vector2(-74, 0) * s, 30.0 * s, col)
	c.draw_circle(p + Vector2(74, 0) * s, 30.0 * s, col)
	c.draw_line(p + Vector2(-74, -44) * s, p + Vector2(-74, 44) * s, col, 8.0 * s)
	c.draw_line(p + Vector2(74, -44) * s, p + Vector2(74, 44) * s, col, 8.0 * s)


# bàn tay bóng: lòng bàn tay + bốn ngón, k = khép lại khi chộp
func _tay_bong(c: Node2D, p: Vector2, col: Color, k: float) -> void:
	c.draw_line(p + Vector2(160, -100), p, col, 44.0, true)
	c.draw_circle(p, 40.0, col)
	for i in 4:
		var a := -2.4 + i * 0.32 + k * 0.9
		var l := 70.0 - k * 26.0
		c.draw_line(p, p + Vector2.from_angle(a) * l, col, 16.0, true)
	c.draw_line(p, p + Vector2.from_angle(-0.6 + k * 1.2) * 46.0, col, 16.0, true)


# bóng người kiểu con rối giấy: đầu tròn, thân thang, tay giang (arm: góc nghiêng tay, lean: nghiêng thân)
func _nguoi_bong(c: Node2D, p: Vector2, s: float, col: Color, arm: float, lean: float) -> void:
	var up := Vector2(sin(lean), -cos(lean))
	var rt := Vector2(-up.y, up.x)
	var hip := p + up * 70.0 * s
	var nk := hip + up * 120.0 * s
	c.draw_colored_polygon(PackedVector2Array([hip - rt * 46.0 * s, nk - rt * 28.0 * s, nk + rt * 28.0 * s, hip + rt * 46.0 * s]), col)
	c.draw_line(hip - rt * 18.0 * s, p - rt * 30.0 * s, col, 18.0 * s, true)
	c.draw_line(hip + rt * 18.0 * s, p + rt * 30.0 * s, col, 18.0 * s, true)
	c.draw_circle(nk + up * 46.0 * s, 44.0 * s, col)
	c.draw_line(nk - rt * 20.0 * s, nk - rt * 20.0 * s + (-rt).rotated(arm + 0.5) * 100.0 * s, col, 16.0 * s, true)
	c.draw_line(nk + rt * 20.0 * s, nk + rt * 20.0 * s + rt.rotated(-arm - 0.5) * 100.0 * s, col, 16.0 * s, true)


# ---------------------------------------------------------------- mặt nạ quân tử (vẽ trên đầu Nhạc)

func _head_xf() -> Transform2D:
	var hn: Node2D = nbq.node.J["head"]
	var o := to_w(hn, Vector2(0, -90))
	var ax := to_w(hn, Vector2(1, -90)) - o
	var ay := to_w(hn, Vector2(0, -89)) - o
	return Transform2D(ax * 1.18, ay * 1.18, o)


func _near(c: Node2D) -> void:
	var sp := _split()
	var fade := 1.0 - smooth(L("k18-06") - 1.0, L("k18-06"), t)
	var a9 := L("k18-09")
	if fade > 0.01:
		_mat_na(c, _head_xf(), sp, fade)
	# hai nửa mặt nạ nằm trên sàn dưới bục, sau đó Lệnh Hồ Xung nhìn
	if sp > 0.99:
		var lie := smooth(L("k18-06") - 1.0, L("k18-06"), t)
		if lie > 0.01:
			for sd: float in [-1.0, 1.0]:
				var p := Vector2(DAIS.x - 230.0 + sd * 60.0, ground_y + 30.0)
				c.draw_set_transform(p, sd * 1.3, Vector2(0.55, 0.55))
				_nua(c, sd, -1.0, lie)
				c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	# dòng rượu đắng
	var a8 := L("k18-08")
	var pk := bump(a8 + 2.2, a8 + 2.4, a8 + 4.4, a8 + 4.6) + bump(a9 - 2.1, a9 - 1.9, a9 - 1.1, a9 - 0.9)
	if pk > 0.01 and ho.has("mouthw"):
		var m0: Vector2 = ho.mouthw
		var tg := to_w(lhx.node.J["head"], Vector2(14, -28))
		var st := round_pts(PackedVector2Array([m0, (m0 + tg) * 0.5 + Vector2(0, -8), tg]), false, 4)
		c.draw_polyline(st, Color(0, 0, 0, 0.6 * pk), 11.0, true)
		c.draw_polyline(st, Color(BITTER, pk), 7.0, true)
		c.draw_polyline(st, Color(0.9, 0.6, 0.5, 0.5 * pk), 2.0, true)


func _mat_na(c: Node2D, xf: Transform2D, sp: float, a: float) -> void:
	var g2 := _glitch_t()
	var gl := bump(g2, g2 + 0.05, g2 + 0.3, g2 + 0.4)
	# hai nửa văng ra và rơi khi vỡ
	for sd: float in [-1.0, 1.0]:
		var off := Vector2(sd * sp * 120.0, sp * sp * 520.0)
		var m := Transform2D(sd * sp * 1.6, off)
		if gl > 0.01:
			# nhiễu: bóng đỏ – lam lệch và lát cắt ngang trượt
			for gh in [[Color(1, 0.2, 0.2, 0.5 * gl), Vector2(-10, 0)], [Color(0.2, 0.9, 1, 0.5 * gl), Vector2(10, 4)]]:
				var gc: Color = gh[0]
				var go: Vector2 = gh[1]
				c.draw_set_transform_matrix(xf * Transform2D(0.0, go + Vector2(sin(t * 90.0) * 8.0, 0)) * m)
				_nua(c, sd, 0.0, a, gc)
		c.draw_set_transform_matrix(xf * Transform2D(0.0, Vector2(sin(t * 113.0) * 6.0 * gl, 0)) * m)
		_nua(c, sd, _crack() if sp < 0.01 else -1.0, a * (1.0 - smooth(0.8, 1.0, sp)))
	c.draw_set_transform_matrix(Transform2D.IDENTITY)


# một nửa mặt nạ (sd = -1 trái, 1 phải) trong toạ độ đầu; cr = độ rạn; tint != trắng = bóng nhiễu
func _nua(c: Node2D, sd: float, cr: float, a: float, tint := Color(0, 0, 0, 0)) -> void:
	var ctr := Vector2(-6, 6)
	var pts := PackedVector2Array()
	# đường nứt chính chạy dọc giữa, răng cưa
	var seam := [Vector2(0, -78), Vector2(8, -50), Vector2(-6, -24), Vector2(6, 2), Vector2(-4, 30), Vector2(4, 58), Vector2(0, 84)]
	for p: Vector2 in seam:
		pts.append(ctr + p)
	for i in 15:
		var an := PI * 0.5 - sd * PI * i / 14.0
		pts.append(ctr + Vector2(cos(an) * 74.0, sin(an) * 84.0) * Vector2(1, 1))
	if tint.a > 0.0:
		c.draw_colored_polygon(pts, tint)
		return
	c.draw_colored_polygon(pts, Color(0.96, 0.95, 0.9, a))
	# viền ngoài theo cung; mép giữa chỉ hiện khi đã tách
	c.draw_polyline(pts.slice(seam.size()), Color(ink, a), 4.0, true)
	if cr < 0.0:
		c.draw_polyline(pts.slice(0, seam.size()), Color(ink, a), 4.0, true)
	# mắt hiền cong, má hồng, ria mảnh — gương mặt "quân tử" vẽ sẵn
	var ex := ctr.x + sd * 30.0
	c.draw_arc(Vector2(ex, ctr.y - 6), 13.0, PI * 1.1, PI * 1.9, 8, Color(ink, a), 4.0)
	c.draw_line(Vector2(ex - 16, ctr.y - 30), Vector2(ex + 16, ctr.y - 34 + sd * 0.0), Color(ink, a * 0.8), 3.0)
	c.draw_circle(Vector2(ctr.x + sd * 44.0, ctr.y + 20), 10.0, Color(0.9, 0.5, 0.45, 0.4 * a))
	var mpts := PackedVector2Array([Vector2(ctr.x + sd * 2.0, ctr.y + 40), Vector2(ctr.x + sd * 22.0, ctr.y + 34), Vector2(ctr.x + sd * 32.0, ctr.y + 44)])
	c.draw_polyline(mpts, Color(ink, a), 3.0, true)
	# vết rạn lan từ đường giữa ra
	if sd > 0.0 and cr > 0.01:
		var br := [[Vector2(6, 2), Vector2(40, -20), Vector2(62, -10)], [Vector2(-6, -24), Vector2(-34, -44), Vector2(-60, -40)],
			[Vector2(-4, 30), Vector2(-30, 56), Vector2(-40, 74)], [Vector2(8, -50), Vector2(30, -66), Vector2(50, -70)]]
		for i in br.size():
			var k := clampf(cr * 4.0 - i, 0.0, 1.0)
			if k <= 0.0:
				continue
			var b: Array = br[i]
			var p0: Vector2 = ctr + b[0]
			var p1: Vector2 = ctr + b[1]
			var p2: Vector2 = ctr + b[2]
			var e := p1.lerp(p2, k) if k > 0.5 else p0.lerp(p1, k * 2.0)
			c.draw_line(p0, p1 if k > 0.5 else e, Color(ink, a), 3.0, true)
			if k > 0.5:
				c.draw_line(p1, e, Color(ink, a), 2.5, true)
		# đường nứt chính hiện dần
		var sl := PackedVector2Array()
		var n := int(clampf(cr * 2.0, 0.0, 1.0) * (seam.size() - 1)) + 1
		for i in n:
			sl.append(ctr + seam[i])
		if sl.size() > 1:
			c.draw_polyline(sl, Color(ink, a), 4.0, true)


func _glow(c: Node2D) -> void:
	# nón đèn rọi từ trên xuống ghế cao
	var on_ := 1.0 - smooth(L("k18-07") + 0.2, L("k18-07") + 2.4, t) * 0.8
	var cold := bump(L("k18-06"), L("k18-06") + 0.6, L("k18-07") - 0.4, L("k18-07"))
	var col := Color(1.0, 0.85, 0.6).lerp(Color(0.5, 0.75, 1.2), cold)
	c.draw_polygon(PackedVector2Array([Vector2(DAIS.x - 50, -200), Vector2(DAIS.x + 50, -200), Vector2(DAIS.x + 260, DAIS.y), Vector2(DAIS.x - 260, DAIS.y)]),
		PackedColorArray([Color(col, 0.22 * on_), Color(col, 0.22 * on_), Color(col, 0.04 * on_), Color(col, 0.04 * on_)]))
	# ánh đỏ của kiếm phổ hắt lên mặt nạ
	var a4d := L("k18-04d")
	var red := bump(a4d + 0.6, a4d + 1.4, L("k18-05") + 0.4, L("k18-05") + 1.2)
	if red > 0.01:
		var hp := head_of(nbq)
		for i in 5:
			c.draw_circle(hp, 50.0 + i * 30.0, Color(1.4, 0.15, 0.1, 0.07 * red))
	# đèn nhỏ cho Lệnh Hồ Xung ở mép sân khấu
	var lo := smooth(L("k18-07") + 1.0, L("k18-07") + 3.0, t)
	if lo > 0.01:
		var p := Vector2(lhx.pos.x, ground_y)
		c.draw_polygon(PackedVector2Array([Vector2(p.x - 30, -200), Vector2(p.x + 30, -200), Vector2(p.x + 200, ground_y + 60), Vector2(p.x - 200, ground_y + 60)]),
			PackedColorArray([Color(0.7, 0.8, 1.1, 0.12 * lo), Color(0.7, 0.8, 1.1, 0.12 * lo), Color(0.7, 0.8, 1.1, 0.02 * lo), Color(0.7, 0.8, 1.1, 0.02 * lo)]))
