#!/usr/bin/env python3
"""Tìm cụm từ người Việt hay gõ trên ô tìm kiếm YouTube, để đưa vào tiêu đề và tag.

    python3 tu-khoa.py "lời nguyền tutankhamun" "pharaoh ai cập" "tutankhamun"
    python3 tu-khoa.py --json "giang nam thất quái" "kim dung"
    python3 tu-khoa.py --bo=naga,25071990 "cổ long" "lý tầm hoan"     (bỏ gợi ý chứa các chữ này: trùng tên, game…)

Lấy gợi ý tự động (autocomplete) của YouTube cho từng từ gốc, và cho từ gốc ghép thêm các từ người ta hay gõ kèm
("là ai", "có thật", "vì sao"…), như khi người dùng gõ dần. YouTube xếp gợi ý phổ biến lên trước, nên một cụm càng
hay xuất hiện và càng đứng đầu thì điểm càng cao. Đây là tín hiệu tương đối (cụm nào được gõ nhiều HƠN), không phải
số lượt tìm kiếm thật.
"""

import json
import sys
import time
import unicodedata
import urllib.parse
import urllib.request
from collections import defaultdict

URL = "https://suggestqueries.google.com/complete/search?client=firefox&ds=yt&hl=vi&gl=VN&q="
# Từ người Việt hay gõ kèm khi tìm video kể chuyện, lịch sử, kiếm hiệp.
DUOI = ["", "là ai", "có thật", "vì sao", "bí ẩn", "sự thật", "lịch sử", "câu chuyện", "mạnh nhất", "vs",
        "chết", "bị giết", "kết cục", "ai mạnh hơn", "võ công", "là gì", "kể chuyện", "tóm tắt", "phim", "giải thích"]
# Gợi ý chứa các chữ này gần như luôn là game / thứ trùng tên, không phải người tìm chuyện. Thêm bằng --bo=a,b.
NHIEU = ["gameplay", "pvp", "mobile", "game", "vl1", "tik tok"]
# Dấu hiệu một gợi ý là CÂU HỎI người xem mang theo (chết thế nào, ai mạnh hơn…): tiêu đề nên trả lời đúng câu này.
HOI = ["chết", "bị giết", "vì sao", "tại sao", "là ai", "là gì", "có thật", "ai mạnh", "mạnh nhất", "kết cục",
       "sự thật", "bí ẩn", "vs", "và"]


def goi_y(q):
    try:
        with urllib.request.urlopen(URL + urllib.parse.quote(q), timeout=10) as r:
            return json.loads(r.read().decode("utf-8", "replace"))[1]
    except Exception:
        return []


def bo_dau(s):
    s = unicodedata.normalize("NFD", s.replace("đ", "d").replace("Đ", "D"))
    return "".join(c for c in s if unicodedata.category(c) != "Mn")


def co_dau(s):
    return bo_dau(s) != s


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    as_json = "--json" in sys.argv
    bo = NHIEU + [w.strip().lower() for a in sys.argv[1:] if a.startswith("--bo=") for w in a[5:].split(",") if w.strip()]
    if not args:
        print(__doc__)
        sys.exit(1)

    diem = defaultdict(float)       # cụm gợi ý đầy đủ → điểm
    lan = defaultdict(int)          # cụm gợi ý → số lần xuất hiện
    for goc in args:
        for duoi in DUOI:
            q = f"{goc} {duoi}".strip()
            for i, s in enumerate(goi_y(q)):
                s = s.strip().lower()
                if s == q.lower() or any(w in s for w in bo):
                    continue
                diem[s] += 10 - i
                lan[s] += 1
            time.sleep(0.15)

    # Cụm con 2–6 chữ chung của nhiều gợi ý: đó là phần người ta gõ giống nhau nhất.
    cum = defaultdict(float)
    for s, d in diem.items():
        w = s.split()
        seen = set()
        for n in range(2, 7):
            for k in range(len(w) - n + 1):
                c = " ".join(w[k:k + n])
                if c not in seen:
                    seen.add(c)
                    cum[c] += d
    goc_set = {g.lower() for g in args}
    cum = {c: d for c, d in cum.items() if c not in goc_set}
    # Tiếng Việt nhiều từ ghép 2 âm tiết, nên "pharaoh ai" hay "cập cổ" chỉ là mảnh của "pharaoh ai cập cổ đại".
    # Bỏ cụm nào nằm gọn trong một cụm dài hơn có điểm gần bằng (≥ 90%).
    cum = {c: d for c, d in cum.items()
           if not any(c != o and f" {c} " in f" {o} " and od >= 0.9 * d for o, od in cum.items())}

    if not diem:
        print("Không lấy được gợi ý nào từ YouTube (mất mạng, bị chặn, hoặc sandbox không cho ra mạng). "
              "Ghi rõ điều này vào ghi chú của tập, đừng bịa từ khoá.", file=sys.stderr)
        sys.exit(2)
    top_goi_y = sorted(diem.items(), key=lambda x: -x[1])[:25]
    top_cum = sorted(cum.items(), key=lambda x: -x[1])[:20]
    khong_dau = [s for s, _ in top_goi_y if not co_dau(s) and any(co_dau(g) for g in args)][:8]
    # Câu hỏi: gợi ý có tên neo + một dấu hiệu hỏi. "và"/"vs" chỉ tính khi ghép hai tên (cặp người ta hay so).
    goc_l = [g.lower() for g in args]
    cau_hoi = [(s, d) for s, d in sorted(diem.items(), key=lambda x: -x[1])
               if any(g in s for g in goc_l) and any(f" {h} " in f" {s} " for h in HOI)][:10]

    if as_json:
        print(json.dumps({"goi_y": top_goi_y, "cum": top_cum, "cau_hoi": cau_hoi, "khong_dau": khong_dau},
                         ensure_ascii=False, indent=1))
        return
    print("== Gợi ý YouTube được gõ nhiều nhất (điểm cao = hay xuất hiện, đứng đầu):")
    for s, d in top_goi_y:
        print(f"  {d:5.0f}  {s}")
    print("\n== Cụm chung nhiều gợi ý nhất (ưu tiên đưa vào 40 ký tự đầu tiêu đề):")
    for c, d in top_cum:
        print(f"  {d:5.0f}  {c}")
    if cau_hoi:
        print("\n== Người xem đang hỏi gì về tên neo (tiêu đề nên trả lời câu cao điểm nhất mà video trả lời được):")
        for c, d in cau_hoi:
            print(f"  {d:5.0f}  {c}")
    if khong_dau:
        print("\n== Người ta cũng gõ không dấu (thêm vào tag):")
        for s in khong_dau:
            print(f"         {s}")


if __name__ == "__main__":
    main()
