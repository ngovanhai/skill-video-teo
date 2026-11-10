// Trộn sẵn mọi <audio> của index.html thành assets/mix.m4a và ghi index-mix.html chỉ còn 1 track.
// Lý do: hyperframes render trên Windows lỗi "spawn ENAMETOOLONG" khi có ~400 clip audio.
// Dùng: node premix.mjs <dir>  → rồi render với -c index-mix.html
import fs from "node:fs"; import path from "node:path"; import { execFileSync } from "node:child_process";
const dir = path.resolve(process.argv[2] || ".");
const html = fs.readFileSync(path.join(dir, "index.html"), "utf8");
const tags = [...html.matchAll(/<audio[^>]*>\s*<\/audio>/g)].map((m) => m[0]);
const attr = (t, k) => (t.match(new RegExp(`${k}="([^"]*)"`)) || [])[1];
const tl = JSON.parse(fs.readFileSync(path.join(dir, "work/timeline.json"), "utf8"));
const total = +tl.total;
const parts = [], labels = [];
tags.forEach((t, i) => {
  const src = attr(t, "src"), st = +attr(t, "data-start"), du = +attr(t, "data-duration"), vol = +(attr(t, "data-volume") ?? 1);
  const ms = Math.round(st * 1000);
  parts.push(`amovie=${src},aformat=sample_rates=48000:channel_layouts=stereo,atrim=0:${du},asetpts=PTS-STARTPTS,volume=${vol},adelay=${ms}|${ms}[a${i}]`);
  labels.push(`[a${i}]`);
});
// amix theo nhóm 32 để đỡ nặng
let cur = labels, lvl = 0;
while (cur.length > 1) {
  const next = [];
  for (let i = 0; i < cur.length; i += 32) {
    const g = cur.slice(i, i + 32), o = `[m${lvl}_${i}]`;
    parts.push(g.length > 1 ? `${g.join("")}amix=inputs=${g.length}:normalize=0:dropout_transition=0${o}` : `${g[0]}anull${o}`);
    next.push(o);
  }
  cur = next; lvl++;
}
parts.push(`${cur[0]}apad,atrim=0:${total},alimiter=limit=0.95[out]`);
fs.mkdirSync(path.join(dir, "work"), { recursive: true });
const fsPath = path.join(dir, "work/mix.filter");
fs.writeFileSync(fsPath, parts.join(";\n"));
execFileSync("ffmpeg", ["-y", "-hide_banner", "-loglevel", "error", "-/filter_complex", "work/mix.filter", "-map", "[out]", "-c:a", "aac", "-b:a", "192k", "assets/mix.m4a"], { cwd: dir, stdio: "inherit" });
const single = `<audio id="mix0" src="assets/mix.m4a" data-start="0" data-duration="${total}" data-track-index="12" data-volume="1"></audio>`;
let first = true;
const out = html.replace(/<audio[^>]*>\s*<\/audio>/g, () => (first ? ((first = false), single) : ""));
fs.writeFileSync(path.join(dir, "index-mix.html"), out);
console.log(`premix: ${tags.length} clip → assets/mix.m4a (${total.toFixed(2)} s), index-mix.html`);
