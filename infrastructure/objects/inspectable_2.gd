extends SimObject

func _ready():
	self.highlight_shape = $CSGBox

func use(agent, tool_object):
	debug_info.log("inspectable 2 used", true)
