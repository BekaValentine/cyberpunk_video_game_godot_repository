class_name DebugInfo
extends CanvasLayer


var label = null
var messages = {}

func _ready():
	label = $Label
	# label.hide()

func show():
	label.show()

func hide():
	label.hide()

func log(msg_name: String, msg_content):
	if msg_content == null:
		messages.erase(msg_name)
	else:
		if not (msg_content is String):
			msg_content = str(msg_content)
		
		messages[msg_name] = msg_content
	
	show_text()

func show_text():
	var text = ""
	for msg_name in messages:
		text += msg_name +": " + messages[msg_name] + "\n"
	
	label.text = text
