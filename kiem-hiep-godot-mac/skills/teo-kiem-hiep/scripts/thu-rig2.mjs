// Lát cắt thử rig v2: node scripts/thu-rig2.mjs <dir có doan.json> <dir tập gốc có voice/ + assets/>
// Đọc kịch bản dựng khai báo doan.json → index.html (1 clip) bằng rig2 + moves2 + runtime2. In số đo: % thời gian có
// động tác thân, số tween bị bỏ vì chồng, số dòng lời.
import { readFileSync, writeFileSync, mkdirSync, existsSync, copyFileSync, readdirSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { figure, PRESETS, JPOS, EXPRS, FEET } from "../engine/rig2.mjs";
import { Mover, MOVES, POSES } from "../engine/moves2.mjs";
import { SETS, GROUND } from "../engine/sets.mjs";
import { loadVoice } from "../engine/voice.mjs";

const SKILL = dirname(dirname(fileURLToPath(import.meta.url)));
const [dir, srcDir] = process.argv.slice(2).map((p) => p.replace(/[\\/]+$/, ""));
if (!dir || !srcDir) { console.error("dùng: thu-rig2.mjs <dir> <dir tập gốc>"); process.exit(1); }
const D = JSON.parse(readFileSync(join(dir, "doan.json"), "utf8"));
const f2 = (x) => +(+x).toFixed(2);
const mulberry = (a) => () => { a |= 0; a = (a + 0x6d2b79f5) | 0; let t = Math.imul(a ^ (a >>> 15), 1 | a); t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t; return ((t ^ (t >>> 14)) >>> 0) / 4294967296; };
const rnd = mulberry(D.seed || 1);
const W = 1920, H = 1080, S = "s";

// ---------------------------------------------------------------- tài sản
for (const sub of ["assets/fonts", "assets/sfx", "assets/bgm", "voice"]) mkdirSync(join(dir, sub), { recursive: true });
copyFileSync(join(srcDir, "assets/gsap.min.js"), join(dir, "assets/gsap.min.js"));
for (const sub of ["assets/fonts", "assets/sfx", "assets/bgm"]) for (const f of readdirSync(join(srcDir, sub))) copyFileSync(join(srcDir, sub, f), join(dir, sub, f));
if (existsSync(join(srcDir, "hyperframes.json"))) copyFileSync(join(srcDir, "hyperframes.json"), join(dir, "hyperframes.json"));
const voice = loadVoice(srcDir);

// ---------------------------------------------------------------- diễn viên
const cast = {};
for (const [id, c] of Object.entries(D.cast)) {
  const look = { ...(PRESETS[c.preset] || {}), ...c };
  const w = c.w || 240, h = Math.round((w * 620) / 400), feet = FEET / 620;
  cast[id] = { id, look, w, h, x: c.x, x0: c.x, face: c.face || "right", top: GROUND - h * feet, html: figure(id, w, look) };
}
const actorDiv = (a) => `<div id="${S}-a-${a.id}" style="position:absolute;left:${f2(a.x0 - a.w / 2)}px;top:${f2(a.top)}px;width:${a.w}px;height:${a.h}px"><div style="width:${a.w}px;height:${a.h}px;transform:scaleX(${a.face === "left" ? -1 : 1})">${a.html}</div></div>`;

// ---------------------------------------------------------------- dựng theo kịch bản
const lines = [], audio = [], fxHtml = [], hudHtml = [];
const js = (s) => lines.push(s);
const warns = [];
const m = new Mover({ js, warn: (s) => warns.push(s), rnd });
let puffN = 0, trailN = 0, sfxN = 0, chipN = 0;
const puff = (x) => { const id = `${S}-pf${puffN++}`; fxHtml.push(`<div id="${id}" style="position:absolute;left:${f2(x - 40)}px;top:${GROUND - 34}px;width:80px;height:44px;border-radius:50%;background:radial-gradient(ellipse,rgba(255,255,255,.95),rgba(200,210,220,.5) 55%,rgba(200,210,220,0) 72%);opacity:0"></div>`); return id; };
const trail = (a) => { const id = `${S}-tr${trailN++}`, s = a.face === "left" ? -1 : 1, X = a.x, y0 = GROUND - a.h * 0.72; fxHtml.push(`<svg class="fill" viewBox="0 0 1920 1080" style="overflow:visible"><path id="${id}" d="M${f2(X - s * 150)} ${f2(y0 - 160)} Q${f2(X + s * 40)} ${f2(y0 - 230)} ${f2(X + s * 250)} ${f2(y0 + 40)} Q${f2(X + s * 300)} ${f2(y0 + 150)} ${f2(X + s * 240)} ${f2(GROUND - 30)}" fill="none" stroke="#F6FBFF" stroke-width="30" stroke-linecap="round" opacity="0"/></svg>`); return id; };
const sfx = (name, t, vol = 0.4, dur = 1.6) => audio.push(`<audio id="sx${sfxN++}" src="assets/sfx/lib-${name}.mp3" data-start="${f2(t)}" data-duration="${dur}" data-track-index="${20 + (sfxN % 4)}" data-volume="${vol}"></audio>`);
const motion = []; // [t0,t1] đoạn có động tác thân (không tính talk)
const stats = { vo: 0, voDur: 0 };
let t = 0.3, voN = 0;
const bodyAct = (who, name, at, o) => {
  const a = cast[who], d = MOVES[name](m, who, at, o);
  if (name !== "talk" && name !== "pose" && name !== "look") motion.push([at, at + d]);
  if (["walk", "jump", "heavy-slash"].includes(name)) a.x += o.dx || 0; // theo dõi vị trí màn để đặt bụi/vệt/camera
  if (name === "block-stagger") a.x += (o.n ?? 3) * (o.dx ?? -70);
  return d;
};
const camTo = (t0, c) => {
  let { s = 1, x = 0, y = 0, d = 1 } = c;
  if (c.focus) { const a = typeof c.focus === "string" ? cast[c.focus] : null; const px = a ? a.x : c.focus[0], py = a ? GROUND - a.h * 0.62 : c.focus[1]; x = 960 - ((px - 960) * s + 960); y = 560 - ((py - 540) * s + 540); }
  x = Math.max(-(s - 1) * 960, Math.min((s - 1) * 960, x)); y = Math.max(-(s - 1) * 540, Math.min((s - 1) * 540, y)); // không lộ mép đen
  js(`TO("#${S}-cam", ${f2(t0)}, ${f2(Math.max(d, 0.01))}, { scale: ${s}, x: ${f2(x)}, y: ${f2(y)} }, "power2.inOut");`);
};
for (const [i, sh] of D.shots.entries()) {
  const v = sh.vo ? voice?.(sh.vo) : null;
  if (sh.vo && !v) warns.push(`không có giọng: ${sh.vo.slice(0, 40)}`);
  const voDur = v ? v.dur : 0;
  if (v) { audio.push(`<audio id="vo${voN}" src="voice/${v.file.split("/").pop()}" data-start="${f2(t)}" data-duration="${f2(v.dur)}" data-track-index="${14 + (voN % 2)}" data-volume="1"></audio>`); copyFileSync(join(srcDir, v.file), join(dir, "voice", v.file.split("/").pop())); voN++; stats.vo++; stats.voDur += v.dur; }
  let end = t + Math.max(voDur + 0.45, sh.hold || 0);
  if (sh.cam) camTo(t, sh.cam);
  const speaker = sh.who || "teo";
  if (v) m.talk(speaker, t + 0.05, t + v.dur);
  for (const act of sh.acts || []) {
    const at = t + (act.at || 0);
    if (act.sfx) { sfx(act.sfx, at, act.vol); continue; }
    if (act.cam?.shake) { js(`SHAKE("#${S}-shake", ${f2(at)}, 0.35, ${act.cam.shake});`); continue; }
    if (act.flash) { js(`FLASH(${f2(at)}, ${act.flash.peak ?? 0.8}, 0.4);`); continue; }
    if (act.expr) { m.EX(act.who, at, act.expr); continue; }
    if (!act.do) continue;
    const a = cast[act.who], o = { ...act, sel: `#${S}-a-${act.who}` };
    delete o.who; delete o.do; delete o.at;
    if (act.do === "talk" && !o.dur) o.dur = Math.max(1, voDur - (act.at || 0));
    if (typeof o.dust === "number") o.dust = Array.from({ length: o.dust }, (_, k) => puff(a.x + (act.do === "block-stagger" ? (k + 1) * (o.dx ?? -70) : (o.dx ?? 0) + (k - 1) * 70)));
    if (o.trail === true) o.trail = trail({ ...a, x: a.x + (o.dx ?? 0) });
    if (o.shake) o.cam = `#${S}-shake`;
    if (act.do === "heavy-slash") o.dx = (o.dx ?? 120);
    const d = bodyAct(act.who, act.do, at, o);
    end = Math.max(end, at + d + 0.2);
  }
  if (sh.chip) { const id = `${S}-ch${chipN++}`; hudHtml.push(`<div id="${id}" class="chip" style="position:absolute;left:${sh.chip.x}px;top:${sh.chip.y}px;opacity:0">${sh.chip.text}</div>`); js(`POP("#${id}", ${f2(t + (sh.chip.at || 0))});`); js(`HIDE("#${id}", ${f2(end - 0.2)});`); }
  t = end;
}
const DUR = f2(t + 0.6);
for (const id of Object.keys(cast)) { m.ambient(id, 0, DUR); m.blinks(id, 0, DUR); }
// bgm
if (D.bgm) for (let k = 0, b = 0; b < DUR; k++, b += 67) audio.push(`<audio id="bgm${k}" src="assets/bgm/${D.bgm}" data-start="${b}" data-duration="${f2(Math.min(67, DUR - b))}" data-track-index="${12 + (k % 2)}" data-volume="0.06"></audio>`);

// ---------------------------------------------------------------- nền
const ctx = { S, t0: 0, t1: DUR, rnd, range: (a, b) => a + rnd() * (b - a), pick: (arr) => arr[Math.floor(rnd() * arr.length)] };
const set = SETS[D.set](ctx, { time: D.time || "ngay" });

// ---------------------------------------------------------------- trang
const CSS = `@font-face { font-family: "Inter"; src: url("assets/fonts/Inter-Variable.ttf") format("truetype"); font-weight: 100 900; font-display: block; }
@font-face { font-family: "Space Grotesk"; src: url("assets/fonts/Space_Grotesk-Variable.ttf") format("truetype"); font-weight: 300 700; font-display: block; }
* { margin: 0; padding: 0; box-sizing: border-box; }
html, body { overflow: hidden; background: #000; }
#root { position: relative; overflow: hidden; background: #000; font-family: "Space Grotesk", sans-serif; }
.fill { position: absolute; left: 0; top: 0; width: 1920px; height: 1080px; }
.chip { display: inline-block; background: #fff; border: 5px solid #111; box-shadow: 8px 8px 0 #111; padding: 14px 34px 10px; font: 700 46px "Space Grotesk"; color: #111; }
html, body, #root { width: ${W}px; height: ${H}px; }`;
const initial = Object.keys(cast).map((p) => `JS("${p}-wpF", 180); JS("${p}-wpB", 180);`).join(" ");
const html = `<!doctype html>
<html lang="vi"><head><meta charset="UTF-8" /><meta name="viewport" content="width=${W}, height=${H}" />
<script src="assets/gsap.min.js"></script><style>${CSS}</style></head>
<body>
<div id="root" data-composition-id="main" data-start="0" data-duration="${DUR}" data-width="${W}" data-height="${H}">
<div id="${S}" class="clip fill" data-start="0" data-duration="${DUR}" data-track-index="1" style="z-index:2;overflow:hidden">
<div id="${S}-shake" class="fill"><div id="${S}-cam" class="fill" style="transform-origin:50% 50%">
<div id="${S}-bg" class="fill">${set.html}</div>
<div id="${S}-act" class="fill">${Object.values(cast).map(actorDiv).join("\n")}</div>
<div id="${S}-fx" class="fill">${fxHtml.join("\n")}</div>
</div></div>
<div id="${S}-hud" class="fill">${hudHtml.join("\n")}</div>
<div id="X-flash" class="fill" style="background:#fff;opacity:0"></div>
</div>
${audio.join("\n")}
</div>
<script>
const JPOS = ${JSON.stringify(JPOS)}; const EXPRS = ${JSON.stringify(EXPRS)}; const SEED = ${D.seed || 1};
${readFileSync(join(SKILL, "engine/runtime2.js"), "utf8")}
${initial}
${set.js}
${lines.join("\n")}
</script>
</body></html>`;
writeFileSync(join(dir, "index.html"), html);

// ---------------------------------------------------------------- số đo
const merged = motion.sort((a, b) => a[0] - b[0]).reduce((acc, [a, b]) => { const L = acc[acc.length - 1]; if (L && a <= L[1]) L[1] = Math.max(L[1], b); else acc.push([a, b]); return acc; }, []);
const motionS = merged.reduce((s, [a, b]) => s + Math.min(b, DUR) - a, 0);
console.log(`index.html: ${DUR}s, ${D.shots.length} cảnh, ${stats.vo} câu (${f2(stats.voDur)}s lời), ${lines.length} lệnh, tween ok ${m.n.ok} / bỏ ${m.n.drop}`);
console.log(`động tác thân (không tính cử chỉ nói): ${f2(motionS)}s = ${Math.round((motionS / DUR) * 100)}% ; đứng nói thuần: ${Math.round(((DUR - motionS) / DUR) * 100)}%`);
if (warns.length) console.log("cảnh báo:\n  " + warns.slice(0, 30).join("\n  ") + (warns.length > 30 ? `\n  … +${warns.length - 30}` : ""));
