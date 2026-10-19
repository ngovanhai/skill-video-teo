// In-page runtime for teo-kiem-hiep episodes. build.mjs injects `const RIG = {...}; const SEED = n;` before this file
// and the generated beat code after it. All times are absolute seconds on the root timeline.
window.__timelines = window.__timelines || {};
const tl = gsap.timeline({ paused: true });
window.__timelines["main"] = tl;
let __sd = SEED;
const rand = () => (__sd = (__sd * 16807) % 2147483647) / 2147483647;
const NF = { immediateRender: false };
const PIV = {
  teo: { armF: "272 305", foreF: "318 410", armB: "128 305", foreB: "108 420", legL: "167 545", legR: "233 545", head: "200 262", eyes: "200 178", tail: "122 158", all: "200 740" },
  npc: { armF: "140 150", armB: "62 150", legL: "82 222", legR: "118 222", head: "100 148", eyes: "100 115", all: "100 290" },
};
const org = (id) => { const i = id.lastIndexOf("-"); return PIV[RIG[id.slice(0, i)] || "teo"][id.slice(i + 1)]; };
const $id = (id) => document.getElementById(id);
const R = (id, deg, t, dur = 0.3, ease = "power2.inOut") => { if ($id(id)) tl.to("#" + id, { rotation: deg, svgOrigin: org(id), duration: dur, ease }, t); };
const RS = (id, deg) => { if ($id(id)) gsap.set("#" + id, { rotation: deg, svgOrigin: org(id) }); };
const ATTR = (id, t, o) => { if ($id(id)) tl.set("#" + id, { attr: { opacity: o } }, t); };
const FLAP = (p, t0, t1) => { for (let t = t0; t < t1 - 0.1; t += 0.3) { ATTR(p + "-mo", t, 1); ATTR(p + "-mc", t, 0); ATTR(p + "-mo", t + 0.15, 0); ATTR(p + "-mc", t + 0.15, 1); } };
const BLINK = (p, t) => { const id = p + "-eyes"; tl.to("#" + id, { scaleY: 0.1, svgOrigin: org(id), duration: 0.06 }, t).to("#" + id, { scaleY: 1, svgOrigin: org(id), duration: 0.08 }, t + 0.1); };
const BROW = (p, t, angry) => { ATTR(p + "-browN", t, angry ? 0 : 1); ATTR(p + "-browA", t, angry ? 1 : 0); };
const KO = (p, t, on = true) => { ATTR(p + "-face", t, on ? 0 : 1); ATTR(p + "-ko", t, on ? 1 : 0); };
const POP = (sel, t, extra = {}) => tl.fromTo(sel, { scale: 0, opacity: 0 }, { scale: 1, opacity: 1, duration: 0.45, ease: "back.out(2.2)", ...NF, ...extra }, t);
const STAMP = (sel, t, rotTo = -6) => tl.fromTo(sel, { scale: 2.8, opacity: 0, rotation: rotTo - 10 }, { scale: 1, opacity: 1, rotation: rotTo, duration: 0.26, ease: "power4.in", ...NF }, t);
const SHOW = (sel, t, dur = 0.25, from = {}) => tl.fromTo(sel, { opacity: 0, ...from }, { opacity: 1, x: 0, y: 0, duration: dur, ease: "power2.out", ...NF }, t);
const HIDE = (sel, t, dur = 0.2) => tl.to(sel, { opacity: 0, duration: dur }, t);
const FLASH = (t, peak = 0.9, dur = 0.4, color = "#ffffff") => { tl.set("#X-flash", { backgroundColor: color }, t); tl.fromTo("#X-flash", { opacity: peak }, { opacity: 0, duration: dur, ease: "power2.out", ...NF }, t); };
const SHAKE = (sel, t, dur, amp) => { const n = Math.max(1, Math.round(dur / 0.04)); for (let k = 0; k < n; k++) { const f = 1 - k / n; tl.to(sel, { x: (rand() - 0.5) * 2 * amp * f, y: (rand() - 0.5) * 2 * amp * f, duration: 0.04, ease: "none" }, t + k * 0.04); } tl.to(sel, { x: 0, y: 0, duration: 0.04 }, t + n * 0.04); };
const RUN = (p, t0, t1, bob, arms = true, amp = 28, step = 0.14) => {
  let k = 0;
  for (let t = t0; t < t1 - 1e-6; t += step, k++) {
    const a = k % 2 ? amp : -amp;
    R(p + "-legL", a, t, step, "sine.inOut"); R(p + "-legR", -a, t, step, "sine.inOut");
    if (arms) { R(p + "-armF", -a * 0.7, t, step, "sine.inOut"); R(p + "-armB", -a * 0.7, t, step, "sine.inOut"); }
  }
  ["legL", "legR"].concat(arms ? ["armF", "armB"] : []).forEach((part) => R(p + "-" + part, 0, t1, 0.15));
  if (bob && k) tl.to(bob, { y: -14, duration: step / 2, yoyo: true, repeat: 2 * k - 1, ease: "sine.out" }, t0);
};
// poses: [armF, foreF, armB] for Tèo; [armF, armB] for npc
const POSES = {
  teo: { rest: [0, 0, 0], raise: [-66, 41, 20], windup: [-146, 41, 30], slash: [-36, 121, -10], point: [-80, 110, 0], guard: [-30, 60, 40], wave: [-106, 71, 0], palm: [-60, 120, 30], up: [-150, 70, 60] },
  npc: { rest: [0, 0], raise: [-40, 20], windup: [-120, 30], slash: [-10, -20], point: [-70, 0], guard: [-30, 30], palm: [-75, 20], up: [-150, 40] },
};
const POSE = (p, name, t, dur = 0.3, ease = "back.out(1.6)") => {
  const type = RIG[p] || "teo", v = POSES[type][name] || POSES[type].rest;
  if (type === "teo") { R(p + "-armF", v[0], t, dur, ease); R(p + "-foreF", v[1], t, dur, ease); R(p + "-armB", v[2], t, dur, ease); }
  else { R(p + "-armF", v[0], t, dur, ease); R(p + "-armB", v[1], t, dur, ease); }
};
const DRAW = (sel, t, dur = 0.4, ease = "power2.out") => tl.to(sel, { strokeDashoffset: 0, duration: dur, ease }, t);
// length-based dash for paths too wide for pathLength=1 dashing (Chrome drops partial dashes on very wide strokes)
const DASHLEN = (id) => { const el = $id(id); if (!el) return; el.removeAttribute("pathLength"); const L = Math.ceil(el.getTotalLength()) + 10; el.setAttribute("stroke-dasharray", L + " " + L * 2); el.setAttribute("stroke-dashoffset", L); };
