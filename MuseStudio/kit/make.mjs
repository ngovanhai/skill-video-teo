#!/usr/bin/env node
// Long-video pipeline: video.json -> VieNeu voice -> word timings -> per-scene compositions ->
// per-chapter render -> concat -> thumbnail -> publish notes. Every stage is resumable.
//   node kit/make.mjs <videoDir> [--stage all|scaffold|validate|tts|align|build|lint|render|thumb|publish|fxlog] [--only ch01,ch02]
import { readFileSync, writeFileSync, existsSync, mkdirSync, copyFileSync, readdirSync, statSync, rmSync } from "node:fs";
import { join, resolve, basename } from "node:path";
import { spawnSync } from "node:child_process";
import { pathToFileURL } from "node:url";
import { KIT, Cues, wrapScene, r3 } from "./lib/base.mjs";
import { TEMPLATES } from "./scenes/index.mjs";
import { FX, sceneFx, CONTINUOUS_CAM } from "./fx/index.mjs";
import { captionGroups, captionsComposition } from "./lib/captions.mjs";
import { thumbnailHtml } from "./lib/thumbnail.mjs";

const HF = "hyperframes@0.8.172";
const VIENEU_DIR = process.env.VIENEU_DIR || "__VIENEU_DIR__";
const VIENEU_PY = join(VIENEU_DIR, process.platform === "win32" ? ".venv/Scripts/python.exe" : ".venv/bin/python");
const WHISPER_PY = process.env.WHISPER_PY || "__WHISPER_PY__";
const LEAD = 0.25; // silence before the voice in each scene
const TAIL = 0.3; // breath after it
const STAGES = ["scaffold", "validate", "tts", "align", "build", "lint", "render", "thumb", "publish"];

const args = process.argv.slice(2);
const dir = resolve(args.find((a) => !a.startsWith("--")) || ".");
const opt = (k, d) => { const i = args.indexOf(`--${k}`); return i >= 0 ? args[i + 1] : d; };
const stage = opt("stage", "all");
const only = opt("only", "").split(",").filter(Boolean);
const flag = (k) => args.includes(`--${k}`);

const PYENV = Object.assign({}, process["env"], { PYTHONIOENCODING: "utf-8", PYTHONUTF8: "1" });
const log = (...m) => console.log(...m);
const die = (m) => { console.error(`\n✗ ${m}`); process.exit(1); };
const pad = (n, w = 3) => String(n).padStart(w, "0");
const run = (cmd, argv, o = {}) => {
  log(`$ ${cmd} ${argv.join(" ")}`);
  const r = spawnSync(cmd, argv, { stdio: "inherit", shell: process.platform === "win32" && cmd === "npx", cwd: dir, env: PYENV, ...o });
  if (r.status !== 0 && !o.allowFail) die(`${cmd} failed (${r.status})`);
  return r.status;
};
const capture = (cmd, argv) => spawnSync(cmd, argv, { encoding: "utf8", cwd: dir }).stdout || "";

// ---------------------------------------------------------------- load
const vfile = join(dir, "video.json");
if (!existsSync(vfile)) die(`no video.json in ${dir}`);
const video = JSON.parse(readFileSync(vfile, "utf8"));
video.__dir = dir;
video.cast = { teo: { svg: "narrator", name: "Tèo" }, ...(video.cast || {}) };
// a chapter may live in its own file: "chapters": ["chapters/01.json", ...]
const chapters = (video.chapters || []).map((c) => (typeof c === "string" ? JSON.parse(readFileSync(join(dir, c), "utf8")) : c));
let n = 0;
for (const [ci, ch] of chapters.entries()) {
  ch.id = `ch${pad(ci + 1, 2)}`;
  for (const s of ch.scenes) { s.id = `s${pad(++n)}`; s.chapter = ch.id; }
}
const scenes = chapters.flatMap((c) => c.scenes);
const P = (...p) => join(dir, ...p);
const wav = (s) => P("audio", `${s.id}.wav`);
const wordsFile = (s) => P("words", `${s.id}.json`);
const spoken = (s) => String(s.say || "").replace(/\s+/g, " ").trim();
const plain = (x) => String(x || "").toLowerCase().normalize("NFC").replace(/[^\p{L}\p{N}]+/gu, " ").trim();
const HISTORY = join(KIT, "..", "ideas", "fx-history.json");
const readHistory = () => (existsSync(HISTORY) ? JSON.parse(readFileSync(HISTORY, "utf8")) : []);
const slugOf = () => video.slug || basename(dir);

