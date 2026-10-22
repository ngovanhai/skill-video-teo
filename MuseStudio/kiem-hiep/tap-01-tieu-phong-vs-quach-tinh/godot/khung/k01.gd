# k01 giọt mực: giọt rơi, loang thành rồng, rồng tách đôi chạy về hai đầu cuộn; hai người hiện ở hai đầu.
extends Khung

func _init() -> void:
	X = 0.0; pre = 1.2; travel = 0.0; keep = false; post = 1.2

func cam(t: float) -> Array:
	var z := lerpf(1.45, 0.95, But.ez(But.pg(t, 1.0, 5.0)))
	var y := lerpf(-40.0, 0.0, But.ez(But.pg(t, 1.0, 5.0)))
	z = lerpf(z, 0.82, But.ez(pg(L(5), 3.0)))
	return [Vector2(0, y), z]

func sfx() -> Array:
	return [[-0.35, "impact-bass-1", -4.0], [L(0) + 3.6, "whoosh-cinematic", -6.0], [L(1), "chime", -8.0], [L(2), "whoosh", -8.0], [L(3), "whoosh", -8.0], [L(4) + 1.5, "riser", -10.0]]

func teo(_t: float) -> Dictionary:
	return {}

func ve() -> void:
	var t := lt
	# giọt rơi
	if t < -0.3:
		var u := But.pg(t, -1.2, 0.9)
		var p := Vector2(0, lerpf(-700.0, 0.0, u * u))
		draw_colored_polygon(PackedVector2Array([p + Vector2(0, -46), p + Vector2(14, -8), p + Vector2(0, 12), p + Vector2(-14, -8)]), But.MUC)
		draw_circle(p, 14, But.MUC)
		return
	var sp := But.pg(t, -0.3, 0.6)
	But.ban(self, Vector2.ZERO, 120 + 160 * sp, 22, 3.0, But.MUC, sp)
	# vũng mực loang rồi rút dần vào thân rồng
	var lo := But.eo(But.pg(t, -0.3, 1.6)) * (1.0 - But.pg(t, L(0) + 3.5, 2.0) * 0.8)
	But.loang(self, Vector2.ZERO, 180 * lo + 1, 120 * lo + 1, But.MUC, 1.0, lo)
	# một con rồng cuộn tròn rồi tách hai
	var split := But.ez(But.pg(t, L(0) + 3.5, 2.5))
	var face := But.ez(ap(4, 2.0))           # câu 5: hai rồng quay lại nhìn nhau
	var calm := 1.0 - ap(5, 2.0) * 0.6
	for side in [1.0, -1.0]:
		var hx := lerpf(60.0 * side, 700.0 * side, split)
		hx = lerpf(hx, 230.0 * side, face)
		var hy := lerpf(-40.0, -170.0, split) + sin(tt * 1.4 + side) * 20.0 * calm
		var dir := Vector2(side, -0.4).normalized()
		dir = dir.lerp(Vector2(-side, -0.1).normalized(), face).normalized()
		var length := lerpf(260.0, 760.0, But.pg(t, L(0) + 1.0, 4.0))
		var path := Canh.rong_path(Vector2(hx, hy), dir, length, tt, 60.0 * calm + 10.0, 34, 1.7)
		var col := But.MUC if side > 0 else Color("2b3a4a")
		var w := lerpf(40.0, 64.0, split)
		But.rong(self, path, w, col, But.eo(But.pg(t, L(0) + 0.8, 2.5)), tt, side)
	# tên bộ chưởng
	var p1 := ap(1, 1.4)
	But.chu(self, "HÀNG LONG THẬP BÁT CHƯỞNG", Vector2(0, -420), 74, But.MUC, 1, HORIZONTAL_ALIGNMENT_CENTER, -1, p1)
	But.chu(self, "mười tám chưởng hàng phục rồng · Kim Dung", Vector2(0, -360), 34, But.ca(But.MUC, 0.7), 2, HORIZONTAL_ALIGNMENT_CENTER, -1, p1)
	But.dau(self, Vector2(But.chu_w("HÀNG LONG THẬP BÁT CHƯỞNG", 74, 1) * 0.5 + 80, -445), 90, ["18"], ap(1, 0.6, 1.2), 0.08, 5.0)
	# hai người ở hai đầu
	var pt := ap(2, 1.0); var pq := ap(3, 1.0)
	var lift := sin(tt * 2.0) * 3.0
	if pt > 0.0:
		var strike := But.ez(ap(4, 0.6, 1.0))
		nguoi("tieu", Vector2(720, 330 + lift), 0.95, {"face": -1, "aF": lerpf(0.5, 1.6, strike), "eF": lerpf(1.0, 0.0, strike), "palmF": true, "stride": 0.3 * strike, "lean": 0.1 * strike}, "quyet-tam", pt)
		Canh.nhan(self, "Tiêu Phong", Vector2(720, 420), pt, 40, "Bắc Tống · Thiên Long Bát Bộ")
	if pq > 0.0:
		var strike2 := But.ez(ap(4, 0.6, 1.4))
		nguoi("quach", Vector2(-720, 330 - lift), 0.95, {"face": 1, "aF": lerpf(0.5, 1.6, strike2), "eF": lerpf(1.0, 0.0, strike2), "palmF": true, "stride": 0.3 * strike2, "lean": 0.1 * strike2}, "quyet-tam", pq)
		Canh.nhan(self, "Quách Tĩnh", Vector2(-720, 420), pq, 40, "Nam Tống · Anh Hùng Xạ Điêu")
	# dấu hỏi giữa hai rồng
	var q := ap(4, 1.0, 2.5)
	if q > 0.0:
		But.net(self, But.bez(Vector2(-40, -130), Vector2(-40, -230), Vector2(60, -220), Vector2(10, -130)), 16, But.SON, q, 0.1, 0.5)
		draw_circle(Vector2(8, -80), 11 * q, But.SON)
	# hai cửa ải xa xa
	var g := ap(5, 2.0)
	Canh.cua_ai(self, Vector2(1000, 300), 0.45, g, 2.0)
	Canh.cua_ai(self, Vector2(-1000, 300), 0.45, g, 3.0, Color("8c8172"))
	if g > 0.0:
		But.chu(self, "cửa ải", Vector2(1000, 350), 30, But.ca(But.MUC, 0.7), 2, HORIZONTAL_ALIGNMENT_CENTER, -1, g)
		But.chu(self, "cửa ải", Vector2(-1000, 350), 30, But.ca(But.MUC, 0.7), 2, HORIZONTAL_ALIGNMENT_CENTER, -1, g)
