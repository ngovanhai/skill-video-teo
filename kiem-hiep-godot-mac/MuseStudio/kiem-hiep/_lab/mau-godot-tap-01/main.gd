# Tập 01 — Cuộn tranh mực. Đọc loi.txt (## kNN = khung, [id] = câu), xếp giờ theo độ dài giọng thật (voice/voice.json),
# dựng máy quay trôi dọc cuộn giấy, phát giọng/nhạc/sfx. Hợp đồng gd-render: --from= --to= --dur, quit khi hết.
extends Node2D

const FPS := 30.0
const GAP := 0.7                       # nghỉ giữa hai câu
var DUR := 0.0
var t := 0.0
var from := 0.0
var to := INF
var frame := 0
var stop := false

var khungs: Array = []                 # Khung theo thứ tự kể
var lines: Array = []                  # {id, t0, dur, k}
var sfxs: Array = []                   # [giờ toàn phim, tên, dB]
var world := Node2D.new()
var cam := Camera2D.new()
var paper: Node2D
var song: Node2D
var teo_node: Node2D
var vo := AudioStreamPlayer.new()
var vo_id := ""
var nhac := AudioStreamPlayer.new()
var sfx_pool: Array = []
var sfx_i := 0

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
	add_child(world)
	paper = preload("res://giay.gd").new(); world.add_child(paper)
	song = preload("res://song.gd").new(); world.add_child(song)
	for k in khungs:
		if k.kid == "k03": song.k3 = k
	for k in khungs:
		k.position = Vector2(k.X, 0); world.add_child(k)
	var grain := preload("res://van-giay.gd").new(); world.add_child(grain)
	world.add_child(cam); cam.make_current()
	var ui := CanvasLayer.new(); ui.layer = 3; add_child(ui)
	teo_node = preload("res://teo.gd").new(); ui.add_child(teo_node)
	var vg := CanvasLayer.new(); vg.layer = 4; add_child(vg)
	vg.add_child(preload("res://khung-vien.gd").new())
	add_child(vo); add_child(nhac)
	for i in 6:
		var p := AudioStreamPlayer.new(); add_child(p); sfx_pool.append(p)
	if ResourceLoader.exists("res://nhac.ogg"):
		nhac.stream = load("res://nhac.ogg"); nhac.volume_db = -3.0
	t = from
	_step()

func _build() -> void:
	var man := {}
	if FileAccess.file_exists("res://voice/voice.json"):
		man = JSON.parse_string(FileAccess.get_file_as_string("res://voice/voice.json")).lines
	var cur: Khung = null
	var raw: Array = []                # [[khung, [ids], [durs]]]
	for ln in FileAccess.get_file_as_string("res://loi.txt").split("\n"):
		ln = ln.strip_edges()
		if ln.begins_with("## "):
			var kid := ln.substr(3).split(" ")[0]
			cur = load("res://khung/%s.gd" % kid).new()
			cur.kid = kid
			raw.append([cur, [], []])
		elif ln.begins_with("[") and cur != null:
			var id := ln.substr(1, ln.find("]") - 1)
			var text := ln.substr(ln.find("]") + 1).strip_edges()
			var d: float = man[id].dur if man.has(id) else text.split(" ").size() / 4.1
			raw[-1][1].append(id); raw[-1][2].append(d)
	var tc := 0.0
	for r in raw:
		var k: Khung = r[0]
		tc += k.travel + k.pre
		k.t_first = tc
		var lt := 0.0
		for i in r[1].size():
			k.ls.append(lt); k.ld.append(r[2][i])
			lines.append({"id": r[1][i], "t0": tc + lt, "dur": r[2][i], "k": k})
			lt += r[2][i] + GAP + k.gaps.get(i, 0.0)
		lt -= GAP
		tc += lt + k.post
		k.t_end = tc
		khungs.append(k)
		for s in k.sfx(): sfxs.append([k.t_first + s[0], s[1], s[2] if s.size() > 2 else 0.0])
	DUR = tc + 0.5
	sfxs.sort_custom(func(a, b): return a[0] < b[0])

func _save_timeline() -> void:
	var o := {"dur": DUR, "khung": []}
	for k in khungs: o.khung.append({"id": k.kid, "t0": k.t_first, "t1": k.t_end})
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

# khung chính lúc t: khung cuối cùng đã bắt đầu trôi tới
func _cur() -> int:
	var i := 0
	for j in khungs.size():
		if t >= khungs[j].t_first - khungs[j].travel - khungs[j].pre: i = j
	return i

func _step() -> void:
	var ci := _cur()
	for j in khungs.size():
		var k: Khung = khungs[j]
		k.lt = t - k.t_first; k.tt = t; k.active = j == ci
	# máy quay
	var k: Khung = khungs[ci]
	var c: Array = k.cam(k.lt)
	var pos: Vector2 = Vector2(k.X, 0) + c[0]
	var zm: float = c[1]
	var tr0 := k.t_first - k.travel - k.pre
	if ci > 0 and t < k.t_first - k.pre:
		var pk: Khung = khungs[ci - 1]
		var pc: Array = pk.cam(pk.t_end - pk.t_first)
		var p0: Vector2 = Vector2(pk.X, 0) + pc[0]
		var u := But.ez((t - tr0) / k.travel)
		var dist := p0.distance_to(pos)
		var dip := clampf(dist / 7000.0, 0.0, 0.85)          # đi xa thì lùi máy ra một chút cho thấy cuộn giấy
		zm = lerpf(pc[1], zm, u) * (1.0 - dip * sin(u * PI))
		pos = p0.lerp(pos, u)
	cam.position = pos
	cam.zoom = Vector2(zm, zm)
	# ẩn khung ngoài tầm nhìn
	var half := 960.0 / zm + 1600.0
	for kk in khungs: kk.visible = (kk.wide or absf(kk.X - pos.x) < half) and kk.lt > -kk.travel - kk.pre - 0.5
	paper.queue_redraw(); song.set("tt", t); song.queue_redraw()
	# Tèo
	var talking := false
	var cur_line := {}
	for l in lines:
		if t >= l.t0 and t < l.t0 + l.dur: cur_line = l; talking = true; break
	teo_node.st = k.teo(k.lt); teo_node.talk = talking; teo_node.tt = t; teo_node.queue_redraw()
	# giọng
	if cur_line.is_empty():
		if vo.playing and t > 0.1: vo.stop()
		vo_id = ""
	elif cur_line.id != vo_id:
		vo_id = cur_line.id
		vo.stream = load("res://voice/%s.wav" % vo_id) if ResourceLoader.exists("res://voice/%s.wav" % vo_id) else null
		if vo.stream: vo.play(t - cur_line.t0)
	# nhạc
	if nhac.stream and not nhac.playing and t < nhac.stream.get_length(): nhac.play(t)
	# sfx: phát cái nào rơi vào khung hình này
	for s in sfxs:
		if s[0] >= t and s[0] < t + 1.0 / FPS:
			var p: AudioStreamPlayer = sfx_pool[sfx_i % sfx_pool.size()]; sfx_i += 1
			p.stream = load("res://sfx/lib-%s.mp3" % s[1]); p.volume_db = s[2]; p.play()
