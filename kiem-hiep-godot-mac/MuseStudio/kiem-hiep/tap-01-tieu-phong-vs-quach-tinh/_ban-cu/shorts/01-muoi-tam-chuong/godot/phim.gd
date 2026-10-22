# Short 01 · "Mười tám chưởng từng là hai mươi tám" — dọc 1080×1920, nét cọ của tập 01 (But / Canh / Nguoi).
# Một con rồng mực đứng dọc khung, 28 vảy son trên lưng. Mỗi đời người, vảy rụng xuống đáy khung thành đống: 28 → 18 → 12.
# Vùng hình y 190–1350; dưới đó để trống cho phụ đề (phude.gd) và nút của Shorts.
extends Node2D

const GROUND := 1335.0
var main: Node
var t := 0.0
var T := {}          # id câu → [t0, dur]

func setup(m: Node) -> void:
	main = m
	for l in m.lines: T[l.id] = [float(l.t0), float(l.dur)]

func at(tt: float, _s: Dictionary, _l: Dictionary) -> void:
	t = tt
	queue_redraw()

func a0(id: String) -> float: return T[id][0]
func ad(id: String) -> float: return T[id][1]
func am(id: String, f: float) -> float: return a0(id) + ad(id) * f      # mốc f (0..1) trong câu
func fade(a: float, b: float, d := 0.4) -> float:                        # hiện từ a, tắt ở b
	return clampf((t - a) / d, 0.0, 1.0) * clampf((b - t) / d, 0.0, 1.0)

# nội suy theo mốc [[giây, giá trị], …], đoạn giữa hai mốc đi êm
func kf(tt: float, k: Array) -> float:
	if tt <= k[0][0]: return k[0][1]
	for i in range(1, k.size()):
		if tt < k[i][0]:
			return lerpf(k[i - 1][1], k[i][1], But.ez((tt - k[i - 1][0]) / (k[i][0] - k[i - 1][0])))
	return k[-1][1]

# ---------------------------------------------------------------- rồng + vảy
func rx(tt: float) -> float:
	return kf(tt, [[a0("s02-01"), 560.0], [a0("s02-01") + 0.9, 700.0], [a0("k09-11") - 0.3, 700.0]])
func rw(tt: float) -> float:
	return kf(tt, [[am("k09-10", 0.7), 120.0], [am("k09-10", 1.0), 102.0], [a0("k09-11") + 1.0, 90.0]])
func ra(tt: float) -> float:
	return kf(tt, [[a0("k09-08"), 1.0], [a0("k09-08") + 0.6, 0.16], [a0("k09-10") - 0.2, 0.16], [a0("k09-10") + 0.5, 1.0], [a0("s03-01"), 1.0], [a0("s03-01") + 0.6, 0.28]])
func rpath(tt: float) -> PackedVector2Array:
	var x := rx(tt)
	return Canh.rong_path(Vector2(x - 40, 300), Vector2(-0.18, -1.0), 1010.0, tt * 0.55, 150.0, 40, 1.3)

func pop_t(k: int) -> float:
	if k < 18: return -1.0
	return am("s01-01", 0.62) + (k - 18) * 0.05
func drop_t(k: int) -> float:
	if k >= 18: return am("k09-07", 0.55) + (27 - k) * 0.11
	if k >= 12: return am("k09-10", 0.74) + (17 - k) * 0.14
	return INF

func vay_pos(q: PackedVector2Array, k: int, w: float) -> Vector2:
	var i := 4 + int(round(k * (q.size() - 9) / 27.0))
	var d := (q[i + 1] - q[i - 1]).normalized()
	return q[i] + Vector2(-d.y, d.x) * w * 0.16 * (1.0 if k % 2 == 0 else -1.0)

func vay(c: Vector2, sz: float, rot: float, col: Color) -> void:
	draw_set_transform(c, rot)
	draw_colored_polygon(PackedVector2Array([Vector2(0, -sz), Vector2(sz * 0.62, 0), Vector2(0, sz * 0.9), Vector2(-sz * 0.62, 0)]), col)
	draw_line(Vector2(0, -sz * 0.7), Vector2(0, sz * 0.6), But.ca(But.MUC, col.a * 0.35), 2.0)
	draw_set_transform(Vector2.ZERO)

