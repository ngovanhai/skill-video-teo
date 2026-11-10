# SVG Layer Splitter + Godot Rig v1

## Requirements
- Python 3.9+ (standard library only)
- Godot 4.x (SVG import supported)
- SVG source with top-level semantic groups: shadow, hair_back, body, robe_back, legs, arms_back, head, hair_front, arms_front, robe_front, weapon.

## Export layers
From repository root, after Builder has generated and validated a master SVG:

```powershell
$character = "teo-kiem-khach"
$latest = Get-Content "art/characters/$character/source/LATEST"
$svg = "art/characters/$character/source/$latest/master.svg"
python skills/nhan-vat-chibi/builder/split_layers.py $svg --out "art/characters/$character/layers"
```

The script writes individual SVG files and `pivots.json`. All SVGs preserve the same viewBox so their coordinates stay aligned. The splitter fails if required groups are absent; it never silently fabricates missing body parts.

## Godot 4
1. Copy the exported `layers/` folder into your Godot project's `res://art/characters/<id>/layers/`.
2. Copy `godot/character_svg_rig.gd` into the project.
3. Create a Node2D, attach the script, and set `manifest_path` to the copied `pivots.json`.
4. Run the scene and adjust each pivot in `pivots.json` (coordinates are in the 1024x1536 SVG canvas).
5. Use AnimationPlayer for authored actions, or call `tween_part("arms_front", -35.0)` for simple procedural motion.

## Important rig caveat
This is a first-pass cutout rig, not a production skeletal mesh. Parts rotate around pivot points and can reveal gaps if DeepSeek has not drawn hidden overlap geometry beneath foreground parts. Check shoulder, elbow, wrist, hip and knee seams in the test scene. The generated pivot positions are starter estimates and MUST be adjusted by visual inspection. Layer z-order and nested parent transforms may need tuning for each character.

## Recommended pivot editing
- head: base of neck
- arms: shoulder for upper arm; elbow/wrist require additional segmentation in a later pass
- legs: hip; knee/ankle require additional segmentation in a later pass
- hair_front: scalp attachment
- weapon: grip point
