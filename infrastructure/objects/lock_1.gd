extends Lock


func _ready():
	highlight_shape = $CSGBox

func _init():
	._init()
	lock_types = ["Type1", "Type2"]
	max_unlock_time = 5
