---
name: shorts-doc-3-moi-video
description: "video-teo + teo-kiem-hiep-godot: ĐÃ BỎ Shorts (2026-10-29) — gói youtube/ chỉ cần video dài + thumbnail + tiêu đề + mô tả + tags"
metadata:
  node_type: memory
  type: feedback
  originSessionId: 0addfd6c-b27e-4b06-b33d-2be7099d5f5d
  modified: 2026-10-21T16:25:42.882Z
---

Mỗi video dài của video-teo phải kèm 3 short YouTube = 3 đoạn ấn tượng nhất, khác kiểu nhau, ≤60 s, hook ≤12 s.
Chủ kênh ban đầu nói "16:9" nhưng khi hỏi lại thì chọn **"render riêng ra dạng dọc"** → 1080×1920, cảnh dọc tự vẽ trong `videos/<slug>/shorts/scenes/`, chạy `<SKILL_DIR>/scripts/build-short.mjs`, gói ra `youtube/shorts/`.

> **ĐÃ BỎ (chủ kênh chốt 2026-10-29):** cả hai kênh không làm Shorts nữa — `min_shorts = 0`, `"tat_shorts": true`; gói `youtube/` chỉ cần video dài + thumbnail.png + tiêu đề + mô tả + tags. Phần dưới giữ làm lịch sử, không dùng nữa.

**Why:** Shorts phải dọc mới được xếp vào kệ Shorts; crop từ 16:9 mất hình/chữ.
**How to apply:** làm theo SKILL.md mục 6c sau khi xong gói 6b; mẫu đầu tiên ở `videos/tesla-roadster-2026/shorts/`. 
**Kiếm hiệp Godot (2026-10-22, chủ kênh: "thêm cả vào skill teo-kiem-hiep-godot"):** mỗi tập cũng 3 short; mỗi short là project Godot dọc riêng `<tap>/shorts/<NN-ten>/` tạo bằng `new-short.mjs`, rồi gd-voice/gd-check/gd-render/pack chạy thẳng trên thư mục short. Mục "Shorts dọc" trong SKILL.md; mẫu đầu: tap-01 `shorts/01-muoi-tam-chuong`. Liên quan [[teo-kiem-hiep-godot-skill]], [[visual-system-per-video]], [[thumbnail-seo-standard]].
