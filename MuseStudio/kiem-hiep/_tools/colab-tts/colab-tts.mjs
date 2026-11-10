// Đọc giọng bằng ZeroTTS trên Google Colab (GPU T4) qua colab CLI — cùng job + cùng .key với kit/py/tts-zerotts.py (người dùng chốt 2026-11-03):
//   node colab-tts.mjs <job.json>      job: { "voice": "tiendat", "lines": [{ "id", "text", "out": "abs/path.wav" }] }
// Tự tạo phiên "tts" nếu chưa có, tự cài (setup-zerotts.py), mỗi lần gửi giọng (~/.zerotts/voices) + kit/py/tts-zerotts.py lên,
// gửi từng mẻ 60 câu (synth-zerotts.py), tải zip về rồi chép wav vào "out" + ghi .key như tts-zerotts.py.
// Đăng nhập colab một lần trong terminal: colab sessions (dán mã Google).
// Hai lệnh cùng lúc thì chờ nhau (.lock, người chờ ghi tên vào .wait/). Xong job thì thoát ngay, phiên để lại cho job kế: một tiến trình nền (--reap, log ở .reap.log)
// tắt phiên khi 15 phút liền (COLAB_TTS_GRACE) không job nào gọi Colab (GPU tốn hạn mức); COLAB_TTS_KEEP=1 để luôn giữ phiên. Tắt tay: node colab-tts.mjs --stop
//   node colab-tts.mjs --align <job.json> [model]   căn chữ bằng Whisper trên cùng phiên (kit/make.mjs stage align gọi; cài qua setup-align.py, chạy align-run.py)
import { readFileSync, writeFileSync, mkdirSync, copyFileSync, existsSync, rmSync, statSync, readdirSync, openSync } from "node:fs";
import { join, dirname } from "node:path";
import { spawnSync, spawn } from "node:child_process";
import { createHash } from "node:crypto";
import { tmpdir, homedir } from "node:os";
import { fileURLToPath } from "node:url";

const HERE = dirname(fileURLToPath(import.meta.url));
const COLAB = process.env.COLAB_CLI || "colab";
const VOICES = process.env.ZEROTTS_VOICES_HOME || join(homedir(), ".zerotts/voices"); // mỗi giọng một thư mục: voice.npz + meta.json
const ZT_PY = process.env.ZEROTTS_PY_SRC || join(HERE, "../../../kit/py/tts-zerotts.py");
const GRACE = Number(process.env.COLAB_TTS_GRACE ?? 15);
const S = "tts", BATCH = 60, LOCK = join(HERE, ".lock"), WAIT = join(HERE, ".wait");
const LAST = join(HERE, ".last"), REAPER = join(HERE, ".reaper"); // LAST: lúc job cuối xong; REAPER: pid tiến trình nền đang canh giờ tắt
const env = { ...process.env, PYTHONUTF8: "1", PYTHONIOENCODING: "utf-8", MSYS_NO_PATHCONV: "1" };
let tmp = null, locked = false; // locked: đã giữ phiên → die phải dọn phiên + thư mục tạm như lúc xong
const die = (m) => { console.error("colab-tts: " + m); if (locked) finish(false); release(); process.exit(1); };
// Colab thu hồi / không cấp GPU: mã 75 = nơi gọi làm ở CPU máy nhà (người dùng chốt 2026-11-03); mẻ đã tải về giữ .key nên không đọc lại
const toLocal = (m) => { console.log(`colab-tts: ${m} → làm ở CPU máy nhà`); if (locked) finish(false); release(); process.exit(75); };
const sleep = (ms) => Atomics.wait(new Int32Array(new SharedArrayBuffer(4)), 0, 0, ms);

