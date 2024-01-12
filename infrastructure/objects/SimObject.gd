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
var meshes = []
var focal_object_resource = null
var focal_object = null
var root_object = null

func _ready():
	add_visual_instances(self)

func add_visual_instances(node):
	debug_info.log("trying add mesh for " + str(node), true)
	if node is VisualInstance:
		meshes.push_back(node)
	for c in node.get_children():
		add_visual_instances(c)

func move_meshes_to_layers(layers):
	for m in meshes:
		m.layers = layers

func set_root_object(obj):
	self.root_object = obj



#### Internal Functions MUST NOT OVERRIDE ####

func _hold():
	if not self.holdable: return

	self.move_meshes_to_layers(2)
	
	self.hold()

func _release():
	if not self.holdable: return
	
	self.move_meshes_to_layers(1)
	
	self.release()
	
func _stash():
	if not self.holdable: return
	
	self.stash()

func _unstash():
	if not self.holdable: return
	
	self.unstash()

func _use(agent, tool_object = null):
	if not self.interactable: return
	
	self.use(agent, tool_object)

func _focus():
	debug_info.log("focused on an object", self)
	self.focus()
	focal_object = focal_object_resource.instance()
	focal_object.set_root_object(self)
	return focal_object

func _unfocus():
	focal_object = null


#### Exposed Functions MAY OVERRIDE ####

func hold():
	pass

func release():
	pass

func stash():
	pass

func unstash():
	pass

func use(agent, tool_object):
	pass

func focus():
	pass

func unfocus():
	pass
