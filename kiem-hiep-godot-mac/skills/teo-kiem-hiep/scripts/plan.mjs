// Chọn hiệu ứng cho từng slot của một tập sao cho KHÔNG lặp lại thứ tự của các tập trước.
//   node <SKILL>/scripts/plan.mjs <dir> [--replan] [--seed N]     → ghi <dir>/work/plan.json, in bảng chọn
// Luật cứng (nới dần nếu hết ứng viên): không lặp liền trong cùng nhóm · cặp liên tiếp (bigram) không có trong 5 tập gần nhất
//   · opener/ender/theme khác 3 tập gần nhất · chiêu kết liễu khác 5 tập gần nhất.
// Luật mềm: phạt hiệu ứng dùng nhiều gần đây + dùng nhiều trong chính tập này; thử nhiều seed, lấy seed có độ giống (LCS) thấp nhất ≤ 0.35.
// Lịch sử: <SKILL>/data/history.json — chỉ pack.mjs ghi vào (khi tập đã render xong).
import { readFileSync, writeFileSync, mkdirSync, existsSync } from "fs";
import { join, resolve, basename } from "path";
import { pathToFileURL } from "url";
import { loadLibrary, SKILL } from "../engine/library.mjs";
import { slots, slotSignature } from "../engine/slots.mjs";

export const HISTORY = join(SKILL, "data/history.json");
export const readHistory = () => (existsSync(HISTORY) ? JSON.parse(readFileSync(HISTORY, "utf8")) : []);
const MAX_SIM = 0.35, TRIES = 60;

const mulberry = (a) => () => { a |= 0; a = (a + 0x6d2b79f5) | 0; let t = Math.imul(a ^ (a >>> 15), 1 | a); t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t; return ((t ^ (t >>> 14)) >>> 0) / 4294967296; };
function lcs(a, b) {
  const m = a.length, n = b.length, d = Array.from({ length: m + 1 }, () => new Array(n + 1).fill(0));
  for (let i = 1; i <= m; i++) for (let j = 1; j <= n; j++) d[i][j] = a[i - 1] === b[j - 1] ? d[i - 1][j - 1] + 1 : Math.max(d[i - 1][j], d[i][j - 1]);
  return d[m][n];
}
// độ giống thứ tự: chỉ tính các hiệu ứng "nhìn thấy rõ" (bỏ camera), chuẩn hoá theo độ dài dài hơn
const visible = (seq) => seq.filter((id) => !id.startsWith("cam-"));
export const similarity = (a, b) => { const x = visible(a), y = visible(b); return x.length && y.length ? lcs(x, y) / Math.max(x.length, y.length) : 0; };

function tryPlan(tap, lib, hist, seed) {
  const rnd = mulberry(seed);
  const recent = hist.slice(-8);
  const bigrams = new Set();
  for (const h of hist.slice(-5)) for (let i = 1; i < (h.seq || []).length; i++) bigrams.add(h.seq[i - 1] + ">" + h.seq[i]);
  const ban = {
    opener: new Set(hist.slice(-3).map((h) => h.opener)),
    ender: new Set(hist.slice(-3).map((h) => h.ender)),
    finisher: new Set(hist.slice(-5).map((h) => h.finisher)),
  };
  const wear = {}; // dùng gần đây, tập càng mới càng nặng
  recent.forEach((h, k) => { const w = (k + 1) / recent.length; for (const id of h.seq || []) wear[id] = (wear[id] || 0) + w; });
  const used = {}, lastInCat = {};
  const pick = {}, seq = [];
  let prev = null, relaxed = 0, finisher = null;
  for (const s of slots(tap)) {
    let id = s.fixed;
    if (!id) {
      const pool = (lib.byCat[s.cat] || []).filter((e) => !(s.keep && e.removes) && !(s.soft && (e.down || e.removes))); // luật tuyệt đối, không nới
      if (!pool.length) throw new Error(`không có hiệu ứng nào trong nhóm "${s.cat}"`);
      const rules = [
        (e) => e.id !== lastInCat[s.cat],
        (e) => !(prev && bigrams.has(prev + ">" + e.id)),
        (e) => !(s.cat === "opener" && ban.opener.has(e.id)) && !(s.cat === "ender" && ban.ender.has(e.id)),
        (e) => !(s.finisher && ban.finisher.has(e.id)),
      ];
      let cand = [];
      for (let drop = 0; drop <= rules.length && !cand.length; drop++) {
        // nới luật từ cuối danh sách lên (giữ "không lặp liền" lâu nhất)
        const active = rules.slice(0, rules.length - drop);
        cand = pool.filter((e) => active.every((r) => r(e)));
        if (drop && cand.length) relaxed++;
      }
      const score = (e) => (wear[e.id] || 0) * 1.0 + (used[e.id] || 0) * 3 + rnd() * 1.2;
      id = cand.map((e) => [score(e), e.id]).sort((a, b) => a[0] - b[0])[0][1];
    }
    pick[s.key] = id;
    if (s.finisher) finisher = id;
    used[id] = (used[id] || 0) + 1;
    lastInCat[s.cat] = id;
    seq.push(id);
    prev = id;
  }
  const themes = Object.keys(lib.THEMES);
  let theme = tap.theme && tap.theme !== "auto" ? tap.theme : null;
  if (!theme) {
    const banT = new Set(hist.slice(-3).map((h) => h.theme));
    const ok = themes.filter((t) => !banT.has(t));
    const pool = ok.length ? ok : themes;
    theme = pool[Math.floor(rnd() * pool.length)];
  }
  const sims = hist.map((h) => ({ slug: h.slug, sim: similarity(seq, h.seq || []) }));
  const maxSim = sims.reduce((m, x) => Math.max(m, x.sim), 0);
  return { seed, theme, pick, seq, finisher, opener: pick.op, ender: pick.ed, relaxed, maxSim, sims };
}

