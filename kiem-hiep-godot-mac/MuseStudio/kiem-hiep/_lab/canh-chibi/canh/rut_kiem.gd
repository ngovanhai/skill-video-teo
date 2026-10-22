extends "res://canh/rung_truc.gd"
# Thử vật phẩm: RÚT KIẾM. Kiếm + vỏ đeo hông (tua đỏ đung đưa) → tay nắm chuôi → rút dọc theo vỏ (lưỡi lộ dần)
# → lóe sáng chạy dọc lưỡi → giương kiếm → chém (vệt kiếm) chẻ đôi chiếc lá đang rơi → thu thế chĩa kiếm.

var kiem: Dictionary
var la := {"p": Vector2(1150, 260), "cut": -1.0, "halves": []}
var prev_g := Vector2.INF
# lấy đà THẤP: kiếm kéo ra sau hông (tay F vòng xuống dưới, không giơ qua mặt) → chém hất lên chéo trước ngực
const WIND := {"uaF": 88, "faF": -22, "uaB": -34, "faB": -50, "torso": 12, "head": 5, "thF": -18, "shF": 24, "thB": 16, "shB": -20, "all": [0, -8, 16]}
const RISE := {"uaF": -100, "faF": 8, "uaB": 34, "faB": -20, "torso": -14, "head": -6, "thF": -44, "shF": 32, "thB": 26, "shB": -8, "all": [0, 40, 20]}


func _build() -> void:
	_bg()
	hero = actor("hiep-khach", Vector2(860, ground_y), 1.0)
	hero.base = "stance"
	hero.expr = "binh"
	kiem = prop(hero, "kiem", "hong", "F", {"vo": true, "hong": Vector2(34, 4), "pull_k": 1.7, "sheath": Vector2(-0.9, 0.42).normalized()})


func _story(dt: float) -> void:
	_weather()
	if hero.is_empty() or t < 0.0:
		return
	var to: Node2D = hero.node.J["torso"]
	var sh: Vector2 = kiem.sheath
	var sheath_w := ldir(to, sh)
	var grip_pt: Vector2 = Vector2(34, 4) - sh * 22.0
	# 1) đưa tay tới chuôi
	if t < 1.8:
		hero.hold["F"] = [grip_pt, smooth(1.3, 1.75, t)]
		hero.expr = "binh" if t < 1.3 else "quyet-tam"
	# 2) nắm chuôi, rút dọc phương vỏ (lock = giữ hướng thế giới của vỏ)
	elif t < 2.1:
		if kiem.at != "tay":
			prop_to(kiem, "tay", "F")
			kiem.lock = 1.0
			kiem.out = 0.0
			kiem.lockdir = sheath_w
		var k := smooth(1.8, 2.08, t)
		hero.hold["F"] = [grip_pt - sh * 120.0 * k, 1.0]
		hero.extra = [[{"torso": -8.0, "uaB": 50.0}, k]]
	# 3) lóe sáng, buông khoá hướng, giương kiếm (windup)
	elif t < 3.12:
		if float(kiem.glint) < 0.0:
			kiem.glint = 2.12
		var k := smooth(2.1, 2.6, t)
		kiem.lock = 1.0 - smooth(2.1, 2.35, t)
		kiem.grip = lerpf(-60.0, 0.0, k)      # lưỡi nối dài cẳng tay: chĩa xuống sau
		var hv: Array = hero.hold["F"]
		hero.hold["F"] = [hv[0], 1.0 - k]
		hero.extra = [[WIND, k]]
		hero.hands = {"F": "nam"}
	# 4) chém
	elif t < 3.5:
		var k := smooth(3.12, 3.32, t)
		kiem.trail_on = t > 3.19 and t < 3.42     # vệt chỉ hiện khi lưỡi đã lên ngang ngực (đoạn quét sát đất bỏ)
		if not kiem.trail_on:
			kiem.trail.clear()     # xoá lịch sử để vệt không kéo lại đoạn quét sát đất
		kiem.grip = lerpf(0.0, -10.0, k)
		hero.extra = [[WIND, 1.0 - k], [RISE, k]]
		hero.hands = {"F": "nam"}
		hero.expr = "gian"
	# 5) thu thế: kiếm chĩa ngang
	else:
		var k := smooth(4.2, 4.8, t)
		kiem.trail_on = false
		kiem.grip = lerpf(-10.0, -4.0, k)
		hero.extra = [[RISE, 1.0 - k], ["point", k]]
		hero.hands = {}
		hero.expr = "gian" if t < 4.6 else "dac-y"
	_leaf(dt)


# chiếc lá rơi; nhát chém quét qua thì chẻ đôi
func _leaf(dt: float) -> void:
	var g: Vector2 = kiem.guardw
	var tip: Vector2 = kiem.tipw
	if la.cut < 0.0:
		la.p = Vector2(1110.0 + sin(t * 2.2) * 20.0, 260.0 + t * 115.0)
		if kiem.trail_on and prev_g != Vector2.INF:
			var tr: Array = kiem.trail
			if tr.size() > 1:
				var t1: Array = tr[1]
				var poly := PackedVector2Array([prev_g, t1[0], tip, g])
				var lp: Vector2 = la.p
				if Geometry2D.is_point_in_polygon(lp, poly):
					la.cut = t
					var dirv := (tip - g).normalized()
					var nv := Vector2(-dirv.y, dirv.x)
					la.halves = [{"p": lp, "v": nv * 160.0 + Vector2(0, -60), "r": 0.6, "rs": 5.0},
						{"p": lp, "v": -nv * 160.0 + Vector2(0, -40), "r": 0.6, "rs": -6.0}]
					spawn("smoke", lp, {"col": Color(1, 1, 0.9), "max": 0.5, "life": 0.5, "s": 0.25, "z": 1.1})
	else:
		for h in la.halves:
			var hv: Vector2 = h.v
			var hp: Vector2 = h.p
			hv = hv.move_toward(Vector2(wind(hp.x) * 60.0, 80.0), dt * 260.0)
			h.v = hv
			h.p = hp + hv * dt
			h.r += h.rs * dt
	prev_g = g


func _cam() -> Array:
	return [Vector2(lerpf(1000.0, 1020.0, smooth(0.0, 8.0, t)), lerpf(660.0, 640.0, smooth(0.0, 8.0, t))), lerpf(1.4, 1.3, smooth(3.0, 8.0, t))]


func _near(c: Node2D) -> void:
	super._near(c)
	var col := Color("#f2b33a")
	if la.cut < 0.0:
		leaf(c, la.p, 0.5 + sin(t * 2.2) * 0.4, 64.0, 22.0, col, 3.0)
	else:
		for h in la.halves:
			var hp: Vector2 = h.p
			var r: float = h.r
			var d := Vector2.from_angle(r)
			var pts := PackedVector2Array()
			for i in 9:
				var k := float(i) / 8.0
				pts.append(hp + d * (k - 0.5) * 64.0 + d.orthogonal() * sin(k * PI) * 11.0)
			shape(c, pts, col, 3.0)
