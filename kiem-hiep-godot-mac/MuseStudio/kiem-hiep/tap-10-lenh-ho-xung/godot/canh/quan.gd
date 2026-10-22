extends "res://canh.gd"
# Hồi Nhạn lâu: quầy rượu của Tèo. Bốn kiểu dựng theo arg.m:
#   ghe  (k01) — đấu ngồi nhìn qua khe ván quầy; cắt ngược thấy Tèo (bên hông quầy, rồi con mắt sau khe)
#   quay (k02) — mặt tiền quầy, Tèo đứng giữa rót lần thứ nhất; kệ chín hồ lô
#   ban  (k19) — mặt bàn khách thành sân khấu: chén rượu, quân cờ chibi nhỏ đứng trên bàn
#   ke   (k21) — đêm, Tèo lau chén, đặt hồ lô lên kệ

const WOOD := Color("#a8743e")
const FLOOR := Color("#5a3c22")
const WALL := Color("#3a2618")
const CLOTH := Color("#2e4a6e")
const WHITE_WINE := Color("#f3ecd8")
const WINE := [Color("#d9a441"), Color("#f3ecd8"), Color("#e8b65a"), Color("#d98a3a"), Color("#6b4a2a"), Color("#e89ab0"),
	Color("#7fb8a8"), Color("#e6e2c8"), Color("#5a2a22"), Color("#e0a040")]

var m := "ghe"
var lhx: Dictionary
var dien: Dictionary
var teo: Dictionary
var nl: Dictionary
var ho: Dictionary
var dao: Dictionary
var ma: Dictionary
var g_l: Dictionary
var g_d: Dictionary
var g_n: Dictionary
var shreds: Array = []
var hits: Array = []
var hit_done := 0
var puddle := 0.0
var TEO := Vector2(-1300, 880)
var WALL_X := -1170.0


func _palette() -> void:
	m = arg.get("m", "ghe")
	if m == "ke":
		sky_top = Color("#1c1626")
		sky_bot = Color("#3a2a2a")
		char_tint = Color(0.92, 0.86, 0.9)
		ground_y = 960.0
		vign_a = 0.45
		wind_base = 0.0
		wind_gust = 0.05
		return
	sky_top = Color("#4a3220")
	sky_bot = Color("#7a5634")
	char_tint = Color(1.0, 0.95, 0.86)
	ground_y = 880.0
	vign_a = 0.25
	wind_base = 0.0
	wind_gust = 0.1
	if m == "quay":
		ground_y = 960.0
	elif m == "ban":
		ground_y = 800.0


func _build() -> void:
	match m:
		"ghe":
			_b_ghe()
		"quay":
			_b_quay()
		"ban":
			_b_ban()
		"ke":
			_b_ke()


func _story(dt: float) -> void:
	if t < 0.0:
		return
	match m:
		"ghe":
			_s_ghe(dt)
		"quay":
			_s_quay(dt)
		"ban":
			_s_ban(dt)
		"ke":
			_s_ke(dt)


func _cam() -> Array:
	match m:
		"ghe":
			return _c_ghe()
		"quay":
			return _c_quay()
		"ban":
			return _c_ban()
		"ke":
			return _c_ke()
	return [CENTER, 1.0]


func _sky(c: Node2D) -> void:
	vgrad(c, Rect2(-3000, -600, 6600, 2200), sky_top, sky_bot)


func _back(c: Node2D) -> void:
	match m:
		"ghe", "quay", "ke":
			_quan_vach(c)
		"ban":
			_quan_vach(c)
			c.draw_rect(Rect2(-3200, -600, 6400, 2200), Color(0.08, 0.05, 0.03, 0.3))


func _ground(c: Node2D) -> void:
	match m:
		"ghe":
			_g_ghe(c)
		"quay", "ke":
			_g_quay(c)
		"ban":
			_g_ban(c)


func _near(c: Node2D) -> void:
	match m:
		"ghe":
			_n_ghe(c)
		"quay", "ke":
			_n_quay(c)
		"ban":
			_n_ban(c)


func _glow(c: Node2D) -> void:
	if m == "ke":
		var lp := Vector2(900, 330)
		for i in 6:
			c.draw_circle(lp, 420.0 - i * 60.0, Color(1.0, 0.7, 0.35, 0.05 * dim_k()))


func _d_screen(c: Node2D) -> void:
	super._d_screen(c)
	match m:
		"ghe":
			_sc_ghe(c)
		"ban":
			_sc_ban(c)
		"ke":
			var d := 1.0 - dim_k()
			if d > 0.01:
				c.draw_rect(Rect2(0, 0, W, H), Color(0.02, 0.01, 0.02, d * 0.85))


# ---------------------------------------------------------------- dùng chung trong quán

# vách quán: ván dọc sẫm + kệ vò rượu
func _quan_vach(c: Node2D) -> void:
	for i in 64:
		var x := -3200.0 + i * 100.0
		c.draw_rect(Rect2(x, 80, 96, 820), WALL.lightened(0.04 * (i % 3)))
		cut(c, Vector2(x + 20, 200 + (i * 37) % 300), Vector2(x + 70, 210 + (i * 37) % 300), 3.0, Color(ink, 0.5))
	c.draw_rect(Rect2(-3200, 430, 6400, 16), Color("#2a1a10"))
	if m == "quay" or m == "ke":
		return
	for i in 40:
		holo(c, Vector2(-2700 + i * 140, 390), 0.7, Color("#7a1f2a"), 0.0)


func _san(c: Node2D) -> void:
	for i in 6:
		c.draw_circle(Vector2(960, ground_y - 160), 520.0 - i * 70.0, Color(1.0, 0.8, 0.45, 0.05))
	c.draw_rect(Rect2(-3200, ground_y, 6400, 500), FLOOR)
	hatch(c, PackedVector2Array([Vector2(-3200, ground_y), Vector2(3200, ground_y), Vector2(3200, 1400), Vector2(-3200, 1400)]), 0.3, 24.0, Color(ink, 0.35))
	for i in 24:
		c.draw_line(Vector2(-3000 + i * 260, ground_y), Vector2(-3100 + i * 300, 1400), Color(ink, 0.4), 3.0)


func _ban_do(c: Node2D, p: Vector2, s: float) -> void:
	var top := PackedVector2Array([p + Vector2(-8 * s, 0), p + Vector2(8 * s, 0), p + Vector2(8 * s, -150), p + Vector2(-8 * s, -150)])
	shape(c, top, Color("#7b522c"), 3.0)
	for k: float in [-120.0, -30.0]:
		shape(c, PackedVector2Array([p + Vector2(8 * s, k), p + Vector2(96 * s, k - 4), p + Vector2(96 * s, k + 8), p + Vector2(8 * s, k + 12)]), Color("#6b4426"), 3.0)


# vò rượu sành: tâm p, nghiêng rot, đáy vò ở dưới
func _vo(c: Node2D, p: Vector2, r: float, rot: float, nhan_do := true) -> Vector2:
	c.draw_set_transform(p, rot, Vector2.ONE)
	var body := Color("#8a5a2a")
	c.draw_circle(Vector2.ZERO, r + 4.0, inkof(body))
	c.draw_circle(Vector2.ZERO, r, body)
	c.draw_circle(Vector2(-r * 0.35, -r * 0.3), r * 0.28, Color(1, 0.9, 0.7, 0.18))
	c.draw_rect(Rect2(-r * 0.4, -r * 1.25, r * 0.8, r * 0.42), Color("#6b4426"))
	c.draw_rect(Rect2(-r * 0.4, -r * 1.25, r * 0.8, r * 0.42), inkof(body), false, 3.0)
	if nhan_do:
		c.draw_rect(Rect2(-r * 0.5, -r * 0.2, r, r * 0.62), Color("#b8322c"))
	c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	return p + Vector2(0, -r * 1.25).rotated(rot)


