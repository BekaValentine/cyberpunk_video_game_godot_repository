extends SimObject


func _ready():
	self.interactable = true
	self.focal_object_resource = preload("res://infrastructure/objects/inspectable_4.tscn")
	self.highlight_shape = $CSGBox

func use(agent, tool_object):
	debug_info.log("inspectable 1 used", true)

func focus():
	debug_info.log("inspectable 1 focused", true)
