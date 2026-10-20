// Gói đăng YouTube cho một video Tèo đã render: videos/<slug>/youtube/
//   node <SKILL_DIR>/scripts/youtube-pack.mjs videos/<slug> [videos/<slug2> …]
//   node <SKILL_DIR>/scripts/youtube-pack.mjs --all          (mọi video có renders/final.mp4 + youtube/seo.json, trừ _pilot)
//   Thêm --no-drive để KHÔNG chép lên Google Drive (mặc định: video đóng gói không lỗi được chép youtube/ sang G:/My Drive/TeoKenhYoutube/<slug>/ qua drive-sync.mjs).
// Đầu vào do người viết: youtube/seo.json = { "title": "...", "alts": ["...", "..."] }   (KHÔNG ghi đuôi "| Tèo Kể", script tự gắn)
// Đầu ra: <slug>.mp4 (hardlink tới renders/final.mp4), thumbnail.png, tieu-de.txt, mo-ta.txt, tags.txt, phu-de.vi.srt, DANG-YOUTUBE.md
// Chỉ đọc video.json / chapters / words / work/timeline.json; không ghi gì ngoài thư mục youtube/.
import { readFileSync, writeFileSync, mkdirSync, existsSync, copyFileSync, linkSync, rmSync, statSync, readdirSync } from "fs";
import { execFileSync } from "child_process";
import { join, resolve, basename } from "path";
import { syncToDrive } from "./drive-sync.mjs";

const BRAND = "Tèo Kể"; // dấu ấn kênh: đuôi mọi tiêu đề + hashtag đầu tiên
const SUFFIX = ` | ${BRAND}`;
const TAG_BRAND = "#TeoKe";
const MAX_TITLE = 60, MAX_TAGS = 500, MAX_DESC = 5000;
const LEAD = 0.25, TAIL = 0.3; // phải khớp kit/make.mjs (layout)

const die = (m) => { console.error(`youtube-pack: ${m}`); process.exit(1); };
const pad = (n, w) => String(n).padStart(w, "0");
const ts = (t) => { t = Math.floor(t); const h = Math.floor(t / 3600), m = Math.floor((t % 3600) / 60), s = t % 60; return (h ? `${h}:${pad(m, 2)}` : `${m}`) + `:${pad(s, 2)}`; };
const srtTime = (t) => { const ms = Math.round(t * 1000); return `${pad(Math.floor(ms / 3600000), 2)}:${pad(Math.floor(ms / 60000) % 60, 2)}:${pad(Math.floor(ms / 1000) % 60, 2)},${pad(ms % 1000, 3)}`; };
const probe = (file, entries) => execFileSync("ffprobe", ["-v", "error", "-show_entries", entries, "-of", "default=nw=1", file], { encoding: "utf8" });

const FOOTER = `━━━━━━━━━━━━━━━
👋 ${BRAND}: mỗi video là một chuyến khám phá dài hơn 20 phút về khoa học, lịch sử và truyện kể, bằng hoạt hình 2D cho cả nhà cùng xem.
📚 Thông tin trong video được đối chiếu từ nhiều nguồn tin cậy. Thấy chỗ nào chưa đúng, bạn bình luận cho Tèo biết nhé!
🔔 Đăng ký kênh và bật chuông để không lỡ chuyến khám phá tiếp theo cùng Tèo.`;

