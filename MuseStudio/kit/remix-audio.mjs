// Dựng lại riêng phần tiếng của renders/final.mp4 (giọng + nhạc nền, theo work/chNN.html sau `--stage build`),
// giữ nguyên hình — dùng khi đổi luật âm thanh (vd. 2026-10-29 bỏ hết sfx) mà không muốn render lại hình.
// node kit/remix-audio.mjs <dir video>   → renders/final.mp4 (bản cũ đổi tên final.old.mp4)
// node kit/remix-audio.mjs <dir short> --short → renders/short.mp4 theo index.html (short dựng bằng build-short)
// Thẻ <audio> trỏ vào assets/sfx bị bỏ qua, nên không cần build lại.
import { readFileSync, writeFileSync, existsSync, renameSync, mkdirSync } from "node:fs";
import { join, resolve } from "node:path";
import { spawnSync } from "node:child_process";

const dir = resolve(process.argv[2] || die("thiếu <dir video>"));
const P = (...a) => join(dir, ...a);
function die(m) { console.error("remix-audio: " + m); process.exit(1); }
// -nostdin + hạn 15 phút (KILL): 2026-10-29 một ffmpeg của script này treo 55 phút sau khi node cha chết, bỏ qua TERM
const run = (args) => {
  const r = spawnSync("ffmpeg", ["-nostdin", "-hide_banner", "-v", "error", "-y", ...args], { stdio: ["ignore", "inherit", "inherit"], timeout: 15 * 60e3, killSignal: "SIGKILL" });
  if (r.error || r.status) die(r.error?.code === "ETIMEDOUT" ? "ffmpeg quá 15 phút, đã giết" : "ffmpeg lỗi");
};

const SHORT = process.argv.includes("--short");
const tl = SHORT ? [{ id: "index", file: P("index.html"), dur: +readFileSync(P("index.html"), "utf8").match(/data-composition-id="main"[^>]*data-duration="([\d.]+)"/)[1] }]
  : JSON.parse(readFileSync(P("work/timeline.json"), "utf8"));
const tmp = P("work/remix"); mkdirSync(tmp, { recursive: true });
const attr = (tag, k) => (tag.match(new RegExp(`${k}="([^"]*)"`)) || [])[1];
const wavs = [];
for (const ch of tl) {
  const html = readFileSync(ch.file || P("work", `${ch.id}.html`), "utf8");
  const tags = [...html.matchAll(/<audio [^>]*>/g)].map((m) => m[0]).filter((t) => !attr(t, "src").includes("assets/sfx"));
  const ins = [], fl = [];
  tags.forEach((t, i) => {
    const st = +attr(t, "data-start"), d = +attr(t, "data-duration"), ms = +(attr(t, "data-media-start") || 0), v = +(attr(t, "data-volume") || 1);
    ins.push("-i", P(attr(t, "src")));
    fl.push(`[${i}:a]aresample=48000,aformat=channel_layouts=stereo,atrim=${ms}:${ms + d},asetpts=PTS-STARTPTS,volume=${v},adelay=${Math.round(st * 1000)}:all=1[a${i}]`);
  });
  const out = join(tmp, `${ch.id}.wav`);
  fl.push(`${tags.map((_, i) => `[a${i}]`).join("")}amix=inputs=${tags.length}:normalize=0:duration=longest,apad=whole_dur=${ch.dur},atrim=0:${ch.dur}[o]`);
  run([...ins, "-filter_complex", fl.join(";"), "-map", "[o]", "-c:a", "pcm_s16le", out]);
  wavs.push(out);
  process.stdout.write(`${ch.id} `);
}
const list = join(tmp, "list.txt");
writeFileSync(list, wavs.map((f) => `file '${f}'`).join("\n") + "\n");
const base = SHORT ? "short" : "final", mp4 = P(`renders/${base}.mp4`), old = P(`renders/${base}.old.mp4`);
if (!existsSync(mp4)) die(`chưa có renders/${base}.mp4`);
renameSync(mp4, old);
run(["-i", old, "-f", "concat", "-safe", "0", "-i", list, "-map", "0:v", "-map", "1:a", "-c:v", "copy", "-c:a", "aac", "-b:a", "192k", "-ar", "48000",
  "-af", "alimiter=limit=0.95:level=false", "-shortest", mp4]);
console.log(`\nremix-audio: xong ${mp4} (bản cũ: ${old})`);
