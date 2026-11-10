---
name: hoat-anh-kich-ban
description: Tự động phân tích kịch bản video (loi.txt / video.json) để thiết kế storyboard điện ảnh và sinh mã hoạt cảnh 2D Godot phong phú, biến hóa linh hoạt theo từng nội dung (không bị cố định một khung hình tĩnh). Tích hợp Hệ Thống Vũ Đạo Hành Động Chibi 2D (Chibi Combat & Action Choreography) với 12 tuyệt kỹ chiến đấu, chiến trận, diễn xuất kịch tính và tương tác đạo cụ. Chống bẫy slide chữ tĩnh, điều phối chuyển động Chibi rig2, Mascot Tèo di động, camera điện ảnh và hiệu ứng môi trường. Dùng khi người dùng nói "tạo hoạt ảnh", "thêm hoạt cảnh", "video ít hoạt ảnh", "làm video sinh động", "storyboard kịch bản", "hoạt cảnh không cố định", "vũ đạo hành động", "chém kiếm", "bắn cung", "cưỡi ngựa".
---

# Kỹ Năng: Thiết Kế Hoạt Ảnh & Vũ Đạo Hành Động Chibi 2D (`hoat-anh-kich-ban`)

Kỹ năng này đóng vai trò như một **Đạo Diễn Hoạt Hình Điện Ảnh 2D kiêm Đạo Diễn Chỉ Đạo Võ Thuật (Cinematic Director & Action Choreographer)**, giải phóng video khỏi lối mòn của các khung tĩnh và các bài thuyết trình slide nhiều chữ.

---

## ⚔️ THƯ VIỆN VŨ ĐẠO HÀNH ĐỘNG CHIBI 2D (`hanh_dong.gd`)

Thư viện cung cấp 12 kỹ thuật hành động chuyên sâu được thiết kế tối ưu bằng GDScript 2D thuần, vẽ trực tiếp qua CanvasItem (`ci`) kết hợp chuyển động hình thể Chibi rig2 (`nguoi.gd`) và nét bút lông thủy mặc (`but.gd`).

### 1. `chem_kiem(ci, pos, dir, t, opt)` — Tuốt Kiếm Chém Ra Vệt Sáng Hình Cung
- **Diễn hoạt:** Nhân vật rút kiếm hông lấy đà (`cyc < 0.5`), bước lướt chém bổ chéo tới trước (`cyc 0.5..1.0`), rồi thu kiếm về tư thế thủ vững chãi (`cyc > 1.0`).
- **Hiệu ứng:** 
  - Vệt kiếm khí hình cung bán nguyệt (`crescent`) sáng rực với lõi trắng nhiệt độ cao và vầng năng lượng màu cam/lam.
  - Chùm 16 tia lửa tóe ra theo góc chém (`sparks`).
  - Vòng sóng xung kích (`shockwave`) mở rộng và cụm bụi đất chân đạp tung bay.
- **Tùy chọn (`opt`):** `vai` (nhân vật), `F` (kích cỡ), `col` (màu kiếm khí), `hot` (lõi sáng), `radius` (bán kính cung).

### 2. `doi_dau_kiem_dao(ci, pos1, pos2, t, opt)` — Đối Đầu Đao Kiếm Va Chạm Tóe Lửa
- **Diễn hoạt:** Hai nhân vật lao thẳng vào nhau từ hai hướng đối lập (`cyc < 0.65`), vũ khí chạm nhau cực mạnh tại điểm trung tâm rung giật bần bật (`cyc 0.65..1.15`), sau đó lực chấn đẩy lùi cả hai về phía sau (`cyc > 1.15`).
- **Hiệu ứng:** 
  - Điểm tiếp xúc bừng sáng chớp nháy (Clash Spark).
  - Ngôi sao phát quang 8 cánh cùng chùm 24 tia lửa bắn tung toé đa hướng.
  - Vòng sóng xung kích kép lan tỏa mạnh mẽ kèm rung chấn camera (`shake: 5.0`).

