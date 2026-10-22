// Sổ nhân vật chibi dùng chung: data/chars.json -> look rig2 đầy đủ (gộp preset + ghi đè).
// Dùng ở nơi khác: import { lookOf, loadChars, rig } from "<skill>/scripts/lib.mjs"
import fs from "fs";
import os from "os";
import path from "path";
import { fileURLToPath, pathToFileURL } from "url";

export const SKILL = path.dirname(path.dirname(fileURLToPath(import.meta.url)));
export const CHARS_FILE = path.join(SKILL, "data/chars.json");
const KH = path.join(os.homedir(), ".claude/skills/teo-kiem-hiep/engine");
export const rig = await import(pathToFileURL(path.join(KH, "rig2.mjs")).href);
export const { POSES } = await import(pathToFileURL(path.join(KH, "moves2.mjs")).href);

export const loadChars = () => JSON.parse(fs.readFileSync(CHARS_FILE, "utf8"));

// look rig2 của một nhân vật: preset (nếu có) rồi ghi đè; hair ghi đè từng phần
export function lookOf(id, chars = loadChars()) {
  const c = chars[id];
  if (!c) throw new Error(`không có nhân vật "${id}" trong ${CHARS_FILE}`);
  const { preset, ...o } = c.look;
  const base = preset ? rig.PRESETS[preset] : {};
  if (preset && !base) throw new Error(`${id}: preset "${preset}" không có trong rig2`);
  const out = { ...base, ...o, id };
  if (base.hair || o.hair) out.hair = { style: "ngan", color: "#2B2220", ...(base.hair || {}), ...(o.hair || {}) };
  return out;
}

// kiểm giá trị look: trả về danh sách lỗi
export function lint(id, chars = loadChars()) {
  const errs = [];
  const c = chars[id];
  if (!c.name) errs.push("thiếu name");
  let o;
  try { o = lookOf(id, chars); } catch (e) { return [e.message]; }
  const hex = /^#[0-9A-Fa-f]{6}$/;
  for (const k of ["skin", "robe", "robe2", "pants", "belt", "boots", "eyes", "eyes2", "band", "sash", "beardColor", "hatColor"])
    if (o[k] !== undefined && !hex.test(o[k])) errs.push(`${k}="${o[k]}" phải là mã #RRGGBB`);
  if (o.hair?.style && !rig.KIT.HAIR[o.hair.style]) errs.push(`hair.style "${o.hair.style}" không có (${Object.keys(rig.KIT.HAIR).join(", ")})`);
  if (o.hair?.color && !hex.test(o.hair.color)) errs.push(`hair.color phải là mã #RRGGBB`);
  if (o.beard && o.beard !== true && !["rau-de", "rau-dai", "ria"].includes(o.beard)) errs.push(`beard "${o.beard}" không có (rau-de, rau-dai, ria)`);
  if (o.hat && !["non-la", "khan", "linh", "troc", "tram"].includes(o.hat)) errs.push(`hat "${o.hat}" không có (non-la, khan, linh, troc, tram)`);
  if (o.weapon && !rig.WEAPONS.includes(o.weapon)) errs.push(`weapon "${o.weapon}" không có (${rig.WEAPONS.join(", ")})`);
  return errs;
}

// svg toàn thân đã đặt tư thế. pose: tên trong POSES hoặc dict khớp->độ; all = [độ, dx, dy]
export function posed(p, w, look, pose = "rest", expr = "binh") {
  let svg = rig.figure(p, w, { ...look, expr });
  const v = typeof pose === "string" ? POSES[pose] || POSES.rest : pose;
  for (const [j, a] of Object.entries(v)) {
    const [deg, dx, dy] = Array.isArray(a) ? a : [a, 0, 0];
    svg = svg.replace(new RegExp(`(<g id="${p}-${j}" transform="translate\\()([-\\d.]+) ([-\\d.]+)\\) rotate\\(0\\)`), (_, h, x, y) => `${h}${+x + dx} ${+y + dy}) rotate(${deg})`);
  }
  return svg;
}
