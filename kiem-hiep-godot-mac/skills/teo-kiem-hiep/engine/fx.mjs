// Effect library. Every effect: { id, cat, label, run(ctx, beat, t) -> { dur, hit? } }.
// run() appends markup with ctx.add(layer, html) (layers: bg | act | fx | hud | over) and timeline code with ctx.js(code).
// Every effect randomises its own look through ctx.rnd/range/pick, so even a reused effect never looks identical.
// Categories (the planner rotates within each): opener transition camera enter intro power attack impact react caption card stat ender.

const css = (o) => Object.entries(o).map(([k, v]) => `${k.replace(/[A-Z]/g, (m) => "-" + m.toLowerCase())}:${typeof v === "number" && !/opacity|zIndex/.test(k) ? v + "px" : v}`).join(";");
const div = (id, style, inner = "") => `<div${id ? ` id="${id}"` : ""} style="position:absolute;${css(style)}">${inner}</div>`;
// quầng sáng không dùng filter: 2 bản nét to, mờ dần phía sau nét chính. geo = thuộc tính hình (d=…, x1=…, pathLength…)
const glowStroke = (tag, geo, w, color, glow, px, extra = "") => `<${tag} ${geo} fill="none" stroke="${glow}" stroke-width="${w + px * 2}" opacity=".25" ${extra}/><${tag} ${geo} fill="none" stroke="${glow}" stroke-width="${w + px}" opacity=".45" ${extra}/><${tag} ${geo} fill="none" stroke="${color}" stroke-width="${w}" ${extra}/>`;
const f2 = (x) => (Math.round(x * 100) / 100).toString();
const esc = (s) => String(s).replace(/&/g, "&amp;").replace(/</g, "&lt;");
const star4 = (fill, stroke) => `<svg viewBox="-60 -60 120 120" width="120" height="120" style="position:absolute;left:-60px;top:-60px;overflow:visible"><path d="M0 -58 L10 -10 L58 0 L10 10 L0 58 L-10 10 L-58 0 L-10 -10 Z" fill="${fill}" stroke="${stroke}" stroke-width="4"/></svg>`;
const star5 = (c) => `<svg viewBox="-20 -20 40 40" width="40" height="40"><path d="M0 -18 L5 -5 L18 -5 L8 3 L12 17 L0 9 L-12 17 L-8 3 L-18 -5 L-5 -5 Z" fill="${c}" stroke="#111" stroke-width="3" stroke-linejoin="round"/></svg>`;
const bigSword = (glow) => `<svg viewBox="0 0 120 700" width="120" height="700" style="display:block;overflow:visible"><path d="M48 520 L48 46 L60 0 L72 46 L72 520 Z M8 516 H112 V542 H8 Z" fill="none" stroke="${glow}" stroke-width="44" stroke-linejoin="round" opacity=".22"/><path d="M48 520 L48 46 L60 0 L72 46 L72 520 Z M8 516 H112 V542 H8 Z" fill="none" stroke="${glow}" stroke-width="22" stroke-linejoin="round" opacity=".4"/><path class="hl" d="M48 520 L48 46 L60 0 L72 46 L72 520 Z" fill="none" stroke="#fff" stroke-width="60" stroke-linejoin="round" opacity="0"/><path d="M48 520 L48 46 L60 0 L72 46 L72 520 Z" fill="#EEF3F8" stroke="#111" stroke-width="6" stroke-linejoin="round"/><path d="M60 40 L60 510" stroke="#AFC0D0" stroke-width="5"/><rect x="8" y="516" width="104" height="26" rx="10" fill="#E3A21A" stroke="#111" stroke-width="6"/><rect x="49" y="540" width="22" height="118" rx="6" fill="#6B3E1F" stroke="#111" stroke-width="5"/><circle cx="60" cy="670" r="17" fill="#E3A21A" stroke="#111" stroke-width="5"/></svg>`;
const titleCss = (size, color, stroke = "#111") => `font:700 ${size}px/1.05 'Space Grotesk';color:${color};-webkit-text-stroke:${Math.round(size / 24)}px ${stroke};paint-order:stroke fill;text-shadow:${Math.round(size / 24)}px ${Math.round(size / 24)}px 0 ${stroke};text-align:center`;
// particles flying from a ring of radius r0 into (cx, cy) between t0..t1
function converge(ctx, layer, cx, cy, n, color, t0, t1, r0 = [500, 900], size = 12) {
  const u = ctx.uid("cv");
  ctx.add(layer, div(null, { left: cx, top: cy, width: 0, height: 0 }, Array.from({ length: n }, (_, i) => `<div id="${u}-${i}" style="position:absolute;left:${-size / 2}px;top:${-size / 2}px;width:${size}px;height:${size}px;border-radius:50%;background:${color};box-shadow:0 0 14px ${color};opacity:0"></div>`).join("")));
  for (let i = 0; i < n; i++) {
    const a = ctx.range(0, Math.PI * 2), r = ctx.range(r0[0], r0[1]), d = ctx.range(0.5, Math.min(1.2, t1 - t0)), s = ctx.range(t0, t1 - d);
    ctx.js(`tl.fromTo("#${u}-${i}", { x: ${f2(Math.cos(a) * r)}, y: ${f2(Math.sin(a) * r)}, opacity: 0 }, { x: 0, y: 0, opacity: 1, duration: ${f2(d)}, ease: "power2.in", ...NF }, ${f2(s)}); tl.set("#${u}-${i}", { opacity: 0 }, ${f2(s + d)});`);
  }
}
function burst(ctx, layer, cx, cy, n, color, t, r = [300, 700], size = 12, dur = 0.7) {
  const u = ctx.uid("bu");
  ctx.add(layer, div(null, { left: cx, top: cy, width: 0, height: 0 }, Array.from({ length: n }, (_, i) => `<div id="${u}-${i}" style="position:absolute;left:${-size / 2}px;top:${-size / 2}px;width:${size}px;height:${size}px;border-radius:50%;background:${color};box-shadow:0 0 12px ${color};opacity:0"></div>`).join("")));
  for (let i = 0; i < n; i++) { const a = ctx.range(0, Math.PI * 2), d = ctx.range(r[0], r[1]); ctx.js(`tl.fromTo("#${u}-${i}", { x: 0, y: 0, opacity: 1 }, { x: ${f2(Math.cos(a) * d)}, y: ${f2(Math.sin(a) * d)}, opacity: 0, duration: ${f2(dur * ctx.range(0.7, 1.2))}, ease: "power3.out", ...NF }, ${f2(t)});`); }
}
function dust(ctx, x, y, t, n = 6, col = "rgba(200,170,120,.85)") {
  const u = ctx.uid("du");
  ctx.add("fx", Array.from({ length: n }, (_, i) => div(`${u}-${i}`, { left: x - 40, top: y - 40, width: 80, height: 80, borderRadius: "50%", background: col, opacity: 0 })).join(""));
  for (let i = 0; i < n; i++) { const dx = (i - (n - 1) / 2) * ctx.range(50, 80); ctx.js(`tl.fromTo("#${u}-${i}", { x: 0, y: 0, scale: 0.3, opacity: 0.9 }, { x: ${f2(dx)}, y: ${f2(-ctx.range(10, 60))}, scale: ${f2(ctx.range(1, 1.8))}, opacity: 0, duration: 0.7, ease: "power2.out", ...NF }, ${f2(t)});`); }
}
const defaultTarget = (ctx, b) => (b.target ? [].concat(b.target) : ctx.others(b.who)).map((id) => ctx.actor(id));
const centroid = (ts) => ({ x: ts.reduce((s, a) => s + a.cx, 0) / ts.length, y: ts.reduce((s, a) => s + a.cy, 0) / ts.length });

export const FX = [];
const def = (cat, id, label, run, extra = {}) => FX.push({ cat, id, label, run, ...extra }); // extra.removes: nạn nhân rời khung · extra.down: nạn nhân nằm gục (cấm ở tập chủ đề)

