extends Node2D
## Full-body segmented cutout rig. Manifest pivots are in original SVG canvas coordinates.
@export_file("*.json") var manifest_path := "res://art/characters/character/layers/full_body_rig.json"
var part_nodes: Dictionary = {}
var part_sprites: Dictionary = {}
var rest_rotations: Dictionary = {}

func _ready() -> void:
    load_rig(manifest_path)

func load_rig(path: String) -> void:
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        push_error("Cannot open rig manifest: " + path)
        return
    var parsed = JSON.parse_string(file.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY or not parsed.has("parts"):
        push_error("Invalid full_body_rig.json")
        return
    var parts: Dictionary = parsed.parts
    # Parents must be created before children. Iterate until all resolvable nodes are built.
    var pending: Array = parts.keys()
    while not pending.is_empty():
        var progressed := false
        for part_name in pending.duplicate():
            var cfg: Dictionary = parts[part_name]
            var parent_name: String = str(cfg.get("parent", "root"))
            if parent_name != "root" and not part_nodes.has(parent_name):
                continue
            _make_part(part_name, cfg, parent_name)
            pending.erase(part_name)
            progressed = true
        if not progressed:
            push_error("Rig has missing parent or cyclic hierarchy: " + str(pending))
            return

func _make_part(part_name: String, cfg: Dictionary, parent_name: String) -> void:
    var pivot_data: Dictionary = cfg.get("pivot", {})
    var absolute_pivot := Vector2(float(pivot_data.get("x", 0)), float(pivot_data.get("y", 0)))
    var parent_pivot := Vector2.ZERO
    if parent_name != "root":
        var parent_cfg: Dictionary = _get_part_config(parent_name)
        var pp: Dictionary = parent_cfg.get("pivot", {})
        parent_pivot = Vector2(float(pp.get("x", 0)), float(pp.get("y", 0)))
    var pivot := Node2D.new()
    pivot.name = part_name
    pivot.position = absolute_pivot - parent_pivot
    pivot.z_index = int(cfg.get("z_index", 0))
    (self if parent_name == "root" else part_nodes[parent_name]).add_child(pivot)
    part_nodes[part_name] = pivot
    rest_rotations[part_name] = 0.0
    var sprite := Sprite2D.new()
    sprite.name = part_name + "_sprite"
    sprite.centered = false
    sprite.position = -absolute_pivot
    var texture_path := manifest_path.get_base_dir().path_join(str(cfg.get("texture", part_name + ".svg")))
    sprite.texture = load(texture_path)
    if sprite.texture == null:
        push_error("Texture not imported by Godot: " + texture_path)
    else:
        pivot.add_child(sprite)
        part_sprites[part_name] = sprite

# Manifest lookup cached from JSON.
var _parts_cache: Dictionary = {}
func _get_part_config(part_name: String) -> Dictionary:
    return _parts_cache.get(part_name, {})

func apply_pose(pose: Dictionary, duration: float = 0.12) -> void:
    for part_name in pose:
        if not part_nodes.has(part_name):
            push_warning("Pose references unknown rig part: " + str(part_name))
            continue
        var target := deg_to_rad(float(pose[part_name]))
        var tween := create_tween()
        tween.tween_property(part_nodes[part_name], "rotation", target, duration)

func play_action(keyframes: Array, fps: float = 24.0) -> void:
    # Each keyframe: {"at": seconds, "pose": {"upper_arm_R": -40, ...}}
    if keyframes.size() < 2:
        push_warning("Action requires at least two keyframes")
        return
    var ordered := keyframes.duplicate(true)
    ordered.sort_custom(func(a, b): return float(a.get("at", 0.0)) < float(b.get("at", 0.0)))
    var tween := create_tween()
    var previous_time := float(ordered[0].get("at", 0.0))
    var previous_pose: Dictionary = ordered[0].get("pose", {})
    apply_pose(previous_pose, 0.0)
    for i in range(1, ordered.size()):
        var frame: Dictionary = ordered[i]
        var at := float(frame.get("at", previous_time))
        var pose: Dictionary = frame.get("pose", {})
        var duration := maxf(0.0, at - previous_time)
        for part_name in pose:
            if part_nodes.has(part_name):
                tween.parallel().tween_property(part_nodes[part_name], "rotation", deg_to_rad(float(pose[part_name])), duration)
        previous_time = at
    tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)

func reset_pose(duration: float = 0.18) -> void:
    var pose := {}
    for part_name in rest_rotations:
        pose[part_name] = 0.0
    apply_pose(pose, duration)
