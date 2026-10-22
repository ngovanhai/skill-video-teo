# Cài VieNeu-TTS lên phiên Colab (GPU T4) — colab-tts.mjs tự gọi qua `colab exec -f`, chạy lại không sao (bỏ qua bước đã xong).
# Trước khi gọi, colab-tts.mjs đã upload: /content/up/onnx_runtime_lite.py (bản vá chọn provider) và
# /content/vieneu_home/user_voices_v3_turbo.json (giọng Lóng đã lưu ở máy nhà).
import os, subprocess
from pathlib import Path

R = Path("/content/VieNeu-TTS")
COMMIT = "bd0f88eb8de7d560753a6172ba9c868f309a101c"  # đúng bản đang chạy ở __VIENEU_DIR__


def sh(c):
    print("$", c, flush=True)
    subprocess.run(c, shell=True, check=True)


if not (R / ".git").exists():
    sh(f"git clone -q https://github.com/pnnbao97/VieNeu-TTS.git {R}")
sh(f"git -C {R} checkout -q {COMMIT}")
sh(f"cp /content/up/onnx_runtime_lite.py {R}/src/vieneu/_v3_turbo_engine/onnx_runtime_lite.py")
if not Path("/content/.vieneu_deps").exists():
    # bỏ gradio (web UI, nặng) và onnxruntime bản CPU; vieneu cài --no-deps
    sh("pip uninstall -q -y onnxruntime || true")
    sh("pip install -q onnxruntime-gpu 'sea-g2p>=0.9.1' soundfile soxr 'kaldi-native-fbank>=1.20' 'tokenizers>=0.20' huggingface_hub PyYAML 'librosa>=0.11.0'")
    sh(f"pip install -q --no-deps -e {R}")
    Path("/content/.vieneu_deps").touch()
import onnxruntime as ort  # noqa: E402

print("onnxruntime", ort.__version__, ort.get_available_providers(), flush=True)
if "CUDAExecutionProvider" not in ort.get_available_providers():
    raise SystemExit("onnxruntime-gpu không thấy CUDA")
Path("/content/.vieneu_ready").touch()
print("SETUP_OK", flush=True)
