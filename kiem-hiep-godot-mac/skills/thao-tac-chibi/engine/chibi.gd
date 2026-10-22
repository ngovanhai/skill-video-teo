extends Node2D
# Nhân vật chibi rig2 dựng từ chars/<id>.json (tools/export-chars.mjs): mỗi khớp một Node2D, mảnh SVG rasterize lúc chạy.
# Gốc node = điểm chân chạm đất. Góc khớp theo độ, dương = thuận kim đồng hồ (giống POSES của teo-kiem-hiep/moves2.mjs).
# Tay F (x=+50) là tay phía đối thủ; quay mặt trái thì scale.x = -1.
# Tay chân v2: vẽ thủ tục mỗi khung — ống cong liền mạch (Chaikin qua vai/khuỷu/cổ tay), tay áo loe, ống quần,
# bàn tay 4 dạng (tha | nam | xoe | chi). Vật cầm kẹp giữa lòng bàn tay và ngón tay. v1 = mảnh SVG cứng (V2_DEFAULT=false).

const RS := 1.6          # hệ số rasterize SVG (nét vẫn sắc khi camera zoom ~1.5)
const FEET := 548.0
const HIP := 430.0

const POSES := {
	"rest": {"uaF": 6, "faF": 0, "uaB": -6, "faB": 0, "head": 0, "torso": 0, "thF": 0, "shF": 0, "thB": 0, "shB": 0, "ftF": 0, "ftB": 0, "all": [0, 0, 0]},
	"stance": {"uaF": -40, "faF": -70, "uaB": 30, "faB": -60, "torso": 3, "head": 2, "thF": -18, "shF": 22, "thB": 18, "shB": -22, "all": [0, 0, 10]},
	"charge": {"uaF": 28, "faF": -115, "uaB": -28, "faB": 115, "torso": 0, "head": -3, "thF": -30, "shF": 36, "thB": 30, "shB": -36, "all": [0, 0, 22]},
	"palm": {"uaF": -92, "faF": -8, "uaB": -72, "faB": -26, "torso": -8, "head": -4, "thF": -34, "shF": 26, "thB": 30, "shB": -8, "all": [-4, 16, 14]},
	"point": {"uaF": -88, "faF": -6, "uaB": 40, "faB": -80, "torso": -4, "head": -3, "thF": -16, "shF": 18, "thB": 16, "shB": -16, "all": [0, 0, 8]},
	"raise": {"uaF": -165, "faF": -8, "uaB": 165, "faB": 8, "torso": 6, "head": 4, "thF": -10, "shF": 16, "thB": 10, "shB": -16, "all": [0, 0, 12]},
	"windup": {"uaF": -205, "faF": -40, "uaB": 40, "faB": -30, "torso": 10, "head": 6, "thF": -14, "shF": 20, "thB": 12, "shB": -18, "all": [0, -10, 14]},
	"slash": {"uaF": -55, "faF": 10, "uaB": 30, "faB": 10, "torso": -16, "head": -8, "thF": -46, "shF": 34, "thB": 28, "shB": -8, "all": [0, 44, 22]},
	"guard": {"uaF": -70, "faF": -95, "uaB": 36, "faB": -70, "torso": 4, "head": 2, "thF": -12, "shF": 16, "thB": 14, "shB": -16, "all": [0, 0, 8]},
	"fly": {"uaF": -150, "faF": -30, "uaB": 150, "faB": 30, "torso": 14, "head": 18, "thF": 30, "shF": 30, "thB": -20, "shB": 40, "all": [0, 0, 0]},
	"kneel": {"uaF": -20, "faF": -60, "uaB": 10, "faB": -20, "torso": 18, "head": 14, "thF": -80, "shF": 80, "thB": 40, "shB": 50, "all": [0, 0, 70]},
	"run": {"uaF": -60, "faF": -40, "uaB": 50, "faB": -40, "torso": -12, "head": -6, "thF": -40, "shF": 40, "thB": 30, "shB": 20, "all": [0, 0, 12]},
}

static var cache := {}   # id -> {segs: [[tex, off]], faces: {expr: {idx: [tex, off]}}, data}
static var V2_DEFAULT := true

