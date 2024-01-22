class_name BookFocus
extends SimObject

var page_scene = preload("res://infrastructure/simulation_classes/focus_classes/BookPage.tscn")
var dir = 1
var horizontal_angle = 0
var page_turn_tween = null
var book_shift_tween = null
var vertical_pivot = null
var rotation_rate = 1.0/360 # 1/2 second per 360 degrees = 1/4s per 180 degrees
export(Array, Texture) var pages = []
var half_width = 0
var page_pivots = []
var left_page_pivots = []
var right_page_pivots = []

func _ready():
	._ready()
	page_turn_tween = $PageTurnTween
	page_turn_tween.connect("tween_completed", self, "_on_page_turn_tween_completed")
	page_turn_tween.connect("tween_step", self, "_on_page_turn_tween_step")
	book_shift_tween = $BookShiftTween
	vertical_pivot = $VerticalPivot

	# set up pages
	for i in range(len(pages)):
		var page = pages[i]
		debug_info.log("page " + str(i), page)
		var page_pivot = page_scene.instance()
		page_pivots.push_back(page_pivot)
		var page_mesh = page_pivot.get_node("Page")
		page_mesh.material = SpatialMaterial.new()
		page_mesh.material.albedo_texture = page
		page_mesh.material.set_feature(SpatialMaterial.FEATURE_TRANSPARENT, true)
		vertical_pivot.add_child(page_pivot)
		right_page_pivots.push_back(page_pivot)

		if i == 0:
			half_width = 0.5 * page_mesh.mesh.get_aabb().size.x * page_mesh.scale.x
			page_pivot.show()
		else:
			page_pivot.hide()
		
	vertical_pivot.global_transform.origin.x = -half_width

func _on_page_turn_tween_completed(object, key):
	if dir == 1:
		if len(left_page_pivots) > 0:
			left_page_pivots[-1].hide()
		if len(right_page_pivots) > 1:
			right_page_pivots[1].show()
		left_page_pivots.push_back(right_page_pivots[0])
		right_page_pivots.pop_front()
	if dir == -1:
		if len(right_page_pivots) > 0:
			right_page_pivots[0].hide()
		if len(left_page_pivots) > 1:
			left_page_pivots[-2].show()
		right_page_pivots.push_front(left_page_pivots[-1])
		left_page_pivots.pop_back()

func _on_page_turn_tween_step(object, key, elapsed, value):
	var cutoff = 10
	if dir == 1:
		if value < -cutoff and len(right_page_pivots) > 1:
			right_page_pivots[1].show()
		if value < -180+cutoff and len(left_page_pivots) > 0:
			left_page_pivots[-1].hide()
	elif dir == -1:
		if value > cutoff and len(left_page_pivots) > 1:
			left_page_pivots[-2].show()
		if value > 180-cutoff and len(right_page_pivots) > 0:
			right_page_pivots[0].hide()



func set_horizontal_pivot_angle(theta):
	if dir == 1:
		debug_info.log("page " + str(len(left_page_pivots)), theta)
		right_page_pivots[0].rotate_y(deg2rad(theta - horizontal_angle))
		horizontal_angle = theta
	elif dir == -1:
		debug_info.log("page " + str(len(right_page_pivots)), theta)
		left_page_pivots[-1].rotate_y(deg2rad(theta - horizontal_angle))
		horizontal_angle = theta
	
func set_book_shift(frac):
	vertical_pivot.global_transform.origin.x = frac*half_width

func focus_left():
	if !page_turn_tween.is_active():
		if len(left_page_pivots) > 0:
			dir = -1
			horizontal_angle = 0
			var theta = 180
			var time = theta * rotation_rate
			page_turn_tween.interpolate_method(
				self,
				"set_horizontal_pivot_angle",
				horizontal_angle,
				horizontal_angle+theta,
				time
			)

			if len(left_page_pivots) == 1:
				var end = 0
				if len(left_page_pivots) == 1:
					end = 1
				book_shift_tween.interpolate_method(
					self,
					"set_book_shift",
					end,
					-1,
					time
				)
				book_shift_tween.start()
			
			elif len(right_page_pivots) == 0:
				book_shift_tween.interpolate_method(
					self,
					"set_book_shift",
					1,
					0,
					time
				)
				book_shift_tween.start()

			page_turn_tween.start()

func focus_right():
	if !page_turn_tween.is_active():
		if len(right_page_pivots) > 0:
			dir = 1
			horizontal_angle = 0
			var theta = -180
			var time = -theta * rotation_rate
			page_turn_tween.interpolate_method(
				self,
				"set_horizontal_pivot_angle",
				horizontal_angle,
				horizontal_angle+theta,
				time
			)
			
			if len(left_page_pivots) == 0:
				var end = 0
				if len(right_page_pivots) == 1:
					end = 1
				book_shift_tween.interpolate_method(
					self,
					"set_book_shift",
					-1,
					end,
					time
				)
				book_shift_tween.start()
			
			elif len(right_page_pivots) == 1:
				book_shift_tween.interpolate_method(
					self,
					"set_book_shift",
					0,
					1,
					time
				)
				book_shift_tween.start()
				
			page_turn_tween.start()
