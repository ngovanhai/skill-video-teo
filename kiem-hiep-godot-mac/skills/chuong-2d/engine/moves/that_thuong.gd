extends "res://engine.gd"
# Thất Thương Quyền (tập 16 Thành Côn, 2026-10-24)
# Thẻ chiêu: Tạ Tốn (còn sáng mắt) · thần tăng Không Kiến (đứng chắp tay chịu đòn, không đánh trả, Kim Cang Bất Hoại thể) ·
# BẢY SỢI KÌNH bảy màu xoắn bện quanh nắm đấm; mỗi quyền tách thành bảy mũi bay vào thân nhà sư, gặp lớp kim thân vàng thì tắt
# thành gợn; bộ đếm 13 quyền trên màn (3 quyền chậm, 9 quyền liên hoàn) · bảy sắc vs vàng kim · sân đá Thiếu Lâm lúc chạng vạng,
# sương tím tro, mái chùa đen xa, hai đèn đá · đỉnh: quyền thứ 13, bảy sợi bện thành một dây, va kim thân → một phần kình DỘI
# NGƯỢC chạy về cánh tay Tạ Tốn (vết nứt đỏ sáng trên tay áo) = "chưa thương người đã thương mình".
# Kết (lệch luật): Không Kiến không văng, chỉ lùi nửa bước, vẫn chắp tay; Tạ Tốn bị dội trượt lùi, ôm tay.

const KINH := [Color(1.7, 0.35, 0.3), Color(1.7, 0.85, 0.25), Color(1.55, 1.5, 0.35), Color(0.4, 1.55, 0.5),
	Color(0.35, 1.2, 1.7), Color(0.55, 0.5, 1.75), Color(1.4, 0.45, 1.6)]
const HOT := Color(2.2, 1.9, 1.5)
const VANG := Color(1.6, 1.25, 0.45)        # kim thân
const VANG_HOT := Color(2.2, 1.85, 0.9)
const DO := Color(1.9, 0.35, 0.25)          # kình dội ngược
const BEATS := [2.4, 2.95, 3.5, 3.85, 4.05, 4.25, 4.45, 4.62, 4.79, 4.96, 5.13, 5.3]
const PEAK := 6.1
const CHAP := {"uaF": -8, "faF": -104, "uaB": 14, "faB": -20, "torso": 2, "head": 4, "thF": -6, "shF": 8, "thB": 6, "shB": -8, "all": [0, 0, 4]}   # thao-tac-chibi: nhà sư dựng một bàn tay trước ngực
const WIND := {"uaF": 50, "faF": -125, "uaB": -30, "faB": -40, "torso": 8, "head": 2, "thF": -24, "shF": 22, "thB": 18, "shB": -18, "all": [0, 0, 14]}   # kéo quyền về hông
const OM := {"uaF": 18, "faF": -30, "uaB": -78, "faB": -38, "torso": 10, "head": 10}
const DAM := {"uaF": -86, "faF": -4, "uaB": 40, "faB": -95, "torso": -10, "head": -4, "thF": -30, "shF": 26, "thB": 24, "shB": -10}

var beat_i := 0
var hit := false
var shots: Array = []       # [t bắn, chỉ số quyền]
var dem := 0
var foe_x0 := 1250.0
var hero_x0 := 600.0


