extends Area2D

var goal: Vector2
var dir

const SPEED := 900.0

func _physics_process(delta: float) -> void:
	var distance := global_position.distance_to(goal)

	if distance <= SPEED * delta:
		global_position = goal
		queue_free()
		return

	rotation = global_position.angle_to_point(goal) - PI / 2
	global_position = global_position.move_toward(goal, SPEED * delta)
