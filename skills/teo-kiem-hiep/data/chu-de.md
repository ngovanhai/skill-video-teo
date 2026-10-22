# Kho chủ đề Tèo Kiếm Hiệp: kiếm hiệp Trung Quốc kinh điển

Đây là kho ý tưởng cho video hoạt hình chibi **dài ít nhất 20 phút** (một chủ đề chính ghép với các chủ đề phụ, xem phần 4 và 5). Tèo làm MC, nói về tác giả, tác phẩm, so nhân vật và so võ công.

## 0. Cách dùng

- **Mỗi video dài ≥20 phút.** Một dòng trong bảng chỉ đủ khoảng 2–4 phút, nên mỗi tập ghép 1 chủ đề chính và 4–6 chủ đề phụ (xem phần 5).
- Dùng xong chủ đề nào thì ghi `(tập N)` vào cuối dòng của nó. Lần sau ưu tiên dòng chưa có đánh dấu.
- **Tự tóm tắt bằng lời mình.** Mỗi tập trích nguyên văn tối đa 1 câu, và phải ghi rõ câu đó lấy từ bộ nào. Không chép đoạn truyện, không chép lời thoại dài.
- **Mỗi dữ kiện đưa vào tập phải có ≥2 nguồn độc lập**, ví dụ Wikipedia tiếng Việt hoặc tiếng Trung, báo lớn, trang fan uy tín. Ghi các nguồn đó vào `research` của tập. Trong kho này, dòng có ⚠ là dữ kiện dễ sai hoặc khác nhau giữa các nguồn, nên phải kiểm kỹ hơn.
- **Kim Dung có 3 lớp bản**: *bản cũ* (đăng báo, thập niên 1950–60), *bản sửa* (sửa lần 2, thập niên 1970–80, phổ biến nhất) và *bản tân tu* (sửa lần 3, 1999–2006). Chi tiết nào khác nhau giữa các bản thì phải nói rõ bản trên màn hình, ví dụ "theo bản tân tu…".
- Đối đầu khác bộ hoặc khác thời, ví dụ Tiêu Phong vs Quách Tĩnh, đều là **giả tưởng**. Phải ghi "giả tưởng / ý kiến của Tèo", không được nói như thể là nguyên tác.
- Chỉ dùng thứ engine đang có:
  - **set**: `san-tap`, `rung-truc`, `mai-ngoi`, `quan-tro`, `nui-tuyet`, `ben-song`, `cau-go`. Có thể thêm `(dem)` nếu set hỗ trợ đêm.
  - **preset**: `linh`, `linh-do`, `cao-thu`, `hiep-khach`, `thu-sinh`, `chuong-quy`, `su-phu`, `nu-hiep`, `cai-bang`, `tang`, `dao-si`, `cong-tu`, `lao-quai`.
  - **override**: `robe` (mã màu hex), `hat` (`linh`/`bui`/`non`/`khan`/`none`/`troc`/`dao`), `weapon` (`kiem`/`dao`/`giao`/`quat`/`gay`/`none`), `beard`.
  - Engine không có sáo, phi đao, roi, bánh xe… Khi cần thì đặt `weapon: none` và vẽ món đó bằng hiệu ứng local.
- Bên thua chỉ **choáng hoặc lùi**, không bị hạ nhục, không có máu me.

Ký hiệu trong bảng: `A vs B` là preset của bên A rồi bên B. Override ghi trong ngoặc.

---

## 1. Bảng chủ đề theo format

### 1.1 `doi-dau`: nhân vật vs nhân vật

