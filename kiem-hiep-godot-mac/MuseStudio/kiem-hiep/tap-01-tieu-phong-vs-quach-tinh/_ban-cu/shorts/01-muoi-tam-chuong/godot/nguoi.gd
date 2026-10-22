# Người trong cuộn tranh tập 01: thân vẽ bằng nét cọ + màu nước, đầu là texture xuất từ ve.mjs của tập (gd-mat.mjs).
# ve(c, key, feet, s, pose, expr, t): feet = điểm giữa hai bàn chân; s = tỉ lệ (1 ≈ cao 420px); pose là Dictionary:
#   face (1 nhìn phải / -1 nhìn trái), lean (rad, + cúi về trước), crouch 0..1, stride 0..1, lift (nhảy, px),
#   aF/eF, aB/eB: góc vai/khuỷu tay trước/sau (rad, 0 = buông thẳng, + giơ về phía trước), palmF/palmB (bàn tay xoè chưởng),
#   prop: "gay" | "gay-xanh" | "cung" | "but" | "kim-dao" | "ho-lo" | "" ; robe: màu áo (mặc định theo cast); talk: đang nói
class_name Nguoi

static var _tex := {}
static var _meta := {}

static func meta() -> Dictionary:
	if _meta.is_empty():
		_meta = JSON.parse_string(FileAccess.get_file_as_string("res://mat/mat.json"))
	return _meta

static func tex(key: String, name: String) -> Texture2D:
	var k := key + "/" + name
	if not _tex.has(k):
		_tex[k] = load("res://mat/%s.svg" % k)
	return _tex[k]

static func robe_of(key: String) -> Color:
	var c = meta().cast.get(key, {}).get("robe", null)
	return Color(c) if c != null else Color("5c6b7a")

# điểm khớp tay
static func _arm(sh: Vector2, a: float, e: float, l1 := 60.0, l2 := 54.0) -> Array:
	var el := sh + Vector2(sin(a), cos(a)) * l1
	var hd := el + Vector2(sin(a + e), cos(a + e)) * l2
	return [sh, el, hd]

