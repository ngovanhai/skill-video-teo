#!/usr/bin/env node
// Long-video pipeline: video.json -> ZeroTTS voice -> word timings -> per-scene compositions ->
// per-chapter render -> concat -> thumbnail -> publish notes. Every stage is resumable.
//   node kit/make.mjs <videoDir> [--stage all|scaffold|validate|tts|align|build|lint|render|thumb|publish|fxlog] [--only ch01,ch02] [--tts-local] [--align-local]
import { readFileSync, writeFileSync, existsSync, mkdirSync, copyFileSync, readdirSync, statSync, rmSync } from "node:fs";
import { join, resolve, basename } from "node:path";
import { spawnSync, spawn } from "node:child_process";
import { pathToFileURL } from "node:url";
import { KIT, Cues, wrapScene, r3, setTheme } from "./lib/base.mjs";
import { TEMPLATES } from "./scenes/index.mjs";
import { FX, sceneFx, CONTINUOUS_CAM } from "./fx/index.mjs";
import { captionGroups, captionsComposition } from "./lib/captions.mjs";
import { thumbnailHtml } from "./lib/thumbnail.mjs";
import { SFX_ON, sfxVol, bgmVol, syncSfx, isShort, LONG_MIN, ZEROTTS_PY, ZEROTTS_SCRIPT, colabThenLocal } from "./lib/mix.mjs";

const HF = "hyperframes@0.8.172";
const WHISPER_PY = process.env.WHISPER_PY || "__MUSE_ROOT__/.whisper/.venv/bin/python";
// GPU (AMD RX 6600 XT qua DirectML) cho align, thử 2026-10-20: align ~3× và ra y hệt CPU.
// Tắt: --no-gpu hoặc tạo file kit/gpu-off. GPU lỗi → tự chạy lại bằng CPU (cache giữ phần đã xong).
const WHISPER_DML_PY = process.env.WHISPER_DML_PY || "__WHISPER_DML_PY__"; // Windows: venv whisper-dml (install.mjs điền)
// TTS: chỉ ZeroTTS (người dùng chốt 2026-11-03) — trên Colab qua colab-tts.mjs, ở máy nhà bằng py/tts-zerotts.py; cùng job + cùng .key.
// Căn chữ cũng lên Colab: colab-tts.mjs --align chạy chính py/align.py trên GPU Colab, cùng key cache.
// Chỉ bản dài mới lên Colab (người dùng chốt 2026-10-24): short (thư mục …/shorts/…) và sửa ngắn (< LONG_MIN câu sau cache,
// colab-tts --min trả mã 75) làm luôn ở máy nhà. --tts-local / --align-local: luôn máy nhà.
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
const useGpu = (py) => !flag("no-gpu") && !existsSync(join(KIT, "gpu-off")) && existsSync(py);
// chạy bằng GPU trước; hỏng thì báo và chạy lại bằng CPU
const runGpu = (gpu, cpu) => {
  if (gpu && run(gpu.cmd, gpu.argv, { ...gpu.o, allowFail: true }) === 0) return;
  if (gpu) log("! GPU failed — retrying on CPU");
  run(cpu.cmd, cpu.argv, cpu.o);
};
const capture = (cmd, argv) => spawnSync(cmd, argv, { encoding: "utf8", cwd: dir }).stdout || "";

// ---------------------------------------------------------------- load
const vfile = join(dir, "video.json");
if (!existsSync(vfile)) die(`no video.json in ${dir}`);
const video = JSON.parse(readFileSync(vfile, "utf8"));
video.__dir = dir;
try { setTheme(video.theme); } catch (e) { die(e.message); }
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
  if (scenes[0]?.type !== "hook" && scenes[0]?.hook !== true) errs.push(`first scene must be a hook (type "hook", or any type with "hook": true)`);
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
    if (fxl.some((e) => e.id === "punch") && fxl.some((e) => CONTINUOUS_CAM.has(e.id))) warns.push(`${where}: punch + camera fx cùng tween scale của #fxcam — render rớt về chụp chậm; bỏ một cái`);
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

