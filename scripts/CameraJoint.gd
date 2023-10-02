class_name CameraJoint extends SpringArm3D

@export var mouse_sensitivity: float = 0.05
@export var joystick_sensitivity: float = 90.0

func _ready():
	set_as_top_level(true)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
@export_category("Zoom")
@export var zoom_speed: float = 2.0 ** (1.0 / 10.0)
@export var joy_zoom_speed: float = 8.0
@export var zoom_ease_duration = 0.25
@export var zoom_clamp_min: float = 0.1
@export var zoom_clamp_max: float = 10.0
@export var default_length: float = 5.0
@onready var zoom_setpoint: float = 1.0:
	get:
		return zoom_setpoint
	set(value):
		zoom_setpoint = clamp(value, zoom_clamp_min, zoom_clamp_max)
		create_tween().tween_property(self, "spring_length", zoom_setpoint * default_length, zoom_ease_duration)

func rotate_camera(input: Vector2):
	rotation_degrees.x += -input.y
	rotation_degrees.x = clamp(rotation_degrees.x, -90.0, 60.0)
	#rotation = Quaternion.from_euler(Vector3.UP * (event.relative.x * mouse_sensitivity)) * rotation
	rotation_degrees.y += -input.x
	rotation_degrees.y = wrapf(rotation_degrees.y, 0.0, 360.0)

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseMotion:
		var mouse_camera = event.relative * mouse_sensitivity
		rotate_camera(mouse_camera)
	if event is InputEventMouseButton:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				if event.pressed:
					if Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
						Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
					elif Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
						Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			MOUSE_BUTTON_WHEEL_UP:
				zoom_setpoint /= zoom_speed
			MOUSE_BUTTON_WHEEL_DOWN:
				zoom_setpoint *= zoom_speed

func _process(delta):
	position = get_parent().position
	var joy_camera = Input.get_vector("camera_left", "camera_right", "camera_up", "camera_down") * joystick_sensitivity * delta
	rotate_camera(joy_camera)
	var zoom: float = Input.get_axis("zoom_in", "zoom_out")
	zoom_setpoint *= (joy_zoom_speed ** (zoom * delta))
	
	
	
