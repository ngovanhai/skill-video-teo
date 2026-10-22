// Soát một tập Godot trước khi render (và ghi sổ sau khi render xong).
//   node <SKILL>/scripts/gd-check.mjs <thư mục tập> [--no-godot] [--log]
// Kiểm: loi.txt (id, không "Chương", hook → chào → CTA đúng chỗ), giọng đủ và khớp chữ, Godot parse + DUR ≥ 20 phút,
// phim.gd đã thay chỗ giữ, story.json điền đủ và KHÁC 5 tập gần nhất trong data/history.json (độ giống ≥60% là lỗi),
// chân mô tả seo.chan không lặp tập trước, cast.json có trong sổ nhân vật.
// Short dọc (project 1080×1920, tạo bởi new-short.mjs) tự đổi luật: ≤ 60 s, hook ≤ 12 s, kết có "đăng ký", story.kieu khác
// các short anh em, không so history và không --log.
// --log: khi không còn lỗi và đã có renders/final.mp4 → ghi story.json vào data/history.json.
import { existsSync, readFileSync, writeFileSync, readdirSync } from "node:fs";
import { join, resolve, basename, dirname } from "node:path";
import { spawnSync } from "node:child_process";
import { homedir } from "node:os";
import { fileURLToPath } from "node:url";

const SKILL = dirname(dirname(fileURLToPath(import.meta.url)));
const GODOT = "__GODOT__";
const HIST = join(SKILL, "data/history.json");
const CHARS = join(homedir(), ".claude/skills/nhan-vat-chibi/data/chars.json");
const args = process.argv.slice(2);
const has = (k) => { const i = args.indexOf(k); if (i < 0) return false; args.splice(i, 1); return true; };
const noGodot = has("--no-godot"), doLog = has("--log");
if (!args[0]) { console.log("dùng: node gd-check.mjs <thư mục tập> [--no-godot] [--log]"); process.exit(1); }
const TAP = resolve(args[0]), G = join(TAP, "godot"), slug = basename(TAP);
const err = [], warn = [];
const read = (f) => readFileSync(join(G, f), "utf8");
const SHORT = (() => { const p = existsSync(join(G, "project.godot")) ? readFileSync(join(G, "project.godot"), "utf8") : ""; return +(p.match(/viewport_height=(\d+)/)?.[1] || 0) > +(p.match(/viewport_width=(\d+)/)?.[1] || 0); })();
const mmss = (s) => `${Math.floor(s / 60)}:${String(Math.floor(s % 60)).padStart(2, "0")}`;

// ---- loi.txt → đoạn + câu, xếp giờ giống main.gd (GAP 0.7, pre 0.6, post 1.0)
if (!existsSync(join(G, "loi.txt"))) { console.error("không có godot/loi.txt — chạy new-tap.mjs trước"); process.exit(1); }
const man = existsSync(join(G, "voice/voice.json")) ? JSON.parse(read("voice/voice.json")).lines : {};
const segs = [], lines = [], seen = new Set();
for (const raw of read("loi.txt").split("\n")) {
  const ln = raw.trim();
  if (ln.startsWith("## ")) {
    const [name, note = ""] = ln.slice(3).split("|");
    const kid = name.trim().split(/\s+/)[0];
    const opt = (k, d) => { const m = note.match(new RegExp(k + "=([\\d.]+)")); return m ? +m[1] : d; };
    segs.push({ kid, pre: opt("pre", 0.6), post: opt("post", 1.0), lines: [] });
  } else if (ln.startsWith("[") && segs.length) {
    const id = ln.slice(1, ln.indexOf("]")), text = ln.slice(ln.indexOf("]") + 1).trim();
    if (!/^[a-z0-9-]+$/.test(id)) err.push(`id "${id}" chỉ được chữ thường/số/gạch`);
    if (seen.has(id)) err.push(`id "${id}" trùng`);
    seen.add(id);
    const v = man[id];
    if (!v) err.push(`[${id}] chưa có giọng (chạy gd-voice)`);
    else if (v.text !== text) err.push(`[${id}] chữ đã sửa sau khi đọc giọng (chạy lại gd-voice)`);
    else if (!existsSync(join(G, "voice", id + ".wav"))) err.push(`[${id}] thiếu voice/${id}.wav`);
    const l = { id, text, dur: v?.dur ?? text.split(" ").length / 4.1 };
    segs.at(-1).lines.push(l); lines.push(l);
  }
}
if (!segs.length) err.push("loi.txt không có đoạn nào (## kNN …)");
let tc = 0;
for (const s of segs) {
  s.t0 = tc; tc += s.pre;
  for (const l of s.lines) { l.t0 = tc; tc += l.dur + 0.7; }
  if (s.lines.length) tc -= 0.7;
  tc += s.post; s.t1 = tc;
}
const DURjs = tc + 0.5;

