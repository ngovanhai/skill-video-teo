// Mặt riêng tập 10 — "nhãn hũ in ván gỗ": viền nâu đậm cắt góc như dao khắc, mắt hạt dưa nghiêng
// (lòng trắng ngà, tròng hổ phách, đồng tử nâu), mi trên là ba vết khắc hình nêm ở đuôi mắt,
// lông mày một nêm vát, mũi một gạch ngắn, má hổ phách có ba vạch khắc chéo. Cảm xúc bằng vạch khắc, không vết son.
const CX = 150, EY = 188, MY = 244, INK = "#3A2416", IVORY = "#FBF1DC", AMBER = "#E39A3B";
let K;
const hash = (s) => [...String(s)].reduce((a, ch) => (Math.imul(a ^ ch.charCodeAt(0), 0x45d9f3b) + 0x9e37) >>> 0, 2166136261);
const r1 = (x) => Math.round(x * 10) / 10;
const P = (pts) => pts.map(([x, y], i) => `${i ? "L" : "M"}${r1(x)} ${r1(y)}`).join(" ") + "Z";
// nêm khắc: tam giác từ gốc a (rộng w) tới mũi b
function wedge(a, b, w, fill = INK) {
  const dx = b[0] - a[0], dy = b[1] - a[1], d = Math.hypot(dx, dy) || 1, nx = (-dy / d) * w / 2, ny = (dx / d) * w / 2;
  return `<path d="${P([[a[0] + nx, a[1] + ny], b, [a[0] - nx, a[1] - ny]])}" fill="${fill}"/>`;
}
// nét khắc đều: dải mảnh hai đầu vát
function cut(a, b, w, fill = INK) {
  const dx = b[0] - a[0], dy = b[1] - a[1], d = Math.hypot(dx, dy) || 1, ux = dx / d, uy = dy / d, nx = -uy * w / 2, ny = ux * w / 2;
  return `<path d="${P([[a[0] - ux * w * 0.6, a[1] - uy * w * 0.6], [a[0] + nx, a[1] + ny], [b[0] + nx, b[1] + ny], [b[0] + ux * w * 0.6, b[1] + uy * w * 0.6], [b[0] - nx, b[1] - ny], [a[0] - nx, a[1] - ny]])}" fill="${fill}"/>`;
}

// khuôn mặt: đa giác bo nhẹ, góc hàm cắt vát (kiểu khắc). [nửa rộng má, nửa rộng hàm, y hàm, y cằm, nửa rộng cằm]
const JAW = { tron: [100, 84, 250, 278, 34], nhon: [98, 72, 240, 288, 14], vuong: [102, 92, 254, 278, 44], dai: [96, 76, 246, 292, 24] };
function facePath([cb, jx, jy, cy, cw]) {
  return `M150 60 C214 60 ${150 + cb + 6} 106 ${150 + cb} 186 L${150 + jx} ${jy} L${150 + cw} ${cy} L${150 - cw} ${cy} L${150 - jx} ${jy} L${150 - cb} 186 C${150 - cb - 6} 106 86 60 150 60Z`;
}
// dáng mắt hạt dưa: [nửa dài, nửa cao, nghiêng (âm = đuôi xếch)]
const EYE = { xech: [27, 13, -9], hat: [25, 14, -5], dai: [30, 11, -6], tron: [22, 16, -3] };

