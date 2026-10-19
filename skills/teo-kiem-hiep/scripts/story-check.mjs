// Chống trùng CHỦ ĐỀ: tóm tắt các tập trước (đề bài nối mạch) + soi tap.json nháp có lặp chủ đề cũ / thiếu nguồn không.
//   node <SKILL>/scripts/story-check.mjs [<dir tập>] [--history <file>]
// Không có dir: chỉ in tóm tắt + thống kê. Có dir/tap.json: in thêm ✗ (phải sửa) và ! (nên xem).
// Thoát mã 1 khi còn ✗. Chỉ đọc, không ghi gì. pack.mjs dùng storyOf() để ghi trường chủ đề vào history.
import { readFileSync, existsSync } from "fs";
import { join, resolve } from "path";
import { pathToFileURL } from "url";
import { readHistory } from "./plan.mjs";
import { SETS } from "../engine/sets.mjs";

// doi-dau: nhân vật vs nhân vật · so-vo: võ công vs võ công · tac-gia · tac-pham · top: xếp hạng
// mon-phai: môn phái vs môn phái · binh-khi: thần binh · giai-ma: bí ẩn / vì sao
// cuoc-doi · su-that · neu-nhu (what-if) · cap-doi · su-do (thầy trò) · phan-dien · phim-vs-truyen · dong-thoi-gian · chieu-thuc
// an-so: "cái bóng" ít ai để ý cạnh ngôi sao (Đả Cẩu Bổng cạnh Hàng Long, Hư Trúc cạnh Tiêu Phong…)
export const FORMATS = ["doi-dau", "so-vo", "tac-gia", "tac-pham", "top", "mon-phai", "binh-khi", "giai-ma",
  "cuoc-doi", "su-that", "neu-nhu", "cap-doi", "su-do", "phan-dien", "phim-vs-truyen", "dong-thoi-gian", "chieu-thuc", "an-so"];
// Mỗi video phải dài ít nhất 20 phút (tổng timeline, giây).
export const MIN_TOTAL = 1200;

// Trường chủ đề của một tập, lấy từ tap.json — pack.mjs trải thẳng vào bản ghi history.
export function storyOf(tap) {
  const cast = tap.cast || {};
  const beats = (tap.scenes || []).flatMap((s) => s.beats || []);
  return {
    title: tap.title,
    hook: tap.hook,
    next: tap.ender?.next || "",
    sets: (tap.scenes || []).map((s) => s.set),
    chars: Object.entries(cast).filter(([id, c]) => c.kind !== "teo" && id !== "teo").map(([, c]) => c.name),
    moves: beats.filter((b) => b.do === "attack" && b.name).map((b) => b.name),
    story: tap.story || null,
  };
}

const norm = (s = "") => s.normalize("NFD").replace(/[̀-ͯ]/g, "").replace(/đ/g, "d").replace(/Đ/g, "D").toLowerCase().replace(/[^a-z0-9 ]/g, " ").replace(/\s+/g, " ").trim();
const STOP = new Set(["teo", "va", "cua", "la", "mot", "voi", "cho", "nhung", "gap", "o", "tai", "ai", "the", "nao", "vs", "hon"]);
const words = (s) => new Set(norm(s).split(" ").filter((w) => w.length > 1 && !STOP.has(w)));
const jaccard = (a, b) => { const A = words(a), B = words(b); if (!A.size || !B.size) return 0; let n = 0; for (const w of A) if (B.has(w)) n++; return n / (A.size + B.size - n); };
const overlap = (a, b) => { const A = words(a), B = words(b); if (!A.size) return 1; let n = 0; for (const w of A) if (B.has(w)) n++; return n / A.size; };
const subjKey = (st) => [...new Set((st?.subjects || []).map(norm))].sort().join(" + ");

