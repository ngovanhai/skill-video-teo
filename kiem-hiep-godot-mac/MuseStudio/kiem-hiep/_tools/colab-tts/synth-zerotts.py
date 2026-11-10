# Đọc một job bằng ZeroTTS trên phiên Colab — colab-tts.mjs gọi `colab exec -f synth-zerotts.py --env JOB=<tên>`.
# Logic đọc (cắt đoạn, seed, -20 LUFS) là chính kit/py/tts-zerotts.py ở máy nhà, colab-tts.mjs upload lên /content/up/tts_zerotts.py mỗi lần.
# Kernel Jupyter giữ biến giữa các lần exec, nên model chỉ nạp một lần (_ZT) cho cả loạt job.
#   vào:  /content/jobs/<tên>.json   { "voice": "tiendat", "lines": [{ "id": "...", "text": "..." }] }
#   ra:   /content/out/<tên>/<id>.wav  rồi gói /content/out/<tên>.zip  (dòng cuối in ZIP_OK <số câu> <giây>)
import importlib, json, os, sys, time, zipfile
from pathlib import Path

# Giọng nằm ở thư mục mặc định ~/.zerotts/voices (colab-tts.mjs upload vào /root/.zerotts/voices) — không dùng ZEROTTS_VOICES_HOME:
# setup-zerotts.py đã import zerotts trong cùng kernel nên USER_VOICES_DIR đã chốt từ trước.
os.environ["ZEROTTS_MODEL"] = "/content/zerotts"
if "/content/up" not in sys.path:
    sys.path.insert(0, "/content/up")

import tts_zerotts as Z  # noqa: E402

if globals().get("_ZT") is None:
    import onnxruntime as ort
    if hasattr(ort, "preload_dlls"):
        ort.preload_dlls()  # nạp cuDNN/cuBLAS của gói pip nvidia-* trước khi tạo session CUDA
    t = time.time()
    _ZT = Z.load(providers=os.environ.get("ZEROTTS_PROVIDERS", "CUDAExecutionProvider,CPUExecutionProvider").split(","))
    print(f"nạp model {time.time() - t:.0f}s · {_ZT.providers}", flush=True)
else:
    Z = importlib.reload(Z)  # bản tts_zerotts.py vừa upload có thể mới hơn

name = os.environ["JOB"]
job = json.loads(Path(f"/content/jobs/{name}.json").read_text(encoding="utf-8"))
voice = Z.resolve_voice(_ZT, job.get("voice", "tiendat"))
od = Path(f"/content/out/{name}")
od.mkdir(parents=True, exist_ok=True)
t_all = time.time()
for n, it in enumerate(job["lines"], 1):
    w = od / (it["id"] + ".wav")
    if w.exists():
        continue  # exec trước bị ngắt giữa chừng → đọc tiếp từ câu chưa có
    t = time.time()
    audio = Z.synth(_ZT, voice, it["text"], Z.line_key(job["voice"], it["text"]))
    _ZT.save_audio(audio, str(od / (it["id"] + ".part.wav")))
    os.replace(od / (it["id"] + ".part.wav"), w)
    print(f"  [{n}/{len(job['lines'])}] {it['id']} {len(audio) / _ZT.sample_rate:.1f}s trong {time.time() - t:.1f}s", flush=True)
zp = Path(f"/content/out/{name}.zip")
with zipfile.ZipFile(zp, "w", zipfile.ZIP_STORED) as z:
    for it in job["lines"]:
        z.write(od / (it["id"] + ".wav"), it["id"] + ".wav")
print(f"ZIP_OK {len(job['lines'])} {time.time() - t_all:.0f}", flush=True)
