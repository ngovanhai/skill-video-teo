# k05 thảo nguyên: cỏ gió, lều tròn, mẹ Lý Bình, cậu bé chạy giữa đàn ngựa, Thiết Mộc Chân, Đà Lôi, Hoa Tranh; tấm gương soi hai nửa.
extends Khung

func _init() -> void:
	X = -16800.0; travel = 3.4; ben = -1.0

func cam(t: float) -> Array:
	return Khung.keycam([[-9.0, Vector2(-300, -60), 0.9], [L(1), Vector2(-700, 0), 1.15], [L(2), Vector2(-450, 0), 1.0], [L(3), Vector2(50, 40), 1.1],
		[L(4), Vector2(450, 0), 1.0], [L(5), Vector2(300, 20), 1.1], [L(6), Vector2(0, -60), 0.75]], t, 2.2)

func sfx() -> Array:
	return [[-1.5, "whoosh-cinematic", -6.0], [L(3), "whoosh-short", -8.0], [L(4), "impact-bass-1", -10.0], [L(5), "sparkle", -8.0], [L(6), "chime", -8.0]]

func teo(t: float) -> Dictionary:
	return teo_mac("buon" if t > L(1) and t < L(3) else ("ngai" if t > L(6) else "vui"))

func ve() -> void:
	# đồi cỏ
	But.nui(self, -1300, 1300, 320, 140, 12.0, Color("8fa86a"), pg(-2.5, 2.0), 2.0)
	But.loang(self, Vector2(0, 360), 1300, 60, Color("9fb878"), 2.0, pg(-2.0, 2.0) * 0.8)
	Canh.dat(self, -1300, 1300, 320, pg(-2.0, 2.0), 3.0)
	for i in 26:
		Canh.co(self, Vector2(-1250 + i * 100 + But.h1(i) * 40, 322), 0.8, pg(-1.5 + i * 0.04, 1.0), i, tt)
	Canh.leu(self, Vector2(-850, 320), 1.0, pg(-1.0, 1.4), 1.0)
	Canh.leu(self, Vector2(-430, 300), 0.7, pg(-0.6, 1.4), 2.0)
	Canh.leu(self, Vector2(820, 300), 0.8, pg(-0.3, 1.4), 3.0)
	Canh.may(self, Vector2(-500, -380), 1.2, pg(0.0, 2.0), 1.0, tt)
	Canh.may(self, Vector2(600, -420), 1.0, pg(0.5, 2.0), 2.0, tt)
	# cha: bóng mờ rồi tan
	var pf := ap(1, 1.0) * (1.0 - ap(2, 1.5) * 0.85)
	if pf > 0.0:
		Canh.bong(self, Vector2(-1080, 320), 1.0, 0.35 * pf, 31.0, tt, 0)
		Canh.nhan(self, "Quách Khiếu Thiên", Vector2(-1080, 420), pf, 30, "người Tống nghĩa khí")
	# mẹ Lý Bình đi lên thảo nguyên
	var pm := ap(2, 0.8)
	if pm > 0.0:
		var mx := lerpf(-1250.0, -700.0, But.ez(ap(2, 3.0)))
		Canh.bong(self, Vector2(mx, 320), 0.95, 0.8 * pm, 32.0, tt, 0)
		Canh.nhan(self, "Lý Bình", Vector2(mx, 420), pm, 32, "mẹ Quách Tĩnh")
	# đàn ngựa + cậu bé chạy
	var ph := ap(3, 1.0)
	if ph > 0.0:
		for i in 4:
			var hx := -150.0 + i * 170.0 + sin(tt * 0.5 + i) * 30.0
			Canh.ngua(self, Vector2(hx, 330 + (i % 2) * 18), 0.75, tt, 1.0, ph * (0.7 + 0.1 * i), i, 1.0)
		var bx := 40.0 + sin(tt * 0.9) * 120.0
		var run := sin(tt * 9.0)
		nguoi("quach", Vector2(bx, 340), 0.48, {"face": 1.0 if cos(tt * 0.9) > 0 else -1.0, "stride": 0.5 + 0.4 * run, "aF": 0.6 * run, "aB": -0.6 * run, "lift": absf(run) * 6.0}, "vui", ph)
		Canh.nhan(self, "Quách Tĩnh", Vector2(bx, 430), ph, 30)
	# Thiết Mộc Chân che chở
	var pd := ap(4, 1.0)
	if pd > 0.0:
		nguoi("daihan", Vector2(560, 320), 1.0, {"face": -1, "aF": 0.9, "eF": 0.6, "palmF": true}, "binh", pd)
		Canh.nhan(self, "Thiết Mộc Chân", Vector2(560, 420), pd, 36, "về sau là Thành Cát Tư Hãn")
	# Đà Lôi + Hoa Tranh
	var pl := ap(5, 1.0)
	if pl > 0.0:
		Canh.bong(self, Vector2(240, 330), 0.5, 0.75 * pl, 41.0, tt, 1)
		Canh.nhan(self, "Đà Lôi", Vector2(240, 420), pl, 28, "anh em kết nghĩa")
		But.net(self, But.qd(Vector2(60, 200), Vector2(150, 120), Vector2(240, 200)), 5, But.SON, ap(5, 1.2, 0.5), 0.1, 0.1)
		Canh.bong(self, Vector2(980, 300), 0.6, 0.6 * ap(5, 1.0, 3.0), 42.0, tt, 0)
		Canh.nhan(self, "Hoa Tranh", Vector2(980, 390), ap(5, 1.0, 3.0), 28, "công chúa")
	# tấm gương: hai vế đối nhau
	var pg2 := ap(6, 1.2)
	if pg2 > 0.0:
		But.chu(self, "Khiết Đan » lớn lên như người Tống", Vector2(0, -470), 46, But.MUC, 2, HORIZONTAL_ALIGNMENT_CENTER, -1, pg2)
		But.chu(self, "Tống » lớn lên như người Mông Cổ", Vector2(0, -400), 46, Color("2b3a4a"), 2, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(6, 1.2, 3.0))
	var pc := ap(7, 1.5)
	if pc > 0.0:
		But.chu(self, "không chọn nơi sinh · chỉ chọn đứng về phía nào", Vector2(0, -320), 34, But.SON, 1, HORIZONTAL_ALIGNMENT_CENTER, -1, pc)
