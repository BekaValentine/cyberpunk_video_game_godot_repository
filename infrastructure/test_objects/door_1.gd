extends Door

var normal_color = null

func start_highlight():
	normal_color = $CSGBox.material.albedo_color
	$CSGBox.material.albedo_color = normal_color.lightened(0.5)

func end_highlight():
	$CSGBox.material.albedo_color = normal_color

func affected_by(agent, tool_object):
	if tool_object is Crowbar:
		self.destroy()

func destroy():
	self.get_parent().remove_child(self)