const SHOULDER := Vector2(50, -94)   # vai thụt vào trong viền thân
const L_UA := 52.0
const L_FA := 52.0
const MAX_STR := 0.18                # tay giãn tối đa 18% khi với quá tầm (key pose "strF"/"strB")

var J := {}
var rest := {}
var head_spr := {}
var faces := {}
var expr := ""
var t := 0.0
var sway := 1.0

var v2 := true
var hand_form := {"F": "tha", "B": "tha"}
var limb_col := {}
var spr_of := {}
var dnodes: Array = []
var palm_node := {}
var cloth := {}          # vạt áo v2: side -> [a1, v1, a2, v2] (rad, + = về phía trước, hệ toạ độ nhân vật)
var one_arm := false     # nhân vật cụt tay (look.oneArm): không có khớp uaB → dựng khớp ảo, vẽ tay áo rỗng
var move_v := 0.0        # tốc độ đi (px/s, + = hướng mặt) — vạt bị gió cản ngược lại


static func _raster(defs: String, view: Array, body: String) -> Array:
	var doc := '<svg xmlns="http://www.w3.org/2000/svg" viewBox="%d %d %d %d" width="%d" height="%d">%s%s</svg>' % [view[0], view[1], view[2], view[3], view[2], view[3], defs, body]
	var img := Image.new()
	img.load_svg_from_string(doc, RS)
	var used := img.get_used_rect()
	if used.size.x <= 0:
		return [null, Vector2.ZERO]
	var reg := img.get_region(used)
	reg.generate_mipmaps()
	var tex := ImageTexture.create_from_image(reg)
	return [tex, Vector2(used.position)]


static func _load(id: String) -> Dictionary:
	if cache.has(id):
		return cache[id]
	var d: Dictionary = JSON.parse_string(FileAccess.get_file_as_string("res://chars/%s.json" % id))
	var segs := []
	for s in d.segs:
		segs.append(_raster(d.defs, d.view, s.svg))
	var fc := {}
	for e in d.faces:
		fc[e] = {}
		for pair in d.faces[e]:
			fc[e][int(pair[0])] = _raster(d.defs, d.view, pair[1])
	var c := {"segs": segs, "faces": fc, "data": d}
	cache[id] = c
	return c


func setup(id: String) -> void:
	v2 = V2_DEFAULT
	var c := _load(id)
	var d: Dictionary = c.data
	faces = c.faces
	for j in d.joints:
		var n := Node2D.new()
		n.name = j.name
		J[j.name] = n
		rest[j.name] = Vector2(j.pos[0], j.pos[1])
		n.position = rest[j.name]
	rest["all"] = Vector2(0, HIP - FEET)
	J["all"].position = rest["all"]
	for j in d.joints:
		var n: Node2D = J[j.name]
		for o in j.order:
			if o.has("joint"):
				n.add_child(J[o.joint])
			else:
				var idx := int(o.seg)
				var r: Array = c.segs[idx]
				if r[0] == null:
					continue
				var sp := Sprite2D.new()
				sp.centered = false
				sp.texture = r[0]
				sp.offset = r[1]
				sp.scale = Vector2.ONE / RS
				sp.position = Vector2(d.view[0], d.view[1])
				n.add_child(sp)
				if not spr_of.has(j.name):
					spr_of[j.name] = []
				spr_of[j.name].append([sp, String(d.segs[idx].svg)])
				if j.name == "head":
					head_spr[idx] = sp
	if not J.has("uaB") and J.has("torso"):
		one_arm = true
		var par: Node2D = J["torso"]
		for jn in ["uaB", "faB", "hdB"]:
			var n := Node2D.new()
			n.name = jn
			J[jn] = n
			rest[jn] = Vector2.ZERO
			par.add_child(n)
			par = n
	add_child(J["all"])
	set_expr("binh")
	if v2:
		_limbs_v2()


func set_expr(e: String) -> void:
	if e == expr or not faces.has(e):
		return
	expr = e
	for idx in faces[e]:
		if head_spr.has(idx):
			var r: Array = faces[e][idx]
			head_spr[idx].texture = r[0]
			head_spr[idx].offset = r[1]