// ---- Godot: parse + DUR
let DUR = DURjs, fresh = false;
if (!noGodot) {
  spawnSync(GODOT, ["--headless", "--path", G, "--import"], { stdio: "ignore", timeout: 180000 });
  const r = spawnSync(GODOT, ["--headless", "--path", G, "--", "--dur"], { encoding: "utf8", timeout: 90000 }); // script lỗi thì Godot không tự quit
  const out = (r.stdout || "") + (r.stderr || "");
  for (const m of out.matchAll(/(SCRIPT ERROR|Parse Error|ERROR):[^\n]*(\n\s+at:[^\n]*)?/g)) err.push("godot: " + m[0].replace(/\s+/g, " ").trim());
  const m = out.match(/DUR=([\d.]+)/);
  if (!m) err.push("main không in DUR= khi chạy --dur");
  else { DUR = +m[1]; fresh = true; if (Math.abs(DUR - DURjs) > 1) warn.push(`DUR Godot ${DUR.toFixed(1)} ≠ tính từ loi.txt ${DURjs.toFixed(1)} — main.gd đã đổi cách xếp giờ; luật CTA/chào dùng giờ của Godot`); }
}
if (SHORT) {
  if (DUR > 60) err.push(`short dài ${DUR.toFixed(1)} s > 60 s — cắt bớt lời`);
  else if (DUR < 20) warn.push(`short chỉ ${DUR.toFixed(1)} s — quá ngắn để kể trọn một ý`);
} else if (DUR < 1200) (Object.keys(man).length ? err : warn).push(`thời lượng ${mmss(DUR)} < 20:00`);

// giờ thật lấy từ timeline.json mà main.gd ghi khi --dur (tập có thể đổi cách xếp giờ trong main.gd); không có thì giữ giờ tính bằng JS
const TL = join(G, "timeline.json");
if (fresh && existsSync(TL)) {
  const tl = JSON.parse(readFileSync(TL, "utf8"));
  const at = Object.fromEntries((tl.cau || []).map((c) => [c.id, c.t0]));
  for (const l of lines) if (at[l.id] !== undefined) l.t0 = at[l.id];
  for (const k of tl.khung || []) { const sg = segs.find((x) => x.kid === k.id); if (sg) { sg.t0 = k.t0; sg.t1 = k.t1; } }
  if (!tl.cau) warn.push("timeline.json không có 'cau' — vị trí CTA tính theo cách xếp giờ mặc định");
}

// ---- luật lời: không "Chương", hook trước chào, chào sớm, CTA giữa + cuối
const word = (w) => new RegExp(`(^|[^\\p{L}])${w}(?=$|[^\\p{L}])`, "iu");
for (const l of lines) if (word("chương").test(l.text)) err.push(`[${l.id}] có chữ "Chương" — video liền mạch, không chia chương`);
for (const l of lines) if (/lại là tèo đây/i.test(l.text)) err.push(`[${l.id}] câu chào công thức "lại là Tèo đây" bị cấm — chào theo vai`);
if (lines[0] && /chào/i.test(lines[0].text)) err.push("câu đầu phải là hook, không phải lời chào");
if (SHORT) {
  const hw = lines[0] ? lines[0].text.split(/\s+/).length : 0;
  if (hw > 12) warn.push(`câu hook [${lines[0].id}] ${hw} chữ — nên ≤ 12`);
  if (segs[0] && segs[0].t1 > 12.5) warn.push(`đoạn hook ${segs[0].kid} dài ${segs[0].t1.toFixed(1)} s — nên ≤ 12 s`);
  if (!lines.some((l) => /đăng ký/i.test(l.text) && l.t0 >= DUR * 0.7)) err.push("short phải kết bằng câu mời đăng ký (trong 30% cuối)");
  if (!lines.some((l) => /tèo kể/i.test(l.text))) warn.push('không câu nào nhắc tên kênh "Tèo Kể"');
}
const greet = SHORT || lines.find((l) => /tèo/i.test(l.text));
if (!greet) warn.push("không câu nào nhắc tên Tèo — Tèo phải tự giới thiệu theo vai");
else if (!SHORT && greet.t0 > 90) warn.push(`Tèo xuất hiện lần đầu ở ${mmss(greet.t0)} (nên ≤ 1:00, trừ khung kể bằng nhân vật khác)`);
const CTA = /(đăng ký|bật chuông|bấm like|nhấn like|thả like|bình luận)/i;
const ctas = lines.filter((l) => CTA.test(l.text));
if (!SHORT && !ctas.some((l) => l.t0 >= DUR * 0.25 && l.t0 <= DUR * 0.75)) err.push("thiếu CTA ở khoảng 25–75% thời lượng");
if (!SHORT && !ctas.some((l) => l.t0 >= DUR * 0.9)) err.push("thiếu CTA ở 10% cuối");

