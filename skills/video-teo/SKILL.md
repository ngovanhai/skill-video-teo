---
name: video-teo
description: >
  Sản xuất video YouTube explainer hoạt hình 2D tiếng Việt dài trên 20 phút (thường 20–30) do mascot Tèo dẫn (giọng VieNeu "Lóng"),
  từ chọn chủ đề (bắt buộc là người nổi tiếng hoặc sự việc nhiều người biết) → nghiên cứu ≥2 nguồn → kịch bản video.json → nhân vật SVG → TTS/align/build → snapshot → render MP4
  + thumbnail 1280×720 đẹp + tiêu đề chuẩn SEO (đuôi "| Tèo Kể") + gói đăng youtube/ (mp4, thumb, tiêu đề, mô tả, tags, phụ đề .srt). Dùng khi người dùng nói "tạo video", "làm video Tèo",
  "video dài hôm nay", "làm tiếp video", hoặc chạy chế độ sản xuất liên tục. Dùng kit tại __MUSE_ROOT__/kit.
---

# Video Tèo — dây chuyền video dài trên 20 phút

Mày là cả ê-kíp của một kênh YouTube tiếng Việt: biên kịch, họa sĩ, dựng phim, SEO. Mỗi video làm TRỌN gói. Người dùng chỉ việc xem lại rồi tự đăng.

`KIT = __MUSE_ROOT__/kit` · `<SKILL_DIR>` = thư mục chứa file này.

**ĐỌC TRƯỚC (bắt buộc, mỗi phiên):** `KIT/README.md`. Đây là spec định dạng video.json, các loại cảnh, luật kịch bản, nhân vật, thumbnail và publish. Bảng tra cứu nhanh nằm ở `<SKILL_DIR>/reference.md`.

## Luật cứng

- KHÔNG đăng gì lên mạng. KHÔNG gửi tin nhắn cho ai.
- Chỉ sửa thư mục video đang làm, `__MUSE_ROOT__/ideas/` và **thêm** fx mới vào `kit/fx/<ten>.mjs`. KHÔNG sửa template cũ trong `kit/scenes/`, `kit/lib/`, `kit/make.mjs`. Cảnh tự chế (`custom`) để trong `videos/<slug>/scenes/`.
- Không dùng `videos/_pilot` hay `khoi-nguyen-vu-tru-hy-lap` để thử nghiệm.
- Tránh chính trị nhạy cảm, tôn giáo gây tranh cãi, 18+, bạo lực ghê rợn. Phần truyền thuyết phải nói rõ là truyền thuyết.
- Hỏng mà không tự sửa được thì dừng lại, báo rõ lỗi kèm log.

## Chế độ liên tục (mặc định khi người dùng bảo "tạo liên tục")

Xong video này thì làm ngay video kế. Cho các việc chạy chồng lên nhau để máy không lúc nào rảnh:

- Trong lúc video A chạy TTS hoặc render ở nền, viết kịch bản và vẽ nhân vật cho video B. Có thể giao nghiên cứu cho agent nền (research-expert), dặn rõ ≥2 nguồn mỗi dữ kiện và tách riêng mục tranh cãi.
- Các việc nặng CPU chạy tuần tự: không chạy 2 TTS, 2 align hay 2 render cùng lúc. Riêng `thumb` và `validate` nhẹ, chạy song song được.
- Mỗi video xong thì báo người dùng ngắn gọn (mẫu ở mục 9), rồi làm tiếp.

## 1. Chọn chủ đề

**Luật lõi: mỗi video PHẢI xoay quanh một "neo nổi tiếng"**, tức một cái tên mà đa số người Việt đã nghe:

- **(a) Người nổi tiếng:** nhân vật lịch sử, vua chúa, tướng lĩnh, nhà khoa học, nhà phát minh, nghệ sĩ, doanh nhân, vận động viên… (Trần Hưng Đạo, Napoleon, Einstein, Steve Jobs, Pelé).
- **(b) Sự việc nhiều người biết:** trận đánh, thảm hoạ, phát minh, vụ án, kỳ quan, bí ẩn nổi tiếng (Titanic, Chernobyl, Điện Biên Phủ, Tam giác Bermuda, Pompeii).
- Tên neo phải nằm **trong 3 chữ đầu của tiêu đề** (từ khoá SEO), xem mục 5.

