---
name: teo-kiem-hiep
description: >
  Làm video hoạt hình 2D DÀI (mỗi video ≥20 phút, tiếng Việt) về KIẾM HIỆP TRUNG QUỐC KINH ĐIỂN: tác giả nổi tiếng (Kim Dung, Cổ Long, Lương Vũ Sinh…),
  tác phẩm kinh điển, so sánh nhân vật ("ai mạnh hơn"), so sánh võ công, môn phái, thần binh. Tèo làm MC/trọng tài, nhân vật dựng chibi
  đấu minh hoạ + thẻ thông tin + bảng chỉ số (HyperFrames + GSAP, không ffmpeg). Quy trình: TỰ RESEARCH chủ đề (web + kho chu-de.md,
  dữ kiện ≥2 nguồn, chống trùng chủ đề) → chọn KHUNG DỰNG + vai Tèo + bối cảnh/stage/thời tiết/nhạc/bố cục khác 5 tập trước
  → tap.json + ≥1 hiệu ứng tự chế → build.mjs tự chọn hiệu ứng CHỐNG TRÙNG LẶP → snapshot soi
  → render MP4 → thumbnail 1280×720 (vs / solo / center) + gói youtube/. Dùng khi người dùng nói "Tèo kiếm hiệp", "tập kiếm hiệp mới",
  "video kiếm hiệp của Tèo", "Tèo so sánh võ công", "ai mạnh hơn", "so sánh nhân vật Kim Dung".
---

# Tèo Kiếm Hiệp: video chủ đề kiếm hiệp kinh điển, chống trùng lặp

`SKILL = thư mục chứa file này` · Engine: `SKILL/engine/` · Script: `SKILL/scripts/` · Lịch sử: `SKILL/data/history.json` · Kho chủ đề: `SKILL/data/chu-de.md`.
Font, sfx và bgm lấy từ `__MUSE_ROOT__/kit` (chỉ đọc, build tự copy vào tập).

Mỗi tập là một **chủ đề có thật** trong kiếm hiệp Trung Quốc, theo một trong 18 `format` (9 format chính dưới đây + 9 format mở rộng):

| format | nội dung | ví dụ |
|---|---|---|
| `doi-dau` | nhân vật vs nhân vật | Tiêu Phong vs Quách Tĩnh |
| `so-vo` | võ công vs võ công | Độc Cô Cửu Kiếm vs Tịch Tà Kiếm Phổ |
| `tac-gia` | chân dung tác giả + "phong cách võ" của ông | Cổ Long |
| `tac-pham` | tóm tắt vui một bộ truyện | Xạ Điêu trong 2 phút |
| `top` | xếp hạng | Ngũ Tuyệt Hoa Sơn |
| `mon-phai` | môn phái vs môn phái | Thiếu Lâm vs Võ Đang |
| `binh-khi` | thần binh | Ỷ Thiên kiếm vs Đồ Long đao |
| `giai-ma` | bí ẩn, vì sao | Vì sao Tảo Địa Tăng mạnh nhất? |
| `an-so` | "cái bóng" ít ai để ý cạnh ngôi sao: nhân vật phụ, võ công phụ mà vẫn rất lợi hại | Đả Cẩu Bổng: võ công bị Hàng Long che khuất |

Format mở rộng (chi tiết và kho chủ đề ở `chu-de.md` mục 1.9–1.17): `cuoc-doi` (cuộc đời một nhân vật), `su-that` (người thật, chuyện thật trong truyện), `neu-nhu` (what-if, cần `verdict`), `cap-doi` (tình yêu giang hồ), `su-do` (thầy trò), `phan-dien` (hồ sơ phản diện), `phim-vs-truyen` (phim khác nguyên tác: chỉ kể bằng lời, không dùng hình/nhạc phim), `dong-thoi-gian` (vũ trụ, dòng thời gian Kim Dung), `chieu-thuc` (giải nghĩa tên chiêu, tên võ công).

Tèo dẫn chuyện bằng bong bóng thoại và lời kể. **Vai của Tèo đổi theo từng tập** (`story.teo_role`, tự đặt theo khung của tập) Nhân vật kinh điển diễn minh hoạ bằng rig chibi, dữ kiện hiện trên `card`, điểm so sánh hiện trên `stat`. **Có giọng Tèo**: luôn là VieNeu "Lóng", giống kênh Tèo Kể. Vai chỉ đổi cách xưng hô và câu chữ, không đổi giọng. Mọi `say`, mọi trường `vo` và **mọi `card`** được đọc thành tiếng. Card nên có `vo` viết thành câu nói tự nhiên, phủ hết các dòng trên thẻ; không có `vo` thì Tèo đọc nguyên chữ trên thẻ (tiêu đề, dòng phụ, từng dòng).

**Mỗi tập phải khác hẳn tập trước về hình thức, không chỉ khác chủ đề.** Cụ thể là khác về: cấu trúc (khung dựng, tự thiết kế từ kịch bản của tập), vai Tèo, câu mở và câu kết, bối cảnh, stage (cách dựng khung hình), thời tiết, nhạc nền và nhịp nhạc, kiểu bong bóng, vị trí Tèo, layout thumbnail. 9 tập đầu đều chung một khuôn: chào "Chào các bạn, lại là Tèo đây", Tèo đứng góc trái, thumbnail VS, nhạc phẳng, kết "Đăng ký kênh, hẹn tập sau nha!". Khuôn này giờ bị story-check chặn.

## Luật cứng

- KHÔNG đăng gì lên mạng. KHÔNG gửi tin nhắn cho ai.
- Chỉ sửa thư mục tập đang làm, `__MUSE_ROOT__/ideas/DA-LAM.md` và dấu `(tập N)` trong `SKILL/data/chu-de.md`. KHÔNG sửa `kit/`.
- Không dùng `videos/_pilot` hay `khoi-nguyen-vu-tru-hy-lap` để thử nghiệm.
- Không tự sản xuất tập mới khi người dùng chưa yêu cầu.
- Không chia chương, không nói "Chương X".
- **Thời lượng: mỗi video dài ít nhất 20 phút** (tổng timeline ≥1200 s, nhắm 20–24 phút). story-check báo ✗ khi bản build ngắn hơn, build in cảnh báo, pack.mjs từ chối đóng gói.
- Hỏng mà không tự sửa được thì dừng lại, báo rõ lỗi kèm log.
- **Bản quyền:**
  - Được dùng: tên nhân vật, tên võ công, tóm tắt bằng lời của mình, bình luận, so sánh.
  - KHÔNG trích nguyên văn truyện quá 1 câu mỗi tập.
  - KHÔNG dùng hình, nhạc hay cảnh phim truyền hình/điện ảnh. KHÔNG vẽ giống diễn viên.
  - Nhân vật luôn vẽ bằng rig chibi của engine.
- **Chính xác:**
  - Mọi dữ kiện (năm, tình tiết, chiêu thức, ai thắng ai trong truyện) phải có ≥2 nguồn, ghi vào `story.facts`. story-check chặn nếu thiếu.
  - Chi tiết nào khác nhau giữa các bản Kim Dung (bản cũ / bản sửa / bản tân tu) thì ghi rõ bản trong `story.edition`, và nói trong video nếu chi tiết đó quan trọng (ví dụ "28 chưởng rút còn 18" chỉ có ở bản tân tu).
  - Không chắc thì bỏ dữ kiện đó, đừng bịa.
  - "Ai mạnh hơn" là **nhận định**: Tèo phải nói rõ là ý kiến riêng, dựa vào chi tiết trong truyện. Điểm trong `stat` là "Tèo chấm", phải nói ra trước khi hiện bảng.
