---
name: nhan-vat-chibi
description: >-
  Tạo nhân vật chibi (rig2) từ mô tả bằng lời: viết look vào sổ nhân vật chung, xuất sheet soi
  (toàn thân, 5 tư thế, 9 biểu cảm, thử 5 nền) và ảnh xếp hàng so dáng. Một sổ dùng cho cả chuong-2d
  (clip chưởng Godot) và teo-kiem-hiep (cast {"char": id}). Dùng khi người dùng nói "tạo nhân vật",
  "vẽ nhân vật", "thêm nhân vật X", "nhân vật trông thế nào", "sửa áo/tóc/râu của X".
---

# Nhân vật chibi: tả bằng lời → look → sheet soi → dùng ở mọi engine

`SKILL = thư mục chứa file này`
- Sổ nhân vật: `SKILL/data/chars.json`, nguồn duy nhất cho mọi engine.
- Bộ vẽ: `__SKILLS_DIR__/teo-kiem-hiep/engine/rig2.mjs`, kiểu chibi phẳng mặt anime. Skill này không sửa rig2.
- Lệnh: `node SKILL/scripts/char.mjs <kit|list|look|sheet|lineup>`. Code ngoài lấy look qua `lookOf(id)` trong `scripts/lib.mjs`.

## Quy trình

1. **Đọc mô tả, tra truyện.** Tìm thân phận, tuổi, môn phái, tính cách và ngoại hình truyện tả (áo, tóc, râu, vũ khí).
   Với kiếm hiệp, xem thêm "ngoại hình gợi ý" trong `teo-kiem-hiep/data/chu-de.md`. Không vẽ giống diễn viên phim.
2. **Kiểm sổ.** Chạy `node SKILL/scripts/char.mjs list`.
   - Nhân vật đã có thì sửa entry cũ, không tạo trùng.
   - id viết không dấu, nối gạch: `diet-tuyet`.
3. **Phối look** theo bảng bên dưới. Thêm entry vào `data/chars.json`:
   `"id": { "name", "truyen", "note" (một dòng ngoại hình), "look": { "preset"?: …, …ghi đè } }`
   Chạy `char.mjs kit` để xem đủ giá trị hợp lệ.
4. **Xuất sheet:** `node SKILL/scripts/char.mjs sheet <id>`, rồi mở `SKILL/work/<id>.png` soi theo **Checklist**. Sửa và chạy lại đến khi đạt.
   - Nhân vật sẽ đứng cạnh người khác thì chạy thêm `char.mjs lineup <id> <id2> …` (ra `work/lineup.png`) để chắc hai bên khác nhau rõ.
   - Có mặt riêng (`ve.mjs` của tập teo-kiem-hiep) thì thêm `--ve <file>`.
5. **Dùng.** Xem mục "Dùng ở engine". Cho người dùng xem ảnh sheet khi nhân vật là yêu cầu chính.

## Bảng quy đổi mô tả → look

| mô tả | look |
|---|---|
| sư / hòa thượng / quốc sư | `preset: tang` (đầu trọc, chấm giới, cà sa + `sash`); đổi `robe` theo phe |
| đạo sĩ / chân nhân | `dao-si` (búi cao + trâm) |
| công tử / thiếu hiệp áo trắng | `cong-tu` |
| thư sinh | `thu-sinh` (khăn, quạt) |
| nữ hiệp / sư thái / cô nương | `nu-hiep` (`skirt`, tóc đuôi ngựa); ni cô: `hair troc` + `hat` trống, áo xám |
| sư phụ già hiền | `su-phu` (tóc bạc, râu dài trắng, `age: gia`) |
| lão ma / phản diện già | `lao-quai` |
| ăn mày / Cái Bang | `cai-bang` |
| cao thủ áo đen / sát thủ | `cao-thu` |
| lính / quan binh | `linh` |
| chủ quán / thương nhân | `chuong-quy` |
| đại hán / hảo hán | tự phối: `bui-toi` + `rau-de` + `band` (khăn trán), da `vang` |
| quái nhân / da tái | da `sang`, mắt lam lạnh, tóc `re-ngoi` |

