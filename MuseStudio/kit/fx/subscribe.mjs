// Subscribe call-to-action: red button + bell, a cursor flies in and clicks it.
// Auto-added to any scene with "cta": true (lands on the cue "đăng ký" if the narration has it).
import { when, layer, sfx, r3 } from "./_util.mjs";

const BELL = `<svg viewBox="0 0 64 64" style="width:100%;height:100%;overflow:visible"><path d="M32 6 C20 6 14 16 14 28 L14 40 L8 48 L56 48 L50 40 L50 28 C50 16 44 6 32 6 Z" fill="#F7CB46" stroke="#000" stroke-width="5" stroke-linejoin="round"/><circle cx="32" cy="54" r="6" fill="#000"/></svg>`;
const CURSOR = `<svg viewBox="0 0 40 56" style="width:100%;height:100%;overflow:visible"><path d="M4 2 L4 44 L14 34 L22 52 L30 48 L22 31 L36 31 Z" fill="#fff" stroke="#000" stroke-width="4" stroke-linejoin="round"/></svg>`;

const subscribe = { id: "subscribe", cat: "cta", label: "Nút Đăng ký + chuông, con trỏ bấm (x, y góc trái nút)",
  run(ctx, o) {
    const { t, end } = when(ctx, o.at || o.t != null ? o : { ...o, at: "đăng ký" }, Math.max(0.3, ctx.dur * 0.35));
    const id = ctx.id, x = o.x ?? 1250, y = o.y ?? 690;
    const inner = `<div id="${id}-box" style="position:absolute;left:${x}px;top:${y}px;width:620px;height:150px;opacity:0;">
        <div id="${id}-btn" style="position:absolute;left:0;top:20px;width:430px;height:110px;border-radius:9999px;background:#FF0033;border:5px solid #000;box-shadow:8px 8px 0 #000;color:#fff;font-weight:700;font-size:50px;display:flex;align-items:center;justify-content:center;padding-top:4px;letter-spacing:0.02em;">ĐĂNG KÝ</div>
        <div id="${id}-done" style="position:absolute;left:0;top:20px;width:430px;height:110px;border-radius:9999px;background:#E8E8E8;border:5px solid #000;box-shadow:8px 8px 0 #000;color:#333;font-weight:700;font-size:44px;display:flex;align-items:center;justify-content:center;padding-top:4px;opacity:0;">ĐÃ ĐĂNG KÝ ✓</div>
        <div id="${id}-bell" style="position:absolute;left:470px;top:22px;width:104px;height:104px;border-radius:50%;background:#fff;border:5px solid #000;box-shadow:6px 6px 0 #000;padding:16px;">${BELL}</div>
        <div id="${id}-cur" style="position:absolute;left:300px;top:90px;width:60px;height:84px;">${CURSOR}</div>
      </div>`;
    const tc = r3(t + 0.9), tb = r3(t + 1.5), out = r3(Math.min(end - 0.3, t + (o.hold ?? 5)));
    let js = `      POP(q("#${id}-box"), ${t}, { from: 0.5 });
      tl.fromTo(q("#${id}-cur"), { x: 500, y: 300, opacity: 0 }, { x: 0, y: 0, opacity: 1, duration: 0.6, ease: "power3.out", immediateRender: false }, ${r3(t + 0.25)});
      tl.to(q("#${id}-cur"), { scale: 0.8, duration: 0.08 }, ${tc}); tl.to(q("#${id}-cur"), { scale: 1, duration: 0.12 }, ${r3(tc + 0.08)});
      tl.to(q("#${id}-btn"), { scale: 0.93, duration: 0.08 }, ${tc}); tl.set(q("#${id}-btn"), { opacity: 0 }, ${r3(tc + 0.1)}); tl.set(q("#${id}-done"), { opacity: 1 }, ${r3(tc + 0.1)});
      tl.to(q("#${id}-cur"), { x: 210, y: 0, duration: 0.4, ease: "power2.inOut" }, ${r3(tc + 0.2)});\n`;
    [14, -14, 10, -10, 5, 0].forEach((r, i) => { js += `      tl.to(q("#${id}-bell"), { rotation: ${r}, duration: 0.08, ease: "sine.inOut" }, ${r3(tb + i * 0.08)});\n`; });
    if (out > tb + 0.8) js += `      OUT(q("#${id}-box"), ${out}, 0.35);\n`;
    return { over: layer(id, inner), js, sfx: [sfx("pop", t, 0.3), sfx("click", tc, 0.4), sfx("chime", tb, 0.35)] };
  } };

export default [subscribe];
