// Radium-flavoured fx: `glow` (quầng sáng xanh nhịp thở) and `geiger` (máy đếm Geiger, kim giật + chữ "TÁCH TÁCH").
import { when, layer, reps, sfx, r3, color } from "./_util.mjs";

const glow = { id: "glow", cat: "light", label: "Quầng sáng phát quang nhịp thở ở (x, y), r, color (mặc định xanh radium)",
  run(ctx, o) {
    const { t, d, end } = when(ctx, o, 0.2);
    const id = ctx.id, x = o.x ?? 960, y = o.y ?? 440, r = o.r ?? 320, c = o.color ? color(o.color) : "#7CFFB2";
    const inner = `<div id="${id}-g" style="position:absolute;left:${x - r}px;top:${y - r}px;width:${2 * r}px;height:${2 * r}px;border-radius:50%;background:radial-gradient(circle, ${c}cc 0%, ${c}55 35%, ${c}00 70%);opacity:0;mix-blend-mode:screen;"></div>`;
    const p = 1.6;
    let js = `      tl.fromTo(q("#${id}-g"), { opacity: 0, scale: 0.6 }, { opacity: ${o.opacity ?? 0.85}, scale: 1, duration: 0.8, ease: "power2.out", immediateRender: false }, ${t});\n`;
    if (d > 1.4) js += `      tl.to(q("#${id}-g"), { opacity: ${r3((o.opacity ?? 0.85) * 0.55)}, scale: 1.08, duration: ${p / 2}, ease: "sine.inOut", yoyo: true, repeat: ${reps(d - 0.8, p / 2)} }, ${r3(t + 0.8)});\n`;
    return { [o.layer === "over" ? "over" : "back"]: layer(id, inner), js, sfx: o.sound === false ? [] : [sfx("sparkle", t, 0.18)] };
  } };

const GEIGER = `<svg viewBox="0 0 220 170" style="width:100%;height:100%;overflow:visible">
  <rect x="6" y="20" width="170" height="140" rx="16" fill="#F7CB46" stroke="#000" stroke-width="6"/>
  <rect x="24" y="38" width="134" height="72" rx="8" fill="#FFFDF5" stroke="#000" stroke-width="5"/>
  <path d="M38 98 A54 54 0 0 1 144 98" fill="none" stroke="#000" stroke-width="3"/>
  <path d="M120 64 L134 52" stroke="#FE3D7F" stroke-width="5"/>
  <circle cx="44" cy="134" r="9" fill="#000"/><circle cx="72" cy="134" r="9" fill="#99E885" stroke="#000" stroke-width="3"/>
  <rect x="176" y="70" width="40" height="22" rx="6" fill="#111" stroke="#000" stroke-width="4"/>
  <path d="M176 82 C150 2 210 0 214 30" fill="none" stroke="#111" stroke-width="6"/></svg>`;

const geiger = { id: "geiger", cat: "accent", label: "Máy đếm Geiger: kim giật + chữ TÁCH TÁCH (x, y, text, n lần)",
  run(ctx, o) {
    const { t, end } = when(ctx, o, 0.6);
    const id = ctx.id, x = o.x ?? 1560, y = o.y ?? 120, n = o.n ?? 6;
    const inner = `<div id="${id}-box" style="position:absolute;left:${x}px;top:${y}px;width:220px;height:170px;opacity:0;">
        <div id="${id}-dev" style="position:absolute;inset:0;">${GEIGER}</div>
        <div id="${id}-needle" style="position:absolute;left:89px;top:56px;width:6px;height:46px;background:#000;border-radius:3px;transform-origin:50% 100%;transform:rotate(-60deg);"></div>
        <div id="${id}-tx" style="position:absolute;left:-40px;top:-70px;width:300px;text-align:center;font-weight:700;font-size:44px;color:#7CFFB2;-webkit-text-stroke:2px #000;paint-order:stroke;opacity:0;transform:rotate(-6deg);">${o.text || "TÁCH TÁCH!"}</div>
      </div>`;
    let js = `      POP(q("#${id}-box"), ${t}, { from: 0.4 });\n      POP(q("#${id}-tx"), ${r3(t + 0.3)}, { from: 0.6, r: -6 });\n`;
    const out = [];
    for (let i = 0; i < n; i++) {
      const ti = r3(t + 0.3 + i * 0.22), a = i % 2 ? 10 + (i * 13) % 40 : 45 + (i * 7) % 20;
      js += `      tl.to(q("#${id}-needle"), { rotation: ${a}, duration: 0.08, ease: "power2.out" }, ${ti});\n`;
      js += `      tl.to(q("#${id}-dev"), { x: ${i % 2 ? -3 : 3}, duration: 0.05, ease: "none" }, ${ti});\n`;
      out.push(sfx("click", ti, 0.22));
    }
    js += `      tl.to(q("#${id}-needle"), { rotation: -30, duration: 0.4, ease: "power2.inOut" }, ${r3(t + 0.4 + n * 0.22)});\n`;
    const hide = r3(Math.min(end - 0.3, t + (o.hold ?? 3.2)));
    if (hide > t + 1) js += `      OUT(q("#${id}-box"), ${hide}, 0.3);\n`;
    return { over: layer(id, inner), js, sfx: out };
  } };

export default [glow, geiger];
