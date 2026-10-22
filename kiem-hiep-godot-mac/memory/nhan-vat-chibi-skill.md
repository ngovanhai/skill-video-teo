---
name: nhan-vat-chibi-skill
description: Nhân vật chibi rig2 tạo bằng skill nhan-vat-chibi; sổ chung data/chars.json dùng cho chuong-2d và teo-kiem-hiep (cast {"char": id})
metadata:
  type: project
---

Skill `nhan-vat-chibi` được dựng ngày 2026-10-21 theo yêu cầu người dùng: tả nhân vật bằng lời, ra preset, xuất ảnh chibi kèm sheet biểu cảm để soi.

- **Sổ nhân vật:** `~/.claude/skills/nhan-vat-chibi/data/chars.json` là nguồn duy nhất.
  - `chuong-2d/engine/tools/export-chars.mjs` đọc thẳng sổ này.
  - teo-kiem-hiep `build.mjs` (rig 2) nhận cast `{"char": id}`.
- **Lệnh:** `scripts/char.mjs sheet <id>` ra `work/<id>.png`; `scripts/char.mjs lineup <id…>` để so nhiều nhân vật đứng cạnh nhau.

**Why:** Người dùng muốn tạo nhân vật chuẩn, có ảnh soi, dùng chung giữa clip chưởng và video kiếm hiệp. Kiểu vẽ phải giữ chibi rig2, xem [[old-char-style]] và [[chuong-2d-skill]].

**How to apply:**
- Khi cần nhân vật mới thì gọi skill `nhan-vat-chibi`, rồi soi sheet theo checklist trước khi đưa vào engine.
- Không thêm `CHARS` trực tiếp vào `export-chars.mjs` nữa.
