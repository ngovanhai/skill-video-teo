// TEMPLATE — copy to <video>/work/gen-chars.mjs, edit the `chars` map, run: node work/gen-chars.mjs
// Kit style: 300x420, #111 stroke 6, flat fill, mouth-closed/mouth-open groups, <4 KB, no <text>.
import { writeFileSync, statSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";
const OUT = join(dirname(fileURLToPath(import.meta.url)), "..", "chars");
const S = `stroke="#111" stroke-width="6" stroke-linejoin="round"`;
const SKIN = "#FFD9B8";

function person(o) {
  const robe = o.robe || "#E2483D", sleeve = o.sleeve || robe;
  const p = [];
  if (o.back) p.push(o.back);
  if (o.bun) p.push(`<circle cx="150" cy="58" r="30" fill="#2A1A12" ${S}/>`);
  if (o.longHair) p.push(`<path d="M66 150 Q52 260 90 300 L210 300 Q248 260 234 150 Z" fill="#2A1A12" ${S}/>`);
  p.push(`<path d="M100 235 Q150 222 200 235 L228 400 Q150 414 72 400 Z" fill="${robe}" ${S}/>`);
  if (o.belt) p.push(`<rect x="86" y="300" width="128" height="22" rx="6" fill="${o.belt}" ${S}/>`);
  if (o.chest) p.push(o.chest);
  p.push(`<ellipse cx="88" cy="300" rx="18" ry="44" transform="rotate(14 88 300)" fill="${sleeve}" ${S}/><circle cx="78" cy="344" r="15" fill="${SKIN}" ${S}/>`);
  p.push(`<ellipse cx="212" cy="300" rx="18" ry="44" transform="rotate(-14 212 300)" fill="${sleeve}" ${S}/><circle cx="222" cy="344" r="15" fill="${SKIN}" ${S}/>`);
  p.push(`<circle cx="150" cy="145" r="88" fill="${SKIN}" ${S}/>`);
  if (o.hair) p.push(o.hair);
  if (o.hat) p.push(o.hat);
  const ey = o.eyeY || 150;
  p.push(`<circle cx="120" cy="${ey}" r="9" fill="#111"/><circle cx="180" cy="${ey}" r="9" fill="#111"/><circle cx="123" cy="${ey - 4}" r="3" fill="#fff"/><circle cx="183" cy="${ey - 4}" r="3" fill="#fff"/>`);
  if (o.brows) p.push(o.brows);
  p.push(`<circle cx="100" cy="182" r="11" fill="#FE90E8" opacity=".55"/><circle cx="200" cy="182" r="11" fill="#FE90E8" opacity=".55"/>`);
  if (o.beard) p.push(o.beard);
  p.push(`<g id="mouth-closed"><path d="M132 194 Q150 208 168 194" fill="none" stroke="#111" stroke-width="6" stroke-linecap="round"/></g>`);
  p.push(`<g id="mouth-open" opacity="0"><ellipse cx="150" cy="200" rx="15" ry="12" fill="#7A1626" stroke="#111" stroke-width="5"/></g>`);
  if (o.mustache) p.push(o.mustache);
  if (o.prop) p.push(o.prop);
  return p.join("\n");
}

// hair / hats
const femaleHair = `<path d="M62 142 Q58 58 150 54 Q242 58 238 142 Q214 98 150 96 Q86 98 62 142 Z" fill="#2A1A12" ${S}/>`;
const turban = (c) => `<path d="M64 116 Q150 64 236 116 L230 90 Q150 36 70 90 Z" fill="${c}" ${S}/>`;
const maleKhan = (c) => `<path d="M62 130 Q60 52 150 50 Q240 52 238 130 Q200 96 150 98 Q100 96 62 130 Z" fill="${c}" ${S}/><path d="M74 108 Q150 80 226 108" fill="none" stroke="#111" stroke-width="4"/>`;
const hanHat = (c) => `<path d="M70 112 Q150 76 230 112 L226 92 Q150 58 74 92 Z" fill="#222" ${S}/><path d="M112 82 L112 26 L188 26 L188 82 Q150 70 112 82 Z" fill="${c}" ${S}/><rect x="98" y="20" width="104" height="14" rx="6" fill="#222" ${S}/>`;
const helmet = (c, plume = "#E2483D") => `<path d="M60 128 Q58 44 150 42 Q242 44 240 128 Q200 102 150 104 Q100 102 60 128 Z" fill="${c}" ${S}/><path d="M150 42 L150 14" stroke="#111" stroke-width="6"/><path d="M150 18 Q176 2 196 20 Q172 22 150 30 Z" fill="${plume}" ${S}/>`;
const crown = `<path d="M76 104 Q150 74 224 104 L218 86 Q150 56 82 86 Z" fill="#222" ${S}/><rect x="70" y="40" width="160" height="24" rx="4" fill="#222" ${S}/><path d="M118 64 L118 88 M150 64 L150 84 M182 64 L182 88" stroke="#F7CB46" stroke-width="6"/><path d="M84 64 L84 104 M216 64 L216 104" stroke="#F7CB46" stroke-width="6"/>`;
const phoenix = `<path d="M76 104 Q150 66 224 104 L216 82 Q150 44 84 82 Z" fill="#F7CB46" ${S}/><path d="M150 60 L136 22 L150 34 L164 22 Z" fill="#E2483D" ${S}/>`;

// props held in the right hand (x≈222,y≈344)
const sword = `<path d="M226 336 L262 196" stroke="#111" stroke-width="16" stroke-linecap="round"/><path d="M226 336 L262 196" stroke="#D9DEE3" stroke-width="8" stroke-linecap="round"/><path d="M208 322 L244 334" stroke="#111" stroke-width="10" stroke-linecap="round"/>`;
const spear = (tip = "#D9DEE3") => `<path d="M236 400 L236 150" stroke="#111" stroke-width="14"/><path d="M236 400 L236 150" stroke="#8B5A2B" stroke-width="6"/><path d="M236 104 L254 156 L218 156 Z" fill="${tip}" ${S}/>`;
const bow = `<path d="M244 230 Q290 316 244 400" fill="none" stroke="#8B5A2B" stroke-width="10"/><path d="M244 230 L244 400" stroke="#111" stroke-width="3"/>`;
const oar = `<path d="M240 400 L240 190" stroke="#111" stroke-width="14"/><path d="M240 400 L240 190" stroke="#8B5A2B" stroke-width="6"/><ellipse cx="240" cy="176" rx="20" ry="44" fill="#8B5A2B" ${S}/>`;
const scroll = `<rect x="60" y="318" width="64" height="48" rx="6" fill="#FFF3D6" ${S}/><path d="M72 332 L112 332 M72 346 L104 346" stroke="#111" stroke-width="4"/><path d="M234 332 L268 270" stroke="#111" stroke-width="8" stroke-linecap="round"/><path d="M262 282 L274 258" stroke="#111" stroke-width="12" stroke-linecap="round"/>`;
const baby = `<ellipse cx="92" cy="322" rx="36" ry="28" fill="#FFF3D6" ${S}/><circle cx="96" cy="300" r="20" fill="${SKIN}" ${S}/><circle cx="90" cy="300" r="3" fill="#111"/><circle cx="102" cy="300" r="3" fill="#111"/>`;
const armor = (c) => `<path d="M108 250 L192 250 L196 316 L104 316 Z" fill="${c}" ${S}/><path d="M112 272 L188 272 M110 294 L190 294" stroke="#111" stroke-width="4"/>`;
const angry = `<path d="M100 124 L136 136 M200 124 L164 136" stroke="#111" stroke-width="7" stroke-linecap="round"/>`;
const brave = `<path d="M104 128 L136 132 M196 128 L164 132" stroke="#111" stroke-width="6" stroke-linecap="round"/>`;
const longBeard = (c) => `<path d="M104 190 Q150 330 196 190 Q176 214 150 214 Q124 214 104 190 Z" fill="${c}" ${S}/>`;
const thinMus = `<path d="M150 186 Q120 184 100 206 M150 186 Q180 184 200 206" fill="none" stroke="#111" stroke-width="5" stroke-linecap="round"/>`;
const shortMus = `<path d="M124 186 Q150 176 176 186 Q150 194 124 186 Z" fill="#2A1A12" stroke="#111" stroke-width="4"/>`;
const goatee = `<path d="M140 214 L150 246 L160 214 Z" fill="#2A1A12" stroke="#111" stroke-width="4"/>`;

// 18th-century European looks
const wig = (c = "#F4F1EA") => `<path d="M58 160 Q46 70 150 56 Q254 70 242 160 Q250 196 232 214 Q222 150 216 120 Q150 96 84 120 Q78 150 68 214 Q50 196 58 160 Z" fill="${c}" ${S}/><circle cx="66" cy="186" r="16" fill="${c}" ${S}/><circle cx="234" cy="186" r="16" fill="${c}" ${S}/>`;
const tricorn = (c = "#222", trim = "#F7CB46") => `<path d="M44 112 Q150 30 256 112 Q220 88 150 92 Q80 88 44 112 Z" fill="${c}" ${S}/><path d="M80 74 Q150 22 220 74 L210 96 Q150 80 90 96 Z" fill="${c}" ${S}/><path d="M58 108 Q150 60 242 108" fill="none" stroke="${trim}" stroke-width="5"/>`;
const coat = (cuff = "#F7CB46") => `<path d="M126 238 L150 300 L174 238" fill="#FFF" ${S}/><circle cx="150" cy="316" r="5" fill="${cuff}"/><circle cx="150" cy="340" r="5" fill="${cuff}"/><circle cx="150" cy="364" r="5" fill="${cuff}"/>`;
const scope = `<path d="M222 340 L282 236" stroke="#111" stroke-width="22" stroke-linecap="round"/><path d="M222 340 L282 236" stroke="#C98A3A" stroke-width="12" stroke-linecap="round"/><circle cx="284" cy="232" r="10" fill="#9ED8F5" stroke="#111" stroke-width="4"/>`;
const quill = `<path d="M234 344 L280 250 Q292 262 284 280 Z" fill="#FFF" ${S}/>`;
const book = `<rect x="52" y="314" width="56" height="64" rx="4" fill="#3E7C3A" ${S}/><path d="M64 314 L64 378" stroke="#111" stroke-width="4"/>`;
const sideburn = `<path d="M66 150 Q62 200 82 214 L86 150 Z M234 150 Q238 200 218 214 L214 150 Z" fill="#6B3E1E" ${S}/>`;
const shortHair = (c) => `<path d="M62 140 Q58 60 150 56 Q242 60 238 140 Q220 100 150 102 Q80 100 62 140 Z" fill="${c}" ${S}/>`;
const worried = `<path d="M102 130 Q120 120 136 128 M164 128 Q180 120 198 130" stroke="#111" stroke-width="6" fill="none" stroke-linecap="round"/>`;
const happy = `<path d="M104 126 Q120 116 136 126 M164 126 Q180 116 196 126" stroke="#111" stroke-width="6" fill="none" stroke-linecap="round"/>`;
const mus = `<path d="M124 186 Q150 176 176 186 Q150 194 124 186 Z" fill="#2A1A12" stroke="#111" stroke-width="4"/>`;

// ---- EDIT HERE: one entry per cast key (person() for humans, raw SVG body for props) ----
const chars = {
  vua: person({ robe: "#F7CB46", hat: crown, brows: brave, beard: longBeard("#2A1A12"), prop: sword }),
  nuTuong: person({ robe: "#E2483D", hair: femaleHair, hat: helmet("#C9A227"), chest: armor("#F7CB46"), brows: brave, prop: spear() }),
  hocGia: person({ robe: "#2E5FA8", chest: coat(), hair: wig(), hat: tricorn(), brows: worried, prop: scope }),
};
// props (no face): draw inside 300x420
chars.mattroi = `<circle cx="150" cy="210" r="120" fill="#F7CB46" ${S}/>`;

for (const [k, body] of Object.entries(chars)) {
  const f = join(OUT, `${k}.svg`);
  writeFileSync(f, `<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 300 420" width="300" height="420" data-char="${k}">\n${body}\n</svg>\n`);
  const kb = statSync(f).size / 1024;
  console.log(`${k.padEnd(14)} ${kb.toFixed(2)} KB${kb > 4 ? "  <-- OVER 4KB" : ""}`);
}
