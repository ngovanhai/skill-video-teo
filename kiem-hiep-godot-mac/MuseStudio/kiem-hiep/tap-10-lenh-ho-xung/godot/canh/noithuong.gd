extends "res://canh.gd"
# k11 — lần rót thứ tư, rượu thuốc. Kiểu dựng: mặt cắt bụng (cửa sổ khoét trên người) với tám dòng chân khí.
# Gian thuốc bắc ban đêm: tủ trăm ngăn, chiếu cói. Lục Tiên hiện thành sáu thẻ gỗ đào (rễ, thân, cành, lá, hoa, quả)
# nhảy quanh người; Bất Giới dồn thêm hai dòng; Bình Nhất Chỉ chỉ là một bàn tay với đúng một ngón.

const MED := Color("#d98a3a")                 # màu rượu thuốc (WINE[3])
const TEAL := Color("#173a3c")
const DRAWER := Color("#5c3a22")
const SIX := [["RỄ", Color("#c9884a")], ["THÂN", Color("#e0a040")], ["CÀNH", Color("#9fc25a")],
	["LÁ", Color("#5fd0a8")], ["HOA", Color("#ff8fb8")], ["QUẢ", Color("#ff6a4a")]]
const MONK := Color("#ffe9a0")                # hai dòng của Bất Giới

var m := ""
var lhx: Dictionary
var bg: Dictionary
var teo: Dictionary
var ho: Dictionary
var belly := Vector2(1000, 700)
var wrist := Vector2(1100, 700)
var bg_hand := Vector2.ZERO
var icons: Array = []         # vị trí thế giới của sáu thẻ đào


func _palette() -> void:
	m = arg.get("m", "")
	sky_top = Color("#0f2628")
	sky_bot = Color("#21403e")
	char_tint = Color(1.0, 0.93, 0.84)
	ground_y = 860.0
	vign_a = 0.4
	wind_base = 0.0
	wind_gust = 0.05


func _build() -> void:
	lhx = actor("lenh-ho-xung", Vector2(1000, ground_y), 1.0)
	ho = prop(lhx, "ho_lo", "tay", "F")
	bg = actor("bat-gioi", Vector2(-260, ground_y), 1.0)
	teo = actor("teo-tieu-nhi", Vector2(-300, ground_y), 1.0)
	teo.show = 0.0
	for i in 6:
		icons.append(Vector2.ZERO)


