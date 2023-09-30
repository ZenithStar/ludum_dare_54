class_name Blob extends Node2D

const particle_class : PackedScene = preload("res://prefabs/particle_ball.tscn")
const E = 2.71828182845904523536028747135266249775724709369995

@export var num_particles: int = 50
@export var cohesive_force: float = 100
@export var use_camera: bool = true

var particles : Array[RigidBody2D]
var camera: Camera2D
func _ready():
	# instantiate particles in a spiral so they don't immediately collide as much
	particles = []
	const loops = 2
	const radius = 100
	var final = E ** loops
	for i in range(num_particles, 0, -1):
		var particle = particle_class.instantiate()
		var magnitue = log(final * i / num_particles)
		var rot = magnitue * TAU 
		var orientation = Vector2(cos(rot), -sin(rot))
		var length = radius * magnitue / loops
		particle.position = orientation * length
		add_child(particle)
		particles.append(particle)
	if use_camera:
		camera = Camera2D.new()
		camera.position_smoothing_enabled = true
		add_child(camera)
	else:
		camera = null
		
	var tween = create_tween()
	tween.tween_property(self, "cohesive_force", 10000, 5)
	tween.tween_property(self, "cohesive_force", -1000, 5)
	tween.set_loops()


func _physics_process(delta):
	var center_of_mass: Vector2 = Vector2.ZERO
	for particle in particles:
		center_of_mass += particle.position
	center_of_mass /= particles.size()
	if camera:
		camera.position = center_of_mass
	for particle in particles:
		particle.apply_central_force(cohesive_force * (center_of_mass - particle.position) * delta)
