# Cài ZeroTTS lên phiên Colab (GPU T4) — colab-tts.mjs tự gọi qua `colab exec -f`, chạy lại không sao (bỏ qua bước đã xong).
# Weights tải về thư mục thật (/content/zerotts), không dùng cache HF: onnxruntime mới từ chối file .data qua symlink của cache.
# Bản fp32 (không int8): MatMulInteger của bản int8 không chạy trên CUDA. Giọng (voice.npz + meta.json) colab-tts.mjs upload mỗi lần chạy.
import subprocess
from pathlib import Path

MODEL = Path("/content/zerotts")
VERSION = "0.1.5"  # đúng bản đang chạy ở __ZEROTTS_DIR__


def sh(c):
    print("$", c, flush=True)
    subprocess.run(c, shell=True, check=True)


if not Path("/content/.zerotts_deps").exists():
    sh("pip uninstall -q -y onnxruntime || true")
    sh(f"pip install -q onnxruntime-gpu zerotts=={VERSION}")
    sh("pip uninstall -q -y onnxruntime || true")  # zerotts kéo onnxruntime CPU về, đè mất onnxruntime-gpu
    sh("pip install -q --force-reinstall --no-deps onnxruntime-gpu")
    Path("/content/.zerotts_deps").touch()
if not (MODEL / "config.json").exists():
    from huggingface_hub import snapshot_download
    from zerotts.hub import _ALLOW_PATTERNS
    snapshot_download("zeroweight-ai/ZeroTTS", local_dir=str(MODEL), allow_patterns=_ALLOW_PATTERNS)
import onnxruntime as ort  # noqa: E402

print("onnxruntime", ort.__version__, ort.get_available_providers(), flush=True)
if "CUDAExecutionProvider" not in ort.get_available_providers():
    raise SystemExit("onnxruntime-gpu không thấy CUDA")
Path("/content/.zerotts_ready").touch()
print("SETUP_OK", flush=True)