- **Tôn trọng:**
  - Hai bên đều là huyền thoại. Bên "thua" chỉ choáng hoặc lùi, không bị hạ nhục.
  - Tập có `story.format` thì planner tự cấm các react `down` (nằm gục, bẹp, văng). Chỉ còn af-blow, af-stagger, af-dizzy và react mới không gắn `down`.
  - Không máu me, không chết chóc, không chính trị/tôn giáo gây tranh cãi, không 18+. Nhân vật tăng/đạo sĩ dựng vui nhưng không giễu tôn giáo.

## Dựng bằng Godot 2D (cách làm hiện tại, từ 2026-10-21; thay HyperFrames + beat/planner)

**Quy trình đầy đủ + công cụ (new-tap, gd-check, pack, sổ chống lặp) ở skill `teo-kiem-hiep-godot`; làm tập Godot thì theo skill đó.**

Người dùng yêu cầu: **mỗi tập một kịch bản và một cách dựng riêng, không template chung, hiệu ứng làm bằng Godot 2D** (không dùng HyperFrames). Tập mẫu: `kiem-hiep/tap-10-lenh-ho-xung/godot/ (bản cũ hơn: kiem-hiep/_lab/mau-godot-tap-01/)`. Các phần build.mjs / plan.mjs / beat / fx HyperFrames ở dưới chỉ còn để tham khảo tập cũ.

- Mỗi tập có project Godot riêng `<tap>/godot/` (Godot 4.7.2: `__GODOT__`). Tập tự thiết kế khung dựng, bộ bút, máy quay, nhân vật. **Không chép engine của tập trước** mà chỉ đọc để học. Muốn dùng lại một ý thì viết lại theo kiểu của tập mới.
- Kịch bản `godot/loi.txt`: mỗi câu đọc là một dòng `[id] lời`. Mọi dòng khác (ví dụ `## kNN ghi chú`) để GDScript của tập tự đọc.
- Giọng đọc: `node SKILL/scripts/gd-voice.mjs <tap>` (đọc trên Colab, không qua slot.sh; Colab lỗi thì dừng báo lỗi, chỉ `--local` mới đọc máy nhà) ra `godot/voice/<id>.wav` + `voice.json` với độ dài thật từng câu. Giờ trong video xếp theo độ dài này.
- Mặt: `node SKILL/scripts/gd-mat.mjs <tap>` dùng `<tap>/ve.mjs` riêng của tập để ra `godot/mat/<nv>/<biểu cảm>.svg`. Thân người tập tự vẽ bằng GDScript.
- Hợp đồng với gd-render (đầu file `scripts/gd-render.mjs`):
  - cửa sổ 1920×1080, stretch `canvas_items`;
  - main đọc `--from= --to=`, dựng mọi thứ theo giờ t;
  - in `DUR=` khi chạy `-- --dur`;
  - phát giọng/nhạc/sfx bằng AudioStreamPlayer.
- Kiểm tra cú pháp + độ dài: chạy `Godot --headless --path . -- --dur` trong `godot/`. Lỗi parse chỉ hiện từng lỗi một, sửa xong chạy lại. Hay gặp: `var x := [..][i]` không suy được kiểu, phải ghi `var x: float = …`.
- Soi: `bash kiem-hiep/_tools/slot.sh "<tập> xem" node SKILL/scripts/gd-render.mjs <tap> --preview --from A --to B --sheet 5 --out xa` ra `work/sheet-xa.jpg`. Preview chạy khoảng 2× thời gian thật, nên chia 2 đoạn chạy song song theo 2 suất máy.
- Bản cuối: `… gd-render.mjs <tap> --par 2` ra `renders/final.mp4`.
- Nhạc nền: tập tự sinh (ví dụ `work/nhac.py`: đàn gảy Karplus-Strong ngũ cung + nền trầm + trống, đổi tâm trạng theo `godot/timeline.json`). Ghi wav rồi ffmpeg libvorbis ra `godot/nhac.ogg`; soundfile ghi OGG dài sẽ tràn stack.
- Ảnh bìa: scene `godot/thumb.tscn` vẽ bằng chính bộ bút của tập, chạy có cửa sổ (không `--headless`), lưu `thumb/thumb-godot.png`. Luật thumbnail giữ nguyên: mặt không bị che, chữ to.
- Font Palatino không có mũi tên → ↑ ↓ ✕ ✓: dùng "»" hoặc chữ. sfx thư viện tên `sfx/lib-<tên>.mp3`.

## Chống trùng lặp: vì sao mỗi tập khác nhau

1. **Chủ đề:** `scripts/story-check.mjs` (xem bước 0).
   - Chặn: bản build ngắn hơn 20 phút; cùng bộ `subjects` với tập cũ; cùng `format` 3 tập liền; tiêu đề hoặc logline giống tập cũ.
   - Nhắc: một subject vừa xuất hiện trong 3 tập gần nhất; 3 tập liền cùng tác giả; format trùng tập ngay trước.
   - Một nhân vật hay võ công *được phép* quay lại ở tập khác, miễn góc so sánh mới (Tiêu Phong vs Quách Tĩnh rồi, sau này Tiêu Phong vs Đoàn Dự vẫn được).
2. **Hiệu ứng:** planner (`scripts/plan.mjs`, build tự gọi) gán hiệu ứng cho từng *slot*: opener, transition, camera, enter, intro, power, attack, impact, react, caption, card, stat, ender.
   - Luật cứng (nới dần nếu hết ứng viên):
     - Không lặp liền trong cùng nhóm.
     - Không có cặp liên tiếp (bigram) nào đã xuất hiện trong 5 tập gần nhất.
     - Opener, ender và theme khác 3 tập gần nhất.
     - Chiêu kết liễu khác 5 tập gần nhất.
   - Luật mềm: phạt hiệu ứng hay dùng gần đây. Thử 60 seed, lấy plan có độ giống thứ tự (LCS) thấp nhất, mục tiêu ≤ 0.35. Vượt ngưỡng thì in CẢNH BÁO.
3. **Sáng tạo riêng bắt buộc:** mỗi tập có ≥1 file `<dir>/fx/*.mjs` do mày tự viết mới, gọi bằng beat `{"do":"local:<tên>"}`. pack.mjs từ chối đóng gói nếu thiếu.
   - Ý tưởng nên bám chủ đề: rồng vàng cho Hàng Long, kiếm khí sáu mạch cho Lục Mạch Thần Kiếm, kim châm bay cho Quỳ Hoa Bảo Điển, ngọn lửa cho Thánh Hoả Lệnh…
   - Đừng chép lại hiệu ứng của tập trước.
4. Lịch sử chỉ được ghi khi `pack.mjs` chạy, tức là tập đã render xong. Build thử bao nhiêu lần cũng không làm bẩn lịch sử.
5. Trước khi viết tập mới, chạy `node SKILL/scripts/fx-list.mjs` để xem nhóm nào đang bị dùng nhiều. Nên viết hiệu ứng local thuộc nhóm đó, hoặc thuộc nhóm còn ít lựa chọn.
6. **Hình thức:** story-check (`lookCheck`) so "dấu vân tay hình thức" của tập với các tập trước. Tập cũ chưa có trường này thì nó đọc lại tap.json của tập đó.
   - **✗ (phải sửa):**
     - thiếu `story.frame` (name, analysis ≥25 chữ, axis, open, close, 6–8 segments) hoặc `story.teo_role`
     - tên khung, trục sắp xếp hoặc dàn khung gần giống 1 trong 3 tập gần nhất; vai Tèo gần giống 1 trong 2 tập gần nhất
     - dùng câu công thức cũ ("chào các bạn lại là Tèo đây", "đăng ký kênh hẹn tập sau nha"…)
     - 3 câu mở hoặc 3 câu kết giống tập nào trong 5 tập gần nhất (trigram ≥0,5)
     - 8 beat mở đầu y hệt 1 trong 3 tập gần nhất
     - âm thanh y hệt tập trước: cùng bgm và nhạc phẳng
     - dùng ít hơn 2 kiểu stage
     - chữ thumbnail trùng một tập cũ
   - **! (nên sửa):**
     - dãy beat chính giống >80%
     - bộ stage trùng tập trước
     - không cảnh nào có thời tiết
     - cảnh mở cùng bối cảnh với 1 trong 3 tập gần nhất
     - bộ bối cảnh giống tập trước >60%
     - Tèo đứng góc trái ở ≥70% số cảnh
     - thumb.layout giống 2 tập liền trước
   - pack.mjs ghi `look` vào history.

