extends CharacterBody2D

var darkening = false

var attack_strength = 2

var player_pos = Vector2.ZERO

const gravity = 5000
var falling = false

func _ready() -> void:
	$darken.start()

func _physics_process(delta: float) -> void:
	if falling:
		velocity.y += gravity*delta
		$sprite.material.set_shader_parameter("dir",velocity/5000.0)
		velocity.x = move_toward(velocity.x,position.x-player_pos.x,delta)
	global_position.y += velocity.y*delta
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
