# k11 Tụ Hiền Trang: trang viên, mấy trăm bóng người vây vòng; bát rượu cạn; Thái Tổ Trường Quyền; vòng mực loang hất lớp người ra (choáng, lùi);
# câu 8 buồn; câu 9 lời mời đăng ký: dấu son + cái chuông.
extends Khung

func _init() -> void:
	X = 4800.0; travel = 2.0

func cam(t: float) -> Array:
	return Khung.keycam([[-9.0, Vector2(0, -80), 0.85], [L(1), Vector2(0, 0), 0.75], [L(2), Vector2(0, 80), 1.35], [L(3), Vector2(0, -60), 1.0],
		[L(5), Vector2(0, 40), 0.72], [L(7), Vector2(0, 80), 1.3], [L(8), Vector2(300, -100), 0.95]], t, 2.0)

func sfx() -> Array:
	return [[L(2) + 1.5, "pop", -10.0], [L(2) + 3.0, "pop", -10.0], [L(4), "whoosh", -10.0], [L(5) + 1.0, "impact-bass-1", -6.0], [L(5) + 3.5, "impact-bass-2", -8.0], [L(8), "chime", -6.0], [L(8) + 3.0, "sparkle", -8.0]]

func teo(t: float) -> Dictionary:
	if t > L(8): return teo_mac("vui", {"aF": 1.6 + 0.2 * sin(tt * 4.0), "eF": 0.2})
	return teo_mac("soc" if t > L(4) and t < L(6) else ("buon" if t > L(7) else "binh"))

