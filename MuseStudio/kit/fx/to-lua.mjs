// `caravan`: bóng đoàn lạc đà đi ngang đường chân trời (y, n con, dir left|right, color) — hành trình, sa mạc.
// `compass`: hoa la bàn vẽ nét dần, kim xoay rồi chỉ hướng (x, y, r, dir độ: 0 = bắc, 90 = đông) — lên đường, đổi hướng.
// `scroll`: cuộn giấy da mở ra kèm dòng chữ (text, x, y, w) — trang nhật ký, ghi chép, lời ghi trong sách.
// `lantern`: đèn lồng đỏ treo đung đưa ở mép trên, sáng dần (n, color) — phố xá, cung điện, lễ hội phương Đông.
import { rng, when, layer, sfx, r3, esc, color, reps } from "./_util.mjs";

const CAMEL = `<path d="M-60 0 L-56 -38 Q-60 -52 -46 -56 L-30 -54 Q-22 -78 -8 -70 Q2 -62 8 -54 Q18 -80 32 -70 Q42 -60 44 -46 L58 -60 Q68 -72 78 -66 L80 -58 L70 -54 L56 -30 L54 0 L46 0 L44 -26 L-30 -26 L-40 0 L-48 0 L-50 -26 L-54 0 Z"/>`;

const caravan = { id: "caravan", cat: "atmosphere", label: "Bóng đoàn lạc đà đi ngang chân trời (y, n, dir left|right, color)",
  run(ctx, o) {
    const { t, d } = when(ctx, o, 0.2);
    const id = ctx.id, y = o.y ?? 780, n = Math.min(6, o.n ?? 4), c = o.color ? color(o.color) : "#3A2412";
    const right = (o.dir || "right") === "right", s = o.scale ?? 0.9;
    let g = "";
    for (let i = 0; i < n; i++) g += `<g transform="translate(${-i * 190} 0) scale(${right ? 1 : -1} 1)">${CAMEL}<circle cx="-6" cy="-66" r="7"/></g>`;
    const w = n * 190 + 120;
    const inner = `<div id="${id}-c" style="position:absolute;left:0;top:${r3(y - 90 * s)}px;width:${w}px;height:${r3(100 * s)}px;opacity:0">
      <svg viewBox="${-(n - 1) * 190 - 80} -90 ${w} 100" style="width:100%;height:100%;overflow:visible"><g fill="${c}">${g}</g></svg></div>`;
    const x0 = right ? -w : 1920, x1 = right ? 1920 : -w;
    const js = `      tl.fromTo(q("#${id}-c"), { x: ${x0}, opacity: 0 }, { x: ${r3(x0 + (x1 - x0) * 0.15)}, opacity: ${o.opacity ?? 0.75}, duration: 0.6, ease: "none", immediateRender: false }, ${t});
      tl.to(q("#${id}-c"), { x: ${x1}, duration: ${r3(Math.max(1, d * (o.speed ?? 1.4)))}, ease: "none" }, ${r3(t + 0.6)});
      tl.fromTo(q("#${id}-c"), { y: 0 }, { y: -6, duration: 0.35, yoyo: true, repeat: ${reps(d, 0.35)}, ease: "sine.inOut", immediateRender: false }, ${t});\n`;
    return { [o.layer || "back"]: layer(id, inner), js, sfx: [sfx("whoosh", t, 0.12)] };
  } };

