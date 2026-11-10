#!/usr/bin/env node
// Cài 13 skill Claude Code (video-teo, teo-kiem-hiep, teo-kiem-hiep-godot, chuong-2d, nhan-vat-chibi, thao-tac-chibi, kiem-tra-video, hoat-anh-kich-ban, tim-chu-de-ke) và kit MuseStudio. Chạy được trên macOS và Windows.
//   node install.mjs [--muse-root <thư mục>] [--zerotts-dir <thư mục>] [--godot-dir <thư mục>] [--godot <file chạy Godot có sẵn>]
//                    [--skip-zerotts] [--skip-godot] [--no-env]
import { cpSync, mkdirSync, existsSync, readdirSync, statSync, readFileSync, writeFileSync, renameSync, copyFileSync, appendFileSync, rmSync } from "node:fs";
import { join, resolve, dirname, extname } from "node:path";
import { fileURLToPath } from "node:url";
import { homedir } from "node:os";
import { spawnSync } from "node:child_process";
import { createHash } from "node:crypto";

const HERE = dirname(fileURLToPath(import.meta.url));
const WIN = process.platform === "win32", MAC = process.platform === "darwin";
const args = process.argv.slice(2);
const opt = (k, d) => { const i = args.indexOf("--" + k); return i >= 0 ? args[i + 1] : d; };
const flag = (k) => args.includes("--" + k);
const fwd = (p) => resolve(p).replace(/\\/g, "/");
const MUSE = fwd(opt("muse-root", join(homedir(), "MuseStudio")));
const ZEROTTS = fwd(opt("zerotts-dir", join(homedir(), "Projects", "ZeroTTS-src")));
const ZEROTTS_VER = "0.1.5"; // bản kit đang chạy ổn
const WHISPER_DML = fwd(opt("whisper-dml-py", join(dirname(MUSE), "whisper-dml/Scripts/python.exe"))); // Windows + DirectML (tuỳ chọn)
const GODOT_DIR = fwd(opt("godot-dir", join(dirname(MUSE), "Godot")));
const GODOT_VER = "4.7.2-stable"; // bản các skill Godot đã chạy ổn
const SKILLS = ["video-teo", "teo-kiem-hiep", "teo-kiem-hiep-godot", "chuong-2d", "nhan-vat-chibi", "thao-tac-chibi", "kiem-tra-video", "hoat-anh-kich-ban", "tim-chu-de-ke", "art-director-2d", "cinematic-scene-2d", "godot-visual-effects", "godot-visual-review"];
const SKILL_DIRS = [
  join(homedir(), ".claude", "skills"),
  join(homedir(), ".gemini", "config", "skills"),
  join(homedir(), ".config", "opencode", "skills"),
  join(homedir(), ".agents", "skills"),
];
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
for (const f of ["HOOK-MO-DAU.md", "TIEU-DE-ANH-BIA.md"]) if (!existsSync(join(MUSE, "ideas", f))) copyFileSync(join(HERE, "MuseStudio/ideas", f), join(MUSE, "ideas", f));
cpSync(join(HERE, "MuseStudio/yt-auto/tools"), join(MUSE, "yt-auto/tools"), { recursive: true, force: true }); // luật tiêu đề + từ khoá + độ cạnh tranh
mkdirSync(join(MUSE, "kiem-hiep/_tmp"), { recursive: true });
cpSync(join(HERE, "MuseStudio/kiem-hiep/_tools"), join(MUSE, "kiem-hiep/_tools"), { recursive: true, force: true });
const SAMPLE = "kiem-hiep/tap-01-tieu-phong-vs-quach-tinh/godot"; // tập mẫu Godot (không kèm voice/nhạc); có rồi thì giữ nguyên
if (!existsSync(join(MUSE, SAMPLE))) cpSync(join(HERE, "MuseStudio", SAMPLE), join(MUSE, SAMPLE), { recursive: true });

for (const skillsRoot of SKILL_DIRS) {
  step(`Cài skill vào ${skillsRoot}`);
  mkdirSync(skillsRoot, { recursive: true });
  for (const s of SKILLS) {
    const dst = join(skillsRoot, s);
    if (existsSync(dst)) { renameSync(dst, `${dst}.bak-${stamp}`); console.log(`  bản cũ -> ${s}.bak-${stamp}`); }
    cpSync(join(HERE, "skills", s), dst, { recursive: true });
  }
}

