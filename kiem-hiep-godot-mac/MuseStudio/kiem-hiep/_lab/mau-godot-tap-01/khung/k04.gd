# k04 thuở bé Tiêu Phong (đọc từ phải sang trái): cửa ải Nhạn Môn bên phải → nhà họ Kiều ở giữa → chùa Thiếu Lâm bên trái.
extends Khung

func _init() -> void:
	X = 12000.0; travel = 2.6

func cam(t: float) -> Array:
	var keys := [[-9.0, Vector2(700, -40), 1.15], [L(1), Vector2(560, 0), 0.95], [L(2), Vector2(260, 0), 0.9], [L(3), Vector2(-20, 20), 1.15],
		[L(4), Vector2(-680, 0), 1.1], [L(5), Vector2(0, 0), 0.72], [L(6), Vector2(-640, 160), 2.4]]
	return Khung.keycam(keys, t, 2.0)

func sfx() -> Array:
	return [[L(0) + 0.5, "whoosh", -10.0], [L(1), "impact-bass-2", -10.0], [L(3), "pop", -10.0], [L(4), "click", -8.0], [L(6), "chime", -6.0]]

func teo(t: float) -> Dictionary:
	return teo_mac("buon" if t > L(1) and t < L(3) else ("dac-y" if t > L(5) else "binh"))

func ve() -> void:
	# núi + cửa ải bên phải
	But.nui(self, 150, 1300, 300, 520, 4.0, Color("6b6e70"), pg(-2.0, 2.5), 3.0)
	But.nui(self, -1300, 200, 300, 260, 9.0, Color("8a8c86"), ap(3, 2.5), 2.0)
	Canh.cua_ai(self, Vector2(700, 300), 0.9, pg(-1.2, 2.2), 4.0)
	Canh.nhan(self, "Nhạn Môn Quan", Vector2(700, -330), pg(0.6, 1.2), 44)
	Canh.dan_nhan(self, Vector2(lerpf(1300, 200, fposmod(tt * 0.04, 1.0)), -420), 0.9, tt, 0.7 * pg(0.0, 1.5), 7, -1.0)
	Canh.dat(self, -1250, 1250, 300, pg(-1.5, 2.0), 1.0)
	# phục kích: bóng người từ hai bên đá
	var amb := ap(1, 1.5) * (1.0 - ap(3, 1.5))
	for i in 6:
		var side := 1.0 if i % 2 == 0 else -1.0
		var x := 700 + side * (420 - 160 * But.ez(ap(1, 2.0, i * 0.3))) + side * (i / 2) * 50.0
		Canh.bong(self, Vector2(x, 300), 0.75, 0.75 * amb, i, tt, 2)
	if amb > 0.0:
		But.loang(self, Vector2(700, 250), 220 * amb, 70 * amb, Color("3a3a40"), 3.0, amb * 0.6)
	# người cha bế đứa bé đi về nhà họ Kiều
	var walk := But.ez(ap(2, 3.0, 1.0))
	var pa := ap(2, 0.8) * (1.0 - ap(3, 1.2, 2.0))
	if pa > 0.0:
		var fx := lerpf(620.0, 180.0, walk)
		Canh.bong(self, Vector2(fx, 300), 1.0, 0.85 * pa, 11.0, tt, 0)
		draw_colored_polygon(But.blob_pts(Vector2(fx + 34, 180), 30, 22, 2.0, 0.1, 16), But.ca(Color("e9dcc0"), pa))
		Canh.nhan(self, "Tiêu Viễn Sơn", Vector2(fx, -20), pa, 30)
		for k in 8:
			var u := k / 7.0
			if u < walk: draw_circle(Vector2(lerpf(620, 180, u), 306), 5, But.ca(But.MUC, 0.4))
	# nhà họ Kiều
	Canh.nha_tranh(self, Vector2(-40, 300), 1.1, ap(2, 2.0, 2.0), 5.0)
	var pk := ap(3, 1.0)
	if pk > 0.0:
		Canh.bong(self, Vector2(-250, 300), 0.9, 0.55 * pk, 21.0, tt, 0)
		Canh.bong(self, Vector2(-170, 300), 0.82, 0.45 * pk, 22.0, tt, 0)
		Canh.nhan(self, "Kiều Tam Hoè", Vector2(-210, 400), pk, 32, "cha mẹ nuôi")
	var kid := ap(3, 1.0, 1.5)
	var kx := lerpf(80.0, -560.0, But.ez(ap(4, 2.2)))
	if kid > 0.0:
		var punch := ap(4, 0.4, 2.0) * (0.5 + 0.5 * sin(tt * 4.0))
		nguoi("tieu", Vector2(kx, 300), 0.5, {"face": -1, "aF": 0.2 + 1.3 * punch, "eF": 1.0 - punch, "stride": 0.4 * ap(4, 1.0, 2.0), "crouch": 0.3 * ap(4, 1.0, 2.0)}, "vui", kid)
		Canh.nhan(self, "Kiều Phong", Vector2(kx, 400), kid * (1.0 - ap(4, 0.5)) + ap(5, 0.5), 30)
		# vệt mực xanh trên ngực
		var mk := ap(6, 1.0, 1.0)
		if mk > 0.0:
			But.loang(self, Vector2(kx - 4, 300 - 112), 14 * mk, 11 * mk, Color("2f5f9a"), 7.0, mk)
	# chùa Thiếu Lâm bên trái
	var tl := ap(4, 2.0)
	if tl > 0.0:
		draw_rect(Rect2(-1150, 300 - 200 * tl, 380, 200 * tl), But.ca(Color("c9b48a"), 0.9 * tl))
		draw_rect(Rect2(-1010, 300 - 120 * tl, 100, 120 * tl), But.ca(Color("5b2a1e"), 0.9 * tl))
		Canh.mai(self, Vector2(-960, 300 - 200 * tl), 460, 90, tl, 3.0)
		Canh.cay(self, Vector2(-1200, 300), 0.8, tl, 2.0, Color("4f6a3a"))
		nguoi("huyenkho", Vector2(-760, 300), 0.9, {"face": 1, "aF": 0.9 + 0.3 * sin(tt * 2.0), "eF": 0.6, "palmF": true}, "binh", tl)
		Canh.nhan(self, "Huyền Khổ", Vector2(-760, 400), tl, 32, "chùa Thiếu Lâm")
	# câu 6: hai vế đối nhau
	var ir := ap(5, 1.2)
	if ir > 0.0:
		But.chu(self, "người Khiết Đan", Vector2(400, -470), 48, But.MUC, 2, HORIZONTAL_ALIGNMENT_CENTER, -1, ir)
		But.chu(self, "võ học nước Tống", Vector2(-600, -470), 48, But.SON, 2, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(5, 1.2, 1.0))
		But.net(self, PackedVector2Array([Vector2(180, -485), Vector2(-360, -485)]), 6, But.ca(But.MUC, 0.6), ap(5, 1.0, 0.6), 0.2, 0.2)
