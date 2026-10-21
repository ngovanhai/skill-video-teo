// Scene templates. Each takes ctx = { video, scene, ns, cues, dur } and returns
// { css, html, js, bg, sfx: [{ file, t, vol }] }. Layout keeps y > 880 clear for captions.
import { C, esc, r3, color, pastel, fit, charBox, castName, times, isDark } from "../lib/base.mjs";
import { landscape } from "./places.mjs";

export const SFX = { pop: "lib-pop.mp3", whoosh: "lib-whoosh.mp3", whooshShort: "lib-whoosh-short.mp3", impact: "lib-impact-bass-1.mp3",
  impact2: "lib-impact-bass-2.mp3", chime: "lib-chime.mp3", sparkle: "lib-sparkle.mp3", click: "lib-click.mp3", riser: "lib-riser.mp3",
  glitch: "lib-glitch-1.mp3", error: "lib-error.mp3", cinematic: "lib-whoosh-cinematic.mp3" };
export const fx = (name, t, vol = 0.35) => ({ file: SFX[name] || name, t: r3(Math.max(0, t)), vol });

// Tèo in a corner, talking through the scene (a cameo that keeps the narrator present).
export function cameo(ctx, pose = "talk", side = "left") {
  const { video, ns, cues, dur } = ctx;
  const h = 330;
  const c = charBox(video, "teo", { ns: `${ns}-teo`, left: side === "left" ? 40 : 1920 - 40 - Math.round(h * 0.658), top: 880 - h, h, pose });
  return {
    html: c.html,
    js: `      SLIDE(q("#${ns}-teo"), 0.15, 0, 360, 0.5);
      FLAP("${ns}-teo", ${JSON.stringify(cues.spans(0.4, dur))});
      BOB(q("#${ns}-teo-bob"), 0.7, ${r3(dur - 0.2)}, 4);`,
  };
}
const wantsCameo = (s, dflt) => (s.teo === undefined ? dflt : s.teo);

// speech-ish card used by several templates
const card = (ns, id, text, { left, top, width, bg, size, rot = 0, extra = "" }) =>
  `<div class="${ns}-card ${ns}-up" id="${ns}-${id}" style="left:${left}px;top:${top}px;width:${width}px;background:${bg};font-size:${size}px;text-align:center;transform:rotate(${rot}deg);${extra}">${esc(text)}</div>`;

// ---------------------------------------------------------------- hook
function hook(ctx) {
  const { scene: s, ns, cues, dur, video } = ctx;
  const lines = (s.lines || []).slice(0, 4);
  const tl = times(cues, lines, 0.3, dur * 0.55);
  const qT = s.question ? cues.find(s.question.at, Math.min(dur - 2.5, (tl.at(-1) ?? 0) + 1.6)) : null;
  const teoT = s.teo === false ? null : cues.find(s.teo_at, 0.2);
  const strike = s.style !== "stack";
  const H = 150, GAP = 22, TOP = 120;
  let html = "", js = "", sfx = [];
  if (s.pill) html += `<div class="${ns}-card ${ns}-up" id="${ns}-pill" style="left:64px;top:52px;background:${C.cream};border-radius:9999px;font-size:26px;box-shadow:4px 4px 0 #000;border-width:3px;">${esc(s.pill)}</div>`;
  html += `<div id="${ns}-stack" style="position:absolute;left:960px;top:${TOP}px;width:800px;height:${lines.length * (H + GAP)}px;">`;
  lines.forEach((l, i) => {
    const size = fit(l.text, 720, 96, 40);
    html += `<div class="${ns}-card ${ns}-up" id="${ns}-l${i}" style="left:0;top:${i * (H + GAP)}px;width:800px;height:${H}px;background:${color(l.color, i)};font-size:${size}px;display:flex;align-items:center;justify-content:center;white-space:nowrap;">${esc(l.text)}
      <svg style="position:absolute;left:-20px;top:0;width:840px;height:${H}px;overflow:visible" viewBox="0 0 840 ${H}"><path id="${ns}-s${i}" pathLength="1" stroke-dasharray="1" stroke-dashoffset="1" d="M20 ${H * 0.62} C 220 ${H * 0.5}, 460 ${H * 0.6}, 820 ${H * 0.42}" fill="none" stroke="#000" stroke-width="16" stroke-linecap="round"/></svg></div>`;
    js += `      STAMP(q("#${ns}-l${i}"), ${tl[i]}, ${i % 2 ? 1.5 : -1.5});\n`;
    sfx.push(fx("pop", tl[i], 0.3));
    if (strike && i < lines.length - 1) js += `      DRAW(q("#${ns}-s${i}"), ${r3(tl[i + 1] - 0.25)}, 0.3);\n`;
  });
  html += `</div>`;
  if (strike && lines.length && s.question) js += `      DRAW(q("#${ns}-s${lines.length - 1}"), ${r3(qT - 0.35)}, 0.3);\n`;
  if (s.pill) js += `      SLIDE(q("#${ns}-pill"), 0.05, 0, -80, 0.4);\n`;
  if (s.question) {
    const qs = fit(s.question.text, 900, 64, 34, 2);
    html += `<div id="${ns}-qm" style="position:absolute;left:1180px;top:60px;width:420px;height:520px;" data-layout-allow-overlap>
        <svg viewBox="0 0 420 520" style="width:100%;height:100%;overflow:visible"><text x="226" y="476" text-anchor="middle" font-family="Space Grotesk" font-weight="700" font-size="540" fill="#000">?</text>
        <text x="210" y="460" text-anchor="middle" font-family="Space Grotesk" font-weight="700" font-size="540" fill="${C.yellow}" stroke="#000" stroke-width="14" stroke-linejoin="round" paint-order="stroke">?</text></svg></div>
      <div class="${ns}-card ${ns}-up" id="${ns}-qt" style="left:820px;top:620px;width:1000px;background:${C.blue};font-size:${qs}px;text-align:center;">${esc(s.question.text)}</div>`;
    js += `      tl.to(q("#${ns}-stack"), { scale: 0.42, x: 120, y: -70, opacity: 0.85, transformOrigin: "0% 0%", duration: 0.5, ease: "power3.inOut" }, ${r3(qT - 0.15)});
      tl.fromTo(q("#${ns}-qm"), { scale: 0, rotation: -20, transformOrigin: "50% 85%" }, { scale: 1, rotation: 0, duration: 0.45, ease: "back.out(1.8)", immediateRender: false }, ${r3(qT)});
      [-9, 7, -4, 0].forEach(function (r, i) { tl.to(q("#${ns}-qm"), { rotation: r, duration: 0.15, ease: "power1.inOut" }, ${r3(qT + 0.45)} + i * 0.15); });
      tl.fromTo(q("#${ns}-qt"), { scaleX: 0, transformOrigin: "0% 50%" }, { scaleX: 1, duration: 0.3, ease: "power3.out", immediateRender: false }, ${r3(qT + 0.2)});
      tl.set(q("#${ns}-qm"), { opacity: 1 }, ${r3(qT)});\n`;
    sfx.push(fx("impact", qT, 0.4));
  }
  if (teoT != null) {
    const c = charBox(video, "teo", { ns: `${ns}-teo`, left: 90, top: 340, h: 540, pose: s.pose || "talk" });
    html += c.html + `<div class="${ns}-card ${ns}-up" id="${ns}-tag" style="left:400px;top:300px;background:${C.pink};font-size:64px;">${esc(castName(video, "teo"))}</div>`;
    js += `      SLIDE(q("#${ns}-teo"), ${r3(teoT)}, 0, 640, 0.6);
      STAMP(q("#${ns}-tag"), ${r3(teoT + 0.5)}, -6);
      FLAP("${ns}-teo", ${JSON.stringify(cues.spans(teoT, dur))});
      BOB(q("#${ns}-teo-bob"), ${r3(teoT + 0.6)}, ${r3(dur - 0.2)}, 5);\n`;
    sfx.push(fx("whooshShort", teoT, 0.3));
  }
  const css = `#${ns}-qm, #${ns}-qt, #${ns}-teo, #${ns}-tag { opacity: 0; }`;
  // initial hides via gsap.set happen through immediateRender:false + css opacity 0, so pin them visible on entry
  js += `      tl.set([q("#${ns}-qt")].filter(Boolean), { opacity: 1 }, ${qT != null ? r3(qT + 0.2) : 0});\n`;
  if (teoT != null) js += `      tl.set([q("#${ns}-teo"), q("#${ns}-tag")], { opacity: 1 }, ${r3(teoT)});\n`;
  return { css, html, js, sfx, bg: s.bg || "paper" };
}