| chủ đề | tác phẩm / tác giả | set | preset gợi ý | ý hiệu ứng local |
|---|---|---|---|---|
| Tiêu Phong vs Quách Tĩnh: ai đánh Hàng Long Thập Bát Chưởng mạnh hơn? (giả tưởng) (tập 1) | Thiên Long Bát Bộ / Xạ Điêu Anh Hùng Truyện (Kim Dung) | nui-tuyet | cai-bang (robe #5a3d2b, beard) vs hiep-khach (robe #8b5a2b, hat khan) | hai con rồng vàng từ hai bàn tay lao vào nhau, nổ thành vảy vàng |
| Dương Quá vs Lệnh Hồ Xung: trọng kiếm hay vô chiêu? (giả tưởng) (tập 2) | Thần Điêu Hiệp Lữ / Tiếu Ngạo Giang Hồ | nui-tuyet | hiep-khach (robe #3d4a5c, weapon kiem) vs hiep-khach (robe #2f6f8f, weapon kiem) | kiếm đen nặng đập xuống gây sóng chấn hình tròn; đáp lại là chín vệt kiếm mảnh |
| Đông Tà vs Tây Độc: đấu nhạc trên Đào Hoa Đảo | Xạ Điêu Anh Hùng Truyện | ben-song | su-phu (robe #2e7d5b, weapon none) vs lao-quai (robe #3b3b3b, weapon gay, beard) | nốt nhạc xanh bay ra từ sáo ngọc va với nốt nhạc tím bật ra từ đàn tranh |
| Hồng Thất Công vs Âu Dương Phong: trận cuối trên đỉnh Hoa Sơn | Thần Điêu Hiệp Lữ | nui-tuyet | cai-bang (robe #8a7a5c, weapon gay, beard) vs lao-quai (robe #3b3b3b, weapon gay) | gậy trúc xanh và gậy rắn quấn vào nhau thành hình xoắn |
| Kiều Phong vs Mộ Dung Phục: "Bắc Kiều Phong, Nam Mộ Dung" | Thiên Long Bát Bộ | san-tap | cai-bang (robe #5a3d2b, beard) vs cong-tu (robe #4a6fa5, weapon kiem) | Đẩu Chuyển Tinh Di phản đòn thành chùm sao, rồi chùm sao bị rồng vàng nuốt mất |
| Đoàn Dự vs Hư Trúc: hai huynh đệ kết nghĩa, ai mạnh hơn? | Thiên Long Bát Bộ | rung-truc | thu-sinh (robe #e8dcc0, weapon quat) vs tang (robe #c8a165, hat troc) | sáu tia kiếm khí lúc bật lúc tắt như bóng đèn; đối diện là hoa mai băng rơi |
| Tây Môn Xuy Tuyết vs Diệp Cô Thành: quyết chiến đêm trăng trên mái Tử Cấm Thành | Lục Tiểu Phụng (Cổ Long) | mai-ngoi (dem) | hiep-khach (robe #ffffff, weapon kiem) vs cong-tu (robe #f0ece0, weapon kiem) | Thiên Ngoại Phi Tiên: một vệt sáng lao thẳng từ mặt trăng xuống | (tập 5)
| Lý Tầm Hoan vs Thượng Quan Kim Hồng: phi đao vs song hoàn | Đa Tình Kiếm Khách Vô Tình Kiếm (Cổ Long) | quan-tro | thu-sinh (robe #6d5a4a, weapon none, beard) vs lao-quai (robe #b8860b, weapon none) | chỉ thấy vệt sáng, không thấy tay phóng; hai vòng vàng xoay như bánh xe | (tập 5)
| Sở Lưu Hương vs Lục Tiểu Phụng: Đạo Soái vs Linh Tê Nhất Chỉ (giả tưởng) | Cổ Long | ben-song | cong-tu (robe #7b9acc, weapon quat) vs hiep-khach (robe #c0392b, beard) | quạt bị hai ngón tay kẹp đứng lại; cánh hoa uất kim hương bay lả tả |
| Tiểu Long Nữ vs Chu Chỉ Nhược: Ngọc Nữ Tâm Kinh vs Cửu Âm Bạch Cốt Trảo (giả tưởng) | Thần Điêu Hiệp Lữ / Ỷ Thiên Đồ Long Ký | mai-ngoi (dem) | nu-hiep (robe #ffffff) vs nu-hiep (robe #8e7cc3, weapon kiem) | dải lụa trắng gắn chuông vàng kêu leng keng; móng vuốt tím mờ như khói |
| Trương Vô Kỵ vs Đông Phương Bất Bại: Càn Khôn Đại Na Di có bẻ được kim thêu? (giả tưởng) | Ỷ Thiên Đồ Long Ký / Tiếu Ngạo Giang Hồ | mai-ngoi | hiep-khach (robe #e8e2d0, hat khan) vs cong-tu (robe #c2185b, weapon none) | mưa kim chỉ đỏ bị một vòng xoáy quay ngược về |
| Yến Nam Thiên vs Độc Cô Cầu Bại: đệ nhất kiếm Cổ Long vs Kim Dung (giả tưởng) | Tuyệt Đại Song Kiêu / Thần Điêu Hiệp Lữ | nui-tuyet | hiep-khach (robe #8b0000, beard) vs cao-thu (robe #2b2b2b, beard) | lửa đỏ Giá Y Thần Công đối đầu bốn thanh kiếm bay vòng quanh người |
| Vi Tiểu Bảo vs Đoàn Dự: thi… chạy trốn (giả tưởng) | Lộc Đỉnh Ký / Thiên Long Bát Bộ | san-tap | cong-tu (robe #d4a017, hat khan) vs thu-sinh (robe #e8dcc0, weapon quat) | dấu chân phát sáng xếp thành vòng 64 quẻ Dịch; bụi mù chạy vòng vòng |
| Quách Tĩnh vs Âu Dương Phong: chàng ngốc kiên trì vs lão độc | Xạ Điêu Anh Hùng Truyện | san-tap | hiep-khach (robe #8b5a2b, hat khan) vs lao-quai (robe #3b3b3b, weapon gay) | con cóc khổng lồ phồng bụng (Cáp Mô Công) bị rồng vàng đẩy lùi |

### 1.2 `so-vo`: võ công vs võ công

| chủ đề | tác phẩm / tác giả | set | preset gợi ý | ý hiệu ứng local |
|---|---|---|---|---|
| Hàng Long Thập Bát Chưởng vs Lục Mạch Thần Kiếm | Thiên Long Bát Bộ | san-tap | cai-bang (beard) vs thu-sinh (weapon none) | rồng vàng gầm lên vs sáu tia kiếm khí (thiếu dương, thương dương…) |
| Độc Cô Cửu Kiếm vs Tịch Tà Kiếm Pháp | Tiếu Ngạo Giang Hồ | nui-tuyet | hiep-khach (robe #2f6f8f, weapon kiem) vs cong-tu (robe #b03060, weapon kiem) | chín vệt kiếm chậm mà trúng vs bóng đỏ chớp nhoáng để lại ảo ảnh |
| Cửu Âm Chân Kinh vs Cửu Dương Chân Kinh (tập 4) | Xạ Điêu / Ỷ Thiên Đồ Long Ký | nui-tuyet | nu-hiep (robe #4a5a8a) vs hiep-khach (robe #e8e2d0, hat khan) | khí băng xanh đối đầu khí lửa cam, gặp nhau thành vòng âm dương |
| Càn Khôn Đại Na Di vs Đẩu Chuyển Tinh Di: hai môn "trả đòn" | Ỷ Thiên / Thiên Long | mai-ngoi | hiep-khach (hat khan) vs cong-tu (robe #4a6fa5) | vòng xoáy càn khôn vs các ngôi sao đổi chỗ cho nhau |
| Bắc Minh Thần Công vs Hấp Tinh Đại Pháp vs Hoá Công Đại Pháp | Thiên Long / Tiếu Ngạo | ben-song | thu-sinh vs lao-quai (robe #4b2e4b) vs lao-quai (robe #2e4b2e, beard) | biển xoáy xanh hút nội lực; đối diện là xoáy đen và sương độc xanh lá |
| Nhất Dương Chỉ vs Đạn Chỉ Thần Thông | Xạ Điêu | ben-song | tang (robe #c8a165, hat troc, beard) vs su-phu (robe #2e7d5b) | đầu ngón tay sáng như than hồng vs viên đá bay vèo tạo vệt gió |
| Lăng Ba Vi Bộ vs Thê Vân Tung | Thiên Long / Ỷ Thiên | rung-truc | thu-sinh (weapon quat) vs dao-si (hat dao) | bước chân nở hoa sóng nước vs bậc mây hiện dưới chân |
| Thái Cực Quyền vs Thất Thương Quyền | Ỷ Thiên Đồ Long Ký | san-tap | dao-si (robe #f0f0f0, hat dao, beard) vs lao-quai (robe #6b4a2b, beard) | vòng âm dương xoay mềm nuốt bảy vệt đỏ |
| Cáp Mô Công vs Nhất Dương Chỉ: khắc tinh có thật không? | Xạ Điêu | nui-tuyet | lao-quai (weapon gay) vs dao-si (hat dao) | con cóc phồng to rồi xì hơi khi bị ngón tay sáng điểm trúng |
| Ảm Nhiên Tiêu Hồn Chưởng vs Hàng Long Thập Bát Chưởng (giả tưởng) | Thần Điêu Hiệp Lữ | nui-tuyet | hiep-khach (robe #3d4a5c) vs hiep-khach (robe #8b5a2b, hat khan) | mây xám rơi mưa buồn vs rồng vàng; một tay áo trống phấp phới |
| Tiểu Lý Phi Đao vs Thiên Ngoại Phi Tiên (giả tưởng) | Cổ Long | mai-ngoi (dem) | thu-sinh (beard) vs cong-tu (robe #f0ece0, weapon kiem) | dòng chữ "lệ bất hư phát" (chưa từng trượt) hiện khi phi đao bay ra |
| Giá Y Thần Công vs Minh Ngọc Công | Tuyệt Đại Song Kiêu (Cổ Long) | nui-tuyet | hiep-khach (robe #8b0000, beard) vs nu-hiep (robe #e0f0ff) | lửa đỏ bùng như sấm vs da hoá ngọc trắng lạnh toả sáng |
| Hoả Diệm Đao vs Lục Mạch Thần Kiếm (trận ở chùa Thiên Long) | Thiên Long Bát Bộ | san-tap | tang (robe #b22222, hat troc) vs thu-sinh (weapon none) | lưỡi đao lửa vô hình chém xuống, bị sáu tia kiếm khí cắt vụn |
| Thiên Sơn Chiết Mai Thủ vs 72 tuyệt kỹ Thiếu Lâm | Thiên Long Bát Bộ | nui-tuyet | tang (hat troc) vs tang (robe #7a6a4f, hat troc, beard) | bàn tay bẻ ra cành mai băng vs 72 ô bí kíp lật như bài tú lơ khơ |

### 1.3 `tac-gia`: tác giả

| chủ đề | tác phẩm / tác giả | set | preset gợi ý | ý hiệu ứng local |
|---|---|---|---|---|
| Kim Dung là ai? 15 bộ truyện gói trong một câu đối | Kim Dung (Tra Lương Dung) | mai-ngoi | thu-sinh (robe #3a3a5a, beard) | 14 chữ đầu câu đối rơi xuống thành 14 cuốn sách, thêm Việt Nữ Kiếm |
| Vì sao bút danh là "Kim Dung"? | Kim Dung | quan-tro | thu-sinh (robe #3a3a5a) | chữ Hán 鏞 tách đôi thành 金 + 庸 |
| Kim Dung sửa truyện 3 lần: sửa những gì? | Kim Dung | mai-ngoi | thu-sinh (beard) | ba cuốn sách chồng lên, bút đỏ gạch xoá bay qua bay lại |
| Cổ Long: câu văn ngắn, rượu và nhân vật cô độc | Cổ Long (Hùng Diệu Hoa) | quan-tro (dem) | hiep-khach (robe #4a3a2a, weapon none) | chén rượu rót ra, chữ trên màn hình xuống dòng từng chữ | (tập 5)
| Kim Dung vs Cổ Long: hai phong cách | Kim Dung / Cổ Long | mai-ngoi | thu-sinh vs hiep-khach | màn hình chia đôi: cuộn sách dày vs mảnh giấy ngắn | (tập 5)
| Lương Vũ Sinh: người mở đầu "tân phái võ hiệp" | Lương Vũ Sinh (Trần Văn Thống) | nui-tuyet | thu-sinh (robe #5a6a7a, beard) | bảy luồng kiếm khí từ đỉnh Thiên Sơn bay xuống |
| Trận tỷ võ ở Ma Cao năm 1954 đã sinh ra cả một trào lưu | Lương Vũ Sinh / Kim Dung | san-tap | cao-thu vs cao-thu | tờ báo bay ra, chữ "Long Hổ Đấu Kinh Hoa" in đậm |
| Ôn Thuỵ An: 20 tuổi viết Tứ Đại Danh Bổ | Ôn Thuỵ An (Ôn Lương Ngọc) | mai-ngoi | thu-sinh (robe #2b4a6b) | bốn cái bóng bộ khoái lần lượt xuất hiện như bài tẩy |
| Hoàng Dịch: cha đẻ huyền huyễn võ hiệp | Hoàng Dịch ⚠ (tên thật cần kiểm) | nui-tuyet | thu-sinh (robe #3a2a4a) | hư không nứt vỡ như kính (Phá Toái Hư Không) |
| Ngoạ Long Sinh: nổi tiếng sau một đêm nhờ Phi Yến Kinh Long | Ngoạ Long Sinh (Ngưu Hạc Đình) | rung-truc | thu-sinh (robe #4a5a3a, beard) | chim yến bay vụt qua, rồng giật mình ngóc đầu |
| "Ngũ đại tông sư" võ hiệp là những ai? | Kim Dung, Cổ Long, Lương Vũ Sinh, Ngoạ Long Sinh, Ôn Thuỵ An ⚠ (danh sách khác nhau tuỳ nguồn) | san-tap | 5× thu-sinh, mỗi người một màu robe | năm cuốn sách đứng lên như năm cao thủ chào nhau |
| Đài Loan tam kiệt: Ngoạ Long Sinh, Tư Mã Linh, Gia Cát Thanh Vân | Ngoạ Long Sinh và đồng nghiệp | quan-tro | 3× thu-sinh | ba ngọn đèn lồng lần lượt sáng lên |

### 1.4 `tac-pham`: tóm tắt vui một bộ

| chủ đề | tác phẩm / tác giả | set | preset gợi ý | ý hiệu ứng local |
|---|---|---|---|---|
| Xạ Điêu trong 2 phút: chàng ngốc thành Bắc Hiệp | Xạ Điêu Anh Hùng Truyện (Kim Dung) | san-tap | hiep-khach (robe #8b5a2b, hat khan) + nu-hiep (robe #6fa86f) | mũi tên bắn rơi hai con chim điêu cùng lúc |
| Thần Điêu: 16 năm chờ một lời hẹn | Thần Điêu Hiệp Lữ | nui-tuyet | hiep-khach (robe #3d4a5c) + nu-hiep (robe #ffffff) | con chim điêu lớn dang cánh che kín khung hình |
| Ỷ Thiên Đồ Long Ký: một thanh đao làm cả giang hồ đánh nhau | Ỷ Thiên Đồ Long Ký | nui-tuyet | hiep-khach (hat khan) | đao và kiếm chém nhau ra tia lửa, bên trong rơi ra cuộn giấy |
| Thiên Long Bát Bộ: ba nhân vật chính, ba số phận | Thiên Long Bát Bộ | san-tap | cai-bang + thu-sinh + tang | ba vòng sáng tách ra từ một chữ "Thiên Long" |
| Tiếu Ngạo Giang Hồ: một khúc nhạc, hai người bạn khác phe | Tiếu Ngạo Giang Hồ | rung-truc | hiep-khach (robe #2f6f8f) + nu-hiep (robe #2b2b4b) | nốt nhạc cầm và tiêu quấn vào nhau |
| Lộc Đỉnh Ký: nhân vật chính không biết võ | Lộc Đỉnh Ký | mai-ngoi | cong-tu (robe #d4a017, hat khan) | chủy thủ sắc chém đôi cái bàn, áo giáp hộ thân bật tung đòn đánh |
| Liên Thành Quyết: bộ truyện "đen" nhất của Kim Dung | Liên Thành Quyết | quan-tro (dem) | hiep-khach (robe #6b6b6b) | câu thơ Đường hiện ra rồi tách thành con số (bí mật kiếm phổ) |
| Hiệp Khách Hành: người không biết chữ lại giải được bí kíp | Hiệp Khách Hành | ben-song | hiep-khach (robe #a0522d) | chữ trên vách đá biến thành hình nòng nọc nhảy múa |
| Bích Huyết Kiếm: Kim Xà Lang Quân để lại gì? | Bích Huyết Kiếm | rung-truc | hiep-khach (robe #2e5e4e, weapon kiem) | thanh kiếm cong như con rắn vàng uốn mình |
| Tuyết Sơn Phi Hồ: cái kết bỏ lửng nổi tiếng | Tuyết Sơn Phi Hồ | nui-tuyet | hiep-khach (robe #8b4513, weapon dao) | đao giơ lên rồi đứng hình; trên màn hình hiện "chém hay không chém?" |
| Đa Tình Kiếm Khách Vô Tình Kiếm: phi đao không bao giờ trượt | Cổ Long | quan-tro | thu-sinh (robe #6d5a4a, beard) | tượng gỗ dần thành hình dưới con dao nhỏ |
| Tuyệt Đại Song Kiêu: hai anh em sinh đôi bị nuôi để giết nhau | Cổ Long | rung-truc | cong-tu (robe #f0f0f0) + hiep-khach (robe #e07a2f) | hai cái bóng soi gương, một trắng một cam |
| Bạch Phát Ma Nữ Truyện: tóc bạc sau một đêm | Lương Vũ Sinh | nui-tuyet | nu-hiep (robe #ffffff, weapon kiem) | tóc đen chuyển trắng từ chân tóc lên ngọn, hoa trên núi tuyết nở |
| Tứ Đại Danh Bổ: bốn bộ khoái, bốn năng lực | Ôn Thuỵ An | mai-ngoi | 4×: thu-sinh, hiep-khach, cao-thu, cong-tu | bốn thẻ nhân vật lật ra như bộ bài |
| Tầm Tần Ký: đặc công xuyên không về thời Chiến Quốc | Hoàng Dịch | san-tap | cao-thu (robe #3a3a3a) | cổng thời gian xoáy, đồng hồ hiện đại rơi xuống đất cổ |

### 1.5 `top`: xếp hạng

| chủ đề | tác phẩm / tác giả | set | preset gợi ý | ý hiệu ứng local |
|---|---|---|---|---|
| Thiên hạ Ngũ Tuyệt qua hai lần Hoa Sơn luận kiếm (tập 3) | Xạ Điêu / Thần Điêu | nui-tuyet | su-phu, lao-quai, tang, cai-bang, dao-si | năm phương Đông–Tây–Nam–Bắc–Trung sáng lần lượt trên la bàn |
| Top 5 võ công mạnh nhất Kim Dung (ý kiến Tèo) | Kim Dung | san-tap | tuỳ nhân vật | bảng xếp hạng lật kiểu domino |
| Top 5 thần binh Kim Dung | Kim Dung | nui-tuyet | cao-thu | binh khí lần lượt cắm xuống đất phát sáng |
| Top 5 khinh công | Kim Dung / Cổ Long | rung-truc | thu-sinh, dao-si, cong-tu | đồng hồ bấm giờ chạy trên đầu từng người |
| Top 5 phản diện "nguỵ quân tử" | Kim Dung | mai-ngoi | cong-tu, chuong-quy, lao-quai | mặt nạ cười rơi xuống để lộ mặt cau có |
| Top 5 sư phụ tệ nhất (Nhạc Bất Quần đứng đâu?) | Kim Dung | san-tap | su-phu, lao-quai | thước kẻ của thầy đồ gõ "cốc" lên đầu |
| Top 5 nhân vật thích uống rượu | Kim Dung / Cổ Long | quan-tro | cai-bang, hiep-khach, thu-sinh | vò rượu bay vòng tròn, mỗi vò một cái tên |
| Top 5 người không giỏi võ mà vẫn thắng | Lộc Đỉnh Ký, Thiên Long… | quan-tro | cong-tu, thu-sinh | đèn bóng đèn "ý tưởng" bật trên đầu |
| Top 5 nữ hiệp | Kim Dung / Cổ Long / Lương Vũ Sinh | ben-song | nu-hiep với nhiều màu robe | cánh hoa xoáy theo từng người |
| Top 5 thần thú (chim điêu, Mãng Cổ Chu Cáp, ong ngọc…) | Kim Dung | rung-truc | — | thú chibi lần lượt nhảy vào khung hình |
| Top 5 trận đánh đông người (Tụ Hiền Trang, Quang Minh Đỉnh…) | Kim Dung | san-tap | linh, linh-do + nhân vật chính | quân chibi đông nghịt rồi bị một chiêu thổi bay ngã ngồi |
| Top 5 bí kíp bị tranh giành nhiều nhất | Kim Dung | quan-tro | thu-sinh | cuốn sách bị mười bàn tay giằng co |
| Top 5 tên chiêu thức nghe đẹp nhất | Kim Dung / Cổ Long | ben-song | — | chữ thư pháp viết dần ra theo nét bút lông |

### 1.6 `mon-phai`: môn phái vs môn phái

| chủ đề | tác phẩm / tác giả | set | preset gợi ý | ý hiệu ứng local |
|---|---|---|---|---|
| Thiếu Lâm vs Võ Đang: "Bắc Thiếu Lâm, Nam Võ Đang"? (tập 8) | Kim Dung | san-tap | tang (hat troc) vs dao-si (hat dao) | chuông chùa ngân vs vòng Thái Cực xoay |
| Toàn Chân giáo vs Cổ Mộ phái | Thần Điêu Hiệp Lữ | mai-ngoi (dem) | dao-si (hat dao) vs nu-hiep (robe #ffffff) | ong ngọc bay vo ve quanh đạo sĩ |
| Hoa Sơn Khí tông vs Kiếm tông (tập 10) | Tiếu Ngạo Giang Hồ | nui-tuyet | su-phu (robe #6a5acd) vs hiep-khach (weapon kiem) | đồng hồ cát: khí chảy chậm vs kiếm nhanh |
| Nhật Nguyệt Thần Giáo vs Ngũ Nhạc Kiếm Phái | Tiếu Ngạo Giang Hồ | nui-tuyet | lao-quai (robe #8b0000) vs 5× hiep-khach | mặt trời và mặt trăng ghép thành chữ 明 |
| Minh Giáo vs Lục Đại Môn Phái vây Quang Minh Đỉnh | Ỷ Thiên Đồ Long Ký | nui-tuyet | hiep-khach (robe #c0392b) vs tang, dao-si, nu-hiep… | ngọn lửa thánh bùng lên giữa núi tuyết |
| Tiêu Dao phái vs Tinh Túc phái | Thiên Long Bát Bộ | rung-truc | tang (hat troc) vs lao-quai (robe #2e4b2e, beard) | đệ tử Tinh Túc thổi kèn tung hô bị gió cuốn ngã ngồi |
| Cái Bang Tịnh Y phái vs Ô Y phái | Xạ Điêu Anh Hùng Truyện | quan-tro | cai-bang (robe #d8d0b8) vs cai-bang (robe #4a4038) | bao bố trên vai đếm số túi như cấp bậc |
| Di Hoa Cung vs Ác Nhân Cốc | Tuyệt Đại Song Kiêu (Cổ Long) | rung-truc (dem) | nu-hiep (robe #e0f0ff) vs lao-quai (robe #4b3621) | hoa rơi trắng vs mười cái bóng ác nhân le lưỡi trêu |
| Thiên Địa Hội vs Thần Long Giáo | Lộc Đỉnh Ký | mai-ngoi | hiep-khach (robe #4a6a3a) vs lao-quai (robe #b8860b) | khẩu hiệu tung hô bay ra dài ngoằng rồi gãy |
| Thiên Sơn phái vs Võ Đang | Bạch Phát Ma Nữ Truyện / Thất Kiếm Hạ Thiên Sơn (Lương Vũ Sinh) | nui-tuyet | nu-hiep (robe #ffffff) vs dao-si (hat dao) | hoa Ưu Đàm nở trên vách tuyết ⚠ |
| Âm Quý Phái vs Từ Hàng Tĩnh Trai | Đại Đường Song Long Truyện (Hoàng Dịch) | ben-song | nu-hiep (robe #4b0082) vs nu-hiep (robe #f5f5dc) | ánh sáng tím và ánh sáng trắng nhuộm hai nửa khung hình |
| Kim Phong Tế Vũ Lâu vs Lục Phân Bán Đường | Thuyết Anh Hùng, Thuỳ Thị Anh Hùng (Ôn Thuỵ An) ⚠ | mai-ngoi (dem) | cong-tu (robe #c0c0c0) vs chuong-quy (robe #8b0000) | gió vàng mưa bụi thổi nghiêng khung hình |
| Thiếu Lâm vs Cái Bang: hai "đại phái" ai đông hơn? | Kim Dung | san-tap | tang vs cai-bang | đếm người bằng bảng số chạy liên tục |

### 1.7 `binh-khi`: thần binh

| chủ đề | tác phẩm / tác giả | set | preset gợi ý | ý hiệu ứng local |
|---|---|---|---|---|
| Ỷ Thiên Kiếm vs Đồ Long Đao | Ỷ Thiên Đồ Long Ký | nui-tuyet | nu-hiep (weapon kiem) vs hiep-khach (weapon dao) | hai thứ chém nhau, gãy, rơi ra cuộn giấy ⚠ (nội dung bên trong khác theo bản) | (tập 7)
| Huyền Thiết Trọng Kiếm: kiếm không cần sắc | Thần Điêu Hiệp Lữ | nui-tuyet | hiep-khach (robe #3d4a5c, weapon kiem) | mặt đất lún xuống khi kiếm cắm xuống |
| Bốn thanh kiếm trong Kiếm Trủng của Độc Cô Cầu Bại (tập 2) | Thần Điêu Hiệp Lữ | nui-tuyet | cao-thu (beard) | bốn thanh kiếm hiện lần lượt: lợi kiếm, nhuyễn kiếm, trọng kiếm, mộc kiếm |
| Đả Cẩu Bổng: cây gậy trúc làm tín vật bang chủ | Xạ Điêu / Thiên Long | quan-tro | cai-bang (weapon gay) | gậy xanh biếc phát sáng, mấy con chó chibi chạy tán loạn |
| Tiểu Lý Phi Đao | Đa Tình Kiếm Khách Vô Tình Kiếm | quan-tro | thu-sinh (weapon none) | lưỡi dao nhỏ dài ba tấc ⚠ lơ lửng, xoay chậm cho người xem thấy rõ |
| Kim Xà Kiếm và Kim Xà Trùy | Bích Huyết Kiếm | rung-truc | hiep-khach (weapon kiem) | kiếm vàng uốn như rắn, mũi trùy bay ra theo đường cong |
| Quân Tử Kiếm và Thục Nữ Kiếm | Thần Điêu Hiệp Lữ | rung-truc | hiep-khach + nu-hiep (weapon kiem) | hai thanh kiếm ghép lại thành một hình trái tim |
| Thất Chủng Vũ Khí: bảy món của Cổ Long | Cổ Long ⚠ (món thứ 7 cần kiểm) | quan-tro | nhiều preset | bảy món xếp thành vòng: Trường Sinh Kiếm, Khổng Tước Linh, Bích Ngọc Đao… |
| Thiên Nhai Minh Nguyệt Đao: thanh đao đen của Phó Hồng Tuyết | Biên Thành Lãng Tử / Thiên Nhai Minh Nguyệt Đao (Cổ Long) | nui-tuyet | hiep-khach (robe #1a1a1a, weapon dao) | đao đen chém ra ánh trăng bạc |
| Long Phượng Song Hoàn | Đa Tình Kiếm Khách Vô Tình Kiếm | mai-ngoi | lao-quai (robe #b8860b) | hai vòng vàng hoá rồng và phượng xoay quanh nhau |
| Thuần Dương Vô Cực Kiếm của Yến Nam Thiên ⚠ | Tuyệt Đại Song Kiêu | nui-tuyet | hiep-khach (robe #8b0000, beard, weapon kiem) | kiếm toả hơi nóng làm tuyết tan quanh chân |
| Bánh xe của Kim Luân Pháp Vương | Thần Điêu Hiệp Lữ | san-tap | tang (robe #b8860b, hat troc, weapon none) | năm bánh xe kim loại bay vòng như đĩa ⚠ (số bánh, chất liệu) |
| Huyết Đao | Liên Thành Quyết | nui-tuyet | lao-quai (robe #6b0000, hat troc) | thanh đao mềm cong như rắn đỏ (không có máu) |

### 1.8 `giai-ma`: bí ẩn / vì sao

| chủ đề | tác phẩm / tác giả | set | preset gợi ý | ý hiệu ứng local |
|---|---|---|---|---|
| Vì sao lão tăng quét lá Tảo Địa Tăng mạnh nhất Thiên Long? (tập 6) | Thiên Long Bát Bộ | san-tap | tang (robe #7a6a4f, hat troc, weapon gay, beard) | lá rơi đứng lại giữa không trung khi ông quét |
| Tịch Tà Kiếm Phổ và Quỳ Hoa Bảo Điển có chung gốc? | Tiếu Ngạo Giang Hồ | mai-ngoi (dem) | cong-tu (robe #c2185b) | hai cuốn sách bay chồng lên nhau, khớp từng trang |
| Bên trong Ỷ Thiên Kiếm và Đồ Long Đao giấu gì? | Ỷ Thiên Đồ Long Ký ⚠ ghi bản | nui-tuyet | hiep-khach | cuộn giấy mở ra, chữ mờ trên màn hình (không ghi nội dung) |
| Vì sao Lục Mạch Thần Kiếm của Đoàn Dự lúc được lúc không? | Thiên Long Bát Bộ | rung-truc | thu-sinh (weapon none) | sáu ngón tay chập chờn như bóng đèn sắp hỏng |
| Vì sao Đoàn Dự uống rượu không say? | Thiên Long Bát Bộ | quan-tro | thu-sinh + cai-bang | rượu chảy ra từ đầu ngón út thành dòng nhỏ |
| Vương Ngữ Yên thuộc làu bí kíp, sao không đánh được? | Thiên Long Bát Bộ | ben-song | nu-hiep (robe #f8d7e0, weapon none) | sách bay quanh đầu, mắt hiện chữ "biết nhưng không làm được" |
| Độc Cô Cầu Bại là ai, sao chưa từng xuất hiện? | Thần Điêu / Tiếu Ngạo | nui-tuyet | cao-thu vẽ thành bóng đen | dòng chữ trên vách đá hiện từ từ (tự viết lời mình) |
| Ai viết Cửu Âm Chân Kinh? (tập 4) | Xạ Điêu / Thần Điêu | mai-ngoi | thu-sinh (robe #3a3a5a, beard) | ông quan đọc sách đạo tạng, chữ bay thành chiêu thức |
| Hàng Long "Thập Bát" Chưởng vốn có 28 chưởng? (tập 1) | Thiên Long Bát Bộ, **bản tân tu** ⚠ | nui-tuyet | cai-bang + tang | 28 con rồng nhỏ nhập lại thành 18 con rồng lớn |
| Sư phụ thật của Hư Trúc là ai? | Thiên Long Bát Bộ | rung-truc | tang (hat troc) + lao-quai (robe #f0f0f0, beard) | ván cờ Trân Lung, một nước đi tự lấp mắt cờ lại mở ra cả ván |
| Vì sao Kim Mao Sư Vương Tạ Tốn bị mù? | Ỷ Thiên Đồ Long Ký | nui-tuyet | lao-quai (robe #c8a040, beard) | bờm vàng tung bay, tiếng gầm Sư Tử Hống thành vòng sóng âm |
| Ai là cô gái áo vàng trong Ỷ Thiên? | Ỷ Thiên Đồ Long Ký | mai-ngoi | nu-hiep (robe #f0c419) | bóng chim điêu lướt qua phía sau cô gái (gợi ý, không khẳng định) |
| "Phá Toái Hư Không" nghĩa là gì? | Hoàng Dịch | nui-tuyet | cao-thu | bầu trời nứt như kính rồi ghép lại |
| Vì sao Đoàn Dự cưới ai thì tuỳ bản? | Thiên Long Bát Bộ: **bản sửa** vs **bản tân tu** | mai-ngoi | thu-sinh + nu-hiep ×3 | hai cuốn sách mở ra hai cái kết song song |
| Nhân vật bị "xoá sổ" qua các lần sửa: Tần Nam Cầm | Xạ Điêu, **bản cũ** vs **bản sửa** ⚠ | quan-tro | nu-hiep (robe #c0a080) | nhân vật mờ dần như ảnh bị tẩy |

### Format mở rộng (đề xuất)

> Các format 1.9–1.18 đã có trong SKILL.md và story-check.mjs, khai báo thẳng tên format trong `story.format`. Format ghi trong ngoặc ở mỗi tiêu đề chỉ là format gần nhất để tham khảo dàn ý.

### 1.9 `cuoc-doi`: cuộc đời một nhân vật (tạm dùng: `tac-pham`)

Kể đời nhân vật qua 5–6 mốc, mỗi mốc là một cảnh ngắn. Chuyện bi kịch chỉ nói nhẹ: không vẽ cảnh chết, chỉ dùng biểu tượng như chiếc lá rơi hay ngọn nến tắt.

| chủ đề | tác phẩm / tác giả | set | preset gợi ý | ý hiệu ứng local |
|---|---|---|---|---|
| Tiêu Phong: từ bang chủ Cái Bang đến người không có quê hương (tập 1) | Thiên Long Bát Bộ | nui-tuyet | cai-bang (robe #5a3d2b, beard) | chữ "Khiết Đan" khắc trên vách đá hiện ra ở mốc đầu và mốc cuối, đều ở Nhạn Môn Quan |
| Dương Quá: đứa trẻ mồ côi thành Thần Điêu Đại Hiệp | Thần Điêu Hiệp Lữ | nui-tuyet | hiep-khach (robe #3d4a5c, weapon kiem) | cái lịch xé dần đếm đủ 16 năm |
| Quách Tĩnh: chậm hiểu nhưng giữ thành Tương Dương cả đời | Xạ Điêu / Thần Điêu | mai-ngoi | hiep-khach (robe #8b5a2b, hat khan) | thanh "chậm hiểu" tụt xuống, thanh "kiên trì" vọt lên |
| Lệnh Hồ Xung: đại đệ tử bị trục xuất, cuối cùng sống tự do (tập 10) | Tiếu Ngạo Giang Hồ | rung-truc | hiep-khach (robe #2f6f8f, weapon kiem) | hồ lô rượu đổi màu theo từng chặng đời |
| Trương Vô Kỵ: tuổi thơ trúng Huyền Minh Thần Chưởng, lớn lên làm giáo chủ Minh Giáo | Ỷ Thiên Đồ Long Ký | nui-tuyet | hiep-khach (robe #e8e2d0, hat khan) | hơi lạnh xanh quanh cậu bé tan dần thành lửa cam |
| Hư Trúc: chú tiểu vụng về bỗng thành chưởng môn Tiêu Dao phái | Thiên Long Bát Bộ | rung-truc | tang (robe #c8a165, hat troc) | ván cờ Trân Lung, rồi 70 năm công lực chảy vào người như dòng sáng |
| Vi Tiểu Bảo: từ đứa bé đầu đường đến Lộc Đỉnh Công | Lộc Đỉnh Ký | mai-ngoi | cong-tu (robe #d4a017, hat khan) | mũ quan to dần theo từng mốc |
| Hoàng Dược Sư: thiên tài cô độc trên Đào Hoa Đảo | Xạ Điêu Anh Hùng Truyện | ben-song | su-phu (robe #2e7d5b, beard) | hoa đào rơi đúng theo nhịp sáo |
| Chu Bá Thông: ông già nghịch như trẻ con | Xạ Điêu / Thần Điêu | ben-song | lao-quai (robe #9acd32, beard) | hai tay vẽ hai hình khác nhau (Song Thủ Hỗ Bác) |
| Đông Phương Bất Bại: từ phó giáo chủ đến kẻ ẩn mình thêu hoa | Tiếu Ngạo Giang Hồ | mai-ngoi (dem) | cong-tu (robe #c2185b) | kim chỉ thêu dần thành bức tranh hoa |
| Lý Tầm Hoan: thám hoa nhường người yêu cho bạn | Đa Tình Kiếm Khách Vô Tình Kiếm | quan-tro (dem) | thu-sinh (robe #6d5a4a, beard) | tượng gỗ khắc mãi vẫn là cùng một khuôn mặt | (tập 5)
| Tiểu Ngư Nhi: lớn lên giữa mười ác nhân mà vẫn tốt bụng | Tuyệt Đại Song Kiêu | rung-truc (dem) | cong-tu (robe #e07a2f) | mười cái bóng ác nhân lần lượt dạy một "chiêu" xấu, cậu bé lại dùng vào việc tốt |
| Trương Tam Phong: từ chú tiểu Thiếu Lâm đến tổ sư Võ Đang (tập 8) | Thần Điêu / Ỷ Thiên | san-tap | dao-si (robe #e0e0e0, hat dao, beard) | tóc chuyển đen sang trắng, vòng Thái Cực lớn dần |

### 1.10 `su-that`: người thật, chuyện thật trong truyện (tạm dùng: `giai-ma`)

Format "sử thật vs truyện". Màn hình chia đôi: bên trái là **Sử**, bên phải là **Truyện**. Dữ kiện lịch sử bắt buộc ≥2 nguồn.

| chủ đề | tác phẩm / tác giả | set | preset gợi ý | ý hiệu ứng local |
|---|---|---|---|---|
| Tiêu Phong có thật: danh tướng nhà Liêu, khác hẳn trong truyện (tập 1) | Thiên Long Bát Bộ ⚠ (năm sinh–mất cần kiểm) | nui-tuyet | cai-bang vs cao-thu (robe #4a4a6a, hat linh) | cuộn "Liêu sử" mở ra cạnh cuốn tiểu thuyết |
| Đoàn Dự ngoài đời: vua Đại Lý trị vì lâu nhất ⚠ | Thiên Long Bát Bộ | ben-song | thu-sinh vs cong-tu (robe #d4a017) | vương miện đặt lên đầu Đoàn Dự chibi |
| Nhất Đăng Đại Sư ngoài đời có đi tu không? | Xạ Điêu (Đoàn Trí Hưng) | san-tap | tang vs cong-tu | áo cà sa hiện ra rồi mờ đi kèm dấu hỏi |
| Khâu Xứ Cơ và cuộc gặp Thành Cát Tư Hãn | Xạ Điêu Anh Hùng Truyện | san-tap | dao-si (hat dao, beard) vs cao-thu (robe #6b4a2b) | bình "thuốc trường sinh" vỡ thành dòng chữ "dưỡng sinh" |
| Vương Trùng Dương: tổ sư Toàn Chân có thật | Xạ Điêu Anh Hùng Truyện | san-tap | dao-si (robe #f0f0f0, hat dao, beard) | bảy ngôi sao Bắc Đẩu (Toàn Chân thất tử) sáng lên |
| Thành Cát Tư Hãn trong mắt Quách Tĩnh | Xạ Điêu Anh Hùng Truyện | san-tap | cao-thu (robe #6b4a2b) + hiep-khach | cung tên và lá cờ đuôi ngựa bay |
| Hốt Tất Liệt xuất hiện trong Thần Điêu | Thần Điêu Hiệp Lữ | mai-ngoi | cao-thu (robe #8b0000) | bản đồ Tương Dương bị bóng ngựa phủ lên |
| Khang Hi và Vi Tiểu Bảo: tình bạn ngoài sử sách | Lộc Đỉnh Ký | mai-ngoi | cong-tu (robe #f0c419) + cong-tu (robe #d4a017) | hai cậu bé vật nhau trong cung, rồi thành vua và quan |
| Trương Tam Phong có thật không? | Ỷ Thiên Đồ Long Ký ⚠ (sử còn tranh cãi) | san-tap | dao-si (beard) | chân dung mờ nhoè cạnh dấu hỏi |
| Thiếu Lâm Tự ngoài đời và chuyện "mười ba côn tăng" ⚠ | Thiếu Lâm (motif chung) | san-tap | tang (weapon gay) | 13 cây gậy dựng thành hàng |
| Minh Giáo ngoài đời: tôn giáo từ Ba Tư ⚠ | Ỷ Thiên Đồ Long Ký | nui-tuyet | hiep-khach (robe #c0392b) | ngọn lửa đi từ bản đồ Ba Tư sang Trung Nguyên |

### 1.11 `neu-nhu`: what-if (tạm dùng: `doi-dau` hoặc `giai-ma`)

Luôn ghi "giả tưởng" trên màn hình. Mỗi tập chỉ đổi đúng **một** chi tiết so với nguyên tác.

| chủ đề | tác phẩm / tác giả | set | preset gợi ý | ý hiệu ứng local |
|---|---|---|---|---|
| Nếu Tiêu Phong không đánh nhầm A Châu? | Thiên Long Bát Bộ | nui-tuyet | cai-bang + nu-hiep (robe #f8c8a0) | thời gian tua ngược bằng đồng hồ quay ngược |
| Nếu Dương Quá không mất tay? | Thần Điêu Hiệp Lữ | nui-tuyet | hiep-khach (robe #3d4a5c) | tay áo trống liền lại, Huyền Thiết Trọng Kiếm thành song kiếm |
| Nếu Lệnh Hồ Xung luyện Tịch Tà Kiếm Phổ? | Tiếu Ngạo Giang Hồ | nui-tuyet | hiep-khach (robe #b03060) | hồ lô rượu đổi thành kim thêu, Tèo vội hét "STOP!" |
| Nếu Trương Vô Kỵ chọn sống ở Băng Hoả Đảo cả đời? | Ỷ Thiên Đồ Long Ký | nui-tuyet | hiep-khach (hat khan) | quả cầu tuyết nhỏ chứa cả giang hồ bên trong |
| Nếu Vi Tiểu Bảo biết võ thật? | Lộc Đỉnh Ký | san-tap | cong-tu (robe #d4a017) | thanh "may mắn" tụt về 0, thanh "võ công" lên 100 |
| Nếu Đoàn Dự điều khiển được Lục Mạch Thần Kiếm từ đầu? | Thiên Long Bát Bộ | rung-truc | thu-sinh | sáu tia kiếm khí ổn định như đèn LED |
| Nếu Quách Tĩnh và Dương Khang đổi số phận? | Xạ Điêu Anh Hùng Truyện | san-tap | hiep-khach ×2 (robe khác màu) | hai bức chân dung tráo chỗ cho nhau |
| Nếu Hồng Thất Công không mất võ công? | Xạ Điêu | quan-tro | cai-bang (weapon gay) | đùi gà biến thành đầu rồng |
| Nếu Độc Cô Cầu Bại sống cùng thời Lệnh Hồ Xung? | Tiếu Ngạo / Thần Điêu | nui-tuyet | cao-thu (beard) + hiep-khach | bốn thanh kiếm nhường chỗ cho một thanh |
| Nếu Ngũ Tuyệt cùng ngồi một bàn ăn? (tập vui) | Xạ Điêu | quan-tro | su-phu, lao-quai, tang, cai-bang, dao-si | Hồng Thất Công giành đùi gà, bát đũa bay qua bay lại |

### 1.12 `cap-doi`: tình yêu giang hồ (tạm dùng: `top` hoặc `tac-pham`)

| chủ đề | tác phẩm / tác giả | set | preset gợi ý | ý hiệu ứng local |
|---|---|---|---|---|
| Dương Quá – Tiểu Long Nữ: chờ nhau 16 năm (tập 9) | Thần Điêu Hiệp Lữ | nui-tuyet | hiep-khach + nu-hiep (robe #ffffff) | đáy vực đầy hoa trắng, hai bóng gặp nhau |
| Quách Tĩnh – Hoàng Dung: chàng ngốc và cô gái thông minh nhất | Xạ Điêu Anh Hùng Truyện | ben-song | hiep-khach + nu-hiep (robe #6fa86f) | bóng đèn ý tưởng bật trên đầu Hoàng Dung, dấu chấm hỏi trên đầu Quách Tĩnh |
| Lệnh Hồ Xung – Nhậm Doanh Doanh: khúc nhạc kết duyên (tập 10) | Tiếu Ngạo Giang Hồ | rung-truc | hiep-khach + nu-hiep (robe #2b2b4b) | nốt nhạc cầm và tiêu thành hình trái tim |
| Tiêu Phong – A Châu: lời hẹn ngoài quan ải | Thiên Long Bát Bộ | nui-tuyet | cai-bang + nu-hiep (robe #f8c8a0) | hai con ngựa đi về phía hoàng hôn (không vẽ cảnh buồn) |
| Trương Vô Kỵ và bốn cô gái: chọn ai? | Ỷ Thiên Đồ Long Ký | mai-ngoi | hiep-khach + 4× nu-hiep | bốn cánh hoa, mỗi cánh một cái tên |
| Đoàn Dự: Vương Ngữ Yên hay Mộc Uyển Thanh? (theo bản) | Thiên Long Bát Bộ **bản sửa vs tân tu** | ben-song | thu-sinh + nu-hiep ×2 | hai cái kết lật như trang sách |
| Trác Nhất Hàng – Luyện Nghê Thường: tóc bạc vì một lời nghi ngờ | Bạch Phát Ma Nữ Truyện | nui-tuyet | dao-si + nu-hiep (robe #ffffff) | tóc chuyển trắng dần, hoa trên đỉnh núi nở |
| Lục Tiểu Phụng – Tiết Băng ⚠ | Lục Tiểu Phụng | ben-song | hiep-khach + nu-hiep | quả ớt đỏ (tính nóng) nhảy tưng tưng |
| Top 5 cặp đôi "khổ" nhất Kim Dung | Kim Dung | ben-song | nhiều | thanh "độ khổ" tăng dần theo hạng |

### 1.13 `su-do`: thầy trò (tạm dùng: `top` hoặc `doi-dau`)

| chủ đề | tác phẩm / tác giả | set | preset gợi ý | ý hiệu ứng local |
|---|---|---|---|---|
| Hồng Thất Công dạy Quách Tĩnh: học võ để đổi lấy món ngon (tập 1) | Xạ Điêu | quan-tro | cai-bang + hiep-khach | mỗi món Hoàng Dung nấu đổi được một con rồng |
| Phong Thanh Dương dạy Lệnh Hồ Xung: học để quên chiêu (tập 2) | Tiếu Ngạo Giang Hồ | nui-tuyet | su-phu (beard) + hiep-khach | chiêu thức hiện ra rồi bị cục tẩy xoá dần |
| Trương Tam Phong dạy Trương Vô Kỵ Thái Cực: "quên hết chưa?" (tập 8) | Ỷ Thiên Đồ Long Ký | san-tap | dao-si + hiep-khach | chữ trên bảng mờ dần, vòng Thái Cực hiện rõ hơn |
| Giang Nam Thất Quái: bảy ông thầy, một học trò chậm hiểu | Xạ Điêu | san-tap | 7 preset khác nhau + hiep-khach | bảy bóng thầy chen nhau nói, bong bóng thoại chồng lên nhau |
| Nhạc Bất Quần và Lệnh Hồ Xung: thầy tốt hay nguỵ quân tử? (tập 10) | Tiếu Ngạo Giang Hồ | nui-tuyet | su-phu (robe #6a5acd) + hiep-khach | mặt nạ hiền rơi ra để lộ cái cau mày |
| Vô Nhai Tử truyền 70 năm công lực cho Hư Trúc | Thiên Long Bát Bộ | rung-truc | lao-quai (robe #f0f0f0, beard) + tang | dòng sáng chảy từ đầu sang đầu, đồng hồ đếm 70 năm |
| Tiểu Long Nữ dạy Dương Quá trên dây thừng | Thần Điêu Hiệp Lữ | mai-ngoi (dem) | nu-hiep + hiep-khach | sợi dây treo giữa không trung, Dương Quá chibi lắc lư |
| Top 5 sư phụ "lầy" nhất (Chu Bá Thông, Hồng Thất Công…) | Kim Dung | quan-tro | lao-quai, cai-bang… | bảng xếp hạng có thêm cột "độ lầy" |

### 1.14 `phan-dien`: hồ sơ phản diện (tạm dùng: `doi-dau` hoặc `top`)

Kể vì sao họ thành phản diện. Không cổ vũ cái ác, và kết luôn là "cái giá phải trả".

| chủ đề | tác phẩm / tác giả | set | preset gợi ý | ý hiệu ứng local |
|---|---|---|---|---|
| Nhạc Bất Quần: "Quân Tử Kiếm" mà không quân tử | Tiếu Ngạo Giang Hồ | nui-tuyet | su-phu (robe #6a5acd, weapon kiem) | chữ "Quân Tử" trên cây quạt bị gạch chéo |
| Mộ Dung Phục: giấc mộng phục quốc | Thiên Long Bát Bộ | ben-song | cong-tu (robe #4a6fa5, weapon kiem) | vương miện giấy bị gió thổi bay |
| Âu Dương Phong: luyện ngược Cửu Âm đến mất trí | Xạ Điêu | nui-tuyet | lao-quai (weapon gay) | chữ trong bí kíp lộn ngược, ông đi bằng tay |
| Đinh Xuân Thu: thích được tung hô | Thiên Long Bát Bộ | rung-truc | lao-quai (robe #2e4b2e, beard) | đệ tử thổi kèn, lời tung hô nổ thành pháo giấy |
| Thành Côn: kẻ giật dây sau thảm kịch nhà Tạ Tốn | Ỷ Thiên Đồ Long Ký | mai-ngoi (dem) | tang (robe #4a4a4a, hat troc) | sợi dây rối nối xuống các nhân vật chibi |
| Kim Luân Pháp Vương: phản diện đáng nể nhất Thần Điêu? | Thần Điêu Hiệp Lữ | san-tap | tang (robe #b8860b, hat troc) | các bánh xe xoay quanh người, tầng công lực đếm lên ⚠ |
| Lý Mạc Sầu: vì một chữ "tình" ⚠ | Thần Điêu Hiệp Lữ | rung-truc | nu-hiep (robe #8b5a8b, weapon none) | phất trần quét ra cánh hoa tím |
| Giang Biệt Hạc ⚠ | Tuyệt Đại Song Kiêu | quan-tro | chuong-quy (robe #4a6a8a) | danh hiệu "Giang Nam đại hiệp" bong ra như tem dán |
| Top 5 phản diện có lý do đáng thương nhất | Kim Dung / Cổ Long | mai-ngoi | nhiều | cán cân "đáng ghét / đáng thương" lắc lư |

### 1.15 `phim-vs-truyen`: phim khác nguyên tác (tạm dùng: `giai-ma`)

Không dùng ảnh hay cảnh quay từ phim. Chỉ nói tên phim, năm, diễn viên, và minh hoạ bằng chibi.

| chủ đề | tác phẩm / tác giả | set | preset gợi ý | ý hiệu ứng local |
|---|---|---|---|---|
| Đông Phương Bất Bại bản phim 1992 khác truyện ra sao? | Tiếu Ngạo Giang Hồ ⚠ (năm phim 1991/1992) | mai-ngoi (dem) | cong-tu (robe #c2185b) | Kim Dung chibi gọi điện phản đối, máy quay vẫn quay tiếp |
| Đông Tà Tây Độc: phim mượn tên, chuyện khác hẳn | Xạ Điêu / phim Vương Gia Vệ | quan-tro | su-phu + lao-quai | biển báo "mượn tên" treo trước cửa quán |
| Kết Thiên Long trên phim theo bản nào? | Thiên Long Bát Bộ | ben-song | thu-sinh + nu-hiep | hai cuốn sách và một cái máy quay |
| Tiểu Long Nữ qua các thời: ai giống nguyên tác nhất? | Thần Điêu Hiệp Lữ | mai-ngoi | nu-hiep (robe #ffffff) | thẻ "nguyên tác: áo trắng, lạnh lùng" làm tiêu chí chấm |
| Những chiêu trên phim không có trong truyện | Kim Dung | san-tap | tuỳ | chiêu "phim" có tem ✗, chiêu "truyện" có tem ✓ |
| Vì sao Thiên Long 2003 được khen trung thành với truyện? ⚠ | Thiên Long Bát Bộ | san-tap | cai-bang + thu-sinh + tang | thước đo "% giống truyện" chạy lên |
| Bộ Kim Dung được chuyển thể nhiều lần nhất | Kim Dung | quan-tro | — | cuộn phim dài ra mãi |

### 1.16 `dong-thoi-gian`: vũ trụ Kim Dung (tạm dùng: `tac-gia` hoặc `giai-ma`)

| chủ đề | tác phẩm / tác giả | set | preset gợi ý | ý hiệu ứng local |
|---|---|---|---|---|
| Xếp 15 bộ Kim Dung theo dòng thời gian lịch sử | Kim Dung | mai-ngoi | thu-sinh (Kim Dung) | thanh thời gian chạy từ Xuân Thu đến nhà Thanh, sách cắm vào từng mốc |
| Xạ Điêu tam bộ khúc: 100 năm, ba thế hệ | Xạ Điêu / Thần Điêu / Ỷ Thiên | nui-tuyet | hiep-khach ×3 | cây gia phả mọc nhánh qua ba cuốn sách |
| Đả Cẩu Bổng truyền qua bao đời bang chủ? | Thiên Long → Xạ Điêu → Thần Điêu → Ỷ Thiên ⚠ | quan-tro | cai-bang ×n | cây gậy chuyền tay như gậy tiếp sức |
| Hàng Long Thập Bát Chưởng truyền qua những ai? | Thiên Long → Ỷ Thiên ⚠ | nui-tuyet | cai-bang, hiep-khach | rồng vàng bay qua từng thế hệ |
| Cửu Âm Chân Kinh đi qua tay bao nhiêu người? | Xạ Điêu → Ỷ Thiên | mai-ngoi | nhiều | cuốn sách nhảy từ tay người này sang tay người kia |
| Hậu duệ Quách Tĩnh ở đâu trong Ỷ Thiên? (Quách Tương, Nga Mi) | Thần Điêu / Ỷ Thiên | san-tap | nu-hiep (robe #f0c419) | cây gia phả rẽ sang chữ "Nga Mi" |
| Cầu nối Thiên Long – Xạ Điêu: Nhất Dương Chỉ của họ Đoàn | Thiên Long / Xạ Điêu | ben-song | thu-sinh → tang | ngón tay sáng truyền từ ông sang cháu |
| Tiếu Ngạo nằm ở thời nào khi truyện không ghi rõ? | Tiếu Ngạo Giang Hồ | nui-tuyet | hiep-khach | thám tử Tèo soi kính lúp vào các manh mối |

### 1.17 `chieu-thuc`: giải nghĩa tên chiêu, tên võ công (tạm dùng: `so-vo` hoặc `giai-ma`)

Chữ Hán, nghĩa từng chữ, rồi vì sao đặt tên như vậy. Ghép 8–10 tên chiêu cùng chủ đề thành một tập.

| chủ đề | tác phẩm / tác giả | set | preset gợi ý | ý hiệu ứng local |
|---|---|---|---|---|
| "Hàng Long Thập Bát Chưởng" nghĩa là gì? Tên các chiêu lấy từ Kinh Dịch (tập 1) | Thiên Long / Xạ Điêu | nui-tuyet | cai-bang | quẻ Kiền hiện ra, chiêu "Kháng Long Hữu Hối" |
| "Lăng Ba Vi Bộ": bước chân nhẹ trên sóng nước | Thiên Long Bát Bộ | ben-song | thu-sinh | sóng gợn dưới mỗi bước chân |
| "Ảm Nhiên Tiêu Hồn": chưởng pháp của nỗi buồn | Thần Điêu Hiệp Lữ | nui-tuyet | hiep-khach (robe #3d4a5c) | mây xám, chữ "ảm nhiên" nhỏ giọt như mưa |
| "Càn Khôn Đại Na Di": dời cả trời đất | Ỷ Thiên Đồ Long Ký | mai-ngoi | hiep-khach (hat khan) | bầu trời và mặt đất đổi chỗ cho nhau |
| "Độc Cô Cửu Kiếm": chín thức phá chín loại binh khí (tập 2) | Tiếu Ngạo Giang Hồ | nui-tuyet | hiep-khach (weapon kiem) | chín ô binh khí bị chém chéo lần lượt |
| "Tiếu Ngạo Giang Hồ": tên khúc nhạc thành tên bộ truyện (tập 10) | Tiếu Ngạo Giang Hồ | rung-truc | hiep-khach + nu-hiep | nốt nhạc bay ra thành chữ tiêu đề |
| "Thiên Long Bát Bộ": tám bộ chúng trong kinh Phật | Thiên Long Bát Bộ | san-tap | tang | tám biểu tượng xoay vòng quanh chữ tiêu đề |
| "Phá Toái Hư Không" và "Thiên Ngoại Phi Tiên": hai cái tên đẹp nhất? | Hoàng Dịch / Cổ Long | nui-tuyet | cao-thu + cong-tu | bầu trời nứt vỡ, rồi vệt kiếm từ trăng lao xuống |

---

### 1.18 `an-so`: "cái bóng" ít ai để ý cạnh ngôi sao

Kiểu chủ đề "Ngộ Không 72 phép, Bát Giới 36 phép mà vẫn lợi hại", áp vào kiếm hiệp. Đặt **ngôi sao** (ai cũng biết) cạnh **cái bóng** (nhân vật phụ, võ công phụ). So thẳng xem cái bóng thua ở đâu, rồi lật lại bằng những chiến tích bị quên. Kết luận luôn là "đừng xem thường", không hạ thấp ngôi sao. `subjects` = [ngôi sao, cái bóng]. Dàn ý xem SKILL.md mục "Dàn ý an-so".

Dữ kiện dưới đây đã đối chiếu qua kết quả tìm kiếm (≥2 nguồn, link ở cuối mục). Khi làm tập vẫn phải mở trang đọc lại. Dòng có ⚠ là có chi tiết chưa xác minh được, phải kiểm kỹ hoặc bỏ chi tiết đó.

| chủ đề (ngôi sao → cái bóng) | tác phẩm / tác giả | set | preset gợi ý | ý hiệu ứng local |
|---|---|---|---|---|
| Hàng Long Thập Bát Chưởng → Đả Cẩu Bổng Pháp: tuyệt học trấn bang chỉ truyền cho bang chủ; Hồng Thất Công truyền cho Hoàng Dung (bang chủ đời 19); Dương Quá là ngoại lệ (chiêu từ Hồng Thất Công, khẩu quyết do Hoàng Dung truyền sau) | Xạ Điêu / Thần Điêu | quan-tro | cai-bang + nu-hiep (weapon gay) | cây gậy trúc xanh quấn quanh chân đối thủ như dây leo |
| Lục Mạch Thần Kiếm → Nhất Dương Chỉ: không luyện Nhất Dương Chỉ tới mức thì không học nổi Lục Mạch; Nhất Đăng (Nam Đế) chỉ dùng Nhất Dương Chỉ ⚠ quan hệ Đoàn Dự – Nhất Đăng khác nhau giữa các bản (tập 3) | Thiên Long / Xạ Điêu | mai-ngoi | tang (Nhất Đăng) + thu-sinh (Đoàn Dự) | một tia sáng từ ngón trỏ tách thành sáu tia |
| Lục Mạch Thần Kiếm → Lăng Ba Vi Bộ: bộ pháp Tiêu Dao phái học trong hang Vô Lượng Sơn, cứu Đoàn Dự chạy thoát nhiều lần | Thiên Long Bát Bộ | ben-song | thu-sinh (weapon none) | dấu chân phát sáng theo hình quẻ Kinh Dịch trên mặt nước |
| Hàng Long của Quách Tĩnh → Song Thủ Hỗ Bác của Chu Bá Thông: tự nghĩ ra lúc bị giam ở Đào Hoa Đảo, hai tay đánh hai chiêu khác nhau ⚠ chi tiết "Hàng Long bằng hai tay" chưa xác minh (tập 1) | Xạ Điêu Anh Hùng Truyện | ben-song | lao-quai (Chu Bá Thông, beard) + hiep-khach | hai bàn tay vẽ hai hình khác nhau cùng lúc (tròn và vuông) |
| Hàng Long → Không Minh Quyền: Chu Bá Thông dạy Quách Tĩnh, quyền "rỗng" mà mạnh | Xạ Điêu Anh Hùng Truyện | ben-song | lao-quai + hiep-khach | nắm đấm trong suốt như bong bóng, chạm vào thì nổ |
| Cửu Dương, Càn Khôn Đại Na Di → Thái Cực Quyền / Thái Cực Kiếm: Trương Tam Phong truyền cho Trương Vô Kỵ trên Võ Đang ⚠ cảnh "quên hết chiêu mới dùng được" cần đọc lại truyện (tập 8) | Ỷ Thiên Đồ Long Ký | san-tap | dao-si (Trương Tam Phong, beard) + hiep-khach | vòng âm dương xoay, chiêu thức tan thành sương |
| Võ công Trung Nguyên → Thánh Hoả Lệnh võ công: võ của Minh Giáo Ba Tư, Trương Vô Kỵ học nhờ Tiểu Chiêu dịch chữ Ba Tư ⚠ trận dùng nó đánh ba sứ giả cần kiểm | Ỷ Thiên Đồ Long Ký | nui-tuyet | hiep-khach + nu-hiep | sáu lệnh bài lửa bay vòng tròn |
| Lạc Anh Thần Kiếm Chưởng → Ngọc Tiêu Kiếm Pháp, Đàn Chỉ Thần Thông, Bích Hải Triều Sinh Khúc: kho tuyệt kỹ của Hoàng Dược Sư ngoài chưởng (tập 3) | Xạ Điêu Anh Hùng Truyện | ben-song | thu-sinh (robe #2e7d5a, weapon quat) | sóng biển nhạc phổ cuộn ra từ ống tiêu |
| Độc Cô Cửu Kiếm → Dịch Cân Kinh: thứ thật sự chữa nội thương cho Lệnh Hồ Xung là Dịch Cân Kinh của phương trượng Phương Chứng; Bất Giới, Đào Cốc Lục Tiên truyền nội lực đều thất bại ⚠ có thể khác giữa các bản | Tiếu Ngạo Giang Hồ | san-tap | tang + hiep-khach | sáu luồng khí lộn xộn trong người được duỗi thẳng ra |
| Quách Tĩnh → Hoàng Dung: Lạc Anh Chưởng, Đả Cẩu Bổng, mưu trí (nhận định "bị xem thường" là ý kiến Tèo) | Xạ Điêu / Thần Điêu | ben-song | nu-hiep (robe #f3e5ab) | bàn cờ hiện ra sau lưng, mỗi nước là một mưu kế |
| Tiêu Phong → Hư Trúc: Thiên Sơn Chiết Mai Thủ, Lục Dương Chưởng, Sinh Tử Phù (Đồng Mỗ truyền); khuất phục Đinh Xuân Thu; chủ 36 động 72 đảo quy phục khi được giải phù | Thiên Long Bát Bộ | nui-tuyet | tang (hat troc) | bông tuyết sáu cánh bay ra từ lòng bàn tay |
| Tiêu Phong → Tiêu Viễn Sơn: hơn 30 năm ẩn trong Tàng Kinh Các Thiếu Lâm học trộm võ công | Thiên Long Bát Bộ | san-tap | lao-quai (robe #2b2b2b, beard) | bóng đen lướt giữa giá sách, sách tự mở trang |
| Tiêu Phong, Mộ Dung Phục → Tảo Địa Tăng: lão tăng quét lá thấy cả Tiêu Viễn Sơn lẫn Mộ Dung Bác trộm học (ghép với dòng Tảo Địa Tăng ở 1.8, đừng làm trùng) | Thiên Long Bát Bộ | san-tap | tang (robe #7a6a4f, weapon gay) | lá bay theo nhịp chổi rồi xếp thành chữ "Phật" |
| Trần Cận Nam, Khang Hi → Vi Tiểu Bảo: võ kém nhất nhưng thạo Thần Hành Bách Biến do Cửu Nạn (Trưởng công chúa Trường Bình, Độc Tý Thần Ni) dạy, thoát chết vô số lần. **Dạng "Bát Giới" rõ nhất** | Lộc Đỉnh Ký | quan-tro | thu-sinh (robe #c94f2b) + tang (nữ ni) | Vi Tiểu Bảo hoá thành năm bóng mờ chạy năm hướng |
| Quách Tĩnh → Kha Trấn Ác: mù, đại ca Giang Nam Thất Quái, thiết trượng và Độc Lăng, nghe tiếng nhận người, thầy đầu tiên của Quách Tĩnh | Xạ Điêu Anh Hùng Truyện | quan-tro | lao-quai (weapon gay, mắt nhắm) | vòng sóng âm lan ra, kẻ địch hiện thành bóng đỏ |
| Các cao thủ biết chữ → Thạch Phá Thiên: không biết chữ nên nhìn hình trong 24 phòng đá đảo Hiệp Khách mà luyện thành Thái Huyền Kinh, trong khi người khác mải giải thơ Lý Bạch | Hiệp Khách Hành | nui-tuyet | hiep-khach (robe #8d6e63) | chữ thơ trên vách tan thành nòng nọc, bơi vào kinh mạch |
| Nhân vật chính "chuẩn" → Địch Vân: được Đinh Điển dạy nội công trong ngục ⚠ tên "Thần Chiếu Kinh" cần kiểm thêm nguồn | Liên Thành Quyết | mai-ngoi (dem) | hiep-khach (robe #5d4037) | song sắt cong dần dưới luồng khí |
| Lục Tiểu Phụng → Tư Không Trích Tinh: khinh công và cải trang bậc nhất ("vua trộm" là cách gọi phổ biến, chưa thấy nguồn ghi nguyên văn) | Lục Tiểu Phụng / Cổ Long | mai-ngoi | cong-tu + thu-sinh | mặt nạ thay liên tục, mỗi lần một khuôn mặt |
| Lục Tiểu Phụng, Tây Môn Xuy Tuyết → Hoa Mãn Lâu: mù nhưng cảm nhận rất tinh, võ cao, ghét bạo lực | Lục Tiểu Phụng / Cổ Long | ben-song | cong-tu (robe #fafafa, weapon quat) | hoa nở theo hướng tiếng động, chỉ đúng chỗ kẻ địch |
| Sở Lưu Hương → Hồ Thiết Hoa, Cơ Băng Nhạn: hai bạn thân luôn cứu nguy | Sở Lưu Hương / Cổ Long | ben-song | hiep-khach + cong-tu | bình rượu lăn tới, chèo thuyền lướt sóng |
| Phi đao Lý Tầm Hoan → A Phi: "thiên hạ đệ nhất khoái kiếm", bạn sinh tử của Lý Tầm Hoan | Đa Tình Kiếm Khách Vô Tình Kiếm / Cổ Long | nui-tuyet | hiep-khach (weapon kiem, robe #424242) | một vệt sáng; kiếm đã về vỏ trước khi thấy rút |
| Thiết Thủ, Truy Mệnh, Lãnh Huyết → Vô Tình: thủ lĩnh Tứ Đại Danh Bộ, ngồi xe lăn đầy cơ quan, "Ám Khí Vương" (di chuyển nhờ móc bay của xe, không phải khinh công) | Tứ Đại Danh Bộ / Ôn Thuỵ An | cau-go | cong-tu (robe #eceff1) | xe lăn bung ra hàng chục cơ quan như hộp đồ nghề |
| Hoàng Dược Sư, Hồng Thất Công → Nhất Đăng Đại Sư: một trong Ngũ Tuyệt mà ít được bàn tới | Xạ Điêu Anh Hùng Truyện | mai-ngoi | tang (beard) | đèn dầu một ngọn sáng lên giữa bóng tối |

Nguồn đã đối chiếu: jinyong.fandom.com/wiki/Dog-Beating_Stick_Technique · baike.baidu.com/en/item/Dog%20Beating%20Staff%20Technique/1433522 · baike.baidu.com/en/item/Six%20Meridians%20Divine%20Sword/1430194 · baike.baidu.com/en/item/Yi%20yang%20zhi/1468964 · baike.baidu.com/en/item/Xiaoyao%20Sect/890168 · wuxiasociety.com/duan-yu/ · jinyong.fandom.com/wiki/Zhou_Botong · wuxiasociety.com/legend-of-the-condor-heroes-chapter-17 · wuxia.fandom.com/wiki/Zhang_Wuji · baike.baidu.com/en/item/Zhang%20Wuji/996960 · baike.baidu.com/en/item/Huang%20Yaoshi/16677 · baike.baidu.com/en/item/Five%20Ultimate%20Masters/17960 · wuxia.fandom.com/wiki/The_Smiling,_Proud_Wanderer · baike.baidu.com/en/item/Linghu%20Chong/662251 · en.wikipedia.org/wiki/Huang_Rong · wuxiasociety.com/xuzhu/ · en.wikipedia.org/wiki/Mount_Heaven_Sect · wuxiasociety.com/xiao-yuanshan/ · baike.baidu.com/en/item/Xiao%20Yuanshan/890037 · wuxiasociety.com/wei-xiaobao/ · baike.baidu.com/en/item/Wei%20Xiaobao/15466 · wuxiasociety.com/ke-zhene/ · baike.baidu.com/en/item/Ke%20Zhen%27e/924512 · wuxiasociety.com/shi-potian/ · baike.baidu.com/en/item/Tai%20Xuan%20Jing/1522733 · en.wikipedia.org/wiki/A_Deadly_Secret · en.wikipedia.org/wiki/Lu_Xiaofeng · wuxiasociety.com/gu-long-characters/ · en.wikipedia.org/wiki/Chu_Liuxiang · baike.baidu.com/en/item/A%20Fei/930674 · en.wikipedia.org/wiki/Xiaoli_Feidao · baike.baidu.com/en/item/Wu%20Qing/889854 · baike.baidu.com/en/item/Four%20Great%20Constables%20of%20the%20World/3483587

## 2. Ngoại hình nhân vật nổi tiếng

Dùng làm mặc định cho chibi. Nét nhận diện nên vẽ bằng hiệu ứng local hoặc đạo cụ, và mỗi nhân vật chỉ cần 1–2 nét cho dễ nhận ra.

| nhân vật | tác phẩm | preset + override | nét nhận diện |
|---|---|---|---|
| Tiêu Phong (Kiều Phong) | Thiên Long Bát Bộ | cai-bang (robe #5a3d2b, hat none, weapon none, beard) | to cao vạm vỡ, mặt rám; vò rượu lớn; khí chưởng hình rồng vàng |
| Quách Tĩnh | Xạ Điêu / Thần Điêu | hiep-khach (robe #8b5a2b, hat khan, weapon none) | mặt hiền, ngơ ngác; cung tên Mông Cổ; chim điêu trắng trên vai |
| Dương Quá | Thần Điêu Hiệp Lữ | hiep-khach (robe #3d4a5c, hat none, weapon kiem) | **mất cánh tay phải** nên vẽ tay áo trống bay; kiếm đen to; chim điêu lớn bên cạnh |
| Tiểu Long Nữ | Thần Điêu Hiệp Lữ | nu-hiep (robe #ffffff, hat none, weapon none) | áo trắng toàn thân, mặt lạnh; dải lụa trắng đầu có chuông vàng; ong ngọc |
| Lệnh Hồ Xung | Tiếu Ngạo Giang Hồ | hiep-khach (robe #2f6f8f, hat none, weapon kiem) | hồ lô rượu đeo hông; cười tươi, tóc hơi rối |
| Trương Vô Kỵ | Ỷ Thiên Đồ Long Ký | hiep-khach (robe #e8e2d0, hat khan, weapon none) | áo có hoa văn ngọn lửa Minh Giáo đỏ; khí nóng cam quanh người (Cửu Dương) |
| Đoàn Dự | Thiên Long Bát Bộ | thu-sinh (robe #e8dcc0, hat khan, weapon quat) | công tử thư sinh hiền lành; sáu tia kiếm khí; bước chân trên sóng nước |
| Hư Trúc | Thiên Long Bát Bộ | tang (robe #c8a165, hat troc, weapon none) | đầu trọc, mặt hiền, vẻ lúng túng; về sau mặc thêm áo Tiêu Dao màu xanh nhạt |
| Vi Tiểu Bảo | Lộc Đỉnh Ký | cong-tu (robe #d4a017, hat khan, weapon none) | mắt láo liên, cười ranh mãnh; chủy thủ nhỏ; áo giáp hộ thân bên trong |
| Đông Tà Hoàng Dược Sư | Xạ Điêu Anh Hùng Truyện | su-phu (robe #2e7d5b, hat none, weapon none, beard) | áo xanh, phong thái kiêu ngạo; sáo ngọc vẽ bằng fx; cánh hoa đào bay |
| Tây Độc Âu Dương Phong | Xạ Điêu Anh Hùng Truyện | lao-quai (robe #3b3b3b, hat none, weapon gay, beard) | mũi khoằm, mắt dữ; đầu gậy là con rắn chibi; tư thế ngồi xổm như con cóc |
| Hồng Thất Công | Xạ Điêu / Thần Điêu | cai-bang (robe #8a7a5c, hat none, weapon gay, beard) | áo vá; gậy trúc xanh; hồ lô rượu; lúc nào cũng cầm đùi gà |
| Vương Trùng Dương | Xạ Điêu Anh Hùng Truyện | dao-si (robe #f0f0f0, hat dao, weapon kiem, beard) | đạo bào trắng, râu dài; khí tím Tiên Thiên Công ⚠ màu chỉ là ý vẽ |
| Độc Cô Cầu Bại | Thần Điêu / Tiếu Ngạo (chỉ nhắc tới) | cao-thu (robe #2b2b2b, hat none, weapon kiem, beard) | vẽ thành bóng đen hoặc hồi ức; tóc trắng; bốn thanh kiếm sau lưng |
| Tảo Địa Tăng | Thiên Long Bát Bộ | tang (robe #7a6a4f, hat troc, weapon gay, beard) | lão tăng gầy, lưng hơi còng; chổi quét lá (vẽ gay + fx chổi) |
| Lý Tầm Hoan | Đa Tình Kiếm Khách Vô Tình Kiếm | thu-sinh (robe #6d5a4a, hat none, weapon none, beard) | ho khan, tay cầm chén rượu; con dao nhỏ khắc tượng gỗ |
| Sở Lưu Hương | Sở Lưu Hương hệ liệt (Cổ Long) | cong-tu (robe #7b9acc, hat none, weapon quat) | hay sờ mũi; thoảng hương uất kim hương; con thuyền ba buồm ⚠ |
| Lục Tiểu Phụng | Lục Tiểu Phụng (Cổ Long) | hiep-khach (robe #c0392b, hat none, weapon none, beard) | ria mép tỉa giống hàng lông mày thứ hai (biệt danh "bốn hàng lông mày"); hai ngón tay kẹp |
| Tây Môn Xuy Tuyết | Lục Tiểu Phụng (Cổ Long) | hiep-khach (robe #ffffff, hat none, weapon kiem) | áo trắng tinh, mặt lạnh như băng; hoa mai trắng |
| Yến Nam Thiên | Tuyệt Đại Song Kiêu (Cổ Long) | hiep-khach (robe #8b0000, hat none, weapon kiem, beard) | dáng hào sảng, râu quai nón; khí lửa đỏ Giá Y Thần Công |
| Đông Phương Bất Bại | Tiếu Ngạo Giang Hồ | cong-tu (robe #c2185b, hat none, weapon none) | áo hồng đỏ; kim thêu và sợi chỉ bay như ám khí |
| Trương Tam Phong | Ỷ Thiên Đồ Long Ký | dao-si (robe #e0e0e0, hat dao, weapon kiem, beard) | râu tóc trắng như cước; vòng Thái Cực xoay dưới chân |
| Nhất Đăng Đại Sư (Nam Đế) | Xạ Điêu / Thần Điêu | tang (robe #c8a165, hat troc, beard) | mày trắng dài; ngón tay sáng (Nhất Dương Chỉ) |
| Chu Bá Thông | Xạ Điêu / Thần Điêu | lao-quai (robe #9acd32, hat none, beard) | tóc râu bù xù, nghịch như trẻ con; hai tay vẽ hai hình khác nhau cùng lúc |
| Phong Thanh Dương | Tiếu Ngạo Giang Hồ | su-phu (robe #708090, hat none, weapon kiem, beard) | ông già ẩn trong hang trên núi, vẻ lười biếng; chín vệt kiếm |

---

## 3. Quy đổi địa danh sang set

| địa danh | tác phẩm | set | ghi chú |
|---|---|---|---|
| Hoa Sơn (Hoa Sơn luận kiếm, Ngọc Nữ Phong, hang hối lỗi) | Xạ Điêu / Thần Điêu / Tiếu Ngạo | nui-tuyet | thêm vách đá dựng đứng |
| Quang Minh Đỉnh (Côn Lôn) | Ỷ Thiên Đồ Long Ký | nui-tuyet | ngọn lửa thánh Minh Giáo |
| Thiên Sơn, Phiêu Miễu Phong | Thiên Long / Lương Vũ Sinh | nui-tuyet | |
| Kiếm Trủng (mộ kiếm của Độc Cô Cầu Bại) | Thần Điêu Hiệp Lữ | nui-tuyet | |
| Băng Hoả Đảo | Ỷ Thiên Đồ Long Ký | nui-tuyet | thêm fx núi lửa đỏ ở xa |
| Bạch Đà Sơn, Tây Vực | Xạ Điêu | nui-tuyet | |
| Nhạn Môn Quan | Thiên Long Bát Bộ | nui-tuyet | cảnh quan ải biên giới |
| Thiếu Lâm Tự, Tàng Kinh Các | nhiều bộ | san-tap | |
| Võ Đang Sơn | Ỷ Thiên / Tiếu Ngạo | san-tap | |
| Trùng Dương Cung (Chung Nam Sơn, Toàn Chân) | Xạ Điêu / Thần Điêu | san-tap | |
| Nga Mi Sơn | Ỷ Thiên | san-tap | |
| Thảo nguyên Mông Cổ | Xạ Điêu | san-tap | tạm dùng; engine chưa có set thảo nguyên |
| Cổ Mộ (mộ cổ dưới Chung Nam Sơn) | Thần Điêu Hiệp Lữ | mai-ngoi (dem) | tối, có ánh nến |
| Mái Tử Cấm Thành đêm trăng rằm | Lục Tiểu Phụng | mai-ngoi (dem) | |
| Thành Tương Dương | Thần Điêu / Ỷ Thiên | mai-ngoi | |
| Hoàng cung nhà Thanh | Lộc Đỉnh Ký | mai-ngoi | |
| Mai Trang ở Hàng Châu (Tây Hồ) | Tiếu Ngạo Giang Hồ | mai-ngoi | có thể dùng ben-song cho cảnh Tây Hồ |
| Khách điếm, tửu lâu (tửu lâu ở Vô Tích…) | nhiều bộ | quan-tro | |
| Tụ Hiền Trang | Thiên Long Bát Bộ | quan-tro | sảnh lớn đông người |
| Long Môn khách điếm, quán trọ biên ải | motif chung | quan-tro | |
| Đào Hoa Đảo | Xạ Điêu Anh Hùng Truyện | ben-song | hoa đào bay |
| Hiệp Khách Đảo | Hiệp Khách Hành | ben-song | |
| Nhĩ Hải ở Đại Lý | Thiên Long Bát Bộ | ben-song | |
| Thuyền của Sở Lưu Hương | Sở Lưu Hương hệ liệt | ben-song | |
| Vô Lượng Sơn, Lang Hoàn Phúc Địa | Thiên Long Bát Bộ | rung-truc | |
| Tuyệt Tình Cốc | Thần Điêu Hiệp Lữ | rung-truc | hoa tình có gai |
| Ác Nhân Cốc | Tuyệt Đại Song Kiêu | rung-truc (dem) | |
| Lục Trúc Hạng ở Lạc Dương | Tiếu Ngạo Giang Hồ | rung-truc | |
| Thục Trung Đường Môn | Cổ Long / Ôn Thuỵ An | rung-truc | |
| Cầu treo qua vực, Đoạn Trường Nhai | motif chung / Thần Điêu | cau-go | |

---

## 4. Mẫu dàn ý theo format (mỗi video ≥20 phút)

### 4.0 Quy tắc chung cho video ≥20 phút

- **Mỗi video dài ít nhất 20 phút (≥1200 s).** Nên nhắm 20–24 phút. Video dưới 20 phút thì không được render, phải viết thêm đoạn.
- Một chủ đề trong bảng ở phần 1 chỉ đủ khoảng 2–4 phút. Vì vậy một tập gồm **1 chủ đề chính** và **4–6 chủ đề phụ liên quan** ghép lại; xem phần 5. Các dòng đã dùng làm chủ đề phụ cũng phải ghi `(tập N)`.
- Video phải liền một mạch: **không có chapter card**, không nói "Chương X" hay "chương sau". Giữa các đoạn chuyển bằng "Tiếp theo…", "Nhưng chưa hết…", "Lúc nãy Tèo có nhắc…".
- Video chia thành **6–8 đoạn, mỗi đoạn 2,5–4 phút**. Mỗi đoạn mở bằng một **mini-hook**, là một câu hỏi nhỏ hoặc lời hứa ("Lát nữa sẽ có một chi tiết làm bạn bất ngờ…"), để giữ người xem khoảng 3 phút một lần.
- Hook ≤5 s. Sau đó Tèo xuất hiện **theo vai của khung dựng** (SKILL.md "Khung dựng": khung tự thiết kế sau khi phân tích kịch bản). Không dùng câu chào công thức cũ, không chép lời mở của 5 tập trước. Không bắt buộc hứa "3 điều".
- **Kêu gọi đăng ký** một lần ở khoảng 25–75% video và một lần ở cuối, nói bằng giọng của khung (giờ nghỉ phiên toà, quảng cáo giữa bản tin…).
- Mỗi đoạn có ít nhất 1 beat hình động (attack/react, `card`, `stat`, hoặc hiệu ứng local). Không có cảnh tĩnh nào dài quá 20 s. Cả video có **≥3 hiệu ứng local** khác nhau.
- Chữ trên màn hình vẫn phải ngắn: mỗi caption ≤12 chữ, hiện ≥2 giây, mỗi beat một ý. Nếu chưa có giọng đọc thì dùng thêm `card`/`stat` cho đủ nhịp, và không dồn chữ.
- Kết luận phải ghi "ý kiến của Tèo". Dữ kiện nào phụ thuộc bản Kim Dung thì ghi rõ bản. Bên thua chỉ choáng hoặc lùi, không bị hạ nhục.

### 4.1 Khung thời gian chung

| mốc | nội dung | thời lượng |
|---|---|---|
| 0:00 | Hook bằng câu hỏi gây tranh luận hoặc nghịch lý | ≤5 s |
| 0:05 | Tèo chào, giới thiệu 3 điều sẽ có trong tập | 20–40 s |
| ~0:40 | **Phần thân**: 6–8 đoạn theo format (xem 4.2), mỗi đoạn mở bằng mini-hook | 17–21 phút |
| phút 9–12 | Kêu gọi đăng ký giữa video, đặt ở chỗ chuyển giữa hai đoạn | 10–15 s |
| cuối thân | Chi tiết ít người biết, đặt hiệu ứng local đẹp nhất ở đây | 2–3 phút |
| gần cuối | Kết luận theo nguyên tác ("ý kiến của Tèo"), kèm câu hỏi kêu gọi bình luận | 1–2 phút |
| cuối | Kêu gọi đăng ký, móc sang tập sau | 20–30 s |
| **tổng** | | **≥20:00** |

### 4.2 Phần thân theo từng format

Thời lượng các đoạn trong bảng cộng lại khoảng 17–21 phút. Nếu thiếu thì thêm hiệp đánh, thêm `stat`, hoặc thêm một chủ đề phụ. Con số trong ngoặc là số phút.

| format | các đoạn của phần thân (thời lượng gợi ý) |
|---|---|
| `doi-dau` | ① `card` + tiểu sử ngắn bên A (3) ② bên B (3) ③ so tuyệt chiêu từng cặp, có `stat` (3) ④ 4–5 hiệp minh hoạ, mỗi hiệp attack, react và `stat` (6) ⑤ yếu tố ngoài võ công: mưu trí, thần binh, đồng minh (2) ⑥ các bản và phim đã thể hiện hai người thế nào (2) |
| `so-vo` | ① nguồn gốc và người sáng tạo võ công A (3) ② võ công B (3) ③ những ai từng luyện, kèm cảnh minh hoạ (3) ④ 3–4 hiệp so trực tiếp, có `stat` uy lực / tốc / khó luyện / tác dụng phụ (5) ⑤ khắc chế và điểm yếu (2) ⑥ bản tân tu đã sửa gì (2) |
| `tac-gia` | ① tuổi thơ, xuất thân (3) ② bước vào nghề viết (3) ③ 3–4 tác phẩm tiêu biểu, mỗi bộ một `card` (6) ④ phong cách viết, so với tác giả khác bằng `stat` (3) ⑤ giai thoại đời tư (2) ⑥ di sản: phim và ảnh hưởng (2) |
| `tac-pham` | ① bối cảnh lịch sử và nhân vật chính (3) ② mở đầu (3) ③ biến cố (3) ④ cao trào, có 2–3 cảnh đánh (4) ⑤ kết, ghi bản nếu kết khác nhau (2) ⑥ 3 nhân vật phụ đáng nhớ (3) ⑦ võ công và thần binh của bộ (2) |
| `top` | **Top 10** thay vì top 5. Mỗi hạng 1,5–2 phút, gồm `card`, cảnh minh hoạ và lý do xếp hạng. Thêm "đề cử không lọt top" (2) và so hạng 1 với hạng 2 bằng `stat` (2) |
| `mon-phai` | ① lịch sử, tổ sư, trụ sở phái A (3) ② phái B (3) ③ tuyệt học của mỗi phái (3) ④ đệ tử nổi tiếng qua các đời (3) ⑤ 3 hiệp đệ tử đấu nhau, có `stat` (4) ⑥ những lần hai phái từng đụng độ trong truyện (2) |
| `binh-khi` | Một tập nói **5–7 thần binh**. Mỗi món 2,5–3 phút: ai rèn, ai dùng, cảnh uy lực, bí mật. Thêm so `stat` (2) và "binh khí lạ nhất" (2) |
| `giai-ma` | **3–4 bí ẩn cùng một chủ đề**, ví dụ 4 bí ẩn của Thiên Long. Mỗi bí ẩn 4–5 phút: bối cảnh, 2–3 giả thuyết, đáp án theo nguyên tác và ghi bản |
| `cuoc-doi` | 8–10 mốc đời, mỗi mốc 1,5–2 phút có cảnh chibi, kèm thanh thời gian chạy ở mép màn hình. Thêm `stat` "trước và sau" (2) và "nếu là Tèo thì…" (1) |
| `su-that` | **3–4 nhân vật có thật** cùng một bộ hoặc cùng thời. Mỗi người 4–5 phút, màn chia đôi **Sử** / **Truyện** và so 3 điểm ✓/✗ |
| `neu-nhu` | Tóm lại nguyên tác (3), tua ngược bằng đồng hồ quay, dòng thời gian mới 4–5 cảnh (8), so hai kết bằng `stat` (3), rồi 1–2 câu "nếu như" phụ (4) |
| `cap-doi` / `su-do` / `phan-dien` | 3–4 cặp (hoặc 3–4 phản diện) trong một tập. Mỗi cặp 4–5 phút qua 3 khoảnh khắc: gặp nhau, thử thách, kết. Mỗi cặp có `stat` riêng (xem ghi chú bên dưới) |
| `phim-vs-truyen` | 3–4 bản chuyển thể của cùng một bộ. Mỗi bản 4–5 phút: `card` phim, 3 điểm ✓/✗, chi tiết hậu trường. Chỉ minh hoạ bằng chibi |
| `dong-thoi-gian` | Thanh thời gian lớn chạy suốt video, 6–8 mốc, mỗi mốc 2–3 phút có cảnh minh hoạ |
| `chieu-thuc` | 8–10 tên chiêu cùng một chủ đề, ví dụ 18 chưởng Hàng Long, chọn 10. Mỗi chiêu 1,5–2 phút: chữ Hán, nghĩa từng chữ, cảnh ra chiêu |

Ghi chú `stat` cho format tình cảm, thầy trò, phản diện:
- `cap-doi`: độ ngọt / độ khổ / độ bền.
- `su-do`: thầy giỏi / trò giỏi / độ lầy.
- `phan-dien`: võ công / mưu kế / độ đáng thương. Kết phải nói rõ cái giá phải trả.

### 4.3 Ví dụ chi tiết: `doi-dau` "Tiêu Phong vs Quách Tĩnh" (~21 phút)

| thời điểm | đoạn | ý chính và hiệu ứng |
|---|---|---|
| 0:00 | Hook | "Hai người cùng đánh Hàng Long Thập Bát Chưởng. Ai mạnh hơn?" |
| 0:05 | Tèo theo vai | Tèo xuất hiện theo vai của khung tập này (khung tự thiết kế từ kịch bản, không chọn từ danh sách) |
| 0:35 | Tiêu Phong | `card`; tuổi thơ ở núi Thiếu Thất; làm bang chủ Cái Bang; bị lộ thân thế |
| 3:30 | Quách Tĩnh | `card`; lớn lên ở thảo nguyên; Giang Nam Thất Quái; học Hàng Long từ Hồng Thất Công |
| 6:30 | So chiêu | Hàng Long của mỗi người khác nhau ở đâu; nói thêm chuyện 28 chưởng ⚠ theo bản tân tu |
| 9:30 | Hiệp 1–2 | attack, react, `stat`. Khoảng phút 10–11 chèn **kêu gọi đăng ký giữa video** |
| 13:00 | Hiệp 3–4 | Quách Tĩnh dùng Song Thủ Hỗ Bác, Tiêu Phong dùng nội lực áp đảo; mỗi hiệp có `stat` |
| 16:00 | Ngoài võ công | rượu, khí phách, Cửu Âm Chân Kinh, sự trợ giúp của Hoàng Dung |
| 18:00 | Ít người biết | Tiêu Phong có nguyên mẫu trong Liêu sử; hiệu ứng: hai rồng vàng va nhau |
| 20:00 | Kết luận | "Theo Tèo…", ghi rõ là giả tưởng; hỏi người xem chọn ai |
| 21:00 | CTA cuối | đăng ký, móc sang tập "Dương Quá vs Lệnh Hồ Xung" |

---

## 5. Gói chủ đề cho tập 20+ phút

Mỗi gói gồm 1 chủ đề chính và các chủ đề phụ lấy từ các bảng ở phần 1. Dùng gói nào thì ghi `(tập N)` vào **mọi dòng** trong gói đó.

| gói (tên tập gợi ý) | format chính | chủ đề chính | chủ đề phụ ghép vào |
|---|---|---|---|
| Hàng Long Thập Bát Chưởng: từ Tiêu Phong đến Quách Tĩnh | doi-dau | Tiêu Phong vs Quách Tĩnh (1.1) | Hàng Long "vốn 28 chưởng"? (1.8) · Hàng Long truyền qua những ai (1.16) · giải nghĩa tên chiêu Hàng Long (1.17) · Hồng Thất Công dạy Quách Tĩnh (1.13) |
| Thiên Long Bát Bộ: ba huynh đệ, ba số phận | tac-pham | Thiên Long Bát Bộ (1.4) | Đoàn Dự vs Hư Trúc (1.1) · Tảo Địa Tăng (1.8) · Đoàn Dự uống rượu không say (1.8) · Tiêu Phong có thật (1.10) |
| Bi kịch Tiêu Phong | cuoc-doi | Tiêu Phong (1.9) | Kiều Phong vs Mộ Dung Phục (1.1) · Tiêu Phong – A Châu (1.12) · nếu không đánh nhầm A Châu? (1.11) · Tiêu Phong trong Liêu sử (1.10) |
| Dương Quá: Thần Điêu Đại Hiệp | cuoc-doi | Dương Quá (1.9) | Huyền Thiết Trọng Kiếm (1.7) · Ảm Nhiên Tiêu Hồn Chưởng (1.17) · Dương Quá – Tiểu Long Nữ (1.12) · nếu Dương Quá không mất tay? (1.11) |
| Tiếu Ngạo Giang Hồ toàn tập | tac-pham | Tiếu Ngạo (1.4) | Độc Cô Cửu Kiếm vs Tịch Tà (1.2) · Tịch Tà và Quỳ Hoa chung gốc (1.8) · Nhạc Bất Quần (1.14) · Đông Phương Bất Bại bản phim (1.15) |
| Ngũ Tuyệt: năm cao thủ đứng đầu thiên hạ (tập 3) | top | Thiên hạ Ngũ Tuyệt (1.5) | Đông Tà vs Tây Độc (1.1) · Hồng Thất Công vs Âu Dương Phong (1.1) · Nhất Đăng ngoài đời (1.10) · Vương Trùng Dương có thật (1.10) |
| 10 thần binh Kim Dung | binh-khi | Ỷ Thiên vs Đồ Long (1.7) | Huyền Thiết Trọng Kiếm · Kiếm Trủng · Đả Cẩu Bổng · Kim Xà Kiếm · Quân Tử/Thục Nữ Kiếm · Huyết Đao (đều ở 1.7) |
| Cổ Long: người viết của những kẻ cô độc | tac-gia | Cổ Long (1.3) | Lý Tầm Hoan (1.9) · Tây Môn Xuy Tuyết vs Diệp Cô Thành (1.1) · Sở Lưu Hương vs Lục Tiểu Phụng (1.1) · Thất Chủng Vũ Khí (1.7) | (tập 5)
| Kim Dung và lịch sử thật | su-that | Khâu Xứ Cơ, Thành Cát Tư Hãn (1.10) | Đoàn Dự vua Đại Lý · Nhất Đăng · Khang Hi – Vi Tiểu Bảo · Hốt Tất Liệt (đều ở 1.10) |
| Vũ trụ Kim Dung theo dòng thời gian | dong-thoi-gian | 15 bộ theo lịch sử (1.16) | Xạ Điêu tam bộ khúc · Đả Cẩu Bổng qua các đời · Cửu Âm qua tay ai · hậu duệ Quách Tĩnh (đều ở 1.16) |
| Phản diện Kim Dung: vì sao họ thành ác? | phan-dien | Top 5 phản diện đáng thương (1.14) | Nhạc Bất Quần · Mộ Dung Phục · Âu Dương Phong · Thành Côn (đều ở 1.14) |
| Thiếu Lâm vs Võ Đang (tập 8) | mon-phai | Thiếu Lâm vs Võ Đang (1.6) | Tảo Địa Tăng (1.8) · Trương Tam Phong (1.9) · Thái Cực Quyền vs Thất Thương Quyền (1.2) · 72 tuyệt kỹ (1.2) |
| Ngũ đại tông sư võ hiệp | tac-gia | Ngũ đại tông sư (1.3) | Lương Vũ Sinh · Ôn Thuỵ An · Ngoạ Long Sinh · trận tỷ võ Ma Cao 1954 (đều ở 1.3) |
| Những cặp đôi giang hồ | cap-doi | Top 5 cặp đôi khổ nhất (1.12) | Dương Quá – Tiểu Long Nữ · Quách Tĩnh – Hoàng Dung · Lệnh Hồ Xung – Doanh Doanh · Trác Nhất Hàng – Luyện Nghê Thường (đều ở 1.12) |
| Những người đứng sau Quách Tĩnh | an-so | Quách Tĩnh → Hoàng Dung (1.18) | Kha Trấn Ác (1.18) · Song Thủ Hỗ Bác, Không Minh Quyền của Chu Bá Thông (1.18) · Hồng Thất Công dạy Quách Tĩnh (1.13) · Nhất Đăng (1.18) |
| Võ công hạng hai mạnh hơn bạn nghĩ | an-so | Hàng Long → Đả Cẩu Bổng (1.18) | Nhất Dương Chỉ (1.18) · Lăng Ba Vi Bộ (1.18) · Dịch Cân Kinh chữa Lệnh Hồ Xung (1.18) · Thánh Hoả Lệnh (1.18) |
| Thiên Long Bát Bộ: những cái bóng | an-so | Tiêu Phong → Hư Trúc (1.18) | Tiêu Viễn Sơn (1.18) · Tảo Địa Tăng (1.18, 1.8) · Lăng Ba Vi Bộ (1.18) · Vương Ngữ Yên thuộc bí kíp (1.8) |
| Cái bóng của Cổ Long | an-so | Lý Tầm Hoan → A Phi (1.18) | Tư Không Trích Tinh · Hoa Mãn Lâu · Hồ Thiết Hoa và Cơ Băng Nhạn (đều ở 1.18) · Vô Tình của Ôn Thuỵ An (1.18) |

---

## 6. Series nhiều phần (kiểu "Toàn bộ…" và "Xếp hạng…")

Một chủ đề lớn chia thành nhiều tập, mỗi tập là một phần. Kiểu tiêu đề như "Toàn bộ môn phái trong thế giới Kim Dung — Phần 1" hay "Xếp hạng 20 cao thủ Kim Dung (Phần 2) | Kiều Phong chỉ hạng A, ai hạng S?".

### 6.0 Luật cho series

- **Mỗi phần vẫn ≥20 phút** và xem riêng phải hiểu được. Đầu mỗi phần (sau hook và lời chào) có đoạn tóm tắt phần trước khoảng 30–60 giây.
- **Tiêu đề YouTube ≤60 ký tự, kết thúc bằng "| Tèo Kể"**. Nhắc số phần bằng "P1", "P2". Câu móc tò mò lấy từ kết quả gây tranh cãi nhất của phần đó, ví dụ "Kiều Phong hạng A?".
- **Xếp hạng (tier S/A/B/C) là ý kiến của Tèo.** Phần 1 công bố tiêu chí, ví dụ: thực chiến trong truyện, nội lực, chiêu thức, chiến tích lớn nhất. Các phần sau giữ nguyên tiêu chí. Ai trong truyện không giao đấu thì nói rõ là "suy luận".
- **Cuối mỗi phần có cliffhanger** hé lộ phần sau ("hạng S có một người chưa từng thua…"), rồi CTA đăng ký và mời bình luận "bạn xếp ai hạng S?".
- **Hiệu ứng local dùng chung cả series:** bảng tier S/A/B/C. Thẻ nhân vật bay vào đúng hàng, hàng S phát sáng vàng. Mỗi phần thêm ≥2 hiệu ứng riêng.
- Dùng phần nào thì đánh dấu `(tập N)` ở cột "phần" của series đó trong bảng 6.1.
- Khi đổi thứ tự hay hạng của ai đó ở phần sau thì phải nói ra trong video ("phần trước Tèo xếp…, có bạn bình luận… nên…").

### 6.1 Bảng series

| series | các phần (mỗi phần ≥20 phút) | tiêu đề mẫu (≤60 ký tự) | set | preset gợi ý | ý hiệu ứng local |
|---|---|---|---|---|---|
| Toàn bộ môn phái Kim Dung | P1 Lục đại môn phái: Thiếu Lâm, Võ Đang, Nga Mi, Côn Lôn, Không Động, Hoa Sơn · P2 Ngũ Nhạc kiếm phái (Tung Sơn, Thái Sơn, Hằng Sơn, Hành Sơn, Hoa Sơn) và Nhật Nguyệt Thần Giáo · P3 bang hội và giáo phái: Cái Bang, Minh Giáo, Toàn Chân, Cổ Mộ, Thiên Địa Hội, Thần Long Giáo · P4 kỳ phái, tà phái, thế gia: Tiêu Dao, Tinh Túc, Linh Thứu Cung, Đào Hoa Đảo, Bạch Đà Sơn, Cô Tô Mộ Dung, Đại Lý Đoàn thị | Toàn bộ môn phái Kim Dung P1: Lục đại phái \| Tèo Kể | san-tap, nui-tuyet, mai-ngoi (theo mục 3) | tang, dao-si, nu-hiep, su-phu, cai-bang, lao-quai | bản đồ giang hồ, mỗi phái cắm một lá cờ rồi phóng to vào đó |
| Xếp hạng 20 cao thủ Kim Dung | P1 hạng C và B (10 người) · P2 hạng A và S (10 người, có Kiều Phong, Dương Quá, Quách Tĩnh, Lệnh Hồ Xung, Trương Vô Kỵ, Tảo Địa Tăng, Độc Cô Cầu Bại…) | Top 20 cao thủ Kim Dung P2: Ai hạng S? \| Tèo Kể | san-tap | hiep-khach, tang, su-phu, cao-thu, lao-quai | bảng tier; thẻ "Kiều Phong" đang bay lên hàng S thì khựng lại, rơi về hàng A, Tèo há hốc mồm |
| Tier list võ công Kim Dung | P1 nội công, thần công: Cửu Dương, Cửu Âm, Dịch Cân Kinh, Bắc Minh, Tiểu Vô Tướng, Hấp Tinh Đại Pháp… · P2 chiêu thức: Độc Cô Cửu Kiếm, Hàng Long, Lục Mạch Thần Kiếm, Càn Khôn Đại Na Di, Thái Cực Quyền, Tịch Tà… | Võ công Kim Dung P1: Thần công nào hạng S? \| Tèo Kể | san-tap, rung-truc | tuỳ người dùng võ | cuốn bí kíp mở ra, chữ bay vào hàng tier |
| Toàn bộ 15 bộ Kim Dung | 4 phần, theo câu "Phi Tuyết Liên Thiên Xạ Bạch Lộc, Tiếu Thư Thần Hiệp Ỷ Bích Uyên" cộng Việt Nữ Kiếm: P1 Xạ Điêu tam bộ khúc · P2 Thiên Long, Tiếu Ngạo, Lộc Đỉnh · P3 Thư Kiếm, Bích Huyết Kiếm, Tuyết Sơn Phi Hồ, Phi Hồ Ngoại Truyện · P4 Liên Thành Quyết, Hiệp Khách Hành, Bạch Mã Khiếu Tây Phong, Uyên Ương Đao, Việt Nữ Kiếm | 15 bộ Kim Dung P1: Xạ Điêu tam bộ khúc \| Tèo Kể | quan-tro, ben-song | thu-sinh (Kim Dung), nhân vật chính từng bộ | 14 chữ của câu đối hiện dần, chữ nào nói tới thì sáng lên |
| Hoa Sơn luận kiếm qua các đời (tập 3) | P1 lần 1: Ngũ Tuyệt đời đầu, Vương Trùng Dương đứng đầu · P2 lần 2 và lần 3 (Thần Điêu): Đông Tà, Tây Cuồng, Nam Tăng, Bắc Hiệp, Trung Thần Thông | Hoa Sơn luận kiếm P2: Ngũ Tuyệt đời mới \| Tèo Kể | nui-tuyet | su-phu, lao-quai, tang, cai-bang, dao-si, hiep-khach | la bàn 5 hướng, mỗi hướng hiện một chân dung chibi |
| Toàn bộ thần binh Kim Dung | P1 kiếm: Ỷ Thiên, Huyền Thiết Trọng Kiếm, Kim Xà Kiếm, Quân Tử Kiếm, Thục Nữ Kiếm, Bích Thuỷ Kiếm… · P2 đao, gậy, kỳ binh: Đồ Long Đao, Đả Cẩu Bổng, Huyết Đao, Kim Luân… | Thần binh Kim Dung P1: Kiếm nào mạnh nhất? \| Tèo Kể | nui-tuyet | cao-thu, hiep-khach | binh khí cắm xuống đất theo thứ hạng, bậc S toả hào quang |
| Tier list phản diện Kim Dung | P1 "ác lộ mặt": Âu Dương Phong, Đinh Xuân Thu, Tạ Tốn (thời điên), Lý Mạc Sầu… · P2 "nguỵ quân tử, ác giấu mặt": Nhạc Bất Quần, Thành Côn, Tả Lãnh Thiền, Mộ Dung Phục, Toàn Quán Thanh… | Phản diện Kim Dung P2: Ai ác nhất? \| Tèo Kể | mai-ngoi (dem) | lao-quai, cong-tu, chuong-quy, tang | mặt nạ hiền rơi xuống, thẻ trượt vào hàng tier |
| Tier list nữ nhân Kim Dung | P1 xếp theo võ công: Tiểu Long Nữ, Hoàng Dung, Đông Phương Bất Bại (⚠ nói rõ thân phận), Thiên Sơn Đồng Lão, Lý Thu Thuỷ, Triệu Mẫn… · P2 xếp theo trí tuệ và tình cảm | Nữ cao thủ Kim Dung P1: Ai hạng S? \| Tèo Kể | ben-song | nu-hiep (nhiều màu robe) | cánh hoa xoáy, thẻ bay vào hàng tier |
| Xếp hạng cao thủ Cổ Long | P1 kiếm khách: Tây Môn Xuy Tuyết, Diệp Cô Thành, Yến Thập Tam, Tạ Hiểu Phong, A Phi · P2 phi đao, khinh công, kỳ nhân: Lý Tầm Hoan, Sở Lưu Hương, Lục Tiểu Phụng, Thượng Quan Kim Hồng… | Cao thủ Cổ Long P1: Kiếm ai nhanh nhất? \| Tèo Kể | rung-truc, cau-go | cong-tu, hiep-khach, cao-thu | một đường chớp sáng, đồng hồ bấm giờ dừng ở 0,01 giây |
| Bí kíp Kim Dung bị tranh giành | P1 Cửu Âm, Cửu Dương, Dịch Cân Kinh · P2 Tịch Tà, Quỳ Hoa, Liên Thành kiếm phổ, Tứ Thập Nhị Chương Kinh | Bí kíp Kim Dung P1: Cuốn nào gây hoạ nhất? \| Tèo Kể | quan-tro | thu-sinh, lao-quai, tang | cuốn sách bị mười bàn tay giằng co, giấy bay lả tả |
| Thần thú và kỳ vật Kim Dung | P1 thần thú: chim điêu, Mãng Cổ Chu Cáp, ong ngọc, rắn của Âu Dương Phong… · P2 kỳ vật: Thông Tê Địa Long Hoàn, Hắc Ngọc Đoạn Tục Cao, Thất Thương Quyền phổ… ⚠ | Thần thú Kim Dung P1: Con nào mạnh nhất? \| Tèo Kể | rung-truc | — (thú chibi vẽ bằng fx) | thú chibi nhảy vào bảng tier |
| Bang chủ Cái Bang qua các đời | P1 Uông Kiếm Thông, Tiêu Phong · P2 Hồng Thất Công, Hoàng Dung, Lỗ Hữu Cước, Sử Hoả Long… ⚠ | Bang chủ Cái Bang P1: Từ Tiêu Phong \| Tèo Kể | quan-tro | cai-bang | Đả Cẩu Bổng chuyền tay từ người này sang người khác |

### 6.2 Dàn ý một phần tier list (~22 phút)

| mốc | đoạn | nội dung |
|---|---|---|
| 0:00 | Hook | thả kết quả gây tranh cãi nhất của phần này ("Kiều Phong chỉ hạng A!") |
| 0:15 | Tèo theo vai | Tèo xuất hiện bằng vai của khung, không dùng câu chào cũ |
| 0:40 | Tóm tắt phần trước | 30–60 giây, bảng tier của phần trước hiện lại (phần 1 thì công bố tiêu chí) |
| 1:40 | 5 người đầu | mỗi người 1,5–2 phút: giới thiệu, chiến tích lớn nhất, điểm yếu, thẻ bay vào hàng |
| ~10:00 | CTA giữa | gắn với nội dung ("đăng ký đi, sắp tới người Tèo cãi nhau nhiều nhất…") |
| 10:30 | 5 người còn lại | như trên, người cuối là bất ngờ lớn nhất |
| 19:30 | Bảng tổng | toàn bộ bảng tier, Tèo bình luận 2–3 vị trí gây tranh cãi |
| 21:00 | Cliffhanger và CTA cuối | hé lộ phần sau, mời bình luận "bạn xếp ai hạng S?", đăng ký và bật chuông |

Lưu ý: không có thẻ "Chương" hay "Phần 1" xuất hiện giữa video (luật kênh: không chapter card). Số phần chỉ nằm ở tiêu đề và thumbnail.

### 6.3 Ý tưởng series mới (cùng kiểu "Toàn bộ…" / "Xếp hạng…", góc khác)

Công thức tiêu đề: **[Toàn bộ / Xếp hạng / Tier list] + [nhóm đối tượng] + P[n] + câu móc đảo kỳ vọng**. Câu móc là một vị trí gây sốc, kiểu "Kiều Phong chỉ hạng A". Ví dụ khác: "Hư Trúc hạng S nhờ may?", "Nhạc Bất Quần đứng thứ mấy?", "Ai trên cả Tảo Địa Tăng?".

| series | các phần (mỗi phần ≥20 phút) | tiêu đề mẫu (≤60 ký tự) | set | preset gợi ý | ý hiệu ứng local |
|---|---|---|---|---|---|
| Xếp hạng cao thủ từng bộ Kim Dung | mỗi bộ một phần, top 10 trong bộ đó: P1 Thiên Long · P2 Xạ Điêu · P3 Thần Điêu · P4 Ỷ Thiên · P5 Tiếu Ngạo · P6 Lộc Đỉnh Ký (hạng "võ kém nhất" có Vi Tiểu Bảo) | Top 10 Thiên Long Bát Bộ: Kiều Phong hạng mấy? \| Tèo Kể | theo bộ (mục 3) | theo nhân vật (mục 2) | bìa sách mở ra, 10 thẻ xếp thành tháp |
| Toàn bộ "nhóm số" trong Kim Dung | P1 Ngũ Tuyệt, Toàn Chân Thất Tử, Giang Nam Thất Quái · P2 Tứ Đại Ác Nhân, Mai Trang Tứ Hữu, Đào Cốc Lục Tiên · P3 Võ Đang Thất Hiệp, Tứ Đại Hộ Giáo Pháp Vương, Ngũ Tản Nhân (Minh Giáo) ⚠ | Tứ Đại Ác Nhân và các "bộ số" Kim Dung \| Tèo Kể | san-tap, quan-tro | nhóm chibi cùng preset, khác màu robe | con số lớn (4, 5, 7) đập xuống đất, từng người nhảy ra từ con số |
| Tier list sư phụ Kim Dung | P1 thầy giỏi: Hồng Thất Công, Phong Thanh Dương, Trương Tam Phong, Vô Nhai Tử… · P2 thầy "có vấn đề": Nhạc Bất Quần, Đinh Xuân Thu, Giang Nam Thất Quái (dạy dở mà trò thành tài), Âu Dương Phong | Sư phụ Kim Dung: Ai dạy giỏi nhất? \| Tèo Kể | san-tap | su-phu, lao-quai, cai-bang, dao-si | thước kẻ gõ "cốc", điểm số hiện trên bảng đen |
| Xếp hạng độ "hên" nhân vật chính | P1 cơ duyên trời cho: Hư Trúc, Đoàn Dự, Trương Vô Kỵ · P2 cơ duyên tự giành: Dương Quá, Lệnh Hồ Xung, Quách Tĩnh, Vi Tiểu Bảo | Hư Trúc hạng S nhờ may? Top độ hên Kim Dung \| Tèo Kể | rung-truc | tang, thu-sinh, hiep-khach | cỏ bốn lá và mưa vàng rơi trúng đầu |
| Cao thủ ẩn dật: ít xuất hiện mà mạnh nhất | P1 Tảo Địa Tăng, Phong Thanh Dương, Độc Cô Cầu Bại (chỉ còn kiếm trủng), Hoàng Thường · P2 Vô Danh Lão Tăng khác, Thiên Sơn Đồng Lão, Vô Nhai Tử, Lâm Triều Anh ⚠ | Cao thủ ẩn dật Kim Dung: Ai trên Tảo Địa Tăng? \| Tèo Kể | rung-truc (dem) | tang, su-phu, lao-quai | bóng người mờ dần trong sương, chỉ còn đôi mắt |
| Tier list ngoại hiệu (biệt danh) | P1 tứ phương: Đông Tà, Tây Độc, Nam Đế, Bắc Cái, Trung Thần Thông · P2 biệt danh "ngầu" và "hài": Kim Mao Sư Vương, Thanh Dực Bức Vương, Tử Sam Long Vương, Bạch Mi Ưng Vương, Nam Hải Ngạc Thần, Lão Ngoan Đồng… | Biệt danh Kim Dung: Cái tên nào ngầu nhất? \| Tèo Kể | quan-tro | theo nhân vật | chữ thư pháp viết dần ra, rồi đóng dấu đỏ |
| Toàn bộ quân sư, kẻ mưu trí Kim Dung | P1 Hoàng Dung, Triệu Mẫn, Vi Tiểu Bảo · P2 mưu sĩ phản diện: Nhạc Bất Quần, Thành Côn, Tả Lãnh Thiền, Mộ Dung Bác | Ai mưu trí nhất Kim Dung? Hoàng Dung hạng mấy? \| Tèo Kể | mai-ngoi | nu-hiep, cong-tu, lao-quai | bàn cờ vây, mỗi nước đi là một mưu kế |
| Tier list khinh công Kim Dung và Cổ Long | P1 Kim Dung: Lăng Ba Vi Bộ, Thê Vân Tung, Đông Phương Bất Bại… · P2 Cổ Long: Sở Lưu Hương, Lục Tiểu Phụng, Tư Không Trích Tinh | Ai chạy nhanh nhất kiếm hiệp? Top khinh công \| Tèo Kể | rung-truc, mai-ngoi | thu-sinh, cong-tu, dao-si | đồng hồ bấm giờ và vệt bóng mờ |
| Tier list khoảnh khắc buồn nhất Kim Dung | P1 Tiêu Phong – A Châu, Dương Quá chờ 16 năm, Hồng Thất Công và Âu Dương Phong · P2 Tiểu Chiêu sang Ba Tư, Lệnh Hồ Xung và Tiểu sư muội, Đoàn Dự và chuyện thân thế | Khoảnh khắc buồn nhất Kim Dung: Hạng S là? \| Tèo Kể | nui-tuyet, ben-song | theo nhân vật | tuyết rơi chậm, màu nhạt dần thành đen trắng |
| Thế giới Kim Dung theo bản đồ | P1 Trung Nguyên: Tung Sơn, Hoa Sơn, Võ Đang · P2 phương Nam và biển: Đại Lý, Đào Hoa Đảo, Linh Xà Đảo, Băng Hoả Đảo · P3 biên cương: Liêu, Mông Cổ, Tây Vực, Thiên Sơn | Bản đồ Kim Dung P1: Trung Nguyên \| Tèo Kể | theo vùng (mục 3) | theo vùng | bản đồ giấy cuộn mở, ghim đỏ cắm từng nơi |
| Tier list tình địch, tam giác tình yêu | P1 Trương Vô Kỵ và 4 cô gái · P2 Đoàn Dự – Vương Ngữ Yên – Mộ Dung Phục, Lệnh Hồ Xung – Doanh Doanh – Tiểu sư muội | Trương Vô Kỵ và 4 cô gái: Ai hạng S? \| Tèo Kể | ben-song, cau-go | thu-sinh, nu-hiep | trái tim vỡ đôi, thẻ bay vào bảng tier |
| Toàn bộ cao thủ dùng độc | P1 Âu Dương Phong, Đinh Xuân Thu, Lý Mạc Sầu · P2 cao thủ y thuật giải độc: Trình Linh Tố, Hồ Thanh Ngưu, Bình Nhất Chỉ (chỉ kể chuyện, không hướng dẫn) | Độc vương Kim Dung: Ai đáng sợ nhất? \| Tèo Kể | rung-truc (dem) | lao-quai, nu-hiep, thu-sinh | khói xanh lan ra, chibi ho sặc rồi ngồi bệt (không gục chết) |
| Hỗn chiến Kim Dung vs Cổ Long (giả tưởng) | P1 kiếm: Lệnh Hồ Xung, Độc Cô Cầu Bại vs Tây Môn Xuy Tuyết, Yến Thập Tam · P2 chưởng, ám khí: Kiều Phong vs Lý Tầm Hoan… | Kim Dung vs Cổ Long P1: Kiếm ai thắng? \| Tèo Kể | san-tap, cau-go | hiep-khach, cong-tu, cao-thu | màn hình chia đôi đỏ – xanh, thanh máu kiểu game |
| Xếp hạng đồ đệ "vượt mặt thầy" | P1 Quách Tĩnh vượt Giang Nam Thất Quái, Lệnh Hồ Xung vượt Nhạc Bất Quần · P2 Dương Quá, Trương Vô Kỵ, Hư Trúc | Đồ đệ vượt thầy: Ai giỏi hơn sư phụ nhất? \| Tèo Kể | san-tap | su-phu + hiep-khach | mũi tên tăng trưởng, thẻ trò vượt lên trên thẻ thầy |
| Tier list võ công và nhân vật bị xem thường | P1 Kim Dung: Đả Cẩu Bổng, Nhất Dương Chỉ, Lăng Ba Vi Bộ, Thần Hành Bách Biến, Hư Trúc, Kha Trấn Ác… · P2 Cổ Long và Ôn Thuỵ An: A Phi, Hoa Mãn Lâu, Tư Không Trích Tinh, Vô Tình… (lấy từ 1.18) | Võ công bị xem thường P1: 36 phép mà vẫn mạnh \| Tèo Kể | san-tap, quan-tro | theo nhân vật (1.18) | thẻ "hạng C" bị lật lại, bên dưới là chữ S phát sáng |
