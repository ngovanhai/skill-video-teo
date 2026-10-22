// Giọng đọc Tèo (VieNeu "Lóng", giống kênh Tèo Kể) cho một tập: <dir>/tap.json → <dir>/voice/*.wav + <dir>/voice/voice.json
//   node <SKILL>/scripts/voice.mjs <dir> [--voice Lóng] [--dry] [--no-gpu]
// Đọc mọi beat `say` (lời trong bong bóng), mọi beat có `vo` (lời kể của Tèo, không hiện bong bóng) và mọi `card` (không có vo thì đọc chữ trên thẻ).
// Có cache: dòng nào chưa đổi chữ thì không đọc lại. Sau đó chạy build.mjs, build tự lấy độ dài thật của giọng.
import { readFileSync, writeFileSync, mkdirSync, existsSync, openSync, readSync, closeSync } from "fs";
import { join, resolve } from "path";
import { spawnSync } from "child_process";
import { spoken, keyOf, voOf, DEFAULT_VOICE } from "../engine/voice.mjs";

const KIT = (process.env.MUSE_ROOT || "__MUSE_ROOT__") + "/kit";
const VIENEU = process.env.VIENEU_DIR || "__VIENEU_DIR__";
const VIENEU_PY = join(VIENEU, process.platform === "win32" ? ".venv/Scripts/python.exe" : ".venv/bin/python");
// GPU (AMD RX 6600 XT qua DirectML), giống kit/make.mjs: nhanh ~1,5×. Tắt bằng --no-gpu hoặc file kit/gpu-off. GPU lỗi → tự chạy lại bằng CPU (cache giữ câu đã xong).
const VIENEU_DML_PY = join(VIENEU, ".venv-dml/Scripts/python.exe");
const argv = process.argv.slice(2);
const dir = resolve(argv.find((a) => !a.startsWith("--")) || die("thiếu <dir>"));
const opt = (k, d) => { const i = argv.indexOf("--" + k); return i >= 0 ? argv[i + 1] : d; };
function die(m) { console.error("voice: " + m); process.exit(1); }

const tap = JSON.parse(readFileSync(join(dir, "tap.json"), "utf8"));
const voice = opt("voice", tap.voice || DEFAULT_VOICE);

const lines = [], seen = new Set(), warns = [];
tap.scenes.forEach((sc, i) => (sc.beats || []).forEach((b, j) => {
  for (const text of [b.do === "say" ? b.text : null, voOf(b)].filter(Boolean)) {
    const t = spoken(text), id = keyOf(voice, text);
    if (!t) continue;
    const words = t.split(" ").length;
    if (words < 6) warns.push(`cảnh ${i + 1} beat ${j + 1}: "${t}" chỉ ${words} từ, VieNeu dễ đọc vội/méo; nên viết câu ≥10 từ`);
    if (seen.has(id)) continue;
    seen.add(id);
    lines.push({ id, text: t, out: join(dir, "voice", id + ".wav") });
  }
}));

warns.forEach((w) => console.warn("cảnh báo: " + w));
const words = lines.reduce((n, l) => n + l.text.split(" ").length, 0);
console.log(`voice: ${lines.length} dòng · ${words} từ · ước ${Math.round(words / 4.1)} s giọng (Lóng ≈ 4,1 từ/giây) · TTS ≈ ${Math.round((words / 4.1) * 0.8 / 60)} phút máy`);
if (argv.includes("--dry")) process.exit(0);
if (!existsSync(VIENEU_PY)) die(`không thấy VieNeu: ${VIENEU_PY}`);

mkdirSync(join(dir, "voice"), { recursive: true });
const job = join(dir, "voice", "tts-job.json");
writeFileSync(job, JSON.stringify({ voice, temperature: tap.voice_temperature ?? 0.8, lines }, null, 1));
const PYENV = { ...process.env, PYTHONIOENCODING: "utf-8", PYTHONUTF8: "1" };
const tts = (py, env) => spawnSync(py, [join(KIT, "py/tts.py"), job], { stdio: "inherit", cwd: VIENEU, env }).status;
const gpu = !argv.includes("--no-gpu") && !existsSync(join(KIT, "gpu-off")) && existsSync(VIENEU_DML_PY);
let st = gpu ? tts(VIENEU_DML_PY, { ...PYENV, VIENEU_ORT_PROVIDERS: "DmlExecutionProvider", VIENEU_ORT_GPU_PARTS: "pre,dec,codec" }) : -1;
if (gpu) console.log(st === 0 ? "voice: TTS chạy GPU (DirectML)" : "voice: ! GPU lỗi (exit " + st + ") — chạy lại bằng CPU");
if (st !== 0) st = tts(VIENEU_PY, PYENV);
if (st !== 0) die("tts.py lỗi (exit " + st + ")");

// Độ dài wav đọc thẳng từ header (không cần ffprobe)
function wavDur(f) {
  const fd = openSync(f, "r"), buf = Buffer.alloc(4096);
  const n = readSync(fd, buf, 0, 4096, 0); closeSync(fd);
  let p = 12, rate = 0, size = 0;
  while (p + 8 <= n) {
    const id = buf.toString("ascii", p, p + 4), len = buf.readUInt32LE(p + 4);
    if (id === "fmt ") rate = buf.readUInt32LE(p + 16); // byteRate
    if (id === "data") { size = len; break; }
    p += 8 + len + (len & 1);
  }
  if (!rate || !size) die("wav lỗi: " + f);
  return size / rate;
}
const manifest = { voice, lines: {} };
for (const l of lines) manifest.lines[l.id] = { file: `voice/${l.id}.wav`, dur: Math.round(wavDur(l.out) * 100) / 100, text: l.text };
writeFileSync(join(dir, "voice", "voice.json"), JSON.stringify(manifest, null, 1));
const total = Object.values(manifest.lines).reduce((s, x) => s + x.dur, 0);
console.log(`voice: xong ${lines.length} dòng, tổng ${Math.round(total)} s giọng → ${join(dir, "voice", "voice.json")}`);
