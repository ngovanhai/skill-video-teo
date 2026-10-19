// Accents: one-shot hits that land on a cue. Position options x, y are frame pixels (keep y < 880).
import { rng, when, layer, sfx, esc, fit, C, color, r3 } from "./_util.mjs";

// wobbly closed blob around (0,0)
function blob(R, r, n = 11, wob = 0.35) {
  const pts = Array.from({ length: n }, (_, i) => {
    const a = (Math.PI * 2 * i) / n, k = r * (1 - wob / 2 + R() * wob);
    return [Math.cos(a) * k, Math.sin(a) * k];
  });
  let d = "";
  for (let i = 0; i < n; i++) {
    const p = pts[i], q = pts[(i + 1) % n], m = [(p[0] + q[0]) / 2, (p[1] + q[1]) / 2];
    d += (i ? " Q" : `M${r3((pts[n - 1][0] + p[0]) / 2)} ${r3((pts[n - 1][1] + p[1]) / 2)} Q`) + `${r3(p[0])} ${r3(p[1])} ${r3(m[0])} ${r3(m[1])}`;
  }
  return d + " Z";
}

const inkSplash = { id: "ink-splash", cat: "accent", label: "Mực loang bắn tung toé (x, y, r, color, out: giây biến mất)",
  run(ctx, o) {
    const { t } = when(ctx, o, 0.3);
    const R = rng(ctx.id), id = ctx.id, x = o.x ?? 960, y = o.y ?? 440, r = o.r ?? 230, c = o.color ? color(o.color) : "#111";
    let g = `<path id="${id}-m" d="${blob(R, r)}" fill="${c}"/>`;
    for (let i = 0; i < 9; i++) {
      const a = R() * Math.PI * 2, k = r * (1.15 + R() * 0.7), s = r3(8 + R() * 26);
      g += `<circle class="${id}-d" cx="${r3(Math.cos(a) * k)}" cy="${r3(Math.sin(a) * k)}" r="${s}" fill="${c}"/>`;
    }
    const inner = `<svg viewBox="-600 -600 1200 1200" style="position:absolute;left:${x - 600}px;top:${y - 600}px;width:1200px;height:1200px;overflow:visible"><g id="${id}-g">${g}</g></svg>`;
    let js = `      tl.set(q("#${id}"), { opacity: 1 }, ${t});
      tl.fromTo(q("#${id}-m"), { scale: 0, transformOrigin: "50% 50%" }, { scale: 1, duration: 0.35, ease: "back.out(1.4)", immediateRender: false }, ${t});
      tl.fromTo(qa(".${id}-d"), { scale: 0, transformOrigin: "50% 50%" }, { scale: 1, duration: 0.3, stagger: 0.02, ease: "back.out(2)", immediateRender: false }, ${r3(t + 0.08)});\n`;
    if (o.out != null) js += `      OUT(q("#${id}"), ${r3(t + o.out)}, 0.4);\n`;
    return { [o.layer || "back"]: layer(id, inner, "opacity:0;"), js, sfx: [sfx(o.sound || "pop", t, 0.35)] };
  } };

const shockwave = { id: "shockwave", cat: "accent", label: "Sóng xung kích: 3 vòng tròn lan ra (x, y, color)",
  run(ctx, o) {
    const { t } = when(ctx, o, 0.3);
    const id = ctx.id, x = o.x ?? 960, y = o.y ?? 440, c = o.color ? color(o.color) : "#fff";
    let inner = "";
    for (let i = 0; i < 3; i++) inner += `<div class="${id}-r" style="position:absolute;left:${x - 150}px;top:${y - 150}px;width:300px;height:300px;border-radius:50%;border:${14 - i * 4}px solid ${c};box-shadow:0 0 0 4px #000, inset 0 0 0 4px #000;transform:scale(0);"></div>`;
    return { over: layer(id, inner),
      js: `      tl.fromTo(qa(".${id}-r"), { scale: 0, opacity: 1 }, { scale: 4.5, opacity: 0, duration: 0.9, stagger: 0.13, ease: "power2.out", immediateRender: false }, ${t});\n`,
      sfx: [sfx(o.sound || "impact2", t, 0.4)] };
  } };