### 3. `ban_cung(ci, pos, dir, t, opt)` — Giương Cung Bắn Tên & Vệt Khói Đạn Đạo
- **Diễn hoạt:** Cung thủ giương cánh cung gỗ dâu tằm, kéo căng dây cung về phía sau gò má (`cyc < 0.9`), buông dây tên bật mạnh rung bần bật (`cyc = 0.9`), mũi tên xé gió lao vút đi (`cyc > 0.9`).
- **Hiệu ứng:** 
  - Mũi tên sắt bay theo quỹ đạo đạn đạo parabol chân thực.
  - Vệt khói đạn đạo (Ballistic Trail) gồm 12 phân đoạn mờ dần và mở rộng kích thước phía sau mũi tên.
  - Đốm sáng tụ khí trên mũi tên khi đang ngắm bắn.

### 4. `cuoi_ngua_phi(ci, pos, dir, t, opt)` — Cưỡi Tuấn Mã Phi Nước Đại
- **Diễn hoạt:** Chiến mã sải vó phi nước đại với chu kỳ 4 pha chuẩn cơ học động vật: chân trước vươn dài, chân sau co gấp đẩy mạnh, thân ngựa nhấp nhô nhịp nhàng.
- **Hiệu ứng:** 
  - Bờm ngựa và đuôi ngựa dài tung bay cuồn cuộn theo chiều gió ngược.
  - Bụi mù cuộn tròn bốc lên dưới mỗi nhịp móng sắt nện xuống mặt đất.
  - Kỵ sĩ trên yên đỏ lắc lư theo nhịp phi, vạt áo bào phấp phới uy dũng.

### 5. `dap_ban_dung_day(ci, pos, t, opt)` — Đập Bàn Đứng Phắt Dậy Chém Góc Bàn
- **Diễn hoạt:** Nhân vật tức giận đập mạnh tay xuống bàn nghị sự gỗ mun (`cyc = 0.38`), bàn rung chuyển nảy lên làm chén trà nghiên bút văng lên không; nhân vật đứng phắt dậy tuốt gươm chém vát đứt lìa một góc bàn (`cyc = 2.0`).
- **Hiệu ứng:** 
  - Sóng xung kích phát nổ tại điểm đập tay.
  - Mảnh góc bàn gỗ văng xoay tít giữa không trung theo trọng lực rơi tự do.
  - Tia lửa và vệt kiếm sáng rạch ngang vết chém.

### 6. `hoc_mau_guc_nga(ci, pos, t, opt)` — Ôm Ngực Thổ Huyết Gục Ngã
- **Diễn hoạt:** Nhân vật một tay ôm chặt trước ngực, người rung giật bần bật vì những cơn ho dữ dội (`cyc < 1.2`), há miệng phun ra dòng máu tươi bắn xối xả (`cyc 1.2..2.0`), rồi hai gối quỵ xuống đất ngã gục (`cyc > 2.0`).
- **Hiệu ứng:** 
  - 16 giọt máu đỏ tươi (chu sa) bắn thành vòng cung rơi xuống nền đất.
  - Vũng máu tươi đọng trên mặt đất loang rộng dần.
  - Khói bụi bốc lên khi đầu gối va đập mặt sàn.

### 7. `quy_goi_dang_thu(ci, pos, dir, t, opt)` — Quỳ Gối Dâng Chiếu Thư Phát Sáng
- **Diễn hoạt:** Nhân vật quỳ gối kính cẩn, hai tay nâng cao cuộn thánh chỉ hoàng gia dâng lên trước mặt.
- **Hiệu ứng:** 
  - Chiếu thư bằng gấm vàng nạm ngọc tỏa ra vầng hào quang rực rỡ xung quanh.
  - 8 tia sáng thiên triều xoay tròn chầm chậm.
  - Dấu ấn ngọc tỷ chu sa đỏ rực trên nền gấm vàng.

