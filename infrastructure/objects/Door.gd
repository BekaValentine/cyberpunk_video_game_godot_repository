class_name Door
extends SimObject

var tween = null
var toggling = false
var locked = false
var open = false
var open_angle = Vector3(0,-90,0)
var closed_angle = Vector3(0,0,0)

func _ready():
	tween = $Tween
	highlight_shape = $CSGBox
	log_status()

func log_status():
	debug_info.log("door", ("locked" if locked else "unlocked") + " " + ("open" if open else "closed"))

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