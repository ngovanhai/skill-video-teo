# k12 sân Thiếu Lâm: ba anh em bên phải, Mộ Dung Phục + hai bóng bên trái; con rồng từ bàn tay hất cả nhóm lùi lại (choáng);
# vị lão tăng quét lá đứng xa nhìn; khép nửa phải bằng một vệt cô đơn.
extends Khung

func _init() -> void:
	X = 2400.0; travel = 2.0

func cam(t: float) -> Array:
	return Khung.keycam([[-9.0, Vector2(0, -60), 0.85], [L(1), Vector2(480, 20), 1.15], [L(2), Vector2(0, 0), 0.85], [L(3), Vector2(-60, -60), 0.95],
		[L(4), Vector2(-850, 60), 1.35], [L(5), Vector2(300, 0), 1.0, 4.0]], t, 2.0)

func sfx() -> Array:
	return [[-1.0, "whoosh", -10.0], [L(3) + 0.5, "riser", -10.0], [L(3) + 2.2, "impact-bass-1", -4.0], [L(3) + 2.4, "whoosh-cinematic", -8.0], [L(4), "chime", -10.0]]

func teo(t: float) -> Dictionary:
	return teo_mac("quyet-tam" if t < L(3) else ("soc" if t < L(4) else ("ngai" if t < L(5) else "buon")))

