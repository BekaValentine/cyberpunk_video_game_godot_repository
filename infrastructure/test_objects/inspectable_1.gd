extends SimObject

var normal_color = null

func _ready():
	self.interactable = true
	self.focal_object_resource = preload("res://infrastructure/objects/inspectable_2.tscn")

func start_highlight():
	normal_color = $CSGBox.material.albedo_color
	$CSGBox.material.albedo_color = normal_color.lightened(0.5)

func end_highlight():
	$CSGBox.material.albedo_color = normal_color

func affected_by(agent, tool_object):
	debug_info.log("inspectable 1 used", true)

func focus():
	debug_info.log("inspectable 1 focused", true)
