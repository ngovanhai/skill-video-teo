#!/usr/bin/env node
// Dựng một YouTube Short DỌC 1080×1920 từ một thư mục short (videos/<slug>/shorts/NN-<ten>/).
// Giọng + mốc chữ vẫn do kit làm:  node KIT/make.mjs <shortDir> --stage scaffold,tts,align
// Rồi:  node build-short.mjs <shortDir> [--stage build,render,pack] [--no-gpu] [--force]
//   build  → compositions/sXXX.html (1080×1920) + phụ đề dọc + bgm + index.html
//   render → renders/short.mp4 (hyperframes, --gpu), kiểm 1080×1920 + độ dài
//   pack   → <video>/youtube/shorts/<NN-ten>.mp4 + .txt (tiêu đề, mô tả, tag). KHÔNG đăng gì.
// Cảnh: "type": "custom", "file": "../scenes/<ten>.mjs" — default export (ctx, kit) như cảnh custom thường,
// ctx thêm W=1080, H=1920. Không dùng template kit (chúng vẽ cho 1920×1080).
import { readFileSync, writeFileSync, existsSync, mkdirSync, copyFileSync, readdirSync, statSync } from "node:fs";
import { join, resolve, basename, dirname } from "node:path";
import { spawnSync } from "node:child_process";
import { pathToFileURL } from "node:url";

const KIT = "__MUSE_ROOT__/kit";
const imp = (p) => import(pathToFileURL(join(KIT, p)).href);
const { Cues, r3, esc, setTheme, theme, groundCss, RUNTIME } = await imp("lib/base.mjs");
const { KIT_API } = await imp("scenes/index.mjs");
const { captionGroups } = await imp("lib/captions.mjs");

const HF = "hyperframes@0.8.172";
const LEAD = 0.25, TAIL = 0.3; // giống make.mjs
const W = 1080, H = 1920;

const args = process.argv.slice(2);
const dir = resolve(args.find((a) => !a.startsWith("--")) || ".");
const opt = (k, d) => { const i = args.indexOf(`--${k}`); return i >= 0 ? args[i + 1] : d; };
const flag = (k) => args.includes(`--${k}`);
const todo = opt("stage", "build,render,pack").split(",");
const log = (...m) => console.log(...m);
const die = (m) => { console.error(`\n✗ ${m}`); process.exit(1); };
const P = (...p) => join(dir, ...p);
const ENV = { ...process.env, PYTHONIOENCODING: "utf-8" };
const run = (cmd, argv, o = {}) => {
  log(`$ ${cmd} ${argv.join(" ")}`);
  const r = spawnSync(cmd, argv, { stdio: "inherit", shell: process.platform === "win32" && cmd === "npx", cwd: dir, env: ENV, ...o });
  if (r.status !== 0 && !o.allowFail) die(`${cmd} failed (${r.status})`);
  return r.status;
};
const probe = (file, what) => spawnSync("ffprobe", ["-v", "error", ...what, "-of", "csv=p=0", file], { encoding: "utf8" }).stdout.trim();

// ---------------------------------------------------------------- load
if (!existsSync(P("video.json"))) die(`no video.json in ${dir}`);
const video = JSON.parse(readFileSync(P("video.json"), "utf8"));
video.__dir = dir;
setTheme(video.theme);
video.cast = { teo: { svg: "narrator", name: "Tèo" }, ...(video.cast || {}) };
const chapters = (video.chapters || []).map((c) => (typeof c === "string" ? JSON.parse(readFileSync(P(c), "utf8")) : c));
let n = 0;
for (const ch of chapters) for (const s of ch.scenes) s.id = `s${String(++n).padStart(3, "0")}`;
const scenes = chapters.flatMap((c) => c.scenes);
for (const s of scenes) {
  if (s.type !== "custom" || !s.file) die(`${s.id}: short chỉ nhận cảnh "custom" có "file" (cảnh dọc tự vẽ)`);
  if (!existsSync(P(s.file))) die(`${s.id}: không thấy ${s.file}`);
  s.__mod = (await import(pathToFileURL(P(s.file)).href + `?v=${statSync(P(s.file)).mtimeMs}`)).default;
}

