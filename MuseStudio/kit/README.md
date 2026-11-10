# MuseStudio kit — video giải thích dài 25–30 phút

Mày viết `video.json` (kịch bản + cảnh), kit lo phần còn lại: giọng Tiến Đạt ("tiendat", ZeroTTS) → căn chữ Whisper → dựng cảnh HyperFrames → render từng chương → ghép `renders/final.mp4` → `thumbnail.png` → `publish.md`.

```bash
node __MUSE_ROOT__/kit/make.mjs __MUSE_ROOT__/videos/<slug>                     # tất cả các bước
node __MUSE_ROOT__/kit/make.mjs <dir> --stage validate                                # chỉ kiểm tra kịch bản
node __MUSE_ROOT__/kit/make.mjs <dir> --stage build,lint                              # dựng lại sau khi sửa
node __MUSE_ROOT__/kit/make.mjs <dir> --stage render --only ch03 --force              # render lại 1 chương
```

Các bước: `scaffold, validate, tts, align, build, lint, render, thumb, publish, fxlog`. Bước nào cũng chạy tiếp được (có cache): TTS/căn chữ chỉ làm lại cảnh có `say` đổi, render bỏ qua chương đã render và chưa đổi.

Thời gian (máy này, CPU): TTS ≈ 0,8× thời lượng, căn chữ ≈ 0,5×, render ≈ 2,7× → video 28 phút ≈ **2–2,5 giờ** chạy máy. Chạy `tts`, `align`, `render` ở chế độ nền (background) và theo dõi log.

**TTS + căn chữ trên Colab (mặc định từ 2026-10-23; TTS chỉ dùng ZeroTTS từ 2026-11-03, bỏ VieNeu):** `tts` gửi lên Google Colab GPU T4 qua `kiem-hiep/_tools/colab-tts/colab-tts.mjs` (cùng job + cache `.key` với `py/tts-zerotts.py`, bản máy nhà); `align` qua `colab-tts.mjs --align` (chạy chính `py/align.py` bằng CUDA, wav đổi sang flac 16 kHz trước khi gửi, cùng key cache — đã so: ra y hệt CPU). Không tốn CPU máy nhà; `ideas/chay-nang.sh` cho hai bước này chạy ngay, không chờ làn. Colab lỗi thì dừng; `--tts-local` / `--align-local` để làm ở máy nhà như dưới. Short (`…/shorts/…`) và sửa ngắn (< 30 câu) tự làm ở máy nhà (CPU) — chỉ bản dài mới lên Colab (`lib/mix.mjs`).

**Âm thanh (chốt 2026-10-24, `lib/mix.mjs`):** `sfx/` là bản êm do `node kit/sfx-soft.mjs` làm từ `sfx/_goc/` (lọc trầm < 180 Hz, ≤ -26 LUFS, đỉnh ≤ -12 dBFS) — không tiếng ùm ùm gây giật mình. Build chép đè bản êm vào `assets/sfx`, kẹp `vol` sfx ≤ 0,6, kẹp nhạc nền ≤ -40 LUFS (thấp hơn giọng ≈ -20 LUFS ít nhất 20 dB) theo độ to đo được (cache `<file>.lufs`).

**GPU (AMD RX 6600 XT, DirectML):** `align` (khi `--align-local`) tự chạy trên GPU nếu có `E:/tool/whisper-dml`, căn chữ ≈ 3× (ra y hệt CPU). `tts` ở máy nhà (`--tts-local`, short, sửa ngắn) chạy `py/tts-zerotts.py` bằng CPU (model int8, venv `__ZEROTTS_DIR__/.venv`). GPU lỗi thì tự chạy lại bằng CPU. Tắt bằng `--no-gpu` hoặc tạo file `kit/gpu-off`. Render vốn đã dùng GPU (Chrome D3D11 + encode `--gpu`).

