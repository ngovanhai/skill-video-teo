extends "res://canh.gd"
# Lần rót thứ bảy: chùa và giáo, hai lời mời, hai cái lắc đầu. Ba kiểu dựng theo arg.m:
#   k16  — mặt đứng cổng chùa đối xứng như bức khắc: hồ lô gửi trên bệ đá, phương trượng đưa cuốn kinh
#   k16b — dải ngang chạy dài từ sân chùa sang ngai Nhật Nguyệt; máy quay lia rồi lùi xa thấy cả hai lời mời
#   k17  — ảnh chụp chung phái Hằng Sơn: hai hàng ni cô, một gã say ở giữa; rồi năm ghế Ngũ Nhạc

const PALE := Color("#e6e2c8")      # rượu nhạt mà trong (lần rót thứ bảy)
const RED_GATE := Color("#a8402e")
const STONE := Color("#9a9384")
const ROBE_NI := Color("#8e8c86")

var m := "k16"
var lhx: Dictionary
var pc: Dictionary
var dd: Dictionary
var nng: Dictionary
var nl: Dictionary
var ho: Dictionary
var ma: Dictionary
var g_nng: Dictionary
var g5: Array = []
var lhx5: Dictionary
var flags := {}
var shake := 0.0


func _palette() -> void:
	m = arg.get("m", "k16")
	match m:
		"k16":
			sky_top = Color("#d7c39a")
			sky_bot = Color("#f2e3bf")
			char_tint = Color(1.0, 0.97, 0.9)
			ground_y = 940.0
			wind_base = 0.25
		"k16b":
			sky_top = Color("#b9b49a")
			sky_bot = Color("#ece2c2")
			char_tint = Color(1.0, 0.97, 0.92)
			ground_y = 930.0
			wind_base = 0.15
		"k17":
			sky_top = Color("#c9ccc8")
			sky_bot = Color("#eeeee6")
			char_tint = Color(0.98, 0.98, 1.0)
			ground_y = 930.0
			wind_base = 0.05
	vign_a = 0.22
	wind_gust = 0.3


func _build() -> void:
	match m:
		"k16":
			lhx = actor("lenh-ho-xung", Vector2(-260, ground_y), 1.0)
			ho = prop(lhx, "ho_lo", "tay", "F")
			pc = actor("phuong-chung", Vector2(960, ground_y - 64.0), 1.0)
			pc.size = 0.9
			pc.show = 0.0
		"k16b":
			dd = actor("doanh-doanh", Vector2(-240, ground_y), 1.0)
			lhx = actor("lenh-ho-xung", Vector2(-268, ground_y - 78.0), 1.0)
			ho = prop(lhx, "ho_lo", "hong", "F")
			pc = actor("phuong-chung", Vector2(900, ground_y), -1.0)
			g_nng = ghe_moi(Vector2(2620, ground_y - 50.0), -1.0, Color("#2a1a1a"), 190.0)
			nng = actor("nham-nga-hanh", g_nng.p, -1.0)
			# Doanh Doanh vẽ sau Lệnh Hồ Xung để cõng: đổi thứ tự node
			l_chars.move_child(dd.node, l_chars.get_child_count() - 1)
		"k17":
			lhx = actor("lenh-ho-xung", Vector2(-260, ground_y), 1.0)
			ho = prop(lhx, "ho_lo", "tay", "F")
			nl = actor("nghi-lam", Vector2(740, ground_y), 1.0)
			ma = prop(nl, "ma_do", "mat", "F", {"cheek": Vector2(62, -54)})
			for i in 5:
				g5.append(ghe_moi(Vector2(4300 + i * 300, ground_y), 1.0 if i < 2 else -1.0, Color("#6e4a2a"), 150.0))
			lhx5 = actor("lenh-ho-xung", g5[4].p, -1.0)
			var h5 := prop(lhx5, "ho_lo", "tay", "F")
			h5.lock = 0.0


func _story(dt: float) -> void:
	if t < 0.0:
		return
	shake = maxf(0.0, shake - dt * 3.0)
	match m:
		"k16":
			_s16(dt)
		"k16b":
			_s16b(dt)
		"k17":
			_s17(dt)


func _cam() -> Array:
	var r: Array
	match m:
		"k16":
			r = _c16()
		"k16b":
			r = _c16b()
		"k17":
			r = _c17()
		_:
			r = [CENTER, 1.0]
	if shake > 0.0:
		r[0] = r[0] + Vector2(sin(t * 61.0), cos(t * 47.0)) * shake * 10.0
	return r


func _sky(c: Node2D) -> void:
	vgrad(c, Rect2(-4000, -1400, 12000, 3600), sky_top, sky_bot)


func _far(c: Node2D) -> void:
	match m:
		"k16":
			# núi Tung Sơn sau mái chùa: khối mực mỏng, nét khắc ngang
			var pts := _mt([[-600, 420], [-100, 250], [500, 330], [1000, 180], [1500, 320], [2100, 230], [2700, 400]], 760.0)
			shape(c, pts, air(Color("#7a8a7a"), 0.55), 3.0)
			hatch(c, pts, 0.0, 22.0, Color(ink, 0.12))
		"k17":
			# núi Hằng Sơn tuyết trắng sau khung cửa
			var pts := _mt([[-800, 520], [-200, 300], [400, 420], [1000, 240], [1700, 380], [2400, 300], [3200, 460]], 800.0)
			shape(c, pts, air(Color("#a9b4bc"), 0.45), 3.0)
			for i in 6:
				var x := -200.0 + i * 600.0
				c.draw_colored_polygon(PackedVector2Array([Vector2(x - 90, 380), Vector2(x, 300), Vector2(x + 90, 380), Vector2(x + 40, 360), Vector2(x - 30, 372)]), Color(1, 1, 1, 0.7))


func _back(c: Node2D) -> void:
	match m:
		"k16b":
			_b16b(c)


func _ground(c: Node2D) -> void:
	match m:
		"k16":
			_g16(c)
		"k16b":
			_g16b(c)
		"k17":
			_g17(c)


func _near(c: Node2D) -> void:
	match m:
		"k16":
			_n16(c)
		"k16b":
			_n16b(c)
		"k17":
			_n17(c)


func _glow(c: Node2D) -> void:
	match m:
		"k16":
			_gl16(c)


func _d_screen(c: Node2D) -> void:
	super._d_screen(c)
	if m == "k16b":
		_sc16b(c)


# ---------------------------------------------------------------- dùng chung

func _lips(a: Dictionary, off: Vector2) -> Vector2:
	var to: Node2D = a.node.J["torso"]
	return from_w(to, to_w(a.node.J["head"], Vector2(0, -30))) + off


# dải núi riêng (đỉnh dạng [x, y]), trải từ đỉnh đầu tới đỉnh cuối rồi khép xuống đáy
func _mt(peaks: Array, base_y: float) -> PackedVector2Array:
	var f: Array = peaks[0]
	var l: Array = peaks[peaks.size() - 1]
	var pts := PackedVector2Array([Vector2(float(f[0]) - 400.0, base_y)])
	for pk: Array in peaks:
		pts.append(Vector2(float(pk[0]), float(pk[1])))
	pts.append(Vector2(float(l[0]) + 400.0, base_y))
	var rp := round_pts(pts, false, 6)
	rp.append(Vector2(float(l[0]) + 400.0, H + 600))
	rp.append(Vector2(float(f[0]) - 400.0, H + 600))
	return rp


