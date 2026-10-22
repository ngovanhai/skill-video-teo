extends "res://engine.gd"
# Hấp Tinh Đại Pháp (11.5 s): cao thủ lao tới tung chưởng băng lam, Nhậm Ngã Hành đưa một tay đón -> hai bàn tay dính chặt,
# xoáy hắc khí mở ra, nội lực xanh lam bị hút từ khắp người đối thủ qua tay vào đan điền; đối thủ tái nhợt, khuỵu xuống
# -> Nhậm Ngã Hành hất văng đối thủ.

const BLUE := Color(0.35, 0.9, 1.7)
const BLUE_HOT := Color(1.3, 1.9, 2.4)
const GREEN := Color(0.3, 1.5, 0.55)
const GREEN_HOT := Color(1.2, 2.2, 1.3)
const DARK := Color(0.03, 0.1, 0.06)
const CONTACT := 2.3
const RELEASE := 7.6

var contact := Vector2.ZERO
var touched := false
var released := false
var drains: Array = []
var bolts: Array = []
var x_hit := 0.0


func _setup() -> void:
	sky_cols = [Color("#070b14"), Color("#1e2a40"), Color("#47465a")]
	moon = Vector2(1500, 210)
	far_col = Color("#25304a")
	near_col = Color("#1a2236")
	mist_col = Color(0.6, 0.7, 0.8, 0.22)
	ground_cols = [Color("#383a44"), Color("#141519"), Color("#5a5c68")]
	slowmo = [7.6, 8.15, 0.3]
	title = "HẤP TINH ĐẠI PHÁP"
	title_at = 8.7
	cue(0.5, "lib-riser", 0.6)
	cue(1.55, "lib-whoosh", 0.8)
	cue(CONTACT, "lib-impact-bass-2", 0.9)
	cue(4.0, "lib-glitch-1", 0.4)
	cue(5.5, "lib-glitch-1", 0.4)
	cue(6.0, "lib-riser", 0.8)
	cue(6.8, "lib-glitch-1", 0.5)
	cue(RELEASE - 0.3, "lib-whoosh-cinematic", 0.8)
	cue(RELEASE, "lib-impact-bass-1", 1.0)
	cue(RELEASE, "lib-impact-bass-2", 1.0)
	title_col = Color(0.8, 2.0, 1.0)
	set_char(hero, "nham-nga-hanh")
	set_char(foe, "cao-thu")
	hero.pos = Vector2(640, GROUND)
	foe.pos = Vector2(1460, GROUND)
	hero.col = GREEN
	foe.col = BLUE


func _chest() -> Vector2:
	return hero.pos + Vector2(-10, -175)


