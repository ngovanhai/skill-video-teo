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


## Character registry and auto-discovery

The builder now maintains `art/characters/registry.json`. The episode workflow should resolve each character by stable ID before making a storyboard or cast. Existing IDs are reused; missing IDs are initialized once; draft characters are not production-ready.

```powershell
# List existing characters
node skills/nhan-vat-chibi/builder/builder.mjs list

# Ensure a character exists (create if missing, reuse if present)
node skills/nhan-vat-chibi/builder/builder.mjs ensure tieu-phong --name "Tiêu Phong" --brief "Nam hiệp khất bang, tóc đen, áo nâu đỏ, khí chất hào sảng"

# DeepSeek creates the first vector master
node skills/nhan-vat-chibi/builder/builder.mjs generate tieu-phong
node skills/nhan-vat-chibi/builder/builder.mjs validate tieu-phong
node skills/nhan-vat-chibi/builder/builder.mjs preview tieu-phong

# Human review gate; required before production cast
node skills/nhan-vat-chibi/builder/builder.mjs approve tieu-phong --human-reviewed
node skills/nhan-vat-chibi/builder/builder.mjs cast tieu-phong --actor-id tieu
```

`ensure` never creates a duplicate if the ID already exists. Every generated revision is preserved. A new revision resets approval; review it again before casting. `cast` emits a manifest that points to the exact approved revision; it does not silently migrate legacy rig2 characters.

DeepSeek-only remains enforced: missing API credentials or an invalid SVG is an error, never a fallback to another image provider.

## Current boundary

This workflow provides registry discovery, identity metadata, SVG generation, structural validation, manual approval, and cast-manifest generation. It does **not** yet automatically split the approved SVG into the 21 runtime segments, adjust pivots, or wire the manifest into an existing Godot episode project. Those are still explicit export/integration steps.
