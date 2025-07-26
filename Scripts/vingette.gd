extends Node2D

var progress = 0
var is_up = true

func _ready():
	pass

func _process(delta):
	if is_up and progress < 1:
		progress += delta
	elif not is_up and progress >= 0:
		progress -= delta
	$layer/rect.material.set_shader_parameter("MainAlpha", progress)
