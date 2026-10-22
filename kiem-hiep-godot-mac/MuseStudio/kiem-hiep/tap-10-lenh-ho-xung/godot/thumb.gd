extends Node2D
# Ảnh bìa: dựng canh/bia.gd trong SubViewport HDR 1920×1080, chụp rồi lưu thumb/thumb-godot.png (chạy có cửa sổ).


func _ready() -> void:
	var vp := SubViewport.new()
	vp.size = Vector2i(1920, 1080)
	vp.use_hdr_2d = true
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(vp)
	var sc: Node = load("res://canh/bia.gd").new()
	sc.arg = {"m": "", "lan": 0, "kid": "bia", "dur": 2.0}
	vp.add_child(sc)
	sc.tua(1.0)
	for i in 3:
		await RenderingServer.frame_post_draw
	var img := vp.get_texture().get_image()
	img.convert(Image.FORMAT_RGB8)
	var out := ProjectSettings.globalize_path("res://").path_join("../thumb")
	DirAccess.make_dir_recursive_absolute(out)
	img.save_png(out.path_join("thumb-godot.png"))
	print("thumb: ", out.path_join("thumb-godot.png"))
	get_tree().quit()