// the lines that tend to become a formula: greeting, mid-video subscribe call, closing scenes
const hasPhrase = (s, p) => (" " + plain(spoken(s)) + " ").includes(" " + plain(p) + " ");
function signatureLines() {
  const words = scenes.map((s) => spoken(s).split(" ").length), total = words.reduce((a, b) => a + b, 0) || 1;
  let acc = 0;
  const pos = scenes.map((s, i) => { const f = (acc + words[i] / 2) / total; acc += words[i]; return f; });
  // ~60 s of narration at 4.1 words/s, never fewer than the first 3 scenes
  let w = 0;
  const opening = scenes.filter((s, i) => { w += words[i]; return i < 3 || w - words[i] < 250; });
  const mid = scenes.filter((s, i) => pos[i] >= 0.25 && pos[i] <= 0.75);
  const sentence = (s, p) => (spoken(s).split(/(?<=[.!?…])\s+/).find((x) => plain(x).includes(plain(p))) || "").slice(0, 200);
  const g = opening.find((s) => hasPhrase(s, "lại là tèo"));
  const c = mid.find((s) => s.cta && hasPhrase(s, "đăng ký")) || mid.find((s) => hasPhrase(s, "đăng ký"));
  return { opening, mid, greeting: g ? sentence(g, "lại là tèo") : "", cta: c ? spoken(c).slice(0, 300) : "",
    ending: scenes.slice(-3).map(spoken).join(" ").slice(0, 600) };
}
// word-trigram overlap (Jaccard) — catches copied formulas, not shared topic words
function trigramSim(a, b) {
  const g = (x) => { const t = plain(x).split(" "), r = new Set(); for (let i = 0; i + 2 < t.length; i++) r.add(t.slice(i, i + 3).join(" ")); return r; };
  const A = g(a), B = g(b);
  if (!A.size || !B.size) return 0;
  let n = 0; for (const x of A) if (B.has(x)) n++;
  return n / (A.size + B.size - n);
}