## Quy trình một tập

Thư mục tập: `__MUSE_ROOT__/kiem-hiep/tap-<NN>-<slug>/` (slug không dấu, gạch nối, ví dụ `tap-01-tieu-phong-vs-quach-tinh`).

0. **Research & chọn chủ đề** (bắt buộc, không hỏi người dùng, tự chọn rồi đi tiếp):
   1. `node SKILL/scripts/story-check.mjs`: xem các tập trước (format, subjects, tác giả), lời hẹn `next`, thống kê format/tác giả/tác phẩm/set.
   2. Đọc `SKILL/data/chu-de.md` (kho chủ đề theo format, ngoại hình gợi ý cho nhân vật nổi tiếng, bảng quy đổi bối cảnh → set, mẫu dàn ý, mục 5 gói chủ đề cho tập 20+ phút, mục 6 series nhiều phần và tier list: đang dở series nào thì ưu tiên làm phần tiếp theo).
   3. WebSearch/WebFetch 3–6 truy vấn, tổng cộng ~10 phút:
      - Nguồn ưu tiên: vi/zh/en Wikipedia, Baidu Baike, jinyong.fandom / wuxia.fandom, báo Việt có bài phân tích (soha, cafebiz, zing…).
      - Thêm 1 truy vấn "<chủ đề> ai mạnh hơn" hoặc "<chủ đề> tranh cãi" để biết người xem đang tranh luận gì.
      - Không có mạng thì chỉ chọn chủ đề mà chu-de.md đã ghi sẵn dữ kiện + nguồn; vẫn phải đủ ≥2 nguồn/dữ kiện.
   4. Viết 3 ý tưởng (ưu tiên giữ lời hẹn `next` của tập trước). Mỗi ý gồm: format, subjects, logline, set, ý hiệu ứng local. Chấm 1–5 theo năm tiêu chí:
      - mới so với lịch sử
      - sức hút / độ tranh luận
      - đủ nguồn chính xác
      - dựng được bằng set/preset/beat đang có
      - có chỗ cho hiệu ứng local đẹp
   5. Tự chọn ý có tổng điểm cao nhất.
   6. **Phá khuôn** (bắt buộc, làm trước khi viết dàn ý). Đọc bảng "CHỐNG LẶP HÌNH THỨC" mà story-check in ra, rồi chốt các mục sau:
      - **Kịch bản thô → phân tích → khung dựng:** làm đúng 4 bước ở mục "Khung dựng" bên dưới. Không chọn khung từ danh sách nào. Format (chủ đề) và frame (hình thức) là hai trục độc lập.
      - **Vai Tèo** (`teo_role`): rút ra từ khung, khác 2 tập gần nhất.
      - **Câu mở và câu kết:** viết bằng giọng của vai Tèo, không chép công thức.
      - **Bảng dựng cảnh:** với mỗi cảnh ghi set, time, stage, weather, music và vị trí Tèo.
      - **Âm thanh:** chọn bgm, và nhịp nhạc lên xuống theo cảnh.
      - **Bong bóng:** chọn kiểu `bubble`.
      - **Thumbnail:** chọn layout và chữ.
   7. Viết dàn ý theo `frame.segments` (mẫu đoạn theo format ở chu-de.md mục 4 chỉ để tham khảo nội dung; thứ tự và cách mở/kết theo khung).
   8. Ghi `<dir>/y-tuong.md` gồm:
      - các truy vấn, bảng 3 ý và điểm, lý do chọn
      - mục **"Phân tích"** (6 câu hỏi ở mục Khung dựng) và khung đã thiết kế, rồi dàn ý
      - **bảng dữ kiện** (claim | nguồn 1 | nguồn 2 | bản truyện)
      - điểm `stat` kèm lý do mỗi điểm
      - **bảng "Tập này khác 5 tập trước ở đâu"**, ≥6 điểm: khung, vai Tèo, câu mở, bối cảnh/stage/thời tiết, âm thanh, bố cục/vị trí Tèo, thumbnail
      
      Đánh dấu chủ đề đã dùng trong `data/chu-de.md` bằng `(tập N)`.
1. Chạy `fx-list.mjs` để biết nhóm hiệu ứng nào đang bị dùng nhiều.
2. Viết `tap.json` (định dạng ở dưới, **có khối `story`**) và `fx/<tên>.mjs` (≥1 file). Chạy `node SKILL/scripts/story-check.mjs <dir>`, sửa tới khi hết mọi dòng ✗; dòng ! thì cân nhắc.
3. **Giọng đọc:** `node SKILL/scripts/voice.mjs <dir>` (thêm `--dry` để chỉ ước thời lượng giọng trước khi đọc). Lệnh này đọc mọi `say` + `vo` bằng VieNeu (`__VIENEU_DIR__`), giọng mặc định "Lóng", ghi `<dir>/voice/*.wav` + `voice/voice.json`, có cache nên dòng không đổi chữ không đọc lại. Đổi giọng bằng `"voice"` trong tap.json, độ ngẫu nhiên bằng `"voice_temperature"` (mặc định 0,8).
   - Câu dưới 6 từ VieNeu dễ đọc vội/méo; nên viết câu ≥10 từ. Sửa chữ sau khi đọc thì phải chạy lại voice.mjs (build sẽ cảnh báo câu chưa có giọng).
   - Giọng là nguồn thời lượng chính: ~4,1 từ/giây, nên 20 phút cần khoảng 4.500–5.000 từ lời đọc.

   Sau đó `node SKILL/scripts/build.mjs <dir>`. Lệnh này in plan, ghi `index.html`, `work/timeline.json` và `thumb/`.
   - Muốn đổi tổ hợp hiệu ứng thì thêm `--replan`. Muốn tái lập đúng một plan thì dùng `--seed N`.
   - Đổi chữ trong tap.json mà không đổi cấu trúc beat thì plan giữ nguyên.
   - Tổng thời lượng **≥1200 s (20 phút)**, nhắm 20–24 phút; dòng `build: … · <total> s` cho biết tổng. Thiếu thì thêm đoạn (chủ đề phụ trong gói chủ đề), hiệp, card/stat, chi tiết ít người biết; đừng kéo dài bằng cảnh đứng im (không quá 20 s không có chuyển động). Chạy lại `story-check.mjs <dir>` sau khi build để kiểm thời lượng.
