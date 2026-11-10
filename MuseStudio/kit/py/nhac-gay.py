# Nhạc nền chỉ có đàn gảy (Karplus-Strong, ngũ cung, gảy thưa) cho tập Godot — luật 2026-10-29: không kèn, sáo, chuông, mõ,
# chiêng, trống. Đọc <godot>/timeline.json (khung: id, t0, t1) để đổi tâm trạng theo đoạn, ghi <godot>/nhac.ogg.
# python kit/py/nhac-gay.py <thư mục godot> [hạt giống]
import json, subprocess, sys, os, numpy as np, soundfile as sf
G = sys.argv[1]; SEED = int(sys.argv[2]) if len(sys.argv) > 2 else 7
SR = 44100
tl = json.load(open(os.path.join(G, 'timeline.json')))
out = np.zeros(int((tl['dur'] + 2) * SR) + SR)
rng = np.random.default_rng(SEED)
# gốc Hz, thang ngũ cung, bước (giây), độ dày — xoay vòng theo thứ tự đoạn
MOODS = [(293.7, [0, 2, 4, 7, 9], 0.6, 0.55), (261.6, [0, 3, 5, 7, 10], 0.7, 0.5), (329.6, [0, 2, 5, 7, 9], 0.55, 0.6),
         (246.9, [0, 3, 5, 7, 10], 0.8, 0.45), (349.2, [0, 2, 4, 7, 9], 0.65, 0.5), (220.0, [0, 2, 5, 7, 9], 0.85, 0.4)]
cache = {}
def ks(f, dur):
    k = (round(f, 1), dur)
    if k in cache: return cache[k]
    n = int(dur * SR); p = max(2, int(SR / f))
    buf = np.array(rng.uniform(-1, 1, p)); y = np.zeros(n)
    for i in range(0, n, p):  # Karplus-Strong theo chu kỳ (vector hoá từng vòng)
        m = min(p, n - i); y[i:i + m] = buf[:m]
        buf = 0.5 * (buf + np.roll(buf, -1)) * 0.995
    cache[k] = y
    return y

def sao_truc(f, dur):
    # Âm sáo trúc cổ phong: sóng sin + hài âm + vibrato 5.5 Hz + tiếng hơi nhẹ
    n = int(dur * SR)
    t = np.linspace(0, dur, n, endpoint=False)
    vib_env = np.clip((t - 0.15) / 0.35, 0, 1)
    vib = 1.0 + 0.018 * vib_env * np.sin(2 * np.pi * 5.5 * t)
    phase = 2 * np.pi * np.cumsum(f * vib) / SR
    sig = np.sin(phase) + 0.28 * np.sin(2 * phase) + 0.15 * np.sin(3 * phase) + 0.05 * np.sin(4 * phase)
    noise = rng.normal(0, 0.03, n)
    sig = sig + noise
    att = int(0.15 * SR); rel = int(0.3 * SR)
    env = np.ones(n)
    if n > att + rel:
        env[:att] = 0.5 * (1 - np.cos(np.linspace(0, np.pi, att)))
        env[-rel:] = 0.5 * (1 + np.cos(np.linspace(0, np.pi, rel)))
    else:
        env = np.sin(np.linspace(0, np.pi, n))
    return sig * env * 0.14

def dan_bau(f, dur):
    # Âm đàn bầu: bồi âm + luyến láy ngân rung đặc trưng
    n = int(dur * SR)
    t = np.linspace(0, dur, n, endpoint=False)
    bend = 1.0 + 0.035 * (1 - np.exp(-t / 0.25)) + 0.018 * np.sin(2 * np.pi * 4.8 * t) * (1 - np.exp(-t / 0.35))
    phase = 2 * np.pi * np.cumsum(f * bend) / SR
    sig = (np.sin(phase) + 0.6 * np.sin(2 * phase) + 0.4 * np.sin(3 * phase) + 0.25 * np.sin(4 * phase))
    env = np.exp(-t / (dur * 0.5))
    att = int(0.02 * SR)
    if n > att: env[:att] *= np.linspace(0, 1, att)
    return sig * env * 0.16

def add(t, y, g):
    i = int(t * SR); n = min(len(y), len(out) - i)
    if n > 0: out[i:i + n] += y[:n] * g

for j, seg in enumerate(tl['khung']):
    root, scale, step, dens = MOODS[j % len(MOODS)]
    t = seg['t0']; deg = 2
    # Câu dạo sáo trúc hoặc đàn bầu mở đầu mỗi cảnh (khung)
    if j % 2 == 0:
        f_flute = root * 2 ** ((scale[2] + 12) / 12)
        add(t + 0.5, sao_truc(f_flute, 2.8), 0.22)
    else:
        f_bau = root * 2 ** (scale[0] / 12)
        add(t + 0.5, dan_bau(f_bau, 2.5), 0.24)

    while t < seg['t1'] - 0.3:
        if rng.random() < dens:
            deg = int(np.clip(deg + rng.choice([-2, -1, 1, 1, 2]), 0, 9))
            f = root * 2 ** ((scale[deg % 5] + 12 * (deg // 5)) / 12)
            add(t, ks(f, 1.8), 0.2)
            if rng.random() < 0.15: add(t + step / 2, ks(f * 1.5, 1.2), 0.1)
            # Thỉnh thoảng xen một tiếng đàn bầu ngân nhẹ
            if rng.random() < 0.08:
                add(t + step * 0.8, dan_bau(f, 2.2), 0.18)
        t += step
try:
    from scipy.signal import lfilter
    a = np.exp(-2 * np.pi * 180 / SR)
    for _ in range(2): out = lfilter([a, -a], [1, -a], out)
except Exception:
    pass  # không có scipy: ffmpeg lọc highpass bên dưới
out = out / (np.max(np.abs(out)) + 1e-9) * 0.5
st = np.stack([out, np.roll(out, int(0.012 * SR)) * 0.92], 1)
wav = os.path.join(G, '..', 'work', 'nhac-gay.wav'); os.makedirs(os.path.dirname(wav), exist_ok=True)
sf.write(wav, st, SR)
ff = '/opt/homebrew/bin/ffmpeg' if os.path.exists('/opt/homebrew/bin/ffmpeg') else 'ffmpeg'
subprocess.check_call([ff, '-v', 'error', '-y', '-i', wav, '-af', 'highpass=f=180', '-c:a', 'vorbis', '-strict', '-2', '-ac', '2', os.path.join(G, 'nhac.ogg')])
print('nhac.ogg', round(len(out) / SR, 1), 's')
