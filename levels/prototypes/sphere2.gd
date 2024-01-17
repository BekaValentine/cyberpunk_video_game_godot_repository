extends SimObject

var normal_color = null

func _ready():
	hold_size = 1

func start_highlight():
	normal_color = $CSGSphere.material.albedo_color
	$CSGSphere.material.albedo_color = normal_color.lightened(0.5)

func end_highlight():
	$CSGSphere.material.albedo_color = normal_color