// hand-made scenes: "type": "custom", "file": "scenes/<name>.mjs" (relative to the video dir)
for (const s of scenes.filter((s) => s.type === "custom")) {
  if (!s.file || !existsSync(P(s.file))) { s.__err = `file not found: ${s.file}`; continue; }
  try {
    const m = await import(pathToFileURL(P(s.file)).href + `?v=${statSync(P(s.file)).mtimeMs}`);
    if (typeof m.default === "function") s.__mod = m.default; else s.__err = `${s.file} has no default export function`;
  } catch (e) { s.__err = `${s.file}: ${e.message}`; }
}

// ---------------------------------------------------------------- stages
function scaffold() {
  for (const d of ["audio", "words", "compositions", "assets/fonts", "assets/sfx", "assets/bgm", "renders", "work"]) mkdirSync(P(d), { recursive: true });
  const slug = video.slug || basename(dir);
  if (!existsSync(P("package.json"))) writeFileSync(P("package.json"), JSON.stringify({ name: slug, private: true, type: "module",
    scripts: { dev: `npx --yes ${HF} preview`, check: `npx --yes ${HF} check`, render: `npx --yes ${HF} render` } }, null, 2));
  if (!existsSync(P("hyperframes.json"))) writeFileSync(P("hyperframes.json"), JSON.stringify({ $schema: "https://hyperframes.heygen.com/schema/hyperframes.json",
    paths: { blocks: "compositions", components: "compositions/components", assets: "assets" }, media: { autoProxy: true } }, null, 2));
  if (!existsSync(P("meta.json"))) writeFileSync(P("meta.json"), JSON.stringify({ id: slug, name: slug, createdAt: new Date().toISOString() }, null, 2));
  const cp = (from, to) => { if (!existsSync(to)) copyFileSync(from, to); };
  for (const f of readdirSync(join(KIT, "fonts"))) cp(join(KIT, "fonts", f), P("assets/fonts", f));
  for (const f of readdirSync(join(KIT, "sfx")).filter((f) => f.endsWith(".mp3"))) cp(join(KIT, "sfx", f), P("assets/sfx", f));
  log(`scaffold ok: ${dir}`);
}

