#!/bin/bash
# Chạy một lệnh nặng (TTS voice.mjs hoặc render) trong 1 trong 2 suất máy dùng chung: tối đa 2 job nặng cùng lúc.
# Dùng: bash __MUSE_ROOT__/kiem-hiep/_tools/slot.sh "<tập> <bước>" <lệnh> [tham số...]
WHO=$1; shift
R=__MUSE_ROOT__/kiem-hiep
while :; do
  for n in 1 2; do
    if mkdir $R/_slot$n.lock 2>/dev/null; then SLOT=$R/_slot$n.lock; break 2; fi
  done
  sleep 30
done
echo "$WHO $(date +%H:%M)" > $SLOT/owner.txt
trap 'rm -rf $SLOT' EXIT
echo "slot $SLOT: $WHO"
"$@"
