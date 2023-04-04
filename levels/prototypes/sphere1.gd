extends StaticBody

var highlight_shape = null

func _ready():
	highlight_shape = $CSGSphere

func use(equipped_object):
	print("used!", equipped_object)
