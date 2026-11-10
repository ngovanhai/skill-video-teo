# Cài Whisper lên phiên Colab (GPU T4) cho căn chữ — colab-tts.mjs --align tự gọi qua `colab exec -f`, chạy lại không sao.
# Cùng bản openai-whisper với máy nhà (__MUSE_ROOT__/.whisper) để kết quả căn chữ không lệch.
import subprocess
from pathlib import Path

VER = "20250625"


def sh(c):
    print("$", c, flush=True)
    subprocess.run(c, shell=True, check=True)


if not Path("/content/.whisper_deps").exists():
    sh(f"pip install -q openai-whisper=={VER}")
    Path("/content/.whisper_deps").touch()
import torch  # noqa: E402
import whisper  # noqa: E402

print("whisper", whisper.__version__, "torch", torch.__version__, "cuda", torch.cuda.is_available(), flush=True)
if not torch.cuda.is_available():
    raise SystemExit("torch không thấy CUDA")
Path("/content/.whisper_ready").touch()
print("SETUP_OK", flush=True)
