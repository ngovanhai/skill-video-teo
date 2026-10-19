// Backdrops. Each set(ctx, opts) returns { html, js } — html goes into the scene's bg layer, js is ambient animation
// over [ctx.t0, ctx.t1]. Feet line for actors is GROUND (y=900) unless the set overrides ctx.ground.
export const GROUND = 900;
const W = 1920, H = 1080;
const rep = (ctx, period) => Math.max(1, Math.ceil((ctx.t1 - ctx.t0) / period));
const TINT = { ngay: "", chieu: "rgba(255,120,40,.22)", dem: "rgba(20,30,90,.42)" };
const tint = (time) => TINT[time] ? `<div class="fill" style="background:${TINT[time]};mix-blend-mode:multiply"></div>` : "";
const sky = (time, day, dusk, night) => `<div class="fill" style="background:linear-gradient(${time === "dem" ? night : time === "chieu" ? dusk : day})"></div>`;
const moon = (x, y, r = 70) => `<div style="position:absolute;left:${x}px;top:${y}px;width:${r * 2}px;height:${r * 2}px;border-radius:50%;background:#FFF1C2;box-shadow:0 0 60px #FFE9A8"></div>`;

export const SETS = {
  "san-tap"(ctx, { time = "ngay" }) {
    const S = ctx.S, stakes = Array.from({ length: 34 }, (_, i) => `<path d="M${i * 58 + 10} 150 L${i * 58 + 10} 30 L${i * 58 + 30} 6 L${i * 58 + 50} 30 L${i * 58 + 50} 150 Z" fill="#8A5A34" stroke="#3B2A1A" stroke-width="5" stroke-linejoin="round"/>`).join("");
    const flag = (x, n) => `<div style="position:absolute;left:${x}px;top:60px;width:14px;height:560px;background:#5A3825;border:3px solid #111"></div><div id="${S}-flag${n}" style="position:absolute;left:${x + 14}px;top:80px;width:230px;height:300px;background:#F3E6C8;border:5px solid #3B2A1A;transform-origin:0% 50%"><div style="margin:40px auto 0;width:110px;height:110px;border-radius:50%;border:8px solid #C8372D;font:700 64px/94px 'Space Grotesk';color:#C8372D;text-align:center">武</div></div>`;
    const fx = ctx.range(200, 500), fx2 = ctx.range(1350, 1600);
    return {
      html: `${sky(time, "#9FD6EA 0%, #DCEFE9 45%, #F3EAD2 60%", "#F59E5B 0%, #F8C98A 50%, #F3EAD2 62%", "#1A2443 0%, #33466F 55%, #4A4A5A 62%")}
<svg style="position:absolute;left:0;top:300px" width="1920" height="330" viewBox="0 0 1920 330"><path d="M0 220 Q240 60 520 170 Q760 40 1060 160 Q1340 30 1620 150 Q1800 90 1920 140 L1920 330 L0 330 Z" fill="#8CBF8A" stroke="#3B6B4A" stroke-width="5"/><path d="M0 270 Q300 170 640 250 Q980 160 1300 250 Q1640 180 1920 230 L1920 330 L0 330 Z" fill="#6FA872" stroke="#3B6B4A" stroke-width="5"/></svg>
${flag(fx, 1)}${flag(fx2, 2)}
<svg style="position:absolute;left:0;top:470px" width="1980" height="160" viewBox="0 0 1980 160">${stakes}<rect x="0" y="60" width="1980" height="16" fill="#6B3E1F" stroke="#3B2A1A" stroke-width="4"/></svg>
<div style="position:absolute;left:0;top:610px;width:1920px;height:470px;background:linear-gradient(#E9D3A2,#DCC08A);border-top:6px solid #B89660"></div>${tint(time)}`,
      js: [1, 2].map((n) => `tl.to("#${S}-flag${n}", { skewY: 7, scaleX: 0.93, duration: 0.5, yoyo: true, repeat: ${rep(ctx, 0.5)}, ease: "sine.inOut" }, ${ctx.t0 + n * 0.2});`).join("\n"),
    };
  },
  "rung-truc"(ctx, { time = "ngay" }) {
    const S = ctx.S;
    const stalks = (n, op, wMin, wMax, col, dark) => Array.from({ length: n }, () => { const x = ctx.range(-40, 1900), w = ctx.range(wMin, wMax); const nodes = Array.from({ length: 7 }, (_, k) => `<div style="position:absolute;left:-4px;top:${80 + k * 150 + ctx.range(-20, 20)}px;width:${w + 8}px;height:8px;background:${dark};border-radius:4px"></div>`).join(""); return `<div style="position:absolute;left:${x}px;top:-20px;width:${w}px;height:1120px;background:${col};opacity:${op};border-left:4px solid ${dark};border-right:4px solid ${dark}">${nodes}</div>`; }).join("");
    const leaves = Array.from({ length: 14 }, (_, i) => `<svg id="${S}-lf${i}" style="position:absolute;left:${ctx.range(0, 1900)}px;top:-60px;overflow:visible" width="40" height="20" viewBox="0 0 40 20"><path d="M0 10 Q20 -6 40 10 Q20 26 0 10 Z" fill="#7CB342" stroke="#33691E" stroke-width="3"/></svg>`).join("");
    return {
      html: `${sky(time, "#CFE8C0 0%, #9CCB8A 70%", "#F3C58A 0%, #A9B86A 70%", "#1E3326 0%, #2F4A33 70%")}
${stalks(18, 0.45, 26, 40, "#7FAE6A", "#4F7A43")}${stalks(12, 1, 40, 64, "#8BC34A", "#33691E")}
<div style="position:absolute;left:0;top:780px;width:1920px;height:300px;background:linear-gradient(#9B7A4A,#7A5A34);border-top:6px solid #4E3A22"></div>${leaves}${tint(time)}`,
      js: Array.from({ length: 14 }, (_, i) => `tl.fromTo("#${S}-lf${i}", { y: 0, x: 0, rotation: 0 }, { y: 1200, x: ${Math.round(ctx.range(-300, 300))}, rotation: ${Math.round(ctx.range(360, 900))}, duration: ${ctx.range(4, 7).toFixed(2)}, repeat: ${rep(ctx, 4)}, ease: "none" }, ${(ctx.t0 + ctx.range(-3, 1)).toFixed(2)});`).join("\n"),
    };
  },
  "mai-ngoi"(ctx, { time = "dem" }) {
    const S = ctx.S;
    const stars = Array.from({ length: 30 }, (_, i) => `<div id="${S}-st${i}" style="position:absolute;left:${ctx.range(0, 1920)}px;top:${ctx.range(0, 420)}px;width:6px;height:6px;border-radius:50%;background:#fff;box-shadow:0 0 8px #fff"></div>`).join("");
    const roof = (x, y, w, col) => `<svg style="position:absolute;left:${x}px;top:${y}px;overflow:visible" width="${w}" height="400" viewBox="0 0 ${w} 400"><path d="M-40 60 Q${w * 0.1} 70 ${w * 0.18} 0 L${w * 0.82} 0 Q${w * 0.9} 70 ${w + 40} 60 L${w} 110 L0 110 Z" fill="${col}" stroke="#111" stroke-width="6" stroke-linejoin="round"/>${Array.from({ length: Math.floor(w / 40) }, (_, k) => `<path d="M${k * 40 + 10} 14 L${k * 40} 100" stroke="#111" stroke-width="3" opacity=".35"/>`).join("")}<rect x="10" y="110" width="${w - 20}" height="290" fill="#3B2A1A" stroke="#111" stroke-width="6"/></svg>`;
    const lanterns = [0, 1, 2].map((i) => `<div id="${S}-ln${i}" style="position:absolute;left:${300 + i * 600 + ctx.range(-80, 80)}px;top:560px;width:60px;height:150px;transform-origin:50% 0%"><div style="margin-left:28px;width:4px;height:50px;background:#111"></div><div style="width:60px;height:80px;border-radius:24px;background:#E8452E;border:5px solid #111;box-shadow:0 0 40px #FF7A3A"></div></div>`).join("");
    return {
      html: `${sky(time, "#9FD6EA 0%, #F3EAD2 70%", "#F59E5B 0%, #F8C98A 70%", "#0E1430 0%, #26335E 70%")}${time === "dem" ? stars : ""}${moon(ctx.range(1300, 1600), 90, 80)}
${roof(-60, 620, 800, "#5A3A3A")}${roof(1150, 660, 900, "#4A3434")}
<svg style="position:absolute;left:0;top:${GROUND - 40}px;overflow:visible" width="1920" height="260" viewBox="0 0 1920 260"><path d="M-40 40 Q240 50 360 0 L1560 0 Q1680 50 1960 40 L1960 260 L-40 260 Z" fill="#6B3A3A" stroke="#111" stroke-width="7" stroke-linejoin="round"/>${Array.from({ length: 48 }, (_, k) => `<path d="M${k * 42} 10 L${k * 42 - 10} 250" stroke="#111" stroke-width="4" opacity=".35"/>`).join("")}</svg>${lanterns}${tint(time === "dem" ? "" : time)}`,
      js: [0, 1, 2].map((i) => `tl.to("#${S}-ln${i}", { rotation: ${5 + i}, duration: 0.9, yoyo: true, repeat: ${rep(ctx, 0.9)}, ease: "sine.inOut" }, ${ctx.t0 + i * 0.3});`).join("\n") + "\n" + Array.from({ length: 30 }, (_, i) => `if ($id("${S}-st${i}")) tl.to("#${S}-st${i}", { opacity: 0.2, duration: ${ctx.range(0.4, 0.9).toFixed(2)}, yoyo: true, repeat: ${rep(ctx, 0.6)}, ease: "sine.inOut" }, ${(ctx.t0 + ctx.range(0, 1)).toFixed(2)});`).join("\n"),
    };
  },
  "quan-tro"(ctx, { time = "chieu" }) {
    const S = ctx.S;
    const lanterns = [0, 1, 2, 3].map((i) => `<div id="${S}-ln${i}" style="position:absolute;left:${180 + i * 480}px;top:0;width:70px;height:260px;transform-origin:50% 0%"><div style="margin-left:33px;width:4px;height:130px;background:#111"></div><div style="width:70px;height:96px;border-radius:30px;background:#E8452E;border:5px solid #111;box-shadow:0 0 50px #FF9A4A;font:700 40px/86px 'Space Grotesk';color:#FFE9A8;text-align:center">福</div></div>`).join("");
    const table = (x) => `<div style="position:absolute;left:${x}px;top:700px;width:300px;height:30px;background:#8A5A34;border:5px solid #111;border-radius:6px"></div><div style="position:absolute;left:${x + 30}px;top:725px;width:22px;height:150px;background:#6B3E1F;border:4px solid #111"></div><div style="position:absolute;left:${x + 248}px;top:725px;width:22px;height:150px;background:#6B3E1F;border:4px solid #111"></div><div style="position:absolute;left:${x + 120}px;top:650px;width:56px;height:54px;border-radius:10px 10px 22px 22px;background:#F4F1EA;border:5px solid #111"></div>`;
    return {
      html: `<div class="fill" style="background:repeating-linear-gradient(90deg,#9A6238 0 120px,#8A5630 120px 126px)"></div>
<div style="position:absolute;left:0;top:420px;width:1920px;height:40px;background:#6B3E1F;border-top:5px solid #111;border-bottom:5px solid #111"></div>
<div style="position:absolute;left:760px;top:120px;width:400px;height:120px;background:#2B1A10;border:8px solid #E3A21A;border-radius:10px;font:700 84px/104px 'Space Grotesk';color:#E3A21A;text-align:center">QUÁN TRỌ</div>
<div style="position:absolute;left:120px;top:150px;width:300px;height:230px;background:linear-gradient(#F8C98A,#F59E5B);border:12px solid #3B2A1A"><div style="position:absolute;left:138px;top:0;width:12px;height:206px;background:#3B2A1A"></div></div>
<div style="position:absolute;left:1500px;top:150px;width:300px;height:230px;background:linear-gradient(#F8C98A,#F59E5B);border:12px solid #3B2A1A"><div style="position:absolute;left:138px;top:0;width:12px;height:206px;background:#3B2A1A"></div></div>
${table(ctx.range(60, 200))}${table(ctx.range(1500, 1620))}
<div style="position:absolute;left:0;top:860px;width:1920px;height:220px;background:repeating-linear-gradient(90deg,#7A4B2A 0 160px,#6B3E1F 160px 166px);border-top:6px solid #111"></div>${lanterns}${tint(time === "chieu" ? "" : time)}`,
      js: [0, 1, 2, 3].map((i) => `tl.to("#${S}-ln${i}", { rotation: ${i % 2 ? -4 : 4}, duration: 1.1, yoyo: true, repeat: ${rep(ctx, 1.1)}, ease: "sine.inOut" }, ${ctx.t0 + i * 0.25});`).join("\n"),
    };
  },
  "nui-tuyet"(ctx, { time = "ngay" }) {
    const S = ctx.S;
    const pine = (x, y, s) => `<svg style="position:absolute;left:${x}px;top:${y}px;overflow:visible" width="${120 * s}" height="${240 * s}" viewBox="0 0 120 240"><path d="M60 0 L110 90 L84 90 L118 160 L88 160 L120 220 L0 220 L32 160 L2 160 L36 90 L10 90 Z" fill="#2E5A4A" stroke="#111" stroke-width="5" stroke-linejoin="round"/><path d="M60 0 L82 40 Q60 30 38 40 Z" fill="#fff"/><rect x="50" y="218" width="20" height="22" fill="#5A3825"/></svg>`;
    const flakes = Array.from({ length: 40 }, (_, i) => `<div id="${S}-sn${i}" style="position:absolute;left:${ctx.range(0, 1920)}px;top:-20px;width:${ctx.range(6, 14)}px;height:${ctx.range(6, 14)}px;border-radius:50%;background:#fff;opacity:.9"></div>`).join("");
    return {
      html: `${sky(time, "#BFD9EE 0%, #EAF3FA 60%", "#E9A27A 0%, #F6D5C0 60%", "#16213E 0%, #3A4A6E 60%")}
<svg style="position:absolute;left:0;top:200px" width="1920" height="500" viewBox="0 0 1920 500"><path d="M0 420 L300 120 L460 260 L720 40 L980 300 L1240 90 L1520 280 L1720 160 L1920 300 L1920 500 L0 500 Z" fill="#8FA6C0" stroke="#3B4A6B" stroke-width="5" stroke-linejoin="round"/><path d="M300 120 L360 180 L330 200 L300 170 L260 200 L240 180 Z M720 40 L800 120 L760 140 L720 110 L680 140 L650 120 Z M1240 90 L1310 160 L1280 175 L1240 150 L1200 175 L1170 160 Z" fill="#fff"/></svg>
${pine(ctx.range(40, 200), 560, 1.2)}${pine(ctx.range(1600, 1760), 540, 1.4)}${pine(ctx.range(300, 420), 620, 0.9)}
<div style="position:absolute;left:0;top:800px;width:1920px;height:280px;background:linear-gradient(#FFFFFF,#DDE8F2);border-top:6px solid #9FB4CC"></div>${flakes}${tint(time)}`,
      js: Array.from({ length: 40 }, (_, i) => `tl.fromTo("#${S}-sn${i}", { y: 0, x: 0 }, { y: 1120, x: ${Math.round(ctx.range(-160, 160))}, duration: ${ctx.range(3, 6).toFixed(2)}, repeat: ${rep(ctx, 3)}, ease: "none" }, ${(ctx.t0 + ctx.range(-3, 0.5)).toFixed(2)});`).join("\n"),
    };
  },
  "ben-song"(ctx, { time = "chieu" }) {
    const S = ctx.S;
    const waves = [0, 1, 2].map((i) => `<div id="${S}-wv${i}" style="position:absolute;left:-200px;top:${600 + i * 70}px;width:2400px;height:24px;background:repeating-linear-gradient(90deg,rgba(255,255,255,.55) 0 60px,transparent 60px 200px);border-radius:12px"></div>`).join("");
    const reeds = Array.from({ length: 22 }, () => { const x = ctx.range(0, 1920); return `<path d="M${x} 300 Q${x + ctx.range(-20, 20)} 180 ${x + ctx.range(-30, 30)} ${ctx.range(60, 120)}" stroke="#5E7A3A" stroke-width="6" fill="none"/>`; }).join("");
    return {
      html: `${sky(time, "#A9D8F0 0%, #E9F4F8 50%", "#F59E5B 0%, #FBD7A0 50%", "#141D36 0%, #33466F 50%")}${moon(ctx.range(200, 500), 120, time === "dem" ? 70 : 0)}
<div style="position:absolute;left:0;top:520px;width:1920px;height:560px;background:linear-gradient(#4E8FB8,#2F5F86)"></div>${waves}
<div id="${S}-boat" style="position:absolute;left:${ctx.range(1150, 1400)}px;top:520px;width:420px;height:140px"><svg viewBox="0 0 420 140" width="420" height="140" style="overflow:visible"><path d="M0 60 L420 60 Q380 130 210 130 Q40 130 0 60 Z" fill="#8A5A34" stroke="#111" stroke-width="6" stroke-linejoin="round"/><path d="M120 60 Q210 -10 300 60 Z" fill="#E9CF8E" stroke="#111" stroke-width="5"/></svg></div>
<svg style="position:absolute;left:0;top:600px;overflow:visible" width="1920" height="300" viewBox="0 0 1920 300">${reeds}</svg>
<div style="position:absolute;left:0;top:860px;width:1920px;height:220px;background:repeating-linear-gradient(90deg,#9A6238 0 140px,#7A4B2A 140px 148px);border-top:7px solid #111"></div>
<div style="position:absolute;left:0;top:940px;width:1920px;height:140px;background:rgba(0,0,0,.15)"></div>${tint(time === "chieu" ? "" : time)}`,
      js: [0, 1, 2].map((i) => `tl.fromTo("#${S}-wv${i}", { x: ${i % 2 ? -200 : 0} }, { x: ${i % 2 ? 0 : -200}, duration: ${2 + i * 0.5}, repeat: ${rep(ctx, 2)}, ease: "none" }, ${ctx.t0});`).join("\n") + `\ntl.to("#${S}-boat", { y: 10, rotation: 1.5, duration: 1.2, yoyo: true, repeat: ${rep(ctx, 1.2)}, ease: "sine.inOut" }, ${ctx.t0});`,
    };
  },
  "cau-go"(ctx, { time = "ngay" }) {
    const S = ctx.S;
    const mist = [0, 1, 2].map((i) => `<div id="${S}-ms${i}" style="position:absolute;left:${-300 + i * 700}px;top:${700 + i * 60}px;width:1100px;height:160px;border-radius:50%;background:radial-gradient(ellipse,rgba(255,255,255,.75),rgba(255,255,255,0) 70%)"></div>`).join("");
    const birds = [0, 1, 2].map((i) => `<svg id="${S}-bd${i}" style="position:absolute;left:-100px;top:${120 + i * 50}px;overflow:visible" width="50" height="20" viewBox="0 0 50 20"><path d="M0 10 Q12 0 25 10 Q38 0 50 10" fill="none" stroke="#2B2D42" stroke-width="5" stroke-linecap="round"/></svg>`).join("");
    const planks = Array.from({ length: 40 }, (_, k) => `<rect x="${k * 50}" y="0" width="44" height="40" fill="#8A5A34" stroke="#111" stroke-width="4"/>`).join("");
    return {
      html: `${sky(time, "#B9E0F2 0%, #EAF6FA 60%", "#F59E5B 0%, #FBD7A0 60%", "#141D36 0%, #33466F 60%")}
<svg style="position:absolute;left:0;top:150px" width="1920" height="930" viewBox="0 0 1920 930"><path d="M0 0 L380 60 L460 930 L0 930 Z" fill="#7A8F6A" stroke="#3B4A2A" stroke-width="6"/><path d="M1920 0 L1540 80 L1460 930 L1920 930 Z" fill="#6E835E" stroke="#3B4A2A" stroke-width="6"/><path d="M900 120 L920 930 M960 120 L990 930" stroke="#CDEBF5" stroke-width="18" opacity=".8"/></svg>${mist}
<svg style="position:absolute;left:0;top:${GROUND}px;overflow:visible" width="1920" height="60" viewBox="0 0 1920 60">${planks}</svg>
<svg style="position:absolute;left:0;top:${GROUND - 140}px;overflow:visible" width="1920" height="160" viewBox="0 0 1920 160"><path d="M0 20 Q960 120 1920 20" fill="none" stroke="#6B3E1F" stroke-width="10"/>${Array.from({ length: 20 }, (_, k) => `<path d="M${k * 100} ${20 + 100 * Math.sin(Math.PI * k / 19.2) * 0.9} L${k * 100} 140" stroke="#6B3E1F" stroke-width="6"/>`).join("")}</svg>${birds}${tint(time)}`,
      js: [0, 1, 2].map((i) => `tl.to("#${S}-ms${i}", { x: ${i % 2 ? -260 : 260}, duration: ${ctx.t1 - ctx.t0}, ease: "sine.inOut" }, ${ctx.t0});`).join("\n") + "\n" + [0, 1, 2].map((i) => `tl.fromTo("#${S}-bd${i}", { x: 0, scaleY: 1 }, { x: 2100, duration: ${6 + i}, ease: "none" }, ${ctx.t0 + i * 0.6});tl.to("#${S}-bd${i}", { scaleY: -0.6, duration: 0.2, yoyo: true, repeat: ${rep(ctx, 0.2)} }, ${ctx.t0});`).join("\n"),
    };
  },
};
