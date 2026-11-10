---
name: cinematic-scene-2d
description: >-
  Thiết kế bối cảnh và ngôn ngữ điện ảnh cho hoạt hình 2D Godot: bố cục, staging, camera,
  parallax, chiều sâu, ánh sáng, thời tiết và chuyển cảnh. Dùng khi tạo cảnh mới hoặc cảnh đang
  bị phẳng, rối, thiếu chiều sâu hay không làm rõ hành động.
---

# Cinematic Scene 2D — bố cục và bối cảnh

## Đầu vào
Đọc Art Bible từ `art-director-2d`, storyboard của tập, vị trí nhân vật, thời lượng cảnh và các asset nền có sẵn. Không tự tạo bối cảnh trước khi hiểu hành động cần kể.

## Quy trình
1. Chốt mục đích cảnh trong một câu: giới thiệu địa điểm, tạo căng thẳng, dẫn mắt, hay nhấn cao trào.
2. Chia lớp: foreground (vật che/khung cảnh gần), midground (nhân vật và đạo cụ), background (kiến trúc/núi/trời). Tạo parallax chỉ khi có chuyển động camera phù hợp.
3. Dùng quy tắc 1/3, đường dẫn thị giác, khối sáng/tối và khoảng trống để dẫn mắt đến nhân vật/hành động.
4. Chọn cỡ cảnh và camera: wide để định vị, medium để đọc tương tác, close-up cho cảm xúc/chi tiết. Tránh zoom liên tục không có lý do.
5. Tạo chiều sâu bằng chồng lớp, scale theo khoảng cách, atmospheric perspective và ánh sáng; không chỉ blur mọi lớp.
6. Ánh sáng có nguồn rõ ràng (trăng, đèn lồng, lửa, cửa sổ, mặt trời). Giữ hướng sáng nhất quán giữa nền và nhân vật.
7. Thiết kế chuyển cảnh theo không gian hoặc nhịp truyện; không dùng transition để che lỗi staging.

## Quy tắc Godot
- Ưu tiên Node2D/CanvasItem, Parallax2D, CanvasModulate, PointLight2D và shader 2D phù hợp với cấu trúc dự án.
- Tôn trọng camera, viewport và render pipeline đang có; không đổi project settings toàn cục khi chưa kiểm tra tác động.
- Kiểm tra thứ tự z_index / CanvasLayer, vùng cắt, texture filtering, stretch mode và pixel density.
- Tối ưu số lớp, texture và shader; tránh tạo hàng trăm node chỉ cho chi tiết trang trí.

## Checklist
- Người xem biết nhân vật đang ở đâu trong 1–2 giây.
- Nhân vật tách khỏi nền ở cả khung sáng và khung tối.
- Điểm nhìn chính rõ; không có vật thể vô tình cắt qua đầu/mặt.
- Camera không làm mất hành động hoặc gây chóng mặt.
- Chuyển động nền không cạnh tranh với chuyển động nhân vật.
- Cảnh vẫn đọc tốt khi xem ở kích thước thumbnail.

## Đầu ra
Scene Godot hoặc mã cảnh tương thích engine hiện tại, kèm ghi chú camera, layer, ánh sáng và checklist kiểm tra. Render một frame đại diện trước khi nhân rộng sang các cảnh tương tự.
