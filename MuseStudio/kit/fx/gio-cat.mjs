// `gio-cat`: một (hoặc vài) cơn gió cát quét ngang khung — dải vệt gió trắng mờ + hạt cát vàng bay theo,
// thân khung hơi rung khi cơn gió đi qua. Tham số: n (số cơn, mặc định 1), dir (right|left), y (dải giữa, 120–820),
// band (độ dày dải, mặc định 360), color (màu hạt). Hợp cảnh biển, đồi cát, bão, chuyến bay ngược gió.
import { when, layer, sfx, r3, rng } from "./_util.mjs";

const gioCat = { id: "gio-cat", cat: "atmosphere", label: "Cơn gió cát quét ngang: vệt gió + hạt cát (n cơn, dir, y, band, color)",
  run(ctx, o) {
    const { t, d } = when(ctx, o, 0.4);
    const id = ctx.id, R = rng(id), n = Math.max(1, Math.min(4, o.n ?? 1));
    const dir = o.dir === "left" ? -1 : 1, mid = Math.max(140, Math.min(820, o.y ?? 480)), band = o.band ?? 360;
    const col = o.color || "rgba(196,160,96,0.85)";
    const gap = n > 1 ? Math.max(1.2, d / n) : 0;
    let inner = "", js = "";
    const sf = [];
    for (let g = 0; g < n; g++) {
      const tg = r3(t + g * gap), len = 1.4 + R() * 0.5;
      for (let i = 0; i < 9; i++) {
        const y = r3(mid - band / 2 + R() * band), w = r3(220 + R() * 360), h = r3(2 + R() * 4);
        const x0 = dir > 0 ? -w - 200 : 2120, x1 = dir > 0 ? 2300 : -w - 400;
        inner += `<div id="${id}-s${g}-${i}" style="position:absolute;left:0;top:${y}px;width:${w}px;height:${h}px;border-radius:3px;background:linear-gradient(90deg, rgba(255,255,255,0), rgba(255,255,255,0.8), rgba(255,255,255,0));opacity:0;transform:translateX(${x0}px);"></div>`;
        js += `      tl.fromTo(q("#${id}-s${g}-${i}"), { x: ${x0}, opacity: 1 }, { x: ${x1}, opacity: 0.2, duration: ${r3(len * (0.7 + R() * 0.5))}, ease: "power1.in", immediateRender: false }, ${r3(tg + R() * 0.3)});\n`;
      }
      for (let i = 0; i < 26; i++) {
        const y = r3(mid - band / 2 + R() * band), s = r3(4 + R() * 6);
        const x0 = dir > 0 ? -40 - R() * 300 : 1960 + R() * 300, dx = dir * (1700 + R() * 700);
        inner += `<div id="${id}-g${g}-${i}" style="position:absolute;left:${r3(x0)}px;top:${y}px;width:${s}px;height:${s}px;border-radius:50%;background:${col};opacity:0;"></div>`;
        js += `      tl.fromTo(q("#${id}-g${g}-${i}"), { x: 0, y: 0, opacity: 1 }, { x: ${r3(dx)}, y: ${r3((R() - 0.6) * 160)}, opacity: 0, duration: ${r3(len * (0.8 + R() * 0.6))}, ease: "power1.out", immediateRender: false }, ${r3(tg + R() * 0.4)});\n`;
      }
      sf.push(sfx("whoosh", tg, 0.22));
    }
    return { [o.layer === "back" ? "back" : "over"]: layer(id, inner), js, sfx: o.sound === false ? [] : sf };
  } };

export default [gioCat];