- **Tuổi.** Già: `age: "gia"`, tóc và râu xám `#9A9A9A` hoặc trắng `#DADADA`. Trẻ: không râu, tóc đen.
- **Tính cách qua mắt.** Mắt là chỗ duy nhất đổi màu tự do.
  - Gian, độc: đỏ hoặc tím `#B02A3A`, `#7A2A8A`.
  - Hiền: nâu hoặc lục.
  - Lạnh: lam `#4A8BE0`.
  - Chính khí: nâu đậm.
- **Màu áo.**
  - Theo truyện, ví dụ Minh giáo đỏ trắng, Toàn Chân lam, Thiếu Lâm vàng.
  - Áo `robe` và cổ áo `robe2` nên tương phản sáng tối.
  - `pants` tối hơn áo.
  - `belt`, `sash` là màu nhấn, nên cùng tông với chiêu hoặc phe.
- **Vũ khí.** Clip chưởng và chiêu tay không dùng `weapon: "none"`. Kiếm khách dùng `kiem`, đao khách `dao`, đeo lưng thì thêm `sheath: true`.

## Checklist soi sheet

- [ ] Nhận ra thân phận trong một cái nhìn: sư trọc, đạo sĩ búi cao, nữ có váy…
- [ ] Có ít nhất một nét riêng (khăn trán, dải chéo, râu, màu mắt, vũ khí). Đặt cạnh nhân vật cùng preset trong `lineup` vẫn phân biệt được.
- [ ] Hàng thử nền: không bị chìm ở ít nhất 3/5 nền. Nếu chìm đúng nền sẽ dùng (vd áo tối trên nền đêm) thì đổi `robe` sáng hơn, hoặc ghi chú để engine chọn nền khác.
- [ ] 9 biểu cảm đọc được; râu, mũ, tóc không che mắt hay miệng.
- [ ] 5 tư thế không vỡ khớp; vũ khí (nếu có) theo tay `F`.
- [ ] Màu áo, màu mắt hợp truyện và tính cách; không trùng hệt phối màu của nhân vật khác trong sổ.

## Dùng ở engine

- **chuong-2d (Godot):** `node tools/export-chars.mjs <id>` trong `chuong-2d/engine` đọc thẳng `data/chars.json`, ra `chars/<id>.json`.
- **teo-kiem-hiep (rig 2):** trong `cast` của tap.json ghi `"x": { "char": "<id>", "name": "…" }`.
  build.mjs lấy nguyên look từ sổ (giữ cả robe2, pants, band, beardColor). Các khoá khác ghi cạnh `char` sẽ ghi đè lên look.
  Mặt riêng của tập (ve.mjs) vẫn áp lên như cũ.


## Profile mới: Wuxia Chibi Storybook (Hybrid)

Từ nay nhân vật mới mặc định dùng profile **wuxia-storybook-hybrid**; nhân vật cũ giữ nguyên profile **rig2-legacy** cho đến khi người dùng yêu cầu nâng cấp. Rule chi tiết và schema nằm ở HYBRID-PIPELINE.md.

### Luật bắt buộc cho nhân vật mới

