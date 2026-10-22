// Dựng một tập Tèo kiếm hiệp từ <dir>/tap.json → <dir>/index.html (HyperFrames) + <dir>/thumb/ (thumbnail 1280×720).
//   node <SKILL>/scripts/build.mjs <dir> [--replan] [--seed N]
// Không dùng ffmpeg; chỉ HTML/SVG + GSAP. Render: cd <dir> && npx --yes hyperframes@0.8.172 render --output renders/final.mp4 --quality standard
import { readFileSync, writeFileSync, mkdirSync, existsSync, copyFileSync, readdirSync } from "fs";
import { join, resolve, basename } from "path";
import { pathToFileURL } from "url";
import { teo, npc, PRESETS, HATS, WEAPONS } from "../engine/rig.mjs";
import { figure, PRESETS as PRESETS2, WEAPONS as WEAPONS2, JPOS, EXPRS, FEET } from "../engine/rig2.mjs";
import { POSES as POSES2 } from "../engine/moves2.mjs";
import { SETS, GROUND, WEATHER, STAGES } from "../engine/sets.mjs";
import { execFileSync } from "child_process";
import { createHash } from "crypto";
import { loadLibrary, SKILL } from "../engine/library.mjs";
import { homedir } from "os";
// sổ nhân vật chung (skill nhan-vat-chibi): cast {"char": id} lấy nguyên look rig2 từ đó
const CHARLIB = join(homedir(), ".claude/skills/nhan-vat-chibi/scripts/lib.mjs");
const CHARBOOK = existsSync(CHARLIB) ? await import(pathToFileURL(CHARLIB).href) : null;
import { makePlan, printPlan } from "./plan.mjs";
import { PLANNED } from "../engine/slots.mjs";
import { loadVoice, voOf } from "../engine/voice.mjs";
import { printSlow } from "../engine/slow.mjs";

const KIT = "__MUSE_ROOT__/kit";
const SFX_LEN = { chime: 2.5, click: 0.37, error: 1.62, "glitch-1": 2.64, "impact-bass-1": 2.12, "impact-bass-2": 2.59, pop: 0.72, riser: 10.03, sparkle: 1.8, "whoosh-cinematic": 5.54, "whoosh-short": 0.57, whoosh: 0.57 };
const BGM = { file: "playful-pizzicato.mp3", len: 67 };
// mức nhạc nền theo cảnh (scene.music); "on" = như cũ
const MUSIC = { on: 1, low: 0.4, off: 0, up: 1.7 };
// kiểu bong bóng thoại cả tập (tap.bubble); "tron" = như cũ
const BUBBLE = {
  giay: { normal: "background:#F6EBD0;border:5px solid #5A3B1C;border-radius:8px", think: "background:#F6EBD0;border:5px dashed #5A3B1C;border-radius:8px", color: "#3B2410", tail: "#5A3B1C" },
  muc: { normal: "background:#141414;border:5px solid #F3E6C8;border-radius:6px", think: "background:#141414;border:5px dashed #F3E6C8;border-radius:30px", color: "#F7F1E3", tail: "#F3E6C8" },
  vuong: { normal: "background:#fff;border:7px solid #111;border-radius:0", think: "background:#fff;border:6px dotted #111;border-radius:0", color: "#111", tail: "#111" },
};
// GSAP: có bản trong engine/vendor thì chép vào tập (render không cần mạng), không thì dùng CDN
const GSAP_CDN = "https://cdn.jsdelivr.net/npm/gsap@3.14.2/dist/gsap.min.js";
const GSAP_LOCAL = join(SKILL, "engine/vendor/gsap.min.js");
const GSAP_SRC = existsSync(GSAP_LOCAL) ? "assets/gsap.min.js" : GSAP_CDN;
const copyGsap = (d) => { if (GSAP_SRC !== GSAP_CDN) { mkdirSync(join(d, "assets"), { recursive: true }); copyFileSync(GSAP_LOCAL, join(d, "assets/gsap.min.js")); } };
const LEAD = 0.6, TAIL = 0.7; // đầu/cuối mỗi cảnh (chừa chỗ cho chuyển cảnh che 0.45 s / mở 0.55 s)
const f2 = (x) => (Math.round(x * 100) / 100).toString();
const esc = (s) => String(s).replace(/&/g, "&amp;").replace(/</g, "&lt;");
const die = (m) => { console.error("build: " + m); process.exit(1); };
const mulberry = (a) => () => { a |= 0; a = (a + 0x6d2b79f5) | 0; let t = Math.imul(a ^ (a >>> 15), 1 | a); t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t; return ((t ^ (t >>> 14)) >>> 0) / 4294967296; };

