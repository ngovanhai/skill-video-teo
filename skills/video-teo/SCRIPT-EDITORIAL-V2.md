# Quy trình biên tập kịch bản dùng chung (Script Editorial v2)

Áp dụng cho cả video HyperFrames và Godot. Đây là lớp biên tập nội dung, không thay thế format JSON/loi.txt của từng engine.

## Các đầu ra tiền kỳ

Mỗi tập mới nên lưu trong thư mục tập hoặc thư mục ý tưởng các tài liệu sau (có thể gộp vào file ý tưởng nếu workflow hiện tại yêu cầu):

1. **Research / Evidence**: mỗi claim quan trọng có nguồn gốc, loại nguồn, mức chắc chắn, tranh cãi và vị trí dự kiến trong kịch bản. Hai trang cùng sao chép một nguồn gốc không được tính là hai nguồn độc lập.
2. **Story analysis**: lõi câu chuyện, cảm xúc đầu-cuối, khoảnh khắc mạnh, góc nhìn kể, câu hỏi khán giả, hiểu lầm/tranh cãi và cách chất liệu tự nhiên chia khối.
3. **Narrative frame**: giữ nguyên hợp đồng `creative.frame` (HyperFrames) hoặc `story.frame` (Godot): name, analysis, axis, open, close, segments. Không chọn frame từ danh sách cố định.
4. **Script draft**: lời kể hoàn chỉnh theo frame; mỗi segment có chức năng kể chuyện, không chỉ là một chủ đề.
5. **Editorial review**: các phát hiện về bằng chứng, logic, lặp ý, nhịp kể, hook/payoff và những câu cần sửa.
6. **Voice-ready script**: bản đã tối ưu câu đọc, tên riêng, số/ngày tháng và ngắt nhịp; không thay đổi ý nghĩa dữ kiện.

## Narrative beat — cách tự kiểm từng segment

Với mỗi segment, người viết phải biết rõ:
- câu hỏi hoặc mục đích của đoạn;
- thông tin / bằng chứng mới;
- xung đột, trở ngại hoặc điều khiến thông tin đáng quan tâm;
- diễn biến và hệ quả;
- câu nối hoặc câu hỏi mở dẫn sang đoạn sau.

Không ép mọi segment có đủ mọi beat. Đoạn giải thích, so sánh hoặc tổng hợp có thể dùng cấu trúc riêng, nhưng phải đóng góp thông tin mới hoặc làm thay đổi cách hiểu của người xem.

## Hook và lời hứa

- Hook phải rõ chủ thể/vấn đề, tạo câu hỏi cụ thể và hứa một payoff thực sự có trong video.
- Đối chiếu tiêu đề + thumbnail với 30 giây đầu; 30 giây đầu phải xác nhận đúng lời hứa, không trì hoãn bằng tiểu sử hoặc giới thiệu dài.
- Giữ CTA đầu video theo luật chung hiện hành: sau hook, mời bình luận đề tài và like/đăng ký trong tối đa khoảng 8 giây; không đẩy diễn biến chính quá giây 45.
- Hook không bắt buộc gây sốc. Nghịch lý, lựa chọn khó, bí ẩn hoặc chi tiết cụ thể đều hợp lệ.

## Fact QA

Phân biệt rõ:
- факт / sự kiện được nguồn hỗ trợ;
- lời kể trong tác phẩm hoặc dị bản;
- nhận định/phân tích của người dẫn;
- giả thuyết hoặc chi tiết còn tranh cãi.

Với mỗi claim quan trọng, ghi nguồn trực tiếp và nguồn đối chiếu, ngày/ấn bản nếu có. Nêu rõ khi các bản truyện, bản dịch hoặc sử liệu khác nhau. Không biến suy luận thành sự thật. Nếu không xác minh được thì hạ mức khẳng định hoặc bỏ.

## Retention và nhịp kể

Biên tập viên phải chỉ ra:
- đoạn nào lặp lại thông tin đã biết;
- đoạn nào chỉ liệt kê dữ kiện mà không tạo tiến triển;
- câu hỏi nào được mở nhưng không được trả lời;
- đoạn nào có thể rút gọn mà không mất ý;
- payoff có trả đúng lời hứa hook/tiêu đề/thumbnail không.

Cứ 2–3 phút có thể mở một vòng tò mò, nhưng không tạo câu hỏi giả hoặc trì hoãn câu trả lời chỉ để kéo thời lượng.

## Thời lượng

Số từ chỉ là ước tính. Dùng tốc độ đọc thực tế của giọng và thời lượng file ZeroTTS/voice.json làm chuẩn cuối. Không kéo dài kịch bản bằng cách lặp ý để đạt mốc 20 phút. Profile của từng kênh/format được phép có target khác nhau.

## QA script

Chạy:
```bash
python3 __SKILLS_DIR__/kiem-tra-video/scripts/review-kich-ban-v2.py <thu_muc_tap>
python3 __SKILLS_DIR__/kiem-tra-video/scripts/review-kich-ban-v2.py <thu_muc_tap> --json
```

Đây là kiểm tra tĩnh đa engine. Cảnh báo là tín hiệu cần người viết/biên tập xem lại, không phải bằng chứng kịch bản dở. Script không tự xác minh nguồn, không chấm được cảm xúc hay retention thật. Vẫn phải nghe TTS và kiểm tra audio/video thực tế.

Script cũ `review-kich-ban.py` được giữ nguyên trong giai đoạn chuyển tiếp để tránh phá workflow cũ. Không dùng riêng kết quả PASS của script cũ làm chứng nhận chất lượng biên tập.
