// `brush`: nét bút lông mực tàu quét ngang khung (x, y, w, color, angle, out) — chuyển ý, nhấn mạnh kiểu thư pháp.
// `seal`: ấn son đỏ đóng "cộp" lên khung (text, x, y, size, rot, color) — vd "SỬ CHÉP" / "GIAI THOẠI".
// `war-drum`: trống trận ở góc khung, mỗi nhịp mặt trống rung + chữ TÙNG! (x, y, n nhịp, gap giây, text).
import { rng, when, layer, sfx, r3, esc, color } from "./_util.mjs";

const brush = { id: "brush", cat: "accent", label: "Nét bút lông mực quét ngang + giọt mực (x, y, w, color, angle, out giây)",
  run(ctx, o) {
    const { t } = when(ctx, o, 0.2);
    const R = rng(ctx.id), id = ctx.id, x = o.x ?? 960, y = o.y ?? 480, w = o.w ?? 1500, c = o.color ? color(o.color) : "#111";
    const a = o.angle ?? -4, h = o.h ?? 70;
    const x0 = -w / 2, x1 = w / 2;
    const d = `M${x0} 0 C ${x0 + w * 0.25} ${-h * 0.5}, ${x0 + w * 0.6} ${h * 0.4}, ${x1} ${-h * 0.15}`;
    let drops = "";
    for (let i = 0; i < 7; i++) drops += `<circle class="${id}-d" cx="${r3(x0 + R() * w)}" cy="${r3((R() - 0.5) * h * 2.4)}" r="${r3(4 + R() * 9)}" fill="${c}" opacity="0"/>`;
    const inner = `<svg viewBox="${-w / 2 - 60} ${-h * 2} ${w + 120} ${h * 4}" style="position:absolute;left:${r3(x - w / 2 - 60)}px;top:${r3(y - h * 2)}px;width:${w + 120}px;height:${h * 4}px;overflow:visible;transform:rotate(${a}deg)">
        <path id="${id}-p" d="${d}" pathLength="1" fill="none" stroke="${c}" stroke-width="${h}" stroke-linecap="round" stroke-dasharray="1" stroke-dashoffset="1" opacity="${o.opacity ?? 0.92}"/>
        <path id="${id}-p2" d="${d}" pathLength="1" fill="none" stroke="${c}" stroke-width="${r3(h * 0.35)}" stroke-linecap="round" stroke-dasharray="1" stroke-dashoffset="1" opacity=".5" transform="translate(0 ${r3(h * 0.55)})"/>${drops}</svg>`;
    let js = `      DRAW(q("#${id}-p"), ${t}, ${o.speed ?? 0.5});
      DRAW(q("#${id}-p2"), ${r3(t + 0.08)}, ${o.speed ?? 0.5});
      tl.to(qa(".${id}-d"), { attr: { opacity: 0.85 }, duration: 0.05, stagger: 0.04 }, ${r3(t + 0.3)});\n`;
    if (o.out) js += `      OUT(q("#${id}"), ${r3(t + o.out)}, 0.4);\n`;
    return { [o.layer || "over"]: layer(id, inner), js, sfx: [sfx("whooshShort", t, 0.3)] };
  } };

const seal = { id: "seal", cat: "accent", label: "Ấn son đỏ đóng cộp (text, x, y, size, rot, color) — SỬ CHÉP / GIAI THOẠI",
  run(ctx, o) {
    const { t } = when(ctx, o, 0.5);
    const id = ctx.id, x = o.x ?? 1560, y = o.y ?? 200, s = o.size ?? 230, c = o.color ? color(o.color) : "#C8102E";
    const text = esc(o.text || "SỬ CHÉP");
    const words = text.split(" ");
    const fs = Math.round(Math.min(s * 0.36, (s * 1.5) / Math.max(...words.map((w) => w.length))));
    const inner = `<div id="${id}-s" style="position:absolute;left:${r3(x - s / 2)}px;top:${r3(y - s / 2)}px;width:${s}px;height:${s}px;border:${Math.round(s * 0.06)}px solid ${c};outline:${Math.round(s * 0.02)}px solid ${c};outline-offset:-${Math.round(s * 0.11)}px;border-radius:${Math.round(s * 0.08)}px;display:flex;flex-direction:column;align-items:center;justify-content:center;color:${c};font-weight:800;font-size:${fs}px;line-height:1.05;text-align:center;letter-spacing:1px;background:rgba(255,250,240,.35);opacity:0;transform:rotate(${o.rot ?? -10}deg) scale(2.2);">${words.map((w) => `<span>${w}</span>`).join("")}</div>`;
    const js = `      tl.fromTo(q("#${id}-s"), { opacity: 0, scale: 2.2 }, { opacity: 0.95, scale: 1, duration: 0.22, ease: "power4.in", immediateRender: false }, ${t});
      tl.fromTo(q("#${id}-s"), { x: -4 }, { x: 4, duration: 0.05, yoyo: true, repeat: 3, ease: "none", immediateRender: false }, ${r3(t + 0.22)});\n`;
    return { over: layer(id, inner), js, sfx: o.sound === false ? [] : [sfx("impact2", r3(t + 0.2), 0.35)] };
  } };

