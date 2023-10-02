class_name Spawner extends Node3D

const ball_class : PackedScene = preload("res://prefabs/play_ball.tscn")
const cel_shader : Shader = preload("res://cel-shader/cel-shader-base.gdshader")
const cel_shader_outline : Shader = preload("res://cel-shader/outline.gdshader")
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
var outline_material: ShaderMaterial
var goodball_material: ShaderMaterial
var badball_material: ShaderMaterial 
func _ready():
	outline_material = ShaderMaterial.new()
	outline_material.shader = cel_shader_outline
	goodball_material = ShaderMaterial.new()
	goodball_material.shader = cel_shader
	goodball_material.next_pass = outline_material
	goodball_material.set_shader_parameter("color",Color.GREEN)
	badball_material = ShaderMaterial.new()
	badball_material.shader = cel_shader
	badball_material.next_pass = outline_material
	badball_material.set_shader_parameter("color",Color.CRIMSON)
	display = CSGTorus3D.new()
	display.material = ShaderMaterial.new()
	display.material.shader = cel_shader
	display.material.next_pass = outline_material
	display.material.set_shader_parameter("color",Color.BLUE)
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
			ball.get_node("CSGSphere3D").material = goodball_material
		else:
			ball.add_to_group("BadBall")
			ball.get_node("CSGSphere3D").material = badball_material
		add_child(ball)
		ball.apply_central_force(Vector3(cos(angle+(PI/2)), 0.0, sin(angle+(PI/2))) * exit_force_range * noise.get_noise_1d(elapsed+elapsed_offsets[3]))

