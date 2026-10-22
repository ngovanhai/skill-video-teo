# Đọc một job trên phiên Colab — colab-tts.mjs gọi `colab exec -f synth.py --env JOB=<tên>`.
# Kernel Jupyter giữ biến giữa các lần exec, nên model chỉ nạp một lần (_TTS) cho cả loạt job.
#   vào:  /content/jobs/<tên>.json   { "voice": "Lóng", "temperature": 0.8, "lines": [{ "id": "...", "text": "..." }] }
#   ra:   /content/out/<tên>/<id>.wav  rồi gói /content/out/<tên>.zip  (dòng cuối in ZIP_OK <số câu> <giây>)
import json, os, sys, time, zipfile
from pathlib import Path

R = "/content/VieNeu-TTS"
for p in (R, R + "/src"):
    if p not in sys.path:
        sys.path.insert(0, p)
os.environ["VIENEU_HOME"] = "/content/vieneu_home"
os.environ.setdefault("VIENEU_ORT_PROVIDERS", "CUDAExecutionProvider")
os.environ.setdefault("VIENEU_ORT_GPU_PARTS", "pre,dec,ac,codec")

if globals().get("_TTS") is None:
    import onnxruntime as ort
    if hasattr(ort, "preload_dlls"):
        ort.preload_dlls()  # nạp cuDNN/cuBLAS của gói pip nvidia-* trước khi tạo session CUDA
    from vieneu import Vieneu
    from apps.user_voices import load_user_voices
    t = time.time()
    _TTS = Vieneu()
    _SAVED = load_user_voices(_TTS)
    print(f"nạp model {time.time() - t:.0f}s · giọng đã lưu: {_SAVED}", flush=True)

name = os.environ["JOB"]
job = json.loads(Path(f"/content/jobs/{name}.json").read_text(encoding="utf-8"))
voice = job.get("voice", "Lóng")
if voice not in _SAVED and _TTS.resolve_voice_name(voice) is None:
    raise SystemExit(f"không có giọng '{voice}'; có: {_SAVED}")
od = Path(f"/content/out/{name}")
od.mkdir(parents=True, exist_ok=True)
t_all = time.time()
for n, it in enumerate(job["lines"], 1):
    w = od / (it["id"] + ".wav")
    if w.exists():
        continue  # exec trước bị ngắt giữa chừng → đọc tiếp từ câu chưa có
    t = time.time()
    audio = _TTS.infer(it["text"], voice=voice, temperature=job.get("temperature", 0.8))
    _TTS.save(audio, od / (it["id"] + ".part.wav"))
    os.replace(od / (it["id"] + ".part.wav"), w)
    print(f"  [{n}/{len(job['lines'])}] {it['id']} {len(audio) / _TTS.sample_rate:.1f}s trong {time.time() - t:.1f}s", flush=True)
zp = Path(f"/content/out/{name}.zip")
with zipfile.ZipFile(zp, "w", zipfile.ZIP_STORED) as z:
    for it in job["lines"]:
        z.write(od / (it["id"] + ".wav"), it["id"] + ".wav")
print(f"ZIP_OK {len(job['lines'])} {time.time() - t_all:.0f}", flush=True)
