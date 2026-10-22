# Hạ tầng tập (sinh bởi teo-kiem-hiep-godot/new-tap.mjs). Sửa được, nhưng giữ hợp đồng gd-render:
#   --from= --to= (dựng theo t, nhảy thẳng tới from được) · --dur in "DUR=" + ghi timeline.json · quit khi hết.
# loi.txt: "## kNN tên | ghi chú {pre=0.6 post=1.0}" mở một đoạn; "[id] lời" là một câu Tèo đọc.
# Hình: res://phim.gd (tập tự viết) nhận setup(main) một lần, at(t, seg, line) mỗi khung, sfx() -> [[giây, tên, dB]].
extends Node2D

const FPS := 30.0
const GAP := 0.7                       # nghỉ giữa hai câu
const PRE := 0.6                       # mặc định: lặng trước câu đầu của đoạn
const POST := 1.0                      # mặc định: lặng sau câu cuối của đoạn
var DUR := 0.0
var t := 0.0
var from := 0.0
var to := INF
var frame := 0
var stop := false

var segs: Array = []                   # {kid, ten, note, t0, t1, lines:[...]}  (t0 = lúc đoạn bắt đầu, kể cả pre)
var lines: Array = []                  # {id, text, t0, dur, seg}
var cues: Array = []                   # [giây, tên sfx, dB]
var phim: Node
var phude: Node                        # res://phude.gd nếu có (short dọc: phụ đề do new-short.mjs sinh), vẽ trên phim
var vo := AudioStreamPlayer.new()
var vo_id := ""
var nhac := AudioStreamPlayer.new()
var sfx_pool: Array = []

func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	for a in args:
		if a.begins_with("--from="): from = float(a.substr(7))
		if a.begins_with("--to="): to = float(a.substr(5))
	_build()
	if "--dur" in args:
		print("DUR=%.3f" % DUR)
		_save_timeline()
		stop = true
		get_tree().quit()
		return
	phim = preload("res://phim.gd").new()
	add_child(phim)
	if phim.has_method("setup"): phim.setup(self)
	if ResourceLoader.exists("res://phude.gd"):
		phude = load("res://phude.gd").new(); add_child(phude)
	if phim.has_method("sfx"):
		for s in phim.sfx(): cues.append([s[0], s[1], s[2] if s.size() > 2 else 0.0])
		cues.sort_custom(func(a, b): return a[0] < b[0])
	add_child(vo); add_child(nhac)
	for i in 6:
		var p := AudioStreamPlayer.new(); add_child(p); sfx_pool.append(p)
	if ResourceLoader.exists("res://nhac.ogg"):
		nhac.stream = load("res://nhac.ogg"); nhac.volume_db = -3.0
	t = from
	# --from / --par: sfx bắt đầu trước from mà còn ngân thì phát tiếp từ đúng chỗ (khớp bản render liền)
	for i in cues.size():
		var c: Array = cues[i]
		if c[0] < from:
			var st: AudioStream = load("res://sfx/lib-%s.mp3" % c[1])
			if st and from - c[0] < st.get_length(): _sfx(i, from - c[0])
	_step()

func _opt(note: String, key: String, def: float) -> float:
	var i := note.find(key + "=")
	if i < 0: return def
	return float(note.substr(i + key.length() + 1).split(" ")[0].replace("}", ""))

func _build() -> void:
	var man := {}
	if FileAccess.file_exists("res://voice/voice.json"):
		man = JSON.parse_string(FileAccess.get_file_as_string("res://voice/voice.json")).lines
	var raw: Array = []
	for ln in FileAccess.get_file_as_string("res://loi.txt").split("\n"):
		ln = ln.strip_edges()
		if ln.begins_with("## "):
			var head := ln.substr(3)
			var bar := head.find("|")
			var name_part := head if bar < 0 else head.substr(0, bar)
			var parts := name_part.strip_edges().split(" ", false)
			raw.append({"kid": parts[0], "ten": " ".join(parts.slice(1)), "note": "" if bar < 0 else head.substr(bar + 1).strip_edges(), "lines": []})
		elif ln.begins_with("[") and not raw.is_empty():
			var id := ln.substr(1, ln.find("]") - 1)
			var text := ln.substr(ln.find("]") + 1).strip_edges()
			var d: float = man[id].dur if man.has(id) else text.split(" ").size() / 4.1
			raw[-1].lines.append({"id": id, "text": text, "dur": d})
	var tc := 0.0
	for s in raw:
		s.t0 = tc
		tc += _opt(s.note, "pre", PRE)
		for l in s.lines:
			l.t0 = tc; l.seg = s
			lines.append(l)
			tc += l.dur + GAP
		if not s.lines.is_empty(): tc -= GAP
		tc += _opt(s.note, "post", POST)
		s.t1 = tc
		segs.append(s)
	DUR = tc + 0.5

func _save_timeline() -> void:
	var o := {"dur": DUR, "khung": [], "cau": []}
	for s in segs: o.khung.append({"id": s.kid, "ten": s.ten, "t0": s.t0, "t1": s.t1})
	for l in lines: o.cau.append({"id": l.id, "t0": l.t0, "dur": l.dur})
	var f := FileAccess.open("res://timeline.json", FileAccess.WRITE)
	f.store_string(JSON.stringify(o, " "))

func _process(_d: float) -> void:
	if stop: return
	frame += 1
	t = from + frame / FPS
	if t >= minf(to, DUR):
		stop = true
		get_tree().quit()
		return
	_step()

func _step() -> void:
	var seg: Dictionary = segs[0]
	for s in segs:
		if t >= s.t0: seg = s
	var line := {}
	for l in seg.lines:
		if t >= l.t0 and t < l.t0 + l.dur: line = l; break
	phim.at(t, seg, line)
	if phude: phude.at(t, line)
	# giọng
	if line.is_empty():
		if vo.playing and t > 0.1: vo.stop()
		vo_id = ""
	elif line.id != vo_id:
		vo_id = line.id
		var p := "res://voice/%s.wav" % vo_id
		vo.stream = load(p) if ResourceLoader.exists(p) else null
		if vo.stream: vo.play(t - line.t0)
	# nhạc
	if nhac.stream and not nhac.playing and t < nhac.stream.get_length(): nhac.play(t)
	# sfx rơi vào khung hình này
	for i in cues.size():
		if cues[i][0] >= t and cues[i][0] < t + 1.0 / FPS: _sfx(i, 0.0)

# kênh cố định theo số thứ tự sfx (không theo vòng) để render chia đoạn ra y hệt render liền
func _sfx(i: int, off: float) -> void:
	var sp: AudioStreamPlayer = sfx_pool[i % sfx_pool.size()]
	sp.stream = load("res://sfx/lib-%s.mp3" % cues[i][1]); sp.volume_db = cues[i][2]; sp.play(off)