func _setup() -> void:
	sky_cols = [Color("#55496a"), Color("#9a879c"), Color("#cdb8b0")]
	far_col = Color("#75687e")
	near_col = Color("#5e5268")
	mist_col = Color(0.78, 0.72, 0.82, 0.24)
	ground_cols = [Color("#9a9196"), Color("#5a5260"), Color("#c2b8b6")]
	moon_on = false
	n_stars = 18
	slowmo = [PEAK - 0.05, PEAK + 0.62, 0.3]
	title = "Thất Thương Quyền"
	subtitle = "Tạ Tốn · Không Kiến"
	title_at = 8.4
	title_col = Color(2.0, 1.2, 1.0)
	flash_col = Color(1.0, 0.92, 0.8)
	set_char(hero, "ta-ton-sang")
	set_char(foe, "khong-kien")
	hero.pos = Vector2(hero_x0, GROUND)
	foe.pos = Vector2(foe_x0, GROUND)
	hero.col = Color(1.5, 0.8, 0.5)
	foe.col = VANG
	foe.base = "rest"
	cue(1.0, "lib-riser", 0.8)
	for i in BEATS.size():
		cue(BEATS[i] - 0.06, "lib-whoosh-short" if i < 3 else "lib-glitch-1", 0.55 if i < 3 else 0.35)
	cue(PEAK - 0.3, "lib-whoosh-cinematic", 0.9)


func _shell_c() -> Vector2:
	return foe.pos + Vector2(0, -150)


func _story(_dt: float) -> void:
	# ---- Tạ Tốn
	var gk := smooth(1.0, 1.8, t)
	hero.gather = gk * (1.0 - smooth(2.2, 2.4, t))
	var bp := 0.0
	for b in BEATS:
		bp = maxf(bp, pulse(b - 0.07, b + 0.05, 0.12, t))
	var wind := smooth(5.45, 5.95, t) * (1.0 - smooth(PEAK - 0.06, PEAK, t))
	var strike := smooth(PEAK - 0.06, PEAK, t) * (1.0 - smooth(PEAK + 0.25, PEAK + 0.55, t))
	var om := smooth(PEAK + 0.25, PEAK + 0.7, t)
	hero.push = 0.0
	hero.extra = [["stance", gk * 0.6], [DAM, maxf(bp, strike)], [WIND, wind], [OM, om]]
	hero.lean = bp * 0.4 + strike * 0.5 - om * 0.3
	hero.crouch = om * 0.35
	hero.aura = gk * 0.5 + wind * 0.6 - om * 0.9
	if t > PEAK + 0.2:
		hero.expr = "ngai" if t > 7.8 else "soc"
	elif t > 1.0:
		hero.expr = "quyet-tam"
	else:
		hero.expr = "binh"
	hero.node.hand_form = {"F": "nam", "B": "nam" if om < 0.5 else "xoe"}
	# trượt lùi vì kình dội
	var k := clampf((t - PEAK - 0.15) / 0.9, 0.0, 1.0)
	hero.pos.x = lerpf(hero_x0, 400.0, ease_out(k))
	# ---- Không Kiến: chắp tay, đứng yên; nửa bước lùi ở quyền 13
	foe.extra = [[CHAP, 1.0]]
	foe.node.hand_form = {"F": "xoe", "B": "tha"}
	var kf := clampf((t - PEAK) / 0.5, 0.0, 1.0)
	foe.pos.x = foe_x0 + ease_out(kf) * 34.0 - pulse(PEAK, PEAK + 0.1, 0.4, t) * 0.0
	foe.lean = -pulse(PEAK - 0.02, PEAK + 0.15, 0.45, t) * 0.35
	foe.aura = 0.25 + smooth(5.5, PEAK, t) * 0.5 - smooth(8.0, 9.5, t) * 0.5
	foe.expr = "binh"
	pose(hero, 0.0)
	pose(foe, 0.0)

	if hero.gather > 0.05:
		orbit(hero, rng.randf_range(110, 240), rng.randf_range(2.5, 4.0), 240, rng.randf_range(2, 4), KINH[rng.randi() % 7], 2.4)

	# ---- mỗi quyền: bảy mũi bay vào kim thân
	if beat_i < BEATS.size() and t >= BEATS[beat_i]:
		shots.append([BEATS[beat_i], beat_i])
		beat_i += 1
	for s in shots:
		var u: float = (t - float(s[0])) / 0.16
		if u >= 1.0 and s.size() < 3:
			s.append(true)
			dem = maxi(dem, int(s[1]) + 1)
			var big: bool = int(s[1]) < 3
			var at := _shell_c() + Vector2(-150, 0)
			add_ring(at, 160 if big else 110, VANG_HOT, 6, 0.35, 1.4)
			burst(at, 22 if big else 10, 200, 600, VANG_HOT, KINH[int(s[1]) % 7], 500.0, 1.6, PI * 0.55, PI * 1.45)
			shake = maxf(shake, 12.0 if big else 7.0)
			sfx("lib-impact-bass-2", 0.55 if big else 0.35)

	# ---- đỉnh: quyền thứ 13
	if t >= PEAK and not hit:
		hit = true
		dem = 13
		flash = 0.55
		shake = 30.0
		var at := _shell_c() + Vector2(-150, 0)
		add_ring(at, 520, VANG_HOT, 16, 0.7, 1.3)
		add_ring(Vector2(foe.pos.x, GROUND), 700, VANG, 9, 0.9, 0.2)
		burst(at, 130, 300, 1400, VANG_HOT, HOT, 700.0, 1.0, PI * 0.5, PI * 1.5)
		sfx("lib-impact-bass-1", 1.0)
		sfx("lib-impact-bass-2", 1.0)
	if hit and t > PEAK + 0.12 and not foe.has("doi"):
		foe.doi = true
		sfx("lib-glitch-1", 0.45)
	if hit and t > PEAK + 0.6 and not hero.has("tru"):
		hero.tru = true
		sfx("lib-impact-bass-2", 0.45)
		for i in 16:
			emit("smoke", Vector2(hero.pos.x + rng.randf_range(-60, 80), GROUND), Vector2(rng.randf_range(-200, 60), -rng.randf_range(20, 120)), 1.8, rng.randf_range(36, 80), Color(0.62, 0.56, 0.62, 0.45))


