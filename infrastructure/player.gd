extends "res://infrastructure/objects/Character.gd"

export var mouse_sensitivity = 0.002

var backpack = null
var pivot = null
var camera = null
var hold_camera = null
var hold_position = null
var pickup_detect_ray = null
var highlighted_object = null
var held_object = null
var should_show_highlight = true
var object_highlight = null
var self_initial_rotation = Vector3.ZERO
var held_object_initial_rotation = Vector3.ZERO
var inventory_open = false
var should_move_forward = false
var should_move_backward = false
var should_move_left = false
var should_move_right = false
var stand_height = null
var crouch_height = 0.75

var WORLD_OBJECT_COLLISION_MASK = 2;
var HELD_COLLISION_MASK = 0;
var NORMAL_COLLISION_MASK = 2 | 4;



func _ready():
	._ready()

	backpack = $backpack
	pivot = $pivot
	camera = $pivot/camera
	hold_camera = $pivot/camera/hold_viewport_container/hold_viewport/hold_camera
	hold_position = $pivot/hold_position
	object_highlight = $object_highlight
	pickup_detect_ray = $pivot/pickup_detect_ray

	stand_height = pivot.transform.origin.y
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)





################ Event-driven UI ################



func _unhandled_input(event):
	if event is InputEventMouseMotion:
		self.rotate_y(-event.relative.x * mouse_sensitivity)
		pivot.rotate_x(-event.relative.y * mouse_sensitivity)
		pivot.rotation.x = clamp(pivot.rotation.x, -1.2, 1.2)
	
	elif Input.is_action_pressed("crouch"):
		toggle_crouch()
	
	elif Input.is_action_pressed("primary_interaction"):
		if held_object:
			throw_object()
		
		elif highlighted_object:
			if highlighted_object is SimObject and highlighted_object.holdable:
				pickup_object()
				

	elif Input.is_action_just_pressed("secondary_interaction"):
		if held_object:
			drop_object()

	elif Input.is_action_just_pressed("take"):
		if held_object:
			if held_object:
				take_object()
	
	elif Input.is_action_just_pressed("use"):
		if highlighted_object and highlighted_object is SimObject and highlighted_object.interactable:
			use_object()
	
	elif Input.is_action_pressed("backpack"):
		self.toggle_backpack()

func crouching_height_change(h):
	.crouching_height_change(h)

	pivot.transform.origin.y = lerp(crouch_height, stand_height, crouch_state)
	
	if held_object:
		set_held_object_position()

func pickup_object():
	hold_object(highlighted_object)
	highlighted_object = null

func hold_object(obj):	
	held_object = obj
	if not held_object.get_parent():
		self.get_parent().add_child(held_object)
	self_initial_rotation = self.get_rotation()
	if held_object.transform.basis.y.angle_to(Vector3.UP) > 0.01:
		held_object_initial_rotation = Vector3.ZERO
	else:
		held_object_initial_rotation = held_object.get_rotation()
	held_object.mode = RigidBody.MODE_KINEMATIC
	held_object.collision_mask = HELD_COLLISION_MASK
	held_object._hold()

func throw_object():
	held_object._release()
	var old_transform = held_object.global_transform
	held_object.mode = RigidBody.MODE_RIGID
	held_object.collision_mask = NORMAL_COLLISION_MASK
	held_object.global_transform = old_transform
	held_object.apply_impulse(Vector3(0,0,0), -10*camera.global_transform.basis.z)
	held_object = null

func drop_object():
	held_object._release()
	var old_transform = held_object.global_transform
	held_object.mode = RigidBody.MODE_RIGID
	held_object.collision_mask = NORMAL_COLLISION_MASK
	held_object.global_transform = old_transform
	held_object = null

func take_object():
	held_object._stash()
	backpack.store_item(held_object)
	held_object.get_parent().remove_child(held_object)
	held_object = null
	
func use_object():
	highlighted_object._use(self, held_object)

func toggle_backpack():
	if not backpack.visible:
	# 	self.hide_backpack()
	# else:
		self.show_backpack()

func show_backpack():
	self.set_process_unhandled_input(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	backpack.show()

func hide_backpack():
	self.set_process_unhandled_input(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	backpack.hide()

func stash_object(obj):
	obj._stash()
	backpack.store_item(obj)

func unstash_object(obj):
	if held_object: return false
	
	self.hide_backpack()
	obj._unstash()
	self.hold_object(obj)

	return true
	





################ Physics-based UI ################

func physics_activities():
	calculate_behavior_from_user_inputs()
	.physics_activities()
	interact_objects()
	rotate_held_object()


func calculate_behavior_from_user_inputs():
	should_move_forward = Input.is_action_pressed("move_forward")
	should_move_backward = Input.is_action_pressed("move_backward")
	should_move_left = Input.is_action_pressed("move_left")
	should_move_right = Input.is_action_pressed("move_right")

	should_jump = Input.is_action_just_pressed("jump")
	should_run = Input.is_action_pressed("run")
	should_climb_up = Input.is_action_pressed("move_forward")
	should_climb_down = Input.is_action_pressed("move_backward")

	# set the move target
	move_target = self.global_transform.origin #camera.global_transform.origin + -camera.global_transform.basis.z

	# determine the direction to move in
	var basis = global_transform.basis
	if should_move_forward:
		move_target -= basis.z
	if should_move_backward:
		move_target += basis.z
	if should_move_left:
		move_target -= basis.x
	if should_move_right:
		move_target += basis.x

	debug_info.log("move target", move_target)

func move():
	.move()

	hold_camera.global_transform = camera.global_transform

func interact_objects():
	
	var raycast_hit = pickup_detect_ray.get_collider()

	debug_info.log("player.interact_objects", raycast_hit.name if raycast_hit else "no interactable object")
	
	if raycast_hit and \
		raycast_hit is SimObject and \
		(raycast_hit.interactable or raycast_hit.hold_size):
		highlighted_object = raycast_hit
	else:
		highlighted_object = null

	if highlighted_object and should_show_highlight:
		show_highlight()
	else:
		hide_highlight()

func show_highlight():
	var bounds = highlighted_object.highlight_shape.get_transformed_aabb()
	var origin = bounds.position
	var size = bounds.size
	var points = [
		camera.unproject_position(origin),
		camera.unproject_position(origin + Vector3(size.x,0,0)),
		camera.unproject_position(origin + Vector3(size.x,0,size.z)),
		camera.unproject_position(origin + Vector3(size.x,size.y,0)),
		camera.unproject_position(origin + Vector3(size.x,size.y,size.z)),
		camera.unproject_position(origin + Vector3(0,size.y,0)),
		camera.unproject_position(origin + Vector3(0,size.y,size.z)),
		camera.unproject_position(origin + Vector3(0,0,size.z)),
	]
	
	var left = points[0].x
	var top = points[0].y
	var right = points[0].x
	var bottom = points[0].y
	
	for p in points:
		if p.x < left:
			left = p.x
		
		if right < p.x:
			right = p.x
		
		if p.y < top:
			top = p.y
		
		if bottom < p.y:
			bottom = p.y
	
	object_highlight.set_position(Vector2(left,top))
	object_highlight.set_size(Vector2(right-left,bottom-top))
	object_highlight.visible = true

func hide_highlight():
	object_highlight.visible = false

func rotate_held_object():
	if held_object:
		set_held_object_position()
		var delta_rotation = self.get_rotation() - self_initial_rotation
		held_object.set_rotation(held_object_initial_rotation + delta_rotation)

func viewing_ui():
	return backpack.visible

func set_held_object_position():
	held_object.global_transform.origin = hold_position.global_transform.origin
