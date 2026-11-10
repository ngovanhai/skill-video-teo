# Căn chữ một mẻ trên phiên Colab — colab-tts.mjs --align gọi `colab exec -f align-run.py --env JOB=<tên> --env MODEL=<model>`.
# Chạy chính kit/py/align.py (upload sẵn vào /content/up/align.py) bằng GPU nên kết quả giống máy nhà.
#   vào:  /content/jobs/<tên>.zip   gồm job.json + <id>.flac (16 kHz mono, máy nhà đã đổi từ wav)
#   ra:   /content/out/<tên>.zip    gồm <id>.json (words)   (dòng cuối in ZIP_OK <số câu> <giây>)
import os, sys, time, zipfile
from pathlib import Path

name, model = os.environ["JOB"], os.environ.get("MODEL", "small")
d = Path(f"/content/al/{name}")
d.mkdir(parents=True, exist_ok=True)
zipfile.ZipFile(f"/content/jobs/{name}.zip").extractall(d)
t = time.time()
os.environ["WHISPER_DEVICE"] = "cuda"
sys.argv = ["align.py", str(d / "job.json"), model]
exec(compile(Path("/content/up/align.py").read_text(encoding="utf-8"), "align.py", "exec"), {"__name__": "__main__"})
ws = sorted((d / "w").glob("*.json"))
with zipfile.ZipFile(f"/content/out/{name}.zip", "w", zipfile.ZIP_DEFLATED) as z:
    for w in ws:
        z.write(w, w.name)
print(f"ZIP_OK {len(ws)} {time.time() - t:.0f}", flush=True)
