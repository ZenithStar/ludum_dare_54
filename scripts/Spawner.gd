class_name Spawner extends Node3D

const ball_class : PackedScene = preload("res://prefabs/play_ball.tscn")
@export var radius_upper_limit: float = 79.0
@export var radius_lower_limit: float = 70.0
@export var exit_force_range: float = 10000.0
@onready var noise: FastNoiseLite = FastNoiseLite.new()
@onready var elapsed = 0.0
@onready var accumulation = 0.0
@onready var orientation = Vector2(1.0,0.0)
@export var spawn_delay: float = 0.2
@export var spin_rate: float = PI
@onready var elapsed_offsets: Array[float] = [randf_range(0.0, 1000000.0), randf_range(0.0, 1000000.0), randf_range(0.0, 1000000.0), randf_range(0.0, 1000000.0)]
@export var good_ratio: float = 0.2
var display: CSGTorus3D
func _ready():
	display = CSGTorus3D.new()
	display.material = StandardMaterial3D.new()
	display.material.albedo_color = Color.BLUE
	add_child(display)

func _physics_process(delta):
	elapsed += delta
	var angle = atan2(orientation.y, orientation.x)
	angle += noise.get_noise_1d(elapsed+elapsed_offsets[0]) * spin_rate * delta
	orientation = Vector2(cos(angle),sin(angle))
	accumulation += (1+noise.get_noise_1d(elapsed+elapsed_offsets[1])) / 2.0 * delta
	var radius = ((radius_upper_limit - radius_lower_limit) / 2.0 * (1.0 + noise.get_noise_1d(elapsed+elapsed_offsets[2]))) + radius_lower_limit
	display.position = position + (Vector3(orientation.x, 0.0, orientation.y) * radius)
	while accumulation > spawn_delay:
		accumulation -= spawn_delay
		var ball = ball_class.instantiate()
		ball.top_level = true
		ball.position = display.position
		ball.add_to_group("Consumable")
		if randf() > good_ratio:
			ball.add_to_group("GoodBall")
			var material = StandardMaterial3D.new()
			material.albedo_color = Color.GREEN
			ball.get_node("CSGSphere3D").material = material
		else:
			ball.add_to_group("BadBall")
			var material = StandardMaterial3D.new()
			material.albedo_color = Color.CRIMSON
			ball.get_node("CSGSphere3D").material = material
		add_child(ball)
		ball.apply_central_force(Vector3(cos(angle+(PI/2)), 0.0, sin(angle+(PI/2))) * exit_force_range * noise.get_noise_1d(elapsed+elapsed_offsets[3]))

