# k21 con dấu: lùi xa thấy cả cuộn; câu trả lời ngắn viết to giữa cuộn; con dấu đỏ "MỘT CHƯỞNG / HAI NGƯỜI" đóng chỗ hai rồng gặp nhau;
# Tèo to ra bàn vẽ để chào + nhắc đăng ký; cuối cùng hai trục cuộn chạy vào giữa, cuộn tranh lại.
extends Khung

const X0 := -21000.0
const X1 := 16200.0
const GH := 620.0
const NEN := Color(0.1, 0.09, 0.08)

func _init() -> void:
	X = 0.0; wide = true; travel = 1.0; pre = 0.0; post = 2.5

func cam(t: float) -> Array:
	return Khung.keycam([[-9.0, Vector2(0, 0), 0.62], [L(0), Vector2(-2400, 0), 0.052, 4.0], [L(1), Vector2(0, -100), 0.26, 3.0],
		[L(2), Vector2(-2400, 0), 0.06, 3.0], [L(4), Vector2(0, 0), 0.3, 3.0], [L(5), Vector2(-500, 0), 0.4, 2.0],
		[L(7), Vector2(-2400, 0), 0.052, 3.0], [E(7) - 1.0, Vector2(-300, 0), 0.25, 3.5]], t, 2.0)

func sfx() -> Array:
	return [[L(0), "whoosh-cinematic", -6.0], [L(1), "pop", -8.0], [L(3), "riser", -12.0], [L(4) + 3.0, "impact-bass-2", -4.0], [L(6), "chime", -6.0], [L(6) + 3.0, "click", -6.0], [L(7) + 2.0, "whoosh", -8.0], [E(7) - 1.0, "whoosh-short", -8.0]]

func teo(t: float) -> Dictionary:
	# câu 1–5: Tèo góc dưới như thường; từ câu 6: to ra sau bàn vẽ như lúc chào ở k02
	if t < L(5) - 0.6:
		return teo_mac("binh" if t < L(1) else ("dac-y" if t < L(2) else ("buon" if t < L(4) else "quyet-tam")), {"aF": 0.9 + 1.2 * ap(4, 0.4, 2.5) * (1.0 - ap(4, 0.5, 3.6))})
	var up := But.eo(pg(L(5) - 0.6, 1.0))
	var sink := But.ez(pg(E(7) - 0.4, 1.2))
	var wave := ap(7, 0.3, 4.0) * (1.0 - ap(7, 0.5, 7.0))
	var bell := ap(6, 0.4, 3.0) * (1.0 - ap(6, 0.4, 5.5))
	var pose := {"face": -1, "aF": 0.6 + 1.6 * maxf(wave, bell) + 0.25 * sin(tt * 6.0) * wave, "eF": 0.6 + 0.6 * maxf(wave, bell), "aB": -0.1, "prop": "" if maxf(wave, bell) > 0.1 else "but"}
	var ex := "binh" if t < L(6) else ("vui" if t < L(7) else "dac-y")
	return {"pos": Vector2(1300, 1000 + 400 * (1.0 - up) + 900 * sink), "s": 1.7, "pose": pose, "expr": ex, "a": 1.0, "ban": up * (1.0 - sink)}

