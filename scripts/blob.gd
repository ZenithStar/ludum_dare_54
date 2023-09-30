class_name Blob extends CanvasGroup

const particle_class : PackedScene = preload("res://prefabs/particle_ball.tscn")
const E = 2.71828182845904523536028747135266249775724709369995

@export var num_particles: int = 50
@export var cohesive_force: float = 100
@export var use_camera: bool = true

var particles : Array[RigidBody2D]
var camera: Camera2D
var sprite: AnimatedSprite2D
var sprite_size: Vector2
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
	if has_node("AnimatedSprite2D"):
		sprite = $AnimatedSprite2D
		sprite_size = sprite.sprite_frames.get_frame_texture("default",0).get_size()
	var tween = create_tween()
	tween.tween_property(self, "cohesive_force", 10000, 5)
	tween.tween_property(self, "cohesive_force", -1000, 5)
	tween.set_loops()


func _physics_process(delta):
	var center_of_mass: Vector2 = Vector2.ZERO
	var bounding_box: Rect2 = Rect2(particles[0].position, particles[0].position)
	for particle in particles:
		center_of_mass += particle.position
		if particle.position.x < bounding_box.position.x:
			bounding_box.position.x = particle.position.x
		if particle.position.y < bounding_box.position.y:
			bounding_box.position.y = particle.position.y
		if particle.position.x > bounding_box.end.x:
			bounding_box.end.x = particle.position.x
		if particle.position.y > bounding_box.end.y:
			bounding_box.end.y = particle.position.y
	center_of_mass /= particles.size()
	if camera:
		camera.position = center_of_mass
	for particle in particles:
		particle.apply_central_force(cohesive_force * (center_of_mass - particle.position) * delta)
	if sprite:
		sprite.position = center_of_mass
		print( bounding_box.get_center(), center_of_mass)
		#print(sprite_size, bounding_box.size)
		sprite.scale = bounding_box.size / sprite_size
		sprite.scale.x *= 1.5
		
