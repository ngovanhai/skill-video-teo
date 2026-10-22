---
name: kiem-hiep-voice-long
description: Every teo-kiem-hiep episode is narrated with Tèo's VieNeu voice "Lóng" (scripts/voice.mjs before build.mjs) — user approved 2026-10-20
metadata:
  type: feedback
---

Every teo-kiem-hiep episode must have Tèo's voice-over, using the same VieNeu "Lóng" voice as the video-teo channel. The user approved the test sample on 2026-10-20: "Giọng ổn, dùng luôn cho các tập kiếm hiệp".

**Why:** the user wants one channel voice across all Tèo Kể videos ([[daily-long-video-pipeline]]).

**How to apply:**
- Order of steps: write tap.json, then `node <SKILL>/scripts/voice.mjs <dir>` (cached; `--dry` estimates the length), then build.mjs, then render.
- Lines in `say` beats get spoken, and so does narration in the `vo` field on any beat (card, stat, attack…). Each beat lasts as long as its real audio.
- Write lines of 10 words or more, because VieNeu rushes short lines.
- If build warns that a line has no voice, rerun voice.mjs.
- A 20-minute episode ([[kiem-hiep-video-20-phut]]) needs about 4,900 spoken words, roughly 16 minutes of TTS machine time. Run it in the background.
