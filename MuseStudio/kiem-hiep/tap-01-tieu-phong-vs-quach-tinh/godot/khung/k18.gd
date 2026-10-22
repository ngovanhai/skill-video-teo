# k18 Nhạn Môn Quan lần thứ hai: giấy phủ tuyết lên cảnh cũ; Gia Luật Hồng Cơ phong Nam Viện đại vương; mũi tên xuống nam; song sắt, hai em tới cứu;
# hai đạo quân hai bên cửa ải; lời thề; Tiêu Phong nhạt dần thành mực dưới cửa ải; đàn nhạn bay qua.
extends Khung

func _init() -> void:
	X = 12700.0; travel = 3.4

func cam(t: float) -> Array:
	return Khung.keycam([[-9.0, Vector2(0, -60), 0.8], [L(1), Vector2(380, 40), 1.1], [L(2), Vector2(300, -60), 0.95], [L(3), Vector2(-350, 40), 1.1],
		[L(4), Vector2(0, 20), 0.72], [L(5), Vector2(120, 40), 1.15], [L(6), Vector2(0, 60), 1.3, 5.0], [L(7), Vector2(0, -160), 0.85, 4.0]], t, 2.0)

func sfx() -> Array:
	return [[-2.0, "whoosh-cinematic", -6.0], [L(1), "sparkle", -10.0], [L(3), "click", -6.0], [L(3) + 4.0, "whoosh", -8.0], [L(4), "impact-bass-1", -10.0], [L(5) + 3.0, "chime", -6.0], [L(7), "riser", -14.0]]

func teo(t: float) -> Dictionary:
	return teo_mac("binh" if t < L(3) else ("quyet-tam" if t < L(6) else "buon"))

