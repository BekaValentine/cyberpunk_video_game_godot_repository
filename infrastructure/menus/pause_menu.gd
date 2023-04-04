extends Container

func _ready():
	unpause_game()

func _input(event):
	if event.is_action_pressed("pause_menu"):
		if !get_tree().paused:
			pause_game()
		else:
			unpause_game()

func pause_game():
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	self.show()

func unpause_game():
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	self.hide()

func back_to_game():
	unpause_game()

func goto_main_menu():
	unpause_game()
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	scene_manager.goto_main_menu()
