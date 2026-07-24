extends CharacterBody2D

var goal: Vector2
var dir

var attack_strength = 1

var ground
var direction: Vector2
const SPEED := 900.0

var done = false
func _ready() -> void:
	direction = global_position.direction_to(goal)
	rotation = direction.angle() - PI / 2
	
func _physics_process(delta: float) -> void:
	var distance := global_position.distance_to(goal)
	$particles.global_rotation_degrees = 0

	if not done and global_position.y > ground:
		die()

	global_position += direction * SPEED * delta

func die():
	done = true
	$sprite.hide()
	$collision.disabled = true
	$particles.emitting = true
	await get_tree().create_timer(1.5).timeout
	queue_free()

func attack():
	die()