4. Soi bằng snapshot ở các mốc lấy từ `work/timeline.json` (`beats[].t`):
   `npx --yes hyperframes@0.8.172 snapshot <dir> --at 1,5.2,9.8 --no-end -o <dir>/work/snap --describe false`
   rồi Read từng png (hoặc `contact-sheet.jpg`). Phải kiểm tra:
   - Nhân vật nằm trong khung, không ai ngã ra ngoài.
   - Chữ không bị cắt. Không có mảnh hiệu ứng hiện sẵn từ đầu cảnh hay còn sót lại sau khi xong.
   - Bong bóng thoại, chữ tượng thanh, caption, **card và stat không che mặt nhân vật**. Chụp thêm 1 mốc ngay sau mỗi attack (`t` + 0,9 s) và 1 mốc giữa mỗi card/stat.
   - Chữ trên card đọc rõ và đủ lâu (build tự tính theo số chữ; card >4 dòng hoặc quá cao thì build in cảnh báo).
   - Số trên `stat` khớp `y-tuong.md`, bên được tô sáng đúng bên điểm cao.
   - Bên thua chỉ choáng/lùi.
   - Build không in dòng "CẢNH BÁO … attack không có react".
   - Hiệu ứng local trông đúng ý.
   - Thumbnail (`thumb/`): snapshot `npx --yes hyperframes@0.8.172 snapshot <dir>/thumb --at 0.5 --no-end -o <dir>/work/tsnap --describe false`.
5. Render: `cd <dir> && npx --yes hyperframes@0.8.172 render --output renders/final.mp4 --quality standard` (chạy nền).
   - Tìm trong log render dòng "falls back to screenshot" / "self-verify": có thì tập bị chụp chậm, sửa theo mục "Tốc độ render".
   - GSAP: nếu có `SKILL/engine/vendor/gsap.min.js` (bản 3.14.2) thì build chép vào tập, render không cần mạng. Không có thì tải từ CDN jsdelivr lúc render.
   - Plan được giữ nguyên khi build lại, trừ khi đổi cấu trúc beat **hoặc** lịch sử có tập khác mới pack. Khi đó build tự lập plan mới.
