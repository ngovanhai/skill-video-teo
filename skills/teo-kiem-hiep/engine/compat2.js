// Lớp tương thích v1 → rig v2 (build.mjs khi tap.rig = 2), chèn sau runtime2.js. fx viết cho rig cũ (POSE/R/RS/BROW/KO/RUN/ATTR,
// khớp armF/foreF/armB/foreB/legL/legR/head/all/tail) chạy trên khớp v2. Builder chèn `const POSES2 = {...}` (moves2 POSES) trước file.
// fx mới cho rig 2 nên gọi thẳng J/JS/EX/SWAY với khớp v2 (uaF faF hdF uaB faB hdB thF shF ftF thB shB ftB head torso all wpF tail…).
const J1 = { armF: "uaF", foreF: "faF", armB: "uaB", foreB: "faB", legL: "thB", legR: "thF", head: "head", all: "all", tail: "tail" };
const POSE1 = { wave: "point-up" };
const j2 = (id) => { const i = id.lastIndexOf("-"), j = J1[id.slice(i + 1)]; return j ? id.slice(0, i + 1) + j : null; };
const R = (id, deg, t, dur = 0.3, ease = "power2.inOut") => { const k = j2(id); if (k) J(k, t, dur, deg, 0, 0, ease); else if ($id(id)) tl.to("#" + id, { rotation: deg, duration: dur, ease, ...NF }, t); };
const RS = (id, deg) => { const k = j2(id); if (k) JS(k, deg); };
const ATTR = (id, t, o) => OP(id, t, o);
const BROW = (p, t, angry) => EX(p, t, angry ? "gian" : "vui");
const KO = (p, t, on = true) => EX(p, t, on ? "ko" : "vui");
// như v1: chỉ tay + thân + đầu (chân/all do fx tự lo); khớp tư thế không ghi thì về rest
const POSE_J = ["uaF", "faF", "uaB", "faB", "torso", "head"];
const POSE = (p, name, t, dur = 0.3, ease = "back.out(1.6)") => {
  const P = POSES2[POSE1[name] || name] || POSES2.rest, v = {};
  for (const j of POSE_J) v[j] = P[j] ?? POSES2.rest[j] ?? 0;
  for (const j in v) { const x = Array.isArray(v[j]) ? v[j] : [v[j], 0, 0]; J(p + "-" + j, t, dur, x[0], x[1], x[2], ease); }
};
// chạy/đi: hai đùi đổi nhau, cẳng chân co, tay vung; bob = selector div nhún lên xuống
const RUN = (p, t0, t1, bob, arms = true, amp = 28, step = 0.14) => {
  let k = 0;
  for (let t = t0; t < t1 - 1e-6; t += step, k++) {
    const a = k % 2 ? amp : -amp;
    J(p + "-thF", t, step, a, 0, 0, "sine.inOut"); J(p + "-thB", t, step, -a, 0, 0, "sine.inOut");
    J(p + "-shF", t, step, a > 0 ? 24 : 2, 0, 0, "sine.inOut"); J(p + "-shB", t, step, a > 0 ? 2 : 24, 0, 0, "sine.inOut");
    if (arms) { J(p + "-uaF", t, step, -a * 0.8, 0, 0, "sine.inOut"); J(p + "-uaB", t, step, -a * 0.8, 0, 0, "sine.inOut"); }
  }
  for (const j of ["thF", "thB", "shF", "shB"].concat(arms ? ["uaF", "uaB"] : [])) J(p + "-" + j, t1, 0.15, POSES2.rest[j] || 0);
  if (bob && k) tl.to(bob, { y: -14, duration: step / 2, yoyo: true, repeat: 2 * k - 1, ease: "sine.out" }, t0);
};
const STAMP = (sel, t, rotTo = -6) => tl.fromTo(sel, { scale: 2.8, opacity: 0, rotation: rotTo - 10 }, { scale: 1, opacity: 1, rotation: rotTo, duration: 0.26, ease: "power4.in", ...NF }, t);
// vũ khí: 180 = lưỡi nối dài cẳng tay (như thu-rig2)
document.querySelectorAll('[id$="-wpF"],[id$="-wpB"]').forEach((e) => JS(e.id, 180));
