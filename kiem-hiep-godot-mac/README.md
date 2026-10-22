# Bộ cài `teo-kiem-hiep-godot` cho macOS

Skill Claude Code để làm một tập **Tèo Kể Kiếm Hiệp** (≥20 phút, giọng Lóng), dựng toàn bộ bằng **Godot 2D**,
kèm 3 Shorts dọc. Chỉ chạy trong **Claude Code** (CLI hoặc tab Code của app Claude), không chạy trong chat claude.ai.

## Trong gói có gì

| Thư mục | Nội dung |
|---|---|
| `skills/teo-kiem-hiep-godot` | quy trình tập Godot: new-tap, new-short, gd-chieu, gd-check, pack, sổ chống lặp `data/history.json` |
| `skills/teo-kiem-hiep` | luật nội dung, chủ đề (`data/chu-de.md`), gd-voice / gd-mat / gd-render |
| `skills/chuong-2d` | engine chiêu/chưởng Godot + sổ chiêu `data/moves.json` |
| `skills/nhan-vat-chibi` | sổ nhân vật chung `data/chars.json` + sheet soi |
| `skills/thao-tac-chibi` | sổ động tác + rig chibi v2 |
| `MuseStudio/kit` | sfx, `py/tts.py` (VieNeu tại máy) |
| `MuseStudio/kiem-hiep/_tools` | `slot.sh` (2 suất máy), `colab-tts/` (đọc giọng trên Colab T4) |
| `MuseStudio/kiem-hiep/tap-10…`, `_lab/…` | tập mẫu, **chỉ có code + hình** (không giọng/nhạc/video), để đọc học |
| `MuseStudio/ideas/DA-LAM.md` | danh sách đã làm |
| `vieneu/` | giọng clone "Lóng" → `~/.vieneu/` |
| `memory/` | luật làm tập (mặt tròn, chibi, không chương, CTA…) → memory của Claude Code cho thư mục MuseStudio |

## Cài đặt

1. Cài công cụ (cần [Homebrew](https://brew.sh)) và Claude Code (https://claude.com/claude-code):
   ```bash
   brew install node ffmpeg git uv
   ```
   Muốn soi sheet nhân vật (`nhan-vat-chibi`) thì cần **Google Chrome** trong `/Applications`.
2. Tải về (repo private, cần được mời vào repo) rồi chạy installer trong Terminal:
   ```bash
   git clone https://github.com/ngovanhai/skill-video-teo.git
   cd skill-video-teo/kiem-hiep-godot-mac
   node install.mjs
   ```
   Khi có bản mới: `git pull` rồi chạy lại `node install.mjs` (skill cũ được giữ lại thành `*.bak-<giờ>`).
   Script sẽ:
   - tải **Godot 4.7.2** bản macOS vào `~/Applications/Godot_v4.7.2.app` (nếu chưa có đúng bản này);
   - chép MuseStudio vào `~/MuseStudio`, 5 skill vào `~/.claude/skills/` (bản cũ trùng tên đổi thành `*.bak-<giờ>`);
   - cài VieNeu-TTS vào `~/VieNeu-TTS` (đọc dự phòng khi Colab lỗi) + giọng Lóng vào `~/.vieneu/`;
   - cài `colab` CLI (`uv tool install google-colab-cli`);
   - điền đường dẫn thật, ghi `MUSE_ROOT`, `VIENEU_DIR`, `GODOT` vào `~/.zshrc`, chép memory luật làm tập.

   Tuỳ chọn: `--muse-root <thư mục>`, `--vieneu-dir <thư mục>`, `--godot <đường dẫn binary Godot>`,
   `--skip-vieneu`, `--skip-colab`, `--no-env`, `--no-memory`.
3. Mở terminal **mới**, đăng nhập Colab một lần (dán mã Google): `colab sessions`
4. `cd ~/MuseStudio && claude`, rồi gõ `/teo-kiem-hiep-godot` (vd "làm tập kiếm hiệp Godot về …").

## Lưu ý

- Render Godot dùng Movie Maker nên **mở cửa sổ Godot** khi chạy (không headless): để máy ở trạng thái đã đăng nhập, không khoá màn hình.
- Mac không có DirectML: giọng đọc mặc định chạy trên Colab; Colab lỗi thì lùi về CPU của Mac (chậm hơn, vẫn ra).
- `teo-kiem-hiep-godot/data/history.json`, `chuong-2d/data/moves.json`, `teo-kiem-hiep/data/chu-de.md` mang lịch sử các tập đã làm
  để chống trùng. Nếu dùng chung một kênh thì giữ nguyên; muốn đồng bộ lại thì chép các file này qua lại giữa hai máy.
- Font: SKILL nói chọn font theo bút của tập — trên Mac lấy ở `/System/Library/Fonts`, `/Library/Fonts`, `~/Library/Fonts` hoặc Google Fonts; nhớ thử dấu tiếng Việt.
- Giọng "Lóng" là giọng riêng của kênh Tèo Kể. Không chia sẻ ra ngoài.
