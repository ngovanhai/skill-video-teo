# k16 trận trong tranh (tưởng tượng): hai nửa gặp nhau ở giữa; hai người đứng trên mây; Tèo treo cái cân,
# quả cân thứ nhất (ra đòn đầu) và thứ hai (một chọi nhiều) rơi vào đĩa Tiêu Phong; cuối khung hai con rồng lao vào nhau.
extends Khung

func _init() -> void:
	X = 0.0; travel = 3.2; keep = false; post = 0.6

func cam(t: float) -> Array:
	return Khung.keycam([[-9.0, Vector2(0, -40), 0.6], [L(0), Vector2(0, 60), 0.82], [L(1), Vector2(0, 80), 0.9], [L(3), Vector2(250, 80), 1.05],
		[L(4), Vector2(-250, 80), 1.05], [L(6), Vector2(380, 60), 1.0], [L(7), Vector2(-420, 60), 1.0], [L(8), Vector2(0, 60), 0.85], [L(9), Vector2(0, 30), 0.78]], t, 2.0)

func sfx() -> Array:
	return [[-2.0, "whoosh-cinematic", -6.0], [L(2), "click", -6.0], [L(3) + 1.0, "impact-bass-1", -8.0], [L(5) + 2.0, "pop", -4.0], [L(7) + 6.0, "pop", -4.0], [L(9), "riser", -8.0], [L(9) + 3.0, "impact-bass-2", -4.0]]

func teo(t: float) -> Dictionary:
	var ex := "dac-y" if t < L(3) else ("quyet-tam" if t < L(8) else ("ngai" if t < L(9) else "soc"))
	var d := teo_mac(ex)
	var w1 := ap(5, 1.0, 2.0); var w2 := ap(7, 1.0, 6.0)
	d["can"] = {"p": ap(2, 1.0), "r": [["ra đòn đầu", w1], ["một chọi nhiều", w2]], "l": [], "tilt": 0.09 * But.eo(w1) + 0.09 * But.eo(w2)}
	return d

