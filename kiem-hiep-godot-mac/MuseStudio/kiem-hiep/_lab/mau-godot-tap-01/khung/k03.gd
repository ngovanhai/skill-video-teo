# k03 dòng sông thời gian: song.gd vẽ sông chạy từ phải sang trái; khung này điều máy quay bám đầu sông và tô vệt màu vương triều.
extends Khung

const WW := 2400.0
const VET := [[2.6, "c9a45c", 1], [5.6, "6f5a8a", 1], [-2.6, "b8573a", 3], [-5.4, "5a6f4a", 3], [-7.4, "8a6a3a", 4]]

func _init() -> void:
	X = 0.0; travel = 2.4; wide = true; post = 1.0

func _rx(t: float) -> float:   # trùng với song.gd reveal()
	return lerpf(6.4 * WW, -8.4 * WW, But.ez(But.pg(t, 0.0, E(4) + 1.0)))

func cam(t: float) -> Array:
	var keys := [
		[-1.0, Vector2(6.0 * WW, 220), 0.38],
		[L(1), Vector2(4.2 * WW, 220), 0.36],
		[L(2), Vector2(2.6 * WW, 200), 0.55],
		[L(3), Vector2(-1.0 * WW, 220), 0.36],
		[L(4), Vector2(-6.0 * WW, 220), 0.38],
		[L(5), Vector2(-3.4 * WW, 200), 0.5],
		[L(6), Vector2(-1.0 * WW, 0), 0.052],
		[L(7) + 1.0, Vector2(4.4 * WW, 0), 0.3],
		[E(7), Vector2(4.4 * WW, 0), 0.3],
	]
	var pos: Vector2 = keys[0][1]; var z: float = keys[0][2]
	for i in range(1, keys.size()):
		var u := But.ez(But.pg(t, keys[i][0], 2.4 if i != 6 else 3.0))
		pos = pos.lerp(keys[i][1], u); z = exp(lerpf(log(z), log(keys[i][2]), u))
	# câu 1 và câu 4: bám theo đầu sông đang vẽ
	if t < L(1):
		pos.x = minf(pos.x, _rx(t) + 1600.0)
	return [pos, z]

func sfx() -> Array:
	return [[0.0, "whoosh-cinematic", -8.0], [L(1), "pop", -8.0], [L(1) + 0.4, "pop", -8.0], [L(3), "pop", -8.0], [L(3) + 0.4, "pop", -8.0], [L(4), "pop", -8.0], [L(6), "riser", -10.0]]

func teo(t: float) -> Dictionary:
	return teo_mac("ngai" if t > L(6) else "binh")

func ve() -> void:
	for v in VET:
		var p := ap(v[2], 1.6)
		if p <= 0.0: continue
		var x: float = v[0] * WW
		But.loang(self, Vector2(x, 470), 1100, 90, Color(v[1]), x, p * 0.5)