export async function makePlan(dir, { replan = false, seed = null, quiet = false } = {}) {
  dir = resolve(dir);
  const tap = JSON.parse(readFileSync(join(dir, "tap.json"), "utf8"));
  const out = join(dir, "work/plan.json");
  const sig = slotSignature(tap);
  const hist = readHistory().filter((h) => h.slug !== basename(dir));
  const histKey = hist.map((h) => `${h.slug}:${h.seed}`).join(",");
  if (!replan && seed == null && existsSync(out)) {
    const prev = JSON.parse(readFileSync(out, "utf8"));
    // plan chỉ còn giá trị khi cả cấu trúc beat lẫn lịch sử (các tập khác) đều chưa đổi
    if (prev.sig === sig && prev.histKey === histKey) return prev;
    if (!quiet) console.log(prev.sig !== sig ? "plan: tap.json đổi cấu trúc beat → lập lại plan" : "plan: lịch sử có tập mới → lập lại plan để không trùng");
  }
  const lib = await loadLibrary(dir);
  for (const s of slots(tap)) if (s.fixed && !lib.byId[s.fixed]) throw new Error(`${s.key}: không có hiệu ứng "${s.fixed}"`);
  let best = null;
  const base = seed ?? (Date.now() % 1e6);
  for (let k = 0; k < (seed != null ? 1 : TRIES); k++) {
    const p = tryPlan(tap, lib, hist, base + k * 7919);
    if (!best || p.relaxed < best.relaxed || (p.relaxed === best.relaxed && p.maxSim < best.maxSim)) best = p;
    if (best.maxSim <= MAX_SIM * 0.6 && best.relaxed === 0) break;
  }
  if (best.maxSim > MAX_SIM && !quiet) console.warn(`plan: CẢNH BÁO độ giống ${best.maxSim.toFixed(2)} > ${MAX_SIM} — nên thêm/đổi beat hoặc viết thêm hiệu ứng mới`);
  const plan = { sig, histKey, slug: basename(dir), created: new Date().toISOString().slice(0, 10), ...best };
  mkdirSync(join(dir, "work"), { recursive: true });
  writeFileSync(out, JSON.stringify(plan, null, 1));
  return plan;
}

export function printPlan(plan, lib) {
  const lab = (id) => lib?.byId[id]?.label || "";
  console.log(`seed ${plan.seed} · theme ${plan.theme} · kết liễu ${plan.finisher} · nới luật ${plan.relaxed} lần · giống nhất ${plan.maxSim.toFixed(2)}`);
  for (const [k, id] of Object.entries(plan.pick)) console.log(`  ${k.padEnd(14)} ${id.padEnd(16)} ${lab(id)}`);
  if (plan.sims.length) console.log("  so với: " + plan.sims.map((s) => `${s.slug} ${s.sim.toFixed(2)}`).join(" · "));
}

if (import.meta.url === pathToFileURL(process.argv[1]).href) {
  const args = process.argv.slice(2);
  const dir = args.find((a) => !a.startsWith("--") && !/^\d+$/.test(a));
  if (!dir) { console.error("dùng: node plan.mjs <dir> [--replan] [--seed N]"); process.exit(1); }
  const si = args.indexOf("--seed");
  const plan = await makePlan(dir, { replan: args.includes("--replan"), seed: si >= 0 ? Number(args[si + 1]) : null });
  printPlan(plan, await loadLibrary(resolve(dir)));
}
