class_name CameraJoint extends SpringArm3D

@export var mouse_sensitivity: float = 0.05
@export var joystick_sensitivity: float = 45.0

func _ready():
	set_as_top_level(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func rotate_camera(input: Vector2):
	rotation_degrees.x += -input.y
	rotation_degrees.x = clamp(rotation_degrees.x, -90.0, 30.0)
	#rotation = Quaternion.from_euler(Vector3.UP * (event.relative.x * mouse_sensitivity)) * rotation
	rotation_degrees.y += -input.x
	rotation_degrees.y = wrapf(rotation_degrees.y, 0.0, 360.0)

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseMotion:
		var mouse_camera = event.relative * mouse_sensitivity
		rotate_camera(mouse_camera)

func _process(delta):
	position = get_parent().position
	var joy_camera = Input.get_vector("camera_left", "camera_right", "camera_up", "camera_down") * joystick_sensitivity * delta
	rotate_camera(joy_camera)
	
	
