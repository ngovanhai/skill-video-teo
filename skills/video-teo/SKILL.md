---
name: video-teo
description: >
  Sản xuất video YouTube explainer hoạt hình 2D tiếng Việt dài trên 20 phút (thường 20–30) do mascot Tèo dẫn (giọng Tiến Đạt, đọc bằng ZeroTTS),
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
- Không dùng `videos\_pilot` hay `khoi-nguyen-vu-tru-hy-lap` để thử nghiệm.
- Tránh chính trị nhạy cảm, tôn giáo gây tranh cãi, 18+, bạo lực ghê rợn. Phần truyền thuyết phải nói rõ là truyền thuyết.
- Hỏng mà không tự sửa được thì dừng lại, báo rõ lỗi kèm log.

## Chế độ liên tục (mặc định khi người dùng bảo "tạo liên tục")

Xong video này thì làm ngay video kế. Cho các việc chạy chồng lên nhau để máy không lúc nào rảnh:

- Trong lúc video A chạy TTS hoặc render ở nền, viết kịch bản và vẽ nhân vật cho video B. Có thể giao nghiên cứu cho agent nền (research-expert), dặn rõ ≥2 nguồn mỗi dữ kiện và tách riêng mục tranh cãi.
- Các việc nặng CPU chạy tuần tự: không chạy 2 align hay 2 render cùng lúc. Riêng `thumb` và `validate` nhẹ, chạy song song được.
- **TTS chỉ dùng ZeroTTS (người dùng chốt 2026-11-03, bỏ hẳn VieNeu):** giọng **Tiến Đạt** (`"voice": "tiendat"`, giọng nam trẻ có sẵn của ZeroTTS; người dùng chốt 2026-11-03, trước đó là "Lóng" nạp ở `~/.zerotts/voices`); mọi pipeline đọc bằng `kit/py/tts-zerotts.py` (máy nhà: venv `__ZEROTTS_DIR__/.venv`, model int8) hoặc chính file đó trên Colab (`colab-tts.mjs` gửi lên, `synth-zerotts.py`, model fp32 GPU T4). Mỗi cảnh kéo về -20 LUFS; khoá `.key` có tiền tố `zerotts|` nên wav VieNeu cũ được đọc lại. Code trước khi đổi: `kit/_bak-zerotts-20261103/`.
- **TTS (bản dài) và căn chữ chạy trên Google Colab** (từ 2026-10-23, người dùng yêu cầu): `make.mjs --stage tts` gọi `kiem-hiep/_tools/colab-tts/colab-tts.mjs`, `--stage align` gọi `colab-tts.mjs --align` (chạy chính `py/align.py` trên GPU T4, kết quả y hệt CPU) — cùng job, cùng cache với bản máy nhà, không tốn CPU. `chay-nang.sh` cho các stage tới hết `align` chạy ngay, không chờ làn; `build,lint` mới vào làn giong. Colab thu hồi / không tạo được phiên GPU thì `make.mjs` tự làm tts và căn chữ bằng CPU máy nhà (người dùng chốt 2026-11-03, luật chung `colabThenLocal` trong `kit/lib/mix.mjs`); Colab lỗi khác thì `make.mjs` dừng — sửa Colab theo bảng "Lỗi Colab TTS" trong skill teo-kiem-hiep-godot; chỉ thêm `--tts-local` / `--align-local` (làm ở máy nhà) khi người dùng cho phép. Không đặt `COLAB_TTS_GRACE`.
  **Ngoại lệ chốt 2026-10-24: short (`…/shorts/…`) và sửa ngắn (< 30 câu cần đọc/căn sau cache) tự làm ở máy nhà bằng CPU, chỉ bản dài mới lên Colab** (`kit/lib/mix.mjs`, colab-tts `--min` trả mã 75). Short vì vậy vẫn xếp làn giong trong `chay-nang.sh` như cũ.
- **Người dùng chốt 2026-10-29: KHÔNG hiệu ứng âm thanh nào** (whoosh, pop, chime, riser, kèn, sáo, chuông, mõ, chiêng "beng beng"…). Video chỉ có giọng đọc + nhạc nền nhỏ; nhạc nền cũng không có kèn, sáo, chuông, mõ, chiêng, trống — chỉ đàn gảy/dây êm. `kit/lib/mix.mjs` đặt `SFX_ON = false` nên mọi pipeline (kit/make.mjs, build-short, teo-kiem-hiep build, gd-render) bỏ hết sfx dù cảnh/fx/phim.sfx() có khai báo. Không tự bật lại. Video đã render mà còn sfx: `node kit/remix-audio.mjs <dir>` (video-teo; short: `<dir short> --short`) hoặc `gd-render.mjs <tap> --audio-only` (Godot) — chỉ dựng lại tiếng, giữ hình. Nhạc tập Godot chỉ đàn gảy: `python kit/py/nhac-gay.py <tap>/godot` (dùng python có numpy/soundfile, vd. VieNeu-TTS/.venv).
- **Luật âm thanh (người dùng chốt 2026-10-24, `kit/lib/mix.mjs`):** không sfx "ùm ùm tùm tùm" gây giật mình; sfx luôn nhỏ hơn giọng; nhạc nền nhỏ hơn hẳn giọng. `kit/sfx` là bản êm (`kit/sfx-soft.mjs`: lọc trầm < 180 Hz, ≤ -26 LUFS, đỉnh ≤ -12 dBFS; bản gốc ở `kit/sfx/_goc/`), build tự chép đè vào `assets/sfx` và kẹp `vol` sfx ≤ 0,6; nhạc nền tự đo và kẹp ≤ -40 LUFS (thấp hơn giọng ≥ 20 dB) — `bgm_volume` chỉ hạ được, không vượt trần. Không thêm sfx mới chưa qua `sfx-soft.mjs`.
- Mỗi video xong thì báo người dùng ngắn gọn (mẫu ở mục 9), rồi làm tiếp.
- **Chỉ tiêu hàng ngày (người dùng chốt 2026-11-06):** Giới hạn **1 video / ngày** cho kênh Lại Là Tèo Đây (cùng với 1 video / ngày cho Tèo Tửu Lâu, tổng 2 video/ngày cho cả hệ thống). Chạy vào ca tối hàng ngày (19:00 tạo video, 20:00 đăng video).
- **KHÔNG LÀM SHORTS (chủ kênh chốt 2026-10-29):** Kênh Lại Là Tèo Đây bỏ toàn bộ các bước làm Short (kịch bản short, giọng short, dựng short, render short). `yt-auto` cấu hình `min_shorts = 0` và `"tat_shorts": true`. Gói `youtube/` hoàn chỉnh khi có video dài + thumbnail.png + tieu-de.txt + mo-ta.txt + tags.txt.
- **Lời mời tương tác ngay sau hook (người dùng chốt 2026-11-05):** Ngay sau đoạn hook mở đầu, luôn có một câu hỏi người xem muốn kênh làm về ai hoặc sự kiện/ý tưởng nào thì comment để kênh làm, kết hợp kêu gọi like và follow/đăng ký kênh.
- Trước khi tạo `videos/<slug>`, phải kiểm tra slug chưa có ai làm (thư mục chưa tồn tại, DA-LAM chưa có dòng đó). Không ghi vào thư mục của session khác.
- Cứ 2 tiếng báo cáo người dùng một lần: số video đã xong hôm nay trên chỉ tiêu 10, từng video đang ở bước nào, dự kiến xong lúc mấy giờ, lỗi nếu có.

