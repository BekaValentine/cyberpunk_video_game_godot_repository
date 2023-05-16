extends RigidBody

class_name SimObject

# hold_size is how big the object is for holding/stashing purposes
# null means not holdable or stashable
# integer sizes mean how much bag space it takes up (0 means no space)
var hold_size = null
var holdable setget, get_holdable
func get_holdable():
	return hold_size != null

# interactable is whether the object can be interacted with or not
# when true, 
var interactable = false

var highlight_shape = null



#### Internal Functions MUST NOT OVERRIDE ####

func _hold():
	if not self.holdable: return

	if self.highlight_shape:
		self.highlight_shape.layers = 2
	
	self.hold()

func _release():
	if not self.holdable: return
	
	if self.highlight_shape:
		self.highlight_shape.layers = 1
	
	self.release()
	
func _stash():
	if not self.holdable: return
	
	self.stash()

func _unstash():
	if not self.holdable: return
	
	self.unstash()

func _use(tool_object = null):
	if not self.interactable: return
	
	self.use(tool_object)


#### Exposed Functions MAY OVERRIDE ####

func hold():
	pass

func release():
	pass

func stash():
	pass

func unstash():
	pass

func use(tool_object = null):
	pass
