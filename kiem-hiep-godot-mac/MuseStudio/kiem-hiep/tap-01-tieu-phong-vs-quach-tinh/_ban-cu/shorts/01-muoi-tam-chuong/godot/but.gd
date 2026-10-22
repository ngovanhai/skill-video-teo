# Bút mực của tập 01: nét cọ thon hai đầu, mảng loang màu nước, núi thuỷ mặc, chữ, dấu son.
# Mọi hàm vẽ thẳng lên một CanvasItem (gọi trong _draw), thuần theo tham số — không giữ trạng thái.
class_name But

const MUC := Color("1b1712")          # mực đen ấm
const GIAY := Color("efe6d2")         # giấy
const SON := Color("b8322a")          # son đỏ (dấu triện)
const SON2 := Color("d9553f")

static var _font: Font
static var _fontb: Font
static var _fonti: Font
static func font(kind := 0) -> Font:
	if _font == null:
		_font = load("res://font/pala.ttf"); _fontb = load("res://font/palab.ttf"); _fonti = load("res://font/palai.ttf")
	return [_font, _fontb, _fonti][kind]

# ---------------------------------------------------------------- số giả ngẫu nhiên / nhiễu
static func h1(x: float) -> float:
	return fposmod(sin(x * 12.9898 + 78.233) * 43758.5453, 1.0)
static func n1(x: float) -> float:   # nhiễu trơn 1 chiều, 0..1
	var i := floorf(x); var f := x - i
	var u := f * f * (3.0 - 2.0 * f)
	return lerpf(h1(i), h1(i + 1.0), u)
static func ez(x: float) -> float:   # ease in-out
	x = clampf(x, 0.0, 1.0); return x * x * (3.0 - 2.0 * x)
static func eo(x: float) -> float:   # ease out
	x = clampf(x, 0.0, 1.0); return 1.0 - (1.0 - x) * (1.0 - x) * (1.0 - x)
static func pg(lt: float, a: float, d: float) -> float:  # tiến độ 0..1 của đoạn [a, a+d]
	return clampf((lt - a) / maxf(d, 0.001), 0.0, 1.0)
static func ca(c: Color, a: float) -> Color:
	return Color(c.r, c.g, c.b, c.a * a)

# ---------------------------------------------------------------- đường
static func bez(a: Vector2, b: Vector2, c: Vector2, d: Vector2, n := 24) -> PackedVector2Array:
	var o := PackedVector2Array()
	for i in n + 1:
		var t := float(i) / n; var m := 1.0 - t
		o.append(a * m * m * m + b * 3.0 * m * m * t + c * 3.0 * m * t * t + d * t * t * t)
	return o
static func qd(a: Vector2, b: Vector2, c: Vector2, n := 18) -> PackedVector2Array:
	var o := PackedVector2Array()
	for i in n + 1:
		var t := float(i) / n
		o.append(a.lerp(b, t).lerp(b.lerp(c, t), t))
	return o
static func len_of(p: PackedVector2Array) -> float:
	var s := 0.0
	for i in range(1, p.size()): s += p[i].distance_to(p[i - 1])
	return s
# cắt đường tới tỉ lệ độ dài p (0..1)
static func cut(pts: PackedVector2Array, p: float) -> PackedVector2Array:
	if p >= 1.0: return pts
	var L := len_of(pts) * clampf(p, 0.0, 1.0); var o := PackedVector2Array(); var s := 0.0
	if pts.size() == 0: return o
	o.append(pts[0])
	for i in range(1, pts.size()):
		var d := pts[i].distance_to(pts[i - 1])
		if s + d >= L:
			o.append(pts[i - 1].lerp(pts[i], (L - s) / maxf(d, 0.0001))); return o
		s += d; o.append(pts[i])
	return o

