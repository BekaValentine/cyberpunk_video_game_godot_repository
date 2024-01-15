extends SimObject

var normal_color = null

func _ready():
	self.interactable = true
	self.focal_object_resource = preload("res://infrastructure/objects/inspectable_4.tscn")
	self.highlight_shape = $CSGBox

func start_highlight():
	normal_color = highlight_shape.material.albedo_color
	highlight_shape.material.albedo_color = normal_color.lightened(0.5)

func end_highlight():
	highlight_shape.material.albedo_color = normal_color

func use(agent, tool_object):
	debug_info.log("inspectable 3 used", str(tool_object))

func focus():
	debug_info.log("inspectable 3 focused", true)
