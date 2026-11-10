#!/usr/bin/env python3
"""Đọc kết quả tìm kiếm và danh sách đề xuất của YouTube, để biết video của mình chen vào được ở đâu.

    python3 kiem-hang.py "giang nam thất quái" "giang nam thất quái bị giết"     TRƯỚC khi chốt tiêu đề
    python3 kiem-hang.py --da-dang                                             SAU khi đăng ≥ 3 ngày: video dài đứng thứ mấy
    python3 kiem-hang.py --dang-len=teo-tuu-lau ["cụm thêm" …]                 MỖI TUẦN / khi chọn chủ đề: video nào đang lên để ké

Trước khi chốt tiêu đề: in 10 video đầu (lượt xem, kênh) và đánh giá độ cạnh tranh. "Khó" nghĩa là top 10 toàn video
≥ 100 nghìn lượt xem; khi đó đổi sang cụm dài và hẹp hơn (tên neo + góc riêng của tập), đặt nguyên văn ở đầu tiêu đề.
Video của 2 kênh Tèo (channel_id trong config.json) được đánh dấu ★.

--da-dang: với mỗi video dài trong state.json đã đăng từ 3 ngày (đổi bằng --ngay=N), tìm phần tiêu đề trước dấu ":"
hoặc "?" (bỏ đuôi | Tèo Kể và số phần), in vị trí video trong ~20 kết quả đầu và ghi thêm vào logs/hang.jsonl để so
về sau.

--dang-len=<kênh> (lai-la-teo-day | teo-tuu-lau): tìm các từ khoá của mảng kênh (NGACH bên dưới, thêm cụm bằng đối số),
lấy danh sách đề xuất của các video nổi nhất, rồi in các video ĐANG LÊN (đăng ≤ 60 ngày, không phải phim/clip, đúng
mảng) xếp theo lượt xem mỗi ngày. Đó là video để ké: làm tập cùng chủ đề với góc kể riêng, tiêu đề mang cụm đặc trưng
của nó (không chép nguyên tiêu đề), đăng khi nó còn nóng. Ghi kết quả vào logs/dang-len-<kênh>-<ngày>.json.
Luật ké: ideas/TIEU-DE-ANH-BIA.md mục 1e.

Kết quả lấy không đăng nhập nên không bị cá nhân hoá. Chỉ đọc trang công khai, không đụng gì tới kênh.
"""

import concurrent.futures as cf
import datetime
import json
import os
import re
import sys
import time
import urllib.parse
import urllib.request

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
KHO = 100_000  # lượt xem từ mức này coi là video "lớn"
NOI = 300_000  # video từ mức này coi là "nổi", lấy danh sách đề xuất của nó

# Mảng của từng kênh: từ khoá để quét, và mẫu nhận ra video đúng mảng.
NGACH = {
    "teo-tuu-lau": {
        "tim": ["kim dung", "võ công kim dung", "xếp hạng cao thủ kim dung", "thiên long bát bộ", "tiếu ngạo giang hồ",
                "ỷ thiên đồ long ký", "thần điêu đại hiệp", "lộc đỉnh ký", "tây du ký", "tam quốc diễn nghĩa", "thủy hử",
                "phong thần", "liêu trai", "cổ long"],
        "mang": r"(?<!hoàng )kim dung|cổ long|tây du|tam quốc|thủy hử|phong thần|liêu trai|hồng lâu|ngộ không|đường tăng|võ công|"
                r"kiếm hiệp|giang hồ|võ lâm|thiên long|thần điêu|xạ điêu|ỷ thiên|lộc đỉnh|tiếu ngạo|hiệp khách|cao thủ|"
                r"tào tháo|gia cát|quan vũ|lương sơn|tống giang",
    },
    "lai-la-teo-day": {
        "tim": ["lịch sử thế giới", "bí ẩn lịch sử", "lịch sử việt nam", "văn học việt nam", "chí phèo", "truyện kiều",
                "ai cập cổ đại", "phát minh vĩ đại", "thảm họa lịch sử", "người giàu nhất lịch sử", "vụ lừa đảo lớn nhất"],
        "mang": r"lịch sử|bí ẩn|văn học|truyện|chí phèo|kiều|nam cao|ai cập|pharaoh|phát minh|thảm họa|đế chế|chiến tranh|"
                r"triều|vua|danh nhân|toàn bộ|toàn cảnh|trong \d+ phút|tóm tắt",
    },
}
PHIM = re.compile(r"\bphim\b|tập \d|trích đoạn|vietsub|thuyết minh|lồng tiếng|review|\bfull\b|\(tm\)|\(uslt\)|trailer|"
                  r"music video|\bmv\b", re.I)
H = {"User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 Chrome/124 Safari/537.36",
     "Accept-Language": "vi"}


def tai(url):
    for lan in range(3):
        try:
            with urllib.request.urlopen(urllib.request.Request(url, headers=H), timeout=25) as r:
                return r.read().decode("utf-8", "replace")
        except Exception:
            if lan == 2:
                raise
            time.sleep(2)