// ============================ OPENER (own scene, beat: {title, sub}) ============================
def("opener", "op-rings", "Vòng năng lượng + chữ đập", (ctx, b, t) => {
  const u = ctx.uid("op"), th = ctx.theme, sp = ctx.pick([1, -1]);
  ctx.add("fx", `<div class="fill" style="background:radial-gradient(circle at 50% 50%, ${th.mid} 0%, ${th.dark} 58%, #050308 100%)"></div>
${div(u + "-l", { left: -540, top: -960, width: 3000, height: 3000, background: `repeating-conic-gradient(from 0deg at 50% 50%, rgba(255,255,255,0.10) 0deg 1.4deg, transparent 1.4deg ${f2(ctx.range(7, 12))}deg)`, opacity: 0 })}
${[700, 500, 300].map((s, i) => div(`${u}-r${i}`, { left: 960 - s / 2, top: 540 - s / 2, width: s, height: s, borderRadius: "50%", border: `${24 - i * 5}px solid`, borderColor: `${[th.qi, th.qi2, "#fff"][i]} transparent ${[th.qi2, "#fff", th.qi][i]} transparent`, boxShadow: `0 0 60px ${th.qi}` })).join("")}
${div(u + "-c", { left: 810, top: 390, width: 300, height: 300, borderRadius: "50%", background: `radial-gradient(circle,#fff 0%,${th.light} 26%,${th.qi}aa 52%,transparent 70%)` })}
${div(u + "-t", { left: 0, top: 330, width: 1920, opacity: 0 }, `<div style="${titleCss(200, th.title)}">${esc(b.title)}</div>`)}
${div(u + "-s", { left: 0, top: 600, width: 1920, textAlign: "center", opacity: 0 }, `<span class="chip">${esc(b.sub)}</span>`)}`);
  converge(ctx, "fx", 960, 540, 34, th.light, t, t + 1.5);
  ctx.js(`[0,1,2].forEach(i => { tl.fromTo("#${u}-r" + i, { scale: 0.3, rotation: 0 }, { scale: 1, rotation: ${sp * 400} * (i % 2 ? -1 : 1) * (1 + i * 0.4), duration: 1.5, ease: "power2.out" }, ${t}); tl.to("#${u}-r" + i, { scale: 1.6 + i * 0.3, opacity: 0.3, rotation: "+=" + (${sp} * 300), duration: 3, ease: "power3.out" }, ${t + 1.55}); });
tl.fromTo("#${u}-c", { scale: 0.2 }, { scale: 1.25, duration: 1.5, ease: "power2.in" }, ${t}); tl.to("#${u}-c", { scale: 3.2, opacity: 0, duration: 0.6 }, ${t + 1.55});
tl.fromTo("#${u}-l", { opacity: 0, scale: 1.5 }, { opacity: 1, scale: 1, duration: 0.25, ...NF }, ${t + 1.55}); tl.to("#${u}-l", { rotation: ${sp * 25}, duration: 3, ease: "none" }, ${t + 1.55});
tl.fromTo("#${u}-t", { scale: 3.2, opacity: 0 }, { scale: 1, opacity: 1, duration: 0.22, ease: "power4.in", ...NF }, ${t + 1.6});
tl.to("#${u}-t", { scale: 1.04, duration: 0.5, yoyo: true, repeat: 3, ease: "sine.inOut" }, ${t + 2.3});`);
  burst(ctx, "fx", 960, 540, 30, th.light, t + 1.55, [500, 1100]);
  ctx.js(`FLASH(${t + 1.55}, 0.95, 0.45); SHAKE("#${ctx.S}-shake", ${t + 1.82}, 0.4, 26); POP("#${u}-s", ${t + 2.4});`);
  ctx.sfx("riser", t, 0.45, 1.6); ctx.sfx("impact-bass-2", t + 1.55, 0.6); ctx.sfx("sparkle", t + 2.4, 0.3);
  return { dur: 4.6 };
});
def("opener", "op-ink", "Nét mực viết tên + ấn đỏ", (ctx, b, t) => {
  const u = ctx.uid("op"), th = ctx.theme, y0 = ctx.range(380, 520);
  const strokes = [0, 1, 2].map((i) => `<path id="${u}-k${i}" pathLength="1" stroke-dasharray="1" stroke-dashoffset="1" d="M${-100 + i * 40} ${f2(y0 + (i - 1) * 140 + ctx.range(-30, 30))} C ${f2(ctx.range(400, 700))} ${f2(y0 - 200 + i * 60)}, ${f2(ctx.range(1100, 1500))} ${f2(y0 + 220 - i * 80)}, 2020 ${f2(y0 + (i - 1) * 120)}" fill="none" stroke="${i === 1 ? th.qi : "#2A1E22"}" stroke-width="${[150, 60, 110][i]}" stroke-linecap="round" opacity="${i === 1 ? 0.8 : 1}"/>`).join("");
  ctx.add("fx", `<div class="fill" style="background:radial-gradient(circle at 50% 45%, #2B1D22 0%, #0E0A0C 70%)"></div><svg class="fill" viewBox="0 0 1920 1080" width="1920" height="1080" style="overflow:visible">${strokes}</svg>
${div(u + "-t", { left: 0, top: 360, width: 0, overflow: "hidden" }, `<div style="width:1920px;${titleCss(190, "#F6EFE0", "#000")}">${esc(b.title)}</div>`)}
${div(u + "-seal", { left: ctx.pick([180, 1560]), top: 160, width: 190, height: 190, borderRadius: 18, background: "#C8372D", border: "6px solid #F6EFE0", font: "700 70px/176px 'Space Grotesk'", color: "#F6EFE0", textAlign: "center", opacity: 0 }, "TÈO")}
${div(u + "-s", { left: 0, top: 640, width: 1920, textAlign: "center", opacity: 0, font: "600 52px 'Space Grotesk'", color: th.light, letterSpacing: "6px" }, esc(b.sub))}`);
  ctx.js(`[0,1,2].forEach(i => DRAW("#${u}-k" + i, ${t + 0.2} + i * 0.25, 0.7, "power2.inOut"));
tl.to("#${u}-t", { width: 1920, duration: 1.0, ease: "power2.inOut" }, ${t + 1.2});
STAMP("#${u}-seal", ${t + 2.3}, ${f2(ctx.range(-12, 8))}); SHAKE("#${ctx.S}-shake", ${t + 2.56}, 0.3, 18);
SHOW("#${u}-s", ${t + 2.7}, 0.5, { y: 20 });`);
  ctx.sfx("whoosh-cinematic", t + 0.2, 0.4, 1.6); ctx.sfx("impact-bass-1", t + 2.5, 0.55); ctx.sfx("chime", t + 2.8, 0.25, 1.4);
  return { dur: 4.4 };
});
def("opener", "op-swords", "Hai kiếm giao nhau toé lửa", (ctx, b, t) => {
  const u = ctx.uid("op"), th = ctx.theme, ang = ctx.range(30, 46);
  const rays = Array.from({ length: 12 }, (_, i) => `<div style="position:absolute;left:-6px;top:-260px;width:12px;height:220px;border-radius:6px;background:linear-gradient(#fff,rgba(255,230,140,0));transform-origin:6px 260px;transform:rotate(${i * 30}deg)"></div>`).join("");
  ctx.add("fx", `<div class="fill" style="background:linear-gradient(160deg, ${th.dark}, #07040F)"></div>
${div(u + "-a", { left: 900, top: 190, width: 120, height: 700, transform: `rotate(${f2(ang)}deg)` }, bigSword(th.qi))}${div(u + "-b", { left: 900, top: 190, width: 120, height: 700, transform: `rotate(${f2(-ang)}deg)` }, bigSword(th.qi2))}
${div(u + "-sp", { left: 960, top: 470, width: 0, height: 0, opacity: 0 }, rays)}
${div(u + "-t", { left: 0, top: 80, width: 1920, opacity: 0 }, `<div style="${titleCss(180, th.title)}">${esc(b.title)}</div>`)}
${div(u + "-s", { left: 0, top: 880, width: 1920, textAlign: "center", opacity: 0 }, `<span class="chip">${esc(b.sub)}</span>`)}`);
  ctx.js(`tl.fromTo("#${u}-a", { x: -1500, y: -400 }, { x: 0, y: 0, duration: 0.45, ease: "power3.in" }, ${t + 0.3});
tl.fromTo("#${u}-b", { x: 1500, y: -400 }, { x: 0, y: 0, duration: 0.45, ease: "power3.in" }, ${t + 0.3});
tl.fromTo("#${u}-sp", { opacity: 1, scale: 0.3 }, { opacity: 1, scale: 1.6, rotation: 25, duration: 0.5, ease: "power3.out", ...NF }, ${t + 0.75}); tl.to("#${u}-sp", { opacity: 0, duration: 0.3 }, ${t + 1.1});
FLASH(${t + 0.75}, 0.8, 0.35); SHAKE("#${ctx.S}-shake", ${t + 0.75}, 0.4, 30);
tl.fromTo("#${u}-t", { y: -300, opacity: 0 }, { y: 0, opacity: 1, duration: 0.6, ease: "bounce.out", ...NF }, ${t + 1.3});
POP("#${u}-s", ${t + 2.1});
tl.to(["#${u}-a .hl", "#${u}-b .hl"], { opacity: 0.55, duration: 0.4, yoyo: true, repeat: 3 }, ${t + 1.6});`);
  burst(ctx, "fx", 960, 470, 26, "#FFE08A", t + 0.75, [200, 600], 10, 0.6);
  ctx.sfx("whoosh", t + 0.3, 0.5); ctx.sfx("impact-bass-2", t + 0.75, 0.65); ctx.sfx("pop", t + 2.1, 0.3);
  return { dur: 4.3 };
});
def("opener", "op-scroll", "Cuộn giấy mở ra", (ctx, b, t) => {
  const u = ctx.uid("op"), th = ctx.theme;
  const wind = Array.from({ length: 8 }, (_, i) => div(`${u}-w${i}`, { left: -600, top: ctx.range(100, 980), width: ctx.range(300, 600), height: 6, borderRadius: 3, background: "rgba(255,255,255,.5)" })).join("");
  ctx.add("fx", `<div class="fill" style="background:linear-gradient(${th.dark}, ${th.mid})"></div>${wind}
${div(u + "-p", { left: 260, top: 300, width: 1400, height: 440, background: "#F3E6C8", border: "6px solid #3B2A1A", boxShadow: "0 20px 60px rgba(0,0,0,.5)", transform: "scaleX(0)" }, `<div style="position:absolute;left:0;top:80px;width:100%;${titleCss(150, "#3B2A1A", "#F3E6C8")};text-shadow:none;-webkit-text-stroke:0">${esc(b.title)}</div><div style="position:absolute;left:0;top:290px;width:100%;text-align:center;font:600 46px 'Space Grotesk';color:#8A2A1E">${esc(b.sub)}</div>`)}
${[0, 1].map((i) => div(`${u}-rod${i}`, { left: 930, top: 270, width: 60, height: 500, borderRadius: 14, background: "linear-gradient(90deg,#5A3825,#8A5A34,#5A3825)", border: "5px solid #111" })).join("")}`);
  ctx.js(`tl.to("#${u}-p", { scaleX: 1, duration: 1.1, ease: "power3.inOut" }, ${t + 0.3});
tl.to("#${u}-rod0", { x: -730, duration: 1.1, ease: "power3.inOut" }, ${t + 0.3}); tl.to("#${u}-rod1", { x: 730, duration: 1.1, ease: "power3.inOut" }, ${t + 0.3});
${Array.from({ length: 8 }, (_, i) => `tl.to("#${u}-w${i}", { x: 2700, duration: ${f2(ctx.range(1, 1.8))}, ease: "none", repeat: 2 }, ${f2(t + ctx.range(0, 1))});`).join("\n")}
tl.to("#${u}-p", { scale: 1.04, duration: 0.6, yoyo: true, repeat: 3, ease: "sine.inOut" }, ${t + 1.6});`);
  ctx.sfx("whoosh-cinematic", t + 0.3, 0.4, 1.4); ctx.sfx("chime", t + 1.4, 0.3, 1.5);
  return { dur: 4.2 };
});
def("opener", "op-moon", "Bóng kiếm khách dưới trăng", (ctx, b, t) => {
  const u = ctx.uid("op"), th = ctx.theme, mx = ctx.range(1100, 1400);
  ctx.add("fx", `<div class="fill" style="background:linear-gradient(#070B1E, ${th.dark} 70%, #000)"></div>
${Array.from({ length: 40 }, () => div(null, { left: ctx.range(0, 1920), top: ctx.range(0, 700), width: 5, height: 5, borderRadius: "50%", background: "#fff", opacity: f2(ctx.range(0.3, 1)) })).join("")}
${div(u + "-m", { left: mx - 260, top: 120, width: 520, height: 520, borderRadius: "50%", background: "#FFF1C2", boxShadow: `0 0 120px ${th.light}` })}
<svg class="fill" viewBox="0 0 1920 1080" width="1920" height="1080"><path d="M0 820 L700 820 Q760 790 800 760 L1920 760 L1920 1080 L0 1080 Z" fill="#05050A"/></svg>
${div(u + "-h", { left: mx - 150, top: 330, filter: "brightness(0)" }, ctx.rig("teo", u + "h", 300, { band: "#D7263D", weapon: "kiem" }))}
${div(u + "-t", { left: 0, top: 820, width: 1920, opacity: 0 }, `<div style="${titleCss(130, th.title)}">${esc(b.title)}</div>`)}
${div(u + "-s", { left: 0, top: 960, width: 1920, textAlign: "center", opacity: 0, font: "600 44px 'Space Grotesk'", color: th.light }, esc(b.sub))}`);
  ctx.js(`tl.fromTo("#${u}-m", { y: 260, scale: 0.7 }, { y: 0, scale: 1, duration: 2, ease: "power2.out" }, ${t});
tl.fromTo("#${u}-h", { opacity: 0, y: 30 }, { opacity: 1, y: 0, duration: 0.8, ...NF }, ${t + 0.6});
${ctx.v2 ? `SWAY("${u}h-tail", ${t}, ${t + 4.2}, 14, 0.2);` : `tl.to("#${u}h-tail", { rotation: 14, svgOrigin: PIV.teo.tail, duration: 0.2, yoyo: true, repeat: 21, ease: "sine.inOut" }, ${t});`}
POSE("${u}h", "raise", ${t + 1.6}, 0.4);
tl.fromTo("#${u}-t", { opacity: 0, letterSpacing: "40px" }, { opacity: 1, letterSpacing: "0px", duration: 0.9, ease: "power3.out", ...NF }, ${t + 1.9});
SHOW("#${u}-s", ${t + 2.6}, 0.5, { y: 20 });`);
  ctx.rigType(u + "h", "teo");
  ctx.sfx("riser", t + 0.3, 0.3, 1.8); ctx.sfx("sparkle", t + 1.7, 0.35); ctx.sfx("impact-bass-1", t + 1.9, 0.45);
  return { dur: 4.4 };
});

// ============================ TRANSITION (overlay around cut time c; cover c-0.45..c, uncover c..c+0.55) ============================
const COVER = 0.45;
def("transition", "tr-ink", "Vệt mực quét", (ctx, b, c) => {
  const u = ctx.uid("tr"), dir = ctx.pick([1, -1]), y1 = ctx.range(300, 800), y2 = ctx.range(300, 800);
  const P = (x) => (dir > 0 ? x : 1920 - x);
  ctx.add("over", `<svg class="fill" viewBox="0 0 1920 1080" width="1920" height="1080" style="overflow:visible"><path id="${u}-a" d="M${P(-1100)} ${f2(y1)} C ${P(300)} ${f2(y1 - 350)}, ${P(1500)} ${f2(y2 + 350)}, ${P(2300)} ${f2(y2)}" fill="none" stroke="${ctx.theme.ink}" stroke-width="1500" stroke-linecap="round"/><path id="${u}-b" d="M${P(-300)} ${f2(y1 - 760)} C ${P(500)} ${f2(y1 - 1000)}, ${P(1400)} ${f2(y2 - 500)}, ${P(2300)} ${f2(y2 - 780)}" fill="none" stroke="${ctx.theme.ink}" stroke-width="110" stroke-linecap="round"/></svg>`);
  ctx.js(`DASHLEN("${u}-a"); DASHLEN("${u}-b"); DRAW("#${u}-b", ${f2(c - COVER - 0.05)}, 0.45, "power2.inOut"); DRAW("#${u}-a", ${f2(c - COVER)}, ${COVER + 0.05}, "power2.inOut"); tl.to(["#${u}-a", "#${u}-b"], { opacity: 0, duration: 0.45 }, ${f2(c + 0.05)});`);
  ctx.sfx("whoosh-cinematic", c - COVER, 0.45, 1.3);
});
def("transition", "tr-iris", "Vòng tròn đóng / mở", (ctx, b, c) => {
  const u = ctx.uid("tr"), x1 = ctx.range(500, 1400), y1 = ctx.range(350, 700), x2 = ctx.range(500, 1400), y2 = ctx.range(350, 700);
  ctx.add("over", div(u + "-i", { left: x1, top: y1, width: 0, height: 0, borderRadius: "50%", boxShadow: "0 0 0 1300px #000, 0 0 0 1310px #000", opacity: 0 }) + div(u + "-r", { left: x1 - 1300, top: y1 - 1300, width: 2600, height: 2600, borderRadius: "50%", boxShadow: `0 0 0 3000px #000`, opacity: 0 }));
  // ring hole: big circle with outside shadow; scale shrinks the hole
  ctx.js(`tl.set("#${u}-r", { opacity: 1, scale: 1 }, ${f2(c - COVER)}); tl.to("#${u}-r", { scale: 0.001, duration: ${COVER}, ease: "power3.in" }, ${f2(c - COVER)});
tl.set("#${u}-r", { left: ${f2(x2 - 1300)}, top: ${f2(y2 - 1300)} }, ${f2(c)}); tl.to("#${u}-r", { scale: 1, duration: 0.55, ease: "power3.out" }, ${f2(c + 0.05)}); tl.set("#${u}-r", { opacity: 0 }, ${f2(c + 0.6)});`);
  ctx.sfx("whoosh-short", c - COVER, 0.45);
});
def("transition", "tr-blinds", "Rèm sọc khép / mở", (ctx, b, c) => {
  const u = ctx.uid("tr"), n = Math.round(ctx.range(6, 12)), vert = ctx.rnd() < 0.5, col = ctx.pick(["#111", ctx.theme.ink, "#2B2D42"]);
  ctx.add("over", Array.from({ length: n }, (_, i) => vert ? div(`${u}-${i}`, { left: (1920 / n) * i, top: 0, width: 1920 / n + 2, height: 1080, background: col, transform: "scaleX(0)" }) : div(`${u}-${i}`, { left: 0, top: (1080 / n) * i, width: 1920, height: 1080 / n + 2, background: col, transform: "scaleY(0)" })).join(""));
  const k = vert ? "scaleX" : "scaleY";
  ctx.js(`for (let i = 0; i < ${n}; i++) { tl.fromTo("#${u}-" + i, { ${k}: 0, transformOrigin: "${vert ? "0% 50%" : "50% 0%"}" }, { ${k}: 1, duration: 0.25, ease: "power2.in", ...NF }, ${f2(c - COVER)} + i * ${f2(0.2 / n)}); tl.to("#${u}-" + i, { ${k}: 0, transformOrigin: "${vert ? "100% 50%" : "50% 100%"}", duration: 0.3, ease: "power2.out" }, ${f2(c + 0.05)} + i * ${f2(0.2 / n)}); }`);
  ctx.sfx("whoosh-short", c - COVER, 0.4); ctx.sfx("click", c, 0.3);
});
def("transition", "tr-slash", "Nhát chém cắt đôi màn hình", (ctx, b, c) => {
  const u = ctx.uid("tr"), y1 = ctx.range(-100, 300), y2 = ctx.range(780, 1180), flip = ctx.rnd() < 0.5;
  const A = flip ? [1920, y1] : [0, y1], B = flip ? [0, y2] : [1920, y2];
  ctx.add("over", `<svg class="fill" viewBox="0 0 1920 1080" width="1920" height="1080" style="overflow:visible">
<polygon id="${u}-p" points="${A} ${B} ${flip ? "-2200,1180 -2200,-100" : "2200,1180 2200,-100"}" fill="#0B0B10" transform="translate(${flip ? -2400 : 2400} 0)"/>
<polygon id="${u}-q" points="${A} ${B} ${flip ? "4200,1180 4200,-100" : "-2400,1180 -2400,-100"}" fill="#0B0B10" transform="translate(${flip ? 2400 : -2400} 0)"/>
<g id="${u}-l" stroke-dashoffset="1">${glowStroke("line", `x1="${A[0]}" y1="${A[1]}" x2="${B[0]}" y2="${B[1]}" pathLength="1" stroke-dasharray="1" stroke-linecap="round"`, 22, "#fff", ctx.theme.qi, 18)}</g></svg>`);
  ctx.js(`DRAW("#${u}-l", ${f2(c - COVER)}, 0.15, "power4.out"); tl.to(["#${u}-p", "#${u}-q"], { x: 0, duration: 0.28, ease: "power3.in" }, ${f2(c - 0.3)}); tl.to("#${u}-l", { opacity: 0, duration: 0.1 }, ${f2(c - 0.1)});
tl.to("#${u}-p", { x: ${flip ? -2400 : 2400}, duration: 0.5, ease: "power3.in" }, ${f2(c + 0.05)}); tl.to("#${u}-q", { x: ${flip ? 2400 : -2400}, duration: 0.5, ease: "power3.in" }, ${f2(c + 0.05)});`);
  ctx.sfx("whoosh", c - COVER, 0.5); ctx.sfx("impact-bass-1", c - 0.05, 0.35);
});
def("transition", "tr-paper", "Tờ giấy trượt qua", (ctx, b, c) => {
  const u = ctx.uid("tr"), dir = ctx.pick(["x", "y"]), s = ctx.pick([1, -1]), d = dir === "x" ? 1980 : 1140;
  ctx.add("over", div(u + "-p", { left: 0, top: 0, width: 1920, height: 1080, background: "#F1E3C6", backgroundImage: "radial-gradient(rgba(120,80,30,.1) 1.5px, transparent 1.5px)", backgroundSize: "22px 22px", boxShadow: "0 0 80px rgba(0,0,0,.6)", transform: `translate${dir.toUpperCase()}(${s * d}px)` }, div(null, { left: 860, top: 440, width: 200, height: 200, borderRadius: "50%", background: "#FFD23F", border: "8px solid #3B2A1A", font: "700 110px/186px 'Space Grotesk'", color: "#3B2A1A", textAlign: "center" }, "T")));
  ctx.js(`tl.to("#${u}-p", { ${dir}: 0, duration: ${COVER}, ease: "power3.inOut" }, ${f2(c - COVER)}); tl.to("#${u}-p", { ${dir}: ${-s * d}, duration: 0.55, ease: "power3.inOut" }, ${f2(c + 0.1)});`);
  ctx.sfx("whoosh-short", c - COVER, 0.45); ctx.sfx("whoosh-short", c + 0.1, 0.35);
});
def("transition", "tr-scroll", "Tấm vải cuộn xuống / cuộn lên", (ctx, b, c) => {
  const u = ctx.uid("tr"), col = ctx.pick(["#8A2A1E", "#1D3B6E", "#2B2D42", "#3E5A3A"]);
  ctx.add("over", div(u + "-v", { left: 0, top: 0, width: 1920, height: 1080, background: `repeating-linear-gradient(90deg, ${col} 0 80px, rgba(0,0,0,.12) 80px 84px), ${col}`, transform: "scaleY(0)", transformOrigin: "50% 0%" }, div(null, { left: 860, top: 380, width: 200, height: 320, border: "8px solid #E3A21A", borderRadius: 12, font: "700 90px/1.1 'Space Grotesk'", color: "#E3A21A", textAlign: "center", paddingTop: 30 }, "武<br>俠")) + div(u + "-rod", { left: -20, top: -70, width: 1960, height: 46, borderRadius: 23, background: "linear-gradient(#8A5A34,#5A3825)", border: "5px solid #111" }));
  ctx.js(`tl.to("#${u}-v", { scaleY: 1, duration: ${COVER}, ease: "power2.in" }, ${f2(c - COVER)}); tl.to("#${u}-rod", { y: 1130, duration: ${COVER}, ease: "power2.in" }, ${f2(c - COVER)});
tl.to("#${u}-v", { scaleY: 0, duration: 0.5, ease: "power2.inOut" }, ${f2(c + 0.1)}); tl.to("#${u}-rod", { y: 0, duration: 0.5, ease: "power2.inOut" }, ${f2(c + 0.1)});`);
  ctx.sfx("whoosh", c - COVER, 0.4); ctx.sfx("whoosh-short", c + 0.1, 0.35);
});
def("transition", "tr-shards", "Ô vuông lật phủ kín", (ctx, b, c) => {
  const u = ctx.uid("tr"), cols = 8, rows = 5, w = 1920 / cols, h = 1080 / rows, col = ctx.pick([ctx.theme.ink, "#111", ctx.theme.dark]);
  const order = Array.from({ length: cols * rows }, (_, i) => i).sort(() => ctx.rnd() - 0.5);
  ctx.add("over", order.map((i) => div(`${u}-${i}`, { left: (i % cols) * w, top: Math.floor(i / cols) * h, width: w + 2, height: h + 2, background: col, transform: "scale(0) rotate(45deg)" })).join(""));
  ctx.js(order.map((i, k) => `tl.to("#${u}-${i}", { scale: 1, rotation: 0, duration: 0.22, ease: "power2.out" }, ${f2(c - COVER + (k / order.length) * 0.22)}); tl.to("#${u}-${i}", { scale: 0, rotation: -45, duration: 0.25, ease: "power2.in" }, ${f2(c + 0.05 + ctx.range(0, 0.3))});`).join("\n"));
  ctx.sfx("glitch-1", c - COVER, 0.25, 1); ctx.sfx("whoosh-short", c + 0.05, 0.35);
});
def("transition", "tr-flash", "Chớp trắng + tia tốc độ", (ctx, b, c) => {
  const u = ctx.uid("tr");
  ctx.add("over", div(u + "-l", { left: -540, top: -960, width: 3000, height: 3000, background: `repeating-conic-gradient(from ${f2(ctx.range(0, 30))}deg at 50% 50%, rgba(255,255,255,.95) 0deg 2deg, transparent 2deg ${f2(ctx.range(6, 10))}deg)`, opacity: 0 }) + div(u + "-w", { left: 0, top: 0, width: 1920, height: 1080, background: "#fff", opacity: 0 }));
  ctx.js(`tl.fromTo("#${u}-l", { opacity: 0, scale: 0.4 }, { opacity: 1, scale: 1.4, duration: ${COVER}, ease: "power2.in", ...NF }, ${f2(c - COVER)}); tl.to("#${u}-w", { opacity: 1, duration: 0.2, ease: "power2.in" }, ${f2(c - 0.2)});
tl.set("#${u}-l", { opacity: 0 }, ${f2(c)}); tl.to("#${u}-w", { opacity: 0, duration: 0.5, ease: "power2.out" }, ${f2(c + 0.02)});`);
  ctx.sfx("riser", c - COVER, 0.3, 0.6); ctx.sfx("impact-bass-1", c, 0.4);
});

// ============================ CAMERA (whole scene) ============================
const cam = (id, label, from, to, ease = "sine.inOut") => def("camera", id, label, (ctx, b, t) => {
  const o = typeof from === "function" ? from(ctx) : from, e = typeof to === "function" ? to(ctx) : to;
  ctx.js(`tl.fromTo("#${ctx.S}-cam", ${JSON.stringify({ transformOrigin: "50% 60%", ...o })}, { ...${JSON.stringify(e)}, duration: ${f2(ctx.t1 - ctx.t0)}, ease: "${ease}" }, ${f2(ctx.t0)});`);
  return { dur: 0 };
});
cam("cam-drift-l", "Máy quay trôi sang trái", (c) => ({ scale: 1.06, x: c.range(20, 50) }), (c) => ({ scale: 1.08, x: -c.range(20, 50) }));
cam("cam-drift-r", "Máy quay trôi sang phải", (c) => ({ scale: 1.06, x: -c.range(20, 50) }), (c) => ({ scale: 1.08, x: c.range(20, 50) }));
cam("cam-push", "Đẩy máy chậm vào", { scale: 1 }, (c) => ({ scale: c.range(1.08, 1.14) }));
cam("cam-pull", "Lùi máy chậm ra", (c) => ({ scale: c.range(1.1, 1.16) }), { scale: 1.0 });
cam("cam-tilt", "Máy quay nghiêng nhẹ", (c) => ({ scale: 1.07, rotation: c.pick([-1.2, 1.2]) }), (c) => ({ scale: 1.07, rotation: c.pick([-0.6, 0.6]) }));
cam("cam-rise", "Máy quay nâng lên", (c) => ({ scale: 1.08, y: -c.range(30, 50) }), (c) => ({ scale: 1.08, y: c.range(20, 40) }));

// ============================ ENTER (beat: {who, from?: "left"|"right"}) ============================
const side = (ctx, a, b) => b.from || (a.cx < 960 ? "left" : "right");
def("enter", "en-run", "Chạy vào", (ctx, b, t) => {
  const a = ctx.actor(b.who), s = side(ctx, a, b) === "left" ? -1 : 1, d = 1.0;
  ctx.js(`tl.set("#${a.wrap}", { opacity: 1 }, ${t}); tl.fromTo("#${a.wrap}", { x: ${f2(a.ox + s * 1200)} }, { x: ${f2(a.ox)}, duration: ${d}, ease: "power2.out", ...NF }, ${t}); RUN("${a.p}", ${t}, ${f2(t + d - 0.1)}, "#${a.body}", ${a.type === "teo"});`);
  dust(ctx, a.cx, a.foot - 20, t + d - 0.1, 5);
  ctx.sfx("whoosh-short", t, 0.35);
  return { dur: d + 0.15 };
});
def("enter", "en-leap", "Phi thân nhảy vào", (ctx, b, t) => {
  const a = ctx.actor(b.who), s = side(ctx, a, b) === "left" ? -1 : 1, d = 0.9, hy = -ctx.range(380, 520);
  ctx.js(`tl.set("#${a.wrap}", { opacity: 1 }, ${t});
tl.fromTo("#${a.wrap}", { x: ${f2(a.ox + s * 900)} }, { x: ${f2(a.ox)}, duration: ${d}, ease: "power1.out", ...NF }, ${t});
tl.fromTo("#${a.wrap}", { y: -200 }, { y: ${f2(hy)}, duration: ${d / 2}, ease: "power2.out", ...NF }, ${t}); tl.to("#${a.wrap}", { y: 0, duration: ${d / 2}, ease: "power2.in" }, ${f2(t + d / 2)});
tl.fromTo("#${a.body}", { rotation: ${s * 20} }, { rotation: ${-s * 340}, duration: ${d}, ease: "power1.inOut", transformOrigin: "50% 50%", ...NF }, ${t}); tl.set("#${a.body}", { rotation: 0 }, ${f2(t + d)});
tl.to("#${a.body}", { scaleY: 0.82, scaleX: 1.1, transformOrigin: "50% 100%", duration: 0.08 }, ${f2(t + d)}); tl.to("#${a.body}", { scaleY: 1, scaleX: 1, duration: 0.3, ease: "back.out(3)" }, ${f2(t + d + 0.08)});`);
  dust(ctx, a.cx, a.foot - 20, t + d, 7);
  ctx.sfx("whoosh", t, 0.4); ctx.sfx("impact-bass-1", t + d, 0.35);
  return { dur: d + 0.45 };
});
def("enter", "en-drop", "Rơi từ trời xuống", (ctx, b, t) => {
  const a = ctx.actor(b.who), d = 0.55, u = ctx.uid("dr"), th = ctx.theme;
  ctx.add("fx", div(u, { left: a.cx - 260, top: a.foot - 60, width: 520, height: 120, borderRadius: "50%", border: `12px solid ${th.qi}`, opacity: 0 }) + `<svg style="position:absolute;left:${f2(a.cx - 300)}px;top:${f2(a.foot - 30)}px;overflow:visible" width="600" height="120"><path id="${u}-c" pathLength="1" stroke-dasharray="1" stroke-dashoffset="1" d="M300 30 L230 60 L180 50 L120 90 M300 30 L370 70 L430 60 L500 100 M300 30 L300 90" fill="none" stroke="#3B2A1A" stroke-width="6" stroke-linejoin="round"/></svg>`);
  ctx.js(`tl.set("#${a.wrap}", { opacity: 1 }, ${t}); tl.fromTo("#${a.wrap}", { y: -1300 }, { y: 0, duration: ${d}, ease: "power3.in", ...NF }, ${t});
tl.to("#${a.body}", { scaleY: 0.78, scaleX: 1.12, transformOrigin: "50% 100%", duration: 0.07 }, ${f2(t + d)}); tl.to("#${a.body}", { scaleY: 1, scaleX: 1, duration: 0.35, ease: "back.out(3)" }, ${f2(t + d + 0.07)});
tl.fromTo("#${u}", { scale: 0.2, opacity: 1 }, { scale: 1.6, opacity: 0, duration: 0.6, ease: "power2.out", ...NF }, ${f2(t + d)}); DRAW("#${u}-c", ${f2(t + d)}, 0.2);
SHAKE("#${ctx.S}-shake", ${f2(t + d)}, 0.4, 28); FLASH(${f2(t + d)}, 0.35, 0.25);`);
  dust(ctx, a.cx, a.foot - 20, t + d, 8);
  ctx.sfx("whoosh-short", t, 0.4); ctx.sfx("impact-bass-2", t + d, 0.55);
  return { dur: d + 0.6 };
});
def("enter", "en-smoke", "Hiện ra từ làn khói", (ctx, b, t) => {
  const a = ctx.actor(b.who), u = ctx.uid("sm"), n = 9;
  ctx.add("fx", Array.from({ length: n }, (_, i) => div(`${u}-${i}`, { left: a.cx - 90 + ctx.range(-90, 90), top: a.cy - 90 + ctx.range(-170, 170), width: 180, height: 180, borderRadius: "50%", background: ctx.pick(["#E8E4DC", "#D2CCC2", "#F4F1EA"]), border: "5px solid rgba(0,0,0,.25)", opacity: 0 })).join(""));
  ctx.js(`for (let i = 0; i < ${n}; i++) { tl.fromTo("#${u}-" + i, { scale: 0.2, opacity: 0 }, { scale: 1.3, opacity: 1, duration: 0.25, ease: "back.out(2)", ...NF }, ${t} + i * 0.03); tl.to("#${u}-" + i, { scale: 1.8, opacity: 0, y: -60, duration: 0.6, ease: "power1.in" }, ${t + 0.45} + i * 0.03); }
tl.set("#${a.wrap}", { opacity: 1 }, ${t + 0.3});`);
  ctx.sfx("pop", t, 0.4); ctx.sfx("sparkle", t + 0.3, 0.3);
  return { dur: 1.2 };
});
def("enter", "en-slide", "Lướt tới + phanh tóe bụi", (ctx, b, t) => {
  const a = ctx.actor(b.who), s = side(ctx, a, b) === "left" ? -1 : 1, d = 0.35, u = ctx.uid("sl");
  ctx.add("fx", Array.from({ length: 7 }, (_, i) => div(`${u}-${i}`, { left: s < 0 ? 0 : a.cx, top: a.top + 40 + i * (a.h / 8), width: Math.max(200, s < 0 ? a.cx : 1920 - a.cx), height: 8, borderRadius: 4, background: "rgba(255,255,255,.85)", opacity: 0, transformOrigin: s < 0 ? "100% 50%" : "0% 50%" })).join(""));
  ctx.js(`tl.set("#${a.wrap}", { opacity: 1 }, ${t}); tl.fromTo("#${a.wrap}", { x: ${f2(a.ox + s * 1300)} }, { x: ${f2(a.ox)}, duration: ${d}, ease: "power4.out", ...NF }, ${t});
tl.fromTo("#${a.body}", { rotation: ${s * 14}, transformOrigin: "50% 100%" }, { rotation: 0, duration: 0.5, ease: "back.out(3)", ...NF }, ${f2(t + d - 0.05)});
for (let i = 0; i < 7; i++) tl.fromTo("#${u}-" + i, { opacity: 1, scaleX: 1 }, { opacity: 0, scaleX: 0.1, duration: 0.45, ...NF }, ${t} + i * 0.02);`);
  dust(ctx, a.cx + s * 40, a.foot - 20, t + d - 0.05, 6);
  ctx.sfx("whoosh", t, 0.45);
  return { dur: 0.9 };
});
def("enter", "en-spin", "Xoay tròn lộn vào", (ctx, b, t) => {
  const a = ctx.actor(b.who), s = side(ctx, a, b) === "left" ? -1 : 1, d = 0.8, u = ctx.uid("sp");
  ctx.add("fx", div(u, { left: a.cx, top: a.cy, width: 0, height: 0, opacity: 0 }, star4("#FFF8D0", "#E3A21A")));
  ctx.js(`tl.set("#${a.wrap}", { opacity: 1 }, ${t}); tl.fromTo("#${a.wrap}", { x: ${f2(a.ox + s * 1100)}, y: -160 }, { x: ${f2(a.ox)}, y: 0, duration: ${d}, ease: "power2.out", ...NF }, ${t});
tl.fromTo("#${a.body}", { rotation: 0, transformOrigin: "50% 55%" }, { rotation: ${-s * 720}, duration: ${d}, ease: "power2.out", ...NF }, ${t}); tl.set("#${a.body}", { rotation: 0 }, ${f2(t + d)});
tl.fromTo("#${u}", { opacity: 1, scale: 0, rotation: 0 }, { scale: 1.3, rotation: 90, duration: 0.3, ease: "back.out(2)", ...NF }, ${f2(t + d)}); tl.to("#${u}", { opacity: 0, duration: 0.25 }, ${f2(t + d + 0.3)});`);
  ctx.sfx("whoosh-cinematic", t, 0.35, 1); ctx.sfx("sparkle", t + d, 0.3);
  return { dur: d + 0.4 };
});

// ============================ INTRO (beat: {who, name, title?}) ============================
def("intro", "in-silhouette", "Bóng đen rồi lộ mặt", (ctx, b, t) => {
  const a = ctx.actor(b.who), u = ctx.uid("in");
  ctx.add("fx", div(u + "-q", { left: a.cx - 150, top: a.cy - 200, width: 300, textAlign: "center", opacity: 0 }, `<div style="${titleCss(260, "#fff")}">?</div>`) + div(u + "-r", { left: a.cx - 260, top: a.cy - 260, width: 520, height: 520, borderRadius: "50%", border: `14px solid ${ctx.theme.qi}`, opacity: 0 }));
  ctx.add("hud", div(u + "-n", { left: a.cx - 300, top: Math.min(a.foot + 10, b.title ? 900 : 960), width: 600, textAlign: "center", opacity: 0 }, `<span class="nameplate">${esc(b.name)}</span>${b.title ? `<br><span class="nametag">${esc(b.title)}</span>` : ""}`));
  ctx.js(`tl.set("#${a.inner}", { filter: "brightness(0)" }, ${t}); POP("#${u}-q", ${t + 0.1}); tl.to("#${u}-q", { rotation: 10, duration: 0.15, yoyo: true, repeat: 3 }, ${t + 0.4});
tl.to("#${a.inner}", { filter: "brightness(1)", duration: 0.35 }, ${t + 1.0}); tl.to("#${u}-q", { scale: 1.5, opacity: 0, duration: 0.3 }, ${t + 1.0});
tl.fromTo("#${u}-r", { scale: 0.3, opacity: 1 }, { scale: 1.35, opacity: 0, duration: 0.7, ease: "power2.out", ...NF }, ${t + 1.0}); FLASH(${t + 1.0}, 0.45, 0.3);
SHOW("#${u}-n", ${t + 1.3}, 0.35, { y: 40 }); HIDE("#${u}-n", ${t + 3.2});`);
  ctx.sfx("pop", t + 0.1, 0.3); ctx.sfx("sparkle", t + 1.0, 0.4); ctx.sfx("click", t + 1.3, 0.4);
  return { dur: 3.0 };
});
def("intro", "in-plate", "Bảng tên treo dây thả xuống", (ctx, b, t) => {
  const a = ctx.actor(b.who), u = ctx.uid("in"), x = Math.max(60, Math.min(1860 - 520, a.cx - 260));
  ctx.add("hud", div(u, { left: x, top: -420, width: 520, height: 400 }, `<div style="position:absolute;left:90px;top:0;width:6px;height:240px;background:#3B2A1A"></div><div style="position:absolute;left:424px;top:0;width:6px;height:240px;background:#3B2A1A"></div><div style="position:absolute;left:0;top:236px;width:520px;text-align:center"><span class="plq">${esc(b.name)}</span>${b.title ? `<div style="margin-top:14px"><span class="nametag">${esc(b.title)}</span></div>` : ""}</div>`));
  ctx.js(`tl.to("#${u}", { y: ${f2(Math.max(160, a.top - 80))}, duration: 0.7, ease: "bounce.out" }, ${t}); tl.to("#${u}", { rotation: 3, transformOrigin: "50% 0%", duration: 0.5, yoyo: true, repeat: 3, ease: "sine.inOut" }, ${t + 0.7}); tl.to("#${u}", { y: -40, duration: 0.4, ease: "power2.in" }, ${t + 2.7});`);
  ctx.sfx("whoosh-short", t, 0.35); ctx.sfx("impact-bass-1", t + 0.35, 0.35);
  return { dur: 3.0 };
});
def("intro", "in-freeze", "Đóng băng + dải màu chéo ghi tên", (ctx, b, t) => {
  const a = ctx.actor(b.who), u = ctx.uid("in"), th = ctx.theme, left = a.cx > 960;
  ctx.add("hud", div(u + "-band", { left: -200, top: 640, width: 2400, height: 210, background: th.qi, transform: "rotate(-6deg) scaleX(0)", transformOrigin: left ? "100% 50%" : "0% 50%", boxShadow: "0 0 0 8px #111" }) + div(u + "-n", { left: left ? 120 : 900, top: 680, width: 900, opacity: 0, transform: "rotate(-6deg)" }, `<div style="${titleCss(96, "#fff")};text-align:left">${esc(b.name)}</div>${b.title ? `<div style="font:700 40px 'Space Grotesk';color:#111;margin-top:6px">${esc(b.title)}</div>` : ""}`));
  ctx.js(`tl.to("#${ctx.S}-bg", { filter: "grayscale(1) brightness(0.7)", duration: 0.12 }, ${t}); tl.to("#${ctx.S}-cam", { scale: "+=0.12", transformOrigin: "${f2(a.cx)}px ${f2(a.cy)}px", duration: 0.25, ease: "power3.out" }, ${t});
tl.to("#${u}-band", { scaleX: 1, duration: 0.3, ease: "power3.out" }, ${t + 0.1}); tl.fromTo("#${u}-n", { x: ${left ? -200 : 200}, opacity: 0 }, { x: 0, opacity: 1, duration: 0.35, ease: "power3.out", ...NF }, ${t + 0.25});
tl.to(["#${u}-band", "#${u}-n"], { opacity: 0, duration: 0.25 }, ${t + 2.2}); tl.to("#${ctx.S}-bg", { filter: "grayscale(0) brightness(1)", duration: 0.25 }, ${t + 2.2}); tl.to("#${ctx.S}-cam", { scale: "-=0.12", duration: 0.35 }, ${t + 2.2});`);
  ctx.sfx("click", t, 0.45); ctx.sfx("whoosh", t + 0.1, 0.4); ctx.sfx("impact-bass-1", t + 0.3, 0.4);
  return { dur: 2.6 };
});
def("intro", "in-scroll", "Cuộn thư dọc ghi danh", (ctx, b, t) => {
  const a = ctx.actor(b.who), u = ctx.uid("in"), x = a.cx > 960 ? a.x - 200 : a.x + a.w + 40;
  const name = [...b.name].map((ch) => (ch === " " ? "<br>" : esc(ch))).join("");
  ctx.add("hud", div(u, { left: Math.max(30, Math.min(1720, x)), top: 120, width: 170, height: 760, background: "#F3E6C8", border: "6px solid #3B2A1A", borderRadius: 10, transform: "scaleY(0)", transformOrigin: "50% 0%", boxShadow: "8px 8px 0 rgba(0,0,0,.3)" }, `<div style="position:absolute;left:-20px;top:-26px;width:198px;height:34px;border-radius:17px;background:#5A3825;border:5px solid #111"></div><div style="padding:40px 0;text-align:center;font:700 64px/1.05 'Space Grotesk';color:#8A2A1E">${name}</div>`));
  ctx.js(`tl.to("#${u}", { scaleY: 1, duration: 0.7, ease: "power2.out" }, ${t}); tl.to("#${u}", { scaleY: 0, duration: 0.4, ease: "power2.in" }, ${t + 2.6});`);
  ctx.sfx("whoosh-cinematic", t, 0.35, 1.2);
  return { dur: 3.0 };
});
def("intro", "in-stamp", "Ấn triện đỏ đóng tên", (ctx, b, t) => {
  const a = ctx.actor(b.who), u = ctx.uid("in"), x = Math.max(40, Math.min(1500, a.cx > 960 ? a.x - 420 : a.x + a.w + 20)), y = Math.max(120, a.top);
  ctx.add("hud", div(u + "-s", { left: x, top: y, width: 230, height: 230, borderRadius: 24, background: "#C8372D", border: "8px solid #F3E6C8", boxShadow: "0 0 0 6px #C8372D", font: "700 150px/212px 'Space Grotesk'", color: "#F3E6C8", textAlign: "center", opacity: 0 }, esc([...b.name][0])) + div(u + "-n", { left: x - 60, top: y + 250, width: 350, textAlign: "center", opacity: 0 }, `<span class="nameplate">${esc(b.name)}</span>${b.title ? `<br><span class="nametag">${esc(b.title)}</span>` : ""}`));
  ctx.js(`STAMP("#${u}-s", ${t}, ${f2(ctx.range(-14, 10))}); SHAKE("#${ctx.S}-shake", ${t + 0.26}, 0.25, 14); SHOW("#${u}-n", ${t + 0.5}, 0.3, { y: 30 }); HIDE(["#${u}-s", "#${u}-n"], ${t + 2.5});`);
  ctx.sfx("impact-bass-1", t + 0.22, 0.5); ctx.sfx("click", t + 0.5, 0.35);
  return { dur: 2.8 };
});

// ============================ POWER (beat: {who, name?}) ============================
def("power", "pw-vortex", "Xoáy khí hút vào người", (ctx, b, t) => {
  const a = ctx.actor(b.who), u = ctx.uid("pw"), th = ctx.theme, size = a.h * 1.5, d = 2.6, dir = ctx.pick([1, -1]);
  const spiral = [0, 1, 2, 3].map((k) => `<path transform="rotate(${k * 90} 350 350)" d="M350 350 C 430 300, 500 370, 460 460 C 420 560, 250 570, 190 470" fill="none" stroke="${th.light}" stroke-width="16" stroke-linecap="round" opacity=".85"/>`).join("");
  ctx.add("behind", div(u, { left: a.cx - size / 2, top: a.cy - size / 2, width: size, height: size, opacity: 0 }, `<svg viewBox="0 0 700 700" width="${f2(size)}" height="${f2(size)}"><defs><radialGradient id="${u}-g"><stop offset="0" stop-color="#fff"/><stop offset=".25" stop-color="${th.qi}"/><stop offset=".7" stop-color="${th.dark}" stop-opacity=".85"/><stop offset="1" stop-color="${th.dark}" stop-opacity="0"/></radialGradient></defs><circle cx="350" cy="350" r="345" fill="url(#${u}-g)"/>${spiral}</svg>`));
  ctx.add("behind", div(u + "-au", { left: a.cx - a.w * 0.8, top: a.top - a.h * 0.25, width: a.w * 1.6, height: a.h * 1.4, borderRadius: "50%", background: `radial-gradient(ellipse at 50% 50%, ${th.qi}cc 0%, ${th.qi}66 38%, ${th.qi}00 70%)`, opacity: 0 }));
  converge(ctx, "fx", a.cx, a.cy, 24, th.light, t + 0.3, t + d);
  ctx.js(`tl.fromTo("#${u}", { opacity: 0, scale: 0.2 }, { opacity: 1, scale: 1, duration: 0.6, ease: "back.out(1.4)", ...NF }, ${t}); tl.to("#${u}", { rotation: ${dir * -900}, duration: ${d}, ease: "none" }, ${t}); tl.to("#${u}", { opacity: 0, scale: 0.4, duration: 0.3 }, ${f2(t + d)});
tl.to("#${a.body}", { y: -50, duration: 0.8, ease: "power2.out" }, ${t + 0.1}); tl.to("#${a.body}", { y: 0, duration: 0.3, ease: "power2.in" }, ${f2(t + d)});
tl.to("#${u}-au", { opacity: 1, duration: 0.5 }, ${t}); tl.to("#${u}-au", { opacity: 0, duration: 0.4 }, ${f2(t + d)});
POSE("${a.p}", "up", ${t + 0.1}, 0.5); POSE("${a.p}", "rest", ${f2(t + d)}, 0.3);`);
  ctx.sfx("riser", t, 0.4, d);
  return { dur: d + 0.3 };
});
def("power", "pw-aura", "Hào quang bốc lửa", (ctx, b, t) => {
  const a = ctx.actor(b.who), u = ctx.uid("pw"), th = ctx.theme, d = 2.2, n = 7;
  ctx.add("behind", Array.from({ length: n }, (_, i) => div(`${u}-${i}`, { left: a.cx - a.w * 0.6 + ctx.range(-30, 30), top: a.top - 40 + ctx.range(-20, 40), width: a.w * 1.2, height: a.h * 1.1, borderRadius: "50% 50% 45% 45% / 70% 70% 30% 30%", background: `radial-gradient(ellipse at 50% 70%, ${i % 2 ? th.qi : th.qi2}cc, transparent 70%)`, opacity: 0 })).join(""));
  const sp = ctx.uid("sk");
  ctx.add("fx", Array.from({ length: 16 }, (_, i) => div(`${sp}-${i}`, { left: a.cx + ctx.range(-a.w * 0.5, a.w * 0.5), top: a.foot - 40, width: 10, height: 26, borderRadius: 5, background: th.light, boxShadow: `0 0 10px ${th.qi}`, opacity: 0 })).join(""));
  ctx.js(`for (let i = 0; i < ${n}; i++) { tl.fromTo("#${u}-" + i, { opacity: 0, scaleY: 0.5, transformOrigin: "50% 100%" }, { opacity: 0.9, scaleY: 1.1, duration: 0.3, ...NF }, ${t} + i * 0.05); tl.to("#${u}-" + i, { scaleY: 0.85, scaleX: 1.08, duration: ${f2(ctx.range(0.12, 0.2))}, yoyo: true, repeat: 11, ease: "sine.inOut" }, ${t + 0.3} + i * 0.03); tl.to("#${u}-" + i, { opacity: 0, duration: 0.3 }, ${f2(t + d)}); }
for (let i = 0; i < 16; i++) tl.fromTo("#${sp}-" + i, { y: 0, opacity: 1 }, { y: -${f2(a.h * 1.1)}, opacity: 0, duration: 0.8, ease: "power1.out", repeat: 1, ...NF }, ${t + 0.2} + i * 0.06);
BROW("${a.p}", ${t}, true); POSE("${a.p}", "guard", ${t}, 0.3); tl.to("#${a.body}", { scaleY: 0.94, transformOrigin: "50% 100%", duration: 0.3 }, ${t}); tl.to("#${a.body}", { scaleY: 1, duration: 0.3 }, ${f2(t + d)});
SHAKE("#${ctx.S}-shake", ${t + 0.3}, 1.4, 6);`);
  ctx.sfx("riser", t, 0.35, d); ctx.sfx("impact-bass-1", t + 0.2, 0.3);
  return { dur: d + 0.3 };
});
def("power", "pw-charge", "Tụ khí thành cầu sáng trên tay", (ctx, b, t) => {
  const a = ctx.actor(b.who), u = ctx.uid("pw"), th = ctx.theme, d = 2.0;
  const hx = a.cx + a.w * 0.35, hy = a.top + a.h * 0.25;
  ctx.add("fx", div(u, { left: hx - 90, top: hy - 90, width: 180, height: 180, borderRadius: "50%", background: `radial-gradient(circle, #fff 0%, ${th.light} 30%, ${th.qi}aa 60%, transparent 72%)`, opacity: 0 }));
  converge(ctx, "fx", hx, hy, 26, th.light, t, t + d - 0.2, [300, 700], 10);
  ctx.js(`POSE("${a.p}", "up", ${t}, 0.35); tl.fromTo("#${u}", { opacity: 0, scale: 0.1 }, { opacity: 1, scale: 1.3, duration: ${d}, ease: "power1.in", ...NF }, ${t}); tl.to("#${u}", { scale: 1.6, yoyo: true, repeat: 5, duration: 0.08 }, ${f2(t + d - 0.5)}); tl.to("#${u}", { opacity: 0, scale: 2.4, duration: 0.25 }, ${f2(t + d)});
tl.to("#${ctx.S}-bg", { filter: "brightness(0.55)", duration: 0.4 }, ${t}); tl.to("#${ctx.S}-bg", { filter: "brightness(1)", duration: 0.3 }, ${f2(t + d)}); POSE("${a.p}", "rest", ${f2(t + d)}, 0.3);`);
  ctx.sfx("riser", t, 0.4, d); ctx.sfx("sparkle", t + d - 0.3, 0.35);
  return { dur: d + 0.3 };
});
def("power", "pw-lightning", "Sấm sét quanh người", (ctx, b, t) => {
  const a = ctx.actor(b.who), u = ctx.uid("pw"), th = ctx.theme, d = 2.0, n = 6;
  const bolt = () => { let x = ctx.range(-60, 60), y = -620, p = `M${f2(x)} ${y}`; while (y < 0) { y += ctx.range(60, 120); x += ctx.range(-70, 70); p += ` L${f2(x)} ${f2(Math.min(0, y))}`; } return p; };
  ctx.add("fx", `<svg style="position:absolute;left:${f2(a.cx)}px;top:${f2(a.top + 40)}px;overflow:visible" width="1" height="1">${Array.from({ length: n }, (_, i) => `<g id="${u}-${i}" opacity="0" transform="translate(${f2(ctx.range(-a.w * 0.9, a.w * 0.9))} ${f2(ctx.range(-40, 120))})"><path d="${bolt()}" fill="none" stroke="${th.qi2}" stroke-width="18" stroke-linejoin="round" opacity=".6"/><path d="${bolt()}" fill="none" stroke="#fff" stroke-width="7" stroke-linejoin="round"/></g>`).join("")}</svg>`);
  ctx.js(`tl.to("#${ctx.S}-bg", { filter: "brightness(0.45) saturate(0.6)", duration: 0.25 }, ${t}); tl.to("#${ctx.S}-bg", { filter: "brightness(1) saturate(1)", duration: 0.3 }, ${f2(t + d)});
for (let k = 0; k < 9; k++) { const i = Math.floor(rand() * ${n}); ATTR("${u}-" + i, ${t + 0.2} + k * 0.2, 1); ATTR("${u}-" + i, ${t + 0.28} + k * 0.2, 0); FLASH(${t + 0.2} + k * 0.2, 0.25, 0.12); }
BROW("${a.p}", ${t}, true); POSE("${a.p}", "raise", ${t}, 0.3); SHAKE("#${ctx.S}-shake", ${t + 0.2}, 1.6, 9);`);
  ctx.sfx("glitch-1", t + 0.2, 0.3, 1.6); ctx.sfx("impact-bass-2", t + 0.2, 0.35); ctx.sfx("impact-bass-1", t + 1.2, 0.3);
  return { dur: d + 0.3 };
});
// giant rig cropped to the eye band (band is 320 tall; eyes land at y=160): teo eyes at 0.234h, npc at 0.383h
// rig 2: hình v2 nằm trong cùng hộp, mắt ở 0.283h
const eyeBox = (type, v2) => { const w = type === "teo" ? 1800 : 1000, h = type === "teo" ? (w * 760) / 500 : w * 1.5, ey = h * (v2 ? 0.283 : type === "teo" ? 0.234 : 0.383); return { left: 960 - w / 2, top: Math.round(160 - ey), width: w, height: h }; };
def("power", "pw-eyes", "Màn đen, ánh mắt lóe sáng", (ctx, b, t) => {
  const a = ctx.actor(b.who), u = ctx.uid("pw"), th = ctx.theme, d = 1.8;
  ctx.add("hud", div(u + "-t", { left: 0, top: 0, width: 1920, height: 0, background: "#000" }) + div(u + "-b", { left: 0, top: 1080, width: 1920, height: 0, background: "#000" }) + div(u + "-g", { left: 0, top: 380, width: 1920, height: 320, opacity: 0, background: "#000", overflow: "hidden" }, div(null, eyeBox(a.type, ctx.v2), ctx.rig(a.type, u + "e", a.type === "teo" ? 1800 : 1000, a.look)) + div(u + "-shine", { left: -400, top: 0, width: 260, height: 320, background: `linear-gradient(90deg, transparent, ${th.light}cc, transparent)`, transform: "skewX(-20deg)" })));
  ctx.rigType(u + "e", a.type);
  ctx.js(`tl.to("#${u}-t", { height: 380, duration: 0.25, ease: "power3.out" }, ${t}); tl.to("#${u}-b", { top: 700, height: 380, duration: 0.25, ease: "power3.out" }, ${t});
tl.set("#${u}-g", { opacity: 1 }, ${t + 0.25}); BROW("${u}e", ${t}, true); tl.to("#${u}-shine", { x: 2600, duration: 0.6, ease: "power2.inOut" }, ${t + 0.5});
tl.set("#${u}-g", { opacity: 0 }, ${f2(t + d - 0.25)}); tl.to("#${u}-t", { height: 0, duration: 0.25 }, ${f2(t + d - 0.25)}); tl.to("#${u}-b", { top: 1080, height: 0, duration: 0.25 }, ${f2(t + d - 0.25)}); BROW("${a.p}", ${f2(t + d - 0.25)}, true);`);
  ctx.sfx("whoosh-short", t, 0.35); ctx.sfx("sparkle", t + 0.5, 0.45); ctx.sfx("impact-bass-1", t + 0.55, 0.35);
  return { dur: d };
});
def("power", "pw-ground", "Đất nứt, đá bay lơ lửng", (ctx, b, t) => {
  const a = ctx.actor(b.who), u = ctx.uid("pw"), th = ctx.theme, d = 2.2, n = 8;
  const crack = Array.from({ length: 5 }, (_, i) => { const dir = i % 2 ? 1 : -1; let x = 0, y = 0, p = "M0 0"; for (let k = 0; k < 4; k++) { x += dir * ctx.range(40, 90); y += ctx.range(-14, 22); p += ` L${f2(x)} ${f2(y)}`; } return `<g id="${u}-c${i}" stroke-dashoffset="1">${glowStroke("path", `d="${p}" pathLength="1" stroke-dasharray="1"`, 7, th.qi, th.qi, 8)}</g>`; }).join("");
  ctx.add("fx", `<svg style="position:absolute;left:${f2(a.cx)}px;top:${f2(a.foot - 6)}px;overflow:visible" width="1" height="1">${crack}</svg>` + Array.from({ length: n }, (_, i) => div(`${u}-r${i}`, { left: a.cx + ctx.range(-a.w * 1.2, a.w * 1.2), top: a.foot - 30, width: ctx.range(24, 54), height: ctx.range(20, 40), borderRadius: "30% 40% 35% 45%", background: "#8A7A66", border: "4px solid #3B2A1A", opacity: 0 })).join(""));
  ctx.js(`for (let i = 0; i < 5; i++) DRAW("#${u}-c" + i, ${t} + i * 0.06, 0.35);
for (let i = 0; i < ${n}; i++) { tl.set("#${u}-r" + i, { opacity: 1 }, ${t + 0.15}); tl.to("#${u}-r" + i, { y: -${f2(a.h * 0.6)} - i * 22, rotation: 40 + i * 30, duration: 0.9, ease: "power2.out" }, ${t + 0.2} + i * 0.05); tl.to("#${u}-r" + i, { y: "+=16", duration: 0.4, yoyo: true, repeat: 1, ease: "sine.inOut" }, ${t + 1.1}); tl.to("#${u}-r" + i, { y: 0, opacity: 0, duration: 0.3, ease: "power2.in" }, ${f2(t + d - 0.2)}); }
tl.to("#${ctx.S}-shake", { y: 4, duration: 0.05, yoyo: true, repeat: 20 }, ${t}); BROW("${a.p}", ${t}, true); POSE("${a.p}", "palm", ${t}, 0.35);`);
  ctx.sfx("impact-bass-2", t, 0.45); ctx.sfx("riser", t + 0.2, 0.3, 1.8);
  return { dur: d };
});

// ============================ IMPACT (called by attacks: run(ctx, {x, y}, t)) ============================
def("impact", "im-flash", "Chớp trắng + rung", (ctx, p, t) => { ctx.js(`FLASH(${f2(t)}, 0.8, 0.35); SHAKE("#${ctx.S}-shake", ${f2(t)}, 0.5, 32);`); ctx.sfx("impact-bass-2", t, 0.65); return { dur: 0.5 }; });
def("impact", "im-hitstop", "Khựng hình + nhòe xám", (ctx, p, t) => {
  ctx.js(`tl.to("#${ctx.S}-bg", { filter: "grayscale(1) contrast(1.4)", duration: 0.05 }, ${f2(t)}); tl.to("#${ctx.S}-bg", { filter: "grayscale(0) contrast(1)", duration: 0.2 }, ${f2(t + 0.35)}); tl.to("#${ctx.S}-cam", { scale: "+=0.05", duration: 0.05 }, ${f2(t)}); tl.to("#${ctx.S}-cam", { scale: "-=0.05", duration: 0.3 }, ${f2(t + 0.35)}); FLASH(${f2(t)}, 0.5, 0.2); SHAKE("#${ctx.S}-shake", ${f2(t + 0.35)}, 0.3, 22);`);
  ctx.sfx("impact-bass-1", t, 0.6); return { dur: 0.6 };
});
def("impact", "im-radial", "Tia tốc độ tỏa tròn", (ctx, p, t) => {
  const u = ctx.uid("im");
  ctx.add("fx", div(u, { left: p.x - 1400, top: p.y - 1400, width: 2800, height: 2800, background: `repeating-conic-gradient(from 0deg at 50% 50%, rgba(255,255,255,.9) 0deg 1.6deg, transparent 1.6deg ${f2(ctx.range(6, 10))}deg)`, WebkitMaskImage: "radial-gradient(circle, transparent 12%, #000 30%)", opacity: 0 }));
  ctx.js(`tl.fromTo("#${u}", { opacity: 1, scale: 0.6 }, { opacity: 0, scale: 1.2, duration: 0.5, ease: "power2.out", ...NF }, ${f2(t)}); SHAKE("#${ctx.S}-shake", ${f2(t)}, 0.35, 20);`);
  burst(ctx, "fx", p.x, p.y, 16, "#FFF8D0", t, [150, 420], 12, 0.5);
  ctx.sfx("impact-bass-2", t, 0.55); return { dur: 0.5 };
});
def("impact", "im-text", "Chữ tượng thanh BỐP / XOẸT", (ctx, p, t) => {
  const u = ctx.uid("im"), word = ctx.pick(["BỐP!", "XOẸT!", "RẦM!", "CHÁT!", "VÚT!", "BÙM!"]), col = ctx.pick(["#FFD23F", "#FF6B3D", "#6AD3FF", "#FF4FD8"]);
  // đặt trên đỉnh đầu cao nhất quanh điểm va chạm để không che mặt kẻ đánh lẫn nạn nhân (hộp 600×280, tâm ở giữa)
  const near = Object.keys(ctx.actors).map((id) => ctx.actor(id)).filter((x) => Math.abs(x.cx - p.x) < 520 && !ctx.actors[x.id].gone);
  const head = near.length ? Math.min(...near.map((x) => x.top)) : p.y - 200;
  const X = Math.max(320, Math.min(1600, p.x)), Y = Math.max(170, head - 150);
  ctx.add("fx", div(u, { left: X - 300, top: Y - 140, width: 600, height: 280, opacity: 0 }, `<svg viewBox="-150 -100 300 200" width="600" height="400" style="position:absolute;left:0;top:-60px;overflow:visible"><path d="${Array.from({ length: 16 }, (_, i) => { const r = i % 2 ? 70 : 130, a = (i / 16) * Math.PI * 2; return `${i ? "L" : "M"}${f2(Math.cos(a) * r * 1.3)} ${f2(Math.sin(a) * r * 0.8)}`; }).join(" ")} Z" fill="#fff" stroke="#111" stroke-width="6" stroke-linejoin="round"/></svg><div style="position:relative;top:70px;${titleCss(110, col)}">${word}</div>`));
  ctx.js(`tl.fromTo("#${u}", { scale: 0.2, opacity: 1, rotation: ${f2(ctx.range(-20, 20))} }, { scale: 0.85, rotation: ${f2(ctx.range(-8, 8))}, duration: 0.25, ease: "back.out(3)", ...NF }, ${f2(t)}); tl.to("#${u}", { opacity: 0, scale: 1.2, duration: 0.25 }, ${f2(t + 0.75)}); SHAKE("#${ctx.S}-shake", ${f2(t)}, 0.3, 18);`);
  ctx.sfx("impact-bass-1", t, 0.55); ctx.sfx("pop", t, 0.3); return { dur: 0.6 };
});
def("impact", "im-shards", "Mảnh vỡ văng tung", (ctx, p, t) => {
  const u = ctx.uid("im"), n = 14;
  ctx.add("fx", div(null, { left: p.x, top: p.y, width: 0, height: 0 }, Array.from({ length: n }, (_, i) => `<svg id="${u}-${i}" style="position:absolute;left:-20px;top:-20px;overflow:visible;opacity:0" width="40" height="40" viewBox="0 0 40 40"><path d="M0 0 L${f2(ctx.range(20, 40))} ${f2(ctx.range(0, 14))} L${f2(ctx.range(6, 26))} 40 Z" fill="${ctx.pick(["#fff", ctx.theme.light, ctx.theme.qi])}" stroke="#111" stroke-width="3"/></svg>`).join("")));
  ctx.js(Array.from({ length: n }, (_, i) => { const a = ctx.range(0, Math.PI * 2), r = ctx.range(200, 520); return `tl.fromTo("#${u}-${i}", { x: 0, y: 0, rotation: 0, opacity: 1 }, { x: ${f2(Math.cos(a) * r)}, y: ${f2(Math.sin(a) * r + 120)}, rotation: ${f2(ctx.range(-720, 720))}, opacity: 0, duration: 0.8, ease: "power2.out", ...NF }, ${f2(t)});`; }).join("\n") + `\nFLASH(${f2(t)}, 0.5, 0.2); SHAKE("#${ctx.S}-shake", ${f2(t)}, 0.4, 26);`);
  ctx.sfx("impact-bass-2", t, 0.6); ctx.sfx("glitch-1", t, 0.2, 0.5); return { dur: 0.6 };
});
def("impact", "im-ring", "Vòng sóng xung kích", (ctx, p, t) => {
  const u = ctx.uid("im"), c = ctx.theme.qi;
  ctx.add("fx", [0, 1, 2].map((i) => div(`${u}-${i}`, { left: p.x - 200, top: p.y - 200, width: 400, height: 400, borderRadius: "50%", border: `${16 - i * 4}px solid ${i ? "#fff" : c}`, opacity: 0 })).join(""));
  ctx.js(`[0,1,2].forEach(i => tl.fromTo("#${u}-" + i, { scale: 0.1, opacity: 1 }, { scale: 2.4 + i * 0.5, opacity: 0, duration: 0.6 + i * 0.1, ease: "power2.out", ...NF }, ${f2(t)} + i * 0.06)); FLASH(${f2(t)}, 0.4, 0.25, "${c}"); SHAKE("#${ctx.S}-shake", ${f2(t)}, 0.4, 24);`);
  ctx.sfx("impact-bass-2", t, 0.6); return { dur: 0.6 };
});

// ============================ ATTACK (beat: {who, target?, name?}) -> { dur, hit } ============================
const attackName = (ctx, b, t) => { if (b.name) ctx.sub("caption", { text: b.name, short: true }, t); };
const ghostTrail = (ctx, a, fromX, toX, t, n = 3) => {
  for (let k = 1; k <= n; k++) {
    const g = ctx.uid("gh"), x = fromX + ((toX - fromX) * k) / (n + 1);
    ctx.add("fx", div(g, { left: x, top: a.top, opacity: 0, filter: `brightness(.6) sepia(1) saturate(6) hue-rotate(${ctx.theme.hue}deg)` }, ctx.rig(a.type, g + "r", a.w, a.look, a.flip)));
    ctx.rigType(g + "r", a.type);
    ctx.js(`POSE("${g}r", "windup", 0, 0.01); tl.set("#${g}", { opacity: ${f2(0.65 - k * 0.12)} }, ${f2(t + k * 0.04)}); tl.to("#${g}", { opacity: 0, duration: 0.45 }, ${f2(t + k * 0.04 + 0.1)});`);
  }
};
def("attack", "at-dash", "Lao tới + bóng mờ + vệt chém cung", (ctx, b, t) => {
  const a = ctx.actor(b.who), T = defaultTarget(ctx, b), c = centroid(T), u = ctx.uid("at"), th = ctx.theme, s = c.x > a.cx ? 1 : -1;
  attackName(ctx, b, t);
  const dest = c.x - s * (a.w * 0.9) - a.w / 2, x0 = a.x;
  const y0 = c.y - ctx.range(260, 360), y1 = c.y + ctx.range(180, 260), x1 = c.x - s * 200, x2 = c.x + s * ctx.range(380, 560);
  ctx.add("fx", `<svg class="fill" viewBox="0 0 1920 1080" width="1920" height="1080" style="overflow:visible;position:absolute;left:0;top:0"><path id="${u}-a" pathLength="1" stroke-dasharray="1" stroke-dashoffset="1" d="M${f2(x1)} ${f2(y0)} Q${f2(x2)} ${f2(y0 + 60)} ${f2(x2 + s * 60)} ${f2(y1)}" fill="none" stroke="${th.qi}" stroke-width="80" stroke-linecap="round" opacity=".45"/><path id="${u}-b" pathLength="1" stroke-dasharray="1" stroke-dashoffset="1" d="M${f2(x1)} ${f2(y0)} Q${f2(x2)} ${f2(y0 + 60)} ${f2(x2 + s * 60)} ${f2(y1)}" fill="none" stroke="#fff" stroke-width="32" stroke-linecap="round"/></svg>`);
  ctx.js(`BROW("${a.p}", ${t}, true); POSE("${a.p}", "windup", ${t}, 0.5, "power2.out"); tl.to("#${a.body}", { scaleY: 0.9, scaleX: 1.04, transformOrigin: "50% 100%", duration: 0.45 }, ${t}); tl.to("#${a.body}", { scaleY: 1, scaleX: 1, duration: 0.1 }, ${t + 0.6});`);
  ghostTrail(ctx, a, x0, dest, t + 0.6);
  ctx.moveTo(b.who, dest, t + 0.6, 0.18, "power4.in");
  const hit = t + 0.8;
  ctx.js(`POSE("${a.p}", "slash", ${t + 0.78}, 0.14, "power4.out"); DRAW(["#${u}-a", "#${u}-b"], ${t + 0.78}, 0.14); tl.to(["#${u}-a", "#${u}-b"], { opacity: 0, duration: 0.4 }, ${t + 1.1});`);
  ctx.sub("impact", c, hit);
  ctx.sfx("whoosh-cinematic", t + 0.6, 0.5, 1.2);
  return { dur: 1.5, hit };
});
def("attack", "at-cross", "Hai nhát chém chữ X", (ctx, b, t) => {
  const a = ctx.actor(b.who), T = defaultTarget(ctx, b), c = centroid(T), u = ctx.uid("at"), th = ctx.theme, r = ctx.range(260, 380);
  attackName(ctx, b, t);
  const line = (id, x1, y1, x2, y2) => `<g id="${id}" stroke-dashoffset="1">${glowStroke("path", `d="M${f2(x1)} ${f2(y1)} L${f2(x2)} ${f2(y2)}" pathLength="1" stroke-dasharray="1" stroke-linecap="round"`, 26, "#fff", th.qi, 16)}</g>`;
  ctx.add("fx", `<svg class="fill" viewBox="0 0 1920 1080" width="1920" height="1080" style="overflow:visible;position:absolute;left:0;top:0">${line(u + "-1", c.x - r, c.y - r, c.x + r, c.y + r)}${line(u + "-2", c.x + r, c.y - r, c.x - r, c.y + r)}</svg>`);
  ctx.js(`BROW("${a.p}", ${t}, true); POSE("${a.p}", "windup", ${t}, 0.3); POSE("${a.p}", "slash", ${t + 0.4}, 0.12, "power4.out"); POSE("${a.p}", "windup", ${t + 0.6}, 0.12, "power4.out"); POSE("${a.p}", "slash", ${t + 0.75}, 0.12, "power4.out");
tl.to("#${a.body}", { x: ${s2(c.x > a.cx)}, duration: 0.1, yoyo: true, repeat: 3 }, ${t + 0.4});
DRAW("#${u}-1", ${t + 0.4}, 0.12, "power4.out"); DRAW("#${u}-2", ${t + 0.75}, 0.12, "power4.out"); tl.to(["#${u}-1", "#${u}-2"], { opacity: 0, duration: 0.35 }, ${t + 1.1}); POSE("${a.p}", "raise", ${t + 1.1}, 0.35);`);
  ctx.sfx("whoosh", t + 0.38, 0.45); ctx.sfx("whoosh", t + 0.72, 0.45);
  const hit = t + 0.87; ctx.sub("impact", c, hit);
  return { dur: 1.5, hit };
});
const s2 = (right) => (right ? 30 : -30);
def("attack", "at-whirl", "Xoáy kiếm lốc xoáy xuyên qua", (ctx, b, t) => {
  const a = ctx.actor(b.who), T = defaultTarget(ctx, b), c = centroid(T), u = ctx.uid("at"), th = ctx.theme, s = c.x > a.cx ? 1 : -1;
  attackName(ctx, b, t);
  const dest = Math.max(40, Math.min(1880 - a.w, c.x + s * a.w * 0.2 - a.w / 2));
  ctx.add("fx", div(u, { left: a.cx - a.w, top: a.cy - a.w, width: a.w * 2, height: a.w * 2, opacity: 0 }, `<svg viewBox="-100 -100 200 200" width="${f2(a.w * 2)}" height="${f2(a.w * 2)}" style="overflow:visible">${[0, 1, 2].map((k) => `<path d="M${f2(80 - k * 18)} 0 A${f2(80 - k * 18)} ${f2(80 - k * 18)} 0 1 1 ${f2(-(80 - k * 18) * 0.7)} ${f2(-(80 - k * 18) * 0.7)}" fill="none" stroke="${k ? "#fff" : th.qi}" stroke-width="${12 - k * 3}" stroke-linecap="round" opacity=".9"/>`).join("")}</svg>`));
  ctx.js(`BROW("${a.p}", ${t}, true); POSE("${a.p}", "guard", ${t}, 0.2);
tl.set("#${u}", { opacity: 1 }, ${t + 0.25}); tl.to("#${u}", { rotation: ${s * 1440}, duration: 1.0, ease: "none" }, ${t + 0.25}); tl.to("#${u}", { x: ${f2(dest - a.x)}, duration: 0.6, ease: "power2.inOut" }, ${t + 0.35}); tl.to("#${u}", { opacity: 0, duration: 0.25 }, ${t + 1.15});
tl.to("#${a.body}", { rotation: ${s * 1080}, transformOrigin: "50% 55%", duration: 1.0, ease: "power1.inOut" }, ${t + 0.25}); tl.set("#${a.body}", { rotation: 0 }, ${t + 1.25});`);
  ctx.moveTo(b.who, dest, t + 0.35, 0.6, "power2.inOut");
  ctx.sfx("whoosh-cinematic", t + 0.25, 0.45, 1.2);
  const hit = t + 0.7; ctx.sub("impact", c, hit);
  return { dur: 1.5, hit };
});
def("attack", "at-rain", "Mưa kiếm khí từ trời", (ctx, b, t) => {
  const a = ctx.actor(b.who), T = defaultTarget(ctx, b), c = centroid(T), u = ctx.uid("at"), th = ctx.theme, n = 14;
  attackName(ctx, b, t);
  const spread = Math.max(300, Math.abs(T[T.length - 1].cx - T[0].cx) + 300);
  ctx.add("fx", Array.from({ length: n }, (_, i) => div(`${u}-${i}`, { left: c.x - spread / 2 + ctx.range(0, spread), top: -400, width: 30, height: 300, transform: `rotate(${f2(ctx.range(-12, 12))}deg)` }, `<svg viewBox="0 0 30 300" width="30" height="300" style="overflow:visible"><path d="M15 300 L4 40 L15 0 L26 40 Z" fill="none" stroke="${th.qi}" stroke-width="22" stroke-linejoin="round" opacity=".3"/><path d="M15 300 L4 40 L15 0 L26 40 Z" fill="${th.light}" stroke="#fff" stroke-width="4"/></svg>`)).join(""));
  ctx.js(`POSE("${a.p}", "up", ${t}, 0.3); BROW("${a.p}", ${t}, true); tl.to("#${ctx.S}-bg", { filter: "brightness(0.6)", duration: 0.3 }, ${t}); tl.to("#${ctx.S}-bg", { filter: "brightness(1)", duration: 0.4 }, ${t + 1.6});
for (let i = 0; i < ${n}; i++) { tl.to("#${u}-" + i, { y: ${f2(c.y + 160)} + rand() * 120, duration: 0.3, ease: "power3.in" }, ${t + 0.4} + i * 0.05); tl.to("#${u}-" + i, { opacity: 0, duration: 0.3 }, ${t + 1.3} + i * 0.02); }
SHAKE("#${ctx.S}-shake", ${t + 0.7}, 0.8, 14); POSE("${a.p}", "rest", ${t + 1.5}, 0.3);`);
  ctx.sfx("riser", t, 0.3, 0.6); ctx.sfx("whoosh", t + 0.4, 0.4); ctx.sfx("whoosh", t + 0.7, 0.4);
  const hit = t + 0.75; ctx.sub("impact", c, hit);
  return { dur: 1.7, hit };
});
def("attack", "at-palm", "Chưởng phong sóng lưỡi liềm", (ctx, b, t) => {
  const a = ctx.actor(b.who), T = defaultTarget(ctx, b), c = centroid(T), u = ctx.uid("at"), th = ctx.theme, s = c.x > a.cx ? 1 : -1, n = 3;
  attackName(ctx, b, t);
  const x0 = a.cx + s * a.w * 0.4, dist = c.x - x0;
  ctx.add("fx", Array.from({ length: n }, (_, i) => div(`${u}-${i}`, { left: x0 - 80, top: a.cy - 160, width: 160, height: 320, opacity: 0 }, `<svg viewBox="0 0 160 320" width="160" height="320" style="overflow:visible;transform:scaleX(${s})"><path d="M40 0 Q170 160 40 320 Q110 160 40 0 Z" fill="none" stroke="${th.qi}" stroke-width="30" stroke-linejoin="round" opacity=".3"/><path d="M40 0 Q170 160 40 320 Q110 160 40 0 Z" fill="${i % 2 ? "#fff" : th.qi}" stroke="${th.light}" stroke-width="5"/></svg>`)).join(""));
  ctx.js(`BROW("${a.p}", ${t}, true); POSE("${a.p}", "guard", ${t}, 0.25); POSE("${a.p}", "palm", ${t + 0.35}, 0.12, "power4.out"); tl.to("#${a.body}", { x: ${-s * 20}, duration: 0.1, yoyo: true, repeat: 1 }, ${t + 0.35});
for (let i = 0; i < ${n}; i++) { tl.fromTo("#${u}-" + i, { x: 0, opacity: 1, scale: 0.4 }, { x: ${f2(dist)}, scale: 1.3, duration: 0.35, ease: "power2.in", ...NF }, ${t + 0.4} + i * 0.12); tl.to("#${u}-" + i, { opacity: 0, scale: 1.8, duration: 0.2 }, ${t + 0.75} + i * 0.12); }
POSE("${a.p}", "rest", ${t + 1.3}, 0.3);`);
  ctx.sfx("whoosh", t + 0.4, 0.45); ctx.sfx("whoosh-short", t + 0.52, 0.35);
  const hit = t + 0.75; ctx.sub("impact", c, hit);
  return { dur: 1.5, hit };
});
def("attack", "at-leap", "Bay lên bổ xuống cột sáng", (ctx, b, t) => {
  const a = ctx.actor(b.who), T = defaultTarget(ctx, b), c = centroid(T), u = ctx.uid("at"), th = ctx.theme;
  attackName(ctx, b, t);
  const dest = Math.max(40, Math.min(1880 - a.w, c.x - a.w / 2 - (c.x > a.cx ? a.w * 0.6 : -a.w * 0.6)));
  ctx.add("fx", div(u, { left: c.x - 70, top: -40, width: 140, height: a.foot + 80, background: `linear-gradient(90deg, transparent, ${th.qi}, #fff, ${th.qi}, transparent)`, transform: "scaleY(0)", transformOrigin: "50% 0%", opacity: 0.95 }));
  ctx.js(`POSE("${a.p}", "up", ${t}, 0.2); tl.to("#${a.body}", { scaleY: 0.85, transformOrigin: "50% 100%", duration: 0.2 }, ${t}); tl.to("#${a.body}", { scaleY: 1, duration: 0.1 }, ${t + 0.25});
tl.to("#${a.wrap}", { y: -700, duration: 0.35, ease: "power2.out" }, ${t + 0.25}); tl.to("#${a.wrap}", { y: 0, duration: 0.2, ease: "power4.in" }, ${t + 0.75});
POSE("${a.p}", "slash", ${t + 0.78}, 0.12, "power4.out"); tl.to("#${u}", { scaleY: 1, duration: 0.12, ease: "power4.out" }, ${t + 0.82}); tl.to("#${u}", { scaleX: 3, opacity: 0, duration: 0.45 }, ${t + 0.95});`);
  ctx.moveTo(b.who, dest, t + 0.4, 0.4, "sine.inOut");
  dust(ctx, c.x, a.foot - 20, t + 0.95, 8);
  ctx.sfx("whoosh", t + 0.25, 0.4); ctx.sfx("whoosh-cinematic", t + 0.7, 0.45, 1);
  const hit = t + 0.95; ctx.sub("impact", c, hit);
  return { dur: 1.7, hit };
});
def("attack", "at-flurry", "Trăm nhát kiếm liên hoàn", (ctx, b, t) => {
  const a = ctx.actor(b.who), T = defaultTarget(ctx, b), c = centroid(T), u = ctx.uid("at"), th = ctx.theme, n = 12;
  attackName(ctx, b, t);
  const dest = Math.max(40, Math.min(1880 - a.w, c.x - a.w / 2 - (c.x > a.cx ? a.w * 0.8 : -a.w * 0.8)));
  ctx.moveTo(b.who, dest, t, 0.2, "power3.in");
  ctx.add("fx", `<svg class="fill" viewBox="0 0 1920 1080" width="1920" height="1080" style="overflow:visible;position:absolute;left:0;top:0">${Array.from({ length: n }, (_, i) => { const ang = ctx.range(0, Math.PI), r = ctx.range(120, 220), cx = c.x + ctx.range(-90, 90), cy = c.y + ctx.range(-140, 140); return `<path id="${u}-${i}" pathLength="1" stroke-dasharray="1" stroke-dashoffset="1" d="M${f2(cx - Math.cos(ang) * r)} ${f2(cy - Math.sin(ang) * r)} L${f2(cx + Math.cos(ang) * r)} ${f2(cy + Math.sin(ang) * r)}" stroke="${i % 3 ? "#fff" : th.qi}" stroke-width="${f2(ctx.range(8, 18))}" stroke-linecap="round" fill="none"/>`; }).join("")}</svg>`);
  ctx.js(`BROW("${a.p}", ${t}, true); for (let i = 0; i < ${n}; i++) { DRAW("#${u}-" + i, ${t + 0.25} + i * 0.06, 0.05, "none"); tl.to("#${u}-" + i, { opacity: 0, duration: 0.15 }, ${t + 0.35} + i * 0.06); POSE("${a.p}", i % 2 ? "slash" : "windup", ${t + 0.25} + i * 0.06, 0.05, "none"); }
POSE("${a.p}", "raise", ${f2(t + 0.3 + n * 0.06)}, 0.3); tl.to("#${ctx.S}-shake", { x: 6, duration: 0.03, yoyo: true, repeat: ${n * 2} }, ${t + 0.25});`);
  for (let k = 0; k < 4; k++) ctx.sfx("whoosh-short", t + 0.25 + k * 0.18, 0.3);
  const hit = t + 0.3 + n * 0.06; ctx.sub("impact", c, hit);
  return { dur: hit - t + 0.5, hit };
});
def("attack", "at-beam", "Luồng khí thẳng như tia", (ctx, b, t) => {
  const a = ctx.actor(b.who), T = defaultTarget(ctx, b), c = centroid(T), u = ctx.uid("at"), th = ctx.theme, s = c.x > a.cx ? 1 : -1;
  attackName(ctx, b, t);
  const x0 = a.cx + s * a.w * 0.45, len = Math.abs(1940 - x0) * (s > 0 ? 1 : 0) + (s < 0 ? x0 + 20 : 0), y = a.top + a.h * 0.38;
  ctx.add("fx", div(u, { left: s > 0 ? x0 : x0 - len, top: y - 70, width: len, height: 140, borderRadius: 70, background: `linear-gradient(${th.qi}, #fff 40%, #fff 60%, ${th.qi})`, boxShadow: `0 0 50px ${th.qi}`, transform: "scaleX(0)", transformOrigin: s > 0 ? "0% 50%" : "100% 50%" }) + div(u + "-o", { left: x0 - 110, top: y - 110, width: 220, height: 220, borderRadius: "50%", background: `radial-gradient(circle,#fff,${th.qi}aa 50%,transparent 70%)`, opacity: 0 }));
  ctx.js(`POSE("${a.p}", "guard", ${t}, 0.25); BROW("${a.p}", ${t}, true); tl.fromTo("#${u}-o", { opacity: 0, scale: 0.2 }, { opacity: 1, scale: 1, duration: 0.45, ...NF }, ${t}); POSE("${a.p}", "palm", ${t + 0.45}, 0.1, "power4.out");
tl.to("#${u}", { scaleX: 1, duration: 0.18, ease: "power3.out" }, ${t + 0.5}); tl.to("#${u}", { scaleY: 1.25, duration: 0.06, yoyo: true, repeat: 7 }, ${t + 0.68}); tl.to(["#${u}", "#${u}-o"], { scaleY: 0, opacity: 0, duration: 0.25 }, ${t + 1.2});
SHAKE("#${ctx.S}-shake", ${t + 0.55}, 0.7, 14); POSE("${a.p}", "rest", ${t + 1.35}, 0.3);`);
  ctx.sfx("riser", t, 0.3, 0.5); ctx.sfx("whoosh-cinematic", t + 0.5, 0.5, 1.1);
  const hit = t + 0.62; ctx.sub("impact", c, hit);
  return { dur: 1.6, hit };
});

// ============================ REACT (beat: {who: id | [ids]}) ============================
const victims = (ctx, b) => [].concat(b.who).map((id) => ctx.actor(id));
// khoảng còn lại tới mép khung theo hướng s (giữ nhân vật trong khung khi bị đẩy lùi)
const room = (a, s) => Math.max(0, s > 0 ? 1920 - 40 - a.w / 2 - a.cx : a.cx - a.w / 2 - 40);
const koStars = (ctx, a, t, dur = 1.6) => {
  const u = ctx.uid("ko"), y = a.koHead.y - 70;
  ctx.add("fx", div(u, { left: a.koHead.x, top: y, width: 0, height: 0, opacity: 0 }, div(null, { left: -80, top: -80, width: 160, height: 160, transform: "scaleY(.4)" }, div(u + "-r", { left: 0, top: 0, width: 160, height: 160 }, [0, 1, 2].map((j) => div(null, { left: 60 + 60 * Math.cos(j * 2.094), top: 60 + 60 * Math.sin(j * 2.094) }, star5("#FFD23F"))).join("")))));
  ctx.js(`tl.to("#${u}", { opacity: 1, duration: 0.2 }, ${f2(t)}); tl.to("#${u}-r", { rotation: ${360 * Math.ceil(dur)}, duration: ${f2(dur)}, ease: "none" }, ${f2(t)}); tl.to("#${u}", { opacity: 0, duration: 0.3 }, ${f2(t + dur)});`);
};
def("react", "af-ko", "Ngã lăn ra + sao xoay", (ctx, b, t) => {
  victims(ctx, b).forEach((a, k) => {
    const s = ctx.attackerSide(a), tt = t + k * 0.05;
    ctx.js(`KO("${a.p}", ${f2(tt)}); tl.to("#${a.wrap}", { x: "+=${s * 80}", duration: 0.3, ease: "power2.out" }, ${f2(tt)}); tl.to("#${a.body}", { rotation: ${s * 90}, y: ${f2(-a.w * 0.18)}, transformOrigin: "50% 100%", duration: 0.5, ease: "bounce.out" }, ${f2(tt)});`);
    ctx.knock(a.id, s * 80, s);
    koStars(ctx, ctx.actor(a.id), tt + 0.6);
  });
  ctx.sfx("impact-bass-1", t + 0.3, 0.35);
  return { dur: 2.3 };
}, { down: true });
def("react", "af-fly", "Văng bay khỏi khung", (ctx, b, t) => {
  victims(ctx, b).forEach((a, k) => {
    const s = ctx.attackerSide(a);
    ctx.js(`KO("${a.p}", ${f2(t)}); tl.to("#${a.wrap}", { x: "+=${f2(s * ctx.range(900, 1400))}", y: ${f2(-ctx.range(500, 900))}, duration: 0.85, ease: "power2.out" }, ${f2(t + k * 0.04)}); tl.to("#${a.body}", { rotation: ${f2(s * ctx.range(480, 900))}, transformOrigin: "50% 50%", duration: 0.85 }, ${f2(t + k * 0.04)});`);
    ctx.gone(a.id);
  });
  const u = ctx.uid("tw");
  ctx.add("hud", div(u, { left: ctx.range(1500, 1760), top: 90, width: 0, height: 0, opacity: 0 }, star4("#fff", "#E3A21A")));
  ctx.js(`tl.fromTo("#${u}", { opacity: 1, scale: 0 }, { scale: 0.7, rotation: 90, duration: 0.25, ease: "back.out(3)", ...NF }, ${f2(t + 0.9)}); tl.to("#${u}", { opacity: 0, duration: 0.2 }, ${f2(t + 1.2)});`);
  ctx.sfx("whoosh", t, 0.4); ctx.sfx("sparkle", t + 0.9, 0.3);
  return { dur: 1.4 };
}, { removes: true, down: true });
def("react", "af-domino", "Đổ dây như domino", (ctx, b, t) => {
  const vs = victims(ctx, b), s0 = ctx.attackerSide(vs[0]), s = vs.some((a) => ctx.attackerSide(a) !== s0) ? -s0 : s0; // cả dãy ngã cùng hướng, không ra ngoài khung
  vs.sort((p, q) => s * (p.cx - q.cx)).forEach((a, k) => {
    const tt = t + k * 0.18;
    ctx.js(`KO("${a.p}", ${f2(tt)}); tl.to("#${a.body}", { rotation: ${s * 84}, y: ${f2(-a.w * 0.18)}, transformOrigin: "50% 100%", duration: 0.35, ease: "power2.in" }, ${f2(tt)}); tl.to("#${a.body}", { rotation: ${s * 90}, duration: 0.2, ease: "bounce.out" }, ${f2(tt + 0.35)});`);
    ctx.knock(a.id, 0, s);
    ctx.sfx("pop", tt + 0.3, 0.25);
  });
  vs.forEach((a) => koStars(ctx, ctx.actor(a.id), t + vs.length * 0.18 + 0.4, 1.2));
  return { dur: vs.length * 0.18 + 1.8 };
}, { down: true });
def("react", "af-spin", "Xoay mòng mòng rồi gục", (ctx, b, t) => {
  victims(ctx, b).forEach((a, k) => {
    const tt = t + k * 0.06, s = ctx.attackerSide(a);
    ctx.js(`KO("${a.p}", ${f2(tt)}); tl.to("#${a.body}", { rotation: ${s * 20}, transformOrigin: "50% 100%", duration: 0.2, yoyo: true, repeat: 5, ease: "sine.inOut" }, ${f2(tt)}); tl.to("#${a.wrap}", { y: -30, duration: 0.2, yoyo: true, repeat: 5 }, ${f2(tt)}); tl.to("#${a.body}", { rotation: ${s * 90}, y: ${f2(-a.w * 0.18)}, duration: 0.4, ease: "bounce.out" }, ${f2(tt + 1.25)});`);
    ctx.knock(a.id, 0, s);
    koStars(ctx, a, tt, 1.2);
  });
  ctx.sfx("glitch-1", t, 0.2, 1.2); ctx.sfx("impact-bass-1", t + 1.4, 0.3);
  return { dur: 2.0 };
}, { down: true });
def("react", "af-flat", "Bẹp dí như bánh tráng", (ctx, b, t) => {
  victims(ctx, b).forEach((a) => {
    ctx.js(`KO("${a.p}", ${f2(t)}); tl.to("#${a.body}", { scaleY: 0.12, scaleX: 1.5, transformOrigin: "50% 100%", duration: 0.12, ease: "power4.in" }, ${f2(t)}); tl.to("#${a.body}", { scaleX: 1.6, duration: 0.2, yoyo: true, repeat: 3 }, ${f2(t + 0.15)}); tl.to("#${a.body}", { scaleY: 1, scaleX: 1, duration: 0.4, ease: "elastic.out(1,0.4)" }, ${f2(t + 1.3)}); KO("${a.p}", ${f2(t + 1.3)}, false); BLINK("${a.p}", ${f2(t + 1.8)});`);
    const u = ctx.uid("fl");
    ctx.add("fx", div(u, { left: a.cx - 20, top: a.foot - 120, width: 0, height: 0, opacity: 0 }, `<div style="${titleCss(60, "#fff")};white-space:nowrap">bẹp!</div>`));
    ctx.js(`POP("#${u}", ${f2(t + 0.15)}); HIDE("#${u}", ${f2(t + 1.1)});`);
  });
  ctx.sfx("impact-bass-1", t, 0.45); ctx.sfx("pop", t + 1.3, 0.35);
  return { dur: 2.0 };
}, { down: true });
def("react", "af-blow", "Bị thổi trượt dài, tóe bụi", (ctx, b, t) => {
  victims(ctx, b).forEach((a, k) => {
    const s = ctx.attackerSide(a), d = Math.min(ctx.range(260, 420), room(a, s));
    ctx.js(`tl.to("#${a.wrap}", { x: "+=${f2(s * d)}", duration: 0.6, ease: "power3.out" }, ${f2(t + k * 0.04)}); tl.to("#${a.body}", { rotation: ${s * -14}, transformOrigin: "50% 100%", duration: 0.15 }, ${f2(t)}); tl.to("#${a.body}", { rotation: 0, duration: 0.4, ease: "back.out(3)" }, ${f2(t + 0.6)}); BLINK("${a.p}", ${f2(t + 0.7)}); BLINK("${a.p}", ${f2(t + 0.95)});`);
    dust(ctx, a.cx + s * d * 0.5, a.foot - 20, t + 0.1, 6);
    ctx.knock(a.id, s * d, 0);
  });
  ctx.sfx("whoosh", t, 0.4);
  return { dur: 1.4 };
});

// Chỉ choáng/lùi, đứng vững lại — dùng được cho tập chủ đề (luật tôn trọng: nhân vật kinh điển không bị hạ gục).
const headStars = (ctx, a, t, dur = 1.4) => {
  const u = ctx.uid("hs");
  ctx.add("fx", div(u, { left: a.cx, top: a.top + 6, width: 0, height: 0, opacity: 0 }, div(null, { left: -90, top: -60, width: 180, height: 120, transform: "scaleY(.35)" }, div(u + "-r", { left: 0, top: 0, width: 180, height: 180 }, [0, 1, 2].map((j) => div(null, { left: 70 + 70 * Math.cos(j * 2.094), top: 70 + 70 * Math.sin(j * 2.094) }, star5("#FFD23F"))).join("")))));
  ctx.js(`tl.to("#${u}", { opacity: 1, duration: 0.2 }, ${f2(t)}); tl.to("#${u}-r", { rotation: ${360 * Math.ceil(dur)}, duration: ${f2(dur)}, ease: "none" }, ${f2(t)}); tl.to("#${u}", { opacity: 0, duration: 0.3 }, ${f2(t + dur)});`);
};
def("react", "af-stagger", "Lùi loạng choạng ba bước rồi đứng vững", (ctx, b, t) => {
  victims(ctx, b).forEach((a, k) => {
    const s = ctx.attackerSide(a), tt = t + k * 0.05, d = Math.min(ctx.range(150, 230), room(a, s));
    ctx.js(`for (let i = 0; i < 3; i++) { tl.to("#${a.wrap}", { x: "+=${f2((s * d) / 3)}", duration: 0.22, ease: "power2.out" }, ${f2(tt)} + i * 0.24); tl.to("#${a.body}", { rotation: ${s * -10} * (i % 2 ? -1 : 1), transformOrigin: "50% 100%", duration: 0.22 }, ${f2(tt)} + i * 0.24); }
tl.to("#${a.body}", { rotation: 0, duration: 0.35, ease: "back.out(3)" }, ${f2(tt + 0.75)}); POSE("${a.p}", "guard", ${f2(tt + 0.8)}, 0.3); BLINK("${a.p}", ${f2(tt + 1.1)});`);
    ctx.knock(a.id, s * d, 0);
    dust(ctx, a.cx + s * d * 0.6, a.foot - 20, tt + 0.5, 4);
  });
  ctx.sfx("whoosh-short", t, 0.35); ctx.sfx("pop", t + 0.75, 0.25);
  return { dur: 1.5 };
});
def("react", "af-dizzy", "Choáng tại chỗ, sao xoay quanh đầu", (ctx, b, t) => {
  victims(ctx, b).forEach((a, k) => {
    const s = ctx.attackerSide(a), tt = t + k * 0.06;
    ctx.js(`tl.to("#${a.wrap}", { x: "+=${f2(s * Math.min(50, room(a, s)))}", duration: 0.18, ease: "power2.out" }, ${f2(tt)}); tl.to("#${a.body}", { rotation: ${s * 8}, transformOrigin: "50% 100%", duration: 0.25, yoyo: true, repeat: 4, ease: "sine.inOut" }, ${f2(tt + 0.1)}); tl.to("#${a.body}", { rotation: 0, duration: 0.3 }, ${f2(tt + 1.4)}); BLINK("${a.p}", ${f2(tt + 0.5)}); BLINK("${a.p}", ${f2(tt + 1.0)});`);
    ctx.knock(a.id, s * Math.min(50, room(a, s)), 0);
    headStars(ctx, ctx.actor(a.id), tt + 0.15, 1.3);
  });
  ctx.sfx("impact-bass-2", t, 0.3); ctx.sfx("sparkle", t + 0.3, 0.25);
  return { dur: 1.8 };
});

// ============================ CAPTION (beat: {text}) ============================
def("caption", "cp-stamp", "Biển hiệu đóng dấu", (ctx, b, t) => {
  const u = ctx.uid("cp"), hold = b.short ? 1.2 : 2.0;
  ctx.add("hud", div(u, { left: 0, top: b.y || 70, width: 1920, textAlign: "center", opacity: 0 }, `<span class="plq">${esc(b.text)}</span>`));
  ctx.js(`STAMP("#${u}", ${f2(t)}, ${f2(ctx.range(-5, 3))}); HIDE("#${u}", ${f2(t + hold)});`);
  ctx.sfx("impact-bass-1", t + 0.22, 0.4);
  return { dur: hold + 0.2 };
});
def("caption", "cp-brush", "Chữ hiện trên vệt cọ", (ctx, b, t) => {
  const u = ctx.uid("cp"), hold = b.short ? 1.3 : 2.2, col = ctx.pick(["#8A2A1E", "#141014", ctx.theme.dark]);
  ctx.add("hud", div(u, { left: 260, top: b.y || 70, width: 0, height: 150, overflow: "hidden" }, `<div id="${u}-in" style="position:absolute;left:0;top:0;width:1400px;height:150px"><svg viewBox="0 0 1400 150" width="1400" height="150" style="position:absolute;left:0;top:0"><path d="M20 80 C 300 30, 1100 130, 1380 60 L1370 110 C 1100 150, 300 90, 30 130 Z" fill="${col}" stroke="#F6EFE0" stroke-width="6" stroke-linejoin="round"/></svg><div style="position:relative;line-height:150px;text-align:center;font:700 66px 'Space Grotesk';color:#F6EFE0">${esc(b.text)}</div></div>`));
  ctx.js(`tl.to("#${u}", { width: 1400, duration: 0.5, ease: "power2.out" }, ${f2(t)}); tl.to("#${u}", { left: 1660, width: 0, duration: 0.35, ease: "power2.in" }, ${f2(t + hold)}); tl.to("#${u}-in", { left: -1400, duration: 0.35, ease: "power2.in" }, ${f2(t + hold)});`);
  ctx.sfx("whoosh-short", t, 0.4);
  return { dur: hold + 0.3 };
});
def("caption", "cp-burst", "Chữ trên nền nổ truyện tranh", (ctx, b, t) => {
  const u = ctx.uid("cp"), hold = b.short ? 1.2 : 1.9, col = ctx.pick(["#FFD23F", "#FF6B3D", ctx.theme.qi]);
  const pts = Array.from({ length: 22 }, (_, i) => { const r = i % 2 ? 0.78 : 1, a = (i / 22) * Math.PI * 2; return `${f2(500 + Math.cos(a) * 480 * r)},${f2(110 + Math.sin(a) * 105 * r)}`; }).join(" ");
  ctx.add("hud", div(u, { left: 460, top: b.y || 50, width: 1000, height: 220, opacity: 0 }, `<svg viewBox="0 0 1000 220" width="1000" height="220" style="position:absolute;left:0;top:0;overflow:visible"><polygon points="${pts}" fill="${col}" stroke="#111" stroke-width="7" stroke-linejoin="round"/></svg><div style="position:relative;line-height:220px;${titleCss(70, "#fff")}">${esc(b.text)}</div>`));
  ctx.js(`POP("#${u}", ${f2(t)}, { rotation: ${f2(ctx.range(-4, 4))} }); tl.to("#${u}", { scale: 1.05, duration: 0.15, yoyo: true, repeat: 3 }, ${f2(t + 0.45)}); HIDE("#${u}", ${f2(t + hold)});`);
  ctx.sfx("pop", t, 0.4);
  return { dur: hold + 0.2 };
});
def("caption", "cp-vertical", "Câu chữ dọc rơi xuống", (ctx, b, t) => {
  const u = ctx.uid("cp"), hold = b.short ? 1.4 : 2.3, x = ctx.pick([90, 1720]);
  const chars = b.text.split(" ").map((w) => `<div style="white-space:nowrap">${esc(w)}</div>`).join("");
  ctx.add("hud", div(u, { left: x, top: 90, width: 110, background: "rgba(20,16,20,.88)", border: "5px solid #E3A21A", borderRadius: 12, padding: "18px 0", textAlign: "center", font: "700 34px/1.25 'Space Grotesk'", color: "#F6EFE0", opacity: 0, writingMode: "horizontal-tb" }, chars));
  ctx.js(`tl.fromTo("#${u}", { y: -200, opacity: 0 }, { y: 0, opacity: 1, duration: 0.45, ease: "back.out(1.6)", ...NF }, ${f2(t)}); tl.to("#${u}", { y: -120, opacity: 0, duration: 0.35 }, ${f2(t + hold)});`);
  ctx.sfx("whoosh-short", t, 0.35);
  return { dur: hold + 0.3 };
});
def("caption", "cp-type", "Gõ từng chữ", (ctx, b, t) => {
  const u = ctx.uid("cp"), chars = [...b.text], step = Math.min(0.06, 1 / chars.length), hold = (b.short ? 0.8 : 1.4) + chars.length * step;
  ctx.add("hud", div(u, { left: 0, top: b.y || 80, width: 1920, textAlign: "center", opacity: 0 }, `<span style="display:inline-block;background:rgba(255,250,240,.95);border:5px solid #111;border-radius:14px;padding:14px 30px 8px;font:700 58px 'Space Grotesk';color:#111;box-shadow:8px 8px 0 rgba(0,0,0,.35)">${chars.map((ch, i) => `<span id="${u}-${i}" style="opacity:0">${ch === " " ? "&nbsp;" : esc(ch)}</span>`).join("")}</span>`));
  ctx.js(`tl.set("#${u}", { opacity: 1 }, ${f2(t)}); for (let i = 0; i < ${chars.length}; i++) tl.set("#${u}-" + i, { opacity: 1 }, ${f2(t)} + i * ${f2(step)}); HIDE("#${u}", ${f2(t + hold)});`);
  ctx.sfx("click", t, 0.3);
  return { dur: hold + 0.2 };
});
def("caption", "cp-ribbon", "Dải lụa bay vào", (ctx, b, t) => {
  const u = ctx.uid("cp"), hold = b.short ? 1.2 : 2.0, col = ctx.pick(["#C8372D", "#1D3B6E", "#3E8E5A"]), s = ctx.pick([1, -1]);
  ctx.add("hud", div(u, { left: 360, top: b.y || 70, width: 1200, height: 120, opacity: 0 }, `<svg viewBox="0 0 1200 120" width="1200" height="120" style="position:absolute;left:0;top:0;overflow:visible"><path d="M0 20 L60 60 L0 100 L120 100 L120 20 Z M1200 20 L1140 60 L1200 100 L1080 100 L1080 20 Z" fill="${col}" stroke="#111" stroke-width="5" opacity=".75"/><path d="M90 0 Q600 30 1110 0 L1110 104 Q600 134 90 104 Z" fill="${col}" stroke="#111" stroke-width="6"/></svg><div style="position:relative;line-height:110px;text-align:center;font:700 58px 'Space Grotesk';color:#fff">${esc(b.text)}</div>`));
  ctx.js(`tl.fromTo("#${u}", { x: ${s * 1400}, opacity: 1, skewX: ${s * -20} }, { x: 0, skewX: 0, duration: 0.5, ease: "back.out(1.4)", ...NF }, ${f2(t)}); tl.to("#${u}", { x: ${-s * 2000}, opacity: 0, duration: 0.4, ease: "power2.in" }, ${f2(t + hold)});`);
  ctx.sfx("whoosh", t, 0.35);
  return { dur: hold + 0.2 };
});

// ============================ CARD (beat: {title, sub?, lines[], side?: left|right|center}) ============================
// Thẻ thông tin (tác giả, tác phẩm, nhân vật). Nằm ở dải trên khung (đầu nhân vật ≈ y 540+) nên không che mặt.
// Thẻ luôn được Tèo đọc (build truyền b.voDur = độ dài giọng): thẻ ở lại tới hết câu, các dòng hiện dần theo nhịp đọc.
// Chưa có giọng → thời lượng theo số chữ, đủ để đọc.
const cardText = (b) => [b.title, b.sub, ...(b.lines || [])].filter(Boolean).join(" ");
const readHold = (s, min = 2.6) => Math.min(10, Math.max(min, 1.4 + [...s].length * 0.055));
const cardHold = (b) => (b.voDur ? Math.max(readHold(cardText(b)), b.voDur + 0.5) : readHold(cardText(b)));
const lineGap = (b) => (b.voDur && b.lines?.length ? Math.min(2.5, Math.max(0.35, (b.voDur - 1) / (b.lines.length + 1))) : 0.35);
function cardBox(ctx, b, w) {
  const lines = b.lines || [];
  if (lines.length > 4) console.warn(`fx card: ${ctx.curKey} có ${lines.length} dòng (nên ≤4)`);
  const per = Math.floor((w - 90) / 21); // ≈ ký tự mỗi dòng ở cỡ 38px
  const h = 54 + 78 + (b.sub ? 50 : 0) + lines.reduce((s, l) => s + Math.ceil([...l].length / per) * 50, 0) + 20;
  const x = b.side === "left" ? 60 : b.side === "right" ? 1860 - w : (1920 - w) / 2;
  if (40 + h > 530) console.warn(`fx card: ${ctx.curKey} cao ${h}px, có thể che đầu nhân vật — bớt chữ`);
  return { x, y: 40, w, h };
}
const cardInner = (b, color, sub) => `<div style="${titleCss(60, color)};text-align:left;-webkit-text-stroke:0;text-shadow:none;color:${color}">${esc(b.title)}</div>${b.sub ? `<div style="font:600 36px 'Space Grotesk';color:${sub};margin-top:6px">${esc(b.sub)}</div>` : ""}`;
const cardLines = (b, u, color) => (b.lines || []).map((l, i) => `<div id="${u}-l${i}" style="font:500 38px/1.3 'Space Grotesk';color:${color};margin-top:10px;opacity:0">• ${esc(l)}</div>`).join("");
const revealLines = (u, b, t0, gap = lineGap(b)) => (b.lines || []).map((_, i) => `SHOW("#${u}-l${i}", ${f2(t0 + i * gap)}, 0.3, { x: -30 });`).join(" ");

def("card", "cd-scroll", "Cuộn giấy dó mở ngang", (ctx, b, t) => {
  const u = ctx.uid("cd"), { x, y, w, h } = cardBox(ctx, b, b.side && b.side !== "center" ? 820 : 1100), hold = cardHold(b);
  ctx.add("hud", div(u, { left: x, top: y, width: w, height: h }, `<div id="${u}-p" style="position:absolute;left:0;top:0;width:${w}px;height:${h}px;background:#F3E6C8;border:6px solid #3B2A1A;box-shadow:10px 10px 0 rgba(0,0,0,.35);padding:28px 48px;transform:scaleX(0)">${cardInner(b, "#8A2A1E", "#3B2A1A")}${cardLines(b, u, "#2A1E14")}</div>
${[0, 1].map((i) => `<div id="${u}-r${i}" style="position:absolute;left:${w / 2 - 22}px;top:-18px;width:44px;height:${h + 36}px;border-radius:14px;background:linear-gradient(90deg,#5A3825,#8A5A34,#5A3825);border:5px solid #111;opacity:0"></div>`).join("")}`));
  ctx.js(`tl.set(["#${u}-r0", "#${u}-r1"], { opacity: 1 }, ${f2(t)}); tl.to("#${u}-p", { scaleX: 1, duration: 0.6, ease: "power2.out" }, ${f2(t)}); tl.to("#${u}-r0", { x: ${-w / 2}, duration: 0.6, ease: "power2.out" }, ${f2(t)}); tl.to("#${u}-r1", { x: ${w / 2}, duration: 0.6, ease: "power2.out" }, ${f2(t)});
${revealLines(u, b, t + 0.7)}
tl.to("#${u}-p", { scaleX: 0, duration: 0.4, ease: "power2.in" }, ${f2(t + hold)}); tl.to("#${u}-r0", { x: 0, duration: 0.4, ease: "power2.in" }, ${f2(t + hold)}); tl.to("#${u}-r1", { x: 0, duration: 0.4, ease: "power2.in" }, ${f2(t + hold)}); HIDE(["#${u}-r0", "#${u}-r1"], ${f2(t + hold + 0.4)}, 0.1);`);
  ctx.sfx("whoosh-cinematic", t, 0.3, 0.8); ctx.sfx("click", t + 0.7, 0.25);
  return { dur: hold + 0.5 };
});
def("card", "cd-board", "Bảng gỗ treo dây thả xuống", (ctx, b, t) => {
  const u = ctx.uid("cd"), { x, y, w, h } = cardBox(ctx, b, b.side && b.side !== "center" ? 820 : 1060), hold = cardHold(b);
  ctx.add("hud", div(u, { left: x, top: y - 700, width: w, height: h + 40 }, `<div style="position:absolute;left:${w * 0.18}px;top:-400px;width:6px;height:420px;background:#3B2A1A"></div><div style="position:absolute;left:${w * 0.82}px;top:-400px;width:6px;height:420px;background:#3B2A1A"></div>
<div style="position:absolute;left:0;top:10px;width:${w}px;height:${h}px;border-radius:14px;background:repeating-linear-gradient(0deg,#8A5A34 0 26px,#7A4E2C 26px 30px);border:7px solid #3B2A1A;box-shadow:0 0 0 5px #E3A21A,10px 10px 0 5px rgba(0,0,0,.35);padding:26px 46px">${cardInner(b, "#FFE45C", "#F6EFE0")}${cardLines(b, u, "#FFFAF0")}</div>`));
  ctx.js(`tl.to("#${u}", { y: 700, duration: 0.7, ease: "bounce.out" }, ${f2(t)}); tl.to("#${u}", { rotation: ${f2(ctx.pick([2, -2]))}, transformOrigin: "50% 0%", duration: 0.5, yoyo: true, repeat: 1, ease: "sine.inOut" }, ${f2(t + 0.7)});
${revealLines(u, b, t + 0.8)}
tl.to("#${u}", { y: -40, duration: 0.45, ease: "power2.in" }, ${f2(t + hold)});`);
  ctx.sfx("whoosh-short", t, 0.35); ctx.sfx("impact-bass-1", t + 0.35, 0.3);
  return { dur: hold + 0.5 };
});
def("card", "cd-bamboo", "Thẻ tre xoè ra từng thanh", (ctx, b, t) => {
  const u = ctx.uid("cd"), { x, y, w, h } = cardBox(ctx, b, b.side && b.side !== "center" ? 820 : 1100), hold = cardHold(b), n = Math.ceil(w / 70);
  const slats = Array.from({ length: n }, (_, i) => `<div id="${u}-s${i}" style="position:absolute;left:${i * (w / n)}px;top:0;width:${w / n - 4}px;height:${h}px;border-radius:10px;background:linear-gradient(90deg,#C9A45C,#E8CF8E 45%,#B98F44);border:3px solid #5A3825;transform:scaleY(0);transform-origin:50% 0%"></div>`).join("");
  ctx.add("hud", div(u, { left: x, top: y, width: w, height: h }, `${slats}<div id="${u}-c" style="position:absolute;left:14px;top:14px;width:${w - 28}px;height:${h - 28}px;box-sizing:border-box;padding:12px 32px;border-radius:10px;background:rgba(250,241,216,.93);border:3px solid #5A3825;opacity:0">${cardInner(b, "#8A2A1E", "#3B2A1A")}${cardLines(b, u, "#2A1E14")}</div>`));
  ctx.js(`for (let i = 0; i < ${n}; i++) tl.to("#${u}-s" + i, { scaleY: 1, duration: 0.3, ease: "back.out(1.6)" }, ${f2(t)} + i * 0.03); SHOW("#${u}-c", ${f2(t + 0.35 + n * 0.03)}, 0.25);
${revealLines(u, b, t + 0.5 + n * 0.03)}
HIDE("#${u}-c", ${f2(t + hold)}, 0.15); for (let i = 0; i < ${n}; i++) tl.to("#${u}-s" + i, { scaleY: 0, duration: 0.25, ease: "power2.in" }, ${f2(t + hold + 0.1)} + i * 0.02);`);
  ctx.sfx("click", t, 0.3); ctx.sfx("whoosh-short", t + 0.1, 0.3);
  return { dur: hold + 0.4 + n * 0.02 };
});

// ============================ STAT (beat: {left, right, rows:[{label, l, r}], total?}) ============================
// So chỉ số hai bên (0–10). Bên cao hơn mỗi dòng được tô sáng. Đặt ở dải trên khung, ≤4 dòng.
function statSetup(ctx, b) {
  const rows = (b.rows || []).slice(0, 4);
  if (!rows.length) throw new Error(`${ctx.curKey}: stat cần rows [{label, l, r}]`);
  if ((b.rows || []).length > 4) console.warn(`fx stat: ${ctx.curKey} chỉ hiện 4 dòng đầu`);
  const nm = (id) => ctx.cast?.[id]?.name || id;
  const L = nm(b.left), R = nm(b.right);
  const sum = rows.reduce((s, r) => [s[0] + (+r.l || 0), s[1] + (+r.r || 0)], [0, 0]);
  const wins = rows.reduce((s, r) => [s[0] + (+r.l > +r.r), s[1] + (+r.r > +r.l)], [0, 0]);
  const step = 1.1, rowsEnd = 0.6 + rows.length * step, hold = rowsEnd + (b.total ? 1.6 : 0.8) + 0.8;
  return { rows, L, R, sum, wins, step, rowsEnd, hold };
}
const winner = (l, r) => (l > r ? "l" : r > l ? "r" : "=");

def("stat", "st-bars", "Hai thanh khí mọc từ giữa", (ctx, b, t) => {
  const u = ctx.uid("st"), th = ctx.theme, { rows, L, R, sum, step, rowsEnd, hold } = statSetup(ctx, b), W = 1240, x0 = (1920 - W) / 2, bar = 320;
  const rowHtml = rows.map((r, i) => {
    const w = winner(+r.l, +r.r), y = 96 + i * 76;
    const side = (s, v) => `<div id="${u}-b${s}${i}" style="position:absolute;${s === "l" ? `right:${W / 2 + 130}px` : `left:${W / 2 + 130}px`};top:${y + 14}px;width:${f2((bar * v) / 10)}px;height:38px;border-radius:19px;background:${w === s ? th.qi : "#8C8C8C"};border:4px solid #111;box-shadow:${w === s ? `0 0 18px ${th.qi}` : "none"};transform:scaleX(0);transform-origin:${s === "l" ? "100%" : "0%"} 50%"></div><div id="${u}-n${s}${i}" style="position:absolute;${s === "l" ? `right:${W / 2 + 140 + (bar * v) / 10}px` : `left:${W / 2 + 140 + (bar * v) / 10}px`};top:${y + 6}px;font:700 44px 'Space Grotesk';color:${w === s ? "#FFE45C" : "#ddd"};opacity:0">${v}${w === s ? " ✓" : ""}</div>`;
    return `<div id="${u}-k${i}" style="position:absolute;left:${W / 2 - 125}px;top:${y + 8}px;width:250px;text-align:center;font:700 36px 'Space Grotesk';color:#fff;opacity:0">${esc(r.label)}</div>${side("l", +r.l)}${side("r", +r.r)}`;
  }).join("");
  const tw = winner(sum[0], sum[1]), totY = 96 + rows.length * 76 + 6;
  ctx.add("hud", div(u, { left: x0, top: 30, width: W, height: totY + (b.total ? 84 : 20), opacity: 0 }, `<div style="position:absolute;inset:0;border-radius:24px;background:rgba(12,10,16,.82);border:6px solid ${th.qi};box-shadow:0 0 30px ${th.qi}88"></div>
<div style="position:absolute;left:40px;top:20px;width:${W / 2 - 120}px;font:700 52px 'Space Grotesk';color:${th.light};white-space:nowrap">${esc(L)}</div><div style="position:absolute;left:${W / 2 - 60}px;top:16px;width:120px;text-align:center;${titleCss(56, "#FFE45C")}">VS</div><div style="position:absolute;right:40px;top:20px;width:${W / 2 - 120}px;text-align:right;font:700 52px 'Space Grotesk';color:${th.light};white-space:nowrap">${esc(R)}</div>
${rowHtml}${b.total ? `<div id="${u}-tot" style="position:absolute;left:0;top:${totY}px;width:${W}px;text-align:center;font:700 50px 'Space Grotesk';color:#FFE45C;opacity:0">TỔNG ${sum[0]} – ${sum[1]}${tw === "=" ? " · HOÀ" : ` · ${esc(tw === "l" ? L : R)}`}</div>` : ""}`));
  ctx.js(`SHOW("#${u}", ${f2(t)}, 0.3, { y: -40 });
${rows.map((r, i) => { const s = t + 0.6 + i * step; return `SHOW("#${u}-k${i}", ${f2(s)}, 0.2); tl.to(["#${u}-bl${i}", "#${u}-br${i}"], { scaleX: 1, duration: 0.6, ease: "power2.out" }, ${f2(s + 0.15)}); SHOW(["#${u}-nl${i}", "#${u}-nr${i}"], ${f2(s + 0.7)}, 0.2);`; }).join("\n")}
${b.total ? `STAMP("#${u}-tot", ${f2(t + rowsEnd + 0.2)}, 0);` : ""} HIDE("#${u}", ${f2(t + hold - 0.3)}, 0.3);`);
  ctx.sfx("whoosh-short", t, 0.3);
  rows.forEach((_, i) => ctx.sfx("click", t + 1.35 + i * step, 0.35));
  if (b.total) ctx.sfx("impact-bass-1", t + rowsEnd + 0.4, 0.4);
  return { dur: hold };
});
def("stat", "st-scale", "Cán cân nghiêng dần theo điểm", (ctx, b, t) => {
  const u = ctx.uid("st"), th = ctx.theme, { rows, L, R, sum, step, rowsEnd, hold } = statSetup(ctx, b);
  const pan = (s, name) => `<div style="position:absolute;left:${s === "l" ? 0 : 640}px;top:40px;width:4px;height:90px;background:#3B2A1A;margin-left:${s === "l" ? 60 : 0}px"></div><div style="position:absolute;left:${s === "l" ? -60 : 580}px;top:126px;width:240px;height:60px;border-radius:0 0 120px 120px;background:#E3A21A;border:5px solid #111;text-align:center;font:700 34px/56px 'Space Grotesk';color:#111;white-space:nowrap">${esc(name)}</div>`;
  let acc = 0;
  const tilts = rows.map((r) => { acc += (+r.r || 0) - (+r.l || 0); return Math.max(-14, Math.min(14, acc * 3)); });
  const list = rows.map((r, i) => { const w = winner(+r.l, +r.r); return `<div id="${u}-k${i}" style="opacity:0;margin-top:8px"><span style="color:${w === "l" ? "#FFE45C" : "#fff"}">${+r.l}</span> · ${esc(r.label)} · <span style="color:${w === "r" ? "#FFE45C" : "#fff"}">${+r.r}</span></div>`; }).join("");
  ctx.add("hud", div(u, { left: 0, top: 20, width: 1920, height: 500, opacity: 0 }, `<div style="position:absolute;left:955px;top:40px;width:10px;height:210px;background:#3B2A1A;border:3px solid #111"></div><div style="position:absolute;left:900px;top:240px;width:120px;height:26px;border-radius:12px;background:#5A3825;border:4px solid #111"></div>
<div id="${u}-beam" style="position:absolute;left:600px;top:30px;width:720px;height:200px">${`<div style="position:absolute;left:0;top:28px;width:720px;height:18px;border-radius:9px;background:#8A5A34;border:4px solid #111"></div>`}${pan("l", L)}${pan("r", R)}</div>
<div style="position:absolute;left:560px;top:290px;width:800px;text-align:center;padding:10px 0 16px;border-radius:20px;background:rgba(12,10,16,.8);border:5px solid ${th.qi};font:700 36px 'Space Grotesk';color:#fff">${list}${b.total ? `<div id="${u}-tot" style="opacity:0;margin-top:10px;color:#FFE45C;font-size:44px">TỔNG ${sum[0]} – ${sum[1]}</div>` : ""}</div>`));
  ctx.js(`SHOW("#${u}", ${f2(t)}, 0.3);
${rows.map((_, i) => { const s = t + 0.6 + i * step; return `SHOW("#${u}-k${i}", ${f2(s)}, 0.25, { y: 20 }); tl.to("#${u}-beam", { rotation: ${f2(tilts[i])}, transformOrigin: "50% 37px", duration: 0.6, ease: "back.out(2)" }, ${f2(s + 0.2)});`; }).join("\n")}
${b.total ? `STAMP("#${u}-tot", ${f2(t + rowsEnd + 0.2)}, 0);` : ""} HIDE("#${u}", ${f2(t + hold - 0.3)}, 0.3);`);
  ctx.sfx("whoosh-short", t, 0.3);
  rows.forEach((_, i) => ctx.sfx("click", t + 0.8 + i * step, 0.35));
  if (b.total) ctx.sfx("impact-bass-1", t + rowsEnd + 0.4, 0.4);
  return { dur: hold };
});
def("stat", "st-tally", "Khắc vạch kiếm đếm điểm thắng", (ctx, b, t) => {
  const u = ctx.uid("st"), th = ctx.theme, { rows, L, R, sum, wins, step, rowsEnd, hold } = statSetup(ctx, b);
  const board = (s, name) => `<div style="position:absolute;left:${s === "l" ? 120 : 1320}px;top:30px;width:480px;height:300px;border-radius:16px;background:repeating-linear-gradient(90deg,#8A5A34 0 30px,#7A4E2C 30px 34px);border:7px solid #3B2A1A;box-shadow:10px 10px 0 rgba(0,0,0,.35)"><div style="text-align:center;margin-top:18px;font:700 50px 'Space Grotesk';color:#FFE45C;white-space:nowrap">${esc(name)}</div><div id="${u}-m${s}" style="position:absolute;left:40px;top:110px;width:400px;height:150px"></div></div>`;
  let nl = 0, nr = 0;
  const marks = [];
  rows.forEach((r, i) => { const w = winner(+r.l, +r.r); if (w === "=") return; const k = w === "l" ? nl++ : nr++; marks.push({ i, s: w, html: `<div id="${u}-x${i}" style="position:absolute;left:${(w === "l" ? 160 : 1360) + k * 90}px;top:150px;width:22px;height:140px;border-radius:6px;background:#F6EFE0;border:4px solid #111;transform:rotate(${f2(ctx.range(-10, 10))}deg);opacity:0"></div>` }); });
  ctx.add("hud", div(u, { left: 0, top: 20, width: 1920, height: 480, opacity: 0 }, `${board("l", L)}${board("r", R)}${marks.map((m) => m.html).join("")}
${rows.map((r, i) => `<div id="${u}-k${i}" style="position:absolute;left:660px;top:60px;width:600px;text-align:center;opacity:0"><span class="nametag" style="font-size:40px">${esc(r.label)}</span><div style="margin-top:12px;${titleCss(64, "#fff")}">${+r.l} – ${+r.r}</div></div>`).join("")}
${b.total ? `<div id="${u}-tot" style="position:absolute;left:660px;top:360px;width:600px;text-align:center;opacity:0"><span class="plq">${wins[0]} – ${wins[1]} hiệp</span></div>` : ""}`));
  ctx.js(`SHOW("#${u}", ${f2(t)}, 0.3);
${rows.map((r, i) => { const s = t + 0.6 + i * step; const m = marks.find((x) => x.i === i); return `SHOW("#${u}-k${i}", ${f2(s)}, 0.2, { y: 20 }); ${m ? `STAMP("#${u}-x${i}", ${f2(s + 0.5)}, ${f2(ctx.range(-8, 8))});` : ""} HIDE("#${u}-k${i}", ${f2(s + step - 0.12)}, 0.1);`; }).join("\n")}
${b.total ? `STAMP("#${u}-tot", ${f2(t + rowsEnd + 0.2)}, -3);` : ""} HIDE("#${u}", ${f2(t + hold - 0.3)}, 0.3);`);
  ctx.sfx("whoosh-short", t, 0.3);
  marks.forEach((m) => ctx.sfx("impact-bass-1", t + 0.75 + m.i * step, 0.3));
  if (b.total) ctx.sfx("click", t + rowsEnd + 0.4, 0.4);
  return { dur: hold };
});

// ============================ ENDER (own scene, beat: {next, ep}) ============================
def("ender", "ed-wave", "Tèo vẫy tay + lời hẹn tập sau", (ctx, b, t) => {
  const u = ctx.uid("ed");
  ctx.add("fx", `<div class="fill paper"></div>${div(u + "-t", { left: 120, top: 150, width: 1000, opacity: 0 }, `<div style="font:700 110px/1 'Space Grotesk';color:#3B2A1A">HẾT TẬP ${esc(b.ep)}</div><div style="margin-top:40px;font:600 50px/1.3 'Space Grotesk';color:#8A2A1E">Tập sau: ${esc(b.next)}</div><div style="margin-top:60px"><span class="chip" style="font-size:40px">🔔 Đăng ký Tèo Kể</span></div>`)}
${div(u + "-h", { left: 1250, top: 300 }, ctx.rig("teo", u + "h", 470, { band: "#D7263D", weapon: "kiem" }))}`);
  ctx.rigType(u + "h", "teo");
  ctx.js(`SHOW("#${u}-t", ${t + 0.3}, 0.5, { x: -80 }); POSE("${u}h", "wave", ${t + 0.5}, 0.3); for (let k = 0; k < 8; k++) R("${u}h-foreF", k % 2 ? 91 : 51, ${t + 0.8} + k * 0.15, 0.15, "sine.inOut"); POSE("${u}h", "raise", ${t + 2.2}, 0.35); FLAP("${u}h", ${t + 0.6}, ${t + 2.0}); BLINK("${u}h", ${t + 2.6});
tl.to("#X-black", { opacity: 1, duration: 0.6 }, ${t + 3.6});`);
  ctx.sfx("chime", t + 0.3, 0.35, 2); ctx.sfx("pop", t + 0.5, 0.3);
  return { dur: 4.2 };
});
def("ender", "ed-sunset", "Bóng lưng đi vào hoàng hôn", (ctx, b, t) => {
  const u = ctx.uid("ed");
  ctx.add("fx", `<div class="fill" style="background:linear-gradient(#F59E5B, #F8C98A 55%, #8A4A3A 56%, #3B2A2A)"></div>${div(u + "-sun", { left: 760, top: 300, width: 400, height: 400, borderRadius: "50%", background: "#FFE08A", boxShadow: "0 0 120px #FFD23F" })}
<div class="fill" style="background:linear-gradient(transparent 55%, #3B2A2A 56%)"></div>
${div(u + "-h", { left: 860, top: 520, filter: "brightness(0)" }, ctx.rig("teo", u + "h", 200, { band: "#D7263D", weapon: "kiem" }))}
${div(u + "-t", { left: 0, top: 120, width: 1920, opacity: 0 }, `<div style="${titleCss(100, "#fff", "#3B2A2A")}">HẾT TẬP ${esc(b.ep)}</div><div style="text-align:center;margin-top:20px;font:600 46px 'Space Grotesk';color:#3B2A2A">Tập sau: ${esc(b.next)}</div>`)}`);
  ctx.rigType(u + "h", "teo");
  ctx.js(`tl.to("#${u}-sun", { y: 140, duration: 4, ease: "none" }, ${t}); tl.to("#${u}-h", { scale: 0.5, y: -40, transformOrigin: "50% 100%", duration: 3.6, ease: "none" }, ${t}); RUN("${u}h", ${t}, ${t + 3.4}, null, true, 18, 0.25); ${ctx.v2 ? `SWAY("${u}h-tail", ${t}, ${t + 3.5}, 14, 0.25);` : `tl.to("#${u}h-tail", { rotation: 14, svgOrigin: PIV.teo.tail, duration: 0.25, yoyo: true, repeat: 13 }, ${t});`}
SHOW("#${u}-t", ${t + 0.8}, 0.8, { y: -30 }); tl.to("#X-black", { opacity: 1, duration: 0.7 }, ${t + 3.5});`);
  ctx.sfx("chime", t + 0.8, 0.35, 2);
  return { dur: 4.2 };
});
def("ender", "ed-ink", "Giọt mực loang + ấn kết", (ctx, b, t) => {
  const u = ctx.uid("ed"), x = ctx.range(700, 1200), y = ctx.range(400, 650);
  ctx.add("fx", `<div class="fill paper"></div>${div(u + "-d", { left: x - 60, top: y - 60, width: 120, height: 120, borderRadius: "48% 52% 45% 55%", background: "#141014", transform: "scale(0)" })}
${div(u + "-t", { left: 0, top: 360, width: 1920, opacity: 0 }, `<div style="${titleCss(120, "#F6EFE0", "#000")}">HẾT TẬP ${esc(b.ep)}</div><div style="text-align:center;margin-top:30px;font:600 50px 'Space Grotesk';color:${ctx.theme.light}">Tập sau: ${esc(b.next)}</div>`)}
${div(u + "-s", { left: 1500, top: 720, width: 200, height: 200, borderRadius: 20, background: "#C8372D", border: "7px solid #F6EFE0", font: "700 70px/186px 'Space Grotesk'", color: "#F6EFE0", textAlign: "center", opacity: 0 }, "TÈO")}`);
  ctx.js(`tl.to("#${u}-d", { scale: 0.6, duration: 0.3, ease: "power2.out" }, ${t + 0.2}); tl.to("#${u}-d", { scale: 40, rotation: 40, duration: 1.0, ease: "power2.in" }, ${t + 0.6});
SHOW("#${u}-t", ${t + 1.5}, 0.6, { y: 30 }); STAMP("#${u}-s", ${t + 2.3}, -8); tl.to("#X-black", { opacity: 1, duration: 0.6 }, ${t + 3.6});`);
  ctx.sfx("pop", t + 0.2, 0.3); ctx.sfx("whoosh-cinematic", t + 0.6, 0.35, 1.2); ctx.sfx("impact-bass-1", t + 2.5, 0.4);
  return { dur: 4.2 };
});
def("ender", "ed-scroll", "Cuộn giấy khép lại", (ctx, b, t) => {
  const u = ctx.uid("ed");
  ctx.add("fx", `<div class="fill" style="background:linear-gradient(${ctx.theme.dark}, #050308)"></div>${div(u + "-p", { left: 260, top: 280, width: 1400, height: 480, background: "#F3E6C8", border: "6px solid #3B2A1A" }, `<div style="position:absolute;left:0;top:90px;width:100%;text-align:center;font:700 110px 'Space Grotesk';color:#3B2A1A">HẾT TẬP ${esc(b.ep)}</div><div style="position:absolute;left:0;top:280px;width:100%;text-align:center;font:600 48px 'Space Grotesk';color:#8A2A1E">Tập sau: ${esc(b.next)}</div>`)}
${[0, 1].map((i) => div(`${u}-r${i}`, { left: i ? 1630 : 230, top: 250, width: 60, height: 540, borderRadius: 14, background: "linear-gradient(90deg,#5A3825,#8A5A34,#5A3825)", border: "5px solid #111" })).join("")}`);
  ctx.js(`tl.to("#${u}-p", { scaleX: 0, duration: 0.9, ease: "power3.inOut" }, ${t + 2.6}); tl.to("#${u}-r0", { x: 700, duration: 0.9, ease: "power3.inOut" }, ${t + 2.6}); tl.to("#${u}-r1", { x: -700, duration: 0.9, ease: "power3.inOut" }, ${t + 2.6});
tl.fromTo("#${u}-p", { opacity: 0, y: 40 }, { opacity: 1, y: 0, duration: 0.5, ...NF }, ${t + 0.2}); tl.to("#X-black", { opacity: 1, duration: 0.5 }, ${t + 3.6});`);
  ctx.sfx("chime", t + 0.3, 0.3, 2); ctx.sfx("whoosh-cinematic", t + 2.6, 0.35, 1);
  return { dur: 4.2 };
});

export const THEMES = {
  bang: { name: "Băng", qi: "#6AD3FF", qi2: "#B9A6FF", light: "#DDF4FF", dark: "#0F2140", mid: "#1F4E7A", ink: "#0E1A2A", title: "#BFEFFF", hue: 170 },
  hoa: { name: "Hỏa", qi: "#FF6B3D", qi2: "#FFD23F", light: "#FFE6B0", dark: "#2A0E08", mid: "#6E1F12", ink: "#1A0A08", title: "#FFD23F", hue: -40 },
  loi: { name: "Lôi", qi: "#B07CFF", qi2: "#FFE45C", light: "#F0E6FF", dark: "#160B2E", mid: "#3A1F6E", ink: "#120A1E", title: "#FFE45C", hue: 230 },
  moc: { name: "Mộc", qi: "#6ADF7A", qi2: "#D7F25C", light: "#E6FFD9", dark: "#0C2414", mid: "#1F5A2E", ink: "#0A1A0E", title: "#D7F25C", hue: 80 },
  phong: { name: "Phong", qi: "#7FF0E0", qi2: "#FFFFFF", light: "#F0FFFC", dark: "#0E2A2A", mid: "#1F5A5A", ink: "#0A1818", title: "#FFFFFF", hue: 140 },
  am: { name: "Âm", qi: "#FF4FD8", qi2: "#7B5CFF", light: "#FFD9F6", dark: "#1A0620", mid: "#4A1250", ink: "#14061A", title: "#FF9BEA", hue: 260 },
};
