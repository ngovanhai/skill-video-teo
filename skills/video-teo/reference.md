# Tra cứu nhanh — cảnh, hiệu ứng, mẫu

Nguồn chuẩn vẫn là `__MUSE_ROOT__/kit/README.md`. File này chỉ để tra nhanh.

## Khung video.json

```jsonc
{
  "slug": "ten-khong-dau", "title": "…", "voice": "Lóng", "target_min": [20, 30],
  "names": "Tên riêng 1, Tên riêng 2",          // giúp Whisper căn chữ tên nước ngoài
  "bgm": "playful-pizzicato.mp3", "bgm_volume": 0.09,
  "cast": { "key": { "svg": "chars/key.svg", "name": "Tên hiển thị" } },   // "teo" có sẵn, không cần khai
  "thumbnail": { "text": "3–7 từ", "highlight": "từ đắt", "who": ["chinh", "teo"], "pose": "shock", "pose2": "shock",
                 "prop": "dovat", "circle_x": 320, "circle_y": 345, "circle_r": 240, "arrow": false,
                 "badge": "?", "bg": "red", "sub": "Nhãn dưới", "series": "Lịch sử Việt" },
  "publish": { "titles": ["…≤60 ký tự…", "…", "…"], "description": "…", "hashtags": [], "tags": [], "notes": "…" },
  "chapters": ["chapters/01.json", "…"]
}
```

## Loại cảnh (đủ trường hay dùng)

| type | trường |
|---|---|
| hook | `lines[{text,at,color}]`, `question{text,at}`, `pill` |
| chapter | (không dùng: video là một mạch liền) |
| narrator | `pose` + (`bubble`,`at`) hoặc (`title`,`points[{text,at,color,icon}]` ≤4) |
| intro | `who`,`name`,`tag`,`side`,`speaks`,`color`,`facts[{text,at}]` ≤3 |
| talk | `left`,`right`,`left_name`,`right_name`,`left_pose`,`lines[{who,text,at}]` ≤4 |
| group | `title`, `members[{who,name,at,color}]` ≤6 |
| timeline | `title`, `events[{when,text,at}]` ≤5 |
| list | `title`, `items[{text,at,icon}]` ≤5 |
| stat | `value`,`prefix`,`suffix`,`label`,`at`,`note{text,at}` |
| quote | `text`,`by`,`at`,`by_at`,`bg` |
| versus | `at`, `left/right{title,who,color,points[{text,at}]}` |
| place | `name`,`sub`,`kind`,`at` — kind: mountain sea river city village countryside palace temple castle forest desert battlefield night space |
| moment | `who` (key hoặc [2 key]), `word`, `at`, `effect` shake/zoom, `sound`, `bg`, `caption{text,at}`, `pose` |
| outro | `next{text,at}`, `bye`, `bye_at` |
| custom | `file` (scenes/<ten>.mjs) + tham số tự đặt |

- `bg`: paper dark night red yellow blue pink green cream.
- Pose của Tèo: talk shrug point shock smug think.
- Âm thanh (`sound`): pop whoosh whooshShort impact impact2 chime sparkle click riser glitch error cinematic.

## Trường chung mới: `fx`, `cta`, cảnh `custom`

- `"fx": ["dust", {"id": "punch", "at": "nổ tung"}, {"id": "mark", "shape": "circle", "x": 1300, "y": 300, "t": 2}]`: `at` = cụm trong `say`, `t` = giây từ đầu cảnh, `d` = kéo dài (mặc định tới hết cảnh). Mỗi cảnh chỉ 1 fx camera liên tục (push-in, pull-out, pan, handheld).
- `"cta": true`: tự gắn fx `subscribe` (nút ĐĂNG KÝ đỏ + chuông + con trỏ bấm, hiện ở chữ "đăng ký"). `say` phải có "đăng ký".
- `{"type": "custom", "file": "scenes/<ten>.mjs", ...}`: cảnh tự vẽ, mẫu `kit/examples/custom-scene.mjs`.
- `video.json` → `"creative": {"style", "motif", "hook", "palette", "signature_fx", "gag"}`.
- Kho fx + lịch sử dùng: `node __MUSE_ROOT__/kit/fx-list.mjs`.

| nhóm | fx (tham số) |
|---|---|
| atmosphere | `dust`, `rain` (heavy), `snow`, `embers`, `bubbles`, `twinkle`, `leaves` (petals), `fog`; chung: `n`, `color`, `opacity`, `layer` over/back |
| light | `rays` (x,y,color,n), `vignette` (pulse), `flash` (color,strength,sound), `spotlight` (x,y,to_x,to_y,r), `light-leak`, `old-film` |
| camera | `push-in`, `pull-out`, `pan`, `dutch`, `punch`, `handheld`, `whip` |
| accent | `ink-splash` (x,y,r,color,out), `shockwave`, `speedlines`, `confetti`, `glitch`, `wipe`, `mark` (shape circle/underline/arrow, x,y,w,h), `lightning`, `pow` (text,x,y) |
| cta | `subscribe` (x,y) |

Gợi ý ghép: cú sốc = `punch` + `speedlines`/`shockwave`/`pow`; hồi tưởng = `old-film` hoặc `light-leak`; bí ẩn = `fog` + `vignette` hoặc `spotlight`; chiến công = `rays` + `embers`/`confetti`; giông bão = `rain` + `lightning` + `flash`; chuyển ý = `wipe` hoặc `whip`; nhấn chữ = `mark`.

## Kiểu hook (đổi kiểu mỗi video)

