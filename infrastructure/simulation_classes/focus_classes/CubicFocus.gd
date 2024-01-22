class_name CubicFocus
extends SimObject

var horizontal_angle = 0
var vertical_angle = 0
var tween = null
var horizontal_pivot = null
var vertical_pivot = null
var rotation_rate = 1.0/360 # 1 second per 360 degrees = 1/4s per 90 degrees

func _ready():
	._ready()
	tween = $Tween
	horizontal_pivot = $VerticalPivot/HorizontalPivot
	vertical_pivot = $VerticalPivot

func set_horizontal_pivot_angle(theta):
	horizontal_pivot.rotate_y(deg2rad(theta - horizontal_angle))
	horizontal_angle = theta

func set_vertical_pivot_angle(theta):
	vertical_pivot.rotate_x(deg2rad(theta - vertical_angle))
	vertical_angle = theta

func focus_left():
	if !tween.is_active():
		var theta = -90
		var time = -theta * rotation_rate
		tween.interpolate_method(
			self,
			"set_horizontal_pivot_angle",
			horizontal_angle,
			horizontal_angle+theta,
			time
		)
		tween.start()

func focus_right():
	if !tween.is_active():
		var theta = 90
		var time = theta * rotation_rate
		tween.interpolate_method(
			self,
			"set_horizontal_pivot_angle",
			horizontal_angle,
			horizontal_angle+theta,
			time
		)
		tween.start()

func focus_up():
	if !tween.is_active() and vertical_angle > -30:
		var theta = -30
		var time = -theta * rotation_rate
		tween.interpolate_method(
			self,
			"set_vertical_pivot_angle",
			vertical_angle,
			vertical_angle+theta,
			time
		)
		tween.start()

func focus_down():
	if !tween.is_active() and vertical_angle < 30:
		var theta = 30
		var time = theta * rotation_rate
		tween.interpolate_method(
			self,
			"set_vertical_pivot_angle",
			vertical_angle,
			vertical_angle+theta,
			time
		)
		tween.start()