**Tốc độ render:**
- `render` chạy 2 chương cùng lúc. Đổi số luồng bằng `--par N`; có `--low-memory` thì chỉ chạy 1.
- hyperframes chỉ dùng cách chụp nhanh (drawElement, khoảng 15 fps mỗi luồng) khi trong cảnh **không có** `filter: blur()`, `drop-shadow()`, `mix-blend-mode`, `backdrop-filter` hay CSS animation. Gặp một trong số đó, **cả chương** bị chuyển sang chụp màn hình, chậm gần gấp đôi.
- Vì vậy fx và cảnh custom phải làm quầng sáng, sương, nhoè bằng `radial-gradient`, nhiều nét mờ chồng lên nhau, hoặc opacity. Không dùng filter.
- Cũng không tween `clipPath`, `mask`, `rotationX`/`rotationY` (3D): lật thì dùng `scaleY`/`scaleX`, mở dần thì tween `width`/`left`/`right` kèm `overflow:hidden`.
- **Tua liền hay tua nhảy phải ra cùng một hình.** hyperframes chụp vài khung đối chiếu bằng cách tua nhảy (bỏ qua callback), rồi so với khung chụp nhanh. Lệch thì nó render lại cả chương bằng chụp màn hình. Vì thế:
  - Không dùng `onUpdate`, `onComplete`, `tl.call` để đổi hình. Số chạy thì chồng các nấc rồi bật tắt bằng `tl.set` opacity, như cảnh `stat`.
  - Không cho hai tween cùng prop trên cùng phần tử chồng thời gian lên nhau, ví dụ zoom thêm trên `#cam` trong lúc slow-zoom đang chạy. Bọc một lớp div riêng rồi tween lớp đó.

Ví dụ đầy đủ: `kit/example.video.json` (pilot 6 cảnh), chỉ để xem định dạng JSON, không chép câu chữ hay cấu trúc.

---

## 1. video.json

```jsonc
{
  "slug": "su-tich-ho-guom",                 // tên thư mục, không dấu
  "title": "Sự thật về thanh gươm trả lại giữa hồ",
  "voice": "tiendat",
  "target_min": [25, 30],                    // validate cảnh báo nếu lệch
  "names": "Lê Lợi, Lam Sơn, Thuận Thiên",   // tên riêng giúp Whisper nghe đúng
  "bgm": "playful-pizzicato.mp3",            // file trong kit/bgm, hoặc đường dẫn trong thư mục video ("assets/nhac.mp3")
  "theme": "giay-do",                        // (tuỳ chọn) giay-do | o-ly | bang-den | noir | tron, hoặc {"preset", "font", "caption"}
  // "narrator_style": không đặt — Tèo dùng bản cũ kit/chars/narrator
  "bgm_volume": 0.09,
  "cast": {                                  // "teo" (người dẫn) có sẵn, không cần khai
    "leloi": { "svg": "chars/leloi.svg", "name": "Lê Lợi" },   // file trong thư mục video
    "zeus":  { "svg": "library/zeus", "name": "Zeus" }          // thư viện kit/chars/library
  },
  "thumbnail": { ... },                      // mục 5
  "publish": { ... },                        // mục 6
  "chapters": [                              // hoặc đường dẫn: ["chapters/01.json", ...]
    { "title": "Mở đầu", "scenes": [ { "type": "hook", "say": "...", ... } ] }
  ]
}
```

Mỗi **cảnh** = một đoạn lời đọc (`say`) + một template hình. Mốc thời gian dùng `at`: một **cụm từ có thật trong `say`** (ví dụ `"at": "năm 1428"`). Hình xuất hiện đúng lúc giọng đọc tới chữ đó. Cue tìm lần lượt theo thứ tự nên từ lặp lại vẫn đúng chỗ. Không có `at` thì kit tự rải đều.

## 2. Luật kịch bản (bắt buộc)

