// Dòng điện chạy dọc một sợi dây ngang khung: mode "dc" = các đốm sáng chạy một chiều trái→phải,
// mode "ac" = các đốm lắc tới lui tại chỗ (đổi chiều). (y, x1, x2, mode, color, n)
import { when, layer, sfx, r3, color, reps } from "./_util.mjs";

const dongDien = { id: "dong-dien", cat: "accent", label: "Dòng điện chạy dọc dây ngang: dc chạy một chiều, ac lắc tới lui (y, x1, x2, mode, color, n)",
  run(ctx, o) {
    const { t, d } = when(ctx, o, 0.2);
    const id = ctx.id, ac = o.mode === "ac";
    const c = o.color ? color(o.color) : ac ? "#8DB8F2" : "#F08A80";
    const y = o.y ?? 850, x1 = o.x1 ?? 80, x2 = o.x2 ?? 1840, n = o.n ?? 8, L = x2 - x1;
    let html = `<div style="position:absolute;left:${x1}px;top:${y - 4}px;width:${L}px;height:8px;border-radius:4px;background:${c};opacity:0.45;"></div>`;
    let js = `      tl.set(q("#${id}"), { opacity: 1 }, ${t});\n`;
    for (let i = 0; i < n; i++) {
      const x0 = x1 + (L * i) / n;
      html += `<div id="${id}-d${i}" style="position:absolute;left:${r3(x0 - 16)}px;top:${y - 16}px;width:32px;height:32px;border-radius:50%;background:radial-gradient(circle, #fff 0%, ${c} 40%, rgba(255,255,255,0) 72%);"></div>`;
      if (ac) {
        const step = 0.25, k = Math.min(80, Math.floor(d / step));
        for (let j = 0; j < k; j++) js += `      tl.to(q("#${id}-d${i}"), { x: ${j % 2 ? -40 : 40}, duration: ${step}, ease: "sine.inOut" }, ${r3(t + j * step)});\n`;
      } else {
        const span = L / n;
        js += `      tl.fromTo(q("#${id}-d${i}"), { x: 0 }, { x: ${r3(span)}, duration: 0.6, ease: "none", repeat: ${reps(d, 0.6)}, immediateRender: false }, ${t});\n`;
      }
    }
    if (!ac) html = `<div style="position:absolute;left:${x1}px;top:${y - 20}px;width:${L}px;height:40px;overflow:hidden;"><div style="position:absolute;left:${-x1}px;top:${-(y - 20)}px;width:1920px;height:1080px;">${html}</div></div>`;
    js += `      OUT(q("#${id}"), ${r3(t + d - 0.25)}, 0.2);\n`;
    return { [o.layer || "over"]: layer(id, html, "opacity:0;"), js, sfx: [sfx("whooshShort", t, 0.15)] };
  } };

export default [dongDien];
