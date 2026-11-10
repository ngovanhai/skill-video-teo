// Đom đóm: chấm sáng xanh vàng bay lượn chậm trong một vùng, nhấp nháy tắt bật (đêm quê, bụi tre, gốc cây).
// Tham số: n, x, y, w, h (vùng bay, mặc định cả khung trên y 880), color, at | t, d, layer.
// Quầng sáng vẽ bằng radial-gradient (không filter) để render nhanh.
import { rng, when, layer, reps, r3 } from "./_util.mjs";

const domdom = {
  id: "dom-dom", cat: "atmosphere", label: "Đom đóm bay lượn, nhấp nháy xanh vàng trong vùng (n, x, y, w, h, color)",
  run(ctx, o) {
    const { t, end } = when(ctx, o, 0);
    const R = rng(ctx.id), id = ctx.id;
    const n = o.n ?? 18, X = o.x ?? 0, Y = o.y ?? 120, W = o.w ?? 1920, H = o.h ?? 740;
    const c = o.color || "#C8FF6A";
    let html = "", js = `      FADE(q("#${id}"), ${t}, 0.8);\n`;
    if (o.d != null) js += `      OUT(q("#${id}"), ${r3(Math.max(t + 0.3, end - 0.6))}, 0.6);\n`;
    for (let i = 0; i < n; i++) {
      const s = r3(26 + R() * 22);
      html += `<div class="${id}-m" style="position:absolute;left:${r3(X + R() * W)}px;top:${r3(Y + R() * H)}px;width:${s}px;height:${s}px;">`
        + `<div class="${id}-g" style="position:absolute;inset:0;border-radius:50%;background:radial-gradient(circle, ${c} 0%, ${c} 14%, rgba(200,255,106,0.35) 30%, rgba(200,255,106,0) 70%);opacity:0;"></div></div>`;
      const p = r3(4 + R() * 4), st = r3(Math.max(0, t - R() * p));
      js += `      tl.fromTo(qa(".${id}-m")[${i}], { x: 0, y: 0 }, { x: ${r3((R() - 0.5) * 220)}, y: ${r3((R() - 0.5) * 140)}, duration: ${p}, ease: "sine.inOut", yoyo: true, repeat: ${reps(end - st, p)}, immediateRender: false }, ${st});\n`;
      const b = r3(0.9 + R() * 1.4), sb = r3(Math.max(0, t - R() * b));
      js += `      tl.fromTo(qa(".${id}-g")[${i}], { opacity: 0.05 }, { opacity: 1, duration: ${b}, ease: "sine.inOut", yoyo: true, repeat: ${reps(end - sb, b)}, immediateRender: false }, ${sb});\n`;
    }
    return { [o.layer || "over"]: layer(id, html, "opacity:0;"), js };
  },
};

export default [domdom];