func rong_ve() -> void:
	var p := 0.35 + 0.65 * But.eo(clampf(t / 0.9, 0.0, 1.0))
	var a := ra(t)
	var w := rw(t)
	var q := rpath(t)
	But.loang(self, Vector2(rx(t), 820), 330, 520, But.ca(Color("8c8172"), 0.10 * a), 7.0, 1.0)
	But.rong(self, q, w, But.ca(But.MUC, a), p, t * 0.55, 3.0)
	for k in 28:
		var tp := pop_t(k)
		var td := drop_t(k)
		if t < tp or t >= td: continue
		var i := 4 + int(round(k * (q.size() - 9) / 27.0))
		if float(i) / q.size() > p: continue
		var pp := clampf((t - tp) / 0.25, 0.0, 1.0)
		var u := float(k) / 27.0
		var glow := 1.0 + (0.6 * (1.0 - pp) if k >= 18 else 0.0)
		vay(vay_pos(q, k, w), 17.0 * (1.0 - u * 0.4) * glow * maxf(pp, 0.01), 0.2, But.ca(But.SON, a))

# vảy đã rụng: rơi xuống đáy khung rồi nằm lại thành đống
func vay_rung() -> void:
	var dim := kf(t, [[a0("k09-08"), 1.0], [a0("k09-08") + 0.5, 0.35], [a0("k09-10") - 0.2, 0.35], [a0("k09-10") + 0.4, 1.0]])
	for k in 28:
		var td := drop_t(k)
		if t < td: continue
		var p0 := vay_pos(rpath(td), k, rw(td))
		var dt := t - td
		var land := GROUND - 6.0 - But.h1(k * 1.3) * 26.0
		var tf := sqrt(2.0 * maxf(land - p0.y, 1.0) / 1500.0)
		var dx := sin(k * 2.1) * 120.0
		var pos: Vector2; var rot: float
		if dt < tf:
			pos = Vector2(p0.x + dx * dt / tf + sin(dt * 7.0 + k) * 18.0, p0.y + 750.0 * dt * dt)
			rot = dt * (5.0 + k % 3)
		else:
			pos = Vector2(p0.x + dx, land); rot = tf * (5.0 + k % 3)
		vay(pos, 15.0, rot, But.ca(But.SON, (0.95 if dt < tf else 0.7) * dim))

# ---------------------------------------------------------------- số chưởng (góc trên trái)
func dem() -> void:
	var a := fade(0.0, a0("k09-11") + 0.3, 0.3) * (1.0 - fade(a0("k09-08"), a0("k09-10"), 0.35))
	if a <= 0.0: return
	var n := 18; var since := 0.0
	var marks := [[am("s01-01", 0.62) + 0.5, 28], [am("k09-07", 0.55) + 1.1, 18], [am("k09-10", 0.74) + 0.8, 12]]
	for m in marks:
		if t >= m[0]: n = m[1]; since = t - m[0]
	var kk := 1.0 + 0.35 * (1.0 - But.eo(clampf(since / 0.35, 0.0, 1.0))) if since > 0.0 or n != 18 else 1.0
	var col := But.SON if n != 28 else But.MUC
	draw_set_transform(Vector2(190, 330), 0.0, Vector2(kk, kk))
	But.chu(self, str(n), Vector2(0, 0), 170, But.ca(col, a), 1)
	draw_set_transform(Vector2.ZERO)
	But.chu(self, "chưởng", Vector2(190, 395), 44, But.ca(But.MUC, 0.8 * a), 2)

