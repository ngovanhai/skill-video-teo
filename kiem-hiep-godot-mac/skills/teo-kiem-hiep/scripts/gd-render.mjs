// Render một tập dựng bằng Godot 2D: <tap>/godot (project riêng của tập) → Movie Maker (AVI MJPEG + PCM) → ffmpeg → <tap>/renders/<tên>.mp4
//   node <SKILL>/scripts/gd-render.mjs <tap> [--preview] [--from 0] [--to 60] [--par 2] [--sheet 10] [--out final] [--keep]
//   --preview   nửa khung (960×540; short dọc 540×960), tên mặc định "preview" (soi nhanh)        --from/--to  chỉ render đoạn [giây]
//   --par N     chia đoạn ra N phần render song song rồi nối         --sheet S    sau khi render: tờ ảnh 1 khung/S giây → work/sheet-<tên>.jpg
// Hợp đồng với project của tập (mọi thứ khác do tập tự viết):
//   - project.godot: cửa sổ 1920×1080 (short dọc 1080×1920, đọc từ viewport_width/height), stretch mode "canvas_items" (để --preview thu nhỏ được)
//   - main scene đọc OS.get_cmdline_user_args(): "--from=<giây>" "--to=<giây>"; dựng mọi thứ theo thời gian t (không phụ thuộc frame trước)
//     để nhảy thẳng tới --from được; tự get_tree().quit() khi t ≥ to (hoặc hết phim). Giọng/nhạc phát bằng AudioStreamPlayer, bắt đầu
//     giữa chừng thì play(offset) — Movie Maker ghi luôn tiếng.
//   - main scene có hằng/biến DUR (tổng giây) và in "DUR=<giây>" khi chạy với "--dur" (gd-render dùng để chia --par).
// Nên chạy trong suất máy: bash kiem-hiep/_tools/slot.sh "<tập> render" node …
import { existsSync, mkdirSync, rmSync, statSync, readFileSync } from "node:fs";
import { join, resolve } from "node:path";
import { spawnSync, spawn } from "node:child_process";

const GODOT = process.env.GODOT || "__GODOT__";
const FFMPEG = (process.env.FFMPEG || "ffmpeg");
const argv = process.argv.slice(2);
const opt = (k, d) => { const i = argv.indexOf("--" + k); return i >= 0 ? argv[i + 1] : d; };
const has = (k) => argv.includes("--" + k);
const die = (m) => { console.error("gd-render: " + m); process.exit(1); };
const dir = resolve(argv[0] && !argv[0].startsWith("--") ? argv[0] : die("thiếu <tap> (tham số đầu tiên)"));
const proj = join(dir, "godot"), work = join(dir, "work"), rdir = join(dir, "renders");
if (!existsSync(join(proj, "project.godot"))) die(`không có ${proj}/project.godot`);
const pg = readFileSync(join(proj, "project.godot"), "utf8");
const VW = +(pg.match(/viewport_width=(\d+)/)?.[1] || 1920), VH = +(pg.match(/viewport_height=(\d+)/)?.[1] || 1080);
const preview = has("preview"), name = opt("out", preview ? "preview" : "final"), par = Math.max(1, +opt("par", 1));
mkdirSync(work, { recursive: true }); mkdirSync(rdir, { recursive: true });

const t0 = Date.now(), el = () => ((Date.now() - t0) / 1000).toFixed(0) + "s";
console.log("gd-render: import tài nguyên…");
spawnSync(GODOT, ["--headless", "--path", proj, "--import"], { stdio: "ignore", timeout: 180000 });

let from = +opt("from", 0), to = opt("to", null);
if (to === null) {
  const r = spawnSync(GODOT, ["--headless", "--path", proj, "--", "--dur"], { encoding: "utf8", timeout: 90000 }); // script lỗi thì Godot không tự quit
  const m = (r.stdout || "").match(/DUR=([\d.]+)/);
  if (!m) die("main scene không in DUR=<giây> khi chạy với --dur (xem hợp đồng ở đầu file)\n" + ((r.stdout || "") + (r.stderr || "")).split(/\r?\n/).filter((l) => /ERROR/.test(l)).slice(0, 6).join("\n"));
  to = +m[1];
}
to = +to;
if (!(to > from)) die(`đoạn rỗng: from ${from} to ${to}`);
console.log(`gd-render: ${name} · ${from}–${to.toFixed(1)} s (${((to - from) / 60).toFixed(1)} phút) · ${preview ? `${VW / 2}×${VH / 2}` : `${VW}×${VH}`} · ${par} phần`);

