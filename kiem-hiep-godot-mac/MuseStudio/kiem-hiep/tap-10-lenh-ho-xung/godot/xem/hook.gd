extends "res://canh.gd"
# Thử hook k01 "đấu ngồi" nhìn qua khe ván quầy (mắt Tèo): chân ghế, niêm DÍNH, ghế bập bênh + trượt, Điền bật dậy, ghế đổ,
# cắt ngược thấy mắt Tèo sau khe ván, rồi Lệnh Hồ Xung giơ hồ lô rỗng. Giờ ở đây là giờ thử (cảnh thật lấy theo L(id)).

const WOOD := Color("#a8743e")
const FLOOR := Color("#5a3c22")

const HITS := [3.2, 3.9, 4.6, 5.7, 6.4]
const TJ := 7.6                 # Điền bật dậy
const TR0 := 8.7                # cắt ngược: mắt Tèo
const TR1 := 10.0
var lhx: Dictionary
var dien: Dictionary
var teo: Dictionary
var g_l: Dictionary
var g_d: Dictionary
var ho: Dictionary
var dao: Dictionary
var shreds: Array = []
var hit_done := 0
var TEO := Vector2(-1300, 880)


func _palette() -> void:
	sky_top = Color("#4a3220")
	sky_bot = Color("#7a5634")
	char_tint = Color(1.0, 0.95, 0.86)
	ground_y = 880.0
	vign_a = 0.25


func _build() -> void:
	g_l = ghe_moi(Vector2(800, ground_y), 1.0, WOOD)
	lhx = actor("lenh-ho-xung", g_l.p, 1.0)
	ho = prop(lhx, "ho_lo", "tay", "F")
	g_d = ghe_moi(Vector2(1120, ground_y), -1.0, WOOD.darkened(0.1))
	dien = actor("dien-ba-quang", g_d.p, -1.0)
	dien.expr = "gian"
	dao = prop(dien, "dao", "tay", "F")
	teo = actor("teo-tieu-nhi", TEO, 1.0)
	teo.expr = "soc"


func _arms(name: String) -> Dictionary:
	return arms_of(name)


