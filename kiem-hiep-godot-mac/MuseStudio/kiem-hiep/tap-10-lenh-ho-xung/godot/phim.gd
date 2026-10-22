extends Node2D
# [tap-10] Chín lần rót đầy hồ lô ở quầy Hồi Nhạn lâu.
# Mỗi khung (shot) là một cảnh canh/<file>.gd chạy trong SubViewport riêng, tua theo giờ tập.
# Đổi khung = một dòng rượu tràn ngang màn hình (màu theo lần rót), che đúng lúc đổi cảnh nên chỉ một cảnh sống một lúc.
# Lớp trên: nhãn vò rượu (chữ có câu đọc kèm), chín hồ lô đếm lần rót, bảng CTA, khung nhãn cho chiêu chuong-2d.

const W := 1920.0
const H := 1080.0
const INK := Color("#3A2416")
const PAPER := Color("#f1e2c0")
const VERM := Color("#b8322c")
const CHIEU_T := 505.7
const CHIEU_LEN := 12.5

# kid -> [file cảnh, kiểu, lần rót]
const SCN := {
	"k01": ["quan", "ghe", 0], "k02": ["quan", "quay", 1],
	"k03": ["nui", "chieu", 2], "k03b": ["nui", "sang", 2], "k04": ["khikiem", "", 2], "k05": ["khucnhac", "rung", 2],
	"k06": ["vach", "k06", 3], "k07": ["vach", "k07", 3], "k08": ["vach", "k08", 3], "k09": ["", "chieu", 3],
	"k10": ["vach", "k10", 3], "k11": ["noithuong", "", 4], "k12": ["luctruc", "k12", 5], "k13": ["luctruc", "k13", 5],
	"k14": ["nui", "mua", 6], "k15": ["maitrang", "", 6], "k16": ["thieulam", "k16", 7], "k16b": ["thieulam", "k16b", 7],
	"k17": ["thieulam", "k17", 7], "k18": ["matna", "", 8], "k19": ["quan", "ban", 8], "k20": ["khucnhac", "song", 9],
	"k21": ["quan", "ke", 9],
}
const WINE := [Color("#d9a441"), Color("#f3ecd8"), Color("#e8b65a"), Color("#d98a3a"), Color("#6b4a2a"), Color("#e89ab0"),
	Color("#7fb8a8"), Color("#e6e2c8"), Color("#5a2a22"), Color("#e0a040")]

# nhãn vò rượu: chỉ chữ có trong câu đang đọc, ≤ 12 chữ
const CARD := {
	"k01-02": "Nhấc mông khỏi ghế trước là thua", "k01-03": "Điền Bá Quang", "k01-05": "Nghi Lâm",
	"k02-02": "Lệnh Hồ Xung · đại đệ tử Hoa Sơn", "k02-03": "Minh Báo 1967 – 1969 · bốn mươi hồi",
	"k02-07": "Chín lần rót đầy", "k03-05": "Quân Tử Kiếm", "k03b-01": "Lâm Bình Chi · tiêu cục Phúc Uy",
	"k03b-02": "Tịch Tà Kiếm Phổ", "k04-02": "Khí tông: nội công là gốc", "k04-03": "Kiếm tông: kiếm pháp là cốt lõi",
	"k04-05": "Khí tông thắng · khoảng 25 năm trước", "k04-06b": "Ngũ Nhạc kiếm phái",
	"k05-02": "Lưu Chính Phong · Khúc Dương", "k05-03": "Khúc Tiếu Ngạo Giang Hồ", "k05-07": "Quảng Lăng Tán · bản truyện cũ",
	"k06-03": "Tư Quá Nhai", "k07-01b": "Vạn Lý Độc Hành", "k08-02": "Phong Thanh Dương · thái sư thúc tổ",
	"k08-04": "Độc Cô Cửu Kiếm", "k08-04b": "Độc Cô Cầu Bại", "k08-05": "Tổng Quyết Thức",
	"k08-06": "kiếm · đao · thương · roi · dây · chưởng · tên · khí", "k10-02b": "Bất Khả Bất Giới",
	"k10-03": "Vô chiêu thắng hữu chiêu", "k11-02": "Đào Cốc Lục Tiên", "k11-02b": "rễ · thân · cành · lá · hoa · quả",
	"k11-06": "Bình Nhất Chỉ", "k12-01": "Lục Trúc Hạng · Lạc Dương", "k12-06": "Thanh Tâm Phổ Thiện Chú",
	"k13-01": "Nhậm Doanh Doanh", "k13-02": "Nhật Nguyệt thần giáo", "k14-02": "Trục xuất khỏi môn phái",
	"k15-01": "Mai Trang · Hàng Châu", "k15-02c": "Giang Nam Tứ Hữu", "k15-05": "Hấp Tinh Đại Pháp",
	"k16-04": "Dịch Cân Kinh", "k17-01": "Chưởng môn Hằng Sơn", "k18-04b": "Tả Lãnh Thiền · Tung Sơn",
	"k18-05": "Nguỵ quân tử", "k19-02": "Độc Cô Cửu Kiếm + Hấp Tinh Đại Pháp", "k19-02d": "Quỳ Hoa Bảo Điển",
	"k19-03": "Ý riêng của Tèo", "k20-03": "Ba năm sau", "k20-07": "Tiếu ngạo: cười ngạo nghễ",
}

