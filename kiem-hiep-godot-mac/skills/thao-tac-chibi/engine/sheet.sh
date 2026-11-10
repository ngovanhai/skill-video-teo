#!/bin/bash
# sheet.sh <id> [mốc giây…] → work/sheet_<id>.jpg (2 cột)
ID=$1; shift; TS=("$@"); [ ${#TS[@]} -eq 0 ] && TS=(0.5 2.5 4.5 6.5)
i=0; for s in "${TS[@]}"; do ffmpeg -v error -y -ss "$s" -i "work/$ID.mp4" -frames:v 1 -vf scale=960:-1 "work/_s$i.jpg"; i=$((i+1)); done
ffmpeg -v error -y -i work/_s%d.jpg -vf "tile=2x$(( (i+1)/2 ))" -frames:v 1 "work/sheet_$ID.jpg"; rm -f work/_s*.jpg; echo work/sheet_$ID.jpg