func _once(k: String) -> bool:
	if flags.has(k):
		return false
	flags[k] = true
	return true


# lắc đầu: biên độ a (độ), tốc độ nhanh dần rồi dứt khoát
func _lac(a0: float, t0: float, t1: float) -> float:
	var w := bump(t0, t0 + 0.2, t1 - 0.3, t1)
	return sin((t - t0) * 11.0) * a0 * w


# chắp tay trước ngực (toạ độ thân)
func _chap(a: Dictionary, w: float) -> void:
	a.hold["F"] = [Vector2(46, -86), w]
	a.hold["B"] = [Vector2(40, -90), w]


# dòng rượu tự vẽ (màu theo lần rót) từ miệng hồ lô tới môi
func _dong(c: Node2D, v: Dictionary, a: Dictionary, col: Color, k: float) -> void:
	if k <= 0.01 or not v.has("mouthw"):
		return
	var m0: Vector2 = v.mouthw
	var tg := to_w(a.node.J["head"], Vector2(14, -28))
	var mid := (m0 + tg) * 0.5 + Vector2(0, -10)
	var st := round_pts(PackedVector2Array([m0, mid, tg]), false, 4)
	c.draw_polyline(st, Color(ink, 0.8 * k), 11.0, true)
	c.draw_polyline(st, Color(col, k), 7.0, true)
	c.draw_polyline(st, Color(1, 1, 1, 0.6 * k), 2.0, true)


# ---------------------------------------------------------------- k16: cổng chùa

const BE := Vector2(330, 940)        # bệ đá gửi hồ lô (chân bệ)
const BE_TOP := 812.0


func _s16(_dt: float) -> void:
	var a1 := L("k16-01")
	var a2 := L("k16-02")
	var a3 := L("k16-03")
	var a4 := L("k16-04")
	var a5 := L("k16-05")
	var a5b := L("k16-05b")
	var a6 := L("k16-06")
	var a7 := L("k16-07")
	rain_of("leaf", 2.0, Rect2(-200, -100, 2400, 200), {"col": Color("#c8862e"), "land": ground_y + 20.0})
	# --- đi tới bệ đá, gửi hồ lô, rồi tới cổng
	if _once("vao"):
		lhx.speed = 200.0
		lhx.go = Vector2(BE.x + 120.0, ground_y)
	if t > a1 + 2.8 and t < a2 and _once("toi_cong"):
		lhx.go = Vector2(700, ground_y)
	var put := bump(a1 + 1.2, a1 + 1.8, a1 + 2.2, a1 + 2.6)
	var pick := bump(a6 + 2.0, a6 + 2.5, a6 + 3.0, a6 + 3.4)
	var on_be := t > a1 + 2.0 and t < a6 + 2.8
	var to: Node2D = lhx.node.J["torso"]
	lhx.hold["F"] = [from_w(to, Vector2(BE.x, BE_TOP - 24.0)), maxf(put, pick)]
	ho.node.visible = not on_be
	# --- nội lực lạ: ôm ngực, nhăn mặt
	var dau := bump(a2 + 0.3, a2 + 0.8, a3 - 0.6, a3 - 0.1)
	lhx.hold["B"] = [Vector2(20, -70), dau]
	# --- suy nghĩ rồi lắc đầu, đẩy nhẹ cuốn kinh về
	var nghi := bump(a5 + 0.2, a5 + 0.6, a5 + 2.4, a5 + 2.8)
	var day := bump(a5 + 2.9, a5 + 3.3, a5 + 5.6, a5 + 6.0)
	var lac := _lac(13.0, a5 + 2.6, a5 + 5.4) + _lac(10.0, a5b + 0.6, a5b + 4.8)
	var cui := bump(a6 + 0.2, a6 + 0.6, a6 + 1.4, a6 + 1.8)
	var uong := bump(a7 + 1.4, a7 + 1.9, a7 + 4.4, a7 + 4.9)
	lhx.extra = [[{"torso": 10.0, "head": 12.0}, dau], [{"head": -8.0}, nghi], [arms_of("palm"), day * 0.6],
		[{"head": lac}, 1.0], [{"torso": 30.0, "head": 18.0}, cui], [{"head": -16.0, "torso": -6.0}, uong]]
	if nghi > 0.1:
		lhx.hold["B"] = [Vector2(48, -128), nghi]
	if uong > 0.01:
		lhx.hold["F"] = [Vector2(54, -30).lerp(_lips(lhx, Vector2(12, -10)), uong), uong]
	ho.lock = uong
	ho.lockdir = Vector2.DOWN.lerp(Vector2(0.75, -0.66), uong).normalized()
	lhx.expr = "vui"
	if dau > 0.3:
		lhx.expr = "ngai"
	elif t > a3 and t < a5:
		lhx.expr = "soc" if t > a4 + 0.4 else "binh"
	elif nghi > 0.3:
		lhx.expr = "binh"
	elif t > a5 + 2.6 and t < a6:
		lhx.expr = "quyet-tam" if t < a5b + 4.8 else "vui"
	elif t > a7 and uong < 0.3:
		lhx.expr = "binh"
	# --- quay về bệ đá lấy hồ lô, ngồi nhấp một ngụm
	if t > a6 + 1.6 and _once("ve_be"):
		lhx.speed = 220.0
		lhx.go = Vector2(BE.x + 120.0, ground_y)
	if t > a6 + 3.6:
		lhx.face = -1.0 if t < a7 + 0.6 else 1.0
	# --- phương trượng bước ra cổng, xuống bậc
	pc.show = smooth(a3 - 1.0, a3 - 0.3, t)
	if t > a3 - 0.6 and _once("pc_ra"):
		pc.speed = 90.0
		pc.go = Vector2(1080, ground_y)
	var sz := lerpf(0.9, 1.0, smooth(a3 - 0.6, a3 + 1.6, t))
	pc.size = sz
	var dua := smooth(a4 - 0.2, a4 + 0.5, t) * (1.0 - smooth(a6 - 0.6, a6, t))
	var chap := bump(a3 + 1.6, a3 + 2.0, a4 - 0.6, a4 - 0.2) + bump(a6 + 0.2, a6 + 0.6, a6 + 1.6, a6 + 2.0)
	_chap(pc, chap)
	if dua > 0.0:
		pc.hold["F"] = [Vector2(96, -96), dua]
	if t > a6 + 0.5:
		pc.face = -1.0
	var truyen := smooth(a7 + 0.4, a7 + 1.2, t)
	if truyen > 0.0:
		pc.hold["F"] = [Vector2(90, -110).lerp(Vector2(98, -60), 1.0 - truyen), truyen]
	pc.extra = [[{"torso": 16.0, "head": 14.0}, chap], [{"head": -4.0}, dua]]
	pc.expr = "vui" if t < a5 + 2.6 else ("buon" if t < a6 + 0.2 else ("binh" if t < a7 else "vui"))
	pc.talk = on("k16-03") * 0.4 + on("k16-04") * 0.3


func _book_pos() -> Vector2:
	return to_w(pc.node.J["hdF"], Vector2(0, 14))


