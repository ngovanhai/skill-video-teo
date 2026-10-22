// Dò các mẫu làm hyperframes bỏ chụp nhanh (drawElement) và rớt về chụp màn hình, chậm gấp đôi.
// build.mjs gọi printSlow sau khi dựng index.html.
const RULES = [
  [/(?:^|[^-])filter\s*:[^;"{}]*blur\(|filter:\s*"[^"]*blur\(/i, "filter blur() — dùng radial-gradient mềm thay"],
  [/drop-shadow\(/i, "filter drop-shadow() — vẽ quầng bằng nét to mờ phía sau (glowStroke) hoặc radial-gradient"],
  [/mix-blend-mode|mixBlendMode/, "mix-blend-mode — dùng lớp phủ rgba thường"],
  [/backdrop-filter|backdropFilter/, "backdrop-filter"],
  [/perspective|preserve-3d|backface-visibility/, "CSS 3D (perspective / preserve-3d / backface) — dùng scaleX/scaleY giả lật"],
  [/@keyframes|animation\s*:/, "CSS animation — chuyển động phải nằm trên timeline GSAP"],
  [/\b(rotationX|rotationY|rotateX|rotateY|translateZ|z)\s*:/, "tween 3D (rotationX/Y, z) — dùng scaleX/scaleY"],
  [/\bclipPath\s*:|\bmask(Image)?\s*:/, "tween clipPath/mask — dùng width/left/right + overflow:hidden"],
  [/\bon(Update|Complete|Start|Repeat)\s*:|\btl\.call\(|\.eventCallback\(/, "callback GSAP — hyperframes tua nhảy không gọi callback nên self-verify lệch, render lại cả tập ở chế độ chậm"],
];

// html = index.html đã dựng. Trả mảng { why, sample }.
export function slowLint(html) {
  const out = [];
  const code = html.replace(/<script src=[^>]*><\/script>/g, "");
  for (const [re, why] of RULES) {
    const m = code.match(re);
    if (!m) continue;
    const i = m.index;
    out.push({ why, sample: code.slice(Math.max(0, i - 60), i + 60).replace(/\s+/g, " ") });
  }
  return out;
}

export function printSlow(html, log = console.warn) {
  const hits = slowLint(html);
  for (const h of hits) log(`⚠ render chậm: ${h.why}\n    …${h.sample}…`);
  return hits.length;
}
