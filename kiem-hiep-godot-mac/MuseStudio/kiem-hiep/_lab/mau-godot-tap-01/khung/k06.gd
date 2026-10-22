# k06 mũi tên: Triết Biệt dạy cung, vạch đếm nghìn lần kéo; một mũi tên hạ hai chim điêu; bảy thầy Giang Nam; vách núi đêm, Mã Ngọc dạy thở.
extends Khung

func _init() -> void:
	X = -14400.0; ben = -1.0

func cam(t: float) -> Array:
	return Khung.keycam([[-9.0, Vector2(-600, 0), 1.1], [L(2), Vector2(-450, -180), 0.8], [L(4), Vector2(80, 0), 0.92], [L(6), Vector2(640, -40), 1.1],
		[L(7), Vector2(300, -40), 0.82], [L(8), Vector2(200, 0), 0.75]], t, 2.0)

func sfx() -> Array:
	return [[L(1), "click", -10.0], [L(2) + 2.6, "whoosh-short", -4.0], [L(2) + 3.0, "impact-bass-2", -8.0], [L(3), "chime", -8.0], [L(4), "whoosh", -10.0], [L(6), "riser", -12.0]]

func teo(t: float) -> Dictionary:
	return teo_mac("soc" if t > L(2) + 2.8 and t < L(3) + 1.0 else ("buon" if t > L(5) and t < L(6) else "binh"))

