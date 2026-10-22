// Đọc giọng VieNeu trên Google Colab (GPU T4) qua colab CLI — cùng job với kit/py/tts.py:
//   node colab-tts.mjs <job.json>      job: { "voice": "Lóng", "temperature": 0.8, "lines": [{ "id", "text", "out": "abs/path.wav" }] }
// Tự tạo phiên "tts" nếu chưa có, tự cài (setup.py), gửi từng mẻ 60 câu (synth.py), tải zip về rồi chép wav vào "out" + ghi .key như tts.py.
// Đăng nhập colab một lần trong terminal: colab sessions (dán mã Google).
// Hai lệnh cùng lúc thì chờ nhau (.lock, người chờ ghi tên vào .wait/). Xong job mà không còn ai chờ thì tắt phiên (GPU tốn hạn mức);
// COLAB_TTS_KEEP=1 để luôn giữ phiên. Tắt tay: node colab-tts.mjs --stop
import { readFileSync, writeFileSync, mkdirSync, copyFileSync, existsSync, rmSync, statSync, readdirSync } from "node:fs";
import { join, dirname } from "node:path";
import { spawnSync } from "node:child_process";
import { createHash } from "node:crypto";
import { tmpdir, homedir } from "node:os";
import { fileURLToPath } from "node:url";

const HERE = dirname(fileURLToPath(import.meta.url));
const COLAB = process.env.COLAB_CLI || "colab";
const VOICES = join(process.env.VIENEU_HOME || join(homedir(), ".vieneu"), "user_voices_v3_turbo.json");
const S = "tts", BATCH = 60, LOCK = join(HERE, ".lock"), WAIT = join(HERE, ".wait");
const env = { ...process.env, PYTHONUTF8: "1", PYTHONIOENCODING: "utf-8", MSYS_NO_PATHCONV: "1" };
let tmp = null, locked = false; // locked: đã giữ phiên → die phải dọn phiên + thư mục tạm như lúc xong
const die = (m) => { console.error("colab-tts: " + m); if (locked) finish(); release(); process.exit(1); };
const sleep = (ms) => Atomics.wait(new Int32Array(new SharedArrayBuffer(4)), 0, 0, ms);

function colab(args, { quiet = false, timeout } = {}) {
  const r = spawnSync(COLAB, args, { env, encoding: "utf8", maxBuffer: 64 << 20, timeout });
  const out = (r.stdout || "") + (r.stderr || "");
  if (!quiet) process.stdout.write(out.split("\n").filter((l) => !/it\/s\]|B\/s\]|reconstructing|downloading bytes|^\s*$/.test(l)).map((l) => l + "\n").join(""));
  return { ok: r.status === 0, out, hung: r.error?.code === "ETIMEDOUT" };
}

function acquire() {
  // COLAB_TTS_NOWAIT=1: phiên đang bận job khác thì thoát mã 75 ngay (gd-voice sẽ đọc bằng GPU máy nhà thay vì xếp hàng)
  if (process.env.COLAB_TTS_NOWAIT === "1") {
    try { mkdirSync(LOCK); writeFileSync(join(LOCK, "pid"), String(process.pid)); return; } catch {}
    if (Date.now() - statSync(LOCK).mtimeMs <= 3 * 3600e3) { console.log("colab-tts: phiên Colab đang bận job khác"); process.exit(75); }
  }
  mkdirSync(WAIT, { recursive: true });
  const me = join(WAIT, String(process.pid));
  writeFileSync(me, "");
  for (let i = 0; ; i++) {
    try { mkdirSync(LOCK); writeFileSync(join(LOCK, "pid"), String(process.pid)); rmSync(me, { force: true }); return; } catch {}
    if (Date.now() - statSync(LOCK).mtimeMs > 3 * 3600e3) { rmSync(LOCK, { recursive: true, force: true }); continue; }
    if (i % 12 === 0) console.log("colab-tts: phiên Colab đang bận job khác, chờ…");
    sleep(5000);
  }
}
const waiting = () => (existsSync(WAIT) ? readdirSync(WAIT).filter((f) => Date.now() - statSync(join(WAIT, f)).mtimeMs < 6 * 3600e3).length : 0);
// tắt phiên (GPU tốn hạn mức) trừ khi COLAB_TTS_KEEP=1 hoặc còn job chờ dùng tiếp; dùng cả khi xong lẫn khi die
function finish() {
  if (process.env.COLAB_TTS_KEEP !== "1" && !waiting()) { console.log("colab-tts: tắt phiên Colab"); colab(["stop", "-s", S], { quiet: true, timeout: 120e3 }); }
  else console.log("colab-tts: giữ phiên (COLAB_TTS_KEEP=1 hoặc còn job chờ)");
  if (tmp) rmSync(tmp, { recursive: true, force: true });
}
function release() { if (existsSync(join(LOCK, "pid")) && readFileSync(join(LOCK, "pid"), "utf8") === String(process.pid)) rmSync(LOCK, { recursive: true, force: true }); }

if (process.argv[2] === "--stop") { colab(["stop", "-s", S]); process.exit(0); }
const job = JSON.parse(readFileSync(process.argv[2] || die("thiếu <job.json>"), "utf8"));
const todo = job.lines.map((it) => ({ ...it, key: createHash("sha1").update(job.voice + "|" + it.text).digest("hex") }))
  .filter((it) => !(existsSync(it.out) && existsSync(it.out.replace(/\.wav$/, ".key")) && readFileSync(it.out.replace(/\.wav$/, ".key"), "utf8") === it.key));