function validate() {
  const errs = [], warns = [];
  if (!chapters.length) errs.push("no chapters");
  if (scenes[0]?.type !== "hook") errs.push("first scene must be a hook");
  if (scenes.at(-1)?.type !== "outro") errs.push("last scene must be an outro");
  for (const ch of chapters) {
    if (!ch.title) errs.push(`${ch.id}: missing title`);
  }
  for (const s of scenes) {
    const where = `${s.id} (${s.type})`;
    if (!TEMPLATES[s.type]) { errs.push(`${where}: unknown type`); continue; }
    if (!spoken(s)) errs.push(`${where}: empty say`);
    if (s.__err) errs.push(`${where}: ${s.__err}`);
    const fxl = sceneFx(s);
    for (const e of fxl) if (!FX[e.id]) errs.push(`${where}: unknown fx "${e.id}" (see node kit/fx-list.mjs)`);
    if (fxl.filter((e) => CONTINUOUS_CAM.has(e.id)).length > 1) warns.push(`${where}: more than one continuous camera fx (${[...CONTINUOUS_CAM].join("/")}) — pick one`);
    const words = spoken(s).split(" ").length;
    if (words > 70) warns.push(`${where}: ${words} words — split it (scenes over ~18s get stale)`);
    if (words < 10) warns.push(`${where}: only ${words} words — VieNeu rushes/garbles very short lines, write a full sentence (10+ words)`);
    for (const k of ["who", "left", "right"]) for (const w of [].concat(s[k] || [])) if (typeof w === "string" && !video.cast[w]) errs.push(`${where}: cast "${w}" not defined`);
    for (const m of [...(s.members || []), ...(s.lines || [])]) if (m.who && !video.cast[m.who]) errs.push(`${where}: cast "${m.who}" not defined`);
    // every cue phrase must appear in the narration
    const text = " " + spoken(s).toLowerCase().normalize("NFC").replace(/[^\p{L}\p{N}]+/gu, " ") + " ";
    JSON.stringify(s, (k, v) => {
      if ((k === "at" || k.endsWith("_at")) && typeof v === "string") {
        const p = " " + v.toLowerCase().normalize("NFC").replace(/[^\p{L}\p{N}]+/gu, " ").trim() + " ";
        if (!text.includes(p)) warns.push(`${where}: cue "${v}" not in say`);
      }
      return v;
    });
  }
  for (const [k, c] of Object.entries(video.cast)) {
    if (c.svg === "narrator") continue;
    const f = c.svg.startsWith("library/") ? join(KIT, "chars", c.svg.replace(/\.svg$/, "") + ".svg") : P(c.svg);
    if (!existsSync(f)) errs.push(`cast ${k}: svg not found ${f}`);
  }
  creativeChecks(warns);
  const total = scenes.reduce((a, s) => a + spoken(s).split(" ").length, 0);
  const estMin = total / 4.1 / 60;
  log(`validate: ${chapters.length} chapters, ${scenes.length} scenes, ${total} words ≈ ${estMin.toFixed(1)} min`);
  if (video.target_min && (estMin < video.target_min[0] * 0.9 || estMin > video.target_min[1] * 1.1)) warns.push(`length ${estMin.toFixed(1)} min outside target ${video.target_min.join("–")}`);
  warns.forEach((w) => log(`  ! ${w}`));
  if (errs.length) die("validate failed:\n  " + errs.join("\n  "));
}

// hook → greeting → mid-video subscribe → closing subscribe; fx density; no repeats of recent videos
function creativeChecks(warns) {
  const has = (s, p) => (" " + plain(spoken(s)) + " ").includes(" " + plain(p) + " ");
  if (!scenes.slice(0, 3).some((s) => has(s, "lại là tèo"))) warns.push(`greeting: one of the first 3 scenes (right after the hook) must say "Chào các bạn, lại là Tèo đây…"`);
  const words = scenes.map((s) => spoken(s).split(" ").length), total = words.reduce((a, b) => a + b, 0) || 1;
  let acc = 0;
  const mid = scenes.filter((s, i) => { const f = (acc + words[i] / 2) / total; acc += words[i]; return f >= 0.35 && f <= 0.65; });
  if (!mid.some((s) => has(s, "đăng ký"))) warns.push(`cta: no subscribe call ("đăng ký") in the middle of the video (35–65%) — add one with "cta": true`);
  if (!scenes.slice(-3).some((s) => has(s, "đăng ký"))) warns.push(`cta: the closing scenes (outro or the 2 before it) must ask viewers to subscribe ("đăng ký")`);
  for (const s of scenes) if (s.cta && !has(s, "đăng ký")) warns.push(`${s.id}: "cta": true but the narration never says "đăng ký"`);
  if (!video.target_min) return; // short tests / pilots skip the creativity rules
  const customs = scenes.filter((s) => s.type === "custom").length;
  if (customs < 3) warns.push(`creative: only ${customs} custom scene(s) — every video needs ≥3 hand-made SVG + GSAP scenes`);
  const withFx = scenes.filter((s) => s.type === "custom" || sceneFx(s).length).length;
  if (withFx < scenes.length / 4) warns.push(`creative: only ${withFx}/${scenes.length} scenes have fx or are custom — aim for ~1 in 3`);
  if (sceneFx(scenes[0]).length < 2) warns.push("creative: the hook scene should carry ≥2 fx");
  const c = video.creative || {};
  for (const k of ["style", "motif", "hook"]) if (!c[k]) warns.push(`creative: video.json "creative.${k}" is missing`);
  const recent = readHistory().filter((h) => h.slug !== slugOf()).slice(-2);
  for (const k of ["style", "motif", "hook"]) if (c[k] && recent.some((h) => plain(h.creative?.[k]) === plain(c[k]))) warns.push(`creative: creative.${k} "${c[k]}" repeats one of the last 2 videos`);
  const mine = new Set(scenes.flatMap((s) => sceneFx(s).map((e) => e.id)).filter((id) => id !== "subscribe"));
  const theirs = new Set(recent.flatMap((h) => Object.keys(h.fx || {})));
  const same = [...mine].filter((id) => theirs.has(id));
  if (mine.size && theirs.size && same.length / mine.size > 0.5) warns.push(`creative: ${same.length}/${mine.size} fx kinds also used in the last 2 videos (${same.join(", ")}) — swap some for less used ones`);
}

