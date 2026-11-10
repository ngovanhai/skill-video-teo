// `phosphor`: vệt quét màn hình ống tia âm cực — một dải sáng xanh phosphor (hoặc hổ phách) chạy từ trên xuống,
// kèm chớp mờ toàn khung và lớp vạch quét nhòe đi. Dùng cho mã lỗi, số liệu bật lên, cảnh phòng điều khiển.
// Tham số: color (mặc định #5BE38A), n (số lần quét, mặc định 1), y0/y1 (vùng quét), strength (0..1). Không filter.
import { when, layer, sfx, r3 } from "./_util.mjs";

const phosphor = { id: "phosphor", cat: "light", label: "Vệt quét màn hình phosphor chạy dọc + chớp mờ (color, n, y0, y1, strength)",
  run(ctx, o) {
    const { t } = when(ctx, o, 0.2);
    const id = ctx.id, c = o.color || "#5BE38A", n = Math.max(1, Math.min(4, o.n ?? 1));
    const y0 = o.y0 ?? 0, y1 = o.y1 ?? 880, k = o.strength ?? 0.6;
    const inner = `<div id="${id}-fl" style="position:absolute;inset:0;background:radial-gradient(ellipse at 50% 45%, ${c}55 0%, ${c}00 70%);opacity:0;"></div>
      <div id="${id}-bd" style="position:absolute;left:0;top:${y0 - 60}px;width:1920px;height:120px;background:linear-gradient(180deg, ${c}00 0%, ${c}99 48%, #FFFFFFAA 50%, ${c}99 52%, ${c}00 100%);opacity:0;"></div>
      <div id="${id}-sl" style="position:absolute;left:0;top:${y0}px;width:1920px;height:${y1 - y0}px;background:repeating-linear-gradient(180deg, ${c}22 0 2px, ${c}00 2px 6px);opacity:0;"></div>`;
    let js = `      tl.fromTo(q("#${id}-fl"), { opacity: 0 }, { opacity: ${k}, duration: 0.12, ease: "none", yoyo: true, repeat: 1, immediateRender: false }, ${t});
      tl.fromTo(q("#${id}-sl"), { opacity: ${r3(k * 0.9)} }, { opacity: 0, duration: 1.2, ease: "power1.out", immediateRender: false }, ${t});\n`;
    for (let i = 0; i < n; i++) {
      const ti = r3(t + i * 0.55);
      js += `      tl.fromTo(q("#${id}-bd"), { opacity: 1, y: 0 }, { opacity: 0.2, y: ${y1 - y0}, duration: 0.5, ease: "power1.in", immediateRender: false }, ${ti});\n`;
    }
    js += `      tl.set(q("#${id}-bd"), { opacity: 0 }, ${r3(t + n * 0.55)});\n`;
    return { over: layer(id, inner), js, sfx: o.sound === false ? [] : [sfx("glitch", t, 0.15)] };
  } };

export default phosphor;
