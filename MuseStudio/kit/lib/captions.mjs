// Word-highlight captions for one chapter, as a sub-composition. Groups are built from the
// aligned words (chapter-local seconds); the DOM is generated at load from embedded data.
import { r3 } from "./base.mjs";

export function captionGroups(words, maxWords = 7) {
  const groups = [];
  let cur = [];
  const flush = () => { if (cur.length) groups.push(cur); cur = []; };
  for (let i = 0; i < words.length; i++) {
    const w = words[i];
    const prev = cur[cur.length - 1];
    // a long pause also breaks a group
    if (prev && w.start - prev.end > 0.6) flush();
    cur.push(w);
    const punct = /[.!?…:;]$/.test(w.text) || (/,$/.test(w.text) && cur.length >= 3);
    const tooLong = cur.map((x) => x.text).join(" ").length > 44;
    if (punct || cur.length >= maxWords || tooLong) flush();
  }
  flush();
  return groups.map((g, i) => {
    const next = groups[i + 1];
    const end = next ? Math.min(next[0].start, g.at(-1).end + 0.8) : g.at(-1).end + 0.5;
    return { s: r3(g[0].start), e: r3(Math.max(end, g.at(-1).end)), w: g.map((x) => [x.text, r3(x.start), r3(x.end)]) };
  });
}

export function captionsComposition(id, dur, groups) {
  return `<template id="${id}-template">
  <script src="https://cdn.jsdelivr.net/npm/gsap@3.14.2/dist/gsap.min.js"></script>
  <style>
    @font-face { font-family: "Inter"; src: url("assets/fonts/Inter-Variable.ttf") format("truetype"); font-weight: 100 900; font-style: normal; font-display: block; }
    #${id}-root { position: absolute; inset: 0; pointer-events: none; }
    .${id}-band { position: absolute; left: 0; right: 0; top: 900px; height: 180px; }
    .${id}-g { position: absolute; inset: 0; display: flex; align-items: center; justify-content: center; opacity: 0; }
    .${id}-pill { max-width: 82%; padding: 16px 38px 18px; background: #FFFFFF; border: 4px solid #000; box-shadow: 8px 8px 0 #000;
      display: flex; flex-wrap: wrap; justify-content: center; gap: 0.1em 0.3em;
      font-family: "Inter", sans-serif; font-weight: 900; text-transform: uppercase; font-size: 50px; line-height: 1.18; letter-spacing: -0.02em; }
    .${id}-w { display: inline-block; padding: 0 0.1em; color: #999990; }
  </style>
  <div id="${id}-root" data-composition-id="${id}" data-width="1920" data-height="1080" data-start="0" data-duration="${r3(dur)}">
    <div class="clip ${id}-band" id="${id}-band" data-start="0" data-duration="${r3(dur)}" data-track-index="0"></div>
  </div>
  <script>
    (function () {
      var ID = ${JSON.stringify(id)};
      var G = ${JSON.stringify(groups)};
      var root = document.querySelector('[data-composition-id="' + ID + '"]');
      var band = root.querySelector("#" + ID + "-band");
      var tl = gsap.timeline({ paused: true });
      for (var i = 0; i < G.length; i++) {
        var g = document.createElement("div"); g.className = ID + "-g";
        var p = document.createElement("div"); p.className = ID + "-pill"; g.appendChild(p);
        var spans = [];
        for (var k = 0; k < G[i].w.length; k++) {
          var s = document.createElement("span"); s.className = ID + "-w"; s.textContent = G[i].w[k][0]; p.appendChild(s); spans.push(s);
        }
        band.appendChild(g);
        tl.set(g, { opacity: 1 }, G[i].s);
        tl.set(g, { opacity: 0 }, G[i].e);
        for (var k2 = 0; k2 < spans.length; k2++) {
          var w = G[i].w[k2];
          tl.set(spans[k2], { color: "#000000", backgroundColor: "#F7CB46", boxShadow: "0 0 0 0.08em #F7CB46" }, w[1]);
          tl.set(spans[k2], { backgroundColor: "rgba(247,203,70,0)", boxShadow: "0 0 0 0 rgba(0,0,0,0)" }, Math.max(w[1] + 0.05, k2 + 1 < spans.length ? G[i].w[k2 + 1][1] : w[2]));
        }
      }
      tl.set({}, {}, ${r3(dur)});
      window.__timelines = window.__timelines || {};
      window.__timelines[ID] = tl;
    })();
  </script>
</template>
`;
}
