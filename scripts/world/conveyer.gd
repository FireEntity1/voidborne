extends Area2D

var player: Node2D
var active = false

func _physics_process(delta: float) -> void:
	if active and is_instance_valid(player):
		if not player.moving:
			player.velocity.x = 1500

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player = body
		active = true

func _on_body_exited(body: Node2D) -> void:
	active = false
