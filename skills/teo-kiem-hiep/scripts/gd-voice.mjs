// Giọng đọc cho tập dựng bằng Godot: <tap>/godot/loi.txt → <tap>/godot/voice/<id>.wav + voice.json (độ dài thật từng câu)
//   node <SKILL>/scripts/gd-voice.mjs <tap> [--voice tiendat] [--dry] [--local]
// Chỉ đọc bằng ZeroTTS (người dùng chốt 2026-11-03): trên Google Colab (kiem-hiep/_tools/colab-tts) hoặc máy nhà (kit/py/tts-zerotts.py).
// voice.json ghi engine "zerotts"; voice.json cũ (VieNeu, không có engine) thì mọi câu được đọc lại.
// loi.txt: mỗi câu đọc là một dòng "[id] lời đọc" (id: chữ thường/số/gạch, không trùng). Mọi dòng khác (tiêu đề, ghi chú dựng,
// đánh dấu cảnh…) công cụ này bỏ qua — cấu trúc kịch bản do từng tập tự đặt và tự đọc trong GDScript của tập.
// Có cache: câu nào chữ không đổi và còn wav thì không đọc lại. Gọi thẳng, không qua slot.sh. Colab lỗi thì dừng; chỉ --local mới đọc máy nhà (tự xin suất).
// Chỉ bản dài mới lên Colab (người dùng chốt 2026-10-24, luật chung kit/lib/mix.mjs): short (<tap>/shorts/…) hoặc sửa ngắn
// (< LONG_MIN câu cần đọc) thì đọc luôn ở máy nhà (CPU, tự xin suất) — khỏi chờ tạo phiên + cài ZeroTTS trên Colab.
import { readFileSync, writeFileSync, mkdirSync, existsSync, openSync, readSync, closeSync, unlinkSync } from "node:fs";
import { join, resolve } from "node:path";
import { spawnSync } from "node:child_process";
import { pathToFileURL } from "node:url";
import { spoken, DEFAULT_VOICE } from "../engine/voice.mjs";

const KIT = (process.env.MUSE_ROOT || "__MUSE_ROOT__") + "/kit";
const { useColab, isShort, LONG_MIN, ZEROTTS_PY, ZEROTTS_SCRIPT, colabThenLocal } = await import(pathToFileURL(KIT + "/lib/mix.mjs").href);
const argv = process.argv.slice(2);
const opt = (k, d) => { const i = argv.indexOf("--" + k); return i >= 0 ? argv[i + 1] : d; };
const die = (m) => { console.error("gd-voice: " + m); process.exit(1); };
const dir = resolve(argv.find((a) => !a.startsWith("--")) || die("thiếu <tap>"));
const voice = opt("voice", DEFAULT_VOICE);
const engine = "zerotts";
const vdir = join(dir, "godot/voice"), manFile = join(vdir, "voice.json");

const src = readFileSync(join(dir, "godot/loi.txt"), "utf8").split(/\r?\n/);
const all = [], ids = new Set();
src.forEach((ln, i) => {
  const m = ln.match(/^\s*\[([a-z0-9][a-z0-9-]*)\]\s+(.+)$/);
  if (!m) return;
  if (ids.has(m[1])) die(`dòng ${i + 1}: id "${m[1]}" trùng`);
  ids.add(m[1]);
  const t = spoken(m[2]), w = t.split(" ").length;
  if (w < 6) console.warn(`cảnh báo: [${m[1]}] chỉ ${w} từ — câu quá ngắn dễ đọc vội/méo, nên ≥10 từ`);
  if (/chương\s+(\d|sau|tới|trước)/i.test(t)) console.warn(`cảnh báo: [${m[1]}] nhắc "chương" — luật: không nói Chương X / Chương sau`);
  all.push({ id: m[1], text: t, out: join(vdir, m[1] + ".wav") });
});
if (!all.length) die("loi.txt không có dòng [id] lời đọc nào");
const old = existsSync(manFile) ? JSON.parse(readFileSync(manFile, "utf8")) : { lines: {} };
// voice.json cũ không có engine = VieNeu
const todo = all.filter((l) => !(old.voice === voice && (old.engine || "vieneu") === engine && old.lines[l.id]?.text === l.text && existsSync(l.out)));
const words = all.reduce((n, l) => n + l.text.split(" ").length, 0), wTodo = todo.reduce((n, l) => n + l.text.split(" ").length, 0);
console.log(`gd-voice: ${all.length} câu · ${words} từ · ước ${(words / 4.1 / 60).toFixed(1)} phút giọng (≈ 4,1 từ/giây) · cần đọc ${todo.length} câu (${wTodo} từ)`);
if (argv.includes("--dry")) process.exit(0);

