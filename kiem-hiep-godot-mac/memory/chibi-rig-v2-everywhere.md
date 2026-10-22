---
name: chibi-rig-v2-everywhere
description: Mọi cảnh chibi (kể cả chiêu chuong-2d) phải dùng tay chân rig v2 của thao-tac-chibi
metadata:
  type: feedback
---
Tay chân mới (rig v2: ống cong Chaikin, bàn tay 4 dạng, vạt áo mềm) trong `~/.claude/skills/thao-tac-chibi/engine/chibi.gd` phải dùng ở mọi nơi vẽ chibi, kể cả engine chuong-2d (trước 2026-10-22 chuong-2d còn chibi.gd v1 154 dòng).

**Why:** 2026-10-22 người dùng hỏi "sao k cập nhật phần vẽ chân tay mới" khi chiêu doc_co tập 10 làm bằng engine chuong-2d cũ.

**How to apply:** trước khi làm chiêu / cảnh chibi, so md5 chibi.gd của engine đang dùng với bản thao-tac-chibi; khác thì chép v2 đè (cùng API, cùng định dạng chars json). Liên quan [[chuong-2d-skill]], [[nhan-vat-chibi-skill]].