func ve() -> void:
	# mây hai bên, nét giữa son
	var pm := pg(-2.0, 2.0)
	for i in 8:
		var x := -1150.0 + i * 330.0
		Canh.may(self, Vector2(x, 330 + (i % 2) * 40), 1.4, pm, 70.0 + i, tt)
	But.chu(self, "TRẬN TRONG TRANH", Vector2(0, 470), 44, But.SON, 1, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(0, 1.0, 3.0))
	But.chu(self, "tưởng tượng · không có trong truyện", Vector2(0, 515), 28, But.ca(But.MUC, 0.75), 2, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(0, 1.0, 4.0))
	# hai người
	var atk := ap(3, 1.0) * (1.0 - ap(8, 1.0))
	var sw := sin(tt * 6.0) * atk
	var push := atk * (0.5 + 0.5 * sin(tt * 1.5)) * 80.0
	var pt := ap(1, 1.0)
	nguoi("tieu", Vector2(460 - push * 0.6, 300), 1.05, {"face": -1, "aF": 1.1 + 0.6 * sw, "eF": 0.4, "aB": 0.4 - 0.3 * sw, "palmF": true, "stride": 0.5 * atk, "lean": -0.1 * atk}, "quyet-tam", pt)
	Canh.nhan(self, "Tiêu Phong", Vector2(460, 410), pt, 34, "sau trận Thiếu Lâm")
	var pq := ap(1, 1.0, 3.0)
	var guard := ap(4, 1.0) * (1.0 - ap(8, 1.0))
	nguoi("quach", Vector2(-460 - push * 0.8, 300), 1.0, {"face": 1, "aF": 1.5 * guard + 0.6, "eF": 1.2 * guard + 0.3, "aB": 1.2 * guard, "eB": 1.2 * guard, "palmF": true, "palmB": true, "crouch": 0.35 * guard, "lean": 0.08 * guard}, "quyet-tam", pq)
	Canh.nhan(self, "Quách Tĩnh", Vector2(-460, 410), pq, 34, "sau Hoa Sơn")
	# 18 | 18
	var p18 := ap(1, 1.0, 6.0) * (1.0 - ap(2, 1.0))
	if p18 > 0.0:
		But.chu(self, "18", Vector2(460, -300), 90, But.MUC, 1, HORIZONTAL_ALIGNMENT_CENTER, -1, p18)
		But.chu(self, "=", Vector2(0, -300), 90, But.SON, 1, HORIZONTAL_ALIGNMENT_CENTER, -1, p18)
		But.chu(self, "18", Vector2(-460, -300), 90, Color("2b3a4a"), 1, HORIZONTAL_ALIGNMENT_CENTER, -1, p18)
	# sóng chưởng từ phải đè sang trái
	if atk > 0.0:
		for k in 4:
			var u := fposmod(tt * 0.7 + k * 0.25, 1.0)
			var x := lerpf(320.0, -260.0, u)
			But.net(self, But.qd(Vector2(x, 0), Vector2(x - 60, 120), Vector2(x, 240)), 18 * (1.0 - u), But.ca(But.MUC, 0.6 * atk * (1.0 - u)), 1.0, 0.2, 0.2, 0.2, k)
		But.chu(self, "100 chiêu đầu", Vector2(0, -40), 50, But.MUC, 1, HORIZONTAL_ALIGNMENT_CENTER, -1, atk * (1.0 - ap(6, 1.0)))
	# câu 7: một chọi nhiều — vòng bóng nhỏ quanh Tiêu
	var p6 := ap(6, 1.0) * (1.0 - ap(7, 1.0))
	if p6 > 0.0:
		for i in 10:
			var ang := TAU * i / 10.0 + tt * 0.2
			Canh.bong(self, Vector2(460, 300) + Vector2(cos(ang) * 330, sin(ang) * 40), 0.4, 0.45 * p6, 180 + i, tt, 0)
		But.chu(self, "một người · mấy trăm cao thủ", Vector2(0, -40), 36, But.MUC, 2, HORIZONTAL_ALIGNMENT_CENTER, -1, p6)
	# câu 8: Quách giữ thành có quân, có Hoàng Dung
	var p7 := ap(7, 1.0) * (1.0 - ap(8, 1.0))
	if p7 > 0.0:
		Canh.thanh(self, -900, -100, 340, 2.0 * p7, 30.0, 4.0, p7)
		nguoi("dung", Vector2(-760, 300), 0.7, {"face": 1, "aF": 1.0, "eF": 0.3}, "dac-y", p7)
		But.chu(self, "mạnh nhất khi giữ thành", Vector2(0, -40), 36, Color("2b3a4a"), 2, HORIZONTAL_ALIGNMENT_CENTER, -1, p7)
	# câu 9: "100 chiêu?"
	var p8 := ap(8, 1.0) * (1.0 - ap(9, 1.0))
	if p8 > 0.0:
		But.chu(self, "chỉ 100 chiêu ?", Vector2(0, -40), 64, But.SON, 1, HORIZONTAL_ALIGNMENT_CENTER, -1, p8)
	# câu 10: hai rồng lao vào nhau
	var p9 := ap(9, 2.0, 0.5)
	if p9 > 0.0:
		var meet := But.ez(ap(9, 3.0, 0.5))
		var hr := Vector2(lerpf(1200.0, 60.0, meet), -190 + 20 * sin(tt * 2.0))
		But.rong(self, Canh.rong_path(hr, Vector2(-1, 0.3), 900, tt, 50, 34, 1.6), 120, But.MUC, p9, tt, 1.0)
		var hl := Vector2(lerpf(-1200.0, -60.0, meet), -170 + 20 * sin(tt * 2.0 + 1.0))
		But.rong(self, Canh.rong_path(hl, Vector2(1, 0.3), 900 + 600 * ap(9, 6.0, 3.0), tt, 60, 40, 2.2), 100, Color("2b3a4a"), p9, tt, 2.0)
		if meet >= 1.0:
			Canh.vong(self, Vector2(0, -180), 60 + 80 * fposmod(tt, 1.0), 8.0, 0.6 * (1.0 - fposmod(tt, 1.0)), 7.0, 0.6)
