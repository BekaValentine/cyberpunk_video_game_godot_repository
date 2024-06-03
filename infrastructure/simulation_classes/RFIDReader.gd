class_name RFIDReader
extends SimObject

export(NodePath) var controller_path
var controller

func _init():
	._init()
	self.interactable = true

func _ready():
	if controller_path != null:
		var candidate_controller = get_node(controller_path)
		if candidate_controller is ElectronicLockController:
			controller = candidate_controller

func affected_by(agent, key):
	debug_info.log("rfid used", true)
	if key is RFIDKey and controller != null:
		controller.handle_code(key.key_code)