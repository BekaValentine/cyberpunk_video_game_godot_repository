class_name Lock
extends SimObject

var lock_type = null

func _init():
    interactable = true

func use(tool_object):
    if tool_object is Key:
        if tool_object.lock_type and tool_object.lock_type == self.lock_type:
            print("Open!")
        else:
            print("Wrong key. :(")