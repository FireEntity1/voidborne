extends CharacterBody2D

var camera_float_pos = Vector2.ZERO
const SMOOTH_X = 8.0
const SMOOTH_Y = 4.0
const VERTICAL_DEADZONE = 32.0

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

var jumped = 0.0

func _ready() -> void:
	camera_float_pos = global_position
	$camera.top_level = true

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = -jumped
		jumped -= delta*20.0
	if Input.is_action_just_released("jump") or (-0.1 < velocity.y and velocity.y < 0.1):
		velocity.y = 5
		jumped = 400.0

	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	camera_smooth(delta)
	move_and_slide()
	position = position.round()

func camera_smooth(delta: float):
	var smooth_speed = 12.0
	var target = global_position
	camera_float_pos.x = lerp_avg(camera_float_pos.x, target.x, SMOOTH_X, delta)
	
	var diff_y = target.y - camera_float_pos.y
	if abs(diff_y) > VERTICAL_DEADZONE:
		var actual_target_y = target.y - (sign(diff_y)*VERTICAL_DEADZONE)
		camera_float_pos.y = lerp_avg(camera_float_pos.y,actual_target_y,SMOOTH_Y,delta)
	
	camera_float_pos = camera_float_pos.lerp(global_position, 1.0 - exp(-smooth_speed * delta))
	
	$camera.global_position = camera_float_pos.round()

func lerp_avg(current: float, target: float, speed: float, delta: float):
	return lerp(current, target, 1.0 - exp(-speed * delta))
