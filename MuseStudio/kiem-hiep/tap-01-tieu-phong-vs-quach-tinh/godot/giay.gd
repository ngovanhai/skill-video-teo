# Cuộn giấy: một dải giấy rất dài (toạ độ thế giới), viền lụa trên dưới, hai đầu trục cuộn, vết ố.
extends Node2D

const X0 := -21000.0
const X1 := 16200.0
const H := 620.0

func _draw() -> void:
	var cam := get_viewport().get_camera_2d()
	var cx := cam.position.x if cam else 0.0
	var half := 960.0 / (cam.zoom.x if cam else 1.0) + 400.0
	var a := maxf(X0, cx - half); var b := minf(X1, cx + half)
	# lụa viền
	draw_rect(Rect2(a - 60, -H - 120, b - a + 120, 120), Color("5b3a2a"))
	draw_rect(Rect2(a - 60, H, b - a + 120, 120), Color("5b3a2a"))
	for y in [-H - 104, H + 96]:
		draw_rect(Rect2(a - 60, y, b - a + 120, 8), Color("c9a45c", 0.7))
	# giấy
	draw_rect(Rect2(a, -H, b - a, 2 * H), But.GIAY)
	# mép giấy hơi sẫm
	for i in 6:
		var k := i * 10.0
		draw_rect(Rect2(a, -H + k, b - a, 10), Color(0.55, 0.45, 0.3, 0.05 - i * 0.008))
		draw_rect(Rect2(a, H - k - 10, b - a, 10), Color(0.55, 0.45, 0.3, 0.05 - i * 0.008))
	# vết ố (cố định theo vị trí)
	var s0 := floori(a / 900.0)
	for s in range(s0, floori(b / 900.0) + 1):
		var x := s * 900.0 + But.h1(s) * 900.0
		var y := (But.h1(s * 1.7) - 0.5) * 1000.0
		if But.h1(s * 3.3) > 0.55:
			draw_colored_polygon(But.blob_pts(Vector2(x, y), 120 + 200 * But.h1(s * 5.1), 80 + 120 * But.h1(s * 2.9), s, 0.3, 28), Color(0.6, 0.48, 0.3, 0.035))
	# nếp gấp giữa các khung
	var f0 := ceili((a - 1200) / 2400.0)
	for f in range(f0, floori((b - 1200) / 2400.0) + 1):
		var x := f * 2400.0 + 1200.0
		draw_rect(Rect2(x - 3, -H, 6, 2 * H), Color(0.5, 0.4, 0.25, 0.05))
	# trục cuộn hai đầu
	for e in [[X0, -1.0], [X1, 1.0]]:
		var x: float = e[0]
		if x > a - 300 and x < b + 300:
			draw_rect(Rect2(x - 40 if e[1] > 0 else x - 40, -H - 160, 80, 2 * H + 320), Color("3a2418"))
			draw_rect(Rect2(x - 52, -H - 200, 104, 50), Color("c9a45c"))
			draw_rect(Rect2(x - 52, H + 150, 104, 50), Color("c9a45c"))