// timeout: colab.exe là trình khởi động gọi tiếp python, timeout của spawnSync chỉ giết tiến trình con trực tiếp nên lệnh vẫn treo.
// Nên chạy qua run-timeout.mjs: quá hạn thì taskkill /T cả cây, thoát mã 124 (powershell canh giờ tách riêng không chạy được ở đây).
// tries: lệnh lặp lại được (mk, upload, download, setup) thì thử lại khi lỗi hoặc treo — phiên mới tạo hay treo ở lệnh đầu.
function colab(args, { quiet = false, timeout, tries = 1 } = {}) {
  let res;
  for (let k = 0; k < tries; k++) {
    if (k) console.log(`colab-tts: ${args[0]} ${res.hung ? "treo" : "lỗi"} — thử lại (${k + 1}/${tries})`);
    res = colab1(args, { quiet, timeout });
    if (res.ok) break;
  }
  return res;
}
function colab1(args, { quiet, timeout }) {
  const r = timeout
    ? spawnSync(process.execPath, [join(HERE, "run-timeout.mjs"), String(Math.round(timeout / 1000)), COLAB, ...args], { env, encoding: "utf8", maxBuffer: 64 << 20 })
    : spawnSync(COLAB, args, { env, encoding: "utf8", maxBuffer: 64 << 20 });
  const out = (r.stdout || "") + (r.stderr || "");
  if (!quiet) process.stdout.write(out.split("\n").filter((l) => !/it\/s\]|B\/s\]|reconstructing|downloading bytes|^\s*$/.test(l)).map((l) => l + "\n").join(""));
  return { ok: r.status === 0, out, hung: r.status === 124 };
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
// Phiên Colab tắt là mất sạch bản cài, job sau phải tạo phiên + cài lại VieNeu (3–5 phút). Nên xong job thì nhả khoá, ghi giờ vào .last rồi thoát ngay
// (không bắt gd-voice đứng chờ); việc canh COLAB_TTS_GRACE phút (mặc định 15) giao cho tiến trình nền reap().
function finish(grace = true) { // die gọi finish(false): phiên có thể hỏng, tắt luôn nếu không ai chờ
  if (tmp) rmSync(tmp, { recursive: true, force: true });
  if (process.env.COLAB_TTS_KEEP === "1") return console.log("colab-tts: giữ phiên (COLAB_TTS_KEEP=1)");
  release(); locked = false;
  if (grace) {
    writeFileSync(LAST, String(Date.now()));
    const log = openSync(join(HERE, ".reap.log"), "a");
    spawn(process.execPath, [fileURLToPath(import.meta.url), "--reap"], { detached: true, windowsHide: true, stdio: ["ignore", log, log], env: process.env }).unref();
    return console.log(`colab-tts: giữ phiên — ${GRACE} phút không job nào gọi Colab thì tự tắt (log: .reap.log)`);
  }
  if (waiting()) return console.log("colab-tts: còn job chờ — giữ phiên");
  try { mkdirSync(LOCK); writeFileSync(join(LOCK, "pid"), String(process.pid)); } catch { return console.log("colab-tts: có job khác dùng tiếp — giữ phiên"); }
  console.log("colab-tts: tắt phiên Colab");
  colab(["stop", "-s", S], { quiet: true, timeout: 120e3 });
  release();
}
// Tiến trình nền: chỉ một con canh giờ (con mới ghi đè .reaper, con cũ thấy pid khác thì tự thoát).
// Có job giữ khoá hoặc đang chờ thì tính lại từ đầu; đủ GRACE phút rảnh thì giành khoá rồi mới tắt (không tắt giữa job người khác).
function reap() {
  writeFileSync(REAPER, String(process.pid));
  const mine = () => existsSync(REAPER) && readFileSync(REAPER, "utf8") === String(process.pid);
  const log = (m) => console.log(`${new Date().toLocaleString("vi-VN")} [${process.pid}] ${m}`);
  let busy = 0; // lần cuối thấy có job dùng/chờ Colab
  log(`canh phiên, tắt sau ${GRACE} phút rảnh`);
  for (;;) {
    sleep(5000);
    if (!mine()) return log("có tiến trình canh mới hơn — thoát");
    if (existsSync(LOCK) || waiting()) { busy = Date.now(); continue; }
    const last = Math.max(busy, existsSync(LAST) ? Number(readFileSync(LAST, "utf8")) || 0 : 0);
    if (Date.now() - last < GRACE * 60e3) continue;
    try { mkdirSync(LOCK); writeFileSync(join(LOCK, "pid"), String(process.pid)); } catch { continue; }
    log(`${GRACE} phút không job nào gọi Colab — tắt phiên`);
    colab(["stop", "-s", S], { quiet: true, timeout: 120e3 });
    release();
    if (mine()) rmSync(REAPER, { force: true });
    return;
  }
}
function release() { if (existsSync(join(LOCK, "pid")) && readFileSync(join(LOCK, "pid"), "utf8") === String(process.pid)) rmSync(LOCK, { recursive: true, force: true }); }

