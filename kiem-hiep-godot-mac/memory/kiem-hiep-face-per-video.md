---
name: kiem-hiep-face-per-video
description: "teo-kiem-hiep: never one shared face for all episodes — each video gets its own character drawing (eyes, nose, face shape differ)"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 6378614a-3ea4-498a-a927-91ddf8252157
  modified: 2026-10-21T14:00:35.884Z
---

teo-kiem-hiep: do NOT put a single new face style into the shared engine (rig2) for every episode. Each video must have its own way of drawing characters — eyes, nose, face shape, etc. differ per video and are not shared/reused.

**Why:** User stopped the global apply of the moe anime face on 2026-10-21: "chỉ tạo cách vẽ cho từng video. mỗi video nhân vật phải khác nhau như mắt mũi gương mặt không dùng chung". Same anti-template spirit as [[kiem-hiep-creative]] and [[creative-frames]].

**How to apply:** Implemented 2026-10-21: each episode writes `<dir>/ve.mjs` (default export ve(p,o,kit) → head svg); build checks required ids and refuses same face within an episode, across sibling episodes (work/ve-fp.json), or copied from examples/ve-mau.mjs. See SKILL.md "Mặt riêng từng tập". Engine default face is only a fallback.
