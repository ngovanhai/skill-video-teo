extends "res://canh.gd"
# k15 — lần rót thứ sáu, rượu Tây Hồ. Kiểu dựng: MẶT CẮT DỌC trang viện → đáy hồ → nhà ngục, máy quay cẩu thẳng xuống.
# Mỗi đoạn một kiểu: đi ven hồ (cuộn ngang) · bốn cửa trăng sáng dần (phòng tranh) · quà bay theo cung ·
# đấu kiếm với từng cửa (đòn từ cửa phóng ra) · toàn cảnh mặt cắt rồi cẩu xuống · loé sáng đánh tráo ·
# hồi tưởng nhuộm nâu · tấm sắt nhìn từ trên (ngón tay dò chữ) · xoáy chữ · tám vòng chập một, mầm đỏ.

const WALL := Color("#efe8da")
const SLATE := Color("#4e5662")
const ROCK := Color("#6e6152")
const WATER_T := Color("#4f8fa6")
const WATER_B := Color("#16334a")
const PLUM := Color("#f4a6bf")
const IRON := Color("#3b3f45")
const GATE_X := [480.0, 710.0, 940.0, 1170.0]
const GATE_Y := 420.0
const GATE_R := 92.0
const MASTERS := ["HOÀNG CHUNG CÔNG", "HẮC BẠCH TỬ", "NGỐC BÚT ÔNG", "ĐAN THANH SINH"]
const LOVES := ["ĐÀN", "CỜ", "CHỮ", "TRANH"]
const GIFTS := ["QUẢNG LĂNG TÁN", "KỲ PHỔ", "THIẾP CHỮ TRƯƠNG HÚC", "TRANH PHẠM KHOAN"]
const EIGHT := [Color("#c9884a"), Color("#e0a040"), Color("#9fc25a"), Color("#5fd0a8"), Color("#ff8fb8"),
	Color("#ff6a4a"), Color("#ffe9a0"), Color("#ffe9a0")]
const SHAFT_X := 1300.0
const FLOOR := 2600.0
const CELL := Rect2(1700, 2230, 960, 370)
const PLATE := Rect2(2030, 2565, 440, 35)
const LAKE_X := 1390.0

var m := ""
var lhx: Dictionary
var hvt: Dictionary
var nng: Dictionary
var kiem: Dictionary
var k_state := ""
var lhx_under := false
var swapped := false
var belly := Vector2.ZERO
var bundle := Vector2.ZERO
var hits: Array = []


func _palette() -> void:
	m = arg.get("m", "")
	sky_top = Color("#b3cfda")
	sky_bot = Color("#f3eadb")
	char_tint = Color(1, 1, 1)
	ground_y = 860.0
	vign_a = 0.3
	wind_base = 0.25
	wind_gust = 0.4


func _build() -> void:
	lhx = actor("lenh-ho-xung", Vector2(-260, ground_y), 1.0)
	hvt = actor("huong-van-thien", Vector2(-420, ground_y), 1.0)
	nng = actor("nham-nga-hanh", Vector2(2300, FLOOR - 35.0), -1.0)
	kiem = prop(lhx, "kiem", "hong", "F")
	k_state = "hong"
	var b := L("k15-02b")
	for i in 4:
		hits.append(b + 0.9 + i * 1.25)


