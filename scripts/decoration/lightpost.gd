extends AnimatedSprite2D

func _ready() -> void:
	await get_tree().create_timer(randf_range(0.0,1.0)).timeout
	frame = 0
	while true:
		await get_tree().create_timer(8.0).timeout
		await get_tree().create_timer(randf_range(0.0,1.0)).timeout
		frame = 0
