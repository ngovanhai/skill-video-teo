extends Node
# Bộ ghi khung thay Movie Maker: mỗi khung đọc ảnh viewport (khung vừa vẽ xong ở vòng trước),
# đẩy RGB thô qua pipe sang ffmpeg nén bằng GPU (h264_amf). Movie Maker nén MJPEG trên CPU nên chậm.
# Dùng: godot --path . --disable-vsync --fixed-fps 30 -- --rec out.mp4 <số khung>

var pipe: FileAccess
var pid := -1
var n := 0
var total := 0


func _ready() -> void:
	process_priority = -100
	var args := OS.get_cmdline_user_args()
	var i := args.find("--rec")
	if i < 0:
		set_process(false)
		return
	var out: String = args[i + 1]
	total = int(args[i + 2])
	# x264 veryfast: AMF nhanh ngang nhưng rơi mất vài khung cuối khi đóng pipe
	var enc := ["-c:v", "libx264", "-preset", "veryfast", "-crf", "18"]
	var a := ["-v", "error", "-y", "-f", "rawvideo", "-pix_fmt", "rgb24", "-s", "1920x1080", "-r", "30", "-i", "-"]
	a.append_array(enc)
	a.append_array(["-pix_fmt", "yuv420p", out])
	var res := OS.execute_with_pipe("ffmpeg", a, false)
	pipe = res["stdio"]
	pid = res["pid"]


func _process(_d: float) -> void:
	if n > 0:
		var img := get_viewport().get_texture().get_image()
		if img.get_format() != Image.FORMAT_RGB8:
			img.convert(Image.FORMAT_RGB8)
		pipe.store_buffer(img.get_data())
	n += 1
	if n > total:
		pipe.close()
		while OS.is_process_running(pid):
			OS.delay_msec(20)
		get_tree().quit()