// cắt đúng mép khung (30 fps): phần sau bắt đầu trên cùng lưới khung với bản liền, không lệch nửa khung.
// Movie Maker: khung thứ i của AVI là t = from + (i+1)/30, và lúc quit ghi thêm một khung lặp. Nên phần trước render tới
// hết khung t = mép cắt (to = mép + ε), rồi lúc nối bỏ khung lặp cuối (trim đúng số khung của phần).
const cut = (i) => (i >= par ? to : from + Math.round(((to - from) * i * 30) / par) / 30);
const parts = Array.from({ length: par }, (_, i) => [cut(i), cut(i + 1)]);
const avis = parts.map((_, i) => join(work, `gd-${name}-${i}.avi`));
const runPart = ([a, b], i) => new Promise((ok) => {
  rmSync(avis[i], { force: true });
  const args = ["--path", proj, "--write-movie", avis[i], "--fixed-fps", "30", ...(preview ? ["--resolution", `${VW / 2}x${VH / 2}`] : []), "--", `--from=${a.toFixed(6)}`, `--to=${(i < par - 1 ? b + 0.0005 : b).toFixed(6)}`];
  const p = spawn(GODOT, args, { stdio: ["ignore", "pipe", "pipe"] });
  let err = "";
  p.stderr.on("data", (d) => { err += d; if (err.length > 8000) err = err.slice(-8000); });
  p.stdout.on("data", (d) => { const s = String(d); if (/ERROR|SCRIPT ERROR/.test(s)) err += s; });
  p.on("close", (code) => {
    if (!existsSync(avis[i]) || statSync(avis[i]).size < 1000) die(`phần ${i} hỏng (exit ${code}):\n${err.slice(-3000)}`);
    if (/SCRIPT ERROR/.test(err)) console.warn(`gd-render: ! phần ${i} có lỗi script:\n${err.slice(-2000)}`);
    console.log(`gd-render: xong phần ${i + 1}/${par} (${a.toFixed(0)}–${b.toFixed(0)} s) · ${el()}`);
    ok();
  });
});
await Promise.all(parts.map(runPart));

const mp4 = join(rdir, name + ".mp4");
// nối bằng filter concat: concat demuxer với AVI của Movie Maker làm cụt các phần sau
let input = ["-i", avis[0]];
if (par > 1) {
  const keep = (i) => Math.round((parts[i][1] - parts[i][0]) * 30);
  const pre = avis.map((_, i) => i < par - 1
    ? `[${i}:v]trim=end_frame=${keep(i)},setpts=PTS-STARTPTS[v${i}];[${i}:a]atrim=end=${(keep(i) / 30).toFixed(6)},asetpts=PTS-STARTPTS[a${i}];`
    : `[${i}:v]null[v${i}];[${i}:a]anull[a${i}];`).join("");
  const fc = pre + avis.map((_, i) => `[v${i}][a${i}]`).join("") + `concat=n=${par}:v=1:a=1[v][a]`;
  input = [...avis.flatMap((f) => ["-i", f]), "-filter_complex", fc, "-map", "[v]", "-map", "[a]"];
}
const enc = spawnSync(FFMPEG, ["-loglevel", "error", "-y", ...input, "-c:v", "libx264", "-preset", preview ? "veryfast" : "medium", "-crf", preview ? "26" : "18", "-pix_fmt", "yuv420p", "-c:a", "aac", "-b:a", "192k", "-movflags", "+faststart", mp4], { stdio: "inherit" });
if (enc.status !== 0) die("ffmpeg lỗi khi nén mp4");
console.log(`gd-render: → ${mp4} · ${el()}`);
if (!has("keep")) avis.forEach((f) => rmSync(f, { force: true }));

const sheet = +opt("sheet", 0);
if (sheet > 0) {
  const n = Math.ceil((to - from) / sheet), cols = 6, rows = Math.ceil(n / cols);
  const out = join(work, `sheet-${name}.jpg`);
  spawnSync(FFMPEG, ["-loglevel", "error", "-y", "-i", mp4, "-vf", `fps=1/${sheet},scale=${VW > VH ? 320 : 180}:-1,drawtext=text='%{pts\\:hms}':x=4:y=4:fontsize=14:fontcolor=white:box=1:boxcolor=black@0.5,tile=${cols}x${rows}`, "-frames:v", "1", "-update", "1", out], { stdio: "inherit" });
  console.log(`gd-render: tờ ảnh → ${out} (giờ ghi trên ảnh tính từ đầu đoạn, cộng ${from} s)`);
}
