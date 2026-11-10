// Render một tập dựng bằng Godot 2D bằng ffmpeg (không dùng Movie Maker): <tap>/godot (project riêng của tập) → <tap>/renders/<tên>.mp4
//   node <SKILL>/scripts/gd-render.mjs <tap> [--preview] [--from 0] [--to 60] [--par 2] [--sheet 10] [--out final] [--keep]
//   --preview   nửa khung (960×540; short dọc 540×960), tên mặc định "preview" (soi nhanh)        --from/--to  chỉ render đoạn [giây]
//   --par N     chia đoạn ra N phần render song song rồi nối         --sheet S    sau khi render: tờ ảnh 1 khung/S giây → work/sheet-<tên>.jpg
//   --nhac-db D chỉnh thêm âm lượng nhạc nền (dB, mặc định 0 = theo nhac.volume_db của main; chỉ hạ được, không vượt trần)   --no-duck  không hạ nhạc khi có giọng
//   --sfx-hp HZ lọc dải trầm của sfx (mặc định 180; 0 = tắt) — sfx chưởng chuong-2d có tiếng nổ trầm ù ù
//   Luật âm thanh chung (kit/lib/mix.mjs, người dùng chốt 2026-10-24): sfx dùng bản êm của kit/sfx (tự chép đè vào res://sfx), mỗi cue ≤ SFX_MAX_DB,
//   cả kênh sfx chặn đỉnh -12 dBFS (giọng đỉnh ≈ -3) — không tiếng ùm ùm gây giật mình; nhạc nền tự hạ để ≤ -40 LUFS (thấp hơn giọng ≥ 20 dB).
//   --audio-only  giữ nguyên hình của renders/<tên>.mp4 đã có, chỉ dựng lại tiếng (sửa mix không phải render lại hình)
// Cách làm:
//   - Hình: chép scripts/gdrec.gd vào project thành res://_gdrec.gd, nạp làm autoload qua override.cfg (xoá khi xong). Mỗi khung
//     gdrec đọc ảnh viewport, đẩy RGBA qua pipe sang ffmpeg (libx264). Godot chạy --fixed-fps 30, âm thanh tắt (--audio-driver Dummy).
//   - Tiếng: gdrec chạy 1 khung đọc lines/cues/nhac của main ra json; gd-render tự dựng lại đúng như main phát: giọng res://voice/<id>.wav
//     từ t0 (cắt ở dur), sfx res://sfx/lib-<tên>.mp3 trên sfx_ch kênh (cue i ở kênh i % sfx_ch, cue sau cùng kênh cắt cue trước),
//     nhạc res://nhac.ogg (volume_db). Nhạc lọc bỏ dải trầm dưới 120 Hz (tránh tiếng ù) và tự hạ khi có giọng; cuối có limiter.
// Hợp đồng với project của tập (main.gd của new-tap.mjs đã đúng):
//   - project.godot: cửa sổ 1920×1080 (short dọc 1080×1920, đọc từ viewport_width/height), stretch mode "canvas_items"
//   - main scene đọc OS.get_cmdline_user_args(): "--from=<giây>" "--to=<giây>"; dựng mọi thứ theo thời gian t (không phụ thuộc frame trước)
//     để nhảy thẳng tới --from được; tự get_tree().quit() khi t ≥ to (hoặc hết phim).
//   - main có biến lines [{id,t0,dur}], cues [[giây, tên, dB]], vo / nhac (AudioStreamPlayer), sfx_pool, DUR; in "DUR=<giây>" khi chạy "--dur".
// Nên chạy trong suất máy: bash kiem-hiep/_tools/slot.sh "<tập> render" node …
import { existsSync, mkdirSync, rmSync, statSync, readFileSync, writeFileSync, copyFileSync, openSync, readSync, writeSync, closeSync, ftruncateSync, renameSync } from "node:fs";
import { join, resolve, dirname } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";
import { spawnSync, spawn } from "node:child_process";

