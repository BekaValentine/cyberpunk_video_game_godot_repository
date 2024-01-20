extends SimObject

var horizontal_angle = 0
var vertical_angle = 0
var tween = null
var horizontal_pivot = null
var vertical_pivot = null
var rotation_rate = 0.5/360 # 1/2 second per 360 degrees = 1/4s per 180 degrees

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
		var theta = -180
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
		var theta = 180
		var time = theta * rotation_rate
		tween.interpolate_method(
			self,
			"set_horizontal_pivot_angle",
			horizontal_angle,
			horizontal_angle+theta,
			time
		)
		tween.start()