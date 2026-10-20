// Gói đăng YouTube cho một tập Tèo kiếm hiệp đã render: <dir>/youtube/   + ghi tập vào data/history.json
//   node <SKILL>/scripts/pack.mjs <dir> [--no-history] [--no-drive]
//   Đóng gói xong (không lỗi) thì tự chép youtube/ lên Google Drive qua drive-sync.mjs (G:/My Drive/TeoKenhYoutube/<slug>/); --no-drive để bỏ qua.
// Đầu vào: renders/final.mp4, tap.json (seo), work/plan.json, work/timeline.json, thumb/ (build.mjs dựng sẵn)
// Đầu ra: <slug>.mp4 (hardlink), thumbnail.png, tieu-de.txt, mo-ta.txt, tags.txt, DANG-YOUTUBE.md
// Không dùng ffmpeg: thumbnail chụp bằng hyperframes snapshot; thời lượng lấy từ work/timeline.json.
import { readFileSync, writeFileSync, mkdirSync, existsSync, copyFileSync, linkSync, rmSync, statSync, readdirSync } from "fs";
import { execSync } from "child_process";
import { join, resolve, basename } from "path";
import { loadLibrary } from "../engine/library.mjs";
import { HISTORY, readHistory } from "./plan.mjs";
import { storyOf, MIN_TOTAL } from "./story-check.mjs";
import { syncToDrive } from "./drive-sync.mjs";

const BRAND = "Tèo Kể", SUFFIX = ` | ${BRAND}`, TAG_BRAND = "#TeoKe";
const MAX_TITLE = 60, MAX_TAGS = 500, MAX_DESC = 5000;
const HF = "npx --yes hyperframes@0.8.172";

const die = (m) => { console.error(`pack: ${m}`); process.exit(1); };
const pad = (n) => String(n).padStart(2, "0");
const ts = (t) => { t = Math.floor(t); return `${Math.floor(t / 60)}:${pad(t % 60)}`; };

const FOOTER = `━━━━━━━━━━━━━━━
⚔️ Tèo Kể · Kiếm Hiệp: mỗi tập là một chuyến phiêu lưu giang hồ ngắn của Tèo, hoạt hình 2D vui nhộn cho cả nhà cùng xem.
💬 Mày thích chiêu nào nhất trong tập này? Bình luận cho Tèo biết nhé!
🔔 Đăng ký kênh và bật chuông để không lỡ tập tiếp theo.`;

const args = process.argv.slice(2);
const dirArg = args.find((a) => !a.startsWith("--"));
if (!dirArg) die("dùng: node pack.mjs <dir> [--no-history] [--no-drive]");
const dir = resolve(dirArg);
const slug = basename(dir);
const yt = join(dir, "youtube");
const final = join(dir, "renders/final.mp4");
for (const f of ["tap.json", "work/plan.json", "work/timeline.json", "thumb/index.html"]) if (!existsSync(join(dir, f))) die(`thiếu ${f} — chạy build.mjs trước`);
if (!existsSync(final)) die("chưa có renders/final.mp4 — render trước");

const tap = JSON.parse(readFileSync(join(dir, "tap.json"), "utf8"));
const plan = JSON.parse(readFileSync(join(dir, "work/plan.json"), "utf8"));
const timeline = JSON.parse(readFileSync(join(dir, "work/timeline.json"), "utf8"));
const lib = await loadLibrary(dir);
if (!lib.local.length) die("tập này chưa có hiệu ứng local (fx/*.mjs) — mỗi tập phải có ít nhất 1 sáng tạo riêng");
const usedLocal = lib.local.filter((e) => timeline.used.some((u) => (u.id ?? u) === e.id));
if (!usedLocal.length) die(`có fx/ nhưng không beat nào gọi tới (${lib.local.map((e) => e.id).join(", ")})`);
if (statSync(final).mtimeMs < statSync(join(dir, "work/timeline.json")).mtimeMs) die("final.mp4 cũ hơn bản build mới nhất — render lại");

const seo = tap.seo || {};
const problems = [];
const titles = [seo.title || tap.title, ...(seo.alts || [])].map((t) => t.replace(/\s*\|\s*Tèo Kể\s*$/, "").trim() + SUFFIX);
for (const t of titles) if ([...t].length > MAX_TITLE) problems.push(`tiêu đề ${[...t].length} ký tự > ${MAX_TITLE}: ${t}`);

const hashtags = [TAG_BRAND, "#KiemHiep", ...(seo.hashtags || []).map((h) => (h.startsWith("#") ? h : `#${h}`))]
  .filter((h, i, a) => a.findIndex((x) => x.toLowerCase() === h.toLowerCase()) === i).slice(0, 5);
const desc = [seo.description || "", FOOTER, hashtags.join(" ")].filter(Boolean).join("\n\n");
if (desc.length > MAX_DESC) problems.push(`mô tả ${desc.length} ký tự > ${MAX_DESC}`);
if (/[<>]/.test(desc)) problems.push("mô tả có ký tự < hoặc > (YouTube từ chối)");

const tagCost = (t) => [...t].length + (t.includes(" ") ? 2 : 0);
const tags = [];
let used = 0;
for (const t of [BRAND, "Tèo kiếm hiệp", "hoạt hình kiếm hiệp", ...(seo.tags || [])]) {
  if (tags.some((x) => x.toLowerCase() === t.toLowerCase())) continue;
  const c = tagCost(t) + (tags.length ? 1 : 0);
  if (used + c > MAX_TAGS) continue;
  tags.push(t); used += c;
}

