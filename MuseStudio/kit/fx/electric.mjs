// Electric fx: `arc` (hồ quang điện nhảy giữa 2 điểm, chập chờn) and `sparks` (tia lửa điện toé ra).
import { rng, when, layer, reps, sfx, r3, color } from "./_util.mjs";

// jagged lightning path from (x1,y1) to (x2,y2)
function zig(R, x1, y1, x2, y2, n = 9, amp = 34) {
  const dx = x2 - x1, dy = y2 - y1, L = Math.hypot(dx, dy) || 1, nx = -dy / L, ny = dx / L;
  let d = `M${r3(x1)} ${r3(y1)}`;
  for (let i = 1; i < n; i++) {
    const k = i / n, o = (R() * 2 - 1) * amp * Math.sin(Math.PI * k);
    d += ` L${r3(x1 + dx * k + nx * o)} ${r3(y1 + dy * k + ny * o)}`;
  }
  return d + ` L${r3(x2)} ${r3(y2)}`;
}

const arc = { id: "arc", cat: "accent", label: "Hồ quang điện nhảy giữa 2 điểm, chập chờn (x1, y1, x2, y2, color, amp)",
  run(ctx, o) {
    const { t, d } = when(ctx, o, 0.3);
    const R = rng(ctx.id), id = ctx.id, c = o.color ? color(o.color) : "#9EE7FF";
    const x1 = o.x1 ?? 700, y1 = o.y1 ?? 400, x2 = o.x2 ?? 1220, y2 = o.y2 ?? 400, amp = o.amp ?? 34;
    const F = 3; // 3 shapes swapped to fake flicker
    let g = "";
    for (let k = 0; k < F; k++) {
      const p = zig(R, x1, y1, x2, y2, 10, amp);
      g += `<g class="${id}-f" id="${id}-f${k}" opacity="0"><path d="${p}" fill="none" stroke="${c}" stroke-width="18" stroke-linejoin="round" opacity=".35"/><path d="${p}" fill="none" stroke="#fff" stroke-width="6" stroke-linejoin="round"/></g>`;
    }
    g += `<circle id="${id}-a" cx="${x1}" cy="${y1}" r="22" fill="${c}" opacity="0"/><circle id="${id}-b" cx="${x2}" cy="${y2}" r="22" fill="${c}" opacity="0"/>`;
    const inner = `<svg viewBox="0 0 1920 1080" style="position:absolute;inset:0;width:1920px;height:1080px;overflow:visible">${g}</svg>`;
    let js = `      tl.set(q("#${id}"), { opacity: 1 }, ${t});
      tl.fromTo([q("#${id}-a"), q("#${id}-b")], { attr: { opacity: 0 } }, { attr: { opacity: 0.9 }, duration: 0.15, immediateRender: false }, ${t});\n`;
    const step = 0.09, n = Math.min(60, Math.floor(Math.min(d, o.hold ?? 2.4) / step));
    for (let i = 0; i < n; i++) {
      const ti = r3(t + i * step), k = i % F, prev = (i + F - 1) % F;
      js += `      tl.set(q("#${id}-f${k}"), { attr: { opacity: 1 } }, ${ti}); tl.set(q("#${id}-f${prev}"), { attr: { opacity: 0 } }, ${ti});\n`;
    }
    js += `      OUT(q("#${id}"), ${r3(t + n * step)}, 0.2);\n`;
    return { [o.layer || "over"]: layer(id, inner, "opacity:0;"), js, sfx: [sfx(o.sound || "glitch", t, 0.25)] };
  } };

const sparks = { id: "sparks", cat: "accent", label: "Tia lửa điện toé ra từ (x, y), color, n tia",
  run(ctx, o) {
    const { t } = when(ctx, o, 0.3);
    const R = rng(ctx.id), id = ctx.id, x = o.x ?? 960, y = o.y ?? 440, c = o.color ? color(o.color) : "#FFE45C", n = o.n ?? 14;
    let g = "", js = `      tl.set(q("#${id}"), { opacity: 1 }, ${t});\n`;
    for (let i = 0; i < n; i++) {
      const a = (Math.PI * 2 * i) / n + R() * 0.3, L = 90 + R() * 140, ex = r3(Math.cos(a) * L), ey = r3(Math.sin(a) * L);
      g += `<path class="${id}-s" d="M0 0 L${r3(ex * 0.25)} ${r3(ey * 0.25)}" stroke="${c}" stroke-width="7" stroke-linecap="round"/>`;
      js += `      tl.fromTo(q("#${id}-g").children[${i}], { x: 0, y: 0, opacity: 1 }, { x: ${ex}, y: ${ey}, opacity: 0, duration: ${r3(0.45 + R() * 0.3)}, ease: "power2.out", immediateRender: false }, ${t});\n`;
    }
    g += `<circle id="${id}-c" r="30" fill="#fff" opacity="0"/>`;
    js += `      tl.fromTo(q("#${id}-c"), { attr: { opacity: 1, r: 10 } }, { attr: { opacity: 0, r: 70 }, duration: 0.35, immediateRender: false }, ${t});\n`;
    const inner = `<svg viewBox="-400 -400 800 800" style="position:absolute;left:${x - 400}px;top:${y - 400}px;width:800px;height:800px;overflow:visible"><g id="${id}-g">${g}</g></svg>`;
    return { [o.layer || "over"]: layer(id, inner, "opacity:0;"), js, sfx: [sfx(o.sound || "sparkle", t, 0.3)] };
  } };

export default [arc, sparks];