func _c16() -> Array:
	var a2 := L("k16-02")
	var a3 := L("k16-03")
	var a5b := L("k16-05b")
	var a6 := L("k16-06")
	var a7 := L("k16-07")
	var wide := [Vector2(960, 600), 1.0]
	var hd := head_of(lhx)
	if t < a2:
		return [Vector2(620, 640).lerp(wide[0], smooth(L("k16-01") + 3.0, a2, t)), lerpf(1.25, 1.0, smooth(L("k16-01") + 3.0, a2, t))]
	if t < a3 - 1.0:
		var k := smooth(a2, a2 + 1.4, t)
		return [Vector2(960, 600).lerp(Vector2(hd.x, hd.y + 120.0), k), lerpf(1.0, 1.6, k)]
	if t >= a5b and t < a6:
		var k := smooth(a5b, a5b + 1.2, t)
		var mid := (hd + head_of(pc)) * 0.5
		return [Vector2(960, 600).lerp(Vector2(mid.x - 60.0, hd.y + 70.0), k), lerpf(1.0, 1.85, k)]
	if t >= a7:
		var k := smooth(a7, a7 + 2.0, t)
		return [Vector2(960, 600).lerp(Vector2(760, 620), k), lerpf(1.0, 0.92, k)]
	return [Vector2(960, 600), lerpf(1.08, 1.0, smooth(a3 - 1.0, a3, t))]


func _g16(c: Node2D) -> void:
	var gy := ground_y
	# sân lát đá
	c.draw_rect(Rect2(-3000, gy, 7000, 600), Color("#b7a98a"))
	for i in 30:
		var y := gy + 14.0 + i * 22.0
		c.draw_line(Vector2(-3000, y), Vector2(4000, y), Color(ink, 0.18), 2.0)
	for i in 50:
		var x := -2000.0 + i * 120.0 + (i % 2) * 40.0
		c.draw_line(Vector2(x, gy), Vector2(x - 60.0, gy + 120.0), Color(ink, 0.15), 2.0)
	# tường vàng hai bên
	for sd: float in [-1.0, 1.0]:
		var x0 := 960.0 + sd * 330.0
		var x1 := 960.0 + sd * 2400.0
		var wall := PackedVector2Array([Vector2(x0, gy - 64), Vector2(x0, gy - 420), Vector2(x1, gy - 420), Vector2(x1, gy - 64)])
		shape(c, wall, Color("#d9a85a"), 4.0)
		hatch(c, wall, 1.57, 30.0, Color(ink, 0.12))
		shape(c, PackedVector2Array([Vector2(x0, gy - 420), Vector2(x0 - sd * 20, gy - 470), Vector2(x1, gy - 470), Vector2(x1, gy - 420)]), Color("#5a4632"), 3.0)
	# bậc thềm
	for i in 3:
		var w := 760.0 - i * 80.0
		var y := gy - i * 22.0
		shape(c, PackedVector2Array([Vector2(960 - w * 0.5, y), Vector2(960 - w * 0.5, y - 22), Vector2(960 + w * 0.5, y - 22), Vector2(960 + w * 0.5, y)]), STONE.lightened(0.08 * i), 3.0)
	# cổng: cột đỏ, cửa gỗ mở hé, bóng tối bên trong
	var top := gy - 600.0
	c.draw_rect(Rect2(780, top + 140, 360, 396), Color("#2a1a12"))
	for i in 5:
		c.draw_circle(Vector2(960, gy - 140 - i * 40), 30.0 + i * 16.0, Color(1.0, 0.8, 0.4, 0.04))
	var mo := smooth(L("k16-03") - 2.0, L("k16-03") - 0.8, t) * 70.0
	for sd: float in [-1.0, 1.0]:
		var dx0 := 960.0 + sd * (4.0 + mo)
		var door := PackedVector2Array([Vector2(dx0, gy - 64), Vector2(dx0, top + 140), Vector2(dx0 + sd * (176.0 - mo * 0.6), top + 140), Vector2(dx0 + sd * (176.0 - mo * 0.6), gy - 64)])
		shape(c, door, RED_GATE.darkened(0.15), 3.0)
		for j in 4:
			for k in 3:
				c.draw_circle(Vector2(dx0 + sd * (36.0 + k * 50.0) * (1.0 - mo / 240.0), top + 200 + j * 80), 6.0, Color("#d8b25a"))
	for sd: float in [-1.0, 1.0]:
		var px := 960.0 + sd * 210.0
		shape(c, PackedVector2Array([Vector2(px - 26, gy - 64), Vector2(px - 26, top + 100), Vector2(px + 26, top + 100), Vector2(px + 26, gy - 64)]), RED_GATE, 4.0)
		hatch(c, PackedVector2Array([Vector2(px + 4, gy - 64), Vector2(px + 4, top + 100), Vector2(px + 26, top + 100), Vector2(px + 26, gy - 64)]), 1.2, 12.0, Color(ink, 0.25))
	# mái cong hai tầng
	for lv in 2:
		var yy := top + 100.0 - lv * 120.0
		var hw := 400.0 - lv * 90.0
		var roof := PackedVector2Array([Vector2(960 - hw - 60, yy + 10), Vector2(960 - hw, yy - 40), Vector2(960 + hw, yy - 40), Vector2(960 + hw + 60, yy + 10), Vector2(960 + hw - 20, yy - 6), Vector2(960 - hw + 20, yy - 6)])
		shape(c, roof, Color("#3e4a3e"), 4.0)
		for i in 18:
			var x := 960.0 - hw + i * hw * 2.0 / 17.0
			c.draw_line(Vector2(x, yy - 38), Vector2(x, yy - 8), Color(ink, 0.5), 2.0)
		c.draw_rect(Rect2(960 - hw + 20, yy - 6, hw * 2.0 - 40, 46), Color("#6b3a24"))
	# biển chùa
	shape(c, PackedVector2Array([Vector2(820, top + 60), Vector2(1100, top + 60), Vector2(1100, top + 130), Vector2(820, top + 130)]), Color("#2a2a2a"), 4.0)
	var txt := "THIẾU LÂM TỰ"
	var tw := font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 38).x
	c.draw_string(font, Vector2(960 - tw * 0.5, top + 108), txt, HORIZONTAL_ALIGNMENT_LEFT, -1, 38, Color("#e8c25a"))
	# bệ đá gửi hồ lô (bên trái), cây tùng già bên phải
	var be := PackedVector2Array([Vector2(BE.x - 70, gy), Vector2(BE.x - 60, BE_TOP), Vector2(BE.x + 60, BE_TOP), Vector2(BE.x + 70, gy)])
	shape(c, be, STONE, 4.0)
	hatch(c, be, 0.8, 14.0, Color(ink, 0.25))
	shape(c, PackedVector2Array([Vector2(BE.x - 80, BE_TOP), Vector2(BE.x - 80, BE_TOP - 16), Vector2(BE.x + 80, BE_TOP - 16), Vector2(BE.x + 80, BE_TOP)]), STONE.lightened(0.1), 3.0)
	pine(c, Vector2(1640, gy - 40), 520.0, 260.0, Color("#3e5a3e"), 0.0, 4.0, 3)
	tree(c, Vector2(-120, gy - 40), 460.0, 200.0, Color("#c8862e"), Color("#4a3020"), 7)


