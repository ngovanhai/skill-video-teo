# Tèo đứng ngoài cuộn tranh (toạ độ màn hình). st = {pos, s, pose, expr, a} do khung đang chạy trả về; {} = vắng.
# Thêm: st.ban (0..1) bàn vẽ + nghiên mực; st.can = {p, l:[tên quả bên trái], r:[...], tilt} cái cân Tèo cầm.
extends Node2D

var st := {}
var talk := false
var tt := 0.0

func _draw() -> void:
	if st.is_empty(): return
	var a: float = st.get("a", 1.0)
	if a <= 0.01: return
	var pos: Vector2 = st.pos
	var s: float = st.get("s", 1.0)
	var pose: Dictionary = st.get("pose", {}).duplicate()
	pose["talk"] = talk
	if st.has("can"): _can(st.can, a)
	Nguoi.ve(self, "teo", pos, s, pose, st.get("expr", "binh"), tt, a)
	if st.get("ban", 0.0) > 0.0: _ban(st.ban, a)

func _ban(p: float, a: float) -> void:   # bàn vẽ phía trước Tèo
	var k := But.eo(p)
	var y := 1080.0 - 210.0 * k
	draw_colored_polygon(PackedVector2Array([Vector2(-20, y), Vector2(1940, y), Vector2(1940, 1100), Vector2(-20, 1100)]), Color("4a2e1e", a))
	draw_rect(Rect2(-20, y, 1960, 14), Color("6b4430", a))
	# giấy trải trên bàn
	draw_colored_polygon(PackedVector2Array([Vector2(260, y + 26), Vector2(1660, y + 26), Vector2(1700, 1100), Vector2(220, 1100)]), But.ca(But.GIAY, a))
	# nghiên mực
	var nc := Vector2(1500, y + 90)
	draw_colored_polygon(But.blob_pts(nc, 110, 46, 3.0, 0.05, 30), Color("2a2622", a))
	draw_colored_polygon(But.blob_pts(nc + Vector2(-10, -6), 70, 26, 4.0, 0.05, 30), Color("0e0c0a", a))
	# giá bút
	for i in 4:
		var x := 360.0 + i * 60.0
		But.net(self, PackedVector2Array([Vector2(x, y + 10), Vector2(x + 6, y - 150)]), 10, Color("8a5a34", a), 1.0, 0.0, 0.0, 0.05)
		draw_colored_polygon(PackedVector2Array([Vector2(x - 6, y + 10), Vector2(x + 8, y + 10), Vector2(x + 1, y + 44)]), But.ca(But.MUC, a))
	But.net(self, PackedVector2Array([Vector2(330, y - 150), Vector2(620, y - 156)]), 12, Color("3a2418", a), 1.0, 0.0, 0.0, 0.05)

func _can(c: Dictionary, a: float) -> void:   # cái cân đòn treo ở góc trên
	var p: float = c.get("p", 1.0) * a
	if p <= 0.0: return
	var ctr := Vector2(960, 150 - 220 * (1.0 - But.eo(c.get("p", 1.0))))
	var tilt: float = c.get("tilt", 0.0)
	var ink := But.ca(But.MUC, p)
	draw_line(ctr + Vector2(0, -160), ctr, ink, 4.0)
	var dl := Vector2(cos(tilt), sin(tilt)) * 300.0
	But.net(self, PackedVector2Array([ctr - dl, ctr + dl]), 12, Color("6b4430", p), 1.0, 0.05, 0.05, 0.1)
	draw_circle(ctr, 12, ink)
	var names := [c.get("r", []), c.get("l", [])]   # đĩa trái màn hình = Quách (bên trái cuộn), đĩa phải = Tiêu
	for side in 2:
		var tip := ctr + dl * (1.0 if side == 0 else -1.0)
		var pan := tip + Vector2(0, 130)
		draw_line(tip, pan + Vector2(-70, 0), ink, 2.0); draw_line(tip, pan + Vector2(70, 0), ink, 2.0)
		var arc := PackedVector2Array()
		for i in 13:
			var ang := PI * i / 12.0
			arc.append(pan + Vector2(cos(ang) * -90, sin(ang) * 26))
		draw_colored_polygon(arc, Color("8a6a3a", p))
		But.net(self, arc, 4, ink, 1.0, 0.0, 0.0, 0.1)
		var lst: Array = names[side]
		for i in lst.size():
			var it: Array = lst[i]   # [chữ, độ hiện]
			var q: float = it[1]
			if q <= 0.0: continue
			var drop := (1.0 - But.eo(q)) * -260.0
			var w := pan + Vector2(0, -36 - i * 64 + drop)
			var hw := But.chu_w(it[0], 22, 1) * 0.5 + 16.0   # quả cân rộng theo chữ
			draw_colored_polygon(PackedVector2Array([w + Vector2(-hw - 10, 30), w + Vector2(-hw, -28), w + Vector2(hw, -28), w + Vector2(hw + 10, 30)]), Color("3a3430", p * clampf(q * 3.0, 0, 1)))
			But.chu(self, it[0], w + Vector2(0, 10), 22, But.ca(But.GIAY, p), 1, HORIZONTAL_ALIGNMENT_CENTER, -1, q)
	But.chu(self, "TIÊU PHONG", ctr + dl + Vector2(0, 205), 26, ink, 1, HORIZONTAL_ALIGNMENT_CENTER, -1, p)
	But.chu(self, "QUÁCH TĨNH", ctr - dl + Vector2(0, 205), 26, ink, 1, HORIZONTAL_ALIGNMENT_CENTER, -1, p)
