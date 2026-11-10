---
name: teo-kiem-hiep-godot
description: >-
  Làm một tập Tèo Kể Kiếm Hiệp (≥20 phút, giọng Tiến Đạt) dựng toàn bộ bằng Godot 2D: research → kịch bản loi.txt →
  khung tự thiết kế → giọng ZeroTTS → nhân vật (nhan-vat-chibi + ve.mjs) → phim.gd riêng của tập → soi sheet → render →
  nhạc, ảnh bìa, gói YouTube (KHÔNG làm Shorts). Có khung project (new-tap), bộ soát (gd-check) và sổ chống lặp hình thức.
  Chủ đề: kiếm hiệp và mọi tác phẩm nổi tiếng Trung Quốc (Tam Quốc, Thủy Hử, Tây Du Ký, Phong Thần, Liêu Trai…).
  Dùng khi người dùng nói "làm tập kiếm hiệp Godot", "tập Tam Quốc", "tập Thủy Hử", "tập Tây Du Ký", "dựng tập bằng Godot", "tập kiếm hiệp mới", "làm lại tập N bằng Godot".
---

# Tèo Kiếm Hiệp × Godot 2D: mỗi tập một kịch bản, một khung, một bộ code hình

`SKILL = thư mục chứa file này` · `KH = __SKILLS_DIR__/teo-kiem-hiep` · `LOCK = bash __MUSE_ROOT__/kiem-hiep/_tools/slot.sh`
Godot 4.7.2: `__GODOT__` · Tập mẫu (chỉ đọc để học): `kiem-hiep/tap-10-lenh-ho-xung/godot/ (bản cũ hơn: kiem-hiep/_lab/mau-godot-tap-01/)`

Skill này lo **quy trình Godot**. Luật nội dung vẫn là của `teo-kiem-hiep`, phải đọc và theo:
- mục "Luật cứng" (bản quyền, chính xác ≥2 nguồn, tôn trọng, ≥20 phút, không chia chương);
- mục "Model AI" (người dùng chốt 2026-11-08: cố định sử dụng Gemini 3.8 Flash (High));
- mục "Quy trình một tập", bước 0 (research, chọn chủ đề từ `KH/data/chu-de.md`, 1 chủ đề chính + 4–6 chủ đề phụ);
- mục "Khung dựng" (kịch bản thô → phân tích → khung; mở đầu, kết, CTA).

Phần HyperFrames trong teo-kiem-hiep (tap.json beat, build.mjs, plan.mjs, fx local, pack.mjs) **không dùng** cho tập Godot.

**Biên tập kịch bản:** đọc thêm `__SKILLS_DIR__/video-teo/SCRIPT-EDITORIAL-V2.md` trước khi viết. Giữ nguyên `story.frame`; kiểm tra claim theo từng dị bản; mỗi segment cần mục đích kể chuyện và payoff. Sau khi có `loi.txt`, chạy `python3 __SKILLS_DIR__/kiem-tra-video/scripts/review-kich-ban-v2.py <tap>` như reviewer tĩnh bổ sung cho `gd-check.mjs`.

## Công cụ

| lệnh | việc |
|---|---|
| `node SKILL/scripts/new-tap.mjs <tap> --ten "<khung>"` | Tạo `<tap>/godot/` chỉ gồm hạ tầng: project.godot, main.gd (hợp đồng + xếp giờ theo giọng + phát giọng/nhạc/sfx), phim.gd chỗ giữ, loi.txt/story.json/cast.json mẫu, sfx. Không chép font. Không ghi đè. |
| `node KH/scripts/gd-voice.mjs <tap>` (không qua LOCK) | `loi.txt` → `godot/voice/<id>.wav` + `voice.json` (độ dài thật, ghi cả `engine: zerotts`). Có cache. `--dry` để ước thời lượng. **Chỉ dùng ZeroTTS (người dùng chốt 2026-11-03, bỏ hẳn VieNeu)**, giọng **Tiến Đạt** (`"voice": "tiendat"`, giọng nam trẻ có sẵn của ZeroTTS; người dùng chốt 2026-11-03, trước đó là "Lóng" nạp ở `~/.zerotts/voices`); mỗi câu kéo về -20 LUFS. voice.json cũ của VieNeu (không có `engine`) thì cả tập được đọc lại. Bản dài đọc trên Google Colab GPU T4 (`kiem-hiep/_tools/colab-tts/colab-tts.mjs`: tự tạo phiên, cài ZeroTTS bằng `setup-zerotts.py`, mỗi lần gửi giọng + `kit/py/tts-zerotts.py` lên rồi đọc bằng `synth-zerotts.py`; chờ nhau qua `.lock`; xong job thì giữ phiên thêm 15 phút (`COLAB_TTS_GRACE`) cho job kế, không ai dùng mới tắt; mọi lệnh colab có hạn giờ + thử lại; đăng nhập colab một lần bằng `colab sessions`). Colab lỗi thì **dừng báo lỗi, không lùi về máy nhà** (người dùng chốt: lỗi Colab thì sửa Colab) — **trừ khi Colab thu hồi / không tạo được phiên GPU: khi đó tự đọc bằng CPU máy nhà (chốt 2026-11-03)**; `--local` (chỉ khi người dùng cho) mới đọc ở nhà và tự xin suất LOCK. **Ngoại lệ người dùng chốt 2026-10-24: short (`<tap>/shorts/…`) và sửa ngắn (< 30 câu cần đọc) gd-voice tự đọc ở máy nhà bằng `kit/py/tts-zerotts.py` (CPU, model int8 ở `__ZEROTTS_DIR__`, tự xin suất LOCK), chỉ bản dài mới lên Colab** (luật chung `kit/lib/mix.mjs`). Không bọc bằng LOCK: chờ hàng Colab mà giữ suất thì chặn render. Đừng sửa `slot.sh` khi đang có job chạy (bash đọc script theo byte, sửa giữa chừng làm hỏng job đang chờ). |
| `node KH/scripts/gd-mat.mjs <tap>` | Mặt từng nhân vật bằng `<tap>/ve.mjs` → `godot/mat/<nv>/<biểu cảm>.svg`, đọc `godot/cast.json`. |
| `node SKILL/scripts/gd-chieu.mjs <tap> <id chiêu> [id …]` | Đưa chiêu đã làm xong bên `chuong-2d` (có trong `moves.json`) vào tập: chép engine + chiêu + nhân vật vào `godot/chuong/` (đổi đường `res://`), cầu nối `chuong/chieu.gd`, sfx thiếu; ghi `story.chieu`; đổi project sang renderer `forward_plus` (chiêu làm trên Forward+, gl_compatibility lệch màu). Sửa chiêu bên chuong-2d xong thì chạy lại. |
| `node SKILL/scripts/gd-check.mjs <tap>` | Soát: id, chữ "Chương", hook/Tèo/lời mời đầu video/CTA, giọng khớp chữ, parse Godot, DUR ≥ 20:00, phim.gd đã dựng, story.json khác 5 tập trước, cast có trong sổ. `--no-godot` bỏ bước Godot. |
| `python3 __SKILLS_DIR__/kiem-tra-video/scripts/smoke-test.py <tap>` | **Smoke Test siêu tốc 15s:** Kiểm tra cú pháp Godot headless, soát thời lượng >= 20 phút, soát 170+ biểu cảm Chibi SVG, chụp 4 snapshot preview để duyệt mắt trước khi render dài. |
| `LOCK "<tap> xem" node KH/scripts/gd-render.mjs <tap> --preview --from A --to B --sheet 5 --out xa` | Preview 960×540 + `work/sheet-xa.jpg`. |
| `LOCK "<tap> render" node KH/scripts/gd-render.mjs <tap> --par 2` | Bản cuối `renders/final.mp4`. Render bằng **ffmpeg song song 2 nửa qua pipe**, không dùng Movie Maker. |
| `node KH/scripts/gd-render.mjs <tap> --audio-only` | **Audio Remuxing trong 3 giây:** Khi chỉ sửa LUFS, nhạc nền, SFX ducking, ffmpeg giữ nguyên video stream `-c:v copy` và chỉ thay audio trong 3s (tăng tốc x400, không re-render 20 phút). |
| `node SKILL/scripts/pack.mjs <tap>` | `youtube/`: mp4, thumbnail.png 1280×720, tieu-de, mo-ta, tags. |
| `python3 __SKILLS_DIR__/kiem-tra-video/scripts/check-tong-the.py <tap>` | **Quality Gate chốt chặn:** Kiểm tra toàn diện Kịch bản, Hình ảnh, Âm thanh (-20 LUFS, Peak -0.5), Gói YouTube. Khi 100% PASS tự động cấp chứng chỉ `youtube/.READY_TO_UPLOAD`. |
| `node SKILL/scripts/gd-check.mjs <tap> --log` | Sau bản cuối: ghi story.json vào `SKILL/data/history.json`. |

