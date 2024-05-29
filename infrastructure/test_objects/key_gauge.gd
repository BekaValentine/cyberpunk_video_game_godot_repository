extends SimObject

var normal_color = null
var overlay_resource = null
var overlay = null

func _init():
	hold_size = 1
	self.overlay_resource = preload("res://infrastructure/test_objects/key_gauge_overlay.tscn")

func start_highlight():
	normal_color = $CSGBox.material.albedo_color
	$CSGBox.material.albedo_color = normal_color.lightened(0.5)

func end_highlight():
	$CSGBox.material.albedo_color = normal_color

func use_on(agent, patient):
	debug_info.log("key gauge", true)
	overlay = overlay_resource.instance()
	return overlay