func _story(dt: float) -> void:
	var dr := smooth(CONTACT + 0.3, RELEASE, t)       # mức bị hút
	# ---- đối thủ: tụ khí -> lao tới -> chưởng -> dính -> khuỵu
	foe.gather = smooth(0.5, 1.2, t) * (1.0 - smooth(1.5, 1.7, t))
	foe.aura = smooth(0.5, 1.4, t) * (1.0 - dr * 0.95) * (1.0 - smooth(RELEASE, RELEASE + 0.2, t))
	var dash := smooth(1.55, CONTACT, t)
	foe.extra = [["run", pulse(1.55, 2.05, 0.25, t)]]
	foe.push = smooth(2.0, 2.25, t) * (1.0 - smooth(RELEASE, RELEASE + 0.1, t))
	foe.crouch = foe.gather * 0.5 + dr * 1.3
	foe.lean = foe.push * 0.3 - smooth(2.5, 3.2, t) * 0.5 * (1.0 - dr * 0.5) + sin(t * 23.0) * 0.06 * smooth(2.5, 3.0, t)
	foe.tint = Color(1, 1, 1).lerp(Color(0.62, 0.66, 0.74), dr)
	foe.scale = 1.0 - dr * 0.08
	foe.expr = "ko" if released else ("soc" if t > 2.5 else ("gian" if t > 0.5 else "binh"))
	# ---- Nhậm Ngã Hành: đưa một tay đón, sau đó hai tay đẩy
	var meet := smooth(1.85, 2.2, t) * (1.0 - smooth(RELEASE - 0.1, RELEASE, t))
	hero.extra = [["point", meet], [{"uaB": -40, "faB": -110, "torso": -6}, meet * dr]]
	hero.push = smooth(RELEASE - 0.1, RELEASE + 0.05, t) * (1.0 - smooth(8.6, 9.6, t))
	hero.both = hero.push
	hero.lean = meet * 0.15 + hero.push * 0.3
	hero.aura = smooth(2.4, 3.4, t) * (0.3 + dr * 1.0) * (1.0 - smooth(RELEASE + 0.3, 9.5, t))
	hero.expr = "vui" if t > 8.3 else ("dac-y" if t > 3.2 else ("gian" if t > 1.8 else "binh"))
	pose(hero, 0.0)
	pose(foe, 0.0)
	# đặt đối thủ sao cho hai bàn tay chạm nhau
	if not released:
		var xc: float = foe.pos.x + (hero.hand.x + 150.0 - foe.hand.x)
		foe.pos.x = lerpf(1460.0, xc, ease_out(dash)) if not touched else xc
		pose(foe, 0.0)
	contact = hero.hand.lerp(foe.hand, 0.5)

	if foe.aura > 0.05:
		for i in int(foe.aura * 4):
			emit("add", foe.pos + Vector2(rng.randf_range(-70, 70), -rng.randf_range(0, 260)), Vector2(rng.randf_range(-20, 20), -rng.randf_range(100, 260)), 0.6, rng.randf_range(14, 30), BLUE * Color(1, 1, 1, 0.12))
	if t > 0.6 and t < 1.6:
		for i in 4:
			orbit(foe, rng.randf_range(120, 320), -rng.randf_range(2.0, 4.0), rng.randf_range(200, 360), rng.randf_range(3, 6), BLUE, 1.6)
	if dash > 0.0 and dash < 1.0:
		for i in 3:
			emit("smoke", Vector2(foe.pos.x + rng.randf_range(0, 80), GROUND), Vector2(rng.randf_range(40, 160), -rng.randf_range(10, 60)), 1.2, rng.randf_range(20, 40), Color(0.45, 0.5, 0.48, 0.3))

	if t >= CONTACT and not touched:
		touched = true
		flash = 0.4
		flash_col = Color(0.8, 1.0, 0.9)
		shake = 22.0
		add_ring(contact, 420, BLUE_HOT, 16, 0.5)
		add_ring(contact, 300, GREEN_HOT, 10, 0.5, 1.0, 0.08)
		burst(contact, 90, 300, 1300, BLUE_HOT, GREEN_HOT)

	if touched and not released:
		var vk := smooth(CONTACT + 0.2, CONTACT + 1.2, t)
		shake = maxf(shake, 3.0 + dr * 6.0)
		# nội lực bị rút: hạt từ khắp thân đối thủ -> xoáy -> tay -> đan điền
		if t > CONTACT + 0.3:
			for i in int(2 + vk * 5 * (1.0 - dr * 0.4)):
				var from: Vector2 = foe.pos + Vector2(rng.randf_range(-80, 80), -rng.randf_range(10, 300) * foe.scale)
				drains.append({"from": from, "t0": t, "dur": rng.randf_range(0.7, 1.2), "ph": rng.randf() * TAU, "sz": rng.randf_range(4, 9), "hot": rng.randf() < 0.3})
		# bụi đất bị hút về xoáy
		if rng.randf() < 0.6 * vk:
			var p := Vector2(contact.x + rng.randf_range(-700, 700), GROUND + rng.randf_range(0, 30))
			emit("smoke", p, (contact - p) * rng.randf_range(0.8, 1.4), 1.0, rng.randf_range(16, 34), Color(0.4, 0.5, 0.45, 0.28))
		if int(rt * 30) % 3 == 0:
			bolts.clear()
			for b in int(1 + vk * 3):
				var a := rng.randf() * TAU
				bolts.append(bolt(contact, contact + Vector2(cos(a), sin(a)) * rng.randf_range(120, 260) * (0.6 + dr), 8, 20))
		if int(t * 30) % 15 == 0:
			add_ring(contact, 220 + dr * 160, GREEN_HOT if int(t * 30) % 30 == 0 else BLUE_HOT, 6, 0.5)
		# nhịp hút mạnh
		for pk in [4.0, 5.5, 6.8]:
			if t >= pk and t - dt < pk:
				add_ring(_chest(), 260, GREEN_HOT, 10, 0.5)
				add_ring(foe.pos + Vector2(0, -160), 300, BLUE_HOT, 8, 0.5, 1.0, 0.0)
				shake = maxf(shake, 14.0)
				flash = maxf(flash, 0.15)
				flash_col = Color(0.7, 1.0, 0.8)
	var keep: Array = []
	for d in drains:
		if t - d.t0 < d.dur:
			keep.append(d)
	drains = keep

	if t >= RELEASE and not released:
		released = true
		x_hit = foe.pos.x
		bolts.clear()
		flash = 0.9
		flash_col = Color(0.8, 1.0, 0.85)
		shake = 42.0
		add_ring(contact, 850, GREEN_HOT, 26, 0.85)
		add_ring(contact, 560, Color(2, 2, 2), 12, 0.5, 1.0, 0.06)
		add_ring(Vector2(contact.x, GROUND), 950, GREEN, 14, 1.0, 0.2)
		for i in 220:
			var a := rng.randf() * TAU
			emit("spark", contact, Vector2(cos(a), sin(a)) * rng.randf_range(300, 2000), rng.randf_range(0.4, 1.1), rng.randf_range(2, 5), GREEN_HOT if i % 3 else BLUE_HOT, 900.0, 0.9)
		for i in 30:
			var a := rng.randf() * TAU
			emit("smoke", contact, Vector2(cos(a), sin(a) * 0.6) * rng.randf_range(100, 450), rng.randf_range(1.8, 3.0), rng.randf_range(50, 120), Color(0.25, 0.35, 0.3, 0.55), -40.0, 1.6)
	if released:
		var k := clampf((t - RELEASE) / 1.0, 0.0, 1.0)
		foe.pos = Vector2(lerpf(x_hit, 1560.0, ease_out(k)), GROUND - sin(k * PI) * 150.0 if k < 1.0 else GROUND)
		foe.rot = ease_out(k) * PI * 0.5
		foe.hurt = 1.0
		foe.extra = []
		foe.crouch = 0.0
		if k >= 1.0 and not foe.has("landed"):
			foe.landed = true
			sfx("lib-impact-bass-2", 0.5)
			shake = maxf(shake, 14.0)
			for i in 22:
				emit("smoke", Vector2(1560 + rng.randf_range(-40, 260), GROUND), Vector2(rng.randf_range(-160, 220), -rng.randf_range(20, 140)), 2.2, rng.randf_range(40, 90), Color(0.4, 0.45, 0.42, 0.4))
	if t > 8.0 and rng.randf() < 0.5:
		emit("ember", Vector2(rng.randf_range(500, 1900), GROUND + 20), Vector2(rng.randf_range(-20, 30), -rng.randf_range(40, 120)), rng.randf_range(2.0, 3.5), rng.randf_range(2, 4), GREEN)
	if hero.aura > 0.05:
		for i in int(hero.aura * 4):
			emit("add", hero.pos + Vector2(rng.randf_range(-75, 75), -rng.randf_range(0, 280)), Vector2(rng.randf_range(-20, 20), -rng.randf_range(120, 300) * (0.6 + hero.aura)), rng.randf_range(0.4, 0.8), rng.randf_range(14, 34) * (0.6 + hero.aura * 0.5), GREEN * Color(1, 1, 1, 0.12))


