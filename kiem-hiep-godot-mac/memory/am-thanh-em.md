---
name: am-thanh-em
description: "Mọi video Tèo/kiếm hiệp/chưởng: sfx êm không ùm ùm gây giật mình, sfx nhỏ hơn giọng, nhạc nền thấp hơn giọng ≥ 20 dB — luật nằm trong kit/lib/mix.mjs"
metadata:
  type: feedback
---

Người dùng chốt 2026-10-24: "video tạo không có effect ùm ùm tùm tùm không gây giật mình, sound effect nhỏ hơn giọng đọc. nhạc nền cũng sẽ phải nhỏ hơn".

**Why:** sfx `lib-impact-bass-*` gốc to hơn giọng 4–6 dB và gần như toàn tiếng trầm < 150 Hz; clip chưởng cũ -8 LUFS đỉnh +0.5 dB; nhạc tập 11 Godot chỉ thấp hơn giọng ~9 dB.

**How to apply:**
- Luật nằm trong code `~/MuseStudio/kit/lib/mix.mjs` (SFX_MAX 0.6, BGM_LUFS -40, giọng ≈ -20 LUFS), dùng chung bởi kit/make.mjs, video-teo build-short, teo-kiem-hiep build.mjs + gd-render, chuong-2d engine/mix.sh. Sửa mức thì sửa ở đó, đừng đặt số riêng trong từng pipeline.
- Thư viện sfx (`kit/sfx`, `chuong-2d/engine/sfx`) là bản êm do `node kit/sfx-soft.mjs` làm từ `_goc/`. Thêm sfx mới: bỏ vào `_goc/` rồi chạy lại script, không chép thẳng.
- `bgm_volume` / `nhac.volume_db` chỉ hạ được, bộ trộn tự kẹp trần theo độ to đo được (cache `<file>.lufs`).
Liên quan [[colab-tts]], [[shorts-doc-3-moi-video]].