// record what this video used so the next ones avoid repeating it (publish calls this; builds never do)
function fxlog() {
  const count = {};
  for (const s of scenes) for (const e of sceneFx(s)) count[e.id] = (count[e.id] || 0) + 1;
  const entry = { slug: slugOf(), date: new Date().toISOString().slice(0, 10), title: video.title, creative: video.creative || {}, fx: count,
    custom: scenes.filter((s) => s.type === "custom").map((s) => s.file) };
  const h = readHistory().filter((x) => x.slug !== entry.slug);
  h.push(entry);
  writeFileSync(HISTORY, JSON.stringify(h, null, 1));
  log(`fxlog: ${Object.keys(count).length} fx kinds, ${entry.custom.length} custom scenes → ${HISTORY}`);
}

function tts(subset = scenes) {
  const job = { voice: video.voice || "Lóng", temperature: video.temperature ?? 0.8, lines: subset.map((s) => ({ id: s.id, text: spoken(s), out: wav(s) })) };
  writeFileSync(P("work/tts-job.json"), JSON.stringify(job, null, 1));
  run(VIENEU_PY, [join(KIT, "py/tts.py"), P("work/tts-job.json")], { cwd: VIENEU_DIR });
}

function alignStage(subset = scenes) {
  const names = video.names || Object.values(video.cast).map((c) => c.name).filter(Boolean).join(", ");
  const job = { names, lines: subset.map((s) => ({ id: s.id, text: spoken(s), out: wav(s), words: wordsFile(s) })) };
  writeFileSync(P("work/align-job.json"), JSON.stringify(job, null, 1));
  run(WHISPER_PY, [join(KIT, "py/align.py"), P("work/align-job.json"), video.whisper || "small"]);
}

function align() {
  alignStage();
  // one retry for scenes the TTS garbled
  const weak = scenes.filter((s) => JSON.parse(readFileSync(wordsFile(s), "utf8")).match < 0.6);
  if (weak.length && !flag("no-retry")) {
    log(`retrying TTS for ${weak.length} weak scene(s): ${weak.map((s) => s.id).join(" ")}`);
    for (const s of weak) { rmSync(wav(s), { force: true }); rmSync(wav(s).replace(/\.wav$/, ".key"), { force: true }); }
    tts(weak);
    alignStage(weak);
  }
}

const sfxDur = {};
function durOf(file) {
  if (sfxDur[file] == null) sfxDur[file] = parseFloat(capture("ffprobe", ["-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", file])) || 1;
  return sfxDur[file];
}

