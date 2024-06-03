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

func affected_by(agent, tool_object):
	if locked:
		if "skills" in agent and tool_object is Key and self.should_unlock(tool_object):
			var player_skill = agent.skills["lock"]
			var actual_unlock_time = self.max_unlock_time * (1 - player_skill) * (1 - tool_object.attack_strength)
			debug_info.log("unlock time", actual_unlock_time)
			if actual_unlock_time == 0:
				self.unlock()
			else:
				timer.wait_time = actual_unlock_time
				timer.start()
		elif tool_object is BoltCutters:
			timer.wait_time = self.cut_durability
			timer.start()