func _story(dt: float) -> void:
	if t < 0.0:
		return
	var a2 := L("k15-02")
	var a2c := L("k15-02c")
	var a2d := L("k15-02d")
	var a2b := L("k15-02b")
	var a3 := L("k15-03")
	var a4 := L("k15-04")
	var a4b := L("k15-04b")
	var a5 := L("k15-05")
	var a6 := L("k15-06")
	var a7 := L("k15-07")
	# ---- mặt đất: hai người đi ven hồ tới trang viện
	if t > 0.6 and t < 2.0 and lhx.go == Vector2.INF and lhx.pos.x < 0.0:
		lhx.speed = 170.0
		lhx.go = Vector2(290, ground_y)
		hvt.speed = 170.0
		hvt.go = Vector2(140, ground_y)
	if not lhx_under:
		var look := smooth(a2c, a2c + 0.5, t) * (1.0 - smooth(a2b - 0.4, a2b, t))
		lhx.expr = "vui" if t < a2c else ("ngai" if t < a2d else "binh")
		lhx.extra = [[{"head": -10.0}, look]]
		# đấu với từng cửa: chạy tới dưới cửa, vung lên chém đòn phóng ra
		if t > a2b - 0.6 and k_state == "hong":
			prop_to(kiem, "tay", "F")
			k_state = "tay"
		if t > a3 - 0.4 and k_state == "tay":
			prop_to(kiem, "hong", "F")
			k_state = "hong"
		var wu := 0.0
		var sl := 0.0
		for i in 4:
			var h: float = hits[i]
			wu += bump(h - 0.42, h - 0.2, h - 0.14, h - 0.04)
			sl += bump(h - 0.08, h - 0.01, h + 0.2, h + 0.36)
			if t > h - 0.9 and t < h - 0.5 and lhx.go == Vector2.INF and absf(lhx.pos.x - (GATE_X[i] - 120.0)) > 10.0:
				lhx.speed = 520.0
				lhx.go = Vector2(GATE_X[i] - 120.0, ground_y)
		var fight := smooth(a2b - 0.4, a2b, t) * (1.0 - smooth(a3 - 0.6, a3, t))
		if fight > 0.0:
			lhx.extra = [["stance", fight], [arms_of("windup"), wu], [arms_of("slash"), sl],
				[{"head": -16.0, "torso": -8.0}, fight]]
			lhx.expr = "quyet-tam" if t < hits[3] + 0.5 else "vui"
		kiem.trail_on = sl > 0.4
		if not kiem.trail_on:
			kiem.trail.clear()
	# Hướng Vấn Thiên: đứng xem, rút quà trong bọc (02d), cười thầm
	var give := bump(a2d + 2.8, a2d + 3.2, a2d + 7.6, a2d + 8.2)
	hvt.extra = [[{"uaB": 150.0, "faB": -40.0, "head": 6.0}, give]]
	hvt.expr = "dac-y" if t > a2d else "vui"
	var hto: Node2D = hvt.node.J["torso"]
	bundle = to_w(hto, Vector2(-62, -78))
	# ---- dưới đất: Lệnh Hồ Xung xuống cầu thang tới cửa ngục
	if not lhx_under and t > a3 + 3.6:
		lhx_under = true
		lhx.go = Vector2.INF
		lhx.pos = Vector2(SHAFT_X, FLOOR)
		lhx.extra = []
		lhx.speed = 200.0
		lhx.go = Vector2(1620, FLOOR)
		kiem.node.visible = false
	var fl := smooth(a4 + 0.9, a4 + 1.05, t)
	if lhx_under and not swapped and fl > 0.5:
		swapped = true
		lhx.go = Vector2.INF
		lhx.pos = Vector2(2250, PLATE.position.y)
		lhx.face = 1.0
		nng.pos = Vector2(1620, FLOOR)
		nng.speed = 150.0
		nng.go = Vector2(1330, FLOOR)
	if lhx_under and not swapped:
		lhx.expr = "ngai" if t < a3 + 5.5 else "soc"
		nng.extra = [[NGOI_XEP_BANG, 1.0], [{"head": -8.0}, 1.0]]
		nng.expr = "dac-y"
	if swapped:
		nng.extra = [[{"head": -12.0, "torso": -6.0}, 1.0]]
		nng.expr = "vui"
		nng.show = 1.0 - smooth(1360, 1335, nng.pos.x)
		# trong ngục: ngồi bó gối → nằm ngửa trên tấm sắt (05) → ngồi kiết già luyện (06, 07)
		var lie := smooth(a4b, a4b + 0.2, t) * (1.0 - smooth(a6 - 0.2, a6 + 0.6, t))
		var feel := smooth(a5 + 1.0, a5 + 1.5, t) * (1.0 - smooth(a6 - 0.4, a6, t))
		var sw := sin(t * 2.4)
		if lie > 0.5:
			lhx.pos = Vector2(PLATE.end.x - 22.0, PLATE.position.y - 44.0)
			lhx.rot = -PI * 0.5
			lhx.extra = [[{"uaF": 30.0 + feel * (35.0 + sw * 15.0), "faF": -10.0, "uaB": 10.0, "head": 0.0}, 1.0]]
			lhx.expr = "binh" if t < a5 + 3.0 else "soc"
		else:
			lhx.pos = Vector2(2250, PLATE.position.y)
			lhx.rot = 0.0
			var settle := smooth(a6, a6 + 1.0, t)
			var br := sin(t * 1.6)
			lhx.extra = [[NGOI_BAP_BENH, 1.0 - settle], [NGOI_XEP_BANG, settle],
				[{"torso": br * 2.0, "uaF": -40.0, "faF": -95.0, "uaB": -40.0, "faB": -95.0}, settle]]
			if t < a4b:
				lhx.expr = "soc"
			elif t < a7 + 1.0:
				lhx.expr = "binh"
			elif t < a7 + 4.0:
				lhx.expr = "vui"
			else:
				lhx.expr = "ngai"
		var lto: Node2D = lhx.node.J["torso"]
		belly = to_w(lto, Vector2(14, -54))
	# ánh sáng: dưới lòng đất mờ lạnh, lúc tối hẳn (05) chỉ còn ánh chữ
	var under := _under()
	var dark := smooth(a4 + 1.0, a4 + 2.0, t) * 0.5 + smooth(a5 - 0.1, a5 + 0.4, t) * 0.5 * (1.0 - smooth(a6, a6 + 2.0, t) * 0.5)
	char_tint = Color(1, 1, 1).lerp(Color(0.72, 0.76, 0.88), under).lerp(Color(0.6, 0.62, 0.74), dark * under)
	if t < a3:
		rain_of("petal", 4.0 if t < a2b else 9.0, Rect2(-300, -60, 2000, 40), {"col": PLUM})
	var _u := dt


# 1 khi máy quay ở dưới lòng đất
func _under() -> float:
	var r := _cam()
	var p: Vector2 = r[0]
	return smooth(1300.0, 1900.0, p.y)


func _cam() -> Array:
	var a2 := L("k15-02")
	var a2c := L("k15-02c")
	var a2b := L("k15-02b")
	var a3 := L("k15-03")
	var a4 := L("k15-04")
	var a4b := L("k15-04b")
	var a5 := L("k15-05")
	var a6 := L("k15-06")
	var a7 := L("k15-07")
	var p := Vector2(1560, 560)
	var z := 1.0
	var k := smooth(a2 - 0.6, a2 + 2.0, t)
	p = p.lerp(Vector2(720, 540), k)
	var k2 := smooth(a2c - 0.4, a2c + 0.6, t)
	p = p.lerp(Vector2(760, 520), k2)
	z = lerpf(z, 1.05, k2)
	var k3 := smooth(a2b - 0.3, a2b + 0.4, t) * (1.0 - smooth(a3 - 0.2, a3, t))
	var fx := clampf(lhx.pos.x + 140.0, 500.0, 1100.0)
	p = p.lerp(Vector2(fx, 560), k3)
	z = lerpf(z, 1.25, k3)
	# toàn cảnh mặt cắt rồi cẩu thẳng xuống đáy hồ
	var out := smooth(a3, a3 + 1.6, t)
	var down := smooth(a3 + 3.0, a3 + 5.2, t)
	if t > a3:
		p = Vector2(720, 540).lerp(Vector2(1450, 1560), out).lerp(Vector2(1960, 2400), down)
		z = lerpf(lerpf(1.05, 0.42, out), 1.12, down)
	# hồi tưởng: cắt lên mặt đất, Hướng Vấn Thiên với cái bọc
	if t > a4b and t < a5:
		p = Vector2(330, 600)
		z = 1.45
	if t > a5:
		var c5 := smooth(a5, a5 + 3.0, t)
		p = Vector2(2160, 2470).lerp(Vector2(2230, 2440), smooth(a6, a6 + 2.0, t))
		z = lerpf(1.25, 1.55, c5)
		z = lerpf(z, 1.3, smooth(a6, a6 + 2.0, t))
		z = lerpf(z, 1.15, smooth(a7, a7 + 3.0, t))
	return [p, z]