// lay every scene on the timeline and write all compositions
function layout() {
  let t = 0;
  for (const ch of chapters) {
    ch.start = t;
    let local = 0;
    for (const s of ch.scenes) {
      const wf = wordsFile(s);
      if (!existsSync(wf)) die(`${s.id}: no word timings — run --stage align`);
      const w = JSON.parse(readFileSync(wf, "utf8"));
      s.voiceDur = w.dur;
      s.words = w.words.map((x) => ({ text: x.text, start: r3(x.start + LEAD), end: r3(x.end + LEAD) }));
      s.dur = r3(LEAD + w.dur + TAIL + (s.hold || 0));
      s.local = r3(local);
      local += s.dur;
    }
    ch.dur = r3(local);
    t += local;
  }
  return r3(t);
}

function build() {
  const total = layout();
  for (const s of scenes) {
    const cues = new Cues(s.words, s.dur);
    const ctx = { video, scene: s, ns: s.id, cues, dur: s.dur };
    let r;
    try { r = TEMPLATES[s.type](ctx); } catch (e) { die(`${s.id} (${s.type}): ${e.message}`); }
    // fx layers from kit/fx, behind (back) and on top of (over) the template
    const fxl = sceneFx(s);
    let back = "", over = "", css = r.css || "", js = r.js || "";
    const sfx = [...(r.sfx || [])];
    for (const [i, e] of fxl.entries()) {
      if (!FX[e.id]) die(`${s.id}: unknown fx "${e.id}"`);
      let x;
      try { x = FX[e.id].run({ ...ctx, bg: r.bg || s.bg, id: `${s.id}-fx${i}` }, e) || {}; } catch (err) { die(`${s.id} fx ${e.id}: ${err.message}`); }
      back += x.back || ""; over += x.over || ""; css += x.css ? "\n" + x.css : ""; js += x.js || ""; sfx.push(...(x.sfx || []));
    }
    s.sfx = sfx.filter((x) => x.t < s.dur - 0.1);
    writeFileSync(P("compositions", `${s.id}.html`), wrapScene({ id: s.id, ns: s.id, dur: s.dur, bg: r.bg || s.bg || "paper", css, html: r.html, js, back, over, fxcam: fxl.length > 0 }));
  }
  bgm(total);
  for (const ch of chapters) {
    const words = ch.scenes.flatMap((s) => s.words.map((w) => ({ ...w, start: r3(w.start + s.local), end: r3(w.end + s.local) })));
    writeFileSync(P("compositions", `cap-${ch.id}.html`), captionsComposition(`cap-${ch.id}`, ch.dur, captionGroups(words)));
    writeFileSync(P("work", `${ch.id}.html`), doc(`${ch.id}`, ch.dur, clips(ch.scenes, ch.start, [ch])));
  }
  writeFileSync(P("index.html"), doc("main", total, clips(scenes, 0, chapters, true)));
  writeFileSync(P("work/timeline.json"), JSON.stringify(chapters.map((c) => ({ id: c.id, title: c.title, start: r3(c.start), dur: c.dur })), null, 1));
  log(`build ok: ${scenes.length} scenes, ${chapters.length} chapters, ${(total / 60).toFixed(1)} min`);
}

