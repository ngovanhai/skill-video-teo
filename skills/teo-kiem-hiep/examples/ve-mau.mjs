// MẪU THAM KHẢO mặt riêng của tập (rig 2): kiểu moe anime — mắt to gradient, mi dày, má gạch, tóc lọn nhọn tô cel 2 tông.
// KHÔNG chép nguyên vào tập: build so dấu vân mặt với file này và với các tập khác, trùng là dừng.
// Mỗi tập tự viết <dir>/ve.mjs theo kiểu riêng (mắt, mũi, khuôn mặt, miệng khác hẳn); file này chỉ để xem cấu trúc:
//   nhóm bắt buộc <p>-mat (khuôn mặt + mũi), <p>-ex-<biểu cảm> chứa <p>-mc-/<p>-mo-<biểu cảm>, <p>-blink.
// Trong tập: mỗi nhân vật khác mặt nhờ trục khuon/mui/mat (cast "mat": {...}) hoặc tự băm theo o.id.
// Lớp mắt: lòng trắng (nằm dưới mí) → mống mắt gradient tối trên/sáng dưới → bóng mí → đồng tử → ánh phản xạ đáy → highlight → mí trên dày có đuôi → mi dưới.
// Viền màu (nâu đỏ ấm), bóng da ngả hồng, má hồng có gạch chéo, tóc chia lọn nhọn tô cel 2 tông + vệt bóng.
const CX = 150, EY = 182, EX = 47, ERX = 29, ERY = 37;
const stH = (c, w = 2.6) => `stroke="${dk(c, 0.42)}" stroke-width="${w}" stroke-linejoin="round" stroke-linecap="round"`; // viền tóc nhạt, cùng tông
const LID = "#3A2224";
// khuôn mặt (trục "khuon"): tròn · trái xoan · cằm nhọn · hàm vuông — cùng trán/thái dương, khác cằm
const FACES = {
  tron: "M150 268 C122 268 60 252 52 190 C44 108 92 58 150 58 C208 58 256 108 248 190 C240 252 178 268 150 268Z",
  xoan: "M150 278 C118 278 64 250 54 190 C46 108 92 58 150 58 C208 58 254 108 246 190 C236 250 182 278 150 278Z",
  nhon: "M150 282 C134 278 76 246 56 196 C42 108 92 58 150 58 C208 58 258 108 244 196 C224 246 166 278 150 282Z",
  vuong: "M150 268 C110 268 62 260 54 214 C46 112 92 58 150 58 C208 58 254 112 246 214 C238 260 190 268 150 268Z",
};
// mũi (trục "mui"): chấm · móc (sống mũi cong) · bóng (mảng tối một bên) · hai lỗ mũi
const NOSES = {
  cham: (c) => `<path d="M148 222 l3 3" stroke="${c}" stroke-width="2.6" stroke-linecap="round"/>`,
  moc: (c) => `<path d="M152 196 Q156 214 147 226 Q151 228 155 225" fill="none" stroke="${c}" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"/>`,
  bong: (c) => `<path d="M151 200 L158 224 L148 226Z" fill="${c}" opacity=".35"/>`,
  lo: (c) => `<circle cx="145" cy="225" r="1.6" fill="${c}"/><circle cx="155" cy="225" r="1.6" fill="${c}"/>`,
};
// dáng mắt (trục "mat"): [giãn ngang, giãn dọc, nghiêng đuôi mắt °]
const EYES = { tron: [1, 1, 0], hanh: [1.1, 0.8, 0], xech: [1.04, 0.88, -9], sac: [1.14, 0.64, -4], cup: [1, 0.9, 7] };
const skinSh = (c) => toHex(hx(c).map((v, i) => v * 0.87 + [10, -8, -2][i]));
function eye(cx, o, side) {
  const { iris, expr, gid } = o, rx = ERX, ry = o.age === "gia" ? 24 : o.fem ? ERY : ERY * 0.84, wing = o.fem ? 10 : 5, cy = EY, ix = cx - side * rx, ox = cx + side * rx;
  const S = (d, w, c = LID, op = 1) => `<path d="${d}" fill="none" stroke="${c}" stroke-width="${w}" stroke-linecap="round" stroke-linejoin="round"${op < 1 ? ` opacity="${op}"` : ""}/>`;
  if (expr === "dac-y" && side > 0) return S(`M${ix} ${cy + 4} Q${cx} ${cy - 14} ${ox + side * 4} ${cy + 2}`, 6) + S(`M${ox + side * 2} ${cy + 2} l${side * 9} -4`, 3.5);
  if (expr === "ko") return S(`M${cx} ${cy} m-2 0 a2 2 0 1 1 4 0 a6 6 0 1 1 -12 0 a10 10 0 1 1 20 0 a14 14 0 1 1 -28 0 a18 18 0 1 1 36 0`, 4);
  const p = [];
  const lidB = `M${ix} ${cy - ry * 0.36} Q${cx} ${cy - ry * 1.12} ${ox} ${cy - ry * 0.4}`;
  // lòng trắng: mép trên trùng mí, đáy tròn
  p.push(`<path d="${lidB} Q${ox + side * 2} ${cy + ry * 0.9} ${cx + side * rx * 0.1} ${cy + ry} Q${ix - side * 2} ${cy + ry * 0.95} ${ix} ${cy - ry * 0.36}Z" fill="#FFFDFB"/>`);
  if (expr === "soc") {
    p.push(`<circle cx="${cx}" cy="${cy + 2}" r="8" fill="url(#${gid})"/><circle cx="${cx}" cy="${cy + 2}" r="3.5" fill="${dk(iris, 0.75)}"/><circle cx="${cx - 3}" cy="${cy - 2}" r="2.2" fill="#fff"/>`);
  } else {
    const look = expr === "ngai" ? -7 : 0, ir = rx * 0.8, iry = ry * 0.86, ic = cx + look, icy = cy + ry * 0.06;
    p.push(`<ellipse cx="${cx}" cy="${cy - ry * 0.5}" rx="${rx * 0.82}" ry="${ry * 0.38}" fill="${dk(iris, 0.3)}" opacity=".16"/>`); // bóng mí trên lòng trắng
    p.push(`<ellipse cx="${ic}" cy="${icy}" rx="${ir}" ry="${iry}" fill="url(#${gid})" stroke="${dk(iris, 0.6)}" stroke-width="2"/>`);
    p.push(`<ellipse cx="${ic}" cy="${icy - iry * 0.55}" rx="${ir * 0.84}" ry="${iry * 0.42}" fill="${dk(iris, 0.62)}" opacity=".55"/>`); // bóng mí trên mống mắt
    // vệt sáng toả từ đồng tử xuống nửa dưới + vòng sáng quanh đồng tử → mắt có chiều sâu
    p.push(`<path d="${[-0.6, -0.25, 0.1, 0.45].map((a) => `M${ic + ir * 0.3 * Math.sin(a)} ${icy + iry * 0.35} L${ic + ir * 0.82 * Math.sin(a)} ${icy + iry * 0.85 * Math.cos(a)}`).join(" ")}" stroke="${lt(iris, 0.6)}" stroke-width="2.2" stroke-linecap="round" opacity=".45"/>`);
    p.push(`<ellipse cx="${ic}" cy="${icy - 2}" rx="${ir * 0.54}" ry="${iry * 0.62}" fill="none" stroke="${lt(iris, 0.35)}" stroke-width="2" opacity=".5"/>`);
    p.push(`<ellipse cx="${ic}" cy="${icy - 2}" rx="${ir * 0.4}" ry="${iry * 0.5}" fill="${dk(iris, 0.75)}" opacity=".9"/>`);
    p.push(`<path d="M${ic - ir * 0.66} ${icy + iry * 0.3} Q${ic} ${icy + iry * 1.02} ${ic + ir * 0.66} ${icy + iry * 0.3} Q${ic} ${icy + iry * 0.6} ${ic - ir * 0.66} ${icy + iry * 0.3}Z" fill="${o.iris2}" opacity=".85"/>`); // ánh phản xạ đáy
    if (expr === "quyet-tam") p.push(`<path d="M${ic - ir * 0.3} ${icy - iry * 0.72} l3.5 8 8 3.5 -8 3.5 -3.5 8 -3.5 -8 -8 -3.5 8 -3.5Z" fill="#fff"/>`);
    else p.push(`<ellipse cx="${ic - ir * 0.3}" cy="${icy - iry * 0.4}" rx="${ir * 0.38}" ry="${iry * 0.28}" transform="rotate(-25 ${ic - ir * 0.3} ${icy - iry * 0.4})" fill="#fff"/>`);
    p.push(`<circle cx="${ic + ir * 0.42}" cy="${icy + iry * 0.3}" r="${ir * 0.15}" fill="#fff"/><circle cx="${ic - ir * 0.12}" cy="${icy + iry * 0.6}" r="2" fill="#fff" opacity=".9"/>`);
    if (expr === "buon") // mắt ngấn nước: dải nước ở mi dưới + highlight phụ
      p.push(`<ellipse cx="${cx}" cy="${cy + ry * 0.66}" rx="${rx * 0.8}" ry="${ry * 0.28}" fill="#D6F3FF" opacity=".6"/>${S(`M${cx - rx * 0.6} ${cy + ry * 0.48} Q${cx} ${cy + ry * 0.38} ${cx + rx * 0.6} ${cy + ry * 0.48}`, 2.5, "#fff", 0.9)}<circle cx="${ic + ir * 0.25}" cy="${icy - iry * 0.05}" r="${ir * 0.12}" fill="#fff"/>`);
  }
  // mí trên: dày giữa + đuôi ngoài, mỏng ở khoé trong
  p.push(`<path d="M${ix - side} ${cy - ry * 0.42} Q${cx - side * rx * 0.1} ${cy - ry * 1.32} ${ox + side * 3} ${cy - ry * 0.64} L${ox + side * wing} ${cy - ry * 0.4} L${ox + side} ${cy - ry * 0.38} Q${cx} ${cy - ry * 1.12} ${ix + side * 2} ${cy - ry * 0.34}Z" fill="${LID}" stroke="${LID}" stroke-width="1.5" stroke-linejoin="round"/>`);
  if (o.fem) p.push(S(`M${ox} ${cy - ry * 0.66} l${side * 8} -8`, 3.2) + S(`M${ox + side * 6} ${cy - ry * 0.45} l${side * 8} -2`, 2.6) + `<path d="M${ox + side * 1} ${cy + ry * 0.42} L${ox - side * 6} ${cy + ry * 0.74} L${ox - side * 2} ${cy + ry * 0.5}Z" fill="${LID}"/>`);
  p.push(S(`M${cx + side * rx * 0.2} ${cy + ry * 0.99} Q${cx + side * rx * 0.85} ${cy + ry * 0.86} ${ox + side} ${cy + ry * 0.42}`, 2.4, LID, 0.7));
  // biến thể mí: giận (xếch vào trong), đắc ý (mí sụp), ngại (mí hơi sụp)
  const skin = o.skin, cover = (y1, y2) => `<path d="M${ix - side * 2} ${cy - ry * 0.46} Q${cx - side * rx * 0.1} ${cy - ry * 1.36} ${ox + side * 4} ${cy - ry * 0.66} L${ox + side * 11} ${cy - ry * 0.4} L${ox + side * 11} ${y2} L${ix - side * 2} ${y1}Z" fill="${skin}"/>` + S(`M${ix - side * 2} ${y1 + 1} L${ox + side * 9} ${y2 + 1}`, 6.5);
  if (expr === "gian") p.push(cover(cy - ry * 0.12, cy - ry * 0.72));
  if (expr === "dac-y" || o.sleepy) p.push(cover(cy - ry * 0.12, cy - ry * 0.18));
  if (expr === "ngai") p.push(cover(cy - ry * 0.5, cy - ry * 0.6));
  if (expr === "buon") p.push(`<path d="M${ox - side * 2} ${cy + ry * 0.75} q${side * 7} 12 0 20 q${-side * 7} -8 0 -20Z" fill="#CDEFFF" stroke="#6CB8E6" stroke-width="1.8"/><circle cx="${ox - side * 1}" cy="${cy + ry * 1.12}" r="1.6" fill="#fff"/>`);
  return p.join("");
}
// lông mày vót: dày ở đầu trong, nhọn ở đuôi ngoài (đa giác lấy mẫu dọc đường cong bậc 2)
function taper(x0, y0, qx, qy, x1, y1, w0, w1) {
  const pt = (t) => [(1 - t) ** 2 * x0 + 2 * (1 - t) * t * qx + t * t * x1, (1 - t) ** 2 * y0 + 2 * (1 - t) * t * qy + t * t * y1];
  const a = [], b = [];
  for (let i = 0; i <= 8; i++) {
    const t = i / 8, [x, y] = pt(t), [nx2, ny2] = pt(Math.min(1, t + 0.01)), [px, py] = pt(Math.max(0, t - 0.01));
    const dx = nx2 - px, dy = ny2 - py, n = Math.hypot(dx, dy) || 1, w = (w0 + (w1 - w0) * t) / 2;
    a.push(`${(x - (dy / n) * w).toFixed(1)} ${(y + (dx / n) * w).toFixed(1)}`); b.unshift(`${(x + (dy / n) * w).toFixed(1)} ${(y - (dx / n) * w).toFixed(1)}`);
  }
  return `M${a.join(" L")} L${b.join(" L")}Z`;
}
function brows(expr, c, age) {
  // mỗi bên: [y đuôi ngoài, y điểm uốn, y đầu trong] (đầu trong ở gần sống mũi)
  const k = {
    gian: [-8, 0, 8], buon: [6, -2, -10], soc: [-8, -18, -10], "quyet-tam": [-4, 0, 5],
    "dac-y": [[0, -7, -1], [-10, -16, -6]], ngai: [4, -4, -6], ko: [-2, -14, -6],
  }[expr] || [0, -8, -3];
  const y = EY - 60, old = age === "gia", [wi, wo] = old ? [11, 7] : [6.5, 1.5];
  const one = (s, [yo, ym, yi]) => taper(CX + s * 24, y + yi, CX + s * 48, y + ym, CX + s * 72, y + yo, wi, wo);
  const [kl, kr] = Array.isArray(k[0]) ? k : [k, k];
  return `<path d="${one(-1, kl)} ${one(1, kr)}" fill="${dk(c, 0.3)}" stroke="${dk(c, 0.3)}" stroke-width="1" stroke-linejoin="round"/>`;
}
function mouth(expr, p) {
  const y = 240, M = "#A8323F", S = `stroke="${LID}" stroke-width="2.5" stroke-linejoin="round"`, L = (d, w = 3.2) => `<path d="${d}" fill="none" stroke="${LID}" stroke-width="${w}" stroke-linecap="round" stroke-linejoin="round"/>`;
  const open = {
    vui: `<path d="M140 ${y - 1} Q150 ${y - 3} 160 ${y - 1} Q158 ${y + 14} 150 ${y + 14} Q142 ${y + 14} 140 ${y - 1}Z" fill="${M}" ${S}/><path d="M144 ${y + 10} Q150 ${y + 5} 156 ${y + 10} Q150 ${y + 14} 144 ${y + 10}Z" fill="#FF9AAA"/>`,
    gian: `<path d="M138 ${y + 2} L162 ${y + 2} L157 ${y + 14} L143 ${y + 14}Z" fill="${M}" ${S}/><path d="M141 ${y + 3} L145 ${y + 9} L149 ${y + 3}" fill="#fff"/>`,
    buon: `<path d="M141 ${y + 10} Q150 ${y - 1} 159 ${y + 10} Q150 ${y + 8} 141 ${y + 10}Z" fill="${M}" ${S}/>`,
    soc: `<ellipse cx="150" cy="${y + 6}" rx="8" ry="11" fill="${M}" ${S}/>`,
    "dac-y": `<path d="M140 ${y} Q154 ${y + 2} 162 ${y - 5} Q158 ${y + 12} 149 ${y + 11} Q142 ${y + 9} 140 ${y}Z" fill="${M}" ${S}/>`,
    ngai: `<ellipse cx="150" cy="${y + 5}" rx="5.5" ry="5" fill="${M}" ${S}/>`,
    "quyet-tam": `<path d="M139 ${y} Q150 ${y + 3} 161 ${y} Q159 ${y + 12} 150 ${y + 12} Q141 ${y + 12} 139 ${y}Z" fill="#fff" ${S}/><path d="M140 ${y + 5} L160 ${y + 5}" stroke="${LID}" stroke-width="1.6"/>`,
  }, closed = {
    vui: L(`M141 ${y} Q150 ${y + 8} 159 ${y}`),
    binh: L(`M144 ${y + 3} Q150 ${y + 5} 156 ${y + 3}`, 3),
    gian: L(`M140 ${y + 7} Q150 ${y + 1} 160 ${y + 7}`) + `<path d="M144 ${y + 4} l3 5 2 -6Z" fill="#fff" ${S}/>`,
    buon: L(`M136 ${y + 5} q3.5 -5 7 0 t7 0 t7 0 t7 0`, 3), // miệng mếu gợn sóng
    soc: `<ellipse cx="150" cy="${y + 5}" rx="5" ry="7" fill="${M}" ${S}/>`,
    "dac-y": L(`M139 ${y} Q144.5 ${y + 8} 150 ${y + 1} Q155.5 ${y + 8} 161 ${y}`), // miệng mèo ω
    ngai: L(`M141 ${y + 4} q3 -4 6 0 t6 0 t6 0`, 2.8),
    "quyet-tam": L(`M141 ${y + 3} L159 ${y + 2}`, 3.6),
    ko: `<ellipse cx="150" cy="${y + 6}" rx="7" ry="5" fill="${M}" ${S}/>`,
  };
  const e = expr === "binh" ? "vui" : expr === "ko" ? "soc" : expr;
  return `<g id="${p}-mc-${expr}">${closed[expr] || closed.vui}</g><g id="${p}-mo-${expr}" opacity="0">${open[e] || open.vui}</g>`;
}
function marks(expr) {
  const by = 228, blush = (op) => [-1, 1].map((s) => { const x = CX + s * 68; return `<ellipse cx="${x}" cy="${by}" rx="20" ry="8.5" fill="#FFA9A2" opacity="${op}"/><path d="M${x - 11} ${by + 4} l5 -8 M${x - 3} ${by + 4} l5 -8 M${x + 5} ${by + 4} l5 -8" stroke="#EE6F78" stroke-width="2.2" stroke-linecap="round" opacity="${Math.min(1, op + 0.2)}"/>`; }).join("");
  const sweat = `<path d="M240 120 q10 14 0 22 q-10 -8 0 -22Z" fill="#CDEFFF" stroke="#6CB8E6" stroke-width="2"/>`;
  switch (expr) {
    case "gian": return blush(0.25) + `<g transform="translate(222 100) scale(.8)" stroke="#E23D3D" stroke-width="5" stroke-linecap="round" fill="none"><path d="M-12 -4 Q-4 -4 -4 -12 M4 -12 Q4 -4 12 -4 M12 4 Q4 4 4 12 M-4 12 Q-4 4 -12 4"/></g>`;
    case "soc": return `<path d="M96 106 l0 20 M110 100 l0 26 M124 104 l0 18" stroke="#5B6BD6" stroke-width="3" stroke-linecap="round" opacity=".6"/>` + sweat;
    case "ngai": return blush(0.85) + sweat;
    case "buon": return blush(0.75);
    case "dac-y": return blush(0.45);
    case "quyet-tam": return blush(0.3);
    case "ko": return blush(0.2);
    default: return blush(0.5);
  }
}
// tóc: chỏm (cap) + các lọn nhọn chồng nhau, mỗi lọn tô cel 2 tông (gradient cắt cứng) + vệt bóng "vòng thiên thần"
const lock = (a, b, tip, bend = 0) => `M${a[0]} ${a[1]} Q${(a[0] + tip[0]) / 2 + bend} ${(a[1] + tip[1]) / 2} ${tip[0]} ${tip[1]} Q${(b[0] + tip[0]) / 2 + bend * 0.5} ${(b[1] + tip[1]) / 2} ${b[0]} ${b[1]}Z`;
const CAP = "M44 176 C36 88 94 38 150 38 C206 38 264 88 256 176 C248 120 210 92 150 92 C90 92 52 120 44 176Z";
const SIDE = (s) => lock([150 + s * 88, 104], [150 + s * 106, 128], [150 + s * 98, 262], s * 10); // lọn mai ôm mặt
const LOCKS = {
  bangs: [lock([50, 124], [92, 86], [58, 190], -14), lock([78, 98], [128, 76], [102, 170], -12), lock([112, 82], [156, 72], [134, 146], -6), lock([140, 72], [186, 80], [162, 162], 8), lock([170, 78], [220, 98], [198, 174], 12), lock([206, 92], [252, 126], [244, 192], 14)],
  side: [lock([50, 124], [104, 78], [64, 182], -10), lock([88, 88], [170, 66], [100, 150], -14), lock([132, 70], [214, 86], [128, 132], -22), lock([196, 84], [252, 128], [238, 176], 8)],
  spiky: [lock([52, 124], [96, 84], [40, 150], -6), lock([84, 92], [134, 70], [92, 148], -8), lock([118, 74], [172, 70], [150, 142], 2), lock([160, 72], [214, 92], [196, 148], 8), lock([204, 88], [250, 126], [262, 150], 6)],
  short: [lock([54, 120], [100, 84], [70, 160], -6), lock([90, 88], [150, 70], [110, 136], -6), lock([140, 70], [204, 86], [172, 134], 6), lock([196, 84], [248, 122], [232, 160], 8)],
  swept: [lock([60, 130], [110, 82], [86, 104], 6), lock([190, 82], [240, 130], [214, 104], -6)],
};
const HAIR = { "mai-bang": ["bangs", null, 1], "re-ngoi": ["side", null, 1], "bom-gai": ["spiky", "spikyBack"], "duoi-ngua": ["side", "pony", 1], "bui-cao": ["swept", "bunHigh", 1], "bui-toi": ["swept", "knot", 1], ngan: ["short"], troc: ["none"], "tien-ong": ["swept", "knot", 1], "dai-thang": ["bangs", "long", 1] };
function hairBack(kind, c, gid) {
  const g = `fill="url(#${gid})" ${stH(c, 3)}`;
  switch (kind) {
    case "long": return `<path d="M52 150 C40 220 48 262 72 284 L228 284 C252 262 260 220 248 150 Z" ${g}/><path d="M58 200 C40 270 42 330 54 380 L70 362 L82 384 L94 360 C90 320 92 280 98 262 Z" ${g}/><path d="M242 200 C260 270 258 330 246 380 L230 362 L218 384 L206 360 C210 320 208 280 202 262 Z" ${g}/><path d="M66 260 Q60 320 70 360 M234 260 Q240 320 230 360" fill="none" stroke="${dk(c, 0.35)}" stroke-width="2.5" opacity=".6"/>`;
    case "bunHigh": return `<circle cx="150" cy="30" r="34" ${g}/><path d="M124 22 Q150 6 176 22" fill="none" stroke="${lt(c, 0.5)}" stroke-width="5" stroke-linecap="round" opacity=".7"/>`;
    case "knot": return `<ellipse cx="150" cy="36" rx="26" ry="22" ${g}/><path d="M134 28 Q150 18 166 28" fill="none" stroke="${lt(c, 0.5)}" stroke-width="4" stroke-linecap="round" opacity=".7"/><rect x="136" y="18" width="28" height="9" rx="3" fill="#C9A227" ${st("#C9A227")}/>`;
    case "spikyBack": return `<path d="M58 176 L26 156 L52 130 L30 96 L72 94 L66 52 L108 66 L120 24 L150 50 L180 24 L192 66 L234 52 L228 94 L270 96 L248 130 L274 156 L242 176 Z" ${g}/>`;
    default: return "";
  }
}
function hairFront(kind, c, gid, side, young) {
  const g = `fill="url(#${gid})" ${stH(c)}`;
  if (kind === "none") return { shadow: "", front: `<path d="M106 82 Q150 64 194 82" fill="none" stroke="#fff" stroke-width="6" stroke-linecap="round" opacity=".45"/>` };
  const locks = LOCKS[kind] || LOCKS.short, sides = side ? [SIDE(-1), SIDE(1)] : [];
  const shadow = `<g transform="translate(150 9) scale(.92 1) translate(-150 0)">${locks.map((d) => `<path d="${d}"/>`).join("")}</g>`;
  const shine = [[104, 74, -24], [150, 62, 0], [196, 74, 24]].map(([x, y, r]) => `<path d="M${x - 16} ${y} Q${x} ${y - 7} ${x + 16} ${y} Q${x} ${y + 4} ${x - 16} ${y}Z" transform="rotate(${r} ${x} ${y})" fill="${lt(c, 0.6)}" opacity=".8"/>`).join("");
  const ahoge = !young || kind === "spiky" || kind === "swept" ? "" : `<path d="M150 40 Q136 10 170 4 Q148 16 158 40Z" ${g}/>`;
  return { shadow, front: ahoge + `<path d="${CAP}" fill="url(#${gid}2)" ${stH(c)}/>` + locks.map((d) => `<path d="${d}" ${g}/>`).join("") + shine + sides.map((d) => `<path d="${d}" ${g}/>`).join("") };
}
function beard(kind, c) {
  const g = `fill="${c}" ${st(c)}`;
  switch (kind) {
    case "rau-de": return `<path d="M138 252 Q150 288 162 252 Q150 260 138 252Z" ${g}/>`;
    case "rau-dai": return `<path d="M96 230 Q100 268 150 272 Q200 268 204 230 Q206 306 150 346 Q94 306 96 230Z" ${g}/><path d="M130 288 Q150 308 170 288" fill="none" stroke="${lt(c, 0.5)}" stroke-width="3" opacity=".6"/>`;
    case "ria": return `<path d="M150 226 Q132 218 116 232 Q132 234 150 230 Q168 234 184 232 Q168 218 150 226Z" ${g}/>`;
    default: return "";
  }
}
function hat(kind, c = "#8A2A1E") {
  switch (kind) {
    case "non-la": return `<path d="M150 -10 L292 92 Q150 114 8 92 Z" fill="#F2D88A" ${st("#C9A227")}/>${[40, 70, 100].map((y) => `<path d="M${150 - y * 1.3} ${y - 8} Q150 ${y + 2} ${150 + y * 1.3} ${y - 8}" fill="none" stroke="#C9A227" stroke-width="2"/>`).join("")}`;
    case "khan": return `<path d="M48 122 C52 64 100 34 150 34 C200 34 248 64 252 122 C210 104 90 104 48 122 Z" fill="${c}" ${st(c)}/><path d="M58 100 Q150 70 242 100" fill="none" stroke="${dk(c, 0.4)}" stroke-width="3"/>`;
    case "linh": return `<path d="M42 146 C38 66 96 26 150 26 C204 26 262 66 258 146 C232 114 68 114 42 146Z" fill="#3A3F47" ${st("#3A3F47")}/><path d="M150 26 L150 2" stroke="#2A2F36" stroke-width="6"/><circle cx="150" cy="0" r="9" fill="#C8372D" ${st("#C8372D")}/>`;
    case "troc": return `${[130, 150, 170].map((x) => `<circle cx="${x}" cy="76" r="4" fill="#B5813E"/>`).join("")}`;
    case "tram": return `<path d="M100 30 L210 42" stroke="#C9D3DD" stroke-width="5" stroke-linecap="round"/><circle cx="100" cy="30" r="6" fill="#E3A21A" ${st("#E3A21A")}/>`;
    default: return "";
  }
}

