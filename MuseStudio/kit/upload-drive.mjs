#!/usr/bin/env node
// Tự động đẩy thư mục youtube/ (video MP4, thumb, tags, mô tả, phụ đề) lên Google Drive
// Ưu tiên 1: Google Drive for Desktop (đồng bộ trực tiếp qua filesystem)
// Ưu tiên 2: rclone (nếu có cấu hình gdrive:)
//
// Sử dụng:
//   node kit/upload-drive.mjs videos/<slug>
//   node kit/upload-drive.mjs kiem-hiep/<slug>
import { existsSync, mkdirSync, cpSync, readdirSync, statSync } from "fs";
import { join, resolve, basename } from "path";
import { homedir } from "os";
import { spawnSync, execSync } from "child_process";

const args = process.argv.slice(2);
const dirArg = args.find((a) => !a.startsWith("--"));
if (!dirArg) {
  console.error("Dùng: node kit/upload-drive.mjs <thư_mục_video_hoặc_tập>");
  process.exit(1);
}

const dir = resolve(dirArg);
const ytDir = existsSync(join(dir, "youtube")) ? join(dir, "youtube") : dir;
const slug = basename(dir);

if (!existsSync(ytDir)) {
  console.error(`Lỗi: Không tìm thấy thư mục ${ytDir}`);
  process.exit(1);
}

// 1. Tìm thư mục Google Drive Desktop
function findGoogleDriveDesktop() {
  const cloudStorage = join(homedir(), "Library", "CloudStorage");
  if (existsSync(cloudStorage)) {
    try {
      const matches = readdirSync(cloudStorage).filter((f) => f.startsWith("GoogleDrive-"));
      for (const m of matches) {
        const myDrive = join(cloudStorage, m, "My Drive");
        if (existsSync(myDrive)) return myDrive;
      }
    } catch {}
  }
  const alt = join(homedir(), "Google Drive", "My Drive");
  if (existsSync(alt)) return alt;
  return null;
}

const desktopDrive = findGoogleDriveDesktop();
const folderName = process.env.DRIVE_FOLDER || "TeoKenhYoutube";

if (desktopDrive) {
  const destDir = join(desktopDrive, folderName, slug);
  console.log(`\n==> Tìm thấy Google Drive Desktop: ${desktopDrive}`);
  console.log(`==> Đang sao chép gói YouTube vào: ${destDir}...`);

  mkdirSync(destDir, { recursive: true });
  cpSync(ytDir, destDir, { recursive: true, force: true });

  console.log(`\n✅ Đã đồng bộ vào Google Drive: ${destDir}`);
  console.log(`   (Google Drive Desktop đang tự động tải ngầm lên đám mây)`);
  process.exit(0);
}

// 2. Nếu không có Google Drive Desktop, thử rclone
let hasRclone = false;
try {
  execSync("rclone --version", { stdio: "ignore" });
  hasRclone = true;
} catch {}

if (hasRclone) {
  try {
    const remotes = execSync("rclone listremotes", { encoding: "utf8" });
    const remoteName = process.env.RCLONE_REMOTE || (remotes.includes("gdrive:") ? "gdrive:" : null);
    if (remoteName) {
      const dest = `${remoteName}${folderName}/${slug}`;
      console.log(`\n==> Đang đẩy ${basename(ytDir)} lên Google Drive qua rclone: ${dest}...`);
      const r = spawnSync("rclone", ["copy", ytDir, dest, "--progress"], { stdio: "inherit" });
      if (r.status === 0) {
        console.log(`\n✅ Đã tải thành công lên Google Drive qua rclone: ${dest}`);
        process.exit(0);
      }
    }
  } catch {}
}

console.error("\n❌ Không tìm thấy Google Drive Desktop hoặc rclone remote.");
process.exit(1);