if (process.argv[2] === "--stop") { rmSync(REAPER, { force: true }); colab(["stop", "-s", S]); process.exit(0); }
if (process.argv[2] === "--reap") { reap(); process.exit(0); }
// --align <job.json> [model]: căn chữ (chạy chính kit/py/align.py bằng GPU) trên cùng phiên + cùng khoá. Job như align.py;
// key cache tính ở máy nhà y như align.py (text|mtime wav|model) nên chạy align.py ở nhà sau đó vẫn nhận cache.
// --min N: cần làm ít hơn N câu (sau cache) thì không lên Colab, thoát mã 75 để nơi gọi làm ở máy nhà (luật "sửa ngắn → CPU", kit/lib/mix.mjs)
const mi = process.argv.indexOf("--min"), MIN = mi > 0 ? +process.argv[mi + 1] || 0 : 0;
const pos = process.argv.slice(2).filter((a, i, all) => a !== "--min" && all[i - 1] !== "--min");
const ALIGN = pos[0] === "--align", MODEL = ALIGN ? pos[2] || "small" : "";
const ALIGN_PY = process.env.ALIGN_PY || join(HERE, "../../../kit/py/align.py");
const job = JSON.parse(readFileSync(pos[ALIGN ? 1 : 0] || die("thiếu <job.json>"), "utf8"));
const wordsKey = (it) => createHash("sha1").update(it.text + "|" + statSync(it.out, { bigint: true }).mtimeNs + "|" + MODEL).digest("hex");
const wordsCached = (it) => { try { return JSON.parse(readFileSync(it.words, "utf8")).key === it.key; } catch { return false; } };
const todo = ALIGN
  ? job.lines.map((it) => (existsSync(it.out) ? { ...it, key: wordsKey(it) } : die("thiếu wav " + it.out))).filter((it) => !wordsCached(it))
  : job.lines.map((it) => ({ ...it, key: createHash("sha1").update("zerotts|" + job.voice + "|" + it.text).digest("hex") })) // = line_key của tts-zerotts.py
    .filter((it) => !(existsSync(it.out) && existsSync(it.out.replace(/\.wav$/, ".key")) && readFileSync(it.out.replace(/\.wav$/, ".key"), "utf8") === it.key));
console.log(`colab-tts: ${job.lines.length - todo.length} cached, ${todo.length} to ${ALIGN ? "align" : "synthesize"}`);
if (!todo.length) process.exit(0);
if (todo.length < MIN) { console.log(`colab-tts: chỉ ${todo.length} câu (< ${MIN}) — sửa ngắn, làm ở máy nhà`); process.exit(75); }
if (!existsSync(COLAB) && spawnSync(COLAB, ["--help"], { stdio: "ignore" }).status !== 0) die("không thấy colab CLI: " + COLAB);
const voiceDirs = ALIGN || !existsSync(VOICES) ? [] : readdirSync(VOICES).filter((d) => existsSync(join(VOICES, d, "voice.npz")) && existsSync(join(VOICES, d, "meta.json")));
if (!ALIGN && !existsSync(ZT_PY)) die("không thấy tts-zerotts.py: " + ZT_PY);
if (ALIGN && !existsSync(ALIGN_PY)) die("không thấy align.py: " + ALIGN_PY);

acquire();
locked = true;
process.on("exit", release);
tmp = join(tmpdir(), "colab-tts-" + process.pid);
mkdirSync(tmp, { recursive: true });
const probe = join(tmp, "probe.py");
writeFileSync(probe, 'import os\nprint("ALIVE", *(m.upper() + "_READY" for m in ("zerotts", "whisper") if os.path.exists(f"/content/.{m}_ready")))\n');

