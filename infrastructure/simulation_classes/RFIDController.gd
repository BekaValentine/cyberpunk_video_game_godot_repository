class_name RFIDController
extends Node

var access_codes = []

func key_authorized(key_code):
	debug_info.log("trying rfid controller", key_code + " " + str(self.access_codes))
	return key_code in self.access_codes