---
name: thao-tac-chibi-skill
description: "Skill thao-tac-chibi — sổ động tác + engine chibi rig v2/vật phẩm (từ lab canh-chibi), truyện sau chọn thao tác theo kịch bản (2026-10-22)"
metadata:
  node_type: memory
  type: project
  originSessionId: 24a76cfa-ae94-4ea6-8c8d-0e50c7a88801
  modified: 2026-10-21T17:55:56.586Z
---

User muốn lưu lại các thao tác và cách vẽ đã làm ở lab `kiem-hiep/_lab/canh-chibi` để truyện sau dùng lại theo kịch bản, hoặc làm thao tác mới. Skill được tạo ngày 2026-10-22.
- Nội dung: `~/.claude/skills/thao-tac-chibi/`.
  - `engine/`: bản chép canh.gd, chibi.gd và 10 cảnh mẫu.
  - `data/thao-tac.md`: sổ id + công thức + bài học.
  - `scripts/`: new-project.sh, new-canh.sh, check.sh.
- teo-kiem-hiep-godot SKILL.md đã trỏ sang skill này cho phần diễn xuất.

**Why:** tránh làm lại tay chân, dáng đi, vật phẩm cho mỗi truyện; tích luỹ dần thư viện động tác.
**How to apply:** truyện/tập mới thì bóc kịch bản ra nhịp, tra sổ rồi ghép. Thao tác mới đạt sheet thì ghi thêm vào sổ. Sửa khả năng chung ở engine của skill, không sửa lab. Mặt, nét, nền vẫn riêng từng tập ([[kiem-hiep-face-per-video]], [[kiem-hiep-luon-chibi]]). Chiêu chưởng vẫn làm bằng [[chuong-2d-skill]].
