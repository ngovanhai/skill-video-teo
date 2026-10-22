# Cảnh vật vẽ mực của tập 01 (cửa ải, lều, chùa, thành, chim nhạn, cây, mây, bóng người…). p = độ hiện 0..1.
class_name Canh

const W := 2400.0   # bề rộng một khung trên cuộn
const GROUND := 300.0

static func ink(a := 1.0) -> Color: return But.ca(But.MUC, a)

# mặt đất: một nét cọ ngang dài + vài cụm cỏ
static func dat(c: CanvasItem, x0: float, x1: float, y: float, p := 1.0, seed := 0.0) -> void:
	var pts := PackedVector2Array()
	for i in 25:
		var u := i / 24.0
		pts.append(Vector2(lerpf(x0, x1, u), y + 8.0 * (But.n1(u * 6.0 + seed) - 0.5)))
	But.net(c, pts, 7, ink(0.75), p, 0.05, 0.2, 0.35, seed, 0.3)
	for i in 9:
		var x := lerpf(x0, x1, But.h1(seed + i * 1.3))
		co(c, Vector2(x, y), 0.6 + But.h1(seed + i) * 0.6, clampf(p * 1.5 - But.h1(seed + i * 2.0) * 0.5, 0.0, 1.0), seed + i)

static func co(c: CanvasItem, at: Vector2, s := 1.0, p := 1.0, seed := 0.0, t := 0.0) -> void:
	for k in 5:
		var a := (k - 2) * 0.32 + (But.h1(seed + k) - 0.5) * 0.3 + sin(t * 1.5 + seed + k) * 0.06
		var l := (34 + 30 * But.h1(seed + k * 3.0)) * s
		var tip := at + Vector2(sin(a) * l, -cos(a) * l)
		But.net(c, But.qd(at, at.lerp(tip, 0.5) + Vector2(a * 8, 0), tip, 8), 5 * s, ink(0.8), p, 0.0, 0.9, 0.1, seed + k)

# cửa ải đá: tường + cổng vòm + lầu mái cong
static func cua_ai(c: CanvasItem, ctr: Vector2, s := 1.0, p := 1.0, seed := 0.0, col := Color("7d7468")) -> void:
	if p <= 0.0: return
	var k := But.eo(p)
	var w := 520.0 * s; var h := 260.0 * s
	var base := ctr.y
	var top := base - h * k
	c.draw_colored_polygon(PackedVector2Array([Vector2(ctr.x - w * 0.5, base), Vector2(ctr.x - w * 0.46, top), Vector2(ctr.x + w * 0.46, top), Vector2(ctr.x + w * 0.5, base)]), But.ca(col.lerp(But.GIAY, 0.25), 0.9 * p))
	# hàng gạch
	for r in int(6 * k):
		var y := base - (r + 1) * h / 6.0
		But.net(c, PackedVector2Array([Vector2(ctr.x - w * 0.48, y), Vector2(ctr.x + w * 0.48, y)]), 2.5, ink(0.35), 1.0, 0.05, 0.05, 0.4, seed + r)
	# vòm cổng
	var arch := PackedVector2Array()
	for i in 13:
		var a := PI + PI * i / 12.0
		arch.append(Vector2(ctr.x + cos(a) * 70 * s, base - 110 * s * k + sin(a) * 80 * s * k))
	arch.append(Vector2(ctr.x + 70 * s, base)); arch.insert(0, Vector2(ctr.x - 70 * s, base))
	c.draw_colored_polygon(arch, ink(0.85 * p))
	var outline := PackedVector2Array([Vector2(ctr.x - w * 0.5, base), Vector2(ctr.x - w * 0.46, top), Vector2(ctr.x + w * 0.46, top), Vector2(ctr.x + w * 0.5, base)])
	But.net(c, outline, 6, ink(0.9), p, 0.02, 0.02, 0.3, seed)
	# lầu
	if p > 0.5:
		var q := (p - 0.5) * 2.0
		var ly := top
		c.draw_colored_polygon(PackedVector2Array([Vector2(ctr.x - 150 * s, ly), Vector2(ctr.x - 150 * s, ly - 70 * s * q), Vector2(ctr.x + 150 * s, ly - 70 * s * q), Vector2(ctr.x + 150 * s, ly)]), But.ca(Color("8a3a2a").lerp(But.GIAY, 0.2), 0.85 * q))
		mai(c, Vector2(ctr.x, ly - 70 * s * q), 380 * s, 60 * s, q, seed)

