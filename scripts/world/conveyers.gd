extends Node2D

const CONVEYER = preload("res://components/foundry/conveyer.tscn")

@export var length: int = 1
@export var dir: int = 1

func _ready() -> void:
	for i in range(length):
		var new = CONVEYER.instantiate()
		new.position += Vector2(i*128*dir,-32)
		new.dir = dir
		add_child(new)
