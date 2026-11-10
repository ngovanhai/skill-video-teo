// Giọng đọc Tèo: khoá cache + tra manifest <dir>/voice/voice.json (do scripts/voice.mjs tạo).
import { readFileSync, existsSync } from "fs";
import { join } from "path";
import { createHash } from "crypto";

export const DEFAULT_VOICE = "tiendat"; // giọng Tiến Đạt có sẵn của ZeroTTS (người dùng chốt 2026-11-03, trước là "Lóng")
// Lời đọc = chữ đã bỏ emoji/ký hiệu, gộp khoảng trắng (VieNeu đọc số 1428 đúng nên giữ số)
export const spoken = (s) => String(s).replace(/[\p{Extended_Pictographic}\u{FE0F}*_#~^|<>]/gu, " ").replace(/\s+/g, " ").trim();
// Lời Tèo đọc ở một beat (lời kể vo). Card luôn được đọc: không ghi vo thì đọc tiêu đề, dòng phụ và từng dòng của thẻ.
export const cardVo = (b) => [b.title, b.sub, ...(b.lines || [])].filter(Boolean).map((x) => String(x).replace(/\s*·\s*/g, ", ").replace(/[.;:!?…\s]+$/, "")).join(". ") + ".";
export const voOf = (b) => b.vo || (b.do === "card" ? cardVo(b) : null);
export const keyOf = (voice, text) => createHash("sha1").update(voice + "|" + spoken(text)).digest("hex").slice(0, 12);

// Trả hàm tra (text) → { file, dur } | null. Không có manifest → luôn null (build chạy như cũ, không giọng).
export function loadVoice(dir, voice = DEFAULT_VOICE) {
  const f = join(dir, "voice", "voice.json");
  if (!existsSync(f)) return null;
  const m = JSON.parse(readFileSync(f, "utf8"));
  const v = m.voice || voice;
  const get = (text) => (text ? m.lines[keyOf(v, text)] || null : null);
  get.voice = v;
  return get;
}
