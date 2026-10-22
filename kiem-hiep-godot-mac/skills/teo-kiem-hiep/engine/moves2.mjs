// Thư viện động tác v2 (chạy ở node khi build). Mỗi động tác nhận (ctx, p, t, opts) → sinh lệnh runtime2 vào ctx.js
// và trả về thời lượng. Có sổ bận: hai tween cùng khớp chồng thời gian sẽ bị bỏ + cảnh báo (quy tắc render-speed).
// Góc: dương = xoay thuận kim đồng hồ trên màn. Tay F (x=+56) giơ ra trước = âm; tay B (x=-56) giơ ra trước = dương.
// Vũ khí: 180 = lưỡi nối dài cẳng tay (nghỉ: chúc xuống; giơ tay: chĩa lên).
const f2 = (x) => +x.toFixed(2);

export class Mover {
  constructor({ js, warn = console.warn, rnd = Math.random }) { this.js = js; this.warn = warn; this.rnd = rnd; this.busy = new Map(); this.state = new Map(); this.expr = new Map(); this.n = { ok: 0, drop: 0 }; }
  range(a, b) { return a + this.rnd() * (b - a); }
  // kiểm tra + ghi sổ bận cho (id, kênh)
  take(key, t, d) {
    const L = this.busy.get(key) || [];
    for (const [a, b] of L) if (t < b - 1e-3 && t + d > a + 1e-3) { this.n.drop++; this.warn(`chồng tween ${key} @${f2(t)} (bận ${f2(a)}–${f2(b)})`); return false; }
    L.push([t, t + d]); this.busy.set(key, L); this.n.ok++; return true;
  }
  // xoay/dời 1 khớp
  J(p, j, t, d, a = 0, dx = 0, dy = 0, ease = "power2.inOut") {
    const id = `${p}-${j}`;
    if (!this.take(id, t, d)) return;
    this.state.set(id, [a, dx, dy]);
    this.js(`J("${id}", ${f2(t)}, ${f2(d)}, ${f2(a)}, ${f2(dx)}, ${f2(dy)}, "${ease}");`);
  }
  // nhiều khớp cùng lúc: map {khớp: góc | [góc,dx,dy]}
  K(p, t, d, map, ease) { for (const [j, v] of Object.entries(map)) { const [a, dx, dy] = Array.isArray(v) ? v : [v, 0, 0]; this.J(p, j, t, d, a, dx, dy, ease); } }
  cur(p, j) { return this.state.get(`${p}-${j}`) || [0, 0, 0]; }
  EX(p, t, name) { this.expr.set(p, [...(this.expr.get(p) || []), [t, name]].sort((a, b) => a[0] - b[0])); this.js(`EX("${p}", ${f2(t)}, "${name}");`); }
  exprAt(p, t) { let e = "vui"; for (const [tt, n] of this.expr.get(p) || []) if (tt <= t + 1e-6) e = n; return e; }
  // nói: nhép miệng theo biểu cảm đang hiện (đổi biểu cảm giữa câu vẫn đúng miệng)
  talk(p, t0, t1) {
    const marks = [t0, ...(this.expr.get(p) || []).map((x) => x[0]).filter((x) => x > t0 && x < t1), t1];
    for (let i = 0; i < marks.length - 1; i++) this.js(`FLAP("${p}", "${this.exprAt(p, marks[i])}", ${f2(marks[i])}, ${f2(marks[i + 1])});`);
  }
  // dời div nhân vật theo trục x bằng giá trị tuyệt đối (không dùng "+=" để seek lui/tới không trôi)
  moveX(sel, t, d, dx, ease = "none") { if (!sel || !dx) return; this.pos = this.pos || new Map(); const x = (this.pos.get(sel) || 0) + dx; this.pos.set(sel, x); this.js(`TO("${sel}", ${f2(t)}, ${f2(d)}, { x: ${f2(x)} }, "${ease}");`); }
  blinks(p, t0, t1) { for (let t = t0 + this.range(0.6, 1.8); t < t1 - 0.3; t += this.range(2, 4)) this.js(`BLINK("${p}", ${f2(t)});`); }
  nod(p, t, n = 1) { for (let k = 0; k < n; k++) { this.J(p, "head", t + k * 0.36, 0.14, 6, 0, 7, "power2.out"); this.J(p, "head", t + k * 0.36 + 0.14, 0.18, 0, 0, 0); } return n * 0.36; }
  // nền: thở + tóc/vạt/băng lắc nhẹ suốt cảnh (các khớp phụ này không dùng cho động tác chính)
  ambient(p, t0, t1, o = {}) {
    this.js(`BREATH("${p}", ${f2(t0)}, ${f2(t1)});`);
    const w = o.wind ?? 1;
    for (const [j, amp, per] of [["hairB", 7 * w, 0.9], ["tail", 12 * w, 0.7], ["flapB", 4 * w, 1.1]]) this.js(`SWAY("${p}-${j}", ${f2(t0)}, ${f2(t1)}, ${f2(amp)}, ${per}, ${f2(this.range(0, 0.5))});`);
  }
}

