extends RigidBody

var highlight_shape = null

func _ready():
	highlight_shape = $CSGBox

func hold_collider_extents():
	return $CollisionShape.shape.extents

func hold():
	pass

func release():
	pass