**Độ dài.** 20–30 phút ≈ **5.600–7.000 từ** (giọng thật ≈ 4,5 từ/giây) ≈ **120–160 cảnh**, mỗi cảnh **12–60 từ** (5–15 giây). Câu dưới 10 từ dễ bị đọc vội và méo (validate báo). Trên 70 từ thì tách cảnh.

**Khung kể (`video.creative.frame`).** Không chọn từ danh sách nào: mỗi tập viết kịch bản thô, phân tích chất liệu (lõi chuyện, cảm xúc, khoảnh khắc mạnh nhất, ai đứng gần nhất để kể, người xem muốn biết gì, chất liệu chia thành khối nào) rồi tự thiết kế `frame = {name, analysis, axis, open, close, segments[]}` (skill video-teo mục 2b). Khung quyết định thứ tự thân bài, cách mở, cách kết và vai Tèo (`creative.voice_role`, chữ tự do). Validate cảnh báo nếu khung thiếu phần, `analysis` <25 chữ, tên/trục khung gần giống hoặc dàn khung giống ≥45% một trong 3 tập gần nhất, `voice_role` gần giống 2 tập gần nhất. Video cũ không có frame object vẫn được kiểm như trước. **Không có câu mẫu**: câu chào, CTA, câu kết của 5 tập gần nhất in ở `node fx-list.mjs` để né.

**Mở bài (≤60 giây).**
1. **Hook ≤15 giây:** câu đầu ≤12 từ, vào thẳng, **≥2 fx**. Thường là cảnh `hook`; loại khác thì đặt `"hook": true` ở cảnh đầu. Kiểu hook (`creative.hook`) khác 2 tập gần nhất.
2. **Lời chào dấu ấn kênh:** có cụm "lại là Tèo" trong khoảng 60 giây đầu, vị trí và cách nói theo khung. Validate cảnh báo nếu thiếu.
3. Hứa hẹn tuỳ khung. **Cấm** công thức "ba câu hỏi. Một… Hai… Và ba" (validate báo).

**Thân bài.** Một mạch liền, không cảnh `chapter`, không nói "Chương X". Đi theo thứ tự của khung, không mặc định kể theo thời gian. Cứ 2–3 phút cài một **vòng mở** rồi trả lời ở đoạn sau.

**CTA đăng ký: 2 lần.**
- **Giữa video (25–75% số chữ):** một cảnh `"cta": true` (tự hiện nút ĐĂNG KÝ + chuông + con trỏ bấm), lời mời nói bằng giọng của khung.
- **Cuối video (3 cảnh cuối):** mời đăng ký + bật chuông.
- Validate cảnh báo nếu thiếu "đăng ký" ở giữa hoặc ở cuối, cảnh `cta` mà lời không có "đăng ký", hoặc câu CTA giống tập trước.

**Nhịp hình.** Không dùng cùng một `type` quá 2 lần liên tiếp. `narrator` ≤20% số cảnh (validate báo). Loại cảnh xương sống đi theo khung. Mỗi nhân vật quan trọng có 1 cảnh `intro` khi xuất hiện lần đầu.

**Giọng văn.** Tèo xưng "mình", gọi người xem "các bạn". Câu ngắn, đời thường, có đùa nhẹ, nhịp đổi theo `voice_role`. Tên riêng viết đúng chính tả. Số viết bằng chữ số được (tts-zerotts.py tự đổi số, ngày, giờ sang chữ trước khi đọc).

**Kết.** Theo khung (phán quyết, twist, vòng tròn, câu hỏi để ngỏ…), không mặc định "điểm lại ba điều". Cảnh cuối là `outro`, hé lộ tập sau mỗi lần một kiểu.

**Nội dung.** Không chính trị nhạy cảm, không tôn giáo gây tranh cãi, không 18+. Sự kiện lịch sử phải đúng; phần truyền thuyết thì nói rõ là truyền thuyết.

## 3. Template cảnh (`type`)

