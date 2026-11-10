#!/usr/bin/env node
// Cài skill "teo-kiem-hiep-godot" (+ teo-kiem-hiep, chuong-2d, nhan-vat-chibi, thao-tac-chibi, kiem-tra-video, hoat-anh-kich-ban, tim-chu-de-ke) và phần MuseStudio nó cần, cho macOS.
//   node install.mjs [--muse-root <thư mục>] [--zerotts-dir <thư mục>] [--godot <đường dẫn Godot>] [--skip-zerotts] [--skip-colab] [--no-env] [--no-memory]
import { cpSync, mkdirSync, existsSync, readdirSync, statSync, readFileSync, writeFileSync, renameSync, copyFileSync, appendFileSync, rmSync } from "node:fs";
import { join, resolve, dirname, extname } from "node:path";
import { fileURLToPath } from "node:url";
import { homedir } from "node:os";
import { spawnSync } from "node:child_process";

const HERE = dirname(fileURLToPath(import.meta.url));
const MAC = process.platform === "darwin";
const args = process.argv.slice(2);
const opt = (k, d) => { const i = args.indexOf("--" + k); return i >= 0 ? args[i + 1] : d; };
const flag = (k) => args.includes("--" + k);
const MUSE = resolve(opt("muse-root", join(homedir(), "MuseStudio")));
const ZEROTTS = resolve(opt("zerotts-dir", join(homedir(), "Projects", "ZeroTTS-src")));
const ZEROTTS_VER = "0.1.5"; // bản kit đang chạy ổn
const SKILLS = join(homedir(), ".claude", "skills");
const SKILL_NAMES = ["teo-kiem-hiep-godot", "teo-kiem-hiep", "chuong-2d", "nhan-vat-chibi", "thao-tac-chibi", "kiem-tra-video", "hoat-anh-kich-ban", "tim-chu-de-ke"];
const GODOT_VER = "4.7.2";
const stamp = new Date().toISOString().replace(/[-:T]/g, "").slice(0, 15);
const step = (m) => console.log(`\n==> ${m}`);
const die = (m) => { console.error(`\nLỖI: ${m}`); process.exit(1); };
const has = (cmd, a = "--version") => spawnSync(cmd, [a], { stdio: "ignore" }).status === 0;
function run(cmd, argv, o = {}) {
  console.log(`  $ ${cmd} ${argv.join(" ")}`);
  const r = spawnSync(cmd, argv, { stdio: "inherit", ...o });
  if (r.status !== 0) die(`lệnh thất bại: ${cmd} ${argv.join(" ")}`);
}

if (!MAC) console.log("Cảnh báo: bộ này làm cho macOS. Máy khác vẫn chạy được nhưng phải tự chỉnh đường dẫn Godot/VieNeu.");

step("Kiểm tra công cụ");
const HINT = { ffmpeg: "brew install ffmpeg", git: "xcode-select --install  (hoặc brew install git)", uv: "brew install uv" };
const missing = Object.keys(HINT).filter((c) => !has(c, c === "ffmpeg" ? "-version" : "--version"));
missing.forEach((c) => console.log(`  THIẾU ${c}  ->  ${HINT[c]}`));
if (Number(process.versions.node.split(".")[0]) < 20) die("cần Node.js 20+ (brew install node)");
if (missing.length) die("cài các công cụ còn thiếu ở trên rồi chạy lại: node install.mjs");

step(`Godot ${GODOT_VER}`);
let GODOT = opt("godot", process.env.GODOT);
const cands = [GODOT, join(homedir(), `Applications/Godot_v${GODOT_VER}.app/Contents/MacOS/Godot`), `/Applications/Godot_v${GODOT_VER}.app/Contents/MacOS/Godot`,
  "/Applications/Godot.app/Contents/MacOS/Godot", join(homedir(), "Applications/Godot.app/Contents/MacOS/Godot")].filter(Boolean);
