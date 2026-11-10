---
name: kiem-hiep-voice-tiendat
description: Every teo-kiem-hiep episode is narrated by ZeroTTS voice "Tiến Đạt" ("tiendat") — user switched from VieNeu "Lóng" on 2026-11-03
metadata:
  type: feedback
---

Every teo-kiem-hiep episode must have Tèo's voice-over, read by **ZeroTTS** with the built-in voice **"Tiến Đạt"** (`"voice": "tiendat"`). VieNeu and the "Lóng" clone are gone (user, 2026-11-03): code and voices were switched over on that day, and `kit/_bak-zerotts-20261103/` keeps the old version for reference.

**Why:** the user wants one channel voice across all Tèo Kể videos ([[daily-long-video-pipeline]]), and ZeroTTS is the engine the kit now ships ([[colab-tts]]).

**How to apply:**
- Order of steps: write tap.json, then `node <SKILL>/scripts/voice.mjs <dir>` (cached; `--dry` estimates the length), then build.mjs, then render.
- Lines in `say` beats get spoken, and so does narration in the `vo` field on any beat (card, stat, attack…). Each beat lasts as long as its real audio.
- Write lines of 10 words or more; short lines sound rushed.
- If build warns that a line has no voice, rerun voice.mjs.
- A 20-minute episode ([[kiem-hiep-video-20-phut]]) needs about 4,900 spoken words. The long pass runs on Colab ([[colab-tts]]), short fixes run on the home CPU — run both in the background.