// ---------------------------------------------------------------- chapter
function chapter(ctx) {
  const { scene: s, ns, cues, dur, video } = ctx;
  const bg = s.bg || "dark";
  const tT = cues.find(s.at, 0.55);
  const size = fit(s.title, 1500, 120, 56, 2);
  let html = `<div id="${ns}-num" style="position:absolute;left:810px;top:110px;width:300px;height:300px;border-radius:50%;background:${C.yellow};border:6px solid #000;box-shadow:10px 10px 0 #000;display:flex;align-items:center;justify-content:center;font-weight:700;font-size:170px;line-height:1;padding-top:10px;">${esc(s.num ?? "")}</div>
      <div class="${ns}-card ${ns}-up" id="${ns}-kick" style="left:660px;top:440px;width:600px;background:${C.pink};font-size:34px;text-align:center;border-radius:9999px;">${esc(s.kicker || "Chương " + (s.num ?? ""))}</div>
      <div class="${ns}-card ${ns}-up" id="${ns}-title" style="left:160px;top:560px;width:1600px;background:${C.white};font-size:${size}px;text-align:center;padding:24px 40px 16px;">${esc(s.title)}</div>
      <div id="${ns}-rays" style="position:absolute;left:460px;top:-240px;width:1000px;height:1000px;opacity:0.18;background:repeating-conic-gradient(${C.yellow} 0deg 10deg, transparent 10deg 20deg);border-radius:50%;"></div>`;
  let js = `      tl.fromTo(q("#${ns}-rays"), { rotation: 0, scale: 0.6 }, { rotation: 40, scale: 1, duration: ${r3(dur)}, ease: "none" }, 0);
      tl.fromTo(q("#${ns}-num"), { scale: 0, rotation: -180 }, { scale: 1, rotation: 0, duration: 0.6, ease: "back.out(1.5)", immediateRender: false }, 0.1);
      SLIDE(q("#${ns}-kick"), 0.35, -300, 0, 0.45);
      STAMP(q("#${ns}-title"), ${r3(tT)}, -1);\n`;
  const css = `#${ns}-num, #${ns}-kick, #${ns}-title { opacity: 0; } #${ns}-rays { z-index: 0; }`;
  js += `      tl.set(q("#${ns}-num"), { opacity: 1 }, 0.1);\n`;
  const sfx = [fx("cinematic", 0.05, 0.4), fx("impact2", tT, 0.4)];
  if (wantsCameo(s, false)) { const c = cameo(ctx, s.pose || "point", "left"); html += c.html; js += c.js; }
  return { css, html, js, sfx, bg };
}

