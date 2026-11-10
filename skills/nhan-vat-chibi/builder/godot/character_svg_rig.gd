extends Node2D
## Runtime loader for SVG Character Builder layer exports.
## Attach to a Node2D in Godot 4. Set manifest_path to exported pivots.json.
@export_file("*.json") var manifest_path := "res://art/characters/teo-kiem-khach/layers/pivots.json"
var pivots: Dictionary = {}
var sprites: Dictionary = {}
var pivot_nodes: Dictionary = {}

func _ready() -> void:
    load_character(manifest_path)

func load_character(path: String) -> void:
    var file := FileAccess.open(path, FileAccess.READ)
    if file == null:
        push_error("Cannot open character manifest: " + path)
        return
    var data: Dictionary = JSON.parse_string(file.get_as_text())
    if data.is_empty():
        push_error("Invalid character pivots.json")
        return
    pivots = data.get("parts", {})
    for part_name in pivots.keys():
        _create_part(part_name, pivots[part_name])

func _create_part(part_name: String, config: Dictionary) -> void:
    var parent_name: String = config.get("parent", "root")
    var parent_node: Node2D = self if parent_name == "root" else pivot_nodes.get(parent_name, self)
    var pivot := Node2D.new()
    pivot.name = part_name + "_pivot"
    var point: Dictionary = config.get("pivot", {"x":512,"y":768})
    pivot.position = Vector2(float(point.get("x",512)), float(point.get("y",768)))
    parent_node.add_child(pivot)
    var sprite := Sprite2D.new()
    sprite.name = part_name
    sprite.centered = false
    var texture_path: String = config.get("texture", part_name + ".svg")
    var base_dir := manifest_path.get_base_dir()
    sprite.texture = load(base_dir.path_join(texture_path))
    if sprite.texture == null:
        push_error("Could not load SVG layer: " + texture_path)
    else:
        sprite.position = -pivot.position
        pivot.add_child(sprite)
        sprites[part_name] = sprite
    pivot_nodes[part_name] = pivot

## Example action: call from an AnimationPlayer or gameplay controller.
func tween_part(part_name: String, rotation_degrees: float, duration: float = 0.18) -> void:
    if not pivot_nodes.has(part_name):
        push_warning("Unknown rig part: " + part_name)
        return
    var tween := create_tween()
    tween.tween_property(pivot_nodes[part_name], "rotation_degrees", rotation_degrees, duration)

func reset_pose(duration: float = 0.2) -> void:
    for node in pivot_nodes.values():
        var tween := create_tween()
        tween.tween_property(node, "rotation", 0.0, duration)
