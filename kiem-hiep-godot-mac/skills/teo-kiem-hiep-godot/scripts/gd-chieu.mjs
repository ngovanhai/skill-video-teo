// Đưa chiêu đã làm xong bằng skill chuong-2d vào tập: chép engine + chiêu + nhân vật vào <tap>/godot/chuong/ (đổi đường res://),
// chép cầu nối chieu.gd và sfx còn thiếu. Chạy lại sau khi sửa chiêu bên chuong-2d để cập nhật bản trong tập.
//   node <SKILL>/scripts/gd-chieu.mjs <tap> <id chiêu> [id …]
import { existsSync, mkdirSync, readFileSync, writeFileSync, copyFileSync, readdirSync } from "node:fs";
import { join, resolve, dirname } from "node:path";
import { homedir } from "node:os";
import { fileURLToPath } from "node:url";

const HERE = dirname(fileURLToPath(import.meta.url));
const ENG = join("__SKILLS_DIR__", "chuong-2d/engine");
const MOVES = join("__SKILLS_DIR__", "chuong-2d/data/moves.json");
const die = (m) => { console.error("gd-chieu: " + m); process.exit(1); };
const [tapArg, ...ids] = process.argv.slice(2);
if (!tapArg || !ids.length) die("dùng: gd-chieu.mjs <tap> <id chiêu> [id …]");
const G = join(resolve(tapArg), "godot");
if (!existsSync(join(G, "project.godot"))) die(`không có ${G}/project.godot (chạy new-tap trước)`);

const book = existsSync(MOVES) ? JSON.parse(readFileSync(MOVES, "utf8")) : [];
const logged = new Set((Array.isArray(book) ? book : Object.values(book)).map((m) => m.id));
for (const id of ids) {
  if (!existsSync(join(ENG, "moves", id + ".gd"))) die(`chuong-2d chưa có chiêu "${id}" (làm bằng skill chuong-2d trước)`);
  if (!logged.has(id)) die(`chiêu "${id}" chưa ghi sổ chuong-2d/data/moves.json (chưa đạt checklist của chuong-2d)`);
}

const C = join(G, "chuong");
for (const d of [C, join(C, "moves"), join(C, "chars"), join(G, "sfx")]) mkdirSync(d, { recursive: true });
const fix = (s) => s.replace(/res:\/\/(engine\.gd|chibi\.gd|chars\/)/g, "res://chuong/$1");
const put = (src, dst) => writeFileSync(dst, fix(readFileSync(src, "utf8")));

put(join(ENG, "engine.gd"), join(C, "engine.gd"));
put(join(ENG, "chibi.gd"), join(C, "chibi.gd"));
for (const id of ids) put(join(ENG, "moves", id + ".gd"), join(C, "moves", id + ".gd"));
for (const f of readdirSync(join(ENG, "chars"))) if (f.endsWith(".json")) copyFileSync(join(ENG, "chars", f), join(C, "chars", f));
copyFileSync(join(HERE, "chieu.gd"), join(C, "chieu.gd"));
let n = 0;
for (const f of readdirSync(join(ENG, "sfx"))) if (/^lib-.*\.mp3$/.test(f) && !existsSync(join(G, "sfx", f))) { copyFileSync(join(ENG, "sfx", f), join(G, "sfx", f)); n++; }

// chiêu được thiết kế trên renderer Forward+ (glow HDR 2D): gl_compatibility làm màu nhạt, ngả tím, glow yếu → đổi project sang forward_plus
// (phần 2D thường của tập không đổi màu: đã so 56 dB)
const pp = join(G, "project.godot");
const pg = readFileSync(pp, "utf8").replace(/"gl_compatibility"/g, '"forward_plus"');
writeFileSync(pp, pg);

// ghi id chiêu vào story.json
const sp = join(G, "story.json");
if (existsSync(sp)) {
  const st = JSON.parse(readFileSync(sp, "utf8"));
  st.chieu = [...new Set([...(st.chieu || []), ...ids])];
  writeFileSync(sp, JSON.stringify(st, null, 2));
}
console.log(`gd-chieu: ${ids.join(", ")} → ${C} (thêm ${n} sfx). Dùng trong phim.gd: preload("res://chuong/chieu.gd").new("<id>", <giây bắt đầu>)`);
