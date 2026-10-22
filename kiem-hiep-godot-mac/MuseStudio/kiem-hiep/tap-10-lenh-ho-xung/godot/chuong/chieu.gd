extends Node
# Cầu nối: chạy một chiêu của skill chuong-2d bên trong tập (gd-chieu.mjs chép vào godot/chuong/chieu.gd).
# Chiêu sống trong SubViewport riêng 1920×1080 (HDR 2D + glow như chuong-2d), vẽ ra texture để phim.gd đặt vào cảnh.
# Dựng theo t của tập: at(t) tua chiêu tới đúng bước (t - t0)·30; nhảy lùi thì dựng lại từ đầu. Engine chuong-2d tất định
# (DT cố định, rng seed 2026) nên --from / --par ra y hệt render liền một mạch.
# Project của tập phải chạy forward_plus (gd-chieu tự đổi), gl_compatibility làm lệch màu so với chuong-2d.
#
#   var ch = preload("res://chuong/chieu.gd").new("can_khon", 312.0)   # chiêu bắt đầu ở giây 312 của tập
#   ch.vars = {"subtitle": ""}                                           # (tuỳ) đè biến của chiêu sau _setup
#   add_child(ch)
#   sfx():   trả thêm ch.sfx()                       → [[giây tập, tên, dB]] theo định dạng main.gd
#   mỗi khung: if ch.at(t): draw_texture_rect(ch.tex(), Rect2(...), false)

const FPS := 30.0
var move := ""
var t0 := 0.0
var length := 12.5          # giây thật của clip (chuong-2d: 11.5–13 s)
var gain_db := -8.0         # cộng vào âm lượng sfx của chiêu: chuong-2d để vol 1.0 = 0 dB, tập để sfx quanh -8 dB (không đè giọng)
var vars := {}
var vp: SubViewport
var mv: Node = null
var done := 0               # số bước _process đã chạy


func _init(m: String, start: float, len := 12.5) -> void:
	move = m
	t0 = start
	length = len


func _ready() -> void:
	vp = SubViewport.new()
	vp.size = Vector2i(1920, 1080)
	vp.use_hdr_2d = true
	vp.own_world_3d = true          # glow của chiêu chỉ ăn trong viewport này
	vp.msaa_2d = Viewport.MSAA_2X
	vp.render_target_update_mode = SubViewport.UPDATE_DISABLED
	add_child(vp)


func _spawn(hook: Callable) -> Node:
	var n: Node = load("res://chuong/moves/%s.gd" % move).new()
	n.sfx_hook = hook
	vp.add_child(n)                 # _ready của engine chạy ở đây (_setup của chiêu)
	n.set_process(false)            # bước do at() điều khiển
	for k in vars:
		n.set(k, vars[k])
	return n


func _quiet(_n: String, _rt: float, _v: float) -> void:
	pass


func tex() -> ViewportTexture:
	return vp.get_texture()


# true khi t nằm trong clip (đã tua xong, khung này có hình)
func at(t: float) -> bool:
	var k := int(floor((t - t0) * FPS + 0.5))
	if k < 0 or t - t0 >= length:
		if mv:
			mv.queue_free()
			mv = null
			done = 0
		vp.render_target_update_mode = SubViewport.UPDATE_DISABLED
		return false
	# khung k của clip = sau k+1 bước (như chuong-2d chạy độc lập: _ready rồi _process rồi vẽ)
	if mv == null or k + 1 < done:
		if mv:
			mv.free()
		mv = _spawn(_quiet)
		done = 0
	while done < k + 1:
		mv._process(0.0)
		done += 1
	vp.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	return true


# chạy trước một lượt (không vẽ) để lấy mốc sfx, đổi ra giây của tập
func sfx() -> Array:
	var out: Array = []
	var dt := 1.0 / FPS
	var n := _spawn(func(nm: String, rt: float, v: float) -> void:
		out.append([t0 + rt - dt, nm.trim_prefix("lib-"), 20.0 * log(maxf(v, 0.001)) / log(10.0) + gain_db]))
	for i in int(length * FPS):
		n._process(0.0)
	n.free()
	return out
