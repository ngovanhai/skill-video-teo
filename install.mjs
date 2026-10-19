#!/usr/bin/env node
// Cài 2 skill Claude Code "video-teo" + "teo-kiem-hiep" và kit MuseStudio. Chạy được trên macOS và Windows.
//   node install.mjs [--muse-root <thư mục>] [--vieneu-dir <thư mục>] [--gpu] [--skip-vieneu] [--no-env]
import { cpSync, mkdirSync, existsSync, readdirSync, statSync, readFileSync, writeFileSync, renameSync, copyFileSync, appendFileSync } from "node:fs";
import { join, resolve, dirname, extname } from "node:path";
import { fileURLToPath } from "node:url";
import { homedir } from "node:os";
import { spawnSync } from "node:child_process";

const HERE = dirname(fileURLToPath(import.meta.url));
const WIN = process.platform === "win32", MAC = process.platform === "darwin";
const args = process.argv.slice(2);
const opt = (k, d) => { const i = args.indexOf("--" + k); return i >= 0 ? args[i + 1] : d; };
const flag = (k) => args.includes("--" + k);
const fwd = (p) => resolve(p).replace(/\\/g, "/");
const MUSE = fwd(opt("muse-root", join(homedir(), "MuseStudio")));
const VIENEU = fwd(opt("vieneu-dir", join(dirname(MUSE), "VieNeu-TTS")));
const SKILLS = join(homedir(), ".claude", "skills");
const PY = WIN ? "python" : "python3";
const venvPy = (d) => join(d, WIN ? ".venv/Scripts/python.exe" : ".venv/bin/python");
const stamp = new Date().toISOString().replace(/[-:T]/g, "").slice(0, 15);
const step = (m) => console.log(`\n==> ${m}`);
const die = (m) => { console.error(`\nLỖI: ${m}`); process.exit(1); };
const has = (cmd) => spawnSync(cmd, [cmd === "ffmpeg" ? "-version" : "--version"], { stdio: "ignore" }).status === 0;
function run(cmd, argv, o = {}) {
  console.log(`  $ ${cmd} ${argv.join(" ")}`);
  const r = spawnSync(cmd, argv, { stdio: "inherit", ...o });
  if (r.status !== 0) die(`lệnh thất bại: ${cmd} ${argv.join(" ")}`);
}

step("Kiểm tra công cụ");
const HINT = WIN
  ? { ffmpeg: "winget install Gyan.FFmpeg", git: "winget install Git.Git", uv: "winget install astral-sh.uv" }
  : { ffmpeg: "brew install ffmpeg", git: "xcode-select --install  (hoặc brew install git)", uv: "brew install uv" };
const missing = Object.keys(HINT).filter((c) => !has(c));
missing.forEach((c) => console.log(`  THIẾU ${c}  ->  ${HINT[c]}`));
if (Number(process.versions.node.split(".")[0]) < 20) die("cần Node.js 20+ (https://nodejs.org)");
if (missing.length) die("cài các công cụ còn thiếu ở trên rồi chạy lại: node install.mjs");

step(`Chép kit MuseStudio -> ${MUSE}`);
mkdirSync(MUSE, { recursive: true });
for (const d of ["kit", "avatar"]) cpSync(join(HERE, "MuseStudio", d), join(MUSE, d), { recursive: true, force: true });
for (const d of ["ideas", "videos", "kiem-hiep"]) mkdirSync(join(MUSE, d), { recursive: true });
if (!existsSync(join(MUSE, "ideas/DA-LAM.md"))) copyFileSync(join(HERE, "MuseStudio/ideas/DA-LAM.md"), join(MUSE, "ideas/DA-LAM.md"));

step(`Cài skill vào ${SKILLS}`);
mkdirSync(SKILLS, { recursive: true });
for (const s of ["video-teo", "teo-kiem-hiep"]) {
  const dst = join(SKILLS, s);
  if (existsSync(dst)) { renameSync(dst, `${dst}.bak-${stamp}`); console.log(`  bản cũ -> ${s}.bak-${stamp}`); }
  cpSync(join(HERE, "skills", s), dst, { recursive: true });
}

