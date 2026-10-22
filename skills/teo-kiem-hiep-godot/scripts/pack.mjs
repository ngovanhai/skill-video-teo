// Gói đăng YouTube cho tập Godot: renders/final.mp4 + thumb/thumb-godot.png + story.json seo → <tap>/youtube/
//   node <SKILL>/scripts/pack.mjs <thư mục tập>
// Ra: <slug>.mp4, thumbnail.png (1280×720), tieu-de.txt, mo-ta.txt (seo.mo_ta + seo.chan viết theo giọng khung của tập), tags.txt
// Short dọc (<tap>/shorts/<NN-ten>): ra <tap>/youtube/shorts/<NN-ten>.mp4 + .txt (tiêu đề #Shorts, mô tả, tag); không cần ảnh bìa.
import { existsSync, mkdirSync, readFileSync, writeFileSync, copyFileSync } from "node:fs";
import { join, resolve, basename, dirname } from "node:path";
import { spawnSync } from "node:child_process";

const FFMPEG = "C:/Users/Administrator/AppData/Local/Microsoft/WinGet/Links/ffmpeg.exe";
const FFPROBE = FFMPEG.replace(/ffmpeg\.exe$/, "ffprobe.exe");
if (!process.argv[2]) { console.log("dùng: node pack.mjs <thư mục tập>"); process.exit(1); }
const TAP = resolve(process.argv[2]), slug = basename(TAP), Y = join(TAP, "youtube");
const die = (m) => { console.error(m); process.exit(1); };
const plain = (t) => t.normalize("NFD").replace(/[\u0300-\u036f]/g, "").replace(/đ/g, "d").replace(/Đ/g, "D").replace(/\s+/g, "");

if (basename(dirname(TAP)) === "shorts") {
  const vid = join(TAP, "renders/final.mp4"), st = join(TAP, "godot/story.json");
  for (const f of [vid, st]) if (!existsSync(f)) die("thiếu " + f);
  const seo = JSON.parse(readFileSync(st, "utf8")).seo || {};
  if (!seo.title || seo.title.includes("…") || !seo.mo_ta) die("story.json seo.title / seo.mo_ta chưa viết");
  const wh = spawnSync(existsSync(FFPROBE) ? FFPROBE : "ffprobe", ["-v", "error", "-select_streams", "v:0", "-show_entries", "stream=width,height", "-of", "csv=p=0", vid], { encoding: "utf8" })
    .stdout.split(/[,\s]+/).filter(Boolean).map(Number);
  if (wh[0] !== 1080 || wh[1] !== 1920) die(`short phải 1080×1920 (đang ${wh.join("×")})`);
  const out = join(dirname(dirname(TAP)), "youtube/shorts");
  mkdirSync(out, { recursive: true });
  copyFileSync(vid, join(out, slug + ".mp4"));
  const tags = seo.tags || [];
  const title = /#shorts/i.test(seo.title) ? seo.title : seo.title + " #Shorts";
  const hash = ["#Shorts", "#TeoKe", "#KiemHiep", ...tags.slice(0, 3).map((t) => "#" + plain(t))];
  writeFileSync(join(out, slug + ".txt"), [
    `TIÊU ĐỀ:\n${title}`,
    `\nMÔ TẢ:\n${seo.mo_ta.trim()}\n\n${hash.join(" ")}`,
    `\nTAG:\n${["Tèo Kể", "kiếm hiệp", ...tags].join(", ")}`,
    `\nGHI CHÚ:\n- Video dọc 1080×1920, dưới 3 phút → YouTube tự xếp vào Shorts.\n- Bản đầy đủ: ${seo.full || "(link tập dài sau khi đăng)"}`,
  ].join("\n") + "\n");
  console.log("xong " + join(out, slug + ".mp4") + " + .txt");
  process.exit(0);
}

const vid = join(TAP, "renders/final.mp4"), th = join(TAP, "thumb/thumb-godot.png"), st = join(TAP, "godot/story.json");
for (const f of [vid, th, st]) if (!existsSync(f)) die("thiếu " + f);
const seo = JSON.parse(readFileSync(st, "utf8")).seo || {};
if (!seo.title || !seo.mo_ta || !seo.chan) die("story.json seo.title / seo.mo_ta / seo.chan chưa viết");
mkdirSync(Y, { recursive: true });
copyFileSync(vid, join(Y, slug + ".mp4"));
spawnSync(FFMPEG, ["-y", "-v", "error", "-i", th, "-vf", "scale=1280:720:flags=lanczos", join(Y, "thumbnail.png")], { stdio: "inherit" });
const tags = seo.tags || [];
const hash = ["#TeoKe", "#KiemHiep", ...tags.slice(0, 4).map((t) => "#" + plain(t))];
writeFileSync(join(Y, "tieu-de.txt"), seo.title + "\n");
writeFileSync(join(Y, "mo-ta.txt"), `${seo.mo_ta}

━━━━━━━━━━━━━━━
${seo.chan.trim()}

${hash.join(" ")}
`);
writeFileSync(join(Y, "tags.txt"), ["Tèo Kể", "kiếm hiệp", ...tags].join(", ") + "\n");
console.log("xong " + Y);
