extends Node2D
# Chạy: Godot --path godot res://xem/host.tscn -- --canh=quan --at=1,2,3 --out=../work/xem
var sc: Node
var shots: Array = []
var out := ""
var name_ := ""
var zoom_ := false
var kid := ""
var mode := ""
var abs_ := false


func _ready() -> void:
	var canh := "cast"
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--canh="):
			canh = a.substr(7)
		elif a.begins_with("--at="):
			for s in a.substr(5).split(","):
				shots.append(float(s))
		elif a == "--zoom":
			zoom_ = true
		elif a.begins_with("--kid="):
			kid = a.substr(6)
		elif a.begins_with("--m="):
			mode = a.substr(4)
		elif a == "--abs":
			abs_ = true
		elif a.begins_with("--out="):
			out = a.substr(6)
	if shots.is_empty():
		shots = [1.0]
	name_ = canh
	var vp := SubViewport.new()
	vp.size = Vector2i(1920, 1080)
	vp.use_hdr_2d = true
	vp.own_world_3d = true
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	add_child(vp)
	if canh.begins_with("canh/"):
		# cảnh thật: giờ câu lấy từ timeline.json, --kid=k01 --m=ghe; --abs = --at tính theo giờ tập
		sc = load("res://%s.gd" % canh).new()
		var tl: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://timeline.json"))
		var lt := {}
		var le := {}
		for l in tl.cau:
			lt[l.id] = float(l.t0)
			le[l.id] = float(l.t0) + float(l.dur)
		var t0 := 0.0
		var t1 := 0.0
		for k in tl.khung:
			if k.id == kid:
				t0 = float(k.t0)
				t1 = float(k.t1)
		if kid == "k10":
			t0 = 518.2
		sc.T0 = t0
		sc.line_t0 = lt
		sc.line_end = le
		sc.arg = {"m": mode, "lan": 0, "kid": kid, "dur": t1 - t0}
		if abs_:
			for i in shots.size():
				shots[i] = float(shots[i]) - t0
		name_ = canh.substr(5) + "-" + kid
	else:
		sc = load("res://xem/%s.gd" % canh).new()
		sc.arg = {"zoom": zoom_}
	vp.add_child(sc)
	DirAccess.make_dir_recursive_absolute(out)
	for i in shots.size():
		var at: float = shots[i]
		sc.tua(at)
		await RenderingServer.frame_post_draw
		await RenderingServer.frame_post_draw
		var img := vp.get_texture().get_image()
		img.convert(Image.FORMAT_RGB8)
		img.save_png("%s/%s-%02d.png" % [out, name_, i])
	get_tree().quit()
