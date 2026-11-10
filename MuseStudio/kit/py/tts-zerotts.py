# ZeroTTS narration — bộ đọc duy nhất của pipeline Tèo (người dùng chốt 2026-11-03), cùng job + cùng kiểu cache .key như tts.py cũ
# nên make.mjs / gd-voice / align dùng y nguyên. Bản dài đọc trên Colab: colab-tts.mjs gửi chính file này lên và import (synth-zerotts.py).
#   __ZEROTTS_DIR__/.venv/bin/python kit/py/tts-zerotts.py <job.json>      (máy nhà, CPU, model int8)
# job: { "voice": "tiendat", "lines": [{ "id": "s001", "text": "...", "out": "abs/path.wav" }] }
# Giọng: giọng có sẵn của model (id hoặc tên hiển thị, vd. "tiendat" / "Tiến Đạt" — mặc định của pipeline từ 2026-11-03) hoặc giọng
# tự nạp trong ZEROTTS_VOICES_HOME (mặc định ~/.zerotts/voices, vd. "Lóng"); không phân biệt hoa thường.
# Khoá cache = sha1("zerotts|" + voice + "|" + text) (line_key) → wav cũ của VieNeu không bị coi là đã đọc.
import sys, json, time, hashlib, os
from pathlib import Path

import numpy as np
from scipy.signal import lfilter
from zerotts import ZeroTTS, normalize_vi_text
from zerotts.audio import concat_with_silence
from zerotts.chunking import chunk_text, clean_segment_punctuation, normalize_punctuation
from zerotts.voices import USER_VOICES_DIR

ZT = Path(os.environ.get("ZEROTTS_DIR") or "__ZEROTTS_DIR__")
# có bản int8 tải sẵn trong ZEROTTS_DIR thì dùng (nhanh, nhẹ); không thì để zerotts tự tải weights từ HuggingFace
_I8 = ZT / "models/zerotts-int8"
MODEL = os.environ.get("ZEROTTS_MODEL") or (str(_I8) if _I8.exists() else "zeroweight-ai/ZeroTTS")
TARGET_LUFS = -20.0  # luật trộn nhạc (kit/lib/mix.mjs) tính theo giọng ≈ -20 LUFS
PEAK = 10 ** (-1 / 20)  # trần đỉnh -1 dBFS


def line_key(voice, text):
    return hashlib.sha1(("zerotts|" + voice + "|" + text).encode("utf-8")).hexdigest()


def load(model=MODEL, providers=None):
    return ZeroTTS.from_pretrained(model, providers=providers, intra_op_num_threads=4)


def resolve_voice(tts, want):
    names = tts.list_voices()
    if want in names:
        return want
    w = want.casefold()
    for n in names:  # giọng có sẵn gọi theo tên hiển thị, vd. "Tiến Đạt" → tiendat
        if tts.load_voice(n).display_name.casefold() == w:
            return n
    for d in sorted(USER_VOICES_DIR.glob("*/meta.json")):
        meta = json.loads(d.read_text(encoding="utf-8"))
        if w in (meta.get("name", "").casefold(), meta.get("display_name", "").casefold()):
            return meta["name"]
    sys.exit(f"voice '{want}' not found in ZeroTTS; have: {names}")


def lufs(x, sr):
    # BS.1770: lọc K (shelf + high-pass) rồi gating khối 400 ms (tuyệt đối -70, tương đối -10)
    def biquad(f0, q, gain_db, kind):
        a_ = 10 ** (gain_db / 40); w = 2 * np.pi * f0 / sr; c, s = np.cos(w), np.sin(w); al = s / (2 * q)
        if kind == "shelf":
            b = [a_ * ((a_ + 1) + (a_ - 1) * c + 2 * np.sqrt(a_) * al), -2 * a_ * ((a_ - 1) + (a_ + 1) * c),
                 a_ * ((a_ + 1) + (a_ - 1) * c - 2 * np.sqrt(a_) * al)]
            a = [(a_ + 1) - (a_ - 1) * c + 2 * np.sqrt(a_) * al, 2 * ((a_ - 1) - (a_ + 1) * c),
                 (a_ + 1) - (a_ - 1) * c - 2 * np.sqrt(a_) * al]
        else:
            b = [(1 + c) / 2, -(1 + c), (1 + c) / 2]
            a = [1 + al, -2 * c, 1 - al]
        return np.array(b) / a[0], np.array(a) / a[0]
    y = lfilter(*biquad(1681.97, 0.7072, 4.0, "shelf"), x)
    y = lfilter(*biquad(38.135, 0.5003, 0, "hp"), y)
    blk, hop = int(0.4 * sr), int(0.1 * sr)
    ms = np.array([np.mean(y[i:i + blk] ** 2) for i in range(0, max(len(y) - blk, 0) + 1, hop)])
    ms = ms[ms > 10 ** ((-70 + 0.691) / 10)]
    if not len(ms):
        return None
    ms = ms[ms > np.mean(ms) * 10 ** (-10 / 10)]
    return -0.691 + 10 * np.log10(np.mean(ms))


def synth(tts, voice, text, key):
    """Một câu → float32 mono ở tts.sample_rate: chuẩn hoá chữ, cắt đoạn ≤ 15 s, seed theo key, kéo về TARGET_LUFS."""
    np.random.seed(int(key[:8], 16))  # cùng chữ → cùng giọng đọc
    sr = tts.sample_rate
    segs = [s for s in (clean_segment_punctuation(x) for x in chunk_text(normalize_punctuation(normalize_vi_text(text)), max_chunk_sec=15)) if s]
    audio = concat_with_silence([tts.synthesize(s, voice=voice) for s in segs], 0.15, sr).reshape(-1).astype(np.float64)
    level = lufs(audio, sr)
    if level is not None:
        audio *= 10 ** ((TARGET_LUFS - level) / 20)
    peak = np.max(np.abs(audio)) if len(audio) else 0
    if peak > PEAK:
        audio *= PEAK / peak
    return audio.astype(np.float32)


def main():
    job = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
    todo = []
    for it in job["lines"]:
        out = Path(it["out"])
        it["_key"] = key = line_key(job["voice"], it["text"])
        stamp = out.with_suffix(".key")
        if out.exists() and stamp.exists() and stamp.read_text() == key:
            continue
        todo.append(it)
    print(f"tts(zerotts): {len(job['lines']) - len(todo)} cached, {len(todo)} to synthesize", flush=True)
    if not todo:
        return
    tts = load()
    voice = resolve_voice(tts, job["voice"])
    t_all = time.time()
    for n, it in enumerate(todo, 1):
        t = time.time()
        audio = synth(tts, voice, it["text"], it["_key"])
        out = Path(it["out"])
        out.parent.mkdir(parents=True, exist_ok=True)
        tts.save_audio(audio, str(out))
        out.with_suffix(".key").write_text(it["_key"])
        print(f"  [{n}/{len(todo)}] {it['id']} {len(audio) / tts.sample_rate:.2f}s in {time.time() - t:.1f}s", flush=True)
    print(f"tts done in {time.time() - t_all:.0f}s", flush=True)


if __name__ == "__main__":
    main()