func _lips(a: Dictionary, off: Vector2) -> Vector2:
	var to: Node2D = a.node.J["torso"]
	return from_w(to, to_w(a.node.J["head"], Vector2(0, -30))) + off


# ---------------------------------------------------------------- k01: đấu ngồi qua khe ván

func _b_ghe() -> void:
	g_l = ghe_moi(Vector2(800, ground_y), 1.0, WOOD)
	lhx = actor("lenh-ho-xung", g_l.p, 1.0)
	ho = prop(lhx, "ho_lo", "tay", "F")
	ma = prop(lhx, "ma_do", "mat", "F", {"cheek": Vector2(62, -54)})
	g_d = ghe_moi(Vector2(1120, ground_y), -1.0, WOOD.darkened(0.1))
	dien = actor("dien-ba-quang", g_d.p, -1.0)
	dien.expr = "gian"
	dao = prop(dien, "dao", "tay", "F")
	g_n = ghe_moi(Vector2(1640, ground_y), -1.0, WOOD.lightened(0.08), 96.0)
	nl = actor("nghi-lam", g_n.p, -1.0)
	teo = actor("teo-tieu-nhi", TEO, 1.0)
	teo.expr = "soc"
	var h6 := L("k01-06")
	for k in 7:
		hits.append(h6 + 0.4 + k * 0.62)


# Tèo cắt ngược: bên hông quầy (k01-02b) / con mắt sau khe ván (cuối k01-05b, sau cú bật dậy)
func _side_on() -> bool:
	return t >= L("k01-02b") - 0.1 and t < L("k01-03") - 0.25


func _eye_on() -> bool:
	var e := L("k01-05b")
	if t >= e + 3.0 and t < LE("k01-05b") + 0.4:
		return true
	var tj := L("k01-07") + 2.6
	return t >= tj + 0.9 and t < L("k01-08") + 0.1


func _wide() -> float:
	var d := L("k01-03")
	var e := L("k01-05b")
	var h6 := L("k01-06")
	var tj := L("k01-07") + 2.6
	var w := smooth(d - 0.3, d + 0.4, t) * (1.0 - smooth(e + 2.8, e + 3.0, t))
	w += smooth(h6 + 2.2, h6 + 2.7, t) * (1.0 - smooth(tj + 0.85, tj + 0.9, t))
	w += smooth(L("k01-08") + 0.1, L("k01-08") + 0.2, t)
	return clampf(w, 0.0, 1.0)


func _s_ghe(dt: float) -> void:
	var r := L("k01-02")
	var d := L("k01-03")
	var y4 := L("k01-04")
	var c5 := L("k01-05c")
	var j7 := L("k01-07")
	var tj := j7 + 2.6
	var p8 := L("k01-08")
	var q9 := L("k01-09")
	# ---- niêm DÍNH đóng dấu khi đọc luật
	g_l.seal = smooth(r + 1.0, r + 1.35, t)
	g_d.seal = smooth(r + 1.6, r + 1.95, t)
	# ---- Điền: chồm tới; rút đao cắm xuống sàn (k01-03), nhổ lên trước khi chém; chém 7 nhát
	var wu := 0.0
	var sl := 0.0
	for h: float in hits:
		wu += bump(h - 0.42, h - 0.16, h - 0.12, h - 0.03)
		sl += bump(h - 0.1, h - 0.02, h + 0.16, h + 0.3)
	var up := smooth(tj, tj + 0.28, t)
	var tap := maxf(0.0, sin(t * 9.0)) * smooth(c5, c5 + 0.3, t) * (1.0 - smooth(c5 + 4.5, c5 + 5.0, t))
	var bow := bump(p8 + 0.8, p8 + 1.2, p8 + 3.6, p8 + 4.0)
	var seated := [[NGOI_CHOM, 1.0 - up], [{"ftF": -6.0 - tap * 18.0, "shF": 110.0 - tap * 6.0}, (1.0 - up)],
		[arms_of("windup"), wu * (1.0 - up)], [arms_of("slash"), sl * (1.0 - up)]]
	dien.extra = seated + [["stance", up * (1.0 - bow)], [{"head": -10.0, "torso": -6.0}, up * (1.0 - smooth(tj + 1.5, tj + 2.0, t))],
		[{"uaF": -62.0, "faF": -96.0, "uaB": -56.0, "faB": -100.0, "head": 8.0, "torso": 10.0}, bow]]
	var stab := smooth(d + 1.0, d + 1.25, t) * (1.0 - smooth(c5 + 4.6, c5 + 5.0, t))
	dao.lock = stab
	dao.lockdir = Vector2(-0.08, 1.0).normalized()
	var dt_: Node2D = dien.node.J["torso"]
	dien.hold["F"] = [from_w(dt_, Vector2(g_d.p.x - 96.0, ground_y - 150.0 + tap * 3.0)), stab]
	dao.trail_on = sl > 0.45 and up < 0.1
	if not dao.trail_on:
		dao.trail.clear()
	dien.expr = "dac-y" if t < d + 3.0 else ("gian" if t < j7 + 1.2 else ("soc" if t < p8 + 0.6 else "binh"))
	# ---- ghế Lệnh Hồ Xung: bập bênh nhởn nhơ; mỗi nhát trượt lùi + dội; người né ngửa
	var dodge := 0.0
	var rk := 0.06 + 0.05 * sin(t * 1.7)
	rk += smooth(c5, c5 + 0.5, t) * (1.0 - smooth(c5 + 5.0, c5 + 5.5, t)) * (0.08 + 0.08 * sin(t * 2.6))
	var dx := 0.0
	for h: float in hits:
		var e := t - h
		if e > 0.0:
			rk += 0.3 * exp(-3.5 * e) * absf(sin(e * 8.0))
		dx -= 18.0 * smooth(h - 0.02, h + 0.16, t)
		dodge += bump(h - 0.1, h, h + 0.15, h + 0.45)
	var laugh := bump(j7 + 0.3, j7 + 0.5, tj + 0.6, tj + 0.9)
	var s16 := sin(t * 15.0)
	rk += laugh * (0.1 + absf(s16) * 0.08)
	var pant := smooth(q9 - 0.4, q9, t)
	g_l.rock = rk * (1.0 - pant) + pant * 0.04
	g_l.dx = dx
	ngoi(lhx, g_l)
	# uống (k01-04): đưa hồ lô lên môi, má đỏ dần
	var tip := bump(y4 + 0.6, y4 + 1.2, y4 + 3.0, y4 + 3.5)
	var raise := smooth(q9 + 2.4, q9 + 2.95, t)
	var sp := sin(t * 7.0)
	lhx.extra = [[NGOI_BAP_BENH, 1.0], [{"head": sin(t * 3.4) * 3.0}, 1.0 - pant], [{"head": -18.0, "torso": -7.0}, tip],
		[{"torso": -30.0, "head": -16.0, "uaF": -60.0, "faF": -50.0}, dodge],
		[{"head": s16 * 5.0, "torso": -10.0 + s16 * 3.0, "uaB": -40.0, "faB": -80.0}, laugh],
		[{"torso": -6.0 + sp * 4.0, "head": -4.0 + sp * 3.0, "shB": 80.0, "thB": -95.0}, pant]]
	var hold_tip := _lips(lhx, Vector2(12, -12))
	lhx.hold["F"] = [Vector2(54, -30).lerp(hold_tip, tip) if raise < 0.01 else Vector2(46, -190), maxf(tip, raise)]
	ho.lock = maxf(tip, raise)
	ho.lockdir = Vector2.DOWN.lerp(Vector2(0.75, -0.66), tip).normalized() if raise < 0.01 else Vector2(0.15 + sin(t * 13.0) * 0.25 * smooth(q9 + 3.0, q9 + 3.2, t), -1.0).normalized()
	ho.aim = Vector2(0, -30)
	ho.pour = bump(y4 + 1.2, y4 + 1.4, y4 + 2.8, y4 + 2.9)
	ma.amount = smooth(y4 + 1.6, y4 + 3.2, t)
	lhx.expr = "soc" if dodge > 0.4 else ("vui" if laugh > 0.3 or raise > 0.3 or t < y4 else ("dac-y" if t < q9 else "binh"))
	# áo rách: mỗi nhát văng mảnh vải
	while hit_done < hits.size() and t >= float(hits[hit_done]):
		var cp := to_w(lhx.node.J["torso"], Vector2(30, -60))
		for i in 6:
			var rr := RandomNumberGenerator.new()
			rr.seed = hit_done * 31 + i
			shreds.append({"p": cp + Vector2(rr.randf_range(-20, 20), rr.randf_range(-30, 30)), "v": Vector2(rr.randf_range(-260, 60), rr.randf_range(-380, -120)),
				"a": rr.randf() * TAU, "w": rr.randf_range(-9, 9), "s": rr.randf_range(9, 16)})
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
	# ---- Điền bật dậy: nhảy lên, niêm rách, ghế đổ ngửa
	g_d.tear = smooth(tj, tj + 0.7, t)
	if t < tj:
		ngoi(dien, g_d)
	else:
		var e2 := t - tj
		var hop := sin(clampf(e2 / 0.45, 0.0, 1.0) * PI) * 90.0
		dien.pos = g_d.p + Vector2(-34.0 * smooth(0.0, 0.45, e2), -hop)
		dien.rot = 0.0
		var f := smooth(tj + 0.08, tj + 0.5, t)
		var bo := 0.0
		if t > tj + 0.5:
			bo = 0.07 * exp(-6.0 * (t - tj - 0.5)) * absf(sin((t - tj - 0.5) * 14.0))
		g_d.fall = f - bo
		g_d.dx = 26.0 * f
	# ---- Nghi Lâm: mép ghế, cúi đầu, lén ngước; được thả thì đứng dậy vái rồi đi
	var free := smooth(p8 + 1.4, p8 + 1.8, t)
	if free < 0.5:
		ngoi(nl, g_n, 26.0)
		var pk := fmod(t, 3.6)
		var peek := smooth(1.4, 1.7, pk) * (1.0 - smooth(2.2, 2.4, pk))
		nl.extra = [[NGOI_MEP, 1.0], [{"head": 12.0 - peek * 14.0, "torso": 7.0 - peek * 3.0}, 1.0]]
		nl.hold["F"] = [Vector2(66, -84), 1.0]
		nl.hold["B"] = [Vector2(60, -80), 1.0]
		nl.expr = "ngai" if peek > 0.5 else "binh"
	else:
		if nl.rot != 0.0:
			nl.pos = g_n.p
			nl.rot = 0.0
		var nb := bump(p8 + 1.9, p8 + 2.2, p8 + 3.0, p8 + 3.3)
		nl.extra = [[{"uaF": -30.0, "faF": -110.0, "uaB": -30.0, "faB": -110.0}, 1.0], [{"torso": 26.0, "head": 14.0}, nb]]
		nl.hold = {}
		nl.expr = "vui"
		if t > p8 + 3.4 and nl.go == Vector2.INF and nl.pos.x < 2200.0:
			nl.speed = 260.0
			nl.go = Vector2(2400, ground_y)
	# ---- Tèo sau quầy: ngồi xổm ôm vò run; lúc bên hông quầy thì vò sóng sánh đổ; lúc nhìn khe thì nhổm lên
	var side := _side_on()
	var peek2 := smooth(L("k01-02b") + 2.6, L("k01-02b") + 3.1, t) if side else (1.0 if _eye_on() else 0.0)
	teo.extra = [[NGOI_XOM, 1.0], [{"all": [0.0, sin(t * 47.0) * 1.6, 52.0 - peek2 * 46.0], "head": -4.0 - peek2 * 4.0}, 1.0]]
	teo.expr = "soc"
	if side:
		puddle = minf(1.0, puddle + dt * 0.3)


