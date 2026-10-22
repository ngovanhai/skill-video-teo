extends "res://canh.gd"
# __MO_TA__
# Nhịp: ghi từng beat của kịch bản → thao tác trong data/thao-tac.json (id) → khoảng t.

var a: Dictionary


func _palette() -> void:
	sky_top = Color("#9fd8c8")
	sky_bot = Color("#fbf1cc")
	haze = Color("#d6ecd2")
	ink = Color("#1d2b20")
	char_tint = Color(1, 1, 1)
	ground_y = 870.0
	wind_base = 0.3
	wind_gust = 0.6
	vign_a = 0.3
	caption = ""


func _build() -> void:
	a = actor("hiep-khach", Vector2(500, ground_y), 1.0)
	a.go = Vector2(900, ground_y)      # thao tác "di"
	a.speed = 110.0


func _story(_dt: float) -> void:
	if a.is_empty() or t < 0.0:
		return
	# ví dụ: dừng rồi ngửa mặt
	var k := smooth(4.5, 5.0, t)
	a.extra = [[{"head": -14.0, "torso": -3.0}, k]]
	a.expr = "binh" if t < 4.5 else "vui"


func _cam() -> Array:
	return [Vector2(960, 620), 1.25]


func _sky(c: Node2D) -> void:
	vgrad(c, Rect2(-400, -300, W + 800, ground_y + 300), sky_top, sky_bot)


func _ground(c: Node2D) -> void:
	c.draw_rect(Rect2(-600, ground_y - 6, W + 1200, 700), Color("#b9c48a"))
	grass(c, -600, W + 600, ground_y, 18.0, 26.0, Color("#6f9a4a"), 7)