console.log(`colab-tts: ${job.lines.length - todo.length} cached, ${todo.length} to synthesize`);
if (!todo.length) process.exit(0);
if (!existsSync(COLAB) && spawnSync(COLAB, ["--help"], { stdio: "ignore" }).status !== 0) die("không thấy colab CLI: " + COLAB);
if (!existsSync(VOICES)) die("không thấy giọng đã lưu: " + VOICES);

acquire();
locked = true;
process.on("exit", release);
tmp = join(tmpdir(), "colab-tts-" + process.pid);
mkdirSync(tmp, { recursive: true });
const probe = join(tmp, "probe.py");
writeFileSync(probe, 'import os\nprint("READY" if os.path.exists("/content/.vieneu_ready") else "NEW")\n');

// phiên đứt kết nối thì exec treo hoặc báo "Connection was lost": tắt phiên đó rồi tạo phiên mới
let p = colab(["exec", "-s", S, "-f", probe], { quiet: true, timeout: 120e3 });
if (!p.ok && (p.hung || p.out.includes("Connection was lost"))) {
  console.log("colab-tts: phiên cũ mất kết nối — tắt để tạo phiên mới");
  colab(["stop", "-s", S], { quiet: true, timeout: 120e3 });
}
if (!p.ok) {
  console.log("colab-tts: tạo phiên GPU T4…");
  if (!colab(["new", "-s", S, "--gpu", "T4"]).ok) die("không tạo được phiên Colab (hết hạn mức GPU? chưa đăng nhập?)");
  p = colab(["exec", "-s", S, "-f", probe], { quiet: true });
  if (!p.ok) die("phiên mới không chạy được code:\n" + p.out);
}
if (!p.out.includes("READY")) {
  console.log("colab-tts: cài VieNeu lên phiên…");
  const mk = join(tmp, "mk.py");
  writeFileSync(mk, 'import os\nfor d in ("/content/up", "/content/vieneu_home", "/content/jobs", "/content/out"):\n    os.makedirs(d, exist_ok=True)\n');
  if (!colab(["exec", "-s", S, "-f", mk], { quiet: true }).ok) die("không tạo được thư mục trên phiên");
  if (!colab(["upload", "-s", S, join(HERE, "onnx_runtime_lite.py"), "/content/up/onnx_runtime_lite.py"]).ok) die("upload bản vá lỗi");
  if (!colab(["upload", "-s", S, VOICES, "/content/vieneu_home/user_voices_v3_turbo.json"]).ok) die("upload giọng lỗi");
  const st = colab(["exec", "-s", S, "-f", join(HERE, "setup.py"), "--timeout", "1200"]);
  if (!st.out.includes("SETUP_OK")) die("cài VieNeu lỗi");
}

const t0 = Date.now(), stamp = Date.now().toString(36);
for (let b = 0; b < todo.length; b += BATCH) {
  const part = todo.slice(b, b + BATCH), name = `j${stamp}-${b / BATCH}`;
  const jf = join(tmp, name + ".json");
  writeFileSync(jf, JSON.stringify({ voice: job.voice, temperature: job.temperature ?? 0.8, lines: part.map(({ id, text }) => ({ id, text })) }));
  if (!colab(["upload", "-s", S, jf, `/content/jobs/${name}.json`], { quiet: true }).ok) die("upload job lỗi");
  console.log(`colab-tts: mẻ ${b / BATCH + 1}/${Math.ceil(todo.length / BATCH)} (${part.length} câu)`);
  let ok = false;
  // colab exec đôi khi treo không trả kết quả (phiên vẫn rảnh): quá 8 phút thì giết cả cây tiến trình rồi gửi lại
  for (let k = 0; k < 4 && !ok; k++) {
    const r = colab(["exec", "-s", S, "-f", join(HERE, "synth.py"), "--env", "JOB=" + name, "--timeout", "1800"], { timeout: 480e3 });
    ok = r.out.includes("ZIP_OK");
    if (r.hung) {
      console.log(`colab-tts: mẻ ${name} treo quá 8 phút — gửi lại`);
      spawnSync("pkill", ["-f", `JOB=${name}`]);
    }
  }
  if (!ok) die(`mẻ ${name} đọc lỗi sau 4 lần`);
  const zp = join(tmp, name + ".zip"), xd = join(tmp, name);
  if (!colab(["download", "-s", S, `/content/out/${name}.zip`, zp], { quiet: true }).ok) die("tải zip lỗi");
  mkdirSync(xd, { recursive: true });
  if (spawnSync("tar", ["-xf", zp, "-C", xd]).status !== 0) die("giải nén lỗi: " + zp); // bsdtar của Windows đọc được zip, GNU tar thì không
  for (const it of part) {
    const w = join(xd, it.id + ".wav");
    if (!existsSync(w)) die("thiếu wav " + it.id);
    mkdirSync(dirname(it.out), { recursive: true });
    copyFileSync(w, it.out);
    writeFileSync(it.out.replace(/\.wav$/, ".key"), it.key);
  }
}
console.log(`colab-tts: xong ${todo.length} câu trong ${Math.round((Date.now() - t0) / 1000)}s`);
finish();
