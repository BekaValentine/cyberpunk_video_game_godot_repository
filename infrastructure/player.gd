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
var min_step_depth = 0.1

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
			var current_delta = stair_start_position + stair_up_vec - self.global_transform.origin
			var current_distance = current_delta.length()
			if current_distance > 0.001:
				var target_velocity = stair_speed * current_delta.normalized()
				var velocity_delta = target_velocity - self.linear_velocity
				self.apply_central_impulse(velocity_delta)
			stair_phase_frac = 1 - current_delta.y / stair_up_distance
			if stair_phase_frac >= 0.99:
				stair_phase_frac = 0.0
				stair_phase = 1
				self.global_transform.origin = stair_start_position + stair_up_vec
		else:
			var current_delta = stair_start_position + stair_up_vec + stair_fwd_vec - self.global_transform.origin
			var current_distance = current_delta.length()
			if current_distance > 0.001:
				var target_velocity = stair_speed * current_delta.normalized()
				var velocity_delta = target_velocity - self.linear_velocity
				self.apply_central_impulse(velocity_delta)
			stair_phase_frac = 1 - current_distance / stair_fwd_distance
			if stair_phase_frac >= 0.9:
				using_stair = false
		
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
		
	# The logic of trying to use stairs works like this:
	#
	# 1. Test if the path forward is obstructed. If not, then no possible step.
	# 2. Since we can move, we need to determine where we're going to land on
	#    the step. So we make three movements:
	#   1. A move up to the max step height
	#   2. A move forward to the min step depth
	#   3. A move back down to see where we land
	# 3. This total movement -- the travel -- defines the step. BUT! we might
	#    be on a ramp! So we need to see if the direct travel path is obstructed
	#    and if it is, there must be a step there, otherwise there's a ramp and
	#    we're not using stairs.
	
	# Here we just show some debugging info, not essential
#	if move_direction.length() > 0.01:
#		stair_rays.show()
#	else:
#		stair_rays.hide()
#	var delta_rotation = self.get_rotation() - self_initial_rotation
#	stair_rays.set_rotation(-self.get_rotation())
#	stair_rays.rotate_y(sign(Vector3(1,0,0).cross(Vector3(move_direction.x, 0, move_direction.z)).y)*Vector3(1,0,0).angle_to(Vector3(move_direction.x, 0, move_direction.z)))
	
	# The result of motion tests
	var res
	
	# Here we move forward to test if we're obstructed
	var move_dir = 0.005 * move_direction.normalized()
	res = self.cast_motion(self.global_transform.origin, move_dir, 0)
	if not res:
		# not colliding with anything, so must not be next to a step
		return
		
	# Well set the origin of future tests to be slightly away from the
	# obstruction, otherwise we might collide with it when we run the tests
	# for vertical motion
	var test_origin = self.global_transform.origin - 0.001*move_direction.normalized()
	
	# Here we test upward
	var up_dir = max_step_height * Vector3.UP
	var up_distance
	res = self.cast_motion(test_origin, up_dir, 10);
	if not res:
		up_distance = 1
	else:
		up_distance = res[0]
	if up_distance == 0:
		return
	var up_dest = up_distance * up_dir
	
	# And now forward
	var fwd_dir = min_step_depth * move_direction.normalized()
	var fwd_distance
	res = self.cast_motion(test_origin + up_dest, fwd_dir, 0)
	if not res:
		fwd_distance = 1
	else:
		fwd_distance = res[0]
	if fwd_distance < 1:
		return
	var fwd_dest = fwd_distance * fwd_dir
	
	# And now back down
	var down_dir = -up_dest
	var down_distance
	res = self.cast_motion(test_origin + up_dest + fwd_dest, down_dir, 10)
	if not res:
		down_distance = 1
	else:
		down_distance = res[0]
	var down_dest = down_distance * down_dir
	
	# If we haven't travelled anywhere up a step or ramp, then we can just
	# quit early
	var travel = up_dest + fwd_dest + down_dest
	var travel_distance = travel.length()
	if travel_distance < 0.01 or travel.y <= 0:
		return
	
	# But otherwise we test if we're going up a ramp
	var along_distance
	res = self.cast_motion(test_origin + 0.01 * Vector3.UP, travel, 0)
	if not res:
		return

	# We're not going up a ramp, so we must be at a step!
	using_stair = true
	stair_phase = 0
	stair_phase_frac = 0.0
	stair_start_position = self.global_transform.origin
	stair_up_vec = Vector3(0, travel.y, 0)
	stair_up_distance = travel.y
	stair_fwd_distance = min_step_depth
	stair_fwd_vec = min_step_depth * Vector3(travel.x, 0, travel.z).normalized()
	move_direction = Vector3.ZERO

func use_stair():
	var bottom_hit = !!stair_ray_bottom.get_collider()
	var top_hit = !!stair_ray_top.get_collider()
#	if stair_use and not bottom_hit:
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

func cast_motion(origin : Vector3, dir : Vector3, recursive_steps : int):
	var shape = body_collider.shape
	# raise the shape by half its height so that its at the same position
	# as the collider, then add a millimeter so it doesnt collide with ground
	origin += Vector3(0,shape.height/2 + 0.001,0)
	
	# Create collision parameters
	var params = PhysicsShapeQueryParameters.new()
	params.set_shape(shape)
	params.transform.origin = origin + dir
	params.collide_with_bodies = true
	params.exclude = [self]
	params.margin = 0
	
	var space_state = get_world().direct_space_state
	var results = space_state.intersect_shape(params)
	if len(results) > 0:
		var lower = 0
		var upper = 1
		var mid = 0.5
		var forward
		for i in range(recursive_steps):
			mid = 0.5*(upper + lower)
			forward = mid*dir
			params.transform.origin = origin + forward
			var new_results = space_state.intersect_shape(params)
			if len(new_results) > 0:
				results = new_results
				upper = mid
			else:
				lower = mid
		return [mid, results]
	return null
		
