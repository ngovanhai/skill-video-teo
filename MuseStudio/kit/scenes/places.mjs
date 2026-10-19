// Flat cartoon backdrops (1920x1080, black outlines, pastel fills) for the `place` scene.
// Keep the lower band (y > 880) calm: captions sit there.
const S = 'stroke="#000" stroke-width="6" stroke-linejoin="round"';

const sky = (top, bottom) => `<defs><linearGradient id="SKY" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="${top}"/><stop offset="1" stop-color="${bottom}"/></linearGradient></defs><rect width="1920" height="1080" fill="url(#SKY)"/>`;
const sun = (x, y, r = 90, c = "#F7CB46") => `<circle cx="${x}" cy="${y}" r="${r}" fill="${c}" ${S}/>`;
const cloud = (x, y, k = 1) => `<path d="M${x} ${y} q ${30 * k} ${-50 * k} ${80 * k} ${-20 * k} q ${40 * k} ${-50 * k} ${100 * k} 0 q ${60 * k} ${-10 * k} ${50 * k} ${40 * k} z" fill="#fff" ${S}/>`;
const ground = (y, c) => `<path d="M0 ${y} Q 480 ${y - 40} 960 ${y} T 1920 ${y} L1920 1080 L0 1080 Z" fill="${c}" ${S}/>`;
const hill = (x, w, h, base, c) => `<path d="M${x - w / 2} ${base} Q ${x} ${base - h * 2} ${x + w / 2} ${base} Z" fill="${c}" ${S}/>`;
const peak = (x, w, h, base, c, snow = true) =>
  `<path d="M${x - w / 2} ${base} L${x} ${base - h} L${x + w / 2} ${base} Z" fill="${c}" ${S}/>` +
  (snow ? `<path d="M${x - w * 0.14} ${base - h * 0.72} L${x} ${base - h} L${x + w * 0.14} ${base - h * 0.72} L${x + w * 0.05} ${base - h * 0.66} L${x - w * 0.04} ${base - h * 0.74} Z" fill="#fff" ${S}/>` : "");
const tree = (x, base, k = 1, c = "#99E885") =>
  `<rect x="${x - 10 * k}" y="${base - 70 * k}" width="${20 * k}" height="${70 * k}" fill="#8B5A2B" ${S}/><circle cx="${x}" cy="${base - 110 * k}" r="${60 * k}" fill="${c}" ${S}/>`;
const pine = (x, base, k = 1) =>
  `<rect x="${x - 9 * k}" y="${base - 40 * k}" width="${18 * k}" height="${40 * k}" fill="#8B5A2B" ${S}/><path d="M${x - 60 * k} ${base - 40 * k} L${x} ${base - 200 * k} L${x + 60 * k} ${base - 40 * k} Z" fill="#3FA34D" ${S}/>`;
const house = (x, base, k = 1, wall = "#FFDC8B", roof = "#FE3D7F") =>
  `<rect x="${x - 70 * k}" y="${base - 100 * k}" width="${140 * k}" height="${100 * k}" fill="${wall}" ${S}/><path d="M${x - 95 * k} ${base - 95 * k} L${x} ${base - 175 * k} L${x + 95 * k} ${base - 95 * k} Z" fill="${roof}" ${S}/><rect x="${x - 18 * k}" y="${base - 55 * k}" width="${36 * k}" height="${55 * k}" fill="#8B5A2B" ${S}/>`;
const thatch = (x, base, k = 1) =>
  `<rect x="${x - 80 * k}" y="${base - 90 * k}" width="${160 * k}" height="${90 * k}" fill="#E8C07D" ${S}/><path d="M${x - 115 * k} ${base - 80 * k} Q ${x} ${base - 210 * k} ${x + 115 * k} ${base - 80 * k} Z" fill="#C9A227" ${S}/><rect x="${x - 20 * k}" y="${base - 55 * k}" width="${40 * k}" height="${55 * k}" fill="#6B4423" ${S}/>`;
const tower = (x, base, w, h, c) => `<rect x="${x - w / 2}" y="${base - h}" width="${w}" height="${h}" fill="${c}" ${S}/>` +
  Array.from({ length: Math.floor(h / 60) }, (_, i) => `<rect x="${x - w / 2 + 16}" y="${base - h + 20 + i * 60}" width="${w - 32}" height="22" fill="#C0F7FE" stroke="#000" stroke-width="4"/>`).join("");
