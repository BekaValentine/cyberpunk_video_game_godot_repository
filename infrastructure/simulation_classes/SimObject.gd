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
var interactable = false

var meshes = []
var focal_object_resource = null
var focal_object = null
var in_focus_object_resource = null
var in_focus_object = null
var root_object = self

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

func get_root_object():
	return self.root_object

func set_root_object(obj):
	self.root_object = obj

func can_highlight():
	return self.get_holdable() or interactable or focal_object_resource != null


#### Internal Functions MUST NOT OVERRIDE ####

func _start_highlight():
	self.start_highlight()
	
func _end_highlight():
	self.end_highlight()

func _hold():
	if not self.holdable: return

	self.move_meshes_to_layers(2)

	if self.in_focus_object:
		self.in_focus_object.get_parent().remove(self.in_focus_object)
	
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

func _use_on(agent, patient):
	self.use_on(agent, patient)

func _affected_by(agent, tool_object = null):
	if not self.interactable: return
	
	self.affected_by(agent, tool_object)

func _focus():
	debug_info.log("focused on an object", self)
	self.focus()
	focal_object = focal_object_resource.instance()
	focal_object.set_root_object(self)
	return focal_object

func _unfocus():
	focal_object = null

func _focus_left():
	self.focus_left()

func _focus_right():
	self.focus_right()

func _focus_up():
	self.focus_up()

func _focus_down():
	self.focus_down()


#### Exposed Functions MAY OVERRIDE ####

func start_highlight():
	pass

func end_highlight():
	pass

func hold():
	pass

func release():
	pass

func stash():
	pass

func unstash():
	pass

func use_on(agent, patient):
	# default behavior is to simply pass control to the patient
	patient.affected_by(agent, self)

func affected_by(agent, tool_object):
	pass

func focus():
	pass

func unfocus():
	pass

func focus_left():
	pass

func focus_right():
	pass

func focus_up():
	pass

func focus_down():
	pass
