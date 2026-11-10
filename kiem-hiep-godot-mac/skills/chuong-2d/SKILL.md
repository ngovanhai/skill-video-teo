---
name: chuong-2d
description: >
  Làm clip hiệu ứng CHIÊU THỨC / CHƯỞNG PHÁP kiếm hiệp bằng Godot 2D (11–13 giây, 1920×1080, nhân vật chibi rig2 của teo-kiem-hiep),
  dùng chung một engine: tụ khí → biểu diễn cơ chế đặc trưng → đỉnh slowmo → đối thủ văng → tiêu đề. Mỗi chiêu một file moves/<id>.gd.
  Có bộ rule chuẩn về nhịp, màu, lớp vẽ, pose chibi, SFX, checklist soi và sổ chống trùng cơ chế (data/moves.json).
  Dùng khi người dùng nói "làm chiêu", "hiệu ứng chưởng", "chưởng Godot", "thêm chiêu <tên chiêu>", "Hàng Long / Lục Mạch / Hấp Tinh…",
  hoặc cần clip võ công minh hoạ cho truyện kiếm hiệp.
---

# Chưởng 2D: mỗi chiêu một file, chung engine, theo rule chuẩn

`SKILL = thư mục chứa file này` · Engine (dự án Godot): `SKILL/engine/` · Sổ chiêu: `SKILL/data/moves.json`
Godot: `__GODOT__` · Nhân vật: `engine/tools/export-chars.mjs` (rig2 của skill teo-kiem-hiep).

## Quy trình (làm đủ, không bỏ bước)

1. **Thẻ chiêu.** Tra truyện: ai dùng chiêu, đánh ai, truyện tả chiêu ra sao (hình ảnh, âm thanh, hậu quả). Viết 6 dòng:
   *người dùng · đối thủ hợp truyện · cơ chế đặc trưng · cặp màu · bối cảnh/thời tiết · khoảnh khắc đỉnh*.
2. **Chống trùng.** Đọc `data/moves.json`. Cơ chế đặc trưng, palette nền và kiểu kết **không được trùng** chiêu nào đã làm.
   Bố cục camera và kiểu đối thủ văng khác ít nhất 2 chiêu gần nhất.
3. **Nhân vật.** Dùng skill `nhan-vat-chibi`: nhân vật chưa có trong sổ `nhan-vat-chibi/data/chars.json` thì tạo theo skill đó (tả → look → sheet soi).
   Sau đó chạy `node tools/export-chars.mjs <id>` (đọc thẳng sổ) để ra `engine/chars/<id>.json`. Áo của người ra chiêu phải tương phản với nền (xem hàng thử nền trên sheet).
4. **Code.** `bash SKILL/scripts/new-move.sh <id> "<TÊN CHIÊU>"` chép `moves/_mau.gd` sang `moves/<id>.gd`.
   Điền theo các rule bên dưới. Chỉ sửa `engine.gd` khi cần một khả năng dùng chung (thêm helper, không sửa chiêu cũ vào engine).
5. **Kiểm tra.** `bash SKILL/scripts/check.sh <id> [số khung] [mốc giây…]` chạy lần lượt:
   - kiểm cú pháp → render
   - ghép SFX ra `renders/<id>.mp4`
   - xuất contact sheet `work/sheet_<id>.jpg`, gồm 8 mốc mặc định hoặc mốc truyền vào
   Mở ảnh sheet, soi theo **Checklist**, sửa rồi chạy lại đến khi đạt.
6. **Ghi sổ.** Thêm chiêu vào `data/moves.json`: id, chiêu, truyện, nhân vật, cơ chế, palette, kết, ngày.

## Rule 1: Nhịp 5 đoạn (thời gian truyện `t`, giây)

| đoạn | t | bắt buộc |
|---|---|---|
| Mở | 0–1.0 | Hai nhân vật đứng thế, cam rộng (zoom 1.0), gió/khí nhẹ. Biểu cảm `binh`/`gian`. |
| Tụ khí | 1.0–2.2 | Cam đẩy vào người ra chiêu (zoom 1.3–1.4); `gather`, hạt `orbit`, quầng sàn. SFX `lib-riser`. Biểu cảm `quyet-tam`. |
| Biểu diễn | 2.2–5.5 | **Cơ chế đặc trưng** chạy ≥2 nhịp. Mỗi nhịp có một tác động nhỏ (ring + burst + shake 10–14) và đối thủ phản ứng (guard / lùi / đổi màu). |
| Đỉnh | 5.5–7.5 | Đòn lớn và `slowmo = [rt0, rt1, 0.3]` dài 0.55–0.7 s thật, **bắt đầu ngay trước va chạm**. Flash 0.4–0.85, shake 20–40, 2 ring + burst lớn. SFX `whoosh-cinematic`, rồi `impact-bass-1` và `impact-bass-2` cùng lúc. |
| Hậu quả | 7.5–9 | Đối thủ văng theo cung (`rot → PI/2`, `hurt = 1`, biểu cảm `ko`), **đáp đất trong khung** (đứng bên phải thì x ≤ 1500). Khói đáp, `impact-bass-2` 0.5. |