### 8. `nhap_ruou_can_ly(ci, pos, t, opt)` — Nâng Chén Rượu Cạn Ly Mỉm Cười
- **Diễn hoạt:** Nâng chén đồng ba chân lên ngang miệng (`cyc < 1.0`), ngửa đầu dốc chén uống cạn từng ngụm rượu thơm nồng (`cyc 1.0..2.2`), hạ chén xuống nở nụ cười hào sảng sảng khoái (`cyc > 2.2`).
- **Hiệu ứng:** 
  - Chén nghiêng góc tự nhiên, giọt rượu màu hổ phách sóng sánh.
  - Làn hơi ấm rượu trắng bốc lên thoang thoảng.

### 9. `quat_long_tao_gio(ci, pos, dir, t, opt)` — Khổng Minh Vung Quạt Lông Tạo Gió Lốc
- **Diễn hoạt:** Khổng Minh đưa quạt lông hạc trắng ra sau lấy đà, vung mạnh cổ tay về phía trước tạo nên luồng cuồng phong lốc xoáy.
- **Hiệu ứng:** 
  - Cơn lốc xoáy màu lam ngọc đa tầng cuộn xoáy bay thẳng về phía trước.
  - Các dải gió thanh lam và lá cây bùa chú xoay tít bên trong phễu lốc.
  - Luồng gió quét bụi mù trên mặt đất.

### 10. `phat_co_lenh(ci, pos, dir, t, opt)` — Phất Cờ Lệnh Xuất Quân
- Đại tướng vung cán cờ lệnh chỉ huy, lá đại kỳ hình tam giác thêu chữ "LỆNH" viền kim tuyến uốn lượn phần phật theo gió bão.

### 11. `gay_dan_song_am(ci, pos, t, opt)` — Gảy Cổ Cầm Phát Sóng Âm Kiếm Khí
- Mỹ nhân/Hiệp khách ngồi trước bàn đàn cổ tranh, ngón tay lướt trên dây phát ra từng chuỗi vòng sóng âm kiếm khí vàng kim sắc lẹm xé gió bay xa.

### 12. `tu_khi_chuong(ci, pos, dir, t, opt)` — Tụ Nội Lực Phóng Chưởng
- Hai tay co về trước ngực tụ thành quả cầu nội lực xoay tròn chói lòa, sau đó đẩy mạnh song chưởng phóng ra luồng kình lực cực đại.

---

## 🎭 7 BỐ CỤC ĐIỆN ẢNH KẾT HỢP VŨ ĐẠO (SCENE & ACTION COUPLING)

Mỗi kịch bản video sẽ tự động chuyển đổi giữa 7 ngôn ngữ thị giác kết hợp hoàn hảo cùng hệ thống vũ đạo:

1. **Chiến trận Sa trường (`chien_tran`):**
   - Không gian rộng mở toàn màn hình, sóng nước cuộn trào đa tầng.
   - Thuyền bè rẽ sóng bập bềnh, khói lửa bùng cháy ngùn ngụt trên hạm đội.
   - Vũ đạo tích hợp: `HD.ban_cung` (Hoàng Cái bắn tên lửa), `HD.phat_co_lenh` (Chu Du phát lệnh hỏa công), `HD.chem_kiem`.

2. **Đối đầu / Tranh luận (`doi_dau`):**
   - Bố cục đối xứng hai nửa màn hình (Split-screen) thể hiện mâu thuẫn đối lập (Sử sách vs Tiểu thuyết, Nhân vật A vs Nhân vật B).
   - Biểu tượng đối đầu rực lửa (`VS`), ánh sáng đổi màu theo phe phái.
   - Vũ đạo tích hợp: `HD.doi_dau_kiem_dao` (va chạm đao kiếm tóe lửa), `HD.chem_kiem`.

3. **Thư phòng / Giai thoại / Âm nhạc (`thu_phong`):**
   - Không gian nội cảnh tao nhã, rèm lụa bồng bềnh đung đưa theo gió.
   - Vũ đạo tích hợp: `HD.gay_dan_song_am` (Tiểu Kiều gảy khúc Chu Lang Cố), `HD.nhap_ruou_can_ly` (Chu Du thưởng rượu tri âm).