// hook → greeting → mid-video subscribe → closing subscribe; fx density; no repeats of recent videos
function creativeChecks(warns) {
  const has = hasPhrase;
  const sig = signatureLines();
  if (!sig.opening.some((s) => has(s, "lại là tèo"))) warns.push(`greeting: say "lại là Tèo đây" somewhere in the first ~60 s (any wording, in the frame's voice)`);
  // opening invite (user rule 2026-11-05): right after the hook, ask for topic ideas in the comments + like + subscribe/follow
  const afterHook = scenes.findIndex((s, i) => i > 0 && s.type !== "hook" && s.hook !== true);
  const openTxt = " " + (afterHook > 0 ? plain(spoken(scenes[afterHook])) : "") + " ";
  const miss = [["bình luận"], ["like"], ["đăng ký", "theo dõi"]].filter((ps) => !ps.some((p) => openTxt.includes(" " + plain(p) + " "))).map((ps) => ps.join("/"));
  if (miss.length) warns.push(`invite: the scene right after the hook must ask viewers to comment who/what idea Tèo should cover next, and to like + subscribe — missing: ${miss.join(", ")}`);
  const mid = sig.mid;
  if (!mid.some((s) => has(s, "đăng ký"))) warns.push(`cta: no subscribe call ("đăng ký") in the middle of the video (25–75%) — add one with "cta": true`);
  if (!scenes.slice(-3).some((s) => has(s, "đăng ký"))) warns.push(`cta: the closing scenes (outro or the 2 before it) must ask viewers to subscribe ("đăng ký")`);
  for (const s of scenes) if (s.cta && !has(s, "đăng ký")) warns.push(`${s.id}: "cta": true but the narration never says "đăng ký"`);
  if (!video.target_min) return; // short tests / pilots skip the creativity rules
  const customs = scenes.filter((s) => s.type === "custom").length;
  if (customs < 3) warns.push(`creative: only ${customs} custom scene(s) — every video needs ≥3 hand-made SVG + GSAP scenes`);
  const withFx = scenes.filter((s) => s.type === "custom" || sceneFx(s).length).length;
  if (withFx < scenes.length / 4) warns.push(`creative: only ${withFx}/${scenes.length} scenes have fx or are custom — aim for ~1 in 3`);
  if (sceneFx(scenes[0]).length < 2) warns.push("creative: the hook scene should carry ≥2 fx");
  const narr = scenes.filter((s) => s.type === "narrator").length;
  if (narr > scenes.length * 0.2) warns.push(`creative: ${narr}/${scenes.length} narrator scenes (>20%) — let the frame carry the story (talk, custom, stat, list…)`);
  const triple = scenes.filter((s, i) => i >= 2 && scenes[i - 2].type === "custom" && scenes[i - 1].type === "narrator" && s.type === "moment").length;
  if (triple > 3) warns.push(`creative: the run custom → narrator → moment appears ${triple}× — vary the scene order`);
  for (const s of scenes) if (has(s, "ba câu hỏi")) warns.push(`${s.id}: "ba câu hỏi" is a worn-out formula — promise differently (or not at all)`);
  const c = video.creative || {};
  for (const k of ["style", "motif", "hook", "frame", "voice_role"]) if (!c[k]) warns.push(`creative: video.json "creative.${k}" is missing`);
  const all = readHistory().filter((h) => h.slug !== slugOf());
  const recent = all.slice(-2);
  for (const k of ["style", "motif", "hook"]) if (c[k] && recent.some((h) => plain(h.creative?.[k]) === plain(c[k]))) warns.push(`creative: creative.${k} "${c[k]}" repeats one of the last 2 videos`);
  if (c.frame && typeof c.frame === "object") frameChecks(warns, c, all);
  else if (c.frame) {
    warns.push(`creative: creative.frame is a bare name — analyse the raw script and design { name, analysis, axis, open, close, segments[] } (SKILL.md 2b)`);
    if (all.slice(-3).some((h) => plain(h.frame || h.creative?.frame) === plain(c.frame))) warns.push(`creative: creative.frame "${c.frame}" repeats one of the last 3 videos — pick another storytelling frame`);
  }
  if (c.voice_role && typeof c.frame !== "object" && all.slice(-2).some((h) => plain(h.voice_role || h.creative?.voice_role) === plain(c.voice_role))) warns.push(`creative: creative.voice_role "${c.voice_role}" repeats one of the last 2 videos`);
  const last5 = all.slice(-5);
  for (const k of ["greeting", "cta", "ending"]) {
    if (!sig[k]) continue;
    const hit = last5.find((h) => h[k] && trigramSim(sig[k], h[k]) > 0.7);
    const shared = last5.find((h) => h[k] && trigramSim(sig[k], h[k]) > 0.35);
    if (hit) warns.push(`creative: the ${k} line is almost a copy of "${hit.slug}" — rewrite it in this episode's voice`);
    else if (shared) warns.push(`creative: the ${k} line reuses phrasing from "${shared.slug}" — rewrite it in this episode's voice`);
  }
  const mine = new Set(scenes.flatMap((s) => sceneFx(s).map((e) => e.id)).filter((id) => id !== "subscribe"));
  const theirs = new Set(recent.flatMap((h) => Object.keys(h.fx || {})));
  const same = [...mine].filter((id) => theirs.has(id));
  if (mine.size && theirs.size && same.length / mine.size > 0.5) warns.push(`creative: ${same.length}/${mine.size} fx kinds also used in the last 2 videos (${same.join(", ")}) — swap some for less used ones`);
}

// creative.frame is designed per video from the raw script (no fixed list): { name, analysis, axis, open, close, segments[] }.
// Anti-repeat = similarity of name / axis / whole frame vs the last 3 videos; voice_role (free text) vs the last 2.
// Videos made before this rule have no frame object and keep the old checks above.
const frameName = (f) => (f && typeof f === "object" ? f.name || "" : f || "");
const frameSig = (f) => (f && typeof f === "object" ? [f.axis, f.open, f.close, ...(f.segments || [])].filter(Boolean).join(" | ") : "");
const wordSet = (x) => new Set(plain(x).split(" ").filter(Boolean));
const wordSim = (a, b) => { const A = wordSet(a), B = wordSet(b); if (!A.size || !B.size) return 0; let n = 0; for (const w of A) if (B.has(w)) n++; return n / (A.size + B.size - n); };
const triOverlap = (a, b) => { const g = (x) => { const t = plain(x).split(" ").filter(Boolean), r = new Set(); for (let i = 0; i + 2 < t.length; i++) r.add(t.slice(i, i + 3).join(" ")); return r; };
  const A = g(a), B = g(b); if (!A.size || !B.size) return 0; let n = 0; for (const x of A) if (B.has(x)) n++; return n / Math.min(A.size, B.size); };
