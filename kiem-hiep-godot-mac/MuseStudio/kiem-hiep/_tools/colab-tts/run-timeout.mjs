// node run-timeout.mjs <giây> <lệnh> [tham số…]: chạy lệnh, quá giờ thì taskkill /T cả cây tiến trình và thoát mã 124.
// colab-tts.mjs gọi qua spawnSync: timeout của spawnSync chỉ giết colab.exe (trình khởi động), python con vẫn treo.
import { spawn, spawnSync } from "node:child_process";
const [sec, cmd, ...args] = process.argv.slice(2);
const c = spawn(cmd, args, { stdio: "inherit", detached: true });
const dog = setTimeout(() => {
  try { process.kill(-c.pid, "SIGKILL"); } catch {}
  process.exit(124);
}, Number(sec) * 1000);
c.on("exit", (code) => { clearTimeout(dog); process.exit(code ?? 1); });
c.on("error", (e) => { console.error(e.message); process.exit(1); });