# mái cong kiểu Á Đông
static func mai(c: CanvasItem, ctr: Vector2, w: float, h: float, p := 1.0, seed := 0.0) -> void:
	if p <= 0.0: return
	var pts := PackedVector2Array([ctr + Vector2(-w * 0.5 - 30, 8), ctr + Vector2(-w * 0.38, -h * 0.4), ctr + Vector2(-w * 0.2, -h), ctr + Vector2(w * 0.2, -h), ctr + Vector2(w * 0.38, -h * 0.4), ctr + Vector2(w * 0.5 + 30, 8), ctr + Vector2(w * 0.4, 0), ctr + Vector2(-w * 0.4, 0)])
	c.draw_colored_polygon(pts, ink(0.88 * p))
	But.net(c, But.qd(ctr + Vector2(-w * 0.5 - 40, -2), ctr + Vector2(0, -h * 0.25), ctr + Vector2(w * 0.5 + 40, -2)), 7, ink(p), 1.0, 0.1, 0.1, 0.2, seed)

static func nha_tranh(c: CanvasItem, ctr: Vector2, s := 1.0, p := 1.0, seed := 0.0) -> void:
	if p <= 0.0: return
	var k := But.eo(p)
	var w := 300.0 * s; var h := 150.0 * s
	c.draw_colored_polygon(PackedVector2Array([ctr + Vector2(-w * 0.5, 0), ctr + Vector2(-w * 0.5, -h * k), ctr + Vector2(w * 0.5, -h * k), ctr + Vector2(w * 0.5, 0)]), But.ca(Color("b59a6a").lerp(But.GIAY, 0.35), 0.85 * p))
	c.draw_colored_polygon(PackedVector2Array([ctr + Vector2(-30 * s, 0), ctr + Vector2(-30 * s, -90 * s * k), ctr + Vector2(30 * s, -90 * s * k), ctr + Vector2(30 * s, 0)]), ink(0.7 * p))
	var roof := PackedVector2Array([ctr + Vector2(-w * 0.62, -h * k + 10), ctr + Vector2(0, -h * k - 120 * s * k), ctr + Vector2(w * 0.62, -h * k + 10)])
	c.draw_colored_polygon(roof, But.ca(Color("8d7a4f").lerp(But.GIAY, 0.2), 0.9 * p))
	for i in 7:
		var u := i / 6.0
		var a := roof[0].lerp(roof[2], u)
		But.net(c, PackedVector2Array([roof[1].lerp(a, 0.15), a + Vector2(0, 6)]), 3, ink(0.5), p, 0.0, 0.6, 0.3, seed + i)
	var ol := roof.duplicate(); But.net(c, ol, 6, ink(0.9), p, 0.05, 0.05, 0.3, seed)

static func leu(c: CanvasItem, ctr: Vector2, s := 1.0, p := 1.0, seed := 0.0) -> void:   # lều tròn thảo nguyên
	if p <= 0.0: return
	var k := But.eo(p)
	var w := 260.0 * s; var h := 110.0 * s
	c.draw_colored_polygon(PackedVector2Array([ctr + Vector2(-w * 0.5, 0), ctr + Vector2(-w * 0.5, -h * k), ctr + Vector2(w * 0.5, -h * k), ctr + Vector2(w * 0.5, 0)]), But.ca(Color("e9dcc0"), 0.95 * p))
	var dome := PackedVector2Array()
	for i in 17:
		var a := PI + PI * i / 16.0
		dome.append(ctr + Vector2(cos(a) * w * 0.55, -h * k + sin(a) * 90 * s * k))
	c.draw_colored_polygon(dome, But.ca(Color("d8c8a4"), 0.95 * p))
	But.net(c, dome, 5, ink(0.85), p, 0.02, 0.02, 0.3, seed)
	for x in [-0.5, 0.5]: But.net(c, PackedVector2Array([ctr + Vector2(w * x, 0), ctr + Vector2(w * x, -h * k)]), 5, ink(0.85), p, 0.0, 0.0, 0.2)
	c.draw_colored_polygon(PackedVector2Array([ctr + Vector2(-26 * s, 0), ctr + Vector2(-26 * s, -70 * s * k), ctr + Vector2(26 * s, -70 * s * k), ctr + Vector2(26 * s, 0)]), But.ca(Color("a8432f"), 0.8 * p))
	But.net(c, PackedVector2Array([ctr + Vector2(-w * 0.5, -h * k * 0.5), ctr + Vector2(w * 0.5, -h * k * 0.5)]), 6, But.ca(Color("a8432f"), 0.7 * p), p, 0.0, 0.0, 0.2)