func _n16(c: Node2D) -> void:
	var a1 := L("k16-01")
	var a6 := L("k16-06")
	if t > a1 + 2.0 and t < a6 + 2.8:
		holo(c, Vector2(BE.x, BE_TOP - 16.0 - 56.0 * 0.9), 0.9, Color("#d9a441"), 0.0)
	# cuốn kinh trong tay phương trượng
	var a4 := L("k16-04")
	var dua := smooth(a4 - 0.2, a4 + 0.5, t) * (1.0 - smooth(L("k16-06") - 0.6, L("k16-06"), t))
	if dua > 0.01:
		var bp := _book_pos()
		var sz := 0.6 + 0.4 * dua
		c.draw_set_transform(bp, -0.12, Vector2(sz, sz))
		shape(c, PackedVector2Array([Vector2(-44, -30), Vector2(44, -30), Vector2(44, 30), Vector2(-44, 30)]), Color("#d8b25a"), 4.0)
		c.draw_rect(Rect2(-30, -24, 20, 48), Color("#7a2a1a"))
		for i in 4:
			c.draw_line(Vector2(0, -18 + i * 12), Vector2(36, -18 + i * 12), Color(ink, 0.5), 2.0)
		for i in 4:
			c.draw_circle(Vector2(-40, -20 + i * 13), 3.0, ink)
		c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _gl16(c: Node2D) -> void:
	var a2 := L("k16-02")
	var a3 := L("k16-03")
	var dau := bump(a2 + 0.3, a2 + 0.8, a3 - 0.6, a3 - 0.1)
	if dau > 0.01:
		# nội lực lạ: hai luồng đỏ – lam vặn xoắn quanh thân, giành nhau
		var ctr := to_w(lhx.node.J["torso"], Vector2(0, -60))
		for s in 8:
			var col := Color(1.6, 0.35, 0.25) if s % 2 == 0 else Color(0.35, 0.7, 1.6)
			var pts := PackedVector2Array()
			for i in 22:
				var k := i / 21.0
				var an := t * (2.2 + s * 0.3) * (1.0 if s % 2 == 0 else -1.0) + k * 5.0 + s
				var r := 60.0 + k * 70.0 + sin(t * 4.0 + s + k * 7.0) * 18.0
				pts.append(ctr + Vector2(cos(an) * r, sin(an) * r * 0.75 - k * 40.0))
			c.draw_polyline(pts, Color(col, 0.22 * dau), 5.0, true)
	var bk := smooth(L("k16-04") - 0.2, L("k16-04") + 0.5, t) * (1.0 - smooth(L("k16-05") + 3.0, L("k16-06"), t))
	if bk > 0.01:
		var bp := _book_pos()
		for i in 5:
			c.draw_circle(bp, 30.0 + i * 22.0, Color(1.4, 1.1, 0.5, 0.06 * bk))
		rays(c, bp, -PI * 0.5, PI * 2.0, 12, 140.0 * bk, Color(1.3, 1.1, 0.5, 0.12 * bk), 5)
	var a7 := L("k16-07")
	var tr := smooth(a7 + 0.8, a7 + 1.8, t) * (1.0 - smooth(LE("k16-07") + 0.2, LE("k16-07") + 0.8, t))
	if tr > 0.01:
		# nội công âm thầm: một sợi sáng vàng từ lòng bàn tay phương trượng tới lưng chàng
		var p0 := to_w(pc.node.J["hdF"], Vector2(0, 10))
		var p1 := to_w(lhx.node.J["torso"], Vector2(-20, -60))
		var pts := PackedVector2Array()
		for i in 30:
			var k := i / 29.0
			var p := p0.lerp(p1, k) + Vector2(0, -sin(k * PI) * 140.0 + sin(k * 18.0 - t * 6.0) * 6.0)
			pts.append(p)
		c.draw_polyline(pts, Color(1.4, 1.1, 0.5, 0.35 * tr), 6.0, true)
		c.draw_polyline(pts, Color(1.6, 1.4, 1.0, 0.5 * tr), 2.0, true)
		for j in 4:
			var k := fmod(t * 0.5 + j * 0.25, 1.0)
			var idx := int(k * 29.0)
			c.draw_circle(pts[idx], 9.0, Color(1.6, 1.3, 0.7, 0.5 * tr))
		for i in 4:
			c.draw_circle(p1, 20.0 + i * 18.0, Color(1.3, 1.0, 0.5, 0.07 * tr))


# ---------------------------------------------------------------- k16b: hai lời mời

const LAT_X := 1040.0                # ô cửa song gỗ nơi Doanh Doanh ở lại


func _s16b(_dt: float) -> void:
	var b1 := L("k16b-01")
	var b2 := L("k16b-02")
	var b3 := L("k16b-03")
	var b4 := L("k16b-04")
	var b5 := L("k16b-05")
	var b6 := L("k16b-06")
	var b7 := L("k16b-07")
	# --- Doanh Doanh cõng chàng tới chùa, đặt xuống chiếu, quỳ xin phương trượng
	var dat := b1 + 3.6
	if _once("cong"):
		dd.speed = 170.0
		dd.go = Vector2(600, ground_y)
	if t < dat:
		var fc: float = dd.face
		lhx.pos = dd.pos + Vector2(-fc * 30.0, -80.0 + sin(dd.ph * 2.0) * 3.0)
		lhx.face = fc
		lhx.rot = 0.0
		lhx.extra = [[{"thF": -70.0, "shF": 96.0, "thB": -56.0, "shB": 92.0, "torso": 34.0, "head": 26.0, "uaF": -60.0, "faF": -40.0,
			"uaB": -50.0, "faB": -30.0}, 1.0]]
		lhx.expr = "buon"
		dd.extra = [[{"torso": 20.0, "head": 4.0}, 1.0]]
		dd.hold["F"] = [Vector2(-10, -40), 0.7]
		dd.hold["B"] = [Vector2(-16, -36), 0.7]
		dd.expr = "quyet-tam"
	elif t < b3 + 1.0:
		lhx.pos = Vector2(470, ground_y - 22.0)
		lhx.rot = -PI * 0.5
		lhx.face = 1.0
		lhx.extra = [[{"head": 10.0}, 1.0]]
		lhx.expr = "buon"
		dd.hold = {}
	# quỳ trước phương trượng (b1+4 → b2), rồi vào sau song cửa
	var quy := bump(dat + 0.3, dat + 0.8, b2 - 0.6, b2 - 0.1)
	if t >= dat:
		dd.extra = [["kneel", quy], [{"torso": 6.0, "head": 12.0}, quy]]
		_chap(dd, quy)
		dd.face = 1.0
		dd.expr = "ngai" if quy > 0.5 else "binh"
	if t > b2 - 0.1 and _once("vao_song"):
		dd.speed = 160.0
		dd.go = Vector2(LAT_X, ground_y)
	if t > b2 + 3.0 and t < b3 + 3.4:
		dd.face = -1.0
		dd.expr = "binh"
	# phương trượng đặt tay trên người chàng
	var tri := bump(dat + 1.0, dat + 1.6, b3 - 0.8, b3 - 0.2)
	pc.extra = [[{"torso": 10.0, "head": 14.0}, tri]]
	pc.hold["F"] = [Vector2(80, -40), tri]
	if t > b2 + 0.4 and _once("pc_lui"):
		pc.speed = 110.0
		pc.go = Vector2(300, ground_y)
		pc.face = -1.0
	pc.expr = "binh" if tri < 0.5 else "buon"
	# --- chàng khỏi, dẫn đoàn hảo hán tới đón; nàng bước ra
	if t > b3 + 1.0 and _once("dung"):
		lhx.rot = 0.0
		lhx.pos = Vector2(2300, ground_y)
		lhx.face = -1.0
		lhx.extra = []
		lhx.speed = 190.0
		lhx.go = Vector2(1300, ground_y)
	if t > b3 + 1.0 and t < b4:
		lhx.expr = "quyet-tam"
		lhx.extra = [[{"uaF": -150.0, "faF": -20.0}, bump(b3 + 4.2, b3 + 4.6, b4 - 0.4, b4)]]
	if t > b3 + 4.0 and _once("ra_song"):
		dd.speed = 150.0
		dd.go = Vector2(1200, ground_y)
	# --- cả hai sang ngai Nhật Nguyệt
	if t > b4 - 0.2 and _once("sang_ngai"):
		lhx.speed = 240.0
		lhx.go = Vector2(2160, ground_y)
		dd.speed = 240.0
		dd.go = Vector2(2010, ground_y)
	if t > b4 + 4.0:
		lhx.face = 1.0
		dd.face = 1.0
	# --- Nhậm Ngã Hành trên ngai: mời, chỉ vào ghế cao bên cạnh
	ngoi(nng, g_nng)
	var moi := bump(b4 + 1.4, b4 + 1.8, b5 + 1.6, b5 + 2.0)
	nng.extra = [[NGOI_TUONG, 1.0], [{"torso": 8.0}, 1.0], [arms_of("point"), moi], [{"head": -6.0}, moi]]
	nng.expr = "dac-y" if t < b5 + 1.2 else ("soc" if t < b6 else "gian")
	nng.talk = on("k16b-04") * 0.35
	# --- chàng lắc đầu, tay đặt lên vai nàng
	var lac := _lac(12.0, b5 + 0.3, b5 + 3.6) + _lac(12.0, b6 + 1.2, b6 + 2.6) + _lac(12.0, b6 + 3.2, b6 + 4.6)
	var uong := bump(b7 + 1.6, b7 + 2.1, b7 + 4.6, b7 + 5.1)
	if t > b4 + 3.0:
		var ex := [[{"head": lac}, 1.0], [arms_of("palm"), bump(b5 + 0.4, b5 + 0.8, b5 + 3.4, b5 + 3.8) * 0.7],
			[{"head": -16.0, "torso": -6.0}, uong]]
		lhx.extra = ex
		lhx.expr = "quyet-tam" if t < b6 + 5.0 else "vui"
		lhx.hold["F"] = [Vector2(54, -30).lerp(_lips(lhx, Vector2(12, -10)), uong), uong]
		dd.expr = "ngai" if t < b5 + 2.0 else "vui"
		dd.extra = [[{"head": -10.0}, 1.0]]
	if t > b7 + 1.0 and _once("rut_ho"):
		prop_to(ho, "tay", "F")
	ho.lock = uong
	ho.lockdir = Vector2.DOWN.lerp(Vector2(0.75, -0.66), uong).normalized()


