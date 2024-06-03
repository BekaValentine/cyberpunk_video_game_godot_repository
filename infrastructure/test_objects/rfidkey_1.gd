extends RFIDKey

var normal_color = null
var temperature = 30

func _init():
	._init()
	key_code = "12345"

func start_highlight():
	normal_color = $CSGBox.material.albedo_color
	$CSGBox.material.albedo_color = normal_color.lightened(0.5)

func end_highlight():
	$CSGBox.material.albedo_color = normal_color