def so(text):
    """'1.234.567 lượt xem' → 1234567; '1,6 triệu lượt xem' / '1,6 Tr' → 1600000; '271 nghìn' / '271 N' → 271000."""
    t = (text or "").lower().replace(",", ".")
    m = re.search(r"([\d.]+)\s*(triệu|tr|nghìn|n|k|m)?\b", t)
    if not m:
        return 0
    s, don_vi = m.group(1), m.group(2)
    if don_vi in ("triệu", "tr", "m"):
        return int(float(s) * 1_000_000)
    if don_vi in ("nghìn", "n", "k"):
        return int(float(s) * 1_000)
    return int(re.sub(r"\D", "", s) or 0)


def so_ngay(age):
    """'5 ngày trước' → 5; '1 tháng trước' → 30. Không đọc được (vd. đang phát trực tiếp) → None."""
    m = re.search(r"(\d+)\s*(giờ|ngày|tuần|tháng|năm)", age or "")
    return int(m.group(1)) * {"giờ": 1 / 24, "ngày": 1, "tuần": 7, "tháng": 30, "năm": 365}[m.group(2)] if m else None


def _video(o, out):
    """Gom video từ ytInitialData: videoRenderer (kết quả tìm), compactVideoRenderer và lockupViewModel (đề xuất)."""
    if isinstance(o, dict):
        v = o.get("videoRenderer") or o.get("compactVideoRenderer")
        if v and v.get("videoId"):
            tt = v.get("title", {})
            own = (v.get("ownerText") or v.get("longBylineText") or {}).get("runs", [{}])[0]
            vc = v.get("viewCountText") or {}
            out.append({
                "id": v["videoId"],
                "title": tt.get("simpleText") or "".join(r["text"] for r in tt.get("runs", [])),
                "channel": own.get("text", ""),
                "channel_id": own.get("navigationEndpoint", {}).get("browseEndpoint", {}).get("browseId", ""),
                "views": so(vc.get("simpleText") or "".join(r.get("text", "") for r in vc.get("runs", []))),
                "age": (v.get("publishedTimeText") or {}).get("simpleText", ""),
            })
        lv = o.get("lockupViewModel")
        if lv and lv.get("contentType") == "LOCKUP_CONTENT_TYPE_VIDEO":
            md = lv.get("metadata", {}).get("lockupMetadataViewModel", {})
            parts = [p for r in md.get("metadata", {}).get("contentMetadataViewModel", {}).get("metadataRows", [])
                     for p in r.get("metadataParts", [])]
            rows = [p.get("accessibilityLabel") or p.get("text", {}).get("content", "") for p in parts]
            out.append({
                "id": lv.get("contentId"),
                "title": md.get("title", {}).get("content", ""),
                "channel": rows[0] if rows else "",
                "channel_id": "",
                "views": so(next((x for x in rows if "lượt xem" in x), "")),
                "age": next((x for x in rows if "trước" in x), ""),
            })
        for x in o.values():
            _video(x, out)
    elif isinstance(o, list):
        for x in o:
            _video(x, out)


def _data(h):
    m = re.search(r"var ytInitialData = (\{.*?\});</script>", h)
    return json.loads(m.group(1)) if m else {}


def tim(q):
    """Video trên trang kết quả tìm kiếm: [{id, title, channel, channel_id, views, age}]."""
    out = []
    _video(_data(tai("https://www.youtube.com/results?hl=vi&gl=VN&search_query=" + urllib.parse.quote(q))), out)
    return out


def de_xuat(vid):
    """Danh sách đề xuất bên cạnh một video (cột phải trang xem)."""
    d = _data(tai(f"https://www.youtube.com/watch?v={vid}&hl=vi&gl=VN"))
    out = []
    _video(d.get("contents", {}).get("twoColumnWatchNextResults", {}).get("secondaryResults", {}), out)
    return out


def sp(n):
    """1234567 → '1.234.567' (chỉ đổi dấu trong con số, không đụng tiêu đề)."""
    return f"{n:,}".replace(",", ".")


def kenh_minh():
    p = os.path.join(ROOT, "config.json")  # máy chưa có yt-auto đầy đủ: coi như không có kênh nhà
    if not os.path.exists(p):
        return set()
    cfg = json.load(open(p))
    return {c.get("channel_id") for c in cfg.get("channels", {}).values() if c.get("channel_id")}


def la_minh(v, minh):
    return v["channel_id"] in minh or v["channel"] in ("Tèo Tửu Lâu", "Lại Là Tèo Đây")


def truoc_khi_dang(cum):
    minh = kenh_minh()
    for q in cum:
        vids = tim(q)[:10]
        if not vids:
            print(f"### {q}\n  (không đọc được kết quả: mất mạng hoặc YouTube đổi trang)\n")
            continue
        lon = sum(v["views"] >= KHO for v in vids)
        muc = "KHÓ" if lon >= 6 else "VỪA" if lon >= 3 else "DỄ"
        print(f"### {q}   →  cạnh tranh {muc}: {lon}/{len(vids)} video ≥ {KHO // 1000} nghìn lượt xem")
        for i, v in enumerate(vids, 1):
            sao = "★" if la_minh(v, minh) else " "
            print(f" {sao}{i:2d}. {sp(v['views']):>10s}  {v['title'][:70]}  · {v['channel']}")
        print()


