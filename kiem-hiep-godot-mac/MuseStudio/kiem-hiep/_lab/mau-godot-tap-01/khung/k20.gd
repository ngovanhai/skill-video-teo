# k20 tờ giấy dán thêm "ngoài đời": bóng tướng Quách Bảo Ngọc, dòng thời Mông Cổ mở rộng; "lịch sử là giấy, truyện là nét mực"; họ Tiêu của người Khiết Đan.
# Hết khung thì tờ giấy được bóc ra, trả lại bức tường cho cảnh nhìn toàn cuộn.
extends Khung

func _init() -> void:
	X = -19200.0; ben = -1.0; travel = 1.0; post = 1.2

func cam(t: float) -> Array:
	return Khung.keycam([[-9.0, Vector2(400, -80), 0.95], [L(0), Vector2(700, -80), 1.35], [L(2), Vector2(780, -60), 1.3], [L(3), Vector2(820, -80), 1.4]], t, 1.6)

func sfx() -> Array:
	return [[L(0) + 0.3, "pop", -6.0], [L(0) + 1.0, "click", -8.0], [L(2), "sparkle", -10.0], [L(3), "pop", -8.0]]

func teo(t: float) -> Dictionary:
	return teo_mac("ngai" if t < L(2) else "dac-y")

func ve() -> void:
	var peel := pg(done() + 0.4, 1.2)
	var p := But.eo(ap(0, 0.8, 0.2)) * (1.0 - peel)
	if p <= 0.0: return
	var c := Vector2(780, -80) + Vector2(0, -400 * peel)
	var sz := Vector2(860, 620) * p
	draw_set_transform(c, -0.025 + 0.2 * peel)
	# bóng đổ + tờ giấy hơi vàng + băng dính hai góc
	draw_rect(Rect2(-sz * 0.5 + Vector2(12, 14), sz), Color(0, 0, 0, 0.18 * p))
	draw_rect(Rect2(-sz * 0.5, sz), But.ca(Color("f4ead2"), p))
	draw_rect(Rect2(-sz * 0.5, sz), But.ca(But.MUC, 0.5 * p), false, 3.0)
	for k in 2:
		var cn := Vector2(-sz.x * 0.5 + 40, -sz.y * 0.5) if k == 0 else Vector2(sz.x * 0.5 - 40, -sz.y * 0.5)
		draw_set_transform(c + cn.rotated(-0.025), (-0.6 if k == 0 else 0.6) - 0.025)
		draw_rect(Rect2(-55, -16, 110, 32), Color(0.85, 0.82, 0.7, 0.75 * p))
		draw_set_transform(c, -0.025 + 0.2 * peel)
	But.dau(self, Vector2(-sz.x * 0.5 + 90, -sz.y * 0.5 + 90), 110, ["NGOÀI", "ĐỜI"], ap(0, 0.8, 1.0) * (1.0 - peel), -0.08, 71.0)
	# Quách Bảo Ngọc: bóng người cầm cờ
	var q := ap(0, 1.0, 2.5) * (1.0 - peel)
	if q > 0.0:
		Canh.bong(self, Vector2(-220, 230), 0.95, 0.8 * q, 201.0, tt, 2)
		But.chu(self, "Quách Bảo Ngọc", Vector2(-220, -180), 40, But.MUC, 1, HORIZONTAL_ALIGNMENT_CENTER, -1, q)
		But.chu(self, "tướng có thật", Vector2(-220, -140), 26, But.ca(But.MUC, 0.7), 2, HORIZONTAL_ALIGNMENT_CENTER, -1, q)
	var q1 := ap(1, 1.0) * (1.0 - peel)
	if q1 > 0.0:
		But.chu(self, "người Hán · giỏi binh pháp", Vector2(170, -180), 32, But.MUC, 2, HORIZONTAL_ALIGNMENT_CENTER, -1, q1)
		But.chu(self, "phò Thành Cát Tư Hãn", Vector2(170, -135), 32, But.MUC, 2, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(1, 1.0, 2.0) * (1.0 - peel))
		But.chu(self, "thời Mông Cổ mở rộng", Vector2(170, -90), 32, But.ca(But.MUC, 0.75), 2, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(1, 1.0, 4.0) * (1.0 - peel))
	var q2 := ap(2, 1.0) * (1.0 - peel)
	if q2 > 0.0:
		But.chu(self, "lịch sử là giấy", Vector2(170, 0), 40, But.MUC, 1, HORIZONTAL_ALIGNMENT_CENTER, -1, q2)
		But.chu(self, "truyện là nét mực", Vector2(170, 50), 40, But.SON, 1, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(2, 1.0, 3.0) * (1.0 - peel))
	var q3 := ap(3, 1.0) * (1.0 - peel)
	if q3 > 0.0:
		But.net(self, PackedVector2Array([Vector2(-380, 130), Vector2(380, 130)]), 3, But.ca(But.MUC, 0.4), q3, 0.1, 0.1)
		But.chu(self, "TIÊU", Vector2(-260, 230), 72, But.MUC, 1, HORIZONTAL_ALIGNMENT_CENTER, -1, q3)
		But.chu(self, "dòng họ lớn của người Khiết Đan", Vector2(110, 200), 30, But.MUC, 2, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(3, 1.0, 1.5) * (1.0 - peel))
		But.chu(self, "trong sử nước Liêu", Vector2(110, 245), 30, But.ca(But.MUC, 0.7), 2, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(3, 1.0, 3.0) * (1.0 - peel))
	draw_set_transform(Vector2.ZERO)
