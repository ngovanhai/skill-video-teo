---
name: godot-visual-review
description: >-
  Kiểm định chất lượng hình ảnh hoạt hình Godot bằng render frame/contact sheet: phát hiện
  lỗi bố cục, nhân vật, màu, camera, ánh sáng, VFX, continuity và lỗi khung hình. Dùng trước
  khi render toàn tập hoặc khi cần review/sửa một cảnh.
---

# Godot Visual Review — xem hình thật, không đoán bằng code

## Mục tiêu
Không chấp nhận cảnh chỉ vì project chạy hoặc GDScript không lỗi. Chỉ kết luận đạt khi đã xem frame render thực tế ở kích thước gần đầu ra.

## Quy trình
1. Đọc brief, Art Bible, storyboard và checklist của skill sản xuất chính.
2. Chạy công cụ check/render/contact sheet sẵn có trong skill của dự án. Ưu tiên script hiện có; không tự chế lệnh Godot nếu repo đã định nghĩa pipeline.
3. Lấy frame ở: đầu cảnh, trước hành động, điểm hành động, impact, hậu quả, chuyển cảnh và frame kết. Với cảnh dài, bổ sung mốc đều.
4. Mở ảnh contact sheet và đánh giá từng tiêu chí:
   - composition / hierarchy / negative space;
   - silhouette, pose, biểu cảm và continuity nhân vật;
   - palette, contrast, readability;
   - camera, parallax, layer, clipping;
   - ánh sáng, shadow, bloom, particle và shader;
   - lỗi asset: méo, răng cưa, sai tỷ lệ, sai hướng, texture thiếu;
   - chữ/phụ đề có che nội dung hoặc sai safe area.
5. Ghi issue theo mức độ: P0 (không thể phát hành), P1 (lỗi rõ), P2 (nâng chất lượng), kèm timestamp/frame, mô tả, nguyên nhân giả định và hướng sửa.
6. Sửa theo nhóm lỗi có nguyên nhân chung, render lại đúng các mốc bị ảnh hưởng và một số mốc liền kề để bắt lỗi continuity.
7. Chỉ đánh dấu PASS khi không còn P0/P1 và mọi checklist bắt buộc của skill sản xuất đều đạt.

## Nguyên tắc review
- Không nhận xét mơ hồ như “chưa đẹp”; mô tả cụ thể vùng nào, vì sao, ảnh hưởng gì và sửa thế nào.
- Không sửa hàng loạt asset chuẩn nếu lỗi chỉ nằm ở một cảnh.
- Không bỏ qua frame trung gian: animation có thể đẹp ở keyframe nhưng vỡ ở giữa.
- Không dùng ảnh prompt/ảnh tham khảo thay cho ảnh render Godot.
- Nếu không thể chạy render hoặc xem ảnh, ghi rõ BLOCKED; không giả vờ đã kiểm tra.

## Mẫu báo cáo
| Mốc | Mức | Vấn đề | Hướng sửa | Trạng thái |
|---|---|---|---|---|
| 00:04.2 | P1 | Nhân vật chìm vào nền | Tách value, rim light nhẹ | TODO |

Kết quả cuối: PASS / NEEDS_FIX / BLOCKED, số lỗi theo mức và các mốc đã kiểm tra.