func _eye_y() -> float:
	return to_w(teo.node.J["head"], Vector2(0, -60)).y


func _c_ghe() -> Array:
	if _side_on():
		var s := L("k01-02b")
		return [Vector2(TEO.x + 60.0, 700.0).lerp(Vector2(TEO.x + 90.0, 680.0), smooth(s + 2.4, s + 4.0, t)), lerpf(1.3, 1.65, smooth(s + 2.4, s + 4.0, t))]
	if _eye_on():
		var e0 := L("k01-05b") + 3.0 if t < L("k01-06") else L("k01-07") + 3.5
		return [Vector2(TEO.x + 40.0, _eye_y() + 8.0), lerpf(2.0, 2.5, smooth(e0, e0 + 1.6, t))]
	var w := _wide()
	var lo := Vector2(960, 826)
	var hi := Vector2(960, 650)
	var cp := lo.lerp(hi, w)
	var z := lerpf(1.55, 1.1, w)
	var e := L("k01-05b")
	cp.x += (lerpf(-240.0, 300.0, smooth(e, e + 2.8, t))) * bump(e - 0.4, e, e + 2.8, e + 3.0)
	var p8 := L("k01-08")
	var q9 := L("k01-09")
	if t >= p8:
		var k := smooth(q9 + 1.2, q9 + 3.0, t)
		cp = Vector2(960, 660).lerp(Vector2(870, 640), k)
		z = lerpf(1.15, 1.45, k)
	return [cp, z]


# khe ván: [độ mở px màn hình, tâm y]
func _slit() -> Array:
	if _side_on() or _eye_on():
		return [0.0, 0.0]
	var p8 := L("k01-08")
	if t >= p8:
		return [lerpf(700.0, 1300.0, smooth(p8, p8 + 1.4, t)), 560.0]
	var w := _wide()
	var o := smooth(0.2, 1.4, t) * 190.0 + w * 420.0
	return [o, 560.0 - w * 40.0]


func _g_ghe(c: Node2D) -> void:
	_san(c)
	_ban_do(c, Vector2(330, ground_y), 1.0)
	_ban_do(c, Vector2(1900, ground_y), -1.0)
	# vò vỡ dưới sàn giữa hai ghế
	for i in 3:
		var p := Vector2(560 + i * 34, ground_y - 6)
		c.draw_colored_polygon(PackedVector2Array([p, p + Vector2(22, -18 - i * 4), p + Vector2(40, 2)]), Color("#8a5a2a"))
	flat_blob(c, Vector2(980, ground_y + 6), 120.0, 0.14, Color(WHITE_WINE, 0.25))
	ghe_vet(c, g_l, Color(Color("#e6c48a"), 0.55))
	ghe_vet(c, g_d, Color(Color("#e6c48a"), 0.4))
	ghe_ve(c, g_l)
	ghe_ve(c, g_d)
	ghe_ve(c, g_n)
	# góc quầy của Tèo: kệ vò dưới quầy, vũng rượu đổ
	if _side_on():
		for i in 4:
			_vo(c, Vector2(TEO.x - 420 + i * 92, ground_y - 46), 40.0, 0.0, i % 2 == 0)
		var sp := to_w(teo.node.J["torso"], Vector2(40, -34))
		flat_blob(c, Vector2(sp.x + 40.0, ground_y + 4.0), 30.0 + puddle * 150.0, 0.16, Color(WHITE_WINE, 0.6))
		flat_blob(c, Vector2(sp.x + 40.0, ground_y + 4.0), 20.0 + puddle * 110.0, 0.12, Color(1, 1, 1, 0.35))