// ---------------------------------------------------------------- cast
function castOf(tap) {
  const cast = {};
  for (const [id, c] of Object.entries(tap.cast || {})) {
    const kind = c.kind || (id === "teo" ? "teo" : "npc");
    if (c.char) {
      if (!V2) die(`cast.${id}: "char" chỉ dùng với rig 2 ("rig": 2)`);
      if (!CHARBOOK) die(`cast.${id}: chưa có skill nhan-vat-chibi (${CHARLIB})`);
      const book = CHARBOOK.loadChars();
      if (!book[c.char]) die(`cast.${id}: không có "${c.char}" trong sổ nhan-vat-chibi (có: ${Object.keys(book).join(", ")})`);
      const over = Object.fromEntries(Object.entries(c).filter(([k]) => !["char", "kind", "name", "w", "side", "preset", "x", "face", "hidden"].includes(k)));
      if (over.weapon) over.weapon = WP2(over.weapon);
      cast[id] = { id, kind: "npc", look: { ...CHARBOOK.lookOf(c.char, book), ...over, _v2: true, id }, name: c.name || book[c.char].name, w: c.w || 190, side: c.side || "foe" };
      continue;
    }
    const look = kind === "teo" ? { band: c.band ?? "#D7263D", weapon: c.weapon || "kiem", jacket: c.jacket || "#5B8DEF" } : { ...(PRESETS[c.preset] || {}), ...Object.fromEntries(Object.entries(c).filter(([k]) => ["robe", "hat", "beard", "weapon", "skin", "belt", "patch", "sash"].includes(k))) };
    if (c.preset && !PRESETS[c.preset]) die(`cast.${id}: preset "${c.preset}" không có (có: ${Object.keys(PRESETS).join(", ")})`);
    if (kind !== "teo" && look.hat && !HATS.includes(look.hat)) die(`cast.${id}: hat "${look.hat}" không có (có: ${HATS.join(", ")})`);
    if (look.weapon && !WEAPONS.includes(look.weapon)) die(`cast.${id}: weapon "${look.weapon}" không có (có: ${WEAPONS.join(", ")})`);
    cast[id] = { id, kind, look: V2 ? { ...look2(kind, kind === "teo" ? { ...look, ...pickV2(c) } : Object.fromEntries(Object.entries(c).filter(([k]) => ["robe", "hat", "beard", "weapon", "skin", "belt", "sash", ...V2_ONLY].includes(k))), c.preset), id } : look, name: c.name || id, w: c.w || (kind === "teo" ? 250 : 190), side: c.side || (kind === "teo" ? "hero" : "foe") };
  }
  return cast;
}
// cast đã quy về rig 2 (cho công cụ xem mặt ve.mjs ngoài build)
export function castV2(tap) { const v = V2; V2 = true; try { return castOf(tap); } finally { V2 = v; } }
const rigH = (type, w) => (type === "teo" ? Math.round((w * 760) / 500) : Math.round(w * 1.5));
// rig 2 (tap.rig = 2 hoặc --rig 2): hình v2 (engine/rig2.mjs) vẽ trong đúng hộp w×rigH của rig cũ — chân chạm đáy hộp, đỉnh tóc chạm
// đỉnh hộp — nên vị trí diễn viên, bong bóng, koHead và fx dùng a.top/a.h không đổi. Lệnh v1 trong fx chạy qua engine/compat2.js.
let V2 = false;
let VE = null; // <dir>/ve.mjs: hàm vẽ đầu riêng của tập (rig 2)
const V2_TOP = 99; // đỉnh tóc (toạ độ viewBox 400×620); chân ở FEET
const HAT2 = { non: "non-la", dao: "tram", bui: undefined, none: undefined, linh: "linh", khan: "khan", troc: "troc" };
// trường chỉ rig 2 hiểu (mặt riêng ve.mjs dùng mat/fem/age/eyes2): chép thẳng từ cast
const V2_ONLY = ["eyes", "eyes2", "fem", "hair", "age", "mat"];
const pickV2 = (c) => Object.fromEntries(Object.entries(c).filter(([k]) => V2_ONLY.includes(k)));
const WP2 = (w) => (w === undefined ? undefined : WEAPONS2.includes(w) ? w : "kiem");
// diện mạo v1 (cast cũ hoặc look viết tay trong fx) → v2; look đã là v2 (_v2) thì giữ
function look2(type, look = {}, preset) {
  if (look._v2) return look;
  const def = (o) => Object.fromEntries(Object.entries(o).filter(([, v]) => v !== undefined));
  if (type === "teo") return { ...PRESETS2.teo, ...def({ band: look.band, weapon: WP2(look.weapon), robe: look.jacket }), ...pickV2(look), _v2: true };
  const o = { ...(PRESETS2[preset] || PRESETS2[String(preset).replace(/-.*/, "")] || {}) };
  if (look.robe) o.robe = look.robe;
  if ("hat" in look) { o.hat = HAT2[look.hat] ?? (look.hat in HAT2 ? undefined : look.hat); if (look.hat === "dao") o.hair = { style: "bui-cao", color: o.hair?.color || "#1E1A1A" }; if (look.hat === "bui" && !o.hair) o.hair = { style: "bui-toi", color: "#2B2220" }; }
  if ("beard" in look) { if (!look.beard) delete o.beard; else { o.beard = o.beard || "rau-dai"; if (typeof look.beard === "string" && look.beard.startsWith("#")) o.beardColor = look.beard; } }
  if (look.weapon) o.weapon = WP2(look.weapon);
  for (const k of ["skin", "belt", "sash", ...V2_ONLY]) if (look[k] !== undefined) o[k] = look[k];
  return { ...o, _v2: true };
}
// ---------------------------------------------------------------- mặt riêng từng tập (ve.mjs)
async function loadVe(file) {
  const fn = (await import(pathToFileURL(file).href + "?t=" + Date.now())).default;
  if (typeof fn !== "function") die(`${file}: cần export default function (p, o, kit) → svg đầu`);
  return fn;
}
// lấy nguyên khối <g id="..."> (kể cả g lồng) trong svg
function grabG(svg, id) {
  const i = svg.indexOf(`id="${id}"`); if (i < 0) return null;
  const a = svg.lastIndexOf("<g", i); let d = 0;
  for (const m of svg.slice(a).matchAll(/<g[\s>]|<\/g>/g)) { d += m[0] === "</g>" ? -1 : 1; if (!d) return svg.slice(a, a + m.index + 4); }
  return null;
}
// dấu vân mặt: bỏ prefix + màu → so được hình dáng (mắt/mũi/khuôn mặt) giữa các nhân vật và các tập
const veFp = (g, p) => createHash("sha1").update(g.split(p).join("P").replace(/#[0-9a-fA-F]{3,8}/g, "#")).digest("hex").slice(0, 12);
function veFace(fn, c) {
  const p = "vechk", svg = figure(p, 400, { ...look2(c.kind, c.look), ve: fn, expr: "binh" });
  const need = [`${p}-mat`, `${p}-blink`, ...EXPRS.flatMap((e) => [`${p}-ex-${e}`, `${p}-mc-${e}`, `${p}-mo-${e}`])];
  const miss = need.filter((id) => !svg.includes(`id="${id}"`)).map((id) => id.replace(p, "<p>"));
  if (miss.length) die(`ve.mjs (${c.id}): thiếu nhóm ${miss.slice(0, 6).join(", ")}${miss.length > 6 ? "…" : ""} — xem SKILL.md "Mặt riêng từng tập"`);
  return { mat: veFp(grabG(svg, `${p}-mat`), p), mat2: veFp(grabG(svg, `${p}-ex-binh`), p) };
}
async function checkVe(dir, cast) {
  const fp = Object.fromEntries(Object.values(cast).map((c) => [c.id, veFace(VE, c)]));
  const ids = Object.keys(fp), what = { mat: "khuôn mặt/mũi (nhóm <p>-mat)", mat2: "mắt/mày/miệng (nhóm <p>-ex-binh)" };
  const clash = (fpA, fpB) => ["mat", "mat2"].find((k) => fpA[k] === fpB[k]);
  for (let i = 0; i < ids.length; i++) for (let j = i + 1; j < ids.length; j++) { const k = clash(fp[ids[i]], fp[ids[j]]);
    if (k) die(`ve.mjs: ${ids[i]} và ${ids[j]} trùng ${what[k]} — mỗi nhân vật phải có mặt riêng (dùng o.id / cast.mat)`); }
  // không chép mẫu: cùng cast, vẽ bằng examples/ve-mau.mjs mà ra cùng dấu vân → chép nguyên
  const mau = join(SKILL, "examples/ve-mau.mjs");
  if (existsSync(mau)) { const fnM = await loadVe(mau);
    for (const c of Object.values(cast)) { const k = clash(fp[c.id], veFace(fnM, c)); if (k) die(`ve.mjs: ${c.id} có ${what[k]} giống hệt examples/ve-mau.mjs — mẫu chỉ để tham khảo, tập phải tự vẽ`); } }
  // không trùng tập khác (các thư mục tập cùng cấp có work/ve-fp.json)
  const up = resolve(dir, ".."), self = basename(dir);
  for (const d of readdirSync(up)) { const f = join(up, d, "work/ve-fp.json"); if (d === self || !existsSync(f)) continue;
    const o = JSON.parse(readFileSync(f, "utf8"));
    for (const [oid, ofp] of Object.entries(o.chars || {})) for (const [id, cur] of Object.entries(fp)) { const k = clash(cur, ofp);
      if (k) die(`ve.mjs: ${id} trùng ${what[k]} với ${d}/${oid} — mỗi tập vẽ mặt riêng, không dùng chung`); } }
  mkdirSync(join(dir, "work"), { recursive: true });
  writeFileSync(join(dir, "work/ve-fp.json"), JSON.stringify({ tap: self, chars: fp }, null, 1));
}
function rigSvg(type, p, w, look) {
  if (!V2) return type === "teo" ? teo(p, w, look) : npc(p, w, look);
  const h = rigH(type, w), k = h / (FEET - V2_TOP), w2 = 400 * k;
  return `<div style="position:relative;width:${w}px;height:${h}px"><div style="position:absolute;left:${f2((w - w2) / 2)}px;top:${f2(-V2_TOP * k)}px">${figure(p, f2(w2), { ...look2(type, look), ...(VE ? { ve: VE } : {}) })}</div></div>`;
}
const HEAD1 = { teo: 0.24, npc: 0.33 }, HEAD2 = { teo: 0.283, npc: 0.283 };
let HEAD = HEAD1;

// ---------------------------------------------------------------- built-in beats (không phải "hiệu ứng" xoay vòng)
const BUILTIN = {
  wait: (ctx, b) => ({ dur: b.dur ?? 0.6 }),
  // âm thanh điểm xuyết đặt tay: {"do":"sfx","name":"chime","vol":0.4,"dur":1}
  sfx(ctx, b, t) { if (!SFX_LEN[b.name]) die(`${ctx.curKey}: sfx "${b.name}" không có (có: ${Object.keys(SFX_LEN).join(", ")})`); ctx.sfx(b.name, t, b.vol ?? 0.4, b.len); return { dur: b.dur ?? 0.1 }; },
  pose(ctx, b, t) {
    const a = ctx.actor(b.who);
    ctx.js(`POSE("${a.p}", "${b.pose || "rest"}", ${f2(t)}, ${b.dur ?? 0.3});${b.brow ? ` BROW("${a.p}", ${f2(t)}, ${b.brow === "angry"});` : ""}`);
    return { dur: b.hold ?? 0.4 };
  },
  move(ctx, b, t) {
    const a = ctx.actor(b.who), dest = Math.max(20, Math.min(1900 - a.w, b.to - a.w / 2)), d = b.dur ?? Math.max(0.5, Math.abs(dest - a.x) / 700);
    ctx.moveTo(b.who, dest, t, d, "sine.inOut");
    ctx.js(`RUN("${a.p}", ${f2(t)}, ${f2(t + d)}, "#${a.body}", ${a.type === "teo"}, 22, 0.16);`);
    if (b.face) ctx.face(b.who, b.face, t);
    return { dur: d };
  },
  face(ctx, b, t) { ctx.face(b.who, b.dir, t); return { dur: 0.15 }; },
  say(ctx, b, t) {
    const a = ctx.actor(b.who), text = String(b.text), n = [...text].length, tone = b.tone || "normal";
    const v = ctx.voice?.(text); // giọng Tèo (scripts/voice.mjs) → bong bóng hiện đúng bằng thời gian đọc
    if (ctx.voice && !v) ctx.voiceMiss.push(text);
    const dur = (v ? Math.max(1.5, v.dur + 0.35) : Math.min(5.5, Math.max(1.5, 1.0 + n * 0.055))) + (b.hold || 0);
    if (v) ctx.voiceList.push({ file: v.file, t: t + 0.08, dur: v.dur });
    const fs = tone === "shout" ? 50 : tone === "whisper" ? 38 : 44, cw = fs * 0.56;
    const bw = Math.min(780, n * cw + 80), lines = Math.ceil((n * cw) / (bw - 80)), bh = lines * fs * 1.22 + 48;
    let left = Math.max(30, Math.min(1890 - bw, a.cx - bw / 2)), top = a.top - bh - 46, tail = "down";
    if (top < 30) { top = Math.max(30, a.top); left = a.cx > 960 ? a.x - bw - 30 : a.x + a.w + 30; left = Math.max(30, Math.min(1890 - bw, left)); tail = a.cx > 960 ? "right" : "left"; }
    const tx = Math.max(40, Math.min(bw - 60, a.cx - left - 20));
    const u = ctx.uid("say");
    let style = {
      normal: "background:#fff;border:6px solid #111;border-radius:40px",
      shout: "background:#FFE45C;border:7px solid #111;border-radius:16px",
      whisper: "background:rgba(255,255,255,.92);border:5px dashed #555;border-radius:40px;font-style:italic",
      think: "background:#fff;border:6px solid #111;border-radius:60px",
    }[tone];
    const BB = BUBBLE[ctx.bubble];
    const bbOn = BB && (tone === "normal" || tone === "think");
    if (bbOn) style = BB[tone];
    const ink = bbOn ? BB.color : "#111", tc = bbOn ? BB.tail : "#111";
    const tailSvg = tone === "think"
      ? `<i style="position:absolute;left:${f2(tx)}px;top:${f2(bh + 4)}px;width:26px;height:26px;border-radius:50%;background:#fff;border:5px solid #111"></i><i style="position:absolute;left:${f2(tx + 14)}px;top:${f2(bh + 36)}px;width:14px;height:14px;border-radius:50%;background:#fff;border:4px solid #111"></i>`
      : tail === "down" ? `<i style="position:absolute;left:${f2(tx)}px;top:${f2(bh - 6)}px;width:0;height:0;border-left:20px solid transparent;border-right:20px solid transparent;border-top:40px solid ${tc}"></i>`
      : `<i style="position:absolute;${tail === "left" ? "left:-36px" : "right:-36px"};top:40px;width:0;height:0;border-top:18px solid transparent;border-bottom:18px solid transparent;${tail === "left" ? "border-right" : "border-left"}:40px solid ${tc}"></i>`;
    ctx.add("fx", `<div id="${u}" style="position:absolute;left:${f2(left)}px;top:${f2(top)}px;width:${f2(bw)}px;height:${f2(bh)}px;opacity:0;${style};box-shadow:8px 8px 0 rgba(0,0,0,.3);padding:20px 36px 0;font:700 ${fs}px/1.22 'Space Grotesk';color:${ink};text-align:center">${esc(text)}${tailSvg}</div>`);
    ctx.js(`POP("#${u}", ${f2(t)}); HIDE("#${u}", ${f2(t + dur - 0.2)}, 0.15);`);
    if (tone !== "think") ctx.js(`FLAP("${a.p}", ${f2(t + 0.1)}, ${f2(v ? t + 0.08 + v.dur : t + Math.min(dur - 0.3, 0.4 + n * 0.05))});`);
    if (tone === "shout") { ctx.js(`BROW("${a.p}", ${f2(t)}, true); SHAKE("#${u}", ${f2(t + 0.3)}, 0.3, 6);`); ctx.sfx("pop", t, 0.35); }
    else ctx.sfx("pop", t, 0.2);
    if (b.brow) ctx.js(`BROW("${a.p}", ${f2(t)}, ${b.brow === "angry"});`);
    if (b.pose) ctx.js(`POSE("${a.p}", "${b.pose}", ${f2(t)}, 0.3);`);
    return { dur };
  },
  emote(ctx, b, t) {
    const a = ctx.actor(b.who), u = ctx.uid("em"), hx = a.cx + a.w * 0.32, hy = a.top + a.h * 0.06, kind = b.kind || "sweat";
    const D = 1.2;
    const art = {
      sweat: `<svg width="50" height="70" viewBox="0 0 50 70" style="overflow:visible"><path d="M25 0 Q50 40 25 68 Q0 40 25 0 Z" fill="#7FD3FF" stroke="#111" stroke-width="5"/></svg>`,
      anger: `<svg width="80" height="80" viewBox="-40 -40 80 80" style="overflow:visible">${[0, 90, 180, 270].map((r) => `<path transform="rotate(${r})" d="M6 -30 Q8 -10 30 -6" fill="none" stroke="#E8452E" stroke-width="10" stroke-linecap="round"/>`).join("")}</svg>`,
      "?": `<div style="font:700 110px 'Space Grotesk';color:#fff;-webkit-text-stroke:6px #111;paint-order:stroke fill">?</div>`,
      "!": `<div style="font:700 120px 'Space Grotesk';color:#FFD23F;-webkit-text-stroke:6px #111;paint-order:stroke fill">!</div>`,
      sparkle: `<svg width="90" height="90" viewBox="-45 -45 90 90" style="overflow:visible"><path d="M0 -42 L9 -9 L42 0 L9 9 L0 42 L-9 9 L-42 0 L-9 -9 Z" fill="#FFF3A0" stroke="#111" stroke-width="5"/></svg>`,
      sigh: `<svg width="120" height="60" viewBox="0 0 120 60" style="overflow:visible"><path d="M10 40 Q30 0 60 30 Q90 0 110 34 Q80 60 50 50 Q20 62 10 40 Z" fill="#EEE" stroke="#111" stroke-width="5"/></svg>`,
      drop: `<svg width="60" height="80" viewBox="0 0 60 80" style="overflow:visible"><path d="M8 6 L8 70 M28 0 L28 76 M48 6 L48 70" stroke="#5A6B9A" stroke-width="7" stroke-linecap="round"/></svg>`,
    }[kind];
    if (!art) die(`emote kind "${kind}" không có (sweat|anger|?|!|sparkle|sigh|drop)`);
    const x = kind === "sigh" ? a.cx - 60 : kind === "drop" ? a.cx - 30 : hx, y = kind === "drop" ? a.top + a.h * 0.02 : kind === "sigh" ? a.top + a.h * 0.32 : hy - 60;
    ctx.add("fx", `<div id="${u}" style="position:absolute;left:${f2(x)}px;top:${f2(y)}px;opacity:0">${art}</div>`);
    const anim = { sweat: `tl.to("#${u}", { y: 60, duration: ${D}, ease: "power1.in" }, ${f2(t + 0.2)});`, anger: `tl.to("#${u}", { scale: 1.25, duration: 0.15, yoyo: true, repeat: 5 }, ${f2(t + 0.2)});`, "?": `tl.to("#${u}", { rotation: 12, duration: 0.2, yoyo: true, repeat: 3 }, ${f2(t + 0.3)});`, "!": `tl.to("#${u}", { y: -20, duration: 0.12, yoyo: true, repeat: 3 }, ${f2(t + 0.3)});`, sparkle: `tl.to("#${u}", { rotation: 180, duration: ${D}, ease: "none" }, ${f2(t)});`, sigh: `tl.to("#${u}", { x: ${a.cx > 960 ? -80 : 80}, opacity: 0, duration: ${D}, ease: "power1.out" }, ${f2(t + 0.3)});`, drop: "" }[kind];
    ctx.js(`POP("#${u}", ${f2(t)}); ${anim} HIDE("#${u}", ${f2(t + D + 0.1)});${kind === "anger" ? ` BROW("${a.p}", ${f2(t)}, true);` : ""}${kind === "sparkle" ? ` BLINK("${a.p}", ${f2(t + 0.2)});` : ""}`);
    ctx.sfx(kind === "anger" || kind === "!" ? "click" : kind === "sparkle" ? "sparkle" : "pop", t, 0.3);
    return { dur: b.dur ?? D + 0.2 };
  },
};

// ---------------------------------------------------------------- scene builder
function makeCtx(base, S, t0) {
  const L = { bg: [], behind: [], act: [], fx: [], hud: [] };
  const ctx = {
    ...base, S, t0, t1: t0, L, actors: {}, lastAttacker: null, curKey: S,
    add(layer, html) { if (layer === "over") base.over.push(html); else (L[layer] || die(`layer "${layer}" không có`)).push(html); },
    js(code) { base.code.push(code); },
    uid(p) { return `${S}${p}${base.n++}`; },
    rig(type, p, w, look = {}, flip = false) { base.RIG[p] = type; const s = rigSvg(type, p, w, look); return flip ? `<div style="transform:scaleX(-1)">${s}</div>` : s; },
    rigType(p, type) { base.RIG[p] = type; },
    actor(id) {
      const s = ctx.actors[id];
      if (!s) die(`${ctx.curKey}: diễn viên "${id}" không có trong cảnh`);
      const top = s.foot - s.h, cx = s.x + s.w / 2, d = s.h * (1 - HEAD[s.type]);
      return {
        id, type: s.type, look: s.look, flip: s.flip, p: s.p, wrap: `${S}-a-${id}`, body: `${S}-ab-${id}`, inner: `${S}-ai-${id}`,
        x: s.x, ox: s.x - s.L0, w: s.w, h: s.h, cx, top, cy: top + s.h / 2, foot: s.foot,
        koHead: s.down ? { x: cx + s.downSide * d, y: s.foot - s.w * 0.25 } : { x: cx, y: top + s.h * HEAD[s.type] },
      };
    },
    others(who) {
      const me = ctx.actors[who];
      const live = Object.values(ctx.actors).filter((s) => s.id !== who && !s.gone && !s.down && s.visible);
      const foes = live.filter((s) => s.side !== me?.side);
      const r = (foes.length ? foes : live).map((s) => s.id);
      if (!r.length) die(`${ctx.curKey}: "${who}" tấn công nhưng không còn ai đứng trong cảnh — ghi "target"`);
      return r;
    },
    moveTo(id, left, t, dur, ease = "power2.inOut") { const s = ctx.actors[id]; ctx.js(`tl.to("#${S}-a-${id}", { x: ${f2(left - s.L0)}, duration: ${f2(dur)}, ease: "${ease}" }, ${f2(t)});`); s.x = left; },
    face(id, dir, t) { const s = ctx.actors[id], flip = dir === "left"; if (flip !== s.flip) { ctx.js(`tl.set("#${S}-ai-${id}", { scaleX: ${flip ? -1 : 1} }, ${f2(t)});`); s.flip = flip; } },
    knock(id, dx, side) { const s = ctx.actors[id]; s.x += dx; if (side) { s.down = true; s.downSide = side; } },
    gone(id) { ctx.actors[id].gone = true; },
    // hướng ngã/văng = ra xa người đánh; nếu sát mép khung (đầu sẽ ra ngoài màn hình) thì ngã ngược lại
    attackerSide(a) {
      const att = ctx.lastAttacker ? ctx.actor(ctx.lastAttacker) : null;
      const s = !att ? (a.cx > 960 ? 1 : -1) : a.cx >= att.cx ? 1 : -1;
      return a.cx + s * a.h * 0.9 > 1900 || a.cx + s * a.h * 0.9 < 20 ? -s : s;
    },
    sub(cat, payload, t) {
      const key = `${ctx.curKey}.${cat}`, id = base.plan.pick[key];
      const e = base.lib.byId[id] || die(`${key}: plan thiếu hiệu ứng (chạy lại với --replan)`);
      base.used.push({ key, id, t });
      return e.run(ctx, payload, t);
    },
  };
  return ctx;
}

function runFx(ctx, key, cat, payload, t) {
  const id = ctx.plan.pick[key];
  const e = ctx.lib.byId[id] || die(`${key}: không tìm thấy hiệu ứng "${id}" (chạy lại với --replan)`);
  if (e.cat !== cat && !(cat === "local")) console.warn(`build: ${key} dùng ${id} (nhóm ${e.cat}) cho slot nhóm ${cat}`);
  ctx.used.push({ key, id, t });
  return e.run(ctx, payload, t) || { dur: 1 };
}

function sceneClip(ctx, start, dur, track, z, extraBg = "") {
  const L = ctx.L, S = ctx.S, st = ctx.stage || {};
  const flt = (k) => (st[k] ? ` style="filter:${st[k]}"` : "");
  return `<div id="${S}" class="clip fill" data-start="${f2(start)}" data-duration="${f2(dur)}" data-track-index="${track}" style="z-index:${z};overflow:hidden">
<div id="${S}-shake" class="fill"><div id="${S}-cam" class="fill"${flt("cam")}>
<div id="${S}-bg" class="fill"${flt("bg")}>${extraBg}${L.bg.join("\n")}</div>
<div id="${S}-behind" class="fill">${L.behind.join("\n")}</div>
<div id="${S}-act" class="fill"${flt("act")}>${L.act.join("\n")}</div>
<div id="${S}-fx" class="fill">${L.fx.join("\n")}</div>
</div><div id="${S}-hud" class="fill">${L.hud.join("\n")}</div></div></div>`;
}

function buildScene(base, sc, i, t0) {
  const S = `s${i}`, ctx = makeCtx(base, S, t0);
  if (sc.music && !(sc.music in MUSIC)) die(`scenes[${i}].music "${sc.music}" không có (có: ${Object.keys(MUSIC).join(", ")})`);
  if (!SETS[sc.set]) die(`scenes[${i}].set "${sc.set}" không có (có: ${Object.keys(SETS).join(", ")})`);
  // diễn viên
  for (const a of sc.actors || []) {
    const c = base.cast[a.id] || die(`scenes[${i}]: "${a.id}" chưa khai báo trong cast`);
    const w = a.w || c.w, h = rigH(c.kind, w), foot = a.foot || GROUND + 20, L0 = Math.round(a.x - w / 2);
    const flip = a.face ? a.face === "left" : a.x > 960;
    const p = `${S}${a.id.replace(/[^a-zA-Z0-9]/g, "")}`;
    base.RIG[p] = c.kind;
    ctx.actors[a.id] = { id: a.id, type: c.kind, look: c.look, side: c.side, p, w, h, foot, L0, x: L0, flip, visible: !a.hidden, down: false, gone: false };
    ctx.add("act", `<div id="${S}-a-${a.id}" style="position:absolute;left:${L0}px;top:${foot - h}px;width:${w}px;height:${h}px;opacity:${a.hidden ? 0 : 1}"><div id="${S}-ab-${a.id}" style="position:absolute;left:0;top:0;width:${w}px;height:${h}px"><div id="${S}-ai-${a.id}" style="width:${w}px;height:${h}px;transform:scaleX(${flip ? -1 : 1})">${rigSvg(c.kind, p, w, c.look)}</div></div></div>`);
    if (a.pose) ctx.js(`POSE("${p}", "${a.pose}", ${f2(t0)}, 0.01);`);
    if (a.down) { ctx.js(`KO("${p}", ${f2(t0)}); tl.set("#${S}-ab-${a.id}", { rotation: ${flip ? -90 : 90}, y: ${-w * 0.18}, transformOrigin: "50% 100%" }, ${f2(t0)});`); ctx.actors[a.id].down = true; ctx.actors[a.id].downSide = flip ? -1 : 1; }
  }
  // beats
  let t = t0 + LEAD, lastHit = null, lastEnd = t, prevStart = t;
  sc.beats.forEach((b, j) => {
    const key = `${S}.b${j}`;
    ctx.curKey = key;
    let start = b.with ? prevStart : lastHit != null && b.do === "react" ? lastHit + 0.02 : lastEnd;
    start += b.delay || 0;
    // diễn viên đang nằm mà còn diễn tiếp → tự bật dậy (0.45 s)
    for (const id of [].concat(b.do === "react" ? [] : b.who || [])) {
      const s = ctx.actors[id];
      if (!s?.down) continue;
      ctx.js(`KO("${s.p}", ${f2(start)}, false); tl.to("#${S}-ab-${id}", { rotation: 0, y: 0, scaleX: 1, scaleY: 1, transformOrigin: "50% 100%", duration: 0.4, ease: "back.out(2)" }, ${f2(start)}); BLINK("${s.p}", ${f2(start + 0.45)});`);
      s.down = false;
      start += 0.45;
    }
    let r;
    if (b.do === "enter") { ctx.actors[b.who] || die(`${key}: "${b.who}" không có trong cảnh`); ctx.actors[b.who].visible = true; }
    if (b.do === "attack") {
      ctx.lastAttacker = b.who;
      if (sc.beats[j + 1]?.do !== "react") console.warn(`build: CẢNH BÁO ${key}: attack không có react ngay sau → nạn nhân đứng im, không ngã`);
    }
    // lời đọc của beat (vo; card không có vo thì đọc chữ trên thẻ). Card giữ trên màn hình đủ lâu theo giọng (voDur).
    const vo = voOf(b), v = vo && ctx.voice ? ctx.voice(vo) : null;
    const bx = v && b.do === "card" ? { ...b, voDur: v.dur } : b;
    if (BUILTIN[b.do]) r = BUILTIN[b.do](ctx, bx, start);
    else if (String(b.do).startsWith("local:")) r = runFx(ctx, key, "local", bx, start);
    else if (PLANNED.includes(b.do)) r = runFx(ctx, key, b.do, bx, start);
    else die(`${key}: beat "${b.do}" không có (say|wait|pose|move|face|emote|${PLANNED.join("|")}|local:<tên>)`);
    r ||= { dur: 1 };
    if (vo && ctx.voice) {
      if (v) { base.voiceList.push({ file: v.file, t: start + 0.1, dur: v.dur }); r = { ...r, dur: Math.max(r.dur || 0, v.dur + 0.4) }; }
      else base.voiceMiss.push(vo);
    }
    lastHit = b.do === "attack" ? r.hit ?? start + r.dur * 0.6 : null;
    prevStart = start;
    lastEnd = Math.max(lastEnd, start + (r.dur || 0));
    base.beatsLog.push({ key, do: b.do, t: start, dur: r.dur });
  });
  ctx.t1 = lastEnd + TAIL;
  ctx.curKey = `${S}.cam`;
  // bối cảnh + máy quay + diễn viên thở/chớp mắt
  const set = SETS[sc.set](ctx, { time: sc.time || undefined });
  ctx.L.bg.unshift(set.html);
  ctx.js(set.js);
  if (sc.weather) {
    const w = (WEATHER[sc.weather] || die(`scenes[${i}].weather "${sc.weather}" không có (có: ${Object.keys(WEATHER).join(", ")})`))(ctx);
    ctx.L.fx.unshift(w.html);
    ctx.js(w.js);
  }
  if (sc.stage) {
    const st = (STAGES[sc.stage] || die(`scenes[${i}].stage "${sc.stage}" không có (có: ${Object.keys(STAGES).join(", ")})`))(ctx);
    ctx.stage = st;
    if (st.hud) ctx.L.hud.unshift(st.hud);
  }
  runFx(ctx, `${S}.cam`, "camera", {}, t0);
  for (const s of Object.values(ctx.actors)) {
    const per = 1.1 + ctx.rnd() * 0.6;
    if (V2) ctx.js(`BREATH("${s.p}", ${f2(t0)}, ${f2(ctx.t1)}, 0.022, ${f2(per)}); SWAY("${s.p}-hairB", ${f2(t0)}, ${f2(ctx.t1)}, 7, 0.9); SWAY("${s.p}-tail", ${f2(t0)}, ${f2(ctx.t1)}, 12, 0.7); SWAY("${s.p}-flapB", ${f2(t0)}, ${f2(ctx.t1)}, 4, 1.1);`);
    else ctx.js(`tl.to("#${s.p}-all", { scaleY: 1.018, svgOrigin: PIV.${s.type}.all, duration: ${f2(per)}, yoyo: true, repeat: ${Math.ceil((ctx.t1 - t0) / per)}, ease: "sine.inOut" }, ${f2(t0)});`);
    for (let bt = t0 + ctx.range(0.8, 2); bt < ctx.t1 - 0.3; bt += ctx.range(2.2, 3.8)) ctx.js(`BLINK("${s.p}", ${f2(bt)});`);
  }
  return { ctx, dur: ctx.t1 - t0 };
}

function buildSpecial(base, S, key, cat, payload, t0) {
  const ctx = makeCtx(base, S, t0);
  ctx.curKey = key;
  const r = runFx(ctx, key, cat, payload, t0);
  ctx.t1 = t0 + r.dur;
  return { ctx, dur: r.dur };
}

// ---------------------------------------------------------------- page shell
const CSS = `@font-face { font-family: "Inter"; src: url("assets/fonts/Inter-Variable.ttf") format("truetype"); font-weight: 100 900; font-display: block; }
@font-face { font-family: "Space Grotesk"; src: url("assets/fonts/Space_Grotesk-Variable.ttf") format("truetype"); font-weight: 300 700; font-display: block; }
* { margin: 0; padding: 0; box-sizing: border-box; }
html, body { overflow: hidden; background: #000; }
#root { position: relative; overflow: hidden; background: #000; font-family: "Space Grotesk", sans-serif; }
.fill { position: absolute; left: 0; top: 0; width: 1920px; height: 1080px; }
.chip { display: inline-block; background: #fff; border: 5px solid #111; box-shadow: 8px 8px 0 #111; padding: 14px 34px 10px; font: 700 46px "Space Grotesk"; color: #111; }
.paper { background-color: #F1E3C6; background-image: radial-gradient(circle at 20% 20%, rgba(255,255,255,.35), transparent 40%), radial-gradient(rgba(120,80,30,.08) 1.5px, transparent 1.5px); background-size: auto, 22px 22px; }
.plq { display: inline-block; background: #8A2A1E; color: #fff; font: 700 58px "Space Grotesk"; padding: 16px 34px 10px; border: 6px solid #3B2A1A; border-radius: 12px; box-shadow: 0 0 0 5px #E3A21A, 10px 10px 0 5px rgba(0,0,0,.35); white-space: nowrap; }
.nameplate { display: inline-block; background: #111; color: #FFD23F; font: 700 54px "Space Grotesk"; padding: 12px 30px 8px; border: 5px solid #FFD23F; border-radius: 10px; white-space: nowrap; }
.nametag { display: inline-block; margin-top: 10px; background: #FFFAF0; color: #8A2A1E; font: 700 32px "Space Grotesk"; padding: 8px 20px 4px; border: 4px solid #111; border-radius: 8px; white-space: nowrap; }`;

function page({ id, w, h, dur, body, code, RIG, seed }) {
  const rt = V2
    ? `const RIG = ${JSON.stringify(RIG)}; const SEED = ${seed}; const JPOS = ${JSON.stringify(JPOS)}; const EXPRS = ${JSON.stringify(EXPRS)}; const POSES2 = ${JSON.stringify(POSES2)};
${readFileSync(join(SKILL, "engine/runtime2.js"), "utf8")}
${readFileSync(join(SKILL, "engine/compat2.js"), "utf8")}
${code}
__FLUSH();`
    : `const RIG = ${JSON.stringify(RIG)}; const SEED = ${seed};
${readFileSync(join(SKILL, "engine/runtime.js"), "utf8")}
${code}`;
  return `<!doctype html>
<html lang="vi"><head><meta charset="UTF-8" />
<meta name="viewport" content="width=${w}, height=${h}" />
<script src="${GSAP_SRC}"></script>
<style>${CSS}
html, body, #root { width: ${w}px; height: ${h}px; }</style></head>
<body>
<div id="root" data-composition-id="${id}" data-start="0" data-duration="${f2(dur)}" data-width="${w}" data-height="${h}">
${body}
</div>
<script>
${rt}
</script>
</body></html>`;
}

// tap.bgm: tên file trong <dir>/, <dir>/assets/bgm/ hoặc kit/bgm/ (không đặt = nhạc mặc định)
function resolveBgm(dir, tap) {
  if (!tap.bgm) return { ...BGM, src: join(KIT, "bgm", BGM.file) };
  const src = [join(dir, tap.bgm), join(dir, "assets/bgm", tap.bgm), join(KIT, "bgm", tap.bgm)].find((p) => existsSync(p));
  if (!src) die(`bgm "${tap.bgm}" không thấy trong ${dir}, ${dir}/assets/bgm hay kit/bgm (có: ${readdirSync(join(KIT, "bgm")).join(", ")})`);
  let len;
  try { len = parseFloat(execFileSync("ffprobe", ["-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", src], { encoding: "utf8" })); } catch { die(`bgm: ffprobe không đọc được ${src}`); }
  if (!(len > 1)) die(`bgm: ${src} dài ${len}s?`);
  return { file: basename(src), src, len: Math.floor(len * 100) / 100 };
}

function copyAssets(dir, bgm = { ...BGM, src: join(KIT, "bgm", BGM.file) }) {
  for (const sub of ["fonts", "sfx", "bgm"]) mkdirSync(join(dir, "assets", sub), { recursive: true });
  for (const f of ["Inter-Variable.ttf", "Space_Grotesk-Variable.ttf"]) copyFileSync(join(KIT, "fonts", f), join(dir, "assets/fonts", f));
  for (const n of Object.keys(SFX_LEN)) copyFileSync(join(KIT, "sfx", `lib-${n}.mp3`), join(dir, "assets/sfx", `lib-${n}.mp3`));
  if (resolve(bgm.src) !== resolve(join(dir, "assets/bgm", bgm.file))) copyFileSync(bgm.src, join(dir, "assets/bgm", bgm.file));
  copyGsap(dir);
  const slug = basename(dir);
  if (!existsSync(join(dir, "package.json"))) writeFileSync(join(dir, "package.json"), JSON.stringify({ name: slug, private: true, type: "module" }, null, 2));
  if (!existsSync(join(dir, "hyperframes.json"))) writeFileSync(join(dir, "hyperframes.json"), JSON.stringify({ $schema: "https://hyperframes.heygen.com/schema/hyperframes.json", paths: { blocks: "compositions", components: "compositions/components", assets: "assets" }, media: { autoProxy: true } }, null, 2));
}

// giọng Tèo: wav trong <dir>/voice/, 2 track xen kẽ (14/15) cho khỏi chồng nhau
function voiceTags(list, total) {
  return list.filter((v) => v.t < total - 0.05).map((v, i) => `<audio id="vo${i}" src="${v.file}" data-start="${f2(v.t)}" data-duration="${f2(Math.min(v.dur, total - v.t))}" data-track-index="${14 + (i % 2)}" data-volume="1"></audio>`).join("\n");
}

function audioTags(sfx, total, bgmVol, bgm = BGM, segs = null) {
  const tracks = []; // greedy: không cho 2 âm thanh chồng nhau trên cùng một track
  const out = [];
  sfx.filter((s) => s.t < total - 0.05).sort((a, b) => a.t - b.t).forEach((s, i) => {
    const len = SFX_LEN[s.name] || die(`sfx "${s.name}" không có`);
    const d = Math.min(s.dur ?? len, len, total - s.t);
    let k = tracks.findIndex((end) => end <= s.t);
    if (k < 0) { k = tracks.length; tracks.push(0); }
    tracks[k] = s.t + d + 0.01;
    out.push(`<audio id="sx${i}" src="assets/sfx/lib-${s.name}.mp3" data-start="${f2(Math.max(0, s.t))}" data-duration="${f2(d)}" data-track-index="${20 + k}" data-volume="${f2(s.vol)}"></audio>`);
  });
  if (!segs) for (let k = 0, t = 0; t < total - 0.1; k++, t += bgm.len) out.push(`<audio id="bgm${k}" src="assets/bgm/${bgm.file}" data-start="${f2(t)}" data-duration="${f2(Math.min(bgm.len, total - t))}" data-track-index="${12 + (k % 2)}" data-volume="${bgmVol}"></audio>`);
  else {
    // nhạc liền mạch theo đồng hồ tổng (vị trí trong bài = t % len), chỉ đổi âm lượng theo cảnh; "off" = im hẳn
    let k = 0;
    for (const g of segs) {
      const vol = bgmVol * MUSIC[g.level];
      for (let t = g.t0; vol > 0 && t < Math.min(g.t1, total) - 0.05; ) {
        const p = t % bgm.len, d = Math.min(bgm.len - p, g.t1 - t, total - t);
        out.push(`<audio id="bgm${k}" src="assets/bgm/${bgm.file}" data-start="${f2(t)}" data-duration="${f2(d)}"${p > 0.01 ? ` data-media-start="${f2(p)}"` : ""} data-track-index="${12 + (k % 2)}" data-volume="${f2(vol)}"></audio>`);
        k++; t += d;
      }
    }
  }
  return out.join("\n");
}

// ---------------------------------------------------------------- thumbnail (1280×720, chụp bằng hyperframes snapshot)
function buildThumb(dir, tap, cast, theme, seed) {
  const td = join(dir, "thumb");
  mkdirSync(td, { recursive: true });
  const rnd = mulberry(seed + 99);
  // thumb.vs: [idTrái, idPhải] → ảnh đối đầu hai nhân vật + huy hiệu VS; không có thì Tèo + đối thủ
  // thumb.layout: "vs" (mặc định, đối đầu) | "solo" (1 nhân vật thumb.who to bên phải, chữ trái) | "center" (nhân vật giữa, chữ trên căn giữa)
  const lay = tap.thumb?.layout || "vs", one = lay !== "vs";
  if (!["vs", "solo", "center"].includes(lay)) die(`thumb.layout "${lay}" không có (vs | solo | center)`);
  if (tap.thumb?.who && !cast[tap.thumb.who]) die(`thumb.who "${tap.thumb.who}" không có trong cast`);
  if (tap.thumb?.set && !SETS[tap.thumb.set]) die(`thumb.set "${tap.thumb.set}" không có (có: ${Object.keys(SETS).join(", ")})`);
  const vs = one ? null : tap.thumb?.vs;
  if (vs && (vs.length !== 2 || !vs.every((id) => cast[id]))) die(`thumb.vs phải là 2 id có trong cast (đang là ${JSON.stringify(vs)})`);
  const sc = (vs && tap.scenes.find((s) => vs.every((id) => (s.actors || []).some((a) => a.id === id)))) || tap.scenes.find((s) => (s.actors || []).some((a) => cast[a.id]?.side === "foe")) || tap.scenes[0];
  const ctx = { S: "th", t0: 0, t1: 1, rnd, range: (a, b) => a + rnd() * (b - a), pick: (arr) => arr[Math.floor(rnd() * arr.length)] };
  const set = SETS[tap.thumb?.set || sc.set](ctx, { time: tap.thumb?.time || sc.time || undefined });
  const hero = one && tap.thumb?.who ? cast[tap.thumb.who] : vs ? cast[vs[0]] : Object.values(cast).find((c) => c.kind === "teo") || Object.values(cast)[0];
  const foe = one ? null : vs ? cast[vs[1]] : (sc.actors || []).map((a) => cast[a.id]).find((c) => c && c.side === "foe") || Object.values(cast).find((c) => c.side === "foe");
  const RIG = { thH: hero.kind, thF: foe?.kind || "npc" };
  const hook = tap.thumb?.text || tap.hook || tap.title;
  const heroW = vs ? (hero.kind === "teo" ? 470 : 430) : hero.kind === "teo" ? 560 : 460, foeW = foe ? (vs ? (foe.kind === "teo" ? 470 : 430) : foe.kind === "teo" ? 470 : 400) : 0;
  let heroX = vs ? 400 : 640, foeX = vs ? 1520 : 1480, glow = vs ? "50% 55%" : "34% 62%", heroW2 = heroW;
  if (lay === "solo") { heroX = 1490; heroW2 = hero.kind === "teo" ? 640 : 560; glow = "76% 60%"; }
  if (lay === "center") { heroX = 960; heroW2 = hero.kind === "teo" ? 600 : 520; glow = "50% 66%"; }
  const txt = lay === "solo" ? `left:36px;top:150px;width:700px;font:700 ${[...hook].length > 14 ? 96 : 124}px/1.02 'Space Grotesk'` : lay === "center" ? `left:40px;top:96px;width:1200px;text-align:center;font:700 ${[...hook].length > 18 ? 84 : 104}px/1.0 'Space Grotesk'` : `left:36px;top:26px;width:1000px;font:700 ${[...hook].length > 14 ? 92 : 118}px/1.0 'Space Grotesk'`;
  const body = `<div id="th" class="clip" data-start="0" data-duration="1" data-track-index="0" style="position:absolute;left:0;top:0;width:1280px;height:720px;overflow:hidden">
<div style="position:absolute;left:0;top:0;width:1920px;height:1080px;transform:scale(.6667);transform-origin:0 0">${set.html}
<div class="fill" style="background:radial-gradient(circle at ${glow}, ${theme.qi}cc 0%, ${theme.qi}55 22%, transparent 45%), linear-gradient(rgba(0,0,0,.25), rgba(0,0,0,0) 40%)"></div>
<div style="position:absolute;left:-540px;top:-960px;width:3000px;height:3000px;background:repeating-conic-gradient(from 0deg at ${glow}, rgba(255,255,255,.18) 0deg 1.5deg, transparent 1.5deg 9deg)"></div>
${foe ? `<div style="position:absolute;left:${foeX - foeW / 2}px;top:${1080 + 30 - rigH(foe.kind, foeW)}px"><div style="transform:scaleX(-1)">${rigSvg(foe.kind, "thF", foeW, foe.look)}</div></div>` : ""}
<div style="position:absolute;left:${heroX - heroW2 / 2}px;top:${1080 + (vs ? 30 : 60) - rigH(hero.kind, heroW2)}px;filter:drop-shadow(0 0 30px ${theme.qi})">${rigSvg(hero.kind, "thH", heroW2, hero.look)}</div>
</div>
<div style="position:absolute;${txt};color:${theme.title === "#FFFFFF" ? "#FFE45C" : theme.title};-webkit-text-stroke:12px #111;paint-order:stroke fill;text-shadow:8px 8px 0 #111;text-transform:uppercase">${esc(hook)}</div>
<div style="position:absolute;${lay === "center" ? "left:30px" : "right:30px"};top:${lay === "center" ? 600 : 30}px;background:#C8372D;color:#F6EFE0;border:6px solid #F6EFE0;border-radius:14px;padding:10px 20px 4px;font:700 46px 'Space Grotesk';box-shadow:6px 6px 0 #111">TẬP ${esc(tap.ep ?? 1)}</div>
<div style="position:absolute;${lay === "vs" ? "right" : "left"}:30px;${vs ? "top:112px" : lay === "center" ? "top:24px" : "bottom:26px"};background:#FFD23F;color:#111;border:5px solid #111;border-radius:40px;padding:8px 22px 4px;font:700 34px 'Space Grotesk'">Tèo Kể · Kiếm Hiệp</div>
${vs ? `<div style="position:absolute;left:540px;top:330px;width:200px;height:200px;border-radius:50%;background:#C8372D;border:9px solid #FFE45C;box-shadow:0 0 0 7px #111,0 0 50px ${theme.qi};text-align:center;font:700 112px/182px 'Space Grotesk';color:#FFE45C;-webkit-text-stroke:7px #111;paint-order:stroke fill;transform:rotate(-8deg)">VS</div>
${[[hero, 267], [foe, 1013]].map(([c, x]) => `<div style="position:absolute;left:${x - 250}px;bottom:24px;width:500px;text-align:center"><span style="display:inline-block;background:#111;color:#FFD23F;font:700 46px 'Space Grotesk';padding:8px 24px 4px;border:5px solid #FFD23F;border-radius:10px;white-space:nowrap">${esc(c.name)}</span></div>`).join("")}` : ""}
</div>`;
  const code = `POSE("thH", "${tap.thumb?.pose || (vs ? "palm" : "raise")}", 0, 0.01); BROW("thH", 0, true);${foe ? ` POSE("thF", "${vs ? tap.thumb?.pose2 || "guard" : "guard"}", 0, 0.01); BROW("thF", 0, true);` : ""} tl.set({}, {}, 1);`;
  // snapshot chỉ phục vụ file bên trong thư mục dự án → thumb/ có bản font riêng
  mkdirSync(join(td, "assets/fonts"), { recursive: true });
  for (const f of ["Inter-Variable.ttf", "Space_Grotesk-Variable.ttf"]) copyFileSync(join(KIT, "fonts", f), join(td, "assets/fonts", f));
  copyGsap(td);
  writeFileSync(join(td, "index.html"), page({ id: "thumb", w: 1280, h: 720, dur: 1, body, code, RIG, seed }));
  writeFileSync(join(td, "package.json"), JSON.stringify({ name: basename(dir) + "-thumb", private: true, type: "module" }, null, 2));
  writeFileSync(join(td, "hyperframes.json"), JSON.stringify({ $schema: "https://hyperframes.heygen.com/schema/hyperframes.json", paths: { blocks: "compositions", components: "compositions/components", assets: "assets" }, media: { autoProxy: true } }, null, 2));
}

// scenes[].music: on | low | up | off → đoạn nhạc [t0,t1,level]; opener/ender luôn "on". null = kiểu cũ (lặp nguyên bài)
function musicSegs(tap, cuts, total) {
  if (!tap.scenes.some((sc) => sc.music && sc.music !== "on")) return null;
  const raw = [{ t0: 0, t1: cuts[0], level: "on" }, ...tap.scenes.map((sc, i) => ({ t0: cuts[i], t1: cuts[i + 1], level: sc.music || "on" })), { t0: cuts[cuts.length - 1], t1: total, level: "on" }];
  const out = [];
  for (const g of raw) { const last = out[out.length - 1]; if (last && last.level === g.level) last.t1 = g.t1; else out.push({ ...g }); }
  return out;
}

// ---------------------------------------------------------------- main
export async function build(dir, opts = {}) {
  dir = resolve(dir);
  if (!existsSync(join(dir, "tap.json"))) die(`${dir}: thiếu tap.json`);
  const tap = JSON.parse(readFileSync(join(dir, "tap.json"), "utf8"));
  const rig = opts.rig ?? tap.rig ?? 1;
  if (![1, 2].includes(+rig)) die(`rig "${rig}" không có (1 | 2)`);
  V2 = +rig === 2; HEAD = V2 ? HEAD2 : HEAD1;
  VE = existsSync(join(dir, "ve.mjs")) ? await loadVe(join(dir, "ve.mjs")) : null;
  if (VE && !V2) die("ve.mjs (mặt riêng của tập) chỉ chạy với rig 2 — thêm \"rig\": 2 vào tap.json");
  // --ve-check: chỉ kiểm mặt riêng (nhóm bắt buộc + chống trùng, ghi work/ve-fp.json), không dựng index.html
  if (opts.veCheck) { if (!VE) die(`${dir}: thiếu ve.mjs`); await checkVe(dir, castOf(tap)); console.log(`ve.mjs OK · ${Object.keys(tap.cast || {}).length} nhân vật`); return null; }
  if (!Array.isArray(tap.scenes) || !tap.scenes.length) die("tap.json: cần ít nhất 1 cảnh trong scenes");
  const lib = await loadLibrary(dir);
  const plan = await makePlan(dir, opts);
  const theme = lib.THEMES[plan.theme] || die(`theme "${plan.theme}" không có`);
  const rnd = mulberry(plan.seed);
  const cast = castOf(tap);
  if (VE) await checkVe(dir, cast);
  const base = {
    v2: V2, plan, lib, theme, cast, rnd, range: (a, b) => a + rnd() * (b - a), pick: (arr) => arr[Math.floor(rnd() * arr.length)],
    RIG: {}, code: [], over: [], sfxList: [], used: [], beatsLog: [], n: 0,
    voice: loadVoice(dir, tap.voice), voiceList: [], voiceMiss: [],
  };
  if (tap.bubble) { if (!BUBBLE[tap.bubble]) die(`bubble "${tap.bubble}" không có (có: ${Object.keys(BUBBLE).join(", ")})`); base.bubble = tap.bubble; }
  const bgm = resolveBgm(dir, tap);
  base.sfx = (name, t, vol = 0.4, dur) => base.sfxList.push({ name, t, vol, dur });

  const clips = [];
  let t = 0, track = 0, z = 1;
  const op = buildSpecial(base, "op", "op", "opener", { title: tap.opener?.title || "TÈO KIẾM HIỆP", sub: tap.opener?.sub || `Tập ${tap.ep ?? 1}: ${tap.title}` }, t);
  clips.push(sceneClip(op.ctx, t, op.dur, track++, z++));
  const cuts = [];
  t += op.dur;
  tap.scenes.forEach((sc, i) => {
    cuts.push(t);
    const s = buildScene(base, sc, i, t);
    clips.push(sceneClip(s.ctx, t, s.dur, track++, z++));
    t += s.dur;
  });
  cuts.push(t);
  const ed = buildSpecial(base, "ed", "ed", "ender", { ep: tap.ep ?? 1, next: tap.ender?.next || tap.next || "Còn tiếp…" }, t);
  clips.push(sceneClip(ed.ctx, t, ed.dur, track++, z++));
  t += ed.dur;
  const total = t;
  // chuyển cảnh (lớp phủ toàn cục)
  cuts.forEach((c, k) => { const ctx = makeCtx(base, `tr${k}`, c); ctx.curKey = `tr${k}`; runFx(ctx, `tr${k}`, "transition", {}, c); });

  const local = base.used.filter((u) => u.id.startsWith("local:"));
  const body = `${clips.join("\n")}
<div id="T" class="clip fill" data-start="0" data-duration="${f2(total)}" data-track-index="${track++}" style="z-index:90;pointer-events:none">${base.over.join("\n")}</div>
<div id="X" class="clip fill" data-start="0" data-duration="${f2(total)}" data-track-index="${track++}" style="z-index:99;pointer-events:none"><div id="X-flash" class="fill" style="background:#fff;opacity:0"></div><div id="X-black" class="fill" style="background:#000;opacity:0"></div></div>
${audioTags(base.sfxList, total, tap.bgm_volume ?? (base.voice ? 0.06 : 0.1), bgm, musicSegs(tap, cuts, total))}
${voiceTags(base.voiceList, total)}`;
  copyAssets(dir, bgm);
  writeFileSync(join(dir, "index.html"), page({ id: "main", w: 1920, h: 1080, dur: total, body, code: base.code.join("\n"), RIG: base.RIG, seed: plan.seed }));
  buildThumb(dir, tap, cast, theme, plan.seed);
  const timeline = { total, cuts, beats: base.beatsLog, used: base.used, theme: plan.theme,
    ...(tap.bgm || tap.bubble || tap.scenes.some((x) => x.stage || x.weather || x.music) ? { look: { bgm: bgm.file, bubble: tap.bubble || null, scenes: tap.scenes.map((x) => [x.set, x.time || "", x.stage || "", x.weather || "", x.music || "on"].join("|")) } } : {}),
    voice: base.voice ? { name: base.voice.voice, lines: base.voiceList.length, sec: Math.round(base.voiceList.reduce((x, v) => x + v.dur, 0)), missing: base.voiceMiss.length } : null };
  mkdirSync(join(dir, "work"), { recursive: true });
  writeFileSync(join(dir, "work/timeline.json"), JSON.stringify(timeline, null, 1));
  if (!opts.quiet) {
    printPlan(plan, lib);
    console.log(`build: ${basename(dir)}/index.html · ${f2(total)} s · ${tap.scenes.length} cảnh · ${base.sfxList.length} sfx · hiệu ứng tự chế: ${local.length ? [...new Set(local.map((u) => u.id))].join(", ") : "KHÔNG CÓ"}`);
    if (V2) console.log(`build: rig 2 (engine/rig2.mjs + compat2.js)${VE ? " · mặt riêng ve.mjs" : ""}`);
    if (V2 && !VE) console.warn("build: CẢNH BÁO — tập chưa có ve.mjs: nhân vật dùng mặt chung của engine. Mỗi tập phải tự vẽ mắt/mũi/khuôn mặt (SKILL.md \"Mặt riêng từng tập\")");
    if (base.voice) console.log(`build: giọng ${base.voice.voice} · ${base.voiceList.length} câu · ${f2(base.voiceList.reduce((a, v) => a + v.dur, 0))} s`);
    else console.warn("build: CẢNH BÁO chưa có giọng đọc — chạy scripts/voice.mjs <dir> trước rồi build lại");
    if (base.voiceMiss.length) console.warn(`build: CẢNH BÁO ${base.voiceMiss.length} câu chưa có giọng (sửa chữ sau khi chạy voice.mjs) — chạy lại voice.mjs: ${base.voiceMiss.slice(0, 3).map((x) => JSON.stringify(x)).join(", ")}`);
    if (total < 1200) console.warn(`build: CẢNH BÁO tổng ${(total / 60).toFixed(1)} phút < 20 phút — pack.mjs sẽ từ chối (examples/tap-01 là mẫu ngắn, được phép)`);
    if (printSlow(readFileSync(join(dir, "index.html"), "utf8"), (m) => console.warn("build: " + m))) console.warn("build: CẢNH BÁO — có mẫu làm hyperframes bỏ chụp nhanh, render chậm gấp đôi. Sửa fx/*.mjs của tập theo SKILL.md \"Tốc độ render\"");
    if (!local.length) console.warn("build: CẢNH BÁO — tập này chưa có hiệu ứng tự chế (fx/*.mjs + beat \"local:<tên>\" hoặc \"fx\":\"local:<tên>\"). pack.mjs sẽ từ chối đóng gói.");
  }
  return { total, plan, timeline };
}

if (import.meta.url === pathToFileURL(process.argv[1]).href) {
  const args = process.argv.slice(2);
  const dir = args.find((a) => !a.startsWith("--") && !/^\d+$/.test(a)) || die("dùng: node build.mjs <dir> [--replan] [--seed N] [--rig 1|2] [--ve-check]");
  const si = args.indexOf("--seed"), ri = args.indexOf("--rig");
  await build(dir, { replan: args.includes("--replan"), quiet: args.includes("--quiet"), veCheck: args.includes("--ve-check"), seed: si >= 0 ? Number(args[si + 1]) : null, rig: ri >= 0 ? Number(args[ri + 1]) : undefined });
}
