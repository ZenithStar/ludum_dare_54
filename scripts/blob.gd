class_name Blob extends Node2D

const particle_class : PackedScene = preload("res://prefabs/particle_ball.tscn")

@export var num_particles: int = 50
@export var cohesive_force: float = 1000
@export var use_camera: bool = true

var particles : Array[RigidBody2D]
var camera: Camera2D
func _ready():
	particles = []
	for x in num_particles:
		var particle = particle_class.instantiate()
		add_child(particle)
		particles.append(particle)
	if use_camera:
		camera = Camera2D.new()
		add_child(camera)
	else:
		camera = null
		
	var tween = create_tween()
	tween.tween_property(self, "cohesive_force", 10, 1)
	tween.tween_property(self, "cohesive_force", 10000, 1)
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
