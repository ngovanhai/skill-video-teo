// Chống trùng CHỦ ĐỀ: tóm tắt các tập trước (đề bài nối mạch) + soi tap.json nháp có lặp chủ đề cũ / thiếu nguồn không.
//   node <SKILL>/scripts/story-check.mjs [<dir tập>] [--history <file>]
// Không có dir: chỉ in tóm tắt + thống kê. Có dir/tap.json: in thêm ✗ (phải sửa) và ! (nên xem).
// Thoát mã 1 khi còn ✗. Chỉ đọc, không ghi gì. pack.mjs dùng storyOf() để ghi trường chủ đề vào history.
import { readFileSync, existsSync } from "fs";
import { join, resolve, basename } from "path";
import { pathToFileURL } from "url";
import { readHistory } from "./plan.mjs";
import { voOf } from "../engine/voice.mjs";
import { SETS } from "../engine/sets.mjs";

// doi-dau: nhân vật vs nhân vật · so-vo: võ công vs võ công · tac-gia · tac-pham · top: xếp hạng
// mon-phai: môn phái vs môn phái · binh-khi: thần binh · giai-ma: bí ẩn / vì sao
// cuoc-doi · su-that · neu-nhu (what-if) · cap-doi · su-do (thầy trò) · phan-dien · phim-vs-truyen · dong-thoi-gian · chieu-thuc
// an-so: "cái bóng" ít ai để ý cạnh ngôi sao (Đả Cẩu Bổng cạnh Hàng Long, Hư Trúc cạnh Tiêu Phong…)
export const FORMATS = ["doi-dau", "so-vo", "tac-gia", "tac-pham", "top", "mon-phai", "binh-khi", "giai-ma",
  "cuoc-doi", "su-that", "neu-nhu", "cap-doi", "su-do", "phan-dien", "phim-vs-truyen", "dong-thoi-gian", "chieu-thuc", "an-so"];
// Khung dựng (story.frame) KHÔNG chọn từ danh sách: mỗi tập phân tích kịch bản / chất liệu rồi tự thiết kế khung (SKILL.md "Khung dựng").
// story.frame = { name, analysis, axis, open, close, segments[] }; story.teo_role = vai Tèo tự đặt (chữ tự do).
// Tập cũ không ghi frame: coi như khuôn võ đài cũ.
const OLD_FRAME = { name: "võ đài (khuôn cũ)", axis: "giới thiệu từng bên rồi so sánh và chấm điểm", open: "hook rồi Tèo chào và giới thiệu hai bên", close: "Tèo chấm điểm, mời đăng ký, hẹn tập sau", segments: [] };
export const frameOf = (st) => (st?.frame && typeof st.frame === "object" ? st.frame : st?.frame ? { ...OLD_FRAME, name: String(st.frame) } : OLD_FRAME);
const frameSig = (fr) => [fr.axis, fr.open, fr.close, ...(fr.segments || [])].filter(Boolean).join(" | ");
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
    look: lookOf(tap),
  };
}

// "Dấu vân tay hình thức" của một tập: mở/kết, nhịp beat, bối cảnh, âm thanh, stage, vị trí Tèo, thumbnail.
const KEY = new Set(["card", "attack", "stat", "caption", "enter", "intro", "power"]);
export function lookOf(tap) {
  const sc = tap.scenes || [], beats = sc.flatMap((s) => s.beats || []);
  const spoken = beats.map((b) => voOf(b) || (b.do === "say" ? b.text : "")).filter(Boolean);
  const teoX = sc.map((s) => (s.actors || []).find((a) => a.id === "teo" || tap.cast?.[a.id]?.kind === "teo")).map((a) => (a ? (a.hidden ? -1 : a.x) : null));
  return {
    frame: frameOf(tap.story).name,
    frameSig: frameSig(frameOf(tap.story)),
    frameAxis: frameOf(tap.story).axis || "",
    teo_role: tap.story?.teo_role || "trọng tài",
    open: spoken.slice(0, 3),
    close: spoken.slice(-3),
    openBeats: beats.slice(0, 8).map((b) => b.do).join(">"),
    keySeq: beats.filter((b) => KEY.has(b.do) || String(b.do).startsWith("local:")).map((b) => (String(b.do).startsWith("local:") ? "local" : b.do)),
    sets: sc.map((s) => `${s.set}/${s.time || "-"}`),
    bgm: tap.bgm || "playful-pizzicato.mp3",
    music: sc.map((s) => s.music || "on"),
    stages: sc.map((s) => s.stage || ""),
    weathers: sc.map((s) => s.weather || ""),
    bubble: tap.bubble || "",
    teoX,
    thumb: { layout: tap.thumb?.layout || "vs", text: tap.thumb?.text || tap.hook || "" },
  };
}
const KH_DIR = "E:/tool/MuseStudio/kiem-hiep";
// look của tập cũ: history mới có sẵn; tập ghi trước khi có trường này thì đọc lại tap.json của nó
export function lookOfHist(h) {
  if (h.look) return h.look;
  const f = join(KH_DIR, h.slug || "", "tap.json");
  return existsSync(f) ? lookOf(JSON.parse(readFileSync(f, "utf8"))) : null;
}
const tri = (s) => { const w = norm(s).split(" ").filter(Boolean), out = new Set(); for (let i = 0; i + 2 < w.length; i++) out.add(w.slice(i, i + 3).join(" ")); return out; };
const simTri = (a, b) => { const A = tri(a), B = tri(b); if (!A.size || !B.size) return 0; let n = 0; for (const x of A) if (B.has(x)) n++; return n / Math.min(A.size, B.size); };
const lcs = (a, b) => { const d = Array(b.length + 1).fill(0); for (const x of a) { let p = 0; for (let j = 1; j <= b.length; j++) { const t = d[j]; d[j] = x === b[j - 1] ? p + 1 : Math.max(d[j], d[j - 1]); p = t; } } return d[b.length] / Math.max(1, Math.min(a.length, b.length)); };
const setJ = (a, b) => { const A = new Set(a), B = new Set(b); let n = 0; for (const x of A) if (B.has(x)) n++; return n / (A.size + B.size - n || 1); };
const audioSig = (L) => `${L.bgm}|${L.music.filter((m) => m !== "on").length >= 2 ? L.music.join(",") : "flat"}`;
const FORMULA = ["chao cac ban lai la teo day", "dang ky kenh hen tap sau nha", "hom nay teo khong so ai manh hon ai"];

