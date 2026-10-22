---
name: creative-frames
description: "Video Tèo anti-template rules (2026-10-20) — every episode picks a storytelling frame + Tèo voice_role + theme (old flat chibi chars since 2026-10-21), differing from the last 3–5 episodes"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 2c990956-bdd9-470c-b748-15c76345d134
  modified: 2026-10-20T12:21:59.380Z
---

On 2026-10-20 the user said the video-teo videos all followed the same template and asked for more creativity. (Anime characters were requested too, then reverted on 2026-10-21.) Every new episode must now:
- Pick a `creative.frame` from the 12-frame table in SKILL 2b (ngược thời gian, phiên toà, đếm ngược, song song, phỏng vấn, nhật ký, bản tin, phá án, nếu như, trò chơi, một vật, hành trình). The frame must not repeat any of the last 3 episodes.
- Pick a `creative.voice_role` for Tèo. It must not repeat either of the last 2 episodes. It changes only the wording; the TTS voice is always "Lóng" (user, 2026-10-20).
- Keep narrator scenes ≤20%. Tell the story in the frame's order, not birth → death.
- Set a `theme` (giay-do / o-ly / bang-den / noir / tron) and a `thumbnail.layout` (classic / split / closeup) that each differ from recent episodes.
- **Changed 2026-10-21:** the user asked to go back to the old character style. Draw with `scripts/gen-chars.template.mjs` (flat chibi). Do not use the anime generator or `narrator_style: "anime"`. See [[old-char-style]].

**Why:** All 10 videos had the same skeleton: a hook, a scene-2 greeting, the "3 questions" promise, a CTA at about 50%, and a 5-step ending. The flat chibi characters also looked the same from one video to the next.

**How to apply:** Before writing, run `node kit/fx-list.mjs` to get the CHỐNG LẶP table, and note in ideas/ "tập này khác 5 tập trước ở đâu". Related: [[script-hook-greeting-cta]], [[thumbnail-seo-standard]]. New production is currently off ([[continuous-video-production]]), so these rules apply once production is turned back on.