// ---------------------------------------------------------------- narrator
function narrator(ctx) {
  const { scene: s, ns, cues, dur, video } = ctx;
  const pts = (s.points || []).slice(0, 4);
  const tt = times(cues, pts, 0.8, dur * 0.8);
  const c = charBox(video, "teo", { ns: `${ns}-teo`, left: 150, top: 230, h: 650, pose: s.pose || "talk" });
  let html = c.html, js = "", sfx = [];
  js += `      SLIDE(q("#${ns}-teo"), 0.05, -420, 0, 0.5);
      FLAP("${ns}-teo", ${JSON.stringify(cues.spans(0, dur))});
      BOB(q("#${ns}-teo-bob"), 0.5, ${r3(dur - 0.2)}, 5);\n`;
  let top = 120;
  if (s.title) {
    const ts = fit(s.title, 980, 72, 36, 2);
    html += card(ns, "title", s.title, { left: 780, top: 90, width: 1040, bg: color(s.color, 3), size: ts, rot: -1.5 });
    js += `      STAMP(q("#${ns}-title"), 0.25, -1.5);\n`;
    top = 90 + (ts > 60 ? 140 : 180);
  }
  if (pts.length) {
    const avail = 860 - top;
    const step = Math.min(190, avail / pts.length);
    pts.forEach((p, i) => {
      const sz = fit(p.text, 900, step > 160 ? 56 : 46, 28, 2);
      html += `<div class="${ns}-card" id="${ns}-p${i}" style="left:${820 + (i % 2) * 30}px;top:${r3(top + i * step)}px;width:960px;min-height:${Math.round(step - 30)}px;background:${color(p.color, i)};font-size:${sz}px;display:flex;align-items:center;gap:22px;">
        <span style="flex:none;width:64px;height:64px;border-radius:50%;background:#000;color:#fff;display:flex;align-items:center;justify-content:center;font-size:36px;padding-top:4px;">${p.icon ? esc(p.icon) : i + 1}</span><span>${esc(p.text)}</span></div>`;
      js += `      SLIDE(q("#${ns}-p${i}"), ${tt[i]}, 260, 0, 0.42);\n`;
      sfx.push(fx("click", tt[i], 0.3));
    });
  } else if (s.bubble) {
    const bs = fit(s.bubble, 860, 76, 36, 3);
    html += `<div id="${ns}-bub" style="position:absolute;left:760px;top:180px;width:1020px;">
        <div class="${ns}-card" style="position:relative;background:#fff;border-radius:48px;font-size:${bs}px;padding:44px 52px 36px;text-align:center;">${esc(s.bubble)}</div>
        <svg viewBox="0 0 120 90" style="position:absolute;left:-70px;top:250px;width:140px;height:100px;overflow:visible"><path d="M120 0 L0 80 L95 40 Z" fill="#fff" stroke="#000" stroke-width="5" stroke-linejoin="round"/></svg></div>`;
    js += `      POP(q("#${ns}-bub"), ${r3(cues.find(s.at, 0.5))}, { from: 0.6 });\n`;
  }
  return { css: "", html, js, sfx, bg: s.bg || "paper" };
}

// ---------------------------------------------------------------- intro (a character or object)
function intro(ctx) {
  const { scene: s, ns, cues, dur, video } = ctx;
  const facts = (s.facts || []).slice(0, 3);
  const t0 = cues.find(s.at, 0.3);
  const tf = times(cues, facts, t0 + 1.2, dur * 0.85);
  const right = s.side === "right";
  const h = s.h || 640;
  const c = charBox(video, s.who, { ns: `${ns}-c`, left: 0, top: 0, h, pose: s.pose, flip: !!s.flip });
  const cx = right ? 1420 : 500;
  let html = `<div id="${ns}-spot" style="position:absolute;left:${cx - 330}px;top:110px;width:660px;height:660px;border-radius:50%;background:${color(s.color, 0)};border:5px solid #000;"></div>
      <div style="position:absolute;left:${cx - c.w / 2}px;top:${860 - h}px;width:${c.w}px;height:${h}px;">${c.html.replace(/left:0px;top:0px;/, "left:0;top:0;")}</div>`;
  const name = s.name ?? castName(video, s.who);
  const ns2 = fit(name, 700, 84, 40);
  html += card(ns, "name", name, { left: cx - 380, top: 60, width: 760, bg: C.white, size: ns2, rot: -3 });
  if (s.tag) html += `<div class="${ns}-card ${ns}-up" id="${ns}-tag" style="left:${cx - 220}px;top:${60 + ns2 * 1.2 + 50}px;width:440px;background:#000;color:#fff;font-size:30px;text-align:center;border-color:#000;box-shadow:6px 6px 0 ${C.yellow};">${esc(s.tag)}</div>`;
  let js = `      tl.fromTo(q("#${ns}-spot"), { scale: 0 }, { scale: 1, duration: 0.5, ease: "back.out(1.4)", immediateRender: false }, ${r3(Math.max(0.05, t0 - 0.25))});
      tl.fromTo(q("#${ns}-c"), { y: 700 }, { y: 0, duration: 0.55, ease: "back.out(1.3)", immediateRender: false }, ${r3(t0)});
      STAMP(q("#${ns}-name"), ${r3(t0 + 0.35)}, -3);\n`;
  if (s.tag) js += `      SLIDE(q("#${ns}-tag"), ${r3(t0 + 0.7)}, 0, 40, 0.35);\n`;
  const fx0 = right ? 100 : 1000;
  facts.forEach((f, i) => {
    const sz = fit(f.text, 760, 52, 28, 2);
    html += `<div class="${ns}-card" id="${ns}-f${i}" style="left:${fx0 + (i % 2) * 40}px;top:${300 + i * 185}px;width:820px;background:${color(f.color, i + 1)};font-size:${sz}px;transform:rotate(${i % 2 ? 1 : -1}deg);">${esc(f.text)}</div>`;
    js += `      POP(q("#${ns}-f${i}"), ${tf[i]}, { from: 0.6, r: ${i % 2 ? 1 : -1} });\n`;
  });
  const speak = s.speaks ? `      FLAP("${ns}-c", ${JSON.stringify(cues.spans(t0, dur))});\n` : "";
  js += speak + `      BOB(q("#${ns}-c-bob"), ${r3(t0 + 0.6)}, ${r3(dur - 0.2)}, 4);\n`;
  const css = `#${ns}-spot, #${ns}-name, #${ns}-tag { opacity: 0; } #${ns}-spot { opacity: 1; transform: scale(0); }`;
  return { css, html, js, sfx: [fx("whooshShort", t0, 0.3), fx("pop", t0 + 0.35, 0.3), ...tf.map((t) => fx("click", t, 0.25))], bg: s.bg || "paper" };
}

