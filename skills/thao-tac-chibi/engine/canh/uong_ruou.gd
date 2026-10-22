extends "res://canh/nui_tuyet.gd"
# Thử vật phẩm: UỐNG RƯỢU. Hồ lô đeo hông đung đưa trong gió → cầm lên → ngửa cổ tu, dòng rượu chảy vào miệng
# → hạ xuống, phà một hơi khói lớn, má đỏ dần, cười lắc người, nấc ra bong bóng → đeo hồ lô lại hông.

const NECK := Vector2(44, 22)        # chỗ nắm cổ hồ lô khi đang đeo (toạ độ thân)
var ho: Dictionary
var ma: Dictionary
var puffed := false
var bacc := 0.0


func _build() -> void:
	a = actor("tieu-phong", Vector2(960, ground_y), 1.0)
	a.expr = "binh"
	a.sway = 1.4
	ho = prop(a, "ho_lo", "hong", "F", {"hong": Vector2(40, 4)})
	ma = prop(a, "ma_do", "mat", "F", {"cheek": Vector2(62, -54)})


func _lips_t(off: Vector2) -> Vector2:
	var to: Node2D = a.node.J["torso"]
	return from_w(to, to_w(a.node.J["head"], Vector2(0, -30))) + off


func _story(dt: float) -> void:
	_weather()
	if a.is_empty() or t < 0.0:
		return
	var face: float = a.face
	var tip := smooth(1.6, 2.3, t) * (1.0 - smooth(3.6, 4.1, t))      # độ ngửa/dốc hồ lô
	if t < 1.45:
		a.hold["F"] = [NECK, smooth(0.9, 1.4, t)]
		_breath(dt, [a])
	elif t < 6.4:
		if ho.at != "tay":
			prop_to(ho, "tay", "F")
			ho.lock = 1.0
		ho.lockdir = Vector2.DOWN.lerp(Vector2(face * 0.75, -0.66), tip).normalized()
		var up := smooth(1.45, 2.2, t) * (1.0 - smooth(3.6, 4.2, t))
		var low := smooth(3.6, 4.2, t) * (1.0 - smooth(5.9, 6.35, t))
		var tg := NECK.lerp(_lips_t(Vector2(12, -12)), up)
		tg = tg.lerp(Vector2(54, -44), low)
		if t > 5.9:
			tg = Vector2(54, -44).lerp(NECK, smooth(5.9, 6.35, t))
		a.hold["F"] = [tg, 1.0]
		ho.aim = Vector2(0, -30)
		ho.pour = smooth(2.2, 2.4, t) * (1.0 - smooth(3.45, 3.6, t))
		a.expr = "binh" if t < 2.2 else ("vui" if t < 3.6 else ("dac-y" if t < 4.4 else "vui"))
		# rượu sánh ra mép
		var pr: float = ho.pour
		if pr > 0.5 and rng.randf() < 0.18:
			var mw := to_w(a.node.J["head"], Vector2(14, -26))
			spawn("drop", mw, {"z": 1.2, "life": 1.0, "col": Color(1.0, 0.75, 0.35), "land": ground_y, "v": Vector2(face * 40.0, 20.0)})
	else:
		if ho.at != "hong":
			prop_to(ho, "hong", "F")
		a.hold["F"] = [NECK, 1.0 - smooth(6.4, 6.9, t)]
		_breath(dt, [a])
	# ngửa cổ khi tu, sau đó cười lắc người
	var laugh := smooth(4.5, 4.7, t) * (1.0 - smooth(5.8, 6.1, t))
	var s16 := sin(t * 16.0)
	a.extra = [[{"head": -18.0, "torso": -7.0}, tip],
		[{"all": [0.0, 0.0, absf(s16) * -8.0], "head": s16 * 5.0, "torso": 4.0 + s16 * 3.0, "uaB": -30.0, "faB": -60.0}, laugh]]
	# phà hơi rượu
	if t > 4.15 and not puffed:
		puffed = true
		var mw := to_w(a.node.J["head"], Vector2(20, -28))
		for i in 6:
			spawn("smoke", mw + Vector2(face * i * 16.0, -i * 4.0), {"col": Color(1.0, 0.96, 0.9), "max": 1.8, "life": 1.8, "s": 0.3 + i * 0.08, "z": 1.1})
	ma.amount = smooth(3.8, 4.8, t)
	# nấc ra bong bóng
	if t > 4.8 and t < 6.6:
		bacc += 5.0 * dt
		while bacc >= 1.0:
			bacc -= 1.0
			var mw := to_w(a.node.J["head"], Vector2(18, -28))
			spawn("bubble", mw, {"col": Color(1.0, 0.8, 0.9), "life": 1.2, "s": 0.0, "z": 1.1})


func _cam() -> Array:
	return [Vector2(980.0, 650.0), lerpf(1.5, 1.4, smooth(0.0, 8.0, t))]
