extends CharacterBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var speed = 600.0
var acceleration = 4500.0
var turn_acceleration = 600.0

var player: CharacterBody2D

var x_vel = 0.0

func _ready() -> void:
	pass

func _on_detection_body_entered(body: Node2D) -> void:
	if "player" in body:
		player = body

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity*delta
	
	if $detection.get_overlapping_bodies().has(player):
		$sprite.material.set_shader_parameter("velocity", velocity)
		$sprite.play("move")
		var distance = player.global_position.x - global_position.x
		var direction = sign(distance)
		if direction != 0:
			$sprite.flip_h = direction > 0
			var target_x = direction * speed
			var accel = acceleration
			if sign(velocity.x) != direction and abs(velocity.x) > 10:
				accel = turn_acceleration
			velocity.x = speed*direction
		await get_tree().create_timer(0.2).timeout
		x_vel += clamp(x_vel*acceleration*sign(distance),-1,1)
		global_position.x += sign(distance)*delta*speed*x_vel
	else:
		$sprite.material.set_shader_parameter("velocity",Vector2(0,3))
		$sprite.play("idle")
	move_and_slide()
