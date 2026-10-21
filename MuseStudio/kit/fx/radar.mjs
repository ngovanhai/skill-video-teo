// `radar`: màn hình radar tròn góc khung, tia quét xoay, các chấm sáng (blip) hiện rồi lần lượt tắt — mất liên lạc, mất tích.
// Tham số: x, y (tâm), r (bán kính), n (số chấm), lose (true: chấm tắt dần hết), label (chữ dưới màn), color.
import { rng, when, layer, sfx, r3, esc, reps } from "./_util.mjs";

const radar = { id: "radar", cat: "accent", label: "Màn radar quét, chấm sáng hiện rồi tắt dần (x, y, r, n, lose, label, color)",
  run(ctx, o) {
    const { t, d } = when(ctx, o, 0.3);
    const id = ctx.id, x = o.x ?? 1620, y = o.y ?? 250, r = o.r ?? 190, n = Math.min(8, o.n ?? 5);
    const c = o.color || "#39FF8C", rand = rng(String(id).length * 31 + n);
    let blips = "";
    for (let i = 0; i < n; i++) {
      const a = rand() * Math.PI * 2, rr = r * (0.3 + rand() * 0.55);
      blips += `<circle class="${id}-b" cx="${r3(r + Math.cos(a) * rr)}" cy="${r3(r + Math.sin(a) * rr)}" r="11" fill="${c}" opacity="0"/>`;
    }
    const s = 2 * r;
    const inner = `<div id="${id}-box" style="position:absolute;left:${r3(x - r)}px;top:${r3(y - r)}px;width:${s}px;height:${s + 70}px;opacity:0;">
        <svg viewBox="0 0 ${s} ${s}" style="position:absolute;left:0;top:0;width:${s}px;height:${s}px;overflow:visible">
          <defs><linearGradient id="${id}-gr" x1="0" y1="0" x2="1" y2="0"><stop offset="0" stop-color="${c}" stop-opacity="0"/><stop offset="1" stop-color="${c}" stop-opacity=".75"/></linearGradient></defs>
          <circle cx="${r}" cy="${r}" r="${r}" fill="#06231A" stroke="#111" stroke-width="10"/>
          <circle cx="${r}" cy="${r}" r="${r3(r * 0.66)}" fill="none" stroke="${c}" stroke-opacity=".35" stroke-width="3"/>
          <circle cx="${r}" cy="${r}" r="${r3(r * 0.33)}" fill="none" stroke="${c}" stroke-opacity=".35" stroke-width="3"/>
          <path d="M${r} 8 V${s - 8} M8 ${r} H${s - 8}" stroke="${c}" stroke-opacity=".3" stroke-width="3"/>
          <g id="${id}-sw" style="transform-origin:${r}px ${r}px"><path d="M${r} ${r} L${s - 6} ${r} A${r - 6} ${r - 6} 0 0 0 ${r3(r + (r - 6) * Math.cos(-0.7))} ${r3(r + (r - 6) * Math.sin(-0.7))} Z" fill="url(#${id}-gr)"/>
            <path d="M${r} ${r} L${s - 6} ${r}" stroke="${c}" stroke-width="5"/></g>
          ${blips}<circle cx="${r}" cy="${r}" r="8" fill="${c}"/></svg>
        ${o.label ? `<div style="position:absolute;left:-60px;top:${s + 10}px;width:${s + 120}px;text-align:center;font-weight:800;font-size:40px;color:${c};text-shadow:3px 3px 0 #111;">${esc(o.label)}</div>` : ""}</div>`;
    const sweep = 2.4, show = r3(t + 0.4), lose = o.lose !== false;
    let js = `      FADE(q("#${id}-box"), ${t}, 0.35);
      tl.to(q("#${id}-sw"), { rotation: 360, duration: ${sweep}, ease: "none", repeat: ${reps(d, sweep)} }, ${t});
      qa(".${id}-b").forEach(function (b, i) { tl.to(b, { attr: { opacity: 1 }, duration: 0.15 }, ${show} + i * 0.25); });\n`;
    if (lose) js += `      qa(".${id}-b").forEach(function (b, i) { tl.to(b, { attr: { opacity: 0 }, duration: 0.4 }, ${r3(t + Math.max(1.6, d * 0.45))} + i * ${r3(Math.min(0.7, d * 0.4 / n))}); });\n`;
    return { over: layer(id, inner), js, sfx: o.sound === false ? [] : [sfx("click", show, 0.2), sfx("riser", t + 0.2, 0.15)] };
  } };

export default [radar];
