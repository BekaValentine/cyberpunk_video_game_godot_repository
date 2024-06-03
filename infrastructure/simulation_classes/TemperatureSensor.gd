class_name TemperatureSensor
extends SimObject

export(NodePath) var controller_path
var controller

var min_ignore_temp = 50
var max_ignore_temp = 95

func _ready():
	if controller_path != null:
		var candidate_controller = get_node(controller_path)
		if candidate_controller is ElectronicLockController:
			controller = candidate_controller

func object_entered_view(object):
	if "temperature" in object and \
		(object.temperature < min_ignore_temp or\
		 object.temperature > max_ignore_temp):
		
		self.controller.unlock()
