// `hieroglyph`: một cột chữ tượng hình Ai Cập (mắt, ankh, chim, sóng nước, cây sậy, bọ hung) vẽ nét dần
// từ trên xuống ở mép khung (x, y, n, color, side "left"|"right"), như dòng khắc trên vách mộ.
import { when, layer, sfx, r3, color } from "./_util.mjs";

const GLYPHS = [
  // mắt Horus
  `<path pathLength="1" d="M-34 0 Q0 -26 34 0 Q0 22 -34 0 Z M-8 0 a8 8 0 1 0 16 0 a8 8 0 1 0 -16 0 M-6 14 L-14 34 M6 14 Q14 30 26 26"/>`,
  // ankh
  `<path pathLength="1" d="M0 -6 Q-22 -24 0 -40 Q22 -24 0 -6 Z M-24 -2 L24 -2 M0 -6 L0 40"/>`,
  // chim
  `<path pathLength="1" d="M-30 18 Q-10 -6 10 -14 Q22 -30 32 -18 L22 -12 Q24 14 0 22 Z M-6 22 L-10 38 M6 22 L8 38"/>`,
  // sóng nước
  `<path pathLength="1" d="M-36 -10 l9 -9 l9 9 l9 -9 l9 9 l9 -9 l9 9 l9 -9 M-36 10 l9 -9 l9 9 l9 -9 l9 9 l9 -9 l9 9 l9 -9"/>`,
  // cây sậy
  `<path pathLength="1" d="M0 38 L0 -24 M0 -24 Q16 -36 10 -10 M0 -10 Q-14 -20 -10 0"/>`,
  // bọ hung + mặt trời
  `<path pathLength="1" d="M0 -32 a12 12 0 1 0 0.1 0 M-18 0 Q0 -16 18 0 Q22 26 0 32 Q-22 26 -18 0 Z M0 -6 L0 30 M-18 6 L-32 0 M18 6 L32 0 M-16 22 L-30 30 M16 22 L30 30"/>`,
];

const hieroglyph = { id: "hieroglyph", cat: "accent", label: "Cột chữ tượng hình vẽ nét dần ở mép khung (x, y, n, color, side)",
  run(ctx, o) {
    const { t } = when(ctx, o, 0.3);
    const id = ctx.id, n = Math.min(8, o.n ?? 6), c = o.color ? color(o.color) : "#C8962E";
    const x = o.x ?? (o.side === "left" ? 70 : 1850), y0 = o.y ?? 120, gap = Math.min(110, (850 - y0) / n);
    let inner = `<svg viewBox="0 0 1920 1080" style="position:absolute;inset:0;width:100%;height:100%;overflow:visible">
      <rect id="${id}-band" x="${x - 52}" y="${y0 - 60}" width="104" height="${r3(gap * n + 40)}" rx="10" fill="#F3E2B8" stroke="#111" stroke-width="5" opacity="0"/>`;
    let js = `      FADE(q("#${id}-band"), ${t}, 0.3);\n`;
    for (let i = 0; i < n; i++) {
      inner += `<g transform="translate(${x} ${r3(y0 + i * gap)}) scale(0.95)" fill="none" stroke="${c}" stroke-width="6" stroke-linecap="round" stroke-linejoin="round"><g id="${id}-g${i}" style="stroke-dasharray:1;stroke-dashoffset:1">${GLYPHS[(i + (o.offset ?? 0)) % GLYPHS.length]}</g></g>`;
      js += `      tl.fromTo(qa("#${id}-g${i} path"), { strokeDashoffset: 1 }, { strokeDashoffset: 0, duration: 0.45, ease: "power1.inOut", immediateRender: false }, ${r3(t + 0.2 + i * 0.22)});\n`;
    }
    inner += `</svg>`;
    return { [o.layer === "over" ? "over" : "back"]: layer(id, inner), js, sfx: o.sound === false ? [] : [sfx("sparkle", t, 0.12)] };
  } };

export default [hieroglyph];
