extends CharacterBody2D

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var speed = 600.0
var acceleration = 4500.0
var turn_acceleration = 600.0

var health = 10.0
var player: CharacterBody2D

@export var attack_strength = 1

@onready var sprite: AnimatedSprite2D = $sprite
@onready var shader_mat: ShaderMaterial = sprite.material as ShaderMaterial

func _ready() -> void:
	remove_from_group("enemy")
	if shader_mat:
		shader_mat = shader_mat.duplicate()
		sprite.material = shader_mat
	await get_tree().create_timer(0.5).timeout
	add_to_group("enemy")

func _on_detection_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta

	var chasing_player := false

	if is_instance_valid(player):
		chasing_player = $detection.get_overlapping_bodies().has(player)

	if chasing_player:
		var has_ground = true
		
		var distance = player.global_position.x - global_position.x
		var direction = sign(distance)
		if direction > 0:
			has_ground = $groundcast_l.is_colliding()
		elif direction < 0:
			has_ground = $groundcast_r.is_colliding()
		
		if has_ground:
			sprite.play("move")
			
			if direction != 0:
				sprite.flip_h = direction > 0
			
			var target_x = direction * speed
			var accel = acceleration
		
			if sign(velocity.x) != direction and abs(velocity.x) > 10.0:
				accel = turn_acceleration
		
			velocity.x = move_toward(velocity.x, target_x, accel * delta)
		else:
			sprite.play("idle")
			velocity.x = 0.0
	else:
		sprite.play("idle")
		velocity.x = move_toward(velocity.x, 0.0, acceleration * delta)

	move_and_slide()

	if shader_mat:
		var shader_velocity = Vector2(velocity.x, 0.0)

		if sprite.flip_h:
			shader_velocity.x *= -1.0

		shader_mat.set_shader_parameter("velocity", shader_velocity)

func damage(damage):
	health -= float(damage)
	if health <= 0.0:
		die()
		return
	var direction = sign(player.global_position.x - global_position.x)
	if abs(player.global_position.x - global_position.x) < 80:
		direction = 0
	velocity.x -= direction*300
	modulate.r = 1.8
	await get_tree().create_timer(0.1).timeout
	modulate.r = 1.2
	await get_tree().create_timer(0.1).timeout

func die():
	$death_particles.emitting = true
	$detection.monitoring = false
	$sprite.hide()
	remove_from_group("enemy")
	await $death_particles.finished
	queue_free()
