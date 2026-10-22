---
name: teo-kiem-hiep-godot
description: >-
  Làm một tập Tèo Kể Kiếm Hiệp (≥20 phút, giọng Lóng) dựng toàn bộ bằng Godot 2D: research → kịch bản loi.txt →
  khung tự thiết kế → giọng → nhân vật (nhan-vat-chibi + ve.mjs) → phim.gd riêng của tập → soi sheet → render →
  nhạc, ảnh bìa, gói YouTube, rồi 3 Shorts dọc 1080×1920 (new-short). Có khung project (new-tap), bộ soát (gd-check) và sổ chống lặp hình thức.
  Dùng khi người dùng nói "làm tập kiếm hiệp Godot", "dựng tập bằng Godot", "tập kiếm hiệp mới", "làm lại tập N bằng Godot", "làm short cho tập kiếm hiệp".
---

# Tèo Kiếm Hiệp × Godot 2D: mỗi tập một kịch bản, một khung, một bộ code hình

`SKILL = thư mục chứa file này` · `KH = ~/.claude/skills/teo-kiem-hiep` · `LOCK = bash __MUSE_ROOT__/kiem-hiep/_tools/slot.sh`
Godot 4.7.2: `E:/tool/Godot/Godot_v4.7.2-stable_win64_console.exe` · Tập mẫu (chỉ đọc để học): `kiem-hiep/tap-01-tieu-phong-vs-quach-tinh/godot/`

Skill này lo **quy trình Godot**. Luật nội dung vẫn là của `teo-kiem-hiep`, phải đọc và theo:
- mục "Luật cứng" (bản quyền, chính xác ≥2 nguồn, tôn trọng, ≥20 phút, không chia chương);
- mục "Quy trình một tập", bước 0 (research, chọn chủ đề từ `KH/data/chu-de.md`, 1 chủ đề chính + 4–6 chủ đề phụ);
- mục "Khung dựng" (kịch bản thô → phân tích → khung; mở đầu, kết, CTA).

Phần HyperFrames trong teo-kiem-hiep (tap.json beat, build.mjs, plan.mjs, fx local, pack.mjs) **không dùng** cho tập Godot.

## Công cụ

| lệnh | việc |
|---|---|
| `node SKILL/scripts/new-tap.mjs <tap> --ten "<khung>"` | Tạo `<tap>/godot/` chỉ gồm hạ tầng: project.godot, main.gd (hợp đồng + xếp giờ theo giọng + phát giọng/nhạc/sfx), phim.gd chỗ giữ, loi.txt/story.json/cast.json mẫu, sfx. Không chép font. Không ghi đè. |
| `LOCK "<tap> giọng" node KH/scripts/gd-voice.mjs <tap>` | `loi.txt` → `godot/voice/<id>.wav` + `voice.json` (độ dài thật). Có cache. `--dry` để ước thời lượng. |
| `node KH/scripts/gd-mat.mjs <tap>` | Mặt từng nhân vật bằng `<tap>/ve.mjs` → `godot/mat/<nv>/<biểu cảm>.svg`, đọc `godot/cast.json`. |
| `node SKILL/scripts/gd-chieu.mjs <tap> <id chiêu> [id …]` | Đưa chiêu đã làm xong bên `chuong-2d` (có trong `moves.json`) vào tập: chép engine + chiêu + nhân vật vào `godot/chuong/` (đổi đường `res://`), cầu nối `chuong/chieu.gd`, sfx thiếu; ghi `story.chieu`; đổi project sang renderer `forward_plus` (chiêu làm trên Forward+, gl_compatibility lệch màu). Sửa chiêu bên chuong-2d xong thì chạy lại. |
| `node SKILL/scripts/gd-check.mjs <tap>` | Soát: id, chữ "Chương", hook/Tèo/CTA, giọng khớp chữ, parse Godot, DUR ≥ 20:00, phim.gd đã dựng, story.json khác 5 tập trước, cast có trong sổ. `--no-godot` bỏ bước Godot. |
| `LOCK "<tap> xem" node KH/scripts/gd-render.mjs <tap> --preview --from A --to B --sheet 5 --out xa` | Preview 960×540 + `work/sheet-xa.jpg`. |
| `LOCK "<tap> render" node KH/scripts/gd-render.mjs <tap> --par 2` | Bản cuối `renders/final.mp4`. |
| `node SKILL/scripts/pack.mjs <tap>` | `youtube/`: mp4, thumbnail.png 1280×720, tieu-de, mo-ta (seo.mo_ta + seo.chan), tags. Không có chân mô tả cố định. |
| `node SKILL/scripts/gd-check.mjs <tap> --log` | Sau bản cuối: ghi story.json vào `SKILL/data/history.json`. |