# ---------------------------------------------------------------- cảnh theo câu
func hook() -> void:
	# triện "28" đóng giữa thân rồng ở cuối câu hook
	var ts := am("s01-01", 0.62) + 0.55
	var a := fade(ts, a0("s02-01") + 0.7, 0.3)
	if a > 0.0:
		But.dau(self, Vector2(560, 860), 300, ["28"], clampf((t - ts) / 0.6, 0.0, 1.0) * a, -0.08, 11.0)
	var a2 := fade(0.0, ts + 0.2, 0.25)
	if a2 > 0.0:
		But.chu(self, "Quách Tĩnh", Vector2(190, 470), 46, But.ca(But.MUC, a2), 1)

func tieu_hu() -> void:
	var at := fade(a0("s02-01") + 0.5, a0("k09-08") + 0.4, 0.4)
	if at > 0.0:
		var push := But.eo(clampf((t - a0("s02-01") - 0.6) / 0.6, 0.0, 1.0))
		Nguoi.ve(self, "tieu", Vector2(240, GROUND), 1.8, {"face": 1, "aF": 0.4 + 1.0 * push, "eF": 0.3, "aB": 0.3, "palmF": true, "stride": 0.35, "lean": 0.06 * push}, "quyet-tam", t, at)
		Canh.nhan(self, "Tiêu Phong", Vector2(250, 540), at, 48)
	var ah := fade(am("k09-07", 0.18), a0("k09-08") + 0.4, 0.4)
	if ah > 0.0:
		Nguoi.ve(self, "hu", Vector2(530, GROUND), 1.65, {"face": -1, "aF": 0.6, "eF": 0.9, "aB": 0.2, "talk": true}, "binh", t, ah)
		Canh.nhan(self, "Hư Trúc", Vector2(440, 660), ah, 44, "em kết nghĩa")

func truyen() -> void:
	var a := fade(a0("k09-08"), a0("k09-10") + 0.2, 0.35)
	if a <= 0.0: return
	But.chu(self, "THẬP BÁT CHƯỞNG", Vector2(540, 260), 84, But.ca(But.SON, a), 1, HORIZONTAL_ALIGNMENT_CENTER, -1, clampf((t - am("k09-08", 0.08)) / 0.5, 0.0, 1.0))
	var who := [["tieu", Vector2(250, 800), "Tiêu Phong", 0.05], ["hong", Vector2(560, 1065), "Hồng Thất Công", 0.55], ["quach", Vector2(850, GROUND), "Quách Tĩnh", 0.82]]
	for i in who.size():
		var w: Array = who[i]
		var p := clampf((t - am("k09-08", w[3])) / 0.4, 0.0, 1.0) * a
		if p <= 0.0: continue
		if i > 0:
			var prev: Vector2 = who[i - 1][1]
			var cur: Vector2 = w[1]
			But.net(self, But.qd(prev + Vector2(70, -150), (prev + cur) * 0.5 + Vector2(60, -260), cur + Vector2(-80, -220)), 9, But.ca(But.SON, a), p, 0.1, 0.4, 0.2, i)
		Nguoi.ve(self, w[0], w[1], 1.1, {"face": 1 if i < 2 else -1, "aF": 1.2, "eF": 0.3, "palmF": true}, "binh", t, p)
		But.chu(self, w[2], Vector2(w[1].x, w[1].y - 425), 42, But.ca(But.MUC, p), 1, HORIZONTAL_ALIGNMENT_CENTER)

func su_hoa_long() -> void:
	var a := fade(a0("k09-10"), a0("k09-11") + 0.3, 0.4)
	if a <= 0.0: return
	Canh.nhan(self, "Trăm năm sau", Vector2(250, 560), clampf((t - a0("k09-10") - 0.3) / 0.5, 0.0, 1.0) * a, 56)
	var p := clampf((t - am("k09-10", 0.45)) / 0.5, 0.0, 1.0) * a
	if p > 0.0:
		Canh.bong(self, Vector2(260, GROUND), 2.6, p * 0.9, 5.0, t, 1)
		Canh.nhan(self, "Sử Hoả Long", Vector2(260, 760), p, 46, "Ỷ Thiên Đồ Long Ký")

