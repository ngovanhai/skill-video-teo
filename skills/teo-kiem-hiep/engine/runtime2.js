// Runtime v2 (trong trang) — chỉ có lệnh nguyên thuỷ; thư viện động tác nằm ở engine/moves2.mjs (node) và
// đã kiểm tra chồng tween trước khi sinh mã. Builder chèn `const JPOS=..., EXPRS=..., SEED=...` trước file này.
// Quy ước: khớp là <g id="p-khớp" transform="translate(x y) rotate(a)">; xoay bằng attr transform (không svgOrigin).
window.__timelines = window.__timelines || {};
const tl = gsap.timeline({ paused: true });
window.__timelines["main"] = tl;
let __sd = SEED;
const rand = () => (__sd = (__sd * 16807) % 2147483647) / 2147483647;
const NF = { immediateRender: false };
const $id = (id) => document.getElementById(id);
const jof = (id) => JPOS[id.slice(id.lastIndexOf("-") + 1)] || [0, 0];
const TR = (id, a, dx, dy) => { const [x, y] = jof(id); return `translate(${+(x + dx).toFixed(2)} ${+(y + dy).toFixed(2)}) rotate(${+a.toFixed(2)})`; };
// xoay/dời khớp: J(id, t, d, góc, dx, dy, ease)
const J = (id, t, d, a = 0, dx = 0, dy = 0, ease = "power2.inOut") => { if ($id(id)) tl.to("#" + id, { attr: { transform: TR(id, a, dx, dy) }, duration: d, ease, ...NF }, t); };
const JS = (id, a = 0, dx = 0, dy = 0) => { if ($id(id)) gsap.set("#" + id, { attr: { transform: TR(id, a, dx, dy) } }); };
// lắc qua lại (tóc, vạt áo, dải băng): SWAY(id, t0, t1, biên, chu kỳ, lệch pha)
const SWAY = (id, t0, t1, amp, per, ph = 0) => { if (!$id(id)) return; const n = Math.max(1, Math.ceil((t1 - t0) / per)); tl.fromTo("#" + id, { attr: { transform: TR(id, -amp, 0, 0) } }, { attr: { transform: TR(id, amp, 0, 0) }, duration: per, yoyo: true, repeat: n * 2, ease: "sine.inOut", ...NF }, t0 + ph); };
// thở: scale nhẹ nhóm thân
const BREATH = (p, t0, t1, amp = 0.022, per = 1.4) => { const id = p + "-breath"; if (!$id(id)) return; const n = Math.max(1, Math.ceil((t1 - t0) / per)); tl.fromTo("#" + id, { attr: { transform: "scale(1 1)" } }, { attr: { transform: `scale(1 ${1 + amp})` }, duration: per, yoyo: true, repeat: n, ease: "sine.inOut", ...NF }, t0); };
const OP = (id, t, o) => { if ($id(id)) tl.set("#" + id, { attr: { opacity: o } }, t); };
// biểu cảm: chỉ 1 nhóm p-ex-<tên> hiện
const __exl = {};
const EX = (p, t, name) => { (__exl[p] = __exl[p] || []).push([t, name]); for (const e of EXPRS) OP(`${p}-ex-${e}`, t, e === name ? 1 : 0); };
const exAt = (p, t) => { let n = "vui", tt = -1; for (const [a, e] of __exl[p] || []) if (a <= t + 1e-6 && a >= tt) { tt = a; n = e; } return n; };
// miệng của biểu cảm đang hiện
const MO = (p, ex, t, open) => { OP(`${p}-mo-${ex}`, t, open ? 1 : 0); OP(`${p}-mc-${ex}`, t, open ? 0 : 1); };
// FLAP(p, ex, t0, t1); dạng cũ FLAP(p, t0, t1) xếp hàng, __FLUSH() tra biểu cảm đang hiện lúc t0 (EX gọi theo thứ tự bất kỳ)
const __fq = [];
const __FLUSH = () => { for (const [p, t0, t1] of __fq.splice(0)) FLAP(p, exAt(p, t0), t0, t1); };
const FLAP = (p, ex, t0, t1) => { if (typeof ex === "number") { __fq.push([p, ex, t0]); return; } let t = t0; while (t < t1 - 0.12) { const d = 0.11 + rand() * 0.1; MO(p, ex, t, 1); MO(p, ex, t + d, 0); t += d + 0.08 + rand() * 0.1; } };
const BLINK = (p, t) => { OP(p + "-blink", t, 1); OP(p + "-blink", t + 0.1, 0); };
// nhìn/gật: dịch nhóm mặt trong đầu (p-face giữ scale nên dùng x/y css)
const NOD = (p, t, n = 1) => { for (let k = 0; k < n; k++) { J(p + "-head", t + k * 0.36, 0.14, 6, 0, 7, "power2.out"); J(p + "-head", t + k * 0.36 + 0.14, 0.18, 0, 0, 0, "power2.inOut"); } };
// div/hình phẳng
const TO = (sel, t, d, props, ease = "power2.out") => tl.to(sel, { ...props, duration: d, ease, ...NF }, t);
const FROMTO = (sel, t, d, from, to, ease = "power2.out") => tl.fromTo(sel, from, { ...to, duration: d, ease, ...NF }, t);
const SETP = (sel, t, props) => tl.set(sel, props, t);
const POP = (sel, t, extra = {}) => tl.fromTo(sel, { scale: 0, opacity: 0 }, { scale: 1, opacity: 1, duration: 0.45, ease: "back.out(2.2)", ...NF, ...extra }, t);
const SHOW = (sel, t, dur = 0.25, from = {}) => tl.fromTo(sel, { opacity: 0, ...from }, { opacity: 1, x: 0, y: 0, duration: dur, ease: "power2.out", ...NF }, t);
const HIDE = (sel, t, dur = 0.2) => tl.to(sel, { opacity: 0, duration: dur, ...NF }, t);
const FLASH = (t, peak = 0.9, dur = 0.4, color = "#ffffff") => { tl.set("#X-flash", { backgroundColor: color }, t); tl.fromTo("#X-flash", { opacity: peak }, { opacity: 0, duration: dur, ease: "power2.out", ...NF }, t); };
const SHAKE = (sel, t, dur, amp) => { const n = Math.max(1, Math.round(dur / 0.04)); for (let k = 0; k < n; k++) { const f = 1 - k / n; tl.to(sel, { x: (rand() - 0.5) * 2 * amp * f, y: (rand() - 0.5) * 2 * amp * f, duration: 0.04, ease: "none" }, t + k * 0.04); } tl.to(sel, { x: 0, y: 0, duration: 0.04 }, t + n * 0.04); };
const DRAW = (sel, t, dur = 0.4, ease = "power2.out") => tl.to(sel, { strokeDashoffset: 0, duration: dur, ease, ...NF }, t);
const DASHLEN = (id) => { const el = $id(id); if (!el) return; el.removeAttribute("pathLength"); const L = Math.ceil(el.getTotalLength()) + 10; el.setAttribute("stroke-dasharray", L + " " + L * 2); el.setAttribute("stroke-dashoffset", L); };
// bụi: phần tử #id có sẵn (opacity 0) → nổ ra rồi tan
const PUFF = (id, t, dx, dy, s = 1) => { if (!$id(id)) return; tl.fromTo("#" + id, { x: 0, y: 0, scale: 0.3 * s, opacity: 0.9 }, { x: dx, y: dy, scale: 1.4 * s, opacity: 0, duration: 0.55, ease: "power2.out", ...NF }, t); };
// vệt kiếm: đường #id vẽ ra rồi mờ
const TRAIL = (id, t, d = 0.18) => { if (!$id(id)) return; DASHLEN(id); tl.set("#" + id, { opacity: 1 }, t); DRAW("#" + id, t, d, "power3.out"); tl.to("#" + id, { opacity: 0, duration: 0.25, ...NF }, t + d + 0.05); };