// Phiên sẵn sàng: dò, tạo mới nếu mất, tạo thư mục, cài nếu chưa, gửi code + giọng.
const up = (src, dst, what) => colab(["upload", "-s", S, src, dst], { quiet: true, timeout: 120e3, tries: 3 }).ok || die(`upload ${what} lỗi`);
function ready() {
  // phiên đứt kết nối thì exec treo hoặc báo "Connection was lost": tắt phiên đó rồi tạo phiên mới
  let p = colab(["exec", "-s", S, "-f", probe], { quiet: true, timeout: 120e3 });
  if (!p.ok && (p.hung || p.out.includes("Connection was lost"))) {
    console.log("colab-tts: phiên cũ mất kết nối — tắt để tạo phiên mới");
    colab(["stop", "-s", S], { quiet: true, timeout: 120e3 });
  }
  if (!p.ok) {
    console.log("colab-tts: tạo phiên GPU T4…");
    if (!colab(["new", "-s", S, "--gpu", "T4"], { timeout: 300e3, tries: 2 }).ok) toLocal("không tạo được phiên GPU Colab (hết hạn mức GPU? chưa đăng nhập?)");
    p = colab(["exec", "-s", S, "-f", probe], { quiet: true, timeout: 120e3, tries: 3 });
    if (!p.ok) die("phiên mới không chạy được code:\n" + p.out);
  }
  const mk = join(tmp, "mk.py"), dirs = ["/content/up", "/content/jobs", "/content/out", "/content/al", ...voiceDirs.map((d) => "/root/.zerotts/voices/" + d)];
  writeFileSync(mk, `import os\nfor d in ${JSON.stringify(dirs)}:\n    os.makedirs(d, exist_ok=True)\n`);
  if (!colab(["exec", "-s", S, "-f", mk], { quiet: true, timeout: 120e3, tries: 3 }).ok) die("không tạo được thư mục trên phiên");
  if (!p.out.includes(ALIGN ? "WHISPER_READY" : "ZEROTTS_READY")) {
    console.log(`colab-tts: cài ${ALIGN ? "Whisper" : "ZeroTTS"} lên phiên…`);
    const st = colab(["exec", "-s", S, "-f", join(HERE, ALIGN ? "setup-align.py" : "setup-zerotts.py"), "--timeout", "1200"], { timeout: 1300e3, tries: 2 });
    if (!st.out.includes("SETUP_OK")) die(`cài ${ALIGN ? "Whisper" : "ZeroTTS"} lỗi`);
  }
  // align.py / tts-zerotts.py + giọng gửi lên mỗi lần (nhỏ) để Colab luôn chạy đúng bản ở máy nhà
  if (ALIGN) up(ALIGN_PY, "/content/up/align.py", "align.py");
  else {
    up(ZT_PY, "/content/up/tts_zerotts.py", "tts-zerotts.py");
    for (const d of voiceDirs) for (const f of ["voice.npz", "meta.json"]) up(join(VOICES, d, f), `/root/.zerotts/voices/${d}/${f}`, "giọng " + d);
  }
}
ready();