# thành: tường gạch mọc lên theo số hàng rows (có thể lẻ)
static func thanh(c: CanvasItem, x0: float, x1: float, base: float, rows: float, rh := 34.0, seed := 0.0, p := 1.0) -> void:
	if rows <= 0.0 or p <= 0.0: return
	var full := floori(rows); var part := rows - full
	for r in full + 1:
		var hgt := rh if r < full else rh * part
		if hgt <= 0.5: continue
		var y := base - r * rh
		c.draw_colored_polygon(PackedVector2Array([Vector2(x0, y), Vector2(x0, y - hgt), Vector2(x1, y - hgt), Vector2(x1, y)]), But.ca(Color("8c8172").lerp(But.GIAY, 0.3 + 0.03 * (r % 3)), 0.92 * p))
		var off := 0.0 if r % 2 == 0 else 35.0
		var x := x0 + off
		while x < x1:
			c.draw_line(Vector2(x, y), Vector2(x, y - hgt), ink(0.35 * p), 2.0)
			x += 70.0
		But.net(c, PackedVector2Array([Vector2(x0, y - hgt), Vector2(x1, y - hgt)]), 3, ink(0.55 * p), 1.0, 0.0, 0.0, 0.4, seed + r)
	# lỗ châu mai trên đỉnh
	var topy := base - rows * rh
	var x2 := x0
	while x2 < x1 - 20:
		c.draw_colored_polygon(PackedVector2Array([Vector2(x2, topy), Vector2(x2, topy - 22), Vector2(x2 + 36, topy - 22), Vector2(x2 + 36, topy)]), But.ca(Color("7d7468"), 0.95 * p))
		x2 += 60.0

# chim (nhạn / điêu): nét chữ V cong, vỗ cánh theo t
static func chim(c: CanvasItem, at: Vector2, s: float, t: float, a := 1.0, seed := 0.0) -> void:
	var f := sin(t * 7.0 + seed * 3.0) * 0.5 + 0.5
	var wy := lerpf(-14.0, 10.0, f) * s
	But.net(c, But.qd(at + Vector2(-34 * s, wy), at + Vector2(-14 * s, -10 * s), at), 6 * s, ink(a), 1.0, 0.4, 0.1, 0.1, seed)
	But.net(c, But.qd(at, at + Vector2(14 * s, -10 * s), at + Vector2(34 * s, wy)), 6 * s, ink(a), 1.0, 0.1, 0.4, 0.1, seed + 1)

static func dan_nhan(c: CanvasItem, lead: Vector2, s: float, t: float, a := 1.0, n := 7, dir := -1.0) -> void:
	for i in n:
		var row := (i + 1) / 2; var side := 1.0 if i % 2 == 1 else -1.0
		var off := Vector2(-dir * row * 60.0, side * row * 34.0) * s if i > 0 else Vector2.ZERO
		chim(c, lead + off + Vector2(0, sin(t * 2.0 + i) * 4.0), s, t, a, i)

static func may(c: CanvasItem, ctr: Vector2, s := 1.0, p := 1.0, seed := 0.0, t := 0.0) -> void:  # mây cuộn kiểu tranh cổ
	if p <= 0.0: return
	var dx := sin(t * 0.3 + seed) * 20.0
	for i in 3:
		var cc := ctr + Vector2((i - 1) * 70 * s + dx, -abs(i - 1) * -10 * s)
		var arc := PackedVector2Array()
		for j in 22:
			var a := PI * 0.9 + TAU * 0.85 * j / 21.0
			var r := (38 - j * 0.9) * s
			arc.append(cc + Vector2(cos(a), sin(a)) * r)
		But.net(c, arc, 5 * s, ink(0.55 * p), p, 0.1, 0.4, 0.2, seed + i)
	But.net(c, PackedVector2Array([ctr + Vector2(-140 * s + dx, 30 * s), ctr + Vector2(150 * s + dx, 30 * s)]), 5 * s, ink(0.45 * p), p, 0.2, 0.4, 0.3, seed)

