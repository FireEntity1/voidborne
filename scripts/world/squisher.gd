extends Area2D

func _on_timer_timeout() -> void:
	$sprite.play("default")
	await get_tree().create_timer(0.4).timeout
	for body in get_overlapping_bodies():
		if body.is_in_group("player"):
			body.hit(1,true,global_position)