Việc nặng (giọng, render) luôn chạy qua `LOCK`: máy chỉ có 2 suất. Lệnh dài chạy nền.

## Quy trình

1. **Research, chủ đề, kịch bản thô, phân tích, khung.** Làm đúng teo-kiem-hiep (bước 0 và mục "Khung dựng").
   Ghi `<tap>/kich-ban-tho.md` và `<tap>/y-tuong.md`: nguồn, 3 ý + điểm, phân tích 6 câu, khung, bảng dữ kiện, bảng "khác 5 tập trước".
   Đọc `SKILL/data/history.json` trước khi chọn khung: khung, vai Tèo, bút, máy quay, palette, nhạc, thumbnail, mặt, font, chân mô tả đều phải khác. gd-check so theo tỉ lệ từ chung: giống ≥60% là lỗi, ≥40% là cảnh báo; đổi thứ tự chữ hay thêm bớt một từ không qua được.
2. **Khung project:** `new-tap.mjs <tap> --ten "<tên khung>"`.
3. **Kịch bản `godot/loi.txt`.**
   - `## kNN tên | ghi chú dựng {pre=… post=…}` mở một đoạn; `[id] lời` là một câu Tèo đọc. Viết cả bài, mỗi câu một dòng.
   - 6–8 đoạn lớn, mỗi đoạn 2,5–4 phút; muốn cắt nhỏ để dựng thì chia thêm `## kNN` (tap-01 có 30 khung). Không thẻ chương, không nói "Chương".
   - Đoạn đầu là **hook**: dựng riêng cảnh đắt nhất của kịch bản, khớp nhịp, khớp chữ thumbnail. Tèo giới thiệu theo vai trong khoảng 60 s đầu.
   - CTA (đăng ký / bình luận) hai lần: một ở 25–75%, một ở cuối, nói bằng giọng của khung.
   - Chữ hiện trên hình (thẻ, bảng, chú thích) phải có câu đọc đi kèm.
   - Điền `godot/story.json`: khung, teo_role, but (bút / kiểu nét), may_quay, palette, nhac, thumb, mat, font; `doan` ghi kiểu dựng của từng đoạn (mỗi đoạn một kiểu: tranh, bản đồ, sân khấu bóng, sổ tay, bàn cờ…); `seo` (title, mo_ta, `chan` = chân mô tả viết theo giọng của khung, mời bình luận/đăng ký theo kiểu của tập, tags).
4. **Giọng:** `gd-voice` qua `LOCK`, giọng Lóng. Sau đó `gd-check --no-godot`: biết tổng thời lượng thật. Dưới 20:00 thì viết thêm lời (thêm chủ đề phụ hoặc chi tiết), không kéo dài khoảng lặng.
5. **Nhân vật.**
   - Look lấy từ skill `nhan-vat-chibi`: chưa có thì tạo bằng skill đó và soi sheet. `godot/cast.json`: `{"tieu": {"char": "tieu-phong", "name": "Tiêu Phong"}}`; khoá khác cạnh `char` sẽ ghi đè.
   - Mặt riêng của tập: viết `<tap>/ve.mjs` (mắt, mũi, khuôn mặt theo bút của tập, khác tập trước), rồi `gd-mat`.
   - Thân người tự vẽ trong GDScript theo nét của tập (tap-01: `nguoi.gd` vẽ nét bút lông). Nhiều hoạt ảnh cơ thể: đi, chỉ tay, ôm quyền, ngã ngồi, quay đầu.
   - **Nhân vật luôn là dạng chibi** (người dùng quyết định 2026-10-21, thay luật "tập tự chọn tỉ lệ" cũ): đầu to, thân ngắn khoảng 2–3 đầu, tay chân ngắn, mắt to. Tập vẫn tự chọn nét bút, mặt và chất liệu theo khung (chibi nét mực, chibi rối bóng, chibi tượng gỗ…), nhưng tỉ lệ luôn chibi; không vẽ tỉ lệ người thật. Look (màu áo, tóc, râu) lấy từ sổ `nhan-vat-chibi`.
