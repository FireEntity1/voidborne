extends Area2D

var collected = false

func _physics_process(delta: float) -> void:
	if collected:
		$sprite.modulate.a -= delta*5.0

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		Global.state.light_shards += 1
		collected = true
		$collect.emitting = true
		await $collect.finished
		queue_free()
