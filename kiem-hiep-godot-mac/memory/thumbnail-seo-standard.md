---
name: thumbnail-seo-standard
description: Every video needs a polished YouTube thumbnail (checked visually) and SEO-standard titles
metadata:
  node_type: memory
  type: feedback
  originSessionId: c6ea2a7d-1f6d-48c9-a28c-f9d5c8ebb7ba
  modified: 2026-10-19T13:19:11.746Z
---

User (2026-10-19): mỗi video phải có ảnh thumbnail để up YouTube, title chuẩn SEO, thumbnail chuẩn và đẹp.

**Why:** videos are uploaded to YouTube by the user; CTR depends on thumb + title.

**How to apply:**
- Run `--stage thumb` early (it's independent of render, ~10 s) and READ thumbnail.png; iterate params in video.json (don't edit kit/).
- Check: 1280×720, hook text 2 balanced lines (pick wording so line break reads naturally), prop circle (`circle_x/circle_y/circle_r`) must not cover any face — park it in empty left-middle area (~x320,y345,r240 when 2 chars), `arrow:false` if it points at nothing meaningful, text doesn't touch the circle.
- `badge` must be ONE character ("?", "!", "0") — kit renders it at 140px in a 170px circle; "11 km" overflowed onto a face (Mariana). Put numbers in text/sub instead.
- Titles: main keyword at the very start, ≤60 chars (no truncation), curiosity hook, Title Case-ish; thumbnail text must differ from titles.
- 2026-10-19 user asked for a fixed channel signature ("dấu ấn nhất định") + curiosity titles + a per-video upload folder: every title ends "| Tèo Kể" (so body ≤51 chars), #TeoKe first hashtag, fixed description footer; pack built by skill script youtube-pack.mjs into videos/<slug>/youtube/ (see skill section 6b).
- Related: [[daily-long-video-pipeline]], [[continuous-video-production]]