| kiểu | ví dụ câu đầu (≤12 từ) |
|---|---|
| nghịch lý sốc | "Có một cái hang to đến mức bên trong có mây." |
| con số gây sốc | "240 người ra đi. Chỉ 18 người trở về." |
| in medias res | "Năm 1990, một người thợ rừng nghe gió thổi ra từ vách đá." |
| câu hỏi trực diện | "Nếu được chọn, các bạn có dám bước vào không?" |
| lời hứa bí mật | "Có một chi tiết sách giáo khoa không bao giờ kể." |
| đếm ngược / thách đố | "Ba giây nữa, các bạn sẽ không nhìn bát cơm như cũ." |

## Mẫu lời chào (giữ ý, đổi lời; đừng chép nguyên)

- "Chào các bạn, lại là Tèo đây, và hôm nay mình sẽ cùng các bạn lần theo dấu vết của…"
- "Chào các bạn, lại là Tèo đây! Cầm chắc đèn pin nhé, vì chuyến này mình đi xuống lòng đất."
- "Chào các bạn, lại là Tèo đây. Câu hỏi lúc nãy nghe vô lý đúng không? Vậy thì mình cùng đi tìm câu trả lời."

## Mẫu CTA (gắn với nội dung; đừng chép nguyên)

- Giữa video: "Nếu thấy chuyện này hay thì bấm đăng ký kênh Tèo Kể giúp mình nhé, vì đoạn sau còn gắt hơn nhiều." / "Mới nửa đường thôi mà đã thế này rồi. Bạn nào chưa đăng ký kênh thì bấm luôn đi, kẻo lỡ cái kết."
- Cuối video: "Nếu video này cho các bạn thêm một điều thú vị, hãy đăng ký kênh, bật chuông, và kể mình nghe trong phần bình luận: nếu là các bạn, các bạn sẽ chọn gì?"

## Nhịp mẫu (chỉ tham khảo, mỗi video phải đổi thứ tự)

- Mở đầu: hook (≥2 fx) → narrator chào "lại là Tèo đây…" → moment/stat hé lộ → narrator hứa hẹn.
- Một đoạn thân (~15 cảnh): intro → place(+fog/rays) → moment(+fx) → narrator(points) → talk → **custom** → stat → moment(+fx) → quote(+old-film) → versus → list(+mark) → narrator(bubble, vòng mở).
- Giữa video (40–60%): narrator `cta: true`, ngay trước một bước ngoặt.
- Kết: tóm tắt → câu hỏi bình luận → narrator `cta: true` (đăng ký + chuông) → outro.

## Kho gợi ý chủ đề có neo (chưa làm; dùng rồi thì xoá khỏi đây)

| mảng | ứng viên (neo: góc kể gợi ý) |
|---|---|
| nhân vật lịch sử VN | Trần Hưng Đạo: ba lần đánh Nguyên · Quang Trung: hành quân thần tốc Tết Kỷ Dậu · Lý Thường Kiệt: "Nam quốc sơn hà" và trận Như Nguyệt · Ngô Quyền sau Bạch Đằng · Nguyễn Trãi và vụ án Lệ Chi Viên |
| nhân vật lịch sử thế giới | Napoleon: từ đảo Corse tới Saint Helena · Cleopatra: nữ hoàng cuối cùng của Ai Cập · Thành Cát Tư Hãn: đế chế lớn nhất lịch sử · Tần Thủy Hoàng: vua đi tìm thuốc trường sinh · Alexander Đại đế |
| trận đánh / sự kiện | Điện Biên Phủ: 56 ngày đêm · Xích Bích: trận hoả công · Thermopylae: 300 chiến binh Sparta · Bức tường Berlin sụp đổ |
| nhà khoa học / phát minh | Einstein và E=mc² · Newton: quả táo và lăng kính · Galileo: "Dù sao Trái Đất vẫn quay" |
| thảm hoạ / bí ẩn | Titanic: đêm cuối cùng · Chernobyl: 1 giờ 23 phút · Pompeii: thành phố bị chôn sống · Tam giác Bermuda · Atlantis: lục địa biến mất |
| kỳ quan / địa danh | Vạn Lý Trường Thành · Machu Picchu · Angkor Wat · Tháp Eiffel: công trình bị ghét nhất Paris · Đấu trường Colosseum |
| dân gian / thần thoại | Thánh Gióng · Tôn Ngộ Không: Tây Du Ký có thật? · Chử Đồng Tử – Tiên Dung · Hercules: 12 kỳ công · Vua Arthur và thanh kiếm trong đá |
| người nổi tiếng hiện đại | Steve Jobs: bị đuổi khỏi chính công ty mình · Pelé · Lý Tiểu Long · Charlie Chaplin · Walt Disney và chú chuột Mickey |

**Chủ đề chung → neo nổi tiếng** (gặp ý chung chung thì đổi theo kiểu này):

| ý chung (CẤM) | thay bằng neo |
|---|---|
| Cầu vồng / ánh sáng | Newton và lăng kính |
| Núi lửa | Pompeii, hoặc Krakatoa 1883 |
| Khủng long | Tiểu hành tinh xoá sổ khủng long |
| Sấm sét | Benjamin Franklin và con diều |
| Bóng đèn / điện | Edison vs Tesla |
| Vũ trụ / sao | Galileo và chiếc kính thiên văn |
| Tàu ngầm / đại dương | Titanic được tìm thấy năm 1985 |

## Mẫu dòng DA-LAM

`| 2026-10-19 | Hai Bà Trưng: ba năm làm vua và hai cái kết | Lịch sử Việt Nam | Đã render — chờ đăng |`
