#!/bin/bash
# Kiểm cú pháp -> render -> contact sheet.
# Dùng: check.sh <id> [số khung=240] [mốc giây…]   -> work/<id>.mp4, work/sheet_<id>.jpg
# ENGINE=<thư mục dự án> để chạy trên bản engine khác (vd thư mục tập phim); mặc định engine của skill.
set -e
E="${ENGINE:-$(cd "$(dirname "$0")/../engine" && pwd)}"; cd "$E"; mkdir -p work
G=${GODOT:-__GODOT__}
ID=$1; N=${2:-240}; shift 2 2>/dev/null || shift $#
[ -f "canh/$ID.gd" ] || { echo "không có canh/$ID.gd"; exit 1; }
ERR=$("$G" --path . --headless --check-only --script "res://canh/$ID.gd" 2>&1 | grep -iE "error" || true)
[ -z "$ERR" ] || { echo "$ERR"; exit 1; }
TO=(); for t in timeout gtimeout; do command -v $t >/dev/null && { TO=($t 600); break; }; done # macOS không có sẵn timeout
"${TO[@]}" "$G" --path . --disable-vsync --fixed-fps 30 -- --canh "$ID" --rec "work/$ID.mp4" "$N" 2>&1 | grep -iE "error" | sort -u | head -10 || true
TS=("$@"); [ ${#TS[@]} -gt 0 ] || TS=($(awk "BEGIN{d=$N/30; for(i=0;i<6;i++) printf \"%.2f \", 0.4+i*(d-0.8)/5}"))
bash sheet.sh "$ID" "${TS[@]}" >/dev/null
echo "video: $E/work/$ID.mp4"
echo "sheet: $E/work/sheet_$ID.jpg (mốc ${TS[*]})"
