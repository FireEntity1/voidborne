extends Area2D

@export var return_point := Vector2.ZERO

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.take_damage(1)
		body.global_position = return_point
		Global.fadescreen(true,true,true)
		Global.mod_can_move(false)
		await get_tree().create_timer(1).timeout
		Global.mod_can_move(true)
		Global.fadescreen(false,true,false)
