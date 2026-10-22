#!/bin/bash
# Kiểm cú pháp -> render -> ghép SFX -> contact sheet 8 khung.
# Dùng: check.sh <id> [số khung=345] [8 mốc giây…]   -> renders/<id>.mp4, work/sheet_<id>.jpg
set -e
E="$(cd "$(dirname "$0")/../engine" && pwd)"; cd "$E"
G=${GODOT:-__GODOT__}
ID=$1; N=${2:-345}; shift 2 2>/dev/null || shift $#
[ -f "moves/$ID.gd" ] || { echo "không có moves/$ID.gd"; exit 1; }
ERR=$("$G" --path . --headless --check-only --script "res://moves/$ID.gd" 2>&1 | grep -iE "error" || true)
[ -z "$ERR" ] || { echo "$ERR"; exit 1; }
rm -f "work/$ID.sfx"
"$G" --path . --disable-vsync --fixed-fps 30 -- --move "$ID" --rec "work/$ID.mp4" "$N" 2>&1 | grep -iE "error" | sort -u | head -10 || true
bash mix.sh "$ID"
# mốc mặc định: mở, tụ khí, 3 nhịp biểu diễn, đỉnh, hậu quả, kết
TS=("$@"); [ ${#TS[@]} -eq 8 ] || TS=(0.5 1.6 2.8 4.0 5.3 6.4 7.6 $(awk "BEGIN{print $N/30-0.7}"))
i=0; for s in "${TS[@]}"; do ffmpeg -v error -y -ss "$s" -i "work/$ID.mp4" -frames:v 1 -vf scale=960:-1 "work/_s$i.jpg"; i=$((i+1)); done
ffmpeg -v error -y $(for j in 0 1 2 3 4 5 6 7; do echo -i work/_s$j.jpg; done) \
  -filter_complex "xstack=inputs=8:layout=0_0|w0_0|0_h0|w0_h0|0_h0+h0|w0_h0+h0|0_h0+h0+h0|w0_h0+h0+h0" "work/sheet_$ID.jpg"
rm -f work/_s*.jpg
echo "sheet: $E/work/sheet_$ID.jpg (mốc ${TS[*]})"
echo "sfx:   $(wc -l < "work/$ID.sfx") mốc trong work/$ID.sfx"