Việc nặng ở máy nhà (render, preview, check chiêu) luôn chạy qua `LOCK`; giọng đọc trên Colab thì không: máy chỉ có 2 suất. Lệnh dài chạy nền.

## Quy trình

1. **Research, chủ đề, kịch bản thô, phân tích, khung.** Làm đúng teo-kiem-hiep (bước 0 và mục "Khung dựng"). Bước 0 có cả bước 2b: **ké video đang lên** (`kiem-hang.py --dang-len=teo-tuu-lau`, luật chung mục 1e).
   Ghi `<tap>/kich-ban-tho.md` và `<tap>/y-tuong.md`: nguồn, 3 ý + điểm, phân tích 6 câu, khung, bảng dữ kiện, bảng "khác 5 tập trước".
   Đọc `SKILL/data/history.json` trước khi chọn khung: khung, vai Tèo, bút, máy quay, palette, nhạc, thumbnail, mặt, font, chân mô tả đều phải khác. gd-check so theo tỉ lệ từ chung: giống ≥60% là lỗi, ≥40% là cảnh báo; đổi thứ tự chữ hay thêm bớt một từ không qua được.
2. **Khung project:** `new-tap.mjs <tap> --ten "<tên khung>"`.
3. **Kịch bản `godot/loi.txt`.**
   - **BẮT BUỘC HEADER METADATA HỢP ĐỒNG (Executive Production Directive):** 5 dòng đầu tiên của file phải khai báo chuẩn:
     ```text
     # GENRE: VO_DAI_SO_KEO | TRINH_THAM_KY_AN | LAT_NGUOC_DINH_KIEN | HO_SO_MAT | HUNG_CA_BI_TRANG
     # HOOK_TYPE: PARADOX | CONFLICT | INVERTED | SECRET | PROPHECY
     # TEO_SKIN: teo_tieu_nhi | teo_thu_sinh | teo_hiep_khach | teo_lao_gia
     # TEO_SOCKET: none | kinh_lup | but_long | gay_truc | ho_lo_ruou | the_bai | quat_long_vu
     # TEO_ROLE: <Vai trò cụ thể của Tèo trong tập>
     ```
     *(review-kich-ban.py và tao-storyboard.py sẽ đọc trực tiếp header này để nạp tài nguyên và kiểm tra chống trùng lặp 5 tập. Thiếu header sẽ bị đánh trượt ngay lập tức).*
   - **TỶ LỆ PHÂN BỔ VÀNG 65 / 35 (Chống nhàm chán & Bảo vệ thuật toán YouTube):**
     - **65% Nhóm Nòng Cốt:** *Võ Đài So Kèo* & *Trinh Thám Kỳ Án* (giữ vững bản sắc "Tửu Lâu luận kiếm", nhịp retention cao nhất).
     - **35% Nhóm Gia Vị:** *Lật Ngược Định Kiến* (minh oan nhân vật), *Hồ Sơ Mật* (thâm cung bí sử), *Hùng Ca Bi Tráng* (đại chiến huyết lệ).
     - *Quy tắc luân chuyển: Cứ 2 tập Nòng cốt xen kẽ 1 tập Gia vị.*
   - **4 CHIẾC NEO THƯƠNG HIỆU BẤT BIẾN CỦA TÈO:** Dù biến hóa vai diễn nào, 4 yếu tố sau tuyệt đối không đổi:
     1. Giọng Tiến Đạt (-20 LUFS) ấm áp, có duyên ngầm.
     2. Bản tính tếu táo, thông thái, xưng "Tèo" - gọi "huynh đệ/chư vị".
     3. Nét mặt Chibi tròn, nụ cười tinh quái, gãi đầu quen thuộc.
     4. Câu chốt cạn ly/nâng chén rượu cuối video.
     - **LƯU Ý CỐT TỬ VỀ TÊN KÊNH:** Kênh YouTube kiếm hiệp là **Tèo Tửu Lâu** (`@teoTuuLau`). Trong lời thoại (`k02`, `k12`, CTA) **BẮT BUỘC** nói *"đăng ký kênh Tèo Tửu Lâu"* (hoặc *"ghé quán Tèo Tửu Lâu"*). **TUYỆT ĐỐI KHÔNG** nói *"đăng ký kênh Tèo Kể"* (vì 'Tèo Kể' chỉ là hậu tố tiêu đề SEO `| Tèo Kể` và con dấu triện, không phải tên kênh).
   - **MẬT ĐỘ HÀNH ĐỘNG THỊ GIÁC (Visual Action Density - ADS):** Kịch bản phải chứa tối thiểu $\ge 15$ động từ hành động (`chem_kiem`, `dap_ban`, `hoc_mau`, `ban_cung`, `cuoi_ngua`, `chuong_phap`) để kích hoạt thư viện võ đạo `hanh_dong.gd`. Nghiêm cấm để cảnh tĩnh quá 8 giây.
   - `## kNN tên | ghi chú dựng {pre=… post=…}` mở một đoạn; `[id] lời` là một câu Tèo đọc. Viết cả bài, mỗi câu một dòng.
   - 6–8 đoạn lớn, mỗi đoạn 2,5–4 phút; muốn cắt nhỏ để dựng thì chia thêm `## kNN` (mẫu cũ `_lab/mau-godot-tap-01` có 30 khung). Không thẻ chương, không nói "Chương".
   - Đoạn đầu là **hook**: dựng riêng cảnh đắt nhất của kịch bản, khớp nhịp, khớp chữ thumbnail. Tèo giới thiệu theo vai trong khoảng 60 s đầu.
   - **Luật giữ chân 60 s đầu** (người dùng chốt 2026-10-24, đọc `__MUSE_ROOT__/ideas/HOOK-MO-DAU.md`):
     - Đoạn hook (`k01`) **≤ 5 câu, ≤ 35 s**. Tập 11 có 8 câu, kéo khoảng 1 phút.
     - Mỗi câu ≤ 15 chữ, ≤ 1 con số hoặc niên đại mỗi câu.
     - Diễn biến đầu tiên của câu chuyện bắt đầu **trước giây 45**.
     - Đoạn giới thiệu vai Tèo (`k02`) ≤ 3 câu, thể hiện bằng hành động. **Không** đặt tiểu sử tác giả, danh sách tác phẩm, giải nghĩa câu đối hay tên gọi vào phút đầu. Tập 11 có 27 câu như vậy ngay sau hook. Rải những thứ đó sau phút 3, mỗi lần ≤ 3 câu, đúng lúc nó giúp hiểu chuyện.
     - 3 tập cùng loạt (`yt-auto/series/teo-tuu-lau.json`) mở theo 3 kiểu khác nhau.
     - **Lời mời đầu video** (người dùng chốt 2026-11-05, bắt buộc): đặt **ngay sau đoạn hook ban đầu**: 1–2 câu đầu tiên của `k02`, trước phần Tèo giới thiệu vai. 1–2 câu ngắn (≤ 15 chữ/câu, tổng ≤ 8 s) gồm: mời mọi người **bình luận muốn Tèo làm về nhân vật / tác phẩm / ý tưởng nào**, và kêu gọi **like + đăng ký (theo dõi)** kênh. Viết theo giọng khung, không chép câu tập trước, Tèo hiện trên hình lúc nói. Không tính vào giới hạn 3 câu của `k02`; không đẩy diễn biến đầu tiên ra sau giây 45. gd-check báo lỗi nếu 3 câu đầu của đoạn ngay sau hook thiếu "bình luận", "like" hoặc "đăng ký"/"theo dõi".
   - CTA (đăng ký / bình luận) hai lần nữa ngoài lời mời đầu video: một ở 25–75%, một ở cuối, nói bằng giọng của khung.
   - Chữ hiện trên hình (thẻ, bảng, chú thích) phải có câu đọc đi kèm.
   - Điền `godot/story.json`: khung, teo_role, but (bút / kiểu nét), may_quay, palette, nhac, thumb, mat, font; `doan` ghi kiểu dựng của từng đoạn (mỗi đoạn một kiểu: tranh, bản đồ, sân khấu bóng, sổ tay, bàn cờ…); `seo` (title, mo_ta, `chan` = chân mô tả viết theo giọng của khung, mời bình luận/đăng ký theo kiểu của tập, tags).