# ---------------------------------------------------------------- nét cọ
# pts: đường tâm; w: bề rộng lớn nhất; p: phần đã vẽ (0..1, đầu cọ thon lại ở chỗ đang vẽ)
# tin/tout: đoạn thon đầu/cuối (tỉ lệ); rough: độ sần mép; dry: vệt xơ cọ (0..1)
static func net(c: CanvasItem, pts: PackedVector2Array, w: float, col: Color = MUC, p := 1.0, tin := 0.12, tout := 0.3, rough := 0.18, seed := 0.0, dry := 0.0) -> void:
	if p <= 0.0 or pts.size() < 2: return
	var full := len_of(pts)
	var q := cut(pts, p)
	if q.size() < 2: return
	# lấy mẫu đều ~5px
	var smp := PackedVector2Array(); var us := PackedFloat32Array()
	var step := 5.0; var acc := 0.0; smp.append(q[0]); us.append(0.0)
	for i in range(1, q.size()):
		var a := q[i - 1]; var b := q[i]; var d := a.distance_to(b)
		var k := step - fmod(acc, step)
		while k < d:
			smp.append(a.lerp(b, k / d)); us.append((acc + k) / full); k += step
		acc += d
	smp.append(q[q.size() - 1]); us.append(acc / full)
	var n := smp.size()
	if n < 2: return
	var drawn := acc / full
	var L := PackedVector2Array(); var R := PackedVector2Array()
	for i in n:
		var a := smp[maxi(i - 1, 0)]; var b := smp[mini(i + 1, n - 1)]
		var dir := (b - a).normalized()
		if dir == Vector2.ZERO: dir = Vector2.RIGHT
		var nm := Vector2(-dir.y, dir.x)
		var u := us[i]
		var prof := minf(1.0, u / maxf(tin, 0.001)) * minf(1.0, (1.0 - u) / maxf(tout, 0.001))
		prof = sqrt(clampf(prof, 0.0, 1.0))
		var front := clampf((drawn - u) * full / maxf(w * 1.6, 1.0), 0.0, 1.0)  # đầu cọ đang đi thì thon
		var ww := w * 0.5 * prof * (0.35 + 0.65 * front)
		var r1 := 1.0 + rough * (n1(u * full * 0.05 + seed * 7.1) - 0.5) * 2.0
		var r2 := 1.0 + rough * (n1(u * full * 0.05 + seed * 7.1 + 31.0) - 0.5) * 2.0
		L.append(smp[i] + nm * ww * r1); R.append(smp[i] - nm * ww * r2)
	_strip(c, L, R, col)
	if dry > 0.0:   # vệt xơ cọ: vài sợi mảnh lệch tâm, nhạt
		for s in 3:
			var off := (h1(seed + s * 3.3) - 0.5) * w * 0.7
			var L2 := PackedVector2Array(); var R2 := PackedVector2Array()
			for i in n:
				var mid := (L[i] + R[i]) * 0.5; var nm2 := (L[i] - R[i]).normalized()
				var ww2 := w * 0.06 * (0.5 + h1(seed + s))
				L2.append(mid + nm2 * (off + ww2)); R2.append(mid + nm2 * (off - ww2))
			_strip(c, L2, R2, ca(GIAY, dry * 0.8))

static func _strip(c: CanvasItem, L: PackedVector2Array, R: PackedVector2Array, col: Color) -> void:
	var n := L.size()
	if n < 2: return
	var pts := PackedVector2Array(); var idx := PackedInt32Array(); var cols := PackedColorArray()
	for i in n:
		pts.append(L[i]); pts.append(R[i]); cols.append(col); cols.append(col)
	for i in n - 1:
		var a := i * 2
		idx.append_array([a, a + 1, a + 2, a + 1, a + 3, a + 2])
	RenderingServer.canvas_item_add_triangle_array(c.get_canvas_item(), idx, pts, cols)

# dải màu có màu từng đỉnh (cho đuôi rồng nhạt dần…)
static func strip_cols(c: CanvasItem, L: PackedVector2Array, R: PackedVector2Array, cols_in: PackedColorArray) -> void:
	var n := L.size()
	if n < 2: return
	var pts := PackedVector2Array(); var idx := PackedInt32Array(); var cols := PackedColorArray()
	for i in n:
		pts.append(L[i]); pts.append(R[i]); var ci := cols_in[mini(i, cols_in.size() - 1)]; cols.append(ci); cols.append(ci)
	for i in n - 1:
		var a := i * 2
		idx.append_array([a, a + 1, a + 2, a + 1, a + 3, a + 2])
	RenderingServer.canvas_item_add_triangle_array(c.get_canvas_item(), idx, pts, cols)

# ---------------------------------------------------------------- mảng loang (màu nước)
static func blob_pts(ctr: Vector2, rx: float, ry: float, seed: float, wob := 0.22, n := 40) -> PackedVector2Array:
	var o := PackedVector2Array()
	for i in n:
		var a := TAU * i / n
		var r := 1.0 + wob * (n1(a * 1.6 + seed * 13.0) - 0.5) * 2.0 + wob * 0.4 * (n1(a * 5.0 + seed * 3.0) - 0.5)
		o.append(ctr + Vector2(cos(a) * rx, sin(a) * ry) * r)
	return o
