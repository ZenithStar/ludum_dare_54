class_name SpawnerSpawner extends Node3D

@export var spawn_period: float = 30.0

@onready var duration_remaining = 0.0
func _physics_process(delta):
	duration_remaining -= delta
	if duration_remaining <= 0.0:
		var spawner = Spawner.new()
		add_child(spawner)
		duration_remaining = spawn_period
