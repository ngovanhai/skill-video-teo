# Tiêu đề và ảnh bìa YouTube: luật chung cho mọi kênh Tèo

Dùng cho video-teo (Lại Là Tèo Đây), teo-kiem-hiep và teo-kiem-hiep-godot (Tèo Tửu Lâu).
Tìm hiểu ngày 2026-10-24 từ trang hướng dẫn của YouTube (Thumbnail & title tips, A/B test titles & thumbnails,
chính sách lừa đảo/gây hiểu lầm) và các điểm nhiều nguồn cùng thống nhất. Các con số kiểu "mặt người tăng CTR 30%"
trên blog công cụ đều không có nghiên cứu đi kèm, nên không dùng.

## 0. Nguyên tắc gốc: hứa gì trả nấy

- Công cụ Test & Compare của YouTube chọn bản thắng theo **thời gian xem**, không theo lượt bấm. Tiêu đề hay ảnh bìa
  câu kéo mà video không trả lời được thì người xem bấm vào rồi thoát, bản đó thua. YouTube cũng cấm tiêu đề, ảnh bìa
  hay mô tả hứa thứ mà video không có.
- **30 giây đầu video phải trả đúng lời hứa của ảnh bìa và tiêu đề.** Giọng Tèo mở đầu nhắc lại đúng câu hỏi, con số
  hay hình ảnh trên ảnh bìa, rồi hứa sẽ trả lời. Không mở bằng lời chào dài hay giới thiệu kênh.
- Tiêu đề, chữ trên ảnh bìa và câu đầu mô tả là **3 câu khác nhau, bổ sung cho nhau**. Tiêu đề nói rõ video về gì,
  ảnh bìa lo phần cảm xúc, bí ẩn hoặc hậu quả. Mẹo kiểm tra: che ảnh bìa đi mà không mất thông tin nào thì ảnh bìa
  đang bị phí.

## 1. Tiêu đề


**LUẬT CỨNG (user chốt 2026-10-29): MỖI VIDEO TỰ ĐI TÌM TÊN CỦA RIÊNG NÓ.** Video dài VÀ TỪNG SHORT đều phải tự tìm
trên YouTube với tên neo của chính nó, rồi chọn cái tên **dễ được tìm thấy nhất**:
- Chạy `tu-khoa.py` cho từng video, kể cả từng short. Video dài chạy thêm `kiem-hang.py`.
- Không chép tên hay kết quả tìm kiếm từ video khác, kể cả từ video dài của cùng tập.
- Không đặt tên theo cảm tính.
- Ghi cho từng video: cụm đã tìm, điểm, mức cạnh tranh, tên đã chọn.

Đặt tiêu đề theo 4 bước, theo thứ tự: **từ khoá → câu hỏi của người xem → độ cạnh tranh → viết**. Bước nào công cụ
không chạy được (mất mạng, bị chặn) thì ghi rõ vào ghi chú của tập rồi làm tiếp, đừng bịa số liệu.

