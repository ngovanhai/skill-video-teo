# Ảnh bìa tập 01 vẽ bằng chính bộ bút của cuộn tranh: hai người đối mặt, hai rồng mực gặp nhau ở dấu son giữa.
#   Godot --path . thumb.tscn   → ../thumb/thumb-godot.png (1920×1080, pack.mjs thu về 1280×720)
extends Node2D

var n := 0

func _process(_d: float) -> void:
	n += 1
	queue_redraw()
	if n == 4:
		var img := get_viewport().get_texture().get_image()
		img.save_png(ProjectSettings.globalize_path("res://").path_join("../thumb/thumb-godot.png"))
		get_tree().quit()

func _draw() -> void:
	draw_rect(Rect2(0, 0, 1920, 1080), But.GIAY)
	Canh.troi(self, 0, 1920, Color("8a96a8"), 0.25, 0, 700)
	But.nui(self, 0, 1920, 860, 380, 61.0, Color("8a8d90"), 1.0, 4.0)
	But.loang(self, Vector2(1450, 620), 700, 520, Color("1b1712"), 3.0, 0.10)
	But.loang(self, Vector2(470, 620), 700, 520, Color("2b3a4a"), 4.0, 0.12)
	# hai rồng gặp nhau giữa
	But.rong(self, Canh.rong_path(Vector2(1000, 330), Vector2(1, -0.25), 1300, 0.6, 60, 40, 1.4), 120, But.MUC, 1.0, 0.6, 1.0)
	But.rong(self, Canh.rong_path(Vector2(920, 350), Vector2(-1, -0.25), 1300, 0.6, 60, 40, 1.4), 110, Color("2b3a4a"), 1.0, 0.6, 2.0)
	for k in 3:
		Canh.vong(self, Vector2(960, 340), 90 + k * 70, 10.0, 0.5 - k * 0.12, k, 0.7)
	# hai người, mặt thoáng
	Nguoi.ve(self, "tieu", Vector2(1530, 1330), 3.3, {"face": -1, "aF": 1.3, "eF": 0.3, "aB": 0.4, "palmF": true, "stride": 0.4, "lean": -0.08}, "quyet-tam", 0.6, 1.0)
	Nguoi.ve(self, "quach", Vector2(390, 1330), 3.2, {"face": 1, "aF": 1.3, "eF": 0.3, "aB": 0.4, "palmF": true, "stride": 0.4, "lean": 0.08}, "quyet-tam", 0.6, 1.0)
	# chữ
	_vien("TIÊU PHONG", Vector2(1530, 150), 92, But.MUC)
	_vien("QUÁCH TĨNH", Vector2(390, 150), 92, Color("2b3a4a"))
	_vien("AI MẠNH HƠN ?", Vector2(960, 1010), 120, But.SON)

func _vien(s: String, at: Vector2, size: int, col: Color) -> void:
	for o in [Vector2(-5, 0), Vector2(5, 0), Vector2(0, -5), Vector2(0, 5), Vector2(-4, -4), Vector2(4, 4), Vector2(-4, 4), Vector2(4, -4)]:
		But.chu(self, s, at + o, size, But.GIAY, 1)
	But.chu(self, s, at, size, col, 1)
