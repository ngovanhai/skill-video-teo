---
name: no-chapter-cards
description: "Videos must play as one continuous story — no \"chapter\" scenes, never say \"Chương X\" / \"Chương sau nhé\""
metadata:
  node_type: memory
  type: feedback
  originSessionId: c6ea2a7d-1f6d-48c9-a28c-f9d5c8ebb7ba
  modified: 2026-10-18T19:44:52.329Z
---

Since 2026-10-19 the user doesn't want videos split into chapters on screen or in the narration: no `chapter`-type scenes, no spoken "Chương một…", "Chương sau nhé", "ở chương trước". Use transitions like "Tiếp theo…", "Xem tiếp nhé", "lúc nãy", "ở đầu video".

**Why:** the user wants one continuous video; chapter announcements made it feel cut up.
**How to apply:** chapters/*.json files are still fine for organizing the script (make.mjs merges them into one final.mp4). Ignore the validate warning "should open with a chapter scene". To strip cards from an already-TTS'd video without re-synthesizing everything, use videos/hai-ba-trung/work/drop-chapters.mjs, which renames the audio/words cache to the new ids. Related: [[daily-long-video-pipeline]].