// Luật chống lặp HÌNH THỨC (cấu trúc, dựng cảnh, âm thanh, bố cục) so với các tập trước.
export function lookCheck(tap, hist) {
  const bad = [], warn = [], L = lookOf(tap);
  const H = hist.map((h) => ({ ep: h.ep, L: lookOfHist(h) })).filter((x) => x.L);
  const last = (n) => H.slice(-n);
  const st = tap.story || {};
  // khung tự thiết kế: phải có đủ phần phân tích và dàn khung, và khác 3 tập gần nhất
  const fr = st.frame;
  if (!fr || typeof fr !== "object") bad.push(`thiếu story.frame: { name, analysis, axis, open, close, segments[] } — phân tích kịch bản rồi tự thiết kế khung, không chọn từ danh sách`);
  else {
    for (const k of ["name", "axis", "open", "close"]) if (!String(fr[k] || "").trim()) bad.push(`story.frame.${k} trống`);
    const aw = norm(fr.analysis || "").split(" ").filter(Boolean).length;
    if (aw < 25) bad.push(`story.frame.analysis mới ${aw} chữ — phân tích chất liệu (lõi câu chuyện, cảm xúc, khoảnh khắc mạnh nhất, người xem cần gì) rồi giải thích vì sao khung này hợp (≥25 chữ)`);
    const n = (fr.segments || []).length;
    if (n < 5 || n > 10) bad.push(`story.frame.segments có ${n} đoạn — dàn khung 6–8 đoạn, mỗi đoạn một câu`);
    for (const x of last(3)) {
      const nm = jaccard(L.frame, x.L.frame), sg = x.L.frameSig ? simTri(L.frameSig, x.L.frameSig) : 0, ax = x.L.frameAxis ? jaccard(L.frameAxis, x.L.frameAxis) : 0;
      if (nm >= 0.6) bad.push(`tên khung "${L.frame}" gần giống tập ${x.ep} ("${x.L.frame}")`);
      if (sg >= 0.45) bad.push(`dàn khung (axis/open/close/segments) giống tập ${x.ep} ${(sg * 100).toFixed(0)}% — thiết kế lại từ chất liệu tập này`);
      if (ax >= 0.6) bad.push(`trục sắp xếp đoạn giống tập ${x.ep}: "${x.L.frameAxis}"`);
    }
  }
  if (!String(st.teo_role || "").trim()) bad.push("thiếu story.teo_role — vai của Tèo trong tập, tự đặt cho hợp khung");
  else { const ro = last(2).find((x) => jaccard(st.teo_role, x.L.teo_role) >= 0.6); if (ro) bad.push(`vai Tèo "${st.teo_role}" gần giống tập ${ro.ep} ("${ro.L.teo_role}")`); }
  // câu chữ mở / kết
  const all = norm([...L.open, ...L.close, ...(tap.scenes || []).flatMap((s) => s.beats || []).filter((b) => b.do === "caption").map((b) => b.text)].join(" | "));
  for (const p of FORMULA) if (all.includes(p)) bad.push(`câu công thức cũ "${p}" — viết lời chào / kết theo giọng của khung`);
  for (const x of last(5)) {
    const o = simTri(L.open.join(" "), x.L.open.join(" ")), c = simTri(L.close.join(" "), x.L.close.join(" "));
    if (o >= 0.5) bad.push(`3 câu mở giống tập ${x.ep} (${o.toFixed(2)})`);
    if (c >= 0.5) bad.push(`3 câu kết giống tập ${x.ep} (${c.toFixed(2)})`);
  }
  // nhịp
  const ob = last(3).find((x) => x.L.openBeats === L.openBeats); if (ob) bad.push(`8 beat mở đầu y hệt tập ${ob.ep}: ${L.openBeats}`);
  for (const x of last(3)) { const v = lcs(L.keySeq, x.L.keySeq); if (v > 0.8) warn.push(`dãy beat chính (card/attack/stat/intro…) giống tập ${x.ep} ${(v * 100).toFixed(0)}% — đảo thứ tự / đổi loại beat`); }
  // âm thanh
  const prev = H.at(-1);
  if (prev && audioSig(L) === audioSig(prev.L)) bad.push(`âm thanh y hệt tập ${prev.ep} (bgm ${L.bgm}, nhạc phẳng) — đổi tap.bgm hoặc cho ≥2 cảnh music low/off/up`);
  // dựng cảnh
  const stg = new Set(L.stages.filter(Boolean));
  if (stg.size < 2) bad.push(`mới có ${stg.size} kiểu stage — dùng ≥2 kiểu (letterbox, panel, scroll, silhouette, thuy-mac, spotlight, hoi-uc)`);
  if (prev && stg.size && setJ([...stg], prev.L.stages.filter(Boolean)) >= 0.99) warn.push(`bộ stage trùng hệt tập ${prev.ep}`);
  if (!L.weathers.some(Boolean)) warn.push("chưa cảnh nào có weather (mua, tuyet, suong, la-phong, hoa-dao, dom-dom)");
  const first = L.sets[0], f3 = last(3).find((x) => x.L.sets[0] === first); if (f3) warn.push(`cảnh mở cùng bối cảnh ${first} với tập ${f3.ep}`);
  if (prev) { const j = setJ(L.sets.map((x) => x.split("/")[0]), prev.L.sets.map((x) => x.split("/")[0])); if (j > 0.6) warn.push(`bộ bối cảnh giống tập ${prev.ep} ${(j * 100).toFixed(0)}%`); }
  const xs = L.teoX.filter((x) => x != null && x >= 0), corner = xs.filter((x) => x >= 150 && x <= 350).length;
  if (xs.length >= 3 && corner / xs.length >= 0.7) warn.push(`Tèo đứng góc trái (x 150–350) ở ${corner}/${xs.length} cảnh — đổi chỗ: giữa, phải, nhỏ trên cao, ẩn (chỉ lồng tiếng)`);
  // thumbnail
  const tt = H.find((x) => norm(x.L.thumb.text) === norm(L.thumb.text)); if (tt) bad.push(`chữ thumbnail trùng tập ${tt.ep}`);
  if (last(2).length === 2 && last(2).every((x) => x.L.thumb.layout === L.thumb.layout)) warn.push(`thumb.layout "${L.thumb.layout}" đã dùng 2 tập liền trước`);
  return { bad, warn };
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
  const lk = lookCheck(tap, hist);
  return { bad: [...bad, ...lk.bad], warn: [...warn, ...lk.warn] };
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
    console.log("\nCHỐNG LẶP HÌNH THỨC (5 tập gần nhất) — tập mới phải khác:");
    for (const h of hist.slice(-5)) {
      const L = lookOfHist(h); if (!L) continue;
      const xs = L.teoX.filter((x) => x != null && x >= 0);
      console.log(`  ${String(h.ep).padStart(2)}. khung "${L.frame}" · Tèo ${L.teo_role} · thumb ${L.thumb.layout} "${L.thumb.text}" · bgm ${L.bgm}${L.music.some((m) => m !== "on") ? " (" + L.music.join(",") + ")" : " (phẳng)"}`);
      if (L.frameAxis) console.log(`      trục: ${L.frameAxis}`);
      console.log(`      mở: ${L.openBeats} · stage: ${[...new Set(L.stages.filter(Boolean))].join(",") || "—"} · weather: ${[...new Set(L.weathers.filter(Boolean))].join(",") || "—"} · Tèo x: ${xs.join(",")}`);
      console.log(`      câu đầu: "${(L.open[0] || "").slice(0, 90)}" · câu cuối: "${(L.close.at(-1) || "").slice(0, 60)}"`);
    }
    console.log(`\nchủ đề đã làm: ${hist.map((h) => (h.story?.subjects || []).join(" vs ")).filter(Boolean).join(" · ") || "—"}`);
  }

  if (dirArg) {
    const f = join(resolve(dirArg), "tap.json");
    if (!existsSync(f)) { console.log(`\n(chưa có ${f})`); process.exit(0); }
    const { bad, warn } = check(JSON.parse(readFileSync(f, "utf8")), hist.filter((h) => h.slug !== basename(resolve(dirArg))));
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
