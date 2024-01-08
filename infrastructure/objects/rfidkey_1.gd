extends RFIDKey


func _ready():
	highlight_shape = $CSGBox

func _init():
	._init()
	key_code = "67890"
