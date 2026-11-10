# Bộ cài `teo-kiem-hiep-godot` cho macOS

Skill Claude Code để làm một tập **Tèo Kể Kiếm Hiệp** (≥20 phút, giọng **Tiến Đạt** đọc bằng **ZeroTTS**), dựng toàn bộ bằng **Godot 2D**.
Không làm Shorts. Chỉ chạy trong **Claude Code** (CLI hoặc tab Code của app Claude), không chạy trong chat claude.ai.

## Trong gói có gì

| Thư mục | Nội dung |
|---|---|
| `skills/teo-kiem-hiep-godot` | quy trình tập Godot: new-tap, new-short, gd-chieu, gd-check, pack, sổ chống lặp `data/history.json` |
| `skills/teo-kiem-hiep` | luật nội dung, chủ đề (`data/chu-de.md`), gd-voice / gd-mat / gd-render |
| `skills/chuong-2d` | engine chiêu/chưởng Godot + sổ chiêu `data/moves.json` |
| `skills/nhan-vat-chibi` | sổ nhân vật chung `data/chars.json` + sheet soi |
| `skills/thao-tac-chibi` | sổ động tác + rig chibi v2 |
| `skills/kiem-tra-video` | soát 5 tầng: review kịch bản, smoke test 15 s, check hình/âm thanh, quality gate `youtube/.READY_TO_UPLOAD` |
| `skills/hoat-anh-kich-ban` | kịch bản → storyboard + mã hoạt cảnh Godot (vũ đạo hành động chibi) |
| `skills/tim-chu-de-ke` | tìm chủ đề mới bằng cách ké video đang lên, chống trùng |
| `../MuseStudio/kit` | (lấy từ bộ root) fx, sfx êm, font, nhạc nền, `lib/mix.mjs`, `py/tts-zerotts.py` (ZeroTTS tại máy) |
| `MuseStudio/kiem-hiep/_tools` | `slot.sh` (2 suất máy), `colab-tts/` (đọc giọng + căn chữ trên Colab T4) |
| `MuseStudio/kiem-hiep/tap-10…`, `tap-01…/_ban-cu`, `_lab/…` | tập mẫu, **chỉ có code + hình** (không giọng/nhạc/video), để đọc học |
| `MuseStudio/ideas/` | `DA-LAM.md` (đã làm), `HOOK-MO-DAU.md`, `TIEU-DE-ANH-BIA.md` (luật hook, tiêu đề, ảnh bìa) |
| `MuseStudio/yt-auto/tools/` | `tieu-de.mjs`, `tu-khoa.py`, `kiem-hang.py` (luật tiêu đề, từ khoá, độ cạnh tranh) |
| `memory/` | luật làm tập (mặt tròn, chibi, không chương, CTA…) → memory của Claude Code cho thư mục MuseStudio |

## Cài đặt

1. Cài công cụ (cần [Homebrew](https://brew.sh)) và Claude Code (https://claude.com/claude-code):
   ```bash
   brew install node ffmpeg git uv
   ```
   Muốn soi sheet nhân vật (`nhan-vat-chibi`) thì cần **Google Chrome** trong `/Applications`.
2. Tải **cả repo** về (bộ này dùng chung `MuseStudio/kit` với bộ root) rồi chạy installer trong Terminal:
   ```bash
   git clone https://github.com/ngovanhai/skill-video-teo.git
   cd skill-video-teo/kiem-hiep-godot-mac
   node install.mjs
   ```
   Khi có bản mới: `git pull` rồi chạy lại `node install.mjs` (skill cũ được giữ lại thành `*.bak-<giờ>`).
   Script sẽ:
   - tải **Godot 4.7.2** bản macOS vào `~/Applications/Godot_v4.7.2.app` (nếu chưa có đúng bản này);
   - chép MuseStudio vào `~/MuseStudio`, 5 skill vào `~/.claude/skills/` (bản cũ trùng tên đổi thành `*.bak-<giờ>`);
   - cài **ZeroTTS** vào `~/Projects/ZeroTTS-src/.venv` (`uv pip install zerotts==0.1.5`; weights tự tải từ HuggingFace, hoặc dùng bản int8 nếu thư mục `models/zerotts-int8` có sẵn);
   - cài `colab` CLI (`uv tool install google-colab-cli`);
   - điền đường dẫn thật, ghi `MUSE_ROOT`, `ZEROTTS_DIR`, `GODOT` vào `~/.zshrc`, chép memory luật làm tập.

   Tuỳ chọn: `--muse-root <thư mục>`, `--zerotts-dir <thư mục>`, `--godot <đường dẫn binary Godot>`,
   `--skip-zerotts`, `--skip-colab`, `--no-env`, `--no-memory`.
3. Mở terminal **mới**, đăng nhập Colab một lần (dán mã Google): `colab sessions`
4. `cd ~/MuseStudio && claude`, rồi gõ `/teo-kiem-hiep-godot` (vd "làm tập kiếm hiệp Godot về …").

## Lưu ý

- Render Godot dùng Movie Maker nên **mở cửa sổ Godot** khi chạy (không headless): để máy ở trạng thái đã đăng nhập, không khoá màn hình.
- Mac không có DirectML: giọng đọc mặc định chạy trên Colab; Colab lỗi thì lùi về CPU của Mac (chậm hơn, vẫn ra).
- `teo-kiem-hiep-godot/data/history.json`, `chuong-2d/data/moves.json`, `teo-kiem-hiep/data/chu-de.md` mang lịch sử các tập đã làm
  để chống trùng. Nếu dùng chung một kênh thì giữ nguyên; muốn đồng bộ lại thì chép các file này qua lại giữa hai máy.
- Font: SKILL nói chọn font theo bút của tập — trên Mac lấy ở `/System/Library/Fonts`, `/Library/Fonts`, `~/Library/Fonts` hoặc Google Fonts; nhớ thử dấu tiếng Việt.
- Giọng đọc là **Tiến Đạt** (`"voice": "tiendat"`), giọng có sẵn của ZeroTTS — không cần tải mẫu giọng nào.
