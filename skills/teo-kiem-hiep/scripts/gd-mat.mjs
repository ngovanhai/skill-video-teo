// Xuất mặt (đầu) từng nhân vật của một tập ra SVG cho Godot import thành texture — vẽ bằng <tap>/ve.mjs của chính tập đó.
//   node <SKILL>/scripts/gd-mat.mjs <tap> [--scale 1.5] [--only tieu,quach]
// Đọc cast ở <tap>/godot/cast.json (cùng dạng "cast" của tap.json cũ: preset/robe/hat/beard/... ; thiếu thì lấy tap.json).
// Ra <tap>/godot/mat/<nhân vật>/<biểu cảm>.svg (miệng khép), <biểu cảm>-mo.svg (miệng mở), blink.svg (nhắm mắt, mặt bình).
// Thân người KHÔNG xuất ở đây: mỗi tập tự vẽ thân trong GDScript theo nét riêng của tập.
import { readFileSync, writeFileSync, mkdirSync, existsSync } from "node:fs";
import { join, resolve } from "node:path";
import { pathToFileURL } from "node:url";
import * as R from "../engine/rig2.mjs";
import { castV2 } from "./build.mjs";

const argv = process.argv.slice(2);
const opt = (k, d) => { const i = argv.indexOf("--" + k); return i >= 0 ? argv[i + 1] : d; };
const dir = resolve(argv.find((a) => !a.startsWith("--")) || (console.error("gd-mat: thiếu <tap>"), process.exit(1)));
const scale = +opt("scale", 1.5), only = opt("only", "").split(",").filter(Boolean);
const castFile = join(dir, "godot/cast.json");
const raw = JSON.parse(readFileSync(existsSync(castFile) ? castFile : join(dir, "tap.json"), "utf8"));
const cast = castV2({ cast: raw.cast || raw });
const ve = (await import(pathToFileURL(join(dir, "ve.mjs")).href + "?t=" + Date.now())).default;

// đặt opacity cho thẻ <g id="..."> (thay nếu đã có)
function setOp(svg, id, v) {
  return svg.replace(new RegExp(`<g id="${id}"([^>]*)>`), (m, rest) => `<g id="${id}"${rest.replace(/\s*opacity="[^"]*"/, "")} opacity="${v}">`);
}
const VB = [-50, -70, 400, 540]; // lề cho tóc/mũ/búi vượt khung 300×420
let n = 0;
for (const [k, c] of Object.entries(cast)) {
  if (only.length && !only.includes(k)) continue;
  const L = c.look, p = "m";
  const skin = L.skin || R.SKIN.vang, hair = L.hair || { style: "ngan", color: "#3A2A22" };
  const o = (expr) => ({ id: k, mat: L.mat || {}, skin, hair, eyes: L.eyes || "#6B4A3A", eyes2: L.eyes2, fem: L.fem ?? !!L.skirt, beard: L.beard, beardColor: L.beardColor, hat: L.hat, hatColor: L.hatColor, glasses: L.glasses, age: L.age, expr });
  const band = L.band ? `<path d="M50 132 Q150 96 250 132 L252 154 Q150 118 48 154 Z" fill="${L.band}" ${R.KIT.st(L.band)}/>` : "";
  const wrap = (body) => `<svg xmlns="http://www.w3.org/2000/svg" viewBox="${VB.join(" ")}" width="${VB[2] * scale}" height="${VB[3] * scale}">${body}${band}</svg>`;
  const out = join(dir, "godot/mat", k);
  mkdirSync(out, { recursive: true });
  for (const e of R.EXPRS) {
    const svg = ve(p, o(e), R.KIT);
    writeFileSync(join(out, `${e}.svg`), wrap(svg));
    writeFileSync(join(out, `${e}-mo.svg`), wrap(setOp(setOp(svg, `${p}-mc-${e}`, 0), `${p}-mo-${e}`, 1)));
    n += 2;
  }
  writeFileSync(join(out, "blink.svg"), wrap(setOp(ve(p, o("binh"), R.KIT), `${p}-blink`, 1)));
  n++;
}
// điểm neo cổ trong texture (cho GDScript đặt đầu lên thân): toạ độ (150, 269) của khung mặt = gốc khớp đầu của rig2
writeFileSync(join(dir, "godot/mat/mat.json"), JSON.stringify({ scale, viewBox: VB, neck: [(150 - VB[0]) * scale, (269 - VB[1]) * scale], size: [VB[2] * scale, VB[3] * scale], cast: Object.fromEntries(Object.entries(cast).map(([k, c]) => [k, { name: c.name, robe: c.look.robe, hair: c.look.hair?.color, skin: c.look.skin }])) }, null, 1));
console.log(`gd-mat: ${n} svg → ${join(dir, "godot/mat")}`);