const ver = (g) => (spawnSync(g, ["--version"], { encoding: "utf8" }).stdout || "").trim();
GODOT = cands.find((g) => existsSync(g) && ver(g).startsWith(GODOT_VER));
if (!GODOT) {
  const other = cands.find((g) => existsSync(g));
  if (other) console.log(`  ${other} là bản ${ver(other) || "?"}, không phải ${GODOT_VER} -> tải bản ${GODOT_VER} riêng`);
  if (!MAC) die(`không thấy Godot ${GODOT_VER}; chạy lại với --godot <đường dẫn>`);
  const apps = join(homedir(), "Applications"), zip = join(apps, `godot-${GODOT_VER}.zip`), tmp = join(apps, `.godot-${GODOT_VER}`);
  mkdirSync(apps, { recursive: true });
  run("curl", ["-fL", "-o", zip, `https://github.com/godotengine/godot-builds/releases/download/${GODOT_VER}-stable/Godot_v${GODOT_VER}-stable_macos.universal.zip`]);
  rmSync(tmp, { recursive: true, force: true });
  run("ditto", ["-x", "-k", zip, tmp]);
  const app = readdirSync(tmp).find((f) => f.endsWith(".app")) || die("zip Godot không có .app");
  const dst = join(apps, `Godot_v${GODOT_VER}.app`);
  rmSync(dst, { recursive: true, force: true });
  renameSync(join(tmp, app), dst);
  rmSync(tmp, { recursive: true, force: true }); rmSync(zip, { force: true });
  spawnSync("xattr", ["-dr", "com.apple.quarantine", dst]);
  GODOT = join(dst, "Contents/MacOS/Godot");
}
console.log(`  ${GODOT}  (${ver(GODOT)})`);

step(`Chép MuseStudio -> ${MUSE}`);
const SRC = join(HERE, "..", "MuseStudio"); // kit, yt-auto và ảnh bìa dùng chung với bộ root trong cùng repo
if (!existsSync(SRC)) die(`không thấy ${SRC} — chép cả repo rồi chạy lại (đừng tách riêng thư mục kiem-hiep-godot-mac)`);
mkdirSync(MUSE, { recursive: true });
cpSync(join(SRC, "kit"), join(MUSE, "kit"), { recursive: true, force: true });
cpSync(join(HERE, "MuseStudio", "kiem-hiep"), join(MUSE, "kiem-hiep"), { recursive: true, force: true }); // _tools + tập mẫu (chỉ code)
cpSync(join(SRC, "yt-auto", "tools"), join(MUSE, "yt-auto", "tools"), { recursive: true, force: true }); // luật tiêu đề + từ khoá + độ cạnh tranh
mkdirSync(join(MUSE, "ideas"), { recursive: true });
if (!existsSync(join(MUSE, "ideas/DA-LAM.md"))) copyFileSync(join(SRC, "ideas/DA-LAM.md"), join(MUSE, "ideas/DA-LAM.md"));
for (const f of ["HOOK-MO-DAU.md", "TIEU-DE-ANH-BIA.md"]) if (!existsSync(join(MUSE, "ideas", f))) copyFileSync(join(SRC, "ideas", f), join(MUSE, "ideas", f));

step(`Cài skill vào ${SKILLS}`);
mkdirSync(SKILLS, { recursive: true });
for (const s of SKILL_NAMES) {
  const dst = join(SKILLS, s);
  if (existsSync(dst)) { renameSync(dst, `${dst}.bak-${stamp}`); console.log(`  bản cũ -> ${s}.bak-${stamp}`); }
  cpSync(join(HERE, "skills", s), dst, { recursive: true });
}

if (!flag("skip-zerotts")) {
  step(`ZeroTTS -> ${ZEROTTS}`);
  if (!existsSync(join(ZEROTTS, ".venv/bin/python"))) {
    mkdirSync(ZEROTTS, { recursive: true });
    run("uv", ["venv", "--python", "3.11", join(ZEROTTS, ".venv")]);
  } else console.log("  đã có .venv, bỏ qua");
  run("uv", ["pip", "install", "--python", join(ZEROTTS, ".venv/bin/python"), `zerotts==${ZEROTTS_VER}`, "scipy"]);
}

if (!flag("skip-colab")) {
  step("colab CLI (đọc giọng trên GPU Colab T4)");
  if (has("colab", "--help")) console.log("  đã có lệnh colab");
  else run("uv", ["tool", "install", "google-colab-cli==0.7.5"]);
}

step("Điền đường dẫn vào skill + MuseStudio");
const TEXT = new Set([".md", ".mjs", ".js", ".py", ".json", ".txt", ".sh", ".gd", ".godot", ".tscn"]);
const walk = (d) => readdirSync(d).flatMap((f) => { const p = join(d, f); return statSync(p).isDirectory() ? walk(p) : [p]; });
const WHISPER_PY = join(MUSE, ".whisper/.venv/bin/python");
const WHISPER_DML = join(dirname(MUSE), "whisper-dml/Scripts/python.exe");
const fill = (s) => s.replaceAll("__MUSE_ROOT__", MUSE).replaceAll("__ZEROTTS_DIR__", ZEROTTS).replaceAll("__WHISPER_PY__", WHISPER_PY)
  .replaceAll("__WHISPER_DML_PY__", WHISPER_DML).replaceAll("__GODOT__", GODOT).replaceAll("__SKILLS_DIR__", SKILLS);