static func mix(a: Dictionary, b: Dictionary, k: float) -> Dictionary:
	var o := a.duplicate()
	for key in b:
		var va = a.get(key, POSES.rest.get(key, 0))
		var vb = b[key]
		if vb is Array:
			var aa: Array = va if va is Array else [0, 0, 0]
			o[key] = [lerpf(aa[0], vb[0], k), lerpf(aa[1], vb[1], k), lerpf(aa[2], vb[2], k)]
		else:
			o[key] = lerpf(float(va), float(vb), k)
	return o


static func P(name: String) -> Dictionary:
	return POSES.rest.duplicate() if name == "rest" else mix(POSES.rest, POSES[name], 1.0)


func apply(pose: Dictionary, dt: float) -> void:
	t += dt
	if v2:
		for sd in ["F", "B"]:
			var st := 1.0 + clampf(float(pose.get("str" + sd, 0.0)), 0.0, MAX_STR)
			J["fa" + sd].position = rest["fa" + sd] * st
			J["hd" + sd].position = rest["hd" + sd] * st
	for key in pose:
		if not J.has(key):
			continue
		var v = pose[key]
		if v is Array:
			J[key].rotation_degrees = v[0]
			J[key].position = rest[key] + Vector2(v[1], v[2])
		else:
			J[key].rotation_degrees = v
	# chuyển động phụ: thở + tóc/vạt/băng đô bay
	J["torso"].scale = Vector2(1.0, 1.0 + sin(t * 2.6) * 0.012)
	for pair in [["tail", 12.0, 7.0], ["hairB", 7.0, 6.0], ["flapB", 5.0, 5.0], ["flapF", 4.0, 5.5]]:
		if J.has(pair[0]):
			J[pair[0]].rotation_degrees = sin(t * pair[2]) * pair[1] * sway
	if v2:
		_skirt_step(dt)
	for n in dnodes:
		n.queue_redraw()


# vị trí lòng bàn tay (tay F / B) trong hệ toạ độ của node `space`
func hand(space: Node2D, side := "F") -> Vector2:
	var h: Node2D = J["hd" + side]
	return space.get_global_transform().affine_inverse() * (h.get_global_transform() * Vector2(0, 10))


func head_pos(space: Node2D) -> Vector2:
	return space.get_global_transform().affine_inverse() * (J["head"].get_global_transform() * Vector2(0, -90))


# ---------------------------------------------------------------- tay chân v2

func _limbs_v2() -> void:
	var re := RegEx.new()
	re.compile("(?:stroke|fill)=\"(#[0-9a-fA-F]{3,8})\"")
	for jn in ["uaF", "faF", "hdF", "uaB", "faB", "hdB", "thF", "shF", "thB", "shB"]:
		if not spr_of.has(jn):
			continue
		for pr in spr_of[jn]:
			var sp: Sprite2D = pr[0]
			var svg: String = pr[1]
			if svg.begins_with("<path d=\"M0 0 L0") or svg.begins_with("<circle cy=\"8\" r=\"13\""):
				sp.visible = false
				var m := re.search_all(svg)
				if m.size() >= 2:
					limb_col[jn] = [Color(m[0].get_string(1)), Color(m[1].get_string(1))]
	for sd in ["F", "B"]:       # vạt áo: mảnh svg (fill trước stroke) → [viền, nền]
		if spr_of.has("flap" + sd):
			for pr in spr_of["flap" + sd]:
				pr[0].visible = false
				var m := re.search_all(String(pr[1]))
				if m.size() >= 2:
					limb_col["flap" + sd] = [Color(m[1].get_string(1)), Color(m[0].get_string(1))]
	for sd in ["F", "B"]:       # bàn tay: svg ghi fill trước stroke → đảo về [viền, nền]
		if limb_col.has("hd" + sd):
			var hc: Array = limb_col["hd" + sd]
			limb_col["hd" + sd] = [hc[1], hc[0]]
	rest["uaF"] = SHOULDER
	rest["uaB"] = SHOULDER * Vector2(-1, 1)
	for sd in ["F", "B"]:
		rest["fa" + sd] = Vector2(0, L_UA)
		rest["hd" + sd] = Vector2(0, L_FA)
		for jn in ["ua", "fa", "hd"]:
			J[jn + sd].position = rest[jn + sd]
	var to: Node2D = J["torso"]
	var al: Node2D = J["all"]
	to.move_child(J["uaB"], 0)                     # tay sau: cả chuỗi khớp nằm sau thân
	_dnode(to, J["uaB"].get_index(), _draw_arm.bind("B"))
	_dnode(to, J["uaF"].get_index(), _draw_arm.bind("F"))
	_dnode(al, J["thB"].get_index(), _draw_leg.bind("B"))
	_dnode(al, J["thF"].get_index(), _draw_leg.bind("F"))
	if J.has("flapB"):
		_dnode(al, J["flapB"].get_index(), _draw_flap.bind("B"))
	if J.has("flapF"):
		_dnode(J["flapF"].get_parent(), J["flapF"].get_index(), _draw_flap.bind("F"))
	for sd in ["F", "B"]:
		var hd: Node2D = J["hd" + sd]
		palm_node[sd] = _dnode(hd, 0, _draw_palm.bind(sd))
		_dnode(hd, hd.get_child_count(), _draw_fingers.bind(sd))