func ve() -> void:
	Canh.dat(self, -1250, 1250, 300, pg(-2.0, 2.0), 6.0)
	But.nui(self, -1250, 300, 300, 160, 21.0, Color("9fb07a"), pg(-2.0, 2.0), 2.0)
	for i in 10:
		Canh.co(self, Vector2(-1200 + i * 130, 302), 0.7, pg(-1.0, 1.0), 40 + i, tt)
	# Triết Biệt + Quách Tĩnh kéo cung
	var draw_n := int(1000 * ap(1, ld[1] if ls.size() > 1 else 5.0))
	var pull := 0.5 + 0.5 * sin(tt * 3.0) if lt < L(2) + 2.4 else (1.0 if lt < L(2) + 2.6 else 0.3)
	nguoi("triet", Vector2(-860, 300), 1.0, {"face": 1, "prop": "cung", "aF": 1.3, "eF": 0.2, "aB": 0.9}, "binh", pg(-1.5, 1.0))
	Canh.nhan(self, "Triết Biệt", Vector2(-860, 400), pg(0.3, 1.0), 36, "thần tiễn của Thiết Mộc Chân")
	nguoi("quach", Vector2(-520, 300), 0.66, {"face": 1, "prop": "cung", "aF": 1.4, "eF": 0.15, "aB": 1.1 - 0.6 * pull, "eB": 1.2 * pull, "lean": -0.06}, "quyet-tam", pg(-1.0, 1.0))
	if ap(1, 0.5) > 0.0:
		Canh.vach(self, Vector2(-1100, -300), mini(int(draw_n / 50.0), 20), 1.0, 0.8)
		But.chu(self, "%d lần" % draw_n, Vector2(-860, -380), 54, But.MUC, 1, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(1, 0.5))
	# hai chim điêu, một mũi tên
	var shot := ap(2, 0.5, 2.5)
	var fall := ap(2, 2.0, 3.0)
	for i in 2:
		var ang := tt * 0.6 + i * PI
		var c := Vector2(-280 + 160 * i, -330) + Vector2(cos(ang), sin(ang) * 0.3) * 120 * (1.0 - shot)
		if shot >= 1.0:
			c = Vector2(-200 + 60 * i, -330).lerp(Vector2(-150 + 140 * i, 270), fall * fall)
		var a := ap(2, 1.0) if fall < 1.0 else 0.4
		Canh.chim(self, c, 2.6, tt if shot < 1.0 else 0.0, a, i * 5.0)
	if shot > 0.0 and fall < 1.0:
		var a0 := Vector2(-460, 120); var a1 := Vector2(-120, -370)
		var head := a0.lerp(a1, minf(1.0, shot * 1.2))
		But.net(self, PackedVector2Array([a0.lerp(head, 0.7), head]), 5, But.MUC, 1.0, 0.0, 0.0, 0.0)
	var name := ap(3, 1.2)
	if name > 0.0:
		But.chu(self, "ANH HÙNG XẠ ĐIÊU", Vector2(-200, -470), 72, But.MUC, 1, HORIZONTAL_ALIGNMENT_CENTER, -1, name)
		But.chu(self, "anh hùng bắn chim điêu", Vector2(-200, -420), 32, But.ca(But.MUC, 0.7), 2, HORIZONTAL_ALIGNMENT_CENTER, -1, name)
	# bảy thầy Giang Nam
	var p7 := ap(4, 1.0)
	if p7 > 0.0:
		var slump := ap(5, 1.5)
		for i in 7:
			var x := lerpf(-1300.0, -80.0 + i * 70.0, But.ez(ap(4, 2.5, i * 0.15)))
			Canh.bong(self, Vector2(x, 300 + slump * 6.0), 0.78 - slump * 0.06, 0.7 * p7, 50 + i, tt * (1.0 - slump), 0)
		Canh.nhan(self, "Giang Nam Thất Quái", Vector2(130, 400), ap(4, 1.0, 2.0), 34, "bảy thầy từ phương nam")
		if slump > 0.0:
			for i in 3:
				But.chu(self, "?", Vector2(-40 + i * 160, -10 - 20 * sin(tt * 2.0 + i)), 60, But.ca(But.MUC, 0.6), 1, HORIZONTAL_ALIGNMENT_CENTER, -1, slump)
	# vách núi đêm: Mã Ngọc dạy thở
	var pn := ap(6, 1.5)
	if pn > 0.0:
		Canh.troi(self, 300, 1300, Color("1c2433"), 0.75 * pn, -620, 300)
		draw_circle(Vector2(1050, -400), 50, But.ca(Color("f2e6c0"), pn))
		But.nui(self, 450, 1250, 300, 520, 33.0, Color("4a4a52"), pn, 1.0)
		var top := Vector2(780, -60)
		Canh.bong(self, top + Vector2(-90, 0), 0.75, 0.9 * pn, 61.0, tt, 0)
		Canh.nhan(self, "Mã Ngọc", top + Vector2(-90, -170), pn, 30, "phái Toàn Chân")
		nguoi("quach", top + Vector2(80, 0), 0.6, {"face": -1, "crouch": 0.9, "aF": 0.5, "eF": 1.2, "aB": 0.4, "eB": 1.2}, "ko", pn)
		var br := fposmod(tt * 0.25, 1.0)
		for k in 3:
			var r := fposmod(br + k / 3.0, 1.0)
			Canh.vong(self, top + Vector2(80, -100), 40 + 160 * r, 4.0, (1.0 - r) * 0.6 * pn, k, 0.8)
	# ghi chú góc tranh
	var pnote := ap(7, 1.0)
	if pnote > 0.0:
		Canh.to_giay(self, Vector2(-760, -150), Vector2(420, 200), pnote, -0.04, 0)
		But.chu(self, "khởi đầu chậm", Vector2(-760, -175), 40, But.MUC, 2, HORIZONTAL_ALIGNMENT_CENTER, -1, pnote)
		But.chu(self, "nền nội công bền", Vector2(-760, -110), 40, But.SON, 1, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(7, 1.0, 1.5))
	# câu 9: một làn khói bếp ở chân trời bên phải
	var smoke := ap(8, 2.0, 2.0)
	if smoke > 0.0:
		for i in 5:
			var y := 280 - i * 90 - fposmod(tt * 30.0, 90.0)
			But.net(self, But.qd(Vector2(1180, y), Vector2(1150 + 30 * sin(tt + i), y - 45), Vector2(1180, y - 90)), 8, But.ca(But.MUC, 0.4 * smoke), 1.0, 0.3, 0.3, 0.2, i)
