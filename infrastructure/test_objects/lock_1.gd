extends PhysicalLock

var normal_color = null

func _init():
	._init()
	lock_types = ["Type1", "Type2"]
	valid_pin_heights = [
		[1],
		[2],
		[3,4]
	]
	max_unlock_time = 5

func start_highlight():
	normal_color = $CSGBox.material.albedo_color
	$CSGBox.material.albedo_color = normal_color.lightened(0.5)

func end_highlight():
	$CSGBox.material.albedo_color = normal_color