## 1. Chọn chủ đề

**Luật lõi: mỗi video PHẢI xoay quanh một "neo nổi tiếng"**, tức một cái tên mà đa số người Việt đã nghe:

- **(a) Người nổi tiếng:** nhân vật lịch sử, vua chúa, tướng lĩnh, nhà khoa học, nhà phát minh, nghệ sĩ, doanh nhân, vận động viên… (Trần Hưng Đạo, Napoleon, Einstein, Steve Jobs, Pelé).
- **(b) Sự việc nhiều người biết:** trận đánh, thảm hoạ, phát minh, vụ án, kỳ quan, bí ẩn nổi tiếng (Titanic, Chernobyl, Điện Biên Phủ, Tam giác Bermuda, Pompeii).
- Tiêu đề **mở đầu bằng cụm từ khoá chứa tên neo**, đúng thứ tự chữ người ta gõ, xem mục 5. Tên neo quá lớn (Ronaldo, Quang Trung, Kim Tự Tháp…) thì phải có góc hẹp mà người ta có gõ, vì cụm rộng không chen được vào top tìm kiếm.

- **Ưu tiên chủ đề ké được (luật chung mục 1e).** Trước khi chọn chủ đề hoặc loạt mới, chạy `python3 __MUSE_ROOT__/yt-auto/tools/kiem-hang.py --dang-len=lai-la-teo-day`. Nếu một video đang lên cùng mảng (văn học Việt Nam, lịch sử "toàn bộ / trong N phút" của Văn Vở, Vui Vẻ…) trùng chủ đề mà mình có góc kể riêng, thì chọn chủ đề đó và làm sớm. Tiêu đề mang cụm đặc trưng của video đó, không chép nguyên. Ghi link video đã ké vào `ideas/YYYY-MM-DD.md`.

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

Mỗi video phải **khác video trước ở cấu trúc kể, giọng kể và hình**, không chỉ khác chủ đề. Đã có lúc 10 tập liền dùng chung một bộ xương: hook "Vậy…?" → "Chào các bạn, lại là Tèo đây, hôm nay Tèo khoác áo…" → "ba câu hỏi. Một… Hai… Và ba" → kể từ sinh tới mất → CTA giữa "đoạn sau còn gắt hơn" → "điểm lại ba điều đã hứa" → "Tập sau…". **Đó chính là thứ phải tránh.**

1. **Chống lặp:** chạy `node __MUSE_ROOT__/kit/fx-list.mjs`. Lệnh in kho fx, số lần dùng gần đây và bảng **5 tập gần nhất** gồm: tên khung, trục khung, vai Tèo, kiểu hook, câu chào, câu CTA, câu kết, thông số thumbnail. Đọc thêm 5 dòng cuối `ideas/DA-LAM.md`.
2. **Khung kể: phân tích kịch bản rồi mới tạo khung. KHÔNG có danh sách khung để chọn.** Mỗi video, khung sinh ra từ chính chất liệu của video đó. Làm theo thứ tự:
   1. **Kịch bản thô trước.** Gom hết chất liệu đã research vào mục **"Kịch bản thô"** trong `ideas/YYYY-MM-DD.md`, chưa cần thứ tự: các sự kiện và cảnh, lời nói nổi tiếng (tối đa 1 câu trích nguyên văn), con số đắt sẽ được phóng to, các khoảnh khắc mạnh nhất, những điều người xem hay tranh cãi hoặc hiểu sai.
   2. **Phân tích**, ghi vào mục **"Phân tích"**. Trả lời từng câu:
      - Lõi của chuyện này là gì: một cuộc đối đầu, một bí ẩn, một phát minh, một hành trình, một món đồ, một sai lầm, một cuộc chạy đua với thời gian, hay một lời đồn sai?
      - Cảm xúc chủ đạo là gì, và nó đổi thế nào từ đầu tới cuối?
      - Khoảnh khắc mạnh nhất nằm ở đâu? Có nên mở bằng chính nó không?
      - Ai đứng gần nhất để kể chuyện này? Có thể là một nhân chứng, một người phụ việc, một món đồ, một nơi chốn, hoặc chính Tèo.
      - Người xem đang muốn biết gì, và đang hiểu sai hay cãi nhau về điều gì?
      - Chất liệu tự nhiên chia thành những khối nào: theo thời gian (xuôi hay ngược), theo từng người, theo từng nơi, theo từng câu hỏi, theo từng bằng chứng, hay theo từng con số?
   3. **Thiết kế khung** từ câu trả lời, ghi vào `creative.frame` (object, không phải tên rút gọn):
      - `name`: tên khung tự đặt riêng cho video, bám chất liệu (ví dụ "sổ lương của người thợ xây kim tự tháp"), không phải nhãn chung như "phá án".
      - `analysis`: tóm tắt phân tích ở bước 2 và vì sao khung này hợp (≥25 chữ).
      - `axis`: trục sắp xếp thân bài. Đây là thứ quyết định thứ tự.
      - `open` / `close`: cách mở và cách kết, rút ra từ khoảnh khắc mạnh nhất và cảm xúc cuối.
      - `segments`: 6–10 khối thân bài, mỗi khối một câu. Đây là dàn để chia `chapters/NN.json`.
   4. **Kiểm tra:** dàn khung này có dùng lại được cho video khác bằng cách chỉ thay tên nhân vật không? Nếu được thì khung còn quá chung, phải bám chất liệu hơn. Kể thẳng từ sinh tới mất chỉ được khi phân tích cho thấy chính nhịp đời người là lõi chuyện, và khi đó vẫn phải có người kể hoặc góc nhìn riêng.

   Khung quyết định thứ tự thân bài, cách mở, cách kết, vai Tèo và loại cảnh làm xương sống. Một khung chỉ được tính là đã dùng khi nó **chạy suốt video**: dán nhãn ở đầu/cuối rồi giữa video kể kiểu tiểu sử thì không tính. Validate (`make.mjs --stage validate`) báo khi: `creative.frame` thiếu phần nào hoặc chỉ là một cái tên; `analysis` dưới 25 chữ; tên khung hoặc trục gần giống 1 trong 3 tập gần nhất; dàn khung (axis/open/close/segments) giống ≥45% một trong 3 tập gần nhất.
