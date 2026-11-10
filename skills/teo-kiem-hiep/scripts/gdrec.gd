extends Node
# Bộ ghi của gd-render (thay Movie Maker). gd-render chép file này vào project của tập thành res://_gdrec.gd
# và nạp nó làm autoload qua override.cfg, nên project của tập không phải sửa gì.
#   -- --gdrec-plan=<file.json>   chạy 1 khung: đọc giọng/nhạc/sfx của main scene (lines, cues, nhac…) ghi ra json rồi thoát
#   -- --gdrec=<out.mkv> --gdrec-n=<số khung> --gdrec-ff=<ffmpeg> --gdrec-size=WxH --gdrec-x264=<preset>,<crf> [--gdrec-fit]
#      mỗi khung đọc ảnh viewport (khung vừa vẽ xong ở vòng trước) đẩy RGBA thô qua pipe sang ffmpeg (libx264).
#      Khung k của video = giờ from + k/30. --gdrec-fit: vẽ ở đúng WxH dù cửa sổ nhỏ hơn màn hình (bản cuối, short dọc).
# Không có tham số --gdrec* thì node này không làm gì.

var mode := ""
var out := ""
var ff := "ffmpeg"
var total := 0
var W := 0
var H := 0
var preset := "medium"
var crf := "18"
var pipe: FileAccess
var pid := -1
var n := 0
var warned := false


func _ready() -> void:
	process_priority = -100000
	process_mode = Node.PROCESS_MODE_ALWAYS
	var fit := false
	for a in OS.get_cmdline_user_args():
		if a.begins_with("--gdrec-plan="):
			mode = "plan"; out = a.substr(13)
		elif a.begins_with("--gdrec="):
			mode = "rec"; out = a.substr(8)
		elif a.begins_with("--gdrec-n="):
			total = int(a.substr(10))
		elif a.begins_with("--gdrec-ff="):
			ff = a.substr(11)
		elif a.begins_with("--gdrec-size="):
			var s := a.substr(13).split("x")
			W = int(s[0]); H = int(s[1])
		elif a.begins_with("--gdrec-x264="):
			var p := a.substr(13).split(",")
			preset = p[0]; crf = p[1]
		elif a == "--gdrec-fit":
			fit = true
	if mode == "":
		set_process(false)
		return
	if mode == "rec" and fit and W > 0:
		# vẽ ở đúng WxH, cửa sổ chỉ là chỗ hiển thị (màn hình nhỏ hơn khung vẫn ra đủ phân giải)
		var win := get_window()
		win.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
		win.content_scale_aspect = Window.CONTENT_SCALE_ASPECT_KEEP
		win.content_scale_size = Vector2i(W, H)


func _process(_d: float) -> void:
	if mode == "plan":
		_plan()
		get_tree().quit()
		set_process(false)
		return
	if n > 0:
		_grab()
	n += 1
	if n > total:
		_finish()
		get_tree().quit()
		set_process(false)


func _grab() -> void:
	var img := get_viewport().get_texture().get_image()
	if img.get_format() != Image.FORMAT_RGBA8:
		img.convert(Image.FORMAT_RGBA8)
	if W > 0 and (img.get_width() != W or img.get_height() != H):
		if not warned:
			printerr("gdrec: khung %dx%d khác %dx%d, thu phóng lại" % [img.get_width(), img.get_height(), W, H])
			warned = true
		img.resize(W, H, Image.INTERPOLATE_BILINEAR)
	if pipe == null:
		var a := ["-v", "error", "-y", "-f", "rawvideo", "-pix_fmt", "rgba", "-s", "%dx%d" % [img.get_width(), img.get_height()], "-r", "30", "-i", "-",
			"-c:v", "libx264", "-preset", preset, "-crf", crf, "-pix_fmt", "yuv420p", out]
		var res := OS.execute_with_pipe(ff, a, true)  # pipe chặn: không chặn thì macOS rơi khung khi bộ đệm pipe đầy
		if res.is_empty():
			printerr("gdrec: không chạy được ffmpeg (%s)" % ff)
			get_tree().quit(1)
			return
		pipe = res["stdio"]
		pid = res["pid"]
	pipe.store_buffer(img.get_data())


func _finish() -> void:
	if pipe == null:
		return
	pipe.close()
	pipe = null
	while OS.is_process_running(pid):
		OS.delay_msec(20)


func _exit_tree() -> void:
	_finish()


func _plan() -> void:
	var m: Node = get_tree().current_scene
	var o := {"ok": false}
	if m == null or m.get("lines") == null or m.get("cues") == null:
		o["err"] = "main scene không có biến lines/cues (main.gd của new-tap.mjs)"
	else:
		o["ok"] = true
		o["fps"] = m.get("FPS") if m.get("FPS") != null else 30.0
		o["dur"] = m.get("DUR")
		var ls := []
		for l in m.lines:
			ls.append({"id": l.id, "t0": l.t0, "dur": l.dur})
		o["lines"] = ls
		o["cues"] = m.cues
		var vo: AudioStreamPlayer = m.get("vo")
		o["vo_db"] = vo.volume_db if vo else 0.0
		var pool = m.get("sfx_pool")
		o["sfx_ch"] = pool.size() if pool else 6
		var nh: AudioStreamPlayer = m.get("nhac")
		if nh and nh.stream:
			var lp = nh.stream.get("loop")
			o["nhac"] = {"path": ProjectSettings.globalize_path(nh.stream.resource_path), "db": nh.volume_db, "loop": lp == true}
	var f := FileAccess.open(out, FileAccess.WRITE)
	f.store_string(JSON.stringify(o))
	f.close()