func _dnode(parent: Node2D, idx: int, cb: Callable) -> Node2D:
	var n := Node2D.new()
	parent.add_child(n)
	parent.move_child(n, idx)
	n.draw.connect(func(): cb.call(n))
	dnodes.append(n)
	return n


# chỗ chèn vật cầm tay trong khớp hd: ngay trên lòng bàn tay, dưới ngón tay
func prop_slot(side: String) -> int:
	return palm_node[side].get_index() + 1 if v2 else 0


func shoulder(side: String) -> Vector2:
	var s := SHOULDER if v2 else Vector2(58, -98)
	return s if side == "F" else s * Vector2(-1, 1)


# [bắp tay, cẳng tay + lòng bàn tay]
func arm_len() -> Vector2:
	return Vector2(L_UA, L_FA + 10.0) if v2 else Vector2(56, 58)


static func chaikin(p: PackedVector2Array, it: int) -> PackedVector2Array:
	for k in it:
		var q := PackedVector2Array([p[0]])
		for i in p.size() - 1:
			q.append(p[i].lerp(p[i + 1], 0.25))
			q.append(p[i].lerp(p[i + 1], 0.75))
		q.append(p[p.size() - 1])
		p = q
	return p


func _lp(c: Node2D, n: Node2D, p := Vector2.ZERO) -> Vector2:
	return c.get_global_transform().affine_inverse() * (n.get_global_transform() * p)


# ống mềm: tròn tại mỗi điểm + đoạn thẳng AA, độ dày đổi dần
func _tube(c: Node2D, pts: PackedVector2Array, ws: PackedFloat32Array, col: Color, grow: float) -> void:
	for i in pts.size():
		c.draw_circle(pts[i], ws[i] * 0.5 + grow, col, true, -1.0, true)
	for i in pts.size() - 1:
		c.draw_line(pts[i], pts[i + 1], col, (ws[i] + ws[i + 1]) * 0.5 + grow * 2.0, true)


func _limb_pts(c: Node2D, a: Node2D, b: Node2D, e: Node2D) -> PackedVector2Array:
	return chaikin(PackedVector2Array([_lp(c, a), _lp(c, b), _lp(c, e)]), 3)