**Phép thử "đã nghe tên"** (bắt buộc, ghi kết quả vào `ideas/YYYY-MM-DD.md`). Phải đạt **≥3/4** tiêu chí:

1. Có trang Wikipedia tiếng Việt riêng, nội dung đầy đủ.
2. Có trong sách giáo khoa VN, hoặc là cái tên quen thuộc với đại chúng (phim, sách, báo lớn).
3. WebSearch tên đó bằng tiếng Việt ra nhiều bài báo VN hoặc video YouTube VN nhiều lượt xem.
4. Một người Việt 15–50 tuổi nghe tên là biết ai / chuyện gì.

**CẤM chủ đề kiến thức chung không có neo** (hiện tượng, con vật, đồ vật, cơ thể, khái niệm), ví dụ "Cầu vồng", "Sấm sét", "Ong mật", "Cây lúa". Khoa học và tự nhiên chỉ được làm khi gắn vào người hoặc sự kiện nổi tiếng:

- "Cầu vồng" → *Newton và lăng kính: người bẻ ánh sáng ra 7 màu*
- "Núi lửa" → *Pompeii: thành phố bị chôn sống trong một ngày*
- "Khủng long" → *Tiểu hành tinh đã xoá sổ khủng long*
- "Sấm sét" → *Benjamin Franklin và con diều giữa trời giông*

**Truyện dân gian / thần thoại:** chỉ chọn truyện ai cũng biết (Thánh Gióng, Sơn Tinh Thủy Tinh, Zeus, Tôn Ngộ Không…).

**Góc kể:** chủ đề quen nhưng góc phải lạ. Chọn sự thật trái với điều ai cũng nghĩ, chi tiết đời tư, cái kết, hoặc tranh cãi. Ghi góc kể vào file ý tưởng.

**Quy trình chọn:**

1. Đọc `ideas/DA-LAM.md`. Không trùng hay gần trùng chủ đề cũ, và không làm lại **cùng nhân vật / cùng sự kiện** dù khác góc kể (trừ khi người dùng yêu cầu).
2. WebSearch 2–4 truy vấn:
   - ngày sinh, ngày mất, kỷ niệm sự kiện trong 1–7 ngày tới ("ngày này năm xưa <ngày>")
   - người hoặc sự kiện đang hot: phim, ngày lễ, tin tức có góc lịch sử
   - Không ra gì thì lấy từ "Kho gợi ý chủ đề có neo" trong `reference.md`.
3. Viết **3 ứng viên** (neo, góc kể, mảng). Chấm 1–5 theo 4 tiêu chí:
   - **độ nổi tiếng** (điểm ×2)
   - độ thời sự
   - đủ chất liệu cho hơn 20 phút (nhiều nhân vật, diễn biến, bí ẩn hoặc tranh cãi)
   - điểm chạm Việt Nam
4. Chọn ứng viên tổng điểm cao nhất. Ứng viên nào trượt phép thử "đã nghe tên" thì loại, dù điểm cao.

**Xoay mảng:** không để một mảng xuất hiện 3 lần liền. Các mảng (mảng nào cũng phải có neo):

- nhân vật lịch sử Việt Nam
- nhân vật lịch sử thế giới
- trận đánh / sự kiện lịch sử
- nhà khoa học, nhà phát minh, phát minh nổi tiếng
- thảm hoạ, vụ án, bí ẩn nổi tiếng
- kỳ quan, địa danh nổi tiếng
- truyện dân gian, thần thoại ai cũng biết
- người nổi tiếng hiện đại (doanh nhân, thể thao, nghệ sĩ; tránh người còn sống đang dính tranh cãi)

## 2. Nghiên cứu → `ideas/YYYY-MM-DD.md`

Ngày đó đã có file thì đặt tên `YYYY-MM-DD-2.md`. Nội dung gồm: chủ đề, mảng, lý do chọn, **bảng 3 ứng viên + điểm**, **neo nổi tiếng + kết quả phép thử 4 tiêu chí**, góc kể, dữ kiện chính (mỗi dữ kiện ≥2 nguồn, đánh số nguồn), danh sách nguồn, mục **"Dữ kiện còn tranh cãi"** kèm cách diễn đạt an toàn trong video (ví dụ "theo nhiều bản kể", "đại ý").

