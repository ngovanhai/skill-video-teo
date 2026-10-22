# k09 quẻ Càn: sáu hào vẽ từ dưới lên, con rồng leo theo từng nấc, hào trên cùng hoá son (Kháng Long Hữu Hối) và rồng lùi lại;
# rồi chuyện con số: 28 ô rút còn 18 (bản sửa), 18 còn 12 thời Sử Hoả Long, vảy rồng rụng dần.
extends Khung

const CUT := [2, 5, 8, 10, 13, 16, 19, 22, 24, 27]   # 10 chiêu rườm rà bị bỏ
const NAC := ["ẩn dưới nước", "hiện trên đồng", "", "", "bay trên trời", "bay quá cao"]

func _init() -> void:
	X = -9600.0; ben = -1.0

func cam(t: float) -> Array:
	return Khung.keycam([[-9.0, Vector2(-300, -80), 0.9], [L(1), Vector2(-420, -80), 1.0], [L(3), Vector2(-420, -220), 1.25], [L(4), Vector2(-380, -150), 1.05],
		[L(5), Vector2(420, -60), 1.0], [L(7), Vector2(300, 0), 0.9], [L(8), Vector2(560, -80), 1.2], [L(9), Vector2(300, 40), 0.95], [L(10), Vector2(0, 0), 0.8]], t, 2.0)

func sfx() -> Array:
	return [[L(2), "click", -10.0], [L(3), "riser", -10.0], [L(3) + 2.0, "impact-bass-1", -8.0], [L(6), "whoosh", -10.0], [L(8), "pop", -8.0], [L(9), "glitch-1", -14.0]]

func teo(t: float) -> Dictionary:
	return teo_mac("ngai" if t < L(2) else ("soc" if t > L(3) and t < L(4) else ("dac-y" if t > L(6) and t < L(9) else ("buon" if t > L(9) else "binh"))))

