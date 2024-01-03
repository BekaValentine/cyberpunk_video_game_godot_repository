class_name Lock
extends SimObject

var lock_types = []
var max_unlock_time = 0.0
var timer = null
var locked = true

func _init():
	interactable = true

func _ready():
	timer = Timer.new()
	add_child(timer)
	timer.connect("timeout", self, "unlock")
	
func unlock():
	locked = false
	debug_info.log("lock state changed" + str(self), self.locked)

func highlight_ended():
	timer.stop()

func use(agent, tool_object):
	if locked and "skills" in agent and tool_object is Key:
		
		var player_skill = agent.skills["lock"]
		if tool_object.key_type and tool_object.key_type in self.lock_types:
			var actual_unlock_time = self.max_unlock_time * (1 - player_skill) * (1 - tool_object.attack_strength)
			debug_info.log("unlock time", actual_unlock_time)
			if actual_unlock_time == 0:
				self.unlock()
			else:
				timer.wait_time = actual_unlock_time
				timer.start()