# ---------------------------------------------------------------- vẽ

func _ground(c: Node2D) -> void:
	# đồi xa bên kia hồ + bóng tháp
	var hill := PackedVector2Array([Vector2(1300, 880)])
	for i in 21:
		var x := 1300.0 + i * 140.0
		hill.append(Vector2(x, 760.0 - 70.0 * sin(i * 0.9) - 40.0 * sin(i * 2.3)))
	hill.append(Vector2(4300, 880))
	shape(c, hill, Color("#a8bfc4"), 0.0)
	var tp := Vector2(2900, 700)
	for j in 5:
		var w := 70.0 - j * 11.0
		c.draw_rect(Rect2(tp.x - w * 0.5, tp.y - 26.0 * (j + 1), w, 22), Color("#8ea4ab"))
		c.draw_rect(Rect2(tp.x - w * 0.5 - 12, tp.y - 26.0 * (j + 1) - 6, w + 24, 7), Color("#7d939a"))
	# lòng đất
	c.draw_rect(Rect2(-2400, ground_y, 7600, 2800), ROCK)
	for i in 14:
		var y := 1000.0 + i * 140.0
		var pts := PackedVector2Array()
		for j in 40:
			pts.append(Vector2(-2400.0 + j * 200.0, y + 18.0 * sin(j * 1.7 + i)))
		c.draw_polyline(pts, Color(ink, 0.25), 3.0)
	# đất mặt + lối đi lát đá
	c.draw_rect(Rect2(-2400, ground_y, LAKE_X + 2400, 46), Color("#9a8a64"))
	for i in 30:
		c.draw_rect(Rect2(-600.0 + i * 70.0, ground_y + 6, 58, 14), Color("#b8a984"))
	# hồ: nước từ mặt xuống đáy
	var lake := PackedVector2Array([Vector2(LAKE_X, 880), Vector2(5200, 880), Vector2(5200, 2060)])
	for i in 40:
		var x := 5200.0 - i * 100.0
		if x < LAKE_X + 120.0:
			break
		lake.append(Vector2(x, 2050.0 + 30.0 * sin(i * 0.8)))
	lake.append(Vector2(LAKE_X + 140, 1800))
	lake.append(Vector2(LAKE_X + 40, 1100))
	var lc := WATER_T.lerp(WATER_B, 0.5)
	shape(c, lake, lc, 4.0, Color(ink, 0.8))
	vgrad(c, Rect2(LAKE_X + 140, 880, 3700, 900), Color(WATER_T, 0.9), Color(lc, 0.0))
	for i in 24:
		var x := LAKE_X + 80.0 + fmod(i * 233.0 + t * 30.0, 3600.0)
		var y := 900.0 + (i % 6) * 160.0
		c.draw_line(Vector2(x, y), Vector2(x + 90, y), Color(1, 1, 1, 0.22), 3.0)
	# rong rêu đáy hồ
	for i in 18:
		var bx := LAKE_X + 300.0 + i * 190.0
		var by := 2050.0 + 30.0 * sin(i * 0.8)
		var pts := PackedVector2Array()
		for j in 6:
			pts.append(Vector2(bx + sin(t * 1.2 + i + j * 0.6) * 10.0 * j, by - j * 28.0))
		c.draw_polyline(pts, Color("#3f6a4a"), 6.0)
	# trang viện: tường vôi, mái ngói, bốn cửa trăng
	_manor(c)
	_tree(c, Vector2(205, ground_y), 1.0)
	_tree(c, Vector2(LAKE_X - 20, ground_y), 0.7)
	# giếng thang xoắn + hành lang + ngục
	var shaft := Rect2(SHAFT_X - 70, ground_y, 140, FLOOR - ground_y)
	c.draw_rect(shaft, Color("#241f1c"))
	for i in 34:
		var y := ground_y + 30.0 + i * 50.0
		var x0 := SHAFT_X - 60.0 if i % 2 == 0 else SHAFT_X + 60.0
		c.draw_line(Vector2(x0, y), Vector2(SHAFT_X, y + 25.0), Color("#5a4e44"), 6.0)
	for i in 6:
		var lp := Vector2(SHAFT_X + 56, ground_y + 200.0 + i * 280.0)
		c.draw_circle(lp, 9.0, Color("#ffcf7a"))
	c.draw_rect(Rect2(SHAFT_X - 70, FLOOR - 210, CELL.position.x - SHAFT_X + 70, 210), Color("#241f1c"))
	c.draw_rect(CELL, Color("#4e443c"))
	for r in 6:
		for q in 13:
			var ox := 40.0 if r % 2 == 0 else 0.0
			var br := Rect2(CELL.position.x + ox + q * 80.0, CELL.position.y + r * 62.0, 76, 58)
			br = br.intersection(CELL)
			if br.size.x > 4.0:
				c.draw_rect(br, Color(ink, 0.5), false, 2.0)
	c.draw_rect(CELL, Color(ink, 0.95), false, 6.0)
	# nước rỉ từ trần ngục
	for i in 3:
		var dx := CELL.position.x + 260.0 + i * 280.0
		var ph := fmod(t * 0.7 + i * 0.37, 1.0)
		c.draw_circle(Vector2(dx, CELL.position.y + 6.0 + ph * ph * 360.0), 5.0, Color(0.6, 0.85, 0.95, 0.7 * (1.0 - ph)))
	# xích từ vách vào cổ tay người bị giam
	var who: Dictionary = lhx if swapped else nng
	if float(who.get("show", 1.0)) > 0.5:
		var wn: Node2D = who.node
		for s in ["F", "B"]:
			var hw: Vector2 = wn.hand(world, s)
			var anc := Vector2(CELL.end.x - 30, CELL.position.y + 140.0 + (0.0 if s == "F" else 50.0))
			_chain(c, anc, hw)
	# tấm sắt dưới chỗ nằm
	c.draw_rect(PLATE.grow(4), Color(ink, 0.9))
	c.draw_rect(PLATE, IRON)
	for i in 6:
		c.draw_circle(PLATE.position + Vector2(20.0 + i * 80.0, 17), 4.0, Color("#6a7078"))
	# bọc đồ sau lưng Hướng Vấn Thiên (vẽ sau lưng nhân vật)
	_bundle(c)


