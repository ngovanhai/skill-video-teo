# Full Body Rig v1 (segmented limbs)

This is an optional second-generation export. It does not replace the v1 11-layer splitter.

## DeepSeek SVG contract
Ask DeepSeek to create these exact top-level SVG group IDs, each containing one independently drawable segment:
- `shadow`
- `hair_back`
- `torso`
- `robe_back`
- `thigh_L`
- `shin_L`
- `foot_L`
- `thigh_R`
- `shin_R`
- `foot_R`
- `upper_arm_L`
- `forearm_L`
- `hand_L`
- `upper_arm_R`
- `forearm_R`
- `hand_R`
- `neck`
- `head`
- `hair_front`
- `robe_front`
- `weapon`

Every joint must have hidden overlap geometry (e.g. forearm extends under upper arm; shin extends under thigh). Keep the same viewBox on every part. Avoid drawing a visible gap at shoulder, elbow, wrist, hip, knee and ankle.

## Export on Windows
```powershell
python skills/nhan-vat-chibi/builder/split_full_body.py path\to\master.svg --out art\characters\teo-kiem-khach\full-body
```
Output: individual SVGs and `full_body_rig.json`. Pivots are starter estimates in a 1024x1536 coordinate space; edit them after inspecting the character.

## Godot
Copy the output directory into `res://art/characters/<id>/full-body/`. Copy `godot/full_body_rig.gd` and attach it to a Node2D. Set `manifest_path` to `full_body_rig.json`. Godot must import each SVG as a texture before the scene can display it.

The optional `actions/sword_actions.json` provides initial keyframe values for sword slash, guard and dodge. These are motion-design starting points, not universally correct poses: adjust for the character's facing direction, weapon grip and proportions. The script exposes `apply_pose()`, `play_action()`, and `reset_pose()`; a project-specific action loader can read the JSON and pass its keyframes to `play_action()`.

## Current limits
- 21 rigid segments, not deformable bones or IK.
- Starter pivot coordinates are generic and need per-character adjustment.
- The included script does not yet parse the action JSON automatically.
- No visual/runtime test has been performed in the target Godot project.
- Root translation, foot planting, hand IK, weapon attachment constraints and squash/stretch are not included.
