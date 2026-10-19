// Builds avatar/watermark/index.html: YouTube video watermark (shown bottom-right on every video, doubles as a subscribe button).
// Tèo's head close-up in a ringed circle, rendered at 600x600; the outside of the circle is made transparent with ffmpeg afterwards.
// Snapshot: npx --yes hyperframes@0.8.172 snapshot avatar/watermark --at 0.5 --no-end -o avatar/shot --describe false
// Mask:     ffmpeg -y -i avatar/shot/frame-00-at-0.5s.png -vf "format=rgba,geq=r='r(X,Y)':g='g(X,Y)':b='b(X,Y)':a='if(lte(hypot(X-299.5,Y-299.5),299),255,0)'" avatar/teo-watermark.png
import { readFileSync, writeFileSync, mkdirSync, existsSync } from "fs";
import { fileURLToPath } from "url";
import { join } from "path";
const here = fileURLToPath(new URL(".", import.meta.url));
const out = join(here, "watermark");
mkdirSync(out, { recursive: true });
if (!existsSync(join(out, "package.json"))) writeFileSync(join(out, "package.json"), JSON.stringify({ name: "watermark", private: true, type: "module" }));
const teo = readFileSync(join(here, "teo.svgfrag"), "utf8");
const S = 2.1; // head fills most of the circle so it stays readable at 150px
const left = 300 - 200 * S, top = 285 - 180 * S; // head centre (200,180) → (300,285)
const html = `<!doctype html>
<html lang="vi"><head><meta charset="UTF-8" />
<script src="https://cdn.jsdelivr.net/npm/gsap@3.14.2/dist/gsap.min.js"></script>
<style>
  * { margin: 0; padding: 0; box-sizing: border-box; }
  html, body { width: 600px; height: 600px; overflow: hidden; background: #000; }
  #root { position: relative; width: 600px; height: 600px; overflow: hidden; }
</style></head>
<body>
<div id="root" data-composition-id="watermark" data-start="0" data-duration="1" data-width="600" data-height="600">
  <div class="clip" data-start="0" data-duration="1" data-track-index="0" style="position:absolute;inset:0;border-radius:50%;overflow:hidden;background:radial-gradient(circle at 50% 40%, #FFE066 0%, #F5B700 85%);">
    <div style="position:absolute;left:${left}px;top:${top}px;width:${500 * S}px;height:${760 * S}px;">${teo}</div>
    <div style="position:absolute;inset:0;border-radius:50%;border:28px solid #fff;box-shadow:inset 0 0 0 8px #000;"></div>
  </div>
</div>
<script>window.__timelines = window.__timelines || {}; window.__timelines["watermark"] = gsap.timeline({ paused: true }); window.__timelines["watermark"].set({}, {}, 1);</script>
</body></html>`;
writeFileSync(join(out, "index.html"), html);
console.log("avatar/watermark/index.html written");
