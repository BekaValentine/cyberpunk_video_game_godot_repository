class_name Lock
extends SimObject

var max_unlock_time = 0.0
var timer = null
var locked = true
var cut_durability = 5

func _init():
	useable_or_affected_by_tools = true

func _ready():
	timer = Timer.new()
	add_child(timer)
	timer.connect("timeout", self, "unlock")

func unlock():
	locked = false
	debug_info.log("lock state changed" + str(self), self.locked)

func end_highlight():
	timer.stop()
