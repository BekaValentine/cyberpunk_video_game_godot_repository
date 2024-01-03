class_name Lock
extends SimObject

var lock_types = []
var base_difficulty = 0.0

func _init():
	interactable = true

func use(agent, tool_object):
	if "skills" in agent and tool_object is Key:
		var player_skill = agent.skills["lock"]
		debug_info.log("player lock skill", player_skill)
		debug_info.log("base lock difficulty", self.base_difficulty)
		debug_info.log("attack strength", tool_object.attack_strength)
		if tool_object.key_type and tool_object.key_type in self.lock_types:
			var probability_of_failure = self.base_difficulty * (1 - player_skill) * (1 - tool_object.attack_strength)
			debug_info.log("probability of failure", probability_of_failure)
			var random_value = randf()
			debug_info.log("dice roll", random_value)
			if random_value < probability_of_failure:
				debug_info.log("last lock action", "reject " + tool_object.name)
			else:
				debug_info.log("last lock action", "open with " + tool_object.name + " as " + tool_object.key_type)
		else:
			debug_info.log("last lock action", "reject " + tool_object.name)
