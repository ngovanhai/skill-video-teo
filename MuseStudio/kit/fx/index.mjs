// fx library: every kit/fx/*.mjs (except _*.mjs and this file) exports one fx or an array of them.
// A scene uses them with "fx": ["dust", {"id": "punch", "at": "cụm chữ"}].
import { readdirSync } from "node:fs";
import { dirname, join } from "node:path";
import { fileURLToPath, pathToFileURL } from "node:url";

const here = dirname(fileURLToPath(import.meta.url));
export const FX = {};
for (const f of readdirSync(here).filter((f) => f.endsWith(".mjs") && f !== "index.mjs" && !f.startsWith("_")).sort()) {
  const m = await import(pathToFileURL(join(here, f)).href);
  for (const e of [].concat(m.default || [])) {
    if (!e?.id || typeof e.run !== "function") throw new Error(`kit/fx/${f}: export { id, run } (or an array of them)`);
    if (FX[e.id]) throw new Error(`kit/fx/${f}: duplicate fx id "${e.id}"`);
    FX[e.id] = { cat: "other", label: "", ...e, file: f };
  }
}

// camera fx that drive the whole scene continuously — only one of these per scene
export const CONTINUOUS_CAM = new Set(["push-in", "pull-out", "pan", "handheld"]);

// normalise a scene's fx list (+ the automatic subscribe button for cta scenes)
export function sceneFx(s) {
  const list = [].concat(s.fx || []).map((e) => (typeof e === "string" ? { id: e } : { ...e }));
  if (s.cta && !list.some((e) => e.id === "subscribe")) list.push({ id: "subscribe" });
  return list;
}
