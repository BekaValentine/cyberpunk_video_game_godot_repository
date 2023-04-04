extends ItemList

var stored_items = []
var player

func _ready():
	player = get_parent()
	
func _input(event):
	if event.is_action_pressed("backpack"):
		if self.visible:
			self.hide_inventory()
		else:
			self.show_inventory()

func show_inventory():
	player.set_process_input(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	self.show()

func hide_inventory():
#	player.set_process_input(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	self.hide()

func store_item(obj):
	self.stored_items.push_front(obj)
	self.add_item(obj.name)

func item_selected(i):
	var selected_object = stored_items[i]
	self.hide_inventory()
	stored_items.remove(i)
	self.remove_item(i)
	player.hold_object(selected_object)
#	print("Selected " + str(i) + "=" + selected_object.name)