// HTML for scenes + voice + sfx + bgm + captions. `base` = where t=0 of this document sits in the full video.
function clips(list, base, chs, global = false) {
  const out = [];
  const sfxTracks = []; // end times per sfx track
  for (const [i, s] of list.entries()) {
    const at = r3((global ? chapters.find((c) => c.id === s.chapter).start : 0) + s.local);
    out.push(`      <div id="el-${s.id}" class="scene" data-composition-id="${s.id}" data-composition-src="compositions/${s.id}.html" data-start="${at}" data-duration="${s.dur}" data-track-index="${i % 2}"></div>`);
    out.push(`      <audio id="el-${s.id}-voice" src="audio/${s.id}.wav" data-start="${r3(at + LEAD)}" data-duration="${r3(s.voiceDur)}" data-track-index="10" data-volume="1"></audio>`);
    for (const [k, fx] of s.sfx.entries()) {
      const file = P("assets/sfx", fx.file);
      if (!existsSync(file)) continue;
      const st = r3(at + fx.t), d = r3(Math.min(durOf(file), s.dur - fx.t));
      let tr = sfxTracks.findIndex((end) => end <= st);
      if (tr < 0) { tr = sfxTracks.length; sfxTracks.push(0); }
      sfxTracks[tr] = st + d;
      out.push(`      <audio id="el-${s.id}-fx${k}" src="assets/sfx/${fx.file}" data-start="${st}" data-duration="${d}" data-track-index="${12 + tr}" data-volume="${fx.vol}"></audio>`);
    }
  }
  const len = chs.reduce((a, c) => a + c.dur, 0);
  out.push(`      <audio id="el-bgm" src="assets/bgm/bgm-full.mp3" data-start="0" data-media-start="${r3(global ? 0 : base)}" data-duration="${r3(len)}" data-track-index="11" data-volume="${video.bgm_volume ?? 0.09}"></audio>`);
  for (const c of chs) {
    const at = global ? r3(c.start) : 0;
    out.push(`      <div id="el-cap-${c.id}" class="scene" data-composition-id="cap-${c.id}" data-composition-src="compositions/cap-${c.id}.html" data-start="${at}" data-duration="${c.dur}" data-track-index="9" data-track-kind="captions"></div>`);
  }
  return out.join("\n");
}

function doc(id, dur, body) {
  return `<!doctype html>
<html lang="vi">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=1920, height=1080" />
    <script src="https://cdn.jsdelivr.net/npm/gsap@3.14.2/dist/gsap.min.js"></script>
    <style>
      * { margin: 0; padding: 0; box-sizing: border-box; }
      html, body { width: 1920px; height: 1080px; overflow: hidden; background: #000; }
      #root { position: relative; width: 1920px; height: 1080px; overflow: hidden; background: #FFFDF5; }
      .scene { position: absolute; inset: 0; width: 100%; height: 100%; }
    </style>
  </head>
  <body>
    <div id="root" data-composition-id="${id}" data-start="0" data-duration="${r3(dur)}" data-width="1920" data-height="1080">
${body}
    </div>
    <script>
      window.__timelines = window.__timelines || {};
      window.__timelines[${JSON.stringify(id)}] = gsap.timeline({ paused: true });
      window.__timelines[${JSON.stringify(id)}].set({}, {}, ${r3(dur)});
    </script>
  </body>
</html>
`;
}

function bgm(total) {
  const out = P("assets/bgm/bgm-full.mp3");
  const src = join(KIT, "bgm", video.bgm || "playful-pizzicato.mp3");
  const stamp = P("assets/bgm/bgm-full.len");
  if (existsSync(out) && existsSync(stamp) && readFileSync(stamp, "utf8") === `${src}|${total}`) return;
  const len = r3(total + 1);
  run("ffmpeg", ["-y", "-v", "error", "-stream_loop", "-1", "-i", src, "-t", String(len), "-af", `afade=t=in:d=1.5,afade=t=out:st=${r3(len - 3)}:d=3`, "-c:a", "libmp3lame", "-b:a", "160k", out]);
  writeFileSync(stamp, `${src}|${total}`);
}

function lint() {
  run("npx", ["--yes", HF, "lint"], { allowFail: true });
}

