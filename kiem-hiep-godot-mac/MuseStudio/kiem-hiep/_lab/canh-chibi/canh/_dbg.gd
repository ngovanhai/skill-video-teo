extends "res://canh.gd"
var a: Dictionary

func _build() -> void:
	a = actor("tieu-phong", Vector2(960, ground_y), 1.0)

func _cam() -> Array:
	return [Vector2(960, 640), 2.2]

func _near(c: Node2D) -> void:
	if a.is_empty():
		return
	var hd: Node2D = a.node.J["head"]
	var to: Node2D = a.node.J["torso"]
	for y in range(-160, 41, 20):
		for x in range(-120, 121, 20):
			c.draw_circle(to_w(hd, Vector2(x, y)), 1.6, Color(1, 0, 0, 0.8))
	for y in range(-160, 41, 40):
		c.draw_string(font, to_w(hd, Vector2(-160, y)), str(y), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.RED)
	for x in range(-120, 121, 40):
		c.draw_string(font, to_w(hd, Vector2(x, -170)), str(x), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.RED)
	for y in range(-160, 41, 20):
		for x in range(-100, 141, 20):
			c.draw_circle(to_w(to, Vector2(x, y)), 1.6, Color(0, 0, 1, 0.8))
	for y in range(-160, 41, 40):
		c.draw_string(font, to_w(to, Vector2(150, y)), str(y), HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color.BLUE)
	print("head origin w ", to_w(hd, Vector2.ZERO), " torso origin w ", to_w(to, Vector2.ZERO), " headpos ", head_of(a), " feet ", a.pos)
