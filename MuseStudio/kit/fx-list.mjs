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