func _draw_arm(c: Node2D, sd: String) -> void:
	if one_arm and sd == "B":
		_draw_empty_sleeve(c)
		return
	var pts := _limb_pts(c, J["ua" + sd], J["fa" + sd], J["hd" + sd])
	var cl: Array = limb_col.get("fa" + sd if sd == "B" else "ua" + sd, [Color.BLACK, Color.GRAY])
	var n := pts.size()
	var ws := PackedFloat32Array()
	for i in n:
		var u := float(i) / float(n - 1)
		ws.append(27.0 + 3.0 * u + 9.0 * smoothstep(0.62, 1.0, u))   # tay áo loe dần về cổ tay
	_tube(c, pts, ws, cl[0], 2.6)
	_tube(c, pts, ws, cl[1], 0.0)
	# nếp gấp trong khuỷu khi gập rõ
	var sh := _lp(c, J["ua" + sd])
	var el := _lp(c, J["fa" + sd])
	var wr := _lp(c, J["hd" + sd])
	var bend := (el - sh).normalized().angle_to((wr - el).normalized())
	if absf(bend) > 0.9:
		var inner := ((sh - el).normalized() + (wr - el).normalized()).normalized()
		var p0 := el + inner * 4.0
		c.draw_line(p0, p0 + inner * 8.0 + inner.orthogonal() * 3.0, cl[0], 2.0, true)
	# viền cổ tay áo + miệng tay áo tối
	var d0 := (pts[n - 1] - pts[n - 3]).normalized()
	var nv := d0.orthogonal()
	var cw := ws[n - 1] * 0.5
	var cuff := pts[n - 1] - d0 * 8.0
	c.draw_line(cuff + nv * (cw - 1.0), cuff - nv * (cw - 1.0), cl[0], 2.4, true)
	c.draw_line(cuff + d0 * 3.0 + nv * (cw - 2.5), cuff + d0 * 3.0 - nv * (cw - 2.5), cl[1].lightened(0.3), 2.2, true)
	c.draw_colored_polygon(_ell(pts[n - 1], Vector2(cw * 0.3, cw - 3.0), d0.angle()), cl[0].darkened(0.2))


# tay áo rỗng của người cụt tay: buông rủ từ vai, đung đưa theo t
func _draw_empty_sleeve(c: Node2D) -> void:
	var cl: Array = limb_col.get("uaF", [Color.BLACK, Color.GRAY])
	var sh := _lp(c, J["uaB"])
	var sw := sin(t * 2.2) * 5.0 * sway
	var pts := chaikin(PackedVector2Array([sh, sh + Vector2(-4 + sw * 0.5, 40), sh + Vector2(-2 + sw, 78)]), 3)
	var n := pts.size()
	var ws := PackedFloat32Array()
	for i in n:
		var u := float(i) / float(n - 1)
		ws.append(26.0 - 12.0 * u)
	_tube(c, pts, ws, cl[0], 2.6)
	_tube(c, pts, ws, cl[1], 0.0)
	c.draw_line(pts[n / 2], pts[n - 1] + Vector2(3, -6), cl[0], 1.8, true)


func _draw_leg(c: Node2D, sd: String) -> void:
	var pts := _limb_pts(c, J["th" + sd], J["sh" + sd], J["ft" + sd])
	var cl: Array = limb_col.get("th" + sd, [Color.BLACK, Color.GRAY])
	var n := pts.size()
	var ws := PackedFloat32Array()
	for i in n:
		var u := float(i) / float(n - 1)
		ws.append(38.0 - 7.0 * u + 5.0 * smoothstep(0.8, 1.0, u))      # ống quần loe nhẹ ở cổ chân
	_tube(c, pts, ws, cl[0], 2.6)
	_tube(c, pts, ws, cl[1], 0.0)
	var d0 := (pts[n - 1] - pts[n - 3]).normalized()
	var nv := d0.orthogonal()
	var hem := pts[n - 1] - d0 * 5.0
	c.draw_line(hem + nv * (ws[n - 1] * 0.5 - 1.0), hem - nv * (ws[n - 1] * 0.5 - 1.0), cl[0], 2.2, true)


# ---------------------------------------------------------------- vạt áo mềm v2
# Mỗi vạt = 2 đoạn lò xo góc. Đoạn trên bị đùi đẩy (vạt trước theo đùi nào tiến xa nhất, vạt sau theo đùi lùi xa nhất),
# đoạn dưới theo đoạn trên trễ hơn, rủ về trọng lực (quỳ thì vắt qua gối rồi buông). Đi nhanh: gió cản hất vạt ra sau.
const FLAP_L := 66.0

func _self(n: Node2D, p := Vector2.ZERO) -> Vector2:
	return _lp(self, n, p)


func _drag() -> float:
	return -clampf(move_v * 0.0011, -0.4, 0.4)


func _fwd(sd: String) -> float:
	var d := _self(J["sh" + sd]) - _self(J["th" + sd])
	return atan2(d.x, d.y)