function eye(cx, s, d, e, o) {
  const [hw, hh, tilt] = d, ix = cx - s * hw, ox = cx + s * hw, cy = EY, oy = cy + tilt, p = [];
  if (e === "ko") return cut([cx - 14, cy - 12], [cx + 14, cy + 12], 6) + cut([cx + 14, cy - 12], [cx - 14, cy + 12], 6);
  if (e === "vui" || (e === "dac-y" && s > 0)) {
    // mắt cười: một nêm cong úp xuống
    return `<path d="M${ix} ${cy + 4} Q${cx} ${cy - hh * 1.6} ${ox} ${oy + 2} Q${cx} ${cy - hh * 0.7} ${ix} ${cy + 4}Z" fill="${INK}"/>` + wedge([ox, oy + 1], [ox + s * 10, oy - 6], 5);
  }
  const top = e === "gian" || e === "quyet-tam" ? hh * 0.6 : e === "ngai" ? hh * 0.75 : hh, bot = hh * 0.9;
  // hạt dưa: nhọn hai đầu, bụng trên căng hơn bụng dưới
  const white = `M${ix} ${cy} C${cx - s * hw * 0.5} ${cy - top * 1.5} ${cx + s * hw * 0.5} ${oy - top * 1.5} ${ox} ${oy} C${cx + s * hw * 0.4} ${oy + bot * 1.2} ${cx - s * hw * 0.4} ${cy + bot * 1.2} ${ix} ${cy}Z`;
  p.push(`<path d="${white}" fill="${IVORY}" stroke="${INK}" stroke-width="3" stroke-linejoin="miter"/>`);
  if (e === "soc") p.push(`<circle cx="${cx}" cy="${cy + tilt / 2}" r="4" fill="${INK}"/>`);
  else {
    const look = e === "ngai" ? -s * 6 : 0, r = Math.min(hh * 0.92, 12), icx = cx + look, icy = cy + tilt / 2;
    p.push(`<circle cx="${icx}" cy="${icy}" r="${r}" fill="${K.dk(o.eyes || "#7A4A22", 0.1)}"/><circle cx="${icx}" cy="${icy}" r="${r * 0.5}" fill="${INK}"/>`);
    p.push(`<path d="M${icx - r * 0.5} ${icy - r * 0.55} l${r * 0.42} 0 l-${r * 0.21} ${r * 0.36}Z" fill="#fff"/>`); // ánh sáng hình tam giác khắc
  }
  // mí trên dày + ba nêm mi ở đuôi
  p.push(`<path d="M${ix - s * 2} ${cy + 1} C${cx - s * hw * 0.5} ${cy - top * 1.62} ${cx + s * hw * 0.5} ${oy - top * 1.62} ${ox + s * 3} ${oy - 1} L${ox} ${oy + 4} C${cx + s * hw * 0.4} ${oy - top * 1.2} ${cx - s * hw * 0.4} ${cy - top * 1.2} ${ix} ${cy + 3}Z" fill="${INK}"/>`);
  for (let i = 0; i < 3; i++) p.push(wedge([ox - s * i * 7, oy - 2 - i * 2 + tilt * 0.1], [ox + s * (10 - i * 2), oy - 12 - i * 5], 4.5 - i));
  if (o.fem) p.push(wedge([ox - s * 4, oy + 4], [ox + s * 6, oy + 8], 3));
  if (o.age === "gia") p.push(cut([ox + s * 6, oy + 6], [ox + s * 16, oy + 10], 2) + cut([ix - s * 2, cy + bot + 6], [cx, cy + bot + 9], 2));
  if (e === "buon" && s < 0) p.push(`<path d="M${cx - 4} ${cy + 14} l-6 14 l12 0Z" fill="#CFE3EA" stroke="${INK}" stroke-width="2.5"/>`);
  return p.join("");
}
// lông mày: nêm vát từ đầu trong (dày) ra đuôi (nhọn)
function brows(e, hc, kind) {
  const y = EY - 42, k = { gian: [14, -12], buon: [-10, 10], soc: [-14, 0], "quyet-tam": [10, -8], ngai: [-6, 6], ko: [-12, 0], "dac-y": [0, 0] }[e] || [0, 0];
  const th = kind ? 12 : 9, col = K.dk(hc, 0.45);
  const one = (s, kk) => wedge([CX + s * 22, y + kk[0] * 0.5 + 2], [CX + s * 80, y - 6 + kk[1] - (kind ? 4 : 0)], th, col);
  return e === "dac-y" ? one(-1, [0, 0]) + one(1, [-10, -6]) : one(-1, k) + one(1, k);
}
function mouth(e, p, fem) {
  const y = MY, lip = fem ? "#A8432C" : "#7A3020";
  const O = (d) => `<path d="${d}" fill="${lip}" stroke="${INK}" stroke-width="3" stroke-linejoin="miter"/>`;
  const closed = {
    vui: `<path d="M134 ${y - 2} L150 ${y + 8} L166 ${y - 2} L150 ${y + 3}Z" fill="${INK}"/>`,
    binh: cut([140, y + 2], [160, y + 2], 4),
    gian: cut([136, y + 6], [150, y], 4.5) + cut([150, y], [164, y + 6], 4.5),
    buon: cut([138, y + 7], [150, y + 2], 4) + cut([150, y + 2], [162, y + 7], 4),
    soc: O(`M144 ${y - 2} L156 ${y - 2} L156 ${y + 9} L144 ${y + 9}Z`),
    "dac-y": `<path d="M138 ${y + 4} L160 ${y + 3} L168 ${y - 6} L158 ${y + 7}Z" fill="${INK}"/>`,
    ngai: cut([140, y + 3], [146, y], 3) + cut([146, y], [152, y + 3], 3) + cut([152, y + 3], [158, y], 3),
    "quyet-tam": cut([136, y + 3], [164, y + 3], 6),
    ko: O(`M142 ${y + 3} L158 ${y + 3} L153 ${y + 12} L147 ${y + 12}Z`),
  };
  const open = {
    vui: O(`M134 ${y - 3} L166 ${y - 3} L156 ${y + 17} L144 ${y + 17}Z`) + `<path d="M140 ${y + 10} L160 ${y + 10} L156 ${y + 16} L144 ${y + 16}Z" fill="#D9705A"/>`,
    gian: O(`M134 ${y + 1} L166 ${y + 1} L160 ${y + 17} L140 ${y + 17}Z`) + `<path d="M137 ${y + 4} L163 ${y + 4}" stroke="${IVORY}" stroke-width="3.5"/>`,
    buon: O(`M138 ${y + 14} L150 ${y + 1} L162 ${y + 14}Z`),
    soc: O(`M142 ${y - 2} L158 ${y - 2} L160 ${y + 18} L140 ${y + 18}Z`),
    "dac-y": O(`M138 ${y} L168 ${y - 7} L158 ${y + 13} L146 ${y + 12}Z`),
    ngai: O(`M144 ${y + 1} L156 ${y + 1} L153 ${y + 9} L147 ${y + 9}Z`),
    "quyet-tam": O(`M134 ${y} L166 ${y} L161 ${y + 14} L139 ${y + 14}Z`) + `<path d="M136 ${y + 6} L164 ${y + 6}" stroke="${IVORY}" stroke-width="3"/>`,
  };
  const oe = e === "binh" ? "vui" : e === "ko" ? "soc" : e;
  return `<g id="${p}-mc-${e}">${closed[e]}</g><g id="${p}-mo-${e}" opacity="0">${open[oe]}</g>`;
}
// má hổ phách + ba vạch khắc chéo
function cheek(s, a = 0.55) {
  const x = CX + s * 66, y = 226;
  return `<ellipse cx="${x}" cy="${y}" rx="17" ry="10" fill="${AMBER}" opacity="${a}"/>` + [-8, 0, 8].map((d) => cut([x + d - 4, y + 6], [x + d + 4, y - 6], 2.2, K.dk(AMBER, 0.35))).join("");
}
function marks(e) {
  switch (e) {
    case "gian": return [0, 1, 2].map((i) => cut([214 + i * 9, 92 + i * 4], [228 + i * 9, 110 + i * 4], 3.2)).join("");
    case "soc": return [96, 108, 120].map((x, i) => cut([x, 94 + i * 2], [x + 2, 120], 3)).join("");
    case "ngai": return cheek(-1, 0.95) + cheek(1, 0.95);
    case "buon": return cut([94, 98], [98, 120], 2.5) + cut([106, 96], [109, 116], 2.5);
    case "quyet-tam": return wedge([238, 98], [214, 112], 7);
    default: return "";
  }
}