4. **Giọng:** `gd-voice` (chạy thẳng, không qua `LOCK`; chạy nền nếu hàng Colab dài), giọng Tiến Đạt (`tiendat`) đọc bằng ZeroTTS. Sau đó `gd-check --no-godot`: biết tổng thời lượng thật. Dưới 20:00 thì viết thêm lời (thêm chủ đề phụ hoặc chi tiết), không kéo dài khoảng lặng.
5. **Nhân vật.**
   - Look lấy từ skill `nhan-vat-chibi`: chưa có thì tạo bằng skill đó và soi sheet. `godot/cast.json`: `{"tieu": {"char": "tieu-phong", "name": "Tiêu Phong"}}`; khoá khác cạnh `char` sẽ ghi đè.
   - Mặt riêng của tập: viết `<tap>/ve.mjs` (mắt, mũi, miệng theo bút của tập, khác tập trước), rồi `gd-mat`.
   - **Mặt tự sáng tạo theo nhân vật kịch bản dựng ra** (2026-10-22): không bốc từ bảng chọn hay băm id. Từng người: đọc vai, tuổi, tính cách, khoảnh khắc trong tập → thiết kế mắt, mày, mũi, miệng, nếp má, râu, sẹo, tóc mái cho đúng người đó. Ghi lý do vào `y-tuong.md` mục "Mặt nhân vật".
   - **Khuôn mặt chibi luôn tròn**: má đầy, cằm rộng bo tròn. Cấm cằm nhọn, mặt chữ V, mặt thon/xoan dài, hàm vuông, mặt dài. Phân biệt người bằng nét mặt, không bằng khuôn. Chi tiết ở teo-kiem-hiep mục "Mặt riêng từng tập".
   - Thân người tự vẽ trong GDScript theo nét của tập (mẫu cũ `_lab/mau-godot-tap-01`: `nguoi.gd` vẽ nét bút lông). Nhiều hoạt ảnh cơ thể: đi, chỉ tay, ôm quyền, ngã ngồi, quay đầu.
   - **Nhân vật luôn là dạng chibi** (người dùng quyết định 2026-10-21, thay luật "tập tự chọn tỉ lệ" cũ): đầu to, thân ngắn khoảng 2–3 đầu, tay chân ngắn, mắt to. Tập vẫn tự chọn nét bút, mặt và chất liệu theo khung (chibi nét mực, chibi rối bóng, chibi tượng gỗ…), nhưng tỉ lệ luôn chibi; không vẽ tỉ lệ người thật. Look (màu áo, tóc, râu) lấy từ sổ `nhan-vat-chibi`.
