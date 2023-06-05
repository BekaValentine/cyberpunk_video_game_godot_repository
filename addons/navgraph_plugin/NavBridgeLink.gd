tool
class_name NavBridgeLink
extends Spatial

var plugin

export var space_0_path : NodePath
export var space_1_path : NodePath

func set_spaces(s0, s1):
    space_0_path = s0
    space_1_path = s1

func get_spaces():
    return [self.get_node_or_null(space_0_path), self.get_node_or_null(space_1_path)]