1. Tạo **Character Identity Sheet** trước khi tạo asset: silhouette, tỷ lệ, khuôn mặt, tóc, costume, bảng màu, vật liệu, vũ khí, dấu hiệu nhận dạng. Khóa các đặc điểm không được đổi.
2. AI tạo concept sheet và pose sheet theo cùng một character reference; không dùng prompt độc lập không có ảnh tham chiếu cho từng pose. Không lấy sheet ghép nhiều góc làm sprite sheet animation.
3. Character sheet tối thiểu: front / 3-4 view / side / back; 12 biểu cảm; 12 action key poses; costume & weapon details; palette swatches. Các view phải cùng tỷ lệ và trang phục.
4. Chọn một **hero view** (3/4 view) làm chuẩn. Duyệt khuôn mặt, tóc, trang phục, silhouette và tỷ lệ trước khi tách lớp.
5. Tách asset theo layer có pivot rõ: head, hair_back, hair_front, torso, collar, sleeve_F/B, upper_arm_F/B, forearm_F/B, hand_F/B, belt, sash, robe_panels, pants, thigh/shin/foot_F/B, weapon, sheath, shadow. Layer không có trong thiết kế thì bỏ; không tạo layer giả.
6. Giữ một bản gốc bất biến: art/character/<id>/source/; file đã duyệt ở approved/; file runtime/export ở runtime/. Không ghi đè source khi sửa.
7. AI không tự đổi mặt, màu, tóc, hoa văn, tỷ lệ, tay cầm vũ khí giữa các asset. Nếu asset lệch identity sheet, phải sửa asset trước khi rig.
8. Rig2 cũ vẫn được dùng cho cast legacy, preview nhanh và cảnh không cần độ chi tiết cao. Không âm thầm chuyển nhân vật cũ sang hybrid.
9. Ưu tiên sprite layer + pivot + bone/IK + tween cho chuyển động; chỉ dùng frame-by-frame sprite khi động tác cần biến dạng vải/tóc hoặc silhouette không thể đạt bằng rig. Không sinh ảnh mới cho mọi frame.
10. Chỉ đưa asset vào cast khi đạt checklist trong HYBRID-PIPELINE.md; nếu chưa đạt, đánh dấu WIP và không dùng ở render cuối.

### Lệnh và khả năng thực tế

Các lệnh char.mjs kit|list|look|sheet|lineup hiện tại vẫn là workflow rig2. Không được bịa thêm lệnh như hybrid-export hoặc auto-rig nếu repo chưa có script tương ứng. Khi triển khai một pipeline asset mới, trước tiên kiểm tra công cụ có thật trong repo; thiếu công cụ thì tạo checklist/manual handoff và nêu rõ bước thủ công.


## DeepSeek-only drawing mode

Khi dùng profile wuxia-storybook-hybrid, chỉ dùng DeepSeek làm model AI. DeepSeek sinh SVG vector chi tiết theo HYBRID-PIPELINE.md; không gọi model tạo ảnh bên ngoài. Không chấp nhận SVG dạng stick figure/icon hoặc placeholder vài hình học. Mỗi nhân vật cần identity lock, semantic layers, pivot metadata và preview render. Nếu endpoint không có vision thì không giả vờ đã nhìn thấy ảnh; yêu cầu người dùng review hoặc dùng endpoint DeepSeek có vision.


## Local SVG Character Builder (DeepSeek-only)

For the Hybrid profile, use the local builder in `builder/` from the repository root:

```powershell
node skills/nhan-vat-chibi/builder/builder.mjs init <character-id>
node skills/nhan-vat-chibi/builder/builder.mjs generate <character-id> --brief "..."
node skills/nhan-vat-chibi/builder/builder.mjs validate <character-id>
node skills/nhan-vat-chibi/builder/builder.mjs preview <character-id>
```

Set `DEEPSEEK_API_KEY` in the current shell before generate. The builder saves timestamped SVG revisions under `art/characters/<id>/source/`; it never overwrites approved art. Validation is structural only and preview requires human visual review. Read `builder/README.md` for requirements and current v1 limitations. This tool does not yet extract individual layer files, create pivots, export PNG or import a rig into Godot.


## SVG layer export and Godot cutout rig

After a DeepSeek SVG passes structural validation, export semantic groups:

```powershell
$character = "teo-kiem-khach"
$latest = Get-Content "art/characters/$character/source/LATEST"
$svg = "art/characters/$character/source/$latest/master.svg"
python skills/nhan-vat-chibi/builder/split_layers.py $svg --out "art/characters/$character/layers"
```

The splitter exports aligned SVG layers and `pivots.json`. Missing required groups are a hard failure. Copy `layers/` into Godot `res://`, attach `builder/godot/character_svg_rig.gd` to a Node2D, and set its manifest path. All pivot coordinates are initial estimates and require manual visual adjustment. Read `builder/LAYER-RIG.md` for setup and limitations. This first rig rotates whole limbs; it is not yet a full elbow/knee segmented rig.


## Full-body segmented rig (v2, optional)

