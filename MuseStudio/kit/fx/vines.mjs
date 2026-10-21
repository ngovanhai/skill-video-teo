// `vines`: rễ cây / dây leo rừng nhiệt đới bò ra từ góc khung, vẽ nét dần, lá non bật ra dọc thân
// (corner "tl"|"tr"|"bl"|"br"|"top" = hai góc trên, n nhánh, color thân, leaf màu lá). Hợp đền đổ nát giữa rừng.
import { when, layer, sfx, r3, color, rng } from "./_util.mjs";

const CORNERS = { tl: [0, 0, 1, 1], tr: [1920, 0, -1, 1], bl: [0, 880, 1, -1], br: [1920, 880, -1, -1] };

const vines = { id: "vines", cat: "atmosphere", label: "Rễ cây / dây leo bò ra từ góc khung + lá bật (corner tl|tr|bl|br|top, n, color, leaf)",
  run(ctx, o) {
    const { t } = when(ctx, o, 0.2);
    const id = ctx.id, n = Math.min(5, o.n ?? 3);
    const stem = o.color ? color(o.color) : "#6B4A2B", leaf = o.leaf ? color(o.leaf) : "#4E9A3A";
    const corners = o.corner === "top" ? ["tl", "tr"] : [o.corner && CORNERS[o.corner] ? o.corner : "tl"];
    const R = rng(id);
    let inner = `<svg viewBox="0 0 1920 1080" style="position:absolute;inset:0;width:100%;height:100%;overflow:visible">`;
    let js = "", k = 0;
    for (const c of corners) {
      const [x0, y0, sx, sy] = CORNERS[c];
      for (let i = 0; i < n; i++, k++) {
        // mỗi nhánh: đường cong uốn lượn dần vào trong khung
        const len = 260 + R() * 260, ang = 0.15 + (i / Math.max(1, n - 1)) * 1.25;
        let d = `M${x0} ${y0}`, px = x0, py = y0;
        const pts = [];
        for (let s = 1; s <= 4; s++) {
          const L = (len / 4) * s, w = (s % 2 ? 1 : -1) * (30 + R() * 30);
          const nx = x0 + sx * (Math.cos(ang) * L - Math.sin(ang) * w), ny = y0 + sy * (Math.sin(ang) * L + Math.cos(ang) * w);
          d += ` Q${r3((px + nx) / 2 + sx * w * 0.6)} ${r3((py + ny) / 2 - sy * w * 0.4)} ${r3(nx)} ${r3(ny)}`;
          px = nx; py = ny; pts.push([nx, ny]);
        }
        const sw = 16 - i * 2.5;
        inner += `<path id="${id}-v${k}" pathLength="1" d="${d}" fill="none" stroke="#111" stroke-width="${r3(sw + 6)}" stroke-linecap="round" style="stroke-dasharray:1;stroke-dashoffset:1"/>`;
        inner += `<path id="${id}-w${k}" pathLength="1" d="${d}" fill="none" stroke="${stem}" stroke-width="${r3(sw)}" stroke-linecap="round" style="stroke-dasharray:1;stroke-dashoffset:1"/>`;
        const tb = r3(t + i * 0.18);
        js += `      tl.fromTo([q("#${id}-v${k}"), q("#${id}-w${k}")], { strokeDashoffset: 1 }, { strokeDashoffset: 0, duration: 1.1, ease: "power2.out", immediateRender: false }, ${tb});\n`;
        pts.slice(0, 3).forEach(([lx, ly], j) => {
          const rot = r3((R() * 120 - 60) + (sx < 0 ? 180 : 0));
          inner += `<g transform="translate(${r3(lx)} ${r3(ly)}) rotate(${rot})"><path id="${id}-l${k}-${j}" d="M0 0 Q22 -20 46 0 Q22 20 0 0 Z" fill="${leaf}" stroke="#111" stroke-width="4" style="transform:scale(0);transform-origin:0 0"/></g>`;
          js += `      tl.to(q("#${id}-l${k}-${j}"), { scale: 1, duration: 0.3, ease: "back.out(2.5)" }, ${r3(t + i * 0.18 + 0.3 + j * 0.25)});\n`;
        });
      }
    }
    inner += `</svg>`;
    return { [o.layer === "over" ? "over" : "back"]: layer(id, inner), js, sfx: o.sound === false ? [] : [sfx("whooshShort", t, 0.12)] };
  } };

export default [vines];