function frameChecks(warns, c, all) {
  const f = c.frame;
  for (const k of ["name", "axis", "open", "close"]) if (!String(f[k] || "").trim()) warns.push(`creative: creative.frame.${k} is empty`);
  const aw = plain(f.analysis).split(" ").filter(Boolean).length;
  if (aw < 25) warns.push(`creative: creative.frame.analysis has ${aw} words — sum up the script analysis (core, emotion, strongest moment, who stands closest to tell it, what viewers want, natural blocks) and why this frame fits (≥25 words)`);
  const n = (f.segments || []).length;
  if (n < 5 || n > 12) warns.push(`creative: creative.frame.segments has ${n} entries — lay out the body as 6–10 segments, one sentence each`);
  const me = { name: frameName(f), axis: f.axis || "", sig: frameSig(f) };
  for (const h of all.slice(-3)) {
    const name = h.frame || frameName(h.creative?.frame), axis = h.frame_axis || h.creative?.frame?.axis || "", sig = h.frame_sig || frameSig(h.creative?.frame);
    if (name && wordSim(me.name, name) >= 0.6) warns.push(`creative: frame name "${me.name}" is close to "${h.slug}" ("${name}") — design a new frame from this script`);
    if (axis && wordSim(me.axis, axis) >= 0.6) warns.push(`creative: frame axis is close to "${h.slug}" ("${axis}") — order the body another way`);
    if (sig && triOverlap(me.sig, sig) >= 0.45) warns.push(`creative: frame (axis/open/close/segments) overlaps "${h.slug}" ${(triOverlap(me.sig, sig) * 100).toFixed(0)}% — rebuild it from this video's material`);
  }
  if (c.voice_role) { const h = all.slice(-2).find((x) => wordSim(c.voice_role, x.voice_role || x.creative?.voice_role) >= 0.6); if (h) warns.push(`creative: creative.voice_role "${c.voice_role}" is close to "${h.slug}" ("${h.voice_role || h.creative?.voice_role}")`); }
}

// record what this video used so the next ones avoid repeating it (publish calls this; builds never do)
function fxlog() {
  const count = {};
  for (const s of scenes) for (const e of sceneFx(s)) count[e.id] = (count[e.id] || 0) + 1;
  const sig = signatureLines(), t = video.thumbnail || {}, cr = video.creative || {};
  const entry = { slug: slugOf(), date: new Date().toISOString().slice(0, 10), title: video.title, creative: cr, fx: count,
    custom: scenes.filter((s) => s.type === "custom").map((s) => s.file),
    frame: frameName(cr.frame), frame_axis: cr.frame?.axis || "", frame_sig: frameSig(cr.frame), voice_role: cr.voice_role || "", theme: (typeof video.theme === "string" ? video.theme : video.theme?.preset) || "", greeting: sig.greeting, cta: sig.cta, ending: sig.ending,
    thumb: { pose: t.pose ?? null, bg: t.bg ?? null, circle_x: t.circle_x ?? null, circle_y: t.circle_y ?? null, arrow: t.arrow ?? null, layout: t.layout ?? null, text: t.text ?? t.hook ?? null } };
  const h = readHistory().filter((x) => x.slug !== entry.slug);
  h.push(entry);
  writeFileSync(HISTORY, JSON.stringify(h, null, 1));
  log(`fxlog: ${Object.keys(count).length} fx kinds, ${entry.custom.length} custom scenes → ${HISTORY}`);
}

function tts(subset = scenes) {
  const job = { voice: video.voice || "tiendat", lines: subset.map((s) => ({ id: s.id, text: spoken(s), out: wav(s) })) };
  writeFileSync(P("work/tts-job.json"), JSON.stringify(job, null, 1));
  // Chỉ ZeroTTS (người dùng chốt 2026-11-03): bản dài trên Colab; short / sửa ngắn / Colab thu hồi GPU ở máy nhà (luật chung colabThenLocal)
  const r = colabThenLocal(!flag("tts-local") && !isShort(dir) ? [P("work/tts-job.json"), "--min", String(LONG_MIN)] : null, () => {
    if (!existsSync(ZEROTTS_PY)) die(`không thấy ZeroTTS máy nhà: ${ZEROTTS_PY}`);
    return run(ZEROTTS_PY, [ZEROTTS_SCRIPT, P("work/tts-job.json")], { env: PYENV, allowFail: true });
  }, PYENV);
  if (r.st !== 0) die(r.colab ? "Colab TTS lỗi — xem bảng 'Lỗi Colab TTS' trong skill teo-kiem-hiep-godot, sửa rồi chạy lại; chỉ dùng --tts-local khi người dùng cho phép"
    : `tts-zerotts.py lỗi (${r.st})`);
}