## 2b. Sáng tạo mỗi video (bắt buộc, làm TRƯỚC khi viết kịch bản)

Mỗi video phải trông và nghe **khác hẳn** video trước, không chỉ khác chủ đề.

1. Chạy `node __MUSE_ROOT__/kit/fx-list.mjs` (kho fx + số lần dùng gần đây + concept 3 video cuối) và đọc 3 dòng cuối `ideas/DA-LAM.md`.
2. Chốt **concept sáng tạo**, ghi vào `ideas/YYYY-MM-DD.md` **và** vào `video.json`:
   ```jsonc
   "creative": {
     "style": "điều tra phá án",          // cách kể: nhật ký du hành, đếm ngược top, Tèo xuyên không, phỏng vấn nhân vật, tranh luận hai phe, bản tin khẩn, phim tài liệu giả…
     "motif": "hồ sơ mật + mực tàu",       // chất liệu hình: bản đồ cổ, giấy dó, neon, sổ phác thảo, phim cũ, tranh Đông Hồ…
     "hook": "in medias res",              // kiểu hook (mục 3)
     "palette": "dark + red + cream",      // bg/màu chủ đạo
     "signature_fx": ["ink-splash", "spotlight", "old-film"],   // 2–3 fx chủ đạo, ưu tiên mục "chưa dùng gần đây"
     "gag": "Tèo đóng dấu MẬT lên mọi bằng chứng"                // running gag / câu cửa miệng riêng của tập
   }
   ```
3. `style`, `motif`, `hook` KHÔNG trùng 1 trong 2 video gần nhất (validate báo). Phần lớn fx chữ ký không có trong 2 video gần nhất.
4. Lên ý tưởng **≥3 cảnh `custom`** tự vẽ SVG + GSAP hợp chủ đề (trống đồng xoay, thuyền vượt sóng, bản đồ lan màu, cỗ máy chạy…), xem mục 4b. Cần hiệu ứng mà kho chưa có thì viết thêm `kit/fx/<ten>.mjs` (KIT/README.md mục 3b).

## 3. Kịch bản `videos/<slug>/video.json` + `chapters/NN.json`

**Độ dài: video thật PHẢI > 20 phút. Nhắm 5.600–7.000 từ, 120–160 cảnh, 7–10 chương. Đặt `"target_min": [20, 30]`.**

- Validate ước tính 4,1 từ/giây, nhưng giọng Lóng thật đọc khoảng 4,5 từ/giây (cảnh ~45 từ mất ~10 s, cộng 0,55 s đệm mỗi cảnh). Kịch bản 6.500 từ / 142 cảnh ra **~24,6 phút**. 5.600 từ / 125 cảnh ra khoảng 21 phút, vừa đủ an toàn.
- Mỗi cảnh 35–60 từ. Tối đa 70 từ; dưới 10 từ thì giọng bị méo.
- Cue `at` phải là cụm có thật trong `say`. Kit so khớp chữ thường, dấu câu đổi thành khoảng trắng. Viết `at` ngắn 1–4 chữ, lấy đúng chữ trong câu.
- Không quá 2 cảnh cùng `type` đứng liền nhau. Cứ khoảng 6 cảnh có 1 `moment` hoặc `talk`. Nhân vật quan trọng có `intro` khi ra mắt.

Cấu trúc:

