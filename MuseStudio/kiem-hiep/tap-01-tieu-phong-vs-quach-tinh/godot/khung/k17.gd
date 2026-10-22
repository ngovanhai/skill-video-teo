# k17 sau trăm chiêu: trời sẫm lại, rồng bên trái dài ra và cuộn quanh; quả cân 3 (kho chiêu) và 4 (hơi dài) rơi vào đĩa Quách Tĩnh,
# cân về thăng bằng; "trận ngắn / trận dài"; lời mời bình luận; câu hỏi lớn hơn ở hai đầu cuộn.
extends Khung

const KHO_Q := ["Hàng Long", "Cửu Âm Chân Kinh", "Song Thủ Hỗ Bác", "Không Minh Quyền", "cung tên thảo nguyên"]
const KHO_T := ["Hàng Long", "Thái Tổ Trường Quyền", "Cầm Long Công"]

func _init() -> void:
	X = 0.0; travel = 0.0; pre = 0.0

func cam(t: float) -> Array:
	return Khung.keycam([[-9.0, Vector2(0, 30), 0.78], [L(1), Vector2(-300, 0), 0.95], [L(2), Vector2(300, 0), 0.95], [L(3), Vector2(-250, 40), 1.0],
		[L(5), Vector2(0, 40), 0.8], [L(7), Vector2(0, 0), 0.85], [L(8), Vector2(0, 0), 0.62, 4.0]], t, 2.0)

func sfx() -> Array:
	return [[L(0), "whoosh", -10.0], [L(2) + 4.0, "pop", -4.0], [L(4) + 3.0, "pop", -4.0], [L(5), "chime", -8.0], [L(6), "impact-bass-2", -10.0], [L(7), "sparkle", -8.0]]

func teo(t: float) -> Dictionary:
	var ex := "ngai" if t < L(2) else ("quyet-tam" if t < L(5) else ("dac-y" if t < L(7) else ("vui" if t < L(8) else "binh")))
	var d := teo_mac(ex)
	d["pos"] = Vector2(1690.0, 1200.0)   # nối tiếp k16, không trồi lên lại
	var w3 := ap(2, 1.0, 4.0); var w4 := ap(4, 1.0, 3.0)
	var off := 1.0 - pg(done() + 0.5, 1.2)
	d["can"] = {"p": off, "r": [["ra đòn đầu", 1.0], ["một chọi nhiều", 1.0]], "l": [["kho chiêu", w3], ["hơi dài", w4]], "tilt": 0.18 - 0.09 * But.eo(w3) - 0.09 * But.eo(w4) + 0.01 * sin(tt * 2.0) * (1.0 - ap(5, 2.0))}
	return d

