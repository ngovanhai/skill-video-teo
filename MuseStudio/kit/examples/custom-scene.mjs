// Mẫu cảnh custom — copy sang <video>/scenes/<ten>.mjs rồi vẽ lại cho hợp chủ đề.
// Trong chương: {"type": "custom", "file": "scenes/trong-dong.mjs", "say": "...", "title": "Trống đồng Đông Sơn",
//               "title_at": "trống đồng", "who": "vua", "who_at": "nhà vua", "fx": ["dust"]}
// Luật: vẽ trong y < 880 (phụ đề ở dưới); mọi thứ bắt đầu ẩn rồi hiện đúng cue; id luôn bắt đầu bằng `${ns}-`.
// ctx = { video, scene, ns, cues, dur }; kit = { C, esc, r3, color, fit, charBox, times, sfx, cameo, ... }.
// Runtime trong js: tl, q, qa, POP, STAMP, SLIDE, FADE, OUT, DRAW, SHAKE, BOB, FLAP.
export default function (ctx, kit) {
  const { scene: s, ns, cues, dur, video } = ctx;
  const { C, esc, r3, fit, charBox, sfx } = kit;
  const tTitle = cues.find(s.title_at, 0.4);
  const tDrum = cues.find(s.drum_at, 0.2);

  // 1. SVG vẽ tay: mặt trống đồng — ngôi sao giữa + các vòng hoa văn (vẽ dần bằng stroke-dashoffset)
  const rings = [90, 150, 210, 270, 330];
  let svg = `<circle cx="0" cy="0" r="370" fill="#C98A3A" stroke="#000" stroke-width="10"/>`;
  rings.forEach((r, i) => {
    svg += `<circle class="${ns}-ring" cx="0" cy="0" r="${r}" fill="none" stroke="#5A3410" stroke-width="${i % 2 ? 6 : 10}" pathLength="1" stroke-dasharray="${i % 2 ? "0.02 0.015" : "1"}" stroke-dashoffset="1"/>`;
  });
  const star = Array.from({ length: 28 }, (_, i) => {
    const a = (Math.PI * i) / 14 - Math.PI / 2, r = i % 2 ? 26 : 84;
    return `${r3(Math.cos(a) * r)},${r3(Math.sin(a) * r)}`;
  }).join(" ");
  svg += `<polygon id="${ns}-star" points="${star}" fill="#F7CB46" stroke="#000" stroke-width="6"/>`;
  // chim Lạc bay vòng ngoài: 6 hình chim đơn giản quay quanh tâm
  let birds = "";
  for (let i = 0; i < 6; i++) {
    const a = (360 / 6) * i;
    birds += `<g transform="rotate(${a}) translate(0 -300)"><path d="M-34 6 Q-10 -18 0 0 Q12 -24 40 -4 Q14 -6 0 10 Z" fill="#000"/></g>`;
  }
  svg += `<g id="${ns}-birds" opacity="0">${birds}</g>`;

  let html = `<div id="${ns}-drum" style="position:absolute;left:${960 - 380}px;top:60px;width:760px;height:760px;transform:scale(0);">
      <svg viewBox="-380 -380 760 760" style="width:100%;height:100%;overflow:visible">${svg}</svg></div>`;
  let js = `      tl.fromTo(q("#${ns}-drum"), { scale: 0, rotation: -90 }, { scale: 1, rotation: 0, duration: 0.8, ease: "back.out(1.4)", immediateRender: false }, ${r3(tDrum)});
      DRAW(qa(".${ns}-ring"), ${r3(tDrum + 0.4)}, 1.2);
      tl.fromTo(q("#${ns}-star"), { scale: 0, transformOrigin: "50% 50%" }, { scale: 1, duration: 0.5, ease: "back.out(2)", immediateRender: false }, ${r3(tDrum + 0.5)});
      FADE(q("#${ns}-birds"), ${r3(tDrum + 1.2)}, 0.5);
      tl.to(q("#${ns}-birds"), { rotation: 40, svgOrigin: "0 0", duration: ${r3(Math.max(1, dur - tDrum - 1.2))}, ease: "none" }, ${r3(tDrum + 1.2)});\n`;

  // 2. thẻ tiêu đề kiểu kit (viền đen, bóng cứng)
  if (s.title) {
    html += `<div class="${ns}-card ${ns}-up" id="${ns}-title" style="left:120px;top:70px;width:560px;background:${C.cream};font-size:${fit(s.title, 500, 56, 28, 2)}px;transform:rotate(-2deg);opacity:0;">${esc(s.title)}</div>`;
    js += `      STAMP(q("#${ns}-title"), ${r3(tTitle)}, -2);\n`;
  }

  // 3. nhân vật trong cast (tuỳ chọn)
  if (s.who) {
    const c = charBox(video, s.who, { ns: `${ns}-c`, left: 1440, top: 880 - 460, h: 460, pose: s.pose });
    html += c.html;
    js += `      SLIDE(q("#${ns}-c"), ${r3(cues.find(s.who_at, 1))}, 300, 0, 0.5);
      FLAP("${ns}-c", ${JSON.stringify(cues.spans(0, dur))});\n`;
  }

  return { css: "", html, js, sfx: [sfx("whoosh", tDrum, 0.3), sfx("chime", tDrum + 0.5, 0.3)], bg: s.bg || "cream" };
}
