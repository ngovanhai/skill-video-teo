// `vai-roi`: quả vải đỏ rơi từ mép trên, nảy "bộp" xuống sàn rồi lăn ra (n quả, x, y sàn, dir left|right).
// Running gag kiểu "quả rơi đúng lúc" — hợp vườn cây, vụ án vườn vải, cảnh hài nhẹ.
import { when, layer, sfx, r3, rng } from "./_util.mjs";

const lychee = (id) => `<svg viewBox="-50 -60 100 110" style="width:100%;height:100%;overflow:visible">
  <path d="M0 -40 Q4 -52 14 -58" fill="none" stroke="#5A3A1A" stroke-width="6" stroke-linecap="round"/>
  <path d="M8 -50 Q28 -64 40 -48 Q24 -40 8 -50Z" fill="#4E9A3A" stroke="#2E6A2A" stroke-width="3"/>
  <circle cx="0" cy="0" r="40" fill="#D8343A" stroke="#7A161C" stroke-width="5"/>
  <path d="M-24 -6 l8 8 m6 -20 l8 8 m6 12 l8 8 m-36 8 l8 8 m14 -40 l6 6" stroke="#8A1A1E" stroke-width="3.5" stroke-linecap="round"/>
  <ellipse cx="-14" cy="-16" rx="11" ry="7" fill="#fff" opacity=".5"/></svg>`;

const vaiRoi = { id: "vai-roi", cat: "accent", label: "Quả vải rơi nảy bộp xuống rồi lăn (n, x, y sàn, dir left|right)",
  run(ctx, o) {
    const { t } = when(ctx, o, 0.6);
    const id = ctx.id, n = Math.max(1, Math.min(5, o.n ?? 1));
    const R = rng(id), floor = Math.min(860, o.y ?? 820), dir = o.dir === "left" ? -1 : 1;
    let inner = "", js = "";
    const sf = [];
    for (let i = 0; i < n; i++) {
      const x = r3((o.x ?? 1500) + (i - (n - 1) / 2) * 120 + (R() - 0.5) * 40), s = r3(0.8 + R() * 0.4), tb = r3(t + i * 0.22);
      inner += `<div id="${id}-v${i}" style="position:absolute;left:${x - 45}px;top:${floor - 90}px;width:90px;height:100px;opacity:0;transform:scale(${s})">${lychee(id)}</div>`;
      js += `      tl.fromTo(q("#${id}-v${i}"), { y: ${-floor}, opacity: 1, rotation: 0 }, { y: 0, duration: 0.55, ease: "power2.in", immediateRender: false }, ${tb});
      tl.to(q("#${id}-v${i}"), { y: -90, duration: 0.22, ease: "power2.out" }, ${r3(tb + 0.55)});
      tl.to(q("#${id}-v${i}"), { y: 0, duration: 0.22, ease: "power2.in" }, ${r3(tb + 0.77)});
      tl.to(q("#${id}-v${i}"), { x: ${dir * (120 + R() * 120)}, rotation: ${dir * 300}, duration: 0.9, ease: "power2.out" }, ${r3(tb + 0.99)});\n`;
      sf.push(sfx("pop", r3(tb + 0.55), 0.3));
    }
    return { [o.layer === "back" ? "back" : "over"]: layer(id, inner), js, sfx: o.sound === false ? [] : sf };
  } };

export default [vaiRoi];
