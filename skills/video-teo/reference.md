# Tra cứu nhanh — cảnh, hiệu ứng, mẫu

Nguồn chuẩn vẫn là `__MUSE_ROOT__\kit\README.md`. File này chỉ để tra nhanh.

## Khung video.json

```jsonc
{
  "slug": "ten-khong-dau", "title": "…", "voice": "Lóng", "target_min": [20, 30],
  "names": "Tên riêng 1, Tên riêng 2",          // giúp Whisper căn chữ tên nước ngoài
  "bgm": "playful-pizzicato.mp3", "bgm_volume": 0.09,
  "cast": { "key": { "svg": "chars/key.svg", "name": "Tên hiển thị" } },   // "teo" có sẵn, không cần khai
  "thumbnail": { "text": "3–7 từ", "highlight": "từ đắt", "who": ["chinh", "teo"], "pose": "<khác tập trước>",
                 "prop": "dovat", "circle_x": "<chỗ trống thật>", "circle_y": "…", "circle_r": "…", "arrow": "<true|false>",
                 "badge": "?", "bg": "<khác tập trước>", "sub": "Nhãn dưới", "series": "…" },
  "publish": { "titles": ["…≤60 ký tự…", "…", "…"], "description": "…", "hashtags": [], "tags": [], "notes": "…" },
  "chapters": ["chapters/01.json", "…"]
}
```

## Cảnh custom — xương sống của mọi tập (SKILL.md mục 2c, 4b)

Mỗi tập tự dựng **hệ hình riêng**: `scenes/_<ten>.mjs` (bảng màu `P`, `FONT`, khung, hình dùng lại) + **6–12 loại cảnh** `scenes/<ten>.mjs` nhận tham số JSON. `custom` ≥ 85% số cảnh. Ghi vào `creative.visual` (medium, why, layout, palette, font, kit, scene_kit).

```js
// scenes/<ten>.mjs — mẫu rút từ tập Tesla (scenes/so-lon.mjs + _hud.mjs)
import { P, FONT, frame } from "./_<ten>.mjs";   // frame(ctx, kit, opts) → { html, js } khung chung của tập
export default function (ctx, kit) {
  const { scene: s, ns, cues, dur } = ctx;        // s = object cảnh trong chương
  const { esc, r3, sfx, fit } = kit;
  const tT = cues.find(s.title_at, 0.4);          // giây xuất hiện theo lời đọc
  const f = frame(ctx, kit, { label: s.hud || "…" });
  let html = f.html + `<div id="${ns}-t" style="font-family:${FONT};opacity:0">${esc(s.title)}</div>`;
  let js = f.js + `FADE(q("#${ns}-t"), ${r3(tT)}, 0.4);
`;
  return { bg: P.bg, css: "", html, js, sfx: [] };
}
```

Bẫy: nháy kép trong giá trị chèn vào `style="…"`; id trùng `${ns}-ground/-root/-template/-cam/-fxcam/-fxN`; filter/blend/@keyframes/clipPath/3D tween/callback làm render chậm; `Math.random`.

Ví dụ một bộ cảnh (tập Tesla, **không dùng lại**): `khung-giay` mở đoạn · `ho-so` giới thiệu · `loi-noi`/`bo-dam` lời thoại · `so-lon` con số · `hai-lan`/`doi-chieu` so sánh · `duong-dua` mốc thời gian · `ban-ve`/`vec-to-luc` cơ chế · `bien-lai` gag nhân vật phụ.

## Shorts dọc (SKILL.md mục 6c)

```
videos/<slug>/shorts/
  _make-shorts.mjs        # sinh 3 thư mục từ kịch bản (chạy lại khi sửa lời)
  scenes/_doc.mjs         # bộ hình dọc chung: vframe (vạch tiến độ), headline, chip, stampBox, subscribe({k})
  scenes/v-*.mjs          # cảnh dọc, mọi cảnh type "custom"
  01-ten/ video.json (+ "short": {title, description, hashtags, tags, full}) · chapters/01.json
```
- Khung 1080×1920. Nội dung y 190–1350 · phụ đề y 1380–1600 (tự vẽ) · trống dưới 1600 và mép phải ~100 px.
- `ctx`: `vertical`, `index`, `count`, `fullThumb` (`assets/full-thumb.png`, chép từ `../../youtube/thumbnail.png`).
- `video.short.caption_words` (mặc định 4), `video.short.caption {top, size}` chỉnh phụ đề.
- Lệnh: `make.mjs <dir> --stage scaffold,tts,align` → `build-short.mjs <dir> --stage build` → snapshot → `--stage render,pack` → `youtube/shorts/NN-ten.mp4` + `.txt`.
- Ví dụ bộ cảnh dọc (Tesla, **không dùng lại**): `v-hook-doc` vòng dốc + lia xuống hàng xe · `v-luc` mũi tên lực · `v-so` số + vòng đo · `v-the` thẻ xếp dọc (claim gạch / hẹn gạch) · `v-quy-dao` cận cảnh → quỹ đạo · `v-nhan-vat` nhân vật + nhãn/bong bóng · `v-hai-xe` chia đôi trên/dưới · `v-bien-lai` tờ biên lai · `v-cta` thẻ video dài + Tèo + nút.

## Loại cảnh template của kit (chỉ dự phòng, ≤ 15% tổng, ghi lý do khi dùng)

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
| custom | `file` (scenes/<ten>.mjs) + tham số tự đặt — **loại chính** |

