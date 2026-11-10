# Wuxia Chibi Storybook — Hybrid Character Pipeline

Version: 1.0  
Status: design + production rules. This document does not claim automatic AI layer extraction, auto-rigging, or a finished sprite runtime exists. Those capabilities must be implemented and tested separately.

## 1. Mục tiêu

Tạo nhân vật hoạt hình kiếm hiệp chibi có chất lượng minh họa 2D vẽ tay: đầu lớn, mặt anime giàu biểu cảm, tóc và trang phục nhiều lớp, nếp vải có khối, silhouette võ thuật rõ. Phong cách lấy cảm hứng từ wuxia chibi storybook nhưng phải có nhận diện riêng cho Tèo Kể Kiếm Hiệp; không sao chép nguyên xi nhân vật hoặc sheet tham khảo.

Không để model ngôn ngữ tự vẽ SVG đơn giản rồi coi đó là hình hoàn chỉnh; không yêu cầu AI vẽ lại nhân vật ở mỗi cảnh; không dùng một ảnh sheet nhiều tư thế như sprite sheet animation trực tiếp.

## 2. Hai profile song song

| Profile | Dùng cho | Quy tắc |
|---|---|---|
| rig2-legacy | Nhân vật đang có trong data/chars.json, cảnh cũ | Giữ nguyên look, rig và render hiện tại |
| wuxia-storybook-hybrid | Nhân vật mới hoặc nhân vật được duyệt nâng cấp | AI concept + approved layered sprites + Godot rig/tween |

- Không tự động chuyển toàn bộ cast cũ.
- Mỗi nhân vật trong cast phải khai báo hoặc được suy ra rõ profile; nếu không rõ thì giữ legacy.
- Cảnh so sánh phải dùng cùng kịch bản, camera, thời lượng và độ phân giải.
- Chỉ đổi profile mặc định sau khi test chứng minh hybrid tốt hơn về chất lượng, tính nhất quán và chi phí sản xuất.

## 3. Visual identity rules

### 3.1 Tỷ lệ và hình khối
- Tỷ lệ mục tiêu: khoảng 2.5–3.2 đầu trên toàn thân tùy vai; không ép mọi nhân vật cùng một tỷ lệ.
- Đầu lớn, má đầy, cằm nhỏ; cổ và vai đủ rõ để đọc hướng xoay.
- Thân ngắn nhưng có lồng ngực, hông và trọng tâm phân biệt.
- Tay/chân có khối và khớp; bàn tay phải diễn được nắm, mở, chỉ, đỡ, cầm chuôi.
- Silhouette phải nhận diện được ở thumbnail đen trắng, không phụ thuộc hoa văn.
- Tránh thân hình như que, tay chân thẳng cứng, đầu dính trực tiếp vào thân.

### 3.2 Face identity
- Mỗi nhân vật có face ID: hình đầu, khoảng cách mắt, hình mí, lông mày, mũi, miệng, má, tai.
- Mắt có tròng/đồng tử/highlight; biểu cảm thay đổi bằng mí, lông mày, miệng và hướng nhìn, không chỉ đổi miệng.
- Không đổi khoảng cách mắt, dáng cằm hoặc vị trí tai giữa các góc.
- Tóc có khối chính, lớp sau/lớp trước, lọn tóc đặc trưng và phụ kiện; không thay kiểu tóc theo từng pose.
- Character sheet phải giữ cùng một tuổi cảm nhận, khí chất và dấu hiệu nhận dạng.

### 3.3 Costume and material
- Trang phục có cấu trúc: lớp trong, cổ giao lĩnh, thân áo, tay áo, đai, vạt, quần, giày/băng chân.
- Nếp gấp theo trọng lực, điểm neo và hướng chuyển động; không rải đường gấp ngẫu nhiên.
- Mỗi nhân vật có 1–3 dấu hiệu riêng: viền áo, hoa văn, nút buộc, phù hiệu, dây, vết sẹo hoặc phụ kiện.
- Hoa văn phải hỗ trợ nhận diện, không làm nhiễu silhouette.
- Chất liệu khác nhau cần cách tô khác nhau: vải mờ, da/giáp ít bóng, kim loại có highlight sắc.
- Palette gồm base / shadow / highlight / accent; giữ tương phản với nền và cast còn lại.

### 3.4 Line and shading
- Viền nâu đậm hoặc màu mực phù hợp palette; có phân cấp nét: silhouette rõ hơn chi tiết nội bộ.
- Tránh viền đen dày đồng nhất và tô phẳng một màu.
- Bóng đổ nhất quán theo một key light; có ambient fill nhẹ.
- Má ửng và chuyển sắc da vừa phải; không dùng bloom để thay cho shading.
- Khi render ở kích thước video, mắt, bàn tay, vũ khí và nếp áo quan trọng phải còn đọc được.

## 4. Character Identity Pack — đầu vào bắt buộc

