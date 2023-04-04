extends RigidBody

var highlight_shape = null

func _ready():
	highlight_shape = $CSGSphere

func hold_collider_extents():
	var r = $CollisionShape.shape.radius
	return Vector3(r,r,r)

func hold():
	pass

func release():
	pass

func take():
	print("taken!")
