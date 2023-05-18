class_name Lock
extends SimObject

var lock_type = null

func _init():
    interactable = true

func use(agent, tool_object):
    if tool_object is Key:
        if tool_object.lock_type and tool_object.lock_type == self.lock_type:
            debug_info.log("last lock action", "open with " + tool_object.name)
        else:
            debug_info.log("last lock action", "reject " + tool_object.name)