static func cay(c: CanvasItem, at: Vector2, s := 1.0, p := 1.0, seed := 0.0, la := Color("6f8a4a")) -> void:  # cây: thân nét đậm + tán loang
	if p <= 0.0: return
	var top := at + Vector2((But.h1(seed) - 0.5) * 60 * s, -280 * s)
	But.net(c, But.qd(at, at.lerp(top, 0.5) + Vector2(30 * s, 0), top), 22 * s, ink(0.85), clampf(p * 1.6, 0, 1), 0.0, 0.5, 0.35, seed, 0.4)
	for k in 3:
		var bp := at.lerp(top, 0.5 + k * 0.15)
		var bt := bp + Vector2((k - 1) * 110 * s, -70 * s)
		But.net(c, But.qd(bp, bp.lerp(bt, 0.5) + Vector2(0, -20 * s), bt), 9 * s, ink(0.8), clampf(p * 2.0 - 0.4, 0, 1), 0.0, 0.8, 0.3, seed + k)
	for k in 5:
		var lc := top + Vector2((But.h1(seed + k * 3.1) - 0.5) * 260 * s, (But.h1(seed + k * 1.7) - 0.6) * 120 * s)
		But.loang(c, lc, 90 * s, 60 * s, la, seed + k, clampf(p * 2.0 - 0.6 - k * 0.1, 0, 1))

static func bong(c: CanvasItem, feet: Vector2, s := 1.0, a := 1.0, seed := 0.0, t := 0.0, pose := 0) -> void:  # bóng người (không mặt)
	var col := ink(a)
	var sway := sin(t * 2.0 + seed) * 3.0
	c.draw_circle(feet + Vector2(sway, -170 * s), 26 * s, col)
	var body := PackedVector2Array([feet + Vector2(-30 * s + sway, -142 * s), feet + Vector2(30 * s + sway, -142 * s), feet + Vector2(44 * s, -10 * s), feet + Vector2(-44 * s, -10 * s)])
	c.draw_colored_polygon(body, col)
	if pose == 1:   # giơ tay
		But.net(c, PackedVector2Array([feet + Vector2(24 * s, -130 * s), feet + Vector2(64 * s, -210 * s)]), 16 * s, col, 1.0, 0.0, 0.3, 0.1)
	elif pose == 2: # cầm giáo
		But.net(c, PackedVector2Array([feet + Vector2(34 * s, 0), feet + Vector2(44 * s, -260 * s)]), 5 * s, col, 1.0, 0.0, 0.0, 0.1)
	c.draw_colored_polygon(PackedVector2Array([feet + Vector2(-20 * s, -12 * s), feet + Vector2(-8 * s, 0), feet + Vector2(-30 * s, 0)]), col)
	c.draw_colored_polygon(PackedVector2Array([feet + Vector2(20 * s, -12 * s), feet + Vector2(30 * s, 0), feet + Vector2(8 * s, 0)]), col)

static func doan_quan(c: CanvasItem, x0: float, x1: float, y: float, rows: int, s: float, a: float, t: float, seed := 0.0, co_mau := Color("8a2a1e")) -> void:
	for r in rows:
		var n := int((x1 - x0) / (46.0 * s))
		for i in n:
			var x := x0 + i * 46.0 * s + (r % 2) * 23.0 * s
			bong(c, Vector2(x, y - r * 26.0 * s), s * (1.0 - r * 0.12), a * (1.0 - r * 0.2), seed + i + r * 31, t, 2)
	# cờ
	for i in 3:
		var fx := lerpf(x0, x1, (i + 0.5) / 3.0)
		var pole := Vector2(fx, y - rows * 26 * s - 260 * s)
		c.draw_line(Vector2(fx, y - 20), pole, ink(a), 4.0)
		var wv := sin(t * 3.0 + i) * 10.0
		c.draw_colored_polygon(PackedVector2Array([pole, pole + Vector2(90 * s, 10 + wv), pole + Vector2(84 * s, 56 * s + wv), pole + Vector2(0, 50 * s)]), But.ca(co_mau, 0.85 * a))

static func lua(c: CanvasItem, at: Vector2, s: float, t: float, a := 1.0) -> void:  # bếp lửa
	for i in 5:
		var h := (60 + 40 * But.n1(t * 4.0 + i * 2.0)) * s
		var x := (i - 2) * 12.0 * s
		var pts := PackedVector2Array([at + Vector2(x - 16 * s, 0), at + Vector2(x + sin(t * 6 + i) * 8 * s, -h), at + Vector2(x + 16 * s, 0)])
		c.draw_colored_polygon(pts, But.ca(Color("d9553f").lerp(Color("f2b04a"), float(i % 2)), 0.75 * a))
	But.net(c, PackedVector2Array([at + Vector2(-60 * s, 6), at + Vector2(60 * s, -4)]), 12 * s, ink(a), 1.0, 0.1, 0.1, 0.3)
	But.net(c, PackedVector2Array([at + Vector2(-50 * s, -6), at + Vector2(64 * s, 8)]), 12 * s, ink(a), 1.0, 0.1, 0.1, 0.3)