Mỗi nhân vật hybrid có thư mục:

    art/character/<character-id>/
      identity.md
      prompts/
        master-prompt.md
        negative-prompt.md
      source/
        concept/
        turnaround/
        expressions/
        action-poses/
        costume-weapon/
      approved/
        hero-view.png
        turnaround-approved.png
        expression-approved.png
        action-poses-approved.png
        palette.png
      layers/
        source/
        cleaned/
      runtime/
        sprites/
        pivots.json
        rig-map.json
      review/
        review.md
        contact-sheet.png

Không ghi đè source. Mọi lần sửa tạo version mới hoặc lưu vào thư mục revision riêng.

### identity.md schema

Phải ghi:
- character_id, tên, tác phẩm, vai trò, tuổi cảm nhận, môn phái.
- profile: wuxia-storybook-hybrid.
- silhouette: chiều cao, tỷ lệ đầu/thân, dáng vai/hông, đặc điểm nhận diện.
- face_id: hình đầu, mắt, lông mày, mũi, miệng, tai, tàn nhang/sẹo.
- hair_id: kiểu, màu, búi/lọn, phụ kiện.
- costume_id: từng lớp áo, màu, viền, hoa văn, đai, giày.
- weapon_id: loại, kích thước tương đối, tay cầm, vị trí bao kiếm.
- palette: base/shadow/highlight/accent theo mã hex.
- asymmetry: các chi tiết không được lật gương.
- allowed_variants và forbidden_changes.
- reference_files trỏ tới asset đã duyệt.

## 5. AI image generation protocol

### 5.1 Thứ tự tạo

1. Master concept: một nhân vật, nền trơn, toàn thân, hero view 3/4, pose trung tính.
2. Identity approval: duyệt mặt, tóc, tỷ lệ, costume, palette, vũ khí. Không đạt thì sửa master concept trước.
3. Turnaround: front / 3-4 / side / back, cùng scale và cùng costume. Góc khuất không được tự bịa phụ kiện.
4. Expression sheet: tối thiểu 12 trạng thái; giữ nguyên cấu trúc mặt.
5. Action key-pose sheet: tối thiểu 12 pose riêng biệt, silhouette rõ; không yêu cầu AI tạo hàng loạt frame trung gian.
6. Costume & weapon sheet: chi tiết lớp áo, tay áo, đai, giày, vũ khí, bao kiếm, grip.
7. Layer decomposition: tách riêng từng bộ phận từ bản đã duyệt; sửa các vùng bị che bằng vẽ bổ sung, không để AI tự thay đổi toàn nhân vật.
8. Rig preparation: chuẩn hóa canvas, anchor, pivot, overlap và vùng khớp.
9. Godot test: preview các động tác cơ bản, sửa layer/pivot/rig trước khi sản xuất cảnh.

### 5.2 Prompt master template

Dùng nội dung dưới đây làm template, thay thông tin trong ngoặc vuông. Luôn đính kèm ảnh hero view đã duyệt khi sinh biến thể.

    Design one original wuxia chibi storybook character for a 2D animated series.
    Character: [name, role, personality, age impression, sect].
    Distinct identity: [face shape, eye shape, eyebrow, hair silhouette, signature detail].
    Body: expressive compact chibi anatomy, readable shoulders, hips, elbows, knees,
    hands and feet; balanced martial-arts proportions, not a stick figure.
    Costume: layered traditional Chinese martial-arts clothing, crossed collar,
    structured sleeves, sash, loose trousers, cloth footwear, designed folds and seams.
    Palette: [base], [shadow], [highlight], [accent].
    Weapon and grip: [weapon, dimensions, correct hand].
    Art direction: hand-drawn anime storybook illustration, warm refined linework,
    controlled line-weight hierarchy, soft cel shading with subtle gradients,
    clear material separation, expressive face, clean silhouette.
    Pose: neutral 3/4 hero view, full body, feet visible, arms slightly separated
    from torso, weapon unobstructed.
    Plain neutral background, no text, no labels, no watermark, no extra characters.
    Keep this design original; do not imitate a named copyrighted character.

### 5.3 Consistency prompt for sheets

    Use the attached approved hero-view image as the exact identity reference.
    Preserve the same face geometry, eye spacing, hair silhouette, costume layers,
    palette, body proportions, signature details and weapon design.
    Only change the requested camera angle or pose: [specify].
    Do not redesign, simplify, embellish, recolor or replace any identity feature.
    Show the complete body and keep the character scale consistent.

### 5.4 Negative constraints
- no extra fingers, missing fingers, fused hands, broken elbows/knees;
- no floating weapon, wrong grip, duplicated sheath, bent blade;
- no costume redesign, random ornaments, palette drift, hairstyle drift;
- no cropped feet, hidden hands, overlapping arms that destroy silhouette;
- no text, watermark, labels, collage borders or panel captions;
- no motion blur on master character sheet;
- no inconsistent face between views.

### 5.5 Sheet is not animation

Turnaround/expression/action sheets are reference boards only. Do not slice a collage into runtime frames. Every runtime layer/frame must be individually cleaned, aligned, named and approved.

## 6. Layering and pivot contract

Suggested logical layers (omit absent parts):
- shadow
- weapon_back, sheath
- hair_back
- leg_back_upper, leg_back_lower, foot_back
- torso, pants, robe_back, robe_front
- collar_inner, collar_outer, belt, sash_tail
- arm_back_upper, arm_back_lower, hand_back
- arm_front_upper, arm_front_lower, hand_front
- head, ear_front, hair_front, hair_accessory
- weapon_front, fx_attachment

