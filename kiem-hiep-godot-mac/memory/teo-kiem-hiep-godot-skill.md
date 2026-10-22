---
name: teo-kiem-hiep-godot-skill
description: "Skill teo-kiem-hiep-godot — quy trình tập kiếm hiệp dựng Godot: new-tap (chỉ hạ tầng), gd-check, pack, data/history.json chống lặp (2026-10-21)"
metadata:
  node_type: memory
  type: project
  originSessionId: 24a76cfa-ae94-4ea6-8c8d-0e50c7a88801
  modified: 2026-10-21T15:28:20.204Z
---

Tập kiếm hiệp dựng bằng Godot theo skill `~/.claude/skills/teo-kiem-hiep-godot` (tạo 2026-10-21 theo yêu cầu người dùng).
- `new-tap.mjs` chỉ sinh hạ tầng (main.gd hợp đồng gd-render + xếp giờ theo voice.json); phim.gd là chỗ giữ có dấu CHUA_DUNG, tập tự viết hình.
- `gd-check.mjs` soát lời/giọng/DUR/story.json; `--log` ghi `data/history.json` sau bản cuối. `pack.mjs` ra youtube/ từ story.json seo.
- Chống khuôn chung: không chép font sẵn (story.font), chân mô tả YouTube tự viết (seo.chan), so history theo độ giống từ (≥60% lỗi), không gợi ý chép cấu trúc tap-01 (sửa 2026-10-21).
- Cảnh ra chưởng/đánh nhau trong tập: gọi skill chuong-2d cho từng chiêu (người dùng yêu cầu 2026-10-21), không tự viết chiêu.
- Ghép chiêu: `gd-chieu.mjs <tap> <id>` chép engine chuong-2d vào godot/chuong/, đổi project sang forward_plus (gl_compatibility lệch màu); phim.gd dùng `chuong/chieu.gd` (SubViewport, tua theo t, sfx qua engine.sfx_hook, gain -8 dB). Đã thử can_khon: khớp từng khung với render độc lập, --par khớp từng pixel (2026-10-21).
- gd-render --par: cắt đúng lưới khung + bỏ khung lặp khi quit của Movie Maker; main.gd mới phát tiếp đuôi sfx trước --from (tap-01 còn code sfx cũ).
- gd-voice / gd-mat / gd-render vẫn nằm ở teo-kiem-hiep/scripts (không chuyển).

**Why:** người dùng muốn skill riêng cho cách làm Godot, tách khỏi phần HyperFrames cũ.
**How to apply:** làm tập kiếm hiệp mới hoặc làm lại thì dùng skill này; luật nội dung vẫn đọc từ teo-kiem-hiep. Liên quan [[kiem-hiep-godot]], [[nhan-vat-chibi-skill]], [[kiem-hiep-creative]].
