class_name RollingBall extends RigidBody3D

@onready var active:bool = true
@export var force_factor: float = 500000.0
@export var density: float = 1000.0
@export var radius: float = 0.5:
	get:
		return radius
	set(value):
		if value <= 0.0:
			active = false
			Hud.game_over()
		else:
			radius = value
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(self, "mass", density * RollingBall.sphere_radius_to_volume(radius), 0.25)
		tween.tween_property($CSGSphere3D, "radius", radius, 0.25)
		tween.tween_property($CollisionShape3D.shape, "radius", radius, 0.25)
		$CSGSphere3D.visibility_range_begin_margin = radius * 4.0
		$CSGSphere3D.visibility_range_begin = radius * 6.0
		$CameraJoint.default_length = radius * 10.0
		
func _ready():
	mass = density * RollingBall.sphere_radius_to_volume(radius)
	
static func sphere_radius_to_volume(x:float) -> float:
	return (4.0/3.0 * PI * (x**3.0))
static func sphere_volume_to_radius(x:float) -> float:
	if x >= 0.0:
		return (x / 4.0 * 3.0 / PI ) ** (1.0/3.0)
	else:
		return 0.0

func _unhandled_input(event):
	if event.is_action("restart"):
		get_tree().reload_current_scene()
		Hud.reset()

func _integrate_forces(state):
	if active:
		var mean_normal = Vector3.ZERO
		for x in state.get_contact_count():
			var object = state.get_contact_collider_object(x)
			if object.is_in_group("Consumable"):
				object.queue_free()
				if object.is_in_group("GoodBall"):
					radius = RollingBall.sphere_volume_to_radius (RollingBall.sphere_radius_to_volume(radius) + RollingBall.sphere_radius_to_volume(0.5) * object.size)
					Hud.score += 1 * object.size
				if object.is_in_group("BadBall"):
					radius = RollingBall.sphere_volume_to_radius (RollingBall.sphere_radius_to_volume(radius) - (RollingBall.sphere_radius_to_volume(0.5) * 10 * object.size) )
					Hud.score -= 10 * object.size
					var explode_force = state.get_contact_local_normal(x) * force_factor * 30.0 * RollingBall.sphere_radius_to_volume(radius)
					apply_central_force(explode_force)
			mean_normal += state.get_contact_impulse(x)
		mean_normal = mean_normal.normalized()
		var force_plane = Plane(mean_normal)
		var force_input = Input.get_vector("move_left", "move_right", "move_forward", "move_back").rotated(-$CameraJoint.rotation.y)
		var force_direction = force_plane.project(Vector3(force_input.x, 0.0, force_input.y)).normalized()
		var force_vector = force_direction * clamp(force_input.length(), 0.0, 1.0) * force_factor * RollingBall.sphere_radius_to_volume(radius)
		apply_central_force(force_vector * state.get_step())
	
