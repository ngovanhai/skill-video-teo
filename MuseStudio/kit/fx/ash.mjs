// `ash`: tro núi lửa xám rơi chậm, lả tả (heavy: true cho tro dày đặc).
// `ticker`: dải bản tin "TIN KHẨN" chạy chữ ở mép trên khung hình (text, label, color, y).
import { rng, when, layer, reps, sfx, r3, esc, color } from "./_util.mjs";

const ash = { id: "ash", cat: "atmosphere", label: "Tro núi lửa xám rơi lả tả (heavy: true cho tro dày)",
  run(ctx, o) {
    const { t, end } = when(ctx, o, 0);
    const R = rng(ctx.id), id = ctx.id, n = o.n ?? (o.heavy ? 90 : 55);
    let html = "", js = `      FADE(q("#${id}"), ${t}, ${o.fade ?? 0.8});\n`;
    if (o.d != null) js += `      OUT(q("#${id}"), ${r3(Math.max(t + 0.3, end - 0.5))}, 0.5);\n`;
    for (let i = 0; i < n; i++) {
      const s = r3(4 + R() * (o.heavy ? 12 : 9)), c = o.color || ["#9A9A9A", "#BDBDBD", "#6E6E6E", "#D6D2CC"][i % 4];
      html += `<div class="${id}-p" style="position:absolute;left:${r3(R() * 2100 - 90)}px;top:-40px;width:${s}px;height:${r3(s * (0.6 + R() * 0.6))}px;border-radius:${R() > 0.5 ? "50%" : "30%"};background:${c};"></div>`;
      const p = r3((o.heavy ? 4 : 6) + R() * 4), start = r3(Math.max(0, t - R() * p));
      js += `      tl.fromTo(qa(".${id}-p")[${i}], { y: 0, x: 0, rotation: 0 }, { y: 1160, x: ${r3((R() - 0.6) * 340)}, rotation: ${r3((R() - 0.5) * 540)}, duration: ${p}, ease: "sine.inOut", repeat: ${reps(end - start, p)}, immediateRender: false }, ${start});\n`;
    }
    const tint = o.tint === false ? "" : `<div style="position:absolute;inset:0;background:linear-gradient(180deg, rgba(60,55,50,${o.heavy ? 0.35 : 0.18}), rgba(60,55,50,0));"></div>`;
    return { [o.layer || "over"]: layer(id, tint + html, `opacity:0;${o.opacity != null ? `filter:opacity(${o.opacity});` : ""}`), js };
  } };

const ticker = { id: "ticker", cat: "accent", label: "Dải bản tin TIN KHẨN chạy chữ ở mép trên (text, label, color, y)",
  run(ctx, o) {
    const { t, d } = when(ctx, o, 0.2);
    const id = ctx.id, y = o.y ?? 24, c = o.color ? color(o.color) : "#E0352B";
    const text = esc(o.text || "TIN KHẨN"), label = esc(o.label || "TIN KHẨN");
    const run = `${text} &nbsp;•&nbsp; ${text} &nbsp;•&nbsp; ${text} &nbsp;•&nbsp; ${text}`;
    const inner = `<div id="${id}-bar" style="position:absolute;left:0;top:${y}px;width:1920px;height:72px;background:#111;border-top:5px solid ${c};border-bottom:5px solid ${c};overflow:hidden;opacity:0;transform:scaleX(0);transform-origin:0 50%;">
        <div id="${id}-run" style="position:absolute;left:300px;top:8px;white-space:nowrap;font-weight:700;font-size:42px;color:#FFFDF5;">${run}</div>
        <div style="position:absolute;left:0;top:0;width:270px;height:62px;background:${c};display:flex;align-items:center;justify-content:center;font-weight:700;font-size:38px;color:#fff;letter-spacing:2px;">
          <span id="${id}-dot" style="display:inline-block;width:18px;height:18px;border-radius:50%;background:#fff;margin-right:12px;"></span>${label}</div>
      </div>`;
    let js = `      tl.fromTo(q("#${id}-bar"), { opacity: 0, scaleX: 0 }, { opacity: 1, scaleX: 1, duration: 0.35, ease: "power3.out", immediateRender: false }, ${t});\n`;
    js += `      tl.fromTo(q("#${id}-run"), { x: 0 }, { x: ${r3(-Math.max(600, d * 160))}, duration: ${d}, ease: "none", immediateRender: false }, ${t});\n`;
    js += `      tl.to(q("#${id}-dot"), { opacity: 0.15, duration: 0.4, yoyo: true, repeat: ${reps(d, 0.4)}, ease: "none" }, ${t});\n`;
    return { over: layer(id, inner), js, sfx: o.sound === false ? [] : [sfx("whoosh", t, 0.2)] };
  } };

export default [ash, ticker];