function alignStage(subset = scenes) {
  const names = video.names || Object.values(video.cast).map((c) => c.name).filter(Boolean).join(", ");
  const job = { names, lines: subset.map((s) => ({ id: s.id, text: spoken(s), out: wav(s), words: wordsFile(s) })) };
  writeFileSync(P("work/align-job.json"), JSON.stringify(job, null, 1));
  const argv = [join(KIT, "py/align.py"), P("work/align-job.json"), video.whisper || "small"];
  const gpu = !process.env.WHISPER_PY && useGpu(WHISPER_DML_PY) && { cmd: WHISPER_DML_PY, argv, o: { env: { ...PYENV, WHISPER_DEVICE: "dml" } } };
  const colab = !flag("align-local") && !isShort(dir) ? ["--align", P("work/align-job.json"), video.whisper || "small", "--min", String(LONG_MIN)] : null;
  const r = colabThenLocal(colab, () => (runGpu(gpu, { cmd: WHISPER_PY, argv, o: {} }), 0), PYENV);
  if (r.st !== 0) die("Colab căn chữ lỗi — xem bảng 'Lỗi Colab TTS' trong skill teo-kiem-hiep-godot, sửa rồi chạy lại; chỉ dùng --align-local khi người dùng cho phép");
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
  const nSfx = syncSfx(P("assets/sfx")); // bản sfx êm (kit/sfx-soft.mjs) thay bản cũ đã chép lúc scaffold
  if (nSfx) log(`sfx: cập nhật ${nSfx} file từ kit/sfx (bản êm)`);
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
    s.sfx = SFX_ON ? sfx.filter((x) => x.t < s.dur - 0.1) : [];
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
      out.push(`      <audio id="el-${s.id}-fx${k}" src="assets/sfx/${fx.file}" data-start="${st}" data-duration="${d}" data-track-index="${12 + tr}" data-volume="${sfxVol(fx.vol)}"></audio>`);
    }
  }
  const len = chs.reduce((a, c) => a + c.dur, 0);
  out.push(`      <audio id="el-bgm" src="assets/bgm/bgm-full.mp3" data-start="0" data-media-start="${r3(global ? 0 : base)}" data-duration="${r3(len)}" data-track-index="11" data-volume="${BGM_VOL}"></audio>`);
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

let BGM_VOL = 0.05; // bgm() đặt lại theo độ to thật của bgm-full.mp3
function bgm(total) {
  const out = P("assets/bgm/bgm-full.mp3");
  // video.bgm: a file in kit/bgm, or a path relative to the video folder (e.g. "assets/my-track.mp3")
  const src = video.bgm && existsSync(join(dir, video.bgm)) ? join(dir, video.bgm) : join(KIT, "bgm", video.bgm || "playful-pizzicato.mp3");
  if (!existsSync(src)) die(`bgm not found: ${video.bgm}`);
  const stamp = P("assets/bgm/bgm-full.len");
  const len = r3(total + 1);
  if (!(existsSync(out) && existsSync(stamp) && readFileSync(stamp, "utf8") === `${src}|${total}`)) {
    run("ffmpeg", ["-y", "-v", "error", "-stream_loop", "-1", "-i", src, "-t", String(len), "-af", `afade=t=in:d=1.5,afade=t=out:st=${r3(len - 3)}:d=3`, "-c:a", "libmp3lame", "-b:a", "160k", out]);
    writeFileSync(stamp, `${src}|${total}`);
  }
  // nhạc nền luôn thấp hơn giọng ≥ 20 dB (kit/lib/mix.mjs): video.bgm_volume chỉ được nhỏ hơn mức đó, không được to hơn
  BGM_VOL = bgmVol(src, video.bgm_volume); // đo file gốc (cache cạnh file), bgm-full chỉ là bản lặp của nó
  log(`bgm: âm lượng ${BGM_VOL}${video.bgm_volume != null && BGM_VOL < video.bgm_volume ? ` (video.bgm_volume ${video.bgm_volume} quá to, đã hạ)` : ""}`);
}

