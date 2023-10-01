class_name Spawner extends Node3D

const ball_class : PackedScene = preload("res://prefabs/play_ball.tscn")
@export var radius_upper_limit: float = 10.0
@export var radius_lower_limit: float = 5.0
@export var exit_force_range: float = 1000.0
@export var noise: FastNoiseLite
@onready var elapsed = 0.0
@onready var accumulation = 0.0
@onready var orientation = Vector2(1.0,0.0)
@export var spawn_rate: float = 1.0
@export var spin_rate: float = 1.0
@export var displacement_rate: float = 1.0
func _physics_process(delta):
	accumulation += noise.get_noise_1d(elapsed) * delta
	var angle = atan2(orientation.y, orientation.x)
	angle += noise.get_noise_1d(elapsed)
	print(noise.get_noise_1d(elapsed))
	while accumulation > spawn_rate:
		accumulation -= spawn_rate
		var ball = ball_class.instantiate()
		ball.apply_central_force(Vector3())
	elapsed += delta
