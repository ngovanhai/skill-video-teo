// Giấy vụn / mẩu báo cắt rơi xoay chậm khắp khung (tòa soạn, bản tin, kho lưu trữ).
// Tham số: n (số mẩu), color (màu giấy), ink (màu vạch chữ), layer (over/back), at | t, d
import { rng, when, layer, reps, r3 } from "./_util.mjs";

const giayVun = { id: "giay-vun", cat: "atmosphere", label: "Mẩu giấy báo vụn rơi xoay chậm (n, color, ink, layer)",
  run(ctx, o) {
    const { t, end } = when(ctx, o, 0);
    const R = rng(ctx.id), id = ctx.id, n = o.n ?? 18;
    const paper = o.color || "#F2EBDA", ink = o.ink || "rgba(21,21,21,0.55)";
    let html = "", js = `      FADE(q("#${id}"), ${t}, 0.6);\n`;
    for (let i = 0; i < n; i++) {
      const w = r3(34 + R() * 46), h = r3(22 + R() * 30), x = r3(R() * 1920), rot = r3(R() * 360);
      const lines = `repeating-linear-gradient(180deg, transparent 0 5px, ${ink} 5px 7px)`;
      html += `<div class="${id}-p" style="position:absolute;left:${x}px;top:-80px;width:${w}px;height:${h}px;background:${lines}, ${paper};border:1.5px solid rgba(21,21,21,0.6);transform:rotate(${rot}deg);"></div>`;
      const p = r3(7 + R() * 6);
      const start = r3(Math.max(0, t - R() * p));
      js += `      tl.fromTo(qa(".${id}-p")[${i}], { y: 0, x: 0, rotation: ${rot} }, { y: 1200, x: ${r3((R() - 0.5) * 260)}, rotation: ${r3(rot + (R() > 0.5 ? 1 : -1) * (180 + R() * 360))}, duration: ${p}, ease: "none", repeat: ${reps(end - start, p)}, immediateRender: false }, ${start});\n`;
    }
    return { [o.layer || "over"]: layer(id, html, "opacity:0;"), js };
  },
};
export default giayVun;