const compass = { id: "compass", cat: "accent", label: "Hoa la bàn vẽ nét dần, kim xoay rồi chỉ hướng (x, y, r, dir độ 0=bắc 90=đông)",
  run(ctx, o) {
    const { t } = when(ctx, o, 0.3);
    const id = ctx.id, x = o.x ?? 1700, y = o.y ?? 200, r = o.r ?? 130, c = o.color ? color(o.color) : "#5A3410";
    const dir = o.dir ?? 90;
    const star = [0, 90, 180, 270].map((a) => `<path d="M0 0 L${r3(r * 0.16)} ${r3(-r * 0.16)} L0 ${-r} L${r3(-r * 0.16)} ${r3(-r * 0.16)} Z" transform="rotate(${a})"/>`).join("");
    const inner = `<svg viewBox="${-r - 50} ${-r - 50} ${2 * r + 100} ${2 * r + 100}" style="position:absolute;left:${x - r - 50}px;top:${y - r - 50}px;width:${2 * r + 100}px;height:${2 * r + 100}px;overflow:visible">
      <circle id="${id}-o" r="${r}" fill="#F4E3C1" fill-opacity=".85" stroke="${c}" stroke-width="7" pathLength="1" stroke-dasharray="1" stroke-dashoffset="1"/>
      <g id="${id}-st" fill="${c}" opacity="0" stroke="${c}" stroke-width="2">${star}</g>
      <text id="${id}-n" y="${-r - 14}" text-anchor="middle" font-size="${r3(r * 0.32)}" font-weight="900" fill="${c}" opacity="0">B</text>
      <g id="${id}-k" opacity="0"><path d="M0 ${r3(-r * 0.78)} L${r3(r * 0.09)} 0 L0 ${r3(r * 0.2)} L${r3(-r * 0.09)} 0 Z" fill="#C8102E" stroke="#111" stroke-width="3"/><circle r="${r3(r * 0.08)}" fill="#111"/></g></svg>`;
    const js = `      DRAW(q("#${id}-o"), ${t}, 0.5);
      tl.fromTo(q("#${id}-st"), { opacity: 0, scale: 0.3 }, { opacity: 0.9, scale: 1, svgOrigin: "0 0", duration: 0.4, ease: "back.out(2)", immediateRender: false }, ${r3(t + 0.35)});
      tl.to(q("#${id}-n"), { opacity: 1, duration: 0.2 }, ${r3(t + 0.5)});
      tl.fromTo(q("#${id}-k"), { opacity: 0, rotation: -200 }, { opacity: 1, rotation: ${dir + 25}, svgOrigin: "0 0", duration: 0.9, ease: "power2.out", immediateRender: false }, ${r3(t + 0.5)});
      tl.to(q("#${id}-k"), { rotation: ${dir}, svgOrigin: "0 0", duration: 0.6, ease: "elastic.out(1,0.4)" }, ${r3(t + 1.4)});\n`;
    return { over: layer(id, inner), js, sfx: [sfx("click", r3(t + 0.5), 0.2)] };
  } };

const scroll = { id: "scroll", cat: "accent", label: "Cuộn giấy da mở ra kèm dòng chữ (text, x, y, w)",
  run(ctx, o) {
    const { t } = when(ctx, o, 0.3);
    const id = ctx.id, x = o.x ?? 1440, y = o.y ?? 160, w = o.w ?? 640;
    const inner = `<div id="${id}-w" style="position:absolute;left:${r3(x - w / 2)}px;top:${y - 50}px;width:${w}px;height:100px;opacity:0">
      <div id="${id}-p" style="position:absolute;left:${r3(w / 2)}px;right:${r3(w / 2)}px;top:6px;bottom:6px;overflow:hidden;background:#EAD3A2;border-top:5px solid #5A3410;border-bottom:5px solid #5A3410;"><div style="position:absolute;left:50%;top:0;bottom:0;width:${r3(w - 60)}px;transform:translateX(-50%);display:flex;align-items:center;justify-content:center;font-weight:800;font-size:38px;color:#2A1A12;font-style:italic;">${esc(o.text || "Trang nhật ký")}</div></div>
      <div id="${id}-l" style="position:absolute;left:${r3(w / 2 - 24)}px;top:0;width:24px;height:100px;border-radius:12px;background:#8B5A2B;border:4px solid #111"></div>
      <div id="${id}-r" style="position:absolute;left:${r3(w / 2)}px;top:0;width:24px;height:100px;border-radius:12px;background:#8B5A2B;border:4px solid #111"></div></div>`;
    const js = `      tl.fromTo(q("#${id}-w"), { opacity: 0, y: -30 }, { opacity: 1, y: 0, duration: 0.25, ease: "power2.out", immediateRender: false }, ${t});
      tl.to(q("#${id}-l"), { x: ${r3(-(w / 2 - 24))}, duration: 0.6, ease: "power2.out" }, ${r3(t + 0.2)});
      tl.to(q("#${id}-r"), { x: ${r3(w / 2 - 24)}, duration: 0.6, ease: "power2.out" }, ${r3(t + 0.2)});
      tl.fromTo(q("#${id}-p"), { left: ${r3(w / 2)}, right: ${r3(w / 2)} }, { left: 30, right: 30, duration: 0.6, ease: "power2.out", immediateRender: false }, ${r3(t + 0.2)}); // không tween clipPath: hyperframes rớt về chụp chậm\n` +
      (o.out ? `      OUT(q("#${id}-w"), ${r3(t + o.out)}, 0.4);\n` : "");
    return { over: layer(id, inner), js, sfx: [sfx("whooshShort", r3(t + 0.2), 0.25)] };
  } };

