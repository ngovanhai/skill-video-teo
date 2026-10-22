#!/bin/bash
# Tạo cảnh mới từ mẫu: new-canh.sh <id> ["mô tả"]   (ENGINE=<dự án> để tạo trong engine khác)
set -e
E="${ENGINE:-$(cd "$(dirname "$0")/../engine" && pwd)}"
ID=$1; [ -n "$ID" ] || { echo "thiếu id"; exit 1; }
F="$E/canh/$ID.gd"; [ -f "$F" ] && { echo "đã có $F"; exit 1; }
sed "s|__MO_TA__|${2:-$ID}|" "$E/canh/_mau.gd" > "$F"; echo "$F"
