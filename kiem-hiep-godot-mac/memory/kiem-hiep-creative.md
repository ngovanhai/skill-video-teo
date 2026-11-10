---
name: kiem-hiep-creative
description: teo-kiem-hiep — mỗi tập khác cấu trúc/dựng cảnh/nền/âm thanh/effect/bố cục; khung tự thiết kế sau khi phân tích kịch bản (không danh sách); mọi card phải được đọc
metadata:
  node_type: memory
  type: feedback
  originSessionId: 2c990956-bdd9-470c-b748-15c76345d134
  modified: 2026-10-20T15:31:39.993Z
---

2026-10-20: người dùng muốn mỗi video kiếm hiệp có cấu trúc, cách dựng cảnh, nền, âm thanh, effect và bố cục khác nhau. 9 tập đầu chung một khuôn: chào "lại là Tèo đây", Tèo đứng góc trái x250, thumb VS, nhạc phẳng, kết "hẹn tập sau".

Cũng trong ngày, người dùng sửa tiếp:
- **Không fix cứng danh sách khung.** Mỗi tập phải phân tích kịch bản trước rồi mới tạo khung. Trước đó tao có làm bảng 13 khung và người dùng đã bác.
- **Mọi card đều phải được đọc thành tiếng.** 72 card của 9 tập đầu đều câm.

**Why:** các tập lặp mẫu, nhàm. Chọn khung từ danh sách vẫn ra khuôn, chỉ là khuôn khác. Card câm thì người xem phải tự đọc. Đây là cùng yêu cầu đã áp cho video-teo ([[creative-frames]]).

**How to apply:**
- Quy trình: viết kich-ban-tho.md → trả lời 6 câu "Phân tích" trong y-tuong.md → `story.frame` = {name, analysis ≥25 chữ, axis, open, close, segments 6–8}. `story.teo_role` là chữ tự do.
- story-check bắt lỗi khi tên khung, trục sắp xếp hoặc dàn khung giống 3 tập gần nhất, hoặc khi frame là chuỗi chọn sẵn.
- Card: build/voice tự đọc chữ trên thẻ nếu không có `vo` (`engine/voice.mjs` voOf/cardVo), và thẻ giữ trên màn hình theo độ dài giọng.
- Tập cũ chưa chạy lại voice.mjs thì card vẫn câm, nhưng output build vẫn y hệt engine cũ.
- Các trường dựng cảnh: stage/weather/music, bgm, bubble, thumb.layout, beat sfx, 5 set mới.
- Giọng luôn là Tiến Đạt (ZeroTTS) ([[kiem-hiep-voice-tiendat]]).
- Sản xuất đang dừng ([[kiem-hiep-10-video-ngay]]).
- Backup trước khi sửa: /Users/haingo/MuseStudio/.tmp/kh-bak/.

2026-10-21, người dùng thêm:
- Kiếm hiệp **không** dùng kiểu tranh thế giới (world canvas) như bản thử Pompeii của video-teo.
- Muốn **nhiều hoạt ảnh cơ thể người hơn**. Rig cũ ít khớp: NPC không có khuỷu/gối, cảnh đánh chủ yếu dựa vào fx.
- **Mỗi phần (segment) trong một tập phải có kiểu dựng khác nhau, không dùng template.** 9 tập đầu, phần nào cũng là: 1 set nền + 2–3 nhân vật đứng trên vạch sân khấu + chuỗi `pose` nói chuyện, xen card/emote/attack-react.

**How to apply:** đề xuất (đang chờ duyệt) gồm 2 phần:
- rig v2 nhiều khớp, kèm thư viện động tác võ
- mỗi phần là một module cảnh riêng, có form riêng (không gian/máy quay/cỡ nhân vật/động lực chuyển động/màu/âm thanh), story-check chặn các phần trùng form
