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
var hold_position = null
var on_floor = false
var pivot = null
var pickup_detect_ray = null
var stair_rays = null
var stair_ray_bottom = null
var stair_ray_top = null
var using_stair = false
var stair_start_position = null
var stair_up_vec = null
var stair_up_distance = 0
var stair_fwd_vec = null
var stair_fwd_distance = 0
#var stair_start_position = null
#var stair_middle_position = null
#var stair_end_position = null
var stair_phase = 0
var stair_phase_frac = 0.0
var stair_speed = 2

var highlighted_object = null
var held_object = null
var should_show_highlight = true
var object_highlight = null
var self_initial_rotation = Vector3.ZERO
var held_object_initial_rotation = Vector3.ZERO
var velocity = Vector3.ZERO
var velocity_after_move_and_slide = null
var move_direction = Vector3.ZERO
var stand_height = null
var crouch_height = 0.75
var crouch_time = 0.25
var crouching = false
var in_crouching_transition = false
var pushed_objects = []
var pushed_objects_changed = false
var inventory_open = false
var max_step_height = 0.178
var max_step_depth = 0.279

var tick = 0

var WORLD_OBJECT_COLLISION_MASK = 2;
var HELD_COLLISION_MASK = 0;
var NORMAL_COLLISION_MASK = 2 | 4;




func _ready():
	backpack = $backpack
	body_collider = $body_collider
	camera = $pivot/camera
	hold_camera = $pivot/camera/hold_viewport_container/hold_viewport/hold_camera
	crouch_tween = $crouch_tween
	hold_position = $pivot/hold_position
	object_highlight = $object_highlight
	pickup_detect_ray = $pivot/pickup_detect_ray
	pivot = $pivot
	stair_rays = $stair_rays
	stair_ray_bottom = $stair_rays/stair_ray_bottom
	stair_ray_top = $stair_rays/stair_ray_top
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
	self_initial_rotation = self.get_rotation()
	if held_object.transform.basis.y.angle_to(Vector3.UP) > 0.01:
		held_object_initial_rotation = Vector3.ZERO
	else:
		held_object_initial_rotation = held_object.get_rotation()
	held_object.mode = RigidBody.MODE_KINEMATIC
	held_object.collision_mask = HELD_COLLISION_MASK
	held_object.start_hold()
	held_object.hold()

func throw_object():
	held_object.end_hold()
	held_object.release()
	var old_transform = held_object.global_transform
	held_object.mode = RigidBody.MODE_RIGID
	held_object.collision_mask = NORMAL_COLLISION_MASK
	held_object.global_transform = old_transform
	held_object.apply_impulse(Vector3(0,0,0), -10*camera.global_transform.basis.z)
	held_object = null

func drop_object():
	held_object.end_hold()
	held_object.release()
	var old_transform = held_object.global_transform
	held_object.mode = RigidBody.MODE_RIGID
	held_object.collision_mask = NORMAL_COLLISION_MASK
	held_object.global_transform = old_transform
	held_object = null

func take_object():
	held_object.take()
	backpack.store_item(held_object)
	held_object.get_parent().remove_child(held_object)
	held_object = null
	
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
		try_stairs()
#		use_stair()

func is_on_floor():
	return on_floor

func move(delta):
	if using_stair:
		
		if stair_phase == 0:
#			$debug_message.show_text(str(stair_phase) + " " + str(stair_phase_frac))
			stair_phase_frac += stair_speed * delta / stair_up_distance
			stair_phase_frac = min(1.0, stair_phase_frac)
			self.global_transform.origin = stair_start_position + stair_phase_frac*stair_up_vec
#			$debug_message.show_text(str(stair_phase_frac))
			if stair_phase_frac >= 1.0:
				stair_phase_frac = 0.0
				stair_phase = 1
		else:
#			$debug_message.show_text(str(stair_phase) + " " + str(stair_phase_frac))
			stair_phase_frac += stair_speed * delta / stair_fwd_distance
			stair_phase_frac = min(1.0, stair_phase_frac)
			self.global_transform.origin = stair_start_position + stair_up_vec + stair_phase_frac*stair_fwd_vec
#			$debug_message.show_text(str(stair_phase_frac))
			
			if stair_phase_frac >= 1.0:
				using_stair = false
#				$debug_message.show_text("Done!")
		
	else:
		
		velocity = Vector3.ZERO
		move_direction = Vector3.ZERO
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
			
			# actual velocity we need to add is the target velocity minus current velocity
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

func try_stairs():
	if using_stair or not is_on_floor() or move_direction == Vector3.ZERO:
		return
	
	if move_direction.length() > 0.01:
		stair_rays.show()
	else:
		stair_rays.hide()
	var delta_rotation = self.get_rotation() - self_initial_rotation
	stair_rays.set_rotation(-self.get_rotation())
	stair_rays.rotate_y(sign(Vector3(1,0,0).cross(Vector3(move_direction.x, 0, move_direction.z)).y)*Vector3(1,0,0).angle_to(Vector3(move_direction.x, 0, move_direction.z)))
	