const HERE = dirname(fileURLToPath(import.meta.url));
const { SFX_ON, sfxDb, bgmDb, syncSfx } = await import(pathToFileURL(join(process.env.MUSE_ROOT || "__MUSE_ROOT__", "kit/lib/mix.mjs")).href);
const GODOT = process.env.GODOT || "__GODOT__";
const FFMPEG = process.env.FFMPEG || (existsSync("/opt/homebrew/bin/ffmpeg") ? "/opt/homebrew/bin/ffmpeg" : "ffmpeg");
const argv = process.argv.slice(2);
const opt = (k, d) => { const i = argv.indexOf("--" + k); return i >= 0 ? argv[i + 1] : d; };
const has = (k) => argv.includes("--" + k);
const die = (m) => { console.error("gd-render: " + m); cleanup(); process.exit(1); };
const dir = resolve(argv[0] && !argv[0].startsWith("--") ? argv[0] : (console.error("gd-render: thiếu <tap> (tham số đầu tiên)"), process.exit(1)));
const proj = join(dir, "godot"), work = join(dir, "work"), rdir = join(dir, "renders");
if (!existsSync(join(proj, "project.godot"))) { console.error(`gd-render: không có ${proj}/project.godot`); process.exit(1); }
const pg = readFileSync(join(proj, "project.godot"), "utf8");
const VW = +(pg.match(/viewport_width=(\d+)/)?.[1] || 1920), VH = +(pg.match(/viewport_height=(\d+)/)?.[1] || 1080);
const preview = has("preview"), name = opt("out", preview ? "preview" : "final"), par = Math.max(1, +opt("par", 1));
const [OW, OH] = preview ? [VW / 2, VH / 2] : [VW, VH];
const FPS = 30, SR = 48000;
mkdirSync(work, { recursive: true }); mkdirSync(rdir, { recursive: true });

// --- gắn bộ ghi vào project (override.cfg + res://_gdrec.gd) ---
const OVR = join(proj, "override.cfg"), REC = join(proj, "_gdrec.gd");
// override.cfg do một gd-render khác đang chạy tạo ra (có _gdrec) thì không coi là bản gốc của tập
const ovrRaw = existsSync(OVR) ? readFileSync(OVR, "utf8") : null;
const ovrOld = ovrRaw && !ovrRaw.includes("_gdrec") ? ovrRaw : null;
function cleanup() {
  // còn gd-render khác chạy trên cùng project thì để nguyên override.cfg + _gdrec.gd cho nó (nó tự dọn khi xong)
  const others = spawnSync("pgrep", ["-f", `gd-render.mjs ${argv[0]}`], { encoding: "utf8" }).stdout.split("\n").filter((x) => x && +x !== process.pid);
  if (others.length) return;
  if (ovrOld === null) rmSync(OVR, { force: true }); else writeFileSync(OVR, ovrOld);
  for (const f of [REC, REC + ".uid"]) rmSync(f, { force: true });
}
copyFileSync(join(HERE, "gdrec.gd"), REC);
writeFileSync(OVR, (ovrOld && !/\[autoload\]/.test(ovrOld) ? ovrOld + "\n" : "") + `[autoload]\n\nGdRec="*res://_gdrec.gd"\n`);
process.on("SIGINT", () => { cleanup(); process.exit(130); });

const t0 = Date.now(), el = () => ((Date.now() - t0) / 1000).toFixed(0) + "s";
console.log("gd-render: import tài nguyên…");
spawnSync(GODOT, ["--headless", "--path", proj, "--import"], { stdio: "ignore", timeout: 300000 });

