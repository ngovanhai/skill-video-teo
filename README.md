# Bộ skill Tèo: 13 skill sản xuất video + hoạt hình Godot

Bộ skill cho **Claude Code**, dùng để làm video YouTube kênh Tèo:
- `video-teo`: video dài từ 20 phút trở lên, có giọng Tèo (ZeroTTS, giọng **Tiến Đạt**), phụ đề, thumbnail và gói upload. Không làm Shorts.
- `teo-kiem-hiep`: tập kiếm hiệp hoạt hình (HyperFrames + GSAP), đọc bằng ZeroTTS giọng "Tiến Đạt".
- `teo-kiem-hiep-godot`: tập dựng toàn bộ bằng Godot 2D (Godot 4.7.2 do `install.mjs` tự tải; tập mẫu nằm ở `MuseStudio/kiem-hiep/tap-01-tieu-phong-vs-quach-tinh/godot`, không kèm voice/nhạc). Chủ đề: kiếm hiệp và các tác phẩm nổi tiếng Trung Quốc (Tam Quốc, Thủy Hử, Tây Du Ký, Phong Thần…).
- `chuong-2d`: tạo chiêu/chưởng Godot 2D (engine nằm trong skill), dùng cho tập kiếm hiệp Godot.
- `nhan-vat-chibi`: tạo nhân vật chibi, lưu look vào sổ chung `chars.json`.
- `thao-tac-chibi`: sổ động tác chibi (rig v2) + vật phẩm (kiếm/ô/đèn/hồ lô).
- `kiem-tra-video`: bộ soát 5 tầng (review kịch bản, smoke test 15 s, check hình/âm thanh, quality gate cấp `youtube/.READY_TO_UPLOAD`).
- `hoat-anh-kich-ban`: phân tích kịch bản → storyboard + sinh mã hoạt cảnh Godot (vũ đạo hành động chibi, chống slide chữ tĩnh).
- `tim-chu-de-ke`: tìm chủ đề mới bằng cách ké video đang lên (`kiem-hang.py --dang-len`, `tu-khoa.py`), chống trùng chủ đề đã làm.\n- `art-director-2d`: xây Art Bible, palette và quy tắc mỹ thuật thống nhất cho cả tập.\n- `cinematic-scene-2d`: bố cục cảnh, camera, parallax, chiều sâu và ánh sáng.\n- `godot-visual-effects`: thiết kế VFX 2D như kiếm khí, chưởng lực, khói, lửa, băng và shader.\n- `godot-visual-review`: render contact sheet, soi frame thật và lập danh sách lỗi hình ảnh trước khi xuất bản.

> Các skill này chạy trên máy của bạn: render, ffmpeg và (khi không có Colab) giọng đọc đều chạy tại máy.
> Vì vậy **không dùng được trong chat claude.ai**, chỉ dùng được trong **Claude Code** (CLI hoặc tab Code của app Claude).

## Trong gói có gì

| Thư mục | Nội dung |
|---|---|
| `skills/` | 13 skill, được chép vào `~/.claude/skills/`, `~/.gemini/config/skills/`, `~/.agents/skills/`, `~/.config/opencode/skills/` |
| `MuseStudio/kit` | công cụ dựng video (`make.mjs`, cảnh, fx, font, nhạc nền, sfx êm, `lib/mix.mjs`, `py/tts-zerotts.py`) |
| `MuseStudio/avatar` | avatar, banner, watermark của kênh |
| `MuseStudio/ideas` | `DA-LAM.md` (đã làm), `HOOK-MO-DAU.md`, `TIEU-DE-ANH-BIA.md` (luật hook, tiêu đề, ảnh bìa) |
| `MuseStudio/yt-auto/tools` | `tieu-de.mjs`, `tu-khoa.py`, `kiem-hang.py` (luật tiêu đề, từ khoá, độ cạnh tranh) |
| `MuseStudio/kiem-hiep/_tools` | `slot.sh` (2 suất máy), `colab-tts/` (đọc giọng + căn chữ trên Colab T4) |

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
   - `--zerotts-dir <thư mục>`: nơi cài ZeroTTS (venv + weights). Mặc định `~/Projects/ZeroTTS-src`.
   - `--skip-zerotts`: dùng khi máy đã có venv ZeroTTS.
   - `--skip-colab`: không cài `colab` CLI (khi chỉ đọc giọng ở máy nhà).
   - `--godot-dir <thư mục>`: nơi cài Godot 4.7.2 (script tự tải bản chính thức từ GitHub, kiểm tra SHA512). Mặc định là thư mục `Godot` nằm cạnh MuseRoot.
   - `--godot <file>`: dùng file chạy Godot 4.7.2 có sẵn thay vì tải. `--skip-godot`: bỏ qua Godot (khi không làm tập Godot).
3. Mở terminal **mới**, `cd` vào MuseRoot, chạy `claude` rồi gõ `/video-teo`, `/teo-kiem-hiep` hoặc `/teo-kiem-hiep-godot`.

Script cài sẽ thay `__MUSE_ROOT__` / `__ZEROTTS_DIR__` / `__WHISPER_PY__` / `__WHISPER_DML_PY__` / `__GODOT__` / `__FFMPEG__` / `__SKILLS_DIR__` (thư mục skills đang cài) trong skill, kit, ideas, yt-auto và `kiem-hiep/_tools` bằng đường dẫn thật của máy bạn. Script cũng đặt 2 biến môi trường `MUSE_ROOT` và `ZEROTTS_DIR`: trên Windows dùng `setx`, trên Mac ghi vào `~/.zshrc`. Nếu Python của máy chưa có whisper, script tạo venv riêng ở `MuseRoot/.whisper`. Lần đọc giọng đầu tiên, ZeroTTS tự tải weights (~1 GB) từ HuggingFace nên cần mạng. Nếu máy đã có skill cùng tên, bản cũ được đổi tên thành `*.bak-<giờ>`.

## Gói riêng cho Mac: `kiem-hiep-godot-mac/`

Chỉ cần làm tập kiếm hiệp Godot trên Mac thì dùng thư mục `kiem-hiep-godot-mac/` (13 skill bản mới nhất, gồm bộ sản xuất video, Godot và visual; lấy trực tiếp từ `skills/` gốc, kèm kit, avatar, colab-tts, tập mẫu và memory — chỉ cài cho Mac). Xem `kiem-hiep-godot-mac/README.md`:
```bash
cd kiem-hiep-godot-mac && node install.mjs
```

## Lưu ý

- Lần đầu render, `npx hyperframes@0.8.172` sẽ tự tải trình duyệt headless nên cần có mạng.
- Bản dài đọc giọng + căn chữ trên **Google Colab GPU T4** (đăng nhập một lần: `colab sessions`). Colab thu hồi / không cấp GPU thì tự đọc bằng CPU máy nhà (chậm hơn nhưng vẫn ra); short và sửa ngắn luôn đọc ở máy nhà.
- `teo-kiem-hiep/data/chu-de.md` có đánh dấu `(tập N)` cho các chủ đề đã làm. Nếu dùng chung một kênh thì giữ nguyên để không làm trùng chủ đề.
- Giọng đọc là **Tiến Đạt** (`"voice": "tiendat"`), giọng có sẵn của ZeroTTS — không cần mẫu giọng riêng, không phải xin phép ai.
