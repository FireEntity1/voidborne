extends Node2D

const LIGHTPOST = preload("res://components/decoration/lightpost.tscn")
@export var count: int
@export var space: int

func _ready() -> void:
	for i in range(count):
		var post = LIGHTPOST.instantiate()
		post.position = Vector2(position.x+i*space,position.y-288)
		add_child(post)
