// ANIME CHIBI — copy to <video>/work/gen-chars.mjs, edit the `chars` map at the bottom, run: node work/gen-chars.mjs
// Each character → chars/<key>.svg (default expression) + chars/<key>-<expr>.svg for every expression in `exprs`.
// Style: 300x420, ~2.3 heads tall, big glossy eyes, layered hair with gradient shine, thin tinted outlines (3.5px),
// soft blush. Every file keeps <g id="mouth-closed"> / <g id="mouth-open"> for lip-sync. Budget: ≤12 KB per file.
// Also writes work/chars-preview.html (open it in the Browser pane and screenshot to self-check).
//   node work/gen-chars.mjs              → characters of this video
//   node gen-chars.anime.mjs --teo <dir> → anime Tèo (6 poses, 500x760) into <dir>
import { writeFileSync, statSync, mkdirSync } from "node:fs";
import { join, dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";

// ---------------------------------------------------------------- colour helpers
const hx = (c) => { c = c.replace("#", ""); if (c.length === 3) c = [...c].map((x) => x + x).join(""); return [0, 2, 4].map((i) => parseInt(c.slice(i, i + 2), 16)); };
const toHex = (a) => "#" + a.map((v) => Math.max(0, Math.min(255, Math.round(v))).toString(16).padStart(2, "0")).join("");
const dk = (c, f = 0.45) => toHex(hx(c).map((v) => v * (1 - f)));
const lt = (c, f = 0.35) => toHex(hx(c).map((v) => v + (255 - v) * f));
const SW = 3.5;
const st = (c, w = SW) => `stroke="${dk(c, 0.55)}" stroke-width="${w}" stroke-linejoin="round" stroke-linecap="round"`;
const LINE = "#3A2420";

// skin tones
export const SKIN = { sang: "#FFE3CF", vang: "#FBD3B0", nau: "#E2A578", dam: "#A86B45" };

// ---------------------------------------------------------------- layout (300x420)
const CX = 150, EY = 172, EX = 38; // eye centre y, half distance between eyes
const FACE = "M150 262 C110 262 58 232 53 170 C48 100 92 56 150 56 C208 56 252 100 247 170 C242 232 190 262 150 262Z";

// ---------------------------------------------------------------- eyes
function eye(cx, o, side) {
  const { type, iris, expr } = o;
  const rx = 23, ry = type === "sac" ? 21 : type === "gia" ? 14 : 29;
  const cy = EY + (type === "sac" ? 4 : 0);
  const look = expr === "ngai" ? -6 * side : 0;
  const tiny = expr === "soc";
  const p = [];
  const closedArc = (up) => `<path d="M${cx - rx} ${cy + 4} Q${cx} ${cy + (up ? -16 : 14)} ${cx + rx} ${cy + 4}" fill="none" stroke="${LINE}" stroke-width="6" stroke-linecap="round"/>`;
  if (type === "hip" || (type === "nhay" && side > 0) || (expr === "vui" && type === "gia")) return closedArc(true);
  if (expr === "buon" && type === "hip") return closedArc(false);
  p.push(`<ellipse cx="${cx}" cy="${cy}" rx="${rx}" ry="${ry}" fill="#fff"/>`);
  if (tiny) {
    p.push(`<circle cx="${cx}" cy="${cy}" r="6" fill="${dk(iris, 0.5)}"/><circle cx="${cx - 2}" cy="${cy - 2}" r="2" fill="#fff"/>`);
  } else {
    const ir = rx * 0.74, iry = ry * 0.8, ic = cx + look, icy = cy + ry * 0.1;
    p.push(`<ellipse cx="${ic}" cy="${icy}" rx="${ir}" ry="${iry}" fill="url(#iris)"/>`);
    p.push(`<ellipse cx="${ic}" cy="${icy + 2}" rx="${ir * 0.45}" ry="${iry * 0.5}" fill="${dk(iris, 0.7)}"/>`);
    if (type === "lap-lanh" || expr === "quyet-tam") {
      const s = (x, y, r) => `<path d="M${x} ${y - r} L${x + r * 0.3} ${y - r * 0.3} L${x + r} ${y} L${x + r * 0.3} ${y + r * 0.3} L${x} ${y + r} L${x - r * 0.3} ${y + r * 0.3} L${x - r} ${y} L${x - r * 0.3} ${y - r * 0.3}Z" fill="#fff"/>`;
      p.push(s(ic - ir * 0.35, icy - iry * 0.4, 9), s(ic + ir * 0.4, icy + iry * 0.4, 5));
    } else {
      p.push(`<circle cx="${ic - ir * 0.38}" cy="${icy - iry * 0.42}" r="${ir * 0.36}" fill="#fff"/><circle cx="${ic + ir * 0.4}" cy="${icy + iry * 0.42}" r="${ir * 0.15}" fill="#fff"/>`);
    }
  }
  // lids: sleepy / smug cover the top half with skin
  const half = type === "buon-ngu" || expr === "dac-y";
  if (half) p.push(`<path d="M${cx - rx - 2} ${cy + 2} L${cx - rx - 2} ${cy - ry - 4} L${cx + rx + 2} ${cy - ry - 4} L${cx + rx + 2} ${cy + 2}Z" fill="${o.skin}"/><path d="M${cx - rx - 3} ${cy + 2} Q${cx} ${cy - 3} ${cx + rx + 3} ${cy + 2}" fill="none" stroke="${LINE}" stroke-width="6" stroke-linecap="round"/>`);
  else {
    // upper lash: thick, outer corner flick (outer = away from centre)
    const ox = cx + side * (rx + 4), ix = cx - side * (rx + 2);
    const tilt = type === "sac" || expr === "gian" ? -side * 0 : 0;
    const ang = expr === "gian" ? 7 : expr === "buon" ? -6 : 0; // inner corner down when angry, up when sad
    p.push(`<path d="M${ix} ${cy - ry * 0.25 + ang} Q${cx} ${cy - ry - 9 + tilt} ${ox} ${cy - ry * 0.45 - (type === "sac" ? 6 : 0)}" fill="none" stroke="${LINE}" stroke-width="6.5" stroke-linecap="round"/>`);
    p.push(`<path d="M${ox - side * 2} ${cy - ry * 0.45} l${side * 8} -7" stroke="${LINE}" stroke-width="4" stroke-linecap="round"/>`);
    p.push(`<path d="M${cx - rx * 0.6} ${cy + ry + 2} Q${cx} ${cy + ry + 5} ${cx + rx * 0.6} ${cy + ry + 2}" fill="none" stroke="${LINE}" stroke-width="2.5" stroke-linecap="round" opacity=".7"/>`);
  }
  if (expr === "buon" && side < 0) p.push(`<path d="M${cx - 6} ${cy + ry} q-6 14 0 20 q6 -6 0 -20Z" fill="#8FD3FF" stroke="#4A9BD6" stroke-width="2"/>`);
  return p.join("");
}

function brows(o) {
  const c = dk(o.hairColor, 0.25), w = o.eyeType === "gia" ? 7 : 4.5;
  const y = EY - 46;
  const d = {
    gian: [`M${CX - 62} ${y - 6} L${CX - 16} ${y + 10}`, `M${CX + 62} ${y - 6} L${CX + 16} ${y + 10}`],
    buon: [`M${CX - 60} ${y + 8} Q${CX - 40} ${y - 4} ${CX - 18} ${y - 8}`, `M${CX + 60} ${y + 8} Q${CX + 40} ${y - 4} ${CX + 18} ${y - 8}`],
    soc: [`M${CX - 60} ${y - 6} Q${CX - 40} ${y - 16} ${CX - 20} ${y - 8}`, `M${CX + 60} ${y - 6} Q${CX + 40} ${y - 16} ${CX + 20} ${y - 8}`],
    "quyet-tam": [`M${CX - 60} ${y - 4} L${CX - 18} ${y + 6}`, `M${CX + 60} ${y - 4} L${CX + 18} ${y + 6}`],
    "dac-y": [`M${CX - 60} ${y} Q${CX - 40} ${y - 8} ${CX - 18} ${y - 2}`, `M${CX + 60} ${y - 10} Q${CX + 40} ${y - 16} ${CX + 18} ${y - 6}`],
  }[o.expr] || [`M${CX - 60} ${y} Q${CX - 40} ${y - 9} ${CX - 18} ${y - 3}`, `M${CX + 60} ${y} Q${CX + 40} ${y - 9} ${CX + 18} ${y - 3}`];
  return `<path d="${d[0]} ${d[1]}" fill="none" stroke="${c}" stroke-width="${w}" stroke-linecap="round"/>`;
}

function mouth(expr) {
  const y = 226, open = {
    vui: `<path d="M136 ${y - 2} Q150 ${y - 4} 164 ${y - 2} Q162 ${y + 18} 150 ${y + 18} Q138 ${y + 18} 136 ${y - 2}Z" fill="#B8344A" stroke="${LINE}" stroke-width="3"/><path d="M142 ${y + 12} Q150 ${y + 6} 158 ${y + 12} Q150 ${y + 18} 142 ${y + 12}Z" fill="#FF8FA3"/>`,
    gian: `<path d="M134 ${y + 2} L166 ${y + 2} L160 ${y + 18} L140 ${y + 18}Z" fill="#B8344A" stroke="${LINE}" stroke-width="3"/><path d="M136 ${y + 5} L164 ${y + 5}" stroke="#fff" stroke-width="4"/>`,
    buon: `<path d="M138 ${y + 14} Q150 ${y} 162 ${y + 14} Q150 ${y + 10} 138 ${y + 14}Z" fill="#B8344A" stroke="${LINE}" stroke-width="3"/>`,
    soc: `<ellipse cx="150" cy="${y + 8}" rx="11" ry="15" fill="#B8344A" stroke="${LINE}" stroke-width="3"/>`,
    "dac-y": `<path d="M138 ${y} Q154 ${y + 2} 166 ${y - 6} Q160 ${y + 14} 148 ${y + 12} Q140 ${y + 10} 138 ${y}Z" fill="#B8344A" stroke="${LINE}" stroke-width="3"/>`,
    ngai: `<ellipse cx="150" cy="${y + 6}" rx="7" ry="6" fill="#B8344A" stroke="${LINE}" stroke-width="3"/>`,
    "quyet-tam": `<path d="M134 ${y} Q150 ${y + 4} 166 ${y} Q164 ${y + 16} 150 ${y + 16} Q136 ${y + 16} 134 ${y}Z" fill="#fff" stroke="${LINE}" stroke-width="3"/><path d="M135 ${y + 6} L165 ${y + 6}" stroke="${LINE}" stroke-width="2"/>`,
  }, closed = {
    vui: `<path d="M140 ${y} Q150 ${y + 9} 160 ${y}" fill="none" stroke="${LINE}" stroke-width="4" stroke-linecap="round"/>`,
    gian: `<path d="M138 ${y + 8} Q144 ${y + 2} 150 ${y + 6} Q156 ${y + 2} 162 ${y + 8}" fill="none" stroke="${LINE}" stroke-width="4" stroke-linecap="round"/>`,
    buon: `<path d="M140 ${y + 8} Q150 ${y} 160 ${y + 8}" fill="none" stroke="${LINE}" stroke-width="4" stroke-linecap="round"/>`,
    soc: `<ellipse cx="150" cy="${y + 6}" rx="6" ry="8" fill="#B8344A" stroke="${LINE}" stroke-width="3"/>`,
    "dac-y": `<path d="M136 ${y + 2} Q143 ${y + 8} 150 ${y + 2} Q157 ${y + 8} 166 ${y - 4}" fill="none" stroke="${LINE}" stroke-width="4" stroke-linecap="round"/>`,
    ngai: `<path d="M138 ${y + 4} q4 -4 8 0 t8 0 t8 0" fill="none" stroke="${LINE}" stroke-width="3.5" stroke-linecap="round"/>`,
    "quyet-tam": `<path d="M138 ${y + 4} L162 ${y + 2}" stroke="${LINE}" stroke-width="4.5" stroke-linecap="round"/>`,
  };
  return `<g id="mouth-closed">${closed[expr] || closed.vui}</g><g id="mouth-open" opacity="0">${open[expr] || open.vui}</g>`;
}

// expression marks around the face
function marks(expr, o) {
  const blush = (op = 0.45, lines = false) => `<ellipse cx="${CX - 62}" cy="208" rx="17" ry="9" fill="#FF8FA3" opacity="${op}"/><ellipse cx="${CX + 62}" cy="208" rx="17" ry="9" fill="#FF8FA3" opacity="${op}"/>` +
    (lines ? `<path d="M${CX - 74} 212 l8 -10 M${CX - 64} 213 l8 -10 M${CX - 54} 212 l8 -10 M${CX + 50} 212 l8 -10 M${CX + 60} 213 l8 -10 M${CX + 70} 212 l8 -10" stroke="#E0506E" stroke-width="2.5" stroke-linecap="round"/>` : "");
  switch (expr) {
    case "gian": return blush(0.3) + `<g transform="translate(228 92)" stroke="#E23D3D" stroke-width="5" stroke-linecap="round" fill="none"><path d="M-12 -4 Q-4 -4 -4 -12 M4 -12 Q4 -4 12 -4 M12 4 Q4 4 4 12 M-4 12 Q-4 4 -12 4"/></g>`;
    case "soc": return `<path d="M88 104 l0 22 M104 98 l0 26 M120 102 l0 20" stroke="#5B6BD6" stroke-width="3" stroke-linecap="round" opacity=".7"/><path d="M236 120 q10 14 0 22 q-10 -8 0 -22Z" fill="#8FD3FF" stroke="#4A9BD6" stroke-width="2"/>`;
    case "ngai": return blush(0.7, true) + `<path d="M238 118 q9 13 0 20 q-9 -7 0 -20Z" fill="#8FD3FF" stroke="#4A9BD6" stroke-width="2"/>`;
    case "dac-y": return blush(0.4) + `<path d="M258 120 l4 10 l10 4 l-10 4 l-4 10 l-4 -10 l-10 -4 l10 -4Z" fill="#FFD84A" stroke="#C9A227" stroke-width="2"/>`;
    case "quyet-tam": return blush(0.35) + `<path d="M252 150 q14 -18 4 -36 q18 10 16 30 q8 -8 6 -18 q12 22 -6 36Z" fill="#FF8A3D" stroke="#D0531C" stroke-width="2.5"/>`;
    case "buon": return blush(0.25);
    default: return blush(o.age === "gia" ? 0.2 : 0.5);
  }
}

// ---------------------------------------------------------------- hair (back layer + front layer)
const HAIR = {
  "mai-bang":  { front: "bangs" },
  "re-ngoi":   { front: "side" },
  "bom-gai":   { front: "spiky", back: "spikyBack" },
  "duoi-ngua": { front: "side", back: "pony" },
  "hai-bim":   { front: "bangs", back: "pigtails" },
  "bui-cao":   { front: "swept", back: "bunHigh" },
  "bui-toi":   { front: "swept", back: "knot" },
  "dai-thang": { front: "bangs", back: "long" },
  "xoan":      { front: "curly", back: "curlyBack" },
  "ngan":      { front: "short" },
  "hoi":       { front: "bald" },
  "toc-tet":   { front: "side", back: "braid" },
  "tien-ong":  { front: "swept", back: "longKnot" },
  "toc-gia":   { front: "wig", back: "wigBack" },
  "troc":      { front: "none" },
};
function hairBack(kind, c) {
  const S = st(c);
  const g = `fill="url(#hg)" ${S}`;
  switch (kind) {
    case "long": return `<path d="M56 150 C40 260 52 330 80 360 L220 360 C248 330 260 260 244 150 Z" ${g}/>`;
    case "pony": return `<path d="M228 96 C292 110 300 220 262 300 C268 230 252 170 220 130 Z" ${g}/><circle cx="232" cy="100" r="12" fill="#E2483D" ${st("#E2483D")}/>`;
    case "pigtails": return `<path d="M62 150 C14 190 22 280 52 320 C46 260 70 210 84 176 Z M238 150 C286 190 278 280 248 320 C254 260 230 210 216 176 Z" ${g}/><circle cx="70" cy="160" r="11" fill="#FF6F91" ${st("#FF6F91")}/><circle cx="230" cy="160" r="11" fill="#FF6F91" ${st("#FF6F91")}/>`;
    case "bunHigh": return `<circle cx="150" cy="34" r="34" ${g}/><path d="M118 40 Q150 22 182 40" fill="none" stroke="${lt(c, 0.4)}" stroke-width="4" stroke-linecap="round" opacity=".7"/>`;
    case "knot": return `<ellipse cx="150" cy="40" rx="24" ry="20" ${g}/><rect x="138" y="22" width="24" height="8" rx="3" fill="#C9A227" ${st("#C9A227")}/>`;
    case "longKnot": return `<path d="M60 150 C46 250 60 320 86 344 L214 344 C240 320 254 250 240 150 Z" ${g}/><ellipse cx="150" cy="38" rx="24" ry="20" ${g}/>`;
    case "braid": return `<g ${g}>${[0, 1, 2, 3, 4].map((i) => `<ellipse cx="${236 - i * 2}" cy="${176 + i * 34}" rx="17" ry="20"/>`).join("")}</g><circle cx="226" cy="340" r="8" fill="#E2483D"/>`;
    case "curlyBack": return `<g ${g}>${[[60, 170], [56, 215], [70, 255], [240, 170], [244, 215], [230, 255]].map(([x, y]) => `<circle cx="${x}" cy="${y}" r="26"/>`).join("")}</g>`;
    case "spikyBack": return `<path d="M60 170 L30 150 L56 128 L36 96 L74 92 L70 54 L108 66 L120 28 L150 52 L180 28 L192 66 L230 54 L226 92 L264 96 L244 128 L270 150 L240 170 Z" ${g}/>`;
    case "wigBack": return `<path d="M64 160 C56 240 80 280 110 290 L190 290 C220 280 244 240 236 160 Z" ${g}/><path d="M140 290 L130 320 L150 306 L170 320 L160 290 Z" fill="#2B2D42" ${st("#2B2D42")}/>`;
    default: return "";
  }
}
function hairFront(kind, c) {
  const S = st(c), g = `fill="url(#hg)" ${S}`;
  const shine = (d) => `<path d="${d}" fill="none" stroke="${lt(c, 0.6)}" stroke-width="6" stroke-linecap="round" opacity=".55"/>`;
  switch (kind) {
    case "bangs": return `<path d="M48 168 C40 80 96 38 150 38 C204 38 260 80 252 168 L242 136 L226 128 L214 140 L198 124 L182 140 L166 122 L150 138 L134 122 L118 140 L102 124 L86 140 L74 128 L58 136 Z" ${g}/>` + shine("M90 80 Q150 52 210 80");
    case "side": return `<path d="M48 170 C40 80 96 38 152 38 C206 38 262 82 252 170 C246 128 226 106 200 98 C188 126 150 142 104 136 C86 142 64 152 48 170 Z" ${g}/><path d="M200 98 C214 120 222 136 226 160 C230 130 222 110 200 98Z" ${g}/>` + shine("M96 84 Q150 54 206 82");
    case "spiky": return `<path d="M50 170 C44 96 92 48 150 46 C208 48 256 96 250 170 L236 140 L226 156 L212 118 L194 146 L178 112 L162 144 L146 108 L130 146 L112 114 L98 150 L84 122 L72 156 L62 136 Z" ${g}/>` + shine("M96 84 Q150 60 204 84");
    case "swept": return `<path d="M50 168 C44 86 96 44 150 44 C204 44 256 86 250 168 C240 120 210 98 150 96 C90 98 60 120 50 168 Z" ${g}/>` + shine("M84 92 Q150 60 216 92") + `<path d="M150 96 L150 58" stroke="${dk(c, 0.5)}" stroke-width="2" opacity=".5"/>`;
    case "curly": return `<g ${g}>${[[72, 118], [98, 86], [132, 70], [168, 70], [202, 86], [228, 118], [60, 156], [240, 156], [116, 108], [150, 100], [184, 108]].map(([x, y]) => `<circle cx="${x}" cy="${y}" r="27"/>`).join("")}</g>` + shine("M100 76 Q150 56 200 76");
    case "short": return `<path d="M52 158 C46 84 96 46 150 46 C204 46 254 84 248 158 C240 124 218 112 196 108 L186 124 L170 106 L150 122 L132 106 L116 124 L102 110 C80 116 60 130 52 158 Z" ${g}/>` + shine("M96 82 Q150 58 204 82");
    case "bald": return `<path d="M54 186 C48 160 52 140 62 128 C66 150 72 170 76 190 Z M246 186 C252 160 248 140 238 128 C234 150 228 170 224 190 Z" ${g}/>` + `<path d="M110 80 Q150 64 190 80" fill="none" stroke="#fff" stroke-width="6" stroke-linecap="round" opacity=".45"/>`;
    case "wig": return `<path d="M50 172 C42 84 96 40 150 40 C204 40 258 84 250 172 C240 128 214 104 150 102 C86 104 60 128 50 172 Z" ${g}/>${[156, 190].map((y) => `<ellipse cx="54" cy="${y}" rx="18" ry="14" ${g}/><ellipse cx="246" cy="${y}" rx="18" ry="14" ${g}/>`).join("")}` + shine("M92 80 Q150 56 208 80");
    case "none": return `<path d="M104 78 Q150 62 196 78" fill="none" stroke="#fff" stroke-width="6" stroke-linecap="round" opacity=".45"/>`;
    default: return "";
  }
}

// ---------------------------------------------------------------- beards, hats
function beard(kind, c) {
  const g = `fill="${c}" ${st(c)}`;
  switch (kind) {
    case "rau-de": return `<path d="M136 244 Q150 280 164 244 Q150 252 136 244Z" ${g}/>`;
    case "rau-dai": return `<path d="M96 222 Q100 262 150 266 Q200 262 204 222 Q206 300 150 340 Q94 300 96 222Z" ${g}/><path d="M130 280 Q150 300 170 280 M140 310 Q150 320 160 310" fill="none" stroke="${lt(c, 0.5)}" stroke-width="3" opacity=".6"/>`;
    case "ria": return `<path d="M150 214 Q132 206 116 220 Q132 222 150 218 Q168 222 184 220 Q168 206 150 214Z" ${g}/>`;
    case "quai-non": return `<path d="M58 180 Q60 250 150 268 Q240 250 242 180 Q232 236 196 246 Q150 256 104 246 Q68 236 58 180Z" ${g}/>`;
    default: return "";
  }
}
function hat(kind, c = "#C9A227", c2 = "#E2483D") {
  const S = (x) => st(x);
  switch (kind) {
    case "non-la": return `<path d="M150 -6 L290 96 Q150 118 10 96 Z" fill="#F2D88A" ${S("#C9A227")}/>${[40, 70, 100].map((y) => `<path d="M${150 - y * 1.3} ${y - 6 + 2} Q150 ${y + 6} ${150 + y * 1.3} ${y - 4}" fill="none" stroke="#C9A227" stroke-width="2"/>`).join("")}`;
    case "khan-xep": return `<path d="M52 126 C56 70 100 48 150 48 C200 48 244 70 248 126 C210 108 90 108 52 126 Z" fill="${c}" ${S(c)}/><path d="M60 104 Q150 76 240 104 M70 84 Q150 58 230 84" fill="none" stroke="${dk(c, 0.4)}" stroke-width="3"/>`;
    case "mu-quan": return `<path d="M70 110 C70 52 230 52 230 110 Z" fill="#222" ${S("#222")}/><path d="M100 70 Q150 28 200 70 Z" fill="#333" ${S("#222")}/><ellipse cx="34" cy="96" rx="40" ry="10" fill="#222" ${S("#222")}/><ellipse cx="266" cy="96" rx="40" ry="10" fill="#222" ${S("#222")}/><rect x="70" y="100" width="160" height="12" rx="4" fill="${c}" ${S(c)}/>`;
    case "vuong-mien": return `<path d="M88 92 L80 32 L116 64 L150 20 L184 64 L220 32 L212 92 Z" fill="url(#gold)" ${S("#C9A227")}/><circle cx="150" cy="70" r="9" fill="${c2}" ${S(c2)}/><circle cx="112" cy="78" r="6" fill="#3BA0E6"/><circle cx="188" cy="78" r="6" fill="#3BA0E6"/>`;
    case "mu-giap": return `<path d="M50 140 C46 66 96 30 150 30 C204 30 254 66 250 140 L226 126 C210 100 190 92 150 92 C110 92 90 100 74 126 Z" fill="url(#gold)" ${S("#9A7A1A")}/><path d="M150 30 C140 10 150 -4 170 -8 C160 6 166 20 150 30Z" fill="${c2}" ${S(c2)}/><path d="M64 120 Q150 84 236 120" fill="none" stroke="#9A7A1A" stroke-width="4"/>`;
    case "nhi-giac": return `<path d="M20 100 Q150 -10 280 100 Q150 70 20 100 Z" fill="#1E1E2A" ${S("#1E1E2A")}/><circle cx="196" cy="62" r="13" fill="#E2483D" stroke="#fff" stroke-width="4"/><path d="M40 96 Q150 20 260 96" fill="none" stroke="#C9A227" stroke-width="3"/>`;
    case "nemes": return `<path d="M46 150 C40 70 96 36 150 36 C204 36 260 70 254 150 L262 300 L222 300 L214 170 C200 120 100 120 86 170 L78 300 L38 300 Z" fill="#F2C94C" ${S("#B08A1A")}/>${[70, 100, 130, 200, 240, 280].map((y) => `<path d="M${y < 150 ? 70 : 44} ${y} L${y < 150 ? 230 : 82} ${y} ${y > 150 ? `M218 ${y} L256 ${y}` : ""}" stroke="#2B5DB8" stroke-width="7"/>`).join("")}<path d="M140 40 Q150 20 160 40 L156 60 L144 60Z" fill="#F2C94C" ${S("#B08A1A")}/>`;
    case "nguyet-que": return `<g fill="#6DBE4B" ${S("#6DBE4B")}>${[-60, -40, -20, 20, 40, 60].map((a) => `<ellipse cx="${150 + a * 1.6}" cy="${84 - Math.cos(a / 40) * 20 + Math.abs(a) * 0.4}" rx="14" ry="7" transform="rotate(${a} ${150 + a * 1.6} ${84 - Math.cos(a / 40) * 20 + Math.abs(a) * 0.4})"/>`).join("")}</g>`;
    case "tham-hiem": return `<path d="M58 118 C58 50 242 50 242 118 Z" fill="#E8D5A0" ${S("#B09A60")}/><ellipse cx="150" cy="118" rx="118" ry="16" fill="#E8D5A0" ${S("#B09A60")}/><rect x="64" y="100" width="172" height="10" fill="#8A6A3A"/>`;
    case "mu-cao": return `<rect x="92" y="-6" width="116" height="96" rx="6" fill="#1E1E2A" ${S("#1E1E2A")}/><ellipse cx="150" cy="92" rx="88" ry="14" fill="#1E1E2A" ${S("#1E1E2A")}/><rect x="92" y="64" width="116" height="14" fill="${c2}"/>`;
    case "quan-doi": return `<path d="M64 110 C64 50 236 50 236 110 Z" fill="${c}" ${S(c)}/><path d="M60 108 Q150 124 250 112 Q240 136 150 132 Q80 130 60 108Z" fill="#222" ${S("#222")}/><path d="M150 62 l5 11 12 1 -9 8 3 12 -11 -6 -11 6 3 -12 -9 -8 12 -1Z" fill="#F7CB46"/>`;
    case "phi-hanh-gia": return `<circle cx="150" cy="158" r="124" fill="#BFE7FF" opacity=".28" ${S("#7FB8D8")}/><path d="M70 90 Q100 50 150 44" fill="none" stroke="#fff" stroke-width="8" stroke-linecap="round" opacity=".7"/>`;
    case "khan-quang": return `<path d="M46 150 C42 76 96 42 150 42 C204 42 258 76 254 150 C240 118 60 118 46 150Z" fill="${c}" ${S(c)}/><path d="M232 120 Q270 150 262 210 Q248 170 228 150Z" fill="${c}" ${S(c)}/>`;
    default: return "";
  }
}

// ---------------------------------------------------------------- props (drawn centred on the hand)
const PROPS = {
  guom: `<path d="M0 0 L0 -150" stroke="#556" stroke-width="15" stroke-linecap="round"/><path d="M0 0 L0 -150" stroke="#DCE6F0" stroke-width="9" stroke-linecap="round"/><rect x="-22" y="-10" width="44" height="10" rx="4" fill="#C9A227" stroke="#7A5A10" stroke-width="3"/>`,
  giao: `<path d="M0 60 L0 -170" stroke="#6B4423" stroke-width="9" stroke-linecap="round"/><path d="M0 -205 L13 -168 L0 -160 L-13 -168Z" fill="#DCE6F0" stroke="#556" stroke-width="3"/><path d="M-10 -160 q10 14 20 0" fill="#E2483D"/>`,
  but: `<path d="M0 10 L22 -70" stroke="#6B4423" stroke-width="8" stroke-linecap="round"/><path d="M-2 10 Q-6 26 4 32 Q8 20 4 10Z" fill="#222"/>`,
  "but-long": `<path d="M0 6 C10 -40 36 -80 44 -110 C24 -84 8 -46 0 6Z" fill="#fff" stroke="#9AA" stroke-width="3"/>`,
  sach: `<rect x="-28" y="-36" width="56" height="70" rx="5" fill="#B04A3A" stroke="#6A2A20" stroke-width="3.5"/><rect x="-22" y="-30" width="44" height="58" rx="2" fill="none" stroke="#F7CB46" stroke-width="2"/>`,
  "cuon-giay": `<rect x="-40" y="-16" width="80" height="32" fill="#F6E7C1" stroke="#A88A50" stroke-width="3"/><rect x="-48" y="-22" width="12" height="44" rx="5" fill="#8A5A2A"/><rect x="36" y="-22" width="12" height="44" rx="5" fill="#8A5A2A"/>`,
  "kinh-lup": `<path d="M0 0 L26 -38" stroke="#6B4423" stroke-width="10" stroke-linecap="round"/><circle cx="40" cy="-58" r="26" fill="#CDEFFF" fill-opacity=".6" stroke="#556" stroke-width="6"/><path d="M28 -66 q8 -8 18 -6" stroke="#fff" stroke-width="4" fill="none" stroke-linecap="round"/>`,
  "bong-den": `<path d="M0 -30 C-30 -30 -32 -70 0 -76 C32 -70 30 -30 0 -30Z" fill="#FFE57A" stroke="#C9A227" stroke-width="3.5"/><rect x="-10" y="-30" width="20" height="16" rx="3" fill="#99A" stroke="#556" stroke-width="3"/><path d="M-24 -96 l-8 -10 M0 -100 l0 -14 M24 -96 l8 -10" stroke="#FFC93C" stroke-width="4" stroke-linecap="round"/>`,
  quat: `<path d="M0 0 L-46 -64 A80 80 0 0 1 46 -64 Z" fill="#FFF3D6" stroke="#B08A50" stroke-width="3"/><path d="M0 0 L-24 -76 M0 0 L0 -80 M0 0 L24 -76" stroke="#B08A50" stroke-width="2"/><circle cx="-6" cy="-52" r="9" fill="#E2483D" opacity=".8"/>`,
  co: `<path d="M0 50 L0 -170" stroke="#6B4423" stroke-width="7" stroke-linecap="round"/><path d="M0 -168 Q40 -178 80 -160 L80 -110 Q40 -126 0 -116Z" fill="#E2483D" stroke="#8A1A1A" stroke-width="3"/><path d="M38 -148 l4 9 10 1 -8 6 3 10 -9 -6 -9 6 3 -10 -8 -6 10 -1Z" fill="#F7CB46"/>`,
  "ong-nhom": `<rect x="-26" y="-24" width="22" height="40" rx="8" fill="#333" stroke="#111" stroke-width="3"/><rect x="4" y="-24" width="22" height="40" rx="8" fill="#333" stroke="#111" stroke-width="3"/><circle cx="-15" cy="-24" r="8" fill="#9ED8F5"/><circle cx="15" cy="-24" r="8" fill="#9ED8F5"/>`,
  "binh-hoa-chat": `<path d="M-10 -60 L10 -60 L10 -30 L32 14 Q36 26 24 26 L-24 26 Q-36 26 -32 14 L-10 -30Z" fill="#E9FBFF" stroke="#7AA" stroke-width="3.5"/><path d="M-26 6 L26 6 L32 14 Q36 26 24 26 L-24 26 Q-36 26 -32 14Z" fill="#7CFFB2"/><circle cx="4" cy="-8" r="4" fill="#7CFFB2"/><circle cx="-6" cy="-24" r="3" fill="#7CFFB2"/>`,
  "la-ban": `<circle r="30" fill="#F6E7C1" stroke="#8A5A2A" stroke-width="5"/><path d="M0 -22 L6 0 L0 22 L-6 0Z" fill="#E2483D"/><path d="M0 22 L6 0 L-6 0Z" fill="#556"/>`,
  khien: `<path d="M0 -50 Q40 -44 44 -30 Q44 30 0 54 Q-44 30 -44 -30 Q-40 -44 0 -50Z" fill="#B0413E" stroke="#5A1A1A" stroke-width="4"/><circle r="14" fill="#F7CB46" stroke="#9A7A1A" stroke-width="3"/>`,
  gay: `<path d="M0 -20 L-6 120" stroke="#8A5A2A" stroke-width="9" stroke-linecap="round"/><path d="M0 -20 Q-4 -40 14 -40" fill="none" stroke="#8A5A2A" stroke-width="9" stroke-linecap="round"/>`,
};

// ---------------------------------------------------------------- outfits
// each returns torso svg; `long` = robe reaching the feet (legs hidden)
const LONG = new Set(["giao-linh", "hoang-bao", "ao-dai", "toga", "kimono", "tu-than", "han"]);
function outfit(type, c, c2, hw, top, bot, skin) {
  const S = st(c);
  const body = (fill = c, b = bot, flare = 8) => `<path d="M${CX - hw} ${top + 18} Q${CX} ${top - 4} ${CX + hw} ${top + 18} L${CX + hw + flare} ${b} Q${CX} ${b + 8} ${CX - hw - flare} ${b} Z" fill="${fill}" ${st(fill)}/>`;
  const fold = (x1, y1, x2, y2, col = c) => `<path d="M${x1} ${y1} Q${(x1 + x2) / 2 + 6} ${(y1 + y2) / 2} ${x2} ${y2}" fill="none" stroke="${dk(col, 0.3)}" stroke-width="2.5" opacity=".6"/>`;
  const shade = (b = bot) => `<path d="M${CX + hw * 0.35} ${top + 12} L${CX + hw + 6} ${b - 2} L${CX + hw * 0.5} ${b} Z" fill="#000" opacity=".08"/>`;
  const L = 404;
  switch (type) {
    case "__teo": return teoOutfit(hw, top, bot);
    case "vest": return body(c) + `<path d="M${CX - 22} ${top + 4} L${CX} ${top + 60} L${CX + 22} ${top + 4} Z" fill="#fff" ${st("#ccc")}/><path d="M${CX} ${top + 8} L${CX - 7} ${top + 22} L${CX} ${top + 64} L${CX + 7} ${top + 22}Z" fill="${c2}" ${st(c2)}/><path d="M${CX - 22} ${top + 4} L${CX - 4} ${top + 70} M${CX + 22} ${top + 4} L${CX + 4} ${top + 70}" stroke="${dk(c, 0.5)}" stroke-width="3"/><circle cx="${CX}" cy="${top + 84}" r="4" fill="${dk(c, 0.5)}"/>` + shade();
    case "blouse": return body("#FAFCFF", bot + 14, 14) + `<path d="M${CX - 18} ${top + 4} L${CX} ${top + 44} L${CX + 18} ${top + 4} Z" fill="${c}" ${S}/><path d="M${CX - 24} ${top + 4} L${CX - 6} ${top + 66} L${CX - 6} ${bot + 16} M${CX + 24} ${top + 4} L${CX + 6} ${top + 66} L${CX + 6} ${bot + 16}" fill="none" stroke="#B8C4D0" stroke-width="3"/><rect x="${CX + hw - 34}" y="${top + 54}" width="22" height="16" rx="3" fill="none" stroke="#B8C4D0" stroke-width="2.5"/><path d="M${CX + hw - 28} ${top + 50} l0 14" stroke="${c2}" stroke-width="4" stroke-linecap="round"/>`;
    case "quan-phuc": return body(c) + `<path d="M${CX} ${top + 2} L${CX} ${bot}" stroke="${dk(c, 0.45)}" stroke-width="3"/>${[24, 46, 68].map((y) => `<circle cx="${CX}" cy="${top + y}" r="4.5" fill="#F7CB46" stroke="#9A7A1A" stroke-width="1.5"/>`).join("")}<rect x="${CX - hw - 2}" y="${bot - 26}" width="${hw * 2 + 4}" height="12" fill="#5A3A1A"/><rect x="${CX - 8}" y="${bot - 28}" width="16" height="16" rx="2" fill="#F7CB46"/><path d="M${CX - hw - 6} ${top + 16} l26 -6 0 10 -26 6Z M${CX + hw + 6} ${top + 16} l-26 -6 0 10 26 6Z" fill="#F7CB46" stroke="#9A7A1A" stroke-width="2"/><circle cx="${CX - 30}" cy="${top + 40}" r="6" fill="${c2}" stroke="#9A7A1A" stroke-width="2"/>`;
    case "giap": return body(c) + `<g fill="none" stroke="${dk(c, 0.4)}" stroke-width="2.5">${[0, 1, 2, 3].map((r) => [...Array(5)].map((_, i) => `<path d="M${CX - hw + 10 + i * (hw * 2 - 20) / 5} ${top + 30 + r * 16} q${(hw * 2 - 20) / 10} 10 ${(hw * 2 - 20) / 5} 0"/>`).join("")).join("")}</g><path d="M${CX - hw - 16} ${top + 30} Q${CX - hw} ${top} ${CX - hw + 24} ${top + 10} L${CX - hw + 14} ${top + 40}Z M${CX + hw + 16} ${top + 30} Q${CX + hw} ${top} ${CX + hw - 24} ${top + 10} L${CX + hw - 14} ${top + 40}Z" fill="url(#gold)" ${st("#C9A227")}/><rect x="${CX - hw - 4}" y="${bot - 30}" width="${hw * 2 + 8}" height="14" rx="5" fill="${c2}" ${st(c2)}/><circle cx="${CX}" cy="${bot - 23}" r="9" fill="url(#gold)" ${st("#C9A227")}/><path d="M${CX - hw - 6} ${bot - 16} L${CX - hw - 12} ${bot + 22} L${CX + hw + 12} ${bot + 22} L${CX + hw + 6} ${bot - 16}Z" fill="${c2}" ${st(c2)}/>${[-2, -1, 0, 1].map((i) => `<path d="M${CX + i * hw / 2 + hw / 4} ${bot - 14} L${CX + i * hw / 2 + hw / 4} ${bot + 20}" stroke="${dk(c2, 0.4)}" stroke-width="2"/>`).join("")}`;
    case "giao-linh": case "han": case "hoang-bao": {
      const robe = body(c, L, 26);
      const collar = `<path d="M${CX - 28} ${top + 2} L${CX + 24} ${top + 80} M${CX + 28} ${top + 2} L${CX - 4} ${top + 46}" fill="none" stroke="${c2}" stroke-width="11" stroke-linecap="round"/>`;
      const sash = `<rect x="${CX - hw - 6}" y="${top + 86}" width="${hw * 2 + 12}" height="16" rx="5" fill="${c2}" ${st(c2)}/><path d="M${CX + 10} ${top + 100} l-6 46 m14 -46 l8 42" stroke="${c2}" stroke-width="7" stroke-linecap="round"/>`;
      const emblem = type === "hoang-bao" ? `<circle cx="${CX - hw / 2}" cy="${top + 150}" r="20" fill="none" stroke="#C9A227" stroke-width="4"/><path d="M${CX - hw / 2 - 12} ${top + 152} q6 -14 12 0 t12 0" fill="none" stroke="#C9A227" stroke-width="3"/>` : "";
      return robe + fold(CX - hw + 10, top + 110, CX - hw - 16, L - 6) + fold(CX + hw - 10, top + 110, CX + hw + 18, L - 6) + collar + sash + emblem + shade(L);
    }
    case "ao-dai": return body(c, L, 10) + `<path d="M${CX - 18} ${top + 2} L${CX + 18} ${top + 2} L${CX + 16} ${top - 10} L${CX - 16} ${top - 10}Z" fill="${c}" ${S}/><path d="M${CX - 4} ${top + 2} Q${CX + 26} ${top + 24} ${CX + hw - 6} ${top + 26}" fill="none" stroke="${dk(c, 0.3)}" stroke-width="2.5"/><path d="M${CX - hw - 2} ${top + 120} L${CX - hw - 12} ${L} M${CX + hw + 2} ${top + 120} L${CX + hw + 12} ${L}" stroke="#fff" stroke-width="5"/>${[0, 1, 2].map((i) => `<circle cx="${CX - 20 + i * 22}" cy="${top + 70 + i * 26}" r="7" fill="${c2}" opacity=".85"/>`).join("")}`;
    case "tu-than": return body(c, L, 22) + `<path d="M${CX - 26} ${top + 4} L${CX} ${top + 70} L${CX + 26} ${top + 4}Z" fill="${c2}" ${st(c2)}/><rect x="${CX - hw - 8}" y="${top + 80}" width="${hw * 2 + 16}" height="14" rx="5" fill="#7CBF5A" ${st("#7CBF5A")}/><path d="M${CX - 4} ${top + 92} l-10 60 M${CX + 8} ${top + 92} l10 56" stroke="#7CBF5A" stroke-width="7" stroke-linecap="round"/>` + fold(CX - hw, top + 110, CX - hw - 14, L - 4) + fold(CX + hw, top + 110, CX + hw + 16, L - 4);
    case "kimono": return body(c, L, 14) + `<path d="M${CX - 26} ${top + 2} L${CX + 20} ${top + 74} M${CX + 26} ${top + 2} L${CX} ${top + 36}" stroke="${c2}" stroke-width="10" stroke-linecap="round"/><rect x="${CX - hw - 4}" y="${top + 72}" width="${hw * 2 + 8}" height="30" fill="${c2}" ${st(c2)}/><rect x="${CX - 18}" y="${top + 80}" width="36" height="14" rx="4" fill="${lt(c2, 0.5)}"/>${[[CX - 30, top + 150], [CX + 26, top + 200], [CX - 10, top + 240]].map(([x, y]) => `<circle cx="${x}" cy="${y}" r="9" fill="${lt(c, 0.55)}" opacity=".8"/>`).join("")}`;
    case "toga": return body("#F7F5EE", L, 18) + `<path d="M${CX - hw} ${top + 18} Q${CX} ${top + 120} ${CX + hw + 14} ${top + 210}" fill="none" stroke="${c2}" stroke-width="10"/><path d="M${CX - hw + 4} ${top + 30} Q${CX + 10} ${top + 120} ${CX + hw + 8} ${top + 180} M${CX - hw + 14} ${top + 60} Q${CX + 10} ${top + 140} ${CX + hw} ${top + 230}" fill="none" stroke="#D8D2C2" stroke-width="3"/><circle cx="${CX - hw + 8}" cy="${top + 22}" r="8" fill="url(#gold)"/>`;
    case "ai-cap": return `<path d="M${CX - hw + 4} ${top + 18} Q${CX} ${top} ${CX + hw - 4} ${top + 18} L${CX + hw - 2} ${bot - 30} L${CX - hw + 2} ${bot - 30}Z" fill="${skin}" ${st(skin)}/><path d="M${CX - hw - 2} ${top + 18} Q${CX} ${top + 76} ${CX + hw + 2} ${top + 18} Q${CX} ${top - 4} ${CX - hw - 2} ${top + 18}Z" fill="${c2}" ${st(c2)}/><path d="M${CX - hw + 10} ${top + 24} Q${CX} ${top + 60} ${CX + hw - 10} ${top + 24}" fill="none" stroke="#F7CB46" stroke-width="6"/><path d="M${CX - hw - 4} ${bot - 32} L${CX + hw + 4} ${bot - 32} L${CX + hw + 14} ${bot + 14} L${CX - hw - 14} ${bot + 14}Z" fill="#FAF7EC" ${st("#C8C0A8")}/><path d="M${CX - 16} ${bot - 32} L${CX} ${bot + 14} L${CX + 16} ${bot - 32}" fill="#F7CB46" ${st("#C9A227")}/>`;
    case "khmer": return `<path d="M${CX - hw + 4} ${top + 18} Q${CX} ${top} ${CX + hw - 4} ${top + 18} L${CX + hw - 2} ${bot - 30} L${CX - hw + 2} ${bot - 30}Z" fill="${skin}" ${st(skin)}/><path d="M${CX - hw} ${top + 20} L${CX + hw - 4} ${bot - 40}" stroke="${c2}" stroke-width="16" stroke-linecap="round"/><path d="M${CX - hw - 4} ${bot - 34} L${CX + hw + 4} ${bot - 34} L${CX + hw + 10} ${bot + 16} L${CX - hw - 10} ${bot + 16}Z" fill="${c}" ${S}/><path d="M${CX} ${bot - 34} L${CX - 4} ${bot + 16}" stroke="${dk(c, 0.3)}" stroke-width="3"/><path d="M${CX - 30} ${top + 10} Q${CX} ${top + 30} ${CX + 30} ${top + 10}" fill="none" stroke="#F7CB46" stroke-width="6"/>`;
    case "au-18": return body(c, bot + 18, 16) + `<path d="M${CX - 18} ${top + 4} L${CX} ${top + 40} L${CX + 18} ${top + 4}Z" fill="#fff" ${st("#ccc")}/><path d="M${CX - 12} ${top + 8} Q${CX} ${top + 30} ${CX + 12} ${top + 8} Q${CX + 6} ${top + 40} ${CX} ${top + 46} Q${CX - 6} ${top + 40} ${CX - 12} ${top + 8}Z" fill="#fff" ${st("#bbb")}/><path d="M${CX - 22} ${top + 4} L${CX - 30} ${top + 60} L${CX - 8} ${bot + 18} M${CX + 22} ${top + 4} L${CX + 30} ${top + 60} L${CX + 8} ${bot + 18}" fill="none" stroke="${c2}" stroke-width="5"/>${[56, 78, 100].map((y) => `<circle cx="${CX - 18}" cy="${top + y}" r="4" fill="${c2}"/><circle cx="${CX + 18}" cy="${top + y}" r="4" fill="${c2}"/>`).join("")}` + shade(bot + 18);
    case "phi-hanh-gia": return body("#F4F6FA") + `<rect x="${CX - 28}" y="${top + 34}" width="56" height="40" rx="6" fill="#DDE3EC" ${st("#9AA6B8")}/><circle cx="${CX - 12}" cy="${top + 48}" r="5" fill="#E2483D"/><circle cx="${CX + 4}" cy="${top + 48}" r="5" fill="#3BA0E6"/><rect x="${CX - 16}" y="${top + 60}" width="30" height="6" rx="3" fill="#7CFFB2"/><rect x="${CX + hw - 30}" y="${top + 16}" width="20" height="13" fill="${c2}"/><rect x="${CX - hw - 4}" y="${bot - 26}" width="${hw * 2 + 8}" height="10" fill="#B8C4D0"/>`;
    case "nong-dan": return body(c) + `<path d="M${CX - 16} ${top + 2} L${CX} ${top + 26} L${CX + 16} ${top + 2}" fill="none" stroke="${dk(c, 0.4)}" stroke-width="3"/><rect x="${CX - hw - 2}" y="${bot - 24}" width="${hw * 2 + 4}" height="10" fill="${c2}"/>${[30, 52].map((y) => `<circle cx="${CX}" cy="${top + y}" r="3.5" fill="${dk(c, 0.5)}"/>`).join("")}` + shade();
    default: return body(c) + `<path d="M${CX - 20} ${top + 4} Q${CX} ${top + 22} ${CX + 20} ${top + 4}" fill="none" stroke="${dk(c, 0.4)}" stroke-width="4"/>${c2 ? `<path d="M${CX - hw + 6} ${top + 70} L${CX + hw - 6} ${top + 70}" stroke="${c2}" stroke-width="10" opacity=".9"/>` : ""}` + shade();
  }
}

// ---------------------------------------------------------------- arms (shoulder → elbow → hand)
function armPaths(pose, hw, top) {
  const lS = [CX - hw + 8, top + 26], rS = [CX + hw - 8, top + 26];
  const down = (s, d) => [s, [s[0] + d * 14, top + 72], [s[0] + d * 10, top + 100]];
  const P = {
    xuoi: [down(lS, -1), down(rS, 1)],
    "chong-nanh": [[lS, [lS[0] - 46, top + 58], [lS[0] - 2, top + 92]], [rS, [rS[0] + 46, top + 58], [rS[0] + 2, top + 92]]],
    "gio-tay": [down(lS, -1), [rS, [rS[0] + 28, top - 4], [rS[0] + 34, top - 44]]],
    chi: [down(lS, -1), [rS, [rS[0] + 42, top + 28], [rS[0] + 72, top + 20]]],
    khoanh: [[lS, [lS[0] + 10, top + 62], [CX + 22, top + 54]], [rS, [rS[0] - 10, top + 66], [CX - 22, top + 60]]],
    "hai-tay": [[lS, [lS[0] - 28, top - 2], [lS[0] - 36, top - 42]], [rS, [rS[0] + 28, top - 2], [rS[0] + 36, top - 42]]],
    nhun: [[lS, [lS[0] - 30, top + 58], [lS[0] - 48, top + 20]], [rS, [rS[0] + 30, top + 58], [rS[0] + 48, top + 20]]],
    cam: [down(lS, -1), [rS, [rS[0] + 14, top + 62], [CX + 30, top - 14]]],
    "noi": [down(lS, -1), [rS, [rS[0] + 36, top + 48], [rS[0] + 56, top + 8]]],
  };
  return P[pose] || P.xuoi;
}
function arm(pts, sleeve, skin, wide) {
  const d = `M${pts[0][0]} ${pts[0][1]} Q${pts[1][0]} ${pts[1][1]} ${pts[2][0]} ${pts[2][1]}`;
  const w = wide ? 30 : 22;
  return `<path d="${d}" fill="none" stroke="${dk(sleeve, 0.55)}" stroke-width="${w + 7}" stroke-linecap="round"/><path d="${d}" fill="none" stroke="${sleeve}" stroke-width="${w}" stroke-linecap="round"/>` +
    `<circle cx="${pts[2][0]}" cy="${pts[2][1]}" r="12" fill="${skin}" ${st(skin, 3)}/>`;
}

// ---------------------------------------------------------------- the character
// o: { skin, body:"tre|thanh-nien|gia|beo|gay", hair:{style,color}, eyes:{type,color}, outfit:{type,color,color2,pants},
//      hat, hatColor, hatColor2, beard, beardColor, glasses, arms, prop, propHand:"r|l", expr }
export function anime(o) {
  const skin = o.skin || SKIN.vang, expr = o.expr || "vui";
  const hairColor = o.hair?.color || "#3A2A22", style = o.hair?.style || "ngan";
  const eyeType = o.eyes?.type || "tron", iris = o.eyes?.color || "#6B4A3A";
  const of = o.outfit || {}, oc = of.color || "#4F7DD8", oc2 = of.color2 || "#F7CB46";
  const bt = o.body || "thanh-nien";
  const hw = { tre: 42, "thanh-nien": 52, gia: 50, beo: 72, gay: 42 }[bt] || 52;
  const top = 254, bot = bt === "tre" ? 350 : bt === "gay" ? 372 : 362;
  const long = LONG.has(of.type);
  const sleeve = of.sleeve || (of.type === "blouse" ? "#FAFCFF" : of.type === "ai-cap" || of.type === "khmer" ? skin : of.type === "toga" ? "#F7F5EE" : of.type === "phi-hanh-gia" ? "#F4F6FA" : oc);
  const wide = ["giao-linh", "han", "hoang-bao", "kimono", "tu-than"].includes(of.type);
  const pose = o.arms || "xuoi";
  const head = bt === "gia" ? `translate(6 10)` : bt === "tre" ? `translate(0 -4)` : "";
  const H = HAIR[style] || HAIR.ngan;
  const p = [];
  p.push(`<defs><linearGradient id="hg" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="${lt(hairColor, 0.25)}"/><stop offset=".55" stop-color="${hairColor}"/><stop offset="1" stop-color="${dk(hairColor, 0.25)}"/></linearGradient>` +
    `<linearGradient id="iris" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="${dk(iris, 0.45)}"/><stop offset="1" stop-color="${lt(iris, 0.45)}"/></linearGradient>` +
    `<linearGradient id="gold" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#FFE68A"/><stop offset="1" stop-color="#D9A520"/></linearGradient></defs>`);
  p.push(`<ellipse cx="150" cy="412" rx="${hw + 34}" ry="8" fill="#000" opacity=".12"/>`);
  // legs / feet
  const pants = of.pants || dk(oc, 0.35);
  if (long) p.push(`<ellipse cx="${CX - 22}" cy="406" rx="20" ry="9" fill="#3A2A22"/><ellipse cx="${CX + 22}" cy="406" rx="20" ry="9" fill="#3A2A22"/>`);
  else {
    const sp = bt === "beo" ? 30 : 20, ly = bot - 4;
    p.push(`<path d="M${CX - sp} ${ly} L${CX - sp} 400 M${CX + sp} ${ly} L${CX + sp} 400" stroke="${dk(pants, 0.5)}" stroke-width="27" stroke-linecap="round"/><path d="M${CX - sp} ${ly} L${CX - sp} 398 M${CX + sp} ${ly} L${CX + sp} 398" stroke="${pants}" stroke-width="20" stroke-linecap="round"/>`);
    p.push(`<ellipse cx="${CX - sp - 4}" cy="406" rx="19" ry="9" fill="#3A2A22"/><ellipse cx="${CX + sp + 4}" cy="406" rx="19" ry="9" fill="#3A2A22"/>`);
  }
  const arms = armPaths(pose, hw, top);
  const behindHead = pose === "cam";
  p.push(`<g transform="${head}">${hairBack(H.back, hairColor)}</g>`);
  if (o.hat === "nemes") p.push(`<g transform="${head}">${hat("nemes")}</g>`);
  p.push(outfit(of.type, oc, oc2, hw, top, bot, skin));
  p.push(arm(arms[0], sleeve, skin, wide));
  if (!behindHead) p.push(arm(arms[1], sleeve, skin, wide));
  // head
  const h = [];
  h.push(`<path d="M${CX - 16} 246 L${CX - 16} 270 Q${CX} 278 ${CX + 16} 270 L${CX + 16} 246Z" fill="${dk(skin, 0.12)}"/>`);
  h.push(`<ellipse cx="52" cy="182" rx="12" ry="17" fill="${skin}" ${st(skin, 3)}/><ellipse cx="248" cy="182" rx="12" ry="17" fill="${skin}" ${st(skin, 3)}/>`);
  h.push(`<path d="${FACE}" fill="${skin}" ${st(skin)}/>`);
  h.push(`<path d="M70 210 C90 250 210 250 230 210 C214 244 186 258 150 258 C114 258 86 244 70 210Z" fill="${dk(skin, 0.08)}" opacity=".6"/>`);
  h.push(marks(expr, { age: bt }));
  const eo = { type: eyeType, iris, expr, skin };
  h.push(eye(CX - EX, eo, -1), eye(CX + EX, eo, 1));
  h.push(`<path d="M148 204 q3 3 6 0" fill="none" stroke="${dk(skin, 0.35)}" stroke-width="2.5" stroke-linecap="round"/>`);
  if (o.beard) h.push(beard(o.beard, o.beardColor || hairColor));
  h.push(mouth(expr));
  if (o.beard === "ria" || o.beard === "rau-dai") h.push(beard("ria", o.beardColor || hairColor));
  h.push(hairFront(H.front, hairColor));
  h.push(brows({ expr, hairColor, eyeType }));
  if (o.glasses || eyeType === "kinh") h.push(`<g fill="none" stroke="${o.glassesColor || "#4A3A30"}" stroke-width="4.5"><circle cx="${CX - EX}" cy="${EY + 2}" r="31"/><circle cx="${CX + EX}" cy="${EY + 2}" r="31"/><path d="M${CX - 8} ${EY - 2} Q${CX} ${EY - 8} ${CX + 8} ${EY - 2} M${CX - EX - 31} ${EY - 4} L54 170 M${CX + EX + 31} ${EY - 4} L246 170"/></g><path d="M${CX - EX - 18} ${EY - 16} l10 -8 M${CX + EX - 18} ${EY - 16} l10 -8" stroke="#fff" stroke-width="4" stroke-linecap="round" opacity=".8"/>`);
  if (o.hat && o.hat !== "nemes") h.push(hat(o.hat, o.hatColor, o.hatColor2));
  if (o.hat === "nemes") h.push(`<path d="M140 40 Q150 20 160 40 L156 60 L144 60Z" fill="#F2C94C" ${st("#B08A1A")}/>`);
  p.push(`<g transform="${head}">${h.join("")}</g>`);
  if (behindHead) p.push(arm(arms[1], sleeve, skin, wide));
  if (o.prop && PROPS[o.prop]) {
    const hand = (o.propHand === "l" ? arms[0] : arms[1])[2];
    p.push(`<g transform="translate(${hand[0]} ${hand[1]})">${PROPS[o.prop]}</g>`);
    p.push(`<circle cx="${hand[0]}" cy="${hand[1]}" r="12" fill="${skin}" ${st(skin, 3)}/>`);
  }
  if (pose === "chi") { const hd = arms[1][2]; p.push(`<path d="M${hd[0] + 8} ${hd[1] - 2} l18 -4" stroke="${dk(skin, 0.55)}" stroke-width="10" stroke-linecap="round"/><path d="M${hd[0] + 8} ${hd[1] - 2} l18 -4" stroke="${skin}" stroke-width="5" stroke-linecap="round"/>`); }
  return p.join("\n");
}

export const EXPRS = ["vui", "gian", "buon", "soc", "dac-y", "ngai", "quyet-tam"];
const wrap = (body, vb = "0 0 300 420", data = "") => `<svg xmlns="http://www.w3.org/2000/svg" viewBox="${vb}" width="${vb.split(" ")[2]}" height="${vb.split(" ")[3]}"${data}>\n${body}\n</svg>\n`;

// write <key>.svg (+ <key>-<expr>.svg) and a preview page
export function writeChars(chars, outDir, previewFile) {
  mkdirSync(outDir, { recursive: true });
  const cells = [];
  for (const [k, def] of Object.entries(chars)) {
    const outs = typeof def === "string" ? [[k, def]] : [[k, anime(def)], ...(def.exprs || []).filter((e) => e !== (def.expr || "vui")).map((e) => [`${k}-${e}`, anime({ ...def, expr: e })])];
    if (typeof def === "object" && def.prop === undefined) { /* ok */ }
    for (const [name, body] of outs) {
      const f = join(outDir, `${name}.svg`);
      writeFileSync(f, wrap(body, "0 0 300 420", ` data-char="${name}"`));
      const kb = statSync(f).size / 1024;
      console.log(`${name.padEnd(22)} ${kb.toFixed(2)} KB${kb > 12 ? "  <-- OVER 12KB" : ""}`);
      cells.push(name);
    }
  }
  if (previewFile) writeFileSync(previewFile, `<!doctype html><meta charset="utf-8"><title>chars</title><style>body{margin:0;background:#EEF1F6;font:14px sans-serif;display:flex;flex-wrap:wrap;gap:10px;padding:12px}figure{margin:0;background:#fff;border-radius:12px;padding:6px;text-align:center;box-shadow:0 1px 4px #0002}img{width:150px;height:210px;display:block}</style>` +
    cells.map((n) => `<figure><img src="${previewFile.includes("work") ? "../chars/" : ""}${n}.svg"><figcaption>${n}</figcaption></figure>`).join("") + "\n");
}

// ---------------------------------------------------------------- anime Tèo (kit narrator, 500x760, 6 poses)
export const TEO = { skin: SKIN.sang, body: "thanh-nien", hair: { style: "bom-gai", color: "#6B3F26" }, eyes: { type: "tron", color: "#4A8BE0" }, glasses: true,
  outfit: { type: "teo" } };
function teoOutfit(hw, top, bot) {
  const c = "#5B8DEF";
  return `<path d="M${CX - hw} ${top + 18} Q${CX} ${top - 4} ${CX + hw} ${top + 18} L${CX + hw + 8} ${bot} Q${CX} ${bot + 8} ${CX - hw - 8} ${bot} Z" fill="${c}" ${st(c)}/>` +
    `<path d="M${CX - 24} ${top + 4} L${CX + 24} ${top + 4} L${CX + 20} ${bot + 2} L${CX - 20} ${bot + 2}Z" fill="#fff" ${st("#B8C4D0")}/>` +
    `<path d="M${CX - 9} ${top + 34} L${CX + 9} ${top + 34} M${CX} ${top + 34} L${CX} ${top + 62}" stroke="#2B2D42" stroke-width="6" stroke-linecap="round"/>` +
    `<path d="M${CX - 24} ${top + 4} L${CX - 38} ${top + 44} L${CX - 20} ${top + 70} M${CX + 24} ${top + 4} L${CX + 38} ${top + 44} L${CX + 20} ${top + 70}" fill="none" stroke="${dk(c, 0.45)}" stroke-width="3.5" stroke-linejoin="round"/>` +
    `<path d="M${CX + hw * 0.35} ${top + 12} L${CX + hw + 6} ${bot - 2} L${CX + hw * 0.5} ${bot} Z" fill="#000" opacity=".08"/>`;
}
const TEO_POSES = { talk: ["noi", "vui"], point: ["chi", "quyet-tam"], shock: ["hai-tay", "soc"], shrug: ["nhun", "ngai"], smug: ["chong-nanh", "dac-y"], think: ["cam", "vui"] };
export function teo(pose) {
  const [arms, expr] = TEO_POSES[pose];
  let body = anime({ ...TEO, arms, expr: pose === "think" ? "vui" : expr, outfit: { type: "__teo", color: "#5B8DEF", pants: "#2B2D42", sleeve: "#5B8DEF" } });
  if (pose === "think") body = body.replace(/<g id="mouth-closed">[\s\S]*?<\/g>/, `<g id="mouth-closed"><path d="M140 230 Q148 226 160 230" fill="none" stroke="${LINE}" stroke-width="4" stroke-linecap="round"/></g>`) +
    `<g fill="#fff" stroke="#9AA6B8" stroke-width="3"><circle cx="262" cy="70" r="9"/><circle cx="280" cy="44" r="13"/></g>`;
  // place the 300x420 figure in the narrator's 500x760 frame, feet on the bottom edge
  return wrap(`<g transform="translate(-2 67) scale(1.65)">\n${body}\n</g>`, "0 0 500 760", ` data-pose="${pose}"`);
}

// ---------------------------------------------------------------- CLI
const here = dirname(fileURLToPath(import.meta.url));
if (process.argv[1] && resolve(process.argv[1]) === resolve(fileURLToPath(import.meta.url))) {
  const i = process.argv.indexOf("--teo");
  if (i > 0) {
    const out = resolve(process.argv[i + 1] || "teo-anime");
    mkdirSync(out, { recursive: true });
    for (const pose of Object.keys(TEO_POSES)) {
      const f = join(out, `teo-${pose}.svg`);
      writeFileSync(f, teo(pose));
      console.log(`teo-${pose}.svg ${(statSync(f).size / 1024).toFixed(2)} KB`);
    }
    writeFileSync(join(out, "preview.html"), `<!doctype html><meta charset="utf-8"><style>body{margin:0;background:#EEF1F6;display:flex;gap:10px;padding:12px;flex-wrap:wrap}img{width:200px;background:#fff;border-radius:12px}</style>` +
      Object.keys(TEO_POSES).map((p) => `<img src="teo-${p}.svg" title="${p}">`).join(""));
  } else {
    // ---- EDIT HERE: one entry per cast key. Pick a DIFFERENT hair style + colour for every character.
    // hair.style: mai-bang re-ngoi bom-gai duoi-ngua hai-bim bui-cao bui-toi dai-thang xoan ngan hoi toc-tet tien-ong toc-gia troc
    // eyes.type:  tron sac buon-ngu hip nhay lap-lanh kinh gia
    // outfit.type: ao-thun vest blouse quan-phuc giap giao-linh han hoang-bao ao-dai tu-than kimono toga ai-cap khmer au-18 phi-hanh-gia nong-dan
    // hat: non-la khan-xep mu-quan vuong-mien mu-giap nhi-giac nemes nguyet-que tham-hiem mu-cao quan-doi phi-hanh-gia khan-quang
    // beard: rau-de rau-dai ria quai-non · body: tre thanh-nien gia beo gay
    // arms: xuoi chong-nanh gio-tay chi khoanh hai-tay nhun cam noi · prop: ${Object.keys(PROPS).join(" ")}
    // exprs: ${EXPRS.join(" ")}  (main characters: ≥3 expressions; use "<key>-<expr>" in scenes)
    const chars = {
      vua: { skin: SKIN.vang, hair: { style: "bui-toi", color: "#2A1A14" }, eyes: { type: "sac", color: "#8A5A2A" }, outfit: { type: "hoang-bao", color: "#F2C230", color2: "#C0392B" },
        hat: "vuong-mien", beard: "rau-de", arms: "chong-nanh", exprs: ["vui", "gian", "soc", "quyet-tam"] },
      nuTuong: { skin: SKIN.vang, hair: { style: "duoi-ngua", color: "#1E1A2E" }, eyes: { type: "lap-lanh", color: "#C0392B" }, outfit: { type: "giap", color: "#B0413E", color2: "#5A2A6A" },
        hat: "mu-giap", hatColor2: "#E2483D", arms: "gio-tay", prop: "giao", exprs: ["quyet-tam", "vui", "buon"] },
      nhaKhoaHoc: { skin: SKIN.sang, body: "gia", hair: { style: "hoi", color: "#D8D8DC" }, eyes: { type: "kinh", color: "#3B7DD8" }, outfit: { type: "blouse", color: "#7A9CC6", color2: "#E2483D" },
        beard: "ria", beardColor: "#D8D8DC", arms: "xuoi", prop: "binh-hoa-chat", exprs: ["vui", "soc", "dac-y"] },
    };
    writeChars(chars, join(here, "..", "chars"), join(here, "chars-preview.html"));
  }
}
