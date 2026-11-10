#!/usr/bin/env node
// Làm "êm" thư viện sfx (người dùng chốt 2026-10-24: không có tiếng ùm ùm tùm tùm gây giật mình, sfx luôn nhỏ hơn giọng đọc).
//   node kit/sfx-soft.mjs [thư mục sfx…]   (mặc định kit/sfx và chuong-2d/engine/sfx)
// Bản gốc giữ ở <thư mục>/_goc/ (lần đầu chạy tự chép vào); mỗi lần chạy đều làm lại từ bản gốc nên chạy lại không bị hạ chồng.
// Mỗi file: lọc trầm dưới HP Hz (bỏ tiếng nổ/bass ù), hạ về tối đa TARGET LUFS (file nhỏ hơn thì giữ, không kéo to lên),
// chặn đỉnh PEAK dBFS, fade-out 80 ms. Giọng đọc VieNeu ≈ -20 LUFS, nên sfx ở data-volume ≤ 0.6 luôn thấp hơn giọng ≥ 8 dB.
import { readdirSync, mkdirSync, existsSync, copyFileSync } from "node:fs";
import { join, dirname } from "node:path";
import { spawnSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const KIT = dirname(fileURLToPath(import.meta.url));
const HP = 180, TARGET = -26, PEAK = -12;
const HPF = Array(3).fill(`highpass=f=${HP}:poles=2`).join(","); // 3 tầng = dốc 36 dB/quãng tám: tiếng nổ bass gốc quá mạnh, 1 tầng còn sót ù
const dirs = process.argv.slice(2).length ? process.argv.slice(2) : [join(KIT, "sfx"), join("__SKILLS_DIR__/chuong-2d/engine/sfx")];

const lufs = (f) => {
  const r = spawnSync("ffmpeg", ["-hide_banner", "-nostats", "-i", f, "-af", `${HPF},ebur128`, "-f", "null", "-"], { encoding: "utf8" });
  const m = [...(r.stderr || "").matchAll(/I:\s+(-?[\d.]+|-inf) LUFS/g)].pop();
  return m && m[1] !== "-inf" ? +m[1] : -70;
};
const dur = (f) => +spawnSync("ffprobe", ["-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", f], { encoding: "utf8" }).stdout || 1;

for (const dir of dirs) {
  if (!existsSync(dir)) { console.log(`bỏ qua (không có): ${dir}`); continue; }
  const goc = join(dir, "_goc");
  mkdirSync(goc, { recursive: true });
  for (const f of readdirSync(dir).filter((f) => f.endsWith(".mp3"))) if (!existsSync(join(goc, f))) copyFileSync(join(dir, f), join(goc, f));
  for (const f of readdirSync(goc).filter((f) => f.endsWith(".mp3"))) {
    const src = join(goc, f), I = lufs(src), gain = Math.min(0, TARGET - I), d = dur(src);
    const af = `${HPF},volume=${gain.toFixed(1)}dB,alimiter=limit=${Math.pow(10, PEAK / 20).toFixed(3)}:level=false,afade=t=out:st=${Math.max(0, d - 0.08).toFixed(2)}:d=0.08`;
    const r = spawnSync("ffmpeg", ["-v", "error", "-y", "-i", src, "-af", af, "-c:a", "libmp3lame", "-q:a", "2", join(dir, f)], { encoding: "utf8" });
    if (r.status !== 0) { console.error(`✗ ${f}: ${r.stderr}`); process.exitCode = 1; continue; }
    console.log(`${dir.replace(process.env.HOME, "~")}/${f}: sau lọc trầm ${I.toFixed(1)} LUFS → hạ ${gain.toFixed(1)} dB, đỉnh ≤ ${PEAK} dBFS`);
  }
}
