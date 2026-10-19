// `verdict`: búa thẩm phán gõ xuống + con dấu phán quyết đóng mạnh lên khung (BÁC BỎ / CÓ THẬT / NỬA ĐÚNG).
// Tham số: text, color (red | green | yellow | "#hex"), x, y (tâm con dấu), rot, gavel (false để bỏ búa), size.
import { when, layer, sfx, r3, esc, color } from "./_util.mjs";

const verdict = { id: "verdict", cat: "accent", label: "Búa thẩm phán gõ + dấu phán quyết (text, color, x, y, rot, gavel)",
  run(ctx, o) {
    const { t } = when(ctx, o, Math.max(0.3, ctx.dur - 2.5));
    const id = ctx.id, x = o.x ?? 1400, y = o.y ?? 330, rot = o.rot ?? -12, size = o.size ?? 96;
    const c = o.color ? color(o.color) : "#D7263D";
    const text = esc(o.text || "BÁC BỎ");
    const w = Math.max(360, [...String(o.text || "BÁC BỎ")].length * size * 0.62 + 90);
    const stamp = `<div id="${id}-s" style="position:absolute;left:${r3(x - w / 2)}px;top:${r3(y - size * 0.8)}px;width:${r3(w)}px;height:${r3(size * 1.6)}px;opacity:0;
        display:flex;align-items:center;justify-content:center;border:10px solid ${c};border-radius:22px;color:${c};font-weight:800;font-size:${size}px;letter-spacing:4px;
        background:rgba(255,253,245,.82);box-shadow:inset 0 0 0 6px rgba(255,253,245,.9), inset 0 0 0 12px ${c};transform:rotate(${rot}deg);">${text}</div>`;
    const gx = x + w / 2 - 40, gy = y - size * 0.8 - 230;
    const gavel = o.gavel === false ? "" : `<div id="${id}-g" style="position:absolute;left:${r3(gx)}px;top:${r3(gy)}px;width:260px;height:200px;opacity:0;transform-origin:220px 170px;">
        <svg viewBox="0 0 260 200" style="width:100%;height:100%;overflow:visible">
          <path d="M40 60 L200 170" stroke="#111" stroke-width="22" stroke-linecap="round"/><path d="M40 60 L200 170" stroke="#A0662E" stroke-width="12" stroke-linecap="round"/>
          <rect x="-10" y="10" width="110" height="64" rx="14" transform="rotate(34 45 42)" fill="#7A4A1E" stroke="#111" stroke-width="7"/>
          <rect x="18" y="10" width="14" height="64" transform="rotate(34 45 42)" fill="#F7CB46"/><rect x="60" y="10" width="14" height="64" transform="rotate(34 45 42)" fill="#F7CB46"/>
        </svg></div>`;
    let js = "";
    if (gavel) js += `      tl.fromTo(q("#${id}-g"), { opacity: 0, rotation: -40 }, { opacity: 1, rotation: -40, duration: 0.15, immediateRender: false }, ${r3(Math.max(0, t - 0.45))});
      tl.to(q("#${id}-g"), { rotation: 18, duration: 0.18, ease: "power4.in" }, ${r3(Math.max(0, t - 0.2))});
      tl.to(q("#${id}-g"), { rotation: -10, duration: 0.3, ease: "power2.out" }, ${r3(t)});
      tl.to(q("#${id}-g"), { opacity: 0, duration: 0.3 }, ${r3(t + 0.7)});\n`;
    js += `      tl.fromTo(q("#${id}-s"), { scale: 2.2, opacity: 0, rotation: ${rot + 8} }, { scale: 1, opacity: 1, rotation: ${rot}, duration: 0.22, ease: "power4.in", immediateRender: false }, ${r3(t)});
      tl.to(q("#${id}-s"), { scale: 1.04, duration: 0.08, yoyo: true, repeat: 1, ease: "none" }, ${r3(t + 0.22)});\n`;
    return { over: layer(id, gavel + stamp), js, sfx: o.sound === false ? [] : [sfx("impact", t, 0.4)] };
  } };

export default [verdict];