func _story(dt: float) -> void:
	if t < 0.0:
		return
	var a1 := L("k11-01")
	var a2b := L("k11-02b")
	var a3 := L("k11-03")
	var a4 := L("k11-04")
	var a5 := L("k11-05")
	var a6 := L("k11-06")
	var a6b := L("k11-06b")
	var a7 := L("k11-07")
	var a8 := L("k11-08")
	# ---- Lệnh Hồ Xung ngồi bệt trên chiếu, lả người; uống rượu thuốc thì nhăn mặt
	var sip := bump(a1 + 1.4, a1 + 2.0, a1 + 3.4, a1 + 3.9)
	var hurt := smooth(a3, a3 + 1.0, t) * (1.0 - smooth(a7 - 0.5, a7, t))
	var fight := smooth(a5, a5 + 0.6, t) * (1.0 - smooth(a6, a6 + 0.8, t))
	var jolt := sin(t * 23.0) * fight
	var arm_out := smooth(a6 - 0.2, a6 + 0.5, t) * (1.0 - smooth(a6b + 5.0, a6b + 5.8, t))
	var cheer := smooth(a7 + 0.4, a7 + 1.0, t)
	var laugh := smooth(a8 + 2.0, a8 + 2.5, t)
	var s9 := sin(t * 9.0)
	lhx.extra = [[SIT_GROUND, 1.0], [{"torso": 18.0, "head": 12.0}, hurt * (1.0 - arm_out * 0.5)],
		[{"torso": 14.0 + jolt * 6.0, "head": 8.0 - jolt * 8.0}, fight],
		[{"uaF": -78.0, "faF": -8.0}, arm_out],
		[{"uaF": -158.0, "faF": -12.0, "head": -10.0, "torso": -6.0}, cheer * (1.0 - laugh)],
		[{"head": -14.0 + s9 * 5.0, "torso": -8.0 + s9 * 3.0, "uaF": -120.0, "faF": -30.0}, laugh]]
	var lips := _lips()
	lhx.hold["F"] = [Vector2(46, -70).lerp(lips, sip), sip]
	ho.lock = sip
	ho.lockdir = Vector2.DOWN.lerp(Vector2(0.75, -0.66), sip).normalized()
	ho.aim = Vector2(0, -30)
	ho.pour = bump(a1 + 2.0, a1 + 2.2, a1 + 3.2, a1 + 3.4)
	if t < a1 + 4.4:
		lhx.expr = "binh" if t < a1 + 2.6 else "soc"
	elif fight > 0.3:
		lhx.expr = "soc"
	elif hurt > 0.5:
		lhx.expr = "buon"
	elif arm_out > 0.5:
		lhx.expr = "binh"
	else:
		lhx.expr = "vui"
	var to: Node2D = lhx.node.J["torso"]
	belly = to_w(to, Vector2(14, -54))
	wrist = lhx.node.hand(world, "F")
	# ---- sáu thẻ gỗ đào: vào vòng quanh người theo từng tên, nhảy tưng tưng
	for i in 6:
		var an := PI * (1.08 + i * 0.17)
		var home := belly + Vector2(cos(an), sin(an)) * Vector2(330, 205) + Vector2(60, 10)
		var appear := smooth(a2b + 0.5 + i * 1.1, a2b + 0.9 + i * 1.1, t)
		var from := home + Vector2(0, -700)
		var hop := absf(sin(t * 5.0 + i * 1.3)) * 16.0
		icons[i] = from.lerp(home, appear) + Vector2(0, -hop * appear)
	# ---- Bất Giới: đi vào từ trái, đẩy song chưởng
	if t > a4 - 1.2 and t < a5 and bg.go == Vector2.INF and bg.pos.x < 400.0:
		bg.speed = 420.0
		bg.go = Vector2(470, ground_y)
	var push := smooth(a4 + 1.0, a4 + 1.5, t) * (1.0 - smooth(a5 + 1.0, a5 + 1.6, t))
	bg.extra = [["palm", push]]
	bg.expr = "quyet-tam" if push > 0.3 else ("vui" if t > a4 - 1.0 else "binh")
	if t > a5 + 2.0 and bg.go == Vector2.INF and bg.pos.x > 300.0:
		bg.speed = 380.0
		bg.go = Vector2(-300, ground_y)
	bg_hand = bg.node.hand(world, "F")
	# ---- Tèo (k11-08): nằm co ro ôm chăn, run
	var tin := smooth(a8 - 0.3, a8 + 0.3, t)
	teo.show = tin
	teo.pos = Vector2(620, ground_y - 36.0)
	teo.rot = -1.35
	teo.extra = [["kneel", 1.0], [{"head": 20.0 + sin(t * 40.0) * 2.0, "uaF": -60.0, "faF": -100.0, "uaB": -50.0, "faB": -110.0}, 1.0]]
	teo.expr = "buon"


func _lips() -> Vector2:
	var to: Node2D = lhx.node.J["torso"]
	return from_w(to, to_w(lhx.node.J["head"], Vector2(0, -30))) + Vector2(12, -12)


func _cam() -> Array:
	var a3 := L("k11-03")
	var a6 := L("k11-06")
	var a7 := L("k11-07")
	var a8 := L("k11-08")
	var wide := [Vector2(980, 660), 1.3]
	var close := [belly + Vector2(-30, 0), 1.5]
	var hand := [Vector2(1180, 660), 1.35]
	var mid := [Vector2(940, 660), 1.35]
	var k1 := smooth(a3 - 0.8, a3 + 0.4, t) * (1.0 - smooth(a6 - 0.6, a6 + 0.2, t))
	var k2 := smooth(a6 - 0.6, a6 + 0.2, t) * (1.0 - smooth(a7 - 0.5, a7 + 0.3, t))
	var k3 := smooth(a7 - 0.5, a7 + 0.3, t) * (1.0 - smooth(a8 - 0.6, a8, t))
	var p: Vector2 = wide[0]
	var z: float = wide[1]
	# bước mở: đẩy nhẹ vào hồ lô khi rót
	var a1 := L("k11-01")
	var pk := bump(a1 - 0.3, a1 + 0.6, a1 + 4.0, a1 + 4.8)
	p = p.lerp(Vector2(1040, 600), pk)
	z = lerpf(z, 1.6, pk)
	p = p.lerp(close[0], k1)
	z = lerpf(z, close[1], k1)
	p = p.lerp(hand[0], k2)
	z = lerpf(z, hand[1], k2)
	p = p.lerp(mid[0], k3)
	z = lerpf(z, mid[1], k3)
	return [p, z]


