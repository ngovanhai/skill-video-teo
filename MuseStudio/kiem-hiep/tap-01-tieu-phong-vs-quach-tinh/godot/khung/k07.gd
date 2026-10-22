# k07 Cái Bang: đám áo vá trên đường, Uông Kiếm Thông trao gậy trúc xanh, câu "Bắc Kiều Phong · Nam Mộ Dung" dựng thành hai cột chữ; Kiều Phong vẽ cao giữa đám đệ tử.
extends Khung

func _init() -> void:
	X = 9600.0; travel = 2.4

func cam(t: float) -> Array:
	return Khung.keycam([[-9.0, Vector2(300, 0), 0.85], [L(1), Vector2(-200, 40), 1.15], [L(2), Vector2(-120, -60), 1.5], [L(3), Vector2(0, -80), 0.85],
		[L(5), Vector2(500, -260), 1.2], [L(6), Vector2(-60, 0), 0.9]], t, 2.0)

func sfx() -> Array:
	return [[L(1) + 3.0, "pop", -10.0], [L(2), "chime", -8.0], [L(3), "whoosh", -10.0], [L(3) + 2.0, "impact-bass-1", -10.0], [L(6), "sparkle", -10.0]]

func teo(t: float) -> Dictionary:
	return teo_mac("vui" if t < L(5) else ("dac-y" if t < L(6) else "buon"))

func ve() -> void:
	# con đường đất vòng qua làng
	Canh.dat(self, -1250, 1250, 300, pg(-2.0, 2.0), 7.0)
	But.net(self, But.bez(Vector2(-1250, 360), Vector2(-500, 260), Vector2(300, 420), Vector2(1250, 330), 30), 46, Color("b49a6a", 0.6), pg(-1.5, 2.0), 0.2, 0.2, 0.25, 3.0)
	Canh.cay(self, Vector2(-1100, 300), 1.1, pg(-1.0, 1.5), 7.0, Color("5f7a3c"))
	Canh.cay(self, Vector2(1120, 300), 0.9, pg(-0.6, 1.5), 8.0, Color("6f8a4a"))
	# đám áo vá: bóng người đeo túi, đi trên đường
	var walk := pg(-1.0, 1.0)
	for i in 9:
		var x := -1050.0 + i * 240.0 + fposmod(tt * 18.0 + i * 37.0, 120.0) - 60.0
		if absf(x) < 260: continue
		Canh.bong(self, Vector2(x, 300 + (i % 3) * 12), 0.7, 0.55 * walk, 70 + i, tt, 0)
		# miếng vá
		draw_rect(Rect2(x - 10, 300 - 90 + (i % 3) * 12, 14, 12), But.ca(Color("8a6a3a"), 0.7 * walk))
	Canh.nhan(self, "Cái Bang", Vector2(-800, 410), pg(0.5, 1.0), 40, "bang hội đông người nhất thiên hạ")
	# Uông Kiếm Thông trao gậy
	var give := But.ez(ap(1, 2.5, 2.5))
	var pu := ap(1, 1.0) * (1.0 - ap(3, 1.5) * 0.7)
	if pu > 0.0:
		nguoi("uong", Vector2(-260, 300), 0.95, {"face": 1, "aF": 0.5 + 0.6 * give, "eF": 0.3, "prop": "gay-xanh" if give < 0.5 else ""}, "binh", pu)
		Canh.nhan(self, "Uông Kiếm Thông", Vector2(-260, 400), pu, 32, "bang chủ đời trước")
	var grow := ap(0, 2.0)
	var ts := lerpf(0.9, 1.25, ap(6, 2.0))
	nguoi("tieu", Vector2(160, 300), ts, {"face": -1 if lt < L(3) else 1, "aF": 0.9 + 0.5 * give, "eF": 0.4, "prop": "gay-xanh" if give >= 0.5 else "", "lean": -0.03}, "quyet-tam" if lt < L(6) else "binh", grow)
	Canh.nhan(self, "Kiều Phong", Vector2(160, 400), grow, 36, "bang chủ Cái Bang" if give >= 1.0 else "")
	# câu 3: gậy là lời hứa — ba chữ hiện quanh ngọn gậy
	var hua := ap(2, 1.0) * (1.0 - ap(3, 1.0, 1.0))
	if hua > 0.0:
		var words := ["cả bang", "người ăn xin", "đất nước"]
		for i in 3:
			var ang := -PI * 0.5 + (i - 1) * 0.7
			var at := Vector2(200, -60) + Vector2(cos(ang), sin(ang)) * 260
			But.chu(self, words[i], at, 40, But.ca(Color("2f6a3a"), 0.9), 2, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(2, 0.8, 1.0 + i * 0.8) * hua)
			But.net(self, PackedVector2Array([Vector2(200, -60), at.lerp(Vector2(200, -60), 0.25)]), 3, But.ca(Color("2f6a3a"), 0.5), ap(2, 0.8, 1.0 + i * 0.8) * hua, 0.2, 0.2)
	# câu 4–5: hai cột chữ — bắc ở phải, nam ở trái
	var pb := ap(3, 1.5)
	if pb > 0.0:
		Canh.cot(self, ["BẮC", "KIỀU", "PHONG"], Vector2(980, -470), 72, pb, But.MUC, 1)
		Canh.cot(self, ["NAM", "MỘ", "DUNG"], Vector2(-980, -470), 72, ap(3, 1.5, 1.8), Color("2b3a4a"), 1)
		But.chu(self, "phương bắc", Vector2(980, -10), 30, But.ca(But.MUC, 0.7), 2, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(4, 1.0))
		But.chu(self, "phương nam", Vector2(-980, -10), 30, But.ca(Color("2b3a4a"), 0.7), 2, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(4, 1.0, 1.0))
		var pm := ap(4, 1.0, 2.0)
		if pm > 0.0:
			nguoi("mo", Vector2(-640, 300), 0.7, {"face": 1, "aF": 0.3, "eF": 0.5}, "dac-y", pm * 0.8)
			Canh.nhan(self, "Mộ Dung Phục", Vector2(-640, 400), pm * 0.8, 28)
	# câu 6: cuộn giấy dài với con số bị che
	var pz := ap(5, 1.2) * (1.0 - ap(6, 1.0))
	if pz > 0.0:
		var w := 520.0 * But.ez(ap(5, 2.0))
		Canh.to_giay(self, Vector2(500, -260), Vector2(80 + w, 150), pz, 0.02, 0)
		But.chu(self, "HÀNG LONG · ? CHƯỞNG", Vector2(500, -245), 44, But.MUC, 1, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(5, 1.0, 1.0) * pz)
		But.chu(self, "để dành trang sau", Vector2(500, -195), 28, But.SON, 2, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(5, 1.0, 3.5) * pz)
	# câu 7: đệ tử vây quanh, ngước nhìn; một vệt mây đen ở chân trời
	var p7 := ap(6, 1.5)
	if p7 > 0.0:
		for i in 6:
			var side := -1.0 if i % 2 == 0 else 1.0
			Canh.bong(self, Vector2(160 + side * (200 + (i / 2) * 110), 312), 0.62, 0.6 * p7, 80 + i, tt, 1 if i < 2 else 0)
		But.loang(self, Vector2(-900, -430), 260 * ap(6, 4.0, 2.0), 50, Color("3a3a40"), 9.0, 0.5 * ap(6, 4.0, 2.0))