Chung cho mọi cảnh: `say` (bắt buộc), `bg` (paper | dark | night | red | yellow | blue | pink | green | cream), `teo` (cameo Tèo góc trái: `false` để tắt, hoặc tên pose), `hold` (giây thêm sau lời đọc). Pose của Tèo: `talk, shrug, point, shock, smug, think`. Màu (`color`): yellow | blue | pink | green | cream | red | "#hex". Hình nằm trên y < 880 vì phụ đề nằm dưới.

| type | Dùng khi | Tham số |
|---|---|---|
| `hook` | Câu mở đầu | `lines[{text, at, color}]` ≤4 thẻ (kiểu `"strike"` gạch dần hoặc `"stack"`), `question{text, at}` (dấu ? khổng lồ), `pill`, `pose`, `teo_at` |
| `chapter` | Mở chương | `num`, `title`, `kicker`, `at` |
| `narrator` | Tèo giảng trực tiếp | `pose`, `title`, `points[{text, at, color, icon}]` ≤4 **hoặc** `bubble` + `at` |
| `intro` | Giới thiệu nhân vật | `who`, `name`, `tag`, `facts[{text, at}]` ≤3, `at`, `side` (left/right), `h`, `pose`, `flip`, `speaks`, `color` |
| `talk` | Hai nhân vật đối thoại | `left`, `right`, `lines[{who, text, at}]` ≤4 bong bóng, `left_name`, `right_name`, `left_pose`, `right_pose`, `flip_right` |
| `group` | Một nhóm người hoặc phe | `title`, `members[{who, name, at, pose, color}]` ≤6 |
| `timeline` | Dòng thời gian | `title`, `events[{when, text, at}]` ≤5 |
| `list` | Liệt kê lý do hoặc bước | `title`, `items[{text, at, icon}]` ≤5 (mặc định có Tèo cameo) |
| `stat` | Một con số gây sốc | `value`, `prefix`, `suffix`, `decimals`, `grouping`, `label`, `at`, `note{text, at}` (năm 1000–2100 tự bỏ dấu chấm ngăn cách) |
| `quote` | Trích dẫn hoặc câu nói nổi tiếng | `text`, `by`, `at`, `by_at` |
| `versus` | So sánh hai bên | `left{title, who, points[{text, at}], color}`, `right{…}`, `at` |
| `place` | Địa danh | `name`, `sub`, `kind`, `at`, `pin_x`, `pin_y`, `who`, `who_x`, `who_at`, `pose_teo` |
| `moment` | Khoảnh khắc kịch tính hoặc hài | `who` (1 hoặc mảng 2), `word` (chữ to kiểu truyện tranh: "BÙM!", "HẢ?!"), `at`, `effect` (shake/zoom), `caption{text, at}`, `sound`, `color`, `pose`, `pose2` |
| `outro` | Kết | `next{text, at}`, `bye`, `bye_at`, `pose` |

`place.kind`: mountain, sea, river, city, village, countryside (đồng lúa), palace (cung điện, chùa), temple (đền cột), castle, forest, desert, battlefield, night, space.

`text` trên thẻ chỉ là **tóm tắt 2–6 chữ** của lời đọc, không chép nguyên câu.

### 3b. Lớp hiệu ứng `fx` (chung cho mọi cảnh)

`"fx": ["dust", {"id": "punch", "at": "nổ tung"}, {"id": "mark", "shape": "circle", "x": 1300, "y": 300, "t": 2}]`. Mỗi mục là id hoặc object `{id, at | t, d, ...tham số}`. `at` = cụm chữ trong `say` (giống cảnh), `t` = giây tính từ đầu cảnh, `d` = kéo dài bao lâu (mặc định tới hết cảnh). fx nằm 2 lớp: `back` (sau hình cảnh) và `over` (trên hình cảnh). fx camera lắc/zoom cả khung hình cảnh (không đụng phụ đề). Mỗi cảnh chỉ 1 fx camera chạy liên tục (push-in, pull-out, pan, handheld).

