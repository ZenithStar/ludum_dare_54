class_name RollingBall extends RigidBody3D

@export var force_factor: float = 20.0

var force_vector: Vector3 = Vector3.ZERO

func _process(delta):
	var force_vector_display = force_vector / force_factor * 2.0
	$ForceVector.position = position + (force_vector_display / 2.0)
	$ForceVector.height = force_vector_display.length()
	$ForceVector.look_at(force_vector_display)

func _integrate_forces(state):
	var mean_normal = Vector3.ZERO
	for x in state.get_contact_count():
		mean_normal += state.get_contact_impulse(x)
	mean_normal = mean_normal.normalized()
	var force_plane = Plane(mean_normal)
	var force_input = Input.get_vector("move_left", "move_right", "move_forward", "move_back").rotated(-$CameraJoint.rotation.y)
	var force_direction = force_plane.project(Vector3(force_input.x, 0.0, force_input.y)).normalized()
	force_vector = force_direction * clamp(force_input.length(), 0.0, 1.0) * force_factor
	apply_central_force(force_vector * state.get_step())
	