func _n_ghe(c: Node2D) -> void:
	ghe_niem(c, g_l)
	ghe_niem(c, g_d)
	for s in shreds:
		var p: Vector2 = s.p
		var sz: float = s.s
		var an: float = s.a
		var d := Vector2(cos(an), sin(an)) * sz
		var n := Vector2(-d.y, d.x) * 0.45
		c.draw_colored_polygon(PackedVector2Array([p - d + n, p + d * 0.6 + n * 0.3, p + d, p - d * 0.4 - n]), CLOTH)
	if _side_on():
		# vò trong tay Tèo: run → nghiêng → rượu tràn ra miệng vò
		var s := L("k01-02b")
		var vp := to_w(teo.node.J["torso"], Vector2(40, -34))
		var tilt := 0.35 * smooth(s + 0.4, s + 1.0, t) + sin(t * 31.0) * 0.06
		var mouth := _vo(c, vp, 34.0, tilt)
		var a := smooth(s + 0.6, s + 0.9, t)
		var pts := PackedVector2Array()
		for i in 9:
			var k := i / 8.0
			pts.append(mouth + Vector2(14.0 * k + sin(t * 20.0 + k * 6.0) * 3.0, (ground_y - mouth.y) * k * k + 40.0 * k * (1.0 - k)))
		c.draw_polyline(pts, Color(WHITE_WINE, 0.85 * a), 9.0, true)
		c.draw_polyline(pts, Color(1, 1, 1, 0.6 * a), 3.0, true)
		# vách quầy cắt ngang: ván dọc, mặt quầy, lỗ mắt
		var gy := ground_y
		var top := gy - 400.0
		var wx := WALL_X
		c.draw_rect(Rect2(wx, top, 46, 400), PLANK)
		for i in 6:
			c.draw_line(Vector2(wx, top + 70 * i), Vector2(wx + 46, top + 70 * i), Color(ink, 0.8), 3.0)
		c.draw_rect(Rect2(wx, top, 46, 400), Color(ink, 0.9), false, 4.0)
		shape(c, PackedVector2Array([Vector2(wx - 160, top - 26), Vector2(wx + 560, top - 26), Vector2(wx + 560, top + 8), Vector2(wx - 160, top + 8)]), PLANK.lightened(0.08), 4.0)
		var ey := _eye_y()
		c.draw_rect(Rect2(wx - 2, ey - 14, 50, 30), Color("#1a0f08"))
		c.draw_rect(Rect2(wx + 30, ey - 12, 20, 26), Color(1.0, 0.85, 0.5, 0.8))
		# vò trên mặt quầy
		_vo(c, Vector2(wx + 200, top - 60), 34.0, 0.0)
	if _eye_on():
		var ey := _eye_y()
		var x0 := TEO.x - 1400.0
		var x1 := TEO.x + 1400.0
		van_mang(c, Rect2(x0, ey - 600.0, x1 - x0, 600.0 - 16.0), 0)
		van_mang(c, Rect2(x0, ey + 40.0, x1 - x0, ground_y + 200.0 - ey), 3)


func _sc_ghe(c: Node2D) -> void:
	var sv := _slit()
	var o: float = sv[0]
	var cy: float = sv[1]
	if o <= 0.0 or o >= 1250.0:
		return
	var top := cy - o * 0.5
	var bot := cy + o * 0.5
	if t >= L("k01-08"):
		top -= (o - 700.0) * 0.4
		bot += (o - 700.0) * 0.4
	van_tam(c, -20.0, top, true)
	van_tam(c, bot, H + 20.0, false)
	var r := L("k01-02")
	var la := bump(r + 0.5, r + 0.9, r + 4.0, r + 4.4)
	if la > 0.01 and top > 120.0:
		nhan(c, Vector2(W * 0.5, top - 70.0), "NHẤC MÔNG TRƯỚC LÀ THUA", 54, Color("#f1e2c4"), la, -0.02)


# ---------------------------------------------------------------- k02 / k21: mặt tiền quầy (nhìn thẳng)

const QX0 := 470.0
const QX1 := 1310.0
const QTOP := 690.0
const TY := 770.0
const GO := Vector2(1200, 645)       # hồ lô đặt trên quầy
var ho_on := "tay"
var kiem: Dictionary
var dp: Dictionary
var nham: Dictionary
var huong: Dictionary
var doanh: Dictionary
var kiem_at := "tay"


func dim_k() -> float:
	if m != "ke":
		return 1.0
	var e := LE("k21-04")
	return 1.0 - smooth(e + 0.8, e + 3.2, t) * 0.9


func _keys(ks: Array) -> Array:
	var p: Vector2 = ks[0][1]
	var z: float = ks[0][2]
	for k in ks:
		var k0: float = k[0]
		var w := smooth(k0, k0 + 0.9, t)
		var kp: Vector2 = k[1]
		var kz: float = k[2]
		p = p.lerp(kp, w)
		z = lerpf(z, kz, w)
	return [p, z]


func _hand(a: Dictionary, side: String) -> Vector2:
	return to_w(a.node.J["hd" + side], Vector2(0, 10))


func _b_quay() -> void:
	teo = actor("teo-tieu-nhi", Vector2(900, TY + 230.0), 1.0)
	lhx = actor("lenh-ho-xung", Vector2(2300, ground_y), -1.0)
	ho = prop(lhx, "ho_lo", "tay", "F")
	ma = prop(lhx, "ma_do", "mat", "F", {"cheek": Vector2(62, -54)})