func _manor(c: Node2D) -> void:
	var wl := Rect2(350, 240, 1000, 620)
	c.draw_rect(wl.grow(4), Color(ink, 0.9))
	c.draw_rect(wl, WALL)
	c.draw_rect(Rect2(350, 800, 1000, 60), Color("#8d8a84"))
	var roof := PackedVector2Array([Vector2(300, 250), Vector2(1400, 250), Vector2(1350, 170), Vector2(350, 170)])
	shape(c, roof, SLATE, 4.0)
	for i in 28:
		var x := 330.0 + i * 38.0
		c.draw_line(Vector2(x + 12, 176), Vector2(x, 246), Color(ink, 0.5), 3.0)
	c.draw_line(Vector2(330, 166), Vector2(1370, 166), Color(ink), 8.0)
	c.draw_line(Vector2(330, 166), Vector2(290, 140), Color(ink), 8.0)
	c.draw_line(Vector2(1370, 166), Vector2(1410, 140), Color(ink), 8.0)
	# cửa xuống hầm
	c.draw_rect(Rect2(SHAFT_X - 60, 660, 120, 200), Color("#2a211c"))
	c.draw_rect(Rect2(SHAFT_X - 60, 660, 120, 200), Color(ink), false, 4.0)
	var a2 := L("k15-02")
	var a2c := L("k15-02c")
	var a2b := L("k15-02b")
	for i in 4:
		var g := Vector2(GATE_X[i], GATE_Y)
		var lit := smooth(a2 + 3.6 + i * 0.55, a2 + 4.0 + i * 0.55, t)
		lit = maxf(lit, smooth(a2c + 2.4 + i * 1.2, a2c + 2.8 + i * 1.2, t))
		c.draw_circle(g, GATE_R + 16.0, Color(ink, 0.9))
		c.draw_circle(g, GATE_R + 12.0, Color("#cfc5b0"))
		c.draw_circle(g, GATE_R, Color("#3b2f28").lerp(Color("#f6dca2"), lit))
		# trang chủ "cúi chào" sau khi thua: biểu tượng nghiêng
		var h: float = hits[i]
		var bow := smooth(h + 0.1, h + 0.5, t) * 0.5 + bump(h, h + 0.08, h + 0.12, h + 0.4) * 0.3
		_icon(c, i, g, 1.0, bow, lit)
		var tg := smooth(a2c + 2.4 + i * 1.2, a2c + 2.7 + i * 1.2, t) * (1.0 - smooth(a2b - 0.5, a2b, t))
		nhan(c, g + Vector2(0, GATE_R + 44.0 + (i % 2) * 48.0), MASTERS[i], 25, Color("#3a4a5a"), tg)


func _icon(c: Node2D, i: int, g: Vector2, s: float, bow: float, lit: float) -> void:
	var ic := Color(ink).lerp(Color("#5a3a22"), 0.3)
	ic.a = 0.35 + 0.65 * lit
	c.draw_set_transform(g, bow * 0.5, Vector2.ONE * s)
	match i:
		0:   # đàn cổ: tấm gỗ dài, dây căng
			var board := PackedVector2Array([Vector2(-70, 22), Vector2(62, -30), Vector2(70, -14), Vector2(-62, 38)])
			shape(c, board, Color("#9a5a2a", ic.a), 3.0)
			for k in 5:
				c.draw_line(Vector2(-60, 26 + k * 2.5), Vector2(64, -24 + k * 2.5), Color(1, 0.95, 0.8, ic.a), 1.5)
		1:   # bàn cờ vây, quân đen trắng
			c.draw_rect(Rect2(-52, -42, 104, 84), Color("#d8b070", ic.a))
			for k in 6:
				c.draw_line(Vector2(-44 + k * 17.6, -36), Vector2(-44 + k * 17.6, 36), Color(ic, ic.a), 1.5)
				c.draw_line(Vector2(-44, -36 + k * 14.4), Vector2(44, -36 + k * 14.4), Color(ic, ic.a), 1.5)
			for k in 7:
				var sp := Vector2(-44 + ((k * 3) % 6) * 17.6, -36 + ((k * 5) % 6) * 14.4)
				c.draw_circle(sp, 7.0, Color(0.1, 0.1, 0.12, ic.a) if k % 2 == 0 else Color(0.97, 0.95, 0.9, ic.a))
		2:   # bút lông + nét mực
			c.draw_line(Vector2(30, -60), Vector2(-4, 20), Color("#7a5a32", ic.a), 8.0)
			c.draw_line(Vector2(-4, 20), Vector2(-14, 44), Color(0.1, 0.1, 0.1, ic.a), 10.0)
			var st := PackedVector2Array()
			for k in 14:
				st.append(Vector2(-60 + k * 9.0, 52 + sin(k * 0.7) * 10.0))
			c.draw_polyline(st, Color(0.1, 0.1, 0.12, ic.a), 6.0)
		3:   # tranh sơn thuỷ: núi chồng núi
			c.draw_rect(Rect2(-56, -56, 112, 112), Color("#f2e6c8", ic.a))
			shape(c, PackedVector2Array([Vector2(-50, 40), Vector2(-20, -30), Vector2(10, 40)]), Color("#5a6a70", ic.a), 2.0)
			shape(c, PackedVector2Array([Vector2(-10, 40), Vector2(22, -10), Vector2(50, 40)]), Color("#8a9aa0", ic.a), 2.0)
			c.draw_circle(Vector2(28, -34), 9.0, Color("#c8463a", ic.a))
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _tree(c: Node2D, base: Vector2, s: float) -> void:
	var tr := Color("#4a3428")
	var top := base + Vector2(20, -470) * s
	c.draw_line(base, top, tr, 26.0 * s)
	for j in 5:
		var st := base.lerp(top, 0.35 + j * 0.13)
		var dir := Vector2(1.0 if j % 2 == 0 else -1.0, -0.6).normalized()
		var en := st + dir * (140.0 - j * 14.0) * s
		c.draw_line(st, en, tr, 12.0 * s)
		for q in 6:
			var bp := st.lerp(en, 0.3 + q * 0.13) + Vector2(sin(q * 2.1 + j) * 16.0, cos(q * 1.7 + j) * 16.0) * s
			c.draw_circle(bp, 12.0 * s, Color(PLUM).darkened(0.25))
			c.draw_circle(bp, 9.0 * s, PLUM)
			c.draw_circle(bp, 3.0 * s, Color("#fff2c0"))


