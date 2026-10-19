---
name: teo-kiem-hiep
description: >
  Làm video hoạt hình 2D DÀI (mỗi video ≥20 phút, tiếng Việt) về KIẾM HIỆP TRUNG QUỐC KINH ĐIỂN: tác giả nổi tiếng (Kim Dung, Cổ Long, Lương Vũ Sinh…),
  tác phẩm kinh điển, so sánh nhân vật ("ai mạnh hơn"), so sánh võ công, môn phái, thần binh. Tèo làm MC/trọng tài, nhân vật dựng chibi
  đấu minh hoạ + thẻ thông tin + bảng chỉ số (HyperFrames + GSAP, không ffmpeg). Quy trình: TỰ RESEARCH chủ đề (web + kho chu-de.md,
  dữ kiện ≥2 nguồn, chống trùng chủ đề) → tap.json + ≥1 hiệu ứng tự chế → build.mjs tự chọn hiệu ứng CHỐNG TRÙNG LẶP → snapshot soi
  → render MP4 → thumbnail VS 1280×720 + gói youtube/. Dùng khi người dùng nói "Tèo kiếm hiệp", "tập kiếm hiệp mới",
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

Tèo là MC kiêm trọng tài: dẫn bằng bong bóng thoại, nhân vật kinh điển đấu minh hoạ bằng rig chibi, dữ kiện hiện trên `card`, điểm so sánh hiện trên `stat`. **Có giọng Tèo** (VieNeu "Lóng", giống kênh Tèo Kể): mọi `say` và mọi trường `vo` được đọc thành tiếng.

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
   5. Tự chọn ý có tổng điểm cao nhất. Viết dàn ý theo mẫu của format trong chu-de.md.
   6. Ghi `<dir>/y-tuong.md`: các truy vấn, bảng 3 ý và điểm, lý do chọn, dàn ý, **bảng dữ kiện** (claim | nguồn 1 | nguồn 2 | bản truyện), và điểm `stat` kèm lý do mỗi điểm. Đánh dấu chủ đề đã dùng trong `data/chu-de.md` bằng `(tập N)`.
1. Chạy `fx-list.mjs` để biết nhóm hiệu ứng nào đang bị dùng nhiều.
2. Viết `tap.json` (định dạng ở dưới, **có khối `story`**) và `fx/<tên>.mjs` (≥1 file). Chạy `node SKILL/scripts/story-check.mjs <dir>`, sửa tới khi hết mọi dòng ✗; dòng ! thì cân nhắc.
3. **Giọng đọc:** `node SKILL/scripts/voice.mjs <dir>` (thêm `--dry` để chỉ ước thời lượng giọng trước khi đọc). Lệnh này đọc mọi `say` + `vo` bằng VieNeu (`E:	oolVieNeu-TTS`), ghi `<dir>/voice/*.wav` + `voice/voice.json`, có cache nên dòng không đổi chữ không đọc lại. Đổi giọng bằng `"voice"` trong tap.json, độ ngẫu nhiên bằng `"voice_temperature"` (mặc định 0,8).
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
   - GSAP: nếu có `SKILL/engine/vendor/gsap.min.js` (bản 3.14.2) thì build chép vào tập, render không cần mạng. Không có thì tải từ CDN jsdelivr lúc render.
   - Plan được giữ nguyên khi build lại, trừ khi đổi cấu trúc beat **hoặc** lịch sử có tập khác mới pack. Khi đó build tự lập plan mới.
6. Viết `seo` trong tap.json rồi chạy `node SKILL/scripts/pack.mjs <dir>`. Lệnh này chụp thumbnail và tạo `youtube/`: mp4, thumbnail.png, tieu-de.txt, mo-ta.txt, tags.txt, DANG-YOUTUBE.md. Nó cũng ghi lịch sử (kể cả khối story). Nếu chỉ chạy thử thì thêm `--no-history`.
7. Read `youtube/thumbnail.png` để kiểm tra: mặt không bị che, chữ hook đọc được.
8. Ghi một dòng vào `__MUSE_ROOT__/ideas/DA-LAM.md`, mảng "Tèo kiếm hiệp": tập, tiêu đề, đường dẫn, hiệu ứng local.

## Dàn ý chuẩn cho video ≥20 phút (doi-dau; các format khác xem chu-de.md mục 4)

Một video = 1 chủ đề chính + 4–6 chủ đề phụ (lấy từ **gói chủ đề** ở chu-de.md mục 5), chia **6–8 đoạn**, mỗi đoạn 2,5–4 phút và mở bằng một mini-hook (câu hỏi nhỏ giữ người xem). Đoạn nối nhau liền mạch, không thẻ chương. Cả video có **≥3 hiệu ứng local** (rải ở các đoạn cao trào), caption ≤12 chữ, CTA đăng ký ở khoảng phút 9–12 (40–60% video) và ở cuối. Khung một đoạn đối đầu:

