// Cut-out rigs (SVG split into rotatable parts). Pivots live in runtime.js (PIV.teo / PIV.npc) — keep both in sync.
// Tèo: viewBox 0 0 500 760 (same drawing as kit/chars/narrator/teo-talk.svg). NPC: viewBox 0 0 200 300.
const K = 'stroke="#111"';
const limb = (d, c, w = 44) => `<path d="${d}" fill="none" stroke="#111" stroke-width="${w}" stroke-linecap="round"/><path d="${d}" fill="none" stroke="${c}" stroke-width="${w - 12}" stroke-linecap="round"/>`;

// weapons drawn in the hand's local frame (hand at 0,0, blade pointing "up" = -y), scale s
const WEAPON = {
  kiem: (s = 1) => `<g transform="scale(${s})"><path d="M-11 -34 L-11 -318 L0 -352 L11 -318 L11 -34 Z" fill="#EEF3F8" ${K} stroke-width="5" stroke-linejoin="round"/><path d="M0 -40 L0 -320" stroke="#AFC0D0" stroke-width="4"/><rect x="-42" y="-38" width="84" height="16" rx="7" fill="#E3A21A" ${K} stroke-width="5"/><rect x="-8" y="-24" width="16" height="58" rx="5" fill="#6B3E1F" ${K} stroke-width="4"/></g>`,
  dao: (s = 1) => `<g transform="scale(${s})"><path d="M-12 -30 L-14 -250 Q-10 -330 40 -350 Q20 -300 26 -250 L14 -30 Z" fill="#E4E9EE" ${K} stroke-width="5" stroke-linejoin="round"/><rect x="-40" y="-36" width="80" height="14" rx="6" fill="#8A2A1E" ${K} stroke-width="5"/><rect x="-8" y="-22" width="16" height="56" rx="5" fill="#3B2A1A" ${K} stroke-width="4"/></g>`,
  giao: (s = 1) => `<g transform="scale(${s})"><path d="M0 120 L0 -300" stroke="#6B3E1F" stroke-width="14" stroke-linecap="round"/><path d="M0 -360 L20 -300 L-20 -300 Z" fill="#C9D3DD" ${K} stroke-width="5" stroke-linejoin="round"/><path d="M-14 -296 Q0 -270 14 -296 Z" fill="#C8372D"/></g>`,
  gay: (s = 1) => `<g transform="scale(${s})"><path d="M0 140 L0 -300" stroke="#111" stroke-width="22" stroke-linecap="round"/><path d="M0 140 L0 -300" stroke="#B5813E" stroke-width="12" stroke-linecap="round"/><path d="M-11 -240 L11 -240 M-11 80 L11 80" stroke="#8A2A1E" stroke-width="10"/></g>`,
  quat: (s = 1) => `<g transform="scale(${s})"><path d="M0 0 L-90 -150 A175 175 0 0 1 90 -150 Z" fill="#F6EFE0" ${K} stroke-width="5" stroke-linejoin="round"/><path d="M0 0 L-45 -165 M0 0 L0 -175 M0 0 L45 -165" stroke="#C8372D" stroke-width="4"/><circle r="9" fill="#3B2A1A"/></g>`,
  none: () => "",
};

const HAIR = {
  teo: `<path d="M118 176 Q108 92 168 72 Q204 52 246 70 Q296 88 284 168 Q270 128 246 118 Q236 138 200 132 Q218 116 210 104 Q176 136 132 130 Q124 150 118 176 Z" fill="#5A3825" ${K} stroke-width="6" stroke-linejoin="round"/>`,
};