func _chain(c: Node2D, a: Vector2, b: Vector2) -> void:
	var n := int(a.distance_to(b) / 18.0)
	var sag := 40.0
	for i in n:
		var u := float(i) / maxf(1.0, n - 1)
		var p := a.lerp(b, u) + Vector2(0, sin(u * PI) * sag)
		c.draw_arc(p, 8.0, 0.0, TAU, 10, Color("#7a7f86") if i % 2 == 0 else Color("#5a5f66"), 3.0)


func _bundle(c: Node2D) -> void:
	if float(hvt.get("show", 1.0)) < 0.5:
		return
	var a2d := L("k15-02d")
	var a4b := L("k15-04b")
	var a5 := L("k15-05")
	var full := 1.0 - smooth(a2d + 3.0, a2d + 8.0, t) * 0.55
	if t > a4b and t < a5:
		full = 1.0   # hồi tưởng: bọc còn đầy như hôm mới gặp
	var r := 56.0 * (0.7 + 0.3 * full)
	var bc := Color("#6e7f5a")
	c.draw_circle(bundle, r + 4.0, Color(ink, 0.9))
	c.draw_circle(bundle, r, bc)
	hatch(c, _circle_pts(bundle, r - 4.0), 0.8, 16.0, bc.darkened(0.2), 2.0)
	c.draw_line(bundle + Vector2(-r * 0.6, -r * 0.8), bundle + Vector2(r * 0.9, r * 0.5), Color("#3a2a1a"), 6.0)
	var knot := bundle + Vector2(-8, -r)
	c.draw_circle(knot, 13.0, bc.darkened(0.15))


func _circle_pts(ctr: Vector2, r: float) -> PackedVector2Array:
	var pts := PackedVector2Array()
	for i in 20:
		pts.append(ctr + Vector2(cos(i * TAU / 20.0), sin(i * TAU / 20.0)) * r)
	return pts


func _near(c: Node2D) -> void:
	# chấn song cửa ngục
	var dx := CELL.position.x
	for i in 4:
		var x := dx - 18.0 + i * 14.0
		c.draw_line(Vector2(x, CELL.position.y + 150.0), Vector2(x, FLOOR), Color(ink), 9.0)
		c.draw_line(Vector2(x, CELL.position.y + 150.0), Vector2(x, FLOOR), Color("#6a6f76"), 5.0)
	c.draw_line(Vector2(dx - 26, CELL.position.y + 160.0), Vector2(dx + 34, CELL.position.y + 160.0), Color("#6a6f76"), 10.0)
	c.draw_line(Vector2(dx - 26, FLOOR - 120.0), Vector2(dx + 34, FLOOR - 120.0), Color("#6a6f76"), 10.0)
	if t < 0.0:
		return
	# quà bay theo cung từ bọc vào từng cửa (02d)
	var a2d := L("k15-02d")
	for i in 4:
		var st := a2d + 3.4 + i * 1.3
		var pr := smooth(st, st + 0.9, t)
		var vis := smooth(st - 0.05, st + 0.05, t) * (1.0 - smooth(L("k15-02b") - 0.3, L("k15-02b"), t))
		if vis < 0.01:
			continue
		var g := Vector2(GATE_X[i], GATE_Y + 30.0)
		var p := bundle.lerp(g, pr) + Vector2(0, -sin(pr * PI) * 260.0)
		_gift(c, i, p, 1.0 - pr * 0.3, vis, pr)
	# đòn từ mỗi cửa phóng vào người cầm kiếm (02b)
	for i in 4:
		var h: float = hits[i]
		var fly := smooth(h - 0.5, h - 0.02, t)
		var gone := smooth(h, h + 0.04, t)
		var g := Vector2(GATE_X[i], GATE_Y)
		var tgt := head_of(lhx) + Vector2(30, -20)
		if fly > 0.0 and gone < 1.0:
			var p := g.lerp(tgt, fly)
			_shot(c, i, p, g, fly)
		var bu := smooth(h, h + 0.35, t) * (1.0 - smooth(h + 0.25, h + 0.5, t))
		if bu > 0.01:
			var bp := g.lerp(tgt, 0.98)
			for k in 8:
				var an := k * TAU / 8.0 + i
				var e := smooth(h, h + 0.4, t)
				c.draw_line(bp + Vector2(cos(an), sin(an)) * (20.0 + e * 60.0), bp + Vector2(cos(an), sin(an)) * (40.0 + e * 90.0),
					Color(1, 0.95, 0.8, bu), 5.0)