// ---------------------------------------------------------------- tư thế tĩnh (tay F = phía đối thủ)
export const POSES = {
  rest: { uaF: 6, faF: 0, uaB: -6, faB: 0, head: 0, torso: 0, thF: 0, shF: 0, thB: 0, shB: 0, all: [0, 0, 0] },
  point: { uaF: -82, faF: -18, uaB: -10, faB: 6, head: -4, torso: -4 },
  "point-up": { uaF: -150, faF: -24, uaB: -6, faB: 0, head: -6, torso: -3 },
  raise: { uaF: -165, faF: -8, uaB: 165, faB: 8, torso: 6, head: 4, thF: -10, shF: 16, thB: 10, shB: -16, all: [0, 0, 12] },
  windup: { uaF: -205, faF: -40, uaB: 40, faB: -30, torso: 10, head: 6, thF: -14, shF: 20, thB: 12, shB: -18, all: [0, -10, 14] },
  slash: { uaF: -55, faF: 10, uaB: 30, faB: 10, torso: -16, head: -8, thF: -46, shF: 34, thB: 28, shB: -8, all: [0, 44, 22] },
  guard: { uaF: -70, faF: -95, uaB: 36, faB: -70, torso: 4, head: 2, thF: -12, shF: 16, thB: 14, shB: -16, all: [0, 0, 8] },
  palm: { uaF: -92, faF: -12, uaB: 10, faB: -8, torso: -3, head: -2 },
  spread: { uaF: -110, faF: -40, uaB: 110, faB: 40, torso: 0, head: 3 },
  think: { uaF: -38, faF: -128, uaB: 24, faB: -72, head: 9, torso: 2 },
  hip: { uaF: 6, faF: 0, uaB: 42, faB: -76, head: -3, torso: -2 },
  cross: { uaF: 42, faF: -112, uaB: -42, faB: 112, head: 4, torso: 3 },
  up: { uaF: -172, faF: -12, uaB: -8, faB: 0, torso: -3, head: -3 },
  wipe: { uaF: -150, faF: -122, uaB: 10, faB: 0, head: 5, torso: 2 },
  crouch: { thF: -40, shF: 70, thB: 30, shB: -70, torso: -8, head: 2, all: [0, 0, 60] },
  bow: { torso: -28, head: -6, uaF: 30, faF: -40, uaB: -30, faB: 40 },
  lean: { torso: 10, head: 6, all: [0, -8, 0] },
};
const LIMBS = ["uaF", "faF", "uaB", "faB", "head", "torso", "thF", "shF", "thB", "shB", "all"];

