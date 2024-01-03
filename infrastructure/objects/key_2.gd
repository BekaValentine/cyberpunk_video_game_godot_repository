extends Key


func _ready():
	highlight_shape = $CSGBox

func _init():
	._init()
	key_type = "Type2"
	attack_strength = 0.25