func ve() -> void:
	Canh.dat(self, -1250, 1250, 300, pg(-2.0, 2.0), 9.0)
	# chữ "KINH DỊCH" + chữ quẻ
	var p1 := ap(1, 1.0)
	But.chu(self, "KINH DỊCH", Vector2(-900, -470), 54, But.MUC, 1, HORIZONTAL_ALIGNMENT_CENTER, -1, p1)
	But.chu(self, "quẻ Càn · quẻ của trời", Vector2(-900, -420), 30, But.ca(But.MUC, 0.7), 2, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(1, 1.0, 3.0))
	# sáu hào dương, vẽ từ dưới lên
	var base := Vector2(-760, 230)
	var red := ap(3, 1.0, 1.5)
	for i in 6:
		var y := base.y - i * 95.0
		var q := ap(2, 0.8, [0.0, 2.5, 3.5, 4.3, 5.0, 7.5][i])
		var col := But.MUC if i < 5 else But.MUC.lerp(But.SON, red)
		But.net(self, PackedVector2Array([Vector2(base.x - 170, y), Vector2(base.x + 170, y)]), 34, col, q, 0.05, 0.08, 0.15, i)
		if NAC[i] != "":
			But.chu(self, NAC[i], Vector2(base.x - 260, y + 10), 30, But.ca(But.MUC, 0.8), 2, HORIZONTAL_ALIGNMENT_RIGHT, -1, q)
	# rồng leo theo hào
	var climb := 0.0
	var stg := [[L(2), 0.0], [L(2) + 2.5, 1.0], [L(2) + 5.0, 4.0], [L(2) + 7.5, 5.0]]
	for s in stg:
		climb = lerpf(climb, s[1], But.ez(But.pg(lt, s[0], 1.5)))
	climb -= 0.9 * But.ez(ap(4, 2.5, 1.5))   # hối: lùi lại một nấc
	var pr := ap(2, 1.0)
	if pr > 0.0:
		var head := Vector2(base.x + 260, base.y - climb * 95.0 - 30)
		var path := Canh.rong_path(head, Vector2(0.15, -1.0).normalized(), 520, tt, 40, 30, 1.6)
		But.rong(self, path, 64, But.MUC, pr, tt, 3.0)
	# Kháng Long Hữu Hối
	var pk := ap(3, 1.2, 1.5)
	if pk > 0.0:
		Canh.cot(self, ["KHÁNG", "LONG", "HỮU", "HỐI"], Vector2(-160, -470), 64, pk, But.SON, 1)
		But.chu(self, "rồng lên cùng cực ắt có lúc hối", Vector2(-160, 70), 28, But.ca(But.MUC, 0.75), 2, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(3, 1.0, 4.0))
	var p4 := ap(4, 1.0)
	if p4 > 0.0:
		var ring := 1.0 - ap(4, 3.0, 2.0) * 0.3
		Canh.vong(self, Vector2(-160, 160), 120 * ring, 6.0, 0.6 * p4, 3.0, 0.5)
		But.chu(self, "đánh 7 · giữ 3", Vector2(-160, 175), 40, But.MUC, 1, HORIZONTAL_ALIGNMENT_CENTER, -1, p4)
	# lưới chưởng: 28 → 18 → 12
	var pg5 := ap(5, 1.0)
	if pg5 > 0.0:
		var b2 := Vector2(170, -360)
		var cut := But.ez(ap(6, 3.0, 1.5))      # 10 ô bị gạch, kéo ra
		var lose := But.ez(ap(9, 2.5, 1.0))      # 6 ô nữa mờ đi
		var kept := 0
		for i in 28:
			var gone := i in CUT
			var at := b2 + Vector2((i % 7) * 86, (i / 7) * 86)
			var a := pg5
			var col := But.MUC
			if gone:
				at += Vector2(0, 340 * cut * cut)
				a *= 1.0 - cut
			else:
				kept += 1
				if kept > 12: a *= 1.0 - 0.8 * lose
			if a <= 0.01: continue
			draw_rect(Rect2(at, Vector2(70, 70)), But.ca(col, 0.85 * a), false, 3.0)
			But.chu(self, "chưởng", at + Vector2(35, 44), 18, But.ca(col, 0.8 * a), 2, HORIZONTAL_ALIGNMENT_CENTER, -1, a)
		var shown := 28 - int(10 * cut) - int(6 * lose)
		But.chu(self, str(shown), b2 + Vector2(700, 140), 120, But.SON if shown < 28 else But.MUC, 1, HORIZONTAL_ALIGNMENT_CENTER, -1, pg5)
	# Tiêu Phong + Hư Trúc ngồi bàn
	var p6 := ap(6, 1.0) * (1.0 - ap(9, 1.0))
	if p6 > 0.0:
		nguoi("tieu", Vector2(330, 300), 0.6, {"face": 1, "crouch": 0.6, "aF": 0.8 + 0.2 * sin(tt * 2.0), "eF": 0.6}, "binh", p6)
		nguoi("hu", Vector2(600, 300), 0.6, {"face": -1, "crouch": 0.6, "aF": 0.7, "eF": 0.8}, "vui", p6)
		draw_rect(Rect2(400, 230, 130, 18), But.ca(Color("6b4430"), p6))
		Canh.nhan(self, "Tiêu Phong · Hư Trúc", Vector2(465, 400), p6, 30)
	# bản sửa
	var p8 := ap(8, 1.0)
	if p8 > 0.0:
		But.dau(self, Vector2(1080, -420), 120, ["BẢN", "SỬA"], p8, 0.1, 22.0)
		But.chu(self, "bản cũ không có đoạn này", Vector2(1080, -320), 26, But.SON, 2, HORIZONTAL_ALIGNMENT_CENTER, -1, ap(8, 1.0, 2.5))
	# Sử Hoả Long
	var p9 := ap(9, 1.0)
	if p9 > 0.0:
		Canh.bong(self, Vector2(1000, 300), 0.8, 0.7 * p9, 91.0, tt, 0)
		Canh.nhan(self, "Sử Hoả Long", Vector2(1000, 400), p9, 30, "Ỷ Thiên Đồ Long Ký")
	# vảy rụng
	var p10 := ap(10, 1.0)
	if p10 > 0.0:
		for i in 12:
			var u := fposmod(tt * 0.12 + But.h1(i) , 1.0)
			var at := Vector2(-500 + But.h1(i + 3) * 1300, -400 + u * 700)
			var r := 16.0 + 8.0 * But.h1(i + 7)
			var pts := PackedVector2Array()
			for k in 9:
				var ang := PI * k / 8.0 + tt * (0.5 + But.h1(i))
				pts.append(at + Vector2(cos(ang), sin(ang) * 0.6) * r)
			draw_colored_polygon(pts, But.ca(But.MUC, 0.5 * p10 * (1.0 - u)))
