// `bong-nay`: quả bóng quần vợt trắng ngà (kiểu thập niên 1930) bay vào từ một mép, nảy 2 lần trên "mặt sân" ở độ cao y,
// để lại vết bóng in trên đất nện, rồi bay ra mép kia. Dùng cho chuyển ý, điểm số, "bóng ra ngoài" (out: true thêm dấu X đỏ ở cú nảy cuối).
// Tham số: y (sàn, mặc định 800), dir left|right, x1, x2 (điểm nảy), color (bóng), mark (màu vết), out, n (số bóng 1–3)
import { when, layer, sfx, r3, rng } from "./_util.mjs";

const ballSvg = (c) => `<svg viewBox="-50 -50 100 100" style="width:100%;height:100%;overflow:visible">
  <circle r="44" fill="${c}" stroke="#1C1A1E" stroke-width="5"/>
  <path d="M-40 -16 Q0 -2 -16 40 M40 16 Q0 2 16 -40" fill="none" stroke="#C9B48C" stroke-width="4"/>
  <ellipse cx="-15" cy="-18" rx="10" ry="5" fill="#fff" opacity=".7" transform="rotate(-30 -15 -18)"/></svg>`;

const bongNay = { id: "bong-nay", cat: "accent", label: "Bóng quần vợt trắng bay vào, nảy 2 lần để lại vết trên đất nện rồi bay ra (y, dir, x1, x2, out, n, color)",
  run(ctx, o) {
    const { t } = when(ctx, o, 0.4);
    const id = ctx.id, R = rng(id);
    const n = Math.max(1, Math.min(3, o.n ?? 1));
    const floor = Math.min(860, o.y ?? 800), dir = o.dir === "left" ? -1 : 1;
    const startX = dir > 0 ? -120 : 2040, endX = dir > 0 ? 2040 : -120;
    let inner = "", js = "";
    const sf = [];
    for (let i = 0; i < n; i++) {
      const tb = r3(t + i * 0.35);
      const x1 = r3((o.x1 ?? (dir > 0 ? 700 : 1220)) + (R() - 0.5) * 120 + i * 60 * dir);
      const x2 = r3((o.x2 ?? (dir > 0 ? 1240 : 680)) + (R() - 0.5) * 120 + i * 60 * dir);
      const fl = floor - i * 18;
      [x1, x2].forEach((x, k) => {
        inner += `<div id="${id}-m${i}${k}" style="position:absolute;left:${x - 42}px;top:${fl + 30}px;width:84px;height:22px;border-radius:50%;background:radial-gradient(ellipse, rgba(110,40,20,.55) 0%, rgba(110,40,20,0) 70%);opacity:0;"></div>`;
      });
      inner += `<div id="${id}-b${i}" style="position:absolute;left:${startX - 45}px;top:${fl - 45}px;width:90px;height:90px;opacity:0;">${ballSvg(o.color || "#F4F0E2")}</div>`;
      const dx1 = r3(x1 - startX), dx2 = r3(x2 - startX), dx3 = r3(endX - startX);
      js += `      tl.set(q("#${id}-b${i}"), { opacity: 1, x: 0, y: -420 }, ${tb});
      tl.to(q("#${id}-b${i}"), { x: ${dx1}, y: 0, rotation: ${dir * 360}, duration: 0.42, ease: "power1.in" }, ${tb});
      tl.to(q("#${id}-b${i}"), { x: ${r3((dx1 + dx2) / 2)}, y: -260, rotation: ${dir * 600}, duration: 0.3, ease: "power1.out" }, ${r3(tb + 0.42)});
      tl.to(q("#${id}-b${i}"), { x: ${dx2}, y: 0, rotation: ${dir * 840}, duration: 0.3, ease: "power1.in" }, ${r3(tb + 0.72)});
      tl.to(q("#${id}-b${i}"), { x: ${dx3}, y: -360, rotation: ${dir * 1200}, duration: 0.5, ease: "power1.out" }, ${r3(tb + 1.02)});
      tl.set(q("#${id}-m${i}0"), { opacity: 1 }, ${r3(tb + 0.42)});
      tl.set(q("#${id}-m${i}1"), { opacity: 1 }, ${r3(tb + 1.02)});\n`;
      sf.push(sfx("click", r3(tb + 0.42), 0.3), sfx("click", r3(tb + 1.02), 0.25));
    }
    if (o.out) {
      const x = o.x2 ?? (dir > 0 ? 1240 : 680);
      inner += `<svg style="position:absolute;inset:0;width:100%;height:100%;overflow:visible" viewBox="0 0 1920 1080"><path id="${id}-x" d="M${x - 40} ${floor - 10} l80 80 M${x + 40} ${floor - 10} l-80 80" stroke="#B8322A" stroke-width="14" stroke-linecap="round" fill="none" pathLength="1" stroke-dasharray="1" stroke-dashoffset="1"/></svg>`;
      js += `      tl.fromTo(q("#${id}-x"), { strokeDashoffset: 1 }, { strokeDashoffset: 0, duration: 0.3, immediateRender: false }, ${r3(t + 1.05)});\n`;
    }
    return { [o.layer === "back" ? "back" : "over"]: layer(id, inner), js, sfx: o.sound === false ? [] : sf };
  } };

export default [bongNay];