// ---- phần hình
if (!existsSync(join(G, "phim.gd")) && !existsSync(join(G, "main.gd"))) err.push("không có phim.gd");
else if (existsSync(join(G, "phim.gd")) && read("phim.gd").includes("CHUA_DUNG")) err.push("phim.gd còn là chỗ giữ (CHUA_DUNG) — chưa dựng hình");

// ---- story.json: điền đủ, khác các tập gần (so theo độ giống: tỉ lệ từ chung, không chỉ chữ y hệt)
const FIELDS = ["khung", "teo_role", "but", "may_quay", "palette", "nhac", "thumb", "mat", "font"];
const STOP = new Set(["của", "và", "trên", "một", "các", "những", "theo", "kiểu", "với", "cho", "là", "có", "trong", "chữ"]);
const norm = (s) => String(s || "").toLowerCase().normalize("NFC").replace(/\s+/g, " ").trim();
const words = (s) => new Set(norm(s).split(/[^\p{L}\p{N}]+/u).filter((w) => w && !STOP.has(w)));
// Jaccard trên tập từ: "cuộn tranh mực" ~ "tranh cuộn mực" = 1. contain=true (chân mô tả) hoặc một bên ≤ 2 từ (font, tên)
// thì tính theo bên ngắn hơn: "Palatino" ~ "Palatino (pala/palab)" = 1, chép 2/3 dòng chân cũ cũng bị bắt.
const sim = (a, b, contain = false) => {
  const A = words(a), B = words(b); if (!A.size || !B.size) return 0;
  let n = 0; for (const w of A) if (B.has(w)) n++;
  const lo = Math.min(A.size, B.size);
  return contain || lo <= 2 ? Math.max(n / lo, n / (A.size + B.size - n)) : n / (A.size + B.size - n);
};
const SIM_ERR = 0.6, SIM_WARN = 0.4;
let story = null;
if (!existsSync(join(G, "story.json"))) err.push("thiếu godot/story.json");
else if (SHORT) {
  story = JSON.parse(read("story.json"));
  if (!norm(story.kieu) || story.kieu.startsWith("<")) err.push("story.kieu (kiểu short) chưa viết");
  const sdir = dirname(TAP);
  for (const o of readdirSync(sdir)) {
    const f = join(sdir, o, "godot/story.json");
    if (o === slug || !existsSync(f)) continue;
    const x = sim(story.kieu, JSON.parse(readFileSync(f, "utf8")).kieu);
    if (x >= SIM_ERR) err.push(`story.kieu giống short ${o} ${Math.round(x * 100)}% — 3 short của tập phải khác kiểu`);
  }
  if (!norm(story.seo?.mo_ta)) err.push("story.seo.mo_ta chưa viết");
  const t = story.seo?.title || "";
  if (!t || t.includes("…")) err.push("story.seo.title chưa viết");
  else if (t.length > 60 || !t.endsWith("| Tèo Kể")) err.push(`seo.title phải ≤ 60 ký tự và kết thúc "| Tèo Kể" (đang ${t.length})`);
} else {
  story = JSON.parse(read("story.json"));
  const hist = JSON.parse(readFileSync(HIST, "utf8")).filter((h) => h.tap !== slug).slice(-5);
  const near = (f, v) => hist.map((h) => [h, sim(v, h[f], f === "chan")]).sort((a, b) => b[1] - a[1])[0] || [null, 0];
  for (const f of [...FIELDS, "chan"]) {
    const v = f === "chan" ? story.seo?.chan : story[f];
    if (!norm(v)) { err.push(`story.json: "${f === "chan" ? "seo.chan" : f}" trống`); continue; }
    const [h, x] = near(f, v);
    if (x >= SIM_ERR) err.push(`story.json: ${f} giống ${h.tap} ${Math.round(x * 100)}% ("${String(h[f]).split("\n")[0].slice(0, 50)}")`);
    else if (x >= SIM_WARN) warn.push(`story.json: ${f} hơi giống ${h.tap} (${Math.round(x * 100)}%)`);
  }
  const fdir = join(G, "font");
  if (norm(story.font) && !(existsSync(fdir) && readdirSync(fdir).some((f) => /\.(ttf|otf)$/i.test(f))))
    warn.push(`story.font "${story.font}" nhưng godot/font/ chưa có file .ttf/.otf nào`);
  const doan = Object.entries(story.doan || {});
  if (doan.length < 3) warn.push("story.doan nên ghi kiểu dựng của từng đoạn (mỗi đoạn một kiểu)");
  for (let i = 0; i < doan.length; i++) for (let j = i + 1; j < doan.length; j++)
    if (sim(doan[i][1], doan[j][1]) >= SIM_ERR) err.push(`story.doan: ${doan[i][0]} và ${doan[j][0]} cùng kiểu dựng ("${doan[i][1]}" ~ "${doan[j][1]}")`);
  const t = story.seo?.title || "";
  if (!t || t.includes("…")) err.push("story.seo.title chưa viết");
  else if (t.length > 60 || !t.endsWith("| Tèo Kể")) err.push(`seo.title phải ≤ 60 ký tự và kết thúc "| Tèo Kể" (đang ${t.length})`);
}