let from = +opt("from", 0), to = opt("to", null);
const godotErr = (r) => ((r.stdout || "") + (r.stderr || "")).split(/\r?\n/).filter((l) => /ERROR/.test(l)).slice(0, 8).join("\n");
{
  const r = spawnSync(GODOT, ["--headless", "--path", proj, "--", "--dur"], { encoding: "utf8", timeout: 120000 }); // script lỗi thì Godot không tự quit
  const m = (r.stdout || "").match(/DUR=([\d.]+)/);
  if (!m) die("main scene không in DUR=<giây> khi chạy với --dur (xem hợp đồng ở đầu file)\n" + godotErr(r));
  to = Math.min(to === null ? +m[1] : +to, +m[1]);
}
if (!(to > from)) die(`đoạn rỗng: from ${from} to ${to}`);
console.log(`gd-render: ${name} · ${from}–${to.toFixed(1)} s (${((to - from) / 60).toFixed(1)} phút) · ${OW}×${OH} · ${par} phần`);

// --- kế hoạch tiếng từ main scene ---
const planF = join(work, `gd-plan-${name}.json`);
rmSync(planF, { force: true });
{
  const r = spawnSync(GODOT, ["--headless", "--path", proj, "--", `--from=${from}`, `--to=${from + 5}`, `--gdrec-plan=${planF}`], { encoding: "utf8", timeout: 180000 });
  if (!existsSync(planF)) die("không đọc được kế hoạch tiếng từ main scene\n" + godotErr(r));
}
const plan = JSON.parse(readFileSync(planF, "utf8"));
if (!plan.ok) die(plan.err);

// --- hình: N phần song song, mỗi phần đúng round((b-a)*30) khung ---
const cut = (i) => (i >= par ? to : from + Math.round(((to - from) * i * FPS) / par) / FPS);
const parts = Array.from({ length: par }, (_, i) => [cut(i), cut(i + 1)]);
const vids = parts.map((_, i) => join(work, `gd-${name}-${i}.mkv`));
const x264 = preview ? "veryfast,26" : "medium,18";
const runPart = ([a, b], i) => new Promise((ok) => {
  rmSync(vids[i], { force: true });
  const nfr = Math.round((b - a) * FPS);
  const args = ["--path", proj, "--disable-vsync", "--fixed-fps", String(FPS), "--audio-driver", "Dummy",
    ...(preview ? ["--resolution", `${OW}x${OH}`] : []),
    "--", `--from=${a.toFixed(6)}`, `--to=${(b + 1).toFixed(6)}`,
    `--gdrec=${vids[i]}`, `--gdrec-n=${nfr}`, `--gdrec-ff=${FFMPEG}`, `--gdrec-size=${OW}x${OH}`, `--gdrec-x264=${x264}`, ...(preview ? [] : ["--gdrec-fit"])];
  const p = spawn(GODOT, args, { stdio: ["ignore", "pipe", "pipe"] });
  let err = "";
  const eat = (d) => { const s = String(d); if (/ERROR|gdrec/.test(s)) { err += s; if (err.length > 8000) err = err.slice(-8000); } };
  p.stderr.on("data", eat); p.stdout.on("data", eat);
  p.on("close", (code) => {
    if (!existsSync(vids[i]) || statSync(vids[i]).size < 1000) die(`phần ${i} hỏng (exit ${code}):\n${err.slice(-3000)}`);
    if (/SCRIPT ERROR/.test(err)) console.warn(`gd-render: ! phần ${i} có lỗi script:\n${err.slice(-2000)}`);
    console.log(`gd-render: xong hình phần ${i + 1}/${par} (${a.toFixed(0)}–${b.toFixed(0)} s, ${nfr} khung) · ${el()}`);
    ok();
  });
});

