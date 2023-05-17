extends ItemList

var stored_items = []
var player

func _ready():
	player = get_parent()

func show():
	.show()
	debug_info.log("backpack log", "show")

func hide():
	.hide()
	debug_info.log("backpack log", "hide")

func _unhandled_input(event):
	if not self.visible: return
	
	var handled = false

	if event is InputEventMouseMotion:
		handled = true
		
	elif Input.is_action_pressed("backpack"):
		player.hide_backpack()
		handled = true
		
	if handled:
		get_tree().set_input_as_handled()
	
func store_item(obj):
	self.stored_items.push_front(obj)
	self.add_item(obj.name)

func unstore_item(i):
	stored_items.remove(i)
	self.remove_item(i)

func item_selected(i):
	if player.unstash_object(stored_items[i]):
		self.unstore_item(i)
	else:
		debug_info.log("backpack log", "hrmph")
		self.unselect_all()
