extends RigidBody

func hold_collider_extents():
	return $CollisionShape.shape.extents

func start_hold():
	$CSGBox.layers = 2

func end_hold():
	$CSGBox.layers = 1

func hold():
	pass

func release():
	pass