// ---------------------------------------------------------------- talk (two characters, speech bubbles)
function talk(ctx) {
  const { scene: s, ns, cues, dur, video } = ctx;
  const lines = (s.lines || []).slice(0, 4);
  const tt = times(cues, lines, 0.6, dur * 0.8);
  const h = 560;
  const L = charBox(video, s.left, { ns: `${ns}-a`, left: 200, top: 880 - h, h, pose: s.left_pose });
  const R0 = charBox(video, s.right, { ns: `${ns}-b`, left: 0, top: 880 - h, h, pose: s.right_pose, flip: s.flip_right !== false });
  const R = { ...R0, html: R0.html.replace("left:0px;", `left:${1720 - R0.w}px;`) };
  let html = L.html + R.html;
  html += card(ns, "na", s.left_name ?? castName(video, s.left), { left: 150, top: 820, width: 520, bg: C.yellow, size: 40 });
  html += card(ns, "nb", s.right_name ?? castName(video, s.right), { left: 1250, top: 820, width: 520, bg: C.blue, size: 40 });
  let js = `      SLIDE(q("#${ns}-a"), 0.05, -600, 0, 0.55);
      SLIDE(q("#${ns}-b"), 0.15, 600, 0, 0.55);
      STAMP(q("#${ns}-na"), 0.45, -2); STAMP(q("#${ns}-nb"), 0.55, 2);\n`;
  let sfx = [];
  lines.forEach((l, i) => {
    const side = l.who === s.right ? "b" : "a";
    const sz = fit(l.text, 720, 58, 30, 3);
    const left = side === "a" ? 560 : 520;
    html += `<div id="${ns}-q${i}" style="position:absolute;left:${left}px;top:${90}px;width:840px;">
        <div class="${ns}-card" style="position:relative;background:${side === "a" ? C.cream : C.white};border-radius:40px;font-size:${sz}px;padding:30px 40px 24px;text-align:center;">${esc(l.text)}</div>
        <svg viewBox="0 0 100 80" style="position:absolute;${side === "a" ? "left:60px" : "right:60px"};bottom:-62px;width:100px;height:70px;overflow:visible"><path d="${side === "a" ? "M20 0 L0 70 L60 0 Z" : "M80 0 L100 70 L40 0 Z"}" fill="${side === "a" ? C.cream : C.white}" stroke="#000" stroke-width="5" stroke-linejoin="round"/></svg></div>`;
    const end = i < lines.length - 1 ? tt[i + 1] - 0.15 : null;
    js += `      POP(q("#${ns}-q${i}"), ${tt[i]}, { from: 0.5 });\n`;
    if (end) js += `      OUT(q("#${ns}-q${i}"), ${r3(end)}, 0.15);\n`;
    js += `      FLAP("${ns}-${side}", ${JSON.stringify(cues.spans(tt[i], end ?? dur))});\n`;
    js += `      tl.to(q("#${ns}-${side}-bob"), { y: -14, duration: 0.18, ease: "power2.out" }, ${tt[i]}); tl.to(q("#${ns}-${side}-bob"), { y: 0, duration: 0.3, ease: "bounce.out" }, ${r3(tt[i] + 0.18)});\n`;
    sfx.push(fx("pop", tt[i], 0.25));
  });
  const css = `#${ns}-na, #${ns}-nb { opacity: 0; }`;
  return { css, html, js, sfx, bg: s.bg || "paper" };
}

// ---------------------------------------------------------------- group (lineup)
function group(ctx) {
  const { scene: s, ns, cues, dur, video } = ctx;
  const m = (s.members || []).slice(0, 6);
  const tt = times(cues, m, 0.5, dur * 0.75);
  const h = [0, 560, 540, 500, 440, 380, 330][m.length] || 330;
  const top0 = s.title ? 180 : 120;
  let html = "", js = "", sfx = [];
  if (s.title) {
    const ts = fit(s.title, 1300, 72, 36);
    html += card(ns, "title", s.title, { left: 310, top: 40, width: 1300, bg: color(s.color, 0), size: ts, rot: -1 });
    js += `      STAMP(q("#${ns}-title"), 0.15, -1);\n`;
  }
  const slot = 1800 / m.length;
  m.forEach((p, i) => {
    const c = charBox(video, p.who, { ns: `${ns}-m${i}`, left: 0, top: 0, h, pose: p.pose });
    const cx = 60 + slot * (i + 0.5);
    html += `<div style="position:absolute;left:${r3(cx - c.w / 2)}px;top:${780 - h}px;width:${c.w}px;height:${h}px;">${c.html.replace(/left:0px;top:0px;/, "left:0;top:0;")}</div>`;
    const name = p.name ?? castName(video, p.who);
    const sz = fit(name, slot - 50, 44, 22);
    html += card(ns, `n${i}`, name, { left: r3(cx - (slot - 30) / 2), top: 790, width: r3(slot - 30), bg: color(p.color, i), size: sz, rot: i % 2 ? 2 : -2, extra: "padding:10px 10px 6px;" });
    js += `      tl.fromTo(q("#${ns}-m${i}"), { y: 500, opacity: 0 }, { y: 0, opacity: 1, duration: 0.5, ease: "back.out(1.4)", immediateRender: false }, ${tt[i]});
      STAMP(q("#${ns}-n${i}"), ${r3(tt[i] + 0.25)}, ${i % 2 ? 2 : -2});\n`;
    sfx.push(fx("pop", tt[i], 0.28));
  });
  const css = m.map((_, i) => `#${ns}-m${i}, #${ns}-n${i}`).join(", ") + (m.length ? ` { opacity: 0; }` : "");
  return { css, html, js, sfx, bg: s.bg || "paper" };
}

