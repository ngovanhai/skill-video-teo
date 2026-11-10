#!/bin/bash
# Trộn SFX vào video một chiêu: ./mix.sh <move>  (work/<move>.mp4 -> renders/<move>.mp4)
# Mốc lấy từ work/<move>.sfx (engine ghi khi render: "<file> <giây thật> <volume>").
# Luật âm thanh chung (kit/lib/mix.mjs, người dùng chốt 2026-10-24): sfx là bản êm (kit/sfx-soft.mjs), mỗi tiếng ≤ 0.6,
# cả kênh lọc trầm < 180 Hz và chặn đỉnh -12 dBFS — không tiếng ùm ùm tùm tùm gây giật mình.
cd "$(dirname "$0")"
MV=${1:-hang_long}
[ -f "work/$MV.sfx" ] || { echo "thiếu work/$MV.sfx — render lại chiêu trước"; exit 1; }
EV=(); while IFS= read -r l || [ -n "$l" ]; do EV+=("$l"); done < "work/$MV.sfx"
args=(-v error -y -i "work/$MV.mp4"); fc=""; mix=""
for i in "${!EV[@]}"; do
  set -- ${EV[$i]}; args+=(-i "sfx/$1.mp3"); ms=$(awk "BEGIN{print int($2*1000)}"); v=$(awk "BEGIN{print ($3 > 0.6 ? 0.6 : $3)}")
  fc+="[$((i+1)):a]aresample=48000,volume=$v,adelay=${ms}|${ms}[a$i];"; mix+="[a$i]"
done
fc+="${mix}amix=inputs=${#EV[@]}:normalize=0,highpass=f=180:poles=2,highpass=f=180:poles=2,highpass=f=180:poles=2,alimiter=limit=0.25:level=false,apad[out]"
mkdir -p renders
ffmpeg "${args[@]}" -filter_complex "$fc" -map 0:v -map "[out]" -c:v copy -c:a aac -b:a 192k -shortest "renders/$MV.mp4"
echo "renders/$MV.mp4 (${#EV[@]} sfx)"
