class_name Door
extends SimObject

var tween = null
var toggling = false
export(NodePath) var lock_path
var lock = null
var open = false
var open_angle = Vector3(0,-90,0)
var closed_angle = Vector3(0,0,0)

func _ready():
	tween = $Tween
	highlight_shape = $CSGBox
	if lock_path != null:
		var candidate_lock = get_node(lock_path)
		if candidate_lock is Lock:
			lock = candidate_lock

func _init():
	interactable = true

func affected_by(agent, tool_object):
	if lock and lock.locked: return
	
	if toggling: return
	
	if open:
		close()
	else:
		open()

func open():
	toggling = true
	tween.interpolate_property(
		self,
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
		self,
		"rotation_degrees",
		open_angle,
		closed_angle,
		0.5,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT)
	tween.start()

func toggle_done():
	open = !open
	toggling = false