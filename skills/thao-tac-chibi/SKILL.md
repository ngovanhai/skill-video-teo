---
name: thao-tac-chibi
description: Dựng cảnh truyện 2D bằng Godot với nhân vật chibi rig v2 (tay chân cong liền, bàn tay 4 dạng, vạt áo mềm, đi 4 nhịp) và hệ vật phẩm tách rời (kiếm/vỏ, ô, đèn lồng, hồ lô). Dùng khi làm truyện/tập mới cần nhân vật đi, nói, thế võ, rút kiếm, chém, cầm ô, uống rượu, cầm đèn… — tra sổ thao tác, ghép theo kịch bản, thiếu thì thiết kế thao tác mới rồi ghi sổ.
---

# Thao tác chibi: sổ động tác + cách vẽ dùng lại cho mọi truyện

`SKILL = thư mục chứa file này`

| Mục | Ở đâu |
|---|---|
| Engine (dự án Godot) | `SKILL/engine/` (gồm `canh.gd` cho nền, hạt và vật phẩm; `chibi.gd` cho rig v2; `main.gd`; `rec.gd`) |
| Sổ thao tác | `SKILL/data/thao-tac.md`: id, công thức, cảnh mẫu, bài học |
| Cảnh mẫu | `SKILL/engine/canh/*.gd` |

Godot: `E:/tool/Godot/Godot_v4.7.2-stable_win64_console.exe`. Lab gốc nơi phát triển: `__MUSE_ROOT__/kiem-hiep/_lab/canh-chibi`.

## Quy trình

1. **Bóc kịch bản ra nhịp.** Mỗi câu hoặc hành động thành một dòng: `t0–t1 · ai · làm gì · vật gì · cảm xúc`.
2. **Tra sổ.** Đọc `data/thao-tac.md` và gán mỗi nhịp một id có sẵn (vd `di`, `noi`, `rut_kiem`, `chem_hat`, `cam_o_mua`, `ngoai_lai`).
   - Có id thì chép công thức, chỉnh thời gian, điểm và màu theo cảnh.
   - **Chưa có** thì thiết kế thao tác mới (xem mục bên dưới), thử riêng, đạt thì **ghi thêm vào sổ** theo đúng khuôn.
3. **Dự án.**
   - Thử nhanh: làm thẳng trong `SKILL/engine`.
   - Truyện hoặc tập thật: `bash SKILL/scripts/new-project.sh <thư mục>`, chép engine sang để không đụng bản gốc. Các lệnh sau thêm `ENGINE=<thư mục>`.
4. **Cảnh.** `bash SKILL/scripts/new-canh.sh <id> "mô tả"` tạo `canh/<id>.gd` từ `_mau.gd`. Có thể `extends` một cảnh mẫu để kế thừa nền (vd `extends "res://canh/rung_truc.gd"`), nhưng nền của truyện mới nên vẽ lại cho hợp.
5. **Kiểm.** `bash SKILL/scripts/check.sh <id> [số khung] [mốc giây…]` chạy lần lượt:
   - check-only
   - render ra `work/<id>.mp4`
   - xuất sheet `work/sheet_<id>.jpg` (6 mốc đều nhau hoặc mốc truyền vào; nên đặt mốc đúng các khoảnh khắc thao tác)

   Mở sheet, soi theo checklist, sửa đến khi đạt.

## Khung một cảnh (`extends "res://canh.gd"`)

| Hàm | Làm gì |
|---|---|
| `_palette()` | Màu và thông số cảnh: `sky_top`, `sky_bot`, `haze`, `ink`, `char_tint`, `ground_y`, `wind_base`, `wind_gust`, `vign_a`, `caption` |
| `_build()` | Tạo nhân vật bằng `actor(id, pos, face)` và vật phẩm bằng `prop(...)`; sinh dữ liệu nền bằng `rng` (seed 2026, tất định) |
| `_story(dt)` | Diễn theo `t` (giây; chạy trước 6 s để hạt và vạt áo ổn định; `t < 0` là đang chạy trước) |
| `_cam()` | Trả `[tâm, zoom]` |

Các lớp vẽ:

| Lớp | Parallax / blend |
|---|---|
| `_sky` | 0.02 |
| `_far` | 0.15 |
| `_mid` | 0.4 |
| `_back` | 0.7 |
| `_ground` | 1.0 (cùng lớp nhân vật) |
| `_near` | 1.0, vẽ trước nhân vật |
| `_glow` | blend cộng; kênh > 1 thì bloom ăn |
| `_front` | 1.3 |

Bộ vẽ có sẵn:
- Hình: `vgrad`, `blob`, `flat_blob`, `shape`, `round_pts`, `puff`, `cloud`, `clip_fill`
- Cây cỏ: `leaf`, `maple`, `tree`, `pine`, `bamboo`, `grass`
- Cảnh vật: `house`, `lantern`, `mountain_pts`, `bird`, `rays`, `flag`
- Màu: `inkof` (màu viền), `air` (màu xa theo không khí)

Nhân vật lấy từ `engine/chars/<id>.json`. Nhân vật mới thì tạo bằng skill **nhan-vat-chibi**, xuất qua `chuong-2d/engine/tools/export-chars.mjs <id>`, rồi chép file json vào `chars/`.

## Thiết kế thao tác mới (khi sổ không có)

1. Tả động tác thành 3–5 khoá:
   - pose (dict khớp)
   - điểm tay `hold`
   - trạng thái vật (`at`, `lock`, `grip`…)
   - biểu cảm
2. Dựng bằng thứ đã có, theo thứ tự ưu tiên:
   1. pha pose có sẵn
   2. dict khớp riêng (hằng ở đầu file như `WIND`, `RISE`)
   3. `hold` IK
   4. thông số vật

   Chỉ sửa `canh.gd`/`chibi.gd` khi cần một **khả năng chung** (vật phẩm kiểu mới, dạng tay mới, hạt mới). Sửa ở `SKILL/engine` để truyện sau cũng có, sau đó chạy lại vài cảnh mẫu để chắc không vỡ.
3. Soi sheet từng khoá: tay hoặc vật **không che mặt**, bàn chân không trượt, vật nằm trong tay đúng hướng.
4. Ghi vào `data/thao-tac.md`: id, mô tả, công thức, cảnh mẫu, bài học.

## Ranh giới với các skill khác

- **teo-kiem-hiep-godot** (tập kiếm hiệp): dùng skill này cho động tác, tư thế và vật phẩm. **Mặt, nét vẽ và hệ hình vẫn riêng từng tập** (không áp một kiểu mặt chung). Nền và bố cục không chép từ tập trước.
- **chuong-2d**: chiêu chưởng, hiệu ứng nội công, đối chưởng. Skill này lo diễn xuất đời thường và vũ khí cầm tay.
- **nhan-vat-chibi**: tạo hoặc sửa nhân vật (sổ `chars.json`).

## Checklist soi sheet

- [ ] Mỗi nhịp kịch bản đọc được trong 1 khung (tư thế rõ, biểu cảm đúng)
- [ ] Không tay hay vật phẩm nào che mặt quá 0.3 s
- [ ] Đi không trượt chân; dừng thì vạt áo lắc rồi lặng
- [ ] Vật cầm nằm giữa lòng bàn tay và ngón; đổi chỗ (hông ↔ tay) không giật
- [ ] Nhân vật tương phản với nền (cảnh đêm có `char_tint`, không chìm)
- [ ] Không có vệt trắng hoặc khối bloom cứng; đa giác không mất hình