func ve() -> void:
	Canh.dat(self, -1250, 1250, 300, pg(-2.0, 2.0), 11.0)
	# trang viên: tường + mái + cổng
	var ph := pg(-1.5, 2.0)
	draw_rect(Rect2(-1150, 300 - 300 * ph, 2300, 300 * ph), But.ca(Color("d7c7a4"), 0.5 * ph))
	Canh.mai(self, Vector2(-700, 300 - 300 * ph), 760, 110, ph, 11.0)
	Canh.mai(self, Vector2(700, 300 - 300 * ph), 760, 110, ph, 12.0)
	Canh.nhan(self, "Tụ Hiền Trang", Vector2(0, -470), pg(0.4, 1.0), 48)
	# vòng vây + sóng choáng
	var hit := ap(5, 4.0, 0.8)     # ba lớp bị hất lần lượt
	var pn := ap(1, 1.5)
	for ring in 3:
		var push := But.eo(clampf(hit * 3.0 - ring, 0.0, 1.0))
		var r := 260.0 + ring * 170.0 + push * 160.0
		var n := 8 + ring * 4
		for i in n:
			var ang := PI + PI * (i + 0.5) / n
			var feet := Vector2(cos(ang) * r * 1.9, 300 + sin(ang) * r * 0.18 + 40)
			var wob := sin(tt * 7.0 + i) * 8.0 * push * (1.0 - ap(6, 2.0, 2.0))
			Canh.bong(self, feet + Vector2(wob, 0), 0.6 - ring * 0.05, (0.75 - ring * 0.12) * pn * (1.0 - 0.35 * push), 120 + ring * 20 + i, tt * (1.0 - push), 2 if ring == 0 and push < 0.5 else 0)
	for k in 3:
		var u := clampf(hit * 3.0 - k, 0.0, 1.0)
		if u > 0.0 and u < 1.0:
			Canh.vong(self, Vector2(0, 260), 120 + u * 900, 14.0 * (1.0 - u), 0.7 * (1.0 - u), k * 3.0, 0.22)
	# ba hào kiệt áo màu đứng gần nhất
	for i in 3:
		var hx: float = [-420.0, 380.0, -240.0][i]
		var back := But.eo(clampf(hit * 3.0 - 0.3, 0.0, 1.0)) * 140.0 * signf(hx)
		nguoi("hao%d" % (i + 1), Vector2(hx + back, 300 + i * 6), 0.78, {"face": -signf(hx), "aF": 1.0, "eF": 0.4, "lean": -0.12 * signf(hx) * hit, "crouch": 0.3 * hit}, "soc" if hit > 0.3 else "gian", ap(1, 1.0, 1.0 + i * 0.4))
	# Tiêu Phong ở giữa
	var fist := ap(4, 0.6) * (0.5 + 0.5 * sin(tt * 5.0)) if lt < L(7) else 0.0
	nguoi("tieu", Vector2(0, 300), 1.0, {"face": 1 if fmod(tt, 4.0) < 2.0 else -1, "aF": 0.6 + 1.0 * fist, "eF": 0.9 - 0.8 * fist, "palmF": false, "stride": 0.5 * ap(4, 1.0), "crouch": 0.2 * ap(4, 1.0)}, "quyet-tam" if lt < L(7) else "buon", ap(1, 1.0, 1.5))
	# bát rượu
	var pb := ap(2, 1.0) * (1.0 - ap(3, 1.0))
	if pb > 0.0:
		for i in 5:
			var at := Vector2(-260 + i * 130, 140 - (1.0 if fmod(tt + i * 0.6, 3.0) < 0.6 else 0.0) * 40)
			var pts := PackedVector2Array([at + Vector2(-40, 0), at + Vector2(40, 0), at + Vector2(26, 30), at + Vector2(-26, 30)])
			draw_colored_polygon(pts, But.ca(Color("6b4430"), pb))
			draw_rect(Rect2(at + Vector2(-38, -4), Vector2(76, 6)), But.ca(Color("c9b48a"), pb))
		But.chu(self, "cạn bát · cắt tình xưa", Vector2(0, 30), 40, But.MUC, 2, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(2, 1.0, 2.0) * pb)
	# Thái Tổ Trường Quyền
	var pq := ap(3, 1.2, 2.0)
	if pq > 0.0:
		Canh.cot(self, ["THÁI", "TỔ", "TRƯỜNG", "QUYỀN"], Vector2(1080, -470), 56, pq, But.MUC, 1)
		But.chu(self, "bài quyền phổ thông của người Tống", Vector2(780, -60), 28, But.ca(But.MUC, 0.75), 2, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(4, 1.0))
	# câu 7: chiêu đầu
	var p6 := ap(6, 1.0) * (1.0 - ap(7, 1.0))
	if p6 > 0.0:
		But.chu(self, "những chiêu đầu · khí thế cao nhất", Vector2(0, -360), 44, But.SON, 1, HORIZONTAL_ALIGNMENT_CENTER, -1, p6)
	# câu 8: không muốn đánh — bong bóng lời bị gạch
	var p7 := ap(7, 1.0) * (1.0 - ap(8, 1.0))
	if p7 > 0.0:
		Canh.to_giay(self, Vector2(-320, -220), Vector2(420, 120), p7, 0.03, 0)
		But.chu(self, "tôi không phải kẻ ác", Vector2(-320, -210), 36, But.MUC, 2, HORIZONTAL_ALIGNMENT_CENTER, -1, p7)
		But.net(self, PackedVector2Array([Vector2(-500, -200), Vector2(-140, -222)]), 6, But.ca(But.MUC, 0.6), ap(7, 1.0, 3.0), 0.1, 0.1)
		But.chu(self, "không ai nghe", Vector2(-320, -140), 28, But.SON, 2, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(7, 1.0, 4.0) * p7)
	# câu 9: đăng ký
	var p8 := ap(8, 1.0)
	if p8 > 0.0:
		But.dau(self, Vector2(300, -200), 200, ["ĐĂNG KÝ", "TÈO KỂ"], p8, -0.05, 31.0)
		var bell := Vector2(560, -230)
		var sw := sin(tt * 8.0) * 0.3 * ap(8, 1.0, 1.0) * (1.0 - ap(8, 2.0, 3.0))
		draw_set_transform(bell, sw)
		var pts := PackedVector2Array([Vector2(-40, 30), Vector2(-30, -20), Vector2(0, -44), Vector2(30, -20), Vector2(40, 30)])
		draw_colored_polygon(pts, But.ca(Color("c99a3a"), ap(8, 1.0, 1.0)))
		draw_circle(Vector2(0, 38), 9, But.ca(But.MUC, ap(8, 1.0, 1.0)))
		draw_set_transform(Vector2.ZERO)
		But.chu(self, "mỗi lượt đăng ký = một thỏi mực", Vector2(300, -40), 32, But.MUC, 2, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(8, 1.0, 4.0))
		draw_rect(Rect2(150, -15, 300 * ap(8, 1.0, 5.0), 26), But.ca(But.MUC, 0.85))
