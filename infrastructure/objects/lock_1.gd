extends Lock


func _ready():
	highlight_shape = $CSGBox

func _init():
	._init()
	lock_type = "Type1"