// Tèo. opts: band (headband colour or false), weapon (kiem|dao|quat|gay|none), jacket colour
export function teo(p, w, { band = false, weapon = "none", jacket = "#5B8DEF" } = {}) {
  const h = Math.round(w * 760 / 500);
  const wp = weapon === "none" ? "" : `<g transform="translate(352 330) rotate(25)">${WEAPON[weapon](1)}</g>`;
  const bandSvg = band ? `<path d="M120 150 Q200 120 280 150 L282 172 Q200 142 118 172 Z" fill="${band}" ${K} stroke-width="5" stroke-linejoin="round"/>` : "";
  const tail = band ? `<g id="${p}-tail"><path d="M126 154 Q92 146 58 170 Q84 170 94 186 Q104 166 126 168 Z" fill="${band}" ${K} stroke-width="5" stroke-linejoin="round"/><path d="M124 162 Q96 186 84 220 Q100 206 116 212 Q114 188 128 172 Z" fill="${band}" ${K} stroke-width="5" stroke-linejoin="round" opacity=".85"/></g>` : "";
  return `<svg viewBox="0 0 500 760" width="${w}" height="${h}" style="display:block;overflow:visible"><g id="${p}-all">
<g id="${p}-legL"><rect x="140" y="540" width="54" height="180" rx="10" fill="#2B2D42" ${K} stroke-width="6"/><ellipse cx="160" cy="728" rx="40" ry="17" fill="#111"/></g>
<g id="${p}-legR"><rect x="206" y="540" width="54" height="180" rx="10" fill="#2B2D42" ${K} stroke-width="6"/><ellipse cx="240" cy="728" rx="40" ry="17" fill="#111"/></g>
<g id="${p}-armB">${limb("M128 305 L108 420", jacket)}<g id="${p}-foreB">${limb("M108 420 L118 515", jacket)}<circle cx="118" cy="528" r="19" fill="#FFD9B8" ${K} stroke-width="6"/></g></g>
<path d="M120 300 Q200 272 280 300 L290 560 L110 560 Z" fill="${jacket}" ${K} stroke-width="6" stroke-linejoin="round"/>
<path d="M168 288 L232 288 L226 560 L174 560 Z" fill="#FFFFFF" ${K} stroke-width="4"/>
<text x="200" y="372" text-anchor="middle" font-family="Inter" font-weight="800" font-size="30" fill="#111">T</text>
<path d="M168 288 L150 360 L178 420 M232 288 L250 360 L222 420" fill="none" ${K} stroke-width="4" stroke-linejoin="round"/>
<rect x="182" y="244" width="36" height="44" fill="#FFD9B8" ${K} stroke-width="6"/>
<g id="${p}-head">${tail}
<ellipse cx="120" cy="188" rx="14" ry="20" fill="#FFD9B8" ${K} stroke-width="6"/><ellipse cx="280" cy="188" rx="14" ry="20" fill="#FFD9B8" ${K} stroke-width="6"/>
<path d="M124 180 Q122 262 200 266 Q278 262 276 180 Q276 104 200 100 Q124 104 124 180 Z" fill="#FFD9B8" ${K} stroke-width="6"/>
${HAIR.teo}${bandSvg}
<g id="${p}-face">
<g id="${p}-browN"><path d="M150 140 L192 136 M208 136 L250 140" ${K} stroke-width="6" stroke-linecap="round"/></g>
<g id="${p}-browA" opacity="0"><path d="M146 126 L192 148 M208 148 L254 126" ${K} stroke-width="9" stroke-linecap="round"/></g>
<g id="${p}-eyes"><circle cx="172" cy="178" r="6" fill="#111"/><circle cx="228" cy="178" r="6" fill="#111"/></g>
<g id="${p}-mc"><path d="M182 228 Q200 242 218 228" fill="none" ${K} stroke-width="6" stroke-linecap="round"/></g>
<g id="${p}-mo" opacity="0"><path d="M180 224 Q200 222 220 224 Q216 252 200 252 Q184 252 180 224 Z" fill="#B3263A" ${K} stroke-width="5" stroke-linejoin="round"/></g>
</g>
<g id="${p}-ko" opacity="0"><path d="M160 166 L184 190 M184 166 L160 190 M216 166 L240 190 M240 166 L216 190" ${K} stroke-width="6" stroke-linecap="round"/><ellipse cx="200" cy="236" rx="12" ry="10" fill="#7A2230" ${K} stroke-width="4"/></g>
<circle cx="172" cy="180" r="27" fill="none" ${K} stroke-width="5"/><circle cx="228" cy="180" r="27" fill="none" ${K} stroke-width="5"/>
<path d="M199 178 Q200 172 201 178 M145 176 L126 170 M255 176 L274 170" ${K} stroke-width="5" fill="none"/>
</g>
<g id="${p}-armF">${limb("M272 305 L318 410", jacket)}<g id="${p}-foreF">${wp}${limb("M318 410 L348 345", jacket)}<circle cx="352" cy="330" r="19" fill="#FFD9B8" ${K} stroke-width="6"/></g></g>
</g></svg>`;
}