For characters that need independent elbow, wrist, knee and ankle motion, use `builder/split_full_body.py` instead of the simpler 11-layer splitter. DeepSeek must create 21 top-level SVG groups with the exact IDs documented in `builder/FULL-BODY-RIG.md`. Each segment needs hidden overlap geometry beneath the adjacent segment; otherwise rotations expose gaps.

Export with:

```powershell
python skills/nhan-vat-chibi/builder/split_full_body.py path\to\master.svg --out art\characters\<id>\full-body
```

Copy the output into Godot `res://`, attach `builder/godot/full_body_rig.gd` to a Node2D, and set `manifest_path`. This rig supports separate upper/lower arms, hands, thighs, shins and feet. Pivots are generic starter coordinates and must be adjusted per character. Starter sword actions are in `builder/actions/sword_actions.json`; load a selected action's `keyframes` and pass them to `play_action()`. See `builder/FULL-BODY-RIG.md` for limitations. Keep the original rig2 and v1 path as fallback until a real Godot test scene passes.


## Wuxia Action Library (33 reusable actions)

Use `builder/actions/wuxia_action_library.json` with the segmented Full Body Rig. It contains 33 keyframe actions across movement, swordplay, defense, qinggong and acting. Attach `builder/godot/action_library.gd` to a Node, configure `library_path` and `rig_path`, then call `$ActionLibrary.play("slash_horizontal")`. See `builder/actions/README.md` for IDs and integration.

Camera and FX fields are cues for the scene director only; they are not automatically executed. Match contact/peak keyframes with sword trails, impact sounds and camera shake. Always inspect the motion at multiple timestamps and adjust angles for the character's facing direction and proportions. This is a reusable motion-blocking library, not a finished choreography pack.


## Character Registry — auto-discovery for new characters

The registry at `art/characters/registry.json` is the authoritative index for Hybrid characters. Do not infer identity from a display name or create a second folder for an existing ID.

### Automatic resolution rule
When a script, episode brief, storyboard or cast request mentions a character:
1. Normalize the requested name to a stable ASCII kebab-case ID and search the registry first.
2. If the ID exists, reuse its `identity.json`, approved revision and asset directory. Never call `init` for an existing character.
3. If it does not exist, create a new workspace with `ensure <id> --name "..." --brief "..." `, then use DeepSeek to generate its first SVG.
4. A character is eligible for production cast only when `status=approved` and `approved_revision` is set. Draft/WIP characters must be listed as pending and must not be silently replaced by a preset or another character.
5. Revisions preserve the character ID and identity lock. A new design that changes face, hair, costume or weapon materially requires explicit human approval again.

### Commands (repository root)
```powershell
# Show known characters
node skills/nhan-vat-chibi/builder/builder.mjs list

# Reuse if present; otherwise create exactly one new profile
node skills/nhan-vat-chibi/builder/builder.mjs ensure tieu-phong --name "Tiêu Phong" --brief "Nam hiệp khất bang, dáng cao chắc, tóc đen, áo nâu đỏ, khí chất hào sảng"

# Generate with DeepSeek only, then validate and preview
node skills/nhan-vat-chibi/builder/builder.mjs generate tieu-phong
node skills/nhan-vat-chibi/builder/builder.mjs validate tieu-phong
node skills/nhan-vat-chibi/builder/builder.mjs preview tieu-phong

# After a human has inspected the artwork
node skills/nhan-vat-chibi/builder/builder.mjs approve tieu-phong --human-reviewed
node skills/nhan-vat-chibi/builder/builder.mjs cast tieu-phong --actor-id tieu
```

The `cast` command writes a cast-entry.json referencing the approved immutable revision. Copy its fields into the episode's `godot/cast.json` / character manifest as required by that episode's runtime. It does not automatically alter legacy `chars.json` or convert old rig2 characters.

### Required context passed to every scene
Each scene/shot request must carry `character_id`, approved `revision`, `identity.json` (or its locked traits), and the same approved master asset. Use the ID as the key, not the character's name. A scene may change pose, expression, camera and lighting; it may not change identity traits. For a newly named character, run the registry resolution step before generating storyboards or art.
