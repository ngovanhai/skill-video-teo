#!/bin/bash
# Chép engine sang thư mục truyện/tập mới (không đụng engine gốc của skill): new-project.sh <thư mục>
# Sau đó: ENGINE=<thư mục> bash check.sh <id>
set -e
SRC="$(cd "$(dirname "$0")/../engine" && pwd)"; D=$1; [ -n "$D" ] || { echo "thiếu thư mục"; exit 1; }
mkdir -p "$D"; cp -r "$SRC"/project.godot "$SRC"/main.gd "$SRC"/main.tscn "$SRC"/rec.gd "$SRC"/canh.gd "$SRC"/chibi.gd "$SRC"/sheet.sh "$SRC"/*.uid "$SRC"/chars "$D"/
mkdir -p "$D/canh" "$D/work"; cp "$SRC/canh/_mau.gd" "$D/canh/"
echo "$D (chép cảnh mẫu cần tham khảo từ $SRC/canh/ nếu muốn kế thừa nền)"
