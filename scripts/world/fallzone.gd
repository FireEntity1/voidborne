extends Area2D

@export var return_point := Vector2.ZERO

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage(1)
		body.global_position = return_point
		Dialogic.emit_signal("signal_event","screen_instant_black")
