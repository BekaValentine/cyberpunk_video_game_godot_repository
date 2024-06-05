class_name Hinge
extends SimObject

var enabled = true
export(NodePath) var door_assembly_path = null
var door_assembly = null
var pin_is_poppable = false

func _init():
	._init()
	self.useable_or_affected_by_tools = true

func _ready():
	._ready()
	if door_assembly_path:
		self.door_assembly = get_node(door_assembly_path)

func affected_by(agent, tool_object):
	if tool_object is Crowbar:
		self.pop_pin()

func pop_pin():
	if self.pin_is_poppable:
		self.enabled = false
		if self.door_assembly:
			self.door_assembly.notify_hinge_disabled()
