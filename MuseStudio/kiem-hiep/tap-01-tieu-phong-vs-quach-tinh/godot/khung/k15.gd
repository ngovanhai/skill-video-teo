# k15 Hoa Sơn: đỉnh núi nhọn giữa biển mây; năm cái tên của lần luận kiếm thứ nhất xếp thành ngũ giác;
# Quách Tĩnh lên đỉnh, đếm 100+ chiêu với Hoàng Dược Sư và Hồng Thất Công, vòng thở đều; dấu BẮC HIỆP vọng lại "Bắc Kiều Phong".
extends Khung

const NGU := [["Trung Thần Thông", "Vương Trùng Dương"], ["Đông Tà", ""], ["Tây Độc", ""], ["Nam Đế", ""], ["Bắc Cái", "Hồng Thất Công"]]

func _init() -> void:
	X = -2400.0; ben = -1.0; travel = 2.2

func cam(t: float) -> Array:
	return Khung.keycam([[-9.0, Vector2(0, 100), 0.8], [L(0), Vector2(0, -60), 0.75, 5.0], [L(1), Vector2(-500, -200), 1.05], [L(2), Vector2(100, -120), 1.0],
		[L(3), Vector2(180, -160), 1.15], [L(4), Vector2(100, -200), 1.45], [L(5), Vector2(0, -180), 0.9]], t, 2.0)

func sfx() -> Array:
	return [[L(0), "whoosh-cinematic", -10.0], [L(1), "chime", -10.0], [L(3), "impact-bass-1", -12.0], [L(3) + 4.0, "impact-bass-1", -12.0], [L(5) + 1.0, "impact-bass-2", -6.0]]

func teo(t: float) -> Dictionary:
	return teo_mac("ngai" if t < L(2) else ("quyet-tam" if t < L(4) else ("vui" if t < L(5) else "dac-y")))

func ve() -> void:
	# núi: ba đỉnh nhọn
	var pn := pg(-2.0, 3.0)
	But.nui(self, -1250, 1250, 380, 900, 51.0, Color("5a5e62"), pn, 3.0)
	But.nui(self, -1250, 1250, 420, 520, 52.0, Color("8a8c86"), pn, 5.0)
	Canh.nhan(self, "Hoa Sơn", Vector2(-950, -460), pg(0.5, 1.0), 52, "nơi luận kiếm")
	# biển mây trôi ngang
	for i in 7:
		var x := fposmod(-1250.0 + i * 380.0 + tt * 14.0, 2500.0) - 1250.0
		Canh.may(self, Vector2(x, 160 + (i % 3) * 60), 1.3, pn, 30.0 + i, tt)
	# lần luận kiếm thứ nhất: năm cái tên xếp ngũ giác
	var p1 := ap(1, 1.0) * (1.0 - ap(2, 1.0) * 0.85)
	if p1 > 0.0:
		var c := Vector2(-560, -220)
		for i in 5:
			var ang := -PI * 0.5 + TAU * i / 5.0
			var at := c + Vector2(cos(ang), sin(ang)) * 170
			var q := ap(1, 0.8, 1.0 + i * 1.0) * p1
			But.chu(self, NGU[i][0], at, 34 if i == 0 else 38, But.SON if i == 4 else But.MUC, 1, HORIZONTAL_ALIGNMENT_CENTER, -1, q)
			if NGU[i][1] != "":
				But.chu(self, NGU[i][1], at + Vector2(0, 38), 24, But.ca(But.MUC, 0.7), 2, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(1, 0.8, 2.0 + i * 1.0) * p1)
		But.chu(self, "lần thứ nhất", c + Vector2(0, 10), 30, But.ca(But.MUC, 0.6), 2, HORIZONTAL_ALIGNMENT_CENTER, -1, p1)
	# đỉnh: Quách Tĩnh + hai đối thủ
	var top := Vector2(100, -40)
	var p2 := ap(2, 1.0)
	if p2 > 0.0:
		var spar := ap(3, 1.0)
		var sw := sin(tt * 4.0) * spar
		nguoi("quach", top, 0.8, {"face": 1, "aF": 1.0 + 0.6 * sw, "eF": 0.5, "aB": 0.6 - 0.4 * sw, "palmF": true, "stride": 0.4 * spar}, "quyet-tam", p2)
		Canh.nhan(self, "Quách Tĩnh", top + Vector2(0, -400), p2, 30, "lần luận kiếm thứ hai")
		var who := 0 if lt < L(3) + 4.0 else 1
		var pa := ap(3, 1.0) * (1.0 - ap(3, 0.8, 4.0)) if who == 0 else ap(3, 0.8, 4.0)
		if who == 0:
			Canh.bong(self, top + Vector2(330, 10), 0.8, 0.75 * pa, 171.0, tt, 1)
			Canh.nhan(self, "Hoàng Dược Sư", top + Vector2(330, -360), pa, 28, "Đông Tà · chủ đảo Đào Hoa")
		else:
			nguoi("hong", top + Vector2(330, 10), 0.8, {"face": -1, "aF": 1.0 - 0.6 * sw, "eF": 0.5, "palmF": true, "prop": ""}, "dac-y", pa)
			Canh.nhan(self, "Hồng Thất Công", top + Vector2(330, -360), pa, 28, "Bắc Cái · thầy của anh")
		# bộ đếm chiêu
		if spar > 0.0:
			var n1 := int(108 * But.ez(ap(3, 3.5)))
			var n2 := int(106 * But.ez(ap(3, 3.5, 4.0)))
			But.chu(self, "%d chiêu" % n1, Vector2(700, -420), 46, But.MUC, 1, HORIZONTAL_ALIGNMENT_CENTER, -1, spar)
			But.chu(self, "%d chiêu" % n2, Vector2(700, -350), 46, But.MUC, 1, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(3, 1.0, 4.0))
			But.chu(self, "100+ · 100+", Vector2(700, -280), 30, But.SON, 2, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(3, 1.0, 7.0))
	# hơi thở đều
	var p4 := ap(4, 1.0)
	if p4 > 0.0:
		var br := fposmod(tt * 0.3, 1.0)
		for k in 3:
			var r := fposmod(br + k / 3.0, 1.0)
			Canh.vong(self, top + Vector2(0, -150), 40 + 220 * r, 5.0, (1.0 - r) * 0.6 * p4, k, 0.8)
		But.chu(self, "càng về cuối · hơi càng đều", Vector2(-420, -120), 36, But.ca(But.MUC, 0.85), 2, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(4, 1.0, 2.0) * (1.0 - ap(5, 1.0)))
		But.chu(self, "nền Mã Ngọc dạy năm nào", Vector2(-420, -70), 28, But.ca(But.MUC, 0.6), 2, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(4, 1.0, 4.0) * (1.0 - ap(5, 1.0)))
	# BẮC HIỆP + tiếng vọng
	var p5 := ap(5, 1.0, 0.8)
	if p5 > 0.0:
		But.dau(self, Vector2(-380, -260), 170, ["BẮC", "HIỆP"], p5, -0.06, 41.0)
		var echo := ap(5, 2.0, 3.5)
		for k in 3:
			But.chu(self, "Bắc Kiều Phong", Vector2(-380 + 240 + k * 200, -300 - k * 30), 34 - k * 6, But.ca(But.MUC, (0.6 - k * 0.18) * echo), 2, HORIZONTAL_ALIGNMENT_CENTER, -1, echo)