# đường đi của một hạt nội lực: thân đối thủ -> xoáy quanh điểm chạm -> dọc tay -> đan điền
func _drain_pos(d: Dictionary, k: float) -> Vector2:
	var chest := _chest()
	if k < 0.6:
		var u := k / 0.6
		var sp := (1.0 - u) * 90.0
		var a: float = d.ph + u * 9.0
		return d.from.lerp(contact, u * u) + Vector2(cos(a), sin(a)) * sp
	var u2 := (k - 0.6) / 0.4
	var mid: Vector2 = hero.handF.lerp(chest, 0.5) + Vector2(0, -30)
	return contact.lerp(mid, u2).lerp(mid.lerp(chest, u2), u2)


func _cam() -> Array:
	var c := CENTER
	var z := 1.0
	var k1 := smooth(2.6, 7.4, t) * (1.0 - smooth(7.6, 8.2, t))
	c = c.lerp(contact + Vector2(-60, -10), smooth(2.2, 3.5, t) * (1.0 - smooth(7.6, 8.2, t)))
	z = lerpf(z, 1.55, k1)
	var k2 := smooth(7.7, 8.3, t)
	c = c.lerp(Vector2(1080, 590), k2)
	z = lerpf(z, 1.02, k2)
	z += 0.04 * smooth(0.0, 2.0, t) * (1.0 - smooth(2.2, 3.0, t))
	return [c, z]