func _gift(c: Node2D, i: int, p: Vector2, s: float, a: float, spin: float) -> void:
	c.draw_set_transform(p, sin(spin * PI * 2.0) * 0.3, Vector2.ONE * s)
	match i:
		0:   # bản đàn: cuộn giấy có nốt
			c.draw_rect(Rect2(-40, -16, 80, 32), Color("#f2e6c8", a))
			c.draw_rect(Rect2(-46, -20, 8, 40), Color("#8a5a2a", a))
			c.draw_rect(Rect2(38, -20, 8, 40), Color("#8a5a2a", a))
			for k in 5:
				c.draw_circle(Vector2(-26 + k * 13.0, -4 + (k % 2) * 8.0), 3.0, Color(0.1, 0.1, 0.1, a))
		1:   # kỳ phổ: cuốn sách
			c.draw_rect(Rect2(-30, -38, 60, 76), Color("#2f4a6a", a))
			c.draw_rect(Rect2(-18, -30, 24, 34), Color("#f2e6c8", a))
		2:   # thiếp chữ
			c.draw_rect(Rect2(-24, -44, 48, 88), Color("#f6efe0", a))
			for k in 3:
				c.draw_line(Vector2(-6 + k * 0.0, -34 + k * 26.0), Vector2(8, -18 + k * 26.0), Color(0.1, 0.1, 0.1, a), 6.0)
		3:   # tranh cuộn
			c.draw_rect(Rect2(-20, -50, 40, 100), Color("#f2e6c8", a))
			shape(c, PackedVector2Array([Vector2(-16, 30), Vector2(0, -10), Vector2(16, 30)]), Color("#5a6a70", a), 1.5)
			c.draw_rect(Rect2(-26, -54, 52, 8), Color("#8a5a2a", a))
	c.draw_rect(Rect2(-50, -56, 100, 112), Color(1, 0.9, 0.6, 0.0), false)
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _shot(c: Node2D, i: int, p: Vector2, g: Vector2, fly: float) -> void:
	match i:
		0:   # tiếng đàn: những vòng sóng âm
			for k in 3:
				var q := g.lerp(p, 1.0 - k * 0.12)
				c.draw_arc(q, 26.0 + k * 10.0, -0.9, 0.9, 12, Color(1, 0.9, 0.5, 0.9 - k * 0.25), 6.0)
		1:   # quân cờ bay
			for k in 3:
				var q := g.lerp(p, 1.0 - k * 0.1) + Vector2(0, (k - 1) * 28.0)
				c.draw_circle(q, 13.0, Color(ink))
				c.draw_circle(q, 10.0, Color(0.1, 0.1, 0.12) if k != 1 else Color(0.97, 0.95, 0.9))
		2:   # vệt mực
			var pts := PackedVector2Array()
			for k in 10:
				pts.append(g.lerp(p, 0.4 + k * 0.066) + Vector2(0, sin(k * 1.3 + t * 10.0) * 12.0))
			c.draw_polyline(pts, Color(0.08, 0.08, 0.1, 0.95), 14.0)
		3:   # màu vẽ vẩy
			for k in 5:
				var q := g.lerp(p, 1.0 - k * 0.07) + Vector2(sin(k * 2.0) * 22.0, cos(k * 2.0) * 22.0)
				c.draw_circle(q, 11.0 - k, [Color("#c8463a"), Color("#3f7ab0"), Color("#5fa05a"), Color("#e0a040"), Color("#8a5ab0")][k])
	var _f := fly


