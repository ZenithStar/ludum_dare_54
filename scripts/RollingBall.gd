class_name RollingBall extends RigidBody3D

@export var force_factor: float = 10.0

func _physics_process(delta):
	var force_input = Input.get_vector("move_left", "move_right", "move_forward", "move_back").rotated(-$CameraJoint.rotation.y)
	
	apply_central_force(Vector3(force_input.x, 0.0, force_input.y) * force_factor * delta)
