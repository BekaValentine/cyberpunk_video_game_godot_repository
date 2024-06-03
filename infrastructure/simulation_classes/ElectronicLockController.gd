class_name ElectronicLockController
extends Lock

var access_codes = []

func key_authorized(key_code):
	debug_info.log("trying rfid controller", key_code + " " + str(self.access_codes))
	return key_code in self.access_codes

func handle_code(code):
	if self.key_authorized(code):
		self.locked = false