func _glow(c: Node2D) -> void:
	if t < 0.0:
		return
	var a3 := L("k15-03")
	var a4 := L("k15-04")
	var a5 := L("k15-05")
	var a6 := L("k15-06")
	var a7 := L("k15-07")
	# đèn trên vách thang
	for i in 6:
		blob(c, Vector2(SHAFT_X + 56, ground_y + 200.0 + i * 280.0), 60.0, Color(1.0, 0.7, 0.3, 0.3))
	# Nhậm Ngã Hành: quầng khí đỏ sẫm quanh người khi máy cẩu xuống
	if not swapped and t > a3 + 3.0:
		blob(c, nng.pos + Vector2(0, -150), 200.0, Color(0.8, 0.2, 0.2, 0.18 + 0.06 * sin(t * 3.0)))
	# loé sáng đánh tráo
	var fl := bump(a4 + 0.8, a4 + 1.0, a4 + 1.1, a4 + 1.6)
	if fl > 0.01:
		blob(c, Vector2(1950, 2440), 900.0, Color(1, 0.95, 0.85, 0.85 * fl))
	if not swapped:
		return
	# chữ trên tấm sắt sáng dưới bàn tay (05)
	var g5 := smooth(a5 + 1.0, a5 + 2.0, t) * (1.0 - smooth(a7 + 2.0, a7 + 4.0, t))
	if g5 > 0.01:
		for i in 14:
			var gx := PLATE.position.x + 22.0 + i * 29.0
			var on := smooth(a5 + 1.0 + i * 0.12, a5 + 1.3 + i * 0.12, t)
			c.draw_line(Vector2(gx, PLATE.position.y + 8), Vector2(gx + 10, PLATE.end.y - 8), Color(1.0, 0.75, 0.35, 0.8 * on * g5), 4.0)
		blob(c, Vector2(PLATE.get_center().x, PLATE.position.y), 260.0, Color(1.0, 0.65, 0.3, 0.22 * g5))
	# chữ bóc khỏi tấm sắt, xoáy vào đan điền (06)
	var g6 := smooth(a6 + 0.5, a6 + 1.5, t) * (1.0 - smooth(a7 + 1.0, a7 + 2.5, t))
	if g6 > 0.01:
		for i in 22:
			var ph := fmod(t * 0.45 + i / 22.0, 1.0)
			var st := Vector2(PLATE.position.x + 20.0 + fmod(i * 97.0, 400.0), PLATE.position.y + 10.0)
			var an := ph * TAU * 1.6 + i
			var rad := (1.0 - ph) * 150.0
			var p := st.lerp(belly, ph) + Vector2(cos(an), sin(an) * 0.6) * rad * (1.0 - ph)
			var al := sin(ph * PI) * g6
			c.draw_line(p, p + Vector2(10, -6).rotated(an), Color(1.0, 0.8, 0.4, al), 4.0)
	# tám luồng chập về một mối, rồi một mầm đỏ (07)
	var mg := smooth(a7 + 0.5, a7 + 3.5, t)
	var e8 := smooth(a7 - 0.3, a7 + 0.4, t)
	if e8 > 0.01:
		for i in 8:
			var col: Color = EIGHT[i]
			var rad := lerpf(200.0 + i * 16.0, 30.0, mg)
			var sp := (1.2 + i * 0.15) * (1.0 + mg * 2.0)
			var pts := PackedVector2Array()
			for k in 40:
				var an := t * sp + i * TAU / 8.0 + k * 0.12
				pts.append(belly + Vector2(cos(an) * rad, sin(an) * rad * 0.42 + sin(an * 2.0 + i) * 16.0 * (1.0 - mg)))
			c.draw_polyline(pts, Color(col.lerp(Color("#fff0c0"), mg), 0.55 * e8 * (1.0 - mg * 0.4)), 6.0, true)
		blob(c, belly, 60.0 + mg * 80.0, Color(1.0, 0.9, 0.6, 0.35 * mg * e8))
	var sd := smooth(a7 + 4.0, a7 + 4.6, t)
	if sd > 0.01:
		var pu := 0.7 + 0.3 * sin(t * 4.0)
		blob(c, belly, 70.0 * pu, Color(0.75, 0.05, 0.08, 0.6 * sd))
		c.draw_circle(belly, 9.0 * pu, Color(0.9, 0.1, 0.1, sd))


func _d_screen(c: Node2D) -> void:
	var a := L("k15-01")
	var a2 := L("k15-02")
	var a2c := L("k15-02c")
	var a2d := L("k15-02d")
	var a2b := L("k15-02b")
	var a3 := L("k15-03")
	var a4 := L("k15-04")
	var a4b := L("k15-04b")
	var a5 := L("k15-05")
	var a6 := L("k15-06")
	var a7 := L("k15-07")
	# bóng tối ngục: phủ trước khi vẽ nhãn
	var dk := smooth(a5 - 0.1, a5 + 0.4, t) * (1.0 - smooth(a6, a6 + 2.0, t) * 0.5)
	if t > a5 and dk > 0.01:
		c.draw_texture_rect(vign, Rect2(-300, -400, W + 600, H + 800), false, Color(0, 0, 0, 0.6 * dk))
	# hồi tưởng nhuộm nâu
	var sep := bump(a4b - 0.05, a4b + 0.2, a5 - 0.3, a5 - 0.05)
	if sep > 0.01:
		c.draw_rect(Rect2(0, 0, W, H), Color(0.55, 0.38, 0.18, 0.32 * sep))
		c.draw_texture_rect(vign, Rect2(-200, -260, W + 400, H + 520), false, Color(0.25, 0.15, 0.05, 0.8 * sep))
		# vòng sáng quanh cái bọc
		var bs := _w2s(bundle)
		var rr := 120.0 + 10.0 * sin(t * 5.0)
		c.draw_arc(bs, rr, 0.0, TAU, 48, Color(1, 0.9, 0.6, 0.85 * sep), 5.0)
	# tấm sắt nhìn từ trên: ngón tay dò khẩu quyết (05)
	var pl := smooth(a5 + 2.4, a5 + 2.9, t) * (1.0 - smooth(a6 - 0.4, a6, t))
	if pl > 0.01:
		_plate_top(c, pl, smooth(a5 + 2.8, a6 - 0.8, t))
	super(c)
	var ctr := Vector2(960, 140)
	nhan(c, ctr, "RƯỢU TÂY HỒ · MAI TRANG", 40, Color("#7a2e3a"), bump(a + 0.4, a + 0.8, LE("k15-01") - 0.2, LE("k15-01") + 0.2))
	nhan(c, ctr, "HƯỚNG VẤN THIÊN", 40, Color("#2f4a5a"), bump(a2 + 0.6, a2 + 1.0, a2 + 3.2, a2 + 3.5))
	for i in 4:
		var s := a2 + 3.6 + i * 0.55
		nhan(c, Vector2(560 + i * 270, 960), LOVES[i], 36, Color("#7a4a22"), bump(s, s + 0.2, LE("k15-02") - 0.1, LE("k15-02") + 0.3))
	nhan(c, ctr, "GIANG NAM TỨ HỮU", 42, Color("#3a4a5a"), bump(a2c + 0.6, a2c + 1.0, LE("k15-02c") - 0.2, LE("k15-02c") + 0.2))
	nhan(c, ctr, "BỐN MÓN QUÀ", 40, Color("#6a4a2a"), bump(a2d + 1.2, a2d + 1.6, a2d + 3.2, a2d + 3.4))
	for i in 4:
		var s := a2d + 3.4 + i * 1.3
		var e := s + 1.3 if i < 3 else LE("k15-02d") + 0.2
		nhan(c, ctr, GIFTS[i], 38, Color("#6a4a2a"), bump(s, s + 0.15, e - 0.15, e))
	nhan(c, ctr, "THẮNG HẾT", 46, Color("#b8322c"), bump(LE("k15-02b") - 2.2, LE("k15-02b") - 1.9, LE("k15-02b"), LE("k15-02b") + 0.3))
	nhan(c, ctr, "DƯỚI ĐÁY HỒ", 44, Color("#1f4a5e"), bump(a3 + 1.4, a3 + 1.8, a3 + 3.4, a3 + 3.8))
	nhan(c, ctr, "NHẬM NGÃ HÀNH", 44, Color("#6a1e22"), bump(a3 + 4.6, a3 + 5.0, LE("k15-03") - 0.1, LE("k15-03") + 0.2))
	nhan(c, ctr, "ĐÁNH TRÁO", 46, Color("#3a3a46"), bump(a4 + 0.2, a4 + 0.6, a4 + 3.6, a4 + 4.0))
	nhan(c, ctr, "SẮP SẴN TỪ TRƯỚC", 44, Color("#6a4a22"), bump(LE("k15-04b") - 2.8, LE("k15-04b") - 2.4, LE("k15-04b") - 0.1, LE("k15-04b") + 0.2))
	nhan(c, ctr, "HẤP TINH ĐẠI PHÁP", 46, Color("#8a2a1e"), bump(LE("k15-05") - 2.4, LE("k15-05") - 2.0, a6 - 0.2, a6 + 0.2))
	nhan(c, ctr, "LẦN THEO CHỮ MÀ LUYỆN", 40, Color("#5a3a1e"), bump(LE("k15-06") - 2.6, LE("k15-06") - 2.2, LE("k15-06"), LE("k15-06") + 0.3))
	nhan(c, ctr, "TÁM LUỒNG VỀ MỘT MỐI", 42, Color("#5a4a1e"), bump(a7 + 0.6, a7 + 1.0, a7 + 3.6, a7 + 3.9))
	nhan(c, ctr, "MẦM HOẠ MỚI", 46, Color("#7a1015"), bump(a7 + 4.2, a7 + 4.6, LE("k15-07") + 0.2, LE("k15-07") + 0.6))


