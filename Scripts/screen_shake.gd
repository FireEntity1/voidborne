extends Node2D

var time = -1

var is_shaking = false

func _ready():
	run()

func run():
	if time > 0:
		await get_tree().create_timer(time)
		queue_free()
	if is_shaking:
		$layer/rect.material.set_shader_parameter("ShakeStrength", 0.2)
	else:
		$layer/rect.material.set_shader_parameter("ShakeStrength", 0.0)
