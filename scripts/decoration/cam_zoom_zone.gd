extends Area2D

@export var zoom: float = 1.0
var is_player_inside = false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.cam_zoom = zoom

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.cam_zoom = 1.0
