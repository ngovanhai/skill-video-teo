// Hiệu ứng tự chế của tập này: một con rồng vàng uốn lượn bay ra từ lòng bàn tay rồi ngừng ngay trước mặt đối thủ (minh hoạ Hàng Long Thập Bát Chưởng).
// Quầng sáng = nét to mờ phía sau (${u}-g), KHÔNG dùng filter drop-shadow (làm render chậm gấp đôi).
export default {
  cat: "power",
  label: "Rồng vàng uốn lượn từ chưởng",
  run(ctx, b, t) {
    const a = ctx.actor(b.who), u = ctx.uid("rong"), th = ctx.theme, d = 2.4;
    const tg = b.target ? ctx.actor(b.target) : null;
    const dir = tg ? (tg.cx > a.cx ? 1 : -1) : ctx.pick([1, -1]);
    // đầu rồng (rộng 150) phải dừng trước mặt đối thủ; hai người quá gần thì cho rồng bay vòng trên đầu
    const gap = tg ? Math.abs(tg.cx - a.cx) - a.w * 0.35 - tg.w * 0.5 - 150 : 600;
    const high = gap < 300, len = high ? 420 : Math.min(760, gap);
    const amp = 70, y0 = high ? Math.min(a.top, tg?.top ?? a.top) - 150 : a.top + a.h * 0.42, x0 = a.cx + dir * a.w * 0.35;
    // thân rồng: sóng sin 2 nhịp, vẽ từ tay ra
    const seg = len / 4, body = `M0 0 C ${seg * 0.5} ${-amp}, ${seg * 1.5} ${-amp}, ${seg * 2} 0 S ${seg * 3.5} ${amp}, ${len} 0`;
    const head = `<svg viewBox="0 0 120 100" width="150" height="125" style="overflow:visible"><path d="M10 50 Q40 10 90 30 L118 46 L92 56 L112 74 Q70 92 30 76 Z" fill="#FFD23F" stroke="#111" stroke-width="6" stroke-linejoin="round"/><path d="M40 28 L30 0 M62 26 L66 -6" stroke="#111" stroke-width="7" stroke-linecap="round"/><circle cx="70" cy="44" r="7" fill="#111"/><path d="M96 62 Q120 90 104 104 M84 68 Q96 98 80 108" stroke="#C8372D" stroke-width="5" fill="none" stroke-linecap="round"/></svg>`;
    ctx.add("fx", `<div id="${u}" style="position:absolute;left:${x0}px;top:${y0}px;width:0;height:0;transform:scaleX(${dir})">
<svg style="position:absolute;left:0;top:${-amp - 40}px;overflow:visible" width="${len}" height="${amp * 2 + 80}"><g transform="translate(0 ${amp + 40})">
<path id="${u}-g" d="${body}" fill="none" stroke="${th.qi}" stroke-width="100" stroke-linecap="round" opacity=".3"/>
<path id="${u}-o" d="${body}" fill="none" stroke="#111" stroke-width="62" stroke-linecap="round"/>
<path id="${u}-b" d="${body}" fill="none" stroke="#FFD23F" stroke-width="48" stroke-linecap="round"/>
<path id="${u}-s" d="${body}" fill="none" stroke="#E3A21A" stroke-width="20" stroke-linecap="round"/></g></svg>
<div id="${u}-h" style="position:absolute;left:${len - 40}px;top:-62px;width:150px;height:125px;opacity:0;transform:scale(0)">${head}</div></div>`);
    ctx.js(`["${u}-g", "${u}-o", "${u}-b", "${u}-s"].forEach(DASHLEN);
POSE("${a.p}", "palm", ${t}, 0.25); BROW("${a.p}", ${t}, true);
DRAW(["#${u}-g", "#${u}-o", "#${u}-b", "#${u}-s"], ${t + 0.2}, 0.8, "power2.out");
POP("#${u}-h", ${t + 0.85});
tl.to("#${u}-h", { y: -14, duration: 0.3, yoyo: true, repeat: 3, ease: "sine.inOut" }, ${t + 1.1});
HIDE("#${u}", ${t + d - 0.4}, 0.4);
POSE("${a.p}", "guard", ${t + d - 0.3}, 0.3);`);
    ctx.sfx("whoosh-cinematic", t + 0.15, 0.4); ctx.sfx("impact-bass-2", t + 0.9, 0.35);
    return { dur: d };
  },
};