3. **Vai của Tèo** (`voice_role`, chữ tự do) rút ra từ khung: người trong cuộc, người hỏi, người ghi chép, người dẫn đường, hay vắng mặt và chỉ lồng tiếng. Không gần giống 2 tập gần nhất (validate so độ giống chữ). Mỗi vai có thói quen nói riêng như câu cửa miệng, cách gọi người xem, nhịp câu. Tèo vẫn xưng "mình". **`voice_role` chỉ đổi lời văn, KHÔNG đổi giọng đọc: luôn `"voice": "tiendat"`.**
4. Ghi concept vào `ideas/YYYY-MM-DD.md` **và** `video.json`. Mỗi trường tự nghĩ ra từ phân tích, không lấy lại giá trị của 5 tập trước:
   ```jsonc
   "creative": {
     "frame": {
       "name": "<tên khung tự đặt>",
       "analysis": "<tóm tắt phân tích + vì sao khung hợp, ≥25 chữ>",
       "axis": "<trục sắp xếp thân bài>",
       "open": "<cách mở>",
       "close": "<cách kết>",
       "segments": ["<khối 1>", "<khối 2>", "…"]
     },
     "voice_role": "<vai của Tèo, chữ tự do>",
     "style": "<một câu mô tả cách kể>",
     "motif": "<chất liệu hình chủ đạo>",
     "hook": "<kiểu hook, mục 3>",
     "hook_visual": "<hình chủ đạo + chuyển động của hook, khác 3 tập trước>",
     "palette": "<màu nền chủ đạo>",
     "signature_fx": ["<fx>", "<fx>"],
     "gag": "<running gag riêng của tập>",
     "visual": {
       "medium": "<ngôn ngữ hình của tập, rút từ kịch bản: HUD đo thời gian, sổ kế toán, bản vẽ kỹ thuật, tranh khắc gỗ, bàn cờ, hồ sơ cảnh sát…>",
       "why": "<vì sao chất liệu này sinh ra ngôn ngữ hình đó, ≥15 chữ>",
       "layout": "<bố cục khung hình chung: lưới, điểm nhìn, chỗ đặt chữ, chỗ đặt nhân vật>",
       "palette": ["#hex", "#hex", "#hex"],
       "font": "<font chữ tiêu đề + chữ thường>",
       "kit": "scenes/_<ten>.mjs",
       "scene_kit": ["<loại cảnh 1>: <dùng khi nào>", "…6–12 loại"]
     }
   }
   ```
   Chọn luôn **diện mạo** hợp khung, đặt ở gốc `video.json`: `"theme"` (giay-do, o-ly, bang-den, noir, tron; hoặc không đặt để dùng lưới cổ điển), `"bgm"` (file trong `kit/bgm` hoặc trong thư mục video, nếu chủ kênh đã bỏ nhạc vào). Theme chỉ ảnh hưởng cảnh template và phụ đề (mục 2c); không trùng 2 tập gần nhất (`fx-list.mjs` in cột theme). Theme, phụ đề và nhạc chọn theo cảm xúc và chất liệu đã phân tích, không theo tên khung.
5. Ghi mục **"Tập này khác 5 tập trước ở đâu"** (≥5 điểm cụ thể: khung và trục, mở, kết, vai Tèo, thumbnail, **hệ hình: medium, bố cục, màu, font, bộ cảnh**…). Validate còn báo nếu `style`/`motif`/`hook` trùng 2 tập gần nhất.
6. **Thiết kế hệ hình riêng của tập (`creative.visual`), mục 2c.** Đây là bước quyết định video trông khác hẳn tập trước. Cần hiệu ứng kho chưa có thì viết `kit/fx/<ten>.mjs` (KIT/README.md mục 3b).

## 2c. Hệ hình riêng từ kịch bản (KHÔNG dùng template làm xương sống)

**Vì sao:** các cảnh template của kit (`narrator`, `intro`, `talk`, `group`, `timeline`, `list`, `stat`, `quote`, `versus`, `place`, `moment`, `hook`) vẽ ra cùng một bố cục cho mọi chủ đề. Đã có 40/45 tập dựng ~90–100% bằng template, nên đổi chủ đề, đổi theme mà video vẫn trông y nhau. Từ giờ **mỗi tập tự dựng bộ cảnh của riêng nó**, giống tập Tesla Roadster (khung HUD tua chậm, 98/99 cảnh custom).

1. **Đọc kịch bản thô + phân tích (mục 2b) rồi hỏi: "Câu chuyện này tự nó trông như thứ gì?"** Ngôn ngữ hình phải mọc ra từ chất liệu, không chọn từ danh sách:
   - chuyện đo từng phần nghìn giây → màn hình HUD, đồng hồ đo, khung hình tua chậm
   - chuyện một con tàu chìm → bản vẽ mặt cắt boong tàu, nhật ký điện báo, mực nước dâng
   - chuyện một vị tướng → sa bàn, quân cờ gỗ, mũi tên mực son
   - chuyện một nhà khoa học → trang sổ thí nghiệm, ống nghiệm, nét bút chì
   - chuyện dân gian → tranh Đông Hồ, rối nước, khắc gỗ
   Đây chỉ là ví dụ để hiểu cách nghĩ. Hai tập cùng mảng (hai vị tướng) vẫn phải ra hai ngôn ngữ hình khác nhau, vì kịch bản khác nhau.
2. **Chống lặp:** `medium`, `layout`, `palette` (màu chủ đạo) và `font` khác **5 tập gần nhất** (xem `creative.visual` trong video.json của 5 tập đó và cột custom của `fx-list.mjs`). Không copy file `scenes/` của tập cũ rồi đổi màu.
3. **Viết module phong cách dùng chung** `scenes/_<ten>.mjs` (tên bắt đầu bằng `_`, không phải cảnh): export bảng màu `P`, `FONT`, khung nền / viền / lưới chung, và các hình vẽ dùng lại nhiều lần của tập (con tàu, sa bàn, chiếc xe, trang sổ…). Mọi cảnh của tập import từ đây, nên cả video thống nhất một phong cách.
4. **Bộ cảnh của tập (`scene_kit`): 6–12 loại cảnh custom tự đặt tên theo ngôn ngữ hình**, mỗi loại một file `scenes/<ten>.mjs` nhận tham số từ JSON và dùng lại nhiều lần. Bộ cảnh phải phủ đủ các việc một video cần, mỗi việc làm theo kiểu riêng của tập:
   | việc cần | kiểu template cũ (KHÔNG dùng) | ví dụ kiểu riêng (Tesla) |
   |---|---|---|
   | mở đoạn, chuyển đoạn | `chapter`/`moment` | `khung-giay` — khung tua chậm T+0,X s |
   | giới thiệu nhân vật | `intro` | `ho-so` — thẻ hồ sơ trên HUD |
   | lời thoại / trích dẫn | `talk`/`quote` | `loi-noi`, `bo-dam` — bộ đàm |
   | con số | `stat` | `so-lon` — đồng hồ số + kim |
   | so sánh | `versus` | `hai-lan`, `doi-chieu` |
   | mốc thời gian | `timeline` | `duong-dua` — đường đua có cột mốc |
   | giải thích cơ chế | `list`/`narrator` | `ban-ve`, `vec-to-luc` |
   | Tèo dẫn chuyện | `narrator` | Tèo `charBox` trong cảnh custom của tập |
   | gag / lời nhân vật phụ | `talk` | `bien-lai` — khách gọi tới |
   Tên và kiểu trong cột cuối **chỉ là ví dụ của một tập**, tập sau phải tự nghĩ bộ khác.
