// `clay-crack`: vết nứt đất nung lan ra từ (x, y), mảnh vỡ bật ra + bụi đất (n nhánh, r, color).
import { rng, when, layer, sfx, r3 } from "./_util.mjs";

const clayCrack = { id: "clay-crack", cat: "accent", label: "Vết nứt đất nung lan từ (x, y) + mảnh vỡ bật + bụi đất (n, r, color)",
  run(ctx, o) {
    const { t } = when(ctx, o, 0.2);
    const R = rng(ctx.id), id = ctx.id, x = o.x ?? 960, y = o.y ?? 420, n = o.n ?? 6, rad = o.r ?? 260;
    const c = o.color || "#3A2416";
    let paths = "", shards = "", dust = "", js = `      FADE(q("#${id}"), ${t}, 0.05);\n`;
    for (let i = 0; i < n; i++) {
      const a = (i / n) * Math.PI * 2 + (R() - 0.5) * 0.6;
      let px = x, py = y, d = `M${x} ${y}`;
      const seg = 4;
      for (let k = 1; k <= seg; k++) {
        const rr = (rad * k) / seg, aa = a + (R() - 0.5) * 0.5;
        px = x + Math.cos(aa) * rr; py = Math.min(860, y + Math.sin(aa) * rr);
        d += ` L${r3(px)} ${r3(py)}`;
      }
      paths += `<path class="${id}-c" d="${d}" pathLength="1" fill="none" stroke="${c}" stroke-width="${r3(5 + R() * 4)}" stroke-linecap="round" stroke-linejoin="round" stroke-dasharray="1" stroke-dashoffset="1"/>`;
      const bx = x + Math.cos(a) * rad * 0.45, by = y + Math.sin(a) * rad * 0.45, s = r3(14 + R() * 14);
      shards += `<path class="${id}-s" d="M${r3(bx)} ${r3(by - s)} L${r3(bx + s)} ${r3(by)} L${r3(bx - s * 0.4)} ${r3(by + s * 0.8)} Z" fill="#B9764A" stroke="#111" stroke-width="3" opacity="0"/>`;
      js += `      tl.to(qa(".${id}-c")[${i}], { strokeDashoffset: 0, duration: ${r3(0.35 + R() * 0.25)}, ease: "power2.out" }, ${r3(t + i * 0.04)});\n`;
      js += `      tl.fromTo(qa(".${id}-s")[${i}], { opacity: 1, x: 0, y: 0, rotation: 0, transformOrigin: "50% 50%" }, { opacity: 0, x: ${r3(Math.cos(a) * 160)}, y: ${r3(Math.sin(a) * 120 + 160)}, rotation: ${r3((R() - 0.5) * 360)}, duration: 0.9, ease: "power2.out", immediateRender: false }, ${r3(t + 0.1)});\n`;
    }
    for (let i = 0; i < 10; i++) {
      const s = r3(30 + R() * 50);
      dust += `<circle class="${id}-d" cx="${r3(x + (R() - 0.5) * 120)}" cy="${r3(y + (R() - 0.5) * 60)}" r="${s}" fill="#C9A27A" opacity="0"/>`;
      js += `      tl.fromTo(qa(".${id}-d")[${i}], { opacity: 0.55, scale: 0.3, transformOrigin: "50% 50%" }, { opacity: 0, scale: 1.6, y: ${r3(-40 - R() * 60)}, duration: 1.2, ease: "sine.out", immediateRender: false }, ${r3(t + 0.05)});\n`;
    }
    const svg = `<svg width="1920" height="1080" viewBox="0 0 1920 1080" style="position:absolute;left:0;top:0">${dust}${paths}${shards}</svg>`;
    return { [o.layer || "over"]: layer(id, svg, "opacity:0;"), js, sfx: o.sound === false ? [] : [sfx("impact2", t, 0.35)] };
  } };

export default [clayCrack];
