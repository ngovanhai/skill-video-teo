extends Node
# Chọn chiêu: godot --path . -- --move hang_long [--rec out.mp4 N]   (moves/<tên>.gd kế thừa engine.gd)

func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	var i := args.find("--move")
	var mv: String = args[i + 1] if i >= 0 else "hang_long"
	var n: Node = load("res://moves/%s.gd" % mv).new()
	add_child(n)
