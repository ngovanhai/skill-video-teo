// `morse`: dải băng giấy điện tín chạy ngang, chấm–gạch Morse in dần, chữ giải mã hiện bên dưới (text, x, y, w, color).
// `frost`: băng giá loang từ 4 góc khung vào trong (n nhánh, color, reach) — lạnh, đóng băng, đêm trên biển băng.
import { rng, when, layer, sfx, r3, esc } from "./_util.mjs";

const CODE = { A: ".-", B: "-...", C: "-.-.", D: "-..", E: ".", F: "..-.", G: "--.", H: "....", I: "..", J: ".---", K: "-.-", L: ".-..", M: "--",
  N: "-.", O: "---", P: ".--.", Q: "--.-", R: ".-.", S: "...", T: "-", U: "..-", V: "...-", W: ".--", X: "-..-", Y: "-.--", Z: "--..",
  0: "-----", 1: ".----", 2: "..---", 3: "...--", 4: "....-", 5: ".....", 6: "-....", 7: "--...", 8: "---..", 9: "----." };

const morse = { id: "morse", cat: "accent", label: "Băng điện tín chạy chấm–gạch Morse + chữ giải mã (text, x, y, w, color)",
  run(ctx, o) {
    const { t, d } = when(ctx, o, 0.3);
    const id = ctx.id, text = String(o.text || "SOS").toUpperCase(), x = o.x ?? 360, y = o.y ?? 70, w = o.w ?? 1200;
    const ink = o.color || "#0D1B2E";
    // build marks: dot = circle, dash = rounded bar; letter gap 26, symbol gap 12
    let cx = 20, marks = "", n = 0;
    for (const ch of text) {
      if (ch === " ") { cx += 34; continue; }
      for (const s of CODE[ch] || "") {
        if (s === ".") { marks += `<circle class="${id}-m" cx="${cx + 7}" cy="45" r="8" fill="${ink}" opacity="0"/>`; cx += 26; }
        else { marks += `<rect class="${id}-m" x="${cx}" y="38" width="38" height="14" rx="7" fill="${ink}" opacity="0"/>`; cx += 52; }
        n++;
      }
      cx += 22;
    }
    const tapeW = Math.max(w, cx + 40);
    const inner = `<div id="${id}-box" style="position:absolute;left:${x}px;top:${y}px;width:${w}px;height:170px;opacity:0;">
        <div style="position:absolute;left:0;top:0;width:${w}px;height:90px;overflow:hidden;background:#F4E9CF;border:5px solid #111;box-shadow:6px 6px 0 #111;">
          <svg id="${id}-tape" viewBox="0 0 ${tapeW} 90" style="position:absolute;left:0;top:0;width:${tapeW}px;height:90px;">
            <path d="M0 12 H${tapeW} M0 78 H${tapeW}" stroke="#C9B48A" stroke-width="3" stroke-dasharray="14 10"/>${marks}</svg></div>
        <div id="${id}-txt" style="position:absolute;left:0;top:104px;width:${w}px;text-align:center;font-weight:700;font-size:52px;letter-spacing:10px;color:#FFFDF5;text-shadow:4px 4px 0 #111;opacity:0;">${esc(text)}</div></div>`;
    const step = r3(Math.min(0.12, Math.max(0.04, (d * 0.6) / Math.max(1, n))));
    let js = `      FADE(q("#${id}-box"), ${t}, 0.3);
      qa(".${id}-m").forEach(function (m, i) { tl.set(m, { attr: { opacity: 1 } }, ${t} + 0.3 + i * ${step}); });\n`;
    if (tapeW > w) js += `      tl.fromTo(q("#${id}-tape"), { x: 0 }, { x: ${-(tapeW - w)}, duration: ${r3(n * step)}, ease: "none", immediateRender: false }, ${r3(t + 0.3)});\n`;
    js += `      SLIDE(q("#${id}-txt"), ${r3(t + 0.3 + n * step)}, 0, 20, 0.4);\n`;
    return { over: layer(id, inner), js, sfx: o.sound === false ? [] : [sfx("click", t + 0.3, 0.25), sfx("click", t + 0.3 + n * step * 0.5, 0.2)] };
  } };

const frost = { id: "frost", cat: "atmosphere", label: "Băng giá loang từ 4 góc khung vào trong (n nhánh, color, reach)",
  run(ctx, o) {
    const { t, d, end } = when(ctx, o, 0.1);
    const R = rng(ctx.id), id = ctx.id, n = o.n ?? 7, reach = o.reach ?? 340, col = o.color || "#DFF3FF";
    const corners = [[0, 0, 1, 1], [1920, 0, -1, 1], [0, 1080, 1, -1], [1920, 1080, -1, -1]];
    let paths = "";
    corners.forEach(([cx, cy, sx, sy]) => {
      for (let i = 0; i < n; i++) {
        const a = (Math.PI / 2) * ((i + 0.5) / n), len = reach * (0.55 + R() * 0.6);
        const ex = cx + sx * Math.cos(a) * len, ey = cy + sy * Math.sin(a) * len;
        let dd = `M${cx} ${cy} L${r3(ex)} ${r3(ey)}`;
        for (let k = 1; k <= 3; k++) {
          const f = k / 4, bx = cx + (ex - cx) * f, by = cy + (ey - cy) * f, bl = len * 0.18 * (1 - f * 0.5);
          dd += ` M${r3(bx)} ${r3(by)} l${r3(sx * Math.cos(a + 0.6) * bl)} ${r3(sy * Math.sin(a + 0.6) * bl)} M${r3(bx)} ${r3(by)} l${r3(sx * Math.cos(a - 0.6) * bl)} ${r3(sy * Math.sin(a - 0.6) * bl)}`;
        }
        paths += `<path class="${id}-b" d="${dd}" fill="none" stroke="${col}" stroke-width="${r3(3 + R() * 3)}" stroke-linecap="round" pathLength="1" stroke-dasharray="1" stroke-dashoffset="1" opacity=".85"/>`;
      }
    });
    const glaze = `<div id="${id}-gl" style="position:absolute;inset:0;opacity:0;background:radial-gradient(ellipse at center, rgba(223,243,255,0) 55%, rgba(223,243,255,.35) 100%);"></div>`;
    const inner = `${glaze}<svg viewBox="0 0 1920 1080" style="position:absolute;inset:0;width:1920px;height:1080px;">${paths}</svg>`;
    const grow = r3(Math.min(2.4, Math.max(0.8, d * 0.5)));
    let js = `      FADE(q("#${id}"), ${t}, 0.3);
      FADE(q("#${id}-gl"), ${t}, ${grow});
      qa(".${id}-b").forEach(function (b, i) { tl.fromTo(b, { strokeDashoffset: 1 }, { strokeDashoffset: 0, duration: ${grow}, ease: "power2.out", immediateRender: false }, ${t} + (i % ${n}) * 0.06); });\n`;
    if (o.d != null) js += `      OUT(q("#${id}"), ${r3(Math.max(t + 0.3, end - 0.5))}, 0.5);\n`;
    return { [o.layer || "over"]: layer(id, inner, "opacity:0;"), js, sfx: o.sound === false ? [] : [sfx("sparkle", t, 0.2)] };
  } };

export default [morse, frost];