// ---------------------------------------------------------------- động tác (ctx = Mover) → thời lượng
export const MOVES = {
  // về tư thế tên `pose` trong d giây
  pose(m, p, t, { pose = "rest", d = 0.35, ease = "back.out(1.4)", only } = {}) {
    const v = POSES[pose] || POSES.rest, keys = only || Object.keys(v);
    for (const j of keys) if (j in v) { const x = Array.isArray(v[j]) ? v[j] : [v[j], 0, 0]; m.J(p, j, t, d, ...x, ease); }
    return d;
  },
  // nói chuyện có cử chỉ nhỏ ngẫu nhiên (tay F nhịp, nghiêng đầu, đổi trụ) trong [t, t+dur]
  talk(m, p, t, { dur = 3, base = "rest", energy = 1 } = {}) {
    MOVES.pose(m, p, t, { pose: base, d: 0.3 });
    let k = t + 0.5;
    while (k < t + dur - 0.6) {
      const g = Math.floor(m.rnd() * 4), d = m.range(0.28, 0.42) / energy;
      if (g === 0) { m.J(p, "uaF", k, d, m.range(-70, -40), 0, 0, "power2.out"); m.J(p, "faF", k, d, m.range(-50, -20), 0, 0, "power2.out"); m.J(p, "uaF", k + d + 0.3, 0.4, POSES[base]?.uaF ?? 6); m.J(p, "faF", k + d + 0.3, 0.4, POSES[base]?.faF ?? 0); }
      else if (g === 1) { m.J(p, "head", k, d, m.range(-7, 7) * energy, 0, 0, "sine.inOut"); m.J(p, "head", k + d + 0.5, 0.4, 0); }
      else if (g === 2) { m.J(p, "torso", k, d, m.range(-4, 4) * energy); m.J(p, "torso", k + d + 0.5, 0.4, 0); }
      else { m.J(p, "all", k, d, 0, m.range(-8, 8), 0, "sine.inOut"); }
      k += d + m.range(0.9, 1.7);
    }
    return dur;
  },
  nod(m, p, t, { n = 2 } = {}) { return m.nod(p, t, n); },
  // quay đầu nhìn: góc dương nghiêng về bên B
  look(m, p, t, { a = -8, d = 0.25 } = {}) { m.J(p, "head", t, d, a, 0, 0, "power2.out"); return d; },
  // bước đi tới dx (px, toạ độ màn, chưa lật) với n bước, hai chân đổi nhau, thân nhún
  walk(m, p, t, { dx = 200, n, step = 0.3, sel } = {}) {
    n = n || Math.max(2, Math.round(Math.abs(dx) / 55));
    const s = Math.sign(dx) || 1;
    for (let k = 0; k < n; k++) {
      const a = (k % 2 ? 1 : -1) * 26 * s;
      m.J(p, "thF", t + k * step, step, a, 0, 0, "sine.inOut"); m.J(p, "thB", t + k * step, step, -a, 0, 0, "sine.inOut");
      m.J(p, "shF", t + k * step, step, a > 0 ? 24 : 2, 0, 0, "sine.inOut"); m.J(p, "shB", t + k * step, step, a > 0 ? 2 : 24, 0, 0, "sine.inOut");
      m.J(p, "uaF", t + k * step, step, -a * 0.8, 0, 0, "sine.inOut"); m.J(p, "uaB", t + k * step, step, -a * 0.8, 0, 0, "sine.inOut");
      m.J(p, "all", t + k * step, step / 2, 0, 0, -8, "sine.out"); m.J(p, "all", t + k * step + step / 2, step / 2, 0, 0, 0, "sine.in");
    }
    for (const j of ["thF", "thB", "shF", "shB", "uaF", "uaB"]) m.J(p, j, t + n * step, 0.2, POSES.rest[j] || 0);
    m.moveX(sel, t, n * step, dx);
    return n * step + 0.2;
  },
  // nâng trọng kiếm hai tay: chậm, nặng, hạ tấn
  "heavy-raise"(m, p, t, { d = 1.1 } = {}) {
    MOVES.pose(m, p, t, { pose: "crouch", d: 0.35, ease: "power2.out", only: ["thF", "shF", "thB", "shB", "all"] });
    m.J(p, "torso", t, 0.35, 8); m.J(p, "head", t, 0.35, 6);
    m.J(p, "uaF", t + 0.2, d, -170, 0, 0, "power3.inOut"); m.J(p, "faF", t + 0.2, d, -6, 0, 0, "power3.inOut");
    m.J(p, "uaB", t + 0.2, d, 170, 0, 0, "power3.inOut"); m.J(p, "faB", t + 0.2, d, 6, 0, 0, "power3.inOut");
    m.J(p, "torso", t + 0.5, d - 0.2, -4, 0, 0, "power2.inOut"); m.J(p, "head", t + 0.5, d - 0.2, -4);
    for (const [j, a] of [["thF", -14], ["shF", 20], ["thB", 14], ["shB", -20]]) m.J(p, j, t + 0.4, d - 0.2, a, 0, 0, "power2.inOut");
    m.J(p, "all", t + 0.4, d - 0.2, 0, 0, 14, "power2.inOut");
    return d + 0.3;
  },
  // chém nặng: lấy đà → lao chém → đứng khựng. opts.trail = id đường vệt, opts.dust = [id...], opts.cam = selector camera
  "heavy-slash"(m, p, t, { trail, dust = [], cam, sel, dx = 120, big = true } = {}) {
    MOVES.pose(m, p, t, { pose: "windup", d: 0.42, ease: "power2.inOut" });
    const ts = t + 0.55;
    MOVES.pose(m, p, ts, { pose: "slash", d: big ? 0.14 : 0.1, ease: "power4.in" });
    m.moveX(sel, ts, 0.16, dx, "power3.in");
    if (trail) m.js(`TRAIL("${trail}", ${f2(ts + 0.04)}, 0.16);`);
    dust.forEach((id, i) => m.js(`PUFF("${id}", ${f2(ts + 0.12 + i * 0.03)}, ${f2(m.range(-70, 70))}, ${f2(m.range(-50, -10))}, ${f2(m.range(0.7, 1.4))});`));
    if (cam) m.js(`SHAKE("${cam}", ${f2(ts + 0.14)}, 0.4, ${big ? 18 : 9});`);
    // hồi: giữ thế chém một nhịp rồi về
    MOVES.pose(m, p, ts + 1.0, { pose: "rest", d: 0.5, ease: "power2.inOut" });
    return 2.1;
  },
  // đỡ rồi loạng choạng lùi n bước (dx mỗi bước, px màn). sel = div nhân vật để dời; dust ids
  "block-stagger"(m, p, t, { sel, n = 3, dx = -70, dust = [], impact = t + 0.35 } = {}) {
    MOVES.pose(m, p, t, { pose: "guard", d: 0.28, ease: "power2.out" });
    let k = impact;
    for (let i = 0; i < n; i++) {
      const hop = 0.22;
      m.J(p, "all", k, hop / 2, 10 + i * 4, 0, -18, "power2.out"); m.J(p, "all", k + hop / 2, hop / 2, 8 + i * 4, 0, 6, "power2.in");
      m.J(p, "thF", k, hop, -30, 0, 0, "sine.inOut"); m.J(p, "thB", k, hop, 20, 0, 0, "sine.inOut"); m.J(p, "shF", k, hop, 40, 0, 0, "sine.inOut");
      m.J(p, "thF", k + hop, 0.12, 10); m.J(p, "thB", k + hop, 0.12, -10); m.J(p, "shF", k + hop, 0.12, 10);
      m.J(p, "torso", k, hop, 12 + i * 5, 0, 0, "power2.out"); m.J(p, "head", k, hop, 10 + i * 3, 0, 0, "power2.out");
      m.moveX(sel, k, hop, dx, "power1.out");
      if (dust[i]) m.js(`PUFF("${dust[i]}", ${f2(k + hop)}, ${f2(-Math.sign(dx) * 40)}, -20, 0.9);`);
      k += hop + 0.12;
    }
    m.J(p, "all", k, 0.35, 0, 0, 0, "power2.out"); m.J(p, "torso", k, 0.4, 0); m.J(p, "head", k, 0.4, 0);
    for (const j of ["thF", "thB", "shF", "shB"]) m.J(p, j, k + 0.05, 0.35, 0);
    MOVES.pose(m, p, k + 0.3, { pose: "rest", d: 0.4, only: ["uaF", "faF", "uaB", "faB"] });
    return k + 0.8 - t;
  },
  // lau mồ hôi: tay lên trán, đầu nghiêng, rồi hạ
  wipe(m, p, t, {} = {}) {
    MOVES.pose(m, p, t, { pose: "wipe", d: 0.4, ease: "power2.out" });
    m.J(p, "faF", t + 0.5, 0.25, -100, 0, 0, "sine.inOut"); m.J(p, "faF", t + 0.75, 0.25, -122, 0, 0, "sine.inOut");
    MOVES.pose(m, p, t + 1.3, { pose: "rest", d: 0.4 });
    return 1.7;
  },
  // nhún vai / dang tay
  shrug(m, p, t, {} = {}) {
    MOVES.pose(m, p, t, { pose: "spread", d: 0.35, ease: "back.out(1.8)" });
    m.J(p, "all", t, 0.2, 0, 0, -6, "power2.out"); m.J(p, "all", t + 0.2, 0.3, 0, 0, 0, "bounce.out");
    return 0.6;
  },
  // thở dốc: cúi + thở 2 nhịp
  pant(m, p, t, { n = 2 } = {}) {
    m.J(p, "torso", t, 0.3, -14, 0, 0, "power2.out"); m.J(p, "head", t, 0.3, -6); m.J(p, "uaF", t, 0.3, -30); m.J(p, "faF", t, 0.3, -20); m.J(p, "uaB", t, 0.3, 30); m.J(p, "faB", t, 0.3, 20);
    for (let k = 0; k < n; k++) { const b = t + 0.35 + k * 0.7; m.J(p, "torso", b, 0.35, -18, 0, 0, "sine.inOut"); m.J(p, "torso", b + 0.35, 0.35, -12, 0, 0, "sine.inOut"); }
    const e = t + 0.35 + n * 0.7;
    MOVES.pose(m, p, e, { pose: "rest", d: 0.45 });
    return e + 0.45 - t;
  },
  // múa kiếm một tay (Dương Quá): xoay cổ tay 2 vòng rồi chĩa
  flourish(m, p, t, { wp = "wpF" } = {}) {
    m.J(p, "uaF", t, 0.3, -95, 0, 0, "power2.out"); m.J(p, "faF", t, 0.3, -10);
    m.J(p, wp, t + 0.3, 0.5, 180 + 360, 0, 0, "power1.inOut"); m.J(p, wp, t + 0.8, 0.4, 180 + 720, 0, 0, "power2.out");
    m.J(p, "torso", t, 0.3, -5); m.J(p, "head", t, 0.3, -4);
    m.J(p, "all", t + 0.3, 0.5, 0, 10, 0, "sine.inOut"); m.J(p, "all", t + 0.8, 0.4, 0, 0, 0, "sine.inOut");
    return 1.3;
  },
  // nhảy lên (tấn công/tránh): bật, co chân, tiếp đất nhún
  jump(m, p, t, { sel, dx = 0, h = 160, d = 0.6, dust = [] } = {}) {
    m.J(p, "all", t, 0.18, 0, 0, 30, "power2.in"); // nhún lấy đà
    m.J(p, "thF", t + 0.18, 0.2, -50, 0, 0, "power2.out"); m.J(p, "shF", t + 0.18, 0.2, 70); m.J(p, "thB", t + 0.18, 0.2, 30); m.J(p, "shB", t + 0.18, 0.2, -80);
    m.J(p, "uaF", t + 0.18, 0.25, -140); m.J(p, "uaB", t + 0.18, 0.25, 120); m.J(p, "torso", t + 0.18, 0.25, -8);
    m.J(p, "all", t + 0.18, d / 2, -6, 0, -h, "power2.out"); m.J(p, "all", t + 0.18 + d / 2, d / 2, 4, 0, 20, "power2.in");
    m.moveX(sel, t + 0.18, d, dx);
    const land = t + 0.18 + d;
    for (const j of ["thF", "shF", "thB", "shB"]) m.J(p, j, land, 0.15, POSES.crouch[j]);
    m.J(p, "all", land, 0.25, 0, 0, 0, "power2.out");
    dust.forEach((id, i) => m.js(`PUFF("${id}", ${f2(land + i * 0.02)}, ${f2(i % 2 ? 60 : -60)}, -16, 1);`));
    MOVES.pose(m, p, land + 0.3, { pose: "rest", d: 0.4 });
    return land + 0.7 - t;
  },
};
export const MOVE_NAMES = Object.keys(MOVES);