1. **Mở đầu: hook → lời chào → hứa hẹn** (5–7 cảnh, 40–60 s):
   - **Hook (cảnh 1–2, ≤15 s), phải thật ấn tượng.** Câu đầu tiên ≤12 từ và "đánh" ngay, không rào đón. Chọn 1 kiểu, **khác kiểu của video trước**:
     - *nghịch lý sốc*: "Có một cái hang to đến mức bên trong có cả mây."
     - *con số gây sốc*: "240 người ra đi. Chỉ 18 người trở về."
     - *in medias res*: thả thẳng vào khoảnh khắc kịch tính ("Năm 1990, giữa rừng sâu, một người đàn ông nghe thấy tiếng gió… thổi ra từ vách đá.")
     - *câu hỏi trực diện*: "Nếu được chọn, các bạn có dám bước vào không?"
     - *lời hứa bí mật*: "Có một chi tiết mà sách giáo khoa không bao giờ kể."
     Cảnh hook có **≥2 fx** (ví dụ `punch` + `speedlines`, `flash` + `shockwave`). Cảnh đó có thể là `hook`, `moment` hoặc `custom`.
   - **Lời chào ngay sau hook (nằm trong 3 cảnh đầu):** luôn có "**Chào các bạn, lại là Tèo đây**", nửa sau biến tấu theo chủ đề và nối về hook. Ví dụ: "Chào các bạn, lại là Tèo đây, và hôm nay mình sẽ cùng các bạn lần theo dấu vết của…", "Chào các bạn, lại là Tèo đây! Cầm chắc đèn pin nhé, vì chuyến này mình chui xuống lòng đất." Mỗi video đổi lời, không chép câu của video trước.
   - 1–2 cảnh `moment`/`quote` hé lộ chi tiết, không giải đáp. Rồi `narrator` hứa hẹn: "xem tới cuối sẽ biết… chi tiết số 3…".
2. **Các phần thân bài**: KHÔNG dùng cảnh `chapter`, KHÔNG đọc "Chương X" / "Chương sau nhé" / "ở chương trước". Video là một mạch liền, file chương chỉ để tổ chức kịch bản. Chuyển đoạn bằng "Tiếp theo…", "Xem tiếp nhé", "lúc nãy". Cứ 2–3 phút cài một vòng mở rồi trả lời ở phần sau. Cảnh cuối mỗi phần phải kéo người xem sang phần kế.
3. **CTA đăng ký giữa video (40–60% số chữ):** một cảnh (thường `narrator`) có `"cta": true` để hiện nút ĐĂNG KÝ + chuông + con trỏ bấm. Lời mời gắn với nội dung, không khô: "Nếu thấy chuyện này hay thì bấm đăng ký kênh Tèo Kể giúp mình nhé, vì đoạn sau còn gắt hơn nhiều…". Đặt ngay trước một bước ngoặt để người xem có lý do ở lại.
4. **Chương cuối**:
   - Tóm tắt các bí ẩn đã hứa.
   - Mời bình luận bằng một câu hỏi.
   - **CTA cuối** (trong 3 cảnh cuối, nên gắn `cta: true` cho cảnh liền trước `outro`): mời đăng ký + bật chuông + bình luận.
   - `outro` hé lộ tập sau.

Validate cảnh báo nếu thiếu lời chào "lại là Tèo" ở 3 cảnh đầu, thiếu "đăng ký" ở giữa hoặc ở cuối, hoặc có cảnh `cta` mà lời không có chữ "đăng ký".

**Hình và hiệu ứng (đây là chỗ tạo khác biệt):**
- **Mật độ fx:** khoảng 1/3 số cảnh có `fx` (tối thiểu 1/4, validate báo). Mỗi `moment` có ≥1 fx. Hook, cảnh custom và các bước ngoặt là chỗ đầu tư nhiều nhất. fx chữ ký của video lặp lại xuyên suốt để tạo bản sắc riêng cho tập.
- Chọn fx theo nghĩa: mưa, sương cho cảnh buồn hoặc bí ẩn; `embers`, `rays` cho chiến công; `old-film`, `light-leak` cho hồi tưởng; `mark` khoanh đúng chữ cần nhấn; `punch`, `pow`, `shockwave` cho cú sốc. Đừng rải fx vô nghĩa.
- **≥3 cảnh `custom`** (mục 4b), rải đều: 1 ở mở đầu, 1 ở giữa, 1 ở cao trào.
- Không có nhịp chương "cố định". Nhịp mẫu trong reference.md chỉ để tham khảo, mỗi video đổi thứ tự các loại cảnh.

Giọng văn: Tèo xưng "mình", gọi người xem là "các bạn". Câu ngắn, đời thường, đùa nhẹ.

Viết cảnh **mỗi cảnh một dòng** trong file chương để sau này chèn, sửa bằng script cho dễ. Mỗi chương một file, `video.json` trỏ `"chapters": ["chapters/01.json", …]`.

## 4. Nhân vật SVG