func _cam() -> Array:
	var c := CENTER
	var z := 1.0
	var k1 := smooth(0.9, 1.7, t) * (1.0 - smooth(2.15, 2.5, t))
	c = c.lerp(hero.pos + Vector2(130, -230), k1)
	z = lerpf(z, 1.35, k1)
	var k2 := smooth(2.3, 2.8, t) * (1.0 - smooth(5.4, 5.8, t))
	c = c.lerp(Vector2(930, 560), k2)
	z = lerpf(z, 1.1, k2)
	var k3 := smooth(5.4, 5.9, t) * (1.0 - smooth(PEAK + 0.2, PEAK + 0.5, t))
	c = c.lerp(Vector2(1000, 590), k3)
	z = lerpf(z, 1.22, k3)
	var k4 := smooth(PEAK + 0.2, PEAK + 0.6, t) * (1.0 - smooth(7.9, 9.0, t))
	c = c.lerp(Vector2(hero.pos.x + 420, 600), k4)
	z = lerpf(z, 1.15, k4)
	var k5 := smooth(8.6, 10.4, t)
	c = c.lerp(Vector2(900, 580), k5)
	return [c, z]


func _fx_ground(c: Node2D) -> void:
	# mái chùa đen xa + hai đèn đá + đường lát đá
	var roof := PackedVector2Array([Vector2(1000, 560), Vector2(1120, 470), Vector2(1560, 470), Vector2(1700, 560), Vector2(1660, 548), Vector2(1660, GROUND), Vector2(1040, GROUND), Vector2(1040, 548)])
	c.draw_colored_polygon(roof, Color("#6a5e74"))
	c.draw_colored_polygon(PackedVector2Array([Vector2(1130, 420), Vector2(1550, 420), Vector2(1600, 470), Vector2(1080, 470)]), Color("#6a5e74"))
	for x in [1140, 1240, 1340, 1440, 1540]:
		c.draw_rect(Rect2(x, 600, 18, GROUND - 600), Color("#7a6e84"))
	for x in [230.0, 1760.0]:
		c.draw_rect(Rect2(x - 26, GROUND - 170, 52, 170), Color("#6e6672"))
		c.draw_rect(Rect2(x - 44, GROUND - 205, 88, 40), Color("#6e6672"))
		c.draw_colored_polygon(PackedVector2Array([Vector2(x - 60, GROUND - 205), Vector2(x, GROUND - 250), Vector2(x + 60, GROUND - 205)]), Color("#5c5460"))
		flat_blob(c, Vector2(x, GROUND - 185), 60, 0.6, Color(1.0, 0.75, 0.4, 0.35))
	for i in 9:
		var y := GROUND + 18.0 + i * i * 6.0
		c.draw_line(Vector2(-600, y), Vector2(W + 600, y), Color(0.42, 0.38, 0.44, 0.5), 2.0)
	for i in 22:
		var x := -300.0 + i * 120.0
		c.draw_line(Vector2(x, GROUND), Vector2(CENTER.x + (x - CENTER.x) * 1.8, H + 300), Color(0.42, 0.38, 0.44, 0.35), 2.0)