// NPC (lính, cao thủ, chưởng quỹ…). opts: robe, hat (linh|non|bui|khan|none|troc|dao), beard (bool), weapon, skin, belt, patch (áo vá), sash (cà sa chéo, mã màu)
const HAT = {
  linh: `<path d="M48 96 Q50 36 100 34 Q150 36 152 96 Q126 78 100 78 Q74 78 48 96 Z" fill="#3A3F47" ${K} stroke-width="5" stroke-linejoin="round"/><path d="M100 34 L100 16" ${K} stroke-width="6"/><circle cx="100" cy="13" r="8" fill="#C8372D" ${K} stroke-width="4"/>`,
  non: `<path d="M18 82 L100 18 L182 82 Q100 70 18 82 Z" fill="#E9CF8E" ${K} stroke-width="5" stroke-linejoin="round"/><path d="M60 64 L100 34 L140 64" fill="none" stroke="#B89660" stroke-width="3"/>`,
  bui: `<path d="M52 92 Q50 46 100 44 Q150 46 148 92 Q130 66 100 64 Q70 66 52 92 Z" fill="#1E1A1A" ${K} stroke-width="5"/><circle cx="100" cy="34" r="20" fill="#1E1A1A" ${K} stroke-width="5"/><path d="M84 30 L120 22" stroke="#E3A21A" stroke-width="5" stroke-linecap="round"/>`,
  khan: `<path d="M50 90 Q48 40 100 38 Q152 40 150 90 L150 74 Q100 54 50 74 Z" fill="#8A2A1E" ${K} stroke-width="5" stroke-linejoin="round"/><path d="M150 70 Q176 82 170 112 Q160 96 148 92 Z" fill="#8A2A1E" ${K} stroke-width="4"/>`,
  none: `<path d="M52 92 Q50 46 100 44 Q150 46 148 92 Q128 70 100 70 Q72 70 52 92 Z" fill="#2B2220" ${K} stroke-width="5"/>`,
  troc: `<path d="M70 62 Q86 52 100 52" fill="none" stroke="#fff" stroke-width="6" stroke-linecap="round" opacity=".7"/>${[86, 100, 114].map((x) => `<circle cx="${x}" cy="66" r="4" fill="#B5813E"/>`).join("")}`,
  dao: `<path d="M52 92 Q50 46 100 44 Q150 46 148 92 Q128 70 100 70 Q72 70 52 92 Z" fill="#1E1A1A" ${K} stroke-width="5"/><ellipse cx="100" cy="36" rx="18" ry="15" fill="#1E1A1A" ${K} stroke-width="5"/><path d="M72 30 L128 40" stroke="#C9D3DD" stroke-width="5" stroke-linecap="round"/><circle cx="72" cy="30" r="5" fill="#E3A21A" ${K} stroke-width="2"/>`,
};
export const HATS = Object.keys(HAT), WEAPONS = Object.keys(WEAPON);
export function npc(p, w, { robe = "#5C6B7A", hat = "linh", beard = false, weapon = "giao", skin = "#FFD9B8", belt = "#3B2A1A", patch = false, sash = null } = {}) {
  const h = Math.round(w * 1.5);
  const wpScale = { giao: 0.5, gay: 0.5, kiem: 0.42, dao: 0.45, quat: 0.45, none: 1 }[weapon];
  const wp = weapon === "none" ? "" : `<g transform="translate(160 196) rotate(${weapon === "quat" ? 15 : 0})">${WEAPON[weapon](wpScale)}</g>`;
  const beardSvg = beard ? `<path d="M68 126 Q100 196 132 126 Q118 146 100 146 Q82 146 68 126 Z" fill="#2B2220" ${K} stroke-width="4" stroke-linejoin="round"/>` : "";
  return `<svg viewBox="0 0 200 300" width="${w}" height="${h}" style="display:block;overflow:visible"><g id="${p}-all">
<g id="${p}-legL"><rect x="72" y="222" width="24" height="56" rx="6" fill="#2B2D42" ${K} stroke-width="5"/><ellipse cx="82" cy="282" rx="18" ry="8" fill="#111"/></g>
<g id="${p}-legR"><rect x="104" y="222" width="24" height="56" rx="6" fill="#2B2D42" ${K} stroke-width="5"/><ellipse cx="118" cy="282" rx="18" ry="8" fill="#111"/></g>
<g id="${p}-armB">${limb("M62 150 L44 200", robe, 26)}<circle cx="42" cy="206" r="12" fill="${skin}" ${K} stroke-width="4"/></g>
<path d="M58 140 Q100 124 142 140 L152 232 L48 232 Z" fill="${robe}" ${K} stroke-width="5" stroke-linejoin="round"/>
<path d="M88 132 L100 170 L112 132" fill="none" ${K} stroke-width="4"/>
<rect x="52" y="186" width="96" height="14" fill="${belt}"/>
${sash ? `<path d="M64 142 L84 134 L146 222 L124 232 Z" fill="${sash}" ${K} stroke-width="4" stroke-linejoin="round"/>` : ""}
${patch ? `<rect x="64" y="204" width="22" height="20" fill="#C9A45C" ${K} stroke-width="3" transform="rotate(-8 75 214)"/><rect x="114" y="150" width="20" height="18" fill="#8A5A34" ${K} stroke-width="3" transform="rotate(10 124 159)"/>` : ""}
<g id="${p}-head">
<circle cx="100" cy="98" r="50" fill="${skin}" ${K} stroke-width="5"/>
${HAT[hat]}
<g id="${p}-face">
<g id="${p}-browN"><path d="M76 100 L94 102 M106 102 L124 100" ${K} stroke-width="5" stroke-linecap="round"/></g>
<g id="${p}-browA" opacity="0"><path d="M72 92 L94 106 M128 92 L106 106" ${K} stroke-width="7" stroke-linecap="round"/></g>
<g id="${p}-eyes"><circle cx="86" cy="115" r="5" fill="#111"/><circle cx="114" cy="115" r="5" fill="#111"/></g>
<g id="${p}-mc"><path d="M90 134 Q100 140 110 134" fill="none" ${K} stroke-width="5" stroke-linecap="round"/></g>
<g id="${p}-mo" opacity="0"><ellipse cx="100" cy="136" rx="10" ry="9" fill="#7A2230" ${K} stroke-width="4"/></g>
</g>
<g id="${p}-ko" opacity="0"><path d="M78 106 L94 122 M94 106 L78 122 M106 106 L122 122 M122 106 L106 122" ${K} stroke-width="5" stroke-linecap="round"/><ellipse cx="100" cy="138" rx="9" ry="7" fill="#7A2230" ${K} stroke-width="3"/></g>
${beardSvg}
</g>
<g id="${p}-armF">${wp}${limb("M140 150 L160 196", robe, 26)}<circle cx="160" cy="198" r="12" fill="${skin}" ${K} stroke-width="4"/></g>
</g></svg>`;
}

