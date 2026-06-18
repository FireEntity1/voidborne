extends AnimatedSprite2D

func _ready() -> void:
	frame = randi_range(0,8)
	while true:
		await get_tree().create_timer(2.0).timeout
		frame = randi_range(0,8)
