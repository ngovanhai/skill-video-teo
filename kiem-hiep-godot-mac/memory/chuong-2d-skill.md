---
name: chuong-2d-skill
description: "Mọi clip hiệu ứng chiêu/chưởng Godot 2D làm qua skill chuong-2d (engine chuẩn ở ~/.claude/skills/chuong-2d/engine, không phải .tmp)"
metadata:
  node_type: memory
  type: project
  originSessionId: 24a76cfa-ae94-4ea6-8c8d-0e50c7a88801
  modified: 2026-10-21T14:37:08.993Z
---

Chiêu thức / chưởng kiếm hiệp dạng Godot 2D làm bằng skill `chuong-2d`, dựng ngày 2026-10-21.
- Bản engine chuẩn nằm ở `~/.claude/skills/chuong-2d/engine`.
- `__MUSE_ROOT__/.tmp/godot-2d-chuong` chỉ là bản nháp cũ (4 chiêu đầu render ở đó).
- Mỗi chiêu theo rule trong SKILL.md: nhịp 5 đoạn, màu tương phản nền, cơ chế đặc trưng không trùng `data/moves.json`, SFX qua `cue()`/`sfx()`.
- Kiểm tra bằng `scripts/check.sh`.

**Why:** Người dùng muốn mỗi truyện có chiêu riêng nhưng lần sau vẫn chuẩn và đẹp như 4 chiêu đầu (Hàng Long, Lục Mạch, Hấp Tinh, Hàn Băng). Nhân vật chibi theo kiểu rig2, xem [[old-char-style]].

**How to apply:**
- Khi được yêu cầu làm chiêu mới thì gọi skill `chuong-2d`, tạo file bằng `new-move.sh`. Nhân vật tạo qua skill `nhan-vat-chibi` ([[nhan-vat-chibi-skill]]).
- Soi sheet theo checklist, xong thì ghi chiêu vào `data/moves.json`.
- Sửa engine ở bản trong skill, không sửa ở `.tmp`.