6. Viết `seo` trong tap.json rồi chạy `node SKILL/scripts/pack.mjs <dir>`. Lệnh này chụp thumbnail và tạo `youtube/`: mp4, thumbnail.png, tieu-de.txt, mo-ta.txt, tags.txt, DANG-YOUTUBE.md. Nó cũng ghi lịch sử (kể cả khối story). Nếu chỉ chạy thử thì thêm `--no-history`.
   - **Đồng bộ Google Drive (tự động, bắt buộc):** đóng gói không lỗi xong, pack.mjs chép cả `youtube/` sang `G:\My Drive\TeoKenhYoutube\<slug>\` qua ứng dụng Google Drive for desktop (ứng dụng tự tải lên mây). Chép qua file `.part` rồi đổi tên; file đã có cùng kích thước và không cũ hơn thì bỏ qua.
   - Không thấy `G:\My Drive` thì pack báo "CHƯA lên Drive" và thoát mã 1 (gói `youtube/` và lịch sử đã ghi xong). Mở ứng dụng Google Drive rồi chạy `node SKILL/scripts/drive-sync.mjs <dir>`.
   - Sửa thumbnail hay seo sau bước 7 thì chạy lại pack để Drive nhận bản mới. `--no-drive` chỉ dùng khi chạy thử; đổi đích bằng biến môi trường `TEO_DRIVE_DIR`.
7. Read `youtube/thumbnail.png` để kiểm tra: mặt không bị che, chữ hook đọc được.
8. Ghi một dòng vào `__MUSE_ROOT__/ideas/DA-LAM.md`, mảng "Tèo kiếm hiệp": tập, tiêu đề, đường dẫn, hiệu ứng local. Khi báo cáo cho người dùng, ghi kèm đường dẫn trên Drive (hoặc nói rõ là chưa lên Drive).

## Khung dựng: phân tích kịch bản rồi mới tạo khung (bắt buộc `story.frame`)

Một video gồm 1 chủ đề chính + 4–6 chủ đề phụ (lấy từ **gói chủ đề** ở chu-de.md mục 5), chia **6–8 đoạn**, mỗi đoạn 2,5–4 phút. Các đoạn nối liền mạch, không có thẻ chương. Cả video có **≥3 hiệu ứng local** đặt ở các chỗ cao trào. Caption ≤12 chữ. Mời đăng ký 2 lần: một lần ở khoảng 25–75% video, một lần ở cuối, nói bằng giọng của khung.

**KHÔNG có danh sách khung để chọn.** Mỗi tập, khung sinh ra từ chính kịch bản của tập đó. Làm theo thứ tự:

1. **Kịch bản thô trước.** Gom hết chất liệu đã research thành `<dir>/kich-ban-tho.md`, chưa cần thứ tự:
   - các sự kiện và cảnh truyện
   - lời thoại nổi tiếng (tối đa 1 câu trích nguyên văn)
   - dữ kiện sẽ lên `card` và `stat`
   - các khoảnh khắc mạnh nhất
   - các tranh cãi của người xem
2. **Phân tích kịch bản**, ghi vào `y-tuong.md` mục "Phân tích". Trả lời từng câu:
   - Lõi của chuyện này là gì: một cuộc đối đầu, một bí ẩn, một mối tình, một lời hẹn, một món đồ, một hành trình, một sự hiểu lầm, hay một bảng xếp hạng?
   - Cảm xúc chủ đạo là gì, và nó đổi thế nào từ đầu tới cuối?
   - Khoảnh khắc mạnh nhất nằm ở đâu? Có nên mở bằng chính nó không?
   - Ai trong truyện là người đứng gần nhất để kể chuyện này? Có thể là một nhân vật phụ, một món đồ, một nơi chốn.
   - Người xem đang muốn biết gì, và đang cãi nhau về điều gì?
   - Chất liệu này tự nhiên chia thành những khối nào: theo thời gian, theo từng người, theo từng chiêu, theo từng nơi, theo từng câu hỏi, hay theo từng bằng chứng?
3. **Thiết kế khung** từ câu trả lời, ghi vào `story.frame`:
   - `name`: tên khung tự đặt riêng cho tập, ví dụ "sổ tay của con điêu".
   - `analysis`: tóm tắt phân tích ở bước 2 và vì sao khung này hợp với kịch bản (≥25 chữ).
   - `axis`: trục sắp xếp các đoạn. Đây là thứ quyết định thứ tự.
   - `open` / `close`: cách mở và cách kết, rút ra từ khoảnh khắc mạnh nhất và cảm xúc cuối.
   - `segments`: 6–8 đoạn, mỗi đoạn một câu.

   Sau đó chọn **vai Tèo** (`story.teo_role`, chữ tự do) hợp với khung. Tèo có thể là người trong cuộc, người hỏi, người ghi chép, hoặc vắng mặt và chỉ lồng tiếng.
4. **Khung kéo theo phần dựng.** Từ khung mới chọn:
   - set, stage, weather và nhạc cho từng đoạn
   - vị trí Tèo
   - nhịp beat (không phải tập nào cũng mở bằng `say > say > pose > pose…`)
   - kiểu bong bóng
   - layout thumbnail

**Kiểm tra trước khi viết tap.json.** Dàn khung này có dựng lại được cho tập khác bằng cách chỉ thay tên nhân vật không? Nếu được thì khung còn quá chung chung, phải bám sát chất liệu hơn.

story-check chặn các trường hợp sau, so với 3 tập gần nhất:
- tên khung gần giống
- trục sắp xếp gần giống
- dàn khung (axis/open/close/segments) giống ≥45%
- vai Tèo gần giống 2 tập gần nhất

Lệnh `story-check` không có `<dir>` sẽ in khung của 5 tập gần nhất để tránh.

**Mở đầu:**
- Câu đầu là hook ≤5 s, khớp chữ thumbnail.
- **CẤM** dùng "Chào các bạn, lại là Tèo đây, hôm nay Tèo…" làm câu thứ 2 như 9 tập đầu.
- Tèo tự giới thiệu theo vai, trong khoảng 60 s đầu. Ví dụ ý (không chép): tiểu nhị lau bàn chào khách; phóng viên giơ micro; quan toà gõ búa; hoặc nhân vật khác giới thiệu Tèo.
- Khung nào kể bằng nhân vật khác hoặc mở bằng cái kết thì có thể vào thẳng chuyện, Tèo xuất hiện sau.

**Kết:**
- Kết theo khung: phán quyết, quay về cảnh mở, câu hỏi để ngỏ, nhân vật nói lời cuối, hoặc bảng xếp hạng chốt.
- **CẤM** caption "Đăng ký kênh, hẹn tập sau nha!" và cấm chép câu kết của 5 tập trước.
- Vẫn móc `ender.next` (chủ đề tập sau) và vẫn mời đăng ký, bình luận, nhưng diễn đạt mới.

**Tôn trọng và chính xác** vẫn như luật cứng. "Ai mạnh hơn", phán quyết, xếp hạng đều là ý kiến của Tèo, phải nói rõ. Format `an-so` (ngôi sao + cái bóng, kho ý tưởng ở chu-de.md mục 1.18) có `subjects` = [ngôi sao, cái bóng]: nói thật cái bóng thua ở đâu, rồi lật lại những chiến tích bị quên. Format này ghép được với khung nào cũng được.

## Dựng cảnh, bố cục, âm thanh: các nút để mỗi tập trông khác

- **Bối cảnh `set`** (12 cái): san-tap, rung-truc, mai-ngoi, quan-tro, nui-tuyet, ben-song, cau-go, **thao-nguyen** (lều, cỏ lay, chim bay), **hang-dong** (thạch nhũ, chùm sáng, chữ khắc phát sáng), **tang-kinh-cac** (kệ sách cuộn, đèn đung đưa), **dinh-nui** (đỉnh trên biển mây, tùng nghiêng), **pho-cho** (sạp hàng, cờ 酒茶藥, dây lồng đèn).
  - `time`: ngay / chieu / dem.
  - 9 tập đầu dùng nui-tuyet, san-tap, mai-ngoi, quan-tro rất nhiều. story-check in số lần dùng, nên ưu tiên set ít dùng.
- **`weather`** theo cảnh: mua, tuyet, suong, la-phong, hoa-dao, dom-dom. Thời tiết phải hợp nghĩa: mưa cho chia ly, hoa đào cho tình, đom đóm cho đêm kể chuyện.
- **`stage`** theo cảnh, là cách đóng khung hình. Mỗi tập dùng ≥2 kiểu:

  | stage | tác dụng | hợp với |
  |---|---|---|
  | `letterbox` | viền đen điện ảnh | cảnh mở, trận lớn |
  | `panel` | khung truyện tranh trắng + chấm halftone | câu đố, xét xử |
  | `scroll` | cuộn giấy gỗ + nền sepia | bi-kip, nhật ký |
  | `silhouette` | nhân vật thành bóng đen | bí ẩn, giao nhau |
  | `thuy-mac` | nền thuỷ mặc xám | đỉnh núi, triết lý |
  | `spotlight` | tối quanh vùng giữa | độc thoại, tuyên án |
  | `hoi-uc` | sepia + vignette + vạch phim | quá khứ, ngược thời gian |

- **Vị trí Tèo:** đừng mặc định đứng góc trái (x ≈ 250) ở mọi cảnh như 9 tập đầu. Đổi theo khung:
  - đứng giữa khi phỏng vấn
  - lệch phải (x 1500–1700) khi hai nhân vật đấu bên trái
  - nhỏ và đứng cao (`w` 140, `foot` 520) như đang ngồi trên mái
  - vắng mặt, chỉ có `vo`
  - `enter` muộn giữa cảnh
- **`bubble`** (cả tập): mặc định trắng viền đen; `giay` (giấy dó nâu), `muc` (nền mực đen chữ kem), `vuong` (khung vuông truyện tranh). Áp cho tone normal và think.
- **Nhạc:**
  - `tap.bgm`: tên file mp3 trong `<dir>/`, `<dir>/assets/bgm/` hoặc `kit/bgm/`. Build đo độ dài bằng ffprobe rồi tự lặp.
  - Hiện kit/bgm chỉ có `playful-pizzicato.mp3`. Muốn thêm nhạc thì **người dùng tự bỏ file vào kit/bgm**. KHÔNG tải nhạc từ nguồn lạ, KHÔNG dùng nhạc phim.
  - **`scenes[].music`**: `on` (mặc định), `low` (×0,4), `up` (×1,7), `off` (im hẳn). Nhạc chạy liền theo đồng hồ tổng, chỉ đổi âm lượng.
  - Dùng để tạo nhịp: im lặng trước cú twist, nhỏ lúc kể buồn, to ở hạng 1. Một tập có ≥2 cảnh khác `on`, hoặc dùng bgm khác tập trước.
- **beat `sfx`**: `{ "do": "sfx", "name": "chime", "vol": 0.5, "len": 1, "dur": 0.1 }`. Đặt sfx chủ động: chime báo tin, riser trước twist, pop khi lật đáp án.
- **Thumbnail `thumb.layout`:**
  - `vs`: mặc định, hai nhân vật + huy hiệu VS. 8/9 tập đầu dùng kiểu này.
  - `solo`: một nhân vật `thumb.who` to bên phải, chữ to bên trái.
  - `center`: nhân vật giữa, chữ căn giữa phía trên.
  - `thumb.set` / `thumb.time` đổi nền thumbnail.
  - Chữ thumbnail tránh lặp kiểu "AI … ?" của các tập trước.

## tap.json

Mẫu cấu trúc, đã build thử: `SKILL/examples/tap-01/` (Tiêu Phong vs Quách Tĩnh). **Mẫu này chỉ dài ~1,5 phút để minh hoạ cú pháp beat** (tương đương một đoạn); tập thật phải nhân lên 6–8 đoạn để đủ ≥20 phút. Rút gọn. Mẫu cũ dựng theo khuôn võ đài cũ; các trường mới (frame, teo_role, bgm, bubble, stage, weather, music, thumb.layout) được thêm vào để minh hoạ. **Lời thoại trong `examples/tap-01/tap.json` là khuôn cũ (có câu chào công thức), chỉ xem cú pháp, không chép lời:**

```json
{
  "ep": 1, "title": "Tiêu Phong vs Quách Tĩnh: ai mạnh hơn?", "hook": "AI MẠNH HƠN?",
  "theme": "auto", "bgm": "playful-pizzicato.mp3", "bubble": "giay",
  "opener": { "title": "TÈO KỂ KIẾM HIỆP", "sub": "Tiêu Phong vs Quách Tĩnh" },
  "ender": { "next": "Lệnh Hồ Xung vs Dương Quá: kiếm ai nhanh hơn" },
  "thumb": { "text": "CHƯỞNG AI NẶNG HƠN", "layout": "solo", "who": "tieu", "set": "dinh-nui", "time": "chieu" },
  "cast": {
    "teo": { "kind": "teo", "name": "Tèo", "band": "#D7263D", "weapon": "kiem" },
    "tieu": { "preset": "hiep-khach", "name": "Tiêu Phong", "robe": "#5A3A22", "hat": "none", "weapon": "none" },
    "quach": { "preset": "hiep-khach", "name": "Quách Tĩnh", "robe": "#2E6FB7", "hat": "khan", "weapon": "none" }
  },
  "scenes": [ { "set": "nui-tuyet", "time": "ngay", "stage": "letterbox", "weather": "tuyet", "music": "low",
    "actors": [ { "id": "teo", "x": 1650 }, { "id": "tieu", "x": 760 }, { "id": "quach", "x": 1500, "hidden": true } ],
    "beats": [
      { "do": "card", "side": "right", "title": "Quách Tĩnh", "sub": "Xạ Điêu Anh Hùng Truyện · Kim Dung", "lines": ["…", "…"] },
      { "do": "attack", "who": "tieu", "target": "quach", "name": "Hàng Long Thập Bát Chưởng" },
      { "do": "react", "who": "quach" },
      { "do": "stat", "left": "tieu", "right": "quach", "total": true,
        "rows": [ { "label": "Hàng Long", "l": 10, "r": 9 }, { "label": "Biến hoá", "l": 8, "r": 9 } ] },
      { "do": "local:rong-chuong", "who": "tieu", "target": "quach" }
    ] } ],
  "story": {
    "format": "doi-dau", "teo_role": "lão ăn mày Cái Bang giữ sổ của hai đời bang chủ",
    "frame": { "name": "hai trang trong sổ Cái Bang", "analysis": "Lõi chuyện là một môn võ truyền qua hai người khác hẳn số phận: một người bị đuổi khỏi bang, một người được cả thiên hạ nhớ. Cảm xúc đi từ tự hào tới tiếc nuối, nên kể qua cuốn sổ ghi chép của Cái Bang thay vì chấm điểm.", "axis": "mỗi đoạn là một trang sổ, lật xen kẽ giữa hai đời chưởng pháp", "open": "trang cuối sổ, dòng chữ về trận Thiếu Thất Sơn", "close": "để trống trang so sánh, mời người xem tự ghi", "segments": ["…6–8 câu…"] },
    "logline": "Tiêu Phong và Quách Tĩnh cùng dùng Hàng Long Thập Bát Chưởng, Tèo làm trọng tài so ai mạnh hơn",
    "subjects": ["Tiêu Phong", "Quách Tĩnh"], "works": ["Thiên Long Bát Bộ", "Xạ Điêu Anh Hùng Truyện"], "authors": ["Kim Dung"],
    "edition": "bản tân tu",
    "verdict": "Ý kiến của Tèo: nghiêng về Tiêu Phong nhờ thực chiến; truyện không có trận nào giữa hai người.",
    "facts": [ { "claim": "Bản tân tu: Tiêu Phong cùng Hư Trúc rút Hàng Long từ 28 chưởng còn 18", "src": ["https://…", "https://…"] } ],
    "sources": ["https://…"]
  },
  "seo": { "title": "Tiêu Phong vs Quách Tĩnh: ai mạnh hơn?", "alts": ["…"], "description": "…", "tags": ["tiêu phong", "quách tĩnh", "kim dung"], "hashtags": ["#KimDung"] }
}
```

- **Tiêu đề / SEO:**
  - `seo.title` không ghi đuôi, pack tự gắn " | Tèo Kể". Tổng độ dài ≤60 ký tự.
  - Kiểu tiêu đề: "A vs B: ai mạnh hơn?", "Vì sao X …?", "Top 5 kiếm pháp Kim Dung", "Cổ Long khác Kim Dung ở đâu?".
  - Tags gồm tên nhân vật, võ công, tác phẩm, tác giả, "ai mạnh hơn". Hashtag mặc định đã có #TeoKe và #KiemHiep; thêm tên tác giả (#KimDung, #CoLong…).
  - Mô tả nêu rõ tác phẩm/tác giả và câu "so sánh là ý kiến riêng".
- **story:** bắt buộc.
  - `format` thuộc 18 format ở trên (chủ đề). `frame` là khung tự thiết kế {name, analysis, axis, open, close, segments}, xem mục Khung dựng. `teo_role`: vai Tèo bằng chữ tự do. `subjects`: nhân vật / võ công / tác giả / tác phẩm mà tập bàn tới (format đối đầu cần ≥2).
  - `works`, `authors`, `edition`, `verdict` (doi-dau/so-vo nên có), `facts[{claim, src[≥2]}]`, `sources` (nguồn tham khảo thêm).
  - pack.mjs ghi story, title, next, sets, chars, moves và `look` (dấu vân tay hình thức) vào history để các tập sau tránh trùng.
- **thumb:**
  - `text`: chữ lớn (≤3–4 từ).
  - `vs: [idTrái, idPhải]`: thumbnail đối đầu (2 nhân vật + huy hiệu VS + biển tên). Hai id phải cùng có mặt trong một cảnh.
  - `pose` (bên trái hoặc Tèo), `pose2` (bên phải). Không có `vs` thì vẽ Tèo + một đối thủ như kiểu cũ.
  - `layout`: vs (mặc định) | solo | center; `who`: nhân vật chính của solo/center; `set`, `time`: nền riêng cho thumbnail. Xem mục Dựng cảnh.
- **Cả tập:** `bgm` (file nhạc), `bgm_volume`, `bubble` (giay / muc / vuong).
- **cast:**
  - `kind:"teo"` hoặc `preset` thuộc: linh, linh-do, cao-thu, hiep-khach, thu-sinh, chuong-quy, su-phu, nu-hiep, **cai-bang** (áo vá nâu, gậy), **tang** (cà sa vàng, đầu trọc), **dao-si** (áo lam, búi đạo sĩ, kiếm), **cong-tu** (áo trắng, kiếm), **lao-quai** (áo tím sẫm, râu, gậy).
  - Ghi đè được: `robe`, `hat` (linh/bui/non/khan/none/troc/dao), `beard`, `weapon` (kiem/dao/giao/quat/gay/none), `belt`, `patch` (áo vá), `sash` (mã màu cà sa chéo).
  - Gợi ý ngoại hình cho ~20 nhân vật nổi tiếng nằm trong chu-de.md. Không vẽ giống diễn viên.
  - **Rig 2 + sổ nhân vật chung:** `"x": { "char": "<id>", "name": "…" }` lấy nguyên look (cả robe2, pants, band, màu râu) từ `nhan-vat-chibi/data/chars.json`; khoá khác ghi cạnh `char` sẽ ghi đè. Nhân vật mới tạo bằng skill `nhan-vat-chibi` (có sheet soi) rồi mới đưa vào cast.
  - `w`: bề rộng; mặc định teo 250, npc 190. `side:"hero"`: đồng minh của Tèo.
- **scenes[]:**
  - `set` thuộc: san-tap, rung-truc, mai-ngoi, quan-tro, nui-tuyet, ben-song, cau-go, thao-nguyen, hang-dong, tang-kinh-cac, dinh-nui, pho-cho (bảng quy đổi địa danh trong truyện → set nằm ở chu-de.md).
  - `time`: ngay, chieu hoặc dem. `stage`, `weather`, `music`: xem mục Dựng cảnh.
  - `actors[]`: {id, x (tâm, px trên khung 1920), hidden?, w?, foot?}. Vị trí Tèo đổi theo khung (giữa, phải, nhỏ trên cao bằng `w`+`foot`, vắng mặt); không đứng góc trái mọi cảnh.
  - `transition`, `camera`: ép một hiệu ứng cụ thể (không nên dùng).
- **Beat** (mọi beat đều nhận thêm `with: true` để chạy cùng lúc với beat trước, `delay`, và `vo`: lời kể của Tèo đọc thành tiếng nhưng không hiện bong bóng. Beat có `vo` kéo dài ít nhất bằng câu đọc + 0,4 s):

| do | tham số | ghi chú |
|---|---|---|
| `say` | who, text, tone normal/shout/whisper/think, hold, pose, brow | bong bóng thoại; có giọng thì bong bóng hiện đúng bằng thời gian đọc, không có thì tính theo số chữ |
| `emote` | who, kind sweat/anger/?/!/sparkle/sigh/drop | |
| `pose` | who, pose, dur, hold, brow angry/… | tư thế: rest raise windup slash point guard wave(teo) palm up |
| `move` | who, to (x), dur, face | |
| `face` | who, dir left/right | |
| `wait` | dur | |
| `enter` | who, from | nhân vật phải `hidden:true` trong actors |
| `intro` | who, name, title | bảng tên giới thiệu |
| `power` | who | vận công |
| `attack` | who, target (id hoặc mảng), name (có thì hiện caption tên chiêu), finisher, impact | không ghi finisher thì chiêu cuối là kết liễu. Attack có thể đổi chỗ hai người (xuyên qua) |
| `react` | who (id hoặc mảng) | luôn đặt ngay sau attack; tập chủ đề chỉ ra choáng/lùi |
| `caption` | text | chữ dẫn chuyện, kêu gọi đăng ký (không dùng câu công thức cũ) |
| `sfx` | name, vol?, len?, dur? | đặt một tiếng sfx chủ động (chime, riser, pop…) |
| `card` | title, sub?, lines[≤4], side left/right/center, vo? | thẻ thông tin ở dải trên khung. **Luôn được đọc**: `vo` nếu có, không thì đọc chữ trên thẻ. Thẻ ở lại tới hết câu đọc, các dòng hiện dần theo nhịp đọc. Biến thể: cd-scroll, cd-board, cd-bamboo |
| `stat` | left (id), right (id), rows[{label, l, r}] (0–10, ≤4 dòng), total? | bảng so điểm; tên lấy từ cast. Biến thể: st-bars, st-scale, st-tally |
| `local:<tên>` | tuỳ hiệu ứng | hiệu ứng tự chế của tập |
| (bất kỳ) | fx: "<id>" | ép hiệu ứng cụ thể, bỏ qua planner (hạn chế dùng) |

- **Luật keep/removes/down:**
  - React có cờ `removes` (af-fly: văng khỏi khung) bị cấm khi nạn nhân là teo, phe hero, hoặc còn được nhắc ở beat sau.
  - Tập có `story.format` thì mọi react cấm cả cờ `down` (af-ko, af-domino, af-spin, af-flat, af-fly).
  - Hai luật này không bao giờ nới. Nhân vật đang nằm mà được giao beat khác thì tự đứng dậy.

### Rig 2 (nhân vật kiểu mới): `"rig": 2`
Thêm `"rig": 2` vào tap.json (hoặc `build.mjs <dir> --rig 2`) → nhân vật vẽ bằng `engine/rig2.mjs` (chibi mặt anime, khớp lồng nhau). Không ghi = rig cũ, kết quả y hệt trước.
- cast giữ nguyên cách viết cũ (preset/hat/beard/weapon/robe…): build tự đổi sang v2 (preset cùng tên trong rig2.mjs; hat non→non-la, dao→trâm + búi cao, bui/none→tóc theo preset; beard mã màu → rau-dai màu đó).
- Hình v2 nằm đúng hộp w×cao của rig cũ (chân chạm đáy, đỉnh tóc chạm đỉnh) → a.top/a.h/a.cx/koHead, bong bóng thoại, vị trí fx không đổi; đầu ở 0.283·h.
- Lệnh cũ trong fx (POSE R RS BROW KO RUN ATTR FLAP(p,t0,t1) BLINK) chạy qua `engine/compat2.js`: armF→uaF, foreF→faF, armB→uaB, foreB→faB, legR→thF, legL→thB, head/all/tail giữ tên; BROW→EX gian/vui, KO→EX ko. `PIV`/`org()` KHÔNG có ở rig 2.
- fx viết mới cho rig 2 nên gọi thẳng runtime2: `J(id,t,d,góc,dx,dy,ease)`, `JS`, `EX(p,t,"vui|binh|gian|buon|soc|dac-y|ngai|quyet-tam|ko")`, `SWAY`, `NOD`, `PUFF`, `TRAIL`; khớp: all torso head uaF faF hdF uaB faB hdB thF shF ftF thB shB ftB wpF(vũ khí, 180 = nối dài cẳng tay) flapF flapB hairB tail. Rẽ nhánh bằng `ctx.v2`.
- fx chèn đồ vào `<p>-armF` (chổi, gậy…) phải đổi sang `<p>-hdF` (bàn tay, gốc 0,0 toạ độ khớp) khi `ctx.v2`.
- cast rig 2 còn nhận: `eyes` `eyes2` (màu phản sáng đáy mắt) `fem` (nữ; mặc định = có váy) `hair` {style,color} `age` ("gia") `mat` (trục mặt cho ve.mjs).

### Mặt riêng từng tập: `<dir>/ve.mjs` (BẮT BUỘC với tập mới / làm lại)
Không có một kiểu mặt chung cho mọi tập. Mỗi tập tự vẽ đầu nhân vật — mắt, mũi, khuôn mặt, miệng, lông mày — theo một kiểu riêng, và trong tập mỗi nhân vật một mặt khác. Engine chỉ giữ thân, khớp, vũ khí; mặt mặc định của engine chỉ là dự phòng (build cảnh báo khi tập rig 2 thiếu ve.mjs).
- Có `ve.mjs` thì build tự dùng cho mọi rig của tập (cảnh, `ctx.rig`, thumbnail). Cần `"rig": 2`.
- Viết: `export default function ve(p, o, kit) { return svgĐầu; }`
  - toạ độ đầu 300×420: đỉnh tóc y=38, tâm mặt x=150, cằm ~y 265–285 (khớp chỗ đặt sẵn trong thân).
  - `o`: id (cast id) mat (= cast.mat) skin hair{style,color} eyes eyes2 fem age beard beardColor hat hatColor glasses expr.
  - `kit`: dk lt hx toHex st EXPRS SKIN, và tóc/mũ/râu dựng sẵn của engine (hairBack hairFront HAIR beard hat) — dùng hay tự vẽ tuỳ tập; mắt/mũi/khuôn mặt/miệng thì tự vẽ.
- Nhóm bắt buộc (build kiểm, thiếu là dừng):
  - `<p>-mat`: khuôn mặt + mũi (+ tai).
  - `<p>-ex-<e>` cho mỗi e trong vui binh gian buon soc dac-y ngai quyet-tam ko; chỉ nhóm `o.expr || "vui"` có opacity 1, còn lại 0. Mỗi nhóm chứa `<p>-mc-<e>` (miệng khép) và `<p>-mo-<e>` (miệng mở, opacity 0) — runtime bật/tắt khi nói.
  - `<p>-blink` (opacity 0): mí phủ khi chớp.
  - Đặt id gradient/def theo prefix `p` (vd `${p}-ig`) để các nhân vật không đè nhau.
- Chống trùng (build dừng, báo tên):
  - 2 nhân vật cùng tập trùng hình `<p>-mat` hoặc `<p>-ex-binh` (màu không tính) → phân biệt bằng `o.id` hoặc cast `"mat": {...}`.
  - Trùng nhân vật bất kỳ ở tập cùng thư mục cha (`work/ve-fp.json` mỗi tập ghi lại) → tập phải vẽ khác.
  - Giống hệt `examples/ve-mau.mjs` → mẫu chỉ để xem cấu trúc, không chép.
- Mẫu: `examples/ve-mau.mjs` (moe anime: mắt gradient nhiều lớp, mi dày, má gạch; trục `mat: {khuon, mui, mat}` chỉ để xem cấu trúc — khuôn trong mẫu đều tròn: tron|bau|banhbao|mochi; mặt thiết kế theo nhân vật, băm id chỉ là dự phòng). Tập khác nên đổi hẳn cách vẽ (mắt nét mực, mắt chấm, mũi đổ bóng…), không chỉ đổi tham số.
- **Mặt sáng tạo theo nhân vật của kịch bản** (người dùng yêu cầu 2026-10-22). Không bốc mặt từ bảng chọn hay băm theo id. Mỗi nhân vật kịch bản dựng ra thì đọc lại vai, tuổi, tính cách và khoảnh khắc của họ trong tập, rồi thiết kế mặt riêng: mắt (to tròn ngây thơ, híp cười, sụp mi già dặn, trợn lì…), mày, mũi, miệng, nếp má, nốt ruồi, sẹo, râu, tóc mái. Ghi vài dòng lý do cho từng người trong `y-tuong.md` (mục "Mặt nhân vật": người · tính cách · mặt vẽ thế nào). `o.mat` nếu có thì là các nét đã thiết kế cho người đó, không phải trục ngẫu nhiên.
- **Khuôn mặt chibi luôn TRÒN** (người dùng yêu cầu 2026-10-22: "mặt nhọn xấu quá"). Viền mặt là khối tròn/bầu: má đầy, cằm rộng và bo tròn, đáy mặt gần như cung tròn. CẤM cằm nhọn, mặt chữ V, mặt thon/trái xoan dài, hàm vuông góc cạnh, mặt dài. Muốn phân biệt người thì đổi mắt/mày/mũi/miệng/râu/tóc/nếp má, hoặc đổi độ bầu (tròn vo · bánh bao · mochi hơi dẹt) — vẫn tròn. Đáy mặt: dùng cung bezier rộng (vd `C 238 232 200 268 150 270 C 100 268 62 232 …`), không dồn điểm về một đỉnh cằm.
- Luật render vẫn áp dụng: không filter/clipPath/3D trong ve.mjs; gradient tĩnh được.
- Kiểm nhanh không dựng: `node scripts/build.mjs <dir> --ve-check` (chỉ kiểm nhóm + chống trùng, ghi `work/ve-fp.json`). Băm id thì dịch bằng `>>>` (không dùng `>>` — ra chỉ số âm).
- Kiểu đã dùng ở 9 tập hiện có (tập mới tránh lặp): 01 nét bút mực · 02 anime thập niên 90 · 03 mặt tuồng · 04 hình học tối giản · 05 manhua noir nét chì · 06 đất nặn · 07 khắc gỗ Đông Hồ · 08 hoạt hình hạt đậu · 09 màu nước không viền.

## Viết hiệu ứng local `fx/<tên>.mjs`

Mẫu đầy đủ: `SKILL/examples/tap-01/fx/rong-chuong.mjs` (rồng vàng từ chưởng, tự né mặt đối thủ).

```js
export default { cat: "power", label: "Mô tả ngắn", run(ctx, b, t) { /* … */ return { dur: 2 }; } };
```

- `ctx.actor(id)` → {p (prefix rig), wrap/body/inner (id DOM), x, w, h, cx, cy, top, foot, koHead, flip}.
- `ctx.cast[id]`: dữ liệu cast (có `name`).
- `ctx.add(layer, html)`: layer là bg, behind, act, fx, hud hoặc over.
- `ctx.js(code)`: code chạy trên timeline `tl`. Hàm runtime có sẵn: POSE(p, tư thế, t, dur), BROW(p, t, giận), BLINK, KO, POP, STAMP, SHOW, HIDE, FLASH, SHAKE, DRAW, DASHLEN, rand.
- `ctx.uid("x")`: tạo id duy nhất.
- `ctx.theme`: {qi, qi2, light, dark, mid, ink, title}.
- `ctx.pick(arr)`, `ctx.range(a, b)`: ngẫu nhiên theo seed.
- `ctx.sfx(tên, t, vol, dur?)`: tên thuộc chime, click, error, glitch-1, impact-bass-1/2, pop, riser, sparkle, whoosh-cinematic, whoosh-short, whoosh.
- `ctx.moveTo`, `ctx.face`, `ctx.knock(id, dx, side)`, `ctx.gone(id)`, `ctx.attackerSide(a)`, `ctx.others(who)`.
- `ctx.rig(type, prefix, w, look, flip)`: dựng thêm một bản rig (bóng, ảo ảnh).
- **Bắt buộc:** mọi phần tử chỉ được hiện khi tới lượt. Lúc add thì đặt opacity 0 hoặc scale 0, rồi tween hiện lên tại `t`. Lúc xong thì HIDE.
- Hiệu ứng nhắm vào đối thủ phải tính khoảng cách thật lúc chạy (`ctx.actor(target).cx`), vì attack trước đó có thể đã đổi chỗ hai người.
- Mỗi beat trả về `{dur}`.
- Hiệu ứng react mới: thêm `down: true` nếu nạn nhân nằm gục, `removes: true` nếu rời khung (trường của object export; trong `engine/fx.mjs` là tham số thứ 5 của `def`).

### Tốc độ render (bắt buộc với fx local)

hyperframes chụp nhanh bằng drawElement; gặp các mẫu dưới đây nó rớt về chụp màn hình cho **cả tập**, chậm gấp đôi. build.mjs in "⚠ render chậm: …" khi gặp:
- CSS `filter: blur()` / `drop-shadow()` (tĩnh hay tween đều cấm), `mix-blend-mode`, `backdrop-filter`, `@keyframes`/`animation`, CSS 3D (`perspective`, `preserve-3d`, `backface-visibility`).
- Tween `rotationX/Y`, `z`, `clipPath`, `mask`. clip-path tĩnh thì được.
- Callback GSAP (`onUpdate/onComplete/onStart`, `tl.call`): hyperframes tua nhảy không gọi callback, self-verify lệch.
- Filter màu `brightness/grayscale/sepia/saturate/hue-rotate/contrast` vẫn được.

Thay thế: quầng sáng = vẽ thêm 1–2 bản nét to, opacity thấp phía sau (xem `glowStroke` trong `engine/fx.mjs`) hoặc div `radial-gradient` tween opacity; lộ dần = tween `width` của khung `overflow:hidden` (bên trong đặt width cố định); lật = `scaleX`. Vẽ nét dần cho nhóm nhiều nét: đặt `stroke-dashoffset` trên `<g>` và DRAW cái `g`.

Hiệu ứng local nào đẹp và dùng lại được thì chép vào `SKILL/engine/fx-extra/<id>.mjs` (bỏ tiền tố local). Từ tập sau, planner sẽ tự xếp nó vào kho. Không có `id` thì lấy tên file làm id. Id không được trùng.

## Âm thanh

- **Giọng Tèo:** wav từ `voice.mjs`, build đặt vào track 14/15 (xen kẽ cho khỏi chồng), âm lượng 1. Thiếu `voice/voice.json` thì build vẫn chạy nhưng không giọng và in CẢNH BÁO; tập thật bắt buộc có giọng.
- **BGM:** `tap.bgm` (mặc định pizzicato) lặp, 0,06 khi có giọng, 0,1 khi không (ghi đè bằng `bgm_volume`). `scenes[].music` on/low/up/off đổi âm lượng theo cảnh (build tách đoạn nhạc bằng `data-media-start`, nhạc liền mạch). Thêm nhạc: người dùng bỏ file vào `kit/bgm`, không tải từ nguồn lạ.
- **sfx** theo hiệu ứng + beat `sfx` đặt tay.
