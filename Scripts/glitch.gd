extends Node2D

var time = -1

func _ready():
	if time > 0:
		await get_tree().create_timer(time)
		queue_free()