if (!flag("skip-zerotts")) {
  step(`ZeroTTS -> ${ZEROTTS}`);
  if (!existsSync(venvPy(ZEROTTS))) {
    mkdirSync(ZEROTTS, { recursive: true });
    run("uv", ["venv", "--python", "3.11", join(ZEROTTS, ".venv")]);
  } else console.log("  đã có .venv, bỏ qua");
  // tts-zerotts.py đọc bằng CPU (model int8 nếu có sẵn trong <ZEROTTS>/models, không thì để zerotts tự tải weights từ HuggingFace)
  run("uv", ["pip", "install", "--python", venvPy(ZEROTTS), `zerotts==${ZEROTTS_VER}`, "scipy"]);
}

if (!flag("skip-colab")) {
  step("colab CLI (đọc giọng + căn chữ bản dài trên GPU Colab T4)");
  if (has("colab", "--help")) console.log("  đã có lệnh colab");
  else run("uv", ["tool", "install", "google-colab-cli==0.7.5"]);
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

step(`Godot ${GODOT_VER} -> ${GODOT_DIR}`);
const GODOT_ZIP = WIN ? `Godot_v${GODOT_VER}_win64.exe.zip` : MAC ? `Godot_v${GODOT_VER}_macos.universal.zip` : `Godot_v${GODOT_VER}_linux.x86_64.zip`;
const GODOT_BIN = WIN ? `Godot_v${GODOT_VER}_win64_console.exe` : MAC ? "Godot.app/Contents/MacOS/Godot" : `Godot_v${GODOT_VER}_linux.x86_64`;
const GODOT = fwd(opt("godot", join(GODOT_DIR, GODOT_BIN)));
if (flag("skip-godot")) console.log("  bỏ qua (--skip-godot)");
else if (existsSync(GODOT)) console.log(`  đã có ${GODOT}`);
else {
  const base = `https://github.com/godotengine/godot/releases/download/${GODOT_VER}/`;
  const get = async (u) => { const r = await fetch(u); if (!r.ok) die(`tải thất bại (${r.status}): ${u}`); return Buffer.from(await r.arrayBuffer()); };
  console.log(`  tải ${base}${GODOT_ZIP}`);
  const [zip, sums] = await Promise.all([get(base + GODOT_ZIP), get(base + "SHA512-SUMS.txt")]);
  const want = sums.toString().split("\n").find((l) => l.trim().endsWith(GODOT_ZIP))?.split(/\s+/)[0];
  const got = createHash("sha512").update(zip).digest("hex");
  if (!want || want !== got) die(`SHA512 của ${GODOT_ZIP} không khớp, không cài`);
  mkdirSync(GODOT_DIR, { recursive: true });
  const zp = join(GODOT_DIR, GODOT_ZIP);
  writeFileSync(zp, zip);
  // tar của Windows (bsdtar) và macOS giải được zip; Git Bash có tar GNU không giải được nên gọi thẳng System32
  if (WIN) run(join(process.env.SystemRoot || "C:/Windows", "System32", "tar.exe"), ["-xf", zp, "-C", GODOT_DIR]);
  else if (MAC) run("ditto", ["-x", "-k", zp, GODOT_DIR]);
  else { run("unzip", ["-o", "-q", zp, "-d", GODOT_DIR]); run("chmod", ["+x", GODOT]); }
  if (!existsSync(GODOT)) die(`giải nén xong mà không thấy ${GODOT}`);
  rmSync(zp);
}

step("ffmpeg");
const whichCmd = spawnSync(WIN ? "where" : "which", ["ffmpeg"], { encoding: "utf8" });
const FFMPEG = whichCmd.status === 0 ? fwd(whichCmd.stdout.split(/\r?\n/)[0].trim()) : "ffmpeg";
console.log(`  ${FFMPEG}`);

step("Điền đường dẫn vào skill + kit");
const TEXT = new Set([".md", ".mjs", ".js", ".py", ".json", ".txt", ".sh"]);
const walk = (d) => readdirSync(d).flatMap((f) => { const p = join(d, f); return statSync(p).isDirectory() ? walk(p) : [p]; });
let n = 0;
const skillRoots = SKILL_DIRS.flatMap((dir) => SKILLS.map((s) => join(dir, s))).filter(existsSync);
// __SKILLS_DIR__ = thư mục skills đang cài skill này (mỗi máy một khác: ~/.claude/skills, ~/.gemini/config/skills…)
const sdOf = (root) => SKILL_DIRS.find((d) => root.startsWith(d + "/") || root.startsWith(d + "\\")) || SKILL_DIRS[0];
const fill = (s, sd) => s.replaceAll("__MUSE_ROOT__", MUSE).replaceAll("__ZEROTTS_DIR__", ZEROTTS).replaceAll("__WHISPER_PY__", WHISPER)
  .replaceAll("__WHISPER_DML_PY__", WHISPER_DML).replaceAll("__GODOT__", GODOT).replaceAll("__FFMPEG__", FFMPEG).replaceAll("__SKILLS_DIR__", sd);
for (const root of [...skillRoots, join(MUSE, "kit"), join(MUSE, "avatar"), join(MUSE, "kiem-hiep/_tools"), join(MUSE, "ideas"), join(MUSE, "yt-auto")])
  for (const f of walk(root)) {
    if (!TEXT.has(extname(f))) continue;
    const s = readFileSync(f, "utf8");
    if (!/__(MUSE_ROOT|ZEROTTS_DIR|WHISPER_PY|WHISPER_DML_PY|GODOT|FFMPEG|SKILLS_DIR)__/.test(s)) continue;
    writeFileSync(f, fill(s, sdOf(root)));
    n++;
  }
console.log(`  ${n} file`);

step("Biến môi trường MUSE_ROOT / ZEROTTS_DIR");
if (flag("no-env")) console.log("  bỏ qua (--no-env)");
else if (WIN) { run("setx", ["MUSE_ROOT", MUSE]); run("setx", ["ZEROTTS_DIR", ZEROTTS]); }
else {
  const rc = join(homedir(), MAC ? ".zshrc" : ".bashrc");
  const old = existsSync(rc) ? readFileSync(rc, "utf8") : "";
  if (!old.includes("# teo-skills")) appendFileSync(rc, `\n# teo-skills\nexport MUSE_ROOT="${MUSE}"\nexport ZEROTTS_DIR="${ZEROTTS}"\n`);
  console.log(`  đã ghi vào ${rc}`);
}

step("Kiểm tra");
run("node", [join(MUSE, "kit/fx-list.mjs")], { stdio: ["ignore", "ignore", "inherit"] });
if (!flag("skip-godot")) run(GODOT, ["--version"]);
const opencodeCmds = join(homedir(), ".config", "opencode", "commands");
if (existsSync(dirname(opencodeCmds))) {
  mkdirSync(opencodeCmds, { recursive: true });
  writeFileSync(join(opencodeCmds, "video-teo.md"), `---
description: Sản xuất video YouTube hoạt hình 2D tiếng Việt dài >20 phút do Tèo dẫn (| Tèo Kể)
---

Sản xuất video Tèo theo yêu cầu sau:

$ARGUMENTS

Thực hiện theo đúng quy trình và nguyên tắc trong skill \`video-teo\` tại kit \`${MUSE}/kit\`.
`);
  writeFileSync(join(opencodeCmds, "teo-kiem-hiep.md"), `---
description: Sản xuất video hoạt hình 2D dài (≥20 phút) về kiếm hiệp Kim Dung, Cổ Long... do Tèo dẫn
---

Sản xuất video Tèo Kiếm Hiệp theo yêu cầu sau:

$ARGUMENTS

Thực hiện theo đúng quy trình và nguyên tắc trong skill \`teo-kiem-hiep\` tại \`${MUSE}\`.
`);
}

console.log(`\nXONG. Mở terminal MỚI, cd "${MUSE}", chạy Claude, Antigravity hoặc OpenCode rồi gõ /video-teo, /teo-kiem-hiep hoặc /teo-kiem-hiep-godot.`);
