extends CharacterBody2D

var darkening = false

var attack_strength = 2

var player_pos = Vector2.ZERO

const gravity = 5000
var falling = false

var dead = false

func _ready() -> void:
	$darken.start()
	$sprite.material = $sprite.material.duplicate()

func _physics_process(delta: float) -> void:
	if dead:
		return
	if falling:
		velocity.y += gravity*delta
		$sprite.material.set_shader_parameter("dir",velocity/5000.0)
		#velocity.x = move_toward(velocity.x,position.x-player_pos.x,delta)
	else:
		$sprite.material.set_shader_parameter("dir",Vector2.ZERO)
	#global_position.y += velocity.y*delta
	move_and_slide()

	for i in get_slide_collision_count():
		var body = get_slide_collision(i).get_collider()
		if body.is_in_group("player"):
			body.hit(attack_strength,true,global_position)
			die()
			return

	if is_on_floor():
		$fall.play()
		die()
	if darkening:
		$sprite.self_modulate -= Color(delta, delta, delta)/8.0
	else:
		$sprite.self_modulate += Color(delta,delta,delta)/8.0

func _on_detection_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_pos = body.global_position
		fire()
		falling = true

func fire():
	$sprite.play("default")

func _on_body_entered(body: Node2D) -> void:
	pass

func _on_darken_timeout() -> void:
	darkening = not darkening

func damage(amtd):
	die()

func die():
	if dead:
		return
	dead = true
	$collision.disabled = true
	$sprite.hide()
	$death_particles.emitting = true
	await $death_particles.finished
	queue_free()
