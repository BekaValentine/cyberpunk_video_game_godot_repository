extends SimObject

func _ready():
	highlight_shape = $CSGSphere
	interactable = true

func use(tool_object = null):
	print("used!", tool_object)
