// Tiêu đề YouTube dùng chung cho mọi skill Tèo (video-teo, teo-kiem-hiep, teo-kiem-hiep-godot).
// Luật: __MUSE_ROOT__/ideas/TIEU-DE-ANH-BIA.md mục 1d.
//   import { ganDuoi, kiemTieuDe } from "__MUSE_ROOT__/yt-auto/tools/tieu-de.mjs";
//   ganDuoi("Nhạc Bất Quần Chết Ra Sao? | Tèo Kể")         → "Nhạc Bất Quần Chết Ra Sao? | Tèo Kể"
//   ganDuoi("Thầy Mù Đánh Trong Đêm #Shorts", true)       → "Thầy Mù Đánh Trong Đêm #Shorts | Tèo Kể"
//   kiemTieuDe(title, { thumb: "16 NĂM DƯỚI VỰC" })        → { err: [...], warn: [...] }

export const BRAND = "Tèo Kể";
export const MAX = 60;

// Bỏ đuôi cũ người viết lỡ ghi (| Tèo Kể, #Shorts, ở bất kỳ thứ tự nào) rồi gắn đuôi chuẩn:
// video dài "… | Tèo Kể", Shorts "… #Shorts | Tèo Kể".
export function ganDuoi(title, short = false) {
  const core = String(title || "")
    .replace(/#shorts\b/gi, " ")
    .replace(/\|\s*tèo kể/gi, " ")
    .replace(/\s+/g, " ")
    .replace(/[\s|]+$/, "")
    .trim();
  return `${core}${short ? " #Shorts" : ""} | ${BRAND}`;
}

const tu = (s) => String(s || "").toLowerCase().normalize("NFC").match(/[\p{L}\p{N}]+/gu) || [];
const EMOJI = /\p{Extended_Pictographic}/u;
// Chữ được phép viết thường giữa tiêu đề Viết Hoa Từng Chữ.
const THUONG = new Set(["vs"]);

// Kiểm tiêu đề ĐÃ gắn đuôi. err = phải sửa, warn = nên xem lại.
export function kiemTieuDe(title, { thumb = "" } = {}) {
  const err = [], warn = [];
  // " #Shorts" không tính vào giới hạn (giữ như luật cũ của Shorts): phần tự viết tối đa 51 ký tự cho cả hai loại.
  const n = [...title.replace(/\s*#shorts\b/i, "")].length;
  if (n > MAX) err.push(`tiêu đề ${n} ký tự > ${MAX} (không tính #Shorts): ${title}`);
  if (EMOJI.test(title)) err.push(`tiêu đề có emoji: ${title}`);
  const core = title.replace(/\s*#shorts\b/i, "").replace(/\s*\|\s*tèo kể\s*$/i, "");
  const words = core.match(/[\p{L}][\p{L}\p{M}]*/gu) || [];
  const hoa = words.filter((w) => w.length > 1 && w === w.toUpperCase());
  if (hoa.length >= 3 && hoa.length >= words.length / 2) err.push(`tiêu đề viết HOA toàn bộ: ${title}`);
  const thuong = words.filter((w) => w[0] !== w[0].toUpperCase() && !THUONG.has(w));
  if (thuong.length) warn.push(`chưa Viết Hoa Từng Chữ (${thuong.slice(0, 4).join(", ")}): ${title}`);
  const t = tu(thumb);
  if (t.length) {
    const c = new Set(tu(core));
    const chung = t.filter((w) => c.has(w)).length;
    if (chung / t.length > 0.5) warn.push(`chữ ảnh bìa "${thumb}" lặp ${chung}/${t.length} từ của tiêu đề: phải là câu khác, bổ sung cho tiêu đề`);
  }
  return { err, warn };
}