// thumbnail: chụp thumb/ bằng hyperframes snapshot (1280×720 PNG)
mkdirSync(yt, { recursive: true });
const snapDir = join(dir, "work/thumbsnap");
rmSync(snapDir, { recursive: true, force: true });
try {
  execSync(`${HF} snapshot "${join(dir, "thumb")}" --at 0.5 --no-end -o "${snapDir}" --describe false`, { stdio: "pipe" });
} catch (e) { die("snapshot thumbnail hỏng:\n" + (e.stderr?.toString() || e.message)); }
const png = existsSync(snapDir) && readdirSync(snapDir).find((f) => f.endsWith(".png"));
if (!png) die(`snapshot không ra file png trong ${snapDir}`);
const thumbOut = join(yt, "thumbnail.png");
copyFileSync(join(snapDir, png), thumbOut);
const head = readFileSync(thumbOut).subarray(16, 24);
const [tw, th] = [head.readUInt32BE(0), head.readUInt32BE(4)];
if (tw !== 1280 || th !== 720) problems.push(`thumbnail ${tw}×${th}, cần 1280×720`);
if (statSync(thumbOut).size >= 2 * 1024 * 1024) problems.push("thumbnail.png ≥ 2 MB");

const mp4 = join(yt, `${slug}.mp4`);
rmSync(mp4, { force: true });
try { linkSync(final, mp4); } catch { copyFileSync(final, mp4); }
const dur = timeline.total;
if (dur < MIN_TOTAL) die(`video mới dài ${(dur / 60).toFixed(1)} phút, quy định ≥${MIN_TOTAL / 60} phút — kéo dài kịch bản rồi build + render lại`);
if (statSync(final).size < 100 * 1024) problems.push("final.mp4 quá nhỏ — render có thể hỏng");

writeFileSync(join(yt, "tieu-de.txt"), titles.join("\n") + "\n");
writeFileSync(join(yt, "mo-ta.txt"), desc + "\n");
writeFileSync(join(yt, "tags.txt"), tags.join(", ") + "\n");
writeFileSync(join(yt, "DANG-YOUTUBE.md"), `# ${titles[0]}

Gói đăng YouTube — skill teo-kiem-hiep (pack.mjs). Sửa \`seo\` trong tap.json rồi chạy lại để cập nhật.

| File | Dán / tải vào đâu trong YouTube Studio |
|---|---|
| \`${slug}.mp4\` | Tạo → Tải video lên (${ts(dur)}) |
| \`tieu-de.txt\` | Tiêu đề — dòng 1 là bản chính (${[...titles[0]].length} ký tự), các dòng sau dự phòng |
| \`mo-ta.txt\` | Nội dung mô tả (${desc.length}/5000 ký tự) |
| \`thumbnail.png\` | Hình thu nhỏ (PNG 1280×720) |
| \`tags.txt\` | Hiện thêm → Thẻ (${used}/500 ký tự) |

## Cài đặt nên chọn
- Ngôn ngữ: Tiếng Việt · Danh mục: Phim và hoạt hình · Playlist: Tèo Kể · Kiếm Hiệp
- **"Dành cho trẻ em?"** là quyết định pháp lý của chủ kênh (COPPA).
- Trước khi đăng, mở video xem lướt đầu – giữa – cuối.

## Hiệu ứng tập này
- Theme \`${plan.theme}\` · mở \`${plan.opener}\` · kết \`${plan.ender}\` · chiêu kết liễu \`${plan.finisher}\` · seed ${plan.seed}
- Sáng tạo riêng: ${usedLocal.map((e) => `\`${e.id}\` (${e.label})`).join(", ")}
- Độ giống thứ tự với tập gần nhất: ${plan.maxSim.toFixed(2)}
${problems.length ? `\n## ⚠ Cần sửa\n${problems.map((x) => `- ${x}`).join("\n")}\n` : ""}`);

// lịch sử chống trùng: thay entry cùng slug
if (!args.includes("--no-history")) {
  const hist = readHistory().filter((h) => h.slug !== slug);
  hist.push({ slug, ep: tap.ep, date: new Date().toISOString().slice(0, 10), theme: plan.theme, seq: plan.seq, opener: plan.opener, ender: plan.ender, finisher: plan.finisher, seed: plan.seed, local: usedLocal.map((e) => e.id), ...storyOf(tap) });
  mkdirSync(join(HISTORY, ".."), { recursive: true });
  writeFileSync(HISTORY, JSON.stringify(hist, null, 1));
}
console.log(`${problems.length ? "⚠" : "ok"} ${slug}: ${titles[0]} · ${ts(dur)} · tags ${used}/500 · history ${args.includes("--no-history") ? "bỏ qua" : "đã ghi"}${problems.length ? "\n   " + problems.join("\n   ") : ""}`);
if (problems.length) process.exit(1);
if (!args.includes("--no-drive")) {
  try { const r = syncToDrive(dir); console.log(`drive: → ${r.dest} · chép ${r.copied}, bỏ qua ${r.skipped} (đã có)${r.newer.length ? ` · ⚠ trên Drive mới hơn, không đè: ${r.newer.join(", ")}` : ""}`); }
  catch (e) { die(`đóng gói xong nhưng CHƯA lên Drive: ${e.message}`); }
}