var main: Node
var shots: Array = []            # {t0, t1, kid, file, m, lan}
var vp: SubViewport
var cur: Node = null
var cur_i := -1
var last_t := -1.0
var t := 0.0
var line_t0 := {}
var line_end := {}
var ch = null
var font: Font
var fontr: Font
var line_id := ""


func setup(m: Node) -> void:
	main = m
	font = load("res://font/constanb.ttf")
	fontr = load("res://font/constan.ttf")
	for l in main.lines:
		line_t0[l.id] = l.t0
		line_end[l.id] = l.t0 + l.dur
	for s in main.segs:
		var d: Array = SCN.get(s.kid, ["quan", "ke", 9])
		shots.append({"t0": s.t0, "t1": s.t1, "kid": s.kid, "file": d[0], "m": d[1], "lan": d[2]})
	# chiêu kết thúc trước khi hết đoạn k09: cảnh sau trận vào sớm
	for i in shots.size():
		if shots[i].kid == "k10":
			shots[i].t0 = CHIEU_T + CHIEU_LEN
			shots[i - 1].t1 = CHIEU_T + CHIEU_LEN
	shots[-1].t1 = main.DUR
	vp = SubViewport.new()
	vp.size = Vector2i(1920, 1080)
	vp.use_hdr_2d = true
	vp.own_world_3d = true
	vp.msaa_2d = Viewport.MSAA_2X
	vp.render_target_update_mode = SubViewport.UPDATE_DISABLED
	add_child(vp)
	if ResourceLoader.exists("res://chuong/chieu.gd"):
		ch = load("res://chuong/chieu.gd").new("doc_co", CHIEU_T, CHIEU_LEN)
		add_child(ch)


func _shot_at(tt: float) -> int:
	var k := 0
	for i in shots.size():
		if tt >= shots[i].t0:
			k = i
	return k


func at(tt: float, _seg: Dictionary, line: Dictionary) -> void:
	t = tt
	line_id = line.get("id", "")
	var i := _shot_at(t)
	if i != cur_i or t < last_t - 0.001:
		_spawn(i)
	last_t = t
	if cur:
		cur.tua(t - float(shots[i].t0))
	if ch:
		ch.at(t)
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS if cur else SubViewport.UPDATE_DISABLED
	queue_redraw()


func _spawn(i: int) -> void:
	if cur:
		cur.free()
		cur = null
	cur_i = i
	var s: Dictionary = shots[i]
	if s.file == "":
		return
	var n: Node = load("res://canh/%s.gd" % s.file).new()
	n.T0 = s.t0
	n.line_t0 = line_t0
	n.line_end = line_end
	n.arg = {"m": s.m, "lan": s.lan, "kid": s.kid, "dur": float(s.t1) - float(s.t0)}
	vp.add_child(n)
	cur = n