const warDrum = { id: "war-drum", cat: "accent", label: "Trống trận góc khung, mỗi nhịp rung + chữ TÙNG! (x, y, n, gap, text)",
  run(ctx, o) {
    const { t } = when(ctx, o, 0.2);
    const id = ctx.id, x = o.x ?? 1700, y = o.y ?? 170, n = o.n ?? 3, gap = o.gap ?? 0.55;
    const word = esc(o.text || "TÙNG!");
    const drum = `<svg viewBox="-110 -110 220 220" style="position:absolute;left:${x - 110}px;top:${y - 110}px;width:220px;height:220px;overflow:visible">
        <g id="${id}-dr"><rect x="-80" y="-30" width="160" height="110" rx="20" fill="#B3262D" stroke="#111" stroke-width="7"/>
        <path d="M-80 0 H80 M-80 50 H80" stroke="#7A1626" stroke-width="6"/>
        <ellipse cx="0" cy="-30" rx="80" ry="26" fill="#F4E3C1" stroke="#111" stroke-width="7"/>
        <circle cx="0" cy="-30" r="12" fill="#C98A3A"/></g>
        <path id="${id}-st" d="M70 -100 L18 -36" stroke="#111" stroke-width="14" stroke-linecap="round"/></svg>`;
    let words = "";
    for (let i = 0; i < n; i++) words += `<div class="${id}-w" style="position:absolute;left:${x - 120 - (i % 2) * 60}px;top:${y + 90 + (i % 2) * 20}px;font-weight:900;font-size:56px;color:#F7CB46;-webkit-text-stroke:3px #111;transform:rotate(${i % 2 ? 8 : -8}deg);opacity:0;">${word}</div>`;
    let js = `      tl.fromTo(q("#${id}-wrap"), { opacity: 0, y: -40 }, { opacity: 1, y: 0, duration: 0.3, ease: "back.out(2)", immediateRender: false }, ${t});\n`;
    const S = [];
    for (let i = 0; i < n; i++) {
      const tb = r3(t + 0.35 + i * gap);
      js += `      tl.fromTo(q("#${id}-st"), { rotation: 0 }, { rotation: 18, svgOrigin: "70 -100", duration: 0.08, yoyo: true, repeat: 1, ease: "power2.in", immediateRender: false }, ${tb});
      tl.fromTo(q("#${id}-dr"), { scale: 1 }, { scale: 1.12, svgOrigin: "0 0", duration: 0.08, yoyo: true, repeat: 1, immediateRender: false }, ${r3(tb + 0.08)});
      tl.fromTo(qa(".${id}-w")[${i}], { opacity: 0, scale: 0.4 }, { opacity: 1, scale: 1, duration: 0.15, ease: "back.out(3)", immediateRender: false }, ${r3(tb + 0.08)});
      tl.to(qa(".${id}-w")[${i}], { opacity: 0, duration: 0.25 }, ${r3(tb + 0.5)});\n`;
      S.push(sfx("impact", r3(tb + 0.08), 0.28));
    }
    return { over: layer(id, `<div id="${id}-wrap" style="position:absolute;inset:0;opacity:0;">${drum}${words}</div>`), js, sfx: o.sound === false ? [] : S };
  } };

export default [brush, seal, warDrum];