5. **Tỉ lệ:** cảnh `custom` **≥ 85%** số cảnh. Template chỉ được dùng ở chỗ thật sự cần và không làm lộ "bộ mặt kit": `outro`, hoặc vài cảnh lẻ mà bộ cảnh của tập không có loại phù hợp (ghi lý do trong ý tưởng). **Không dùng template `narrator`, `intro`, `stat`, `timeline`, `versus`, `quote`, `list`, `place`, `moment`, `hook`** trừ khi ghi rõ vì sao. Validate chỉ báo khi custom < 3, nên tự đếm: `grep -oh '"type": *"[a-z]*"' chapters/*.json | sort | uniq -c`.
6. **Đa dạng trong tập:** không để một loại cảnh custom chiếm > 25% số cảnh, không 3 cảnh cùng file đứng liền nhau. Mỗi loại cảnh nên có vài biến thể qua tham số (màu, `focus`, `mode`, số dòng) để lần dùng sau không y hệt lần trước.
7. Ghi vào `ideas/YYYY-MM-DD.md` mục **"Hệ hình"**: medium + lý do, phác bố cục, bảng màu, font, bảng `scene_kit` (tên file · việc · tham số JSON · chuyển động chính).

## 3. Kịch bản `videos/<slug>/video.json` + `chapters/NN.json`

**Độ dài: video thật PHẢI > 20 phút. Nhắm 5.600–7.000 từ, 120–160 cảnh, 7–10 file chương. Đặt `"target_min": [20, 30]`.**

- Validate ước tính 4,1 từ/giây, nhưng giọng thật đọc khoảng 4,5 từ/giây (cảnh ~45 từ mất ~10 s, cộng 0,55 s đệm mỗi cảnh). Kịch bản 6.500 từ / 142 cảnh ra **~24,6 phút**. 5.600 từ / 125 cảnh ra khoảng 21 phút, vừa đủ an toàn.
- Mỗi cảnh 35–60 từ. Tối đa 70 từ; dưới 10 từ thì giọng bị méo.
- Cue `at` phải là cụm có thật trong `say`. Kit so khớp chữ thường, dấu câu đổi thành khoảng trắng. Viết `at` ngắn 1–4 chữ, lấy đúng chữ trong câu.
- Không quá 2 cảnh cùng **file cảnh** đứng liền nhau. Nhân vật quan trọng có cảnh giới thiệu khi ra mắt, dựng bằng loại cảnh "giới thiệu" trong bộ cảnh của tập (mục 2c), không dùng template `intro`.
- **Cảnh dựng bằng bộ cảnh của tập (mục 2c):** `custom` ≥ 85%. Hệ hình và khung quyết định loại cảnh nào làm xương sống, ghi rõ trong ý tưởng. Nếu lỡ dùng template thì `narrator` vẫn **≤ 20%** (validate báo). Dành các cảnh bước ngoặt cho chỗ thật sự có bước ngoặt, đừng rắc đều mỗi 2–3 cảnh.

### Mở đầu (≤ 60 s)

**Luật giữ chân 60 s đầu (người dùng chốt 2026-10-24, kèm số liệu thật của kênh): đọc `__MUSE_ROOT__/ideas/HOOK-MO-DAU.md` trước khi viết chương 1.** Tóm tắt: 0–5 s là hình đắt nhất và 1 câu khớp ảnh bìa. 5–15 s là một câu hỏi cụ thể. 15–30 s là lý do phải xem và một lời hứa cụ thể. Diễn biến đầu tiên bắt đầu **trước giây 45**. Câu ≤ 15 chữ, ≤ 1 con số mỗi câu. Tèo tự giới thiệu ≤ 1 câu, thể hiện vai bằng hành động. Tiểu sử và tranh cãi số liệu để sau phút 3. Mở bằng "Khoan…", tự giới thiệu theo công thức, và cá cược bằng đồ vật: mỗi kiểu tối đa 1 lần trong 5 tập. 3 tập cùng loạt phải mở theo 3 kiểu khác nhau.

- **Hook ≤ 15 s, câu đầu ≤ 12 từ, vào thẳng. Mỗi video một hook riêng, sinh ra từ chính kịch bản, phải gây ấn tượng ngay 3 giây đầu.**
  1. **Đọc kịch bản trước, rồi mới thiết kế hook.** Tìm **hình ảnh đắt nhất của riêng câu chuyện này**: một đồ vật (quả vải, chiếc nhẫn, lá thư), một khoảnh khắc (tiếng súng, con tàu nghiêng), một con số, một âm thanh. Ghi vào `ideas/YYYY-MM-DD.md` mục **"Hook"**: hình chủ đạo, vì sao nó đắt, từng nhịp lời đọc ứng với biến đổi hình nào, cú chốt cuối. Ghi `creative.hook` (kiểu hook) và `creative.hook_visual` (một câu mô tả hình + chuyển động).
  2. **Hook là cảnh `custom` vẽ riêng, cùng ngôn ngữ hình của tập** (`scenes/hook-<ten>.mjs`, import `_<ten>.mjs`, đặt `"hook": true`, thường `"teo": false`):
     - Hình chủ đạo chiếm ≥ 40% khung, ở giữa hoặc chiếm trọn, **không** nằm lọt thỏm ở góc.
     - **Mỗi nhịp lời đọc là một biến đổi hình** (phóng to, xoay, nứt, lật, đổi màu, cháy, rơi, đèn rọi, nhãn chỉ chi tiết…). Không để hình đứng yên quá 2 s.
     - Có **cú chốt thị giác** ở cuối hook: tên vụ việc đóng dấu xuống, hình biến đổi lần cuối (nứt, vỡ, lật mặt sau), hay một twist hiện ra.
     - Lời và hình khớp tuyệt đối: lời bảo "nhìn kỹ X" thì X phải to giữa màn hình ngay lúc đó.
  3. **Không dùng template `type: "hook"`** (thẻ chữ + Tèo đứng góc): nó giống nhau ở mọi tập. Chủ đề không có đồ vật đắt thì lấy một con số, một câu nói hay một âm thanh làm hình chủ đạo, vẫn vẽ bằng custom.
  4. **Không lặp:** kiểu hook **và** bố cục/chuyển động hook (`hook_visual`) khác 3 tập gần nhất (`fx-list.mjs` in kiểu hook các tập trước). Không copy cảnh hook của tập cũ rồi đổi hình.
  5. Hook có **≥ 2 fx** chọn theo nghĩa của hình (không rắc cho đủ số).
  6. **Kiểm bắt buộc:** snapshot ≥ 4 mốc trong hook (mỗi nhịp một mốc) và tự hỏi: "người đang lướt có dừng lại ở giây thứ 3 không?". Chưa thì làm lại: hình to hơn, chuyển động gắt hơn, cú chốt rõ hơn.

  Gợi ý kiểu hook (không giới hạn, tự nghĩ kiểu mới càng tốt): nghịch lý sốc · con số gây sốc · in medias res · câu hỏi trực diện · lời hứa bí mật · cold open bằng thoại nhân vật (không có Tèo) · âm thanh / im lặng rồi một câu · trailer giả · "lời đồn sai" rồi gạch đi · người xem đóng vai · đếm ngược · chi tiết nhỏ xíu phóng to.

  **Không** kết hook bằng "Vậy…?" nếu tập trước đã làm vậy.