# ---------------------------------------------------------------- vẽ

func _back(c: Node2D) -> void:
	# tủ thuốc bắc trăm ngăn chạy hết vách
	c.draw_rect(Rect2(-1400, 60, 4800, 860), Color("#2a1c14"))
	for col in 44:
		for row in 7:
			var x := -1300.0 + col * 108.0
			var y := 110.0 + row * 108.0
			var r := Rect2(x, y, 96, 96)
			c.draw_rect(r, DRAWER.darkened(0.25).lightened(0.03 * ((col + row) % 3)))
			c.draw_rect(r, Color(ink, 0.9), false, 3.0)
			c.draw_rect(Rect2(x + 30, y + 14, 36, 22), Color("#7a6a4c"))
			c.draw_circle(Vector2(x + 48, y + 66), 6.0, Color("#8a6a3a"))
	# dây phơi thảo dược trên cao
	for i in 12:
		var x := -900.0 + i * 340.0
		c.draw_line(Vector2(x, 40), Vector2(x + 20, 150), Color(ink, 0.8), 3.0)
		puff(c, [[Vector2(x + 20, 170), 26.0], [Vector2(x + 4, 196), 20.0], [Vector2(x + 34, 198), 18.0]], Color("#6f7a3a"), 3.0)


func _ground(c: Node2D) -> void:
	c.draw_rect(Rect2(-1400, ground_y, 4800, 600), Color("#3a2a1a"))
	# chiếu cói dưới chỗ ngồi
	var mat := PackedVector2Array([Vector2(700, ground_y + 6), Vector2(1380, ground_y + 6), Vector2(1460, ground_y + 70), Vector2(620, ground_y + 70)])
	shape(c, mat, Color("#b89a5a"), 3.0)
	hatch(c, mat, 1.57, 14.0, Color("#7a6436"), 2.0)
	# ấm sắc thuốc + bếp than đỏ
	var kp := Vector2(1420, ground_y)
	shape(c, PackedVector2Array([kp + Vector2(-50, 0), kp + Vector2(50, 0), kp + Vector2(40, -46), kp + Vector2(-40, -46)]), Color("#4a3a2e"), 3.0)
	c.draw_circle(kp + Vector2(0, -88), 46.0, inkof(Color("#6b4a2a")))
	c.draw_circle(kp + Vector2(0, -88), 42.0, Color("#6b4a2a"))
	c.draw_line(kp + Vector2(36, -100), kp + Vector2(82, -126), Color("#6b4a2a"), 10.0)
	for i in 3:
		var sp := kp + Vector2(sin(t * 1.3 + i * 2.0) * 14.0, -150.0 - fmod(t * 40.0 + i * 40.0, 120.0))
		var a := 1.0 - fmod(t * 40.0 + i * 40.0, 120.0) / 120.0
		c.draw_circle(sp, 14.0 + (1.0 - a) * 20.0, Color(0.9, 0.85, 0.75, 0.18 * a))


func _glow(c: Node2D) -> void:
	# than đỏ dưới ấm
	blob(c, Vector2(1420, ground_y - 10), 90.0, Color(1.0, 0.45, 0.15, 0.35 + 0.08 * sin(t * 7.0)))
	if t < 0.0:
		return
	var a3 := L("k11-03")
	var a4 := L("k11-04")
	# sáu dòng từ sáu thẻ đào bay vào bụng
	for i in 6:
		var st := a3 + 0.3 + i * 0.35
		var pr := smooth(st, st + 1.2, t)
		var fade := 1.0 - smooth(a3 + 4.6, a3 + 5.2, t)
		if pr > 0.0 and fade > 0.0:
			var col: Color = SIX[i][1]
			_stream(c, icons[i], belly, pr, col, fade, i)
	# hai dòng của Bất Giới
	for j in 2:
		var st := a4 + 1.2 + j * 0.4
		var pr := smooth(st, st + 1.0, t)
		var fade := 1.0 - smooth(L("k11-05") + 1.0, L("k11-05") + 1.6, t)
		if pr > 0.0 and fade > 0.0:
			_stream(c, bg_hand + Vector2(0, -10 + j * 20), belly, pr, MONK, fade, 7 + j)
	_belly_glow(c)