const waves = (y, c = "#5B8DEF") => `<path d="M0 ${y} ${Array.from({ length: 13 }, (_, i) => `Q ${i * 160 + 80} ${y - 30} ${i * 160 + 160} ${y}`).join(" ")} L1920 1080 L0 1080 Z" fill="${c}" ${S}/>`;
const boat = (x, y) => `<path d="M${x - 110} ${y} L${x + 110} ${y} L${x + 80} ${y + 50} L${x - 80} ${y + 50} Z" fill="#8B5A2B" ${S}/><rect x="${x - 5}" y="${y - 150}" width="10" height="150" fill="#000"/><path d="M${x + 5} ${y - 145} L${x + 95} ${y - 20} L${x + 5} ${y - 20} Z" fill="#fff" ${S}/>`;
const pagoda = (x, base, k = 1, c = "#FE3D7F") => {
  let s = "";
  for (let i = 0; i < 3; i++) {
    const w = (220 - i * 50) * k, y = base - i * 110 * k;
    s += `<rect x="${x - w / 2 + 20 * k}" y="${y - 80 * k}" width="${w - 40 * k}" height="${80 * k}" fill="#FFDC8B" ${S}/>`;
    s += `<path d="M${x - w / 2 - 30 * k} ${y - 70 * k} Q ${x} ${y - 120 * k} ${x + w / 2 + 30 * k} ${y - 70 * k} L${x + w / 2 + 50 * k} ${y - 95 * k} Q ${x} ${y - 150 * k} ${x - w / 2 - 50 * k} ${y - 95 * k} Z" fill="${c}" ${S}/>`;
  }
  return s;
};
const columns = (x, base, n, w = 60, h = 300, gap = 110) => {
  let s = `<rect x="${x - 40}" y="${base - 30}" width="${(n - 1) * gap + w + 80}" height="30" fill="#fff" ${S}/>`;
  for (let i = 0; i < n; i++) s += `<rect x="${x + i * gap}" y="${base - 30 - h}" width="${w}" height="${h}" fill="#fff" ${S}/>`;
  s += `<path d="M${x - 60} ${base - 30 - h} L${x + ((n - 1) * gap + w) / 2} ${base - 30 - h - 130} L${x + (n - 1) * gap + w + 60} ${base - 30 - h} Z" fill="#fff" ${S}/>`;
  return s;
};
const castle = (x, base) => tower(x - 240, base, 140, 380, "#C9C9D6") + tower(x + 240, base, 140, 380, "#C9C9D6") +
  `<rect x="${x - 180}" y="${base - 280}" width="360" height="280" fill="#DADAE6" ${S}/><path d="M${x - 50} ${base} L${x - 50} ${base - 110} Q ${x} ${base - 170} ${x + 50} ${base - 110} L${x + 50} ${base} Z" fill="#6B4423" ${S}/>` +
  [-280, -200, 200, 280].map((d) => `<rect x="${x + d - 22}" y="${base - 420}" width="44" height="44" fill="#C9C9D6" ${S}/>`).join("") +
  `<rect x="${x - 4}" y="${base - 420}" width="8" height="140" fill="#000"/><path d="M${x + 4} ${base - 418} L${x + 90} ${base - 390} L${x + 4} ${base - 362} Z" fill="#FE3D7F" ${S}/>`;
const rice = (y) => Array.from({ length: 5 }, (_, i) => `<path d="M0 ${y + i * 40} Q 960 ${y + i * 40 - 30} 1920 ${y + i * 40}" fill="none" stroke="#2E7D32" stroke-width="6"/>`).join("");
const dune = (x, w, h, base, c = "#F2C46D") => `<path d="M${x - w / 2} ${base} Q ${x - w / 6} ${base - h} ${x + w / 2} ${base} Z" fill="${c}" ${S}/>`;
const flag = (x, base, c) => `<rect x="${x - 4}" y="${base - 260}" width="8" height="260" fill="#000"/><path d="M${x + 4} ${base - 258} L${x + 130} ${base - 225} L${x + 4} ${base - 190} Z" fill="${c}" ${S}/>`;
const sword = (x, y, rot) => `<g transform="translate(${x} ${y}) rotate(${rot})"><rect x="-6" y="-160" width="12" height="150" fill="#E0E0E0" ${S}/><rect x="-30" y="-12" width="60" height="14" fill="#8B5A2B" ${S}/><rect x="-6" y="2" width="12" height="40" fill="#8B5A2B" ${S}/></g>`;