- Copy `<SKILL_DIR>/scripts/gen-chars.template.mjs` sang `<video>/work/gen-chars.mjs`.
- Sửa map `chars`. Template có sẵn `person()` và các helper tóc, mũ, áo, râu, mày, vũ khí, kính, sách. Đạo cụ (prop) viết SVG thô.
- Chạy `node work/gen-chars.mjs`. Mỗi file phải dưới 4 KB.
- Xem trước bằng một trang HTML ghép tất cả SVG (`work/chars-preview.html`) trong Browser pane.
- Mỗi key trong `cast` phải có file `chars/<key>.svg`. Tèo (`teo`) có sẵn.
- Rà lại: mỗi nhân vật trong cảnh phải trỏ đúng key của người đó. Nhầm key là lỗi hay gặp.

## 4b. Cảnh custom (SVG + GSAP tự vẽ)

- Copy `KIT/examples/custom-scene.mjs` sang `videos/<slug>/scenes/<ten>.mjs`, vẽ lại cho hợp chủ đề. Trong chương: `{"type": "custom", "file": "scenes/<ten>.mjs", "say": "...", ...tham số tự đặt}`.
- Hàm `export default (ctx, kit)` trả `{css, html, js, sfx, bg}`. Runtime có sẵn `tl, q, qa, POP, STAMP, SLIDE, FADE, OUT, DRAW, SHAKE, BOB, FLAP`; kit có `C, esc, r3, fit, charBox, sfx, color`.
- Luật: vẽ trong y < 880 (phụ đề ở dưới); mọi id bắt đầu bằng `${ns}-`; **mọi thứ khởi đầu ẩn** (opacity 0 / scale 0 / dashoffset 1) rồi hiện đúng cue qua `cues.find("cụm chữ", fallback)`; không dùng `Math.random` (build lại phải ra y hệt).
- Nên có chuyển động thật: vẽ nét dần (`DRAW` với `pathLength="1"`), xoay, đổi màu, vật bay theo quỹ đạo, nhân vật trong cast qua `charBox`. Cảnh custom vẫn nhận `fx`, `cta`, `teo`.
- Lỗi import hoặc thiếu export default thì validate báo lỗi. Snapshot **bắt buộc** có mốc rơi vào từng cảnh custom.

## 5. Thumbnail + SEO (bắt buộc đẹp, PHẢI xem ảnh)

`thumb` không phụ thuộc render và chạy ~10 s, nên làm ngay sau khi viết xong video.json:

```bash
node __MUSE_ROOT__/kit/make.mjs <dir> --stage thumb
```

Mở `thumbnail.png` ra xem (Read). Lặp lại tới khi đạt đủ checklist:

- [ ] 1280×720, chữ hook 3–7 từ, **khác tiêu đề**, câu hỏi hoặc nghịch lý, gây tò mò.
- [ ] Chữ ngắt 2 dòng tự nhiên. Kit chia đều theo độ dài; nếu gãy giữa cụm, ví dụ "CÁI / NÀO THẬT", thì đổi câu (ví dụ "Tự trầm hay bị chém?").
- [ ] `highlight` tô vàng 1–2 từ đắt nhất.
- [ ] **Không có gì đè lên mặt nhân vật.** Với 2 nhân vật, vòng đạo cụ đặt ở khoảng trống bên trái giữa ảnh: `"circle_x": 320, "circle_y": 345, "circle_r": 240`. Vòng không được chạm chữ.
- [ ] `arrow: false` nếu mũi tên không chỉ vào thứ gì có nghĩa.
- [ ] Nhân vật chính lớn bên phải, có cảm xúc. Nhân vật tự vẽ không có pose, nên chọn người có biểu cảm hợp (mày nhíu, mắt lo lắng).
- [ ] `series` (nhãn trên cùng) và `sub` (nhãn vàng dưới) ngắn gọn.

**Tiêu đề SEO** (`publish.titles`, 3 phương án; bản đăng thật nằm ở `youtube/seo.json`, xem mục 6b):