6. **Code hình.** Thay hết `phim.gd` (xóa dấu `CHUA_DUNG`) và thêm các file vẽ riêng của tập.
   - main.gd gọi `phim.setup(main)` một lần (có `main.segs`, `main.lines`, `main.DUR`), `phim.at(t, seg, line)` mỗi khung, `phim.sfx()` → `[[giây, "whoosh", dB], …]`.
   - Cách chia file và cấu trúc code do tập tự chọn theo khung (một file cho cả phim, mỗi đoạn một file, theo lớp cảnh, theo nhân vật…). Không lấy cấu trúc của tập trước làm sẵn.
   - **Không chép code hình của tập trước**, chỉ đọc để học.
   - **Diễn xuất nhân vật (đi, nói, thế võ, rút kiếm, chém, cầm ô/đèn/hồ lô…): tra skill `thao-tac-chibi`** (`data/thao-tac.md` + engine rig v2) và dùng lại thao tác hợp kịch bản; thiếu thì thiết kế mới rồi ghi sổ bên đó. Mặt/nét/nền vẫn riêng từng tập.
   - **Cảnh ra chưởng / đánh nhau: gọi skill `chuong-2d`** (Skill tool) cho từng chiêu, làm đủ quy trình của skill đó: thẻ chiêu, chống trùng `data/moves.json`, rule nhịp 5 đoạn, màu, SFX, `check.sh` soi sheet đến khi đạt checklist, ghi sổ. Không tự viết chiêu ngoài skill. Chiêu chưa đạt checklist của chuong-2d thì chưa đưa vào tập. Xong thì `gd-chieu <tap> <id>` đưa vào tập (tự ghi `story.chieu`). Trong `phim.gd`:
     ```gdscript
     var ch = preload("res://chuong/chieu.gd").new("can_khon", 312.0)   # chiêu bắt đầu ở giây 312 của tập; tham số 3 = dài (mặc định 12.5 s)
     ch.vars = {"subtitle": "…"}   # (tuỳ) đè biến của chiêu; ch.gain_db chỉnh tiếng sfx của chiêu (mặc định -8 dB)
     add_child(ch)                  # trong setup()
     # sfx(): trả thêm ch.sfx()      at(t): if ch.at(t): draw_texture_rect(ch.tex(), khung, false)
     ```
     Chiêu chạy trong SubViewport riêng (HDR + glow của chuong-2d), `at(t)` tự tua đúng khung nên `--from`/`--par` cắt giữa chiêu vẫn khớp. Khung đặt chiêu (toàn màn, trong khung tranh, chuyển cảnh vào/ra) do tập tự dựng theo bút của mình. Nhớ để lời Tèo nhường chỗ cho đoạn đỉnh của chiêu.
   - Sửa `main.gd` được (ví dụ máy quay đi giữa các khung như mẫu cũ `_lab/mau-godot-tap-01`), nhưng giữ hợp đồng ở dưới.
7. **Soát:** `gd-check <tap>` đến khi `OK`.
8. **Soi:** preview vài đoạn qua `LOCK` (chia 2 đoạn chạy song song nếu có 2 suất trống), mở `work/sheet-*.jpg` soi theo **Checklist**. Sửa rồi soi lại đúng đoạn đó.
9. **Nhạc:** tập tự sinh nhạc (`work/nhac.py` đọc `godot/timeline.json` để đổi tâm trạng theo khung). Ghi wav/raw rồi ffmpeg ra `godot/nhac.ogg` (soundfile ghi OGG dài bị tràn stack); ffmpeg Homebrew không có libvorbis thì dùng `-c:a vorbis -strict -2 -ac 2`. Không dùng nhạc có bản quyền; khác kiểu nhạc tập trước.
   **Người dùng chốt (2026-10-23): nhạc nền phải nhỏ hơn hẳn tiếng nhân vật, không có tiếng ù ù khó chịu** — không drone/bass/trống trầm dưới ~150 Hz, đặt `nhac.volume_db` sao cho nhạc thấp hơn giọng ≥ 15 dB (giọng ZeroTTS ~ -20 LUFS), gd-render còn hạ thêm khi có lời.
   **Âm nhạc nền kiếm hiệp (người dùng cập nhật 2026-11-06):** Cho phép kết hợp âm sắc **đàn gảy, đàn bầu (ngân luyến) và sáo trúc (tiếng tiêu/sáo trúc cổ phong nhẹ nhàng)** làm nhạc nền phù hợp với không khí kiếm hiệp. Vẫn giữ nguyên quy tắc an toàn: âm lượng nhỏ hơn hẳn giọng đọc (thấp hơn giọng ≥ 15 dB, nền ≤ -40 LUFS, gd-render tự ducking khi có lời), âm điệu êm dịu thanh thoát, tuyệt đối KHÔNG có tiếng chiêng, mõ, chuông, trống gõ giật mình hoặc SFX ồn ào.
   **Chốt thêm 2026-10-24 (luật chung `kit/lib/mix.mjs`):** gd-render tự đo nhạc và hạ để ≤ -40 LUFS (thấp hơn giọng ≥ 20 dB) dù `volume_db` đặt to hơn; sfx dùng bản êm của `kit/sfx` (gd-render tự chép đè vào `godot/sfx`), mỗi cue ≤ -4,4 dB, cả kênh lọc trầm < 180 Hz + chặn đỉnh -12 dBFS — không tiếng ùm ùm tùm tùm gây giật mình.