# một dòng chân khí uốn từ a tới b, đầu dòng chạy tới pr
func _stream(c: Node2D, a: Vector2, b: Vector2, pr: float, col: Color, k: float, seed: int) -> void:
	var pts := PackedVector2Array()
	var n := int(30 * pr) + 2
	var d := b - a
	var nn := Vector2(-d.y, d.x).normalized()
	for i in n:
		var u := float(i) / 30.0
		var off := sin(u * 9.0 + t * 6.0 + seed) * 26.0 * (1.0 - u) + sin(u * PI) * 60.0 * (1.0 if seed % 2 == 0 else -1.0)
		pts.append(a + d * u + nn * off)
	if pts.size() < 2:
		return
	c.draw_polyline(pts, Color(col, 0.14 * k), 18.0, true)
	c.draw_polyline(pts, Color(col * 1.25, 0.8 * k), 5.0, true)
	blob(c, pts[pts.size() - 1], 28.0, Color(col, 0.3 * k))


func _open() -> float:
	return smooth(L("k11-03") - 0.3, L("k11-03") + 0.5, t) * (1.0 - smooth(L("k11-06") + 0.3, L("k11-06") + 1.0, t)) \
		+ 0.6 * smooth(L("k11-07") + 2.0, L("k11-07") + 2.8, t) * (1.0 - smooth(L("k11-08") - 0.4, L("k11-08"), t))


# số dòng đã vào trong bụng
func _inside() -> int:
	var n := 0
	for i in 6:
		if t > L("k11-03") + 1.5 + i * 0.35:
			n += 1
	for j in 2:
		if t > L("k11-04") + 2.2 + j * 0.4:
			n += 1
	return n


func _loop_pts(i: int, rx: float, ry: float) -> PackedVector2Array:
	var fight := smooth(L("k11-05"), L("k11-05") + 0.6, t) * (1.0 - smooth(L("k11-06"), L("k11-06") + 0.8, t))
	var sp := 1.2 + i * 0.37 + fight * 2.5
	var k1 := 1.0 + (i % 3)
	var k2 := 2.0 + (i % 2)
	var pts := PackedVector2Array()
	for s in 49:
		var u := TAU * s / 48.0
		var j := sin(u * 7.0 + t * 13.0 + i) * 8.0 * fight
		pts.append(belly + Vector2(cos(u * k1 + t * sp + i) * (rx + j), sin(u * k2 + t * sp * 0.8 + i * 1.7) * (ry + j)))
	return pts


func _belly_glow(c: Node2D) -> void:
	var o := _open()
	if o < 0.01:
		return
	var n := _inside()
	for i in n:
		var col: Color = MONK if i >= 6 else SIX[i][1]
		var pts := _loop_pts(i, 58.0 * o, 66.0 * o)
		c.draw_polyline(pts, Color(col, 0.18 * o), 7.0, true)


func _near(c: Node2D) -> void:
	if t < 0.0:
		return
	var a1 := L("k11-01")
	# vò rượu thuốc nghiêng rót từ trên xuống hồ lô (k11-01)
	var pv := bump(a1 - 0.2, a1 + 0.4, a1 + 1.5, a1 + 2.0)
	if pv > 0.01:
		var mouth: Vector2 = ho.get("mouthw", wrist)
		var jp := mouth + Vector2(70, -270 + (1.0 - pv) * -200.0)
		c.draw_set_transform(jp, -1.9 * pv, Vector2.ONE * 0.75)
		c.draw_circle(Vector2.ZERO, 62.0, inkof(Color("#8a5a2a")))
		c.draw_circle(Vector2.ZERO, 58.0, Color("#8a5a2a"))
		c.draw_rect(Rect2(-24, -82, 48, 26), Color("#6b4426"))
		c.draw_rect(Rect2(-30, -14, 60, 38), Color("#b8322c"))
		c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		var lip := jp + Vector2(0, -52).rotated(-1.9 * pv)
		var fl := smooth(a1 + 0.5, a1 + 0.7, t) * (1.0 - smooth(a1 + 1.4, a1 + 1.6, t))
		if fl > 0.01:
			c.draw_line(lip, mouth, Color(MED, 0.9 * fl), 9.0, true)
			c.draw_line(lip, mouth, Color(1, 0.9, 0.7, 0.5 * fl), 3.0, true)
	# cửa sổ khoét trên bụng: nền xanh đêm, viền giấy, vạch khắc
	var o := _open()
	if o > 0.01:
		var rx := 74.0 * o
		var ry := 84.0 * o
		var wob := sin(t * 17.0) * 5.0 * smooth(L("k11-05"), L("k11-05") + 0.6, t) * (1.0 - smooth(L("k11-06"), L("k11-06") + 0.8, t))
		var ring := PackedVector2Array()
		for s in 40:
			var u := TAU * s / 40.0
			ring.append(belly + Vector2(cos(u) * (rx + wob * sin(u * 3.0)), sin(u) * (ry + wob * cos(u * 2.0))))
		c.draw_colored_polygon(ring, Color(TEAL, 0.92))
		hatch(c, ring, 0.8, 12.0, Color(0, 0, 0, 0.25), 2.0)
		var cl := ring.duplicate()
		cl.append(ring[0])
		c.draw_polyline(cl, Color("#f1e2c4"), 6.0, true)
		c.draw_polyline(cl, Color(ink, 0.9), 2.0, true)
		# đan điền
		c.draw_circle(belly + Vector2(0, 22) * o, 12.0 * o, Color("#b8322c"))
		var n := _inside()
		for i in n:
			var col: Color = MONK if i >= 6 else SIX[i][1]
			c.draw_polyline(_loop_pts(i, 58.0 * o, 66.0 * o), Color(col, 0.95), 3.0, true)
	# sáu thẻ gỗ đào
	var a2b := L("k11-02b")
	var gone := smooth(L("k11-04") - 0.5, L("k11-04"), t)
	for i in 6:
		var p: Vector2 = icons[i]
		var ap := smooth(a2b + 0.5 + i * 1.1, a2b + 0.9 + i * 1.1, t) * (1.0 - gone)
		if ap > 0.01:
			_the_dao(c, p, i, ap)
	# bàn tay Bình Nhất Chỉ
	_ban_tay(c)