function render() {
  const timeline = JSON.parse(readFileSync(P("work/timeline.json"), "utf8"));
  const parts = [];
  for (const c of timeline) {
    const outFile = P("renders", `${c.id}.mp4`);
    parts.push(outFile);
    if (only.length && !only.includes(c.id)) continue;
    const src = statSync(P("work", `${c.id}.html`)).mtimeMs;
    if (existsSync(outFile) && statSync(outFile).mtimeMs > src && !flag("force")) { log(`render: ${c.id} up to date`); continue; }
    const t0 = Date.now();
    const argv = ["--yes", HF, "render", "--composition", `${c.id}.html`, "--output", `renders/${c.id}.mp4`, "--quality", opt("quality", "standard"), "--quiet"];
    if (flag("low-memory")) argv.push("--low-memory-mode");
    // chapter docs live in work/ so the project keeps a single root; copied to the root only while rendering
    copyFileSync(P("work", `${c.id}.html`), P(`${c.id}.html`));
    try { run("npx", argv); } finally { rmSync(P(`${c.id}.html`), { force: true }); }
    log(`render: ${c.id} (${(c.dur / 60).toFixed(1)} min) took ${((Date.now() - t0) / 60000).toFixed(1)} min`);
  }
  if (only.length) return;
  writeFileSync(P("work/concat.txt"), parts.map((p) => `file '${p.replace(/\\/g, "/")}'`).join("\n"));
  run("ffmpeg", ["-y", "-v", "error", "-f", "concat", "-safe", "0", "-i", P("work/concat.txt"), "-c", "copy", "-movflags", "+faststart", P("renders/final.mp4")]);
  log(`final: ${P("renders/final.mp4")}`);
}

function thumb() {
  const td = P("thumb");
  mkdirSync(join(td, "assets/fonts"), { recursive: true });
  for (const f of readdirSync(join(KIT, "fonts"))) if (!existsSync(join(td, "assets/fonts", f))) copyFileSync(join(KIT, "fonts", f), join(td, "assets/fonts", f));
  writeFileSync(join(td, "index.html"), thumbnailHtml(video));
  if (!existsSync(join(td, "package.json"))) writeFileSync(join(td, "package.json"), JSON.stringify({ name: "thumb", private: true, type: "module" }));
  const shots = P("work/thumb-shot");
  rmSync(shots, { recursive: true, force: true });
  run("npx", ["--yes", HF, "snapshot", td, "--at", "0.5", "--no-end", "-o", shots, "--describe", "false"]);
  const png = readdirSync(shots).find((f) => f.endsWith(".png"));
  if (!png) die("thumbnail snapshot produced no png");
  copyFileSync(join(shots, png), P("thumbnail.png"));
  log(`thumbnail: ${P("thumbnail.png")}`);
}

function publish() {
  const timeline = JSON.parse(readFileSync(P("work/timeline.json"), "utf8"));
  const ts = (t) => { t = Math.floor(t); const h = Math.floor(t / 3600), m = Math.floor((t % 3600) / 60), s = t % 60; return (h ? `${h}:${pad(m, 2)}` : `${m}`) + `:${pad(s, 2)}`; };
  const p = video.publish || {};
  const stamps = timeline.map((c, i) => `${ts(i === 0 ? 0 : c.start)} ${i === 0 ? (p.intro_label || "Mở đầu") : c.title}`);
  const md = `# ${video.title}

## Tiêu đề (chọn 1)
${(p.titles || [video.title]).map((t) => `- ${t}`).join("\n")}

## Mô tả
${p.description || ""}

${stamps.join("\n")}

${(p.hashtags || []).map((h) => (h.startsWith("#") ? h : `#${h}`)).join(" ")}

## Tags
${(p.tags || []).join(", ")}

## File
- Video: renders/final.mp4
- Thumbnail: thumbnail.png
${p.notes ? `\n## Ghi chú kiểm tra\n${p.notes}\n` : ""}`;
  writeFileSync(P("publish.md"), md);
  log(`publish: ${P("publish.md")}`);
  fxlog();
}

// ---------------------------------------------------------------- main
const table = { scaffold, validate, tts: () => tts(), align, build, lint, render, thumb, publish, fxlog };
const todo = stage === "all" ? STAGES : stage.split(",");
for (const st of todo) {
  if (!table[st]) die(`unknown stage ${st}`);
  const t0 = Date.now();
  log(`\n== ${st} ==`);
  table[st]();
  log(`== ${st} done in ${((Date.now() - t0) / 1000).toFixed(0)}s`);
}