func lan_at(tt: float) -> int:
	return int(shots[_shot_at(tt)].lan)


func L(id: String) -> float:
	return float(line_t0.get(id, -99.0))


func LE(id: String) -> float:
	return float(line_end.get(id, -99.0))


# ---------------------------------------------------------------- vẽ

func _draw() -> void:
	var s: Dictionary = shots[cur_i]
	if cur:
		draw_texture_rect(vp.get_texture(), Rect2(0, 0, W, H), false)
	if s.file == "":
		_d_chieu()
	_d_notch()
	_d_card()
	_d_cta()
	_d_wipe()


func _d_chieu() -> void:
	# nhãn vò rượu khổng lồ: giấy đỏ son viền đôi, chiêu chạy trong ô
	draw_rect(Rect2(0, 0, W, H), Color("#2a1a10"))
	var k := smoothstep(504.9, 505.7, t)
	var r := Rect2(120, 70, 1680, 945)
	var ri := r.grow(-40)
	var rr := Rect2(r.position + Vector2(0, r.size.y * (1.0 - k) * 0.5), Vector2(r.size.x, r.size.y * k))
	draw_rect(rr, VERM)
	draw_rect(rr.grow(-14), Color("#e8c98f"), false, 4.0)
	if ch and t >= CHIEU_T and t < CHIEU_T + CHIEU_LEN:
		draw_texture_rect(ch.tex(), ri, false)
		draw_rect(ri, INK, false, 6.0)
	# bốn góc triện
	for c in [r.position, r.position + Vector2(r.size.x, 0), r.end, r.position + Vector2(0, r.size.y)]:
		var cc: Vector2 = c
		draw_circle(cc, 30.0 * k, Color("#e8c98f"))
		draw_circle(cc, 22.0 * k, VERM)
	if t < CHIEU_T + 0.4:
		_txt(Vector2(960, 560), "Độc Cô Cửu Kiếm", 72, Color(PAPER, k * (1.0 - smoothstep(CHIEU_T, CHIEU_T + 0.4, t))))


func _d_notch() -> void:
	# chín hồ lô nhỏ góc trên phải: rót tới đâu sáng tới đó
	var lan := lan_at(t)
	var b: float = shots[cur_i].t0
	if t < 1.0 or (shots[cur_i].file == "" and t > CHIEU_T):
		return
	for i in 9:
		var p := Vector2(1395 + i * 54, 62)
		var full := i < lan
		var pop := 0.0
		if i == lan - 1 and lan_at(b - 0.6) < lan:
			pop = sin(clampf((t - b) / 0.8, 0.0, 1.0) * PI) * 0.45
		var sc := 1.0 + pop
		var col: Color = WINE[i + 1] if full else Color(PAPER, 0.25)
		draw_circle(p + Vector2(0, 12) * sc, 15.0 * sc, Color(INK, 0.85))
		draw_circle(p + Vector2(0, -6) * sc, 10.0 * sc, Color(INK, 0.85))
		draw_circle(p + Vector2(0, 12) * sc, 12.0 * sc, col)
		draw_circle(p + Vector2(0, -6) * sc, 7.5 * sc, col)
		draw_line(p + Vector2(-8, 3) * sc, p + Vector2(8, 3) * sc, VERM, 3.0)
		draw_rect(Rect2(p + Vector2(-3, -20) * sc, Vector2(6, 6) * sc), Color(INK, 0.9))


func _d_card() -> void:
	if not CARD.has(line_id):
		return
	var a := smoothstep(L(line_id), L(line_id) + 0.25, t) * (1.0 - smoothstep(LE(line_id) + 0.2, LE(line_id) + 0.5, t))
	var pop := 1.0 + 0.12 * sin(clampf((t - L(line_id)) / 0.3, 0.0, 1.0) * PI)
	label(Vector2(960, 150), CARD[line_id], 46, a, pop, -0.02)


