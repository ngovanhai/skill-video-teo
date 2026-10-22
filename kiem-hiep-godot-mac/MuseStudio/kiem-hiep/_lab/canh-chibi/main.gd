extends Node
# godot --path . -- --canh rung_truc [--rec out.mp4 N]   (canh/<tên>.gd kế thừa canh.gd)

func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	var i := args.find("--canh")
	var id: String = args[i + 1] if i >= 0 else "rung_truc"
	add_child(load("res://canh/%s.gd" % id).new())
