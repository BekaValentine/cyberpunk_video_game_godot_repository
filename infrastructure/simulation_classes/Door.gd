class_name Door
extends SimObject

func _init():
	useable_or_affected_by_tools = true

func become_holdable():
	self.hold_size = 1