Bài học từ số liệu thật (đo 2026-10-29, xem `yt-auto/logs/hang.jsonl`):
- Kiếm hiệp ít cạnh tranh. Tên neo đứng đầu tiêu đề là video lên top 5 sau 1–2 ngày (Nhạc Bất Quần #3, Võ Đang
  Thất Hiệp #3, Tứ Đại Ác Nhân #5).
- Tên neo lớn như Ronaldo, Quang Trung, Kim Tự Tháp hay Tutankhamun bị kênh lớn và báo lớn chiếm hết kết quả. Video
  chỉ lên khi tiêu đề **mở đầu bằng một cụm dài và hẹp** trùng với cái người ta gõ ("Ronaldo Bị Gạch Tên…" lên #1–3).
- Tiêu đề mở bằng ẩn dụ của khung dựng ("Bảy Đêm Canh Lửa…", "Mặt Nạ Quân Tử", "7 Thầy, 18 Năm Giữ Lời") không
  khớp với thứ người ta gõ. Gợi ý cho "giang nam thất quái" đứng đầu là "**bị giết**", nhưng tiêu đề lại không trả lời câu đó.

### 1a. Từ khoá người ta thật sự gõ (bắt buộc, làm TRƯỚC khi viết tiêu đề)

```bash
python3 __MUSE_ROOT__/yt-auto/tools/tu-khoa.py "<tên neo>" "<tên neo + góc của tập>" "<chủ đề chung của loạt>"
# thêm --bo=chữ1,chữ2 để bỏ gợi ý trùng tên / game (vd. --bo=naga,25071990)
```

Công cụ lấy gợi ý tự động của YouTube (tiếng Việt, khu vực VN) cho từng từ gốc và các biến thể ghép thêm như "là ai",
"có thật", "vì sao", "bị giết", "ai mạnh hơn"…, rồi chấm điểm theo vị trí và số lần xuất hiện. Điểm cao = cụm được
gõ nhiều **hơn**: đây là so sánh tương đối, không phải số lượt tìm kiếm. Gợi ý game (gameplay, pvp, mobile…) đã tự bỏ.

- Gõ 3–5 từ gốc: tên neo (người, vật, sự việc), tên neo ghép với góc của tập, và chủ đề chung của loạt. Gõ cả **tên
  gọi khác** người Việt hay dùng rồi lấy tên được gõ nhiều hơn: Kiều Phong / Tiêu Phong, Vô Danh Thần Tăng / Tảo Địa
  Tăng, Giáng Long / Hàng Long Thập Bát Chưởng, Tiểu Lý Phi Đao / Cổ Long, Lý Tiểu Long / Bruce Lee.
- **Chỉ lấy cụm đúng nghĩa với video.** Bỏ cụm của người hoặc vật trùng tên, cụm game hay phim không liên quan, và cụm
  mà video không trả lời được.
- **Tên neo yếu thì ghép với tên mạnh.** Tên neo có dưới khoảng 5 gợi ý đúng nghĩa (vd. "thành côn" chỉ ra "thành
  công…") thì ghép với một tên được gõ nhiều hơn trong cùng câu chuyện, và đặt tên mạnh lên trước
  (vd. "Tạ Tốn Và Thành Côn", không viết "Thành Côn Và Tạ Tốn").
- Các cụm đúng nghĩa còn lại (cả bản không dấu, bản tiếng Anh nếu có) đưa vào tag. Câu đầu mô tả dùng lại cụm chính.

### 1b. Câu hỏi người xem đang mang theo (bắt buộc)

`tu-khoa.py` in mục **"Người xem đang hỏi gì"**: các gợi ý ghép tên neo với chết / bị giết / vì sao / là ai / có thật /
ai mạnh hơn / kết cục / A và B… Đó là câu người xem gõ để tìm, và là lời hứa họ muốn thấy.

- Lấy câu có điểm cao nhất **mà video trả lời được**, và cho tiêu đề (hoặc ít nhất một trong 3 phương án) trả lời
  thẳng câu đó. Ví dụ: "Giang Nam Thất Quái Bị Giết Thế Nào? 7 Thầy Của Quách Tĩnh", "Nhạc Bất Quần Chết Ra Sao?…".
- Video không trả lời được câu nào trong danh sách thì không được giả vờ trả lời. Dùng cụm từ khoá ở 1a và một lời hứa
  cụ thể khác.

### 1c. Đo độ cạnh tranh (bắt buộc, chạy với 1–3 cụm định đặt ở đầu tiêu đề)

```bash
python3 __MUSE_ROOT__/yt-auto/tools/kiem-hang.py "<cụm 1>" "<cụm 2>"
```

In 10 video đầu kết quả tìm kiếm (lượt xem, kênh; video của kênh Tèo có ★) và đánh giá DỄ / VỪA / KHÓ theo số video
≥ 100 nghìn lượt xem.

- **DỄ / VỪA:** dùng cụm đó ở đầu tiêu đề.
- **KHÓ, hoặc top 10 toàn báo lớn / kênh chính thức:** đổi sang **cụm dài và hẹp** gồm tên neo và góc riêng của tập,
  mà người ta có gõ (có trong `tu-khoa.py`), rồi đặt nguyên văn ở đầu tiêu đề. Ví dụ đổi "Ronaldo Quả Bóng Vàng…" thành
  "Ronaldo Bị Gạch Tên…".
- Ghi cụm đã chọn, điểm từ khoá và mức cạnh tranh vào ghi chú của tập (ideas/YYYY-MM-DD.md hoặc ghi chú tập kiếm hiệp).
- **Sau khi đăng ≥ 3 ngày:** `python3 .../kiem-hang.py --da-dang` in vị trí của từng video dài với cụm đầu tiêu đề và
  ghi vào `yt-auto/logs/hang.jsonl`. Đọc file này trước khi đặt tiêu đề cho loạt mới: cụm kiểu nào lên top, kiểu nào
  không lọt top 20.

### 1d. Luật viết tiêu đề

- **Cụm từ khoá đứng ĐẦU tiêu đề**, nguyên văn theo thứ tự chữ người ta gõ (vd. "Lời Nguyền Tutankhamun", đừng viết
  "Tutankhamun Và Lời Nguyền"). Cụm từ khoá và lời hứa chính nằm trong **40 ký tự đầu**, vì điện thoại cắt tiêu đề ở
  khoảng 45–50 ký tự.
- **Không đưa ẩn dụ của khung dựng vào 40 ký tự đầu** ("bảy đêm canh lửa", "xem số", "mặt nạ", "đem cầm"…). Ẩn dụ
  để cho chữ ảnh bìa, câu mở đầu hoặc phần cuối tiêu đề. Người chưa xem video không hiểu và cũng không ai gõ những cụm đó.
- Hứa một điều **cụ thể**: câu trả lời cho câu hỏi ở 1b, một con số có thật (đã kiểm ở ≥ 2 nguồn), hoặc một nghịch lý
  mà video trả lời được.
- Chọn một trong hai hướng cho từng tập: **dễ tìm** (nói rõ nội dung, trả lời câu người ta hỏi) hoặc **gây tò mò**.
  Không tập nào cũng giấu: tò mò liên tục thì người xem thôi tin.
- **Viết Hoa Chữ Cái Đầu Mỗi Từ**, cho mọi kênh Tèo, cả video dài lẫn Shorts. Không viết HOA toàn bộ, không emoji.
- **Đuôi cố định, script pack tự gắn** (người viết không ghi): video dài `… | Tèo Kể`, Shorts `… #Shorts | Tèo Kể`.
  Tổng ≤ 60 ký tự, không tính " #Shorts", nên phần mình viết tối đa **51** ký tự cho cả video dài lẫn Shorts.
- Số phần "(Phần N/3)" chỉ dùng khi các tập nối tiếp nhau về nội dung (xem mục 3), đặt ngay trước đuôi.
- 3 phương án tiêu đề (`titles` / `alts`) phải là **3 góc khác hẳn nhau**, ví dụ câu hỏi ở 1b, con số, nghịch lý.
  Mỗi phương án vẫn mở đầu bằng một cụm từ khoá đúng nghĩa. Không được chỉ đổi vài chữ, để sau này đem thử bằng
  Test & Compare.
- **Shorts:** mỗi short chạy `tu-khoa.py` với tên neo của chính đoạn đó. Shorts bị cắt ở khoảng 40 ký tự, nên cụm từ
  khoá phải nằm ngay đầu.
- Tiêu đề, chữ trên ảnh bìa và câu đầu mô tả là 3 câu khác nhau (mục 0). Chữ ảnh bìa không lặp quá nửa số từ của
  tiêu đề (vd. tiêu đề "…: 16 Năm Dưới Vực Sâu" mà ảnh bìa ghi "16 NĂM DƯỚI VỰC" là sai).

### 1e. Ké video đang lên (user chốt 2026-10-29)

Đo ngày 2026-10-29 (73 video nổi, 1.455 đề xuất). Video "2200 Năm Kim Dung" đạt 18,8 nghìn lượt xem, trong khi các tập
khác chỉ 138 đến 1 nghìn, vì nó đứng **#3 trong đề xuất** của "Toàn Bộ Kim Dung: 2200 Năm Võ Lâm…" (Anh Chàng IT,
868 nghìn lượt xem, đăng 4 tuần trước), và nằm cạnh "Toàn bộ Tam Quốc trong 49 phút" (4,4 triệu).
- Ké đến chủ yếu từ **đề xuất**, không phải từ tìm kiếm. 80% video nhỏ được đề xuất cạnh video nổi không trùng chữ
  nào với nó: YouTube ghép theo việc người xem có xem tiếp hay không. Vì vậy chỉ trùng từ khoá thì không đủ, phải
  **cùng chủ đề cụ thể và cùng kiểu xem**.
- "Xóm" đề xuất của kênh mình là dạng **"Toàn Bộ X / X Trong N Phút / Xếp Hạng"** (Văn Vở, Tờ Bờ, Vui Vẻ, Anh Chàng IT,
  Thạch Sùng). Trong kết quả tìm kiếm lịch sử và văn học, dạng "toàn bộ / trong N phút" có lượt xem trung vị cao nhất
  (545 nghìn). Video mình **không** bao giờ được xếp cạnh kênh phim hay clip, dù phim chiếm 47% kết quả tìm kiếm kiếm hiệp.

Cách làm:
1. **Khi chọn chủ đề (tập hoặc loạt mới), chạy** `python3 __MUSE_ROOT__/yt-auto/tools/kiem-hang.py --dang-len=<kênh>`.
   Lệnh in các video đang lên trong mảng (đăng ≤ 60 ngày, xếp theo lượt xem mỗi ngày). Nếu một video đang lên trùng chủ đề
   mà mình kể được **góc riêng** (không làm lại y hệt), thì ưu tiên chủ đề đó và làm sớm, trong khoảng 1–3 tuần khi nó còn nóng.
2. **Tiêu đề mang cụm đặc trưng của video đó** (tên nhân vật hoặc tác phẩm + khái niệm riêng, vd. "2200 Năm", "81 Kiếp
   Nạn", "Mổ Bụng Vượn"), nhưng **không chép nguyên tiêu đề**. Cụm vẫn phải đúng nghĩa với video mình. Cụm đồng nghĩa
   mà video đó dùng (vd. "khỉ trắng" cho "vượn trắng") thì đưa vào tag.
3. **Tập tổng hợp hoặc video dài 1 tiếng dùng dạng "… Trong N Phút" / "Toàn Bộ …" / "Xếp Hạng …"**. N là số phút thật
   của video, làm tròn, và chỉ chốt sau khi render.
4. **Không ké:**
   - tên phim, diễn viên, clip phim (sai người xem);
   - video, kênh hay nhân vật mà video mình không nói tới. YouTube cấm siêu dữ liệu gây hiểu lầm, có thể gỡ video;
   - chép nguyên tiêu đề hay ảnh bìa của video khác;
   - nhồi tag.
5. Ghi vào ghi chú của tập: video đang lên đã ké (link, lượt xem mỗi ngày) và cụm đã mượn.

## 2. Ảnh bìa

Ảnh bìa được xem ở **cỡ nhỏ trên điện thoại**, chỉ rộng khoảng 1/3 màn hình. Luật:

1. **Chỉ một khối chữ chính, 3–5 từ**, to và tương phản mạnh, có viền đen. Thêm tối đa **một** nhãn nhỏ (tên loạt
   hoặc một dòng phụ), không dùng cả hai. Tổng chữ trên ảnh không quá khoảng 7 từ.
2. **Hình đắt nhất phải to nhất.** Đồ vật hoặc cảnh làm nên câu chuyện (chiếc bánh chưng, quả bóng vàng, cái mặt nạ
   vàng…) chiếm khoảng 1/4 đến 1/2 khung. Đừng để nó thành một chấm nhỏ trong vòng tròn.
3. **Một nhân vật chính, mặt to, cảm xúc rõ** (sốc, nghi ngờ, giận, cười đắc thắng). Mắt hoặc tay hướng về hình đắt
   nhất. Không có gì đè lên mặt.
4. Bố cục theo luật một phần ba: chữ một bên, nhân vật và hình đắt nhất một bên. Nền đơn giản, ít chi tiết.
5. **Góc dưới bên phải để trống chữ**, vì ô thời lượng video của YouTube che chỗ đó. Hình vẽ ở góc này thì được.
6. Ảnh bìa nhắc tới đúng hình ảnh hoặc câu hỏi sẽ xuất hiện trong 30 giây đầu (xem mục 0).
7. **Soi ở cỡ điện thoại (bắt buộc):** thu ảnh về rộng 360 px rồi mở ra xem, ví dụ
   `sips -Z 360 thumbnail.png --out work/thumb-phone.png`. Ở cỡ này mà không đọc được chữ trong 1 giây, hoặc không
   nhận ra hình đắt nhất, thì làm lại.
8. Xuất ảnh 1280×720 trở lên, tỉ lệ 16:9. Ảnh nhỏ hơn 720p thì khi chạy Test & Compare, mọi ảnh thử đều bị hạ xuống 480p.

## 3. Loạt 3 tập (xem sổ loạt yt-auto/series/<kênh>.json)

- 3 tập cùng một loạt phải **nhìn là biết cùng loạt**: dùng chung một nhãn loạt (vd. "BÍ ẨN AI CẬP", "BỘ SỐ KIM DUNG")
  ở cùng một vị trí, và nếu skill cho phép thì dùng chung một màu nền chủ đạo.
- Nhưng mỗi tập vẫn khác nhau về hình đắt nhất, nhân vật, biểu cảm và kiểu chữ hook. Sang loạt mới thì đổi màu chủ đạo
  và đổi nhãn loạt.
- Tèo Tửu Lâu: `gd-check` chặn palette hay thumbnail giống tập cũ, nên dấu hiệu chung của loạt là **nhãn loạt**,
  không phải màu nền.
- Chỉ đánh số "(Phần N/3)" khi các tập NỐI TIẾP nhau về nội dung (tập sau kể tiếp tập trước). Loạt cùng chủ đề mà
  mỗi tập một tác phẩm / nhân vật riêng (Kiều, Chí Phèo, Tắt Đèn) thì không đánh số ở tiêu đề lẫn mô tả, vì người xem
  tưởng thiếu phần trước của cùng một truyện (user chốt 2026-10-28). Mô tả chỉ nhắc tên loạt và tên các tập khác.
