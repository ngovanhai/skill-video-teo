#!/bin/bash
# Tạo chiêu mới từ file mẫu: new-move.sh <id> "<TÊN CHIÊU>"   -> engine/moves/<id>.gd
set -e
E="$(cd "$(dirname "$0")/../engine" && pwd)"
ID=$1; NAME=${2:-$1}
[ -n "$ID" ] || { echo "dùng: new-move.sh <id> \"<TÊN CHIÊU>\""; exit 1; }
[ -f "$E/moves/$ID.gd" ] && { echo "đã có moves/$ID.gd"; exit 1; }
sed "s/__TITLE__/$NAME/g" "$E/moves/_mau.gd" > "$E/moves/$ID.gd"
echo "$E/moves/$ID.gd"