#	var bottom_hit = !!stair_ray_bottom.get_collider()
#	var top_hit = !!stair_ray_top.get_collider()
#	$debug_message.show_text(str(bottom_hit) + " / " + str(top_hit))
#	$debug_message.show_text(str(stair_ray_bottom.get_collider()))
	var move_dir = 0.1 * move_direction.normalized()
	var move_dist = self.compute_move(self.global_transform.origin, move_dir)
#	$debug_message.show_text(str(move_dir) + " " + str(move_dist))
	var move_hit = move_dist <= 0.35
	if not move_hit:
#		$debug_message.show_text("florp " + str(move_dir))
		using_stair = false
		return
	
#	$debug_message.show_text("Step up?")
#		self.apply_central_impulse(0.75*jump_speed*global_transform.basis.y)
#		self.add_central_force(Vector3(0,2000,0))
#		using_stair = true
	var up_dir = max_step_height * Vector3.UP
	var up_distance = self.compute_move(self.global_transform.origin, up_dir)
	var up_dest = up_distance * up_dir
#	$debug_message.show_text("Up: " + str(up_dir) + " " + str(up_distance) + " " + str(up_dest))
#	$debug_message.show_text(str(up_distance))
	if up_distance == 0:
		return
	var fwd_dir = max_step_depth * move_direction.normalized()
	var fwd_distance = self.compute_move(self.global_transform.origin + up_dest, fwd_dir)
	var fwd_dest = fwd_distance * fwd_dir
#	$debug_message.show_text("Fwd: " + str(fwd_dir) + " " + str(fwd_distance) + " " + str(fwd_dest))
	if fwd_distance == 0:
		return
	if fwd_dest.length() > 0.1:
		fwd_dest = 0.1 * fwd_dest.normalized()
	var down_dir = -up_dest
	var down_distance = self.compute_move(self.global_transform.origin + up_dest + fwd_dest, down_dir)
	var down_dest = down_distance * down_dir
	var travel = up_dest + fwd_dest + down_dest
	var travel_distance = travel.length()
	$debug_message.show_text(str(up_dest) + " " + str(fwd_dest) + " " + str(down_dest) + " " + str(travel) + " " + str(travel_distance))
#	$debug_message.show_text(str(travel))
#	$debug_message.show_text(str(up_distance) + " " + str(fwd_distance) + " " + str(down_distance))
	if travel_distance < 0.01 or travel.y <= 0:
		return
	
#	print(str(move_direction) + " " + str(fwd_dir) + " " + str(fwd_distance) + " " + str(fwd_dest) + " " + str(travel))
	using_stair = true
	stair_phase = 0
	stair_phase_frac = 0.0
	stair_start_position = self.global_transform.origin
	stair_up_vec = Vector3(0, travel.y, 0)
	stair_up_distance = stair_up_vec.length()
	stair_fwd_vec = Vector3(travel.x, 0, travel.z)
	stair_fwd_distance = stair_fwd_vec.length()
#	$debug_message.show_text(str(stair_up_distance))
#			stair_start_position = self.global_transform.origin
#			stair_middle_position = up_dest
#			stair_end_position = fwd_dest

func use_stair():
	var bottom_hit = !!stair_ray_bottom.get_collider()
	var top_hit = !!stair_ray_top.get_collider()
#	$debug_message.show_text(str(bottom_hit) + " / " + str(top_hit))
#	if stair_use and not bottom_hit:
#		$debug_message.show_text("Step passed")
#		stair_use = false

func rotate_held_object():
	if held_object:
		set_held_object_position()
		var delta_rotation = self.get_rotation() - self_initial_rotation
		held_object.set_rotation(held_object_initial_rotation + delta_rotation)

func viewing_ui():
	return backpack.visible

func set_held_object_position():
	held_object.global_transform.origin = hold_position.global_transform.origin



func compute_move(origin : Vector3, dir : Vector3):
	var shape = body_collider.shape
	origin += Vector3(0,shape.height/2,0)
	
	# Create collision parameters
	var params = PhysicsShapeQueryParameters.new()
	params.set_shape(shape)
	params.transform.origin = origin
	params.collide_with_bodies = true
	params.exclude = [self]
	params.margin = 0
	#params.set_collision_mask(mask)
	
	
	# Get distance fraction and position of first collision
	var space_state = get_world().direct_space_state
#	$debug_message.show_text(str(space_state.collide_shape(params)))
	var results = space_state.cast_motion(params, dir)
	
#	$debug_message.show_text(str(results))
	
	if len(results) == 0:
		return 1
	else:
		return results[0]