const SCENES = {
  mountain: () => sky("#C0F7FE", "#FFFDF5") + sun(1620, 200) + cloud(300, 220) + cloud(1100, 160, 0.8) +
    peak(560, 900, 560, 860, "#8E9AAF") + peak(1300, 1000, 680, 860, "#7A869A") + peak(1760, 700, 420, 860, "#8E9AAF") + ground(860, "#99E885"),
  sea: () => sky("#C0F7FE", "#E8FBFF") + sun(1500, 220) + cloud(380, 200) + waves(620, "#5B8DEF") + boat(1100, 600) + waves(760, "#3C6FD8"),
  river: () => sky("#C0F7FE", "#FFFDF5") + sun(300, 180) + ground(560, "#99E885") +
    `<path d="M700 560 Q 900 700 760 880 L1260 880 Q 1300 700 1100 560 Z" fill="#5B8DEF" ${S}/>` + tree(300, 760) + tree(1600, 740, 1.2) + boat(1000, 760),
  city: () => sky("#FFDC8B", "#FFFDF5") + sun(1650, 180, 80) + tower(300, 860, 200, 480, "#FE90E8") + tower(560, 860, 180, 600, "#C0F7FE") +
    tower(820, 860, 220, 420, "#F7CB46") + tower(1100, 860, 200, 660, "#99E885") + tower(1380, 860, 190, 500, "#FE90E8") + tower(1640, 860, 220, 380, "#C0F7FE") + ground(860, "#BDBDBD"),
  village: () => sky("#C0F7FE", "#FFFDF5") + sun(1620, 190) + cloud(260, 180) + hill(500, 1100, 200, 760, "#99E885") + hill(1500, 1200, 160, 760, "#7FD36E") +
    thatch(520, 780) + thatch(900, 790, 1.2) + thatch(1350, 780) + tree(1650, 800, 1.1) + tree(180, 800) + ground(800, "#99E885"),
  countryside: () => sky("#C0F7FE", "#FFFDF5") + sun(1550, 200) + cloud(400, 210) + hill(1400, 1200, 160, 600, "#7FD36E") +
    `<rect x="0" y="600" width="1920" height="480" fill="#B5E08C" ${S}/>` + rice(640) + thatch(1500, 640, 0.8) + tree(260, 640, 0.9),
  palace: () => sky("#FFDC8B", "#FFFDF5") + sun(1640, 180) + `<rect x="400" y="760" width="1120" height="100" fill="#E8C07D" ${S}/>` +
    pagoda(960, 760, 1.6, "#FE3D7F") + pagoda(520, 760, 0.8, "#F7CB46") + pagoda(1400, 760, 0.8, "#F7CB46") + ground(860, "#C9A227"),
  temple: () => sky("#C0F7FE", "#FFFDF5") + sun(1600, 200) + columns(560, 840, 7) + ground(840, "#99E885") + tree(300, 840) + tree(1640, 840, 1.2),
  castle: () => sky("#C0F7FE", "#FFFDF5") + cloud(300, 200) + cloud(1400, 160) + hill(960, 1600, 120, 860, "#99E885") + castle(960, 820) + ground(860, "#7FD36E"),
  forest: () => sky("#99E885", "#E9FBE4") + Array.from({ length: 9 }, (_, i) => pine(120 + i * 210, 860, 1 + ((i * 3) % 4) * 0.25)).join("") +
    Array.from({ length: 5 }, (_, i) => tree(220 + i * 380, 880, 1.3, "#3FA34D")).join("") + ground(880, "#3FA34D"),
  desert: () => sky("#FFDC8B", "#FFF3D6") + sun(1500, 220, 110, "#FE3D7F") + dune(500, 1300, 300, 860) + dune(1500, 1200, 360, 860, "#E8B04B") +
    `<path d="M760 860 L960 560 L1160 860 Z" fill="#F2C46D" ${S}/><path d="M960 560 L1160 860 L1040 860 Z" fill="#D9A441" ${S}/>` + ground(860, "#F2C46D"),
  battlefield: () => sky("#FE90E8", "#FFDC8B") + sun(960, 360, 160, "#FE3D7F") + hill(500, 1200, 140, 860, "#B08A5B") + hill(1500, 1200, 120, 860, "#9C7A4E") +
    flag(400, 800, "#FE3D7F") + flag(1500, 800, "#5B8DEF") + sword(900, 820, -25) + sword(1020, 820, 25) + ground(860, "#9C7A4E"),
  night: () => `<rect width="1920" height="1080" fill="#12132A"/>` + Array.from({ length: 40 }, (_, i) => `<circle cx="${(i * 373) % 1920}" cy="${(i * 211) % 620}" r="${3 + (i % 3) * 2}" fill="#fff"/>`).join("") +
    sun(1540, 200, 100, "#FFF3B0") + hill(600, 1400, 150, 860, "#2A2D5A") + thatch(700, 800) + ground(860, "#1E2045"),
  space: () => `<rect width="1920" height="1080" fill="#0B0C1E"/>` + Array.from({ length: 70 }, (_, i) => `<circle cx="${(i * 487) % 1920}" cy="${(i * 263) % 1080}" r="${2 + (i % 4)}" fill="#fff"/>`).join("") +
    `<circle cx="1400" cy="480" r="240" fill="#5B8DEF" ${S}/><path d="M1220 420 Q 1300 380 1380 440 Q 1420 520 1330 560 Z" fill="#99E885" ${S}/><circle cx="460" cy="300" r="90" fill="#F7CB46" ${S}/>`,
};

export const PLACE_KINDS = Object.keys(SCENES);
export function landscape(kind, ns) {
  const f = SCENES[kind] || SCENES.village;
  const svg = f().replace(/id="SKY"/g, `id="${ns}-sky"`).replace(/url\(#SKY\)/g, `url(#${ns}-sky)`);
  return `<svg viewBox="0 0 1920 1080" style="width:100%;height:100%;display:block">${svg}</svg>`;
}