4. **Bi kịch / Tang thương / Bạo bệnh (`bi_kich`):**
   - Tông màu u ám, lạnh lẽo; hiệu ứng thời tiết mưa rơi rả rích, sương lạnh.
   - Vũ đạo tích hợp: `HD.hoc_mau_guc_nga` (Chu Du ôm ngực thổ huyết gục ngã trên giường bệnh), đồng đội quỳ phục ôm đầu than khóc.

5. **Sa bàn Bản đồ Chiến lược (`sa_ban`):**
   - Bản đồ da dê cổ phong chia vùng các đại thế lực.
   - Các mũi tên hành quân đồ họa tự động vẽ uốn lượn theo tiến trình phân tích.
   - Vũ đạo tích hợp: `HD.cuoi_ngua_phi` (Kỵ binh phi nước đại hành quân phạt Thục).

6. **Mưu lược / Thao túng / Thời tiết (`thuyen_co`):**
   - Màn sương mù mờ ảo cuộn trôi lững lờ.
   - Vũ đạo tích hợp: `HD.quat_long_tao_gio` (Gia Cát Lượng cầu gió đông nam), Tôn Quyền quay thuyền cân bằng tên.

7. **Thuyết thư / Tương tác Khán giả (`thuyet_thu`):**
   - Mascot Tèo bước từ cánh gà ra sân khấu chào khán giả.
   - Gõ kinh đường mộc rung bàn khi chốt ý then chốt; nâng chén rượu cạn ly (`HD.nhap_ruou_can_ly`) mời gọi like/đăng ký.

---

## 🎬 NGUYÊN TẮC CHỈ ĐẠO VÕ THUẬT & CAMERA ĐIỆN ẢNH

1. **Nhịp điệu 3 hồi (3-Act Rhythm):**
   - **Khởi (Windup):** Lấy đà, tụ lực, rút vũ khí (0.4 – 0.6s) -> Tạo sự chờ đợi căng thẳng.
   - **Phát (Climax Strike):** Tung đòn nhanh chớp nhoáng (0.1 – 0.2s) kèm vệt sáng, flash, sparks và camera shake.
   - **Thu (Follow-through & Settle):** Giữ thế kết uy nghi (0.5 – 1.0s), khói bụi tản dần.

2. **Rung chấn Camera (Impact Shake):**
   - Đòn chém kiếm / va chạm đao kiếm: `shake = 4.0 .. 5.5`.
   - Đập bàn thịnh nộ: `shake = 5.5`.
   - Bắn cung / quạt gió: `shake = 2.5 .. 3.5`.
   - Tranh luận bình thường: `shake = 0.0`.

3. **Độ tương phản và Bố cục thị giác:**
   - Nhân vật hành động luôn được đặt tại điểm vàng 1/3 hoặc trung tâm khung hình.
   - Vũ khí và vệt kiếm sáng tương phản rõ với màu nền (nền tối -> kiếm sáng cam/lam; nền sáng -> nét mực đậm + vệt son).

---

## 🛠️ CÁCH SỬ DỤNG TRONG QUY TRÌNH SẢN XUẤT

### 1. Phân tích kịch bản và sinh Storyboard điện ảnh kèm Vũ đạo:
```bash
python3 __SKILLS_DIR__/hoat-anh-kich-ban/scripts/tao-storyboard.py <đường_dẫn_tập>
```
*Lệnh này đọc `loi.txt`, quét các động từ hành động tiếng Việt và sinh ra file `godot/storyboard.json` với trường `action_type`, `action_opt`, `actors` và thông số camera cho từng shot.*

### 2. Tự động sinh mã hoạt cảnh Godot (`tranh.gd` & `phim.gd`):
```bash
python3 __SKILLS_DIR__/hoat-anh-kich-ban/scripts/gen-hoat-anh.py <đường_dẫn_tập>
```
*Lệnh này tự động sao chép `hanh_dong.gd` vào dự án Godot của tập phim, nhúng các hàm vũ đạo vào `tranh.gd` và `phim.gd`.*

### 3. Kiểm tra tính toàn vẹn cú pháp và thời lượng:
```bash
node __SKILLS_DIR__/teo-kiem-hiep-godot/scripts/gd-check.mjs <đường_dẫn_tập>
```