function pack(dir) {
  const slug = basename(dir);
  const yt = join(dir, "youtube");
  const final = join(dir, "renders/final.mp4");
  if (!existsSync(final)) die(`${slug}: chưa có renders/final.mp4`);
  if (!existsSync(join(yt, "seo.json"))) die(`${slug}: thiếu youtube/seo.json (title + alts)`);
  const seo = JSON.parse(readFileSync(join(yt, "seo.json"), "utf8"));
  const video = JSON.parse(readFileSync(join(dir, "video.json"), "utf8"));
  const p = video.publish || {};
  const problems = [];

  // tiêu đề: dấu ấn + giới hạn độ dài
  const titles = [seo.title, ...(seo.alts || [])].map((t) => t.trim() + SUFFIX);
  for (const t of titles) if ([...t].length > MAX_TITLE) problems.push(`tiêu đề ${[...t].length} ký tự > ${MAX_TITLE}: ${t}`);

  // mô tả: hook + nội dung (video.json) + mốc thời gian + chân trang cố định + hashtag
  const timeline = JSON.parse(readFileSync(join(dir, "work/timeline.json"), "utf8"));
  const stamps = timeline.map((c, i) => `${ts(i === 0 ? 0 : c.start)} ${i === 0 ? p.intro_label || "Mở đầu" : c.title}`);
  const tagsHash = [TAG_BRAND, ...(p.hashtags || []).map((h) => (h.startsWith("#") ? h : `#${h}`))]
    .filter((h, i, a) => a.findIndex((x) => x.toLowerCase() === h.toLowerCase()) === i && h.toLowerCase() !== "#teo").slice(0, 5);
  const desc = [p.description || "", `⏱ Mốc thời gian\n${stamps.join("\n")}`, FOOTER, tagsHash.join(" ")].join("\n\n");
  if (desc.length > MAX_DESC) problems.push(`mô tả ${desc.length} ký tự > ${MAX_DESC}`);
  if (/[<>]/.test(desc)) problems.push("mô tả có ký tự < hoặc > (YouTube từ chối)");

  // tags: thương hiệu trước, bỏ trùng, cắt cho vừa 500 ký tự (YouTube tính cả dấu phẩy, tag có khoảng trắng +2 cho ngoặc kép)
  const tagCost = (t) => [...t].length + (t.includes(" ") ? 2 : 0);
  const tags = [];
  let used = 0;
  for (const t of [BRAND, "Kênh của Tèo", ...(p.tags || []).filter((t) => t !== "Tèo")]) {
    if (tags.some((x) => x.toLowerCase() === t.toLowerCase())) continue;
    const c = tagCost(t) + (tags.length ? 1 : 0);
    if (used + c > MAX_TAGS) continue;
    tags.push(t); used += c;
  }

  // phụ đề .srt từ word timings (tái dựng layout của kit: cảnh nối tiếp, mỗi cảnh LEAD + voice + TAIL + hold)
  const chapters = (video.chapters || []).map((c) => (typeof c === "string" ? JSON.parse(readFileSync(join(dir, c), "utf8")) : c));
  let n = 0, t0 = 0;
  const words = [];
  for (const ch of chapters) for (const s of ch.scenes) {
    const w = JSON.parse(readFileSync(join(dir, "words", `s${pad(++n, 3)}.json`), "utf8")); // kit đánh số s001… theo thứ tự
    for (const x of w.words) words.push({ text: x.text, start: t0 + LEAD + x.start, end: t0 + LEAD + x.end });
    t0 += LEAD + w.dur + TAIL + (s.hold || 0);
  }
  const total = timeline.reduce((a, c) => a + c.dur, 0);
  if (Math.abs(t0 - total) > 1) problems.push(`phụ đề lệch timeline ${(t0 - total).toFixed(2)} s`);
  const cues = [];
  let cur = [];
  const flush = () => { if (cur.length) cues.push({ start: cur[0].start, end: cur.at(-1).end, text: cur.map((w) => w.text).join(" ") }); cur = []; };
  for (const w of words) {
    if (cur.length && (w.start - cur.at(-1).end > 0.6 || [...cur.map((x) => x.text).join(" ")].length + w.text.length > 42 || w.end - cur[0].start > 5)) flush();
    cur.push(w);
    if (/[.?!…:;]$/.test(w.text)) flush();
  }
  flush();
  const cueEnd = (c, i) => Math.min(Math.max(c.end, c.start + 0.5), cues[i + 1]?.start ?? Infinity); // ≥0,5 s nhưng không chồng dòng sau
  const srt = cues.map((c, i) => `${i + 1}\n${srtTime(c.start)} --> ${srtTime(cueEnd(c, i))}\n${c.text}\n`).join("\n");

  // thumbnail: bắt buộc PNG 1280×720 < 2 MB; khác chuẩn thì ffmpeg đổi lại
  const thumbSrc = join(dir, "thumbnail.png");
  if (!existsSync(thumbSrc)) die(`${slug}: thiếu thumbnail.png`);
  mkdirSync(yt, { recursive: true });
  const thumbOut = join(yt, "thumbnail.png");
  const info = probe(thumbSrc, "stream=codec_name,width,height");
  if (/codec_name=png/.test(info) && /width=1280/.test(info) && /height=720/.test(info)) copyFileSync(thumbSrc, thumbOut);
  else execFileSync("ffmpeg", ["-v", "error", "-y", "-i", thumbSrc, "-vf", "scale=1280:720:force_original_aspect_ratio=increase,crop=1280:720", "-frames:v", "1", thumbOut]);
  if (statSync(thumbOut).size >= 2 * 1024 * 1024) problems.push("thumbnail.png ≥ 2 MB");

  // video: hardlink (không tốn thêm ổ đĩa), hỏng thì copy
  const mp4 = join(yt, `${slug}.mp4`);
  rmSync(mp4, { force: true });
  try { linkSync(final, mp4); } catch { copyFileSync(final, mp4); }
  const dur = parseFloat(probe(final, "format=duration").split("=")[1]);
  const streams = probe(final, "stream=codec_type");
  if (dur <= 1200) problems.push(`video chỉ ${(dur / 60).toFixed(1)} phút (≤ 20)`);
  if (!/video/.test(streams) || !/audio/.test(streams)) problems.push("final.mp4 thiếu stream video hoặc audio");

  writeFileSync(join(yt, "tieu-de.txt"), titles.join("\n") + "\n");
  writeFileSync(join(yt, "mo-ta.txt"), desc + "\n");
  writeFileSync(join(yt, "tags.txt"), tags.join(", ") + "\n");
  writeFileSync(join(yt, "phu-de.vi.srt"), srt);
  writeFileSync(join(yt, "DANG-YOUTUBE.md"), `# ${titles[0]}

Gói đăng YouTube — tạo bởi skill video-teo (youtube-pack). Sửa \`seo.json\` rồi chạy lại script để cập nhật.

| File | Dán / tải vào đâu trong YouTube Studio |
|---|---|
| \`${slug}.mp4\` | Tạo → Tải video lên (${ts(dur)}) |
| \`tieu-de.txt\` | Tiêu đề — dòng 1 là bản chính (${[...titles[0]].length} ký tự), dòng 2–3 dự phòng / để thử A/B |
| \`mo-ta.txt\` | Nội dung mô tả (${desc.length}/5000 ký tự; mốc thời gian tự thành chương trên thanh tua) |
| \`thumbnail.png\` | Hình thu nhỏ (PNG 1280×720) |
| \`tags.txt\` | Hiện thêm → Thẻ (${used}/500 ký tự) |
| \`phu-de.vi.srt\` | Phụ đề → Thêm ngôn ngữ: Tiếng Việt → Tải tệp lên → "Có thời gian" |

## Cài đặt nên chọn
- Ngôn ngữ video và tiêu đề: Tiếng Việt · Danh mục: Giáo dục
- Danh sách phát: xếp vào playlist cùng mảng (Khoa học / Lịch sử / Truyện kể)
- Màn hình kết thúc: Đăng ký + 1 video khác của kênh (20 giây cuối) · Thẻ: video liên quan ở giữa video
- **Đối tượng người xem ("Dành cho trẻ em?")** là quyết định pháp lý của chủ kênh (COPPA). Chọn "Có" thì YouTube tắt bình luận, chuông thông báo, thẻ, màn hình kết thúc và hình mờ của video đó.
- Trước khi đăng, mở video xem lướt đầu – giữa – cuối.

## Dữ kiện nên kiểm lại
${p.notes || "(không có ghi chú)"}
${problems.length ? `\n## ⚠ Cần sửa\n${problems.map((x) => `- ${x}`).join("\n")}\n` : ""}`);
  console.log(`${problems.length ? "⚠" : "ok"} ${slug}: ${titles[0]} · ${(dur / 60).toFixed(1)} phút · ${cues.length} dòng phụ đề · tags ${used}/500${problems.length ? "\n   " + problems.join("\n   ") : ""}`);
  return problems.length;
}

const argv = process.argv.slice(2), noDrive = argv.includes("--no-drive");
const args = argv.filter((a) => a !== "--no-drive");
if (!args.length) die("cần đường dẫn videos/<slug> hoặc --all");
const dirs = args[0] === "--all"
  ? readdirSync(resolve("videos")).filter((d) => d !== "_pilot" && existsSync(join("videos", d, "youtube/seo.json"))).map((d) => resolve("videos", d))
  : args.map((a) => resolve(a));
let bad = 0;
for (const d of dirs) {
  if (pack(d)) { bad++; continue; }
  if (noDrive) continue;
  try { const r = syncToDrive(d); console.log(`   drive: → ${r.dest} · chép ${r.copied}, bỏ qua ${r.skipped} (đã có)${r.newer.length ? ` · ⚠ trên Drive mới hơn, không đè: ${r.newer.join(", ")}` : ""}`); }
  catch (e) { console.error(`   drive: CHƯA lên Drive — ${e.message}`); bad++; }
}
if (bad) { console.error(`${bad} video còn lỗi — xem mục "Cần sửa" trong DANG-YOUTUBE.md`); process.exit(1); }
