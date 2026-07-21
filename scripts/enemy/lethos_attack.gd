extends Area2D

var goal: Vector2

func _physics_process(delta: float) -> void:
	var dir = global_position.direction_to(goal)
	global_position += dir
