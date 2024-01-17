class_name RFIDLock
extends Lock

export(NodePath) var rfid_controller_path
var rfid_controller

func _init():
	._init()
	lock_types += ["RFID"]

func _ready():
	if rfid_controller_path != null:
		var candidate_controller = get_node(rfid_controller_path)
		if candidate_controller is RFIDController:
			rfid_controller = candidate_controller

func should_unlock(key):
	return key is RFIDKey and rfid_controller != null and rfid_controller.key_authorized(key.key_code)