// ---------------------------------------------------------------- timeline
function timeline(ctx) {
  const { scene: s, ns, cues, dur } = ctx;
  const ev = (s.events || []).slice(0, 5);
  const tt = times(cues, ev, 0.6, dur * 0.85);
  const y = 470, x0 = 160, x1 = 1760;
  let html = "", js = "", sfx = [];
  if (s.title) {
    const ts = fit(s.title, 1300, 68, 36);
    html += card(ns, "title", s.title, { left: 310, top: 50, width: 1300, bg: color(s.color, 4), size: ts, rot: -1 });
    js += `      STAMP(q("#${ns}-title"), 0.1, -1);\n`;
  }
  html += `<svg style="position:absolute;left:0;top:0;width:1920px;height:1080px;overflow:visible" viewBox="0 0 1920 1080"><path id="${ns}-line" d="M${x0} ${y} L${x1} ${y}" stroke="#000" stroke-width="14" stroke-linecap="round" fill="none"/></svg>`;
  const xs = ev.map((_, i) => (ev.length === 1 ? (x0 + x1) / 2 : x0 + 120 + ((x1 - x0 - 240) * i) / (ev.length - 1)));
  const lw = Math.min(400, (x1 - x0) / Math.max(1, ev.length) + 40);
  // the line grows to each marker as it's named
  js += `      tl.fromTo(q("#${ns}-line"), { attr: { d: "M${x0} ${y} L${x0} ${y}" } }, { attr: { d: "M${x0} ${y} L${r3(xs[0] ?? x1)} ${y}" }, duration: 0.5, ease: "power2.out", immediateRender: false }, ${r3(Math.max(0.05, (tt[0] ?? 0.6) - 0.5))});\n`;
  ev.forEach((e, i) => {
    const above = i % 2 === 0;
    const ws = fit(e.when, lw - 30, 64, 30);
    const ts = fit(e.text, lw - 30, 40, 22, 3);
    html += `<div id="${ns}-d${i}" style="position:absolute;left:${r3(xs[i] - 30)}px;top:${y - 30}px;width:60px;height:60px;border-radius:50%;background:${color(e.color, i)};border:6px solid #000;"></div>
      <div id="${ns}-e${i}" style="position:absolute;left:${r3(xs[i] - lw / 2)}px;${above ? `bottom:${1080 - y + 60}px` : `top:${y + 60}px`};width:${lw}px;text-align:center;">
        <div class="${ns}-card ${ns}-up" style="position:relative;display:inline-block;background:#000;color:#fff;font-size:${ws}px;box-shadow:6px 6px 0 ${color(e.color, i)};">${esc(e.when)}</div>
        <div class="${ns}-card" style="position:relative;margin-top:16px;background:#fff;font-size:${ts}px;">${esc(e.text)}</div></div>`;
    if (i > 0) js += `      tl.to(q("#${ns}-line"), { attr: { d: "M${x0} ${y} L${r3(xs[i])} ${y}" }, duration: 0.45, ease: "power2.inOut" }, ${r3(tt[i] - 0.45)});\n`;
    js += `      POP(q("#${ns}-d${i}"), ${tt[i]}, { d: 0.3 });
      SLIDE(q("#${ns}-e${i}"), ${r3(tt[i] + 0.1)}, 0, ${above ? 50 : -50}, 0.4);\n`;
    sfx.push(fx("pop", tt[i], 0.28));
  });
  js += `      tl.to(q("#${ns}-line"), { attr: { d: "M${x0} ${y} L${x1} ${y}" }, duration: 0.5, ease: "power2.out" }, ${r3((tt.at(-1) ?? 0.6) + 0.5)});\n`;
  const css = ev.map((_, i) => `#${ns}-d${i}, #${ns}-e${i}`).join(", ") + (ev.length ? ` { opacity: 0; }` : "");
  let out = { css, html, js, sfx, bg: s.bg || "paper" };
  if (wantsCameo(s, false)) { const c = cameo(ctx, s.pose || "point", "left"); out.html += c.html; out.js += c.js; }
  return out;
}

// ---------------------------------------------------------------- list
function list(ctx) {
  const { scene: s, ns, cues, dur } = ctx;
  const items = (s.items || []).slice(0, 5);
  const tt = times(cues, items, 0.8, dur * 0.85);
  const cam = wantsCameo(s, true);
  const left = cam ? 480 : 260, width = cam ? 1340 : 1400;
  let html = "", js = "", sfx = [];
  const ts = fit(s.title || "", width - 60, 70, 36);
  if (s.title) {
    html += card(ns, "title", s.title, { left, top: 50, width, bg: color(s.color, 0), size: ts, rot: -1 });
    js += `      STAMP(q("#${ns}-title"), 0.15, -1);\n`;
  }
  const top = s.title ? 200 : 80, step = Math.min(150, (860 - top) / Math.max(1, items.length));
  items.forEach((it, i) => {
    const sz = fit(it.text, width - 200, step > 130 ? 54 : 44, 26, 2);
    html += `<div class="${ns}-card" id="${ns}-i${i}" style="left:${left}px;top:${r3(top + i * step)}px;width:${width}px;height:${Math.round(step - 22)}px;background:#fff;font-size:${sz}px;display:flex;align-items:center;gap:26px;padding:6px 28px 4px 0;">
        <span style="flex:none;align-self:stretch;width:${Math.round(step - 30)}px;background:${color(it.color, i + 1)};border-right:4px solid #000;display:flex;align-items:center;justify-content:center;font-size:${Math.round(step * 0.45)}px;padding-top:6px;">${it.icon ? esc(it.icon) : i + 1}</span><span>${esc(it.text)}</span></div>`;
    js += `      SLIDE(q("#${ns}-i${i}"), ${tt[i]}, 0, 60, 0.38);\n`;
    sfx.push(fx("click", tt[i], 0.3));
  });
  const out = { css: "", html, js, sfx, bg: s.bg || "paper" };
  if (cam) { const c = cameo(ctx, s.pose || "point", "left"); out.html += c.html; out.js += c.js; }
  return out;
}

