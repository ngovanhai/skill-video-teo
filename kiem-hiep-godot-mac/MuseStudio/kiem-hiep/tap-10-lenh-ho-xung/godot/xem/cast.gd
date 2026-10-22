extends "res://canh.gd"
# Xem trước: dàn 17 nhân vật của tập với mặt riêng (bút khắc gỗ).

const ROWS := [
	["lenh-ho-xung", "Lệnh Hồ Xung", "vui"], ["dien-ba-quang", "Điền Bá Quang", "gian"], ["teo-tieu-nhi", "Tèo", "vui"],
	["nghi-lam", "Nghi Lâm", "binh"], ["nhac-bat-quan", "Nhạc Bất Quần", "binh"], ["phong-thanh-duong", "Phong Thanh Dương", "ngai"],
	["doanh-doanh", "Nhậm Doanh Doanh", "dac-y"], ["luu-chinh-phong", "Lưu Chính Phong", "binh"], ["khuc-duong", "Khúc Dương", "vui"],
	["nhac-linh-san", "Nhạc Linh San", "vui"], ["lam-binh-chi", "Lâm Bình Chi", "gian"], ["bat-gioi", "Bất Giới", "vui"],
	["luc-truc-ong", "Lục Trúc Ông", "binh"], ["huong-van-thien", "Hướng Vấn Thiên", "quyet-tam"], ["phuong-chung", "Phương Chứng", "binh"],
	["dong-phuong-bat-bai", "Đông Phương Bất Bại", "dac-y"], ["nham-nga-hanh", "Nhậm Ngã Hành", "gian"],
]
var names: Array = []


func _palette() -> void:
	sky_top = Color("#f1e2c0")
	sky_bot = Color("#e6cf9f")
	vign_a = 0.25


func _build() -> void:
	for i in ROWS.size():
		var r: Array = ROWS[i]
		var back := i < 9
		var col := i if back else i - 9
		var n := 9 if back else 8
		var x := 960.0 + (col - (n - 1) * 0.5) * (200.0 if back else 215.0)
		var y := 470.0 if back else 930.0
		var a := actor(r[0], Vector2(x, y), 1.0 if col < n / 2 else -1.0)
		a.expr = r[2]
		a.size = 1.05
		a.base = "stance" if r[0] in ["huong-van-thien", "dien-ba-quang"] else "rest"
		names.append([Vector2(x, y + 40), r[1]])


func _sky(c: Node2D) -> void:
	vgrad(c, Rect2(-200, -200, 2320, 1480), sky_top, sky_bot)
	grain(c, Rect2(0, 0, 1920, 1080), 900, Color(ink, 0.06), 7)
	c.draw_line(Vector2(60, 470), Vector2(1860, 470), Color(ink, 0.35), 3.0, true)
	c.draw_line(Vector2(60, 930), Vector2(1860, 930), Color(ink, 0.35), 3.0, true)


func _front(c: Node2D) -> void:
	for nm in names:
		nhan(c, nm[0], nm[1], 20)