let dk, lt, hx, toHex, st;
// băm id → số; dùng để mỗi nhân vật tự có tổ hợp + lệch nhỏ riêng khi cast không ghi "mat"
const hash = (s) => [...String(s)].reduce((a, ch) => (Math.imul(a, 31) + ch.charCodeAt(0)) >>> 0, 7);
const pickBy = (obj, n) => Object.keys(obj)[n % Object.keys(obj).length];
// ve.mjs: export default (p, o, kit) → svg đầu (toạ độ 300×420, đỉnh tóc y=38). o.mat = cast.mat {khuon, mui, mat}
export default function ve(p, o, kit) {
  ({ dk, lt, hx, toHex, st } = kit);
  const EXPRS = kit.EXPRS, skin = o.skin, hc = o.hair.color, hg = `${p}-hg`, ig = `${p}-ig`, ssh = skinSh(skin);
  const n = hash(o.id || p), m = o.mat || {};
  const khuon = m.khuon || pickBy(FACES, n), mui = m.mui || pickBy(NOSES, n >> 3), dang = m.mat || pickBy(EYES, n >> 6);
  const ex = EX + ((n >> 9) % 7) - 3; // khoảng cách hai mắt lệch ±3
  const [sx, sy, tilt] = EYES[dang] || EYES.tron;
  const [front, back, side] = HAIR[o.hair.style] || HAIR.ngan;
  const iris2 = o.eyes2 || lt(o.eyes, 0.55);
  const h = [];
  h.push(`<defs><linearGradient id="${hg}" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="${lt(hc, 0.22)}"/><stop offset=".56" stop-color="${hc}"/><stop offset=".56" stop-color="${dk(hc, 0.13)}"/><stop offset="1" stop-color="${dk(hc, 0.22)}"/></linearGradient><linearGradient id="${hg}2" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="${lt(hc, 0.25)}"/><stop offset="1" stop-color="${hc}"/></linearGradient><linearGradient id="${ig}" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="${dk(o.eyes, 0.5)}"/><stop offset=".5" stop-color="${o.eyes}"/><stop offset="1" stop-color="${lt(o.eyes, 0.4)}"/></linearGradient></defs>`);
  if (back) h.push(hairBack(back, hc, hg));
  // nhóm <p>-mat (bắt buộc): tai + khuôn mặt + bóng cằm + mũi
  h.push(`<g id="${p}-mat"><ellipse cx="52" cy="190" rx="11" ry="16" fill="${skin}" ${st(skin)}/><ellipse cx="248" cy="190" rx="11" ry="16" fill="${skin}" ${st(skin)}/><path d="${FACES[khuon] || FACES.tron}" fill="${skin}" ${st(skin, 2.6)}/><path d="M72 222 C94 256 206 256 228 222 C212 252 184 264 150 264 C116 264 88 252 72 222Z" fill="${ssh}" opacity=".5"/>${(NOSES[mui] || NOSES.cham)(dk(skin, 0.3))}</g>`);
  const hf = hairFront(front, hc, hg, side, o.age !== "gia" && !o.hat);
  if (hf.shadow) h.push(`<g fill="${ssh}">${hf.shadow}</g>`); // bóng tóc đổ lên trán
  if (o.beard) h.push(beard(o.beard === true ? "rau-dai" : o.beard, o.beardColor || hc));
  h.push(hf.front); // mắt + lông mày vẽ đè lên mái (kiểu anime tóc "trong suốt")
  const shape = (cx, s, svg) => `<g transform="translate(${cx} ${EY}) rotate(${s * tilt}) scale(${sx} ${sy}) translate(${-cx} ${-EY})">${svg}</g>`;
  for (const e of EXPRS) {
    const eo = { iris: o.eyes, iris2, expr: e, gid: ig, skin, age: o.age, fem: o.fem };
    h.push(`<g id="${p}-ex-${e}" opacity="${e === (o.expr || "vui") ? 1 : 0}">${marks(e)}${shape(CX - ex, -1, eye(CX - ex, eo, -1)) + shape(CX + ex, 1, eye(CX + ex, eo, 1))}${brows(e, hc, o.age)}${mouth(e, p)}</g>`);
  }
  h.push(`<g id="${p}-blink" opacity="0">${[-1, 1].map((s) => { const cx = CX + s * ex; return shape(cx, s, `<ellipse cx="${cx}" cy="${EY - 6}" rx="37" ry="45" fill="${skin}"/><path d="M${cx - 28} ${EY + 4} Q${cx} ${EY + 17} ${cx + 28} ${EY + 4} l${s * 6} -5" fill="none" stroke="${LID}" stroke-width="5.5" stroke-linecap="round" stroke-linejoin="round"/>`); }).join("")}</g>`);
  if (o.beard === "ria" || o.beard === "rau-dai" || o.beard === true) h.push(beard("ria", o.beardColor || hc));
  if (o.glasses) h.push(`<g fill="none" stroke="#4A3A30" stroke-width="4.5"><circle cx="${CX - ex}" cy="${EY + 2}" r="39"/><circle cx="${CX + ex}" cy="${EY + 2}" r="39"/><path d="M${CX - ex + 36} ${EY - 4} Q${CX} ${EY - 10} ${CX + ex - 36} ${EY - 4} M${CX - ex - 39} ${EY - 4} L54 182 M${CX + ex + 39} ${EY - 4} L246 182"/></g>`);
  if (o.hat) h.push(hat(o.hat, o.hatColor));
  return h.join("");
}