# toạ độ thế giới → màn hình theo máy quay hiện tại
func _w2s(p: Vector2) -> Vector2:
	var r := _cam()
	var cp: Vector2 = r[0]
	var z: float = r[1]
	return (p - cp) * z + CENTER


# mặt tấm sắt (nhìn từ trên): hàng chữ khắc, ngón tay dò tới đâu chữ sáng tới đó
func _plate_top(c: Node2D, a: float, prog: float) -> void:
	var r := Rect2(460, 330, 1000, 470)
	var sc := 0.92 + 0.08 * a
	c.draw_set_transform(CENTER, 0.0, Vector2.ONE * sc)
	r.position -= CENTER
	c.draw_rect(r.grow(10), Color(0, 0, 0, 0.8 * a))
	c.draw_rect(r, Color(IRON, a))
	for i in 9:
		c.draw_circle(r.position + Vector2(30 + i * 117.5, 26), 6.0, Color(0.5, 0.52, 0.56, a))
		c.draw_circle(r.position + Vector2(30 + i * 117.5, r.size.y - 26), 6.0, Color(0.5, 0.52, 0.56, a))
	var cols := 12
	var rows := 5
	var n := cols * rows
	var fp := Vector2.ZERO
	for k in n:
		var cx := cols - 1 - k / rows       # đọc cột dọc từ phải sang trái
		var ry := k % rows
		var gp := r.position + Vector2(90.0 + cx * 74.0, 90.0 + ry * 74.0)
		var lit := smooth(float(k) / n - 0.02, float(k) / n + 0.02, prog)
		var col := Color(0.3, 0.32, 0.36, a).lerp(Color(1.0, 0.78, 0.4, a), lit)
		_glyph(c, gp, k, col)
		if lit > 0.5:
			fp = gp
	if prog > 0.01 and prog < 0.99:
		c.draw_circle(fp + Vector2(18, 22), 34.0, Color(1.0, 0.75, 0.4, 0.25 * a))
		var tip := fp + Vector2(16, 20)
		var dirf := Vector2(0.35, 1.0).normalized()
		c.draw_line(tip + dirf * 10.0, tip + dirf * 230.0, Color(ink, a), 44.0)
		c.draw_line(tip + dirf * 10.0, tip + dirf * 230.0, Color(Color("#f2c9a0"), a), 36.0)
		c.draw_circle(tip + dirf * 10.0, 20.0, Color(ink, a))
		c.draw_circle(tip + dirf * 10.0, 17.0, Color(Color("#f2c9a0"), a))
		c.draw_circle(tip + dirf * 16.0, 9.0, Color(Color("#fbe3cc"), a))
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


# một chữ khắc giả: vài nét ngang/dọc/phẩy ghép theo số k (không phải chữ thật)
func _glyph(c: Node2D, p: Vector2, k: int, col: Color) -> void:
	var s := 22.0
	var h := k * 7919 + 13
	for j in 4:
		var kind := (h >> (j * 2)) & 3
		var o := Vector2(((h >> (j + 3)) & 3) * 8.0 - 12.0, j * 11.0 - 18.0)
		match kind:
			0:
				c.draw_line(p + o + Vector2(-s * 0.6, 0), p + o + Vector2(s * 0.6, 0), col, 4.0)
			1:
				c.draw_line(p + o + Vector2(0, -8), p + o + Vector2(0, 14), col, 4.0)
			2:
				c.draw_line(p + o + Vector2(6, -6), p + o + Vector2(-10, 10), col, 4.0)
			3:
				c.draw_line(p + o + Vector2(-6, -6), p + o + Vector2(10, 10), col, 4.0)
