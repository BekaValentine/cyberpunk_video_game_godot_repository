class_name Lock
extends SimObject

var lock_types = []
var max_unlock_time = 0.0
var timer = null
var locked = true
var cut_durability = 5

func _init():
	interactable = true

func _ready():
	timer = Timer.new()
	add_child(timer)
	timer.connect("timeout", self, "unlock")
	
func should_unlock(key):
	return key.key_type and key.key_type in self.lock_types

func unlock():
	locked = false
	debug_info.log("lock state changed" + str(self), self.locked)

func highlight_ended():
	timer.stop()

func use(agent, tool_object):
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