10. **Bản cuối:** `gd-render --par 2` qua `LOCK`, chạy nền. Xem vài giây ở đầu, giữa, cuối bằng ffprobe/ảnh để chắc có hình và tiếng.
11. **Ảnh bìa:** `godot/thumb.tscn` + `thumb.gd` vẽ bằng chính bút của tập, chạy có cửa sổ (không `--headless`): `Godot --path godot thumb.tscn`, lưu `thumb/thumb-godot.png`. Mở ảnh soi: mặt không bị che, chữ to đọc được, khớp hook. Theo luật chung `__MUSE_ROOT__/ideas/TIEU-DE-ANH-BIA.md` (người dùng chốt 2026-10-24):
   - **Một khối chữ chính 3–5 từ**, thêm tối đa một nhãn nhỏ. Tập thuộc một loạt (sổ loạt `yt-auto/series/teo-tuu-lau.json`) thì nhãn đó là **tên loạt, giống hệt ở cả 3 tập, cùng một vị trí**. Không dùng màu nền chung cho cả loạt, vì gd-check chặn palette và thumbnail giống tập cũ.
   - **Hình đắt nhất to nhất** (chiêu thức, binh khí, nhân vật chính mặt to và cảm xúc rõ), chiếm khoảng 1/4 đến 1/2 khung. Không nhét 3 nhân vật nhỏ ngang nhau.
   - Góc dưới bên phải không có chữ, vì ô thời lượng của YouTube che chỗ đó.
   - **Soi ở cỡ điện thoại:** `sips -Z 360 thumb/thumb-godot.png --out work/thumb-phone.png` rồi Read ảnh đó. Không đọc được chữ trong 1 giây thì làm lại.
   - Chữ hoặc hình trên ảnh bìa phải được nhắc lại trong **30 giây đầu** của hook.
   - **Tiêu đề (`seo.title`): làm đủ 4 bước của `__MUSE_ROOT__/ideas/TIEU-DE-ANH-BIA.md` mục 1:**
     > **LUẬT CỨNG: MỖI VIDEO TỰ ĐI TÌM TÊN CỦA RIÊNG NÓ.** Video dài và **từng short** đều phải tự tìm trên YouTube (`tu-khoa.py`, video dài thêm `kiem-hang.py`) với tên neo của chính nó, rồi chọn tên dễ được tìm thấy nhất. Không chép tên hay kết quả tìm kiếm của video khác, không đặt tên theo cảm tính. Ghi lại cụm đã tìm, điểm, mức cạnh tranh và tên đã chọn của từng video.
     1. `python3 __MUSE_ROOT__/yt-auto/tools/tu-khoa.py "<nhân vật / nhóm>" "<nhân vật + tác phẩm>" "<chủ đề loạt>"` (bỏ gợi ý trùng tên / game bằng `--bo=…`). Lấy cụm điểm cao nhất mà đúng nghĩa, giữ nguyên thứ tự chữ. Gõ cả tên gọi khác của nhân vật (Kiều Phong / Tiêu Phong…) rồi lấy tên được gõ nhiều hơn.
     2. Đọc mục "Người xem đang hỏi gì" (chết, bị giết, ai mạnh hơn, có thật không…). Tiêu đề trả lời thẳng câu cao điểm nhất mà tập trả lời được. Ví dụ "giang nam thất quái bị giết" đứng đầu, nhưng tiêu đề "7 Thầy, 18 Năm Giữ Lời" bỏ lỡ câu đó.
     3. `python3 __MUSE_ROOT__/yt-auto/tools/kiem-hang.py "<cụm>"`. Gặp KHÓ thì đổi sang cụm dài và hẹp hơn.
     4. Viết theo khuôn **`<Cụm Từ Khoá>: <Lời Hứa Cụ Thể>`**:
        - Không mở đầu bằng ẩn dụ của khung dựng ("Mặt Nạ Quân Tử", "Bảy Đêm Canh Lửa"…); ẩn dụ để cho ảnh bìa.
        - Viết Hoa Từng Chữ, không viết HOA toàn bộ, không emoji. Chữ trên ảnh bìa khác tiêu đề.
        - ≤ 51 ký tự, không cần ghi đuôi: pack tự gắn `| Tèo Kể` (đuôi lỡ ghi sẵn thì nó tự bỏ). gd-check chặn khi quá 60 ký tự sau khi gắn đuôi, có emoji hoặc viết HOA toàn bộ.
        - Tên neo yếu (ít gợi ý, vd. Thành Côn) thì ghép với tên mạnh hơn và đặt tên mạnh lên trước.
        - Nhãn "(Phần N/3)" CHỈ dùng khi các tập nối tiếp nhau về nội dung; loạt mà mỗi tập một nhân vật / chuyện riêng thì không đánh số phần.
        - Nếu có 3 phương án thì là 3 góc khác hẳn nhau, mỗi phương án vẫn mở bằng một cụm từ khoá.
        - Cụm đúng nghĩa khác đưa vào `seo.tags`. Ghi cụm đã chọn, điểm và mức cạnh tranh vào ghi chú của tập.
     5. Sau khi đăng ≥ 3 ngày, `kiem-hang.py --da-dang` ghi vị trí tìm kiếm vào `yt-auto/logs/hang.jsonl`; đọc file này trước khi đặt tiêu đề cho loạt mới.