func ve() -> void:
	Canh.dat(self, -1250, 1250, 300, pg(-2.0, 2.0), 12.0)
	# chùa: mái lớn phía sau, bậc đá
	var ph := pg(-1.5, 2.0)
	draw_rect(Rect2(-700, 300 - 330 * ph, 1400, 330 * ph), But.ca(Color("c9b48a"), 0.55 * ph))
	draw_rect(Rect2(-130, 300 - 190 * ph, 260, 190 * ph), But.ca(Color("5b2a1e"), 0.7 * ph))
	Canh.mai(self, Vector2(0, 300 - 330 * ph), 1600, 150, ph, 21.0)
	Canh.nhan(self, "chùa Thiếu Lâm", Vector2(0, -470), pg(0.3, 1.0), 44)
	for i in 3:
		draw_rect(Rect2(-900 + i * 40, 300 + i * 12, 1800 - i * 80, 12), But.ca(Color("8a8c86"), 0.5 * ph))
	Canh.cay(self, Vector2(-1150, 300), 1.2, ph, 13.0, Color("4f6a3a"))
	Canh.cay(self, Vector2(1150, 300), 1.1, ph, 14.0, Color("4f6a3a"))
	# đòn
	var hit := ap(3, 1.0, 2.2)
	var push := But.eo(hit) * 180.0
	# bên phải: ba anh em
	var pr := ap(1, 1.0)
	nguoi("tieu", Vector2(330, 300), 1.0, {"face": -1, "aF": 0.9 + 0.8 * ap(3, 0.5, 1.5), "eF": 0.8 - 0.8 * ap(3, 0.4, 1.8), "palmF": true, "stride": 0.5 * ap(3, 0.5, 1.5), "lean": -0.08 * ap(3, 0.5, 1.5)}, "quyet-tam", pr)
	Canh.nhan(self, "Tiêu Phong", Vector2(330, 400), pr, 32)
	nguoi("hu", Vector2(620, 300), 0.85, {"face": -1, "aF": 0.6, "eF": 0.5}, "binh", ap(1, 1.0, 1.5))
	Canh.nhan(self, "Hư Trúc", Vector2(620, 400), ap(1, 1.0, 1.5), 28, "nhà sư hiền lành")
	nguoi("doan", Vector2(860, 300), 0.82, {"face": -1, "aF": 0.4, "eF": 0.6}, "vui", ap(1, 1.0, 3.5))
	Canh.nhan(self, "Đoàn Dự", Vector2(860, 400), ap(1, 1.0, 3.5), 28, "công tử Đại Lý")
	# bên trái: Mộ Dung Phục + Đinh Xuân Thu + Du Thản Chi
	var pl := ap(2, 1.0)
	if pl > 0.0:
		nguoi("mo", Vector2(-360 - push, 300), 0.95, {"face": 1, "aF": 1.0 - 0.6 * hit, "eF": 0.4, "lean": 0.12 * hit, "crouch": 0.35 * hit}, "soc" if hit > 0.3 else "gian", pl)
		Canh.nhan(self, "Mộ Dung Phục", Vector2(-360 - push, 400), pl, 30)
		for i in 2:
			var bx := -620.0 - i * 230.0 - push * (0.7 - i * 0.2)
			Canh.bong(self, Vector2(bx, 300), 0.85, 0.75 * pl, 140 + i, tt, 1)
			Canh.nhan(self, ["Đinh Xuân Thu", "Du Thản Chi"][i], Vector2(bx, 400), pl, 26)
	# rồng từ bàn tay
	var pd := ap(3, 1.6, 1.6)
	if pd > 0.0:
		var head := Vector2(lerpf(250.0, -330.0, But.eo(pd)), 100 - 60 * sin(pd * PI))
		var path := Canh.rong_path(head, Vector2(-1, 0), 520, tt, 50, 30, 1.4)
		var a := 1.0 - ap(3, 2.0, 4.5)
		if a > 0.0:
			But.rong(self, path, 110, But.ca(But.MUC, a), pd, tt, 9.0)
		if hit > 0.0 and hit < 1.0:
			Canh.vong(self, Vector2(-400, 220), 80 + 400 * hit, 12.0 * (1.0 - hit), 0.7 * (1.0 - hit), 4.0, 0.4)
		But.chu(self, "KHÁNG LONG HỮU HỐI", Vector2(0, -360), 56, But.MUC, 1, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(3, 1.0, 2.0) * (1.0 - ap(5, 1.0)))
	# lão tăng quét lá
	var pm := ap(4, 1.5)
	if pm > 0.0:
		var m := Vector2(-1040, 300)
		Canh.bong(self, m, 0.8, 0.6 * pm, 151.0, 0.0, 0)
		var sw := sin(tt * 1.4) * 30.0
		But.net(self, PackedVector2Array([m + Vector2(30, -150), m + Vector2(70 + sw, 0)]), 6, But.ca(Color("6b4430"), pm), 1.0, 0.0, 0.0, 0.05)
		for k in 6:
			draw_line(m + Vector2(70 + sw, 0), m + Vector2(50 + sw + k * 10, 14), But.ca(But.MUC, 0.6 * pm), 2.0)
		for k in 5:
			var u := fposmod(tt * 0.2 + k * 0.2, 1.0)
			draw_colored_polygon(But.blob_pts(m + Vector2(120 + k * 40 + u * 60, -200 + u * 210), 7, 4, k, 0.2, 8), Color("b88a3a", 0.6 * pm * (1.0 - u)))
		Canh.nhan(self, "Vô Danh lão tăng", m + Vector2(0, 100), pm, 28, "Tàng Kinh Các")
		# ánh nhìn: nét chấm từ lão tăng tới Tiêu Phong
		var pe := ap(4, 1.5, 1.5)
		for k in 14:
			var u := k / 13.0
			if u < pe: draw_circle(m.lerp(Vector2(330, 120), u) + Vector2(0, -200 * sin(u * PI) - 140 * (1.0 - u)), 4, But.ca(But.SON, 0.6))
	# câu 6: mọi thứ mờ dần, chỉ còn Tiêu Phong
	var p5 := ap(5, 3.0, 1.0) * (1.0 - pg(done() + 1.0, 2.0))
	if p5 > 0.0:
		draw_rect(Rect2(-1250, -620, 1450, 1240), But.ca(But.GIAY, 0.75 * p5))
		draw_rect(Rect2(620 - 140, -620, 770, 1240), But.ca(But.GIAY, 0.75 * p5))
		But.chu(self, "mạnh nhất đời mình", Vector2(330, -330), 46, But.MUC, 1, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(5, 1.0, 2.0))
		But.chu(self, "cô đơn nhất đời mình", Vector2(330, -270), 46, But.ca(But.MUC, 0.6), 2, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(5, 1.0, 4.0))
