extends SimObject

var vtilt = 0

func affected_by(agent, tool_object):
	debug_info.log("inspectable 2 used", true)

func focus_left():
	var old = vtilt
	if old != 0:
		self.reset_tilt()
	$FocusPivot/FocusShape.rotate_y(deg2rad(90))
	if old != 0:
		$FocusPivot/FocusShape.rotate_x(deg2rad(old))
		vtilt = old

func focus_right():
	var old = vtilt
	if old != 0:
		self.reset_tilt()
	$FocusPivot/FocusShape.rotate_y(deg2rad(-90))
	if old != 0:
		$FocusPivot/FocusShape.rotate_x(deg2rad(old))
		vtilt = old

func focus_up():
	if vtilt >= 0:
		$FocusPivot/FocusShape.rotate_x(deg2rad(-30))
		vtilt -= 30

func focus_down():
	if vtilt <= 0:
		$FocusPivot/FocusShape.rotate_x(deg2rad(30))
		vtilt += 30

func reset_tilt():
	if vtilt > 0:
		$FocusPivot/FocusShape.rotate_x(deg2rad(-30))
	elif vtilt < 0:
		$FocusPivot/FocusShape.rotate_x(deg2rad(30))
	vtilt = 0
