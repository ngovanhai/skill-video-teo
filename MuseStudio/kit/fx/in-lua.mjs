// `in-lua`: vệt in lụa — thanh gạt mực (squeegee) quét ngang khung, để lại một lớp màu mực trong suốt và lớp chấm tram
// loé lên rồi nhạt dần, như một lượt kéo mực in áp phích. Dùng cho chuyển ý, khẩu hiệu bật ra, "bản chính thức" in xong.
// Tham số: color (mặc định đỏ son #C62A1F), dir (right | left), strength (0..1, mặc định 0.35), dot (true/false). Không filter.
import { when, layer, sfx, r3 } from "./_util.mjs";

const inLua = { id: "in-lua", cat: "accent", label: "Vệt in lụa: thanh gạt quét ngang để lại lớp mực + chấm tram nhạt dần (color, dir, strength, dot)",
  run(ctx, o) {
    const { t } = when(ctx, o, 0.15);
    const id = ctx.id, c = o.color || "#C62A1F", k = o.strength ?? 0.35, left = o.dir === "left";
    const inner = `<div id="${id}-wa" style="position:absolute;top:0;${left ? "right" : "left"}:0;width:0;height:880px;background:${c};opacity:${k};"></div>
      ${o.dot === false ? "" : `<div id="${id}-dt" style="position:absolute;left:0;top:0;width:1920px;height:880px;background-image:radial-gradient(circle, ${c} 30%, rgba(0,0,0,0) 34%);background-size:20px 20px;opacity:0;"></div>`}
      <div id="${id}-sq" style="position:absolute;top:-20px;left:${left ? 1920 : -40}px;width:40px;height:920px;background:linear-gradient(90deg, #1B1816 0%, #3A3430 50%, #1B1816 100%);border-radius:8px;opacity:0;"></div>`;
    const d = 0.55;
    let js = `      tl.set(q("#${id}-sq"), { opacity: 1 }, ${t});
      tl.fromTo(q("#${id}-sq"), { x: 0 }, { x: ${left ? -1960 : 1960}, duration: ${d}, ease: "power1.inOut", immediateRender: false }, ${t});
      tl.set(q("#${id}-sq"), { opacity: 0 }, ${r3(t + d)});
      tl.fromTo(q("#${id}-wa"), { width: 0 }, { width: 1920, duration: ${d}, ease: "power1.inOut", immediateRender: false }, ${t});
      tl.to(q("#${id}-wa"), { opacity: 0, duration: 0.8, ease: "power1.out" }, ${r3(t + d)});\n`;
    if (o.dot !== false) js += `      tl.fromTo(q("#${id}-dt"), { opacity: 0 }, { opacity: ${r3(k * 0.8)}, duration: 0.2, ease: "none", immediateRender: false }, ${r3(t + d * 0.6)});
      tl.to(q("#${id}-dt"), { opacity: 0, duration: 0.9, ease: "power1.out" }, ${r3(t + d + 0.1)});\n`;
    return { over: layer(id, inner), js, sfx: o.sound === false ? [] : [sfx("whooshShort", t, 0.15)] };
  } };

export default inLua;
