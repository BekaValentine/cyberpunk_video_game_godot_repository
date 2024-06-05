class_name DoorAssembly
extends SimObject

var hinge_pivot = null
var door = null
var tween = null
var toggling = false
export(NodePath) var lock_path
var lock = null
var hinges = []
var all_hinges_disabled = false
var open = false
var open_angle = Vector3(0,-90,0)
var closed_angle = Vector3(0,0,0)

func _ready():
	hinge_pivot = $HingePivot
	door = $HingePivot/Door
	tween = $Tween
	tween.connect("tween_completed", self, "toggle_done")
	debug_info.log("tween", tween)
	if lock_path != null:
		var candidate_lock = get_node(lock_path)
		if candidate_lock is Lock:
			lock = candidate_lock
	for child in self.get_children():
		if child is Hinge:
			hinges.push_back(child)

func _init():
	useable_or_affected_by_tools = true

func affected_by(agent, tool_object):
	debug_info.log("being used", [self, self.can_use_or_affect(), randf()])
	# debug_info.log("door used", str(randf()) + " " + str(toggling) + " " + str(lock and lock.locked) + " " + str(open))

	if toggling: return

	if tool_object is Crowbar:
		self.destroy()

	elif lock and lock.locked:
		return
	
	elif not self.all_hinges_disabled:
		if open:
			close()

		else:
			open()

func destroy():
	self.get_parent().remove_child(self)

func open():
	toggling = true
	tween.interpolate_property(
		self.hinge_pivot,
		"rotation_degrees",
		closed_angle,
		open_angle,
		0.5,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT)
	tween.start()

func close():
	toggling = true
	tween.interpolate_property(
		self.hinge_pivot,
		"rotation_degrees",
		open_angle,
		closed_angle,
		0.5,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT)
	tween.start()

func toggle_done(object, key):
	open = !open
	toggling = false

func notify_hinge_disabled():
	self.all_hinges_disabled = true
	for hinge in self.hinges:
		if hinge.enabled:
			self.all_hinges_disabled = false
			break
	if self.all_hinges_disabled:
		self.set_hinges_disabled()

func set_hinges_disabled():
	debug_info.log("hinges disabled", true)
	self.door.mode = RigidBody.MODE_RIGID
	self.door.become_holdable()
