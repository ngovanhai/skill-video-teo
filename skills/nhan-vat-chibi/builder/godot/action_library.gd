extends Node
## Loads a named action from wuxia_action_library.json and plays it on a FullBodyRig node.
@export_file("*.json") var library_path := "res://art/characters/actions/wuxia_action_library.json"
@export_node_path("Node2D") var rig_path: NodePath
var library: Dictionary = {}
var rig: Node2D

func _ready() -> void:
    rig = get_node_or_null(rig_path) as Node2D
    if rig == null:
        push_error("Action library: rig_path must point to the FullBodyRig Node2D")
        return
    var file := FileAccess.open(library_path, FileAccess.READ)
    if file == null:
        push_error("Cannot open action library: " + library_path)
        return
    var parsed = JSON.parse_string(file.get_as_text())
    if typeof(parsed) != TYPE_DICTIONARY or not parsed.has("actions"):
        push_error("Invalid wuxia action library JSON")
        return
    library = parsed

func play(action_id: String) -> void:
    if library.is_empty() or rig == null:
        push_warning("Action library or rig is not ready")
        return
    var actions: Dictionary = library.get("actions", {})
    if not actions.has(action_id):
        push_warning("Unknown wuxia action: " + action_id)
        return
    var action: Dictionary = actions[action_id]
    if not rig.has_method("play_action"):
        push_error("Target rig does not implement play_action()")
        return
    rig.call("play_action", action.get("keyframes", []))
    # Camera and FX cues are intentionally returned as metadata; the scene owns their implementation.
    print("Playing action: ", action_id, " | camera=", action.get("camera", {}), " | fx=", action.get("fx", {}))

func get_action_ids(category: String = "") -> Array[String]:
    var ids: Array[String] = []
    for id in library.get("actions", {}):
        var action: Dictionary = library.actions[id]
        if category == "" or action.get("category", "") == category:
            ids.append(id)
    ids.sort()
    return ids
