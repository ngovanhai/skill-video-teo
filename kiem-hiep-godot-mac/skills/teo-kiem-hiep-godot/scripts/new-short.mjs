// Dựng khung một short dọc (1080×1920) từ một tập Godot: <tap>/shorts/<NN-ten>/ là một project Godot riêng, cùng hợp đồng
// với tập (gd-voice / gd-render / gd-check / pack chạy thẳng trên thư mục short).
//   node <SKILL>/scripts/new-short.mjs <tap> <NN-ten> [--tu kA-01..kB-05]… [--nhac <giây>]
// Làm:
//   - chép từ <tap>/godot: font/, mat/, chars/, chuong/, sfx/, cast.json và các file .gd vẽ của tập (trừ main/phim/thumb) — short vẽ bằng
//     chính bút của tập; renderer + màu nền theo project của tập.
//   - --tu a..b (lặp được): chép các câu id a…b của loi.txt tập vào đoạn thân, kèm wav + voice.json (gd-voice không đọc lại).
//   - nhạc: cắt nhac.ogg của tập từ --nhac <giây> (mặc định: 10 s trước câu --tu đầu tiên, theo timeline.json), 70 s, fade vào.
//   - phude.gd: phụ đề 3–4 chữ một nhóm ở y≈1490 (vùng an toàn của Shorts); kiểu ở story.json "phu_de".
//   - story.json kiểu short: kieu, nguon, seo {title, mo_ta, tags, full}.
// Rồi gọi new-tap.mjs --doc cho phần hạ tầng (main.gd, phim.gd chỗ giữ). Không ghi đè file đã có.
import { existsSync, mkdirSync, writeFileSync, readFileSync, copyFileSync, readdirSync, cpSync } from "node:fs";
import { join, resolve, basename, dirname } from "node:path";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const SKILL = dirname(dirname(fileURLToPath(import.meta.url)));
const FFMPEG = (process.env.FFMPEG || "ffmpeg");
const args = process.argv.slice(2);
const die = (m) => { console.error("new-short: " + m); process.exit(1); };
const tus = [];
let nhacAt = null;
for (let i = 0; i < args.length; i++) {
  if (args[i] === "--tu") tus.push(args.splice(i--, 2)[1]);
  else if (args[i] === "--nhac") nhacAt = +args.splice(i--, 2)[1];
}
if (args.length < 2) die("dùng: node new-short.mjs <tap> <NN-ten> [--tu kA-01..kB-05] [--nhac <giây>]");
const TAP = resolve(args[0]), TG = join(TAP, "godot"), name = args[1];
if (!/^\d\d-[a-z0-9-]+$/.test(name)) die(`tên short "${name}" phải dạng NN-ten-khong-dau (vd 01-ban-tay-chin-ngon)`);
if (!existsSync(join(TG, "project.godot"))) die(`không có ${TG}/project.godot`);
const S = join(TAP, "shorts", name), G = join(S, "godot");
mkdirSync(join(G, "voice"), { recursive: true });
const made = [];
const put = (f, s) => { const p = join(G, f); if (existsSync(p)) return; writeFileSync(p, s); made.push(f); };

// ---- tài nguyên của tập (bút, mặt, nhân vật, font, chiêu, sfx)
const skip = (f) => /\.(import|uid)$/.test(f);
for (const d of ["font", "mat", "chars", "chuong", "sfx"]) {
  if (!existsSync(join(TG, d))) continue;
  cpSync(join(TG, d), join(G, d), { recursive: true, force: false, filter: (f) => !skip(f) });
  made.push(d + "/");
}
for (const f of readdirSync(TG)) {
  if (!f.endsWith(".gd") || ["main.gd", "phim.gd", "thumb.gd"].includes(f) || existsSync(join(G, f))) continue;
  copyFileSync(join(TG, f), join(G, f)); made.push(f);
}
if (existsSync(join(TG, "cast.json"))) put("cast.json", readFileSync(join(TG, "cast.json"), "utf8"));

// ---- câu lấy từ tập (+ giọng sẵn)
const tapLines = [];
for (const ln of readFileSync(join(TG, "loi.txt"), "utf8").split(/\r?\n/)) {
  const m = ln.match(/^\s*\[([a-z0-9][a-z0-9-]*)\]\s+(.+)$/);
  if (m) tapLines.push({ id: m[1], text: m[2].trim() });
}
const picked = [];
for (const r of tus) {
  const [a, b = a] = r.split("..");
  const i = tapLines.findIndex((l) => l.id === a), j = tapLines.findIndex((l) => l.id === b);
  if (i < 0 || j < i) die(`--tu ${r}: không thấy id trong loi.txt của tập (hoặc ngược thứ tự)`);
  picked.push(...tapLines.slice(i, j + 1));
}
const tman = existsSync(join(TG, "voice/voice.json")) ? JSON.parse(readFileSync(join(TG, "voice/voice.json"), "utf8")) : null;
const manFile = join(G, "voice/voice.json");
if (tman && picked.length && !existsSync(manFile)) {
  const man = { voice: tman.voice, engine: tman.engine, lines: {} };
  for (const l of picked) {
    const w = join(TG, "voice", l.id + ".wav");
    if (!tman.lines[l.id] || !existsSync(w)) continue;
    copyFileSync(w, join(G, "voice", l.id + ".wav"));
    man.lines[l.id] = tman.lines[l.id];
  }
  writeFileSync(manFile, JSON.stringify(man, null, 1));
  made.push(`voice/ (${Object.keys(man.lines).length} câu sẵn giọng)`);
}

