extends RFIDLock


func _ready():
	highlight_shape = $CSGBox

func _init():
	._init()
	max_unlock_time = 5