6. **Code hình.** Thay hết `phim.gd` (xóa dấu `CHUA_DUNG`) và thêm các file vẽ riêng của tập.
   - main.gd gọi `phim.setup(main)` một lần (có `main.segs`, `main.lines`, `main.DUR`), `phim.at(t, seg, line)` mỗi khung, `phim.sfx()` → `[[giây, "whoosh", dB], …]`.
   - Cách chia file và cấu trúc code do tập tự chọn theo khung (một file cho cả phim, mỗi đoạn một file, theo lớp cảnh, theo nhân vật…). Không lấy cấu trúc của tập trước làm sẵn.
   - **Không chép code hình của tập trước**, chỉ đọc để học.
   - **Diễn xuất nhân vật (đi, nói, thế võ, rút kiếm, chém, cầm ô/đèn/hồ lô…): tra skill `thao-tac-chibi`** (`data/thao-tac.md` + engine rig v2) và dùng lại thao tác hợp kịch bản; thiếu thì thiết kế mới rồi ghi sổ bên đó. Mặt/nét/nền vẫn riêng từng tập.
   - **Cảnh ra chưởng / đánh nhau: gọi skill `chuong-2d`** (Skill tool) cho từng chiêu, làm đủ quy trình của skill đó: thẻ chiêu, chống trùng `data/moves.json`, rule nhịp 5 đoạn, màu, SFX, `check.sh` soi sheet đến khi đạt checklist, ghi sổ. Không tự viết chiêu ngoài skill. Chiêu chưa đạt checklist của chuong-2d thì chưa đưa vào tập. Xong thì `gd-chieu <tap> <id>` đưa vào tập (tự ghi `story.chieu`). Trong `phim.gd`:
     ```gdscript
     var ch = preload("res://chuong/chieu.gd").new("can_khon", 312.0)   # chiêu bắt đầu ở giây 312 của tập; tham số 3 = dài (mặc định 12.5 s)
     ch.vars = {"subtitle": "…"}   # (tuỳ) đè biến của chiêu; ch.gain_db chỉnh tiếng sfx của chiêu (mặc định -8 dB)
     add_child(ch)                  # trong setup()
     # sfx(): trả thêm ch.sfx()      at(t): if ch.at(t): draw_texture_rect(ch.tex(), khung, false)
     ```
     Chiêu chạy trong SubViewport riêng (HDR + glow của chuong-2d), `at(t)` tự tua đúng khung nên `--from`/`--par` cắt giữa chiêu vẫn khớp. Khung đặt chiêu (toàn màn, trong khung tranh, chuyển cảnh vào/ra) do tập tự dựng theo bút của mình. Nhớ để lời Tèo nhường chỗ cho đoạn đỉnh của chiêu.
   - Sửa `main.gd` được (ví dụ máy quay đi giữa các khung như tap-01), nhưng giữ hợp đồng ở dưới.
7. **Soát:** `gd-check <tap>` đến khi `OK`.
8. **Soi:** preview vài đoạn qua `LOCK` (chia 2 đoạn chạy song song nếu có 2 suất trống), mở `work/sheet-*.jpg` soi theo **Checklist**. Sửa rồi soi lại đúng đoạn đó.
9. **Nhạc:** tập tự sinh nhạc (`work/nhac.py` đọc `godot/timeline.json` để đổi tâm trạng theo khung). Ghi wav rồi `ffmpeg -c:a libvorbis` ra `godot/nhac.ogg` (soundfile ghi OGG dài bị tràn stack). Không dùng nhạc có bản quyền; khác kiểu nhạc tập trước.
10. **Bản cuối:** `gd-render --par 2` qua `LOCK`, chạy nền. Xem vài giây ở đầu, giữa, cuối bằng ffprobe/ảnh để chắc có hình và tiếng.
11. **Ảnh bìa:** `godot/thumb.tscn` + `thumb.gd` vẽ bằng chính bút của tập, chạy có cửa sổ (không `--headless`): `Godot --path godot thumb.tscn`, lưu `thumb/thumb-godot.png`. Mở ảnh soi: mặt không bị che, chữ to đọc được, khớp hook.
12. **Gói:** `pack.mjs <tap>`, đọc lại `youtube/thumbnail.png`. Rồi `gd-check <tap> --log` để ghi sổ, và thêm một dòng vào `__MUSE_ROOT__\ideas\DA-LAM.md` (mảng "Tèo kiếm hiệp"). Không đăng lên mạng.

13. **3 Shorts dọc** (mục dưới). Mỗi tập xong đều làm 3 short.

## Shorts dọc (3 short mỗi tập, 1080×1920, ≤ 60 s)

