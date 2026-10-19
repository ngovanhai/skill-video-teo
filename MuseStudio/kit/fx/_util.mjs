// Shared helpers for fx modules. An fx is { id, cat, label, run(ctx, o) } and run returns any of
// { back, over, css, js, sfx, cam }:
//   back = html behind the scene, over = html on top of it, js = code on the scene timeline `tl`
//   (runtime: q, qa, POP, STAMP, SLIDE, FADE, OUT, DRAW, SHAKE, …), sfx = [{file, t, vol}],
//   cam = true when the fx moves #<ns>-fxcam (camera fx).
// ctx = { video, scene, ns, cues, dur, id } where id is a unique prefix for this fx instance.
// Rules: everything starts hidden (opacity 0 / scale 0) and appears at its time; keep accents above y 880.
import { r3 } from "../lib/base.mjs";
export { C, esc, r3, color, fit } from "../lib/base.mjs";
export { fx as sfx } from "../scenes/index.mjs";

// deterministic random per fx instance, so a rebuild gives the same frames
export function rng(seed) {
  let h = 2166136261;
  for (const ch of String(seed)) h = Math.imul(h ^ ch.charCodeAt(0), 16777619);
  return () => {
    h += 0x6d2b79f5;
    let x = h;
    x = Math.imul(x ^ (x >>> 15), x | 1);
    x ^= x + Math.imul(x ^ (x >>> 7), x | 61);
    return ((x ^ (x >>> 14)) >>> 0) / 4294967296;
  };
}

// start time / length of an fx inside its scene: `at` (cue phrase) or `t` (seconds), `d` (seconds)
export function when(ctx, o, fallback = 0.1) {
  const t = r3(Math.max(0, Math.min(ctx.dur - 0.3, ctx.cues.find(o.at, o.t ?? fallback))));
  const d = r3(Math.max(0.3, Math.min(o.d ?? ctx.dur - t, ctx.dur - t)));
  return { t, d, end: r3(t + d) };
}

// full-frame layer that never blocks layout checks
export const layer = (id, inner, style = "") =>
  `<div id="${id}" style="position:absolute;inset:0;pointer-events:none;${style}" data-layout-allow-overlap>${inner}</div>`;

// GSAP `repeat` count so a loop of length `p` covers `d` seconds
export const reps = (d, p) => Math.max(0, Math.ceil(d / p) - 1);
