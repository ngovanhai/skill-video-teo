extends "res://canh.gd"
# So sánh giai đoạn 2: TRƯỚC (vạt cứng + đi sin) | SAU (vạt mềm lò xo + chu kỳ đi 4 nhịp).
# Đi tại chỗ (nền trôi để soi trượt chân) → dừng (vạt lắc rồi lặng) → thế thủ → quỳ → vung chém → gió → 4 nhịp đi đứng hình.

const SPEED := 110.0
const BEATS := ["chạm gót", "nhún", "lướt qua", "nhấc"]
var A: Array = []
var sc := 0.0
var label := ""


func _palette() -> void:
	sky_top = Color("#d6e4dc")
	sky_bot = Color("#f4eedf")
	ground_y = 900.0
	vign_a = 0.2
	caption = "Vạt áo · dáng đi — trước / sau"


func _build() -> void:
	Chibi.V2_DEFAULT = false
	A.append(actor("hiep-khach", Vector2(680, ground_y), 1.0))
	A[0].gait = "v1"
	Chibi.V2_DEFAULT = true
	A.append(actor("hiep-khach", Vector2(1240, ground_y), 1.0))


func _story(dt: float) -> void:
	if A.is_empty() or t < 0.0:
		return
	var walking := t < 4.4
	for a in A:
		a.inplace = SPEED if walking else 0.0
		a.extra = []
		a.sway = 1.0
		a.expr = "binh"
	sc += dt * SPEED * float(A[1].walk)
	label = "đi" if t < 4.4 else "dừng"
	if t >= 5.2 and t < 10.2:
		var seq := [[5.2, "stance", "thế thủ"], [6.3, "kneel", "quỳ"], [7.5, "windup", "vung"], [7.95, "slash", "chém"], [8.7, "rest", "gió thổi"]]
		var cur := 0
		for i in seq.size():
			if t >= seq[i][0]:
				cur = i
		var prv: String = "rest" if cur == 0 else seq[cur - 1][1]
		var dur := 0.12 if seq[cur][1] == "slash" else 0.3
		var k := smooth(seq[cur][0], seq[cur][0] + dur, t)
		label = seq[cur][2]
		for a in A:
			a.extra = [[prv, 1.0 - k], [seq[cur][1], k]]
			a.expr = "quyet-tam"
			if seq[cur][1] == "rest":
				a.sway = 1.0 + 3.0 * smooth(8.8, 9.2, t) * (1.0 - smooth(9.7, 10.1, t))
	elif t >= 10.2:
		var b := mini(int((t - 10.2) / 0.6), 3)
		label = "nhịp %d · %s" % [b + 1, BEATS[b]]
		for a in A:
			var ph := float(b) * TAU / 8.0
			a.extra = [[_walk_pose(ph, a.get("gait", "v2")), 1.0]]


func _cam() -> Array:
	return [Vector2(960, 700), 1.55]


func _ground(c: Node2D) -> void:
	c.draw_rect(Rect2(-400, ground_y - 6, W + 800, 600), Color("#d6c7a2"))
	c.draw_line(Vector2(-400, ground_y - 6), Vector2(W + 400, ground_y - 6), Color("#9c8a68"), 3.0, true)
	for x0 in [680.0, 1240.0]:      # sỏi trôi theo tốc độ đi: chân chạm đất phải trôi cùng sỏi
		for i in 8:
			var x: float = x0 + fposmod(i * 60.0 - sc, 480.0) - 240.0
			c.draw_circle(Vector2(x, ground_y + 6), 4.0, Color("#8f7b58"), true, -1.0, true)


func _near(c: Node2D) -> void:
	for pr in [[680.0, "TRƯỚC"], [1240.0, "SAU"]]:
		c.draw_string(font, Vector2(pr[0] - 150.0, 470.0), pr[1], HORIZONTAL_ALIGNMENT_CENTER, 300.0, 34, Color("#3a2d2a"))
	c.draw_string(font, Vector2(760, 960), label, HORIZONTAL_ALIGNMENT_CENTER, 400.0, 30, Color("#7a4a2a"))
