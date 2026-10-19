// Shared pieces for every scene template: escaping, cast SVG loading, cue timing, palette,
// and the wrapper that turns a template's {css, html, js} into a HyperFrames sub-composition.
import { readFileSync, existsSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";

export const KIT = join(dirname(fileURLToPath(import.meta.url)), "..");

export const C = {
  ink: "#000000", paper: "#FFFDF5", dark: "#111111",
  pink: "#FE90E8", blue: "#C0F7FE", green: "#99E885", yellow: "#F7CB46", cream: "#FFDC8B",
  red: "#FE3D7F", white: "#FFFFFF",
};
export const PASTELS = [C.yellow, C.blue, C.pink, C.green, C.cream];
export const pastel = (i) => PASTELS[((i % PASTELS.length) + PASTELS.length) % PASTELS.length];
export const color = (v, i = 0) => (v && C[v]) || (v && v.startsWith("#") ? v : pastel(i));

export const esc = (s) =>
  String(s ?? "").replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;").replace(/"/g, "&quot;");
export const r3 = (x) => Math.round(x * 1000) / 1000;

export const norm = (w) => String(w).normalize("NFC").toLowerCase().replace(/[^\p{L}\p{N}]/gu, "");

// ---------- cast ----------
// cast entry: { svg: "narrator" | "library/<name>" | "<path relative to the video dir>", name, pose? }
export function castSvg(video, who, pose, ns) {
  const entry = video.cast?.[who];
  if (!entry) throw new Error(`cast "${who}" is not defined in video.json`);
  let file;
  if (entry.svg === "narrator") file = join(KIT, "chars", "narrator", `teo-${pose || entry.pose || "talk"}.svg`);
  else if (entry.svg.startsWith("library/")) file = join(KIT, "chars", entry.svg + (entry.svg.endsWith(".svg") ? "" : ".svg"));
  else file = join(video.__dir, entry.svg);
  if (!existsSync(file)) throw new Error(`svg for "${who}" not found: ${file}`);
  let s = readFileSync(file, "utf8").replace(/<\?xml[^>]*>/, "").replace(/<!--[\s\S]*?-->/g, "").trim();
  // namespace ids so several inlined SVGs never collide
  s = s.replace(/\bid="([^"]+)"/g, `id="${ns}-$1"`)
    .replace(/url\(#([^)]+)\)/g, `url(#${ns}-$1)`)
    .replace(/href="#([^"]+)"/g, `href="#${ns}-$1"`);
  // the wrapper sizes it; drop fixed width/height so it scales to its box
  s = s.replace(/<svg([^>]*?)\swidth="[^"]*"/, "<svg$1").replace(/<svg([^>]*?)\sheight="[^"]*"/, "<svg$1");
  s = s.replace(/<svg/, `<svg preserveAspectRatio="xMidYMax meet" style="width:100%;height:100%;display:block;overflow:visible"`);
  return { svg: s, hasMouth: s.includes(`id="${ns}-mouth-open"`), aspect: viewBoxAspect(s) };
}
function viewBoxAspect(s) {
  const m = s.match(/viewBox="\s*[-\d.]+\s+[-\d.]+\s+([\d.]+)\s+([\d.]+)/);
  return m ? +m[1] / +m[2] : 300 / 420;
}
export const castName = (video, who) => video.cast?.[who]?.name ?? who;

// ---------- timing ----------
// A scene carries its aligned words (scene-local seconds). `at` is a phrase from the narration;
// cues resolve in order, each searched after the previous one, so repeated words land correctly.
export class Cues {
  constructor(words, dur) {
    this.words = words || [];
    this.dur = dur;
    this.cursor = 0;
    this.tokens = this.words.map((w) => norm(w.text));
  }
  find(phrase, fallback) {
    if (phrase == null || phrase === "") return fallback;
    if (typeof phrase === "number") return phrase;
    const p = String(phrase).split(/\s+/).map(norm).filter(Boolean);
    if (!p.length) return fallback;
    const search = (from) => {
      for (let i = from; i <= this.tokens.length - p.length; i++) {
        let ok = true;
        for (let k = 0; k < p.length; k++) if (this.tokens[i + k] !== p[k]) { ok = false; break; }
        if (ok) return i;
      }
      return -1;
    };
    let i = search(this.cursor);
    if (i < 0) i = search(0);
    if (i < 0) {
      console.warn(`  ! cue "${phrase}" not found in narration — using fallback ${fallback?.toFixed?.(2)}`);
      return fallback;
    }
    this.cursor = i + p.length;
    return this.words[i].start;
  }
  // time when the word after a phrase ends (for strikes / exits)
  end() { return this.dur; }
  // spread n cues evenly across [a, b] when the author gave none
  spread(n, a = 0.4, b = this.dur * 0.8) {
    return Array.from({ length: n }, (_, i) => a + ((b - a) * i) / Math.max(1, n - 1 || 1));
  }
  // word spans [start, end] inside [a, b] — drives mouth flaps
  spans(a = 0, b = Infinity) {
    return this.words.filter((w) => w.start >= a - 0.01 && w.start < b).map((w) => [r3(w.start), r3(w.end)]);
  }
}

// resolve a list of items with optional `at` into times, falling back to an even spread
export function times(cues, items, a, b) {
  const fb = cues.spread(items.length, a, b);
  let last = -1;
  return items.map((it, i) => {
    let t = cues.find(it?.at, fb[i]);
    if (t <= last) t = last + 0.25;
    last = t;
    return r3(t);
  });
}

// ---------- runtime helpers (inlined into each scene script) ----------
export const RUNTIME = `
      var POP = function (el, t, o) { o = o || {}; tl.fromTo(el, { scale: o.from || 0, rotation: o.rf || 0, opacity: 0 }, { scale: 1, rotation: o.r || 0, opacity: 1, duration: o.d || 0.4, ease: "back.out(1.7)", immediateRender: false }, t); };
      var STAMP = function (el, t, r) { tl.fromTo(el, { scale: 1.35, rotation: (r || 0) + 4, opacity: 0 }, { scale: 1, rotation: r || 0, opacity: 1, duration: 0.32, ease: "back.out(1.6)", immediateRender: false }, t); };
      var SLIDE = function (el, t, x, y, d) { tl.fromTo(el, { x: x || 0, y: y || 0, opacity: 0 }, { x: 0, y: 0, opacity: 1, duration: d || 0.55, ease: "power3.out", immediateRender: false }, t); };
      var FADE = function (el, t, d) { tl.fromTo(el, { opacity: 0 }, { opacity: 1, duration: d || 0.4, ease: "power1.out", immediateRender: false }, t); };
      var OUT = function (el, t, d) { tl.to(el, { opacity: 0, scale: 0.92, duration: d || 0.25, ease: "power2.in" }, t); };
      var DRAW = function (el, t, d) { tl.fromTo(el, { strokeDashoffset: 1 }, { strokeDashoffset: 0, duration: d || 0.5, ease: "power2.inOut", immediateRender: false }, t); };
      var FLAP = function (ns, spans) {
        var mo = q("#" + ns + "-mouth-open"), mc = q("#" + ns + "-mouth-closed");
        if (!mo || !mc) return;
        tl.set(mo, { attr: { opacity: 0 } }, 0); tl.set(mc, { attr: { opacity: 1 } }, 0);
        for (var w = 0; w < spans.length; w++) {
          for (var t = spans[w][0]; t < spans[w][1] - 0.04; t += 0.15) {
            tl.set(mo, { attr: { opacity: 1 } }, t); tl.set(mc, { attr: { opacity: 0 } }, t);
            var tc = Math.min(t + 0.1, spans[w][1]);
            tl.set(mo, { attr: { opacity: 0 } }, tc); tl.set(mc, { attr: { opacity: 1 } }, tc);
          }
        }
      };
      var BOB = function (el, a, b, amp) {
        for (var t = a, k = 0; t < b - 0.3; t += 0.34, k++) tl.to(el, { y: k % 2 ? 0 : -(amp || 5), duration: 0.34, ease: "sine.inOut" }, t);
        tl.to(el, { y: 0, duration: 0.25, ease: "power2.out" }, Math.max(a, b - 0.3));
      };
      var SHAKE = function (el, t, amp) { var a = amp || 10; [a, -a, a * 0.6, -a * 0.6, 0].forEach(function (x, i) { tl.to(el, { x: x, duration: 0.05, ease: "none" }, t + i * 0.05); }); };`;

// ---------- grounds ----------
export function groundCss(kind, p) {
  const grid = (c) => `background-image: linear-gradient(${c} 2px, transparent 2px), linear-gradient(90deg, ${c} 2px, transparent 2px); background-size: 80px 80px; background-position: -2px -2px;`;
  switch (kind) {
    case "dark": return `background-color: ${C.dark}; ${grid("rgba(255,255,255,0.05)")}`;
    case "night": return `background: radial-gradient(ellipse at 50% 30%, #2A2D5A 0%, #12132A 70%);`;
    case "red": return `background-color: ${C.red}; ${grid("rgba(0,0,0,0.08)")}`;
    case "yellow": return `background-color: ${C.yellow}; ${grid("rgba(0,0,0,0.07)")}`;
    case "blue": return `background-color: ${C.blue}; ${grid("rgba(0,0,0,0.06)")}`;
    case "pink": return `background-color: ${C.pink}; ${grid("rgba(0,0,0,0.06)")}`;
    case "green": return `background-color: ${C.green}; ${grid("rgba(0,0,0,0.06)")}`;
    case "cream": return `background-color: ${C.cream}; ${grid("rgba(0,0,0,0.06)")}`;
    default: return `background-color: ${C.paper}; ${grid("rgba(0,0,0,0.07)")}`;
  }
}
export const isDark = (bg) => bg === "dark" || bg === "night";

// ---------- wrapper ----------
// tpl result: { css, html, js, bg?, sfx?: [{file, t, vol}] }
// fx layers (kit/fx): `back` sits behind the scene, `over` on top of it; with `fxcam` the scene + back layer
// are wrapped in #<ns>-fxcam so camera fx can move them without fighting the slow zoom on #<ns>-cam.
export function wrapScene({ id, ns, dur, bg = "paper", css, html, js, camera = true, back = "", over = "", fxcam = false }) {
  const D = r3(dur);
  return `<template id="${id}-template">
  <script src="https://cdn.jsdelivr.net/npm/gsap@3.14.2/dist/gsap.min.js"></script>
  <style>
    @font-face { font-family: "Inter"; src: url("assets/fonts/Inter-Variable.ttf") format("truetype"); font-weight: 100 900; font-style: normal; font-display: block; }
    @font-face { font-family: "Space Grotesk"; src: url("assets/fonts/Space_Grotesk-Variable.ttf") format("truetype"); font-weight: 300 700; font-style: normal; font-display: block; }
    #${ns}-root { position: absolute; inset: 0; width: 1920px; height: 1080px; overflow: hidden; font-family: "Space Grotesk", sans-serif; color: #000; }
    #${ns}-root * { box-sizing: border-box; }
    .${ns}-ground { position: absolute; inset: 0; ${groundCss(bg)} }
    .${ns}-cam { position: absolute; inset: 0; }
    .${ns}-card { position: absolute; border: 4px solid #000; box-shadow: 8px 8px 0 #000; padding: 14px 28px 10px; font-weight: 700; line-height: 1.2; }
    .${ns}-up { text-transform: uppercase; letter-spacing: -0.01em; }
    .${ns}-chr { position: absolute; }
    .${ns}-bob { position: absolute; inset: 0; }
${css}
  </style>
  <div id="${ns}-root" data-composition-id="${id}" data-width="1920" data-height="1080" data-start="0" data-duration="${D}">
    <div class="clip ${ns}-ground" id="${ns}-ground" data-start="0" data-duration="${D}" data-track-index="0"></div>
    <div class="clip ${ns}-cam" id="${ns}-cam" data-start="0" data-duration="${D}" data-track-index="1">
${fxcam ? `      <div id="${ns}-fxcam" style="position:absolute;inset:0;">\n${back}\n${html}\n      </div>\n${over}` : html}
    </div>
  </div>
  <script>
    (function () {
      var ID = ${JSON.stringify(id)};
      var root = document.querySelector('[data-composition-id="' + ID + '"]');
      var q = function (s) { return root.querySelector(s); };
      var qa = function (s) { return root.querySelectorAll(s); };
      var tl = gsap.timeline({ paused: true });
${RUNTIME}
${camera ? `      tl.fromTo(q("#${ns}-cam"), { scale: 1 }, { scale: 1.035, duration: ${D}, ease: "none", transformOrigin: "50% 45%" }, 0);` : ""}
${js}
      tl.set({}, {}, ${D});
      window.__timelines = window.__timelines || {};
      window.__timelines[ID] = tl;
    })();
  </script>
</template>
`;
}

// A character box: positioned wrapper > bob layer > inline svg. Returns html + the ns for mouth flaps.
export function charBox(video, who, { ns, cls, left, top, h, pose, flip = false, extraStyle = "" }) {
  const c = castSvg(video, who, pose, ns);
  const w = Math.round(h * c.aspect);
  return {
    w, h, hasMouth: c.hasMouth, ns,
    html: `<div class="${cls || ""} chr-box" id="${ns}" style="position:absolute;left:${left}px;top:${top}px;width:${w}px;height:${h}px;${extraStyle}">
        <div id="${ns}-bob" style="position:absolute;inset:0;"><div style="position:absolute;inset:0;${flip ? "transform:scaleX(-1);" : ""}">${c.svg}</div></div>
      </div>`,
  };
}

// Font size that keeps `text` inside `width` px on at most `lines` lines (uppercase display face).
export function fit(text, width, max, min = 28, lines = 1, k = 0.62) {
  const n = Math.max(1, [...String(text)].length);
  const longest = Math.max(...String(text).split(/\s+/).map((w) => [...w].length), 1);
  let s = max;
  while (s > min && (n * s * k > width * lines * 0.92 || longest * s * k > width * 0.98)) s -= 2;
  return s;
}