// --- tiếng: dựng track giọng (mono) và sfx (stereo) dạng f32le trên đĩa, cộng dồn từng clip ---
function decode(file, ss, len, ch) {
  const r = spawnSync(FFMPEG, ["-v", "error", ...(ss > 0 ? ["-ss", ss.toFixed(4)] : []), "-i", file, ...(len > 0 ? ["-t", len.toFixed(4)] : []),
    "-f", "f32le", "-ac", String(ch), "-ar", String(SR), "-"], { maxBuffer: 1 << 30 });
  if (r.status !== 0) { console.warn(`gd-render: ! không giải mã được ${file}`); return null; }
  return new Float32Array(r.stdout.buffer, r.stdout.byteOffset, r.stdout.length / 4);
}
function track(file, ch) {
  const fd = openSync(file, "w+"); ftruncateSync(fd, Math.ceil((to - from) * SR) * ch * 4);
  return { fd, ch, add(at, pcm, gain) { // at: giây tính từ from
    let off = Math.round(at * SR) * ch, n = pcm.length;
    const max = Math.ceil((to - from) * SR) * ch;
    if (off < 0) { pcm = pcm.subarray(-off); n = pcm.length; off = 0; }
    n = Math.min(n, max - off); if (n <= 0) return;
    const buf = Buffer.alloc(n * 4); readSync(fd, buf, 0, n * 4, off * 4);
    const cur = new Float32Array(buf.buffer, buf.byteOffset, n);
    for (let k = 0; k < n; k++) cur[k] += pcm[k] * gain;
    writeSync(fd, buf, 0, n * 4, off * 4);
  } };
}
const dbg = (db) => Math.pow(10, db / 20);
function buildAudio() {
  const voF = join(work, `gd-${name}-vo.f32`), sfF = join(work, `gd-${name}-sfx.f32`);
  const vo = track(voF, 1), sf = track(sfF, 2);
  let nv = 0, ns = 0;
  for (const l of plan.lines) {
    const f = join(proj, "voice", `${l.id}.wav`);
    if (!existsSync(f) || l.t0 + l.dur <= from || l.t0 >= to) continue;
    const ss = Math.max(0, from - l.t0), pcm = decode(f, ss, l.dur - ss, 1);
    if (pcm) { vo.add(l.t0 + ss - from, pcm, dbg(plan.vo_db || 0)); nv++; }
  }
  const cues = SFX_ON ? plan.cues : [], CH = plan.sfx_ch || 6, cache = {};
  for (let i = 0; i < cues.length; i++) {
    const [c0, nm, db] = cues[i];
    const f = join(proj, "sfx", `lib-${nm}.mp3`);
    if (!existsSync(f) || c0 >= to) continue;
    const next = cues[i + CH] ? cues[i + CH][0] : Infinity; // cùng kênh: cue sau cắt cue trước
    cache[nm] ||= decode(f, 0, 0, 2);
    let pcm = cache[nm]; if (!pcm) continue;
    const len = Math.min(pcm.length / 2 / SR, next - c0), ss = Math.max(0, from - c0);
    if (len - ss <= 0) continue;
    pcm = pcm.subarray(Math.round(ss * SR) * 2, Math.round(len * SR) * 2);
    sf.add(c0 + ss - from, pcm, dbg(sfxDb(db))); ns++;
  }
  closeSync(vo.fd); closeSync(sf.fd);
  console.log(`gd-render: tiếng · ${nv} câu giọng · ${ns} sfx${plan.nhac ? " · nhạc " + plan.nhac.path.split("/").pop() : " · không nhạc"} · ${el()}`);
  return { voF, sfF };
}

const AUDIO_ONLY = has("audio-only");
const oldMp4 = join(rdir, name + ".mp4");
if (AUDIO_ONLY && !existsSync(oldMp4)) die(`--audio-only: chưa có ${oldMp4}`);
if (!AUDIO_ONLY) await Promise.all(parts.map(runPart));
const nSfx = syncSfx(join(proj, "sfx")); // bản sfx êm thay bản cũ đã chép lúc new-tap / gd-chieu
if (nSfx) console.log(`gd-render: sfx · cập nhật ${nSfx} file bản êm từ kit/sfx`);
const { voF, sfF } = buildAudio(); // sau phần hình: buildAudio chạy đồng bộ, chạy song song sẽ không đọc kịp stdout của Godot