1. **Hook** ≤5 s: câu hỏi gây tranh luận, khớp chữ thumbnail.
2. **Chào:** "Chào các bạn, lại là Tèo đây…" (mỗi tập đổi vế sau).
3. `card` giới thiệu bên A (enter + intro trước), rồi `card` bên B.
4. **Hiệp 1–3:** attack minh hoạ + react (chỉ choáng). Tèo nói "điểm Tèo chấm cho vui" rồi `stat` (gộp 3–4 tiêu chí, hoặc mỗi hiệp một dòng).
5. **Giữa video:** caption kêu gọi đăng ký.
6. **Chi tiết ít người biết:** đặt hiệu ứng local ở đây.
7. **Kết luận:** Tèo nghiêng về bên nào, nói rõ là ý kiến, kèm "Bạn nghĩ ai mạnh hơn? Bình luận nhé".
8. **Cuối:** kêu gọi đăng ký, móc `ender.next` (chủ đề tập sau).

Bước 3–6 lặp lại cho từng đoạn/chủ đề phụ (mỗi đoạn một góc: một hiệp, một tiêu chí, một chi tiết bản truyện…). Kết luận + câu hỏi bình luận + CTA cuối chỉ đặt một lần ở đoạn cuối.

## Dàn ý an-so (ngôi sao + cái bóng, ≥20 phút, 6–8 đoạn)

Kiểu chủ đề "Ngộ Không 72 phép, Bát Giới 36 phép mà vẫn lợi hại", áp vào kiếm hiệp. Kho ý tưởng ở chu-de.md mục 1.18. `story.subjects` = [ngôi sao, cái bóng].

1. **Hook đảo kỳ vọng:** "Ai cũng nhớ Hàng Long, nhưng bang chủ Cái Bang còn giữ một thứ khác…".
2. **Chào:** "Chào các bạn, lại là Tèo đây…" (đổi vế sau).
3. `card` ngôi sao, rồi `card` cái bóng.
4. **So thẳng** bằng `stat`: cái bóng thua ở tiêu chí nào (nói thật, kiểu "36 so với 72").
5. **Lật lại:** 3–5 đoạn, mỗi đoạn một "chiến tích bị quên" (dữ kiện ≥2 nguồn + một trận minh hoạ + hiệu ứng local ở đoạn hay nhất).
6. **Giữa video:** CTA đăng ký.
7. **Vì sao bị lãng quên:** cách tác giả kể, phim cắt bớt, chi tiết khác nhau giữa các bản.
8. **Kết luận "đừng xem thường"** (nói rõ là ý kiến, không hạ thấp ngôi sao) → "Bạn còn biết cái bóng nào?" → CTA cuối, móc `ender.next`.

## tap.json

Mẫu cấu trúc, đã build thử: `SKILL/examples/tap-01/` (Tiêu Phong vs Quách Tĩnh). **Mẫu này chỉ dài ~1,5 phút để minh hoạ cú pháp beat** (tương đương một đoạn); tập thật phải nhân lên 6–8 đoạn để đủ ≥20 phút. Rút gọn:

