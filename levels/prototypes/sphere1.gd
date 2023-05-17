extends SimObject

func _ready():
	highlight_shape = $CSGSphere
	interactable = true

func use(tool_object = null):
	debug_info.log("last interactable action", "use " + self.name + (" with tool " + tool_object.name if tool_object else ""))
