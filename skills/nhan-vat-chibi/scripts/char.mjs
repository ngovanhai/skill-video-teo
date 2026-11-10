// Nhân vật chibi rig2: xem kit, kiểm look, xuất sheet soi.
//   node char.mjs kit                  -> liệt kê preset / tóc / râu / mũ / vũ khí / da / biểu cảm / tư thế
//   node char.mjs list                 -> các nhân vật trong data/chars.json
//   node char.mjs look <id>            -> look rig2 đã gộp preset (JSON)
//   node char.mjs sheet <id> [--ve f]  -> work/<id>.png: toàn thân, 5 tư thế, 9 biểu cảm, thử 5 nền
//   node char.mjs lineup <id> <id>...  -> work/lineup.png: đứng cạnh nhau để so dáng, màu, chiều cao
import fs from "fs";
import path from "path";
import { spawnSync } from "child_process";
import { pathToFileURL } from "url";
import { SKILL, loadChars, lookOf, lint, posed, rig, POSES } from "./lib.mjs";

const [cmd, ...rest] = process.argv.slice(2);
const flag = (k) => { const i = rest.indexOf(k); return i < 0 ? null : rest.splice(i, 2)[1]; };
const WORK = path.join(SKILL, "work");
fs.mkdirSync(WORK, { recursive: true });
const CHROME = [process.env.CHROME, "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome", "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge", "/Applications/Chromium.app/Contents/MacOS/Chromium"].filter(Boolean).find((f) => fs.existsSync(f));

const EXPR = rig.EXPRS; // vui binh gian buon soc dac-y ngai quyet-tam ko
const POSE5 = [["rest", "binh"], ["palm", "quyet-tam"], ["raise", "dac-y"], ["guard", "soc"], ["crouch", "gian"]];
const BGS = [["đêm tím", "#2a1d4a"], ["hoàng hôn", "#a8443e"], ["tuyết", "#dfe8f0"], ["rừng", "#2f5a3a"], ["sa mạc", "#c9a46a"]];
let n = 0;
const fig = (look, w, pose, expr) => posed(`f${n++}`, w, look, pose, expr);
// cắt riêng đầu: đổi viewBox của svg toàn thân
const headOnly = (look, expr, size) => fig(look, 400, "rest", expr).replace(/viewBox="0 0 400 620" width="\d+" height="\d+" style="display:block;overflow:visible"/, `viewBox="60 45 280 300" width="${size}" height="${Math.round(size * 300 / 280)}" style="display:block"`);

function shoot(html, out, w, h) {
  if (!CHROME) { console.error("không tìm thấy Chrome/Edge để chụp; mở file html bằng trình duyệt"); return; }
  const f = out.replace(/\.png$/, ".html");
  fs.writeFileSync(f, html);
  spawnSync(CHROME, ["--headless=new", "--disable-gpu", "--hide-scrollbars", `--window-size=${w},${h}`, `--screenshot=${out}`, pathToFileURL(f).href], { stdio: "ignore" });
  console.log(fs.existsSync(out) ? out : "chụp lỗi: " + f);
}
const page = (body, w) => `<!doctype html><meta charset="utf-8"><style>
body{margin:0;width:${w}px;background:#8a8f99;font:600 18px "Segoe UI",sans-serif;color:#fff}
.row{display:flex;gap:10px;padding:10px 14px;align-items:flex-end}.cell{text-align:center;font-size:15px}
.box{display:flex;align-items:flex-end;justify-content:center;border-radius:10px;overflow:hidden}
h1{margin:0;font-size:30px}.sub{opacity:.85;font-weight:500;margin-top:4px}</style><body>${body}</body>`;

const C = loadChars();
const need = (id) => { if (!C[id]) { console.error(`không có "${id}". Có: ${Object.keys(C).join(", ")}`); process.exit(1); } };

if (cmd === "kit") {
  console.log("preset :", Object.entries(rig.PRESETS).map(([k, v]) => `${k}(${v.robe})`).join("  "));
  console.log("tóc    :", Object.keys(rig.KIT.HAIR).join(", "));
  console.log("râu    : rau-de (chòm cằm), rau-dai (dài + ria), ria (ria mép)");
  console.log("mũ     : non-la, khan, linh, troc (chấm giới đầu trọc), tram (trâm)");
  console.log("vũ khí :", rig.WEAPONS.join(", "), "| hand F|B | sheath:true (đeo lưng)");
  console.log("da     :", Object.entries(rig.SKIN).map(([k, v]) => `${k} ${v}`).join(", "));
  console.log("khác   : robe robe2(cổ áo) pants belt boots sash(dải chéo) band(khăn trán+đuôi) eyes eyes2 glasses age:'gia' skirt fem oneArm flaps:false");
  console.log("biểu cảm:", EXPR.join(", "));
  console.log("tư thế :", Object.keys(POSES).join(", "));
} else if (cmd === "list") {
  for (const [id, c] of Object.entries(C)) console.log(`${id.padEnd(16)} ${c.name.padEnd(18)} ${(c.truyen || "").padEnd(22)} ${c.note || ""}`);
} else if (cmd === "look") {
  need(rest[0]); console.log(JSON.stringify(lookOf(rest[0], C), null, 1));
} else if (cmd === "sheet") {
  const id = rest[0]; need(id);
  const errs = lint(id, C); if (errs.length) { console.error(id + ":\n  " + errs.join("\n  ")); process.exit(1); }
  const look = lookOf(id, C);
  const ve = flag("--ve");
  if (ve) look.ve = (await import(pathToFileURL(path.resolve(ve)).href)).default;
  const c = C[id];
  const meta = `${c.truyen || ""} · ${c.note || ""} · ${c.look.preset ? "preset " + c.look.preset : "tự phối"}`;
  const body =
    `<div class="row" style="align-items:stretch">
      <div class="box" style="width:330px;height:480px;background:#5d6470;flex-direction:column;align-items:center;justify-content:space-between;padding:12px 0">
        <div><h1>${c.name}</h1><div class="sub">${id}</div></div>${fig(look, 260, "rest", "binh")}</div>
      ${POSE5.map(([p, e]) => `<div class="cell"><div class="box" style="width:260px;height:440px;background:#6b7280;padding-bottom:6px">${fig(look, 230, p, e)}</div>${p} · ${e}</div>`).join("")}
    </div>
    <div class="row sub" style="padding-top:0">${meta}</div>
    <div class="row">${EXPR.map((e) => `<div class="cell"><div class="box" style="width:168px;height:180px;background:#5d6470;align-items:center">${headOnly(look, e, 160)}</div>${e}</div>`).join("")}</div>
    <div class="row">${BGS.map(([nm, bg]) => `<div class="cell"><div class="box" style="width:300px;height:250px;background:${bg};padding-bottom:6px">${fig(look, 140, "rest", "binh")}</div>${nm}</div>`).join("")}</div>`;
  shoot(page(body, 1720), path.join(WORK, `${id}.png`), 1720, 1150);
} else if (cmd === "lineup") {
  rest.forEach(need);
  const body = `<div class="row" style="background:#5d6470;justify-content:center;gap:24px;padding:20px">${rest.map((id) => `<div class="cell">${fig(lookOf(id, C), 230, "rest", "binh")}<div>${C[id].name}</div></div>`).join("")}</div>`;
  const w = Math.max(700, rest.length * 260 + 60);
  shoot(page(body, w), path.join(WORK, "lineup.png"), w, 460);
} else {
  console.log(fs.readFileSync(new URL(import.meta.url), "utf8").split("\n").slice(0, 7).join("\n"));
}
