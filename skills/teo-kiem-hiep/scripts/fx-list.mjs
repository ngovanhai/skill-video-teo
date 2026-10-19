// In danh mục hiệu ứng theo nhóm + số lần dùng trong 8 tập gần nhất (để biết nên viết hiệu ứng mới ở nhóm nào).
//   node <SKILL>/scripts/fx-list.mjs [<dir tập>]     (có dir thì liệt kê thêm hiệu ứng local của tập đó)
import { resolve } from "path";
import { loadLibrary } from "../engine/library.mjs";
import { readHistory } from "./plan.mjs";

const dir = process.argv[2] ? resolve(process.argv[2]) : null;
const lib = await loadLibrary(dir);
const recent = readHistory().slice(-8);
const count = {};
for (const h of recent) for (const id of h.seq || []) count[id] = (count[id] || 0) + 1;
const cats = {};
for (const e of lib.all) (cats[e.cat] ||= []).push(e);
console.log(`${lib.all.length} hiệu ứng · lịch sử ${recent.length} tập gần nhất`);
for (const [cat, list] of Object.entries(cats)) {
  console.log(`\n[${cat}] ${list.length}`);
  for (const e of list) {
    const n = count[e.id] || 0;
    const tag = [e.id.startsWith("local:") ? "local" : e.file ? "extra" : "", e.removes ? "removes" : "", e.down ? "down" : ""].filter(Boolean).join(",");
    console.log(`  ${e.id.padEnd(18)} ${String(n).padStart(2)}× ${"▮".repeat(n).padEnd(8)} ${e.label}${tag ? `  (${tag})` : ""}`);
  }
}
const themes = {};
for (const h of recent) themes[h.theme] = (themes[h.theme] || 0) + 1;
console.log(`\ntheme: ${Object.keys(lib.THEMES).map((t) => `${t} ${themes[t] || 0}×`).join(" · ")}`);
