// Camera: moves #<ns>-fxcam (the scene and its back layer). One camera fx per scene, plus `punch` / `shake` accents.
import { when, sfx, r3 } from "./_util.mjs";

const CAM = (ctx) => `q("#${ctx.ns}-fxcam")`;
const origin = (o) => `${o.x ?? 50}% ${o.y ?? 45}%`;

const pushIn = { id: "push-in", cat: "camera", label: "Đẩy máy chậm vào (scale, x%, y% tâm)",
  run(ctx, o) {
    const { t, d } = when(ctx, o, 0);
    return { cam: true, js: `      tl.fromTo(${CAM(ctx)}, { scale: 1 }, { scale: ${o.scale ?? 1.16}, duration: ${d}, ease: "power1.inOut", transformOrigin: "${origin(o)}", immediateRender: false }, ${t});\n` };
  } };

const pullOut = { id: "pull-out", cat: "camera", label: "Kéo máy lùi ra, lộ toàn cảnh",
  run(ctx, o) {
    const { t, d } = when(ctx, o, 0);
    return { cam: true, css: `#${ctx.ns}-fxcam { transform: scale(${o.scale ?? 1.25}); transform-origin: ${origin(o)}; }`,
      js: `      tl.fromTo(${CAM(ctx)}, { scale: ${o.scale ?? 1.25} }, { scale: 1, duration: ${r3(Math.min(d, o.len ?? 2.4))}, ease: "power2.out", transformOrigin: "${origin(o)}" }, ${t});\n` };
  } };

const pan = { id: "pan", cat: "camera", label: "Lia máy ngang (dx px, dir: left/right)",
  run(ctx, o) {
    const { t, d } = when(ctx, o, 0);
    const dx = (o.dx ?? 110) * (o.dir === "left" ? -1 : 1);
    return { cam: true, css: `#${ctx.ns}-fxcam { transform: scale(1.08) translateX(${-dx}px); }`,
      js: `      tl.fromTo(${CAM(ctx)}, { scale: 1.08, x: ${-dx} }, { scale: 1.08, x: ${dx}, duration: ${d}, ease: "sine.inOut" }, ${t});\n` };
  } };

const dutch = { id: "dutch", cat: "camera", label: "Nghiêng khung (deg) — bất an, có chuyện",
  run(ctx, o) {
    const { t } = when(ctx, o, 0.3);
    return { cam: true, js: `      tl.to(${CAM(ctx)}, { rotation: ${o.deg ?? -4}, scale: 1.07, duration: 0.6, ease: "back.out(1.6)" }, ${t});\n`, sfx: [sfx("whooshShort", t, 0.25)] };
  } };

const punch = { id: "punch", cat: "camera", label: "Giật zoom nhanh + rung (nhấn mạnh một chữ)",
  run(ctx, o) {
    const { t } = when(ctx, o, 0.3);
    return { cam: true, js: `      tl.to(${CAM(ctx)}, { scale: ${o.scale ?? 1.18}, duration: 0.1, ease: "power3.out", transformOrigin: "${origin(o)}" }, ${t});
      tl.to(${CAM(ctx)}, { scale: 1, duration: 0.45, ease: "power2.out" }, ${r3(t + 0.12)});
      SHAKE(${CAM(ctx)}, ${r3(t + 0.08)}, ${o.amp ?? 12});\n`, sfx: o.sound === false ? [] : [sfx(o.sound || "impact", t, 0.4)] };
  } };

const handheld = { id: "handheld", cat: "camera", label: "Máy cầm tay rung nhẹ liên tục (phóng sự, hồi hộp)",
  run(ctx, o) {
    const { t, end } = when(ctx, o, 0);
    const a = o.amp ?? 6;
    let js = `      tl.set(${CAM(ctx)}, { scale: 1.04 }, ${t});\n`;
    for (let k = 0, tt = t; tt < end - 0.5; k++, tt = r3(tt + 0.55))
      js += `      tl.to(${CAM(ctx)}, { x: ${r3(Math.sin(k * 1.7) * a)}, y: ${r3(Math.cos(k * 2.3) * a * 0.7)}, rotation: ${r3(Math.sin(k * 1.1) * 0.5)}, duration: 0.55, ease: "sine.inOut" }, ${tt});\n`;
    return { cam: true, js };
  } };

const whip = { id: "whip", cat: "camera", label: "Lia vụt vào cảnh, nhoè chuyển động (dir: left/right)",
  run(ctx, o) {
    const { t } = when(ctx, o, 0);
    const dx = o.dir === "right" ? -700 : 700;
    return { cam: true, css: `#${ctx.ns}-fxcam { opacity: 0; }`,
      js: `      tl.fromTo(${CAM(ctx)}, { x: ${dx}, opacity: 0, filter: "blur(24px)" }, { x: 0, opacity: 1, filter: "blur(0px)", duration: 0.38, ease: "power3.out" }, ${t});\n`,
      sfx: [sfx("whoosh", t, 0.35)] };
  } };

export default [pushIn, pullOut, pan, dutch, punch, handheld, whip];
