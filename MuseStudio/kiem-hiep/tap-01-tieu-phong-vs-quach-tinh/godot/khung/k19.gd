# k19 Tương Dương: sông Hán Thuỷ, bức tường mọc từng hàng gạch theo năm; Quách Tĩnh + Hoàng Dung trên mặt thành nhìn về thảo nguyên;
# câu trích duy nhất của tập viết bằng nét to nhất; hai cuộc đời, cùng một lựa chọn.
extends Khung

func _init() -> void:
	X = -19200.0; ben = -1.0; travel = 3.4

func cam(t: float) -> Array:
	return Khung.keycam([[-9.0, Vector2(0, 40), 0.8], [L(1), Vector2(-500, 0), 0.9], [L(2), Vector2(100, -40), 1.0], [L(3), Vector2(100, 0), 0.85],
		[L(4), Vector2(0, -250), 0.95], [L(5), Vector2(0, -260), 1.05], [L(6), Vector2(150, -80), 1.0], [L(7), Vector2(0, -60), 0.8]], t, 2.0)

func sfx() -> Array:
	return [[-2.0, "whoosh-cinematic", -6.0], [L(1), "impact-bass-1", -12.0], [L(3), "click", -10.0], [L(5), "riser", -12.0], [L(5) + 1.0, "impact-bass-2", -6.0], [L(8), "chime", -8.0]]

func teo(t: float) -> Dictionary:
	return teo_mac("ngai" if t < L(4) else ("quyet-tam" if t < L(6) else ("buon" if t < L(7) else "dac-y")))

func ve() -> void:
	# sông Hán Thuỷ
	var pr := pg(-2.0, 2.5)
	But.loang(self, Vector2(0, 430), 1300, 90, Color("7a9aa8"), 21.0, 0.7 * pr)
	for i in 4:
		var pts := PackedVector2Array()
		for k in 40:
			var x := -1250.0 + k * 64.0
			pts.append(Vector2(x, 400 + i * 22 + sin(x * 0.012 + tt * 0.7 + i) * 6.0))
		But.net(self, pts, 4, But.ca(Color("3f5f6f"), 0.4), pr, 0.1, 0.1, 0.2, i)
	But.chu(self, "sông Hán Thuỷ", Vector2(-950, 500), 30, But.ca(But.MUC, 0.7), 2, HORIZONTAL_ALIGNMENT_CENTER, -1, pg(0.5, 1.0))
	Canh.dat(self, -1250, 1250, 340, pr, 19.0)
	# tường thành mọc theo năm
	var years := 3.0 + 27.0 * But.ez(ap(2, 4.0, 1.0)) + 10.0 * But.ez(ap(3, 6.0))
	var rows := minf(years / 4.0, 10.0) * pg(-1.0, 1.0)
	Canh.thanh(self, -700, 900, 340, rows, 34.0, 19.0, pg(-1.0, 1.5))
	var top := 340.0 - rows * 34.0
	Canh.nhan(self, "Tương Dương", Vector2(100, top - 260), pg(0.0, 1.0) * (1.0 - ap(4, 1.0)), 52, "cánh cửa che chắn miền nam nước Tống")
	# vạch năm
	var py := ap(2, 1.0) * (1.0 - ap(4, 1.0))
	if py > 0.0:
		Canh.vach(self, Vector2(-1150, -380), int(years), 0.9, 0.8 * py)
		But.chu(self, "%d năm" % int(years), Vector2(-950, -440), 44, But.MUC, 1, HORIZONTAL_ALIGNMENT_CENTER, -1, py)
	# quân Mông Cổ từ trái kéo tới
	var pm := ap(1, 1.5) * (1.0 - ap(7, 2.0) * 0.5)
	if pm > 0.0:
		var adv := lerpf(-1600.0, -820.0, But.ez(ap(1, 4.0)))
		Canh.doan_quan(self, adv - 420, adv, 340, 3, 0.5, 0.75 * pm, tt, 6.0, Color("5a3a2a"))
		But.chu(self, "quân Mông Cổ", Vector2(adv - 200, 60), 34, But.MUC, 1, HORIZONTAL_ALIGNMENT_CENTER, -1, pm * (1.0 - ap(7, 1.0)))
	# Quách + Dung trên mặt thành
	var pq := ap(1, 1.0, 3.0)
	if pq > 0.0:
		var age := ap(2, 6.0)
		nguoi("quach", Vector2(60, top), 0.7, {"face": -1, "aF": 0.5, "eF": 0.4, "palmF": true}, "quyet-tam", pq)
		nguoi("dung", Vector2(220, top), 0.62, {"face": -1, "aF": 0.4, "eF": 0.6, "prop": "gay-xanh"}, "binh", pq)
		Canh.nhan(self, "Quách Tĩnh · Hoàng Dung", Vector2(140, top + 70), pq * (1.0 - ap(4, 1.0)), 28, "tóc xanh rồi tóc bạc" if age > 0.5 else "")
		# ánh nhìn về thảo nguyên (về trái)
		for k in 10:
			var u := k / 9.0
			if u < ap(3, 3.0, 2.0) * (1.0 - ap(4, 1.0)):
				draw_circle(Vector2(lerpf(0.0, -1100.0, u), top - 260 + 60 * sin(u * PI)), 4, But.ca(But.MUC, 0.5))
	# câu trích: chữ to nhất cuộn tranh
	var p5 := ap(5, 1.2, 0.3)
	if p5 > 0.0:
		var hold := 1.0 - ap(7, 1.0) * 0.5
		But.chu(self, "HIỆP CHI ĐẠI GIẢ", Vector2(0, -430), 104, But.MUC, 1, HORIZONTAL_ALIGNMENT_CENTER, -1, p5 * hold)
		But.chu(self, "VỊ QUỐC VỊ DÂN", Vector2(0, -310), 104, But.SON, 1, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(5, 1.2, 1.6) * hold)
		But.chu(self, "bậc đại hiệp là người vì nước, vì dân", Vector2(0, -245), 34, But.ca(But.MUC, 0.8), 2, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(5, 1.0, 3.6) * hold)
	elif ap(4, 1.0) > 0.0:
		# câu 5: ngọn bút to chấm mực sẵn
		var dot := ap(4, 1.0)
		But.loang(self, Vector2(-500, -400), 40 * dot, 40 * dot, But.MUC, 31.0, dot)
	# câu 8–9: tấm gương — hai đường đời gặp ở cùng một chữ
	var p7 := ap(7, 1.0)
	if p7 > 0.0:
		But.chu(self, "đứng chắn giữa hai đạo quân", Vector2(-850, -230), 32, But.MUC, 2, HORIZONTAL_ALIGNMENT_CENTER, -1, p7)
		But.chu(self, "để dân thường được sống", Vector2(-850, -185), 32, But.SON, 2, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(7, 1.0, 2.0))
	var p8 := ap(8, 1.0)
	if p8 > 0.0:
		But.chu(self, "Khiết Đan » giữ hoà bình cho Tống", Vector2(-850, -90), 30, But.MUC, 2, HORIZONTAL_ALIGNMENT_CENTER, -1, p8)
		But.chu(self, "Tống » giữ thành trước Mông Cổ", Vector2(-850, -45), 30, Color("2b3a4a"), 2, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(8, 1.0, 3.5))
		But.dau(self, Vector2(-850, 50), 110, ["MỘT", "LỰA CHỌN"], ap(8, 1.0, 6.0), -0.05, 61.0)