// --- nối hình + trộn tiếng ---
const vlist = join(work, `gd-${name}-list.txt`);
const keepVid = join(work, `gd-${name}-video.mp4`);
if (AUDIO_ONLY) renameSync(oldMp4, keepVid);
writeFileSync(vlist, (AUDIO_ONLY ? [keepVid] : vids).map((f) => `file '${f.replace(/'/g, "'\\''")}'`).join("\n") + "\n");
const D = (to - from).toFixed(6);
const inputs = ["-f", "concat", "-safe", "0", "-i", vlist,
  "-f", "f32le", "-ar", String(SR), "-ac", "1", "-i", voF,
  "-f", "f32le", "-ar", String(SR), "-ac", "2", "-i", sfF];
const sfHp = +opt("sfx-hp", 180);
let fc = `[1:a]aformat=channel_layouts=stereo,asplit=2[vo][vok];[2:a]${sfHp > 0 ? `highpass=f=${sfHp}:poles=2,highpass=f=${sfHp}:poles=2,highpass=f=${sfHp}:poles=2,` : ""}alimiter=limit=0.25:level=false[sf];`;
let mix = "[vo][sf]";
if (plan.nhac && existsSync(plan.nhac.path)) {
  inputs.push(...(plan.nhac.loop ? ["-stream_loop", "-1"] : []), "-ss", String(from), "-i", plan.nhac.path);
  const want = (plan.nhac.db || 0) + +opt("nhac-db", 0), g = +bgmDb(plan.nhac.path, want).toFixed(1);
  if (g < want) console.log(`gd-render: nhạc nền ${want} dB quá to so với giọng → hạ còn ${g} dB (≤ -40 LUFS)`);
  fc += `[3:a]aresample=${SR},aformat=channel_layouts=stereo,highpass=f=120:poles=2,volume=${g}dB,apad[nh0];`;
  fc += has("no-duck") ? `[nh0]anull[nh];[vok]anullsink;` : `[nh0][vok]sidechaincompress=threshold=0.03:ratio=3:attack=60:release=700:makeup=1[nh];`;
  mix += "[nh]";
} else fc += `[vok]anullsink;`;
fc += `${mix}amix=inputs=${mix.split("][").length}:normalize=0:duration=first,alimiter=limit=0.95:level=false,atrim=0:${D}[a]`;
const mp4 = join(rdir, name + ".mp4");
const enc = spawnSync(FFMPEG, ["-loglevel", "error", "-y", ...inputs, "-filter_complex", fc, "-map", "0:v", "-map", "[a]",
  "-c:v", "copy", "-c:a", "aac", "-b:a", "192k", "-t", D, "-movflags", "+faststart", mp4], { stdio: "inherit" });
cleanup();
if (enc.status !== 0) { if (AUDIO_ONLY && existsSync(keepVid)) renameSync(keepVid, oldMp4); console.error("gd-render: ffmpeg lỗi khi ghép mp4"); process.exit(1); }
console.log(`gd-render: → ${mp4} · ${el()}`);
if (enc.status === 0 && AUDIO_ONLY) rmSync(keepVid, { force: true });
if (!has("keep")) [...vids, vlist, voF, sfF, planF].forEach((f) => rmSync(f, { force: true }));

const sheet = +opt("sheet", 0);
if (sheet > 0) {
  const n = Math.ceil((to - from) / sheet), cols = 6, rows = Math.ceil(n / cols);
  const out = join(work, `sheet-${name}.jpg`);
  const vf = (txt) => `fps=1/${sheet},scale=${VW > VH ? 320 : 180}:-1,${txt ? "drawtext=text='%{pts\\:hms}':x=4:y=4:fontsize=14:fontcolor=white:box=1:boxcolor=black@0.5," : ""}tile=${cols}x${rows}`;
  const mk = (txt) => spawnSync(FFMPEG, ["-loglevel", "error", "-y", "-i", mp4, "-vf", vf(txt), "-frames:v", "1", "-update", "1", out], { encoding: "utf8" });
  if (mk(true).status !== 0) mk(false); // ffmpeg bản gọn (Homebrew) không có drawtext: tờ ảnh không in giờ, ô thứ k = from + k·S giây
  console.log(`gd-render: tờ ảnh → ${out} (giờ ghi trên ảnh tính từ đầu đoạn, cộng ${from} s)`);
}
