// Fuse fx: `fuse` — dây cháy chậm chạy ngang khung, đốm lửa bò dọc dây, phần dây phía sau cháy mất.
// Tham số: x1, x2, y (mặc định mép trên y 70), d (giây cháy), color (lửa), boom (chữ bật ra khi cháy hết, vd "BÙM!").
import { rng, when, layer, reps, sfx, r3, color } from "./_util.mjs";

const fuse = { id: "fuse", cat: "accent", label: "Dây cháy chậm: đốm lửa bò dọc dây ngang khung, dây cháy dần (x1, x2, y, d, color, boom)",
  run(ctx, o) {
    const { t, d } = when(ctx, o, 0.2);
    const R = rng(ctx.id), id = ctx.id, c = o.color ? color(o.color) : "#FFB020";
    const x1 = o.x1 ?? 120, x2 = o.x2 ?? 1800, y = Math.min(o.y ?? 70, 860);
    const burn = r3(Math.max(0.6, d - (o.boom ? 0.6 : 0.1)));
    let rays = "";
    for (let i = 0; i < 8; i++) {
      const a = (Math.PI * 2 * i) / 8 + R() * 0.4, L = 26 + R() * 18;
      rays += `<path d="M0 0 L${r3(Math.cos(a) * L)} ${r3(Math.sin(a) * L)}" stroke="${c}" stroke-width="5" stroke-linecap="round"/>`;
    }
    const rope = `M${x1} ${y} L${x2} ${y}`;
    const inner = `<svg viewBox="0 0 1920 1080" style="position:absolute;inset:0;width:1920px;height:1080px;overflow:visible">
      <path id="${id}-rope" d="${rope}" pathLength="1" stroke-dasharray="1 1" stroke-dashoffset="0" stroke="#111" stroke-width="16" stroke-linecap="round" fill="none"/>
      <path id="${id}-rope2" d="${rope}" pathLength="1" stroke-dasharray="1 1" stroke-dashoffset="0" stroke="#C98A3A" stroke-width="8" fill="none"/>
      <g transform="translate(${x1} ${y})"><g id="${id}-head"><g id="${id}-sp">${rays}</g><circle r="14" fill="#fff" stroke="${c}" stroke-width="6"/></g></g>
      ${o.boom ? `<g transform="translate(${x2} ${y})"><g id="${id}-boom" opacity="0"><circle r="70" fill="${c}" stroke="#111" stroke-width="6"/></g></g>` : ""}
    </svg>${o.boom ? `<div id="${id}-bt" style="position:absolute;left:${x2 - 150}px;top:${y - 32}px;width:300px;text-align:center;font:700 64px/1 'Space Grotesk',sans-serif;color:#fff;-webkit-text-stroke:3px #111;opacity:0;">${o.boom}</div>` : ""}`;
    let js = `      tl.set(q("#${id}"), { opacity: 1 }, ${t});
      tl.fromTo([q("#${id}-rope"), q("#${id}-rope2")], { attr: { "stroke-dashoffset": 0 } }, { attr: { "stroke-dashoffset": -1 }, duration: ${burn}, ease: "none", immediateRender: false }, ${t});
      tl.fromTo(q("#${id}-head"), { x: 0 }, { x: ${x2 - x1}, duration: ${burn}, ease: "none", immediateRender: false }, ${t});
      tl.fromTo(q("#${id}-sp"), { scale: 0.6, rotation: 0, svgOrigin: "0 0" }, { scale: 1.25, rotation: 25, svgOrigin: "0 0", duration: 0.12, yoyo: true, repeat: ${reps(burn, 0.12)}, ease: "none", immediateRender: false }, ${t});\n`;
    const end = r3(t + burn);
    if (o.boom) {
      js += `      tl.set(q("#${id}-head"), { opacity: 0 }, ${end});
      tl.fromTo(q("#${id}-boom"), { opacity: 0, scale: 0.2, svgOrigin: "0 0" }, { opacity: 1, scale: 1.4, svgOrigin: "0 0", duration: 0.3, ease: "back.out(2)", immediateRender: false }, ${end});
      POP(q("#${id}-bt"), ${end});\n`;
    } else js += `      OUT(q("#${id}-head"), ${end}, 0.2);\n`;
    const s = [sfx(o.sound || "riser", t, 0.18)];
    if (o.boom) s.push(sfx("impact", end, 0.3));
    return { [o.layer || "over"]: layer(id, inner, "opacity:0;"), js, sfx: s };
  } };

export default [fuse];