- Tiêu đề `title_at` 8.1–8.9 (giây thật).
- Clip dài 11.5–13 s (345–390 khung), sau tiêu đề có ≥2 s tĩnh.
- Cam kết ở zoom 1.0, thấy cả hai nhân vật.
- Người ra chiêu kết bằng `dac-y` / `ngai` / `vui`.

## Rule 2: Màu

- Mỗi chiêu có một cặp `COL` (kênh 0.5–1.8) và `HOT` (có kênh > 1.5 để bloom ăn). Đối thủ dùng màu **tương phản**: lửa ↔ băng, tím ↔ vàng, đỏ ↔ lục.
- Nền (sky, far, near, ground) phải tương phản với áo người ra chiêu và khác palette nền 3 chiêu gần nhất. *Bài học Hấp Tinh:* áo xanh lục trên nền xanh lục thì nhân vật biến mất.
- `title_col` lấy theo tông `HOT`.

## Rule 3: Lớp vẽ

| móc | vẽ gì |
|---|---|
| `_fx_ground` | quầng sàn, vết nứt, sương lan (dùng `flat_blob`) |
| `_fx_back` | khí sau lưng nhân vật (engine đã vẽ aura và lưỡi lửa theo `f.aura`) |
| `_fx_norm` | **vật thể đặc**: băng, đá, khói, khối, tuyết, bóng tối (blend thường) |
| `_fx_add` | **ánh sáng**: tia, kiếm khí, chớp, quầng (blend cộng) |
| `_fx_ui` | chữ, vạch phủ màn hình |

Giới hạn:
- `blob` bán kính > 150 thì alpha ≤ 0.35.
- Không vẽ đường đặc dày > 10 px có kênh > 1 (bloom thành vệt trắng cứng). Vệt lóe dùng alpha ≤ 0.2.
- Hiệu ứng không che mặt nhân vật quá 0.5 s, trừ khoảnh khắc nổ.

## Rule 4: Nhân vật chibi

- **Tay chibi ngắn.** Hai người chạm chưởng thì giữ khoảng cách ≥ 150 px giữa hai bàn tay, đặt hiệu ứng (xoáy / va chạm) vào giữa. Tính x đối thủ theo vị trí tay, không cho thân chồng nhau.
- Pose dựng từ thanh trượt: `gather`, `push`, `crouch`, `lean`, `hurt`, `both` (1 = song chưởng).
- Pose riêng: `extra = [[tên pose hoặc dict khớp, trọng số]]`. Khớp tính bằng độ, dương = theo chiều kim đồng hồ, tay `F` là tay hướng về đối thủ. Pose có sẵn: rest, stance, charge, palm, point, raise, windup, slash, guard, fly, kneel, run.
- Biểu cảm có sẵn: vui, binh, gian, soc, quyet-tam, ko, dac-y, ngai.
  - Đối thủ: `gian` → `soc` (khi bị áp đảo) → `ko`.
- Gọi `pose(f, 0.0)` trong `_story` trước khi đọc `f.hand`, `f.handF`, `f.handB`, `f.head`.
- Đóng băng tư thế: `f.frozen = true`. Đổi màu bị ảnh hưởng: `f.tint`. Co người: `f.scale`.
- Tàn ảnh: thêm Chibi phụ vào `l_chars`, phát lại lịch sử pose (xem `han_bang.gd`).

## Rule 5: Cơ chế đặc trưng (linh hồn của chiêu)

Không chỉ "bắn một tia". Cơ chế phải dịch đúng mô tả trong truyện thành hình ảnh, và người xem đọc được trong 1 giây.

Đã dùng (không lặp):

| chiêu | cơ chế |
|---|---|
| hang_long | tụ khí rồng vàng, tia đối chưởng đẩy qua lại rồi nổ cầu năng lượng |
| luc_mach | kiếm khí mảnh đâm xuyên; chẻ đôi lửa địch; quạt 6 kiếm sau lưng phóng ra |
| hap_tinh | chạm tay, xoáy đen; nội lực chảy ngược về ngực; đối thủ xám và teo lại |
| han_bang | khinh công để lại tàn ảnh; liên hoàn 3 chưởng; cột băng lan, đóng băng rồi vỡ |
| can_khon | vòng bát quái bắt chưởng địch; hất trời / dập đất / xoay trả ngược; cầu đổi màu |
| doc_co | khoái đao liên hoàn, mỗi đao lộ dấu sơ hở; slowmo sơ hở bừng sáng; một nhát đâm thẳng, đao văng, đối thủ ngồi xuống |