static func loang(c: CanvasItem, ctr: Vector2, rx: float, ry: float, col: Color, seed := 0.0, p := 1.0) -> void:
	if p <= 0.0: return
	var k := eo(p)
	# 3 lớp: quầng ngoài nhạt, thân, mép đậm (đặc trưng màu nước)
	c.draw_colored_polygon(blob_pts(ctr, rx * k * 1.08, ry * k * 1.08, seed + 0.5, 0.26), ca(col, 0.35))
	c.draw_colored_polygon(blob_pts(ctr, rx * k, ry * k, seed), ca(col, 0.55))
	c.draw_colored_polygon(blob_pts(ctr + Vector2(rx * 0.08, -ry * 0.06) * k, rx * k * 0.6, ry * k * 0.6, seed + 2.0, 0.3), ca(col, 0.3))

# chấm mực bắn
static func ban(c: CanvasItem, ctr: Vector2, r: float, n: int, seed: float, col: Color = MUC, p := 1.0) -> void:
	for i in n:
		var a := TAU * h1(seed + i * 1.7); var d := r * (0.2 + 0.8 * h1(seed + i * 2.9)) * eo(p)
		var s := (2.0 + 9.0 * h1(seed + i * 5.3)) * (1.0 - 0.6 * d / r)
		c.draw_circle(ctr + Vector2(cos(a), sin(a)) * d, s, ca(col, clampf(p * 3.0, 0.0, 1.0)))

# ---------------------------------------------------------------- núi thuỷ mặc (đỉnh đậm, chân tan vào sương)
static func nui(c: CanvasItem, x0: float, x1: float, base: float, hgt: float, seed: float, col: Color, p := 1.0, peaks := 3.0) -> void:
	if p <= 0.0: return
	var top := PackedVector2Array(); var n := 60
	for i in n + 1:
		var u := float(i) / n; var x := lerpf(x0, x1, u)
		var env := sin(u * PI)
		var y := base - hgt * env * (0.55 + 0.45 * n1(u * peaks * 2.0 + seed)) * eo(p)
		top.append(Vector2(x, y))
	var pts := PackedVector2Array(); var cols := PackedColorArray()
	for i in n + 1:
		pts.append(top[i]); cols.append(ca(col, 0.85))
	for i in range(n, -1, -1):
		pts.append(Vector2(top[i].x, base + 40)); cols.append(ca(col, 0.0))
	c.draw_polygon(pts, cols)
	net(c, top, 5.0, ca(MUC, 0.55 * p), 1.0, 0.05, 0.05, 0.3, seed)

# ---------------------------------------------------------------- chữ
static func chu(c: CanvasItem, s: String, pos: Vector2, size: int, col: Color = MUC, kind := 0, align := HORIZONTAL_ALIGNMENT_CENTER, width := -1.0, p := 1.0) -> void:
	if p <= 0.0: return
	var f := font(kind)
	var w := width if width > 0 else f.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	var x := pos.x - (w * 0.5 if align == HORIZONTAL_ALIGNMENT_CENTER else (w if align == HORIZONTAL_ALIGNMENT_RIGHT else 0.0))
	c.draw_string(f, Vector2(x, pos.y), s, HORIZONTAL_ALIGNMENT_LEFT, -1, size, ca(col, clampf(p * 1.5, 0.0, 1.0)))
static func chu_w(s: String, size: int, kind := 0) -> float:
	return font(kind).get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x

# ---------------------------------------------------------------- dấu son (triện)
static func dau(c: CanvasItem, ctr: Vector2, sz: float, lines: Array, p := 1.0, rot := 0.0, seed := 0.0) -> void:
	if p <= 0.0: return
	var k := 1.0 + 0.25 * (1.0 - eo(clampf(p * 2.0, 0.0, 1.0)))   # đóng xuống: hơi to rồi ép lại
	var a := clampf(p * 3.0, 0.0, 1.0)
	c.draw_set_transform(ctr, rot, Vector2(k, k))
	var poly := PackedVector2Array()
	for i in 4:
		var cn: Vector2 = [Vector2(-1, -1), Vector2(1, -1), Vector2(1, 1), Vector2(-1, 1)][i] * sz * 0.5
		poly.append(cn + Vector2(h1(seed + i) - 0.5, h1(seed + i + 9) - 0.5) * sz * 0.04)
	c.draw_colored_polygon(poly, ca(SON, 0.92 * a))
	var fs := int(sz * 0.8 / maxf(1.0, lines.size()) * 0.62)
	for i in lines.size():
		var y := -sz * 0.5 + sz * (i + 0.5) / lines.size() + fs * 0.35
		chu(c, str(lines[i]), Vector2(0, y), fs, ca(GIAY, a), 1)
	# mép triện ăn mòn
	for i in 14:
		var e := Vector2(h1(seed + i * 2.1) - 0.5, h1(seed + i * 3.7) - 0.5) * sz
		c.draw_circle(e, sz * 0.02 * (0.5 + h1(seed + i)), ca(GIAY, 0.8 * a))
	c.draw_set_transform(Vector2.ZERO)

