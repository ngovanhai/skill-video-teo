# VieNeu-TTS narration for every scene of a long video. Skips scenes whose wav is newer than
# their text (cache key = text hash stored next to the wav), so a crashed run resumes.
#   E:/tool/VieNeu-TTS/.venv/Scripts/python kit/py/tts.py <job.json>
# job: { "voice": "Lóng", "temperature": 0.8, "lines": [{ "id": "s001", "text": "...", "out": "abs/path.wav" }] }
import sys, json, time, hashlib
from pathlib import Path

REPO = Path("E:/tool/VieNeu-TTS")
sys.path.insert(0, str(REPO))
from vieneu import Vieneu
from apps.user_voices import load_user_voices


def main():
    job = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
    todo = []
    for it in job["lines"]:
        out = Path(it["out"])
        key = hashlib.sha1((job["voice"] + "|" + it["text"]).encode("utf-8")).hexdigest()
        it["_key"] = key
        stamp = out.with_suffix(".key")
        if out.exists() and stamp.exists() and stamp.read_text() == key:
            continue
        todo.append(it)
    print(f"tts: {len(job['lines']) - len(todo)} cached, {len(todo)} to synthesize", flush=True)
    if not todo:
        return
    tts = Vieneu()
    saved = load_user_voices(tts)
    voice = job["voice"]
    if voice not in saved and tts.resolve_voice_name(voice) is None:
        sys.exit(f"voice '{voice}' not found; saved: {saved}")
    t_all = time.time()
    for n, it in enumerate(todo, 1):
        t = time.time()
        audio = tts.infer(it["text"], voice=voice, temperature=job.get("temperature", 0.8))
        out = Path(it["out"])
        out.parent.mkdir(parents=True, exist_ok=True)
        tts.save(audio, out)
        out.with_suffix(".key").write_text(it["_key"])
        print(f"  [{n}/{len(todo)}] {it['id']} {len(audio) / tts.sample_rate:.2f}s in {time.time() - t:.1f}s", flush=True)
    print(f"tts done in {time.time() - t_all:.0f}s", flush=True)


main()
