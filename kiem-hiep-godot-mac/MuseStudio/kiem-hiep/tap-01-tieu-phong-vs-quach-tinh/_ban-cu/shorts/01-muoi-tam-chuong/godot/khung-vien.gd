# Viền tối nhẹ quanh màn hình (vignette) như ánh đèn bàn vẽ.
extends ColorRect

func _ready() -> void:
	size = Vector2(1920, 1080)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	var sh := Shader.new()
	sh.code = """
shader_type canvas_item;
void fragment() {
	vec2 d = UV - vec2(0.5);
	d.x *= 1.5;
	float v = smoothstep(0.45, 0.95, length(d));
	COLOR = vec4(0.08, 0.05, 0.02, v * 0.55);
}
"""
	var m := ShaderMaterial.new(); m.shader = sh
	material = m