Mỗi short là **một project Godot dọc riêng** ở `<tap>/shorts/<NN-ten>/godot/`. Nó dùng lại bút, mặt, font, chiêu và giọng của tập, nhưng hình phải **dựng lại cho khung dọc**: không cắt, không crop từ bản ngang. Các lệnh gd-voice, gd-check, gd-render, pack chạy thẳng trên thư mục short (`S = <tap>/shorts/<NN-ten>`).

| lệnh | việc |
|---|---|
| `node SKILL/scripts/new-short.mjs <tap> <NN-ten> --tu kA-01..kB-05 [--tu …] [--nhac <giây>]` | Tạo `S/godot/` dọc 1080×1920. Chép font/, mat/, chuong/, sfx/, các file vẽ `.gd` của tập (trừ main/phim/thumb) và cast.json. Câu `--tu` vào `loi.txt` (đoạn `s02 than`) kèm wav và voice.json, nên không phải đọc lại. Có sẵn chỗ viết hook `s01` và kết `s03`. Thêm `story.json` (kieu, phu_de, seo), `phude.gd` (phụ đề 2–4 chữ, y≈1490) và `nhac.ogg` cắt 70 s từ nhạc tập (mặc định 10 s trước câu đầu). |
| `LOCK "<tap> sNN giọng" node KH/scripts/gd-voice.mjs S` | Chỉ đọc câu mới hoặc câu đã sửa chữ. |
| `node SKILL/scripts/gd-check.mjs S` | Chế độ short (tự nhận theo khung dọc). **Lỗi:** quá 60 s, thiếu "đăng ký" trong 30% cuối, kieu trống hoặc giống short khác của tập ≥60%, title quá 60 ký tự hoặc không kết "\| Tèo Kể", thiếu mo_ta. **Cảnh báo:** hook > 12 chữ, hook dài > 12 s, thiếu "Tèo Kể", dưới 20 s. Không dùng `--log`. |
| `LOCK "<tap> sNN xem" node KH/scripts/gd-render.mjs S --preview --sheet 2` | Preview 540×960 + `S/work/sheet-preview.jpg`. |
| `LOCK "<tap> sNN render" node KH/scripts/gd-render.mjs S` | `S/renders/final.mp4` 1080×1920. Short ngắn, không cần `--par`. |
| `node SKILL/scripts/pack.mjs S` | Kiểm 1080×1920, ra `<tap>/youtube/shorts/<NN-ten>.mp4` + `.txt` (tiêu đề `#Shorts`, mô tả + hashtag, tag, link bản đầy đủ). Không cần ảnh bìa. |

**Quy trình short:**

1. **Chọn 3 đoạn** đắt nhất của tập, mỗi short **một kiểu khác nhau**: một chiêu chưởng trọn vẹn, một bí mật hay chi tiết ít ai biết, một con số, một cuộc đối đầu hay cãi nhau, một câu thoại… Ghi vào `story.kieu`. Mỗi đoạn phải tự đứng được: người xem short chưa xem tập.
2. `new-short.mjs` với `--tu` là các câu của đoạn đó. Tổng giọng ≈ 35–50 s là vừa; bỏ bớt câu nếu dài.
3. **Lời** (`S/godot/loi.txt`):
   - `[s01-01]` hook ≤ 12 chữ, vào thẳng điểm đắt.
   - Câu nối hoặc giới thiệu lại tên người, tên môn võ nếu đoạn cắt giữa chừng. Viết câu mới thay câu tập bắt đầu bằng "Còn…", "Vì thế…" trơ trọi.
   - `[s03-01]` kết một câu, có "đăng ký" và "Tèo Kể".
   - Điền `story.json`: kieu, seo.title (≤ 60, kết "| Tèo Kể"), mo_ta, tags. Sửa `phu_de` (font, cỡ, màu) theo bút của tập nếu cần.
4. Chạy `gd-voice` qua LOCK, rồi `gd-check S`.
5. **Viết `S/godot/phim.gd` dọc**, dùng các hàm vẽ của tập (tap-01: `But`, `Canh`, `Nguoi`). Lấy giờ từng câu ở `main.lines` (id → t0, dur) để hình khớp lời.
   - Vùng hình y 190–1350. Dưới y 1350 để trống cho phụ đề và nút của Shorts; mép phải cũng để thoáng.
   - **Trong 1–2 s đầu phải có hình đắt nhất, khung không được trống.** Hook có cú chốt, ví dụ triện đóng xuống.
   - Một ý hình xuyên suốt short (tap-01 s01: rồng 28 vảy rụng dần thành 18 rồi 12). Nhân vật chibi của tập to, có cử động.
   - Cảnh kết có Tèo, triện "Tèo Kể" và nút ĐĂNG KÝ.
   - Muốn có chưởng thì gọi chiêu đã có bằng `preload("res://chuong/chieu.gd")` như ở tập, đặt chiêu vào khung dọc.