// TTS: gửi job json, nhận zip wav. Căn chữ: gửi zip (job.json + flac 16 kHz mono — Whisper cũng tự hạ về 16 kHz mono, nhẹ hơn wav nhiều lần), nhận zip words json.
function sendJob(part, name) {
  if (!ALIGN) {
    const jf = join(tmp, name + ".json");
    writeFileSync(jf, JSON.stringify({ voice: job.voice, lines: part.map(({ id, text }) => ({ id, text })) }));
    if (!colab(["upload", "-s", S, jf, `/content/jobs/${name}.json`], { quiet: true, timeout: 120e3, tries: 3 }).ok) die("upload job lỗi");
    return;
  }
  const pd = join(tmp, name + "-in"), rd = `/content/al/${name}`;
  mkdirSync(pd, { recursive: true });
  for (const it of part) {
    const r = spawnSync("ffmpeg", ["-v", "error", "-y", "-i", it.out, "-ar", "16000", "-ac", "1", join(pd, it.id + ".flac")], { encoding: "utf8" });
    if (r.status !== 0) die(`ffmpeg đổi ${it.out} lỗi: ${r.stderr || r.error?.message}`);
  }
  writeFileSync(join(pd, "job.json"), JSON.stringify({ names: job.names,
    lines: part.map(({ id, text, key }) => ({ id, text, key, out: `${rd}/${id}.flac`, words: `${rd}/w/${id}.json` })) }));
  const zp = join(tmp, name + "-in.zip");
  if (spawnSync("tar", ["--format", "zip", "-cf", zp, "-C", pd, "job.json", ...part.map((it) => it.id + ".flac")]).status !== 0) die("nén mẻ lỗi: " + zp);
  if (!colab(["upload", "-s", S, zp, `/content/jobs/${name}.zip`], { quiet: true, timeout: 600e3, tries: 3 }).ok) die("upload mẻ lỗi");
}
function takeResult(part, xd) {
  for (const it of part) {
    const f = join(xd, it.id + (ALIGN ? ".json" : ".wav"));
    if (!existsSync(f)) die(`thiếu ${ALIGN ? "words" : "wav"} ${it.id}`);
    const dst = ALIGN ? it.words : it.out;
    mkdirSync(dirname(dst), { recursive: true });
    copyFileSync(f, dst);
    if (!ALIGN) writeFileSync(it.out.replace(/\.wav$/, ".key"), it.key);
  }
}

const t0 = Date.now(), stamp = Date.now().toString(36);
const RUN = ALIGN ? ["-f", join(HERE, "align-run.py"), "--env", "MODEL=" + MODEL] : ["-f", join(HERE, "synth-zerotts.py")];
for (let b = 0; b < todo.length; b += BATCH) {
  const part = todo.slice(b, b + BATCH), name = `${ALIGN ? "a" : "j"}${stamp}-${b / BATCH}`;
  sendJob(part, name);
  console.log(`colab-tts: mẻ ${b / BATCH + 1}/${Math.ceil(todo.length / BATCH)} (${part.length} câu${ALIGN ? ", căn chữ" : ""})`);
  let ok = false;
  // colab exec đôi khi treo không trả kết quả (phiên vẫn rảnh): quá 8 phút thì colab() giết cả cây tiến trình, gửi lại.
  // Phiên bị Colab thu hồi giữa mẻ ("appears to be lost" / "not found"): người dùng chốt 2026-11-03 → làm ở CPU máy nhà (mã 75).
  for (let k = 0; k < 4 && !ok; k++) {
    const r = colab(["exec", "-s", S, ...RUN, "--env", "JOB=" + name, "--timeout", "1800"], { timeout: 480e3 });
    ok = r.out.includes("ZIP_OK");
    if (r.hung) console.log(`colab-tts: mẻ ${name} treo quá 8 phút — gửi lại`);
    if (!ok && /appears to be lost|Session '[^']*' not found/.test(r.out)) toLocal(`Colab thu hồi phiên GPU giữa mẻ ${name}`);
  }
  if (!ok) die(`mẻ ${name} ${ALIGN ? "căn chữ" : "đọc"} lỗi sau 4 lần`);
  const zp = join(tmp, name + ".zip"), xd = join(tmp, name);
  if (!colab(["download", "-s", S, `/content/out/${name}.zip`, zp], { quiet: true, timeout: 300e3, tries: 3 }).ok) die("tải zip lỗi");
  mkdirSync(xd, { recursive: true });
  if (spawnSync("tar", ["-xf", zp, "-C", xd]).status !== 0) die("giải nén lỗi: " + zp); // bsdtar của Windows đọc được zip, GNU tar thì không
  takeResult(part, xd);
}
console.log(`colab-tts: xong ${todo.length} câu${ALIGN ? " căn chữ" : ""} trong ${Math.round((Date.now() - t0) / 1000)}s`);
finish();
