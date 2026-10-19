// Effect slots of an episode, in screen order. Shared by plan.mjs (choose) and build.mjs (consume) so keys always match.
// key: "op" | "tr<k>" | "s<i>.cam" | "s<i>.b<j>" | "s<i>.b<j>.caption" | "s<i>.b<j>.impact" | "ed"
export const PLANNED = ["enter", "intro", "power", "attack", "react", "caption", "card", "stat"];

export function slots(tap) {
  const out = [];
  const fixed = (b) => (b.fx ? String(b.fx) : null);
  out.push({ key: "op", cat: "opener", fixed: tap.opener?.fx || null });
  const attacks = [];
  tap.scenes.forEach((sc, i) => {
    out.push({ key: `tr${i}`, cat: "transition", fixed: sc.transition || null });
    out.push({ key: `s${i}.cam`, cat: "camera", fixed: sc.camera || null });
    sc.beats.forEach((b, j) => {
      const k = `s${i}.b${j}`;
      if (String(b.do).startsWith("local:")) { out.push({ key: k, cat: "local", fixed: b.do }); return; }
      if (!PLANNED.includes(b.do)) return;
      if (b.do === "attack" && b.name) out.push({ key: `${k}.caption`, cat: "caption", fixed: null });
      const s = { key: k, cat: b.do, fixed: fixed(b) };
      // react: nạn nhân là phe chính hoặc còn được nhắc ở beat sau → cấm hiệu ứng làm biến mất khỏi khung
      if (b.do === "react") {
        const ids = [].concat(b.who);
        if (ids.some((id) => id === "teo" || tap.cast?.[id]?.side === "hero" || sc.beats.slice(j + 1).some((x) => [].concat(x.who, x.target).includes(id)))) s.keep = true;
        // tập chủ đề (có story.format): nhân vật kinh điển chỉ choáng/lùi, không nằm gục, không văng
        if (tap.story?.format) s.soft = true;
      }
      out.push(s);
      if (b.do === "attack") { if (b.finisher) s.finisher = true; attacks.push(s); out.push({ key: `${k}.impact`, cat: "impact", fixed: b.impact || null }); }
    });
  });
  out.push({ key: `tr${tap.scenes.length}`, cat: "transition", fixed: null });
  out.push({ key: "ed", cat: "ender", fixed: tap.ender?.fx || null });
  if (attacks.length && !attacks.some((s) => s.finisher)) attacks.at(-1).finisher = true; // chiêu kết liễu mặc định = chiêu cuối
  return out;
}
export const slotSignature = (tap) => slots(tap).map((s) => `${s.key}:${s.cat}:${s.fixed || ""}${s.keep ? ":k" : ""}${s.soft ? ":s" : ""}`).join("|");
