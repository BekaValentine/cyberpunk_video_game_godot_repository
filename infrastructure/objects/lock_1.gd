extends Lock


func _ready():
	highlight_shape = $CSGBox

func _init():
	._init()
	lock_types = ["Type1", "Type2"]
	base_difficulty = 0.75
