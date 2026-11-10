# Wuxia Chibi Storybook — Hybrid Character Pipeline

Version: 1.0  
Status: design + production rules. This document does not claim automatic AI layer extraction, auto-rigging, or a finished sprite runtime exists. Those capabilities must be implemented and tested separately.

## 1. Mục tiêu

Tạo nhân vật hoạt hình kiếm hiệp chibi có chất lượng minh họa 2D vẽ tay: đầu lớn, mặt anime giàu biểu cảm, tóc và trang phục nhiều lớp, nếp vải có khối, silhouette võ thuật rõ. Phong cách lấy cảm hứng từ wuxia chibi storybook nhưng phải có nhận diện riêng cho Tèo Kể Kiếm Hiệp; không sao chép nguyên xi nhân vật hoặc sheet tham khảo.

Không dùng SVG sơ sài vài hình cơ bản làm hình hoàn chỉnh; DeepSeek phải sinh vector có tạo hình, đường nét, shading và layer đủ chi tiết. Không yêu cầu AI vẽ lại nhân vật ở mỗi cảnh; không dùng một ảnh sheet nhiều tư thế như sprite sheet animation trực tiếp.

## 2. Hai profile song song

| Profile | Dùng cho | Quy tắc |
|---|---|---|
| rig2-legacy | Nhân vật đang có trong data/chars.json, cảnh cũ | Giữ nguyên look, rig và render hiện tại |
| wuxia-storybook-hybrid | Nhân vật mới hoặc nhân vật được duyệt nâng cấp | DeepSeek-authored SVG layers + Godot rig/tween |

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
- allowed_variants và forbid## 5. DeepSeek-only vector character production

### 5.1 Hard constraint: one model provider
- Chỉ sử dụng DeepSeek làm model AI trong pipeline: thiết kế, phân tích ảnh tham chiếu (nếu endpoint DeepSeek đang dùng hỗ trợ vision), viết SVG, sửa SVG, tạo metadata, thiết kế pose và animation.
- Không gọi Midjourney, DALL·E, GPT Image, Stable Diffusion, Flux, ComfyUI hoặc bất kỳ image-generation model/provider nào khác.
- Godot, SVG renderer, script xử lý asset và công cụ kiểm tra là phần mềm thực thi, không phải model AI thay thế.
- DeepSeek không được giả vờ đã tạo PNG. Đầu ra hình ảnh của nó là mã vector/SVG hoặc mã/script có thể kiểm tra; Godot hoặc SVG renderer rasterize thành texture khi chạy/render.
- Nếu endpoint DeepSeek hiện tại không nhận ảnh, không giả định có vision: dùng mô tả/reference sheet đã được người dùng cung cấp bằng văn bản, hoặc yêu cầu người dùng chọn endpoint DeepSeek có vision. Không chuyển sang model khác.

### 5.2 Quy trình sinh hình theo từng lớp
1. Design brief: DeepSeek viết identity spec có tỷ lệ, face ID, hair ID, costume ID, palette, weapon, silhouette và asymmetry.
2. Master SVG: sinh một nhân vật toàn thân 3/4 trên nền trong suốt hoặc nền trơn; SVG phải có hình khối, path, gradient có kiểm soát, line-weight và chi tiết trang phục. Không dùng vài hình tròn/đường thẳng làm bản cuối.
3. Visual inspection: render SVG thành PNG bằng Godot hoặc SVG renderer hiện có; DeepSeek Vision chỉ được dùng để đánh giá nếu endpoint hỗ trợ ảnh. Nếu không, dùng kiểm tra SVG/XML tự động và review trực tiếp bởi người dùng.
4. Identity lock: chỉnh master SVG cho tới khi đạt; đóng băng revision đã duyệt.
5. Turnaround: sinh front / 3-4 / side / back thành các SVG riêng, cùng canvas, scale, palette và identity tokens. Không vẽ bốn góc vào một collage rồi cắt tự động.
6. Expression set: sinh 12 face variants SVG riêng, dùng chung face geometry; thay mắt, lông mày, mí, miệng và hướng nhìn theo thông số.
7. Action key poses: sinh ít nhất 12 pose SVG riêng hoặc pose description + rig parameters; mỗi pose có silhouette và trọng tâm khác nhau.
8. Layer decomposition: tạo SVG riêng cho từng layer, cùng viewBox và tọa độ; phần bị che phải được vẽ hoàn chỉnh phía sau layer trước.
9. Rig preparation: tạo pivots.json và rig-map.json; kiểm tra joint overlap, weapon grip và sorting.
10. Godot test: dựng scene test và render contact sheet/video; chỉ đưa vào sản xuất sau review.

