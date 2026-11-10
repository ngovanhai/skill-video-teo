// Luật âm thanh + luật chọn nơi đọc giọng dùng chung cho mọi pipeline (kit/make.mjs, video-teo build-short, teo-kiem-hiep build/gd-render/gd-voice).
// Người dùng chốt 2026-10-24:
//   - Không có sfx "ùm ùm tùm tùm" gây giật mình; sfx luôn nhỏ hơn giọng đọc; nhạc nền nhỏ hơn hẳn giọng.
//   - Short và sửa ngắn (ít câu) thì đọc giọng/căn chữ bằng máy nhà (CPU) luôn; chỉ bản dài mới lên Colab.
//   - 2026-11-03: Colab thu hồi / không cấp GPU thì làm ở CPU máy nhà; lỗi Colab khác vẫn dừng (colabThenLocal).
// Giọng (ZeroTTS, tts-zerotts.py kéo về) ≈ -20 LUFS. Thư viện sfx đã làm êm bằng kit/sfx-soft.mjs (lọc trầm < 180 Hz, ≤ -26 LUFS, đỉnh ≤ -12 dBFS).
import { existsSync, readFileSync, writeFileSync, statSync, readdirSync, copyFileSync, mkdirSync } from "node:fs";
import { join, dirname } from "node:path";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const KIT = join(dirname(fileURLToPath(import.meta.url)), "..");
// Người dùng chốt 2026-10-29: KHÔNG chèn hiệu ứng âm thanh nào (kèn, sáo, chuông, "beng beng", whoosh…) — chỉ giọng + nhạc nền.
// Mọi pipeline đọc SFX_ON; muốn bật lại phải được người dùng cho phép.
export const SFX_ON = false;
export const SFX_MAX = 0.6; // trần âm lượng một sfx (data-volume / hệ số) → sfx thấp hơn giọng ≥ 8 dB
export const SFX_MAX_DB = 20 * Math.log10(SFX_MAX);
export const BGM_LUFS = -40; // nhạc nền sau trộn ≤ -40 LUFS (thấp hơn giọng ≥ 20 dB)
export const LONG_MIN = 30; // ít hơn chừng này câu cần đọc/căn = "sửa ngắn" → máy nhà
// Người dùng chốt 2026-11-03: chỉ dùng ZeroTTS (bỏ VieNeu). Bản dài đọc trên Colab (kiem-hiep/_tools/colab-tts), short / sửa ngắn
// đọc ở máy nhà bằng ZEROTTS_SCRIPT (CPU, bản int8); hai nơi cùng job + cùng .key.
export const ZEROTTS_PY = (process.env.ZEROTTS_DIR || "__ZEROTTS_DIR__") + (process.platform === "win32" ? "/.venv/Scripts/python.exe" : "/.venv/bin/python");
export const ZEROTTS_SCRIPT = join(KIT, "py/tts-zerotts.py");
const r3 = (x) => Math.round(x * 1000) / 1000;

export const sfxVol = (v) => r3(Math.min(v ?? 0.35, SFX_MAX));
export const sfxDb = (db) => Math.min(db || 0, SFX_MAX_DB);

// độ to (LUFS tích hợp) của một file, cache cạnh file: <file>.lufs = "<mtimeMs> <LUFS>"
export function lufsOf(file) {
  const side = file + ".lufs", m = statSync(file).mtimeMs;
  if (existsSync(side)) { const [t, v] = readFileSync(side, "utf8").split(" "); if (+t === m) return +v; }
  const r = spawnSync("ffmpeg", ["-hide_banner", "-nostats", "-i", file, "-af", "ebur128", "-f", "null", "-"], { encoding: "utf8", maxBuffer: 256 << 20 });
  const hit = [...(r.stderr || "").matchAll(/I:\s+(-?[\d.]+) LUFS/g)].pop();
  // đo lỗi: coi như file rất to (-10 LUFS) để nhạc bị hạ chứ không bị kéo to, và không ghi cache để lần sau đo lại
  if (!hit) { console.warn(`mix: không đo được độ to ${file} — tạm coi -10 LUFS`); return -10; }
  writeFileSync(side, `${m} ${hit[1]}`);
  return +hit[1];
}
// âm lượng nhạc nền: số người viết muốn (nếu có) nhưng không bao giờ to hơn mức BGM_LUFS
export const bgmVol = (file, wanted) => r3(Math.min(wanted ?? Infinity, Math.pow(10, (BGM_LUFS - lufsOf(file)) / 20)));
export const bgmDb = (file, wantedDb) => Math.min(wantedDb ?? Infinity, BGM_LUFS - lufsOf(file));

// chép bản sfx êm từ kit/sfx vào thư mục sfx của video/tập (thay bản cũ khi khác cỡ file)
export function syncSfx(dst) {
  mkdirSync(dst, { recursive: true });
  let n = 0;
  for (const f of readdirSync(join(KIT, "sfx")).filter((f) => /^lib-.*\.mp3$/.test(f))) {
    const s = join(KIT, "sfx", f), d = join(dst, f);
    if (!existsSync(d) || statSync(d).size !== statSync(s).size) { copyFileSync(s, d); n++; }
  }
  return n;
}

// đọc giọng / căn chữ ở đâu: short (đường dẫn có /shorts/) hoặc ít hơn LONG_MIN câu → máy nhà; còn lại → Colab
export const isShort = (dir) => /[\\/]shorts[\\/]/.test(dir + "/");
export const useColab = (dir, nTodo) => !isShort(dir) && nTodo >= LONG_MIN;

// Luật chung đọc giọng / căn chữ: thử Colab, rồi làm ở CPU máy nhà CHỈ khi colab-tts trả 75 — "việc ngắn" (--min, chốt 2026-10-24)
// hoặc "Colab thu hồi / không cấp phiên GPU" (người dùng chốt 2026-11-03). Lỗi Colab khác trả nguyên mã để nơi gọi dừng (lỗi Colab thì sửa Colab).
// colabArgs: tham số cho colab-tts.mjs, null = không lên Colab; local(): chạy bản máy nhà, trả mã thoát. Câu đã tải về từ Colab có cache .key.
// Trả { st, colab }: colab = true khi lỗi là của Colab (nơi gọi in hướng dẫn sửa Colab), false khi lỗi ở bản máy nhà.
export const COLAB_TTS = process.env.COLAB_TTS || join(KIT, "../kiem-hiep/_tools/colab-tts/colab-tts.mjs");
export function colabThenLocal(colabArgs, local, env = process.env) {
  if (colabArgs) {
    if (!existsSync(COLAB_TTS)) return { st: 1, colab: true };
    const st = spawnSync(process.execPath, [COLAB_TTS, ...colabArgs], { stdio: "inherit", env }).status;
    if (st !== 75) return { st, colab: true };
  }
  return { st: local(), colab: false };
}
