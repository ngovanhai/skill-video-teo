// Atmosphere: particles that fill the frame for the rest of the scene (or `d` seconds).
// Common options: at | t, d, n (count), color, opacity, layer ("over" default, "back" to sit behind).
import { rng, when, layer, reps, r3 } from "./_util.mjs";
import { isDark } from "../lib/base.mjs";

const darkBg = (ctx) => isDark(ctx.bg || ctx.scene.bg);

// generic particle field: make(i, R) -> { html, from, to, p (period s), ease, extra }
function field(ctx, o, def) {
  const { t, d, end } = when(ctx, o, 0);
  const R = rng(ctx.id);
  const n = o.n ?? def.n;
  const id = ctx.id;
  let html = "", js = `      FADE(q("#${id}"), ${t}, ${o.fade ?? 0.6});\n`;
  if (o.d != null) js += `      OUT(q("#${id}"), ${r3(Math.max(t + 0.3, end - 0.5))}, 0.5);\n`;
  for (let i = 0; i < n; i++) {
    const m = def.make(i, R);
    html += `<div class="${id}-p" style="position:absolute;${m.style}">${m.html || ""}</div>`;
    const p = r3(m.p);
    const start = r3(Math.max(0, t - R() * p));
    js += `      tl.fromTo(qa(".${id}-p")[${i}], ${JSON.stringify(m.from)}, Object.assign(${JSON.stringify(m.to)}, { duration: ${p}, ease: "${m.ease || "none"}", repeat: ${reps(end - start, p)}, immediateRender: false }), ${start});\n`;
  }
  return { [o.layer || "over"]: layer(id, html, `opacity:0;${o.opacity != null ? `filter:opacity(${o.opacity});` : ""}`), js };
}

const dust = { id: "dust", cat: "atmosphere", label: "Bụi sáng lơ lửng bay lên",
  run: (ctx, o) => field(ctx, o, { n: 34, make: (i, R) => {
    const s = r3(3 + R() * 7), c = o.color || (darkBg(ctx) ? "rgba(255,240,200,0.75)" : "rgba(60,40,10,0.35)");
    return { style: `left:${r3(R() * 1920)}px;top:${r3(R() * 1080)}px;width:${s}px;height:${s}px;border-radius:50%;background:${c};box-shadow:0 0 ${s * 2}px ${c};`,
      from: { y: 0, x: 0, opacity: 0 }, to: { y: -(120 + R() * 160), x: (R() - 0.5) * 120, opacity: 1, yoyo: false }, p: 5 + R() * 5, ease: "sine.inOut" };
  } }) };

const rain = { id: "rain", cat: "atmosphere", label: "Mưa xiên (heavy: true cho mưa to)",
  run: (ctx, o) => field(ctx, o, { n: o.heavy ? 110 : 70, make: (i, R) => {
    const h = r3(40 + R() * 50), c = o.color || "rgba(200,225,255,0.7)";
    return { style: `left:${r3(R() * 2300 - 200)}px;top:-160px;width:3px;height:${h}px;border-radius:2px;background:${c};transform:rotate(14deg);`,
      from: { y: 0, x: 0 }, to: { y: 1300, x: -320 }, p: (o.heavy ? 0.45 : 0.7) + R() * 0.35 };
  } }) };

const snow = { id: "snow", cat: "atmosphere", label: "Tuyết rơi lắc lư",
  run: (ctx, o) => field(ctx, o, { n: 60, make: (i, R) => {
    const s = r3(5 + R() * 10);
    return { style: `left:${r3(R() * 1920)}px;top:-30px;width:${s}px;height:${s}px;border-radius:50%;background:${o.color || (darkBg(ctx) ? "#fff" : "#E4F0FB")};${darkBg(ctx) ? "box-shadow:0 0 6px rgba(255,255,255,0.8);" : "border:2px solid #7FA3C6;"}`,
      from: { y: 0, x: 0 }, to: { y: 1140, x: (R() - 0.5) * 260 }, p: 7 + R() * 6, ease: "sine.inOut" };
  } }) };

const embers = { id: "embers", cat: "atmosphere", label: "Tàn lửa đỏ cam bay lên",
  run: (ctx, o) => field(ctx, o, { n: 42, make: (i, R) => {
    const s = r3(4 + R() * 6), c = ["#FFB347", "#FF6A2B", "#FFD36B"][i % 3];
    return { style: `left:${r3(R() * 1920)}px;top:1100px;width:${s}px;height:${s}px;border-radius:50%;background:${c};box-shadow:0 0 ${s * 3}px ${c};`,
      from: { y: 0, x: 0, opacity: 1 }, to: { y: -(900 + R() * 400), x: (R() - 0.5) * 300, opacity: 0 }, p: 3 + R() * 3, ease: "power1.out" };
  } }) };