Gợi ý cho chiêu sau:

| chiêu | cơ chế gợi ý |
|---|---|
| Nhất Dương Chỉ | một tia mảnh; huyệt đạo sáng lần lượt trên thân đối thủ |
| Thái Cực Quyền | vòng âm dương, mượn lực đổi hướng |
| Cửu Âm Bạch Cốt Trảo | bóng vuốt đen, 5 vệt cào |
| Độc Cô Cửu Kiếm | slowmo lộ điểm sơ hở, một nhát duy nhất |
| Tiểu Lý Phi Đao | không thấy đao, chỉ một lóe sáng và kết quả |
| Kim Cang Bất Hoại | khiên vàng, chưởng địch dội ngược |
| Sinh Tử Phù | phù băng mỏng găm vào huyệt |
| Ngũ Độc Chưởng | khói độc tím lục, mặt đất héo |
| Ảm Nhiên Tiêu Hồn Chưởng | mưa, màu nhạt dần, chưởng buồn và chậm |

## Rule 6: Âm thanh

Khai mốc trong `_setup` bằng `cue(t_truyện, "lib-…", vol)`. Ở chỗ sự kiện xảy ra động (va chạm, vỡ, đáp đất) thì gọi `sfx("lib-…", vol)`.
Engine tự đổi sang giây thật (đã tính slowmo) và ghi `work/<id>.sfx`; `mix.sh <id>` đọc file đó để ghép.

**Người dùng chốt (2026-10-24): không có tiếng "ùm ùm tùm tùm" gây giật mình, sfx luôn nhỏ hơn giọng đọc.** `engine/sfx` (và `kit/sfx`) là bản êm do `node ~/MuseStudio/kit/sfx-soft.mjs` làm từ `_goc/` (lọc trầm < 180 Hz, ≤ -26 LUFS, đỉnh ≤ -12 dBFS); `impact-bass-*` giờ chỉ còn tiếng "tộc" nhẹ. `mix.sh`, `gd-render` tự kẹp mỗi tiếng ≤ 0.6 và chặn đỉnh cả kênh -12 dBFS, nên vol trong bảng dưới cao hơn 0.6 cũng chỉ ra 0.6. Không thêm file sfx mới chưa qua `sfx-soft.mjs`.

| sự kiện | sfx |
|---|---|
| tụ khí | `lib-riser` 0.6–0.9 |
| lướt / phóng | `lib-whoosh` (`lib-whoosh-short` cho nhịp nhanh) 0.5–0.8 |
| phóng đòn lớn | `lib-whoosh-cinematic` 0.8–0.9 |
| va chạm nhỏ | `lib-impact-bass-2` 0.5–0.7 |
| va chạm lớn | `lib-impact-bass-1` + `lib-impact-bass-2` cùng lúc, 1.0 |
| nhịp năng lượng | `lib-glitch-1` 0.3–0.5 |
| băng / sao / lấp lánh | `lib-sparkle`, `lib-chime` 0.4 |
| đáp đất | `lib-impact-bass-2` 0.5 |

## Rule 7: Kỹ thuật

- Đọc giá trị từ dict thì khai kiểu rõ: `var x: float = f.gather` (`:=` với Variant gây parse error).
- Chạy tất định: chỉ dùng `t`/`rt`/`DT` và `rng` của engine (seed 2026). Không dùng thời gian hệ thống hay `randf()` toàn cục.
- Hạt: dùng `emit` / `burst` / `orbit` / `add_ring`, giữ ≤ khoảng 2000 hạt sống. Hạt kiểu riêng (vd `"shard"`) thì tự vẽ trong `_fx_add`.
- Render khoảng 16 s cho 345 khung; contact sheet là cách soi chính, không cần xem cả video mỗi lần sửa.

## Checklist soi sheet (đạt hết mới xong)

- [ ] Người ra chiêu và đối thủ luôn thấy rõ, màu tương phản với nền
- [ ] Cơ chế đặc trưng đọc được ở ít nhất 2 khung
- [ ] Đỉnh có slowmo, flash, ring, burst; không có vệt trắng cứng hay khối trắng phủ > 1/3 màn hình quá 0.3 s
- [ ] Hai thân không chồng nhau khi chạm chưởng
- [ ] Đối thủ đáp đất trong khung; tiêu đề không đè lên mặt nhân vật
- [ ] Biểu cảm đổi đúng nhịp (quyet-tam lúc tụ khí, soc / ko ở đối thủ)
- [ ] File `work/<id>.sfx` có đủ riser, whoosh, impact; `renders/<id>.mp4` có tiếng
- [ ] Không trùng cơ chế, palette nền, kiểu kết với `data/moves.json`