func _story(dt: float) -> void:
	if t < 0.0:
		return
	# ---- dải niêm đóng dấu
	g_l.seal = smooth(1.5, 1.85, t)
	g_d.seal = smooth(2.1, 2.45, t)
	# ---- Điền chém: lấy đà → chém, mỗi nhát một lần
	var wu := 0.0
	var sl := 0.0
	for h: float in HITS:
		wu += bump(h - 0.55, h - 0.2, h - 0.14, h - 0.04)
		sl += bump(h - 0.12, h - 0.02, h + 0.2, h + 0.4)
	var up := smooth(TJ, TJ + 0.28, t)
	var seated := [[NGOI_CHOM, 1.0 - up], [_arms("windup"), wu * (1.0 - up)], [_arms("slash"), sl * (1.0 - up)]]
	dien.extra = seated + [["stance", up], [{"head": -10.0, "torso": -6.0}, up * (1.0 - smooth(TR1, TR1 + 0.5, t))]]
	dao.trail_on = sl > 0.45 and up < 0.1
	if not dao.trail_on:
		dao.trail.clear()
	# ---- ghế Lệnh Hồ Xung: mỗi nhát trượt lùi một đoạn + bập bênh dội lại; người né ngửa ra sau
	var dodge := 0.0
	var rk := 0.04
	var dx := 0.0
	for h: float in HITS:
		var e := t - h
		if e > 0.0:
			rk += 0.3 * exp(-3.5 * e) * absf(sin(e * 8.0))
		dx -= 22.0 * smooth(h - 0.02, h + 0.16, t)
		dodge += bump(h - 0.1, h, h + 0.15, h + 0.5)
	var laugh := bump(6.9, 7.1, 8.4, 8.6) + smooth(TR1 + 0.2, TR1 + 0.4, t) * (1.0 - smooth(11.2, 11.5, t))
	var s16 := sin(t * 15.0)
	rk += laugh * (0.1 + absf(s16) * 0.08)
	g_l.rock = rk
	g_l.dx = dx
	ngoi(lhx, g_l)
	var raise := smooth(11.3, 11.8, t)
	lhx.extra = [[NGOI_BAP_BENH, 1.0], [{"torso": -30.0, "head": -16.0, "uaF": -60.0, "faF": -50.0}, dodge],
		[{"head": s16 * 5.0, "torso": -10.0 + s16 * 3.0, "uaB": -40.0, "faB": -80.0}, laugh]]
	lhx.hold["F"] = [Vector2(46, -190), raise]
	ho.lock = raise
	ho.lockdir = Vector2(0.15, -1.0).normalized()
	lhx.expr = "soc" if dodge > 0.4 else ("vui" if laugh > 0.3 or raise > 0.3 else "dac-y")
	# áo rách: mỗi nhát văng mảnh vải
	while hit_done < HITS.size() and t >= float(HITS[hit_done]):
		var cp := to_w(lhx.node.J["torso"], Vector2(30, -60))
		for i in 6:
			var r := RandomNumberGenerator.new()
			r.seed = hit_done * 31 + i
			shreds.append({"p": cp + Vector2(r.randf_range(-20, 20), r.randf_range(-30, 30)), "v": Vector2(r.randf_range(-260, 60), r.randf_range(-380, -120)),
				"a": r.randf() * TAU, "w": r.randf_range(-9, 9), "s": r.randf_range(9, 16), "life": 0.0})
		hit_done += 1
	for s in shreds:
		var v: Vector2 = s.v
		v.y += 900.0 * dt
		v.x *= 0.985
		s.v = v
		var p: Vector2 = s.p
		p += v * dt
		if p.y > ground_y - 4.0:
			p.y = ground_y - 4.0
			s.v = Vector2.ZERO
			s.w = 0.0
		s.p = p
		s.a = float(s.a) + float(s.w) * dt
		s.life = float(s.life) + dt
	# ---- Điền bật dậy: người nhảy lên, niêm rách, ghế đổ ngửa
	g_d.tear = smooth(TJ, TJ + 0.7, t)
	if t < TJ:
		ngoi(dien, g_d)
	else:
		var e2 := t - TJ
		var hop := sin(clampf(e2 / 0.45, 0.0, 1.0) * PI) * 90.0
		dien.pos = g_d.p + Vector2(-34.0 * smooth(0.0, 0.45, e2), -hop)
		dien.rot = 0.0
		var f := smooth(TJ + 0.08, TJ + 0.5, t)
		var bo := 0.0
		if t > TJ + 0.5:
			bo = 0.07 * exp(-6.0 * (t - TJ - 0.5)) * absf(sin((t - TJ - 0.5) * 14.0))
		g_d.fall = f - bo
		g_d.dx = 26.0 * f
	dien.expr = "gian" if t < 6.8 else ("soc" if t < TR1 + 1.0 else "binh")
	# ---- Tèo sau quầy: ngồi xổm, nhổm lên tới khe ván, mắt mở to
	var peek := smooth(TR0 + 0.1, TR0 + 0.5, t)
	teo.extra = [[NGOI_XOM, 1.0], [{"all": [0.0, sin(t * 47.0) * 1.4, 52.0 - peek * 46.0], "head": -4.0}, 1.0]]
	teo.expr = "soc" if t > TR0 + 0.6 else "binh"
	teo.size = 1.0


func _eye_y() -> float:
	return to_w(teo.node.J["head"], Vector2(0, -60)).y


func _cam() -> Array:
	if t >= TR0 and t < TR1:
		var ey := _eye_y()
		var z := lerpf(2.0, 2.5, smooth(TR0, TR1, t))
		return [Vector2(TEO.x + 40.0, ey + 8.0), z]
	var wide := smooth(5.0, 5.6, t) * (1.0 - smooth(7.0, 7.4, t)) + smooth(TR1, TR1 + 0.01, t)
	var low := [Vector2(960, 826), 1.55]
	var hi := [Vector2(960, 650), 1.1]
	if t >= TR1:
		return [Vector2(960, 660), 1.2]
	return [low[0].lerp(hi[0], wide), lerpf(low[1], hi[1], wide)]


# độ mở khe ván (px màn hình) và tâm khe
func _slit() -> Array:
	if t >= TR0 and t < TR1:
		return [0.0, 0.0]
	if t >= TR1:
		return [lerpf(700.0, 1200.0, smooth(TR1, TR1 + 1.2, t)), 560.0]
	var o := smooth(0.2, 1.1, t) * 190.0
	o += (smooth(5.0, 5.6, t) * (1.0 - smooth(7.0, 7.4, t))) * 420.0
	return [o, 560.0 - (smooth(5.0, 5.6, t) * (1.0 - smooth(7.0, 7.4, t))) * 40.0]


func _sky(c: Node2D) -> void:
	vgrad(c, Rect2(-2400, -400, 5200, 1700), sky_top, sky_bot)


