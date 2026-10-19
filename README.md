# Bộ skill Tèo: `video-teo` + `teo-kiem-hiep`

Hai skill cho **Claude Code**, dùng để làm video YouTube kênh Tèo:
- `video-teo`: video dài từ 20 phút trở lên, có giọng Tèo, phụ đề, thumbnail và gói upload.
- `teo-kiem-hiep`: tập kiếm hiệp hoạt hình (HyperFrames + GSAP), đọc bằng giọng VieNeu "Lóng".

> Hai skill này chạy trên máy của bạn: giọng đọc, render và ffmpeg đều chạy tại máy.
> Vì vậy **không dùng được trong chat claude.ai**, chỉ dùng được trong **Claude Code** (CLI hoặc tab Code của app Claude).

## Trong gói có gì

| Thư mục | Nội dung |
|---|---|
| `skills/` | 2 skill, được chép vào `~/.claude/skills/` |
| `MuseStudio/kit` | công cụ dựng video (`make.mjs`, cảnh, fx, font, nhạc nền, sfx) |
| `MuseStudio/avatar` | avatar, banner, watermark của kênh |
| `vieneu/` | giọng clone "Lóng", được chép vào `~/.vieneu/` |

## Cài đặt (macOS hoặc Windows)

1. Cài các công cụ cần có. Bỏ qua cái nào máy đã có:
   - **macOS** (cần [Homebrew](https://brew.sh)):
     ```bash
     brew install node ffmpeg git uv
     ```
   - **Windows** (PowerShell):
     ```powershell
     winget install OpenJS.NodeJS.LTS Gyan.FFmpeg Git.Git astral-sh.uv
     ```
   Cài thêm Claude Code: https://claude.com/claude-code (đăng nhập bằng tài khoản Team).
2. Giải nén `teo-skills.zip`, mở Terminal (Mac) hoặc PowerShell (Windows) trong thư mục `teo-skills` và chạy:
   ```bash
   node install.mjs
   ```
   - `--muse-root <thư mục>`: nơi đặt kit và thư mục video. Mặc định là `~/MuseStudio` (Mac) hoặc `C:\Users\<tên>\MuseStudio` (Windows).
   - `--vieneu-dir <thư mục>`: nơi cài VieNeu-TTS. Mặc định là thư mục `VieNeu-TTS` nằm cạnh MuseRoot.
   - `--gpu`: dùng khi máy Windows có card NVIDIA, đọc giọng nhanh hơn khoảng 25 lần. Mac không cần cờ này.
   - `--skip-vieneu`: dùng khi máy đã có VieNeu-TTS.
3. Mở terminal **mới**, `cd` vào MuseRoot, chạy `claude` rồi gõ `/video-teo` hoặc `/teo-kiem-hiep`.

Script cài sẽ thay `__MUSE_ROOT__` / `__VIENEU_DIR__` / `__WHISPER_PY__` trong skill và kit bằng đường dẫn thật của máy bạn. Script cũng đặt 2 biến môi trường `MUSE_ROOT` và `VIENEU_DIR`: trên Windows dùng `setx`, trên Mac ghi vào `~/.zshrc`. Nếu Python của máy chưa có whisper, script tạo venv riêng ở `MuseRoot/.whisper`. Nếu máy đã có skill cùng tên, bản cũ được đổi tên thành `*.bak-<giờ>`.

## Lưu ý

- Lần đầu render, `npx hyperframes@0.8.172` sẽ tự tải trình duyệt headless nên cần có mạng.
- Không có GPU NVIDIA (kể cả Mac) thì giọng đọc chạy bằng CPU: chậm hơn nhiều, nhưng vẫn ra kết quả. Mac chip M chạy tương đối ổn.
- `teo-kiem-hiep/data/chu-de.md` có đánh dấu `(tập N)` cho các chủ đề đã làm. Nếu dùng chung một kênh thì giữ nguyên để không làm trùng chủ đề.
- Giọng "Lóng" là giọng riêng của kênh Tèo Kể. Chỉ dùng cho kênh này, không chia sẻ ra ngoài nhóm.
