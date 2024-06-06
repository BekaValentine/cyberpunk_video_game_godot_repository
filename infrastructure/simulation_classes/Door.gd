class_name Door
extends SimObject

var door_assembly = null

func _init():
	useable_or_affected_by_tools = true

func set_door_assembly(da):
	self.door_assembly = da

func become_holdable():
	self.hold_size = 1

func affected_by(agent, tool_object):
	if self.door_assembly:
		self.door_assembly.affected_by(agent, tool_object)