- `bg`: paper dark night red yellow blue pink green cream.
- Pose của Tèo: talk shrug point shock smug think.
- Âm thanh (`sound`): pop whoosh whooshShort impact impact2 chime sparkle click riser glitch error cinematic.

## Trường chung mới: `fx`, `cta`, cảnh `custom`

- `"fx": ["dust", {"id": "punch", "at": "nổ tung"}, {"id": "mark", "shape": "circle", "x": 1300, "y": 300, "t": 2}]`: `at` = cụm trong `say`, `t` = giây từ đầu cảnh, `d` = kéo dài (mặc định tới hết cảnh). Mỗi cảnh chỉ 1 fx camera liên tục (push-in, pull-out, pan, handheld).
- `"cta": true`: tự gắn fx `subscribe` (nút ĐĂNG KÝ đỏ + chuông + con trỏ bấm, hiện ở chữ "đăng ký"). `say` phải có "đăng ký".
- `{"type": "custom", "file": "scenes/<ten>.mjs", ...}`: cảnh tự vẽ, mẫu `kit/examples/custom-scene.mjs`.
- `video.json` → `"creative": {"frame": {name, analysis, axis, open, close, segments}, "voice_role", "style", "motif", "hook", "palette", "signature_fx", "gag", "visual": {medium, why, layout, palette, font, kit, scene_kit}}` (SKILL.md mục 2b, 2c).
- Kho fx + lịch sử dùng: `node __MUSE_ROOT__/kit/fx-list.mjs`.

| nhóm | fx (tham số) |
|---|---|
| atmosphere | `dust`, `rain` (heavy), `snow`, `embers`, `bubbles`, `twinkle`, `leaves` (petals), `fog`; chung: `n`, `color`, `opacity`, `layer` over/back |
| light | `rays` (x,y,color,n), `vignette` (pulse), `flash` (color,strength,sound), `spotlight` (x,y,to_x,to_y,r), `light-leak`, `old-film` |
| camera | `push-in`, `pull-out`, `pan`, `dutch`, `punch`, `handheld`, `whip` |
| accent | `ink-splash` (x,y,r,color,out), `shockwave`, `speedlines`, `confetti`, `glitch`, `wipe`, `mark` (shape circle/underline/arrow, x,y,w,h), `lightning`, `pow` (text,x,y) |
| cta | `subscribe` (x,y) |

Chọn fx theo nghĩa của cảnh, nhưng đừng dùng mãi một cặp cố định cho một cảm xúc: xem cột "dùng gần đây" trong `fx-list.mjs` và ưu tiên fx ít dùng.

## Kiểu hook (khác 2 tập gần nhất; tự viết câu, không có câu mẫu)

Hook mặc định là cảnh `custom` vẽ riêng quanh hình ảnh đắt nhất của kịch bản (SKILL.md mục 3 › Mở đầu): hình ≥40% khung, mỗi nhịp lời một biến đổi hình, cú chốt cuối, `creative.hook_visual` khác 3 tập trước. Không dùng template `type: "hook"`; hook vẽ bằng ngôn ngữ hình của tập (import `_<ten>.mjs`).

Gợi ý: nghịch lý sốc · con số gây sốc · in medias res · câu hỏi trực diện · lời hứa bí mật · cold open bằng thoại nhân vật · âm thanh / im lặng rồi một câu · trailer giả · "lời đồn sai" rồi gạch đi · người xem đóng vai · đếm ngược · chi tiết nhỏ xíu phóng to.

## Khung kể, vai Tèo, kiểu kết

- Khung kể (`creative.frame`) **không chọn từ danh sách**: viết kịch bản thô → phân tích → tự thiết kế `{name, analysis, axis, open, close, segments}` (SKILL.md mục 2b). Validate so độ giống tên/trục/dàn khung với 3 tập gần nhất; `voice_role` là chữ tự do, so với 2 tập gần nhất.
- Kiểu kết: phán quyết · twist · vòng tròn về cảnh mở · câu hỏi để ngỏ · nhân vật nói lời cuối · đồ vật về chỗ cũ · bảng điểm.
- Câu chào, câu CTA, câu kết của 5 tập gần nhất: `node __MUSE_ROOT__/kit/fx-list.mjs`. **Không có câu mẫu**: mỗi tập tự viết theo giọng khung và `voice_role`.
- Cấm công thức: "ba câu hỏi. Một… Hai… Và ba" · "đoạn sau còn gắt hơn" · "Mỗi lượt đăng ký là thêm một…" (nếu 5 tập trước đã dùng) · "điểm lại ba điều đã hứa" làm kết mặc định · "một … nổi tiếng khác, với một cách kể hoàn toàn mới".

## Kho gợi ý chủ đề có neo (chưa làm; dùng rồi thì xoá khỏi đây)

| mảng | ứng viên (neo: góc kể gợi ý) |
|---|---|
| nhân vật lịch sử VN | Quang Trung: hành quân thần tốc Tết Kỷ Dậu · Lý Thường Kiệt: "Nam quốc sơn hà" và trận Như Nguyệt · Ngô Quyền sau Bạch Đằng · Nguyễn Trãi và vụ án Lệ Chi Viên |
| nhân vật lịch sử thế giới | Cleopatra: nữ hoàng cuối cùng của Ai Cập · Thành Cát Tư Hãn: đế chế lớn nhất lịch sử · Tần Thủy Hoàng: vua đi tìm thuốc trường sinh · Alexander Đại đế |
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