func _strand(c: Node2D, i: int, ctr: Vector2, r: float, ph: float, a: float, w := 4.0) -> void:
	var pts := PackedVector2Array()
	for k in 18:
		var g := ph + TAU * i / 7.0 + k * 0.22
		var rr := r * (0.55 + 0.45 * sin(k * 0.35 + i))
		pts.append(ctr + Vector2(cos(g) * rr, sin(g) * rr * 0.55) + Vector2(0, (k - 9) * 1.5))
	var col: Color = KINH[i]
	col.a = a
	c.draw_polyline(pts, col, w, true)


func _fx_add(c: Node2D) -> void:
	# kim thân: vỏ vàng mờ quanh Không Kiến, sáng lên khi bị đánh
	var sc := _shell_c()
	var glow := 0.0
	for s in shots:
		glow = maxf(glow, pulse(float(s[0]) + 0.14, float(s[0]) + 0.2, 0.3, t))
	glow = maxf(glow, pulse(PEAK - 0.02, PEAK + 0.2, 0.6, t) * 1.6)
	var base := 0.18 + smooth(1.0, 2.0, t) * 0.12
	var pts := PackedVector2Array()
	for k in 49:
		var g := TAU * k / 48.0
		pts.append(sc + Vector2(cos(g) * 165.0, sin(g) * 215.0))
	var vc := VANG
	vc.a = clampf(base + glow * 0.6, 0.0, 1.0)
	c.draw_polyline(pts, vc, 5.0, true)
	blob(c, sc, 230, Color(VANG.r, VANG.g, VANG.b, 0.1 + glow * 0.18))
	# gợn trên kim thân chỗ mũi kình tắt
	for s in shots:
		var age: float = t - float(s[0]) - 0.16
		if age > 0.0 and age < 0.5:
			for j in 7:
				var p := sc + Vector2(-158, (j - 3) * 34.0)
				var rr := 10.0 + age * 90.0
				var col: Color = KINH[j]
				col.a = 0.8 * (1.0 - age / 0.5)
				c.draw_arc(p, rr, PI * 0.55, PI * 1.45, 12, col, 3.0, true)
	# tụ khí: bảy sợi xoắn quanh nắm đấm
	var hp: Vector2 = hero.handF
	var gk := smooth(1.0, 1.9, t) * (1.0 - smooth(PEAK + 0.1, PEAK + 0.4, t))
	if gk > 0.01:
		var br := smooth(5.5, 5.95, t)      # bện lại thành một dây trước quyền 13
		for i in 7:
			_strand(c, i, hp, lerpf(70.0, 26.0, br), t * 7.0, 0.85 * gk, 4.0)
		blob(c, hp, 40 + 30 * br, Color(1.6, 1.2, 1.0, 0.35 * gk))
	# mũi kình bay
	for s in shots:
		var u: float = (t - float(s[0])) / 0.16
		if u < 0.0 or u > 1.0:
			continue
		var from: Vector2 = hp
		for j in 7:
			var to := sc + Vector2(-158, (j - 3) * 34.0)
			var mid := (from + to) * 0.5 + Vector2(0, (j - 3) * 26.0)
			var p := from.lerp(mid, u).lerp(mid.lerp(to, u), u)
			var d := (mid.lerp(to, u) - from.lerp(mid, u)).normalized()
			var col: Color = KINH[j]
			c.draw_line(p - d * 70.0, p, Color(col.r, col.g, col.b, 0.5), 7.0, true)
			c.draw_line(p - d * 40.0, p, col, 3.5, true)
	# quyền 13: dây bện bay thẳng
	if t > PEAK - 0.08 and t < PEAK + 0.12:
		var u2 := clampf((t - PEAK + 0.08) / 0.08, 0.0, 1.0)
		var to2 := sc + Vector2(-160, 0)
		var head := hp.lerp(to2, u2)
		for i in 7:
			var off := Vector2(0, sin(t * 60.0 + i) * 6.0 + (i - 3) * 2.0)
			var col: Color = KINH[i]
			c.draw_line(hp + off, head + off, col, 4.0, true)
		blob(c, head, 50, Color(HOT.r, HOT.g, HOT.b, 0.5))
	# kình dội ngược: tia đỏ chạy về cánh tay, rồi vết nứt đỏ trên tay áo
	if hit:
		var r := smooth(PEAK + 0.02, PEAK + 0.22, t)
		var fade := 1.0 - smooth(PEAK + 0.5, PEAK + 1.0, t)
		if fade > 0.0 and r > 0.0:
			var a := sc + Vector2(-160, 0)
			var b := a.lerp(hp, r)
			var bl := bolt(a, b, 10, 18.0)
			c.draw_polyline(bl, Color(DO.r, DO.g, DO.b, 0.45 * fade), 9.0, true)
			c.draw_polyline(bl, Color(2.0, 1.2, 1.0, fade), 3.0, true)
		var ca := smooth(PEAK + 0.18, PEAK + 0.3, t) * (1.0 - smooth(8.6, 9.6, t))
		if ca > 0.0:
			var sh := joint_pos(hero, "uaF")
			var el := joint_pos(hero, "faF")
			var hd: Vector2 = hero.handF
			for seg in [[sh, el], [el, hd]]:
				var cr := bolt(seg[0], seg[1], 6, 9.0)
				c.draw_polyline(cr, Color(DO.r, DO.g, DO.b, 0.9 * ca), 3.0, true)
			blob(c, el, 26, Color(DO.r, DO.g, DO.b, 0.3 * ca))