def cum_chinh(title):
    t = re.sub(r"\s*(#shorts|\|\s*tèo kể|\(\s*(phần\s*)?\d+\s*/\s*\d+\s*\))", "", title, flags=re.I).strip()
    return re.split(r"[:?]", t)[0].strip().lower()


def sau_khi_dang(ngay):
    state = json.load(open(os.path.join(ROOT, "state.json")))
    nay = datetime.datetime.now()
    log = os.path.join(ROOT, "logs", "hang.jsonl")
    with open(log, "a") as f:
        for kenh, vids in state.items():
            for e in vids.values():
                if e.get("kind") != "long" or not e.get("url") or not e.get("scheduled"):
                    continue
                dang = datetime.datetime.fromisoformat(e["scheduled"])
                if (nay - dang).days < ngay:
                    continue
                vid = re.split(r"[/=]", e["url"])[-1]
                q = cum_chinh(e["title"])
                kq = tim(q)
                pos = next((i for i, v in enumerate(kq, 1) if v["id"] == vid), None)
                print(f"{kenh:15s} {('#' + str(pos)) if pos else 'ngoài ' + str(len(kq)):>9s}  \"{q}\"  ← {e['title']}")
                f.write(json.dumps({"ngay": nay.date().isoformat(), "kenh": kenh, "id": vid, "cum": q,
                                    "hang": pos, "so_kq": len(kq), "title": e["title"]}, ensure_ascii=False) + "\n")
    print(f"\nĐã ghi thêm vào {log}. Ngoài top 20 sau 3 ngày: cụm này quá rộng, tập sau dùng cụm hẹp hơn.")


def _an_toan(fn, x):
    try:
        return fn(x)
    except Exception:
        return []


def dang_len(kenh, them):
    if kenh not in NGACH:
        sys.exit(f"--dang-len=<kênh>: một trong {', '.join(NGACH)}")
    minh, mang = kenh_minh(), re.compile(NGACH[kenh]["mang"], re.I)
    cum = NGACH[kenh]["tim"] + them
    with cf.ThreadPoolExecutor(6) as ex:
        kq = dict(zip(cum, ex.map(lambda q: _an_toan(tim, q), cum)))
    noi = {}
    for vids in kq.values():
        for v in sorted(vids, key=lambda v: -v["views"])[:3]:
            if v["views"] >= NOI:
                noi[v["id"]] = v
    with cf.ThreadPoolExecutor(6) as ex:
        canh = dict(zip(noi, ex.map(lambda i: _an_toan(de_xuat, i), noi)))
    pool = {}
    for v in [v for vids in kq.values() for v in vids] + [r for rs in canh.values() for r in rs]:
        pool.setdefault(v["id"], v)
    rows = []
    for v in pool.values():
        d = so_ngay(v["age"])
        if d is None or d > 60 or not v["views"] or la_minh(v, minh) or "trực tiếp" in v["age"]:
            continue
        if PHIM.search(v["title"]) or PHIM.search(v["channel"]) or not mang.search(v["title"]):
            continue
        rows.append({**v, "ngay": round(d, 1), "moi_ngay": int(v["views"] / max(d, 1))})
    rows.sort(key=lambda r: -r["moi_ngay"])
    print(f"Video đang lên trong mảng {kenh} (≤ 60 ngày, không phải phim/clip), xếp theo lượt xem mỗi ngày.")
    print(f"Quét {len(cum)} từ khoá, {len(noi)} video nổi và đề xuất của chúng. Mở video để xem rồi chọn cái mình có góc kể riêng.\n")
    for r in rows[:30]:
        print(f"  {sp(r['moi_ngay']):>8s}/ngày  {sp(r['views']):>10s}  {r['age']:>14s}  {r['channel'][:16]:16s} {r['title'][:72]}"
              f"  https://youtu.be/{r['id']}")
    out = os.path.join(ROOT, "logs", f"dang-len-{kenh}-{datetime.date.today().isoformat()}.json")
    os.makedirs(os.path.dirname(out), exist_ok=True)
    with open(out, "w") as f:
        f.write(json.dumps(rows[:50], ensure_ascii=False, indent=1))
    print(f"\nĐã ghi {out}")


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    dl = next((a.split("=", 1)[1] for a in sys.argv[1:] if a.startswith("--dang-len=")), None)
    if dl:
        dang_len(dl, args)
    elif "--da-dang" in sys.argv:
        ngay = next((int(a[7:]) for a in sys.argv if a.startswith("--ngay=")), 3)
        sau_khi_dang(ngay)
    elif args:
        truoc_khi_dang(args)
    else:
        print(__doc__)
        sys.exit(1)


if __name__ == "__main__":
    main()
