// Xuất nhân vật chibi rig2 (skill teo-kiem-hiep) sang JSON cho Godot: mỗi khớp một Node2D, phần vẽ riêng của khớp
// tách thành các mảnh SVG (toạ độ khớp, khớp ở 0,0) xen giữa các khớp con đúng thứ tự vẽ. Đầu có một bộ mảnh cho mỗi biểu cảm.
// Dùng: node tools/export-chars.mjs [id…]  -> chars/<id>.json (không ghi id = xuất hết sổ)
import fs from "fs";
import path from "path";
import { pathToFileURL } from "url";
import os from "os";

// Nhân vật lấy từ sổ chung của skill nhan-vat-chibi (data/chars.json); thêm/sửa nhân vật ở đó.
const LIB = path.join("__SKILLS_DIR__", "nhan-vat-chibi/scripts/lib.mjs");
const { rig, loadChars, lookOf, lint } = await import(pathToFileURL(LIB).href);
const { figure, JOINTS } = rig;
const BOOK = loadChars();
const CHARS = Object.fromEntries(Object.keys(BOOK).map((id) => [id, lookOf(id, BOOK)]));
const EXPR = ["vui", "binh", "gian", "soc", "quyet-tam", "ko", "dac-y", "ngai"];
const ONLY = process.argv.slice(2);

// ---- XML tối giản (SVG do rig2 sinh luôn cân tag)
function parse(src) {
  const root = { tag: "#root", attrs: "", kids: [] };
  const st = [root];
  const re = /<!--[\s\S]*?-->|<(\/?)([a-zA-Z][\w:-]*)((?:[^>"']|"[^"]*"|'[^']*')*?)(\/?)>|([^<]+)/g;
  let m;
  while ((m = re.exec(src))) {
    if (m[5] !== undefined) { if (m[5].trim()) st.at(-1).kids.push({ text: m[5] }); continue; }
    if (!m[2]) continue;
    if (m[1]) { st.pop(); continue; }
    const n = { tag: m[2], attrs: m[3], kids: [] };
    st.at(-1).kids.push(n);
    if (!m[4]) st.push(n);
  }
  return root;
}
const ser = (n) => (n.text !== undefined ? n.text : `<${n.tag}${n.attrs}>${n.kids.map(ser).join("")}</${n.tag}>`);
const idOf = (n) => (n.attrs && (n.attrs.match(/\bid="([^"]+)"/) || [])[1]) || "";

function build(id, o, expr) {
  const p = "c";
  const svg = figure(p, 400, { ...o, expr });
  const tree = parse(svg);
  const jointName = (n) => { const i = idOf(n); return i.startsWith(p + "-") && JOINTS.includes(i.slice(2)) && n.tag === "g" ? i.slice(2) : null; };
  const hasJoint = (n) => (n.kids || []).some((k) => jointName(k) || hasJoint(k));
  const defs = [];
  const grabDefs = (n) => { for (const k of n.kids || []) { if (k.tag === "defs") defs.push(ser(k)); else grabDefs(k); } };
  grabDefs(tree);
  const joints = [];
  const segs = [];
  // một khớp: duyệt con theo thứ tự; gom nội dung liền nhau thành một mảnh, gặp khớp con thì cắt mảnh
  function walkJoint(n, name, parent) {
    const tr = n.attrs.match(/translate\(([-\d.]+)[ ,]+([-\d.]+)\)/);
    joints.push({ name, parent, pos: [+tr[1], +tr[2]] });
    const order = [];
    let cur = [];
    const flush = () => { if (cur.length) { order.push({ seg: cur.join("") }); cur = []; } };
    function walk(node, wraps) {
      for (const k of node.kids) {
        const jn = k.text === undefined ? jointName(k) : null;
        if (jn) { flush(); order.push({ joint: jn }); walkJoint(k, jn, name); }
        else if (k.text === undefined && hasJoint(k)) walk(k, [...wraps, k]);
        else if (k.tag !== "defs") {
          let s = ser(k);
          for (let i = wraps.length - 1; i >= 0; i--) s = `<${wraps[i].tag}${wraps[i].attrs.replace(/\bid="[^"]*"/, "")}>${s}</${wraps[i].tag}>`;
          cur.push(s);
        }
      }
    }
    walk(n, []);
    flush();
    const j = joints.find((x) => x.name === name);
    j.order = order.map((x, i) => (x.joint ? { joint: x.joint } : { seg: segs.push({ joint: name, i, svg: x.seg }) - 1 }));
  }
  const all = (function find(n) { for (const k of n.kids || []) { if (jointName(k) === "all") return k; const r = find(k); if (r) return r; } })(tree);
  walkJoint(all, "all", null);
  return { joints, segs, defs: defs.join("") };
}

fs.mkdirSync("chars", { recursive: true });
for (const id of ONLY) if (!CHARS[id]) { console.error(`không có "${id}" trong sổ nhan-vat-chibi/data/chars.json`); process.exit(1); }
for (const [id, o] of Object.entries(CHARS)) {
  if (ONLY.length && !ONLY.includes(id)) continue;
  const errs = lint(id, BOOK);
  if (errs.length) { console.error(`${id}: ${errs.join("; ")}`); process.exit(1); }
  const base = build(id, o, "binh");
  const out = { id, view: [-350, -470, 700, 940], defs: base.defs, joints: base.joints, segs: base.segs.map((s) => ({ joint: s.joint, svg: s.svg })), faces: {} };
  // mảnh của khớp head đổi theo biểu cảm
  for (const e of EXPR) {
    const b = build(id, o, e);
    out.faces[e] = b.segs.map((s, i) => (s.joint === "head" ? [i, s.svg] : null)).filter(Boolean);
  }
  fs.writeFileSync(`chars/${id}.json`, JSON.stringify(out));
  console.log(id, "joints", out.joints.length, "segs", out.segs.length, (fs.statSync(`chars/${id}.json`).size / 1024).toFixed(0) + "KB");
}