func _back(c: Node2D) -> void:
	# vách quán: ván dọc + kệ vò rượu
	for i in 30:
		var x := -400.0 + i * 100.0
		c.draw_rect(Rect2(x, 120, 96, 760), Color("#3a2618").lightened(0.04 * (i % 3)))
		cut(c, Vector2(x + 20, 200 + (i * 37) % 300), Vector2(x + 70, 210 + (i * 37) % 300), 3.0, Color(ink, 0.5))
	c.draw_rect(Rect2(-400, 430, 3000, 16), Color("#2a1a10"))
	for i in 14:
		holo(c, Vector2(80 + i * 140, 390), 0.7, Color("#7a1f2a"), 0.0)


func _ground(c: Node2D) -> void:
	for i in 6:
		c.draw_circle(Vector2(960, ground_y - 160), 520.0 - i * 70.0, Color(1.0, 0.8, 0.45, 0.05))
	c.draw_rect(Rect2(-2400, ground_y, 5200, 500), FLOOR)
	hatch(c, PackedVector2Array([Vector2(-2400, ground_y), Vector2(2800, ground_y), Vector2(2800, 1400), Vector2(-2400, 1400)]), 0.3, 24.0, Color(ink, 0.35))
	for i in 12:
		c.draw_line(Vector2(-400 + i * 260, ground_y), Vector2(-500 + i * 300, 1400), Color(ink, 0.4), 3.0)
	# bàn đổ chỏng chơ (khách chạy hết)
	_ban_do(c, Vector2(420, ground_y), 1.0)
	_ban_do(c, Vector2(1520, ground_y), -1.0)
	ghe_vet(c, g_l, Color(Color("#e6c48a"), 0.55))
	ghe_vet(c, g_d, Color(Color("#e6c48a"), 0.4))
	ghe_ve(c, g_l)
	ghe_ve(c, g_d)


func _ban_do(c: Node2D, p: Vector2, s: float) -> void:
	var top := PackedVector2Array([p + Vector2(-8 * s, 0), p + Vector2(8 * s, 0), p + Vector2(8 * s, -150), p + Vector2(-8 * s, -150)])
	shape(c, top, Color("#7b522c"), 3.0)
	for k: float in [-120.0, -30.0]:
		shape(c, PackedVector2Array([p + Vector2(8 * s, k), p + Vector2(96 * s, k - 4), p + Vector2(96 * s, k + 8), p + Vector2(8 * s, k + 12)]), Color("#6b4426"), 3.0)


func _near(c: Node2D) -> void:
	ghe_niem(c, g_l)
	ghe_niem(c, g_d)
	for s in shreds:
		var p: Vector2 = s.p
		var sz: float = s.s
		var an: float = s.a
		var d := Vector2(cos(an), sin(an)) * sz
		var n := Vector2(-d.y, d.x) * 0.45
		c.draw_colored_polygon(PackedVector2Array([p - d + n, p + d * 0.6 + n * 0.3, p + d, p - d * 0.4 - n]), Color("#2e4a6e"))
	# mặt trước quầy ở chỗ Tèo (cảnh cắt ngược): ván ngang, chừa khe ngang tầm mắt
	var ey := _eye_y()
	var x0 := TEO.x - 1400.0
	var x1 := TEO.x + 1400.0
	_van(c, Rect2(x0, ey - 600.0, x1 - x0, 600.0 - 16.0), 0)
	_van(c, Rect2(x0, ey + 40.0, x1 - x0, ground_y - ey), 3)
	# nhãn luật chơi (đọc kèm k01-02)


func _van(c: Node2D, r: Rect2, seed: int) -> void:
	van_mang(c, r, seed)


func _d_screen(c: Node2D) -> void:
	super._d_screen(c)
	var sv := _slit()
	var o: float = sv[0]
	var cy: float = sv[1]
	if t >= TR0 and t < TR1:
		return
	if o >= 1100.0:
		return
	var top := cy - o * 0.5
	var bot := cy + o * 0.5
	_tam(c, -20.0, top, true)
	_tam(c, bot, H + 20.0, false)
	var la := bump(0.9, 1.3, 3.0, 3.4)
	if la > 0.01 and top > 120.0:
		nhan(c, Vector2(W * 0.5, top - 70.0), "NHẤC MÔNG TRƯỚC LÀ THUA", 54, Color("#f1e2c4"), la, -0.02)


func _tam(c: Node2D, y0: float, y1: float, upper: bool) -> void:
	van_tam(c, y0, y1, upper)
