extends Node2D

var time = -1

var is_glitching = false

func _ready():
	run()

func run():
	if time > 0:
		await get_tree().create_timer(time)
		queue_free()
	if is_glitching:
		$layer/rect.material.set_shader_parameter("shake_rate", 1.0)
	else:
		$layer/rect.material.set_shader_parameter("shake_rate", 0.0)