function tally(hist, get) { const c = {}; for (const h of hist) for (const k of [].concat(get(h) || [])) if (k) c[k] = (c[k] || 0) + 1; return c; }
const fmtTally = (all, c) => all.map((k) => `${k} ${c[k] || 0}×`).sort((a, b) => parseInt(a.split(" ").pop()) - parseInt(b.split(" ").pop())).join(" · ");
const fmtCount = (c) => Object.entries(c).sort((a, b) => b[1] - a[1]).map(([k, n]) => `${k} ${n}×`).join(" · ") || "—";

export function check(tap, hist) {
  const bad = [], warn = [];
  const st = tap.story;
  if (!st) { bad.push("thiếu khối story (format, logline, subjects, works, authors, facts, sources)"); return { bad, warn }; }
  for (const k of ["format", "logline"]) if (!st[k]) bad.push(`story.${k} trống`);
  if (!st.subjects?.length) bad.push("story.subjects trống (nhân vật / võ công / tác giả / tác phẩm mà tập bàn tới)");
  if (st.format && !FORMATS.includes(st.format)) bad.push(`story.format "${st.format}" không thuộc: ${FORMATS.join(", ")}`);
  if (["doi-dau", "so-vo", "mon-phai", "binh-khi", "an-so"].includes(st.format) && (st.subjects?.length || 0) < 2) bad.push(`format ${st.format} cần ≥2 subjects (hai bên đối đầu; an-so: ngôi sao + cái bóng)`);
  if (!st.authors?.length) warn.push("story.authors trống");
  if (!st.works?.length) warn.push("story.works trống");

  // dữ kiện: mỗi claim ≥2 nguồn
  const facts = st.facts || [];
  if (!facts.length) bad.push("story.facts trống: liệt kê dữ kiện dùng trong tập, mỗi dữ kiện ≥2 nguồn");
  facts.forEach((f, i) => { if (!f.claim) bad.push(`facts[${i}] thiếu claim`); else if ((f.src || []).length < 2) bad.push(`dữ kiện "${f.claim}" mới có ${(f.src || []).length} nguồn (cần ≥2)`); });
  if (["doi-dau", "so-vo", "neu-nhu", "an-so"].includes(st.format)) if (!st.verdict) warn.push("chưa có story.verdict (nhận định cuối, nói rõ là ý kiến)");

  // format: cấm 3 tập liền cùng format, nhắc nếu trùng tập ngay trước
  const last2 = hist.slice(-2);
  if (st.format && last2.length === 2 && last2.every((h) => h.story?.format === st.format)) bad.push(`format "${st.format}" đã dùng ở 2 tập liền trước (${last2.map((h) => h.ep).join(", ")}) — đổi format`);
  else if (st.format && hist.at(-1)?.story?.format === st.format) warn.push(`format "${st.format}" trùng tập ngay trước (${hist.at(-1).ep})`);

  // chủ đề: cùng bộ subjects = trùng tập cũ; từng subject lặp trong 3 tập gần nhất thì nhắc
  const key = subjKey(st);
  const same = key && hist.find((h) => subjKey(h.story) === key);
  if (same) bad.push(`bộ chủ đề "${(st.subjects || []).join(" + ")}" đã làm ở tập ${same.ep}`);
  for (const s of st.subjects || []) {
    const hit = hist.slice(-3).find((h) => (h.story?.subjects || []).some((x) => norm(x) === norm(s)));
    if (hit && !same) warn.push(`"${s}" vừa xuất hiện ở tập ${hit.ep} (3 tập gần nhất) — cân nhắc chủ đề khác`);
  }
  // tác giả: 3 tập gần nhất cùng một tác giả với tập này
  for (const a of st.authors || []) {
    const last3 = hist.slice(-3);
    if (last3.length === 3 && last3.every((h) => (h.story?.authors || []).some((x) => norm(x) === norm(a)))) warn.push(`3 tập gần nhất đều về ${a} — nên đổi tác giả`);
  }

  for (const h of hist) {
    const j = jaccard(tap.title, h.title || "");
    if (j >= 0.6) bad.push(`tiêu đề giống tập ${h.ep} "${h.title}" (${j.toFixed(2)})`);
    if (h.story?.logline && st.logline && jaccard(st.logline, h.story.logline) >= 0.5) bad.push(`logline gần giống tập ${h.ep}: "${h.story.logline}"`);
  }
  const prev = hist.at(-1);
  if (prev?.next) {
    const o = overlap(prev.next, `${tap.title} ${st.logline || ""} ${(st.subjects || []).join(" ")} ${tap.opener?.sub || ""}`);
    if (o < 0.3) warn.push(`tập trước hẹn "${prev.next}". Tập này có vẻ không giữ lời hẹn (khớp ${o.toFixed(2)})`);
  }
  if (prev && tap.ep && prev.ep && tap.ep !== prev.ep + 1) warn.push(`ep ${tap.ep} không liền sau tập trước (${prev.ep})`);
  return { bad, warn };
}

