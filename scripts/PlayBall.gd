class_name PlayBall extends RigidBody3D

var base_volume: float = RollingBall.sphere_radius_to_volume(0.5)
@export var density: float = 100.0
@export var size: int = 1:
	get:
		return size
	set(value):
		if value <= 0:
			queue_free()
		else:
			size = value
		var tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(self, "mass", density * base_volume * size, 0.25)
		tween.tween_property($CSGSphere3D, "radius", RollingBall.sphere_volume_to_radius(size * base_volume), 0.25)
		tween.tween_property($CollisionShape3D.shape, "radius", RollingBall.sphere_volume_to_radius(size * base_volume), 0.25)

func _ready():
	mass = density * base_volume * size
	$CSGSphere3D.radius = RollingBall.sphere_volume_to_radius(size * base_volume)
	$CollisionShape3D.shape.radius = RollingBall.sphere_volume_to_radius(size * base_volume)

@onready var alive:bool = true
func combine_with(other: PlayBall):
	if(alive):
		if size >= other.size:
			size += other.size
			other.queue_free()
			other.alive = false
			apply_central_force(Vector3.UP * mass * 100.0)

func _on_body_entered(body):
	if(alive):
		if body is PlayBall:
			if is_in_group("GoodBall"):
				if body.is_in_group("GoodBall"):
					combine_with(body)
			elif is_in_group("BadBall"):
				if body.is_in_group("BadBall"):
					combine_with(body)