const speedlines = { id: "speedlines", cat: "accent", label: "Đường tốc độ kiểu truyện tranh dồn vào tâm (x, y, color)",
  run(ctx, o) {
    const { t, d } = when(ctx, o, 0.2);
    const R = rng(ctx.id), id = ctx.id, x = o.x ?? 960, y = o.y ?? 440, n = 56;
    const mk = () => { let s = ""; for (let i = 0; i < n; i++) { const a = (Math.PI * 2 * i) / n + R() * 0.08, w = 0.006 + R() * 0.012, r0 = 360 + R() * 220;
      s += `<path d="M${r3(Math.cos(a) * r0)} ${r3(Math.sin(a) * r0)} L${r3(Math.cos(a - w) * 1700)} ${r3(Math.sin(a - w) * 1700)} L${r3(Math.cos(a + w) * 1700)} ${r3(Math.sin(a + w) * 1700)} Z"/>`; } return s; };
    const c = o.color || "#000";
    const inner = `<svg viewBox="-1700 -1700 3400 3400" style="position:absolute;left:${x - 1700}px;top:${y - 1700}px;width:3400px;height:3400px;"><g id="${id}-a" fill="${c}">${mk()}</g><g id="${id}-b" fill="${c}" opacity="0">${mk()}</g></svg>`;
    const len = Math.min(d, o.len ?? 1.6);
    let js = `      tl.set(q("#${id}"), { opacity: 1 }, ${t});\n`;
    for (let k = 0, tt = t; tt < t + len; k++, tt = r3(tt + 0.08)) js += `      tl.set(q("#${id}-a"), { opacity: ${k % 2 ? 0 : 1} }, ${tt}); tl.set(q("#${id}-b"), { opacity: ${k % 2 ? 1 : 0} }, ${tt});\n`;
    js += `      tl.to(q("#${id}"), { opacity: 0, duration: 0.25 }, ${r3(t + len)});\n`;
    return { [o.layer || "over"]: layer(id, inner, "opacity:0;"), js, sfx: [sfx("whoosh", t, 0.3)] };
  } };

const confetti = { id: "confetti", cat: "accent", label: "Pháo giấy bung rồi rơi (x, y) — ăn mừng, kỷ lục",
  run(ctx, o) {
    const { t } = when(ctx, o, 0.3);
    const R = rng(ctx.id), id = ctx.id, x = o.x ?? 960, y = o.y ?? 520, pal = [C.yellow, C.pink, C.blue, C.green, C.red, C.cream];
    let inner = "", js = "";
    for (let i = 0; i < 60; i++) {
      const w = r3(12 + R() * 14), dx = r3((R() - 0.5) * 1500), up = r3(250 + R() * 450);
      inner += `<div class="${id}-c" style="position:absolute;left:${x}px;top:${y}px;width:${w}px;height:${r3(w * 0.55)}px;background:${pal[i % pal.length]};border:2px solid #000;transform:scale(0);"></div>`;
      js += `      tl.fromTo(qa(".${id}-c")[${i}], { x: 0, y: 0, scale: 0, rotation: 0 }, { x: ${dx}, y: ${-up}, scale: 1, rotation: ${r3(R() * 360)}, duration: 0.55, ease: "power3.out", immediateRender: false }, ${t});
      tl.to(qa(".${id}-c")[${i}], { y: ${r3(900 - y)}, x: "+=${r3((R() - 0.5) * 200)}", rotation: "+=${r3(360 + R() * 540)}", duration: ${r3(1.8 + R() * 1.2)}, ease: "power1.in" }, ${r3(t + 0.55)});\n`;
    }
    return { over: layer(id, inner), js, sfx: [sfx("sparkle", t, 0.35), sfx("pop", t, 0.3)] };
  } };