```json
{
  "ep": 1, "title": "Tiêu Phong vs Quách Tĩnh: ai mạnh hơn?", "hook": "AI MẠNH HƠN?",
  "theme": "auto",
  "opener": { "title": "TÈO KỂ KIẾM HIỆP", "sub": "Tiêu Phong vs Quách Tĩnh" },
  "ender": { "next": "Lệnh Hồ Xung vs Dương Quá: kiếm ai nhanh hơn" },
  "thumb": { "text": "AI MẠNH HƠN?", "vs": ["tieu", "quach"], "pose": "palm", "pose2": "palm" },
  "cast": {
    "teo": { "kind": "teo", "name": "Tèo", "band": "#D7263D", "weapon": "kiem" },
    "tieu": { "preset": "hiep-khach", "name": "Tiêu Phong", "robe": "#5A3A22", "hat": "none", "weapon": "none" },
    "quach": { "preset": "hiep-khach", "name": "Quách Tĩnh", "robe": "#2E6FB7", "hat": "khan", "weapon": "none" }
  },
  "scenes": [ { "set": "nui-tuyet", "time": "ngay",
    "actors": [ { "id": "teo", "x": 250 }, { "id": "tieu", "x": 760 }, { "id": "quach", "x": 1500, "hidden": true } ],
    "beats": [
      { "do": "card", "side": "right", "title": "Quách Tĩnh", "sub": "Xạ Điêu Anh Hùng Truyện · Kim Dung", "lines": ["…", "…"] },
      { "do": "attack", "who": "tieu", "target": "quach", "name": "Hàng Long Thập Bát Chưởng" },
      { "do": "react", "who": "quach" },
      { "do": "stat", "left": "tieu", "right": "quach", "total": true,
        "rows": [ { "label": "Hàng Long", "l": 10, "r": 9 }, { "label": "Biến hoá", "l": 8, "r": 9 } ] },
      { "do": "local:rong-chuong", "who": "tieu", "target": "quach" }
    ] } ],
  "story": {
    "format": "doi-dau",
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
  - `format` thuộc 8 format ở trên. `subjects`: nhân vật / võ công / tác giả / tác phẩm mà tập bàn tới (format đối đầu cần ≥2).
  - `works`, `authors`, `edition`, `verdict` (doi-dau/so-vo nên có), `facts[{claim, src[≥2]}]`, `sources` (nguồn tham khảo thêm).
  - pack.mjs ghi story, title, next, sets, chars, moves vào history để các tập sau tránh trùng.
- **thumb:**
  - `text`: chữ lớn (≤3–4 từ).
  - `vs: [idTrái, idPhải]`: thumbnail đối đầu (2 nhân vật + huy hiệu VS + biển tên). Hai id phải cùng có mặt trong một cảnh.
  - `pose` (bên trái hoặc Tèo), `pose2` (bên phải). Không có `vs` thì vẽ Tèo + một đối thủ như kiểu cũ.
- **cast:**
  - `kind:"teo"` hoặc `preset` thuộc: linh, linh-do, cao-thu, hiep-khach, thu-sinh, chuong-quy, su-phu, nu-hiep, **cai-bang** (áo vá nâu, gậy), **tang** (cà sa vàng, đầu trọc), **dao-si** (áo lam, búi đạo sĩ, kiếm), **cong-tu** (áo trắng, kiếm), **lao-quai** (áo tím sẫm, râu, gậy).
  - Ghi đè được: `robe`, `hat` (linh/bui/non/khan/none/troc/dao), `beard`, `weapon` (kiem/dao/giao/quat/gay/none), `belt`, `patch` (áo vá), `sash` (mã màu cà sa chéo).
  - Gợi ý ngoại hình cho ~20 nhân vật nổi tiếng nằm trong chu-de.md. Không vẽ giống diễn viên.
  - `w`: bề rộng; mặc định teo 250, npc 190. `side:"hero"`: đồng minh của Tèo.
- **scenes[]:**
  - `set` thuộc: san-tap, rung-truc, mai-ngoi, quan-tro, nui-tuyet, ben-song, cau-go (bảng quy đổi địa danh trong truyện → set nằm ở chu-de.md).
  - `time`: ngay hoặc dem.
  - `actors[]`: {id, x (tâm, px trên khung 1920), hidden?, w?, foot?}. Ba người trong cảnh thì Tèo đứng góc (x ≈ 250, w 190), hai bên đấu ở giữa và bên phải.
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
| `caption` | text | chữ dẫn chuyện, kêu gọi đăng ký |
| `card` | title, sub?, lines[≤4], side left/right/center | thẻ thông tin ở dải trên khung; thời lượng tự tính theo số chữ (≤10 s đọc). Biến thể: cd-scroll, cd-board, cd-bamboo |
| `stat` | left (id), right (id), rows[{label, l, r}] (0–10, ≤4 dòng), total? | bảng so điểm; tên lấy từ cast. Biến thể: st-bars, st-scale, st-tally |
| `local:<tên>` | tuỳ hiệu ứng | hiệu ứng tự chế của tập |
| (bất kỳ) | fx: "<id>" | ép hiệu ứng cụ thể, bỏ qua planner (hạn chế dùng) |

- **Luật keep/removes/down:**
  - React có cờ `removes` (af-fly: văng khỏi khung) bị cấm khi nạn nhân là teo, phe hero, hoặc còn được nhắc ở beat sau.
  - Tập có `story.format` thì mọi react cấm cả cờ `down` (af-ko, af-domino, af-spin, af-flat, af-fly).
  - Hai luật này không bao giờ nới. Nhân vật đang nằm mà được giao beat khác thì tự đứng dậy.

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

Hiệu ứng local nào đẹp và dùng lại được thì chép vào `SKILL/engine/fx-extra/<id>.mjs` (bỏ tiền tố local). Từ tập sau, planner sẽ tự xếp nó vào kho. Không có `id` thì lấy tên file làm id. Id không được trùng.

## Âm thanh

- **Giọng Tèo:** wav từ `voice.mjs`, build đặt vào track 14/15 (xen kẽ cho khỏi chồng), âm lượng 1. Thiếu `voice/voice.json` thì build vẫn chạy nhưng không giọng và in CẢNH BÁO; tập thật bắt buộc có giọng.
- **BGM** pizzicato lặp: 0,06 khi có giọng, 0,1 khi không (ghi đè bằng `bgm_volume`).
- **sfx** theo hiệu ứng.