12. **Gói:** `pack.mjs <tap>`, đọc lại `youtube/thumbnail.png`. Rồi `gd-check <tap> --log` để ghi sổ, và thêm một dòng vào `__MUSE_ROOT__/ideas/DA-LAM.md` (mảng "Tèo kiếm hiệp"). Không đăng lên mạng.

13. **BỎ TẠO SHORTS (người dùng chốt 2026-10-29):** KHÔNG làm Shorts (bỏ mọi bước short: kịch bản short, giọng short, dựng short, render short). `yt-auto` đã đặt `min_shorts = 0` và `"tat_shorts": true`, gói `youtube/` chỉ cần video dài + thumbnail.png + tieu-de.txt + mo-ta.txt + tags.txt là đủ chuẩn để đồng bộ lên Drive và tự động đăng.

## Gói trên Google Drive (tự động, không làm tay)

- Job `yt-sync` (15 phút/lần, `__MUSE_ROOT__/yt-auto`) tự chép `kiem-hiep/<tap>/youtube/` lên **`My Drive/TeoTuuLau/<tap>/`** khi đủ video dài + 3 Shorts, rồi xoá `youtube/` trên máy. Không chép tay, không dùng thư mục `TeoKenhYoutube` (thư mục đó chỉ của kênh Lại Là Tèo Đây).
- Khi `yt-auto` hẹn giờ xong video dài, thư mục được đổi tên thành **`<YYYY-MM-DD HHhMM> <tap>`** (giờ đăng video dài, vd. `2026-10-28 19h00 tap-15-nhac-bat-quan`). Đăng hết thì chuyển sang `My Drive/DaDang/teo-tuu-lau/`, giữ nguyên tên.
- Tên `kiem-hiep/<tap>` trên máy vẫn là tên trần, không tự thêm giờ. Khi xem một tập đã lên Drive / đã đăng chưa, tìm thư mục tên `<tap>` **hoặc kết thúc bằng ` <tap>`** ở `TeoTuuLau` và `DaDang/teo-tuu-lau`.
- Sửa gói sau khi đã lên Drive (ảnh bìa, short…): sửa và `pack.mjs` lại trong `kiem-hiep/<tap>/`, `yt-sync` tự chép đè vào đúng thư mục đã đổi tên.

## Shorts dọc (3 short mỗi tập, 1080×1920, ≤ 60 s)

Mỗi short là **một project Godot dọc riêng** ở `<tap>/shorts/<NN-ten>/godot/`. Nó dùng lại bút, mặt, font, chiêu và giọng của tập, nhưng hình phải **dựng lại cho khung dọc**: không cắt, không crop từ bản ngang. Các lệnh gd-voice, gd-check, gd-render, pack chạy thẳng trên thư mục short (`S = <tap>/shorts/<NN-ten>`).