static func ve(c: CanvasItem, key: String, feet: Vector2, s: float, pose := {}, expr := "binh", t := 0.0, alpha := 1.0) -> void:
	var face: float = pose.get("face", 1.0)
	var lean: float = pose.get("lean", 0.0)
	var crouch: float = pose.get("crouch", 0.0)
	var stride: float = pose.get("stride", 0.0)
	var lift: float = pose.get("lift", 0.0)
	var robe: Color = pose.get("robe", robe_of(key))
	var ink := But.ca(But.MUC, alpha)
	var fill := But.ca(robe.lerp(But.GIAY, 0.12), 0.94 * alpha)
	var dark := But.ca(robe.darkened(0.35), 0.5 * alpha)
	var skin := But.ca(Color(meta().cast.get(key, {}).get("skin", "#FBD3B0")), alpha)
	var seed := float(key.hash() % 1000)
	c.draw_set_transform(feet + Vector2(0, -lift * s), 0.0, Vector2(s * face, s))
	# bóng đất
	c.draw_colored_polygon(But.blob_pts(Vector2(0, 4 + lift), 70 - minf(lift, 60) * 0.5, 9, seed, 0.15, 24), But.ca(But.MUC, 0.12 * alpha))
	var hipY := -150.0 + crouch * 46.0
	var hip := Vector2(0, hipY)
	var rot := func(p: Vector2) -> Vector2: return hip + (p - hip).rotated(lean)
	# chân (thấy dưới vạt áo)
	var fF := Vector2(18 + stride * 46, 0); var fB := Vector2(-18 - stride * 40, 0)
	var kneeOut := crouch * 30.0
	for f in [fB, fF]:
		var top: Vector2 = Vector2(f.x * 0.35, hipY + 40)
		var knee: Vector2 = (top + f) * 0.5 + Vector2(kneeOut * signf(f.x + 0.01), -10)
		But.net(c, PackedVector2Array([top, knee, f + Vector2(0, -12)]), 30, But.ca(robe.darkened(0.45), alpha), 1.0, 0.0, 0.1, 0.1, seed)
		c.draw_colored_polygon(PackedVector2Array([f + Vector2(-16, -16), f + Vector2(24, -12), f + Vector2(30, 2), f + Vector2(-16, 3)]), ink)
	# vạt áo + thân
	var sw := sin(t * 2.3 + seed) * 4.0 + stride * 10.0
	var shL: Vector2 = rot.call(Vector2(-46, -236)); var shR: Vector2 = rot.call(Vector2(46, -236))
	var wL: Vector2 = rot.call(Vector2(-40, hipY + 4)); var wR: Vector2 = rot.call(Vector2(40, hipY + 4))
	var hemY := -34.0 + crouch * 10.0
	var body := PackedVector2Array([shL, rot.call(Vector2(0, -244)), shR, wR, Vector2(64 + stride * 26 + sw, hemY), Vector2(20, hemY + 8), Vector2(-20, hemY + 6), Vector2(-62 - stride * 20 + sw * 0.5, hemY)])
	# tay sau (vẽ trước thân)
	var aB: float = pose.get("aB", -0.12); var eB: float = pose.get("eB", 0.25)
	var armB := _arm(rot.call(Vector2(-38, -228)), aB, eB)
	_sleeve(c, armB, fill.darkened(0.12), ink, skin, pose.get("palmB", false), s)
	c.draw_colored_polygon(body, fill)
	# mảng loang tối một bên thân
	c.draw_colored_polygon(PackedVector2Array([shL, rot.call(Vector2(-6, -240)), rot.call(Vector2(-10, hipY)), Vector2(-14, hemY + 6), Vector2(-62 - stride * 20 + sw * 0.5, hemY), wL]), dark)
	var outline := body.duplicate(); outline.append(body[0])
	But.net(c, outline, 5.0, ink, 1.0, 0.02, 0.02, 0.35, seed)
	# cổ áo chữ V + đai
	But.net(c, PackedVector2Array([rot.call(Vector2(-24, -240)), rot.call(Vector2(4, -196)), rot.call(Vector2(26, -238))]), 4.0, ink, 1.0, 0.1, 0.1, 0.2, seed + 3)
	var belt := Color(pose.get("belt", "#3b2a1a"))
	But.net(c, PackedVector2Array([rot.call(Vector2(-43, hipY - 6)), rot.call(Vector2(0, hipY - 2)), rot.call(Vector2(43, hipY - 6))]), 16, But.ca(belt, alpha), 1.0, 0.05, 0.05, 0.15, seed + 5)
	# đầu
	var neck: Vector2 = rot.call(Vector2(0, -232))
	var hs := 0.34
	var nm: Array = meta().neck
	var name := expr
	var bl := fposmod(t + h1k(seed) * 3.0, 3.7)
	var talk: bool = pose.get("talk", false)
	if expr != "ko" and bl < 0.13: name = "blink"
	elif talk and fposmod(t * 7.3 + seed, 2.0) < 1.0 + 0.6 * (But.n1(t * 5.0) - 0.5): name = expr + "-mo"
	var tx := tex(key, name)
	c.draw_set_transform(feet + Vector2(0, -lift * s) + Vector2(neck.x * s * face, neck.y * s), lean * face * 0.6, Vector2(s * face * hs, s * hs))
	c.draw_texture(tx, Vector2(-nm[0], -nm[1]), Color(1, 1, 1, alpha))
	c.draw_set_transform(feet + Vector2(0, -lift * s), 0.0, Vector2(s * face, s))
	# tay trước + đồ cầm
	var aF: float = pose.get("aF", 0.15); var eF: float = pose.get("eF", 0.3)
	var armF := _arm(rot.call(Vector2(38, -228)), aF, eF)
	var prop: String = pose.get("prop", "")
	if prop != "": _prop(c, prop, armF[2], aF + eF, alpha, t)
	_sleeve(c, armF, fill, ink, skin, pose.get("palmF", false), s)
	c.draw_set_transform(Vector2.ZERO)

