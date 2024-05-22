class_name PhysicalLock
extends Lock

var lock_types = []
var valid_pin_heights = []

func should_unlock(key):
	if !(
		key is PhysicalKey and
		key.key_type in self.lock_types and
		len(self.valid_pin_heights) == len(key.direct_bitting_code)
		):
		return false
	
	for i in range(0, len(self.valid_pin_heights)):
		if !(key.direct_bitting_code[i] in self.valid_pin_heights[i]):
			return false
	
	return true
