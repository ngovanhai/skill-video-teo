# Dòng sông thời gian chạy dọc chân cuộn giấy (k03 vẽ nó từ phải sang trái), các mốc vương triều và hai đường biên.
extends Node2D

const W := 2400.0
const XR := 6.4 * W
const XL := -8.4 * W
const Y := 450.0
var tt := 0.0
var k3: Khung       # main gán

# mốc: [x, chữ lớn, chữ nhỏ, câu k03 xuất hiện]
const MOC := [
	[2.6 * W, "BẮC TỐNG", "cuối thế kỷ XI · Thiên Long Bát Bộ", 1],
	[5.6 * W, "ĐẠI LIÊU", "người Khiết Đan", 1],
	[-2.6 * W, "NAM TỐNG", "đầu thế kỷ XIII · Xạ Điêu", 3],
	[-5.4 * W, "KIM", "chiếm nửa phía bắc", 3],
	[-7.4 * W, "MÔNG CỔ", "Thiết Mộc Chân", 4],
]
const BIEN := [[4.4 * W, "biên giới Tống · Liêu"], [-6.5 * W, "biên giới Nam Tống · phương bắc"]]

func yat(x: float) -> float:
	return Y + 22.0 * sin(x / 900.0) + 12.0 * sin(x / 310.0 + 1.0)

func reveal() -> float:   # mép trái đã vẽ tới đâu
	if k3 == null or k3.lt < -0.2: return XR + 1.0
	return lerpf(XR, XL, But.ez(But.pg(k3.lt, 0.0, k3.E(4) + 1.0)))

func _draw() -> void:
	var rx := reveal()
	if rx > XR: return
	var cam := get_viewport().get_camera_2d()
	var half := 960.0 / cam.zoom.x + 300.0
	var a := maxf(rx, cam.position.x - half); var b := minf(XR, cam.position.x + half)
	if b <= a: return
	var step := maxf(40.0, 30.0 / cam.zoom.x)
	var top := PackedVector2Array(); var bot := PackedVector2Array()
	var x := b
	while x >= a:
		var w := 34.0 + 10.0 * sin(x / 700.0)
		top.append(Vector2(x, yat(x) - w * 0.5)); bot.append(Vector2(x, yat(x) + w * 0.5))
		x -= step
	if top.size() < 2: return
	But.strip_cols(self, top, bot, PackedColorArray([Color("5a7d8c", 0.55)]))
	But.net(self, top, 4, But.ca(But.MUC, 0.7), 1.0, 0.0, 0.0, 0.25, 1.0)
	But.net(self, bot, 3, But.ca(But.MUC, 0.5), 1.0, 0.0, 0.0, 0.25, 2.0)
	# gợn nước chảy sang trái
	var r0 := floori(a / 260.0)
	for r in range(r0, floori(b / 260.0) + 1):
		var rxp := r * 260.0 - fposmod(tt * 60.0, 260.0)
		if rxp < a or rxp > b: continue
		var yy := yat(rxp) + (But.h1(r) - 0.5) * 20.0
		But.net(self, PackedVector2Array([Vector2(rxp, yy), Vector2(rxp - 70, yy + 2)]), 3, But.ca(Color("e9e2cf"), 0.8), 1.0, 0.3, 0.3, 0.1, r)
	# đầu sông đang được vẽ: giọt mực
	if rx > XL + 10 and rx < XR:
		draw_circle(Vector2(rx, yat(rx)), 26, But.ca(But.MUC, 0.85))
	# mốc
	var ka := 1.0
	if k3 and k3.lt > k3.done() + 4.0: ka = 0.6
	for m in MOC:
		if k3 == null: break
		var p := But.pg(k3.lt, k3.L(m[3]), 1.2) * clampf((m[0] - rx) / 500.0 + 1.0, 0.0, 1.0)
		if p <= 0.0 or absf(m[0] - cam.position.x) > half + 600: continue
		var at := Vector2(m[0], yat(m[0]) + 92)
		But.dau(self, at + Vector2(-But.chu_w(m[1], 50, 1) * 0.5 - 50, -16), 64, [m[1].substr(0, 1)], p * ka, 0.04, m[0])
		But.chu(self, m[1], at, 50, But.ca(But.MUC, ka), 1, HORIZONTAL_ALIGNMENT_CENTER, -1, p)
		But.chu(self, m[2], at + Vector2(0, 46), 30, But.ca(But.MUC, 0.7 * ka), 2, HORIZONTAL_ALIGNMENT_CENTER, -1, p)
	# hai đường biên (nét son đứt quãng cắt ngang sông, chạy dọc cuộn)
	for bi in BIEN:
		if k3 == null: break
		var p := But.pg(k3.lt, k3.L(6), 2.0)
		if p <= 0.0 or absf(bi[0] - cam.position.x) > half + 600: continue
		var y := -560.0
		while y < 600.0 * (2.0 * p - 1.0) + 40:
			But.net(self, PackedVector2Array([Vector2(bi[0], y), Vector2(bi[0] + 4, y + 40)]), 7, But.ca(But.SON, 0.8 * ka), 1.0, 0.1, 0.1, 0.1, y)
			y += 70.0
		But.chu(self, bi[1], Vector2(bi[0] + 24, -500), 30, But.ca(But.SON, ka), 2, HORIZONTAL_ALIGNMENT_LEFT, -1, p)
	# khoảng trống giữa hai thời: "hơn 100 năm"
	if k3:
		var p := But.pg(k3.lt, k3.L(3), 1.5)
		if p > 0.0 and absf(cam.position.x) < half + 800:
			But.chu(self, "· · · hơn một trăm năm · · ·", Vector2(0, yat(0) + 96), 34, But.ca(But.MUC, 0.7 * ka), 2, HORIZONTAL_ALIGNMENT_CENTER, -1, p)
