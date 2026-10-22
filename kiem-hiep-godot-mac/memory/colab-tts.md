---
name: colab-tts
description: "TTS VieNeu Lóng chạy trên Google Colab T4 qua colab CLI (gd-voice mặc định), đăng nhập do người dùng dán mã"
metadata:
  node_type: memory
  type: project
  originSessionId: 24a76cfa-ae94-4ea6-8c8d-0e50c7a88801
  modified: 2026-10-22T08:31:41.117Z
---

Từ 2026-10-22 người dùng muốn phần gen TTS dùng Google Colab ("phần gen tts sử dụng colab của google", "chạy colab cli").
- colab CLI cài ở venv `~/.local/share/uv/tools/google-colab-cli` (bản cài bằng uv tool trong AppData lỗi trampoline ở terminal người dùng). Token ở `~/.config/colab-cli/token.json`, Bash sandbox đọc được.
- `kiem-hiep/_tools/colab-tts/colab-tts.mjs <job.json>` (cùng job với kit/py/tts.py): tự `colab new -s tts --gpu T4`, setup.py (clone VieNeu bd0f88e + bản vá onnx, onnxruntime-gpu), synth.py giữ model trong kernel, tải zip về. gd-voice gọi nó mặc định, `--local` để đọc ở nhà.
- Gọi colab từ Git Bash cần `MSYS_NO_PATHCONV=1 PYTHONUTF8=1` (không thì /content/... bị đổi thành C:/Program Files/Git/...).
- Đăng nhập OAuth: người dùng tự dán mã vào tab terminal chạy `colab.exe sessions`; mã gửi trong chat thì không nhập thay. Mã gắn PKCE với đúng tiến trình đã sinh link.
- 2026-10-22: kênh tiếng Anh (video-pip) cũng mặc định Kokoro trên Colab — `kit/colab-en/colab-kokoro.mjs` (chung phiên `tts` + chung khoá với VieNeu), make.mjs tự lùi CPU; `--tts-local`/`KOKORO_LOCAL=1` để đọc ở nhà. Quy định ghi trong video-pip SKILL mục 6.
- 2026-10-22: lỗi đã gặp là exec treo (tự gửi lại sau 8 phút) và phiên đứt "Connection was lost" (tự stop + tạo phiên mới). Bảng xử lý ghi ở teo-kiem-hiep-godot SKILL.md mục "Lỗi Colab TTS đã gặp". Người dùng: Colab lỗi thì sửa Colab, không tự chuyển sang GPU nhà.
- 2026-10-22: cả colab-tts và colab-kokoro giữ phiên 15 phút sau job (`COLAB_TTS_GRACE`, `COLAB_TTS_KEEP=1` = không tắt) vì phiên tắt là mất bản cài; mọi lệnh colab có hạn giờ qua `run-timeout.mjs` (taskkill /T) + thử lại. gd-voice Colab lỗi thì dừng, không lùi máy nhà (chỉ `--local` khi người dùng cho).
**How to apply:** TTS mới cho kiếm hiệp đi qua Colab; nếu token hết hạn thì mở tab terminal chạy `colab sessions` để người dùng dán mã.
Liên quan: [[gpu-tts-align]], [[kiem-hiep-voice-long]], [[teo-kiem-hiep-godot-skill]]
