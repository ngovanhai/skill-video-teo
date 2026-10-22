#!/bin/bash
# Render một tập kiếm hiệp an toàn trên Windows: lấy 1 trong 2 suất máy (slot.sh) → premix audio → render streaming, temp trên ổ E.
# Dùng: bash __MUSE_ROOT__/kiem-hiep/_tools/render.sh <dir> [tên-chủ-khoá]
D=$(cd "$1" && pwd); WHO=${2:-$(basename "$D")}
if [ -z "$IN_SLOT" ]; then IN_SLOT=1 exec bash __MUSE_ROOT__/kiem-hiep/_tools/slot.sh "$WHO render" bash "$0" "$@"; fi
export TMP=__MUSE_ROOT__/kiem-hiep/_tmp TEMP=__MUSE_ROOT__/kiem-hiep/_tmp HF_CAPTURE_PARALLEL_STREAM=true
cd "$D"; s=$(date +%s)
if [ ! -f index-mix.html ] || [ index.html -nt index-mix.html ]; then node __MUSE_ROOT__/kiem-hiep/_tools/premix.mjs . > work-render.log 2>&1 || { echo "premix fail"; exit 1; }; fi
npx --yes hyperframes@0.8.172 render -c index-mix.html --output renders/final.mp4 --quality standard --gpu >> work-render.log 2>&1
echo "render exit $? secs $(( $(date +%s)-s ))"