const glitch = { id: "glitch", cat: "accent", label: "Nhiễu sọc RGB + giật khung (len giây)",
  run(ctx, o) {
    const { t, d } = when(ctx, o, 0.2);
    const R = rng(ctx.id), id = ctx.id, len = Math.min(d, o.len ?? 0.6);
    let inner = "";
    for (let i = 0; i < 7; i++) inner += `<div class="${id}-b" style="position:absolute;left:0;width:1920px;top:0;height:40px;opacity:0;background:${["rgba(255,0,80,0.55)", "rgba(0,240,255,0.55)", "rgba(255,255,255,0.7)"][i % 3]};mix-blend-mode:screen;"></div>`;
    let js = "";
    for (let tt = t; tt < t + len; tt = r3(tt + 0.05)) {
      for (let i = 0; i < 7; i++) js += `      tl.set(qa(".${id}-b")[${i}], { y: ${r3(R() * 1040)}, height: ${r3(6 + R() * 70)}, x: ${r3((R() - 0.5) * 120)}, opacity: ${R() > 0.45 ? 1 : 0} }, ${tt});\n`;
      js += `      tl.set(q("#${ctx.ns}-fxcam"), { x: ${r3((R() - 0.5) * 40)} }, ${tt});\n`;
    }
    js += `      tl.set(qa(".${id}-b"), { opacity: 0 }, ${r3(t + len)}); tl.set(q("#${ctx.ns}-fxcam"), { x: 0 }, ${r3(t + len)});\n`;
    return { cam: true, over: layer(id, inner), js, sfx: [sfx("glitch", t, 0.35)] };
  } };

const wipe = { id: "wipe", cat: "accent", label: "Dải màu chéo quét qua khung (chuyển ý, color)",
  run(ctx, o) {
    const { t } = when(ctx, o, 0);
    const id = ctx.id;
    const inner = `<div id="${id}-w" style="position:absolute;top:-300px;left:-1400px;width:900px;height:1700px;background:${color(o.color, 0)};border-left:10px solid #000;border-right:10px solid #000;transform:skewX(-18deg);"></div>`;
    return { over: layer(id, inner),
      js: `      tl.fromTo(q("#${id}-w"), { x: 0 }, { x: 4300, duration: ${o.speed ?? 0.75}, ease: "power2.inOut", immediateRender: false }, ${t});\n`,
      sfx: [sfx("whooshShort", t, 0.35)] };
  } };

// hand-drawn marks: circle around something, underline, or a curved arrow pointing at it
const mark = { id: "mark", cat: "accent", label: "Nét vẽ tay khoanh / gạch chân / mũi tên (shape, x, y, w, h, color)",
  run(ctx, o) {
    const { t } = when(ctx, o, 0.4);
    const id = ctx.id, x = o.x ?? 960, y = o.y ?? 440, w = o.w ?? 420, h = o.h ?? 180, c = o.color ? color(o.color) : C.red;
    let path;
    if (o.shape === "underline") path = `M${-w / 2} 0 Q 0 ${-h * 0.12} ${w / 2} ${h * 0.05}`;
    else if (o.shape === "arrow") path = `M${-w / 2} ${-h / 2} Q ${-w * 0.1} ${-h * 0.6} ${w / 2 - 20} ${h / 2 - 20} M${w / 2 - 80} ${h / 2 - 10} L${w / 2 - 20} ${h / 2 - 20} L${w / 2 - 20} ${h / 2 - 85}`;
    else path = `M${-w * 0.42} ${-h * 0.42} C ${-w * 0.1} ${-h * 0.62}, ${w * 0.55} ${-h * 0.45}, ${w * 0.5} 0 S ${-w * 0.3} ${h * 0.68}, ${-w * 0.5} ${h * 0.05} S ${-w * 0.2} ${-h * 0.55}, ${w * 0.12} ${-h * 0.5}`;
    const inner = `<svg viewBox="${-w} ${-h} ${w * 2} ${h * 2}" style="position:absolute;left:${x - w}px;top:${y - h}px;width:${w * 2}px;height:${h * 2}px;overflow:visible"><path id="${id}-p" d="${path}" pathLength="1" fill="none" stroke="${c}" stroke-width="${o.stroke ?? 12}" stroke-linecap="round" stroke-linejoin="round" stroke-dasharray="1" stroke-dashoffset="1"/></svg>`;
    return { over: layer(id, inner), js: `      DRAW(q("#${id}-p"), ${t}, ${o.speed ?? 0.55});\n`, sfx: [sfx("click", t, 0.25)] };
  } };