func ve() -> void:
	var fin := pg(done() + 0.5, 2.0)          # hết khung: lau chữ, trời sáng lại, chỉ còn hai rồng + hai người
	var dark := ap(0, 3.0) * (1.0 - ap(6, 3.0) * 0.6) * (1.0 - fin)
	if dark > 0.0:
		Canh.troi(self, -1250, 1250, Color("2a2a33"), 0.45 * dark, -620, 260)
	for i in 8:
		var x := -1150.0 + i * 330.0
		Canh.may(self, Vector2(x, 330 + (i % 2) * 40), 1.4, 1.0, 70.0 + i, tt)
	# hai người tiếp tục đấu
	var sw := sin(tt * 5.0)
	nguoi("tieu", Vector2(460, 300), 1.05, {"face": -1, "aF": 1.1 + 0.5 * sw, "eF": 0.4, "aB": 0.4, "palmF": true, "stride": 0.4, "lean": -0.06}, "quyet-tam", 1.0)
	nguoi("quach", Vector2(-460, 300), 1.0, {"face": 1, "aF": 1.1 - 0.5 * sw, "eF": 0.4, "aB": 0.4, "palmF": true, "stride": 0.4, "lean": 0.06}, "quyet-tam", 1.0)
	# hai rồng: phải đậm, trái dài ra và cuộn
	var grow := ap(0, ld[0] if ld.size() > 0 else 6.0)
	var hr := Vector2(60, -190 + 20 * sin(tt * 2.0))
	But.rong(self, Canh.rong_path(hr, Vector2(-1, 0.3), 900, tt, 50, 34, 1.6), 120, But.MUC, 1.0, tt, 1.0)
	var hl := Vector2(-60, -170 + 20 * sin(tt * 2.0 + 1.0))
	var coil := Canh.rong_path(hl, Vector2(1, 0.3), 1500 + 1100 * grow, tt, 60 + 80 * grow, 50, 2.2 + 1.6 * grow)
	But.rong(self, coil, 100, Color("2b3a4a"), 1.0, tt, 2.0)
	Canh.vong(self, Vector2(0, -180), 60 + 80 * fposmod(tt, 1.0), 8.0, 0.5 * (1.0 - fposmod(tt, 1.0)), 7.0, 0.6)
	var cap0 := ap(0, 1.0, 2.0) * (1.0 - ap(1, 1.0))
	But.chu(self, "sau 100 chiêu", Vector2(0, -230), 56, But.MUC, 1, HORIZONTAL_ALIGNMENT_CENTER, -1, cap0)
	# câu 2–3: kho chiêu hai bên
	var pk := ap(1, 1.0) * (1.0 - ap(3, 1.0))
	if pk > 0.0:
		for i in KHO_Q.size():
			Canh.to_giay(self, Vector2(-900, -380 + i * 95), Vector2(300, 74), ap(1, 0.6, 1.5 + i * 1.2) * pk, -0.03 + 0.02 * i, 0)
			But.chu(self, KHO_Q[i], Vector2(-900, -370 + i * 95), 26, Color("2b3a4a"), 1, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(1, 0.6, 1.5 + i * 1.2) * pk)
		var pt := ap(2, 1.0) * (1.0 - ap(3, 1.0))
		for i in KHO_T.size():
			Canh.to_giay(self, Vector2(900, -380 + i * 95), Vector2(300, 74), ap(2, 0.6, 0.5 + i * 1.2) * pt, 0.03 - 0.02 * i, 0)
			But.chu(self, KHO_T[i], Vector2(900, -370 + i * 95), 26, But.MUC, 1, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(2, 0.6, 0.5 + i * 1.2) * pt)
		But.chu(self, "%d  :  %d" % [mini(5, int(1 + ap(1, 6.0) * 5)), mini(3, int(1 + ap(2, 3.0) * 3))], Vector2(0, -230), 60, But.MUC, 1, HORIZONTAL_ALIGNMENT_CENTER, -1, pk)
	# câu 4–5: hơi dài — vòng thở bên Quách, chiêu đếm tăng
	var ph := ap(3, 1.0) * (1.0 - ap(5, 1.0))
	if ph > 0.0:
		var br := fposmod(tt * 0.3, 1.0)
		for k in 3:
			var r := fposmod(br + k / 3.0, 1.0)
			Canh.vong(self, Vector2(-460, 150), 40 + 200 * r, 5.0, (1.0 - r) * 0.6 * ph, k, 0.8)
		var n := 100 + int(200 * But.ez(ap(4, 4.0)))
		But.chu(self, "chiêu %d" % n, Vector2(0, -230), 60, But.MUC, 1, HORIZONTAL_ALIGNMENT_CENTER, -1, ph)
		But.chu(self, "vẫn thở đều", Vector2(-460, -40), 34, Color("2b3a4a"), 2, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(4, 1.0, 1.5) * ph)
	# câu 6: 2 : 2, không cộng tổng
	var p5 := ap(5, 1.0) * (1.0 - ap(6, 1.0))
	if p5 > 0.0:
		But.chu(self, "2  :  2", Vector2(0, -230), 72, But.SON, 1, HORIZONTAL_ALIGNMENT_CENTER, -1, p5)
		But.chu(self, "không cộng tổng", Vector2(0, -170), 32, But.ca(But.MUC, 0.8), 2, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(5, 1.0, 3.0) * p5)
	# câu 7: trận ngắn / trận dài
	var p6 := ap(6, 1.0) * (1.0 - fin)
	if p6 > 0.0:
		But.chu(self, "trận ngắn » Tiêu Phong", Vector2(460, -250), 46, But.MUC, 1, HORIZONTAL_ALIGNMENT_CENTER, -1, p6 * (1.0 - ap(7, 1.0) * 0.5))
		But.chu(self, "trận dài » Quách Tĩnh", Vector2(-460, -250), 46, Color("2b3a4a"), 1, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(6, 1.0, 3.0) * (1.0 - fin) * (1.0 - ap(7, 1.0) * 0.5))
	# câu 8: bình luận
	var p7 := ap(7, 1.0) * (1.0 - ap(8, 1.0))
	if p7 > 0.0:
		var c := Vector2(0, 80)
		draw_colored_polygon(But.blob_pts(c, 330, 110, 5.0, 0.04, 40), But.ca(But.GIAY, 0.95 * p7))
		But.net(self, But.blob_pts(c, 330, 110, 5.0, 0.04, 40), 5, But.ca(But.MUC, 0.8), p7, 0.0, 0.0, 0.1)
		draw_colored_polygon(PackedVector2Array([c + Vector2(60, 100), c + Vector2(130, 100), c + Vector2(150, 170)]), But.ca(But.GIAY, 0.95 * p7))
		But.chu(self, "phe Tiêu Phong  hay  phe Quách Tĩnh ?", c + Vector2(0, -10), 34, But.MUC, 1, HORIZONTAL_ALIGNMENT_CENTER, -1, p7)
		But.chu(self, "viết xuống phần bình luận", c + Vector2(0, 45), 30, But.SON, 2, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(7, 1.0, 3.0) * p7)
	# câu 9: câu hỏi lớn hơn ở hai đầu cuộn
	var p8 := ap(8, 1.0) * (1.0 - fin)
	if p8 > 0.0:
		var dash := 0.0
		while dash < 900.0 * ap(8, 2.0, 1.0):
			draw_circle(Vector2(560 + dash, 420), 5, But.ca(But.SON, 0.7 * p8))
			draw_circle(Vector2(-560 - dash, 420), 5, But.ca(But.SON, 0.7 * p8))
			dash += 30.0
		But.chu(self, "cửa ải", Vector2(1300, 430), 34, But.SON, 2, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(8, 1.0, 3.0) * (1.0 - fin))
		But.chu(self, "toà thành", Vector2(-1300, 430), 34, But.SON, 2, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(8, 1.0, 3.0) * (1.0 - fin))