func ve() -> void:
	# giấy phủ cảnh cũ + tuyết
	var pw := pg(-2.5, 2.0)
	draw_rect(Rect2(-1250, -620, 2500, 1240), But.ca(But.GIAY, 0.92 * pw))
	Canh.troi(self, -1250, 1250, Color("8a96a8"), 0.35 * pw, -620, 200)
	But.nui(self, -1250, 1250, 300, 560, 61.0, Color("6b6e70"), pw, 3.0)
	Canh.dat(self, -1250, 1250, 300, pw, 18.0)
	draw_rect(Rect2(-1250, 300, 2500, 40), But.ca(Color("f4f0e8"), 0.8 * pw))
	Canh.cua_ai(self, Vector2(0, 300), 1.1, pw, 4.0)
	Canh.nhan(self, "Nhạn Môn Quan", Vector2(0, -420), pg(0.3, 1.0) * (1.0 - ap(4, 1.0)), 46)
	Canh.tuyet(self, Rect2(-1250, -620, 2500, 940), tt, 70, 0.8 * pw)
	# Hồng Cơ + đại vương
	var p1 := ap(1, 1.0) * (1.0 - ap(4, 1.0))
	if p1 > 0.0:
		nguoi("hongco", Vector2(620, 300), 1.0, {"face": -1, "aF": 0.9 + 0.5 * ap(2, 1.0, 1.0), "eF": 0.4}, "vui" if lt < L(2) else "gian", p1)
		Canh.nhan(self, "Gia Luật Hồng Cơ", Vector2(620, 400), p1, 30, "vua nước Liêu")
		But.dau(self, Vector2(320, -260), 140, ["NAM VIỆN", "ĐẠI VƯƠNG"], ap(1, 1.0, 4.0) * (1.0 - ap(3, 1.0)), 0.05, 51.0)
		# câu 3: mũi tên xuống nam (sang trái cuộn)
		var ar := ap(2, 2.0, 1.0) * (1.0 - ap(3, 1.0))
		if ar > 0.0:
			But.net(self, PackedVector2Array([Vector2(500, -120), Vector2(-500, -120)]), 16, But.SON, ar, 0.05, 0.05, 0.1)
			But.chu(self, "đánh nước Tống", Vector2(0, -160), 40, But.SON, 1, HORIZONTAL_ALIGNMENT_CENTER, -1, ar)
	# Tiêu Phong
	var walk := lerpf(260.0, 0.0, But.ez(ap(4, 2.0)))
	var jail := ap(3, 0.8) * (1.0 - ap(3, 1.0, 4.0))
	var tx := walk if lt > L(3) + 4.0 or lt < L(3) else -420.0
	var fade := ap(6, 6.0, 4.0)
	var pt := pg(-0.5, 1.0) * (1.0 - 0.85 * fade)
	nguoi("tieu", Vector2(tx, 300), 1.0, {"face": 1 if lt > L(4) else -1, "aF": 0.4 + (1.2 * ap(5, 0.6) * (1.0 - ap(5, 1.0, 4.0)) if lt < L(6) else 0.0), "eF": 0.6, "palmF": true, "crouch": 0.2 * fade}, "buon" if lt < L(5) else "quyet-tam" if lt < L(6) else "binh", pt)
	if fade > 0.0:
		But.loang(self, Vector2(tx, 240), 160 * fade, 260 * fade, Color("3a3a40"), 19.0, 0.35 * fade)
	Canh.nhan(self, "Tiêu Phong", Vector2(tx, 400), pg(-0.5, 1.0) * (1.0 - ap(4, 1.0)), 32)
	# song sắt + hai em tới cứu
	if jail > 0.0:
		for i in 7:
			draw_rect(Rect2(-560 + i * 46, 300 - 440 * jail, 10, 440 * jail), But.ca(But.MUC, 0.9))
		draw_rect(Rect2(-570, 300 - 440 * jail, 300, 12), But.ca(But.MUC, 0.9))
	var pr := ap(3, 1.0, 2.0) * (1.0 - ap(4, 1.0, 1.0))
	if pr > 0.0:
		nguoi("hu", Vector2(-760, 300), 0.85, {"face": 1, "aF": 1.2, "eF": 0.3, "palmF": true}, "quyet-tam", pr)
		nguoi("doan", Vector2(-960, 300), 0.82, {"face": 1, "aF": 1.0, "eF": 0.3}, "quyet-tam", pr)
		Canh.nhan(self, "Hư Trúc · Đoàn Dự", Vector2(-860, 400), pr, 28)
	# hai đạo quân
	var pa := ap(4, 1.5) * (1.0 - ap(7, 2.0) * 0.6)
	if pa > 0.0:
		Canh.doan_quan(self, 380, 1200, 300, 3, 0.55, 0.7 * pa, tt, 3.0, Color("2f4a6a"))
		Canh.doan_quan(self, -1200, -380, 300, 3, 0.55, 0.7 * pa, tt, 4.0, Color("8a2a1e"))
		But.chu(self, "quân Liêu", Vector2(800, 30), 36, But.MUC, 1, HORIZONTAL_ALIGNMENT_CENTER, -1, pa)
		But.chu(self, "quân Tống", Vector2(-800, 30), 36, But.MUC, 1, HORIZONTAL_ALIGNMENT_CENTER, -1, pa)
	# lời thề
	var p5 := ap(5, 1.0)
	if p5 > 0.0:
		var king := Vector2(170, 300)
		nguoi("hongco", king, 0.95, {"face": -1, "aF": 1.5 * ap(6, 1.0), "eF": 0.1, "crouch": 0.2}, "soc" if lt < L(6) else "buon", p5 * (1.0 - ap(7, 2.0) * 0.5))
		Canh.to_giay(self, Vector2(0, -230), Vector2(560, 150), ap(5, 1.0, 4.0), 0.0, 0)
		But.chu(self, "còn sống ngày nào", Vector2(0, -250), 38, But.MUC, 2, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(5, 1.0, 5.0))
		But.chu(self, "quân Liêu không vượt biên", Vector2(0, -200), 38, But.SON, 1, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(5, 1.0, 6.5))
		But.dau(self, Vector2(240, -170), 70, ["THỀ"], ap(6, 0.8, 0.5), 0.1, 52.0)
	# câu 8: đàn nhạn
	var p7 := ap(7, 2.0)
	if p7 > 0.0:
		Canh.dan_nhan(self, Vector2(lerpf(1300.0, -1300.0, ap(7, 14.0)), -380), 1.2, tt, 0.8 * p7, 9, -1.0)
		But.chu(self, "một người Khiết Đan · chết để người Tống được yên", Vector2(0, -470), 40, But.MUC, 2, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(7, 1.5, 2.0))
