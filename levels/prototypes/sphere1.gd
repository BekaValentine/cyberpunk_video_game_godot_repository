extends SimObject

var normal_color = null

func _ready():
	useable_or_affected_by_tools = true

func start_highlight():
	normal_color = $CSGSphere.material.albedo_color
	$CSGSphere.material.albedo_color = normal_color.lightened(0.5)

func end_highlight():
	$CSGSphere.material.albedo_color = normal_color

func affected_by(agent, tool_object = null):
	debug_info.log("last interactable action", "use " + self.name + (" with tool " + tool_object.name if tool_object else ""))