// ---------------------------------------------------------------- stat
function stat(ctx) {
  const { scene: s, ns, cues, dur } = ctx;
  const t0 = cues.find(s.at, 0.5);
  const val = Number(s.value) || 0;
  const dec = s.decimals ?? (Number.isInteger(val) ? 0 : 1);
  const grp = s.grouping ?? !(Number.isInteger(val) && val >= 1000 && val <= 2100); // years read 1428, not 1.428
  const show = (v) => `${s.prefix || ""}${v.toLocaleString("vi-VN", { minimumFractionDigits: dec, maximumFractionDigits: dec, useGrouping: grp })}${s.suffix || ""}`;
  const txt = show(val), N = 16;
  const steps = Array.from({ length: N + 1 }, (_, k) => show(k === N ? val : val * (1 - (1 - k / N) ** 2))); // power2.out
  const sz = fit(txt, 1500, 260, 90, 1, 0.6);
  let html = `<div id="${ns}-rays" style="position:absolute;left:460px;top:-200px;width:1000px;height:1000px;border-radius:50%;opacity:0.35;background:repeating-conic-gradient(${color(s.color, 0)} 0deg 9deg, transparent 9deg 18deg);"></div>
      <div id="${ns}-num" style="position:absolute;left:0;width:1920px;top:${380 - sz * 0.6}px;text-align:center;font-weight:700;font-size:${sz}px;line-height:1.15;color:${color(s.color, 0)};-webkit-text-stroke:10px #000;paint-order:stroke fill;text-shadow:12px 12px 0 #000;display:grid;">${steps.map((v, k) => `<span id="${ns}-n${k}" style="grid-area:1/1;opacity:${k ? 0 : 1};">${esc(v)}</span>`).join("")}</div>`;
  const ls = fit(s.label || "", 1300, 64, 32, 2);
  if (s.label) html += card(ns, "label", s.label, { left: 310, top: 600, width: 1300, bg: "#fff", size: ls, rot: -1 });
  let js = `      tl.fromTo(q("#${ns}-rays"), { rotation: 0, scale: 0.5 }, { rotation: 30, scale: 1, duration: ${r3(dur)}, ease: "none" }, 0);
      tl.fromTo(q("#${ns}-num"), { scale: 0.3, opacity: 0 }, { scale: 1, opacity: 1, duration: 0.45, ease: "back.out(1.7)", immediateRender: false }, ${r3(t0)});
`;
  // số chạy = các nấc chồng lên nhau, bật tắt bằng tl.set opacity. Không dùng onUpdate: hyperframes tua với
  // suppressEvents nên onUpdate không chạy lúc chụp ảnh đối chiếu, self-verify lệch và cả chương bị render lại.
  for (let k = 1; k <= N; k++) {
    const tk = r3(t0 + (1.1 * k) / N);
    js += `      tl.set(q("#${ns}-n${k - 1}"), { opacity: 0 }, ${tk}); tl.set(q("#${ns}-n${k}"), { opacity: 1 }, ${tk});\n`;
  }
  if (s.label) js += `      STAMP(q("#${ns}-label"), ${r3(t0 + 0.6)}, -1);\n`;
  if (s.note) {
    const tn = cues.find(s.note.at, Math.min(dur - 1, t0 + 2));
    html += card(ns, "note", s.note.text, { left: 460, top: 760, width: 1000, bg: C.yellow, size: fit(s.note.text, 940, 44, 24, 2), rot: 1.5 });
    js += `      POP(q("#${ns}-note"), ${r3(tn)}, { from: 0.6, r: 1.5 });\n`;
  }
  const out = { css: `#${ns}-num, #${ns}-label { opacity: 0; }`, html, js, sfx: [fx("riser", Math.max(0, t0 - 0.6), 0.25), fx("impact", t0 + 1.1, 0.35)], bg: s.bg || "paper" };
  if (wantsCameo(s, false)) { const c = cameo(ctx, s.pose || "shock", "left"); out.html += c.html; out.js += c.js; }
  return out;
}

// ---------------------------------------------------------------- quote
function quote(ctx) {
  const { scene: s, ns, cues, dur } = ctx;
  const t0 = cues.find(s.at, 0.4);
  const sz = fit(s.text, 1280, 76, 34, 4, 0.55);
  let html = `<div id="${ns}-box" style="position:absolute;left:260px;top:150px;width:1400px;">
        <div class="${ns}-card" style="position:relative;background:#fff;font-size:${sz}px;padding:70px 80px 50px;text-align:center;font-style:italic;">${esc(s.text)}</div>
        <div style="position:absolute;left:-30px;top:-110px;font-size:300px;font-weight:700;color:${color(s.color, 0)};-webkit-text-stroke:8px #000;paint-order:stroke fill;line-height:1;">“</div></div>`;
  let js = `      POP(q("#${ns}-box"), ${r3(Math.min(t0, 0.6))}, { from: 0.7 });\n`;
  if (s.by) {
    html += card(ns, "by", "— " + s.by, { left: 960, top: 740, width: 700, bg: color(s.color, 1), size: fit(s.by, 640, 44, 24), rot: -2 });
    js += `      SLIDE(q("#${ns}-by"), ${r3(cues.find(s.by_at, t0 + 0.8))}, 200, 0, 0.4);\n`;
  }
  return { css: "", html, js, sfx: [fx("whooshShort", t0, 0.3)], bg: s.bg || "cream" };
}

