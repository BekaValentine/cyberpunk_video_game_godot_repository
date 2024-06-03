extends Node

var active = false
var grid_position = null
var grid = null
var zoom_speed = 0.005
var rotation_speed_degrees = 1

func _ready():
	self.grid_position = $grid_position
	self.grid = $grid_position/grid
	self.grid_position.global_position = get_viewport().size/2

func _unhandled_input(event):
	if self.active:
		if event is InputEventMouseMotion:
			if Input.is_action_pressed("zoom_overlay"):
				self.zoom(event)
			else:
				self.reposition(event)
		
		elif Input.is_action_just_pressed("rotate_overlay_forward"):
			self.rotate_forward()

		elif Input.is_action_just_pressed("rotate_overlay_backward"):
			self.rotate_backward()

func set_active(yn):
	self.active = yn

func zoom(event):
	self.grid.scale.x = clamp(
		self.grid.scale.x + zoom_speed*event.relative.y,
		0.5,
		2
	)

	self.grid.scale.y = clamp(
		self.grid.scale.y + zoom_speed*event.relative.y,
		0.5,
		2
	)

func reposition(event):
	self.grid_position.global_position.x = clamp(
		self.grid_position.global_position.x + event.relative.x,
		0,
		get_viewport().size.x
	)
	
	self.grid_position.global_position.y = clamp(
		self.grid_position.global_position.y + event.relative.y,
		0,
		get_viewport().size.y
	)

func rotate_forward():
	self.rotate(1)

func rotate_backward():
	self.rotate(-1)

func rotate(d):
	self.grid.set_rotation_degrees(
		self.grid.get_rotation_degrees() +
		d*rotation_speed_degrees)
