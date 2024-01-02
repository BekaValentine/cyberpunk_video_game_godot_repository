tool
class_name NavBridgeLink
extends Spatial

var plugin

export var space_0_path : NodePath
export var space_1_path : NodePath

func _ready():
    self.set_notify_transform(true)

func _notification(note):
    if plugin != null:        
        if note == NOTIFICATION_TRANSFORM_CHANGED:
            self.update_gizmo()

func update_gizmo():
    var g = self.gizmo
    g.get_plugin().redraw(g)

func set_spaces(s0, s1):
    space_0_path = s0
    space_1_path = s1

func get_spaces():
    return [self.get_node_or_null(space_0_path), self.get_node_or_null(space_1_path)]