- **Lời chào dấu ấn kênh** "Chào các bạn, lại là Tèo đây" phải có, nhưng **đặt ở đâu trong 60 s đầu và nói theo kiểu nào là tuỳ khung**. Ví dụ: nhân vật giới thiệu Tèo, Tèo chen ngang bản tin, Tèo bước vào phòng xử. Khi Tèo nói câu chào, **Tèo phải hiện trên hình** (cameo, `charBox` trong cảnh custom, hoặc cảnh có Tèo) theo đúng vai của khung, không để cảnh chào trống người. Không mở bằng công thức "hôm nay Tèo [khoác áo / làm] + đạo cụ" nếu 1 trong 5 tập trước đã dùng. Câu chào cũ in ở `fx-list.mjs`, cấm trùng.
- **Lời mời đầu video (người dùng chốt 2026-11-05, bắt buộc mọi tập):** đặt **ngay sau đoạn hook ban đầu** (cảnh đầu tiên sau các cảnh `"hook": true`, trước hoặc gộp cùng câu chào), Tèo nói gọn (1–2 câu, mỗi câu ≤ 15 chữ, tổng ≤ 8 s) hai ý: **(1) mời mọi người bình luận muốn Tèo làm video về ai / ý tưởng nào**, **(2) kêu gọi like và đăng ký (theo dõi) kênh**. Lời phải có chữ "bình luận", "like" và "đăng ký" hoặc "theo dõi". Nói theo giọng khung, mỗi tập tự viết câu, không chép câu tập trước; Tèo hiện trên hình lúc nói. Không thay thế CTA giữa và cuối video. Không để lời mời đẩy diễn biến đầu tiên ra sau giây 45: hook gọn, chào + mời gộp ngắn.
- **Hứa hẹn:** **CẤM** công thức "Xem tới cuối, các bạn sẽ có câu trả lời cho ba câu hỏi. Một… Hai… Và ba". Thay bằng kiểu khác mỗi tập: một câu hỏi duy nhất, một câu đố, một vật bí ẩn sẽ được mở ở cuối, một lời cá cược với người xem (tối đa 1 lần trong 5 tập, vì mẫu "mình cá với các bạn đúng <đồ vật>" đã thành khuôn), hoặc không hứa gì mà vào thẳng chuyện. Lời hứa phải **cụ thể** (nói rõ cuối video sẽ thấy gì), không mơ hồ kiểu "một chuyện không ai ngờ".

### Thân bài

- KHÔNG dùng cảnh `chapter`, KHÔNG đọc "Chương X" / "Chương sau nhé" / "ở chương trước". Video là một mạch liền, file chương chỉ để tổ chức kịch bản.
- Đi đúng thứ tự `creative.frame.segments`. Chuyển đoạn bằng ngôn ngữ của khung: "phiên tiếp theo", "điểm cầu thứ hai", "mục số 4", "trang nhật ký ngày…". Đừng dùng mãi "Tiếp theo…".
- Cứ 2–3 phút cài một câu hỏi mở rồi trả lời ở phần sau. Cảnh cuối mỗi phần kéo người xem sang phần kế.
- Khung, vai Tèo và gag phải xuất hiện **đều trong suốt video**, không chỉ ở đầu và cuối.

### Mời đăng ký

- **Giữa video (25–75% số chữ):** một cảnh có `"cta": true` (nút ĐĂNG KÝ + chuông + con trỏ), lời có chữ "đăng ký". Viết **bằng giọng của khung**: giải lao giữa phiên toà, "quảng cáo" giữa bản tin, nghỉ giữa hiệp, tờ nhật ký kẹp phiếu đăng ký… Đặt trước một bước ngoặt. Không dùng lại khung câu "Nếu thấy … hay thì bấm đăng ký… vì đoạn sau còn gắt hơn" hay "Mỗi lượt đăng ký là thêm một…" nếu 5 tập trước đã có.
- **Cuối video (trong 3 cảnh cuối):** mời đăng ký + bật chuông, cũng theo giọng khung.

### Kết

Kết theo khung. **Không mặc định "điểm lại ba điều đã hứa"**. Chọn một kiểu khác 2 tập gần nhất:
- phán quyết
- cú twist cuối
- quay về đúng cảnh mở đầu (vòng tròn)
- câu hỏi để ngỏ
- nhân vật nói lời cuối
- đồ vật trở về chỗ cũ
- bảng điểm / kết quả trò chơi

Mời bình luận bằng **một** câu hỏi gắn với kết đó. Không bắt buộc kiểu chọn A/B/C. `outro` hé lộ tập sau mỗi lần một kiểu (hình bóng, đồ vật, câu đố, tên thật nếu đã biết). Không lặp "một … nổi tiếng khác, với một bí mật / cách kể hoàn toàn mới".

Validate cảnh báo nếu thiếu "lại là Tèo" trong ~60 s đầu, thiếu lời mời đầu video (bình luận + like + đăng ký/theo dõi) ở cảnh ngay sau hook, thiếu "đăng ký" ở giữa (25–75%) hoặc ở cuối, cảnh `cta` không có chữ "đăng ký", có cụm "ba câu hỏi", hoặc câu chào / CTA giống tập trước.