// Những thứ làm hyperframes bỏ chụp nhanh (drawElement): filter/blend/3D/clip thì bị chặn từ đầu, còn callback
// thì làm khung đối chiếu (tua nhảy, không chạy callback) lệch khung chụp nhanh nên cả chương bị render lại.
const SLOW = [
  [/filter\s*:\s*[^;"]*(blur|drop-shadow)|mix-blend-mode|backdrop-filter|@keyframes/, "filter/blend/keyframes"],
  [/\b(clipPath|rotationX|rotationY|rotateX|rotateY)\s*:/, "tween clipPath/3D"],
  [/\b(onUpdate|onComplete|onStart)\s*:|\btl\.call\(/, "callback đổi hình"],
];
function lint() {
  run("npx", ["--yes", HF, "lint"], { allowFail: true });
  const dir2 = P("compositions"), hits = {};
  for (const f of existsSync(dir2) ? readdirSync(dir2) : []) {
    const src = readFileSync(join(dir2, f), "utf8");
    for (const [re, why] of SLOW) if (re.test(src)) (hits[why] ||= []).push(f.replace(/\.html$/, ""));
  }
  for (const [why, fs] of Object.entries(hits)) log(`⚠ render chậm (${why}): ${fs.slice(0, 12).join(", ")}${fs.length > 12 ? "…" : ""}. Xem README "Tốc độ render".`);
}

// Các chương render song song (--par N, mặc định 2; --low-memory thì 1). Chụp drawElement chỉ dùng 1 luồng
// mỗi tiến trình, nên 2 tiến trình cùng lúc tận dụng được 4 nhân. Thứ tự ghép final vẫn theo timeline.
async function render() {
  const timeline = JSON.parse(readFileSync(P("work/timeline.json"), "utf8"));
  const parts = [], jobs = [];
  for (const c of timeline) {
    const outFile = P("renders", `${c.id}.mp4`);
    parts.push(outFile);
    if (only.length && !only.includes(c.id)) continue;
    const src = statSync(P("work", `${c.id}.html`)).mtimeMs;
    if (existsSync(outFile) && statSync(outFile).mtimeMs > src && !flag("force")) { log(`render: ${c.id} up to date`); continue; }
    jobs.push(c);
  }
  const par = Math.max(1, Math.min(jobs.length, flag("low-memory") ? 1 : Number(opt("par", 2)) || 1));
  const one = (c) => new Promise((ok, fail) => {
    const t0 = Date.now();
    const argv = ["--yes", HF, "render", "--composition", `${c.id}.html`, "--output", `renders/${c.id}.mp4`, "--quality", opt("quality", "standard"), "--quiet"];
    if (flag("low-memory")) argv.push("--low-memory-mode");
    if (!flag("no-gpu")) argv.push("--gpu");
    copyFileSync(P("work", `${c.id}.html`), P(`${c.id}.html`));
    log(`$ npx ${argv.join(" ")}`);
    const ch = spawn("npx", argv, { stdio: "inherit", shell: process.platform === "win32", cwd: dir, env: PYENV });
    ch.on("error", (e) => { rmSync(P(`${c.id}.html`), { force: true }); fail(e); });
    ch.on("close", (code) => {
      rmSync(P(`${c.id}.html`), { force: true });
      if (code !== 0) return fail(new Error(`render ${c.id} failed (${code})`));
      log(`render: ${c.id} (${(c.dur / 60).toFixed(1)} min) took ${((Date.now() - t0) / 60000).toFixed(1)} min`);
      ok();
    });
  });
  if (jobs.length) log(`render: ${jobs.length} chapter(s), ${par} at a time`);
  let next = 0, err = null;
  await Promise.all(Array.from({ length: par }, async () => {
    while (!err && next < jobs.length) { const c = jobs[next++]; try { await one(c); } catch (e) { err = e; } }
  }));
  if (err) die(err.message);
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
  await table[st]();
  log(`== ${st} done in ${((Date.now() - t0) / 1000).toFixed(0)}s`);
}