6. Preview `--sheet 2`, soi theo checklist dưới, sửa rồi chạy lại. Xong thì render bản cuối, `pack.mjs S`, kiểm mp4 1080×1920 có tiếng. Không đăng.

**Checklist short:** hook có hình đắt ngay giây đầu · hình không chạm vùng phụ đề và nút (dưới y 1350, mép phải) · phụ đề đọc được, không đè mặt · hình khớp đúng câu đang đọc · 3 short của tập khác kiểu, khác ý hình · ≤ 60 s · kết có Tèo + đăng ký + Tèo Kể.

## Hợp đồng với gd-render (main.gd sinh sẵn đã đúng)

- Cửa sổ 1920×1080 (short dọc: 1080×1920, `new-tap.mjs --doc`), stretch `canvas_items` (để `--preview` thu nhỏ được).
- Đọc `--from=` `--to=`; dựng mọi thứ **theo giờ t**, không phụ thuộc khung trước (để nhảy thẳng tới `--from` và chia `--par`).
  Hạt / ngẫu nhiên: dùng hàm băm theo t hoặc `RandomNumberGenerator` seed cố định, gieo lại theo t.
- Chạy với `-- --dur` thì in `DUR=<giây>`, ghi `timeline.json` rồi thoát.
- Giọng / nhạc / sfx phát bằng `AudioStreamPlayer`; bắt đầu giữa chừng thì `play(offset)`.
- Tự `get_tree().quit()` khi t ≥ to hoặc hết phim.

## Bẫy GDScript / Godot đã gặp

- Lấy giá trị từ Array / Dictionary thì khai kiểu rõ: `var x: float = arr[i]` (`:=` với Variant gây parse error).
- Lỗi parse chỉ hiện từng lỗi một: sửa xong chạy lại `gd-check`. Không khai nhiều biến trên một dòng (`var a := 1, b := 2` là parse error).
- **Font do tập tự chọn** theo bút (chép file .ttf vào `godot/font/`, ghi tên vào `story.font`, khác tập trước). Phải có đủ dấu tiếng Việt: thử in "Tiêu Phong ưởng ỹ Ỗ" trước khi dùng. Font chữ nét (Palatino…) thường thiếu ↑ ↓ ✕ ✓: dùng "»" hoặc chữ. Nguồn: `C:/Windows/Fonts`, Google Fonts (OFL).
- sfx thư viện: `godot/sfx/lib-<tên>.mp3`, gọi bằng tên `<tên>` trong `phim.sfx()`.
- Preview chạy khoảng 2× thời gian thật; render bản cuối 20 phút mất cỡ 40–60 phút với `--par 2`.
- `draw_*` không có bộ lọc: bóng / nhòe tự vẽ bằng nhiều lớp alpha thấp; nhiều node `Line2D` nặng hơn vẽ thẳng trong `_draw`.

## Checklist soi sheet

- [ ] Đoạn đầu là hook dựng riêng (không phải màn tiêu đề); Tèo hiện hình theo vai sớm.
- [ ] Mỗi đoạn một kiểu dựng khác hẳn (không chỉ đổi màu nền); hình khớp đúng câu đang đọc.
- [ ] Mỗi cảnh ra chưởng làm bằng skill `chuong-2d`, đã đạt checklist và có trong `chuong-2d/data/moves.json`.
- [ ] Nhân vật đọc được trên nền; mặt là mặt riêng của tập; có cử động cơ thể, không đứng đơ.
- [ ] Chữ trên hình ngắn (≤12 chữ), to, không đè mặt; có câu đọc đi kèm.
- [ ] Không thẻ chương, không chữ "Chương".
- [ ] Màu và bút giữ một chất suốt video (một bộ bút riêng của tập).
- [ ] Chiêu thức (nếu có) có tụ khí → đòn → hậu quả, đối thủ "thua" chỉ lùi / choáng, không bị hạ nhục.
- [ ] `gd-check` OK; khung, vai Tèo, bút, máy quay, palette, nhạc, thumbnail, mặt, font, chân mô tả khác các tập trong history.json.