**Hình và hiệu ứng:**
- **Mật độ fx:** khoảng 1/3 số cảnh có `fx` (tối thiểu 1/4, validate báo). Hook, cảnh custom và các bước ngoặt là chỗ đầu tư nhiều nhất. fx chữ ký của tập lặp lại xuyên suốt để tạo bản sắc riêng.
- Chọn fx theo nghĩa của cảnh, nhưng **đừng dùng mãi một cặp cho một cảm xúc**: xem cột "dùng gần đây" trong `fx-list.mjs` và ưu tiên fx chưa dùng.
- Toàn video dựng bằng bộ cảnh riêng của tập (mục 2c, 4b). Chuyển động, khung viền, chữ, màu đều đến từ `scenes/_<ten>.mjs`, nên tắt tiếng đi người xem vẫn nhận ra đây là tập nào.
- `theme` của kit chỉ đổi nền / phụ đề của cảnh template. Với tập toàn custom thì nền do `bg` của từng cảnh custom quyết định; vẫn đặt `theme` hoặc không, miễn hợp màu của hệ hình.

**Giọng văn:** Tèo xưng "mình", gọi người xem "các bạn". Câu ngắn, đời thường, đùa nhẹ, nhưng **nhịp và thói quen nói đổi theo `voice_role`**: phóng viên nói gấp, ngắn; thẩm phán trịnh trọng; học trò hỏi ngây ngô.

Viết cảnh **mỗi cảnh một dòng** trong file chương để sau này chèn, sửa bằng script cho dễ. Mỗi chương một file, `video.json` trỏ `"chapters": ["chapters/01.json", …]`.


## 4. Nhân vật SVG (chibi phẳng, kiểu cũ)

**Dùng bộ cũ** `<SKILL_DIR>/scripts/gen-chars.template.mjs`: chibi đầu to, tô phẳng, viền đen `#111` dày 6, khung 300×420, má hồng, mắt chấm. **Không dùng `gen-chars.anime.mjs`** (chủ kênh chọn quay về kiểu cũ, 2026-10-21).

1. **Bảng thiết kế trước khi vẽ** (ghi vào `ideas/YYYY-MM-DD.md`), mỗi nhân vật một dòng: tuổi, tính cách, màu áo (`robe`/`sleeve`), tóc hoặc mũ, lông mày (biểu cảm), râu, đạo cụ.
   - **Không có 2 nhân vật trùng cả màu áo lẫn tóc/mũ.** Nhìn là đoán được thời đại và vai: vua đội `crown`, tướng `helmet` + `armor`, học giả châu Âu `wig` + `tricorn` + `coat`…
2. Copy `gen-chars.template.mjs` sang `<video>/work/gen-chars.mjs`, sửa map `chars` (mục `EDIT HERE`). Mỗi người là `person({...})` với các mảnh có sẵn:
   - tóc / mũ: `femaleHair`, `shortHair(c)`, `wig()`, `turban(c)`, `maleKhan(c)`, `hanHat(c)`, `helmet(c)`, `crown`, `phoenix`, `tricorn()`; cờ `bun`, `longHair`
   - lông mày: `angry`, `brave`, `worried`, `happy`; râu: `longBeard(c)`, `thinMus`, `shortMus`, `goatee`, `sideburn`, `mus`
   - thân: `robe`, `sleeve`, `belt`, `chest` (`armor(c)`, `coat()`), `back`
   - đạo cụ: `sword`, `spear()`, `bow`, `oar`, `scroll`, `baby`, `scope`, `quill`, `book`
   - Thiếu mảnh nào (mũ La Mã, áo toga, kính…) thì tự viết thêm hằng SVG cùng kiểu (viền `${S}`, tô phẳng) trong file của video. Vật không có mặt thì cho chuỗi SVG thô 300×420.
3. **Biểu cảm:** muốn nhân vật đổi cảm xúc thì thêm key biến thể chỉ khác lông mày / miệng, ví dụ `napoleon` (`brave`) và `napoleon-gian` (`angry`), khai báo riêng trong `cast` cùng `name`. Thumbnail dùng bản biểu cảm mạnh.
4. Chạy `node work/gen-chars.mjs`. Mỗi file < 4 KB (script báo nếu vượt), không dùng `<text>`. File nào cũng có `mouth-closed`/`mouth-open` để nhép miệng.
5. **Tự chấm bằng mắt (bắt buộc):** xem các SVG trong Browser pane (nhúng dạng data URI nếu ảnh không lên) và chụp màn hình. Chấm: nhìn có đoán ra là ai / thời nào không, các nhân vật có phân biệt được với nhau không. Chưa đạt thì đổi màu, mũ, râu, đạo cụ rồi vẽ lại.
6. **Tèo bản cũ:** **không** đặt `"narrator_style"` trong `video.json`; Tèo dùng `kit/chars/narrator/teo-*.svg` (6 pose: talk, point, shock, shrug, smug, think).
7. Mỗi key trong `cast` phải có file `chars/<key>.svg`. Rà lại: mỗi nhân vật trong cảnh phải trỏ đúng key của người đó. Nhầm key là lỗi hay gặp.

## 4b. Cảnh custom (SVG + GSAP tự vẽ)