// ---- cast.json: char phải có trong sổ nhân vật
if (existsSync(join(G, "cast.json")) && existsSync(CHARS)) {
  const cast = JSON.parse(read("cast.json")), book = JSON.parse(readFileSync(CHARS, "utf8"));
  for (const [k, c] of Object.entries(cast)) if (c.char && !book[c.char]) err.push(`cast.json ${k}: char "${c.char}" không có trong nhan-vat-chibi`);
}

// ---- chiêu: làm bằng chuong-2d (có trong sổ) và đã gd-chieu vào tập
if (existsSync(join(G, "story.json"))) {
  const MV = join(homedir(), ".claude/skills/chuong-2d/data/moves.json");
  const mbook = existsSync(MV) ? JSON.parse(readFileSync(MV, "utf8")) : [];
  const ok = new Set((Array.isArray(mbook) ? mbook : Object.values(mbook)).map((m) => m.id));
  const ch = JSON.parse(read("story.json")).chieu || [];
  if (ch.length && /"gl_compatibility"/.test(read("project.godot"))) err.push(`project.godot còn gl_compatibility: chiêu phải chạy forward_plus (chạy lại gd-chieu.mjs)`);
  for (const id of ch) {
    if (!ok.has(id)) err.push(`story.chieu "${id}" không có trong chuong-2d/data/moves.json (làm chiêu bằng skill chuong-2d)`);
    else if (!existsSync(join(G, "chuong/moves", id + ".gd"))) err.push(`chiêu "${id}" chưa chép vào tập: chạy gd-chieu.mjs ${slug} ${id}`);
  }
}

// ---- báo
console.log(`${SHORT ? "short " : ""}${slug}: ${segs.length} đoạn, ${lines.length} câu, ${mmss(DUR)}`);
for (const s of segs) console.log(`  ${s.kid.padEnd(5)} ${mmss(s.t0)}–${mmss(s.t1)}  ${s.lines.length} câu`);
for (const w of warn) console.log("CẢNH BÁO " + w);
for (const e of err) console.log("LỖI " + e);
if (!err.length) console.log("OK");
if (doLog) {
  if (SHORT) { console.log("short không ghi sổ history.json"); process.exit(1); }
  if (err.length) { console.log("không ghi sổ: còn lỗi"); process.exit(1); }
  if (!existsSync(join(TAP, "renders/final.mp4"))) { console.log("không ghi sổ: chưa có renders/final.mp4"); process.exit(1); }
  const hist = JSON.parse(readFileSync(HIST, "utf8")).filter((h) => h.tap !== slug);
  const row = { tap: slug, ngay: new Date().toISOString().slice(0, 10) };
  for (const f of FIELDS) row[f] = story[f];
  row.chan = story.seo?.chan;
  hist.push(row);
  writeFileSync(HIST, JSON.stringify(hist, null, 1) + "\n");
  console.log("đã ghi " + HIST);
}
process.exit(err.length ? 1 : 0);