- **Dấu ấn kênh:** mọi tiêu đề đăng lên kết thúc bằng `| Tèo Kể` (9 ký tự, script tự gắn). Phần còn lại vì thế **≤ 51 ký tự**.
- **Tên neo nổi tiếng** (người hoặc sự việc, mục 1) phải nằm trong 3 chữ đầu tiêu đề, ví dụ `Napoleon: …`, `Titanic …`, `Trần Hưng Đạo …`.
- **Gợi tò mò** bằng 1 trong 4 kiểu, đổi kiểu giữa các video:
  1. Câu hỏi người xem từng thắc mắc: `Titanic Chìm Vì Đâu? Đêm Cuối Của Con Tàu`
  2. Con số gây sốc: `Magellan: 240 Người Ra Đi, Chỉ 18 Người Về`
  3. Nghịch lý / điều trái trực giác: `Napoleon Không Hề Lùn? Sự Thật Về Hoàng Đế`
  4. "Sự thật / cái kết" khác điều ai cũng nghĩ: `Hai Bà Trưng: Cái Kết Mà Sử Sách Kể Khác Nhau`
- Viết hoa chữ cái đầu mỗi từ. Không clickbait sai sự thật: mỗi lời hứa trong tiêu đề phải được trả lời trong video (đối chiếu `description`/`notes`).
- Tiêu đề, chữ trên thumbnail và câu đầu mô tả là 3 câu KHÁC nhau, bổ sung cho nhau.

Các phần còn lại của `publish`:

- `description`: câu đầu là hook có từ khoá. Thêm 2–3 đoạn tóm tắt, một câu mời bình luận và đăng ký. Mốc chương kit tự chèn.
- `hashtags`: 3–5 cái.
- `tags`: 10–15 từ khoá, có dấu và không dấu.
- `notes`: các dữ kiện người dùng nên kiểm lại trước khi đăng.

## 6. Pipeline

```bash
node __MUSE_ROOT__/kit/make.mjs <dir> --stage scaffold,validate        # sửa tới khi 0 lỗi, 0 cảnh báo
node __MUSE_ROOT__/kit/make.mjs <dir> --stage tts,align,build,lint > <dir>/work/stage2.log 2>&1   # chạy NỀN
```

**Sau TTS, đo thời lượng thật**, đừng tin số ước tính:

```bash
grep -oE "s[0-9]{3} [0-9.]+s in" <dir>/work/stage2.log | awk '{gsub("s","",$2); t+=$2} END {print t/60 + NR*0.55/60 " min"}'
```

Dưới 20 phút thì thêm cảnh (mục 7) rồi chạy lại `tts,align,build,lint`. Chỉ cảnh mới hoặc bị đổi số mới phải đọc lại.

**Snapshot** kiểm tra hình (10–14 mốc, gồm 3, 15, 30 s, cảnh hook, cảnh chào, cả 2 cảnh CTA, **mọi cảnh custom** và vài cảnh có fx):

```bash
cd <dir> && npx --yes hyperframes@0.8.172 snapshot . --at 3,15,30,<…> --no-end -o work/snap --describe false
```

Xem `work/snap/contact-sheet*.jpg`. Thấy chữ tràn, hình đè nhau, cảnh trống, fx che mất nội dung hay đè phụ đề, hoặc nút Đăng ký không rõ thì sửa rồi chạy lại `build,lint`.

**Render** (chạy nền, ~2,7× thời lượng, tức khoảng 70–80 phút):

```bash
node __MUSE_ROOT__/kit/make.mjs <dir> --stage render,thumb,publish > <dir>/work/render.log 2>&1
```

Chết giữa chừng thì chạy lại, chương đã xong được bỏ qua. Thiếu RAM thì thêm `--low-memory`. `publish` tự ghi `ideas/fx-history.json` (stage `fxlog`). Nếu bỏ qua publish thì chạy tay `--stage fxlog` để video sau biết mà né.

**Kiểm tra cuối:**

```bash
ffprobe -v error -show_entries format=duration:stream=codec_type -of compact <dir>/renders/final.mp4
```

Yêu cầu: > 20 phút, có cả stream video lẫn audio. Xem lại `thumbnail.png` và `publish.md`.

## 6b. Gói đăng YouTube → `videos/<slug>/youtube/` (bắt buộc sau render)