export default function ve(p, o, kit) {
  K = kit;
  const skin = o.skin, hc = o.hair.color, hg = `${p}-hg`, n = hash(o.id || p), m = o.mat || {};
  const jk = Object.keys(JAW), ekk = Object.keys(EYE);
  const jaw = [...(JAW[m.khuon] || JAW[jk[n % jk.length]])], ek = EYE[m.mat] ? m.mat : ekk[(n >>> 7) % ekk.length];
  jaw[1] += (n >>> 12) % 7 - 3; jaw[3] += (n >>> 15) % 9 - 4; jaw[4] += (n >>> 19) % 7 - 3;
  const ex = 46 + ((n >>> 22) % 7) - 3, ed = [...EYE[ek]]; ed[0] += (n >>> 25) % 4 - 1.5;
  const ny = 216 + ((n >>> 9) % 5), browThick = (n >>> 28) % 2 === 1;
  const [front, back] = kit.HAIR[o.hair.style] || kit.HAIR.ngan;
  const h = [];
  // tóc phẳng một màu, vạch khắc sáng chạy dọc thay cho gradient
  h.push(`<defs><linearGradient id="${hg}" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="${hc}"/><stop offset="1" stop-color="${kit.dk(hc, 0.18)}"/></linearGradient></defs>`);
  if (back) h.push(kit.hairBack(back, hc, hg));
  const ear = (s) => `<path d="M${150 + s * 96} 172 L${150 + s * 116} 176 L${150 + s * 112} 204 L${150 + s * 96} 210" fill="${skin}" stroke="${INK}" stroke-width="4" stroke-linejoin="miter"/>`;
  // bóng đổ một bên mặt = dải vạch khắc chéo
  const hatch = [0, 1, 2, 3, 4].map((i) => cut([150 + jaw[1] - 10 - i * 2, jaw[2] - 40 + i * 12], [150 + jaw[1] - 24 - i * 3, jaw[2] - 30 + i * 12], 2.4, kit.dk(skin, 0.3))).join("");
  h.push(`<g id="${p}-mat">${ear(-1)}${ear(1)}<path d="${facePath(jaw)}" fill="${skin}" stroke="${INK}" stroke-width="5" stroke-linejoin="miter"/>${hatch}` +
    cut([146, ny], [156, ny + 1], 4.5) + cheek(-1) + cheek(1) + `</g>`);
  if (o.beard) h.push(`<g transform="translate(0 14)">${kit.beard(o.beard === true ? "rau-dai" : o.beard, o.beardColor || hc)}</g>`);
  h.push(kit.hairFront(front, hc, hg));
  for (const e of kit.EXPRS) {
    const eo = { eyes: o.eyes, fem: o.fem, age: o.age };
    h.push(`<g id="${p}-ex-${e}" opacity="${e === (o.expr || "vui") ? 1 : 0}">${marks(e)}${eye(CX - ex, -1, ed, e, eo)}${eye(CX + ex, 1, ed, e, eo)}${brows(e, hc, browThick)}${mouth(e, p, o.fem)}</g>`);
  }
  h.push(`<g id="${p}-blink" opacity="0">${[-1, 1].map((s) => { const cx = CX + s * ex; return `<ellipse cx="${cx}" cy="${EY - 2}" rx="${ed[0] + 8}" ry="${ed[1] * 2 + 4}" fill="${skin}"/>` + cut([cx - s * ed[0], EY + 2], [cx + s * ed[0], EY + ed[2] + 2], 5); }).join("")}</g>`);
  if (o.beard === "ria" || o.beard === "rau-dai" || o.beard === true) h.push(`<g transform="translate(0 14)">${kit.beard("ria", o.beardColor || hc)}</g>`);
  if (o.glasses) h.push(`<g fill="none" stroke="${INK}" stroke-width="4.5"><rect x="${CX - ex - 30}" y="${EY - 20}" width="60" height="40"/><rect x="${CX + ex - 30}" y="${EY - 20}" width="60" height="40"/></g>`);
  if (o.hat) h.push(kit.hat(o.hat, o.hatColor));
  return h.join("");
}