func _s_quay(_dt: float) -> void:
	var a1 := L("k02-01")
	var a2 := L("k02-02")
	var a4 := L("k02-04")
	var a5 := L("k02-05")
	var a6 := L("k02-06")
	var a7 := L("k02-07")
	# Tèo: thụp sau quầy → ló lên ôm vò, run; rót; vẫy tay trả tiền; nghe ngóng; ngước nhìn kệ
	var rise := smooth(a1 - 0.2, a1 + 0.5, t)
	var pop := bump(a1 + 0.3, a1 + 0.45, a1 + 0.55, a1 + 0.8)
	var tx := 900.0 + 160.0 * smooth(a4 - 0.4, a4 + 0.4, t) * (1.0 - smooth(a5 - 0.2, a5 + 0.5, t))
	teo.pos = Vector2(tx, TY + 230.0 * (1.0 - rise) - pop * 26.0)
	var listen := bump(a5 + 0.2, a5 + 0.6, a6 - 0.3, a6 + 0.1)
	teo.face = -1.0 if listen > 0.5 else 1.0
	var push := bump(a4 + 3.3, a4 + 3.5, a4 + 3.9, a4 + 4.2)
	var lookup := smooth(a6 + 0.4, a6 + 1.0, t)
	var jar := 1.0 - smooth(a5 - 0.1, a5 + 0.3, t)
	teo.hold["F"] = [Vector2(70, -96), jar * (1.0 - push)]
	teo.hold["B"] = [Vector2(56, -84), jar]
	teo.extra = [[{"head": sin(t * 40.0) * 1.5 * (1.0 - smooth(a2, a2 + 1.0, t))}, 1.0], [arms_of("palm"), push],
		[{"torso": 14.0, "head": 6.0, "uaF": -150.0, "faF": -110.0}, listen], [{"head": -22.0, "torso": -6.0}, lookup],
		[{"uaB": -150.0, "faB": -60.0}, lookup * (1.0 - jar)]]
	teo.expr = "soc" if t < a2 + 1.5 else ("vui" if t < a5 else ("binh" if t < a6 else ("dac-y" if t < a7 + 2.0 else "vui")))
	# Lệnh Hồ Xung: bước vào, cười, đặt hồ lô, đẩy đồng tiền, cầm hồ lô đi
	if t > a2 - 1.4 and lhx.go == Vector2.INF and lhx.pos.x > 2000.0:
		lhx.speed = 300.0
		lhx.go = Vector2(1430, ground_y)
	if ho_on == "tay" and t > a4 + 0.2 and t < a5 + 0.3:
		ho.node.visible = false        # hồ lô nằm trên quầy: vẽ bằng holo() ở _n_quay
		ho_on = "ban"
	if ho_on == "ban" and t >= a5 + 0.3:
		ho.node.visible = true
		ho_on = "tay2"
	if ho_on == "tay2" and t > a5 + 0.9 and lhx.go == Vector2.INF and lhx.pos.x < 2000.0:
		lhx.speed = 240.0
		lhx.go = Vector2(2500, ground_y)
	var lean := smooth(a2 + 0.2, a2 + 0.8, t) * (1.0 - smooth(a5 + 0.5, a5 + 0.9, t))
	var laugh := absf(sin(t * 12.0)) * bump(a2 + 0.3, a2 + 0.6, a2 + 2.6, a2 + 3.0)
	var coin := bump(a4 + 2.3, a4 + 2.6, a4 + 3.0, a4 + 3.3)
	var wave := bump(a5 + 1.0, a5 + 1.3, a5 + 2.8, a5 + 3.2)
	lhx.extra = [[{"torso": 12.0 * lean - laugh * 6.0, "head": laugh * 6.0, "uaB": -20.0, "faB": -60.0}, 1.0],
		[{"uaF": -80.0, "faF": -20.0}, coin], [{"uaB": -160.0, "faB": -40.0 + sin(t * 14.0) * 25.0}, wave]]
	lhx.expr = "vui"
	ma.amount = 0.4


func _coin_x() -> float:
	var a4 := L("k02-04")
	return lerpf(1360.0, 1170.0, smooth(a4 + 2.4, a4 + 2.9, t)) + 190.0 * smooth(a4 + 3.5, a4 + 3.9, t)


func _pour() -> float:
	var a4 := L("k02-04")
	return bump(a4 + 0.5, a4 + 0.8, a4 + 2.0, a4 + 2.3)


func _c_quay() -> Array:
	return _keys([[0.0, Vector2(900, 640), 1.45], [L("k02-02") - 1.0, Vector2(1120, 650), 1.05], [L("k02-04") - 0.3, Vector2(1130, 640), 1.55],
		[L("k02-05") + 0.2, Vector2(1150, 650), 1.0], [L("k02-06") + 0.5, Vector2(880, 520), 1.2], [L("k02-07") + 0.2, Vector2(880, 470), 1.45],
		[L("k02-08"), Vector2(580, 430), 2.1], [L("k02-09"), Vector2(880, 480), 1.35]])


func _hook_x(i: int) -> float:
	return 560.0 + i * 80.0


func _g_quay(c: Node2D) -> void:
	# quầng đèn ấm sau quầy
	var lk := 1.0 if m == "quay" else 0.45
	for i in 18:
		c.draw_circle(Vector2(900, 520), 950.0 - i * 50.0, Color(1.0, 0.75, 0.4, 0.028 * lk))
	# sàn
	c.draw_rect(Rect2(-3200, ground_y - 80.0, 6400, 600), FLOOR)
	for i in 30:
		c.draw_line(Vector2(-3000 + i * 220, ground_y - 80.0), Vector2(-3200 + i * 260, 1500), Color(ink, 0.35), 3.0)
	# cửa sổ nan + bóng khách qua đường
	var wr := Rect2(150, 300, 260, 300)
	c.draw_rect(wr, Color("#c9a46a") if m == "quay" else Color("#2c3550"))
	if m == "quay":
		var a5 := L("k02-05")
		for k in 2:
			var x := wr.position.x - 80.0 + (t - a5 - k * 1.6) * 140.0
			if x > wr.position.x + 10.0 and x < wr.end.x - 10.0:
				c.draw_circle(Vector2(x, 450), 30.0, Color("#3a2618"))
				c.draw_rect(Rect2(x - 34, 480, 68, 120), Color("#3a2618"))
				for d in 3:
					c.draw_circle(Vector2(x + 30 + d * 16, 400 - d * 6), 5.0, Color(1, 1, 1, 0.8))
	for i in 5:
		c.draw_line(Vector2(wr.position.x + i * 65, wr.position.y), Vector2(wr.position.x + i * 65, wr.end.y), Color("#4a2c1c"), 6.0)
	for i in 5:
		c.draw_line(Vector2(wr.position.x, wr.position.y + i * 75), Vector2(wr.end.x, wr.position.y + i * 75), Color("#4a2c1c"), 6.0)
	c.draw_rect(wr, Color(ink, 0.9), false, 8.0)
	# kệ chín móc hồ lô
	c.draw_rect(Rect2(500, 302, 760, 18), Color("#5a3820"))
	c.draw_rect(Rect2(500, 302, 760, 18), Color(ink, 0.9), false, 3.0)
	for i in 9:
		var x := _hook_x(i)
		c.draw_line(Vector2(x, 320), Vector2(x, 338), Color("#2a1a10"), 4.0)
		if m == "quay":
			var a7 := L("k02-07")
			var a := smooth(a7 + 0.4 + i * 0.35, a7 + 0.7 + i * 0.35, t)
			var fill := 0.0
			var wc: Color = WINE[i]
			if i == 0:
				fill = smooth(L("k02-08") + 0.4, L("k02-08") + 2.4, t)
			else:
				fill = 0.22 * smooth(L("k02-09") + 0.6 + (i - 1) * 0.4, L("k02-09") + 0.9 + (i - 1) * 0.4, t)
			if a > 0.01:
				c.draw_circle(Vector2(x, 320), 10.0 * a, Color(1, 0.85, 0.5, 0.5 * a))
				holo(c, Vector2(x, 362), 0.55, wc, fill, a)
		elif i == 4 and t >= L("k21-01") + 2.0:
			holo(c, Vector2(x, 362), 0.55, WINE[0], 0.0)
	if m == "ke":
		# đèn lồng treo + cửa ra vào
		var lp := Vector2(900, 330)
		c.draw_line(Vector2(900, 80), lp + Vector2(0, -40), Color(ink, 0.9), 3.0)
		blob(c, lp, 46.0, Color("#c0392b"))
		c.draw_circle(lp, 30.0, Color("#f0a050"))
		var a2 := L("k21-02")
		var op := smooth(a2 + 0.4, a2 + 1.2, t) * (1.0 - smooth(LE("k21-02a") - 1.0, LE("k21-02a"), t))
		var dr := Rect2(1560, 420, 240, 460)
		c.draw_rect(dr, Color("#0e0c18"))
		c.draw_rect(Rect2(dr.position.x, dr.position.y, dr.size.x * (1.0 - op * 0.6), dr.size.y), Color("#4a2c1c"))
		c.draw_rect(dr, Color(ink, 0.95), false, 10.0)
		if op > 0.01:
			c.draw_colored_polygon(PackedVector2Array([Vector2(dr.end.x - dr.size.x * op * 0.6, dr.end.y), Vector2(dr.end.x, dr.end.y),
				Vector2(dr.end.x - 60, ground_y + 40), Vector2(dr.end.x - dr.size.x * op * 0.6 - 160, ground_y + 40)]), Color(0.75, 0.8, 1.0, 0.18 * op))


