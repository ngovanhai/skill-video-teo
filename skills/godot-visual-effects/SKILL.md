---
name: godot-visual-effects
description: >-
  Thiết kế và triển khai hiệu ứng hình ảnh 2D trong Godot: kiếm khí, chưởng lực, aura, lửa,
  băng, khói, bụi, tia sáng, impact, shader và particle. Dùng khi tạo hoặc nâng cấp VFX cho
  hoạt hình chibi/kiếm hiệp, không thay thế skill chuong-2d chuyên làm clip chiêu thức.
---

# Godot Visual Effects — hiệu ứng có chủ đích

## Nguyên tắc
Hiệu ứng phải giải thích được lực, hướng, chất liệu và hậu quả của hành động. Mỗi VFX có silhouette, nhịp xuất hiện, điểm sáng và điểm kết thúc rõ ràng. Không biến mọi đòn đánh thành một vụ nổ giống nhau.

## Quy trình
1. Đọc Art Bible, storyboard, palette và mô tả võ công trong truyện. Tra cứu cơ chế trước khi vẽ.
2. Chọn ngôn ngữ hình: đường nét (kiếm khí), khối (đá/băng), hạt (bụi/tàn lửa), trường lực (aura), distortion (khí công) hoặc kết hợp có thứ bậc.
3. Phác 3 nhịp: anticipation → action/impact → aftermath. Mỗi nhịp phải có thời lượng và điểm nhấn.
4. Chọn kỹ thuật theo nhu cầu: GPUParticles2D/CPUParticles2D cho hạt, Line2D cho vệt, Polygon2D cho hình khối, AnimatedSprite2D/Sprite2D cho asset, ShaderMaterial cho distortion/glow. Dùng helper có sẵn trước khi viết mới.
5. Đảm bảo seed/timing tất định nếu engine dùng render theo timeline. Không dùng thời gian hệ thống hoặc random toàn cục trong animation cần render lặp lại.
6. Tạo bản thử ở độ phân giải cuối, xem contact sheet và sửa trước khi ghép vào cảnh.

## Quy tắc thị giác
- Có thứ bậc: một hiệu ứng chính, vài hiệu ứng phụ; tránh mọi thứ cùng sáng và cùng chuyển động.
- Bloom không được làm cháy trắng toàn màn hình; kiểm soát HDR, alpha, độ dày và thời lượng.
- Hạt không che mặt hoặc silhouette quá lâu. Khói/bụi phải có hướng và trọng lượng.
- Màu VFX phải tương phản với áo nhân vật và nền; tránh trùng palette của chiêu gần nhất.
- Tác động phải có phản ứng tương ứng: pose, tint, recoil, camera shake hoặc thay đổi môi trường.
- Không thêm âm thanh ở đây nếu pipeline âm thanh đã do skill khác quản lý; giữ VFX và SFX đồng bộ qua cue/timeline.

## Kiểm tra kỹ thuật
- Xác nhận blend mode, z_index, coordinate space, scale, texture filtering và shader tương thích phiên bản Godot trong dự án.
- Kiểm tra shader trên renderer thực tế (Forward+/Compatibility) trước khi dùng rộng.
- Giới hạn particle/node theo ngân sách cảnh; giải phóng node/tài nguyên đúng lúc.
- Không sửa engine dùng chung chỉ để phục vụ một hiệu ứng đơn lẻ; tạo module riêng hoặc helper tái sử dụng.

## Đầu ra
Mỗi hiệu ứng có mô tả ý đồ, tham số chính, timeline, file Godot/asset, ảnh render thử và checklist. Với chiêu võ công, chuyển yêu cầu sang `chuong-2d` để tuân thủ sổ chống trùng và quy tắc riêng của engine chiêu.