func _c16b() -> Array:
	var b1 := L("k16b-01")
	var b2 := L("k16b-02")
	var b3 := L("k16b-03")
	var b4 := L("k16b-04")
	var b6 := L("k16b-06")
	var b7 := L("k16b-07")
	if t < b2:
		var k := smooth(b1, b1 + 3.6, t)
		return [Vector2(lerpf(300.0, 640.0, k), 640.0), 1.15]
	if t < b3:
		var k := smooth(b2, b2 + 1.6, t)
		return [Vector2(640, 640).lerp(Vector2(LAT_X, 600.0), k), lerpf(1.15, 1.55, k)]
	if t < b4:
		var k := smooth(b3, b3 + 2.0, t)
		return [Vector2(LAT_X, 600.0).lerp(Vector2(1500, 620), k), lerpf(1.55, 0.95, k)]
	if t < b6:
		var k := smooth(b4, b4 + 2.6, t)
		return [Vector2(1500, 620).lerp(Vector2(2340, 640), k), lerpf(0.95, 1.12, k)]
	if t < b7:
		var k := smooth(b6, b6 + 1.8, t)
		return [Vector2(2340, 640).lerp(Vector2(1580, 690), k), lerpf(1.12, 0.62, k)]
	var k := smooth(b7, b7 + 1.8, t)
	return [Vector2(1580, 690).lerp(Vector2(2100, 660), k), lerpf(0.62, 1.4, k)]


func _b16b(c: Node2D) -> void:
	# xa xa: rặng núi; trái mái chùa, phải vách đá đen của Hắc Mộc Nhai
	var pts := _mt([[-1200, 560], [-400, 400], [400, 470], [1200, 360], [2000, 300], [2800, 240], [3600, 380]], 900.0)
	shape(c, pts, air(Color("#8a8a76"), 0.5), 3.0)
	hatch(c, pts, 0.3, 26.0, Color(ink, 0.1))


func _g16b(c: Node2D) -> void:
	var gy := ground_y
	c.draw_rect(Rect2(-3000, gy, 9000, 600), Color("#a89a7c"))
	hatch(c, PackedVector2Array([Vector2(-3000, gy), Vector2(6000, gy), Vector2(6000, gy + 400), Vector2(-3000, gy + 400)]), 0.1, 26.0, Color(ink, 0.18))
	# --- sân chùa (x -400…1350): tường vàng, mái, chuông, chiếu chữa bệnh
	var wall := PackedVector2Array([Vector2(-600, gy), Vector2(-600, gy - 460), Vector2(1350, gy - 460), Vector2(1350, gy)])
	shape(c, wall, Color("#d9a85a"), 4.0)
	hatch(c, wall, 1.57, 34.0, Color(ink, 0.1))
	shape(c, PackedVector2Array([Vector2(-660, gy - 450), Vector2(-600, gy - 520), Vector2(1350, gy - 520), Vector2(1420, gy - 450)]), Color("#3e4a3e"), 4.0)
	# ô cửa song: nền tối phía sau nàng
	c.draw_rect(Rect2(LAT_X - 150, gy - 380, 300, 380), Color("#3a2618"))
	shape(c, PackedVector2Array([Vector2(LAT_X - 170, gy - 400), Vector2(LAT_X + 170, gy - 400), Vector2(LAT_X + 170, gy - 380), Vector2(LAT_X - 170, gy - 380)]), Color("#6b3a24"), 3.0)
	# chuông đồng treo
	c.draw_line(Vector2(140, gy - 460), Vector2(140, gy - 380), ink, 4.0)
	puff(c, [[Vector2(140, gy - 330), 50.0]], Color("#8a6a3a"), 4.0, 0.3)
	c.draw_rect(Rect2(90, gy - 300, 100, 20), Color("#6a4a2a"))
	# chiếu
	shape(c, PackedVector2Array([Vector2(330, gy + 6), Vector2(360, gy - 12), Vector2(640, gy - 12), Vector2(620, gy + 6)]), Color("#c8b27a"), 3.0)
	# --- đường đất giữa (1350…2100): cỏ, cờ đoàn hảo hán
	grass(c, 1360.0, 2100.0, gy, 26.0, 26.0, Color("#6b7a4a"), 4)
	# --- ngai Nhật Nguyệt (x 2300…3100): bục, cờ nhật nguyệt, vách đá đen
	var cliff := PackedVector2Array([Vector2(2280, gy), Vector2(2320, gy - 520), Vector2(2560, gy - 620), Vector2(2900, gy - 560), Vector2(3200, gy - 600), Vector2(3400, gy)])
	shape(c, cliff, Color("#3a3a40"), 4.0)
	hatch(c, cliff, 1.1, 18.0, Color(0, 0, 0, 0.25))
	shape(c, PackedVector2Array([Vector2(2440, gy), Vector2(2470, gy - 50), Vector2(2780, gy - 50), Vector2(2810, gy)]), Color("#5a2a22"), 4.0)
	for sd: float in [-1.0, 1.0]:
		var fx := 2620.0 + sd * 230.0
		c.draw_line(Vector2(fx, gy - 50), Vector2(fx, gy - 460), Color("#2a1a12"), 6.0)
		flag(c, Vector2(fx, gy - 450), 130.0 * -sd, 90.0, Color("#b8322c"))
	# nhật nguyệt sau ngai
	c.draw_circle(Vector2(2620, gy - 420), 62.0, Color("#e8a03a"))
	c.draw_circle(Vector2(2620, gy - 420), 62.0, Color(ink, 0.8), false, 4.0)
	c.draw_circle(Vector2(2650, gy - 432), 44.0, Color("#3a3a40"))
	ghe_ve(c, g_nng)
	# --- đoàn hảo hán: bóng người cầm đuốc, cờ, đi về phía chùa
	var b3 := L("k16b-03")
	var adv := smooth(b3 + 0.4, b3 + 5.0, t)
	if t > b3:
		for i in 14:
			var x0 := 2600.0 + (i % 7) * 120.0 + (i / 7) * 60.0
			var x := lerpf(x0, x0 - 1050.0, adv)
			var row := float(i / 7)
			_hao(c, Vector2(x, gy - 6.0 - row * 30.0), 0.9 - row * 0.12, i, t * 9.0 * (1.0 if adv < 0.99 else 0.0))