// presets usable from tap.json: { "kind": "npc", "preset": "linh" } — any field can be overridden
export const PRESETS = {
  linh: { robe: "#5C6B7A", hat: "linh", weapon: "giao" },
  "linh-do": { robe: "#8A2A1E", hat: "linh", weapon: "giao" },
  "cao-thu": { robe: "#2B2D42", hat: "bui", beard: true, weapon: "dao", belt: "#C8372D" },
  "hiep-khach": { robe: "#3E8E5A", hat: "non", weapon: "kiem" },
  "thu-sinh": { robe: "#E8E2D0", hat: "khan", weapon: "quat", belt: "#2E6FB7" },
  "chuong-quy": { robe: "#B5813E", hat: "none", beard: true, weapon: "none" },
  "su-phu": { robe: "#F3EAD2", hat: "bui", beard: true, weapon: "gay", belt: "#8A2A1E" },
  "nu-hiep": { robe: "#D7263D", hat: "bui", weapon: "kiem", belt: "#F3EAD2" },
  "cai-bang": { robe: "#8A6A44", hat: "none", weapon: "gay", belt: "#C9A45C", patch: true },
  tang: { robe: "#E3A21A", hat: "troc", weapon: "none", belt: "#8A2A1E", sash: "#8A2A1E" },
  "dao-si": { robe: "#3D6FA8", hat: "dao", weapon: "kiem", belt: "#F3EAD2" },
  "cong-tu": { robe: "#F4F1EA", hat: "bui", weapon: "kiem", belt: "#2E6FB7" },
  "lao-quai": { robe: "#4A2E5C", hat: "none", beard: true, weapon: "gay", belt: "#C8372D" },
};

// sword tip in Tèo svg coords given upper-arm rotation a and forearm rotation f (kiem only)
const rot = (px, py, cx, cy, deg) => { const r = deg * Math.PI / 180, c = Math.cos(r), s = Math.sin(r), dx = px - cx, dy = py - cy; return [cx + dx * c - dy * s, cy + dx * s + dy * c]; };
export const teoTip = (a, f) => { const q = rot(500.8, 11, 318, 410, f); return rot(q[0], q[1], 272, 305, a); };
export const teoHand = (a, f) => { const q = rot(352, 330, 318, 410, f); return rot(q[0], q[1], 272, 305, a); };