# nhãn tên: dấu son nhỏ + tên viết nghiêng
static func nhan(c: CanvasItem, s: String, at: Vector2, p := 1.0, size := 40, sub := "") -> void:
	if p <= 0.0: return
	But.dau(c, at + Vector2(-But.chu_w(s, size, 2) * 0.5 - 30, -size * 0.35), size * 0.9, [s.substr(0, 1)], p, 0.05, s.hash() % 100)
	But.chu(c, s, at, size, But.MUC, 2, HORIZONTAL_ALIGNMENT_CENTER, -1, p)
	if sub != "": But.chu(c, sub, at + Vector2(0, size * 0.9), int(size * 0.55), But.ca(But.MUC, 0.75), 0, HORIZONTAL_ALIGNMENT_CENTER, -1, p)

# đường thân rồng: từ đầu (head) lùi theo hướng -dir, uốn sóng chạy theo t
static func rong_path(head: Vector2, dir: Vector2, length: float, t: float, amp := 50.0, n := 30, waves := 1.6) -> PackedVector2Array:
	var o := PackedVector2Array()
	var d := dir.normalized(); var nm := Vector2(-d.y, d.x)
	for i in n:
		var u := float(i) / (n - 1)
		o.append(head - d * u * length + nm * sin(u * TAU * waves - t * 4.0) * amp * minf(u * 3.0, 1.0))
	return o

# ngựa mực: body ngang, chân chạy theo t
static func ngua(c: CanvasItem, feet: Vector2, s: float, t: float, face := 1.0, a := 1.0, seed := 0.0, run := 1.0) -> void:
	c.draw_set_transform(feet, 0.0, Vector2(s * face, s))
	var ik := ink(a)
	var bob := sin(t * 9.0 * run + seed) * 4.0 * run
	var body := But.blob_pts(Vector2(0, -110 + bob), 85, 34, seed, 0.06, 26)
	c.draw_colored_polygon(body, But.ca(Color("6b4a2b").lerp(But.GIAY, 0.25 + But.h1(seed) * 0.3), a))
	But.net(c, body, 4, ik, 1.0, 0.0, 0.0, 0.2, seed)
	for k in 4:
		var hx: float = [-60.0, -40.0, 50.0, 70.0][k]
		var ph := t * 9.0 * run + k * 1.6 + seed
		var knee := Vector2(hx + sin(ph) * 16 * run, -55 + bob)
		var hoof := Vector2(hx + sin(ph + 0.8) * 26 * run, -2 - maxf(0.0, cos(ph)) * 14 * run)
		But.net(c, PackedVector2Array([Vector2(hx, -100 + bob), knee, hoof]), 9, ik, 1.0, 0.0, 0.0, 0.1, seed + k)
	var neck := PackedVector2Array([Vector2(60, -128 + bob), Vector2(100, -175 + bob), Vector2(130, -170 + bob)])
	But.net(c, neck, 26, But.ca(Color("6b4a2b").lerp(But.GIAY, 0.3), a), 1.0, 0.1, 0.3, 0.1)
	But.net(c, neck, 5, ik, 1.0, 0.0, 0.2, 0.1)
	c.draw_colored_polygon(PackedVector2Array([Vector2(118, -186 + bob), Vector2(158, -160 + bob), Vector2(150, -148 + bob), Vector2(114, -160 + bob)]), ik)
	But.net(c, But.qd(Vector2(-84, -120 + bob), Vector2(-120, -110 + sin(t * 5.0) * 10), Vector2(-130, -60 + bob)), 10, ik, 1.0, 0.1, 0.8, 0.2)
	But.net(c, But.qd(Vector2(70, -150 + bob), Vector2(90, -190 + bob), Vector2(116, -186 + bob)), 8, ik, 1.0, 0.2, 0.5, 0.3)
	c.draw_set_transform(Vector2.ZERO)

