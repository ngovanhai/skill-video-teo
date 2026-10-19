// Builds avatar/index.html (800x800 HyperFrames composition) from Tèo's "talk" pose.
// Snapshot: npx --yes hyperframes@0.8.172 snapshot avatar --at 0.5 --no-end -o avatar/shot --describe false
import { readFileSync, writeFileSync } from "fs";
const dir = new URL(".", import.meta.url);
const teo = readFileSync(new URL("teo.svgfrag", dir), "utf8");
const S = 1.8; // scale: head (≈190px wide in svg) → ≈340px; waving hand stays inside YouTube's round crop
const left = 400 - 200 * S, top = 320 - 180 * S; // head centre (200,180) → (400,320)
const html = `<!doctype html>
<html lang="vi"><head><meta charset="UTF-8" />
<script src="https://cdn.jsdelivr.net/npm/gsap@3.14.2/dist/gsap.min.js"></script>
<style>
  @font-face { font-family: "Inter"; src: url("assets/fonts/Inter-Variable.ttf") format("truetype"); font-weight: 100 900; font-display: block; }
  * { margin: 0; padding: 0; box-sizing: border-box; }
  html, body { width: 800px; height: 800px; overflow: hidden; background: #000; }
  #root { position: relative; width: 800px; height: 800px; overflow: hidden; }
</style></head>
<body>
<div id="root" data-composition-id="avatar" data-start="0" data-duration="1" data-width="800" data-height="800">
  <div class="clip" data-start="0" data-duration="1" data-track-index="0" style="position:absolute;inset:0;background:radial-gradient(circle at 50% 42%, #FFE066 0%, #F5B700 80%);">
    <div style="position:absolute;left:-350px;top:-370px;width:1500px;height:1500px;border-radius:50%;opacity:0.28;background:repeating-conic-gradient(#fff 0deg 7deg, transparent 7deg 16deg);"></div>
    <div style="position:absolute;left:150px;top:120px;width:500px;height:500px;border-radius:50%;background:#FFF4C2;opacity:0.55;"></div>
    <div style="position:absolute;left:${left}px;top:${top}px;width:${500 * S}px;height:${760 * S}px;">${teo}</div>
  </div>
</div>
<script>window.__timelines = window.__timelines || {}; window.__timelines["avatar"] = gsap.timeline({ paused: true }); window.__timelines["avatar"].set({}, {}, 1);</script>
</body></html>`;
writeFileSync(new URL("index.html", dir), html);
console.log("avatar/index.html written");