function layout() {
  let t = 0;
  for (const s of scenes) {
    const wf = P("words", `${s.id}.json`);
    if (!existsSync(wf)) die(`${s.id}: chưa có words/ — chạy make.mjs <shortDir> --stage scaffold,tts,align`);
    const w = JSON.parse(readFileSync(wf, "utf8"));
    if (w.match < 0.6) log(`⚠ ${s.id}: giọng khớp chữ thấp (${w.match}) — nghe lại`);
    s.voiceDur = w.dur;
    s.words = w.words.map((x) => ({ text: x.text, start: r3(x.start + LEAD), end: r3(x.end + LEAD) }));
    s.dur = r3(LEAD + w.dur + TAIL + (s.hold || 0));
    s.at = r3(t);
    t += s.dur;
  }
  return r3(t);
}

// ---------------------------------------------------------------- vertical wrappers
const ground = (bg) => (/^(#|rgb|linear|radial)/.test(bg) ? `background: ${bg};` : groundCss(bg));
const FONTS = `@font-face { font-family: "Inter"; src: url("assets/fonts/Inter-Variable.ttf") format("truetype"); font-weight: 100 900; font-style: normal; font-display: block; }
    @font-face { font-family: "Space Grotesk"; src: url("assets/fonts/Space_Grotesk-Variable.ttf") format("truetype"); font-weight: 300 700; font-style: normal; font-display: block; }`;

function wrapV({ id, dur, bg, css, html, js, camera = true }) {
  const D = r3(dur), ns = id;
  return `<template id="${id}-template">
  <script src="https://cdn.jsdelivr.net/npm/gsap@3.14.2/dist/gsap.min.js"></script>
  <style>
    ${FONTS}
    #${ns}-root { position: absolute; inset: 0; width: ${W}px; height: ${H}px; overflow: hidden; font-family: ${theme()?.font || `"Space Grotesk", sans-serif`}; color: #000; }
    #${ns}-root * { box-sizing: border-box; }
    .${ns}-ground { position: absolute; inset: 0; ${ground(bg)} }
    .${ns}-cam { position: absolute; inset: 0; }
${css}
  </style>
  <div id="${ns}-root" data-composition-id="${id}" data-width="${W}" data-height="${H}" data-start="0" data-duration="${D}">
    <div class="clip ${ns}-ground" id="${ns}-ground" data-start="0" data-duration="${D}" data-track-index="0"></div>
    <div class="clip ${ns}-cam" id="${ns}-cam" data-start="0" data-duration="${D}" data-track-index="1">
${html}
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
${camera ? `      tl.fromTo(q("#${ns}-cam"), { scale: 1 }, { scale: 1.03, duration: ${D}, ease: "none", transformOrigin: "50% 40%" }, 0);` : ""}
${js}
      tl.set({}, {}, ${D});
      window.__timelines = window.__timelines || {};
      window.__timelines[ID] = tl;
    })();
  </script>
</template>
`;
}

// Phụ đề dọc: 2–4 chữ một nhóm, chữ to viền đen, từ đang đọc vàng + nảy nhẹ. Nằm ở y ≈ 1380–1600 (trên vùng nút Shorts).
function captionsV(id, dur, groups, o = {}) {
  const top = o.top ?? 1380, size = o.size ?? 82, on = o.on || "#F7CB46";
  return `<template id="${id}-template">
  <script src="https://cdn.jsdelivr.net/npm/gsap@3.14.2/dist/gsap.min.js"></script>
  <style>
    ${FONTS}
    #${id}-root { position: absolute; inset: 0; pointer-events: none; }
    .${id}-band { position: absolute; left: 50px; right: 110px; top: ${top}px; height: 230px; }
    .${id}-g { position: absolute; inset: 0; display: flex; flex-wrap: wrap; align-content: center; justify-content: center; gap: 0 0.28em; opacity: 0;
      font-family: "Inter", sans-serif; font-weight: 900; text-transform: uppercase; font-size: ${size}px; line-height: 1.08; letter-spacing: -0.01em; text-align: center; }
    .${id}-w { display: inline-block; color: #FFFFFF; -webkit-text-stroke: 14px #000; paint-order: stroke fill; text-shadow: 0 8px 0 #000; }
  </style>
  <div id="${id}-root" data-composition-id="${id}" data-width="${W}" data-height="${H}" data-start="0" data-duration="${r3(dur)}">
    <div class="clip ${id}-band" id="${id}-band" data-start="0" data-duration="${r3(dur)}" data-track-index="0"></div>
  </div>
  <script>
    (function () {
      var ID = ${JSON.stringify(id)};
      var G = ${JSON.stringify(groups)};
      var root = document.querySelector('[data-composition-id="' + ID + '"]');
      var band = root.querySelector("#" + ID + "-band");
      var tl = gsap.timeline({ paused: true });
      for (var i = 0; i < G.length; i++) {
        var g = document.createElement("div"); g.className = ID + "-g";
        var spans = [];
        for (var k = 0; k < G[i].w.length; k++) {
          var s = document.createElement("span"); s.className = ID + "-w"; s.textContent = G[i].w[k][0]; g.appendChild(s); spans.push(s);
        }
        band.appendChild(g);
        tl.fromTo(g, { opacity: 0, scale: 0.86 }, { opacity: 1, scale: 1, duration: 0.12, ease: "back.out(2)", immediateRender: false }, G[i].s);
        tl.set(g, { opacity: 0 }, G[i].e);
        for (var k2 = 0; k2 < spans.length; k2++) {
          var w = G[i].w[k2];
          tl.set(spans[k2], { color: ${JSON.stringify(on)}, scale: 1.08 }, w[1]);
          tl.set(spans[k2], { color: "#FFFFFF", scale: 1 }, Math.max(w[1] + 0.05, k2 + 1 < spans.length ? G[i].w[k2 + 1][1] : w[2]));
        }
      }
      tl.set({}, {}, ${r3(dur)});
      window.__timelines = window.__timelines || {};
      window.__timelines[ID] = tl;
    })();
  </script>
</template>
`;
}

function doc(dur, body) {
  return `<!doctype html>
<html lang="vi">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=${W}, height=${H}" />
    <script src="https://cdn.jsdelivr.net/npm/gsap@3.14.2/dist/gsap.min.js"></script>
    <style>
      * { margin: 0; padding: 0; box-sizing: border-box; }
      html, body { width: ${W}px; height: ${H}px; overflow: hidden; background: #000; }
      #root { position: relative; width: ${W}px; height: ${H}px; overflow: hidden; background: #000; }
      .scene { position: absolute; inset: 0; width: 100%; height: 100%; }
    </style>
  </head>
  <body>
    <div id="root" data-composition-id="main" data-start="0" data-duration="${r3(dur)}" data-width="${W}" data-height="${H}">
${body}
    </div>
    <script>
      window.__timelines = window.__timelines || {};
      window.__timelines.main = gsap.timeline({ paused: true });
      window.__timelines.main.set({}, {}, ${r3(dur)});
    </script>
  </body>
</html>
`;
}

const sfxDur = {};
const durOf = (f) => (sfxDur[f] ??= parseFloat(probe(f, ["-show_entries", "format=duration"])) || 1);

const SLOW = [
  [/filter\s*:\s*[^;"]*(blur|drop-shadow)|mix-blend-mode|backdrop-filter|@keyframes/, "filter/blend/keyframes"],
  [/\b(clipPath|rotationX|rotationY|rotateX|rotateY)\s*:/, "tween clipPath/3D"],
  [/\b(onUpdate|onComplete|onStart)\s*:|\btl\.call\(/, "callback"],
];

function build() {
  const total = layout();
  // ảnh bìa video dài (để cảnh CTA khoe "bản đầy đủ")
  const thumb = resolve(dir, "..", "..", "youtube", "thumbnail.png");
  const fullThumb = existsSync(thumb) ? (copyFileSync(thumb, P("assets", "full-thumb.png")), "assets/full-thumb.png") : null;
  const out = [];
  const sfxTracks = [];
  for (const [i, s] of scenes.entries()) {
    const cues = new Cues(s.words, s.dur);
    const ctx = { video, scene: s, ns: s.id, cues, dur: s.dur, W, H, vertical: true, index: i, count: scenes.length, fullThumb };
    let r;
    try { r = s.__mod(ctx, KIT_API) || {}; } catch (e) { die(`${s.id} (${s.file}): ${e.stack || e.message}`); }
    const html = wrapV({ id: s.id, dur: s.dur, bg: r.bg || s.bg || "dark", css: r.css || "", html: r.html || "", js: r.js || "", camera: r.camera !== false });
    for (const [re, why] of SLOW) if (re.test(html)) log(`⚠ ${s.id}: render chậm (${why})`);
    writeFileSync(P("compositions", `${s.id}.html`), html);
    out.push(`      <div id="el-${s.id}" class="scene" data-composition-id="${s.id}" data-composition-src="compositions/${s.id}.html" data-start="${s.at}" data-duration="${s.dur}" data-track-index="${i % 2}"></div>`);
    out.push(`      <audio id="el-${s.id}-voice" src="audio/${s.id}.wav" data-start="${r3(s.at + LEAD)}" data-duration="${r3(s.voiceDur)}" data-track-index="10" data-volume="1"></audio>`);
    for (const [k, fx] of (r.sfx || []).filter((x) => x.t < s.dur - 0.1).entries()) {
      const file = P("assets/sfx", fx.file);
      if (!existsSync(file)) { log(`⚠ ${s.id}: thiếu sfx ${fx.file}`); continue; }
      const st = r3(s.at + fx.t), d = r3(Math.min(durOf(file), s.dur - fx.t));
      let tr = sfxTracks.findIndex((end) => end <= st);
      if (tr < 0) { tr = sfxTracks.length; sfxTracks.push(0); }
      sfxTracks[tr] = st + d;
      out.push(`      <audio id="el-${s.id}-fx${k}" src="assets/sfx/${fx.file}" data-start="${st}" data-duration="${d}" data-track-index="${12 + tr}" data-volume="${fx.vol}"></audio>`);
    }
  }
  // bgm
  const src = video.bgm && existsSync(P(video.bgm)) ? P(video.bgm) : join(KIT, "bgm", video.bgm || "playful-pizzicato.mp3");
  if (!existsSync(src)) die(`bgm not found: ${video.bgm}`);
  const len = r3(total + 1);
  run("ffmpeg", ["-y", "-v", "error", "-stream_loop", "-1", "-i", src, "-t", String(len), "-af", `afade=t=in:d=0.6,afade=t=out:st=${r3(len - 2)}:d=2`, "-c:a", "libmp3lame", "-b:a", "160k", P("assets/bgm/bgm-full.mp3")]);
  out.push(`      <audio id="el-bgm" src="assets/bgm/bgm-full.mp3" data-start="0" data-duration="${total}" data-track-index="11" data-volume="${video.bgm_volume ?? 0.08}"></audio>`);
  // phụ đề
  const words = scenes.flatMap((s) => s.words.map((w) => ({ ...w, start: r3(w.start + s.at), end: r3(w.end + s.at) })));
  writeFileSync(P("compositions", "cap.html"), captionsV("cap", total, captionGroups(words, video.short?.caption_words || 4), video.short?.caption || {}));
  out.push(`      <div id="el-cap" class="scene" data-composition-id="cap" data-composition-src="compositions/cap.html" data-start="0" data-duration="${total}" data-track-index="9" data-track-kind="captions"></div>`);
  writeFileSync(P("index.html"), doc(total, out.join("\n")));
  writeFileSync(P("work/starts.txt"), scenes.map((s) => `${s.id} ${s.at} ${s.dur}`).join("\n"));
  // kiểm nhanh
  const hookDur = scenes[0].dur;
  const lastSay = scenes.at(-1).say || "";
  if (total > 60) log(`⚠ dài ${total.toFixed(1)} s > 60 s (Shorts cho tới 3 phút nhưng ≤60 s giữ người xem tốt hơn)`);
  if (total < 20) log(`⚠ ngắn ${total.toFixed(1)} s`);
  if (hookDur > 12) log(`⚠ cảnh mở dài ${hookDur} s — hook nên đổi hình trong 2 s đầu và ≤ 12 s`);
  if (!/tèo kể|đăng ký/i.test(lastSay)) log(`⚠ cảnh cuối chưa nhắc "Tèo Kể"/"đăng ký"`);
  log(`build ok: ${scenes.length} cảnh, ${total.toFixed(1)} s, 1080×1920`);
}

function render() {
  const outFile = P("renders/short.mp4");
  if (existsSync(outFile) && statSync(outFile).mtimeMs > statSync(P("index.html")).mtimeMs && !flag("force")) { log("render: up to date"); }
  else {
    const argv = ["--yes", HF, "render", "--composition", "index.html", "--output", "renders/short.mp4", "--quality", opt("quality", "standard"), "--quiet"];
    if (!flag("no-gpu")) argv.push("--gpu");
    const t0 = Date.now();
    run("npx", argv);
    log(`render took ${((Date.now() - t0) / 60000).toFixed(1)} min`);
  }
  const wh = probe(outFile, ["-select_streams", "v:0", "-show_entries", "stream=width,height"]);
  const d = parseFloat(probe(outFile, ["-show_entries", "format=duration"]));
  const [pw, ph] = wh.split(/[,\s]+/).filter(Boolean).map(Number);
  if (pw !== W || ph !== H) die(`kích thước sai: ${pw}×${ph} (cần ${W}×${H})`);
  log(`render ok: ${outFile} — ${pw}×${ph}, ${d.toFixed(1)} s`);
}

function pack() {
  const name = basename(dir);
  const parent = resolve(dir, "..", "..");
  const outDir = join(parent, "youtube", "shorts");
  mkdirSync(outDir, { recursive: true });
  if (!existsSync(P("renders/short.mp4"))) die("chưa có renders/short.mp4");
  copyFileSync(P("renders/short.mp4"), join(outDir, `${name}.mp4`));
  const sh = video.short || {};
  let title = sh.title || video.title || name;
  if (!/#shorts/i.test(title)) title = `${title} #Shorts`;
  if ([...title].length > 100) log(`⚠ tiêu đề ${[...title].length} ký tự > 100`);
  const txt = [`TIÊU ĐỀ:\n${title}`, `\nMÔ TẢ:\n${sh.description || ""}\n\n${["#Shorts", ...(sh.hashtags || []).filter((h) => !/^#shorts$/i.test(h))].join(" ")}`.trimEnd(), `\nTAG:\n${(sh.tags || []).join(", ")}`, `\nGHI CHÚ:\n- Video dọc 1080×1920, dưới 3 phút → YouTube tự xếp vào Shorts.\n- Bản đầy đủ: ${sh.full || "(link video dài sau khi đăng)"}`].join("\n");
  writeFileSync(join(outDir, `${name}.txt`), txt);
  log(`pack ok: ${join(outDir, name)}.mp4 + .txt`);
}

for (const d of ["compositions", "assets/bgm", "renders", "work"]) mkdirSync(P(d), { recursive: true });
if (todo.includes("build")) build();
if (todo.includes("render")) render();
if (todo.includes("pack")) pack();