func ve() -> void:
	var roll := But.ez(ap(7, 9.0, 2.0))
	# câu 2: câu trả lời ngắn, viết to giữa cuộn
	var p1 := ap(1, 1.0) * (1.0 - ap(2, 1.0, 2.0) * 0.7) * (1.0 - ap(4, 1.0))
	if p1 > 0.0:
		Canh.to_giay(self, Vector2(0, -330), Vector2(3600, 300), p1, 0.0, 0)
		But.chu(self, "một chưởng đầu: Tiêu Phong", Vector2(0, -370), 130, But.MUC, 1, HORIZONTAL_ALIGNMENT_CENTER, -1, p1)
		But.chu(self, "trận dài: Quách Tĩnh", Vector2(0, -230), 130, Color("2b3a4a"), 1, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(1, 1.0, 4.0) * p1)
	# câu 3–4: hai đầu cuộn sáng lên — cửa ải và toà thành
	var p2 := ap(2, 1.5) * (1.0 - ap(5, 1.5))
	if p2 > 0.0:
		for e in [[12700.0, "CỬA ẢI", "giữ lời thề"], [-19200.0, "TOÀ THÀNH", "giữ dân"]]:
			Canh.vong(self, Vector2(e[0], 0), 1500 + 200 * sin(tt), 60.0, 0.5 * p2, 3.0, 0.8)
			But.chu(self, e[1], Vector2(e[0], -700 - 160), 420, But.SON, 1, HORIZONTAL_ALIGNMENT_CENTER, -1, p2)
			But.chu(self, e[2], Vector2(e[0], 1040), 300, But.MUC, 2, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(2, 1.0, 3.0) * p2)
	var p3 := ap(3, 1.0) * (1.0 - ap(4, 1.0, 4.0))
	if p3 > 0.0:
		But.chu(self, "không dùng để thắng · dùng để đứng chắn", Vector2(-2400, -880), 420, But.MUC, 2, HORIZONTAL_ALIGNMENT_CENTER, -1, p3)
	# câu 5: con dấu đỏ ở chỗ hai rồng gặp nhau
	var p4 := ap(4, 0.35, 3.0)
	if p4 > 0.0:
		var sq := 1.0 + 0.25 * (1.0 - p4)
		But.dau(self, Vector2(0, -60), 720 * sq, ["MỘT CHƯỞNG", "HAI NGƯỜI"], p4, -0.06, 88.0)
		if p4 >= 1.0:
			var r := ap(4, 1.2, 3.3)
			Canh.vong(self, Vector2(0, -60), 400 + 900 * r, 30.0, 0.6 * (1.0 - r), 9.0, 1.0)
	# câu 6: lời nhắc nhỏ dưới con dấu
	var p5 := ap(5, 1.0) * (1.0 - ap(6, 1.0))
	if p5 > 0.0:
		Canh.to_giay(self, Vector2(-500, 470), Vector2(2300, 210), p5, 0.0, 0)
		But.chu(self, "phần so tài: ý kiến riêng của Tèo", Vector2(-500, 450), 72, But.MUC, 2, HORIZONTAL_ALIGNMENT_CENTER, -1, p5)
		But.chu(self, "chi tiết nhân vật: đối chiếu nhiều nguồn", Vector2(-500, 530), 60, But.ca(But.MUC, 0.75), 2, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(5, 1.0, 3.0) * p5)
	# câu 7: đăng ký · chuông · bình luận cặp nhân vật
	var p6 := ap(6, 1.0) * (1.0 - ap(7, 1.0, 1.0))
	if p6 > 0.0:
		var c := Vector2(-1500, 420)
		But.dau(self, c + Vector2(-500, 0), 300, ["ĐĂNG KÝ", "TÈO KỂ"], ap(6, 0.5, 1.0) * p6, -0.05, 91.0)
		# chuông
		var b := ap(6, 0.6, 3.0) * p6
		if b > 0.0:
			var bc := c + Vector2(-50, -20)
			draw_set_transform(bc, 0.25 * sin(tt * 9.0) * (1.0 - ap(6, 0.5, 5.5)))
			draw_colored_polygon(PackedVector2Array([Vector2(-90, 70), Vector2(-70, -30), Vector2(-40, -90), Vector2(0, -105), Vector2(40, -90), Vector2(70, -30), Vector2(90, 70)]), But.ca(Color("c9a45c"), b))
			draw_circle(Vector2(0, 85), 22, But.ca(But.MUC, b))
			draw_set_transform(Vector2.ZERO)
		Canh.to_giay(self, c + Vector2(600, 0), Vector2(780, 260), ap(6, 0.6, 5.0) * p6, 0.02, 0)
		But.chu(self, "cặp nhân vật tiếp theo ?", c + Vector2(600, -20), 56, But.MUC, 1, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(6, 0.6, 5.5) * p6)
		But.chu(self, "viết ở phần bình luận", c + Vector2(600, 50), 46, But.SON, 2, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(6, 0.6, 6.5) * p6)
	# câu 8: hai trục cuộn chạy vào giữa, cuộn tranh lại
	if roll > 0.0:
		var xl := lerpf(X0, -700.0, roll)
		var xr := lerpf(X1, 700.0, roll)
		draw_rect(Rect2(X0 - 2000, -900, xl - X0 + 2000, 1800), NEN)
		draw_rect(Rect2(xr, -900, X1 - xr + 2000, 1800), NEN)
		for x in [xl, xr]:
			var w := 160.0 + 260.0 * roll
			draw_rect(Rect2(x - w * 0.5, -GH - 60, w, 2 * GH + 120), Color("5b3a2a"))
			draw_rect(Rect2(x - w * 0.5, -GH - 60, w * 0.25, 2 * GH + 120), Color(1, 1, 1, 0.06))
			draw_rect(Rect2(x - w * 0.35, -GH - 200, w * 0.7, 140), Color("3a2418"))
			draw_rect(Rect2(x - w * 0.35, GH + 60, w * 0.7, 140), Color("3a2418"))