| lệnh | việc |
|---|---|
| `node SKILL/scripts/new-short.mjs <tap> <NN-ten> --tu kA-01..kB-05 [--tu …] [--nhac <giây>]` | Tạo `S/godot/` dọc 1080×1920. Chép font/, mat/, chars/, chuong/, sfx/, các file vẽ `.gd` của tập (trừ main/phim/thumb) và cast.json. Câu `--tu` vào `loi.txt` (đoạn `s02 than`) kèm wav và voice.json, nên không phải đọc lại. Có sẵn chỗ viết hook `s01` và kết `s03`. Thêm `story.json` (kieu, phu_de, seo), `phude.gd` (phụ đề 2–4 chữ, y≈1490) và `nhac.ogg` cắt 70 s từ nhạc tập (mặc định 10 s trước câu đầu). |
| `node KH/scripts/gd-voice.mjs S` (không qua LOCK) | Chỉ đọc câu mới hoặc câu đã sửa chữ. |
| `node SKILL/scripts/gd-check.mjs S` | Chế độ short (tự nhận theo khung dọc). **Lỗi:** quá 60 s, thiếu "đăng ký" trong 30% cuối, kieu trống hoặc giống short khác của tập ≥60%, title quá 60 ký tự sau khi gắn đuôi (không tính #Shorts), có emoji hoặc viết HOA toàn bộ, thiếu mo_ta. **Cảnh báo:** hook > 12 chữ, hook dài > 12 s, thiếu tên kênh "Tèo Tửu Lâu", dưới 20 s. Không dùng `--log`. |
| `LOCK "<tap> sNN xem" node KH/scripts/gd-render.mjs S --preview --sheet 2` | Preview 540×960 + `S/work/sheet-preview.jpg`. |
| `LOCK "<tap> sNN render" node KH/scripts/gd-render.mjs S` | `S/renders/final.mp4` 1080×1920. Short ngắn, không cần `--par`. |
| `node SKILL/scripts/pack.mjs S` | Kiểm 1080×1920, ra `<tap>/youtube/shorts/<NN-ten>.mp4` + `.txt` (tiêu đề `#Shorts`, mô tả + hashtag, tag, link bản đầy đủ). Không cần ảnh bìa. |

**Quy trình short:**

1. **Chọn 3 đoạn** đắt nhất của tập, mỗi short **một kiểu khác nhau**: một chiêu chưởng trọn vẹn, một bí mật hay chi tiết ít ai biết, một con số, một cuộc đối đầu hay cãi nhau, một câu thoại… Ghi vào `story.kieu`. Mỗi đoạn phải tự đứng được: người xem short chưa xem tập.
2. `new-short.mjs` với `--tu` là các câu của đoạn đó. Tổng giọng ≈ 35–50 s là vừa; bỏ bớt câu nếu dài.
3. **Lời** (`S/godot/loi.txt`):
   - `[s01-01]` hook ≤ 12 chữ, vào thẳng điểm đắt.
   - Câu nối hoặc giới thiệu lại tên người, tên môn võ nếu đoạn cắt giữa chừng. Viết câu mới thay câu tập bắt đầu bằng "Còn…", "Vì thế…" trơ trọi.
   - `[s03-01]` kết một câu, có "đăng ký" và "Tèo Tửu Lâu" (kèm triện "Tèo Kể").
   - Điền `story.json`: kieu, seo.title (≤ 51 ký tự, không ghi đuôi: pack tự gắn " #Shorts | Tèo Kể"; Viết Hoa Từng Chữ; **mỗi short tự tìm tên riêng** (luật cứng ở bước tiêu đề): chạy `__MUSE_ROOT__/yt-auto/tools/tu-khoa.py` với tên neo của đoạn short, đặt cụm đúng nghĩa ngay đầu tiêu đề), mo_ta, tags. Sửa `phu_de` (font, cỡ, màu) theo bút của tập nếu cần.
4. Chạy `gd-voice` (không qua LOCK), rồi `gd-check S`.
5. **Viết `S/godot/phim.gd` dọc**, dùng các hàm vẽ của tập (mẫu cũ `_lab/mau-godot-tap-01`: `But`, `Canh`, `Nguoi`). Lấy giờ từng câu ở `main.lines` (id → t0, dur) để hình khớp lời.
   - Vùng hình y 190–1350. Dưới y 1350 để trống cho phụ đề và nút của Shorts; mép phải cũng để thoáng.
   - **Trong 1–2 s đầu phải có hình đắt nhất, khung không được trống.** Hook có cú chốt, ví dụ triện đóng xuống.
   - Một ý hình xuyên suốt short (short cũ `tap-01/_ban-cu/shorts/01-muoi-tam-chuong`: rồng 28 vảy rụng dần thành 18 rồi 12). Nhân vật chibi của tập to, có cử động.
   - Cảnh kết có Tèo, triện "Tèo Kể" và nút ĐĂNG KÝ.
   - Muốn có chưởng thì gọi chiêu đã có bằng `preload("res://chuong/chieu.gd")` như ở tập, đặt chiêu vào khung dọc.
6. Preview `--sheet 2`, soi theo checklist dưới, sửa rồi chạy lại. Xong thì render bản cuối, `pack.mjs S`, kiểm mp4 1080×1920 có tiếng. Không đăng.

**Checklist short:** hook có hình đắt ngay giây đầu · hình không chạm vùng phụ đề và nút (dưới y 1350, mép phải) · phụ đề đọc được, không đè mặt · hình khớp đúng câu đang đọc · 3 short của tập khác kiểu, khác ý hình · ≤ 60 s · kết có Tèo + đăng ký + Tèo Tửu Lâu (triện góc "Tèo Kể").

## Hợp đồng với gd-render (main.gd sinh sẵn đã đúng)

- Cửa sổ 1920×1080 (short dọc: 1080×1920, `new-tap.mjs --doc`), stretch `canvas_items` (để `--preview` thu nhỏ được).
- Đọc `--from=` `--to=`; dựng mọi thứ **theo giờ t**, không phụ thuộc khung trước (để nhảy thẳng tới `--from` và chia `--par`).
  Hạt / ngẫu nhiên: dùng hàm băm theo t hoặc `RandomNumberGenerator` seed cố định, gieo lại theo t.
- Chạy với `-- --dur` thì in `DUR=<giây>`, ghi `timeline.json` rồi thoát.
- Giọng / nhạc / sfx phát bằng `AudioStreamPlayer`; bắt đầu giữa chừng thì `play(offset)`.
- Tự `get_tree().quit()` khi t ≥ to hoặc hết phim.

## Lỗi Colab TTS đã gặp và cách xử lý (2026-10-22)

Từ 2026-11-03 phiên Colab cài ZeroTTS (`setup-zerotts.py`, dấu `/content/.zerotts_ready`) thay VieNeu; các lỗi phiên/treo/khoá dưới đây vẫn y như cũ. Lỗi riêng của ZeroTTS: báo `voice '<giọng tự nạp>' not found` thì giọng chưa lên phiên (giọng có sẵn như `tiendat` thì không cần gửi) — giọng phải nằm ở `/root/.zerotts/voices/<id>/` (colab-tts upload mỗi lần từ `~/.zerotts/voices`), không đặt `ZEROTTS_VOICES_HOME` trong synth vì kernel đã import zerotts lúc cài.

`colab-tts.mjs` đã tự xử lý hai lỗi đầu. Lỗi chưa tự xử lý được thì làm tay theo bảng. Gọi colab từ Git Bash cần `MSYS_NO_PATHCONV=1 PYTHONUTF8=1`.

| triệu chứng | nguyên nhân | xử lý |
|---|---|---|
| Một mẻ đứng lâu không in gì, thư mục `/content/out/<mẻ>` đã có zip hoặc chưa có | `colab exec` phía máy nhà treo dù phiên vẫn rảnh | Tự động: mọi lệnh colab có hạn giờ đều chạy qua `colab-tts/run-timeout.mjs`; quá 8 phút thì nó `taskkill /T` cả cây (colab.exe → python), rồi gửi lại, tối đa 4 lần. Không dùng timeout của spawnSync (chỉ giết colab.exe, python con vẫn treo), cũng không dùng powershell canh giờ tách riêng (không chạy được ở máy này). Làm tay: tìm `colab.exe exec … JOB=<mẻ>` trong Win32_Process rồi Stop-Process; colab-tts gửi lại. |
| Lệnh treo ngay ở bước dò phiên (probe), hoặc báo `RuntimeError: Connection was lost` | Phiên `tts` đứt kết nối (phiên chết nhưng vẫn còn tên) | Tự động (qua run-timeout.mjs): dò quá 2 phút hoặc thấy chữ đó thì `colab stop -s tts`, rồi `colab new -s tts --gpu T4` + setup.py (khoảng 2–3 phút). Làm tay: `colab.exe stop -s tts`, giết tiến trình probe, rồi chạy lại gd-voice. |
| Mỗi short chờ thêm 3–5 phút "tạo phiên GPU T4… cài ZeroTTS" | Job trước xong là tắt phiên ngay (cả `colab-kokoro.mjs` tiếng Anh dùng chung phiên `tts`) | Đã sửa trong colab-tts: xong job thì **thoát ngay**, một tiến trình nền (`--reap`, log `colab-tts/.reap.log`) giữ phiên và chỉ tắt khi 15 phút liền không job nào gọi Colab (phiên Colab tắt là mất bản cài, không cài cố định được). Người dùng chốt 2026-10-23: **không đặt `COLAB_TTS_GRACE`** khi gọi gd-voice (để mặc định 15) — job không còn đứng chờ nên không có lý do hạ xuống. colab-kokoro (tiếng Anh, người dùng cho sửa 2026-10-22) cũng giữ phiên 15 phút và có hạn giờ + thử lại y như colab-tts. |
| Phiên đứt **giữa lúc đang đọc** một mẻ | Như trên nhưng đã qua bước dò | Tự xử lý một phần: mẻ treo 8 phút mỗi lần, hết 4 lần thì báo lỗi, gd-voice dừng (không lùi về máy nhà). Thấy log lặp "treo quá 8 phút" thì `colab stop -s tts` tay để lần sau tạo phiên mới. |
| Báo `Session 'tts' appears to be lost (404/401)` rồi `Session 'tts' not found` giữa một mẻ | Colab thu hồi phiên GPU giữa chừng | Tự động, **người dùng chốt 2026-11-03: Colab thu hồi phiên GPU (hoặc không tạo được phiên GPU mới) thì dùng CPU máy nhà** — colab-tts thoát mã 75, gd-voice / make.mjs / voice.mjs đọc nốt (và căn chữ) bằng CPU máy nhà qua luật chung `colabThenLocal` trong `kit/lib/mix.mjs` (mọi chỗ gọi Colab đọc giọng / căn chữ phải đi qua hàm này); mẻ đã tải về có cache nên không đọc lại. Lỗi Colab khác vẫn dừng như cũ. |
| Mọi tập đứng ở "phiên Colab đang bận job khác, chờ…" | Một job khác giữ `.lock` (kể cả bản đọc Kokoro tiếng Anh `kit/colab-en`, và căn chữ `colab-tts.mjs --align` của video-teo từ 2026-10-23 — cùng phiên + cùng khoá) hoặc job đã chết mà khoá còn | Xem `kiem-hiep/_tools/colab-tts/.lock/pid`: pid không còn chạy thì xoá `.lock`. Khoá cũ hơn 3 giờ tự bị bỏ. |
| Hỏi đăng nhập / token hết hạn | OAuth hết hạn | Mở tab terminal chạy `colab sessions`, **người dùng tự dán mã**. Không nhập mã thay. |

- Tốc độ bình thường: khoảng 4–5 phút giọng cho một tập 20 phút. Phiên là một hàng đợi chung, 9 tập thì xếp nối nhau.
- Người dùng muốn đọc giọng trên Colab: Colab lỗi thì sửa Colab (bảng trên), **đừng tự chuyển sang `--local`/GPU máy nhà**.
- Xong hết việc: `node kiem-hiep/_tools/colab-tts/colab-tts.mjs --stop` để tắt phiên, kiểm `.wait/` trống.

## Bẫy GDScript / Godot đã gặp

- Lấy giá trị từ Array / Dictionary thì khai kiểu rõ: `var x: float = arr[i]` (`:=` với Variant gây parse error).
- Lỗi parse chỉ hiện từng lỗi một: sửa xong chạy lại `gd-check`. Không khai nhiều biến trên một dòng (`var a := 1, b := 2` là parse error).
- **Font do tập tự chọn** theo bút (chép file .ttf vào `godot/font/`, ghi tên vào `story.font`, khác tập trước). Phải có đủ dấu tiếng Việt: thử in "Tiêu Phong ưởng ỹ Ỗ" trước khi dùng. Font chữ nét (Palatino…) thường thiếu ↑ ↓ ✕ ✓: dùng "»" hoặc chữ. Nguồn: `/System/Library/Fonts`, `/Library/Fonts`, `~/Library/Fonts`, Google Fonts (OFL).
- sfx thư viện: `godot/sfx/lib-<tên>.mp3`, gọi bằng tên `<tên>` trong `phim.sfx()`.
- Preview chạy khoảng 2× thời gian thật; render bản cuối 20 phút mất cỡ 40–60 phút với `--par 2`.
- `draw_*` không có bộ lọc: bóng / nhòe tự vẽ bằng nhiều lớp alpha thấp; nhiều node `Line2D` nặng hơn vẽ thẳng trong `_draw`.

## Checklist soi sheet

- [ ] Đoạn đầu là hook dựng riêng (không phải màn tiêu đề); Tèo hiện hình theo vai sớm.
- [ ] Ngay sau hook có lời mời bình luận chọn chủ đề + like + đăng ký, Tèo hiện trên hình lúc nói.
- [ ] Mỗi đoạn một kiểu dựng khác hẳn (không chỉ đổi màu nền); hình khớp đúng câu đang đọc.
- [ ] Mỗi cảnh ra chưởng làm bằng skill `chuong-2d`, đã đạt checklist và có trong `chuong-2d/data/moves.json`.
- [ ] Nhân vật đọc được trên nền; mặt là mặt riêng của tập; có cử động cơ thể, không đứng đơ.
- [ ] Chữ trên hình ngắn (≤12 chữ), to, không đè mặt; có câu đọc đi kèm.
- [ ] Không thẻ chương, không chữ "Chương".
- [ ] Màu và bút giữ một chất suốt video (một bộ bút riêng của tập).
- [ ] Chiêu thức (nếu có) có tụ khí → đòn → hậu quả, đối thủ "thua" chỉ lùi / choáng, không bị hạ nhục.
- [ ] `gd-check` OK; khung, vai Tèo, bút, máy quay, palette, nhạc, thumbnail, mặt, font, chân mô tả khác các tập trong history.json.
