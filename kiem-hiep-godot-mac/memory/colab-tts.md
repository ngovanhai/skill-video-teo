---
name: colab-tts
description: "TTS ZeroTTS (giọng Tiến Đạt) + căn chữ chạy trên Google Colab T4 qua colab CLI (gd-voice / make.mjs mặc định), đăng nhập do người dùng dán mã"
metadata:
  node_type: memory
  type: project
  originSessionId: 24a76cfa-ae94-4ea6-8c8d-0e50c7a88801
  modified: 2026-10-22T08:31:41.117Z
---

Từ 2026-10-22 người dùng muốn phần gen TTS dùng Google Colab ("phần gen tts sử dụng colab của google", "chạy colab cli").
- colab CLI cài ở venv `~/.local/share/uv/tools/google-colab-cli` (bản cài bằng uv tool trong AppData lỗi trampoline ở terminal người dùng). Token ở `~/.config/colab-cli/token.json`, Bash sandbox đọc được.
- `kiem-hiep/_tools/colab-tts/colab-tts.mjs <job.json>` (cùng job, cùng khoá cache với kit/py/tts-zerotts.py): tự `colab new -s tts --gpu T4`, `setup-zerotts.py` (pip `zerotts==0.1.5` + onnxruntime-gpu, tải weights fp32 vào /content/zerotts — bản int8 không chạy CUDA), `synth-zerotts.py` giữ model trong kernel và import chính `tts-zerotts.py` vừa upload, tải zip về. gd-voice / make.mjs gọi nó mặc định, `--local` / `--tts-local` để đọc ở nhà.
- Gọi colab từ Git Bash cần `MSYS_NO_PATHCONV=1 PYTHONUTF8=1` (không thì /content/... bị đổi thành C:/Program Files/Git/...).
- Đăng nhập OAuth: người dùng tự dán mã vào tab terminal chạy `colab.exe sessions`; mã gửi trong chat thì không nhập thay. Mã gắn PKCE với đúng tiến trình đã sinh link.
- 2026-10-22: kênh tiếng Anh (video-pip) cũng mặc định Kokoro trên Colab — `kit/colab-en/colab-kokoro.mjs` (chung phiên `tts` + chung khoá với VieNeu), make.mjs tự lùi CPU; `--tts-local`/`KOKORO_LOCAL=1` để đọc ở nhà. Quy định ghi trong video-pip SKILL mục 6.
- 2026-10-22: lỗi đã gặp là exec treo (tự gửi lại sau 8 phút) và phiên đứt "Connection was lost" (tự stop + tạo phiên mới). Bảng xử lý ghi ở teo-kiem-hiep-godot SKILL.md mục "Lỗi Colab TTS đã gặp". Người dùng: Colab lỗi thì sửa Colab, không tự chuyển sang GPU nhà.
- 2026-10-22: cả colab-tts và colab-kokoro giữ phiên 15 phút sau job (`COLAB_TTS_GRACE`, `COLAB_TTS_KEEP=1` = không tắt) vì phiên tắt là mất bản cài; mọi lệnh colab có hạn giờ qua `run-timeout.mjs` (taskkill /T) + thử lại. gd-voice Colab lỗi thì dừng, không lùi máy nhà (chỉ `--local` khi người dùng cho).
- 2026-10-23 (máy Mac): người dùng yêu cầu "chạy xong không tắt ngay, đợi 15 phút sau mới tắt nếu không có request nào gọi đến colab". colab-tts.mjs giờ xong job là thoát ngay, tiến trình nền `--reap` (log `.reap.log`, pid `.reaper`, giờ job cuối `.last`) tắt phiên sau 15 phút liền rảnh. Trước đó bản cũ bắt job đứng chờ 15 phút nên session làm video tự đặt `COLAB_TTS_GRACE=0/1/3` → phiên bị tắt ngay. **Không đặt COLAB_TTS_GRACE nữa.**
- 2026-10-23: người dùng "chuyển đọc sang colab" cho dòng video-teo: `kit/make.mjs` stage tts mặc định gọi colab-tts.mjs (`--tts-local` = máy nhà, Colab lỗi thì die); `ideas/chay-nang.sh` chạy tts ngay ngoài làn CPU. Script chay-nang.sh đang có nhiều bash chạy → thay bằng ghi file mới + `mv`, không sửa tại chỗ.
- 2026-10-23: căn chữ cũng lên Colab (người dùng đồng ý): `colab-tts.mjs --align <job> [model]` (setup-align.py cài openai-whisper==20250625 như máy nhà; align-run.py chạy chính kit/py/align.py với WHISPER_DEVICE=cuda; wav → flac 16 kHz mono trước khi upload; key cache tính ở máy nhà truyền qua job "key"). Đã so 2 câu ronaldo-bi-gach-ten: key/match/dur/mốc từ y hệt CPU. make.mjs `--align-local` = máy nhà. chay-nang.sh chạy tới hết align ngoài làn.
- 2026-10-24: người dùng "short và sửa ngắn dùng CPU luôn, chỉ đọc dài mới dùng Colab" (áp cho tất cả skill). `kit/lib/mix.mjs` useColab: đường dẫn có /shorts/ hoặc < LONG_MIN=30 câu cần làm (sau cache) → máy nhà. make.mjs (tts + align) gọi colab-tts `--min 30` (mã 75 = làm ở nhà); gd-voice tự xét todo.length; chay-nang.sh cho short xếp làn giong như cũ.
**How to apply:** TTS mới cho kiếm hiệp đi qua Colab; nếu token hết hạn thì mở tab terminal chạy `colab sessions` để người dùng dán mã.
Liên quan: [[gpu-tts-align]], [[kiem-hiep-voice-tiendat]], [[teo-kiem-hiep-godot-skill]]
