// Đồng bộ gói đăng <dir>/youtube/ lên Google Drive qua ứng dụng Google Drive for desktop (ổ G:, thư mục "My Drive").
//   node <SKILL>/scripts/drive-sync.mjs <dir> [<dir2> …]
// Chép mọi file trong youtube/ vào <DRIVE_ROOT>/<slug>/ (ghi ra file .part rồi đổi tên, để Drive không đồng bộ file dở).
// File đã có cùng kích thước và không cũ hơn bản gốc thì bỏ qua; file trên Drive khác mà MỚI hơn thì không đè, chỉ cảnh báo. Ứng dụng Drive tự tải lên mây ở nền.
// Đổi thư mục đích bằng biến môi trường TEO_DRIVE_DIR. pack.mjs tự gọi sau khi đóng gói thành công.
import { existsSync, mkdirSync, readdirSync, statSync, copyFileSync, renameSync, rmSync } from "fs";
import { join, resolve, basename } from "path";
import { pathToFileURL } from "url";

export const DRIVE_ROOT = process.env.TEO_DRIVE_DIR || "G:/My Drive/TeoTuuLau";
const SLACK = 2000; // ms — Drive làm tròn mtime, lệch nhỏ vẫn coi là cùng lúc

// Trả { dest, copied, skipped, newer } (newer = file trên Drive mới hơn bản gốc, KHÔNG đè — xoá tay trên Drive nếu muốn thay); ném lỗi nếu không thấy Drive hoặc thiếu youtube/.
export function syncToDrive(dir) {
  const src = join(dir, "youtube");
  if (!existsSync(src)) throw new Error(`thiếu ${src} — chạy bước đóng gói trước`);
  if (!existsSync(join(DRIVE_ROOT, ".."))) throw new Error(`không thấy ${join(DRIVE_ROOT, "..")} — mở ứng dụng Google Drive và đăng nhập rồi chạy lại drive-sync.mjs`);
  const dest = join(DRIVE_ROOT, basename(dir));
  mkdirSync(dest, { recursive: true });
  let copied = 0, skipped = 0; const newer = [];
  for (const f of readdirSync(src)) {
    const a = join(src, f), b = join(dest, f);
    const sa = statSync(a);
    if (!sa.isFile()) continue;
    if (existsSync(b)) { const sb = statSync(b); if (sb.size === sa.size && sb.mtimeMs >= sa.mtimeMs - SLACK) { skipped++; continue; }
      if (sb.mtimeMs > sa.mtimeMs + SLACK) { newer.push(f); continue; } } // bản trên Drive mới hơn bản gốc: không đè
    const part = b + ".part";
    copyFileSync(a, part);
    rmSync(b, { force: true });
    renameSync(part, b);
    copied++;
  }
  return { dest, copied, skipped, newer };
}

if (process.argv[1] && import.meta.url === pathToFileURL(process.argv[1]).href) {
  const dirs = process.argv.slice(2).filter((a) => !a.startsWith("--"));
  if (!dirs.length) { console.error("drive-sync: dùng: node drive-sync.mjs <dir> [<dir2> …]"); process.exit(1); }
  let bad = 0;
  for (const d of dirs) {
    try { const r = syncToDrive(resolve(d)); console.log(`drive: ${basename(d)} → ${r.dest} · chép ${r.copied}, bỏ qua ${r.skipped} (đã có)${r.newer.length ? ` · ⚠ trên Drive mới hơn, không đè: ${r.newer.join(", ")}` : ""}`); }
    catch (e) { console.error(`drive-sync: ${e.message}`); bad++; }
  }
  if (bad) process.exit(1);
}