mkdirSync(vdir, { recursive: true });
if (todo.length) {
  for (const l of todo) if (existsSync(l.out)) unlinkSync(l.out); // tts-zerotts.py bỏ qua file đã có
  const job = join(vdir, "tts-job.json");
  writeFileSync(job, JSON.stringify({ voice, lines: todo.map(({ id, text, out }) => ({ id, text, out })) }, null, 1));
  const env = { ...process.env, PYTHONIOENCODING: "utf-8", PYTHONUTF8: "1" };
  // Đọc trên Colab không cần suất máy, nên gọi gd-voice thẳng (không qua slot.sh); lùi về máy nhà thì tự xin suất ở đây.
  // Vẫn được gọi qua slot.sh (lệnh cũ): khi đó đã có suất, không xin thêm.
  const SLOT = "__MUSE_ROOT__/kiem-hiep/_tools/slot.sh";
  let who;
  const run = (py, e, script, cwd) => {
    if (who === undefined) { // chỉ dò cây tiến trình khi thật sự lùi về máy nhà
      const anc = process.platform === "win32"
        ? spawnSync("powershell", ["-NoProfile", "-c", `$p=${process.ppid}; for($i=0;$i -lt 5 -and $p;$i++){ $x=Get-CimInstance Win32_Process -Filter "ProcessId=$p"; $x.CommandLine; $p=$x.ParentProcessId }`], { encoding: "utf8" }).stdout || ""
        : spawnSync("ps", ["-o", "command=", "-p", String(process.ppid)], { encoding: "utf8" }).stdout || "";
      who = anc.includes("slot.sh") ? null : dir.split(/[\\/]/).slice(-3).join("/") + " giọng (máy nhà)";
    }
    return (who
      ? spawnSync("bash", [SLOT, who, py, script, job], { stdio: "inherit", cwd, env: e })
      : spawnSync(py, [script, job], { stdio: "inherit", cwd, env: e })).status;
  };
  // Bản dài đọc trên Google Colab (GPU T4, colab CLI); short / sửa ngắn hoặc --local thì đọc ở máy nhà (CPU, bản int8).
  const colab = !argv.includes("--local") && useColab(dir, todo.length);
  if (!colab && !argv.includes("--local")) console.log(`gd-voice: ${isShort(dir) ? "short" : `sửa ngắn (${todo.length} < ${LONG_MIN} câu)`} → đọc ở máy nhà, không lên Colab`);
  // Luật chung colabThenLocal: Colab thu hồi / không cấp GPU thì đọc nốt ở CPU máy nhà; lỗi Colab khác thì dừng, chỉ đọc máy nhà khi gọi --local
  const r = colabThenLocal(colab ? [job] : null, () => {
    if (!existsSync(ZEROTTS_PY)) die(`không thấy ZeroTTS máy nhà: ${ZEROTTS_PY}`);
    return run(ZEROTTS_PY, env, ZEROTTS_SCRIPT, dir);
  }, env);
  if (r.st !== 0) die(r.colab ? `Colab lỗi (exit ${r.st}) — xem bảng 'Lỗi Colab TTS' trong skill teo-kiem-hiep-godot, sửa rồi chạy lại; chỉ dùng --local khi người dùng cho phép`
    : `tts-zerotts.py lỗi (exit ${r.st})`);
}
function wavDur(f) {
  const fd = openSync(f, "r"), buf = Buffer.alloc(4096), n = readSync(fd, buf, 0, 4096, 0); closeSync(fd);
  let p = 12, rate = 0;
  while (p + 8 <= n) {
    const id = buf.toString("ascii", p, p + 4), len = buf.readUInt32LE(p + 4);
    if (id === "fmt ") rate = buf.readUInt32LE(p + 16);
    if (id === "data") return rate ? len / rate : die("wav lỗi: " + f);
    p += 8 + len + (len & 1);
  }
  die("wav lỗi: " + f);
}
const man = { voice, engine, lines: {} };
for (const l of all) man.lines[l.id] = { dur: Math.round(wavDur(l.out) * 1000) / 1000, text: l.text };
writeFileSync(manFile, JSON.stringify(man, null, 1));
const tot = Object.values(man.lines).reduce((s, x) => s + x.dur, 0);
console.log(`gd-voice: xong ${all.length} câu, tổng ${(tot / 60).toFixed(1)} phút giọng → ${manFile}`);
