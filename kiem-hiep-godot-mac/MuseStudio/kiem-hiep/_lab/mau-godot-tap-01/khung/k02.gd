# k02 bàn vẽ: Tèo hiện sau bàn vẽ, chào; máy quay lùi xa cho thấy cuộn giấy dài và hai nửa dành cho hai người.
extends Khung

func _init() -> void:
	X = 0.0; travel = 0.8; keep = false; post = 0.8

func cam(t: float) -> Array:
	var z := 0.9
	z = lerpf(z, 0.42, But.ez(ap(3, 2.5)))
	z = lerpf(z, 0.9, But.ez(ap(5, 2.0)))
	return [Vector2(0, lerpf(-60.0, 0.0, ap(3, 2.0))), z]

func sfx() -> Array:
	return [[L(0), "sparkle", -6.0], [L(3), "whoosh", -8.0], [L(3) + 2.5, "pop", -8.0], [L(3) + 4.0, "pop", -8.0], [L(5), "click", -6.0]]

func teo(t: float) -> Dictionary:
	var up := But.eo(But.pg(t, -0.8, 1.0))
	var wave := ap(0, 0.3) * (1.0 - ap(0, 0.5, 2.0))
	var grind := ap(5, 0.5)
	var pose := {"face": -1, "aF": 0.6 + wave * 1.8 + 0.25 * sin(tt * 6.0) * wave, "eF": 0.6 + 0.6 * wave, "aB": -0.1, "prop": "" if wave > 0.1 else "but"}
	if grind > 0.0:
		pose.aF = 0.9 + 0.12 * sin(tt * 5.0); pose.eF = 0.8 + 0.15 * cos(tt * 5.0); pose.prop = ""
		pose.lean = 0.12
	var ex := "vui" if t < E(1) else ("ngai" if t < E(2) else "binh")
	if t > L(4): ex = "dac-y"
	var sink := But.ez(pg(E(5) - 0.2, 1.0))
	return {"pos": Vector2(1260, 1000 + 400 * (1.0 - up) + 900 * sink), "s": 1.7, "pose": pose, "expr": ex, "a": 1.0, "ban": up * (1.0 - sink)}

func ve() -> void:
	# hai nửa cuộn tranh: vạch giữa, mũi tên, tên
	var p := ap(3, 1.5)
	if p <= 0.0: return
	var y := -50.0
	var dash := -560.0
	while dash < lerpf(-560.0, 560.0, p):
		But.net(self, PackedVector2Array([Vector2(0, dash), Vector2(0, dash + 34)]), 6, But.ca(But.SON, 0.8), 1.0, 0.1, 0.1, 0.1, dash)
		dash += 60.0
	var pr := ap(3, 1.2, 2.2); var pl := ap(3, 1.2, 3.8)
	But.net(self, PackedVector2Array([Vector2(160, y), Vector2(2600, y)]), 22, But.MUC, pr, 0.1, 0.0, 0.3, 1.0)
	But.net(self, PackedVector2Array([Vector2(2600, y), Vector2(2460, y - 90)]), 18, But.MUC, clampf(pr * 3 - 2, 0, 1))
	But.net(self, PackedVector2Array([Vector2(2600, y), Vector2(2460, y + 90)]), 18, But.MUC, clampf(pr * 3 - 2, 0, 1))
	But.chu(self, "TIÊU PHONG", Vector2(1400, y - 120), 150, But.MUC, 1, HORIZONTAL_ALIGNMENT_CENTER, -1, pr)
	But.chu(self, "nửa phải · Bắc Tống", Vector2(1400, y + 170), 80, But.ca(But.MUC, 0.7), 2, HORIZONTAL_ALIGNMENT_CENTER, -1, pr)
	But.net(self, PackedVector2Array([Vector2(-160, y), Vector2(-2600, y)]), 22, Color("2b3a4a"), pl, 0.1, 0.0, 0.3, 2.0)
	But.net(self, PackedVector2Array([Vector2(-2600, y), Vector2(-2460, y - 90)]), 18, Color("2b3a4a"), clampf(pl * 3 - 2, 0, 1))
	But.net(self, PackedVector2Array([Vector2(-2600, y), Vector2(-2460, y + 90)]), 18, Color("2b3a4a"), clampf(pl * 3 - 2, 0, 1))
	But.chu(self, "QUÁCH TĨNH", Vector2(-1400, y - 120), 150, Color("2b3a4a"), 1, HORIZONTAL_ALIGNMENT_CENTER, -1, pl)
	But.chu(self, "nửa trái · Nam Tống", Vector2(-1400, y + 170), 80, But.ca(Color("2b3a4a"), 0.7), 2, HORIZONTAL_ALIGNMENT_CENTER, -1, pl)
	# câu 5: điểm gặp nhau ở giữa
	var m := ap(4, 1.2, 2.0)
	if m > 0.0:
		But.dau(self, Vector2(0, y), 200, ["GẶP", "NHAU"], m, 0.0, 7.0)