func _skirt_tg(sd: String) -> float:
	var fF := _fwd("F")
	var fB := _fwd("B")
	var drag := _drag()
	if sd == "F":
		return maxf(maxf(fF, fB), 0.0) * 0.85 + drag * 0.5
	return minf(minf(fF, fB), 0.0) * 0.85 + drag


func _skirt_step(dt: float) -> void:
	if not J.has("flapF") or dt <= 0.0:
		return
	var drag := _drag()
	for sd in ["F", "B"]:
		var tg1 := _skirt_tg(sd)
		if not cloth.has(sd):
			cloth[sd] = [tg1, 0.0, tg1 * 0.45, 0.0]
		var c: Array = cloth[sd]
		# gió: gợn theo sway + hất ra sau khi gió mạnh (sway > 1)
		var gust := maxf(sway - 1.0, 0.0)
		var fl := (sin(t * (6.3 if sd == "F" else 5.4)) + 0.5 * sin(t * 11.0 + (1.3 if sd == "F" else 0.0))) * 0.05 * sway
		var tg1w := tg1 - gust * 0.07
		var tg2: float = c[0] * 0.45 + drag * 0.6 + fl - gust * 0.12
		var steps := 4
		var h := dt / steps
		for i in steps:
			c[1] += (170.0 * (tg1w - c[0]) - 13.0 * c[1]) * h
			c[0] += c[1] * h
			c[3] += (95.0 * (tg2 - c[2]) - 7.5 * c[3]) * h
			c[2] += c[3] * h


func _draw_flap(c: Node2D, sd: String) -> void:
	if not cloth.has(sd):
		return
	var cl: Array = limb_col.get("flap" + sd, [Color("#3e1a13"), Color("#8A3A2A")])
	var cs: Array = cloth[sd]
	var a1: float = cs[0]
	var a2: float = cs[2]
	var to: Node2D = J["torso"]
	var s0 := _self(J["flap" + sd])
	var tx := (_self(to, Vector2(1, 0)) - _self(to)).normalized()
	var s1 := s0 + Vector2(sin(a1), cos(a1)) * FLAP_L * 0.5
	var s2 := s1 + Vector2(sin(a2), cos(a2)) * FLAP_L * 0.5
	var sp := chaikin(PackedVector2Array([s0, s1, s2]), 3)
	var n := sp.size()
	var m := c.get_global_transform().affine_inverse() * get_global_transform()
	var lft := PackedVector2Array()
	var rgt := PackedVector2Array()
	var tan_e := Vector2.DOWN
	for i in n:
		var u := float(i) / float(n - 1)
		var tg := (sp[mini(i + 1, n - 1)] - sp[maxi(i - 1, 0)]).normalized()
		var nv := Vector2(tg.y, -tg.x).lerp(tx, 1.0 - smoothstep(0.0, 0.25, u)).normalized()
		var hw := 16.0 + 7.0 * u
		lft.append(sp[i] - nv * hw)
		rgt.append(sp[i] + nv * hw)
		tan_e = tg
	var poly := PackedVector2Array()
	for q in lft:
		poly.append(m * q)
	for k in range(1, 8):          # gấu vạt: cong xuống + gợn nhẹ
		var f := float(k) / 8.0
		var q := lft[n - 1].lerp(rgt[n - 1], f) + tan_e * (sin(f * PI) * 7.0 + sin(f * TAU * 1.5 + t * 3.0) * 1.2)
		poly.append(m * q)
	for i in range(n - 1, -1, -1):
		poly.append(m * rgt[i])
	if Geometry2D.triangulate_polygon(poly).size() > 0:
		c.draw_colored_polygon(poly, cl[1])
	else:
		for i in n - 1:
			c.draw_colored_polygon(PackedVector2Array([m * lft[i], m * lft[i + 1], m * rgt[i + 1], m * rgt[i]]), cl[1])
	# nếp gấp dọc theo vạt
	for off in [-0.3, 0.32]:
		var fold := PackedVector2Array()
		for i in range(int(n * 0.2), n):
			fold.append(m * lft[i].lerp(rgt[i], 0.5 + off))
		c.draw_polyline(fold, Color(cl[0], 0.55), 2.0, true)
	poly.append(poly[0])
	c.draw_polyline(poly, cl[0], 3.0, true)