func _fx_ui(c: Node2D) -> void:
	# bộ đếm 13 quyền: hàng 13 chấm trên đỉnh khung + số lớn
	var a := smooth(2.2, 2.5, rt) * (1.0 - smooth(9.2, 9.8, rt))
	if a <= 0.0:
		return
	var x0 := W * 0.5 - 12 * 26.0
	for i in 13:
		var p := Vector2(x0 + i * 52.0, 70)
		var on := i < dem
		var col: Color = KINH[i % 7] if on else Color(0.85, 0.8, 0.85)
		if i == 12 and on:
			col = Color(2.0, 0.6, 0.45)
		c.draw_circle(p, 15.0 if i == 12 else 11.0, Color(0.08, 0.06, 0.1, 0.7 * a))
		c.draw_circle(p, 10.0 if i == 12 else 7.0, Color(col.r, col.g, col.b, a if on else 0.45 * a))
	if dem > 0:
		var s := "QUYỀN %d" % dem
		var size := 54 if dem < 13 else 66
		var sw := font.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
		var p := Vector2((W - sw) * 0.5, 160)
		c.draw_string_outline(font, p, s, HORIZONTAL_ALIGNMENT_LEFT, -1, size, 12, Color(0.04, 0.02, 0.05, 0.85 * a))
		c.draw_string(font, p, s, HORIZONTAL_ALIGNMENT_LEFT, -1, size, Color(1.0, 0.95, 0.9, a) if dem < 13 else Color(1.8, 0.7, 0.5, a))
