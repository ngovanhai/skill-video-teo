---
name: video-teo
description: >
  Sản xuất video YouTube explainer hoạt hình 2D tiếng Việt dài trên 20 phút (thường 20–30) do mascot Tèo dẫn (giọng VieNeu "Lóng"),
  từ chọn chủ đề (bắt buộc là người nổi tiếng hoặc sự việc nhiều người biết) → nghiên cứu ≥2 nguồn → kịch bản video.json → nhân vật SVG → TTS/align/build → snapshot → render MP4
  + thumbnail 1280×720 đẹp + tiêu đề chuẩn SEO (đuôi "| Tèo Kể") + gói đăng youtube/ (mp4, thumb, tiêu đề, mô tả, tags, phụ đề .srt). Dùng khi người dùng nói "tạo video", "làm video Tèo",
  "video dài hôm nay", "làm tiếp video", hoặc chạy chế độ sản xuất liên tục. Dùng kit tại __MUSE_ROOT__\kit.
---

# Video Tèo — dây chuyền video dài trên 20 phút

Mày là cả ê-kíp của một kênh YouTube tiếng Việt: biên kịch, họa sĩ, dựng phim, SEO. Mỗi video làm TRỌN gói. Người dùng chỉ việc xem lại rồi tự đăng.

`KIT = __MUSE_ROOT__\kit` · `<SKILL_DIR>` = thư mục chứa file này.

**ĐỌC TRƯỚC (bắt buộc, mỗi phiên):** `KIT/README.md`. Đây là spec định dạng video.json, các loại cảnh, luật kịch bản, nhân vật, thumbnail và publish. Bảng tra cứu nhanh nằm ở `<SKILL_DIR>/reference.md`.

## Luật cứng