1. Viết `youtube/seo.json` (KHÔNG ghi đuôi `| Tèo Kể`):
   ```json
   { "title": "Titanic Chìm Vì Đâu? Đêm Cuối Của Con Tàu", "alts": ["Titanic: 2 Giờ 40 Phút Định Mệnh", "Titanic: Vì Sao Chỉ 706 Người Sống Sót?"] }
   ```
2. Chạy từ `__MUSE_ROOT__`:
   ```bash
   node <SKILL_DIR>/scripts/youtube-pack.mjs videos/<slug> [--drive]     # hoặc --all cho mọi video có seo.json
   ```
   - Thêm cờ `--drive` (hoặc đặt biến môi trường `AUTO_UPLOAD_DRIVE=1`) để tự động sao chép gói `youtube/` vào Google Drive (qua Google Drive Desktop hoặc rclone) ngay khi đóng gói xong thành công.
3. Script tạo trong `youtube/`, mọi thứ chủ kênh cần để đăng:
   - `<slug>.mp4`: hardlink tới `renders/final.mp4` (không tốn thêm ổ đĩa).
   - `thumbnail.png`: PNG 1280×720 < 2 MB (khác chuẩn thì ffmpeg đổi lại).
   - `tieu-de.txt`: dòng 1 bản chính, dòng 2–3 dự phòng / thử A/B, đã gắn `| Tèo Kể`.
   - `mo-ta.txt`: `publish.description` + mốc thời gian + chân trang cố định của kênh + hashtag (`#TeoKe` luôn đứng đầu, tối đa 5).
   - `tags.txt`: `Tèo Kể`, `Kênh của Tèo` + `publish.tags`, cắt vừa 500 ký tự.
   - `phu-de.vi.srt`: phụ đề tiếng Việt dựng từ `words/` (tăng SEO, người xem tắt tiếng vẫn theo được).
   - `DANG-YOUTUBE.md`: bảng file nào dán vào đâu, cài đặt nên chọn, dữ kiện cần kiểm lại (`notes`), mục "⚠ Cần sửa" nếu có lỗi.
4. Script thoát mã 1 nếu tiêu đề > 60 ký tự, mô tả > 5000 hoặc có `<`/`>`, video ≤ 20 phút hay thiếu audio, phụ đề lệch timeline > 1 s. Sửa rồi chạy lại.
5. Mở `tieu-de.txt` và `mo-ta.txt` đọc lại một lượt. Dấu ấn phải đồng nhất: đuôi tiêu đề, `#TeoKe`, chân trang mô tả, avatar, ảnh bìa, hình mờ ở `__MUSE_ROOT__/avatar/`.
6. Mục "Dành cho trẻ em" (COPPA) là quyết định của chủ kênh. Chỉ nhắc, không tự quyết.

## 7. Thêm hoặc sửa cảnh mà không đọc lại cả video

- Cache TTS gắn theo **số thứ tự cảnh** (s001…). Chèn 1 cảnh thì mọi cảnh phía sau bị đánh số lại và phải đọc lại.
- → Muốn kéo dài video thì **chèn cảnh ở các chương cuối**. Cũng có thể nối thêm câu vào cảnh ngắn (≤70 từ), cảnh đó chỉ đọc lại riêng nó.
- Đọc lại toàn bộ 142 cảnh mất khoảng 15 phút TTS cộng align, nên không quá đắt. Nhưng đang render thì đừng sửa.
- Sửa hàng loạt bằng một script node nhỏ (`work/expand.mjs`): đọc chương, `splice` cảnh mới, ghi lại mỗi cảnh một dòng.

## 8. Ghi sổ

Thêm 1 dòng vào bảng `ideas/DA-LAM.md`:

```
| YYYY-MM-DD | <chủ đề> | <mảng> | Đã render — chờ đăng |
```

## 9. Báo cáo (tiếng Việt, xưng tao/mày, ngắn)

- Tiêu đề đề xuất (SEO), thời lượng thật.
- Concept sáng tạo (style / motif / kiểu hook / gag), các cảnh custom đã vẽ, fx chữ ký.
- Đường dẫn thư mục `youtube/` (gói đăng) và `DANG-YOUTUBE.md`.
- Dữ kiện nên kiểm lại (lấy từ `notes`).
- Lỗi hoặc chỗ chưa ổn nếu có.
- Chế độ liên tục: báo đang làm video kế tiếp nào.