if (!flag("skip-vieneu")) {
  step(`VieNeu-TTS -> ${VIENEU}`);
  if (!existsSync(venvPy(VIENEU))) {
    if (!existsSync(VIENEU)) run("git", ["clone", "https://github.com/pnnbao97/VieNeu-TTS.git", VIENEU]);
    run("git", ["-c", "advice.detachedHead=false", "checkout", "-q", "bd0f88e"], { cwd: VIENEU }); // bản đã chạy ổn với kit
    run("uv", flag("gpu") && !MAC ? ["sync", "--extra", "cuda"] : ["sync"], { cwd: VIENEU });
  } else console.log("  đã có .venv, bỏ qua");

  step("Giọng Lóng -> ~/.vieneu");
  const vh = process.env.VIENEU_HOME || join(homedir(), ".vieneu");
  const src = join(HERE, "vieneu/user_voices_v3_turbo.json"), dst = join(vh, "user_voices_v3_turbo.json");
  mkdirSync(vh, { recursive: true });
  if (!existsSync(dst)) copyFileSync(src, dst);
  else {
    copyFileSync(dst, `${dst}.bak-${stamp}`);
    const a = JSON.parse(readFileSync(dst, "utf8")), b = JSON.parse(readFileSync(src, "utf8"));
    a.presets = { ...(a.presets || {}), ...b.presets };
    writeFileSync(dst, JSON.stringify(a));
    console.log(`  đã gộp vào file giọng có sẵn (bản cũ: ${dst}.bak-${stamp})`);
  }
}

step("Whisper (căn thời gian chữ cho video-teo)");
let WHISPER = has(PY) && spawnSync(PY, ["-c", "import whisper"], { stdio: "ignore" }).status === 0 ? PY : null;
if (WHISPER) console.log(`  dùng ${PY} có sẵn whisper`);
else {
  const wd = join(MUSE, ".whisper");
  if (!existsSync(venvPy(wd))) run("uv", ["venv", "--python", "3.11", join(wd, ".venv")]);
  run("uv", ["pip", "install", "--python", venvPy(wd), "openai-whisper"]);
  WHISPER = fwd(venvPy(wd));
}

step("Điền đường dẫn vào skill + kit");
const TEXT = new Set([".md", ".mjs", ".js", ".py", ".json", ".txt", ".sh"]);
const walk = (d) => readdirSync(d).flatMap((f) => { const p = join(d, f); return statSync(p).isDirectory() ? walk(p) : [p]; });
let n = 0;
for (const root of [join(SKILLS, "video-teo"), join(SKILLS, "teo-kiem-hiep"), join(MUSE, "kit"), join(MUSE, "avatar")])
  for (const f of walk(root)) {
    if (!TEXT.has(extname(f))) continue;
    const s = readFileSync(f, "utf8");
    if (!/__(MUSE_ROOT|VIENEU_DIR|WHISPER_PY)__/.test(s)) continue;
    writeFileSync(f, s.replaceAll("__MUSE_ROOT__", MUSE).replaceAll("__VIENEU_DIR__", VIENEU).replaceAll("__WHISPER_PY__", WHISPER));
    n++;
  }
console.log(`  ${n} file`);

step("Biến môi trường MUSE_ROOT / VIENEU_DIR");
if (flag("no-env")) console.log("  bỏ qua (--no-env)");
else if (WIN) { run("setx", ["MUSE_ROOT", MUSE]); run("setx", ["VIENEU_DIR", VIENEU]); }
else {
  const rc = join(homedir(), MAC ? ".zshrc" : ".bashrc");
  const old = existsSync(rc) ? readFileSync(rc, "utf8") : "";
  if (!old.includes("# teo-skills")) appendFileSync(rc, `\n# teo-skills\nexport MUSE_ROOT="${MUSE}"\nexport VIENEU_DIR="${VIENEU}"\n`);
  console.log(`  đã ghi vào ${rc}`);
}

step("Kiểm tra");
run("node", [join(MUSE, "kit/fx-list.mjs")], { stdio: ["ignore", "ignore", "inherit"] });
console.log(`\nXONG. Mở terminal MỚI, cd "${MUSE}", chạy 'claude' rồi gõ /video-teo hoặc /teo-kiem-hiep.`);