const lantern = { id: "lantern", cat: "light", label: "Đèn lồng đỏ treo đung đưa ở mép trên, sáng dần (n, color)",
  run(ctx, o) {
    const { t, d } = when(ctx, o, 0.2);
    const R = rng(ctx.id), id = ctx.id, n = Math.min(6, o.n ?? 4), c = o.color ? color(o.color) : "#D7263D";
    let html = "", js = "";
    for (let i = 0; i < n; i++) {
      const x = r3(140 + (i * 1640) / Math.max(1, n - 1)), len = r3(40 + R() * 70);
      html += `<svg id="${id}-${i}" viewBox="-60 0 120 ${len + 150}" style="position:absolute;left:${x - 60}px;top:-10px;width:120px;height:${len + 150}px;overflow:visible;opacity:0">
        <path d="M0 0 V${len}" stroke="#111" stroke-width="4"/><ellipse cx="0" cy="${len + 60}" rx="70" ry="80" fill="#F7CB46" opacity=".0" class="${id}-h"/>
        <rect x="-26" y="${len}" width="52" height="12" fill="#3A2412"/><ellipse cx="0" cy="${len + 60}" rx="46" ry="52" fill="${c}" stroke="#111" stroke-width="5"/>
        <path d="M-30 ${len + 30} Q0 ${len + 20} 30 ${len + 30} M-34 ${len + 60} H34 M-30 ${len + 90} Q0 ${len + 100} 30 ${len + 90}" stroke="#7A1626" stroke-width="3" fill="none"/>
        <rect x="-22" y="${len + 108}" width="44" height="10" fill="#3A2412"/><path d="M0 ${len + 118} V${len + 145}" stroke="#F7CB46" stroke-width="5"/></svg>`;
      const ti = r3(t + i * 0.12);
      js += `      tl.fromTo(q("#${id}-${i}"), { opacity: 0, y: -120 }, { opacity: 1, y: 0, duration: 0.5, ease: "back.out(1.6)", immediateRender: false }, ${ti});
      tl.fromTo(q("#${id}-${i}"), { rotation: -4 }, { rotation: 4, transformOrigin: "50% 0%", duration: ${r3(1.1 + R() * 0.5)}, yoyo: true, repeat: ${reps(d, 1.1)}, ease: "sine.inOut", immediateRender: false }, ${ti});\n`;
    }
    js += `      tl.to(qa(".${id}-h"), { attr: { opacity: 0.45 }, duration: 0.6 }, ${r3(t + 0.5)});\n`;
    return { over: layer(id, html), js, sfx: [sfx("chime", t, 0.15)] };
  } };

export default [caravan, compass, scroll, lantern];