func _quay_mat(c: Node2D) -> void:
	van_mang(c, Rect2(QX0, QTOP, QX1 - QX0, ground_y + 10.0 - QTOP), 1, Color("#7a5232"))
	shape(c, PackedVector2Array([Vector2(QX0 - 30, QTOP - 22), Vector2(QX1 + 30, QTOP - 22), Vector2(QX1 + 30, QTOP + 8), Vector2(QX0 - 30, QTOP + 8)]),
		Color("#a8743e"), 4.0)
	nhan(c, Vector2((QX0 + QX1) * 0.5, QTOP + 120.0), "HỒI NHẠN LÂU", 40, Color("#b8322c"), 0.9)


func _n_quay(c: Node2D) -> void:
	_quay_mat(c)
	if m != "quay":
		_n_ke(c)
		return
	var a5 := L("k02-05")
	var jar := 1.0 - smooth(a5 - 0.1, a5 + 0.3, t)
	# vò trong tay Tèo (sau đó vò nằm trên quầy)
	var hp := (_hand(teo, "F") + _hand(teo, "B")) * 0.5 + Vector2(0, 20)
	var pr := _pour()
	var tilt := pr * 1.15 + sin(t * 36.0) * 0.05 * (1.0 - smooth(L("k02-02"), L("k02-02") + 1.0, t))
	if jar > 0.5:
		var mouth := _vo(c, hp, 38.0, tilt)
		if pr > 0.3:
			var gm := GO + Vector2(0, -36)
			var pts := PackedVector2Array()
			for i in 10:
				var k := i / 9.0
				pts.append(mouth.lerp(gm, k) + Vector2(0, -60.0 * k * (1.0 - k)) + Vector2(sin(t * 22.0 + k * 7.0) * 2.0, 0))
			c.draw_polyline(pts, Color(WHITE_WINE, 0.9), 8.0, true)
			c.draw_polyline(pts, Color(1, 1, 1, 0.7), 3.0, true)
	else:
		_vo(c, Vector2(700, QTOP - 48), 38.0, 0.0)
	# hồ lô trên quầy
	if ho_on == "ban":
		var a4 := L("k02-04")
		holo(c, GO, 0.8, WHITE_WINE, smooth(a4 + 0.8, a4 + 2.2, t))
	# đồng tiền
	var cx := _coin_x()
	if t > L("k02-04") + 2.2 and cx < 1340.0:
		c.draw_circle(Vector2(cx, QTOP - 12), 14.0, Color("#e2b23a"))
		c.draw_rect(Rect2(cx - 4, QTOP - 16, 8, 8), Color("#7a5a1a"))
		c.draw_arc(Vector2(cx, QTOP - 12), 14.0, 0, TAU, 20, Color(ink, 0.9), 2.5)


# ---------------------------------------------------------------- k21: đêm, lau chén

func _b_ke() -> void:
	teo = actor("teo-tieu-nhi", Vector2(900, TY), 1.0)
	lhx = actor("lenh-ho-xung", Vector2(1690, ground_y - 10.0), -1.0)
	lhx.show = 0.0
	lhx.tint = Color(0.7, 0.8, 1.2)


func _s_ke(_dt: float) -> void:
	var a1 := L("k21-01")
	var a2 := L("k21-02")
	var a2a := L("k21-02a")
	var a3 := L("k21-03")
	var a4 := L("k21-04")
	var reach := bump(a1 + 1.0, a1 + 1.6, a1 + 2.2, a1 + 2.8)
	var wipe := 1.0 - bump(a1 + 0.8, a1 + 1.0, a1 + 2.8, a1 + 3.0)
	wipe *= 1.0 - bump(a2 + 0.6, a2 + 1.0, LE("k21-02") - 0.2, LE("k21-02") + 0.2)
	wipe *= 1.0 - bump(a3, a3 + 0.3, LE("k21-03") - 0.3, LE("k21-03"))
	var bow := bump(a3 + 0.2, a3 + 0.7, a3 + 1.4, a3 + 1.9)
	teo.hold["F"] = [Vector2(66 + cos(t * 6.0) * 16.0, -88 + sin(t * 6.0) * 10.0), wipe]
	teo.hold["B"] = [Vector2(58, -78), wipe]
	teo.extra = [[{"head": -26.0, "torso": -8.0, "uaB": -165.0, "faB": -20.0}, reach], [{"torso": 34.0, "head": 16.0}, bow],
		[{"head": -6.0}, bump(a2 + 0.6, a2 + 1.0, LE("k21-02"), LE("k21-02") + 0.4)]]
	teo.face = 1.0
	teo.talk = bump(a2a, a2a + 0.3, LE("k21-02a") - 0.3, LE("k21-02a")) * 0.8 + bump(a3 + 2.0, a3 + 2.3, LE("k21-03") - 0.3, LE("k21-03")) * 0.6
	teo.expr = "soc" if (t > a2 + 1.0 and t < a2 + 2.4) else ("vui" if t < a4 + 2.0 else "binh")
	# bóng gã say ở cửa (chỉ là Tèo tưởng tượng)
	lhx.show = 0.5 * bump(a2 + 1.0, a2 + 1.6, LE("k21-02") + 0.4, LE("k21-02") + 1.2)
	lhx.extra = [["raise", 1.0], [{"head": sin(t * 10.0) * 4.0}, 1.0]]
	lhx.expr = "vui"


func _cup(c: Node2D, p: Vector2, s: float, wc: Color, fill: float, a := 1.0) -> void:
	var top := PackedVector2Array([p + Vector2(-26, -40) * s, p + Vector2(26, -40) * s, p + Vector2(18, 0) * s, p + Vector2(-18, 0) * s])
	c.draw_colored_polygon(top, Color(Color("#ece4d0"), a))
	if fill > 0.01:
		var lv := lerpf(0.0, 36.0, fill)
		var k := lv / 40.0
		c.draw_colored_polygon(PackedVector2Array([p + Vector2(-18 - 8 * k, -lv) * s, p + Vector2(18 + 8 * k, -lv) * s, p + Vector2(16, -2) * s, p + Vector2(-16, -2) * s]), Color(wc, a))
	top.append(top[0])
	c.draw_polyline(top, Color(ink, 0.9 * a), 3.0, true)
	c.draw_line(p + Vector2(-20, -30) * s, p + Vector2(20, -30) * s, Color(Color("#2e4a6e"), 0.6 * a), 2.0)


func _c_ke() -> Array:
	return _keys([[0.0, Vector2(900, 600), 1.3], [L("k21-01") + 0.8, Vector2(880, 540), 1.45], [L("k21-02") + 0.6, Vector2(1240, 620), 1.05],
		[L("k21-02a"), Vector2(760, 620), 1.25], [L("k21-02b"), Vector2(900, 640), 1.25], [L("k21-03"), Vector2(960, 560), 1.0],
		[L("k21-04"), Vector2(980, 650), 1.5]])


