# Wuxia Action Library v1

Contains 33 reusable keyframe actions for the Full Body Rig v1. It is authored as data; no external AI model is called at runtime.

## Categories
- Di chuyển: walk_ready, run_forward, stop_skid, turn_around, kneel_respect
- Kiếm thuật: sword_draw, slash_horizontal, slash_vertical, thrust_forward, backhand_slash, double_slash, spin_slash, sword_guard, parry_high, parry_low, sheathe_sword
- Phòng thủ: dodge_left, dodge_right, duck_evade, lean_evade, hit_recoil, block_impact, stagger_recover
- Khinh công: jump_up, air_kick, land_heavy, float_pose, somersault
- Biểu cảm / diễn xuất: taunt, fear_flinch, victory_pose, meditate, collapse_kneel

## Data contract
Each action includes category, description, expression cue, camera cue, FX cue, phase labels and keyframes. Each keyframe uses seconds and degrees:
```json
{"at":0.22,"phase":"action","pose":{"torso":-12,"upper_arm_R":75}}
```
Pose keys must match the 21 segment names in `full_body_rig.json`. Camera and FX cues are descriptive metadata only; the library does not silently manipulate the scene camera or spawn effects.

## Godot usage
1. Copy `wuxia_action_library.json` and `godot/action_library.gd` into the project.
2. Add a Node with `action_library.gd`, set `library_path`, and set `rig_path` to the FullBodyRig Node2D.
3. Call `$ActionLibrary.play("slash_horizontal")`.
4. Read `get_action_ids("Kiếm thuật")` to populate an action picker.

## Animation quality rules
- Keep anticipation readable before fast attacks; don't compress every move into one instant.
- Contact/peak should align with weapon trail, impact sound and camera shake in the scene timeline.
- Follow-through and recovery are mandatory; do not snap to idle.
- Adjust angles for facing direction, sword hand, character proportions and camera framing.
- Use root motion / foot locking in the scene when a move travels; the current rig library only animates local joint rotations.
- Review the character at 0%, 25%, 50%, 75% and 100% of every new action before reuse.

## Known limitations
- 33 starter actions are generic motion blocking, not final polished choreography.
- No inverse kinematics, foot planting, collision response, root translation, weapon grip constraint, or automatic camera/FX execution.
- The existing FullBodyRig.play_action() interpolates joint rotations only. Confirm timing and visual direction in a Godot test scene before production.
