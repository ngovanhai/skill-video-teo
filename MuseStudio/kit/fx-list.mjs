// In kho fx + số lần dùng ở các video gần đây (ideas/fx-history.json).
//   node kit/fx-list.mjs          → toàn bộ kho, cột "gần đây" = 3 video cuối
//   node kit/fx-list.mjs 5        → tính trên 5 video cuối
import { existsSync, readFileSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath } from "node:url";
import { FX } from "./fx/index.mjs";

const KIT = dirname(fileURLToPath(import.meta.url));
const HISTORY = join(KIT, "..", "ideas", "fx-history.json");
const last = Number(process.argv[2]) || 3;
const hist = existsSync(HISTORY) ? JSON.parse(readFileSync(HISTORY, "utf8")) : [];
const recent = hist.slice(-last);

const used = {}, everUsed = {};
for (const h of hist) for (const id of Object.keys(h.fx || {})) everUsed[id] = (everUsed[id] || 0) + 1;
for (const h of recent) for (const [id, n] of Object.entries(h.fx || {})) used[id] = (used[id] || 0) + n;

const byCat = {};
for (const [id, f] of Object.entries(FX)) (byCat[f.cat] ||= []).push([id, f]);
const pad = (s, n) => String(s).padEnd(n);
console.log(`kho fx: ${Object.keys(FX).length} fx — "gần đây" = số lần dùng trong ${recent.length} video cuối, "video" = số video từng dùng (/${hist.length})\n`);
for (const [cat, list] of Object.entries(byCat).sort()) {
  console.log(`[${cat}]`);
  for (const [id, f] of list.sort()) console.log(`  ${pad(id, 13)} ${pad(used[id] || "-", 5)} ${pad(everUsed[id] || "-", 4)} ${pad(f.file, 16)} ${f.label}`);
  console.log("");
}
if (recent.length) {
  console.log("video gần đây:");
  for (const h of recent) console.log(`  ${h.date} ${h.slug} — ${h.creative?.style || "?"} / ${h.creative?.motif || "?"} / hook: ${h.creative?.hook || "?"} — custom: ${(h.custom || []).join(", ") || "-"}`);
  const fresh = Object.keys(FX).filter((id) => !used[id] && id !== "subscribe");
  console.log(`\nchưa dùng gần đây (ưu tiên làm fx chữ ký): ${fresh.join(", ")}`);
}

// bảng chống lặp: 5 tập gần nhất — khung kể, vai Tèo, câu chào / CTA / kết, thumbnail
const five = hist.slice(-5);
if (five.length) {
  const cut = (s, n) => { s = String(s || "-").replace(/\s+/g, " "); return s.length > n ? s.slice(0, n - 1) + "…" : s; };
  console.log(`\nCHỐNG LẶP — ${five.length} tập gần nhất (khung tự thiết kế từ kịch bản: tên/trục/dàn khung không giống 3 tập cuối, voice_role không giống 2 tập cuối, câu chữ không chép):`);
  for (const h of five) {
    const c = h.creative || {}, t = h.thumb || {};
    console.log(`\n  ● ${h.slug} (${h.date})`);
    const fr = c.frame && typeof c.frame === "object" ? c.frame : null;
    console.log(`    khung: ${h.frame || fr?.name || c.frame || "-"} | vai Tèo: ${h.voice_role || c.voice_role || "-"} | style: ${c.style || "-"} | hook: ${c.hook || "-"} | theme: ${h.theme || "-"}`);
    const axis = h.frame_axis || fr?.axis;
    if (axis) console.log(`    trục:  ${cut(axis, 110)}`);
    console.log(`    chào:  ${cut(h.greeting, 110)}`);
    console.log(`    CTA:   ${cut(h.cta, 110)}`);
    console.log(`    kết:   ${cut(h.ending, 110)}`);
    console.log(`    thumb: pose ${t.pose ?? "-"} · bg ${t.bg ?? "-"} · vòng ${t.circle_x ?? "-"},${t.circle_y ?? "-"} · arrow ${t.arrow ?? "-"} · layout ${t.layout ?? "-"} · chữ "${cut(t.text, 40)}"`);
  }
}
