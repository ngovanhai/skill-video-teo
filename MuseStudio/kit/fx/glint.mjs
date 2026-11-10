// `glint`: ánh kim lấp lánh trên bề mặt kim loại — vệt sáng chéo quét qua một vùng tròn (x, y, r)
// rồi ngôi sao 4 cánh loé ở (sx, sy). Dùng cho vàng, huy chương, cúp. Không filter, không clipPath tween.
import { when, layer, sfx, r3 } from "./_util.mjs";

const glint = { id: "glint", cat: "light", label: "Ánh kim lấp lánh: vệt sáng chéo quét qua vùng tròn (x, y, r) + sao 4 cánh loé (sx, sy), color",
  run(ctx, o) {
    const { t } = when(ctx, o, 0.3);
    const id = ctx.id, x = o.x ?? 960, y = o.y ?? 440, r = o.r ?? 200;
    const sx = o.sx ?? x + r * 0.45, sy = o.sy ?? y - r * 0.45, c = o.color || "#FFF6D0";
    const star = (s) => `<svg viewBox="-50 -50 100 100" style="width:${s}px;height:${s}px;overflow:visible"><path d="M0 -50 Q6 -6 50 0 Q6 6 0 50 Q-6 6 -50 0 Q-6 -6 0 -50 Z" fill="${c}"/><circle r="9" fill="#FFFFFF"/></svg>`;
    const inner = `<div id="${id}-disc" style="position:absolute;left:${x - r}px;top:${y - r}px;width:${2 * r}px;height:${2 * r}px;border-radius:50%;overflow:hidden;opacity:0;">
        <div id="${id}-band" style="position:absolute;left:${-r}px;top:${-r}px;width:${Math.round(r * 0.5)}px;height:${4 * r}px;background:linear-gradient(90deg, rgba(255,255,255,0) 0%, rgba(255,250,225,0.75) 50%, rgba(255,255,255,0) 100%);transform:rotate(30deg);"></div>
      </div>
      <div id="${id}-st" style="position:absolute;left:${sx - 60}px;top:${sy - 60}px;width:120px;height:120px;opacity:0;">${star(120)}</div>`;
    const js = `      tl.set(q("#${id}-disc"), { opacity: 1 }, ${t});
      tl.fromTo(q("#${id}-band"), { x: 0 }, { x: ${r3(r * 3.2)}, duration: 0.7, ease: "power2.inOut", immediateRender: false }, ${t});
      tl.set(q("#${id}-disc"), { opacity: 0 }, ${r3(t + 0.75)});
      tl.fromTo(q("#${id}-st"), { opacity: 0, scale: 0, rotation: -45 }, { opacity: 1, scale: 1, rotation: 0, duration: 0.3, ease: "back.out(2)", immediateRender: false }, ${r3(t + 0.45)});
      tl.to(q("#${id}-st"), { opacity: 0, scale: 0.2, rotation: 45, duration: 0.4, ease: "power2.in" }, ${r3(t + 0.8)});\n`;
    return { over: layer(id, inner), js, sfx: o.sound === false ? [] : [sfx("sparkle", t + 0.4, 0.2)] };
  } };

export default glint;
