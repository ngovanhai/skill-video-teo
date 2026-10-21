// YouTube thumbnail (1280x720) as a one-second HyperFrames composition; `make.mjs thumb`
// snapshots it to thumbnail.png. Built for curiosity: a huge 2-line hook, one shocked character,
// a red circle/arrow on the mystery, a "?" badge.
import { C, esc, fit, castSvg, theme } from "./base.mjs";
// thumbnail.layout: "classic" (default: text left, hero right) | "split" (two faces off, VS badge, text on top)
//                   | "closeup" (hero's face huge on the right, text left)

export function thumbnailHtml(video) {
  const t = video.thumbnail || {};
  const bg = { red: [C.red, "#B3125A"], yellow: [C.yellow, "#E8A900"], dark: ["#2A2D5A", "#0B0C1E"], blue: ["#5B8DEF", "#1D3FA8"], green: ["#3FA34D", "#1E6B2A"] }[t.bg || "red"] || { purple: ["#8E5BEF", "#3A1D8A"], noir: ["#4A4A4A", "#0A0A0A"], teal: ["#2EC4B6", "#0E6B63"], orange: ["#FF9F1C", "#C2410C"] }[t.bg] || [C.red, "#B3125A"];
  const L = t.layout || "classic";
  const text = String(t.text || video.title || "").toUpperCase();
  const hi = String(t.highlight || "").toUpperCase();
  const words = text.split(/\s+/);
  // balanced 2 or 3 lines (long hooks get 3 so the letters stay huge)
  const nLines = L === "split" ? Math.min(2, words.length) : text.length > 24 && words.length >= 3 ? 3 : Math.min(2, words.length);
  const target = text.length / nLines;
  const lines = [];
  let cur = [];
  for (const w of words) {
    if (cur.length && lines.length < nLines - 1 && (cur.join(" ") + " " + w).length > target + 3) { lines.push(cur.join(" ")); cur = []; }
    cur.push(w);
  }
  lines.push(cur.join(" "));
  const whos = [].concat(t.who || []).slice(0, 2);
  const textW = L === "split" ? 1200 : L === "closeup" ? 700 : whos.length ? 800 : 1180;
  const size = Math.min(...lines.map((l) => fit(l, textW, 190, 70, 1, 0.6)));
  const key = (w) => w.normalize("NFC").replace(/[^\p{L}\p{N}]/gu, "");
  const hiSet = new Set(hi.split(/\s+/).map(key).filter(Boolean));
  const paint = (line) => esc(line).split(/\s+/).map((w) => (hiSet.has(key(w)) ? `<span style="color:${C.yellow}">${w}</span>` : w)).join(" ");
  const ringColor = t.bg === "yellow" ? C.red : t.bg === "red" || !t.bg ? C.yellow : C.red;
  const chars = L === "split" ? whos.map((w, i) => {
    const c = castSvg(video, w, i === 0 ? t.pose || "shock" : t.pose2, `th${i}`);
    const h = 540, wpx = Math.round(h * c.aspect);
    const left = i === 0 ? 30 : 1250 - wpx;
    return `<div style="position:absolute;left:${left}px;top:${720 - h + 130}px;width:${wpx}px;height:${h}px;z-index:3;${i ? "transform:scaleX(-1);" : ""}">${c.svg}</div>`;
  }).join("") : L === "closeup" ? whos.slice(0, 1).map((w) => {
    const c = castSvg(video, w, t.pose || "shock", "th0");
    const h = 1080, wpx = Math.round(h * c.aspect);
    return `<div style="position:absolute;left:${1280 - Math.round(wpx * 0.86)}px;top:-10px;width:${wpx}px;height:${h}px;z-index:3;">${c.svg}</div>`;
  }).join("") : whos.map((w, i) => {
    const c = castSvg(video, w, i === 0 ? t.pose || "shock" : t.pose2, `th${i}`);
    const h = i === 0 ? 760 : 560;
    const wpx = Math.round(h * c.aspect);
    const left = i === 0 ? 1280 - wpx + 40 : 1280 - wpx - 330;
    return `<div style="position:absolute;left:${left}px;top:${720 - h + 90}px;width:${wpx}px;height:${h}px;z-index:${3 - i};${i ? "filter:brightness(0.95);" : ""}">${c.svg}</div>`;
  }).join("");
  const badge = t.badge === false ? "" : `<div style="position:absolute;left:${L === "split" ? 555 : L === "closeup" ? 470 : whos.length ? 820 : 1060}px;top:${L === "split" ? 330 : L === "closeup" ? 330 : 40}px;width:170px;height:170px;border-radius:50%;background:${C.yellow};border:7px solid #000;box-shadow:9px 9px 0 #000;display:flex;align-items:center;justify-content:center;font-size:${L === "split" && !t.badge ? 96 : 140}px;font-weight:700;padding-top:10px;transform:rotate(12deg);z-index:6;">${esc(t.badge || (L === "split" ? "VS" : "?"))}</div>`;
  const ring = t.circle === false || (!whos.length && !t.prop) || (L !== "classic" && t.circle_x == null) ? "" : `<svg viewBox="0 0 400 400" style="position:absolute;left:${t.circle_x ?? 900}px;top:${t.circle_y ?? 140}px;width:${t.circle_r ?? 330}px;height:${t.circle_r ?? 330}px;z-index:5;overflow:visible"><ellipse cx="200" cy="200" rx="185" ry="175" fill="none" stroke="${ringColor}" stroke-width="22"/><ellipse cx="200" cy="200" rx="185" ry="175" fill="none" stroke="#000" stroke-width="5" transform="translate(8 8)" opacity="0.6"/></svg>`;
  const arrow = t.arrow === false || (L !== "classic" && t.arrow !== true) ? "" : `<svg viewBox="0 0 300 200" style="position:absolute;left:${whos.length ? 600 : 900}px;top:430px;width:300px;height:200px;z-index:6;overflow:visible;transform:rotate(-18deg)"><path d="M10 120 L190 120 L190 70 L290 140 L190 210 L190 160 L10 160 Z" fill="${C.yellow}" stroke="#000" stroke-width="8" stroke-linejoin="round"/></svg>`;
  // optional mystery object inside the ring (cast key, e.g. a sword svg)
  const R = t.circle_r ?? 330, cx = t.circle_x ?? 900, cy = t.circle_y ?? 140;
  const prop = t.prop ? `<div style="position:absolute;left:${cx + R * 0.15}px;top:${cy + R * 0.12}px;width:${R * 0.7}px;height:${R * 0.76}px;z-index:4;transform:rotate(${t.prop_rot ?? -12}deg);">${castSvg(video, t.prop, undefined, "thp").svg}</div>` : "";
  const pill = t.series ? `<div style="position:absolute;left:36px;top:30px;padding:10px 26px 6px;background:#000;color:#fff;font-size:32px;font-weight:700;text-transform:uppercase;border:4px solid #fff;z-index:6;">${esc(t.series)}</div>` : "";
  return `<!doctype html>
<html lang="vi"><head><meta charset="UTF-8" />
<script src="https://cdn.jsdelivr.net/npm/gsap@3.14.2/dist/gsap.min.js"></script>
<style>
  @font-face { font-family: "Space Grotesk"; src: url("assets/fonts/Space_Grotesk-Variable.ttf") format("truetype"); font-weight: 300 700; font-display: block; }
  @font-face { font-family: "Inter"; src: url("assets/fonts/Inter-Variable.ttf") format("truetype"); font-weight: 100 900; font-display: block; }
  * { margin: 0; padding: 0; box-sizing: border-box; }
  html, body { width: 1280px; height: 720px; overflow: hidden; background: #000; }
  #root { position: relative; width: 1280px; height: 720px; overflow: hidden; font-family: ${theme()?.font || `"Space Grotesk", sans-serif`}; }
</style></head>
<body>
<div id="root" data-composition-id="thumb" data-start="0" data-duration="1" data-width="1280" data-height="720">
  <div class="clip" data-start="0" data-duration="1" data-track-index="0" style="position:absolute;inset:0;background:radial-gradient(circle at 72% 45%, ${bg[0]} 0%, ${bg[1]} 75%);">
    <div style="position:absolute;left:300px;top:-400px;width:1500px;height:1500px;border-radius:50%;opacity:0.22;background:repeating-conic-gradient(#fff 0deg 7deg, transparent 7deg 16deg);"></div>
    ${chars}
    ${prop}${ring}
    <div style="position:absolute;left:40px;top:${t.series ? 110 : L === "split" ? 36 : 60}px;width:${textW}px;z-index:7;${L === "split" ? "text-align:center;" : ""}font-weight:700;font-size:${size}px;line-height:1.08;color:#fff;-webkit-text-stroke:${Math.round(size / 9)}px #000;paint-order:stroke fill;text-shadow:${Math.round(size / 14)}px ${Math.round(size / 14)}px 0 #000;letter-spacing:-0.02em;" data-layout-allow-overlap>
      ${lines.map((l) => `<div>${paint(l)}</div>`).join("")}
    </div>
    ${t.sub ? `<div style="position:absolute;left:40px;bottom:40px;padding:12px 26px 8px;background:${C.yellow};border:5px solid #000;box-shadow:7px 7px 0 #000;font-size:44px;font-weight:700;text-transform:uppercase;z-index:7;transform:rotate(-2deg);">${esc(t.sub)}</div>` : ""}
    ${badge}${arrow}${pill}
  </div>
</div>
<script>window.__timelines = window.__timelines || {}; window.__timelines["thumb"] = gsap.timeline({ paused: true }); window.__timelines["thumb"].set({}, {}, 1);</script>
</body></html>
`;
}