# bàn tay — toạ độ khớp hd: gốc = cổ tay, +y hướng đầu ngón, +x phía ngón cái
func _ell(p: Vector2, r: Vector2, ang: float) -> PackedVector2Array:
	var q := PackedVector2Array()
	var rot := Transform2D(ang, p)
	for i in 28:
		var a := TAU * i / 28.0
		q.append(rot * Vector2(cos(a) * r.x, sin(a) * r.y))
	return q


func _blob(c: Node2D, p: Vector2, r: Vector2, ang: float, fill: Color, line: Color, w := 2.6) -> void:
	var q := _ell(p, r, ang)
	c.draw_colored_polygon(q, fill)
	q.append(q[0])
	c.draw_polyline(q, line, w, true)


func _cap(c: Node2D, a: Vector2, b: Vector2, r: float, fill: Color, line: Color) -> void:
	c.draw_circle(a, r + 2.4, line, true, -1.0, true)
	c.draw_circle(b, r + 2.4, line, true, -1.0, true)
	c.draw_line(a, b, line, r * 2.0 + 4.8, true)
	c.draw_circle(a, r, fill, true, -1.0, true)
	c.draw_circle(b, r, fill, true, -1.0, true)
	c.draw_line(a, b, fill, r * 2.0, true)


func _hc(sd: String) -> Array:
	return limb_col.get("hd" + sd, [Color("#715f4f"), Color("#FBD3B0")])


func _draw_palm(c: Node2D, sd: String) -> void:
	if one_arm and sd == "B":
		return
	var hc := _hc(sd)
	match hand_form[sd]:
		"nam", "chi":
			_blob(c, Vector2(0, 11), Vector2(15, 14), 0.0, hc[1], hc[0])
		"xoe":
			_blob(c, Vector2(0, 12), Vector2(14, 13), 0.0, hc[1], hc[0])
		_:
			_blob(c, Vector2(1, 13), Vector2(13, 16), 0.0, hc[1], hc[0])
			_blob(c, Vector2(11, 7), Vector2(5.5, 7.5), -0.5, hc[1], hc[0], 2.2)


func _draw_fingers(c: Node2D, sd: String) -> void:
	if one_arm and sd == "B":
		return
	var hc := _hc(sd)
	var ln: Color = hc[0]
	var sk: Color = hc[1]
	var f: String = hand_form[sd]
	match f:
		"nam", "chi":
			# 4 đốt ngón cuộn qua chuôi (chuôi nằm ngang trục x tại y≈10) + ngón cái đè lên
			for i in 4:
				c.draw_circle(Vector2(-10.5 + i * 7.0, 16), 9.0, ln, true, -1.0, true)
			for i in 4:
				c.draw_circle(Vector2(-10.5 + i * 7.0, 16), 6.6, sk, true, -1.0, true)
			c.draw_line(Vector2(-11, 14), Vector2(11, 14), sk, 9.0, true)
			for i in 3:
				var x := -7.0 + i * 7.0
				c.draw_line(Vector2(x, 19), Vector2(x, 22), ln, 1.8, true)
			if f == "chi":
				_cap(c, Vector2(10, 18), Vector2(11, 36), 4.2, sk, ln)
				c.draw_circle(Vector2(10, 17), 5.0, sk, true, -1.0, true)
			_blob(c, Vector2(8, 7), Vector2(8.5, 5.5), 0.35, sk, ln, 2.2)
		"xoe":
			for i in 4:
				var x := -9.0 + i * 6.0
				_cap(c, Vector2(x, 18), Vector2(x * 1.3, 33.0 - absf(i - 1.5) * 3.0), 3.4, sk, ln)
			c.draw_circle(Vector2(0, 13), 11.0, sk, true, -1.0, true)
			_cap(c, Vector2(10, 9), Vector2(19, 17), 3.6, sk, ln)
			c.draw_circle(Vector2(8, 10), 5.0, sk, true, -1.0, true)
		_:
			c.draw_line(Vector2(-4, 21), Vector2(-4.5, 27), ln, 1.8, true)
			c.draw_line(Vector2(3, 21), Vector2(3, 27.5), ln, 1.8, true)
