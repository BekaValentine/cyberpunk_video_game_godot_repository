extends SimObject

var normal_color = null

func _ready():
	self.interactable = true
	self.focal_object_resource = preload("res://infrastructure/test_objects/inspectable_4.tscn")

func start_highlight():
	normal_color = $CSGBox.material.albedo_color
	$CSGBox.material.albedo_color = normal_color.lightened(0.5)

func end_highlight():
	$CSGBox.material.albedo_color = normal_color

func affected_by(agent, tool_object):
	debug_info.log("inspectable 3 used", str(tool_object))

func focus():
	debug_info.log("inspectable 3 focused", true)