In kho kèm số lần dùng gần đây: `node kit/fx-list.mjs`. Hiện có:

| nhóm | fx |
|---|---|
| atmosphere | `dust`, `rain` (heavy), `snow`, `embers`, `bubbles`, `twinkle`, `leaves` (petals), `fog` — tham số chung: `n`, `color`, `opacity`, `layer` (over/back) |
| light | `rays` (x, y, color, n), `vignette` (pulse), `flash` (color, strength, sound), `spotlight` (x, y, to_x, to_y, r), `light-leak`, `old-film` |
| camera | `push-in`, `pull-out`, `pan`, `dutch`, `punch`, `handheld`, `whip` |
| accent | `ink-splash` (x, y, r, color, out), `shockwave`, `speedlines`, `confetti`, `glitch`, `wipe`, `mark` (shape circle/underline/arrow, x, y, w, h), `lightning`, `pow` (text, x, y) |
| cta | `subscribe` (x, y; mặc định at = "đăng ký") — tự gắn khi cảnh có `"cta": true` |

Thêm fx mới: tạo `kit/fx/<ten>.mjs` export `{id, cat, label, run(ctx, o)}` (hoặc mảng), `run` trả `{back, over, css, js, sfx}`; dùng helper trong `kit/fx/_util.mjs` (`when`, `layer`, `rng`, `reps`). Mọi phần tử khởi đầu ẩn rồi hiện đúng `t`; random luôn qua `rng(ctx.id)` để build lại ra y hệt.

### 3c. Cảnh `custom` (tự vẽ riêng cho từng video)

`{"type": "custom", "file": "scenes/trong-dong.mjs", "say": "...", ...tham số tự đặt}`. File nằm trong thư mục video, `export default function (ctx, kit)` trả `{css, html, js, sfx, bg}` như template. Mẫu: `kit/examples/custom-scene.mjs` (SVG vẽ tay + timeline GSAP + cue). Luật: vẽ trong y < 880, id bắt đầu bằng `${ns}-`, mọi thứ khởi đầu ẩn, dùng `cues.find(cụm, fallback)` để hẹn giờ. Cảnh custom vẫn nhận `fx`, `cta`, `teo` như mọi cảnh. Cảnh custom nào đẹp, dùng lại được thì chuyển thành fx trong `kit/fx/`.

### 3d. Chống lặp giữa các video

`video.json` có khối `"creative": {"style", "motif", "hook", "palette", "signature_fx", "gag"}`. Khi có `target_min`, validate cảnh báo nếu: < 3 cảnh `custom`; < 1/4 số cảnh có fx; hook < 2 fx; `style`/`motif`/`hook` trùng 1 trong 2 video gần nhất; > 50% loại fx trùng 2 video gần nhất. `publish` tự chạy `--stage fxlog` ghi vào `ideas/fx-history.json` (chạy tay cũng được; build thử không ghi).

## 4. Vẽ nhân vật (SVG)

Thư viện có sẵn: `kit/chars/library/` (thần Hy Lạp). Nhân vật mới thì vẽ vào `<video>/chars/<key>.svg`, đúng phong cách:

- `viewBox="0 0 300 420"`, kiểu **chibi phẳng (kiểu cũ)**: đầu to tròn, thân ngắn, tô màu phẳng, viền đen `#111` dày 6, mắt chấm đen có đốm sáng, má hồng. Bộ vẽ chuẩn: `__SKILLS_DIR__/video-teo/scripts/gen-chars.template.mjs`. Không dùng bộ anime (từ 2026-10-21).
- Trang phục và đạo cụ nói rõ thân phận (long bào, mũ cánh chuồn, áo tứ thân, giáp, nón lá, toga, áo blouse…). Đạo cụ cũng có thể là một "nhân vật" riêng (gươm, rùa…) để dùng trong `moment` hoặc thumbnail.
- Biểu cảm (đổi lông mày / miệng) là file riêng `<key>-<expr>.svg`, khai báo thành key riêng trong `cast`.
- Muốn nhân vật mấp máy môi khi nói (`talk`, `intro.speaks`) thì vẽ 2 nhóm: `<g id="mouth-closed">…</g>` và `<g id="mouth-open" opacity="0">…</g>`.
- < 4 KB mỗi file, không `<text>`, không ảnh nhúng.
- Tèo: không đặt `narrator_style` → dùng `kit/chars/narrator/` (bản cũ). `narrator-anime` vẫn còn trong kit nhưng không dùng.

