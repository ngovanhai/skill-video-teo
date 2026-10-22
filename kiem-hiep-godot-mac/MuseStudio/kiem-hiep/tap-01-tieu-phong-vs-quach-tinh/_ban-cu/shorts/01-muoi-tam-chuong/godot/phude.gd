# Phụ đề short dọc (sinh bởi new-short.mjs; hạ tầng, tập sửa được). Mỗi lần hiện một nhóm 2–4 chữ của câu đang đọc,
# chia giờ theo độ dài chữ. Kiểu ở story.json "phu_de": {font: "res://font/x.ttf" (trống = font đậm đầu tiên trong font/),
# size, mau, vien, y}; "phu_de": false để tắt (khi phim.gd tự vẽ chữ). Nằm ở y≈1380–1600: trên nút của Shorts, dưới hình chính.
extends Node2D

var cfg := {}
var font: Font = ThemeDB.fallback_font
var txt := ""

func _ready() -> void:
	z_index = 100
	var st = JSON.parse_string(FileAccess.get_file_as_string("res://story.json"))
	var pd = st.get("phu_de", {}) if st is Dictionary else {}
	if pd is bool:
		visible = pd
		pd = {}
	cfg = pd
	var f: String = cfg.get("font", "")
	if f == "": f = _font_dam()
	if f != "" and ResourceLoader.exists(f): font = load(f)

func _font_dam() -> String:
	var d := DirAccess.open("res://font")
	if d == null: return ""
	var best := ""
	for n in d.get_files():
		var lo := n.to_lower()
		if not (lo.ends_with(".ttf") or lo.ends_with(".otf")): continue
		if best == "" or lo.contains("bold") or lo.get_basename().ends_with("b"): best = "res://font/" + n
	return best

func at(t: float, line: Dictionary) -> void:
	var s := ""
	if visible and not line.is_empty():
		var groups: Array = []
		var cur: Array = []
		for w in String(line.text).split(" ", false):
			cur.append(w)
			if cur.size() >= 4 or (cur.size() >= 2 and w.right(1) in [",", ".", "?", "!", ":", ";"]):
				groups.append(" ".join(cur)); cur = []
		if not cur.is_empty(): groups.append(" ".join(cur))
		var total := 0
		for g in groups: total += String(g).length()
		var d: float = line.dur
		var t0: float = line.t0
		var p := clampf((t - t0) / maxf(d, 0.01), 0.0, 0.999) * total
		var acc := 0
		for g in groups:
			acc += String(g).length()
			if p < acc:
				s = g
				break
	if s != txt:
		txt = s
		queue_redraw()

func _draw() -> void:
	if txt == "": return
	var size := int(cfg.get("size", 66))
	var w := font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	if w > 960.0:
		size = int(size * 960.0 / w)
		w = font.get_string_size(txt, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	var pos := Vector2(540.0 - w / 2.0, float(cfg.get("y", 1490)))
	draw_string_outline(font, pos, txt, HORIZONTAL_ALIGNMENT_LEFT, -1, size, maxi(8, size / 4), Color(cfg.get("vien", "#000000")))
	draw_string(font, pos, txt, HORIZONTAL_ALIGNMENT_LEFT, -1, size, Color(cfg.get("mau", "#ffffff")))