// ---------------------------------------------------------------- versus
function versus(ctx) {
  const { scene: s, ns, cues, dur, video } = ctx;
  const sides = [s.left || {}, s.right || {}];
  const t0 = cues.find(s.at, 0.3);
  let html = "", js = "", sfx = [fx("impact", t0 + 0.4, 0.35)];
  sides.forEach((sd, k) => {
    const x = k ? 1000 : 80, w = 840;
    const ts = fit(sd.title || "", w - 60, 64, 32);
    html += card(ns, `t${k}`, sd.title || "", { left: x, top: 60, width: w, bg: color(sd.color, k ? 1 : 2), size: ts, rot: k ? 1.5 : -1.5 });
    js += `      SLIDE(q("#${ns}-t${k}"), ${r3(Math.min(t0, 0.4) + k * 0.2)}, ${k ? 400 : -400}, 0, 0.45);\n`;
    let top = 220;
    if (sd.who) {
      const c = charBox(video, sd.who, { ns: `${ns}-c${k}`, left: x + (w - 380 * 0.72) / 2, top: 200, h: 340, pose: sd.pose, flip: k === 1 });
      html += c.html;
      js += `      POP(q("#${ns}-c${k}"), ${r3(Math.min(t0, 0.4) + 0.3 + k * 0.2)}, { from: 0.4 });\n`;
      top = 560;
    }
    const pts = (sd.points || []).slice(0, sd.who ? 2 : 4);
    const tt = times(cues, pts, t0 + 1, dur * 0.85);
    pts.forEach((p, i) => {
      const sz = fit(p.text, w - 60, 44, 24, 2);
      html += `<div class="${ns}-card" id="${ns}-p${k}${i}" style="left:${x}px;top:${top + i * 150}px;width:${w}px;background:#fff;font-size:${sz}px;">${esc(p.text)}</div>`;
      js += `      SLIDE(q("#${ns}-p${k}${i}"), ${tt[i]}, 0, 50, 0.35);\n`;
      sfx.push(fx("click", tt[i], 0.25));
    });
  });
  html += `<div id="${ns}-vs" style="position:absolute;left:880px;top:380px;width:160px;height:160px;border-radius:50%;background:${C.red};border:6px solid #000;box-shadow:8px 8px 0 #000;display:flex;align-items:center;justify-content:center;font-size:70px;font-weight:700;color:#fff;padding-top:6px;">VS</div>`;
  js += `      POP(q("#${ns}-vs"), ${r3(t0 + 0.4)}, { r: -8 });\n`;
  return { css: `#${ns}-vs { opacity: 0; }`, html, js, sfx, bg: s.bg || "paper" };
}

// ---------------------------------------------------------------- place
function place(ctx) {
  const { scene: s, ns, cues, dur, video } = ctx;
  const t0 = cues.find(s.at, 0.4);
  let html = `<div id="${ns}-land" style="position:absolute;inset:0;">${landscape(s.kind || "village", ns)}</div>`;
  const nsz = fit(s.name, 1100, 96, 44);
  html += `<div id="${ns}-pin" style="position:absolute;left:${s.pin_x ?? 1180}px;top:${s.pin_y ?? 330}px;width:90px;height:130px;" data-layout-allow-overlap>
      <svg viewBox="0 0 90 130" style="width:100%;height:100%;overflow:visible"><path d="M45 128 C 20 80, 4 62, 4 42 A 41 41 0 0 1 86 42 C 86 62, 70 80, 45 128 Z" fill="${C.red}" stroke="#000" stroke-width="6"/><circle cx="45" cy="42" r="15" fill="#fff" stroke="#000" stroke-width="5"/></svg></div>`;
  html += card(ns, "name", s.name, { left: 160, top: 60, width: 1200, bg: "#fff", size: nsz, rot: -2 });
  if (s.sub) html += `<div class="${ns}-card ${ns}-up" id="${ns}-sub" style="left:220px;top:${60 + nsz * 1.2 + 50}px;background:#000;color:#fff;font-size:34px;box-shadow:6px 6px 0 ${C.yellow};">${esc(s.sub)}</div>`;
  let js = `      tl.fromTo(q("#${ns}-land"), { scale: 1.12 }, { scale: 1, duration: 1.4, ease: "power2.out" }, 0);
      tl.fromTo(q("#${ns}-pin"), { y: -500, opacity: 0 }, { y: 0, opacity: 1, duration: 0.5, ease: "bounce.out", immediateRender: false }, ${r3(t0)});
      STAMP(q("#${ns}-name"), ${r3(t0 + 0.3)}, -2);\n`;
  if (s.sub) js += `      SLIDE(q("#${ns}-sub"), ${r3(t0 + 0.7)}, -200, 0, 0.4);\n`;
  if (s.who) {
    const c = charBox(video, s.who, { ns: `${ns}-c`, left: s.who_x ?? 1500, top: 880 - 420, h: 420, pose: s.pose });
    html += c.html;
    js += `      SLIDE(q("#${ns}-c"), ${r3(cues.find(s.who_at, t0 + 1))}, 300, 0, 0.5);\n`;
  }
  const out = { css: `#${ns}-pin, #${ns}-name, #${ns}-sub { opacity: 0; }`, html, js, sfx: [fx("whoosh", t0, 0.3)], bg: s.bg || "blue" };
  if (wantsCameo(s, false)) { const c = cameo(ctx, s.pose_teo || "point", "left"); out.html += c.html; out.js += c.js; }
  return out;
}