func _fx_norm(c: Node2D) -> void:
	# xoáy hắc khí (vẽ thường, không cộng sáng) ở điểm chạm
	if touched and not released:
		var vk := smooth(CONTACT + 0.1, CONTACT + 1.2, t)
		var dr := smooth(CONTACT + 0.3, RELEASE, t)
		var R := (90.0 + 110.0 * dr) * vk
		blob(c, contact, R * 1.5, Color(DARK.r, DARK.g, DARK.b, 0.55 * vk))
		for arm in 5:
			var pts := PackedVector2Array()
			for i in 22:
				var u := i / 21.0
				var a := -rt * 5.0 + arm * TAU / 5.0 + u * 4.2
				pts.append(contact + Vector2(cos(a), sin(a) * 0.85) * R * (1.0 - u * 0.92))
			c.draw_polyline(pts, Color(0.02, 0.07, 0.04, 0.75 * vk), 16.0 * (0.5 + dr * 0.5))


func _fx_add(c: Node2D) -> void:
	if foe.gather > 0.05:
		blob(c, foe.hand, 90 * foe.gather, BLUE * Color(1, 1, 1, 0.3))
		blob(c, foe.hand, 24 * foe.gather, BLUE_HOT)
	if foe.push > 0.05 and not touched:
		blob(c, foe.hand, 70, BLUE * Color(1, 1, 1, 0.35))
		blob(c, foe.hand, 22, BLUE_HOT)
	if touched and not released:
		var vk := smooth(CONTACT + 0.1, CONTACT + 1.2, t)
		var dr := smooth(CONTACT + 0.3, RELEASE, t)
		var R := (90.0 + 110.0 * dr) * vk
		# viền xoáy xanh lục + lõi sáng
		for arm in 5:
			var pts := PackedVector2Array()
			for i in 22:
				var u := i / 21.0
				var a := -rt * 5.0 + arm * TAU / 5.0 + u * 4.2 + 0.18
				pts.append(contact + Vector2(cos(a), sin(a) * 0.85) * R * (1.0 - u * 0.92))
			c.draw_polyline(pts, GREEN * Color(1, 1, 1, 0.55 * vk), 3.0)
		c.draw_set_transform(contact, 0.0, Vector2(1.0, 0.85))
		c.draw_arc(Vector2.ZERO, R, 0, TAU, 64, GREEN_HOT * Color(1, 1, 1, 0.7 * vk), 3.0)
		c.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
		blob(c, contact, 30 + 10 * sin(rt * 30.0), GREEN_HOT * Color(1, 1, 1, vk))
		for bl in bolts:
			c.draw_polyline(bl, GREEN_HOT, 2.5)
			c.draw_polyline(bl, GREEN * Color(1, 1, 1, 0.35), 8.0)
		# luồng khí dọc cánh tay vào đan điền
		var chest := _chest()
		var path := PackedVector2Array([contact, hero.handF.lerp(chest, 0.5) + Vector2(0, -30), chest])
		c.draw_polyline(path, BLUE * Color(1, 1, 1, 0.18 * vk), 26.0)
		c.draw_polyline(path, BLUE_HOT * Color(1, 1, 1, 0.5 * vk), 5.0)
		blob(c, chest, 70 + 60 * dr + 8 * sin(rt * 18.0), GREEN * Color(1, 1, 1, 0.35 * vk))
		blob(c, chest, 18 + 16 * dr, GREEN_HOT * Color(1, 1, 1, vk))
	for d in drains:
		var k: float = (t - d.t0) / d.dur
		var p := _drain_pos(d, k)
		var p2 := _drain_pos(d, maxf(0.0, k - 0.06))
		var col: Color = BLUE_HOT if d.hot else BLUE
		c.draw_line(p2, p, col * Color(1, 1, 1, 0.6), d.sz * 0.6)
		blob(c, p, d.sz * 2.4, col * Color(1, 1, 1, 0.3))
	if released:
		var k := smooth(RELEASE, RELEASE + 0.6, t)
		blob(c, contact, 180 * (1.0 - k) + 30, GREEN_HOT * Color(1, 1, 1, 0.35 * (1.0 - k)))
