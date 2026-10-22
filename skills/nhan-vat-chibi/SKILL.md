---
name: nhan-vat-chibi
description: >-
  Tạo nhân vật chibi (rig2) từ mô tả bằng lời: viết look vào sổ nhân vật chung, xuất sheet soi
  (toàn thân, 5 tư thế, 9 biểu cảm, thử 5 nền) và ảnh xếp hàng so dáng. Một sổ dùng cho cả chuong-2d
  (clip chưởng Godot) và teo-kiem-hiep (cast {"char": id}). Dùng khi người dùng nói "tạo nhân vật",
  "vẽ nhân vật", "thêm nhân vật X", "nhân vật trông thế nào", "sửa áo/tóc/râu của X".
---

# Nhân vật chibi: tả bằng lời → look → sheet soi → dùng ở mọi engine

`SKILL = thư mục chứa file này`
- Sổ nhân vật: `SKILL/data/chars.json`, nguồn duy nhất cho mọi engine.
- Bộ vẽ: `~/.claude/skills/teo-kiem-hiep/engine/rig2.mjs`, kiểu chibi phẳng mặt anime. Skill này không sửa rig2.
- Lệnh: `node SKILL/scripts/char.mjs <kit|list|look|sheet|lineup>`. Code ngoài lấy look qua `lookOf(id)` trong `scripts/lib.mjs`.

## Quy trình

1. **Đọc mô tả, tra truyện.** Tìm thân phận, tuổi, môn phái, tính cách và ngoại hình truyện tả (áo, tóc, râu, vũ khí).
   Với kiếm hiệp, xem thêm "ngoại hình gợi ý" trong `teo-kiem-hiep/data/chu-de.md`. Không vẽ giống diễn viên phim.
2. **Kiểm sổ.** Chạy `node SKILL/scripts/char.mjs list`.
   - Nhân vật đã có thì sửa entry cũ, không tạo trùng.
   - id viết không dấu, nối gạch: `diet-tuyet`.
3. **Phối look** theo bảng bên dưới. Thêm entry vào `data/chars.json`:
   `"id": { "name", "truyen", "note" (một dòng ngoại hình), "look": { "preset"?: …, …ghi đè } }`
   Chạy `char.mjs kit` để xem đủ giá trị hợp lệ.
4. **Xuất sheet:** `node SKILL/scripts/char.mjs sheet <id>`, rồi mở `SKILL/work/<id>.png` soi theo **Checklist**. Sửa và chạy lại đến khi đạt.
   - Nhân vật sẽ đứng cạnh người khác thì chạy thêm `char.mjs lineup <id> <id2> …` (ra `work/lineup.png`) để chắc hai bên khác nhau rõ.
   - Có mặt riêng (`ve.mjs` của tập teo-kiem-hiep) thì thêm `--ve <file>`.
5. **Dùng.** Xem mục "Dùng ở engine". Cho người dùng xem ảnh sheet khi nhân vật là yêu cầu chính.

## Bảng quy đổi mô tả → look

| mô tả | look |
|---|---|
| sư / hòa thượng / quốc sư | `preset: tang` (đầu trọc, chấm giới, cà sa + `sash`); đổi `robe` theo phe |
| đạo sĩ / chân nhân | `dao-si` (búi cao + trâm) |
| công tử / thiếu hiệp áo trắng | `cong-tu` |
| thư sinh | `thu-sinh` (khăn, quạt) |
| nữ hiệp / sư thái / cô nương | `nu-hiep` (`skirt`, tóc đuôi ngựa); ni cô: `hair troc` + `hat` trống, áo xám |
| sư phụ già hiền | `su-phu` (tóc bạc, râu dài trắng, `age: gia`) |
| lão ma / phản diện già | `lao-quai` |
| ăn mày / Cái Bang | `cai-bang` |
| cao thủ áo đen / sát thủ | `cao-thu` |
| lính / quan binh | `linh` |
| chủ quán / thương nhân | `chuong-quy` |
| đại hán / hảo hán | tự phối: `bui-toi` + `rau-de` + `band` (khăn trán), da `vang` |
| quái nhân / da tái | da `sang`, mắt lam lạnh, tóc `re-ngoi` |

- **Tuổi.** Già: `age: "gia"`, tóc và râu xám `#9A9A9A` hoặc trắng `#DADADA`. Trẻ: không râu, tóc đen.
- **Tính cách qua mắt.** Mắt là chỗ duy nhất đổi màu tự do.
  - Gian, độc: đỏ hoặc tím `#B02A3A`, `#7A2A8A`.
  - Hiền: nâu hoặc lục.
  - Lạnh: lam `#4A8BE0`.
  - Chính khí: nâu đậm.
- **Màu áo.**
  - Theo truyện, ví dụ Minh giáo đỏ trắng, Toàn Chân lam, Thiếu Lâm vàng.
  - Áo `robe` và cổ áo `robe2` nên tương phản sáng tối.
  - `pants` tối hơn áo.
  - `belt`, `sash` là màu nhấn, nên cùng tông với chiêu hoặc phe.
- **Vũ khí.** Clip chưởng và chiêu tay không dùng `weapon: "none"`. Kiếm khách dùng `kiem`, đao khách `dao`, đeo lưng thì thêm `sheath: true`.

## Checklist soi sheet

- [ ] Nhận ra thân phận trong một cái nhìn: sư trọc, đạo sĩ búi cao, nữ có váy…
- [ ] Có ít nhất một nét riêng (khăn trán, dải chéo, râu, màu mắt, vũ khí). Đặt cạnh nhân vật cùng preset trong `lineup` vẫn phân biệt được.
- [ ] Hàng thử nền: không bị chìm ở ít nhất 3/5 nền. Nếu chìm đúng nền sẽ dùng (vd áo tối trên nền đêm) thì đổi `robe` sáng hơn, hoặc ghi chú để engine chọn nền khác.
- [ ] 9 biểu cảm đọc được; râu, mũ, tóc không che mắt hay miệng.
- [ ] 5 tư thế không vỡ khớp; vũ khí (nếu có) theo tay `F`.
- [ ] Màu áo, màu mắt hợp truyện và tính cách; không trùng hệt phối màu của nhân vật khác trong sổ.

## Dùng ở engine

- **chuong-2d (Godot):** `node tools/export-chars.mjs <id>` trong `chuong-2d/engine` đọc thẳng `data/chars.json`, ra `chars/<id>.json`.
- **teo-kiem-hiep (rig 2):** trong `cast` của tap.json ghi `"x": { "char": "<id>", "name": "…" }`.
  build.mjs lấy nguyên look từ sổ (giữ cả robe2, pants, band, beardColor). Các khoá khác ghi cạnh `char` sẽ ghi đè lên look.
  Mặt riêng của tập (ve.mjs) vẫn áp lên như cũ.