put("loi.txt", `# ${basename(TAP)} · short ${name} (dọc 1080×1920) — tự kể trọn, ≤ 60 s (khoảng 200–230 chữ)
# Cú pháp như loi.txt của tập. Câu chép từ tập giữ nguyên id → dùng lại giọng sẵn; sửa chữ thì gd-voice đọc lại câu đó.
# Viết thêm (bỏ dấu # đầu dòng): hook ≤ 12 s (câu đầu ≤ 12 chữ, hình đắt nhất trong 2 s đầu), câu nối nếu cắt giữa chừng,
# câu kết có "đăng ký" và "Tèo Tửu Lâu". Người xem short chưa xem tập: tên người, môn võ phải tự giới thiệu lại trong short.

## s01 hook | <hình đắt nhất của short, hiện trong 2 s đầu>
# [s01-01] <câu hook ≤ 12 chữ>

## s02 than | lấy từ tập: ${tus.join(", ") || "<id>"}
${picked.map((l) => `[${l.id}] ${l.text}`).join("\n") || "# [s02-01] <lời>"}

## s03 ket | <Tèo chốt một câu + mời đăng ký kênh Tèo Tửu Lâu>
# [s03-01] <câu kết có "đăng ký" và "Tèo Tửu Lâu">
`);

const tieuDe = join(TAP, "youtube/tieu-de.txt");
put("story.json", JSON.stringify({
  tap: basename(TAP), short: name,
  kieu: "<kiểu short: một cảnh chưởng trọn vẹn / một bí mật / một con số / một cuộc cãi… — 3 short của tập phải khác kiểu>",
  nguon: tus,
  phu_de: { font: "", size: 66, mau: "#ffffff", vien: "#000000", y: 1490 },
  seo: { title: "…", mo_ta: "", tags: [], full: existsSync(tieuDe) ? readFileSync(tieuDe, "utf8").trim() : "" },
}, null, 1) + "\n");

put("phude.gd", `# Phụ đề short dọc (sinh bởi new-short.mjs; hạ tầng, tập sửa được). Mỗi lần hiện một nhóm 2–4 chữ của câu đang đọc,
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
`);

// ---- nhạc: một khúc nhạc của tập
const tnhac = join(TG, "nhac.ogg");
if (existsSync(tnhac) && !existsSync(join(G, "nhac.ogg"))) {
  if (nhacAt === null) {
    const tl = existsSync(join(TG, "timeline.json")) ? JSON.parse(readFileSync(join(TG, "timeline.json"), "utf8")) : {};
    // timeline cũ chỉ có khung: lấy đầu khung chứa câu (k09-06 → k09)
    const c = (tl.cau || []).find((x) => x.id === picked[0]?.id) || (tl.khung || []).find((x) => x.id === picked[0]?.id.split("-")[0]);
    nhacAt = c ? Math.max(0, c.t0 - 10) : 0;
  }
  const cut = (enc) => spawnSync(FFMPEG, ["-v", "error", "-y", "-ss", String(nhacAt), "-t", "70", "-i", tnhac, "-af", "afade=t=in:d=0.4", "-ac", "2", ...enc, join(G, "nhac.ogg")], { stdio: "inherit" });
  let r = cut(["-c:a", "libvorbis", "-q:a", "5"]);
  if (r.status !== 0) r = cut(["-c:a", "vorbis", "-strict", "-2", "-q:a", "5"]); // ffmpeg bản gọn (Homebrew) không có libvorbis
  if (r.status === 0) made.push(`nhac.ogg (nhạc tập từ ${nhacAt.toFixed(1)} s)`);
}

// ---- hạ tầng (main.gd, project dọc, phim.gd chỗ giữ)
const nt = spawnSync(process.execPath, [join(SKILL, "scripts/new-tap.mjs"), S, "--doc", "--ten", `short ${name}`], { encoding: "utf8" });
if (nt.status !== 0) die("new-tap lỗi:\n" + nt.stderr);
// renderer + màu nền theo tập (tập có chiêu chạy forward_plus)
const tp = readFileSync(join(TG, "project.godot"), "utf8"), pf = join(G, "project.godot");
let sp = readFileSync(pf, "utf8");
for (const k of ["renderer/rendering_method", "renderer/rendering_method.mobile", "environment/defaults/default_clear_color"]) {
  const m = tp.match(new RegExp(`^${k.replace(/[./]/g, "\\$&")}=.*$`, "m"));
  if (m) sp = sp.replace(new RegExp(`^${k.replace(/[./]/g, "\\$&")}=.*$`, "m"), m[0]);
}
writeFileSync(pf, sp);

console.log(`short ${S}\n  ${made.join("\n  ")}\n${nt.stdout.trim().split("\n")[0]}`);
console.log(`tiếp: viết loi.txt (hook + kết) + story.json, gd-voice (LOCK), viết phim.gd dọc, gd-check, gd-render --sheet, pack.`);