# thẻ gỗ đào: tấm gỗ treo, hình phần cây ở giữa, chân que nhỏ nhảy
func _the_dao(c: Node2D, p: Vector2, i: int, a: float) -> void:
	var col: Color = SIX[i][1]
	var wood := Color("#c99a62")
	c.draw_line(p + Vector2(-12, 50), p + Vector2(-18, 74), Color(ink, a), 4.0)
	c.draw_line(p + Vector2(12, 50), p + Vector2(18, 74), Color(ink, a), 4.0)
	var r := Rect2(p + Vector2(-46, -54), Vector2(92, 108))
	c.draw_rect(r.grow(4), Color(ink, a))
	c.draw_rect(r, Color(wood, a))
	cut(c, p + Vector2(-34, -40), p + Vector2(-10, -44), 2.0, Color(ink, 0.4 * a))
	var q := p + Vector2(0, -6)
	match i:
		0:   # rễ
			for k in 4:
				c.draw_line(q + Vector2(0, -18), q + Vector2(-24 + k * 16, 22), Color(col.darkened(0.3), a), 5.0, true)
		1:   # thân
			c.draw_rect(Rect2(q + Vector2(-10, -26), Vector2(20, 52)), Color(col.darkened(0.2), a))
			cut(c, q + Vector2(-6, -10), q + Vector2(6, -6), 2.0, Color(ink, a))
		2:   # cành
			c.draw_line(q + Vector2(-24, 20), q + Vector2(22, -20), Color(Color("#6b4a2a"), a), 6.0, true)
			c.draw_line(q + Vector2(0, 0), q + Vector2(-14, -22), Color(Color("#6b4a2a"), a), 4.0, true)
			c.draw_circle(q + Vector2(22, -20), 6.0, Color(col, a))
		3:   # lá
			leaf(c, q + Vector2(-2, 18), -PI * 0.4, 46.0, 18.0, Color(col, a), 2.0)
		4:   # hoa
			for k in 5:
				var an := TAU * k / 5.0 + t * 0.6
				c.draw_circle(q + Vector2(cos(an), sin(an)) * 14.0, 11.0, Color(col, a))
			c.draw_circle(q, 7.0, Color(Color("#ffe080"), a))
		5:   # quả
			c.draw_circle(q + Vector2(0, 4), 22.0, Color(col, a))
			c.draw_line(q + Vector2(0, -18), q + Vector2(0, 18), Color(col.darkened(0.3), a), 2.0)
			leaf(c, q + Vector2(2, -18), -PI * 0.25, 22.0, 9.0, Color(Color("#6fb04a"), a), 1.5)