let n = 0;
for (const root of [...SKILL_NAMES.map((s) => join(SKILLS, s)), join(MUSE, "kit"), join(MUSE, "kiem-hiep"), join(MUSE, "ideas"), join(MUSE, "yt-auto")])
  for (const f of walk(root)) {
    if (!TEXT.has(extname(f))) continue;
    const s = readFileSync(f, "utf8");
    if (!/__(MUSE_ROOT|ZEROTTS_DIR|WHISPER_PY|WHISPER_DML_PY|GODOT|SKILLS_DIR)__/.test(s)) continue;
    writeFileSync(f, fill(s)); n++;
  }
for (const f of walk(join(MUSE, "kiem-hiep/_tools")).concat(walk(SKILLS).filter((f) => SKILL_NAMES.some((s) => f.startsWith(join(SKILLS, s))))))
  if (f.endsWith(".sh")) spawnSync("chmod", ["+x", f]);
console.log(`  ${n} file`);

if (!flag("no-memory")) {
  // Claude Code lưu memory theo thư mục dự án: /Users/a/MuseStudio -> ~/.claude/projects/-Users-a-MuseStudio/memory
  const mdir = join(homedir(), ".claude/projects", MUSE.replace(/[^A-Za-z0-9]/g, "-"), "memory");
  step(`Memory luật làm tập -> ${mdir}`);
  mkdirSync(mdir, { recursive: true });
  const idxF = join(mdir, "MEMORY.md"), idx = existsSync(idxF) ? readFileSync(idxF, "utf8") : "";
  let add = "";
  for (const line of readFileSync(join(HERE, "memory/MEMORY.md"), "utf8").split("\n").filter(Boolean)) {
    const f = line.match(/\(([^)]+\.md)\)/)?.[1];
    if (!f || existsSync(join(mdir, f))) continue;
    writeFileSync(join(mdir, f), fill(readFileSync(join(HERE, "memory", f), "utf8")));
    if (!idx.includes(`(${f})`)) add += line + "\n";
  }
  if (add) appendFileSync(idxF, (idx && !idx.endsWith("\n") ? "\n" : "") + add);
  console.log(`  ${add.split("\n").filter(Boolean).length} memory mới`);
}

step("Biến môi trường MUSE_ROOT / ZEROTTS_DIR / GODOT");
if (flag("no-env")) console.log("  bỏ qua (--no-env)");
else {
  const rc = join(homedir(), MAC ? ".zshrc" : ".bashrc");
  const old = existsSync(rc) ? readFileSync(rc, "utf8") : "";
  const block = `# teo-kiem-hiep-godot\nexport MUSE_ROOT="${MUSE}"\nexport ZEROTTS_DIR="${ZEROTTS}"\nexport GODOT="${GODOT}"\nexport PATH="$HOME/.local/bin:$PATH"\n# /teo-kiem-hiep-godot\n`;
  const re = /# teo-kiem-hiep-godot\n[\s\S]*?# \/teo-kiem-hiep-godot\n/;
  writeFileSync(rc, re.test(old) ? old.replace(re, block) : old + "\n" + block);
  console.log(`  đã ghi vào ${rc}`);
}

step("Kiểm tra");
const env = { ...process.env, MUSE_ROOT: MUSE, ZEROTTS_DIR: ZEROTTS, GODOT };
run(GODOT, ["--headless", "--version"], { env });
for (const f of ["teo-kiem-hiep-godot/scripts/gd-check.mjs", "teo-kiem-hiep-godot/scripts/new-tap.mjs", "teo-kiem-hiep/scripts/gd-voice.mjs", "teo-kiem-hiep/scripts/gd-render.mjs"])
  run("node", ["--check", join(SKILLS, f)], { env });
console.log(`
XONG.
  1. Mở terminal MỚI.
  2. Đăng nhập Colab một lần (dán mã Google):  colab sessions
  3. cd "${MUSE}" && claude   rồi gõ  /teo-kiem-hiep-godot`);