# ---------------------------------------------------------------- rồng mực
# path: các điểm thân rồng từ đầu tới đuôi; p: độ hiện; w: bề rộng thân; t: thời gian (cho vảy lượn)
static func rong(c: CanvasItem, path: PackedVector2Array, w: float, col: Color, p := 1.0, t := 0.0, seed := 0.0) -> void:
	if p <= 0.0 or path.size() < 3: return
	var q := cut(path, p)
	var n := q.size()
	if n < 3: return
	var L := PackedVector2Array(); var R := PackedVector2Array(); var cols := PackedColorArray()
	for i in n:
		var a := q[maxi(i - 1, 0)]; var b := q[mini(i + 1, n - 1)]
		var nm := Vector2(-(b - a).normalized().y, (b - a).normalized().x)
		var u := float(i) / (n - 1)
		var ww := w * (0.35 + 0.65 * sin(clampf(u * 1.2 + 0.08, 0.0, 1.0) * PI * 0.5 + 0.4)) * (1.0 - u * 0.75)
		ww *= 1.0 + 0.12 * sin(u * 30.0 - t * 6.0)
		L.append(q[i] + nm * ww * 0.5); R.append(q[i] - nm * ww * 0.5)
		cols.append(ca(col, lerpf(0.95, 0.15, u * u)))
	strip_cols(c, L, R, cols)
	# vây lưng: nét ngắn xiên
	for i in range(2, n - 2, 3):
		var a2 := q[i - 1]; var b2 := q[i + 1]
		var dir := (b2 - a2).normalized(); var nm2 := Vector2(-dir.y, dir.x)
		var u2 := float(i) / (n - 1)
		var base := L[i]
		var tip := base + nm2 * w * 0.35 * (1.0 - u2) - dir * w * 0.25
		net(c, PackedVector2Array([base, tip]), w * 0.12 * (1.0 - u2 * 0.7), ca(col, 0.9 - u2 * 0.6), 1.0, 0.0, 0.8, 0.1, seed + i)
	# đầu rồng ở q[0]: mõm + sừng + râu
	var hd := q[0]; var dir0 := (q[0] - q[2]).normalized(); var nm0 := Vector2(-dir0.y, dir0.x)
	var hw := w * 0.75
	var head := PackedVector2Array([hd + dir0 * hw * 1.1, hd + nm0 * hw * 0.55 + dir0 * hw * 0.2, hd + nm0 * hw * 0.5 - dir0 * hw * 0.6, hd - nm0 * hw * 0.5 - dir0 * hw * 0.6, hd - nm0 * hw * 0.4 + dir0 * hw * 0.3])
	c.draw_colored_polygon(head, ca(col, 0.95))
	c.draw_circle(hd + nm0 * hw * 0.2 + dir0 * hw * 0.15, hw * 0.11, GIAY)
	net(c, qd(hd + nm0 * hw * 0.4 - dir0 * hw * 0.3, hd + nm0 * hw * 1.3 - dir0 * hw * 0.6, hd + nm0 * hw * 1.2 - dir0 * hw * 1.3), w * 0.12, col, 1.0, 0.0, 0.9)
	for s in [-1.0, 1.0]:
		var wv := sin(t * 3.0 + s) * hw * 0.4
		net(c, qd(hd + dir0 * hw * 0.8 + nm0 * s * hw * 0.2, hd + dir0 * hw * 1.6 + nm0 * (s * hw * 0.9 + wv), hd + dir0 * hw * 1.0 + nm0 * (s * hw * 1.8 + wv)), w * 0.07, ca(col, 0.8), 1.0, 0.0, 0.9)