# nhãn dán vò rượu: giấy ngà, viền son đôi, chữ mực
func label(ctr: Vector2, txt: String, sz: int, a: float, sc := 1.0, rot := 0.0) -> void:
	if a <= 0.01:
		return
	var w := font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, sz).x + 90.0
	var h := sz * 1.9
	draw_set_transform(ctr, rot, Vector2(sc, sc))
	var r := Rect2(-w * 0.5, -h * 0.5, w, h)
	draw_rect(Rect2(r.position + Vector2(8, 10), r.size), Color(0, 0, 0, 0.3 * a))
	draw_rect(r, Color(PAPER, a))
	draw_rect(r.grow(-7), Color(VERM, a), false, 4.0)
	draw_rect(r.grow(-14), Color(VERM, a * 0.7), false, 1.5)
	draw_string(font, Vector2(-w * 0.5, sz * 0.36), txt, HORIZONTAL_ALIGNMENT_CENTER, w, sz, Color(INK, a))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _txt(p: Vector2, s: String, sz: int, col: Color) -> void:
	var w := font.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, sz).x
	draw_string(font, p + Vector2(-w * 0.5 + 3, sz * 0.35 + 3), s, HORIZONTAL_ALIGNMENT_LEFT, -1, sz, Color(0, 0, 0, col.a * 0.5))
	draw_string(font, p + Vector2(-w * 0.5, sz * 0.35), s, HORIZONTAL_ALIGNMENT_LEFT, -1, sz, col)


# bảng gỗ treo: CTA nói bằng giọng tiểu nhị (sổ khách quen)
func _board(ctr: Vector2, title: String, sub: String, a: float, swing: float) -> void:
	if a <= 0.01:
		return
	var drop := (1.0 - a) * -260.0
	var c := ctr + Vector2(0, drop)
	draw_line(c + Vector2(-150, -150), c + Vector2(-210, -60), Color(INK, a), 3.0)
	draw_line(c + Vector2(150, -150), c + Vector2(210, -60), Color(INK, a), 3.0)
	draw_set_transform(c, swing, Vector2.ONE)
	var r := Rect2(-330, -70, 660, 190)
	draw_rect(Rect2(r.position + Vector2(10, 12), r.size), Color(0, 0, 0, 0.35 * a))
	draw_rect(r, Color("#6b4426", a))
	for i in 5:
		draw_line(Vector2(-320, -40 + i * 36), Vector2(320, -36 + i * 36), Color("#4e2f1a", a * 0.6), 2.0)
	draw_rect(r, Color(INK, a), false, 5.0)
	draw_string(font, Vector2(-330, -6), title, HORIZONTAL_ALIGNMENT_CENTER, 660, 40, Color("#f3d79a", a))
	# nút đăng ký: triện đỏ
	var br := Rect2(-170, 22, 340, 78)
	draw_rect(br, Color(VERM, a))
	draw_rect(br.grow(-6), Color(PAPER, a * 0.8), false, 2.5)
	draw_string(font, Vector2(-170, 74), sub, HORIZONTAL_ALIGNMENT_CENTER, 340, 36, Color(PAPER, a))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)


func _d_cta() -> void:
	var a1 := smoothstep(L("k10-08") + 3.0, L("k10-08") + 3.6, t) * (1.0 - smoothstep(LE("k10-08") + 0.3, LE("k10-08") + 0.8, t))
	_board(Vector2(1440, 300), "Sổ khách quen · Tèo Kể", "ĐĂNG KÝ", a1, sin(t * 2.2) * 0.03)
	var a2 := smoothstep(L("k10-09"), L("k10-09") + 0.4, t) * (1.0 - smoothstep(LE("k10-09") + 0.3, LE("k10-09") + 0.8, t))
	label(Vector2(1400, 300), "Bình luận: lần rót nào nhớ nhất?", 40, a2, 1.0, 0.03)
	var a3 := smoothstep(L("k21-03") + 2.0, L("k21-03") + 2.6, t) * (1.0 - smoothstep(LE("k21-03") + 1.0, LE("k21-03") + 1.6, t))
	_board(Vector2(1420, 290), "Bình luận: lần sau kể ai?", "ĐĂNG KÝ Tèo Kể", a3, sin(t * 2.0) * 0.03)


