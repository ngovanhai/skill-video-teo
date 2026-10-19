# Word timings for the TTS audio: whisper word timestamps, then the known script words are matched
# onto them (difflib); unmatched words are interpolated. Cached per scene (keyed on wav + text).
#   python kit/py/align.py <job.json> [model]
# job: { "names": "comma list of proper names", "lines": [{ "id", "text", "out" (wav), "words" (json out) }] }
import sys, json, re, difflib, unicodedata, hashlib, time
from pathlib import Path


def norm(w):
    w = unicodedata.normalize("NFC", w.lower())
    return re.sub(r"[^\w]", "", w)


def align(script_words, asr, dur):
    a = [norm(w["text"]) for w in asr]
    b = [norm(w) for w in script_words]
    times = [None] * len(b)
    sm = difflib.SequenceMatcher(None, a, b, autojunk=False)
    for tag, i1, i2, j1, j2 in sm.get_opcodes():
        if tag == "equal":
            for k in range(i2 - i1):
                times[j1 + k] = (asr[i1 + k]["start"], asr[i1 + k]["end"])
        elif tag == "replace":
            s, e = asr[i1]["start"], asr[i2 - 1]["end"]
            n = j2 - j1
            for k in range(n):
                times[j1 + k] = (s + (e - s) * k / n, s + (e - s) * (k + 1) / n)
    known = [i for i, t in enumerate(times) if t]
    for i, t in enumerate(times):
        if t:
            continue
        prev = max([k for k in known if k < i], default=None)
        nxt = min([k for k in known if k > i], default=None)
        s = times[prev][1] if prev is not None else 0.0
        e = times[nxt][0] if nxt is not None else dur
        lo = prev if prev is not None else -1
        hi = nxt if nxt is not None else len(times)
        span = hi - lo - 1
        pos = i - lo - 1
        times[i] = (s + (e - s) * pos / span, s + (e - s) * (pos + 1) / span)
    # keep starts monotonic
    out, last = [], 0.0
    for w, (s, e) in zip(script_words, times):
        s = max(s, last)
        e = max(e, s + 0.05)
        last = s
        out.append({"text": w, "start": round(s, 3), "end": round(min(e, dur), 3)})
    matched = sum(i2 - i1 for tag, i1, i2, _, _ in sm.get_opcodes() if tag == "equal")
    return out, matched


def main():
    job = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
    model_name = sys.argv[2] if len(sys.argv) > 2 else "small"
    todo = []
    for it in job["lines"]:
        wav = Path(it["out"])
        key = hashlib.sha1((it["text"] + "|" + str(wav.stat().st_mtime_ns) + "|" + model_name).encode("utf-8")).hexdigest()
        it["_key"] = key
        dst = Path(it["words"])
        if dst.exists():
            try:
                if json.loads(dst.read_text(encoding="utf-8")).get("key") == key:
                    continue
            except Exception:
                pass
        todo.append(it)
    print(f"align: {len(job['lines']) - len(todo)} cached, {len(todo)} to align", flush=True)
    if not todo:
        return
    import whisper
    model = whisper.load_model(model_name)
    prompt = job.get("names") or None
    t_all = time.time()
    weak = []
    for n, it in enumerate(todo, 1):
        r = model.transcribe(it["out"], language="vi", word_timestamps=True, initial_prompt=prompt,
                             condition_on_previous_text=False, fp16=False)
        asr = [{"text": w["word"].strip(), "start": w["start"], "end": w["end"]} for s in r["segments"] for w in s.get("words", [])]
        dur = whisper.audio.load_audio(it["out"]).shape[0] / whisper.audio.SAMPLE_RATE
        script_words = [w for w in re.split(r"\s+", it["text"].strip()) if norm(w)]
        words, matched = align(script_words, asr, dur) if asr else (
            [{"text": w, "start": round(dur * i / len(script_words), 3), "end": round(dur * (i + 1) / len(script_words), 3)} for i, w in enumerate(script_words)], 0)
        ratio = matched / max(1, len(script_words))
        if ratio < 0.6:
            weak.append(f"{it['id']} ({ratio:.0%}: {r['text'].strip()[:80]})")
        Path(it["words"]).parent.mkdir(parents=True, exist_ok=True)
        Path(it["words"]).write_text(json.dumps({"key": it["_key"], "dur": round(dur, 3), "match": round(ratio, 3), "words": words}, ensure_ascii=False), encoding="utf-8")
        print(f"  [{n}/{len(todo)}] {it['id']} {dur:.1f}s match {ratio:.0%}", flush=True)
    print(f"align done in {time.time() - t_all:.0f}s", flush=True)
    if weak:
        print("WEAK ALIGNMENT (check audio — TTS may have skipped or garbled):\n  " + "\n  ".join(weak), flush=True)


main()