func _n_ke(c: Node2D) -> void:
	var a1 := L("k21-01")
	var a2a := L("k21-02a")
	var a2b := L("k21-02b")
	var a4 := L("k21-04")
	# khách ngồi quay lưng ở đầu quầy (lúc hỏi chuyện)
	var ka := bump(a2a - 0.6, a2a, LE("k21-02a") + 0.4, LE("k21-02a") + 1.0)
	if ka > 0.01:
		var kp := Vector2(380, ground_y - 10.0)
		c.draw_circle(kp + Vector2(0, -250), 70.0, Color(0.06, 0.04, 0.05, ka))
		c.draw_colored_polygon(PackedVector2Array([kp + Vector2(-90, -190), kp + Vector2(90, -190), kp + Vector2(120, 0), kp + Vector2(-120, 0)]), Color(0.06, 0.04, 0.05, ka))
	# chín chén rượu xếp hàng; hai chén cuối sát nhau: chia đôi
	var row := bump(a2b + 0.6, a2b + 1.0, LE("k21-03") - 0.5, LE("k21-03") + 0.3)
	if row > 0.01:
		for i in 9:
			var x := 560.0 + i * 82.0 - (24.0 if i == 8 else 0.0)
			var f := smooth(a2b + 1.3 + i * 0.68, a2b + 1.6 + i * 0.68, t)
			var wc: Color = WINE[i]
			_cup(c, Vector2(x, QTOP - 22), 0.95, wc, f, row)
			if f > 0.01 and f < 0.99:
				c.draw_circle(Vector2(x, QTOP - 64), 10.0, Color(1, 0.9, 0.6, 0.6 * (1.0 - f)))
	# chén của khách quan: để nguyên chỗ cũ
	var last := smooth(a4 + 0.4, a4 + 1.2, t)
	if last > 0.01:
		var p := Vector2(980, QTOP - 22)
		for i in 4:
			c.draw_circle(p + Vector2(0, -20), 60.0 - i * 12.0, Color(1, 0.8, 0.4, 0.06 * last))
		_cup(c, p, 1.1, WINE[0], 0.7, last)
	# chén + khăn trong tay Tèo
	var wipe_on := t < a1 + 0.9 or t > a1 + 2.9
	if wipe_on and row < 0.5 and last < 0.5:
		var hb := _hand(teo, "B")
		_cup(c, hb + Vector2(0, 10), 0.9, WINE[0], 0.0)
		var hf := _hand(teo, "F")
		c.draw_colored_polygon(PackedVector2Array([hf + Vector2(-16, -6), hf + Vector2(14, -10), hf + Vector2(18, 16), hf + Vector2(-12, 20)]), Color("#e8e0cc"))
	# hồ lô rỗng trong tay Tèo trước khi lên kệ
	if t > a1 + 0.9 and t < a1 + 2.0:
		holo(c, _hand(teo, "B") + Vector2(0, -20), 0.55, WINE[0], 0.0)


# ---------------------------------------------------------------- k19: mặt bàn khách thành sân khấu

const SZ := 0.62
const RING := [Vector2(980, 792), Vector2(1380, 792), Vector2(1100, 792), Vector2(1500, 792), Vector2(1040, 792), Vector2(1440, 792), Vector2(1240, 792)]


func _b_ban() -> void:
	lhx = actor("lenh-ho-xung", Vector2(960, ground_y - 8.0), 1.0)
	lhx.size = SZ
	lhx.show = 0.0
	kiem = prop(lhx, "kiem", "tay", "F")
	dp = actor("dong-phuong-bat-bai", Vector2(-400, ground_y - 8.0), -1.0)
	dp.size = SZ
	nham = actor("nham-nga-hanh", Vector2(-600, ground_y - 8.0), 1.0)
	nham.size = SZ
	huong = actor("huong-van-thien", Vector2(-700, ground_y - 8.0), 1.0)
	huong.size = SZ
	doanh = actor("doanh-doanh", Vector2(2600, ground_y - 8.0), -1.0)
	doanh.size = SZ


func _dp_pos(tt: float) -> Vector2:
	var b2 := L("k19-02")
	var bb := L("k19-02b")
	var b3 := L("k19-03")
	if tt < b2 + 3.0:
		return Vector2(-400, 792)
	var p := Vector2(-400, 792).lerp(Vector2(1240, 792), smooth(b2 + 3.0, b2 + 3.4, tt))
	if tt > bb + 1.0 and tt < b3:
		var k := int((tt - bb - 1.0) / 0.5)
		var f := smooth(0.0, 0.1, fmod(tt - bb - 1.0, 0.5))
		var pa: Vector2 = RING[k % RING.size()] if k > 0 else Vector2(1240, 792)
		var pb: Vector2 = RING[(k + 1) % RING.size()]
		p = pa.lerp(pb, f)
	elif tt >= b3:
		var k2 := int((b3 - bb - 1.0) / 0.5)
		var pe: Vector2 = RING[(k2 + 1) % RING.size()]
		p = pe
	return p


func _s_ban(_dt: float) -> void:
	var b1 := L("k19-01")
	var b2 := L("k19-02")
	var bd := L("k19-02d")
	var bb := L("k19-02b")
	var bc := L("k19-02c")
	var b3 := L("k19-03")
	var b4 := L("k19-04")
	var fade := 1.0 - smooth(b3 + 0.2, b3 + 0.9, t)
	# Lệnh Hồ Xung tí hon: hiện ra, múa kiếm; vây đánh; xong thì tra kiếm, tới vò rượu ngồi tựa
	lhx.show = smooth(b1 + 1.2, b1 + 1.6, t)
	var fl := bump(b2 + 0.3, b2 + 0.6, b2 + 2.4, b2 + 2.8)
	var sl := bump(b2 + 1.2, b2 + 1.4, b2 + 1.7, b2 + 2.0)
	kiem.trail_on = sl > 0.4
	if not kiem.trail_on:
		kiem.trail.clear()
	if kiem_at == "tay" and t > b3 + 1.0:
		prop_to(kiem, "hong")
		kiem_at = "hong"
	var ring := smooth(bb + 0.2, bb + 0.9, t) * fade
	var sit := smooth(b3 + 2.6, b3 + 3.0, t)
	if t <= b3 + 1.2:
		lhx.pos = Vector2(lerpf(960.0, 820.0, ring) if t > bb else 960.0, ground_y - 8.0)
		lhx.face = 1.0
	elif sit < 0.5 and lhx.go == Vector2.INF and lhx.pos.x < 1500.0:
		lhx.speed = 200.0
		lhx.go = Vector2(1560, ground_y - 8.0)
	if sit > 0.5:
		lhx.pos = Vector2(1560, ground_y - 8.0)
		lhx.face = 1.0
	var dpp := _dp_pos(t)
	var shove := 0.0
	if t > bb + 1.0 and t < b3:
		shove = exp(-8.0 * fmod(t - bb - 1.0, 0.5)) * smooth(bc - 0.2, bc, t)
	var wave := bump(b4 + 2.4, b4 + 2.7, b4 + 3.4, b4 + 3.8)
	var lnear := 1.0 if absf(dpp.x - lhx.pos.x) < 260.0 else 0.0
	lhx.extra = [[SIT_GROUND, sit], [{"torso": -20.0, "uaB": -90.0, "faB": -40.0}, sit], ["stance", fl * (1.0 - sit)], [arms_of("slash"), sl],
		["guard", ring * 0.8], [{"torso": -16.0, "head": -10.0}, shove * lnear], [arms_of("palm"), wave]]
	lhx.expr = "quyet-tam" if ring > 0.5 else ("vui" if t > b3 else "binh")
	# Đông Phương Bất Bại: lướt nhanh như bóng, kim thêu loé
	dp.pos = dpp
	dp.face = -1.0 if dpp.x > 1100.0 else 1.0
	dp.show = smooth(b2 + 2.9, b2 + 3.0, t) * fade
	dp.extra = [[{"uaF": -100.0, "faF": -10.0}, bump(bd + 0.4, bd + 0.8, LE("k19-02d") - 0.4, LE("k19-02d"))], ["run", ring * 0.6]]
	dp.expr = "dac-y"
	# ba người cùng vây: vào vòng, bị lướt qua thì lùi chật vật
	var who := [[nham, Vector2(640, 792), 1.0], [huong, Vector2(1880, 792), -1.0], [doanh, Vector2(1720, 792), -1.0]]
	for w in who:
		var a: Dictionary = w[0]
		var hp: Vector2 = w[1]
		var fc: float = w[2]
		var sp := Vector2(-700, 792) if fc > 0.0 else Vector2(2600, 792)
		var near := 1.0 - clampf(absf(dpp.x - a.pos.x) / 220.0, 0.0, 1.0)
		var bk := near * smooth(bc - 0.3, bc, t)
		a.pos = sp.lerp(hp, ring) + Vector2(-50.0 * bk * fc, 0)
		a.face = fc
		a.show = ring
		a.extra = [["guard", ring], [{"torso": -18.0, "head": -12.0}, bk]]
		a.expr = "soc" if bk > 0.4 else "quyet-tam"