if (import.meta.url === pathToFileURL(process.argv[1]).href) {
  const args = process.argv.slice(2);
  const hi = args.indexOf("--history");
  const histFile = hi >= 0 ? resolve(args[hi + 1]) : null;
  const dirArg = args.find((a, i) => !a.startsWith("--") && !(hi >= 0 && i === hi + 1));
  const hist = histFile ? JSON.parse(readFileSync(histFile, "utf8")) : readHistory();

  if (!hist.length) console.log("Lịch sử chủ đề: chưa có tập nào. Tự do chọn chủ đề, nhớ ghi khối story có facts + nguồn.");
  else {
    console.log(`Lịch sử chủ đề: ${hist.length} tập · 5 tập gần nhất:`);
    for (const h of hist.slice(-5)) {
      console.log(`  ${String(h.ep).padStart(2)}. ${h.title || h.slug}  [${h.story?.format || "?"}]  ${(h.story?.subjects || []).join(" vs ") || "—"}  · ${(h.story?.authors || []).join(", ") || "?"}`);
      if (h.story?.logline) console.log(`      ${h.story.logline}`);
    }
    const prev = hist.at(-1);
    console.log(`\n→ Tập trước hẹn: "${prev.next || "(không có)"}". Tập mới nên giữ lời hẹn này.`);
    console.log(`\nformat:   ${fmtTally(FORMATS, tally(hist, (h) => h.story?.format))}`);
    console.log(`tác giả:  ${fmtCount(tally(hist, (h) => h.story?.authors))}`);
    console.log(`tác phẩm: ${fmtCount(tally(hist, (h) => h.story?.works))}`);
    console.log(`set:      ${fmtTally(Object.keys(SETS), tally(hist, (h) => h.sets))}`);
    console.log(`chủ đề đã làm: ${hist.map((h) => (h.story?.subjects || []).join(" vs ")).filter(Boolean).join(" · ") || "—"}`);
  }

  if (dirArg) {
    const f = join(resolve(dirArg), "tap.json");
    if (!existsSync(f)) { console.log(`\n(chưa có ${f})`); process.exit(0); }
    const { bad, warn } = check(JSON.parse(readFileSync(f, "utf8")), hist);
    const tf = join(resolve(dirArg), "work/timeline.json");
    if (existsSync(tf)) {
      const total = JSON.parse(readFileSync(tf, "utf8")).total || 0;
      if (total < MIN_TOTAL) bad.push(`bản build hiện dài ${(total / 60).toFixed(1)} phút, cần ≥${MIN_TOTAL / 60} phút: thêm đoạn/hiệp/stat/chi tiết theo chu-de.md mục 4`);
    } else warn.push(`chưa build nên chưa kiểm được thời lượng (cần ≥${MIN_TOTAL / 60} phút)`);
    console.log(`\nSoi ${f}:`);
    for (const x of bad) console.log(`  ✗ ${x}`);
    for (const x of warn) console.log(`  ! ${x}`);
    if (!bad.length && !warn.length) console.log("  ok: không trùng chủ đề cũ, đủ nguồn");
    process.exit(bad.length ? 1 : 0);
  }
}