- KHÔNG đăng gì lên mạng. KHÔNG gửi tin nhắn cho ai.
- Chỉ sửa thư mục video đang làm, `__MUSE_ROOT__\ideas\` và **thêm** fx mới vào `kit/fx/<ten>.mjs`. KHÔNG sửa template cũ trong `kit/scenes/`, `kit/lib/`, `kit/make.mjs`. Cảnh tự chế (`custom`) để trong `videos/<slug>/scenes/`.
- Không dùng `videos\_pilot` hay `khoi-nguyen-vu-tru-hy-lap` để thử nghiệm.
- Tránh chính trị nhạy cảm, tôn giáo gây tranh cãi, 18+, bạo lực ghê rợn. Phần truyền thuyết phải nói rõ là truyền thuyết.
- Hỏng mà không tự sửa được thì dừng lại, báo rõ lỗi kèm log.

## Chế độ liên tục (mặc định khi người dùng bảo "tạo liên tục")

Xong video này thì làm ngay video kế. Cho các việc chạy chồng lên nhau để máy không lúc nào rảnh:

- Trong lúc video A chạy TTS hoặc render ở nền, viết kịch bản và vẽ nhân vật cho video B. Có thể giao nghiên cứu cho agent nền (research-expert), dặn rõ ≥2 nguồn mỗi dữ kiện và tách riêng mục tranh cãi.
- Các việc nặng CPU chạy tuần tự: không chạy 2 TTS, 2 align hay 2 render cùng lúc. Riêng `thumb` và `validate` nhẹ, chạy song song được.
- Mỗi video xong thì báo người dùng ngắn gọn (mẫu ở mục 9), rồi làm tiếp.
- **Chỉ tiêu: tối thiểu 10 video/ngày, video nào cũng phải chuẩn chỉnh** (không bỏ bước kiểm nào để chạy cho đủ số). Làm đa luồng: **mỗi video một session** (start_session), còn các stage nặng (`tts,align,build,lint` và `render,thumb,publish`) chạy qua hàng đợi chung:
  `bash __MUSE_ROOT__/ideas/chay-nang.sh <video_dir> <stages> <log_file>` (chạy nền). KHÔNG gọi thẳng make.mjs cho các stage đó.
- Lúc nào cũng phải có **≥4 video** đang viết hoặc chờ CPU. Mỗi video tốn khoảng 100 phút CPU (TTS cộng render), nên trần là khoảng 14 video/ngày. CPU rảnh là mất chỉ tiêu.
- Trước khi tạo `videos/<slug>`, phải kiểm tra slug chưa có ai làm (thư mục chưa tồn tại, DA-LAM chưa có dòng đó). Không ghi vào thư mục của session khác.
- Cứ 2 tiếng báo cáo người dùng một lần: số video đã xong hôm nay trên chỉ tiêu 10, từng video đang ở bước nào, dự kiến xong lúc mấy giờ, lỗi nếu có.

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
3. **Vai của Tèo** (`voice_role`, chữ tự do) rút ra từ khung: người trong cuộc, người hỏi, người ghi chép, người dẫn đường, hay vắng mặt và chỉ lồng tiếng. Không gần giống 2 tập gần nhất (validate so độ giống chữ). Mỗi vai có thói quen nói riêng như câu cửa miệng, cách gọi người xem, nhịp câu. Tèo vẫn xưng "mình". **`voice_role` chỉ đổi lời văn, KHÔNG đổi giọng đọc: luôn `"voice": "Lóng"`.**
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

- Validate ước tính 4,1 từ/giây, nhưng giọng Lóng thật đọc khoảng 4,5 từ/giây (cảnh ~45 từ mất ~10 s, cộng 0,55 s đệm mỗi cảnh). Kịch bản 6.500 từ / 142 cảnh ra **~24,6 phút**. 5.600 từ / 125 cảnh ra khoảng 21 phút, vừa đủ an toàn.
- Mỗi cảnh 35–60 từ. Tối đa 70 từ; dưới 10 từ thì giọng bị méo.
- Cue `at` phải là cụm có thật trong `say`. Kit so khớp chữ thường, dấu câu đổi thành khoảng trắng. Viết `at` ngắn 1–4 chữ, lấy đúng chữ trong câu.
- Không quá 2 cảnh cùng **file cảnh** đứng liền nhau. Nhân vật quan trọng có cảnh giới thiệu khi ra mắt, dựng bằng loại cảnh "giới thiệu" trong bộ cảnh của tập (mục 2c), không dùng template `intro`.
- **Cảnh dựng bằng bộ cảnh của tập (mục 2c):** `custom` ≥ 85%. Hệ hình và khung quyết định loại cảnh nào làm xương sống, ghi rõ trong ý tưởng. Nếu lỡ dùng template thì `narrator` vẫn **≤ 20%** (validate báo). Dành các cảnh bước ngoặt cho chỗ thật sự có bước ngoặt, đừng rắc đều mỗi 2–3 cảnh.

### Mở đầu (≤ 60 s)

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
- **Hứa hẹn:** **CẤM** công thức "Xem tới cuối, các bạn sẽ có câu trả lời cho ba câu hỏi. Một… Hai… Và ba". Thay bằng kiểu khác mỗi tập: một câu hỏi duy nhất, một câu đố, một vật bí ẩn sẽ được mở ở cuối, một lời cá cược với người xem, hoặc không hứa gì mà vào thẳng chuyện.

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

Validate cảnh báo nếu thiếu "lại là Tèo" trong ~60 s đầu, thiếu "đăng ký" ở giữa (25–75%) hoặc ở cuối, cảnh `cta` không có chữ "đăng ký", có cụm "ba câu hỏi", hoặc câu chào / CTA giống tập trước.

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

Mở `thumbnail.png` ra xem (Read). Lặp lại tới khi đạt đủ checklist:

- [ ] 1280×720, chữ hook 3–7 từ, **khác tiêu đề**, câu hỏi hoặc nghịch lý, gây tò mò.
- [ ] Chữ ngắt 2 dòng tự nhiên. Kit chia đều theo độ dài; nếu gãy giữa cụm, ví dụ "CÁI / NÀO THẬT", thì đổi câu (ví dụ "Tự trầm hay bị chém?").
- [ ] `highlight` tô vàng 1–2 từ đắt nhất.
- [ ] **Không có gì đè lên mặt nhân vật.** Vòng đạo cụ (`circle_x/y/r`) đặt vào khoảng trống thật của ảnh này, không chép toạ độ tập trước, và không chạm chữ.
- [ ] Mũi tên chỉ bật khi chỉ vào thứ có nghĩa.
- [ ] Nhân vật chính có cảm xúc rõ. Dùng bản biểu cảm (`<key>-soc`, `<key>-gian`…) nếu nhân vật có.
- [ ] **Khác 3 tập trước ở ≥3/5 yếu tố:** pose / biểu cảm, `bg`, vị trí vòng, có mũi tên hay không, kiểu chữ hook (câu hỏi / cảm thán / con số / trích lời). Đổi cả `thumbnail.layout`: `classic`, `split` (2 nhân vật đối đầu, badge VS) hoặc `closeup` (cận mặt nhân vật chính); `bg` có thêm purple, noir, teal, orange. Thông số thumbnail các tập trước in ở `fx-list.mjs`.
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
5. Mở `tieu-de.txt` và `mo-ta.txt` đọc lại một lượt. Dấu ấn phải đồng nhất: đuôi tiêu đề, `#TeoKe`, chân trang mô tả, avatar, ảnh bìa, hình mờ ở `__MUSE_ROOT__\avatar\`.
6. Mục "Dành cho trẻ em" (COPPA) là quyết định của chủ kênh. Chỉ nhắc, không tự quyết.
7. **Đồng bộ Google Drive (bắt buộc, tự động):** đóng gói không lỗi xong, `youtube-pack.mjs` chép cả thư mục `youtube/` sang `G:\My Drive\TeoKenhYoutube\<slug>\` (thư mục của ứng dụng Google Drive for desktop; ứng dụng tự tải lên mây ở nền).
   - Ghi qua file `.part` rồi đổi tên, nên Drive không đồng bộ file chép dở. File đã có cùng kích thước và không cũ hơn thì bỏ qua.
   - Sửa gói (thumbnail, tiêu đề…) thì chạy lại `youtube-pack.mjs`; file đổi sẽ được chép đè.
   - Không thấy `G:\My Drive` (Drive chưa mở / chưa đăng nhập) thì script báo "CHƯA lên Drive" và thoát mã 1. Gói ở `youtube/` vẫn đủ; mở ứng dụng Google Drive rồi chạy `node <SKILL_DIR>/scripts/drive-sync.mjs videos/<slug>`.
   - `--no-drive` chỉ dùng khi chạy thử. Đổi thư mục đích bằng biến môi trường `TEO_DRIVE_DIR`.

## 6c. 3 Shorts dọc từ mỗi video (bắt buộc, làm sau 6b)

Mỗi video dài làm thêm **3 short dọc 1080×1920 (9:16)**, mỗi cái 30–60 s, lấy 3 đoạn ấn tượng nhất. **Dựng lại dọc từ đầu, KHÔNG cắt hay crop từ bản 16:9** (crop thì mất nửa hình và chữ). Mỗi short là một video nhỏ hoàn chỉnh: kịch bản riêng, giọng Lóng đọc riêng, cảnh dọc riêng.

1. **Chọn 3 đoạn** (ghi vào `ideas/YYYY-MM-DD.md` mục "Shorts"). Chấm từng ứng viên theo: hình đắt nhất (dừng tay lướt trong 2 s), một ý trọn vẹn kể xong trong 60 s, có cú chốt hoặc twist ở cuối, không cần xem video dài vẫn hiểu. **3 short phải khác kiểu**, ví dụ: (a) cảnh/hình sốc nhất + giải thích, (b) chuyện bên lề lạ nhất, (c) con số / nghịch lý gây tranh cãi nhất. Không lấy 3 đoạn liền nhau.
2. **Kịch bản short** (~200–230 từ, 4–6 cảnh, mỗi cảnh 30–50 từ):
   - Cảnh 1 `"hook": true`, **hook ≤ 12 s, câu đầu vào thẳng hình đắt nhất trong 2 s đầu**. Không chào, không "hôm nay Tèo…".
   - Viết lại câu cho đứng riêng được: không "như mình nói ở trên", không "khung thứ…", không gọi tên segment của video dài.
   - Cảnh cuối nhắc **"Tèo Kể"** + **"đăng ký"** + mời xem bản đầy đủ, hoặc để một câu hỏi mở cho người xem bình luận.
   - Dữ kiện giữ đúng mức chắc chắn như bản dài ("theo Tesla", "theo các báo").
3. **Cảnh dọc**: viết trong `videos/<slug>/shorts/scenes/` (cùng hợp đồng `default(ctx, kit)` như cảnh custom). Có một `_doc.mjs` làm bộ hình dọc chung cho 3 short (khung trên, tiêu đề, chip, dấu, nút đăng ký), **mượn màu/phông từ `_style` của video dài** để đồng bộ, nhưng bố cục là dọc: hình chủ đạo to giữa, không xếp hai cột.
   - **Vùng an toàn Shorts:** nội dung chính trong y 190–1350; y 1380–1600 dành cho phụ đề (build-short tự vẽ); **dưới 1600 và ~100 px mép phải để trống** (nút like/bình luận, tên kênh, mô tả của YouTube đè lên).
   - Mọi cảnh phải `type: "custom"` có `file`. `ctx` có thêm `vertical: true`, `index`, `count` (để vẽ vạch tiến độ), `fullThumb` (thumbnail video dài, dùng cho cảnh mời xem bản đầy đủ).
   - Luật render nhanh như cảnh thường (mục 4b): không filter/clip/3D, không callback, không Math.random.
4. **Thư mục:** `videos/<slug>/shorts/NN-ten/` gồm `video.json` + `chapters/01.json`. Nên sinh bằng một script (`shorts/_make-shorts.mjs`). `video.json` chép `voice`, `names`, `theme`, `bgm` từ video dài; `cast` đổi đường dẫn thành `../../chars/x.svg`; thêm khối:
   ```json
   "short": { "title": "≤60 ký tự, kết bằng | Tèo Kể", "description": "…", "hashtags": ["#Shorts", "#…"], "tags": ["…"], "full": "<tên video dài>" }
   ```
   Chương: `"file": "../scenes/v-xxx.mjs"`.
5. **Chạy** (từ `__MUSE_ROOT__`, tuần tự từng short, nền):
   ```bash
   node kit/make.mjs videos/<slug>/shorts/NN-ten --stage scaffold,tts,align
   node <SKILL_DIR>/scripts/build-short.mjs videos/<slug>/shorts/NN-ten --stage build
   ```
   build-short dựng `index.html` 1080×1920 (cảnh + giọng + sfx + nhạc nền nhỏ + phụ đề to kiểu Shorts: 4 chữ/nhóm, chữ đang đọc vàng) và **cảnh báo** khi: tổng > 60 s hoặc < 20 s, hook > 12 s, cảnh cuối thiếu "Tèo Kể"/"đăng ký", align lệch, có thuộc tính làm render chậm.
6. **Soi trước khi render (bắt buộc):** `npx --yes hyperframes@0.8.172 snapshot . --at <mốc> --no-end -o work/snap --describe false` trong thư mục short, ≥ 1 mốc mỗi cảnh + 3 mốc trong hook. Xem ảnh: hình có tràn mép, có đè phụ đề hay vùng nút Shorts không, chữ đủ to đọc trên điện thoại không.
7. **Render + gói:** `build-short.mjs <dir> --stage render,pack` → `renders/short.mp4` (kiểm 1080×1920) rồi chép vào `videos/<slug>/youtube/shorts/NN-ten.mp4` + `NN-ten.txt` (tiêu đề có `#Shorts`, mô tả, hashtag, tag). Chạy lại `youtube-pack.mjs` để đồng bộ cả `youtube/shorts/` lên Drive.
8. Báo cáo: thêm 3 dòng short (tiêu đề + thời lượng) vào báo cáo mục 9.

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
- Đường dẫn bản trên Google Drive (`G:\My Drive\TeoKenhYoutube\<slug>\`), hoặc báo rõ nếu chưa lên Drive.
- Dữ kiện nên kiểm lại (lấy từ `notes`).
- Lỗi hoặc chỗ chưa ổn nếu có.
- Chế độ liên tục: báo đang làm video kế tiếp nào.