Rules:
- Layer names are semantic, not numbered by arbitrary export order.
- Each layer has transparent background and identical canvas dimensions or explicit offset metadata.
- Pivot is stored in character-local coordinates; never infer pivot from cropped image bounds.
- Joint overlap hides seams at elbow, shoulder, wrist, hip, knee and ankle.
- Hands and weapon grips need dedicated pivot/attachment markers.
- Front/back sorting must be configurable for crossed arms and weapon arcs.
- Preserve original line quality and antialiasing; do not resize repeatedly.
- Keep source artwork at higher resolution than target render; downsample once at export.

### pivots.json example

    {
      "canvas": [1024, 1536],
      "origin": [512, 1450],
      "joints": {
        "shoulder_front": [650, 500],
        "elbow_front": [730, 690],
        "wrist_front": [770, 850],
        "hip": [512, 900],
        "knee_front": [600, 1160],
        "ankle_front": [610, 1370],
        "head_neck": [512, 410]
      },
      "attachments": {
        "weapon_grip": [770, 850],
        "sheath_anchor": [420, 920]
      }
    }

Coordinates above are illustrative only; measure actual artwork. Do not copy them as universal coordinates.

## 7. Godot hybrid runtime rules

Use native Godot nodes already available in the target project. A typical implementation may use:
- Node2D root for character placement and facing;
- Node2D / Sprite2D per layer with explicit z-index and pivot;
- Skeleton2D + Bone2D when bone deformation is useful;
- AnimationPlayer for authored pose/action clips;
- AnimationTree for blending/state transitions when the project needs it;
- Tween for short procedural accents, secondary motion and camera-independent offsets.

Do not add all these nodes blindly. Choose the smallest architecture that matches the project's actual Godot version and rendering setup. No unverified plugin dependency.

### Animation ownership
- Main pose/action belongs to authored animation clips or a deterministic pose evaluator.
- Tween is for small transitions, bounce, recoil, sash/hair follow-up, not the only source of complex fight choreography.
- Physics/root movement and visual pose must agree; avoid moving the root and feet independently in a way that causes sliding.
- Weapon is attached to a grip socket/pivot, not sprite center.
- Secondary motion follows primary movement with delay and damping; avoid random jitter.
- Every action can be evaluated at arbitrary timeline time. Use deterministic time and seeded randomness only; no dependence on previous rendered frame.

### Facing and asymmetry
- Do not horizontally flip a character if the design includes asymmetric insignia, scars, weapon hand, hair ornaments or costume details.
- Use alternate facing assets or a controlled 3/4 view when the shot needs the opposite side.
- Keep camera direction and screen direction consistent through a fight; check 180-degree continuity.

## 8. Action design contract

Every action clip must define:
1. start / anticipation;
2. action path and acceleration;
3. contact or passing point;
4. follow-through;
5. recovery / transition;
6. root motion and planted foot;
7. gaze, facial expression and target;
8. weapon grip / contact point;
9. secondary motion;
10. review timestamps.

A fight beat must communicate intent → movement → result. An attack is not complete until the target reacts or the miss/block is readable.

## 9. Review and acceptance gate

Review at native target resolution and at thumbnail scale.

### Identity
- face geometry, hair, palette, costume, accessories and weapon remain stable;
- silhouette distinguishes character from other cast members;
- no unintended mirror of asymmetric details.

### Asset
- layers have clean alpha, no halos, no white matte;
- pivots and overlaps hide joints;
- no missing pixels at extreme poses;
- line weight and shading remain consistent.

### Motion
- readable silhouette at key poses;
- anticipation and recovery are visible;
- planted feet do not slide;
- weapon follows grip and does not drift or pass through body;
- contact and opponent reaction line up;
- cloth/hair have delayed, damped secondary motion;
- no popping at clip transitions.

### Comparison

For first migration, create one identical 5–10 second scene in both profiles:
- same character role, action, camera, background, frame rate and output size;
- compare visual fidelity, identity stability, motion readability, render time, asset preparation time and ease of revision;
- do not declare hybrid the new default until the comparison is reviewed.

## 10. Versioning and migration
- Existing chars.json entries remain valid and are treated as legacy unless explicitly tagged otherwise.
- Never overwrite legacy SVG/rig exports during hybrid development.
- Hybrid metadata lives beside assets, not as undocumented extra keys in the legacy look object.
- Migration is per-character and reversible: retain old rig export and record the approved hybrid revision.
- If a hybrid asset fails or is unavailable, fall back to legacy explicitly and log the fallback in the scene notes.

## 11. Current implementation boundary

The existing char.mjs commands (kit, list, look, sheet, lineup) and rig2.mjs remain the legacy renderer. This document defines the hybrid production contract. It does not yet implement a sprite-layer importer, a pivot editor, an auto-rigger, a hybrid character runtime, or the 36 action clips as executable animations. Build and test those components incrementally; do not claim a capability is complete until code, sample project and rendered review prove it.
