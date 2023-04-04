extends RigidBody

export var fall_limit = -100
export var gravity = -9.8
export var jump_speed = 5.0
export var mouse_sensitivity = 0.002
export var run_speed = 5.0
export var walk_speed = 1.0
export var air_speed = 0.1
export var push_force = 1

var backpack = null
var body_collider = null
var crouch_tween = null
var camera = null
var hold_camera = null
var hold_collider = null
var hold_position = null
var on_floor = false
var pivot = null
var pickup_detect_ray = null

var highlighted_object = null
var held_object = null
var should_show_highlight = true
var object_highlight = null
var self_initial_rotation = Vector3.ZERO
var held_object_initial_rotation = Vector3.ZERO
var velocity = Vector3.ZERO
var velocity_after_move_and_slide = null
var stand_height = null
var crouch_height = 0.75
var crouch_time = 0.25
var crouching = false
var in_crouching_transition = false
var pushed_objects = []
var pushed_objects_changed = false
var inventory_open = false

var tick = 0

var WORLD_OBJECT_COLLISION_MASK = 2;
var HELD_COLLISION_MASK = 4;
var NORMAL_COLLISION_MASK = 2 | 4;






func _ready():
	backpack = $backpack
	body_collider = $body_collider
	camera = $pivot/camera
	hold_camera = $pivot/camera/hold_viewport_container/hold_viewport/hold_camera
	hold_collider = $hold_collider
	crouch_tween = $crouch_tween
	hold_position = $pivot/hold_position
	object_highlight = $object_highlight
	pickup_detect_ray = $pivot/pickup_detect_ray
	pivot = $pivot
	stand_height = pivot.transform.origin.y
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	hold_collider.disabled = true





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
			if highlighted_object.has_method("hold"):
				pickup_object()
				

	elif Input.is_action_just_pressed("secondary_interaction"):
		if held_object:
			drop_object()

	elif Input.is_action_just_pressed("take"):
		if held_object:
			if held_object.has_method("take"):
				take_object()
	
	elif Input.is_action_just_pressed("use"):
		if highlighted_object:
			if highlighted_object.has_method("use"):
				use_object()
		

func toggle_crouch():
	if not in_crouching_transition:
		crouching = !crouching
		
		crouch_tween.interpolate_method(
			self,
			"set_camera_height",
			pivot.transform.origin.y,
			crouch_height if crouching else stand_height,
			crouch_time,
			Tween.TRANS_LINEAR,
			Tween.EASE_IN_OUT
		)
		in_crouching_transition = true
		crouch_tween.start()

func finished_crouching_transition():
	in_crouching_transition = false

func set_camera_height(h):
	pivot.transform.origin.y = h
	if held_object:
		set_held_object_position()

func pickup_object():
	hold_object(highlighted_object)
	highlighted_object = null

func hold_object(obj):
	held_object = obj
	if not held_object.get_parent():
		self.get_parent().add_child(held_object)
#	hold_position.add_child(held_object)
	self_initial_rotation = self.get_rotation()
	if held_object.transform.basis.y.angle_to(Vector3.UP) > 0.01:
		held_object_initial_rotation = Vector3.ZERO
	else:
		held_object_initial_rotation = held_object.get_rotation()
#	held_object.mode = RigidBody.MODE_KINEMATIC
	held_object.collision_mask = HELD_COLLISION_MASK
	held_object.hold()
	hold_collider.shape.extents = held_object.hold_collider_extents()
	hold_collider.disabled = false

func throw_object():
	held_object.release()
	var old_transform = held_object.global_transform
	held_object.mode = RigidBody.MODE_RIGID
	held_object.collision_mask = NORMAL_COLLISION_MASK
	held_object.global_transform = old_transform
	held_object.apply_impulse(Vector3(0,0,0), -10*camera.global_transform.basis.z)
	held_object = null
	hold_collider.disabled = true

func drop_object():
	held_object.release()
	var old_transform = held_object.global_transform
	held_object.mode = RigidBody.MODE_RIGID
	held_object.collision_mask = NORMAL_COLLISION_MASK
	held_object.global_transform = old_transform
	held_object = null
	hold_collider.disabled = true

func take_object():
	held_object.take()
	backpack.store_item(held_object)
	held_object.get_parent().remove_child(held_object)
	
func use_object():
	highlighted_object.use(held_object)
	





################ Physics-based UI ################



func _integrate_forces(state):
	for index in state.get_contact_count():
		if state.get_contact_local_shape(index) == body_collider.get_index() and\
			state.get_contact_local_normal(index).dot(Vector3.UP) > 0.9:
			on_floor = true
			return
	on_floor = false

func _physics_process(delta):
	tick += 1
	if not self.viewing_ui():
		move(delta)
		rotate_held_object()
		interact_objects()

func is_on_floor():
	return on_floor

func move(delta):
	velocity = Vector3.ZERO
	var move_direction = Vector3.ZERO
	# determine the direction to move in
	var basis = global_transform.basis
	if Input.is_action_pressed("move_forward"):
		move_direction -= basis.z
	if Input.is_action_pressed("move_backward"):
		move_direction += basis.z
	if Input.is_action_pressed("move_left"):
		move_direction -= basis.x
	if Input.is_action_pressed("move_right"):
		move_direction += basis.x
	
#	if is_on_floor():
	# we're walking, running, or jumping
	
	# determine the horizontal velocity to move
	var speed
	if is_on_floor():
		# we're on the floor so we can move under our own power a lot
		
		if Input.is_action_pressed("run"):
			# we're running
			speed = run_speed
		else:
			# we're walking
			speed = walk_speed

		var vel = move_direction.normalized() * speed
		velocity.x = vel.x
		velocity.z = vel.z
		
		velocity = velocity - Vector3(linear_velocity.x, 0, linear_velocity.z)

		# determine the vertical velocity
		if Input.is_action_just_pressed("jump"):
			# we're jumping, so we just set the vertical speed
			velocity.y = jump_speed

		self.apply_central_impulse(velocity)
		
	elif Vector3(linear_velocity.x, 0, linear_velocity.z).length() < air_speed:
		# we're in the air and don't already have some momentum so we can move
		# tiny bit to get onto ledges
		
		speed = air_speed
		
		var vel = move_direction.normalized() * speed
		velocity.x = vel.x
		velocity.z = vel.z
		
		self.apply_central_impulse(velocity)

	
	#prevents infinite falling
	if translation.y < fall_limit:
		scene_manager.reload_scene()

	hold_camera.global_transform = camera.global_transform

func interact_objects():
	
	var raycast_hit = pickup_detect_ray.get_collider()
	
	if raycast_hit:
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
	hold_collider.global_transform.origin = held_object.global_transform.origin
