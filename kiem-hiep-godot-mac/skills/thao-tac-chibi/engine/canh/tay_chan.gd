extends "res://canh.gd"
# So sánh tay chân: TRƯỚC (v1, mảnh SVG cứng) | SAU (v2, ống cong liền mạch + bàn tay 4 dạng). Cùng pose, cùng lúc.

const SEQ := ["rest", "stance", "palm", "point", "raise", "windup", "slash", "guard", "charge", "walk", "kneel", "kiem", "uong"]
const SEG := 0.9
var A: Array = []
var kiem_on := false


func _palette() -> void:
	sky_top = Color("#cfe3ea")
	sky_bot = Color("#f6efe0")
	ground_y = 900.0
	vign_a = 0.2
	caption = "Tay chân · trước / sau"


func _build() -> void:
	Chibi.V2_DEFAULT = false
	A.append(actor("hiep-khach", Vector2(680, ground_y), 1.0))
	Chibi.V2_DEFAULT = true
	A.append(actor("hiep-khach", Vector2(1240, ground_y), 1.0))


func _seg_pose(name: String) -> Variant:
	match name:
		"walk":
			return _walk_pose(t * 7.0)
		"kiem":
			return "point"
		"uong":
			return "rest"
	return name


func _story(_dt: float) -> void:
	if A.is_empty() or t < 0.0:
		return
	var i := mini(int(t / SEG), SEQ.size() - 1)
	var k := smooth(0.0, 0.3, t - i * SEG)
	var cur: String = SEQ[i]
	var prv: String = SEQ[maxi(i - 1, 0)]
	if cur == "kiem" and not kiem_on:
		kiem_on = true
		for a in A:
			prop(a, "kiem", "tay", "F", {"grip": -96.0})
	for a in A:
		a.extra = [[_seg_pose(prv), 1.0 - k], [_seg_pose(cur), k]]
		a.expr = "binh" if i < 2 else ("quyet-tam" if cur != "uong" else "vui")
		a.hold = {}
		a.hands = {}
		if cur == "uong":
			var to: Node2D = a.node.J["torso"]
			var lips := from_w(to, to_w(a.node.J["head"], Vector2(0, -30))) + Vector2(14, -6)
			a.hold["F"] = [lips, k]
			a.hands = {"F": "nam"}
		elif cur == "walk":
			a.hands = {"F": "tha", "B": "tha"}
		if kiem_on and cur == "uong":
			for v in props:
				v.node.visible = false


func _cam() -> Array:
	return [Vector2(960, 700), 1.55]


func _ground(c: Node2D) -> void:
	c.draw_rect(Rect2(-400, ground_y - 6, W + 800, 600), Color("#d9c9a6"))
	c.draw_line(Vector2(-400, ground_y - 6), Vector2(W + 400, ground_y - 6), Color("#9c8a68"), 3.0, true)


func _near(c: Node2D) -> void:
	var i := mini(int(maxf(t, 0.0) / SEG), SEQ.size() - 1)
	for pr in [[680.0, "TRƯỚC"], [1240.0, "SAU"]]:
		c.draw_string(font, Vector2(pr[0] - 150.0, 470.0), pr[1], HORIZONTAL_ALIGNMENT_CENTER, 300.0, 34, Color("#3a2d2a"))
	c.draw_string(font, Vector2(810, 960), SEQ[i], HORIZONTAL_ALIGNMENT_CENTER, 300.0, 30, Color("#7a4a2a"))