# cột chữ dọc (mỗi từ một dòng), vẽ dần theo p
static func cot(c: CanvasItem, words: Array, top: Vector2, size: int, p: float, col := But.MUC, kind := 1) -> void:
	for i in words.size():
		var q := clampf(p * words.size() - i, 0.0, 1.0)
		But.chu(c, words[i], top + Vector2(0, i * size * 1.05), size, col, kind, HORIZONTAL_ALIGNMENT_CENTER, -1, q)

# vòng sóng mực loang ra
static func vong(c: CanvasItem, ctr: Vector2, r: float, w: float, a: float, seed := 0.0, sy := 0.35) -> void:
	if a <= 0.0 or r <= 0.0: return
	var pts := PackedVector2Array()
	for i in 49:
		var ang := TAU * i / 48.0
		pts.append(ctr + Vector2(cos(ang) * r, sin(ang) * r * sy) * (1.0 + 0.04 * (But.n1(i * 0.7 + seed) - 0.5)))
	But.net(c, pts, w, ink(a), 1.0, 0.1, 0.4, 0.3, seed, 0.4)

# vạch đếm (đếm năm / đếm lần)
static func vach(c: CanvasItem, at: Vector2, n: int, s := 1.0, a := 1.0, col := But.MUC) -> void:
	for i in n:
		var g := i / 5; var k := i % 5
		var x := at.x + g * 70.0 * s + k * 12.0 * s
		if k == 4:
			But.net(c, PackedVector2Array([Vector2(at.x + g * 70.0 * s - 6 * s, at.y - 6 * s), Vector2(at.x + g * 70.0 * s + 52 * s, at.y - 44 * s)]), 4 * s, But.ca(col, a), 1.0, 0.1, 0.2, 0.2, i)
		else:
			But.net(c, PackedVector2Array([Vector2(x, at.y), Vector2(x + 2 * s, at.y - 50 * s)]), 4 * s, But.ca(col, a), 1.0, 0.1, 0.2, 0.2, i)

# tờ giấy nhỏ (thư / trang sách / ghi chú)
static func to_giay(c: CanvasItem, ctr: Vector2, sz: Vector2, p: float, rot := 0.0, lines := 6, col := Color("f6efdc")) -> void:
	if p <= 0.0: return
	var k := But.eo(p)
	c.draw_set_transform(ctr, rot, Vector2(1, k))
	var r := Rect2(-sz * 0.5, sz)
	c.draw_rect(Rect2(r.position + Vector2(8, 10), r.size), Color(0, 0, 0, 0.12 * p))
	c.draw_rect(r, But.ca(col, p))
	c.draw_rect(r, ink(0.6 * p), false, 2.0)
	for i in lines:
		var y := -sz.y * 0.5 + (i + 1) * sz.y / (lines + 1)
		var w := sz.x * (0.75 - 0.25 * But.h1(i + rot * 10.0))
		But.net(c, PackedVector2Array([Vector2(-sz.x * 0.38, y), Vector2(-sz.x * 0.38 + w, y)]), 4, ink(0.55), clampf(p * 2.0 - 1.0 - i * 0.05, 0, 1), 0.1, 0.4, 0.4, i)
	c.draw_set_transform(Vector2.ZERO)

# màn trời (mảng tối phủ lên phần trên khung)
static func troi(c: CanvasItem, x0: float, x1: float, col: Color, a: float, y0 := -620.0, y1 := 200.0) -> void:
	if a <= 0.0: return
	var top := PackedVector2Array([Vector2(x0, y0), Vector2(x1, y0)])
	var bot := PackedVector2Array([Vector2(x0, y1), Vector2(x1, y1)])
	c.draw_polygon(PackedVector2Array([top[0], top[1], bot[1], bot[0]]), PackedColorArray([But.ca(col, a), But.ca(col, a), But.ca(col, 0), But.ca(col, 0)]))

# tuyết rơi trong vùng
static func tuyet(c: CanvasItem, r: Rect2, t: float, n: int, a := 1.0) -> void:
	for i in n:
		var x := r.position.x + fposmod(But.h1(i) * r.size.x + sin(t * 0.8 + i) * 30.0, r.size.x)
		var y := r.position.y + fposmod(But.h1(i * 1.3) * r.size.y + t * (40.0 + 30.0 * But.h1(i * 2.1)), r.size.y)
		c.draw_circle(Vector2(x, y), 2.5 + 3.0 * But.h1(i * 3.1), Color(1, 1, 1, 0.85 * a))
