extends "res://canh.gd"
# Xem trước thao tác mới: ngồi ghế (ngoi_ghe) + tu hồ lô khi ngồi, ngồi bệt (ngoi_bet), Điền ngồi vung đao.

const NECK := Vector2(44, 22)
var lhx: Dictionary
var dien: Dictionary
var teo: Dictionary
var nl: Dictionary
var ho: Dictionary
var dao: Dictionary
var ma: Dictionary


func _palette() -> void:
	sky_top = Color("#3b2a1e")
	sky_bot = Color("#7a5634")
	char_tint = Color(1.0, 0.96, 0.9)
	ground_y = 880.0


func _build() -> void:
	lhx = actor("lenh-ho-xung", Vector2(760, ground_y), 1.0)
	lhx.base = "rest"
	ho = prop(lhx, "ho_lo", "tay", "F")
	ho.lock = 1.0
	ma = prop(lhx, "ma_do", "mat", "F", {"cheek": Vector2(62, -54)})
	dien = actor("dien-ba-quang", Vector2(1180, ground_y), -1.0)
	dien.expr = "gian"
	dao = prop(dien, "dao", "tay", "F")
	teo = actor("teo-tieu-nhi", Vector2(330, ground_y), 1.0)
	teo.expr = "soc"
	nl = actor("nghi-lam", Vector2(1560, ground_y), -1.0)
	nl.expr = "binh"


func _lips(a: Dictionary, off: Vector2) -> Vector2:
	var to: Node2D = a.node.J["torso"]
	return from_w(to, to_w(a.node.J["head"], Vector2(0, -30))) + off


func _story(_dt: float) -> void:
	if t < 0.0:
		return
	# Lệnh Hồ Xung ngồi ghế: nâng hồ lô tu (1.0–3.2), cười lắc người (3.4–4.6)
	var tip := smooth(1.0, 1.7, t) * (1.0 - smooth(3.0, 3.5, t))
	ho.lockdir = Vector2.DOWN.lerp(Vector2(0.75, -0.66), tip).normalized()
	ho.aim = Vector2(0, -30)
	ho.pour = smooth(1.7, 1.9, t) * (1.0 - smooth(2.9, 3.0, t))
	lhx.hold["F"] = [Vector2(54, -30).lerp(_lips(lhx, Vector2(12, -12)), tip), 1.0]
	var laugh := smooth(3.4, 3.6, t) * (1.0 - smooth(4.6, 4.9, t))
	var s16 := sin(t * 16.0)
	lhx.extra = [[SIT, 1.0], [{"head": -18.0, "torso": -7.0}, tip],
		[{"all": [0.0, 0.0, 54.0 + absf(s16) * -8.0], "head": s16 * 5.0, "torso": 4.0 + s16 * 3.0, "uaB": -30.0, "faB": -60.0}, laugh]]
	lhx.expr = "vui" if t < 1.7 or t > 3.2 else "dac-y"
	ma.amount = smooth(2.6, 3.6, t)
	# Điền ngồi ghế, vung đao: windup → slash
	var wu := smooth(0.8, 1.6, t) * (1.0 - smooth(2.2, 2.4, t))
	var sl := smooth(2.2, 2.45, t) * (1.0 - smooth(3.6, 4.2, t))
	dien.extra = [[SIT, 1.0], ["windup", wu], ["slash", sl]]
	dien.expr = "gian" if t < 3.0 else "soc"
	dao.trail_on = sl > 0.1 and sl < 0.95
	if not dao.trail_on:
		dao.trail.clear()
	# Tèo ngồi bệt sau quầy (run sợ)
	teo.extra = [[SIT_GROUND, 1.0], [{"head": sin(t * 22.0) * 3.0}, 1.0]]
	# Nghi Lâm đứng chắp tay
	nl.extra = [[{"uaF": -30.0, "faF": -110.0, "uaB": -30.0, "faB": -110.0}, 1.0]]


func _sky(c: Node2D) -> void:
	vgrad(c, Rect2(-200, -200, 2320, 1480), sky_top, sky_bot)
	for i in 9:
		holo(c, Vector2(420 + i * 130, 260), 0.9, Color("#7a1f2a"), 1.0 if i < 4 else 0.0)


func _ground(c: Node2D) -> void:
	c.draw_rect(Rect2(-200, ground_y, 2320, 400), Color("#5a3c22"))
	hatch(c, PackedVector2Array([Vector2(-200, ground_y), Vector2(2120, ground_y), Vector2(2120, 1280), Vector2(-200, 1280)]), 0.3, 26.0, Color(ink, 0.35))
	ghe(c, lhx.pos, 1.0, Color("#a8743e"))
	ghe(c, dien.pos, -1.0, Color("#a8743e"))


func _cam() -> Array:
	if arg.get("zoom", false):
		return [Vector2(980, 720), 1.8]
	return [CENTER, 1.0]
