---
name: art-director-2d
description: >-
  Định hướng mỹ thuật cho video hoạt hình 2D Godot: chốt art bible, bảng màu, ngôn ngữ hình khối,
  style nhân vật/bối cảnh/hiệu ứng và kiểm soát tính nhất quán giữa các cảnh. Dùng trước khi tạo
  tập mới, khi hình ảnh bị lệch style hoặc cần nâng cấp chất lượng tổng thể.
---

# Art Director 2D — đạo diễn mỹ thuật

## Mục tiêu
Tạo một ngôn ngữ hình ảnh thống nhất, có chủ đích và dễ đọc ở khung hình 1920×1080. Không tự ý thay engine, rig, tỉ lệ nhân vật hoặc palette đã được chốt trong dữ liệu dự án.

## Quy trình bắt buộc
1. Đọc skill sản xuất chính và dữ liệu hiện có: `nhan-vat-chibi/data/chars.json`, `teo-kiem-hiep-godot/data/history.json`, `chuong-2d/data/moves.json`, cảnh mẫu và asset đang dùng.
2. Viết **Art Bible ngắn** cho tập: phong cách (2D chibi wuxia), tỷ lệ đầu/thân, độ dày viền, cách đổ bóng, chất liệu, độ bão hòa, tương phản, quy tắc ánh sáng và 3–5 màu chủ đạo.
3. Lập bảng màu theo vai trò: nền xa / nền gần / mặt đất / nhân vật chính / đối thủ / điểm nhấn hiệu ứng. Kiểm tra độ tương phản ở kích thước xem nhỏ.
4. Định nghĩa quy tắc asset: cùng góc nhìn, cùng tỷ lệ, cùng hướng sáng, cùng độ chi tiết; không trộn ảnh 3D bóng bẩy với chibi phẳng nếu không có chủ ý.
5. Chia cảnh thành các nhóm thị giác (toàn cảnh, trung cảnh, cận cảnh, cao trào). Mỗi cảnh chỉ có một điểm nhìn chính.
6. Lưu quyết định vào brief của tập để các skill storyboard, nhân vật, scene và VFX cùng tuân theo.

## Tiêu chuẩn hình ảnh
- Silhouette đọc được ngay cả khi thu nhỏ; không để nhân vật chìm vào nền.
- Ưu tiên tương phản sáng/tối và tương phản màu; không dùng quá nhiều màu nhấn cùng lúc.
- Giữ vùng trống quanh mặt và hành động quan trọng; tránh chữ, hạt và hiệu ứng che biểu cảm.
- Chi tiết phải phục vụ kể chuyện, không trang trí vô cớ.
- Dùng lại asset chuẩn đã có; không sinh lại nhân vật quen thuộc bằng một style khác.

## Đầu ra
`art-direction.md` gồm: style statement, palette, character rules, environment rules, lighting, camera language, VFX language và checklist. Nếu không có thư mục tập, đặt brief trong thư mục work của skill sản xuất đang chạy.

## Không được làm
- Không tự ý sửa sổ nhân vật hoặc lịch sử tập chỉ để hợp một hình ảnh mới.
- Không dùng prompt chung chung kiểu “beautiful cinematic”; phải mô tả hình khối, màu, ánh sáng, góc máy và cảm xúc cụ thể.
- Không đánh giá chất lượng chỉ bằng prompt hoặc mô tả; phải xem ảnh render thực tế.
