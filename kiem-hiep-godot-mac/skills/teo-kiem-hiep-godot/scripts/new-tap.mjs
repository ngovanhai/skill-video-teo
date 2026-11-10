// Dựng khung project Godot cho một tập kiếm hiệp: CHỈ phần hạ tầng (hợp đồng gd-render, xếp giờ theo giọng thật, phát giọng/nhạc/sfx).
// Phần hình (phim.gd và mọi file vẽ) do tập tự viết từ đầu — skill không phát template hình.
//   node <SKILL>/scripts/new-tap.mjs <thư mục tập> [--ten "Tên khung"] [--doc]
// --doc: khung 1080×1920 cho short dọc (new-short.mjs dùng).
// Tạo <tap>/godot/: project.godot, main.tscn, main.gd, phim.gd (chỗ giữ, có dấu CHUA_DUNG), loi.txt mẫu, story.json mẫu,
// cast.json rỗng, sfx/ (thư viện kit). Font không chép sẵn: tập tự chọn font hợp bút (ghi story.font). Không ghi đè file đã có.
import { existsSync, mkdirSync, writeFileSync, copyFileSync, readdirSync } from "node:fs";
import { join, resolve, basename, dirname } from "node:path";
import { fileURLToPath } from "node:url";

const SKILL = dirname(dirname(fileURLToPath(import.meta.url)));
const args = process.argv.slice(2);
const flag = (k) => { const i = args.indexOf(k); return i < 0 ? null : args.splice(i, 2)[1]; };
const ten = flag("--ten") || "chưa đặt";
const doc = args.includes("--doc") && !!args.splice(args.indexOf("--doc"), 1); // short dọc 1080×1920 (new-short.mjs gọi)
const [W, H] = doc ? [1080, 1920] : [1920, 1080];
if (!args[0]) { console.log("dùng: node new-tap.mjs <thư mục tập> [--ten \"Tên khung\"]"); process.exit(1); }
const TAP = resolve(args[0]), G = join(TAP, "godot"), slug = basename(TAP);
mkdirSync(join(G, "voice"), { recursive: true });
mkdirSync(join(G, "sfx"), { recursive: true });
mkdirSync(join(TAP, "work"), { recursive: true });
mkdirSync(join(TAP, "thumb"), { recursive: true });

const made = [];
const put = (f, s) => { const p = join(G, f); if (existsSync(p)) return; writeFileSync(p, s); made.push(f); };

put("project.godot", `; ${slug} — ${ten} (project Godot riêng của tập)
config_version=5

[application]
config/name="${slug}"
run/main_scene="res://main.tscn"

[display]
window/size/viewport_width=${W}
window/size/viewport_height=${H}
window/stretch/mode="canvas_items"

[rendering]
renderer/rendering_method="gl_compatibility"
renderer/rendering_method.mobile="gl_compatibility"
anti_aliasing/quality/msaa_2d=2
environment/defaults/default_clear_color=Color(0, 0, 0, 1)

[editor]
movie_writer/mjpeg_quality=0.9
`);

put("main.tscn", `[gd_scene load_steps=2 format=3]

[ext_resource type="Script" path="res://main.gd" id="1"]

[node name="Main" type="Node2D"]
script = ExtResource("1")
`);

put("main.gd", `# Hạ tầng tập (sinh bởi teo-kiem-hiep-godot/new-tap.mjs). Sửa được, nhưng giữ hợp đồng gd-render:
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
		nhac.stream = load("res://nhac.ogg"); nhac.volume_db = -12.0   # nhạc nền nhỏ hơn hẳn giọng (người dùng chốt 2026-10-23)
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
	for ln in FileAccess.get_file_as_string("res://loi.txt").split("\\n"):
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
`);

put("phim.gd", `# CHUA_DUNG — chỗ giữ của new-tap.mjs: chỉ in mã đoạn + câu đang đọc để --dur/preview chạy được.
# Thay toàn bộ file này bằng phần hình của tập (khung tự thiết kế; xem SKILL.md). gd-check báo lỗi khi còn dấu CHUA_DUNG.
extends Node2D

var main: Node
var t := 0.0
var seg := {}
var line := {}
var font: Font = ThemeDB.fallback_font

func setup(m: Node) -> void:
	main = m

func at(tt: float, s: Dictionary, l: Dictionary) -> void:
	t = tt; seg = s; line = l
	queue_redraw()

func sfx() -> Array:
	return []

func _draw() -> void:
	draw_rect(Rect2(0, 0, ${W}, ${H}), Color(0.12, 0.12, 0.14))
	draw_string(font, Vector2(80, 120), "%s %s  ·  %.1fs" % [seg.get("kid", ""), seg.get("ten", ""), t], HORIZONTAL_ALIGNMENT_LEFT, -1, 44, Color(1, 0.8, 0.4))
	draw_multiline_string(font, Vector2(80, 520), line.get("text", ""), HORIZONTAL_ALIGNMENT_LEFT, ${W - 160}, 52, -1, Color.WHITE)
`);

put("loi.txt", `# ${slug} (dựng Godot) — ${ten}
# Khung: <Tèo đóng vai gì, cả video nằm trong vật/không gian nào, máy quay đi ra sao>
# Cú pháp: "## kNN tên | ghi chú dựng {pre=0.6 post=1.0}" mở một đoạn; "[id] lời" là một câu Tèo đọc. Dòng khác bị bỏ qua.

## k01 hook | cảnh đắt nhất của kịch bản, dựng riêng, khớp nhịp
[k01-01] Câu mở đầu gây tò mò.

## k02 vai-teo | Tèo hiện hình theo vai của khung
[k02-01] Tèo tự giới thiệu bằng giọng của vai (không chép câu chào công thức).
`);

put("story.json", JSON.stringify({
  tap: slug,
  khung: "", teo_role: "", but: "", may_quay: "", palette: "", nhac: "", thumb: "", mat: "", font: "",
  doan: { k01: "kiểu dựng của đoạn (mỗi đoạn một kiểu)" },
  seo: { title: "…", mo_ta: "", chan: "", tags: [] },
}, null, 1) + "\n");

put("cast.json", "{}\n");

const sfxSrc = (process.env.MUSE_ROOT || "__MUSE_ROOT__") + "/kit/sfx";
for (const f of existsSync(sfxSrc) ? readdirSync(sfxSrc) : []) {
  if (/^lib-.*\.mp3$/.test(f) && !existsSync(join(G, "sfx", f))) copyFileSync(join(sfxSrc, f), join(G, "sfx", f));
}

console.log(made.length ? `tạo ${G}:\n  ${made.join("\n  ")}` : "đã có đủ, không ghi đè gì");
console.log("tiếp: viết loi.txt + story.json, rồi gd-voice (trong slot.sh), rồi viết phim.gd");
