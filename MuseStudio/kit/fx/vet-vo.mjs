// `vet-vo`: một hàng vết vó ngựa in dần xuống đất theo một đường (đoàn ngựa đi qua), rồi một làn gió quét ngang
// xoá dần từng vết. Hợp chuyện dấu chân bị xoá, đoàn quân/đoàn xe đi qua thảo nguyên, giấu dấu vết.
// Tham số: y (đường đi, mặc định 780), x1/x2 (đầu/cuối, mặc định 120/1800), n (số cặp vết, mặc định 14),
// color (màu vết), erase (giây sau khi in xong thì gió xoá; false = không xoá), dir (right|left), size (mặc định 1).
import { when, layer, sfx, r3, rng } from "./_util.mjs";

const vetVo = { id: "vet-vo", cat: "accent", label: "Vết vó ngựa in dần theo một đường rồi gió xoá (y, x1, x2, n, color, erase, dir, size)",
  run(ctx, o) {
    const { t, d } = when(ctx, o, 0.3);
    const id = ctx.id, R = rng(id);
    const n = Math.max(4, Math.min(24, o.n ?? 14));
    const y = Math.max(120, Math.min(850, o.y ?? 780));
    const dir = o.dir === "left" ? -1 : 1;
    const xa = o.x1 ?? 120, xb = o.x2 ?? 1800;
    const x0 = dir > 0 ? xa : xb, x1 = dir > 0 ? xb : xa;
    const s = o.size ?? 1;
    const col = o.color || "rgba(70,48,28,0.72)";
    const walk = Math.min(Math.max(1.2, d * 0.55), 3.2);
    const step = walk / n;
    const eraseAt = o.erase === false ? null : r3(t + walk + (o.erase ?? 0.8));
    let inner = "", js = "";
    for (let i = 0; i < n; i++) {
      const x = x0 + ((x1 - x0) * i) / (n - 1);
      for (const side of [-1, 1]) {
        const yy = r3(y + side * 16 * s + (R() - 0.5) * 6), xx = r3(x + side * 12 * s);
        const rot = dir > 0 ? 90 : -90;
        // móng ngựa: hình chữ U mở về phía sau
        inner += `<svg id="${id}-v${i}${side > 0 ? "b" : "a"}" width="${r3(36 * s)}" height="${r3(36 * s)}" viewBox="0 0 36 36" style="position:absolute;left:${r3(xx - 18 * s)}px;top:${r3(yy - 18 * s)}px;opacity:0;transform:rotate(${rot}deg);overflow:visible"><path d="M8 30 Q2 6 18 4 Q34 6 28 30 L22 30 Q26 12 18 11 Q10 12 14 30 Z" fill="${col}"/></svg>`;
        const ti = r3(t + i * step + (side > 0 ? step * 0.45 : 0));
        js += `      tl.fromTo(q("#${id}-v${i}${side > 0 ? "b" : "a"}"), { opacity: 0, scale: 1.5 }, { opacity: 1, scale: 1, duration: 0.12, ease: "power3.in", immediateRender: false }, ${ti});\n`;
        if (eraseAt != null) js += `      tl.to(q("#${id}-v${i}${side > 0 ? "b" : "a"}"), { opacity: 0, x: ${dir * 40}, duration: 0.35, ease: "power1.in" }, ${r3(eraseAt + (i / n) * 0.9)});\n`;
      }
    }
    if (eraseAt != null) {
      // làn gió xoá: vệt trắng mờ quét theo hướng đi
      for (let k = 0; k < 6; k++) {
        const yy = r3(y - 50 + R() * 100), w = r3(260 + R() * 260);
        const a = dir > 0 ? -w - 100 : 2020, b = dir > 0 ? 2200 : -w - 300;
        inner += `<div id="${id}-w${k}" style="position:absolute;left:0;top:${yy}px;width:${w}px;height:${r3(3 + R() * 3)}px;border-radius:3px;background:linear-gradient(90deg, rgba(255,255,255,0), rgba(255,255,255,0.75), rgba(255,255,255,0));opacity:0;transform:translateX(${a}px);"></div>`;
        js += `      tl.fromTo(q("#${id}-w${k}"), { x: ${a}, opacity: 1 }, { x: ${b}, opacity: 0.2, duration: 1.3, ease: "power1.in", immediateRender: false }, ${r3(eraseAt - 0.1 + R() * 0.3)});\n`;
      }
    }
    const sf = o.sound === false ? [] : [sfx("click", t, 0.12)];
    if (eraseAt != null && o.sound !== false) sf.push(sfx("whoosh", eraseAt, 0.18));
    return { [o.layer === "back" ? "back" : "over"]: layer(id, inner), js, sfx: sf };
  } };

export default [vetVo];