- **Thứ tự làm:** viết `scenes/_<ten>.mjs` (phong cách chung) → viết từng loại cảnh trong `scene_kit` → viết chương bằng các loại cảnh đó → `validate,build` → snapshot mỗi loại cảnh ít nhất một mốc **trước khi** viết hết kịch bản, sửa phong cách cho ổn rồi mới nhân ra cả video.
- Khung xuất phát: `KIT/examples/custom-scene.mjs` (chỉ để xem cấu trúc hàm, không giữ bố cục của nó). Trong chương: `{"type": "custom", "file": "scenes/<ten>.mjs", "say": "...", ...tham số tự đặt}`. Tham số đặt tên theo nghĩa của tập (`rows`, `stops`, `arrows`, `focus`…) và mọi chữ hiện lên đều có cue `at`.
- Hàm `export default (ctx, kit)` trả `{css, html, js, sfx, bg}`. Runtime có sẵn `tl, q, qa, POP, STAMP, SLIDE, FADE, OUT, DRAW, SHAKE, BOB, FLAP`; kit có `C, esc, r3, fit, charBox, sfx, color`.
- Luật: vẽ trong y < 880 (phụ đề ở dưới); mọi id bắt đầu bằng `${ns}-`; **mọi thứ khởi đầu ẩn** (opacity 0 / scale 0 / dashoffset 1) rồi hiện đúng cue qua `cues.find("cụm chữ", fallback)`; không dùng `Math.random` (build lại phải ra y hệt). **Không dùng CSS `filter: blur/drop-shadow`, `mix-blend-mode`, `backdrop-filter` hay `@keyframes`**: có một cái là cả chương render chậm gấp đôi. Quầng sáng và sương thì vẽ bằng `radial-gradient`. Cũng không tween `clipPath`/`mask`/`rotationX`/`rotationY`, không dùng `onUpdate`/`onComplete`/`tl.call` để đổi hình, không cho 2 tween cùng prop của cùng phần tử chồng giờ nhau (chi tiết ở KIT/README.md, mục "Tốc độ render").
- Nên có chuyển động thật: vẽ nét dần (`DRAW` với `pathLength="1"`), xoay, đổi màu, vật bay theo quỹ đạo, nhân vật trong cast qua `charBox`. Cảnh custom vẫn nhận `fx`, `cta`, `teo`.
- Lỗi import hoặc thiếu export default thì validate báo lỗi. Snapshot **bắt buộc** có mốc rơi vào từng **loại** cảnh custom (mỗi file ít nhất 1 mốc, cảnh nhiều chữ nhất của loại đó).
- **Bẫy đã gặp (tập Tesla):**
  - Chuỗi chèn vào `style="…"` không được chứa dấu nháy kép. Font viết `Bahnschrift, 'Segoe UI', sans-serif` (nháy đơn); nháy kép làm vỡ thuộc tính style, chữ tí hon và hiện sai lúc.
  - Không đặt id trùng id kit tự sinh: `${ns}-ground`, `${ns}-root`, `${ns}-template`, `${ns}-cam`, `${ns}-fxcam`, `${ns}-fxN`. Đặt tên khác (`${ns}-gnd`). Trùng id thì nền kit đè lên cảnh.
  - Font hệ thống (Bahnschrift, Segoe UI…) làm `lint` báo `font_family_without_font_face`. Lỗi này vô hại nếu log render có dòng "Embedded system font".
  - Tham số độ dài (mũi tên, thanh) tính bằng pixel: kiểm snapshot xem nhãn có đè tiêu đề không.
- Tèo trong tập toàn custom: đặt `"teo": false` ở cảnh không cần Tèo; khi Tèo nói (câu chào, CTA, bình luận) thì vẽ Tèo bằng `charBox` ngay trong cảnh custom, theo đúng vai của khung.

## 5. Thumbnail + SEO (bắt buộc đẹp, PHẢI xem ảnh)

`thumb` không phụ thuộc render và chạy ~10 s, nên làm ngay sau khi viết xong video.json:

```bash
node __MUSE_ROOT__/kit/make.mjs <dir> --stage thumb
```

Mở `thumbnail.png` ra xem (Read). Lặp lại tới khi đạt đủ checklist. Luật chung về tiêu đề và ảnh bìa cho mọi kênh Tèo
(người dùng chốt 2026-10-24) nằm ở `__MUSE_ROOT__/ideas/TIEU-DE-ANH-BIA.md`: đọc trước khi làm mục này.

- [ ] 1280×720, chữ hook **3–5 từ**, **khác tiêu đề**, câu hỏi hoặc nghịch lý, gây tò mò.
- [ ] **Chỉ một khối chữ chính.** Dùng `series` hoặc `sub`, không dùng cả hai. Tập thuộc một loạt (sổ loạt
  `yt-auto/series/<kênh>.json`) thì dùng `series` = nhãn loạt, giống hệt ở cả 3 tập; khi đó bỏ `sub`.
- [ ] **Hình đắt nhất phải to.** Có `prop` thì `circle_r` ≥ 300 (mặc định của kit là 330). Đừng thu vòng đồ vật
  thành một chấm, xuống điện thoại sẽ không thấy. Không có đồ vật đắt thì tắt vòng (`circle: false`) và dùng `closeup`.
- [ ] Góc dưới bên phải không có chữ, vì ô thời lượng của YouTube che chỗ đó.
- [ ] **Soi ở cỡ điện thoại:** `sips -Z 360 <dir>/thumbnail.png --out <dir>/work/thumb-phone.png` rồi Read ảnh đó.
  Không đọc được chữ hoặc không nhận ra hình đắt nhất trong 1 giây thì làm lại.
- [ ] Câu hỏi hoặc hình trên ảnh bìa được nhắc lại trong **30 giây đầu** của hook (luật "hứa gì trả nấy").
- [ ] Chữ ngắt 2 dòng tự nhiên. Kit chia đều theo độ dài; nếu gãy giữa cụm, ví dụ "CÁI / NÀO THẬT", thì đổi câu (ví dụ "Tự trầm hay bị chém?").
- [ ] `highlight` tô vàng 1–2 từ đắt nhất.
- [ ] **Không có gì đè lên mặt nhân vật.** Vòng đạo cụ (`circle_x/y/r`) đặt vào khoảng trống thật của ảnh này, không chép toạ độ tập trước, và không chạm chữ.
- [ ] Mũi tên chỉ bật khi chỉ vào thứ có nghĩa.
- [ ] Nhân vật chính có cảm xúc rõ. Dùng bản biểu cảm (`<key>-soc`, `<key>-gian`…) nếu nhân vật có.
- [ ] **Khác 3 tập trước ở ≥3/5 yếu tố:** pose / biểu cảm, `bg`, vị trí vòng, có mũi tên hay không, kiểu chữ hook (câu hỏi / cảm thán / con số / trích lời). Ba tập cùng loạt thì giữ chung `bg`, còn 4 yếu tố kia phải khác ít nhất 3. Sang loạt mới thì đổi `bg`. Đổi cả `thumbnail.layout`: `classic`, `split` (2 nhân vật đối đầu, badge VS) hoặc `closeup` (cận mặt nhân vật chính); `bg` có thêm purple, noir, teal, orange. Thông số thumbnail các tập trước in ở `fx-list.mjs`.
- [ ] Nhãn đang dùng (`series` ở trên cùng **hoặc** `sub` vàng ở dưới, không cả hai) ngắn, tối đa 3 từ.

> **LUẬT CỨNG: MỖI VIDEO TỰ ĐI TÌM TÊN CỦA RIÊNG NÓ.** Video dài và **từng short** đều phải tự tìm trên YouTube (`tu-khoa.py`, video dài thêm `kiem-hang.py`) với tên neo của chính nó, rồi chọn tên dễ được tìm thấy nhất. Không chép tên hay kết quả tìm kiếm của video khác, không đặt tên theo cảm tính. Ghi lại cụm đã tìm, điểm, mức cạnh tranh và tên đã chọn của từng video.

**Tiêu đề SEO** (`publish.titles`, 3 phương án; bản đăng thật nằm ở `youtube/seo.json`, xem mục 6b). Làm đủ 4 bước của
`__MUSE_ROOT__/ideas/TIEU-DE-ANH-BIA.md` mục 1 (1a–1d), theo thứ tự:

1. **Từ khoá:** `python3 __MUSE_ROOT__/yt-auto/tools/tu-khoa.py "<tên neo>" "<tên neo + góc của tập>" "<chủ đề loạt>"` (thêm `--bo=…` để bỏ gợi ý trùng tên). Lấy cụm điểm cao nhất mà đúng nghĩa. Gõ cả tên gọi khác của tên neo.
2. **Câu hỏi người xem:** mục "Người xem đang hỏi gì" của `tu-khoa.py`. Ít nhất một phương án trả lời thẳng câu cao điểm nhất mà video trả lời được.
3. **Độ cạnh tranh:** `python3 __MUSE_ROOT__/yt-auto/tools/kiem-hang.py "<cụm 1>" "<cụm 2>"`. Kênh này hay gặp mức KHÓ, vì tên neo nổi tiếng thì báo lớn và kênh lớn đã chiếm top. Gặp KHÓ thì đổi sang cụm dài và hẹp (tên neo + góc riêng mà người ta có gõ). Ví dụ "Ronaldo Bị Gạch Tên…" lên #1, trong khi "Ronaldo 2013…" không lọt top.
4. **Viết:**
   - Cụm từ khoá đứng **đầu** tiêu đề, nguyên văn theo thứ tự chữ người ta gõ. Cụm từ khoá và lời hứa nằm trong 40 ký tự đầu.
   - Phần tự viết ≤ 51 ký tự, **không ghi đuôi**: `youtube-pack.mjs` tự gắn `| Tèo Kể`, rồi chặn khi quá 60 ký tự, có emoji hoặc viết HOA toàn bộ. Nó cảnh báo khi chưa Viết Hoa Từng Chữ hoặc khi chữ ảnh bìa lặp quá nửa tiêu đề.
   - Hứa một điều cụ thể. Có thể dùng một trong 4 kiểu, đổi kiểu giữa các video:
     - Câu hỏi: `Titanic Chìm Vì Đâu? Đêm Cuối Của Con Tàu`
     - Con số: `Magellan: 240 Người Ra Đi, Chỉ 18 Người Về`
     - Nghịch lý: `Napoleon Không Hề Lùn? Sự Thật Về Hoàng Đế`
     - Sự thật / cái kết khác điều ai cũng nghĩ: `Hai Bà Trưng: Cái Kết Mà Sử Sách Kể Khác Nhau`
   - "(Phần N/3)" chỉ dùng khi các tập nối tiếp nhau về nội dung, đặt cuối.
   - 3 phương án là 3 góc khác hẳn nhau, mỗi phương án vẫn mở bằng một cụm từ khoá. Viết Hoa Từng Chữ, không emoji.
   - Không clickbait sai sự thật: mỗi lời hứa phải được trả lời trong video (đối chiếu `description`/`notes`).
   - Tiêu đề, chữ thumbnail và câu đầu mô tả là 3 câu KHÁC nhau.
   - Ghi cụm đã chọn, điểm và mức cạnh tranh vào `ideas/YYYY-MM-DD.md`.
5. **Sau khi đăng ≥ 3 ngày:** `python3 .../kiem-hang.py --da-dang` ghi vị trí tìm kiếm của từng video vào `yt-auto/logs/hang.jsonl`. Đọc file này trước khi đặt tiêu đề cho loạt mới.

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
node __MUSE_ROOT__/kit/make.mjs <dir> --stage render,thumb,publish --par 2 > <dir>/work/render.log 2>&1
```

Render mặc định dùng **GPU** (`make.mjs` tự truyền `--gpu` cho hyperframes; Chrome vẽ khung bằng ANGLE D3D11 trên AMD RX 6600 XT; bộ nén mp4 dùng GPU nếu hyperframes tìm được, không thì tự quay về CPU). Hình hỏng / sai màu do GPU thì thêm `--no-gpu`. Đặt `TEMP`/`TMP` sang ổ E: (`chay-nang.sh` đã làm sẵn) vì ổ C: không đủ ~12 GB khung tạm mỗi chương.

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
   node <SKILL_DIR>/scripts/youtube-pack.mjs videos/<slug>      # hoặc --all cho mọi video có seo.json
   ```
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
7. **Google Drive và thư mục gói (tự động, không làm tay):**
   - Trên Mac, job `yt-sync` (15 phút/lần, `__MUSE_ROOT__/yt-auto`) tự chép `videos/<slug>/youtube/` lên `My Drive/TeoKenhYoutube/<slug>/` khi gói đủ video dài + 3 Shorts, rồi xoá `youtube/` trên máy. Node không có quyền ghi Drive, nên `youtube-pack.mjs` báo "CHƯA lên Drive" là bình thường.
   - `TeoKenhYoutube` chỉ chứa video của kênh Lại Là Tèo Đây. Kiếm hiệp ở `My Drive/TeoTuuLau`. Không có video thể thao.
   - Khi `yt-auto` hẹn giờ xong video dài, thư mục gói được đổi tên thành **`<YYYY-MM-DD HHhMM> <slug>`** (giờ đăng video dài, vd. `2026-10-28 19h00 cleopatra-gio-sung`). Đăng hết (dài + Shorts) thì chuyển sang `My Drive/DaDang/lai-la-teo-day/` giữ nguyên tên.
   - Skill **không tự đặt tiền tố giờ**: tên thư mục `videos/<slug>` vẫn là slug trần. Khi tìm xem slug đã lên Drive / đã đăng chưa, tìm thư mục tên `<slug>` **hoặc kết thúc bằng ` <slug>`** ở cả `TeoKenhYoutube` và `DaDang/lai-la-teo-day`.
   - Sửa gói sau khi đã lên Drive (thumbnail, short…): sửa trong `videos/<slug>/youtube/`, `yt-sync` tự chép đè vào đúng thư mục đã đổi tên.

## 6c. BỎ TẠO SHORTS (chủ kênh chốt 2026-10-29)

Kênh "Lại Là Tèo Đây" **không làm Shorts** (bỏ mọi bước kịch bản short, giọng short, dựng short, render short). `yt-auto` cấu hình `min_shorts = 0` và `"tat_shorts": true`. Gói `youtube/` chỉ cần video dài + ảnh bìa + tiêu đề + mô tả + tags là hoàn chỉnh để tải lên Drive và tự động đăng.

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
- Concept sáng tạo (style / motif / kiểu hook / gag), hệ hình (medium · bố cục · màu) + bộ cảnh custom đã vẽ, tỉ lệ custom, fx chữ ký.
- Đường dẫn thư mục `youtube/` (gói đăng) và `DANG-YOUTUBE.md`.
- Gói lên `My Drive/TeoKenhYoutube/<slug>` qua yt-sync (hẹn giờ xong thì thành `<YYYY-MM-DD HHhMM> <slug>`).
- Dữ kiện nên kiểm lại (lấy từ `notes`).
- Lỗi hoặc chỗ chưa ổn nếu có.
- Chế độ liên tục: báo đang làm video kế tiếp nào.