const bubbles = { id: "bubbles", cat: "atmosphere", label: "Bong bóng nước nổi lên (cảnh biển, sông)",
  run: (ctx, o) => field(ctx, o, { n: 30, make: (i, R) => {
    const s = r3(10 + R() * 34);
    return { style: `left:${r3(R() * 1920)}px;top:1110px;width:${s}px;height:${s}px;border-radius:50%;border:3px solid ${o.color || (darkBg(ctx) ? "rgba(255,255,255,0.8)" : "rgba(50,110,170,0.65)")};background:radial-gradient(circle at 30% 30%, rgba(255,255,255,0.6), transparent 45%);`,
      from: { y: 0, x: 0 }, to: { y: -1250, x: (R() - 0.5) * 140 }, p: 4 + R() * 4, ease: "sine.in" };
  } }) };

const STAR = (c) => `<svg viewBox="-10 -10 20 20" style="width:100%;height:100%;overflow:visible"><path d="M0 -10 L2.2 -2.2 L10 0 L2.2 2.2 L0 10 L-2.2 2.2 L-10 0 L-2.2 -2.2 Z" fill="${c}"/></svg>`;
const twinkle = { id: "twinkle", cat: "atmosphere", label: "Sao lấp lánh nhấp nháy",
  run: (ctx, o) => field(ctx, o, { n: o.n ?? 36, make: (i, R) => {
    const s = r3(14 + R() * 26), c = o.color || (i % 4 ? "#FFF6C8" : "#F7CB46");
    return { style: `left:${r3(R() * 1880)}px;top:${r3(R() * 840)}px;width:${s}px;height:${s}px;transform:scale(0);`, html: STAR(c),
      from: { scale: 0, rotation: 0 }, to: { scale: 1, rotation: 90, yoyo: true }, p: 1.2 + R() * 1.6, ease: "sine.inOut" };
  } }) };

const LEAF = (c) => `<svg viewBox="0 0 40 24" style="width:100%;height:100%;overflow:visible"><path d="M2 12 Q20 -6 38 12 Q20 30 2 12 Z" fill="${c}" stroke="#000" stroke-width="2"/><path d="M4 12 L34 12" stroke="#000" stroke-width="1.5"/></svg>`;
const leaves = { id: "leaves", cat: "atmosphere", label: "Lá / cánh hoa rơi xoay (petals: true cho hoa hồng)",
  run: (ctx, o) => field(ctx, o, { n: o.n ?? 22, make: (i, R) => {
    const w = r3(30 + R() * 26), pal = o.petals ? ["#FFC2DD", "#FE90E8", "#FFE3EF"] : ["#99E885", "#F7CB46", "#FF9B4A", "#6CC25A"];
    return { style: `left:${r3(R() * 1920)}px;top:-60px;width:${w}px;height:${r3(w * 0.6)}px;`, html: LEAF(o.color || pal[i % pal.length]),
      from: { y: 0, x: 0, rotation: 0 }, to: { y: 1200, x: (R() - 0.5) * 500, rotation: (R() > 0.5 ? 1 : -1) * (360 + R() * 360) }, p: 6 + R() * 5, ease: "sine.inOut" };
  } }) };

const fog = { id: "fog", cat: "atmosphere", label: "Sương mù trôi ngang",
  run(ctx, o) {
    const { t, end } = when(ctx, o, 0);
    const R = rng(ctx.id), id = ctx.id;
    let html = "", js = `      FADE(q("#${id}"), ${t}, 1.2);\n`;
    for (let i = 0; i < 5; i++) {
      const w = r3(900 + R() * 700), top = r3(80 + i * 160 + R() * 60);
      html += `<div class="${id}-f" style="position:absolute;left:${r3(R() * 1400 - 400)}px;top:${top}px;width:${w}px;height:${r3(w * 0.35)}px;border-radius:50%;background:${o.color || "rgba(255,255,255,0.55)"};filter:blur(50px);"></div>`;
      js += `      tl.fromTo(qa(".${id}-f")[${i}], { x: 0 }, { x: ${r3((i % 2 ? -1 : 1) * (240 + R() * 260))}, duration: ${r3(end - t)}, ease: "none", immediateRender: false }, ${t});\n`;
    }
    return { [o.layer || "over"]: layer(id, html, `opacity:0;${o.opacity != null ? `filter:opacity(${o.opacity});` : ""}`), js };
  } };

export default [dust, rain, snow, embers, bubbles, twinkle, leaves, fog];