func _ban_tay(c: Node2D) -> void:
	var a6 := L("k11-06")
	var a6b := L("k11-06b")
	var k := smooth(a6 - 0.2, a6 + 0.8, t) * (1.0 - smooth(a6b + 5.4, a6b + 6.2, t))
	if k < 0.01:
		return
	var tip := wrist + Vector2(14, -6)
	var base := tip + Vector2(700, -140)
	var hp := base.lerp(tip + Vector2(70, -20), k)
	# tay áo xám xanh
	var dir := (hp - base).normalized()
	var nrm := Vector2(-dir.y, dir.x)
	var sl := PackedVector2Array([base + nrm * 70, hp - dir * 40 + nrm * 50, hp - dir * 40 - nrm * 50, base - nrm * 70])
	shape(c, sl, Color("#9aa6b0"), 5.0, Color("#f1e2c4"))
	hatch(c, sl, 0.9, 16.0, Color(ink, 0.35), 2.0)
	var cf := PackedVector2Array([hp - dir * 40 + nrm * 52, hp - dir * 70 + nrm * 56, hp - dir * 70 - nrm * 56, hp - dir * 40 - nrm * 52])
	shape(c, cf, Color("#5a6672"), 3.0)
	# lòng bàn tay úp + một ngón duỗi đặt lên cổ tay; sau đó ngón tay lắc qua lắc lại
	var wag := sin((t - a6 - 2.2) * 11.0) * 0.5 * smooth(a6 + 2.0, a6 + 2.4, t)
	c.draw_circle(hp, 40.0, inkof(Color("#f0c8a0")))
	c.draw_circle(hp, 36.0, Color("#f0c8a0"))
	for f in 3:
		c.draw_circle(hp + Vector2(-20, 22 + f * 8).rotated(-0.3), 14.0, Color("#e6b890"))
	var fa := (-dir).rotated(wag) if wag != 0.0 else -dir
	var fe := hp + fa * 72.0
	c.draw_line(hp + fa * 20.0, fe, inkof(Color("#f0c8a0")), 22.0, true)
	c.draw_line(hp + fa * 20.0, fe, Color("#f0c8a0"), 16.0, true)
	c.draw_circle(fe, 8.0, Color("#f6dcc0"))


func _d_screen(c: Node2D) -> void:
	super._d_screen(c)
	if t < 0.0:
		return
	var a1 := L("k11-01")
	nhan(c, Vector2(960, 150), "RƯỢU THUỐC · ĐẮNG NGẮT", 46, Color("#7a3a1a"), bump(a1 + 0.8, a1 + 1.2, a1 + 3.6, a1 + 4.0), -0.02)
	var a2 := L("k11-02")
	nhan(c, Vector2(960, 150), "ĐÀO CỐC LỤC TIÊN", 52, Color("#b8322c"), bump(a2 + 2.6, a2 + 3.0, L("k11-02b") - 0.3, L("k11-02b")), 0.02)
	# tên sáu phần cây, hiện lần lượt hàng ngang dưới đáy
	var a2b := L("k11-02b")
	var off := 1.0 - smooth(L("k11-03") - 0.4, L("k11-03"), t)
	for i in 6:
		var ap := smooth(a2b + 0.5 + i * 1.1, a2b + 0.9 + i * 1.1, t) * off
		var col: Color = SIX[i][1]
		nhan(c, Vector2(420 + i * 216, 980), SIX[i][0], 40, col.darkened(0.35), ap)
	var a3 := L("k11-03")
	var a4 := L("k11-04")
	var a5 := L("k11-05")
	nhan(c, Vector2(960, 150), "SÁU LUỒNG CHÂN KHÍ", 50, Color("#245a52"), bump(a3 + 0.4, a3 + 0.8, a4 - 0.4, a4), -0.02)
	nhan(c, Vector2(960, 150), "BẤT GIỚI THÊM HAI LUỒNG", 50, Color("#8a6a1a"), bump(a4 + 1.0, a4 + 1.4, a5 - 0.4, a5), 0.02)
	nhan(c, Vector2(960, 150), "TÁM LUỒNG ĐÁNH NHAU", 54, Color("#b8322c"), bump(a5 + 0.4, a5 + 0.8, LE("k11-05") + 0.2, LE("k11-05") + 0.6), -0.03)
	var a6 := L("k11-06")
	var a6b := L("k11-06b")
	nhan(c, Vector2(960, 150), "BÌNH NHẤT CHỈ LẮC ĐẦU", 50, Color("#4f5a66"), bump(a6 + 1.0, a6 + 1.4, a6b - 0.3, a6b), 0.02)
	nhan(c, Vector2(960, 150), "SÁT NHÂN DANH Y", 56, Color("#5a2a22"), bump(a6b + 0.4, a6b + 0.8, a6b + 6.6, a6b + 7.2), -0.02)
