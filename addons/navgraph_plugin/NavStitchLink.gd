tool
class_name NavStitchLink
extends Spatial

var plugin

export var space_path : NodePath

func set_space(s):
    space_path = s

func get_space():
    return plugin.get_space_by_path(space_path)