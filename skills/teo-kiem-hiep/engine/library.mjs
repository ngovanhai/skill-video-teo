// Loads the effect catalogue: engine/fx.mjs + engine/fx-extra/*.mjs (promoted effects) + <episode>/fx/*.mjs (local, id "local:<file>").
// A fx file default-exports one effect { cat, id?, label, run } or an array of them.
import { readdirSync, existsSync } from "fs";
import { join, basename } from "path";
import { pathToFileURL, fileURLToPath } from "url";
import { FX, THEMES } from "./fx.mjs";

const here = fileURLToPath(new URL(".", import.meta.url));
export const SKILL = join(here, "..");

async function loadDir(dir, idOf) {
  if (!existsSync(dir)) return [];
  const out = [];
  for (const f of readdirSync(dir).filter((f) => f.endsWith(".mjs")).sort()) {
    const m = await import(pathToFileURL(join(dir, f)).href);
    for (const e of [].concat(m.default || [])) {
      if (!e || typeof e.run !== "function" || !e.cat) throw new Error(`${join(dir, f)}: default export phải là { cat, label, run }`);
      out.push({ ...e, id: idOf(f, e), file: join(dir, f) });
    }
  }
  return out;
}

export async function loadLibrary(episodeDir) {
  const extra = await loadDir(join(SKILL, "engine/fx-extra"), (f, e) => e.id || basename(f, ".mjs"));
  const local = episodeDir ? await loadDir(join(episodeDir, "fx"), (f, e) => "local:" + (e.id || basename(f, ".mjs"))) : [];
  const all = [...FX, ...extra, ...local];
  const byId = Object.fromEntries(all.map((e) => [e.id, e]));
  const dup = all.map((e) => e.id).filter((id, i, a) => a.indexOf(id) !== i);
  if (dup.length) throw new Error("trùng id hiệu ứng: " + dup.join(", "));
  // planner candidates: catalogue + promoted only (local ones are the episode's own, never auto-picked)
  const byCat = {};
  for (const e of [...FX, ...extra]) (byCat[e.cat] ||= []).push(e);
  return { all, byId, byCat, local, THEMES };
}
