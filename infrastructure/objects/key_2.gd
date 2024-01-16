extends Key

var normal_color = null

func _init():
	._init()
	key_type = "Type2"
	attack_strength = 0.5

func start_highlight():
	normal_color = $CSGBox.material.albedo_color
	$CSGBox.material.albedo_color = normal_color.lightened(0.5)

func end_highlight():
	$CSGBox.material.albedo_color = normal_color