func _ghost(c: Node2D) -> void:
	var b2 := L("k19-02")
	var b3 := L("k19-03")
	if t < b2 + 2.9 or t > b3 + 0.9:
		return
	var fade := 1.0 - smooth(b3 + 0.2, b3 + 0.9, t)
	var cur := _dp_pos(t)
	for k in range(1, 9):
		var q := _dp_pos(t - k * 0.03)
		if q.distance_to(cur) < 4.0:
			continue
		var a := (1.0 - k / 9.0) * 0.35 * fade
		blob(c, q + Vector2(0, -70), 34.0, Color(0.85, 0.25, 0.5, a))
		blob(c, q + Vector2(0, -130), 28.0, Color(0.95, 0.5, 0.65, a * 0.8))


func _c_ban() -> Array:
	return _keys([[0.0, Vector2(960, 600), 1.0], [L("k19-01") + 1.0, Vector2(960, 640), 1.3], [L("k19-02") + 3.0, Vector2(1100, 640), 1.2],
		[L("k19-02d"), Vector2(1200, 660), 1.75], [L("k19-02b"), Vector2(1200, 630), 1.0], [L("k19-03") + 1.0, Vector2(1450, 660), 1.45],
		[L("k19-04"), Vector2(1620, 650), 1.25]])


func _g_ban(c: Node2D) -> void:
	# mặt bàn: dải gỗ sáng, vân chạy theo chiều sâu
	shape(c, PackedVector2Array([Vector2(-600, ground_y - 50), Vector2(2600, ground_y - 50), Vector2(2700, ground_y), Vector2(-700, ground_y)]), Color("#b07a44"), 4.0)
	for i in 40:
		var x := -600.0 + i * 85.0
		c.draw_line(Vector2(x, ground_y - 50), Vector2(x - 8.0, ground_y), Color(ink, 0.25), 2.0)
	for i in 16:
		c.draw_circle(Vector2(1100, ground_y - 200), 760.0 - i * 42.0, Color(1.0, 0.8, 0.45, 0.025))
	_ghost(c)
	# ba cái chén của khách
	for x: float in [420.0, 590.0, 1940.0]:
		_cup(c, Vector2(x, ground_y - 6.0), 2.4, WINE[2], 0.6)
	# vò rượu cho chàng tựa lưng
	_vo(c, Vector2(1690, ground_y - 66.0), 60.0, 0.0)


func _n_ban(c: Node2D) -> void:
	# mép bàn trước
	van_mang(c, Rect2(-700, ground_y, 3400, 90), 2, Color("#8a5a30"))
	c.draw_rect(Rect2(-700, ground_y + 90, 3400, 600), Color("#1a100a"))
	# kim thêu: một vạch sáng mảnh + sợi chỉ đỏ
	var bd := L("k19-02d")
	var na := bump(bd + 0.6, bd + 1.0, LE("k19-02d") - 0.3, LE("k19-02d") + 0.2) * float(dp.show)
	if na > 0.01:
		var h := _hand(dp, "F")
		var dr := Vector2(-0.9, -0.45).normalized() if dp.face < 0.0 else Vector2(0.9, -0.45).normalized()
		c.draw_line(h, h + dr * 46.0, Color(1, 1, 1, na), 2.5, true)
		c.draw_circle(h + dr * 46.0, 5.0 + sin(t * 20.0) * 2.0, Color(1, 1, 0.9, na * 0.8))
		var pts := PackedVector2Array()
		for i in 12:
			var k := i / 11.0
			pts.append(h + Vector2(k * 80.0 * -dr.x, 30.0 * k + sin(t * 4.0 + k * 6.0) * 10.0 * k))
		c.draw_polyline(pts, Color(0.85, 0.15, 0.2, na), 2.0, true)
	# danh lợi trôi tới: chồng tiền + cái ghế đỏ, rồi trôi đi
	var b4 := L("k19-04")
	var come := smooth(b4 + 0.3, b4 + 1.3, t) * (1.0 - smooth(b4 + 3.0, b4 + 4.0, t))
	if come > 0.01:
		var cx := lerpf(2400.0, 1820.0, come)
		for i in 5:
			c.draw_circle(Vector2(cx, ground_y - 8.0 - i * 9.0), 20.0, Color("#e2b23a"))
			c.draw_arc(Vector2(cx, ground_y - 8.0 - i * 9.0), 20.0, 0, TAU, 20, Color(ink, 0.8), 2.0)
		var gx := lerpf(2600.0, 1960.0, come)
		var wd := Color("#c0392b")
		c.draw_rect(Rect2(gx - 30, ground_y - 60, 60, 10), wd)
		c.draw_rect(Rect2(gx + 22, ground_y - 130, 10, 80), wd)
		c.draw_rect(Rect2(gx - 28, ground_y - 50, 8, 50), wd)
		c.draw_rect(Rect2(gx + 20, ground_y - 50, 8, 50), wd)


func _sc_ban(c: Node2D) -> void:
	# hai ông khách cãi nhau: bóng đầu lớn ở hai mép khung
	var b1 := L("k19-01")
	var a := bump(b1 - 0.6, b1 + 0.2, LE("k19-02") - 0.4, LE("k19-02") + 0.4)
	if a < 0.01:
		return
	for sd: float in [-1.0, 1.0]:
		var x := W * 0.5 + sd * (W * 0.5 + 20.0 - 170.0 * a)
		var y := 640.0 + sin(t * (5.0 + sd)) * 6.0
		var col := Color(0.24, 0.15, 0.1, 0.96)
		c.draw_circle(Vector2(x, y), 176.0, Color(1.0, 0.75, 0.4, 0.5))
		c.draw_circle(Vector2(x, y), 170.0, col)
		c.draw_colored_polygon(PackedVector2Array([Vector2(x - 260, H + 20), Vector2(x - 140, y + 120), Vector2(x + 140, y + 120), Vector2(x + 260, H + 20)]), col)
		var talk := absf(sin(t * (9.0 + sd * 2.0)))
		var mp := Vector2(x - sd * 150.0, y + 50.0)
		c.draw_rect(Rect2(mp.x - 22, mp.y - 6 - talk * 10.0, 44, 12 + talk * 20.0), Color(0.35, 0.1, 0.1, 0.95))