Mẫu: `kit/chars/library/zeus.svg`.

## 5. Thumbnail (1280×720) — phải gợi tò mò

```jsonc
"thumbnail": {
  "text": "Ai lấy lại thanh gươm thần?",  // 3–7 chữ, câu hỏi hoặc nghịch lý, KHÔNG trùng tiêu đề
  "highlight": "gươm thần",               // chữ tô vàng
  "who": ["teo"],                          // 1–2 nhân vật (nhân vật đầu to nhất, pose shock)
  "pose": "shock", "pose2": "think",
  "prop": "sword",                         // (tuỳ chọn) key trong cast, vẽ trong vòng tròn
  "circle_x": 900, "circle_y": 140, "circle_r": 330, "circle": true,
  "arrow": true, "badge": "?",             // badge: "?", "!", "18" hoặc false
  "bg": "red",                             // red | yellow | dark | blue | green | purple | noir | teal | orange
  "layout": "classic",                     // classic (chữ trái, nhân vật phải) | split (2 nhân vật đối đầu, badge VS) | closeup (cận mặt nhân vật chính)
  "sub": "Sự thật bất ngờ",                // nhãn nhỏ góc dưới (tuỳ chọn)
  "series": "Lịch sử Việt"                 // nhãn trên cùng (tuỳ chọn)
}
```

**Theme** (`video.theme`) đổi nền (bỏ lưới 80px: giấy dó có sợi, vở ô ly có lề đỏ, bảng phấn xanh cho cảnh `dark`, noir có viền tối + vân phim, `tron` là màu phẳng), font chữ cảnh và kiểu phụ đề (`pill` cổ điển, `band` băng đen chữ vàng, `outline` chữ viền không hộp, `ink` dải giấy nâu). Font dùng font hệ thống Windows (Georgia, Segoe Print…). Không đặt theme thì hình y như cũ.

Xem `thumbnail.png` sau bước `thumb`. Chữ phải đọc được ở cỡ nhỏ, không đè lên mặt nhân vật.

## 6. Publish

```jsonc
"publish": {
  "titles": ["3 phương án tiêu đề ≤ 70 ký tự, có từ khoá + yếu tố tò mò"],
  "description": "2–3 đoạn mô tả, câu đầu là hook",
  "hashtags": ["lichsuvietnam", "kechuyen"],
  "tags": ["lịch sử việt nam", "..."],
  "notes": "Các dữ kiện cần người xem lại trước khi đăng"
}
```

`publish.md` tự thêm mốc thời gian từng chương.

## 7. Khi lỗi

- `validate` báo lỗi thì sửa video.json. Cảnh báo `cue "…" not in say` nghĩa là hình sẽ hiện theo thời gian rải đều.
- `WEAK ALIGNMENT` thì kit tự đọc lại cảnh đó 1 lần. Nếu vẫn yếu, viết lại câu đó (thường do câu quá ngắn hoặc nhiều tên nước ngoài).
- Render chết giữa chừng: chạy lại `--stage render`, chương xong rồi sẽ bỏ qua. Máy yếu RAM thì thêm `--low-memory`.
- Xem trước: `cd <dir> && npx hyperframes@0.8.172 snapshot . --at 5,60,300 --no-end -o work/snap`, hoặc `npm run dev` để mở Studio.
