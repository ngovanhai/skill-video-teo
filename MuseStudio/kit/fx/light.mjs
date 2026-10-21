// Light: rays, vignette, flash, spotlight, light leak, old film.
import { rng, when, layer, sfx, r3 } from "./_util.mjs";

const rays = { id: "rays", cat: "light", label: "Tia sáng xoay chậm sau cảnh (x, y, color, n)",
  run(ctx, o) {
    const { t } = when(ctx, o, 0);
    const n = o.n ?? 14, x = o.x ?? 960, y = o.y ?? 470, c = o.color || "rgba(255,255,255,0.32)";
    let w = "";
    for (let i = 0; i < n; i++) {
      const a = (Math.PI * 2 * i) / n, b = a + Math.PI / n;
      w += `<path d="M0 0 L${r3(Math.cos(a) * 1600)} ${r3(Math.sin(a) * 1600)} L${r3(Math.cos(b) * 1600)} ${r3(Math.sin(b) * 1600)} Z"/>`;
    }
    const id = ctx.id;
    const inner = `<svg id="${id}-w" viewBox="-1600 -1600 3200 3200" style="position:absolute;left:${x - 1600}px;top:${y - 1600}px;width:3200px;height:3200px;"><g fill="${c}">${w}</g></svg>`;
    return { [o.layer || "back"]: layer(id, inner, "opacity:0;"),
      js: `      FADE(q("#${id}"), ${t}, 0.8);
      tl.fromTo(q("#${id}-w"), { rotation: 0 }, { rotation: ${o.speed ?? 12} * ${r3(ctx.dur - t)} / 10, duration: ${r3(ctx.dur - t)}, ease: "none", transformOrigin: "50% 50%", immediateRender: false }, ${t});\n` };
  } };

const vignette = { id: "vignette", cat: "light", label: "Viền tối quanh khung, tuỳ chọn pulse: true (hồi hộp)",
  run(ctx, o) {
    const { t, d } = when(ctx, o, 0);
    const id = ctx.id;
    let js = `      FADE(q("#${id}"), ${t}, 0.8);\n`;
    if (o.pulse) for (let k = 0; k * 0.9 < d - 1; k++) js += `      tl.to(q("#${id}"), { opacity: ${k % 2 ? 1 : 0.65}, duration: 0.45, ease: "sine.inOut" }, ${r3(t + 0.8 + k * 0.45)});\n`;
    return { over: layer(id, "", `opacity:0;background:radial-gradient(ellipse at 50% 45%, transparent 48%, ${o.color || "rgba(0,0,0,0.72)"} 100%);`), js };
  } };

const flash = { id: "flash", cat: "light", label: "Chớp trắng toàn khung (color)",
  run(ctx, o) {
    const { t } = when(ctx, o, 0.2);
    const id = ctx.id;
    return { over: layer(id, "", `opacity:0;background:${o.color || "#fff"};`),
      js: `      tl.fromTo(q("#${id}"), { opacity: 0 }, { opacity: ${o.strength ?? 0.95}, duration: 0.05, ease: "none", immediateRender: false }, ${t});
      tl.to(q("#${id}"), { opacity: 0, duration: 0.55, ease: "power2.out" }, ${r3(t + 0.06)});\n`,
      sfx: o.sound === false ? [] : [sfx(o.sound || "sparkle", t, 0.3)] };
  } };

const spotlight = { id: "spotlight", cat: "light", label: "Đèn rọi: tối xung quanh, vòng sáng ở (x,y) trượt tới (to_x,to_y)",
  run(ctx, o) {
    const { t, d } = when(ctx, o, 0.2);
    const id = ctx.id, r = o.r ?? 300;
    const css = `#${id} { --x: ${o.x ?? 960}px; --y: ${o.y ?? 450}px; background: radial-gradient(circle ${r}px at var(--x) var(--y), transparent 0, transparent ${r - 60}px, rgba(0,0,0,0.78) ${r}px); }`;
    let js = `      FADE(q("#${id}"), ${t}, 0.5);\n`;
    if (o.to_x != null || o.to_y != null)
      js += `      tl.to(q("#${id}"), { "--x": "${o.to_x ?? o.x ?? 960}px", "--y": "${o.to_y ?? o.y ?? 450}px", duration: ${r3(Math.min(o.move ?? 1.6, d))}, ease: "power2.inOut" }, ${r3(t + 0.5)});\n`;
    return { over: layer(id, "", "opacity:0;"), css, js, sfx: [sfx("click", t, 0.25)] };
  } };

const lightLeak = { id: "light-leak", cat: "light", label: "Vệt sáng ấm quét ngang kiểu phim (color)",
  run(ctx, o) {
    const { t } = when(ctx, o, 0.1);
    const id = ctx.id, c = o.color || "rgba(255,170,90,0.75)";
    const inner = `<div id="${id}-a" style="position:absolute;left:-900px;top:-200px;width:900px;height:1500px;background:radial-gradient(ellipse closest-side, ${c} 0%, transparent 100%);"></div>
      <div id="${id}-b" style="position:absolute;left:-700px;top:300px;width:600px;height:900px;background:radial-gradient(ellipse closest-side, rgba(255,120,170,0.6) 0%, transparent 100%);"></div>`;
    return { over: layer(id, inner, "opacity:0;"),
      js: `      FADE(q("#${id}"), ${t}, 0.4);
      tl.fromTo(q("#${id}-a"), { x: 0 }, { x: 3000, duration: ${o.speed ?? 2.6}, ease: "power1.inOut", immediateRender: false }, ${t});
      tl.fromTo(q("#${id}-b"), { x: 0 }, { x: 2800, duration: ${r3((o.speed ?? 2.6) * 1.2)}, ease: "power1.inOut", immediateRender: false }, ${r3(t + 0.2)});\n` };
  } };

const oldFilm = { id: "old-film", cat: "light", label: "Phim cũ: ngả nâu, nhấp nháy, vết xước (hồi ức, chuyện xưa)",
  run(ctx, o) {
    const { t, end } = when(ctx, o, 0);
    const R = rng(ctx.id), id = ctx.id;
    let inner = `<div style="position:absolute;inset:0;background:rgba(150,95,35,0.28);"></div><div style="position:absolute;inset:0;background:radial-gradient(ellipse at center, transparent 55%, rgba(40,22,6,0.45) 100%);"></div><div id="${id}-k" style="position:absolute;inset:0;background:#2a1a08;opacity:0;"></div>`;
    for (let i = 0; i < 3; i++) inner += `<div class="${id}-s" style="position:absolute;top:0;left:${r3(200 + R() * 1500)}px;width:2px;height:1080px;background:rgba(40,25,10,0.55);"></div>`;
    let js = `      FADE(q("#${id}"), ${t}, 0.3);\n`;
    for (let k = 0, tt = t; tt < end - 0.1; k++, tt = r3(tt + 0.12)) {
      if (k % 2 === 0) js += `      tl.set(q("#${id}-k"), { opacity: ${r3(R() * 0.12)} }, ${tt});\n`;
      if (k % 3 === 0) js += `      tl.set(qa(".${id}-s")[${k % 9 === 0 ? 0 : k % 2 ? 1 : 2}], { x: ${r3((R() - 0.5) * 600)}, opacity: ${R() > 0.4 ? 1 : 0} }, ${tt});\n`;
    }
    return { over: layer(id, inner, "opacity:0;"), js, sfx: [sfx("click", t, 0.2)] };
  } };

export default [rays, vignette, flash, spotlight, lightLeak, oldFilm];
