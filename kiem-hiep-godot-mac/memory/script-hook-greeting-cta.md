---
name: script-hook-greeting-cta
description: "Video Tèo script standard: per-script custom hook visual (≥40% frame, beat-synced, payoff), flexible lại-là-Tèo greeting with Tèo on screen, CTA mid + end in frame voice, no copied formulas"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 2c990956-bdd9-470c-b748-15c76345d134
  modified: 2026-10-20T12:21:52.981Z
---

Every Tèo video opens with a punchy hook (first line ≤12 words). A greeting containing "lại là Tèo" comes somewhere in the first ~60 s, worded in the voice of the episode's frame. It is no longer forced into scene 2. Subscribe CTA: one in the middle (`cta: true`, 25–75%) and one at the end, both worded in the frame's voice. Banned: the "ba câu hỏi. Một… Hai… Và ba" promise formula, and reusing the greeting/CTA/ending wording of the last 5 episodes. `make.mjs validate` flags all of this by comparing trigram similarity against `ideas/fx-history.json`.

Hook visuals (2026-10-21): each video gets its own hook designed from that script's most striking image. It is a custom-drawn scene by default: the main image fills ≥40% of the frame, every spoken beat changes the image, and it ends on a visual payoff. Its `creative.hook_visual` must differ from the last 3 episodes. The generic `type:"hook"` card template is only allowed when the story has no strong image. Tèo must be visible on screen when saying the greeting.

**Why:** On 2026-10-19 the user asked for hook + greeting + CTA. On 2026-10-20 they found that all 10 videos shared one skeleton and copied phrases, and asked for more creativity. On 2026-10-21 they rejected the generic hook (text cards + Tèo in a corner + a tiny lychee) on Nguyễn Trãi and asked for an impressive hook per video, built from its script. See [[creative-frames]].

**How to apply:** Follow video-teo SKILL.md sections 2b and 3, and run `node kit/fx-list.mjs` before writing. Still no chapter cards ([[no-chapter-cards]]).
