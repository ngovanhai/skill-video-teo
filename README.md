# Bộ skill Tèo: `video-teo` + `teo-kiem-hiep` + `teo-kiem-hiep-godot` + `chuong-2d` + `nhan-vat-chibi` + `thao-tac-chibi`

Bộ skill cho **Claude Code**, dùng để làm video YouTube kênh Tèo:
- `video-teo`: video dài từ 20 phút trở lên, có giọng Tèo, phụ đề, thumbnail và gói upload.
- `teo-kiem-hiep`: tập kiếm hiệp hoạt hình (HyperFrames + GSAP), đọc bằng giọng VieNeu "Lóng".
- `teo-kiem-hiep-godot`: tập kiếm hiệp dựng toàn bộ bằng Godot 2D (Godot 4.7.2 do `install.mjs` tự tải; tập mẫu nằm ở `MuseStudio/kiem-hiep/tap-01-tieu-phong-vs-quach-tinh/godot`, không kèm voice/nhạc).
- `chuong-2d`: tạo chiêu/chưởng Godot 2D (engine nằm trong skill), dùng cho tập kiếm hiệp Godot.
- `nhan-vat-chibi`: tạo nhân vật chibi, lưu look vào sổ chung `chars.json`.
- `thao-tac-chibi`: sổ động tác chibi (rig v2) + vật phẩm (kiếm/ô/đèn/hồ lô).

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
2. Tải bộ cài về (repo private, cần được mời vào repo), rồi chạy installer trong Terminal (Mac) hoặc PowerShell (Windows):
   ```bash
   git clone https://github.com/ngovanhai/skill-video-teo.git
   cd skill-video-teo
   node install.mjs
   ```
   Khi có bản mới: `git pull` rồi chạy lại `node install.mjs`.
   - `--muse-root <thư mục>`: nơi đặt kit và thư mục video. Mặc định là `~/MuseStudio` (Mac) hoặc `C:\Users\<tên>\MuseStudio` (Windows).
   - `--vieneu-dir <thư mục>`: nơi cài VieNeu-TTS. Mặc định là thư mục `VieNeu-TTS` nằm cạnh MuseRoot.
   - `--gpu`: dùng khi máy Windows có card NVIDIA, đọc giọng nhanh hơn khoảng 25 lần. Mac không cần cờ này.
   - `--skip-vieneu`: dùng khi máy đã có VieNeu-TTS.
   - `--godot-dir <thư mục>`: nơi cài Godot 4.7.2 (script tự tải bản chính thức từ GitHub, kiểm tra SHA512). Mặc định là thư mục `Godot` nằm cạnh MuseRoot.
   - `--godot <file>`: dùng file chạy Godot 4.7.2 có sẵn thay vì tải. `--skip-godot`: bỏ qua Godot (khi không làm tập Godot).
3. Mở terminal **mới**, `cd` vào MuseRoot, chạy `claude` rồi gõ `/video-teo`, `/teo-kiem-hiep` hoặc `/teo-kiem-hiep-godot`.

Script cài sẽ thay `__MUSE_ROOT__` / `__VIENEU_DIR__` / `__WHISPER_PY__` / `__GODOT__` / `__FFMPEG__` trong skill, kit và `kiem-hiep/_tools` bằng đường dẫn thật của máy bạn. Script cũng đặt 2 biến môi trường `MUSE_ROOT` và `VIENEU_DIR`: trên Windows dùng `setx`, trên Mac ghi vào `~/.zshrc`. Nếu Python của máy chưa có whisper, script tạo venv riêng ở `MuseRoot/.whisper`. Nếu máy đã có skill cùng tên, bản cũ được đổi tên thành `*.bak-<giờ>`.

## Lưu ý

- Lần đầu render, `npx hyperframes@0.8.172` sẽ tự tải trình duyệt headless nên cần có mạng.
- Không có GPU NVIDIA (kể cả Mac) thì giọng đọc chạy bằng CPU: chậm hơn nhiều, nhưng vẫn ra kết quả. Mac chip M chạy tương đối ổn.
- `teo-kiem-hiep/data/chu-de.md` có đánh dấu `(tập N)` cho các chủ đề đã làm. Nếu dùng chung một kênh thì giữ nguyên để không làm trùng chủ đề.
- Giọng "Lóng" là giọng riêng của kênh Tèo Kể. Chỉ dùng cho kênh này, không chia sẻ ra ngoài nhóm.