const lightning = { id: "lightning", cat: "accent", label: "Tia sét giáng xuống điểm (x, y) + chớp sáng",
  run(ctx, o) {
    const { t } = when(ctx, o, 0.3);
    const R = rng(ctx.id), id = ctx.id, x = o.x ?? 1100, y = o.y ?? 700;
    const pts = [[x + (R() - 0.5) * 300, -40]];
    for (let i = 1; i <= 9; i++) pts.push([r3(pts[0][0] + (x - pts[0][0]) * (i / 9) + (i < 9 ? (R() - 0.5) * 140 : 0)), r3(-40 + (y + 40) * (i / 9))]);
    const d = "M" + pts.map((p) => p.join(" ")).join(" L");
    const inner = `<div id="${id}-f" style="position:absolute;inset:0;background:#fff;opacity:0;"></div>
      <svg viewBox="0 0 1920 1080" style="position:absolute;inset:0;width:1920px;height:1080px;overflow:visible"><g id="${id}-b" opacity="0"><path d="${d}" fill="none" stroke="${o.color || "#BFE6FF"}" stroke-width="26" stroke-linejoin="bevel" style="filter:blur(10px)"/><path d="${d}" fill="none" stroke="#fff" stroke-width="9" stroke-linejoin="bevel"/></g></svg>`;
    const js = [[0, 1, 0.85], [0.07, 0, 0.1], [0.12, 1, 0.6], [0.3, 0, 0]].map(([dt, b, f]) =>
      `      tl.set(q("#${id}-b"), { opacity: ${b} }, ${r3(t + dt)}); tl.set(q("#${id}-f"), { opacity: ${f} }, ${r3(t + dt)});\n`).join("");
    return { over: layer(id, inner), js, sfx: [sfx("impact2", t, 0.45)] };
  } };

// comic word anywhere (moment scenes already have one; this adds a smaller extra one)
const pow = { id: "pow", cat: "accent", label: "Chữ truyện tranh nhỏ bật ra (text, x, y, color, rot)",
  run(ctx, o) {
    const { t } = when(ctx, o, 0.4);
    const id = ctx.id, text = o.text || "WOW!", s = fit(text, 600, o.size ?? 110, 50, 1, 0.66);
    const inner = `<div id="${id}-t" style="position:absolute;left:${(o.x ?? 1500) - 350}px;top:${(o.y ?? 160) - s * 0.6}px;width:700px;text-align:center;font-weight:700;font-size:${s}px;line-height:1.2;color:${color(o.color, 0)};-webkit-text-stroke:8px #000;paint-order:stroke fill;text-shadow:8px 8px 0 #000;opacity:0;">${esc(text)}</div>`;
    return { over: layer(id, inner),
      js: `      tl.fromTo(q("#${id}-t"), { scale: 2.2, opacity: 0, rotation: ${o.rot ?? 8} }, { scale: 1, opacity: 1, rotation: ${o.rot ?? 8}, duration: 0.28, ease: "power4.out", immediateRender: false }, ${t});\n`,
      sfx: [sfx(o.sound || "pop", t, 0.35)] };
  } };

export default [inkSplash, shockwave, speedlines, confetti, glitch, wipe, mark, lightning, pow];
