extends CharacterBody2D

const SPEED = 900.0
const JUMP_VELOCITY = 1000.0

var jumped = JUMP_VELOCITY

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = -jumped
		jumped -= delta*20.0
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y = 5
		jumped = JUMP_VELOCITY
	
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if Input.is_action_just_pressed("left"):
		$sprite.scale.x = 1
	elif Input.is_action_just_pressed("right"):
		$sprite.scale.x = -1
	
	if not is_on_floor():
		if velocity.y < 100.0:
			if direction:
				$sprite.play("jump_move")
			else:
				$sprite.play("jump")
		elif velocity.y > 100.0:
			if direction:
				$sprite.play("fall_move")
			else:
				$sprite.play("fall")
	else:
		$sprite.play("default")
	
	#camera_smooth(delta)
	move_and_slide()
	#position = position.round()

#func camera_smooth(delta: float):
	#var smooth_speed = 12.0
	#var target = global_position
	#camera_float_pos.x = lerp_avg(camera_float_pos.x, target.x, SMOOTH_X, delta)
	#
	#var diff_y = target.y - camera_float_pos.y
	#if abs(diff_y) > VERTICAL_DEADZONE:
		#var actual_target_y = target.y - (sign(diff_y)*VERTICAL_DEADZONE)
		#camera_float_pos.y = lerp_avg(camera_float_pos.y,actual_target_y,SMOOTH_Y,delta)
	#
	#camera_float_pos = camera_float_pos.lerp(global_position, 1.0 - exp(-smooth_speed * delta))
	#
	#$camera.global_position = camera_float_pos.round()
#
#func lerp_avg(current: float, target: float, speed: float, delta: float):
	#return lerp(current, target, 1.0 - exp(-speed * delta))
