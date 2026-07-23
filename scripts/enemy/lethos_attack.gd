extends CharacterBody2D

var goal: Vector2
var dir

var attack_strength = 1

const SPEED := 900.0

var done = false

func _physics_process(delta: float) -> void:
	var distance := global_position.distance_to(goal)
	$particles.global_rotation_degrees = 0
	if distance <= SPEED * delta:
		global_position = goal
		if done:
			return
		else:
			done = true
			$sprite.hide()
			$collision.disabled = true
			$particles.emitting = true
			await get_tree().create_timer(1.5).timeout
			queue_free()
			return

	rotation = global_position.angle_to_point(goal) - PI / 2
	global_position = global_position.move_toward(goal, SPEED * delta)
