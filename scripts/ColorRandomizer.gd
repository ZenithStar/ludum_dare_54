class_name ColorRandomizer extends Node

@export var property: String
@export var noise: FastNoiseLite
@onready var elapsed = 0.0
@onready var elapsed_offsets: Array[float] = [randf_range(0.0, 1000000.0), randf_range(0.0, 1000000.0), randf_range(0.0, 1000000.0)]
func rescaled_noise(t: float) -> float:
	return (noise.get_noise_1d(t) + 1.0) / 2.0
func _process(delta):
	elapsed += delta
	var new_color = Color.from_hsv(rescaled_noise(elapsed+elapsed_offsets[0]), 1.0, 1.0)
	get_parent().set(property, new_color)