### 5.3 SVG quality contract
- SVG dùng viewBox thống nhất; ưu tiên tọa độ vector và path rõ nghĩa.
- Dùng semantic groups như head, hair_back, hair_front, torso, arm_front, hand_front, robe_front, weapon.
- Mỗi bộ phận cần path đóng hợp lệ khi tô màu; stroke linejoin/linecap nhất quán; không để path hở ngoài ý muốn.
- Dùng palette token có tên: ink, skin, skin-shadow, robe-base, robe-shadow, robe-highlight, accent.
- Gradient chỉ để tạo khối nhẹ; tránh glow, blur và filter nặng làm SVG khó render.
- Tách outline silhouette khỏi line chi tiết; outline ngoài rõ hơn nội bộ.
- Không lạm dụng path point; đường cong phải mượt, không có góc gãy không chủ ý.
- Tay phải có ngón cái và khối ngón đọc được ở kích thước video; vũ khí phải có chuôi, guard, lưỡi và grip đúng tỷ lệ.
- Khuôn mặt phải có cấu trúc mắt/đồng tử/highlight, lông mày, mũi, miệng, tai và má; không dùng hai chấm mắt tối giản cho hero asset.
- Quần áo có cổ áo, lớp áo, tay áo, đai, vạt, nếp gấp theo trọng lực; hoa văn ít nhưng có chủ đích.
- Cấm SVG nhúng raster ảnh từ model bên ngoài; cấm foreignObject, script, external resource và URL không tin cậy.
- SVG phải parse được; mọi ID duy nhất; không có element bị cắt ngoài viewBox ngoài ý muốn.

### 5.4 DeepSeek master prompt
Dùng prompt này làm hợp đồng đầu ra. Điền các trường trong ngoặc vuông; yêu cầu model chỉ trả về file code khi cần sinh SVG.

    You are the sole AI art-and-code model in a production pipeline.
    Do not call or recommend any external image-generation model.
    Create an original wuxia chibi storybook character for a 2D animated series.
    Character: [name, role, personality, age impression, sect].
    Identity lock: [face geometry, eye spacing, eyebrow shape, hair silhouette,
    signature detail, body ratio, costume construction, palette, weapon].
    Art direction: hand-drawn anime storybook illustration, expressive compact
    chibi anatomy, refined warm ink outlines, controlled line-weight hierarchy,
    soft cel shading with restrained gradients, layered traditional martial-arts
    costume, designed folds, clear material separation and readable silhouette.
    Make the anatomy articulated: neck, shoulders, elbows, wrists, hips, knees,
    ankles, palms, fingers and feet must be visibly designed.
    Pose: full-body 3/4 neutral hero pose, balanced weight, arms separated from
    torso, both hands and feet visible, weapon grip anatomically correct.
    Output: valid standalone SVG only, transparent background, viewBox 0 0 1024 1536.
    Use semantic groups and stable IDs for every independently animated body part.
    Use smooth paths, intentional curves, layered shapes and a restrained palette.
    Do not output a rough icon, stick figure, flat geometric placeholder, raster image,
    external asset, text label, watermark or multiple characters.
    Preserve original design; do not copy a specific existing character.

### 5.5 Prompt for edits and pose variants
    Treat the approved master SVG and identity.md as immutable identity references.
    Change only: [requested pose, expression, view or costume state].
    Preserve face geometry, eye spacing, hair silhouette, costume seams and layers,
    palette tokens, body ratio, signature details and weapon design.
    Return complete valid SVG source for the requested asset, not a description.
    Keep the same viewBox and semantic layer IDs. Do not simplify or redesign.
    List any required layer/pivot changes separately after the SVG only if requested.

### 5.6 Negative constraints
- no stick figure, emoji, icon-like character, featureless flat silhouette;
- no inconsistent eye spacing, face shape, hair bun, costume, palette or proportions;
- no extra/missing/fused fingers, broken joints, detached limbs;
- no floating weapon, wrong grip, duplicated sheath, bent blade;
- no random ornaments, costume redesign, cropped feet or hidden hands;
- no unnecessary glow, blur, filters, noisy gradients or excessive path fragments;
- no raster embedding, external URL, script, foreignObject or untrusted resource;
- no collage-as-sprite-sheet, no fake claim of PNG generation.

### 5.7 Validation loop
1. DeepSeek emits SVG.
2. Local validator checks XML parse, viewBox, unique IDs, allowed elements, external references and required semantic groups.
3. Godot/SVG renderer rasterizes it to a preview.
4. A human checks face, anatomy, silhouette, costume and style. If DeepSeek Vision is available, it may additionally critique the rendered preview.
5. DeepSeek receives the exact defects and edits only affected paths/layers.
6. Repeat until acceptance; save every approved revision.
7. Never mark PASS solely because SVG code parses. Visual review is mandatory.

### 5.8 Sheet is not animation
Turnaround/expression/action sheets are reference boards only. Do not slice a collage into runtime frames. Every runtime layer must be individually generated, cleaned, aligned, named and approved.

 be individually cleaned, aligned, named and approved.

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


## 12. DeepSeek-only operating policy

- Model provider duy nhất là DeepSeek; endpoint/model ID lấy từ cấu hình dự án hiện tại, không hardcode tên model chưa xác nhận.
- Không fallback âm thầm sang model khác khi DeepSeek hết quota hoặc endpoint không hỗ trợ vision. Dừng và báo lỗi/cần đổi cấu hình DeepSeek.
- Mọi yêu cầu tạo/sửa nhân vật phải tạo SVG source có thể chỉnh sửa; PNG chỉ là render artifact.
- Lưu prompt, model ID, revision, identity hash và danh sách asset đã duyệt để tái lập kết quả.
- Chỉ dùng DeepSeek Vision khi cấu hình hiện tại xác nhận hỗ trợ ảnh đầu vào. Nếu không, phần visual critique là human-in-the-loop.
