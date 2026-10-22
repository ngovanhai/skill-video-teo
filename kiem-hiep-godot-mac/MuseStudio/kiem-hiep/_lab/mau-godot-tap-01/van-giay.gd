# Vân giấy (xơ giấy dó) phủ theo toạ độ thế giới, nhân màu.
extends ColorRect

func _ready() -> void:
	var sh := Shader.new()
	sh.code = """
shader_type canvas_item;
render_mode blend_mul;
varying vec2 wp;
void vertex() { wp = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy; }
float h(vec2 p) { return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453); }
float n(vec2 p) { vec2 i = floor(p); vec2 f = fract(p); f = f * f * (3.0 - 2.0 * f);
	return mix(mix(h(i), h(i + vec2(1, 0)), f.x), mix(h(i + vec2(0, 1)), h(i + vec2(1, 1)), f.x), f.y); }
void fragment() {
	float g = n(wp * 0.35) * 0.5 + n(wp * 0.08) * 0.3 + n(vec2(wp.x * 0.02, wp.y * 0.6)) * 0.2;
	float fib = smoothstep(0.82, 0.95, n(vec2(wp.x * 0.05 + wp.y * 0.01, wp.y * 0.9)));
	float v = 1.0 - 0.07 * g - 0.05 * fib;
	if (abs(wp.y) > 620.0) v = 1.0;
	COLOR = vec4(vec3(v), 1.0);
}
"""
	var m := ShaderMaterial.new(); m.shader = sh
	material = m
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _process(_d: float) -> void:
	var cam := get_viewport().get_camera_2d()
	if cam == null: return
	var sz := Vector2(1920, 1080) / cam.zoom + Vector2(200, 200)
	position = cam.position - sz * 0.5
	size = sz