# bóng một hảo hán: thân thang, đầu tròn búi tóc, đuốc hoặc cờ
func _hao(c: Node2D, p: Vector2, s: float, seed: int, ph: float) -> void:
	var cols := [Color("#5a4a3a"), Color("#6a3a2a"), Color("#3a4a5a"), Color("#4a5a3a")]
	var col: Color = cols[seed % 4]
	var bob := absf(sin(ph + seed)) * 6.0
	var q := p + Vector2(0, -bob)
	var body := PackedVector2Array([q + Vector2(-34, 0) * s, q + Vector2(-24, -110) * s, q + Vector2(24, -110) * s, q + Vector2(34, 0) * s])
	shape(c, body, col, 3.0)
	c.draw_circle(q + Vector2(0, -150) * s, 42.0 * s + 3.0, ink)
	c.draw_circle(q + Vector2(0, -150) * s, 42.0 * s, Color("#d8a878"))
	c.draw_circle(q + Vector2(0, -196) * s, 14.0 * s, Color("#1a1414"))
	c.draw_circle(q + Vector2(-12, -150) * s, 4.0 * s, ink)
	c.draw_line(q + Vector2(-18, -128) * s, q + Vector2(-4, -126) * s, ink, 2.0)
	if seed % 3 == 0:
		c.draw_line(q + Vector2(-30, -80) * s, q + Vector2(-40, -260) * s, Color("#2a1a12"), 5.0)
		flag(c, q + Vector2(-40, -258) * s, 70.0 * s, 46.0 * s, Color("#c8862e"))
	else:
		c.draw_line(q + Vector2(-30, -80) * s, q + Vector2(-44, -200) * s, Color("#4a3020"), 6.0)
		var fl := q + Vector2(-44, -214) * s
		c.draw_colored_polygon(PackedVector2Array([fl + Vector2(-12, 10) * s, fl + Vector2(sin(t * 9.0 + seed) * 6.0, -34) * s, fl + Vector2(12, 10) * s]), Color("#f0a030"))
		c.draw_circle(fl + Vector2(0, 4) * s, 8.0 * s, Color("#ffe080"))


func _n16b(c: Node2D) -> void:
	# song cửa gỗ phủ trước nàng (chỉ khi nàng còn trong chùa)
	var gy := ground_y
	var k := 1.0 - smooth(L("k16b-03") + 4.0, L("k16b-03") + 4.6, t)
	if t > L("k16b-02") - 0.4:
		for i in 7:
			var x := LAT_X - 140.0 + i * 46.7
			c.draw_rect(Rect2(x - 6, gy - 380, 12, 380 * k), Color("#6b3a24"))
			c.draw_rect(Rect2(x - 6, gy - 380, 12, 380 * k), Color(ink, 0.8), false, 2.0)
		for j in 3:
			c.draw_rect(Rect2(LAT_X - 150, gy - 340 + j * 120, 300, 10), Color("#6b3a24"))
	# dòng rượu nhạt
	var b7 := L("k16b-07")
	_dong(c, ho, lhx, PALE, bump(b7 + 2.1, b7 + 2.3, b7 + 4.3, b7 + 4.5))


func _sc16b(c: Node2D) -> void:
	var b6 := L("k16b-06")
	var b7 := L("k16b-07")
	var a1 := bump(b6 + 0.8, b6 + 1.2, b7 - 0.2, b7 + 0.2)
	var a2 := bump(b6 + 2.4, b6 + 2.8, b7 - 0.2, b7 + 0.2)
	# toạ độ màn hình của hai nơi theo máy quay đang giữ
	var p1 := (Vector2(400, 330) - cam) * zoom + CENTER
	var p2 := (Vector2(2620, 330) - cam) * zoom + CENTER
	nhan(c, p1, "Thiếu Lâm", 46, Color("#b8322c"), a1, -0.03)
	nhan(c, p2, "Nhật Nguyệt thần giáo", 46, Color("#3a3a40"), a2, 0.03)
	# hai nét gạch: từ chối
	for pr in [[p1, a1, b6 + 1.6], [p2, a2, b6 + 3.2]]:
		var p: Vector2 = pr[0]
		var al: float = pr[1]
		var k := smooth(float(pr[2]), float(pr[2]) + 0.25, t)
		if al > 0.01 and k > 0.0:
			var a := p + Vector2(-150, -40)
			var b := p + Vector2(150, 40)
			c.draw_line(a, a.lerp(b, k), Color(ink, al), 12.0, true)


# ---------------------------------------------------------------- k17: phái Hằng Sơn

const NI_ROW := [[620.0, 860.0], [1300.0, 860.0]]   # [x đầu, y chân] (không dùng y)
const HALL_X := 4300.0


