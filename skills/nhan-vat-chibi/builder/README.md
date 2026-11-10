# SVG Character Builder v1 — DeepSeek-only

Requires Node.js 18+. No npm packages.

PowerShell, from repository root:

```powershell
$env:DEEPSEEK_API_KEY = "YOUR_DEEPSEEK_API_KEY"
$env:DEEPSEEK_MODEL = "deepseek-chat"
node skills/nhan-vat-chibi/builder/builder.mjs init teo-kiem-khach
node skills/nhan-vat-chibi/builder/builder.mjs generate teo-kiem-khach --brief "Thieu hiep tre, toc den buoc cao, ao xanh ngoc nhieu lop, deo truong kiem"
node skills/nhan-vat-chibi/builder/builder.mjs validate teo-kiem-khach
node skills/nhan-vat-chibi/builder/builder.mjs preview teo-kiem-khach
```

Set DEEPSEEK_BASE_URL only to a DeepSeek endpoint. Generated revisions are timestamped and never overwrite previous SVGs.

v1 limitations: validation is a conservative structural check; preview is browser SVG, not PNG; groups are checked but not extracted; pivot editor, rig and Godot importer are not implemented. Human visual review is mandatory.