func gia_di() -> void:
	var a := fade(a0("k09-11"), a0("s03-01") + 0.2, 0.4)
	if a <= 0.0: return
	var s := ["28", "18", "12"]
	for i in 3:
		var p := clampf((t - am("k09-11", 0.05 + i * 0.12)) / 0.35, 0.0, 1.0) * a
		But.chu(self, s[i], Vector2(220, 330 + i * 230), 150, But.ca(But.SON if i > 0 else But.MUC, p), 1)
		if i > 0: But.net(self, PackedVector2Array([Vector2(220, 130 + i * 230), Vector2(220, 205 + i * 230)]), 8, But.ca(But.MUC, 0.6 * p), 1.0, 0.1, 0.4, 0.1, i)
	But.chu(self, "già đi", Vector2(220, 1010), 64, But.ca(But.MUC, a * clampf((t - am("k09-11", 0.6)) / 0.5, 0.0, 1.0)), 2)

func ket() -> void:
	var a := fade(a0("s03-01") - 0.1, INF, 0.4)
	if a <= 0.0: return
	Nguoi.ve(self, "teo", Vector2(360, GROUND), 2.2, {"face": 1, "aF": 2.4, "eF": 0.4, "aB": 0.3, "talk": t < a0("s03-01") + ad("s03-01")}, "vui", t, a)
	But.dau(self, Vector2(800, 400), 220, ["Tèo", "Kể"], clampf((t - a0("s03-01") - 0.2) / 0.5, 0.0, 1.0) * a, 0.05, 21.0)
	var pb := clampf((t - am("s03-01", 0.35)) / 0.35, 0.0, 1.0) * a
	if pb > 0.0:
		var k := 1.0 + 0.08 * sin(t * 6.0) * pb
		draw_set_transform(Vector2(800, 680), 0.0, Vector2(k, k) * But.eo(pb))
		draw_colored_polygon(But.blob_pts(Vector2.ZERO, 210, 56, 9.0, 0.03, 32), But.ca(But.SON, pb))
		But.chu(self, "ĐĂNG KÝ", Vector2(0, 20), 58, But.ca(But.GIAY, pb), 1)
		draw_set_transform(Vector2.ZERO)

# ---------------------------------------------------------------- nền giấy
func nen() -> void:
	draw_rect(Rect2(0, 0, 1080, 1920), But.GIAY)
	for i in 8:
		var k := i * 14.0
		draw_rect(Rect2(0, k, 1080, 14), Color(0.55, 0.45, 0.3, 0.06 - i * 0.007))
		draw_rect(Rect2(0, 1920 - k - 14, 1080, 14), Color(0.55, 0.45, 0.3, 0.06 - i * 0.007))
		draw_rect(Rect2(k, 0, 14, 1920), Color(0.55, 0.45, 0.3, 0.05 - i * 0.006))
		draw_rect(Rect2(1066 - k, 0, 14, 1920), Color(0.55, 0.45, 0.3, 0.05 - i * 0.006))
	But.nui(self, -40, 1120, GROUND + 10, 300, 4.0, But.ca(Color("8c8172"), 0.16), 1.0, 3.0)
	draw_line(Vector2(40, GROUND + 8), Vector2(1040, GROUND + 8), But.ca(But.MUC, 0.25), 3.0)

func _draw() -> void:
	nen()
	rong_ve()
	vay_rung()
	tieu_hu()
	truyen()
	su_hoa_long()
	gia_di()
	hook()
	dem()
	ket()

func sfx() -> Array:
	var o := [[0.05, "whoosh-cinematic", -4.0], [am("s01-01", 0.62), "sparkle", -6.0], [am("s01-01", 0.62) + 0.55, "impact-bass-1", -2.0],
		[a0("s02-01") + 0.5, "whoosh", -8.0], [a0("k09-08"), "whoosh-short", -6.0], [a0("k09-10"), "whoosh-cinematic", -6.0],
		[am("s03-01", 0.35), "pop", -4.0], [a0("s03-01") + 0.2, "impact-bass-2", -5.0]]
	for k in range(12, 28):
		if k % 3 == 0: o.append([drop_t(k), "click", -12.0])
	return o