func _s17(_dt: float) -> void:
	var c1 := L("k17-01")
	var c2 := L("k17-02")
	var c3 := L("k17-03")
	var c4 := L("k17-04")
	var c4b := L("k17-04b")
	# --- loạng choạng đi vào giữa hai hàng ni cô
	if _once("vao"):
		lhx.speed = 150.0
		lhx.go = Vector2(860, ground_y)
	var say := 1.0 - smooth(c2 + 1.0, c2 + 1.6, t) * (1.0 - smooth(c3, c3 + 0.6, t))
	say *= 1.0 - smooth(c4, c4 + 0.6, t)
	var wob := sin(t * 2.3) * 0.08 + sin(t * 3.7) * 0.04
	lhx.rot = wob * say
	var hic := bump(c3 + 1.6, c3 + 1.75, c3 + 1.9, c3 + 2.2) + bump(c3 + 4.0, c3 + 4.15, c3 + 4.3, c3 + 4.6)
	var vai := bump(c2 + 1.6, c2 + 2.0, c2 + 3.6, c2 + 4.0)
	var cui := bump(c4 + 0.8, c4 + 1.2, c4 + 2.6, c4 + 3.0)
	lhx.extra = [[{"head": sin(t * 2.3 + 1.0) * 8.0 * say, "torso": -6.0 * say}, 1.0], [{"all": [0.0, -hic * 10.0, 0.0], "head": -hic * 8.0}, 1.0],
		[{"torso": 26.0, "head": 16.0}, maxf(vai, cui)]]
	_chap(lhx, maxf(vai, cui))
	lhx.expr = "vui" if say > 0.5 else ("buon" if vai > 0.3 else "binh")
	if hic > 0.3:
		lhx.expr = "soc"
	if t > c2 and t < c3:
		lhx.face = 1.0
	if t > c3 + 1.2:
		lhx.face = -1.0
	if t > c4 - 0.3 and _once("cat_ho"):
		prop_to(ho, "hong", "F")
	if t > c2 + 0.6 and t < c3 and _once("toi_ban_tho"):
		lhx.speed = 120.0
		lhx.go = Vector2(1500, ground_y)
	if t > c3 + 0.2 and _once("ve_giua"):
		lhx.speed = 120.0
		lhx.go = Vector2(1100, ground_y)
	# --- Nghi Lâm: chắp tay, liếc, đỏ mặt
	var lk := bump(c3 + 2.4, c3 + 2.8, c4 - 0.3, c4)
	nl.extra = [[{"head": 10.0 - lk * 14.0, "torso": 6.0}, 1.0], [{"torso": 22.0, "head": 14.0}, cui]]
	_chap(nl, 1.0)
	ma.amount = smooth(c3 + 2.6, c3 + 3.6, t)
	nl.expr = "ngai" if lk > 0.3 else "binh"
	nl.face = -1.0 if lhx.pos.x < nl.pos.x else 1.0
	# --- năm ghế Ngũ Nhạc: chàng ngồi ghế cuối, bập bênh
	var g: Dictionary = g5[4]
	g.rock = 0.1 + 0.07 * sin(t * 1.9)
	ngoi(lhx5, g)
	lhx5.extra = [[NGOI_BAP_BENH, 1.0], [{"head": sin(t * 3.0) * 4.0}, 1.0]]
	lhx5.expr = "vui" if fmod(t, 3.4) < 2.4 else "dac-y"
	lhx5.show = 1.0 if t > c4b - 0.6 else 0.0
	lhx.show = 1.0 if t < c4b - 0.3 else 0.0


func _c17() -> Array:
	var c2 := L("k17-02")
	var c3 := L("k17-03")
	var c4 := L("k17-04")
	var c4b := L("k17-04b")
	if t >= c4b - 0.3:
		var k := smooth(c4b, c4b + 4.0, t)
		return [Vector2(HALL_X + 600.0, 640.0).lerp(Vector2(HALL_X + 680.0, 660.0), k), lerpf(0.95, 1.05, k)]
	if t < c2:
		return [Vector2(960, 600), lerpf(1.0, 0.92, smooth(0.0, L("k17-01") + 2.0, t))]
	if t < c3:
		var k := smooth(c2, c2 + 1.6, t)
		return [Vector2(960, 600).lerp(Vector2(1560, 640), k), lerpf(0.92, 1.3, k)]
	if t < c4:
		var k := smooth(c3, c3 + 2.4, t)
		var hd := head_of(nl)
		return [Vector2(1560, 640).lerp(Vector2(hd.x - 70.0, hd.y + 110.0), k), lerpf(1.3, 1.65, k)]
	var k := smooth(c4, c4 + 1.4, t)
	return [Vector2(1050, 600).lerp(Vector2(960, 590), k), lerpf(1.4, 0.95, k)]


# một ni cô vẽ khắc gỗ: áo xám, mũ tăng ni, mắt hiền; nod = cúi chào
func _ni(c: Node2D, p: Vector2, s: float, seed: int, nod: float, look: float) -> void:
	var sw := sin(t * 1.3 + seed * 1.7) * 2.0
	var q := p + Vector2(sw, 0)
	var body := PackedVector2Array([q + Vector2(-40, 0) * s, q + Vector2(-28, -112) * s, q + Vector2(28, -112) * s, q + Vector2(40, 0) * s])
	shape(c, body, ROBE_NI.lightened(0.06 * (seed % 3)), 3.0)
	c.draw_line(q + Vector2(0, -110) * s, q + Vector2(-14, -40) * s, Color(ink, 0.5), 2.0)
	# tay chắp
	c.draw_circle(q + Vector2(0, -74) * s, 11.0 * s, Color("#f4d0b0"))
	var hp := q + Vector2(nod * 14.0, -158 + nod * 18.0) * s
	c.draw_circle(hp, 46.0 * s + 3.0, ink)
	c.draw_circle(hp, 46.0 * s, Color("#f4d6bc"))
	# mũ ni cô
	var cap := PackedVector2Array()
	for i in 13:
		var a := PI + PI * i / 12.0
		cap.append(hp + Vector2(cos(a) * 49.0, sin(a) * 44.0 - 10.0) * s)
	shape(c, cap, Color("#6e6c66"), 3.0)
	var ex := look * 6.0
	for sd: float in [-1.0, 1.0]:
		c.draw_arc(hp + Vector2(sd * 16.0 + ex, 6.0) * s, 7.0 * s, PI * 0.1, PI * 0.9, 6, ink, 3.0)
		c.draw_circle(hp + Vector2(sd * 26.0 + ex, 20.0) * s, 6.0 * s, Color(0.95, 0.5, 0.45, 0.35))
	c.draw_arc(hp + Vector2(ex, 24.0) * s, 7.0 * s, PI * 0.15, PI * 0.85, 6, Color(ink, 0.7), 2.0)