static func h1k(x: float) -> float: return But.h1(x)

static func _sleeve(c: CanvasItem, arm: Array, fill: Color, ink: Color, skin: Color, palm: bool, s: float) -> void:
	var path := But.qd(arm[0], arm[1], arm[2], 10)
	But.net(c, path, 42, ink, 1.0, 0.05, 0.02, 0.1)
	But.net(c, path, 34, fill, 1.0, 0.05, 0.02, 0.1)
	var hd: Vector2 = arm[2]
	var dir: Vector2 = (arm[2] - arm[1]).normalized()
	if palm:
		var pp := PackedVector2Array()
		for i in 12:
			var a := TAU * i / 12.0
			pp.append(hd + dir * 12 + Vector2(cos(a) * 16, sin(a) * 12).rotated(dir.angle()))
		c.draw_colored_polygon(pp, skin)
		pp.append(pp[0]); But.net(c, pp, 3.0, ink, 1.0, 0.0, 0.0, 0.1)
	else:
		c.draw_circle(hd + dir * 8, 12, skin)
		c.draw_arc(hd + dir * 8, 12, 0, TAU, 16, ink, 3.0)

static func _prop(c: CanvasItem, prop: String, hd: Vector2, ang: float, alpha: float, t: float) -> void:
	var ink := But.ca(But.MUC, alpha)
	match prop:
		"gay", "gay-xanh":
			var col := Color("4f8a3c") if prop == "gay-xanh" else Color("7a5a34")
			var a := hd + Vector2(-10, -150); var b := hd + Vector2(8, 120)
			But.net(c, PackedVector2Array([a, b]), 12, ink, 1.0, 0.0, 0.0, 0.1)
			But.net(c, PackedVector2Array([a, b]), 8, But.ca(col, alpha), 1.0, 0.0, 0.0, 0.1)
			for k in [0.25, 0.5, 0.75]: c.draw_line(a.lerp(b, k) + Vector2(-6, 0), a.lerp(b, k) + Vector2(6, 0), ink, 2.0)
		"but":   # bút lông to của Tèo
			var a := hd + Vector2(-6, -110); var b := hd + Vector2(6, 40)
			But.net(c, PackedVector2Array([a, b]), 12, But.ca(Color("8a5a34"), alpha), 1.0, 0.0, 0.0, 0.1)
			var tip := PackedVector2Array([b + Vector2(-9, 0), b + Vector2(9, 0), b + Vector2(2, 48)])
			c.draw_colored_polygon(tip, ink)
		"cung":
			var p := But.qd(hd + Vector2(-20, -110), hd + Vector2(40, 0), hd + Vector2(-20, 110), 16)
			But.net(c, p, 8, But.ca(Color("6b4a2b"), alpha), 1.0, 0.1, 0.1, 0.1)
			c.draw_line(hd + Vector2(-20, -110), hd + Vector2(-20, 110), But.ca(But.MUC, 0.6 * alpha), 1.5)
		"kim-dao":
			var a := hd + Vector2(0, -10); var b := hd + Vector2(70, -130)
			But.net(c, PackedVector2Array([a, b]), 14, But.ca(Color("d9a92a"), alpha), 1.0, 0.0, 0.5, 0.05)
			c.draw_line(a, a + (b - a) * 0.18, ink, 8.0)
		"ho-lo":
			c.draw_circle(hd + Vector2(-4, 34), 16, But.ca(Color("c98a3a"), alpha))
			c.draw_circle(hd + Vector2(-4, 6), 11, But.ca(Color("c98a3a"), alpha))
			c.draw_arc(hd + Vector2(-4, 34), 16, 0, TAU, 18, ink, 3.0)
