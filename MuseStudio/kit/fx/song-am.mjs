// `song-am`: tiếng nói lan ra thành sóng âm — các cung tròn nét mực nở dần từ một điểm (x, y) rồi nhạt đi,
// lặp n đợt, kèm một vệt sóng nhỏ chạy ngang qua điểm đó. Tham số: x, y, n (số đợt, mặc định 3), color, r (bán kính tối đa),
// dir (right|left|both: hướng các cung). Hợp cảnh có người nói vào ống nói, tiếng chuông, tiếng gọi, tiếng vọng qua dây.
import { when, layer, sfx, r3 } from "./_util.mjs";

const songAm = { id: "song-am", cat: "accent", label: "Sóng âm nét mực nở ra từ một điểm (x, y, n, color, r, dir)",
  run(ctx, o) {
    const { t, d } = when(ctx, o, 0.5);
    const id = ctx.id, n = Math.max(1, Math.min(6, o.n ?? 3));
    const x = o.x ?? 960, y = Math.max(80, Math.min(820, o.y ?? 420)), R = o.r ?? 260;
    const col = o.color || "#D2462E", dir = o.dir || "both";
    const gap = Math.max(0.35, Math.min(0.8, d / (n + 1)));
    let inner = "", js = "";
    for (let i = 0; i < n; i++) {
      for (let k = 0; k < 3; k++) {
        const rr = R * (0.45 + k * 0.28);
        const arcs = [];
        if (dir !== "left") arcs.push(`M${r3(rr * 0.5)} ${r3(-rr * 0.866)} A${r3(rr)} ${r3(rr)} 0 0 1 ${r3(rr * 0.5)} ${r3(rr * 0.866)}`);
        if (dir !== "right") arcs.push(`M${r3(-rr * 0.5)} ${r3(-rr * 0.866)} A${r3(rr)} ${r3(rr)} 0 0 0 ${r3(-rr * 0.5)} ${r3(rr * 0.866)}`);
        inner += `<svg id="${id}-a${i}-${k}" width="2" height="2" style="position:absolute;left:${x}px;top:${y}px;overflow:visible;opacity:0;"><path d="${arcs.join(" ")}" fill="none" stroke="${col}" stroke-width="${6 - k * 1.5}" stroke-linecap="round"/></svg>`;
        const ti = r3(t + i * gap + k * 0.08);
        js += `      tl.fromTo(q("#${id}-a${i}-${k}"), { opacity: 0, scale: 0.4 }, { opacity: 0.9, scale: 1, duration: 0.35, ease: "power2.out", immediateRender: false }, ${ti});
      tl.to(q("#${id}-a${i}-${k}"), { opacity: 0, scale: 1.25, duration: 0.45, ease: "power1.in" }, ${r3(ti + 0.35)});\n`;
      }
    }
    return { [o.layer === "back" ? "back" : "over"]: layer(id, inner), js, sfx: o.sound ? [sfx("chime", t, 0.18)] : [] };
  } };

export default [songAm];
