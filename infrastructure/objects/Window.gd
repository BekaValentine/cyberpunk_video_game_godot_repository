class_name Window
extends SimObject

var tween = null
var toggling = false
var locked = false
var open = false
var default_position
var open_position = Vector3(0,0.5,0)
var closed_position = Vector3(0,0,0)

func _ready():
	tween = $Tween
	highlight_shape = $CSGBox
	default_position = self.global_transform.origin
	log_status()

func log_status(extra = ""):
	debug_info.log("window", ("locked" if locked else "unlocked") + " " + ("open" if open else "closed") + extra)

func _init():
	interactable = true

func use(tool_object):
	if locked: return
	
	if toggling: return
	
	if open:
		close()
	else:
		open()
	
	log_status()

func open():
	toggling = true
	tween.interpolate_method(
		self,
		"set_toggling_position",
		closed_position,
		open_position,
		0.5,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT)
	tween.start()

func close():
	toggling = true
	tween.interpolate_method(
		self,
		"set_toggling_position",
		open_position,
		closed_position,
		0.5,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT)
	tween.start()

func set_toggling_position(pos):
	global_transform.origin = default_position + pos

func toggle_done():
	open = !open
	toggling = false
	log_status(" toggle done")