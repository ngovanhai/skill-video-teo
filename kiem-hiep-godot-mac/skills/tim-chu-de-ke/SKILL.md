---
name: tim-chu-de-ke
description: >-
  Tìm chủ đề video mới và tạo tiêu đề chuẩn SEO cho 2 kênh Tèo (Tèo Tửu Lâu kiếm hiệp, Lại Là Tèo Đây lịch sử/văn học): KÉ video đang lên, quét video cùng mảng đăng ≤ 60 ngày đang tăng lượt xem nhanh (kiem-hang.py --dang-len), đo từ khoá người Việt hay gõ (tu-khoa.py), loại chủ đề đã làm (da-lam.py), đặt tiêu đề chuẩn SEO (≤60 ký tự, đuôi | Tèo Kể, Viết Hoa Từng Chữ, không emoji). Dùng khi người dùng nói "tìm chủ đề", "tìm nội dung", "chủ đề mới", "tạo tiêu đề", "đặt tiêu đề", "tiêu đề chuẩn seo", "ké video đang nổi", "video nào đang lên", "lên hàng chờ", "gợi ý video tiếp theo".
---

# Tìm chủ đề ké video đang lên & Tạo tiêu đề chuẩn SEO

Video nhỏ được xem chủ yếu nhờ nằm trong **danh sách đề xuất** cạnh một video lớn cùng chủ đề, không phải nhờ tìm kiếm
(đo 29/10: "2200 Năm Kim Dung" có 18,8 nghìn view nhờ đứng #3 đề xuất của video Anh Chàng IT 868 nghìn view).
Skill này chọn chủ đề sao cho video của mình **cùng chủ đề cụ thể và cùng kiểu xem** với một video đang lên, làm
xong khi nó còn nóng (1–3 tuần). Luật ké đầy đủ: `__MUSE_ROOT__/ideas/TIEU-DE-ANH-BIA.md` mục 1e.

Công cụ (đều ở `__MUSE_ROOT__/yt-auto/tools/`, chỉ đọc trang công khai, không đăng nhập, không đụng kênh):

| Lệnh | Cho biết |
|---|---|
| `python3 kiem-hang.py --dang-len=<kênh> ["cụm thêm" …]` | video đang lên trong mảng, xếp theo lượt xem/ngày; ghi `logs/dang-len-<kênh>-<ngày>.json` |
| `python3 tu-khoa.py "cụm 1" "cụm 2" …` | cụm người ta hay gõ (điểm tương đối) + "Người xem đang hỏi gì" |
| `python3 kiem-hang.py "cụm"` | top 10 kết quả tìm kiếm và độ cạnh tranh (DỄ / VỪA / KHÓ) |
| `python3 da-lam.py <kênh>` | video dài đã đăng, loạt cũ/đang làm, hàng chờ chủ đề, hàng chờ 1 tiếng, thư mục project |
| `node tieu-de.mjs` | kiểm tra định dạng tiêu đề, gắn đuôi `\| Tèo Kể`, kiểm tra lặp từ với thumbnail |

`<kênh>` là `teo-tuu-lau` hoặc `lai-la-teo-day`. `kiem-hang.py --dang-len` mất khoảng 2–5 phút.

---

## 1. Quy trình tìm chủ đề

1. **Quét.** Chạy `kiem-hang.py --dang-len=<kênh>`. Với video 1 tiếng thêm cụm `"toàn bộ" "tóm tắt" "trong 1 giờ"`.
   Nếu đã có `logs/dang-len-<kênh>-<hôm nay>.json` thì đọc file đó, không quét lại.
2. **Gom cụm chủ đề.** Nhóm các video đang lên theo chủ đề cụ thể (vd. "môn phái Kim Dung", "xếp hạng võ công",
   "Phong Thần"), cộng lượt xem/ngày của cả cụm. Bỏ: phim, clip, review phim, kênh dịch truyện audio, video đã quá 60 ngày.
3. **Loại trùng.** Chạy `da-lam.py <kênh>`. Chủ đề đã đăng hoặc đang làm thì bỏ; trùng một phần thì chỉ giữ nếu có
   **góc mới rõ ràng** và ghi rõ khác ở đâu. Chủ đề đã có trong hàng chờ mà đang có video lên mạnh → đề xuất **đôn lên**.
4. **Đo từ khoá.** `tu-khoa.py` cho tên neo của từng ứng viên (gộp nhiều cụm trong một lần chạy). Ghi điểm cụm cao
   nhất và câu hỏi người xem hay gõ. Với ứng viên lọt top, `kiem-hang.py "<cụm>"` để biết độ cạnh tranh.
5. **Chấm và xếp.** Ưu tiên theo thứ tự:
   - video ké đang lên nhanh (lượt xem/ngày cao, đăng ≤ 3 tuần) và mình kể được góc riêng;
   - từ khoá có điểm cao, cạnh tranh không KHÓ (hoặc có cụm hẹp hơn dễ hơn);
   - đối thủ chia nhiều phần mà mình gom trọn trong một video (lợi thế "Toàn bộ … trong N phút");
   - dùng lại được đồ hoạ / nhân vật / research đã có;
   - xen kẽ mảng (Kim Dung ↔ danh tác Trung Quốc; lịch sử thế giới ↔ Việt Nam ↔ văn học), không 2 video liền nhau cùng một bộ truyện.
6. **Viết đề xuất** cho mỗi chủ đề: tên + góc kể riêng, video ké (kênh, tên, link, view/ngày), cụm từ khoá + điểm,
   dạng tiêu đề gợi ý ("Toàn Bộ …", "… Trong N Phút", "Xếp Hạng …"; N chốt sau khi render), rủi ro (trùng, khó research).
   Lưu vào `__MUSE_ROOT__/ideas/<ngày>-chu-de-ke-<kênh>.md`.
7. **Đưa vào hàng chờ** (chỉ khi người dùng bảo thêm, hoặc khi phiên tự động được prompt cho phép):
   - Video 1 tiếng → thêm phần tử vào `"video"` của `__MUSE_ROOT__/yt-auto/series/1h-<kênh>.json`:
     `{"slug", "ten", "khung": "__MUSE_ROOT__/ideas/1h-<tên-ngắn>", "tu_khoa", "ke", "trang_thai": "chua-lam"}`
     (`"ke"` = link + view/ngày của video ké, để phiên làm video mượn cụm đặc trưng cho tiêu đề). Thư mục khung để
     phiên làm video tự tạo; không tạo trước.
   - Loạt 3 tập (20 phút) → thêm chuỗi mô tả vào `"hang_cho_chu_de"` của `series/<kênh>.json`, giữ tiền tố
     `[Danh tác]` cho danh tác Trung Quốc, kèm từ khoá đã đo.
   - **Không** đổi `trang_thai` của video đang làm, **không** xoá phần tử nào; muốn đôn lên thì chỉ đổi thứ tự các
     phần tử `chua-lam`. Sửa JSON bằng Edit, giữ định dạng 2 dấu cách.

---

## 2. Quy chuẩn tạo tiêu đề YouTube chuẩn SEO

Áp dụng quy chuẩn từ `__MUSE_ROOT__/ideas/TIEU-DE-ANH-BIA.md` và memory hệ thống:

### Quy trình 4 bước đặt tiêu đề:
1. **Từ khoá:** Chạy `python3 tu-khoa.py "<tên neo>"`. Chọn cụm có điểm tìm kiếm cao nhất người Việt đang gõ.
2. **Câu hỏi người xem:** Lấy các câu hỏi gợi ý từ `tu-khoa.py` ("là ai", "vì sao", "ai mạnh hơn", "chết vì sao").
3. **Độ cạnh tranh:** Chạy `python3 kiem-hang.py "<cụm>"`. Nếu cạnh tranh KHÓ, chuyển sang cụm dài và hẹp hơn.
4. **Viết tiêu đề:** Ghép tên neo + góc bí ẩn/câu hỏi + đuôi thương hiệu.

### Bộ luật cứng về tiêu đề:
* **Đuôi bắt buộc:**
  * Video dài: `… | Tèo Kể`
  * Shorts: `… #Shorts | Tèo Kể`
* **Độ dài giới hạn:** Tối đa **60 ký tự** (không tính chữ `#Shorts`).
* **Định dạng chữ:** **Viết Hoa Từng Chữ** (Title Case). Ví dụ: *Võ Công Mạnh Nhất Kim Dung: 42 Môn Trong 67 Phút | Tèo Kể*.
  * Tuyệt đối **KHÔNG viết hoa toàn bộ (ALL CAPS)**.
  * Tuyệt đối **KHÔNG chứa Emoji**.
* **Luật số phần (nghiêm cấm đánh số sai):**
  * **KHÔNG** ghi "(Phần N/3)" hay "Tập 2/3" nếu các tập chỉ cùng chủ đề nhưng nội dung độc lập (như Thúy Kiều, Chí Phèo, Tắt Đèn).
  * **CHỈ ĐƯỢC GHI** số phần khi các tập thực sự liên kết mạch truyện trực tiếp nối tiếp nhau.
* **Hứa gì trả nấy:**
  * 30 giây đầu của video bắt buộc phải nhắc lại và trả lời đúng câu hỏi/lời hứa trong tiêu đề.
  * Chữ trên Thumbnail và Tiêu đề phải là **2 câu khác nhau, bổ sung cho nhau**, không lặp từ trên 50%.

---

## 3. Luật phân loại kênh

* **Kênh Tèo Tửu Lâu:** kiếm hiệp (Kim Dung, Cổ Long…) và mọi tác phẩm nổi tiếng Trung Quốc (Tam Quốc, Thủy Hử, Tây Du, Phong Thần, Liêu Trai, Hồng Lâu Mộng). Tiểu thuyết lịch sử luôn tách "truyện kể" và "sử chép".
* **Kênh Lại Là Tèo Đây:** người nổi tiếng / sự việc nhiều người biết, lịch sử, văn học Việt Nam. **Không thể thao.**
* Không ké tên phim, diễn viên, clip phim; không ké video hay nhân vật mà video mình không nói tới; không chép nguyên tiêu đề hay ảnh bìa người khác.
* Số liệu trong đề xuất phải lấy từ kết quả lệnh vừa chạy, ghi rõ ngày đo; không bịa lượt xem.
* Không đăng, không sửa gì trên YouTube.