// ---------------------------------------------------------------- moment (comic beat)
function moment(ctx) {
  const { scene: s, ns, cues, dur, video } = ctx;
  const t0 = cues.find(s.at, 0.5);
  let html = "", js = "";
  html += `<div id="${ns}-burst" style="position:absolute;left:460px;top:40px;width:1000px;height:800px;" data-layout-allow-overlap>
      <svg viewBox="0 0 1000 800" style="width:100%;height:100%"><polygon points="${burst(500, 400, 470, 360, 16)}" fill="${color(s.color, 0)}" stroke="#000" stroke-width="8" stroke-linejoin="round"/></svg></div>`;
  const whos = s.who ? [].concat(s.who) : [];
  whos.slice(0, 2).forEach((w, i) => {
    const h = 520;
    const c = charBox(video, w, { ns: `${ns}-c${i}`, left: whos.length > 1 ? (i ? 1180 : 260) : 720, top: 880 - h, h, pose: i ? s.pose2 : s.pose, flip: i === 1 });
    html += c.html;
    // nhân vật đứng sẵn từ đầu cảnh (cue của moment thường rơi muộn); chữ + burst mới chờ cue
    js += `      POP(q("#${ns}-c${i}"), ${r3(Math.max(0.05, Math.min(t0 - 0.6, 0.3) + i * 0.15))}, { from: 0.5 });\n`;
  });
  const ws = fit(s.word || "BÙM!", 900, 200, 80, 1, 0.66);
  html += `<div id="${ns}-word" style="position:absolute;left:0;width:1920px;top:${whos.length ? 60 : 300}px;text-align:center;font-weight:700;font-size:${ws}px;line-height:1.2;color:${C.yellow};-webkit-text-stroke:10px #000;paint-order:stroke fill;text-shadow:12px 12px 0 #000;transform:rotate(-6deg);" data-layout-allow-overlap>${esc(s.word || "BÙM!")}</div>`;
  js += `      tl.fromTo(q("#${ns}-burst"), { scale: 0, rotation: -30 }, { scale: 1, rotation: 0, duration: 0.35, ease: "back.out(2)", immediateRender: false }, ${r3(t0 - 0.05)});
      tl.fromTo(q("#${ns}-word"), { scale: 2.4, opacity: 0, rotation: -6 }, { scale: 1, opacity: 1, rotation: -6, duration: 0.3, ease: "power4.out", immediateRender: false }, ${r3(t0)});
      SHAKE(q("#${ns}-cam"), ${r3(t0 + 0.28)}, ${s.effect === "zoom" ? 4 : 14});\n`;
  // zoom trên lớp bọc riêng: tween chồng lên slow-zoom của #cam cho kết quả khác nhau khi tua liền và tua nhảy
  if (s.effect === "zoom") js += `      tl.fromTo(q("#${ns}-mz"), { scale: 1 }, { scale: 1.12, duration: 0.25, ease: "power3.out", immediateRender: false }, ${r3(t0)});
      tl.fromTo(q("#${ns}-mz"), { scale: 1.12 }, { scale: 1, duration: 0.7, ease: "power2.inOut", immediateRender: false }, ${r3(t0 + 0.4)});\n`;
  if (s.caption) {
    const tc = cues.find(s.caption.at, t0 + 1.2);
    html += card(ns, "cap", s.caption.text, { left: 460, top: 760, width: 1000, bg: "#fff", size: fit(s.caption.text, 940, 46, 24, 2), rot: 1 });
    js += `      POP(q("#${ns}-cap"), ${r3(tc)}, { from: 0.6, r: 1 });\n`;
  }
  if (s.effect === "zoom") html = `<div id="${ns}-mz" style="position:absolute;inset:0;transform-origin:50% 45%;">${html}</div>`;
  return { css: `#${ns}-word { opacity: 0; } #${ns}-burst { transform: scale(0); }`, html, js, sfx: [fx(s.sound || "impact", t0, 0.45)], bg: s.bg || "red" };
}
function burst(cx, cy, R, r, n) {
  const p = [];
  for (let i = 0; i < n * 2; i++) {
    const a = (Math.PI * i) / n - Math.PI / 2, rad = i % 2 ? r : R * (0.9 + 0.1 * ((i * 7) % 3) / 2);
    p.push(`${r3(cx + Math.cos(a) * rad)},${r3(cy + Math.sin(a) * rad * 0.82)}`);
  }
  return p.join(" ");
}

// ---------------------------------------------------------------- outro
function outro(ctx) {
  const { scene: s, ns, cues, dur, video } = ctx;
  const c = charBox(video, "teo", { ns: `${ns}-teo`, left: 160, top: 220, h: 660, pose: s.pose || "smug" });
  const tb = cues.find(s.bye_at, Math.max(0.5, dur - 2.2));
  let html = c.html, js = `      SLIDE(q("#${ns}-teo"), 0.05, 0, 600, 0.55);
      FLAP("${ns}-teo", ${JSON.stringify(cues.spans(0, dur))});
      BOB(q("#${ns}-teo-bob"), 0.6, ${r3(dur - 0.2)}, 5);\n`;
  if (s.next) {
    const tn = cues.find(s.next.at, 0.8);
    html += `<div class="${ns}-card ${ns}-up" id="${ns}-nk" style="left:820px;top:100px;background:#000;color:#fff;font-size:34px;box-shadow:6px 6px 0 ${C.yellow};">Tập sau</div>`;
    html += card(ns, "next", s.next.text, { left: 820, top: 190, width: 980, bg: C.blue, size: fit(s.next.text, 920, 64, 30, 2), rot: -1.5 });
    js += `      SLIDE(q("#${ns}-nk"), ${r3(tn)}, 300, 0, 0.35); STAMP(q("#${ns}-next"), ${r3(tn + 0.25)}, -1.5);\n`;
  }
  html += card(ns, "bye", s.bye || "Hẹn gặp lại!", { left: 820, top: 480, width: 980, bg: C.yellow, size: 96, rot: 2 });
  html += `<div class="${ns}-card ${ns}-up" id="${ns}-sub" style="left:1080px;top:690px;width:460px;background:${C.red};color:#fff;font-size:40px;text-align:center;border-radius:9999px;">Đăng ký kênh</div>`;
  js += `      STAMP(q("#${ns}-bye"), ${r3(tb)}, 2);
      POP(q("#${ns}-sub"), ${r3(tb + 0.4)}, { from: 0.4 });
      [1.06, 1, 1.06, 1].forEach(function (k, i) { tl.to(q("#${ns}-sub"), { scale: k, duration: 0.25, ease: "sine.inOut" }, ${r3(tb + 1)} + i * 0.25); });\n`;
  return { css: `#${ns}-bye, #${ns}-sub { opacity: 0; }`, html, js, sfx: [fx("chime", tb, 0.35)], bg: s.bg || "yellow" };
}

// ---------------------------------------------------------------- custom (hand-made per video)
// "type": "custom", "file": "scenes/<name>.mjs" in the video dir. make.mjs imports it beforehand into s.__mod;
// its default export gets (ctx, kit) and returns { css, html, js, sfx, bg } like any template.
export const KIT_API = { C, esc, r3, color, pastel, fit, charBox, castName, times, isDark, sfx: fx, cameo };
function custom(ctx) {
  const s = ctx.scene;
  if (typeof s.__mod !== "function") throw new Error(`custom scene needs "file" exporting a default function (${s.file})`);
  const r = s.__mod(ctx, KIT_API) || {};
  const out = { css: r.css || "", html: r.html || "", js: r.js || "", sfx: r.sfx || [], bg: r.bg || s.bg || "paper" };
  if (wantsCameo(s, false)) { const c = cameo(ctx, s.pose || "talk", "left"); out.html += c.html; out.js += c.js; }
  return out;
}

export const TEMPLATES = { hook, chapter, narrator, intro, talk, group, timeline, list, stat, quote, versus, place, moment, outro, custom };