func _g17(c: Node2D) -> void:
	var gy := ground_y
	c.draw_rect(Rect2(-3000, gy, 10000, 600), Color("#8a8478"))
	for i in 40:
		c.draw_line(Vector2(-3000 + i * 260, gy), Vector2(-3200 + i * 300, gy + 300), Color(ink, 0.15), 2.0)
	# chính điện: cột gỗ, xà ngang, rèm trắng
	var back := PackedVector2Array([Vector2(-500, gy), Vector2(-500, gy - 640), Vector2(2400, gy - 640), Vector2(2400, gy)])
	shape(c, back, Color("#d8d4c8"), 4.0)
	for i in 8:
		var x := -300.0 + i * 360.0
		c.draw_rect(Rect2(x, gy - 640, 34, 640), Color("#6e4a2a"))
		c.draw_rect(Rect2(x, gy - 640, 34, 640), Color(ink, 0.8), false, 3.0)
		for j in 6:
			var cx := x + 70.0 + j * 46.0
			c.draw_line(Vector2(cx, gy - 600), Vector2(cx + sin(t * 0.8 + j + i) * 4.0, gy - 200), Color(1, 1, 1, 0.5), 8.0)
	c.draw_rect(Rect2(-500, gy - 660, 2900, 40), Color("#5a3c22"))
	# cửa lớn nhìn ra núi tuyết
	c.draw_rect(Rect2(380, gy - 560, 520, 300), air(Color("#a9b4bc"), 0.2))
	# bàn thờ sư thái Định Nhàn: bài vị, nến, khói hương
	var ax := 1720.0
	shape(c, PackedVector2Array([Vector2(ax - 140, gy), Vector2(ax - 140, gy - 150), Vector2(ax + 140, gy - 150), Vector2(ax + 140, gy)]), Color("#6b3a24"), 4.0)
	shape(c, PackedVector2Array([Vector2(ax - 40, gy - 150), Vector2(ax - 40, gy - 330), Vector2(ax + 40, gy - 330), Vector2(ax + 40, gy - 150)]), Color("#3a2618"), 3.0)
	c.draw_rect(Rect2(ax - 30, gy - 320, 60, 160), Color("#e8d9a8"))
	for i in 5:
		c.draw_line(Vector2(ax - 16, gy - 300 + i * 28), Vector2(ax + 16, gy - 300 + i * 28), Color(ink, 0.55), 3.0)
	for sd: float in [-1.0, 1.0]:
		var cx := ax + sd * 100.0
		c.draw_rect(Rect2(cx - 8, gy - 210, 16, 60), Color("#e8e0d0"))
		c.draw_colored_polygon(PackedVector2Array([Vector2(cx - 6, gy - 212), Vector2(cx + sin(t * 7.0 + sd) * 2.0, gy - 236), Vector2(cx + 6, gy - 212)]), Color("#f0a030"))
	for i in 3:
		var hx := ax - 20.0 + i * 20.0
		c.draw_line(Vector2(hx, gy - 150), Vector2(hx, gy - 190), Color("#8a3a2a"), 2.0)
		var pts := PackedVector2Array()
		for j in 12:
			var k := j / 11.0
			pts.append(Vector2(hx + sin(t * 1.4 + k * 5.0 + i) * 10.0 * k, gy - 190 - k * 160.0))
		c.draw_polyline(pts, Color(1, 1, 1, 0.35), 3.0, true)
	var txt := "Định Nhàn sư thái"
	var c2 := L("k17-02")
	var la := bump(c2 + 0.6, c2 + 1.0, LE("k17-02"), LE("k17-02") + 0.4)
	nhan(c, Vector2(ax, gy - 380), txt, 30, Color("#5a3c22"), la)
	# hai hàng ni cô (hàng sau trên bục)
	var c4 := L("k17-04")
	var nod := bump(c4 + 1.2, c4 + 1.6, c4 + 2.8, c4 + 3.2)
	var lookx := clampf((lhx.pos.x - 960.0) / 500.0, -1.0, 1.0)
	shape(c, PackedVector2Array([Vector2(240, gy - 70), Vector2(1440, gy - 70), Vector2(1460, gy - 20), Vector2(220, gy - 20)]), Color("#7a5a3a"), 3.0)
	for i in 9:
		_ni(c, Vector2(300 + i * 140, gy - 70), 1.05, i, nod, lookx)
	for i in 6:
		var x := 120.0 + i * 130.0 if i < 3 else 1240.0 + (i - 3) * 130.0
		_ni(c, Vector2(x, gy), 1.2, i + 20, nod, lookx)
	# --- phòng họp Ngũ Nhạc: năm ghế, bốn chưởng môn cứng như đá
	_g_ngu_nhac(c)


func _g_ngu_nhac(c: Node2D) -> void:
	var gy := ground_y
	var back := PackedVector2Array([Vector2(HALL_X - 500, gy), Vector2(HALL_X - 500, gy - 700), Vector2(HALL_X + 1900, gy - 700), Vector2(HALL_X + 1900, gy)])
	shape(c, back, Color("#7a6250"), 4.0)
	hatch(c, back, 1.57, 40.0, Color(0, 0, 0, 0.15))
	# năm đỉnh núi treo tường
	var pk := _mt([[HALL_X - 200, 380], [HALL_X + 200, 200], [HALL_X + 600, 280], [HALL_X + 900, 160], [HALL_X + 1200, 280], [HALL_X + 1600, 220], [HALL_X + 1900, 380]], gy - 380.0)
	shape(c, pk, Color("#a08a6a"), 3.0)
	hatch(c, pk, 0.5, 22.0, Color(ink, 0.15))
	var c4b := L("k17-04b")
	nhan(c, Vector2(HALL_X + 600, gy - 560), "Ngũ Nhạc", 48, Color("#b8322c"), smooth(c4b + 0.6, c4b + 1.0, t))
	for i in 5:
		var g: Dictionary = g5[i]
		ghe_ve(c, g)
		if i < 4:
			# chưởng môn ngồi thẳng: bóng khắc gỗ mũ cao
			var p0: Vector2 = g.p + Vector2(float(g.face) * 10.0, -SEAT_H * CS)
			c.draw_set_transform(p0, 0.0, Vector2(1.3, 1.3))
			var p := Vector2.ZERO
			var cols := [Color("#3a5a6a"), Color("#5a3a3a"), Color("#3a3a3a"), Color("#4a5a3a")]
			var col: Color = cols[i]
			shape(c, PackedVector2Array([p + Vector2(-44, 4), p + Vector2(-34, -120), p + Vector2(34, -120), p + Vector2(44, 4)]), col, 3.0)
			shape(c, PackedVector2Array([p + Vector2(-30, 0), p + Vector2(-34, 50), p + Vector2(-10, 50), p + Vector2(-6, 0)]), col.darkened(0.2), 3.0)
			var hp := p + Vector2(0, -170)
			c.draw_circle(hp, 46.0 + 3.0, ink)
			c.draw_circle(hp, 46.0, Color("#e2c0a0"))
			shape(c, PackedVector2Array([hp + Vector2(-26, -36), hp + Vector2(-20, -84), hp + Vector2(20, -84), hp + Vector2(26, -36)]), Color("#2a2a2a"), 3.0)
			var fc: float = g.face
			c.draw_line(hp + Vector2(fc * 4.0 - 14.0, 0), hp + Vector2(fc * 4.0 - 4.0, 0), ink, 4.0)
			c.draw_line(hp + Vector2(fc * 4.0 + 6.0, 0), hp + Vector2(fc * 4.0 + 16.0, 0), ink, 4.0)
			c.draw_line(hp + Vector2(-10, 22), hp + Vector2(10, 22), ink, 3.0)
			c.draw_colored_polygon(PackedVector2Array([hp + Vector2(-12, 28), hp + Vector2(12, 28), hp + Vector2(0, 70)]), Color("#2a2a2a"))
			# liếc sang gã say
			var gl := bump(c4b + 2.0, c4b + 2.4, c4b + 4.6, c4b + 5.0)
			if gl > 0.3:
				c.draw_circle(hp + Vector2(18, -2), 3.0, Color(1, 1, 1, 0.9))
			c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _n17(c: Node2D) -> void:
	# bọt nấc rượu
	var c3 := L("k17-03")
	for e: float in [c3 + 1.7, c3 + 4.1]:
		var k := (t - e) / 1.4
		if k > 0.0 and k < 1.0:
			var hp := head_of(lhx)
			for i in 3:
				var p := hp + Vector2(40 + i * 16, -20 - k * 90.0 - i * 26.0)
				c.draw_circle(p, (8.0 + i * 3.0) * (1.0 - k * 0.5), Color(1, 1, 1, 0.7 * (1.0 - k)))
				c.draw_arc(p, (8.0 + i * 3.0) * (1.0 - k * 0.5), 0.0, TAU, 12, Color(ink, 0.5 * (1.0 - k)), 2.0)
