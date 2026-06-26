extends Area2D

@export var to: String
@export var black: bool = true

func _on_body_entered(body: Node2D) -> void:
	Global.mod_can_move(false)
	Global.fadescreen(true,black)
	await get_tree().create_timer(4.0).timeout
	if body.is_in_group("player"):
		Global.change_scene(to)
	Global.mod_can_move(true)
	Global.fadescreen(false,black)
