// Builds avatar/banner/index.html: YouTube channel art (2560x1440) as a HyperFrames composition.
// Text-and-logo safe area (all devices) is the centred 1546x423 box: x 507–2053, y 508–931.
// Desktop shows the full-width band y 508–931; TV shows everything.
// Snapshot: npx --yes hyperframes@0.8.172 snapshot avatar/banner --at 0.5 --no-end -o avatar/shot --describe false
import { readFileSync, writeFileSync, mkdirSync, copyFileSync, readdirSync, existsSync } from "fs";
import { fileURLToPath } from "url";
import { join } from "path";
const here = fileURLToPath(new URL(".", import.meta.url));
const root = join(here, "..");
const out = join(here, "banner");
mkdirSync(join(out, "assets/fonts"), { recursive: true });
for (const f of readdirSync(join(root, "kit/fonts"))) copyFileSync(join(root, "kit/fonts", f), join(out, "assets/fonts", f));
if (!existsSync(join(out, "package.json"))) writeFileSync(join(out, "package.json"), JSON.stringify({ name: "banner", private: true, type: "module" }));

// inline an svg so it scales to its box (drop fixed width/height, keep viewBox)
const svg = (file) => readFileSync(join(root, file), "utf8")
  .replace(/<svg([^>]*?)\swidth="[^"]*"\sheight="[^"]*"/, "<svg$1")
  .replace("<svg", '<svg preserveAspectRatio="xMidYMax meet" style="width:100%;height:100%;display:block;overflow:visible"');
const put = (file, left, top, w, h, rot = 0) =>
  `<div style="position:absolute;left:${left}px;top:${top}px;width:${w}px;height:${h}px;transform:rotate(${rot}deg);">${svg(file)}</div>`;

// friends from past videos, kept outside the safe area (visible on desktop/TV, cropped on phones)
const friends = [
  put("videos/khung-long/chars/trex.svg", 30, 560, 260, 364, -4),
  put("videos/cay-lua/chars/thoc.svg", 250, 640, 200, 280, 6),
  put("videos/cau-vong/chars/giot.svg", 400, 560, 140, 196, -8),
  put("videos/ong-mat/chars/ongtho.svg", 2040, 540, 170, 238, 8),
  put("videos/cay-lua/chars/trau.svg", 2160, 630, 220, 308, -5),
  put("videos/cau-vong/chars/mattroi.svg", 2340, 530, 200, 280, 6),
].join("\n    ");

const chip = (t, bg) => `<span style="display:inline-block;padding:10px 20px 7px;margin-right:14px;background:${bg};border:5px solid #000;box-shadow:6px 6px 0 #000;font-size:34px;font-weight:700;">${t}</span>`;

const html = `<!doctype html>
<html lang="vi"><head><meta charset="UTF-8" />
<script src="https://cdn.jsdelivr.net/npm/gsap@3.14.2/dist/gsap.min.js"></script>
<style>
  @font-face { font-family: "Space Grotesk"; src: url("assets/fonts/Space_Grotesk-Variable.ttf") format("truetype"); font-weight: 300 700; font-display: block; }
  @font-face { font-family: "Inter"; src: url("assets/fonts/Inter-Variable.ttf") format("truetype"); font-weight: 100 900; font-display: block; }
  * { margin: 0; padding: 0; box-sizing: border-box; }
  html, body { width: 2560px; height: 1440px; overflow: hidden; background: #000; }
  #root { position: relative; width: 2560px; height: 1440px; overflow: hidden; font-family: "Space Grotesk", sans-serif; }
</style></head>
<body>
<div id="root" data-composition-id="banner" data-start="0" data-duration="1" data-width="2560" data-height="1440">
  <div class="clip" data-start="0" data-duration="1" data-track-index="0" style="position:absolute;inset:0;background:radial-gradient(circle at 50% 50%, #FFE066 0%, #F5B700 70%, #E8A900 100%);">
    <div style="position:absolute;left:-2000px;top:-2000px;width:6560px;height:5440px;opacity:0.25;background:repeating-conic-gradient(from 0deg at 50% 50%, #fff 0deg 6deg, transparent 6deg 14deg);"></div>
    <div style="position:absolute;left:0;top:930px;width:2560px;height:510px;background:#3FA34D;border-top:10px solid #000;"></div>
    ${friends}
    <div style="position:absolute;left:560px;top:520px;width:356px;height:520px;">${svg("kit/chars/narrator/teo-talk.svg")}</div>
    <div style="position:absolute;left:900px;top:548px;width:1150px;">
      <div style="display:inline-block;padding:10px 26px 6px;background:#000;color:#fff;font-size:40px;font-weight:700;text-transform:uppercase;border:5px solid #fff;transform:rotate(-2deg);">Kênh của Tèo</div>
      <div style="margin-top:20px;font-size:100px;line-height:1;font-weight:700;color:#fff;text-transform:uppercase;-webkit-text-stroke:6px #000;paint-order:stroke fill;text-shadow:10px 10px 0 #000;">Cùng Tèo <span style="color:#FF4D8D">khám phá!</span></div>
      <div style="margin-top:40px;white-space:nowrap;">${chip("Khoa học", "#9EE6FF")}${chip("Lịch sử", "#FF9EE0")}${chip("Truyện kể", "#A6F28A")}${chip("Video mới mỗi ngày", "#fff")}</div>
    </div>
  </div>
</div>
<script>window.__timelines = window.__timelines || {}; window.__timelines["banner"] = gsap.timeline({ paused: true }); window.__timelines["banner"].set({}, {}, 1);</script>
</body></html>`;
writeFileSync(join(out, "index.html"), html);
console.log("avatar/banner/index.html written");