# dòng rượu tràn ngang: phủ kín đúng lúc đổi cảnh
func _d_wipe() -> void:
	for i in range(1, shots.size()):
		var b: float = shots[i].t0
		if absf(t - b) > 0.5:
			continue
		var u := (t - (b - 0.5)) / 1.0
		var col: Color = WINE[int(shots[i].lan)]
		var x0 := 0.0
		var x1 := 0.0
		if u < 0.5:
			x1 = ease(u / 0.5, 0.6) * (W + 220.0)
		else:
			x0 = ease((u - 0.5) / 0.5, 2.0) * (W + 220.0) - 220.0
			x1 = W + 400.0
		_pour_band(x0, x1, col, b)


func _pour_band(x0: float, x1: float, col: Color, seed: float) -> void:
	var pts := PackedVector2Array()
	var edge := PackedVector2Array()
	var n := 24
	for j in n + 1:
		var y := H * j / n
		var wv := sin(y * 0.012 + t * 9.0 + seed) * 46.0 + sin(y * 0.031 - t * 5.0) * 18.0
		edge.append(Vector2(x1 + wv, y))
	var back := PackedVector2Array()
	for j in n + 1:
		var y := H * (n - j) / n
		var wv := 0.0 if x0 <= 0.0 else sin(y * 0.014 - t * 7.0 + seed) * 40.0
		back.append(Vector2(x0 + wv, y))
	pts.append_array(edge)
	pts.append_array(back)
	draw_colored_polygon(pts, col)
	# vân rượu: nét khắc chéo màu đậm hơn
	var dk := col.darkened(0.25)
	var gx := floorf(x0 / 70.0) * 70.0
	while gx < x1:
		draw_line(Vector2(gx, 0), Vector2(gx - 260, H), Color(dk, 0.35), 3.0)
		gx += 70.0
	draw_polyline(edge, Color(col.lightened(0.55), 0.95), 10.0, true)
	draw_polyline(edge, Color(INK, 0.5), 3.0, true)


func sfx() -> Array:
	var o: Array = []
	for i in range(1, shots.size()):
		o.append([float(shots[i].t0) - 0.45, "whoosh-short", -14.0])
	for id in ["k10-08", "k21-03"]:
		o.append([L(id) + 3.0, "chime", -10.0])
	for id in CARD:
		o.append([L(id) + 0.05, "click", -20.0])
	# k01: đao chém, ghế bật
	for k in 7:
		o.append([L("k01-06") + 0.4 + k * 0.62, "whoosh-short", -12.0])
	o.append([L("k01-03") + 1.2, "whoosh", -12.0])
	o.append([L("k01-07") + 2.6, "impact-bass-2", -10.0])
	o.append([L("k01-09") + 3.0, "pop", -12.0])
	# k07: đánh – thua – vào hang (lặp)
	for k in 4:
		o.append([L("k07-04") + 0.6 + k * 1.1, "whoosh-short", -13.0])
	o.append([L("k07-06") + 1.0, "impact-bass-2", -14.0])
	o.append([L("k08-01") + 0.5, "sparkle", -14.0])
	o.append([L("k13-01") + 0.3, "riser", -12.0])
	o.append([L("k14-02") + 1.0, "impact-bass-1", -12.0])
	o.append([L("k18-02") + 1.2, "glitch-1", -10.0])
	o.append([L("k18-02") + 1.6, "impact-bass-2", -10.0])
	o.append([L("k20-07") + 0.2, "sparkle", -12.0])
	if ch:
		o.append_array(ch.sfx())
	return o
