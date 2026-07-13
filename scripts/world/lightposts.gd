extends Node2D

const LIGHTPOST = preload("res://components/decoration/lightpost.tscn")
const TOPLIGHT = preload("res://components/decoration/toplight.tscn")
@export var count: int
@export var space: int
@export_enum("lightpost","toplight") var type: String = "lightpost"

func _ready() -> void:
	for i in range(count):
		var post = LIGHTPOST.instantiate() if type == "lightpost" else TOPLIGHT.instantiate()
		post.position = Vector2(i*space,-270) if type == "lightpost" else Vector2(i*space,250)
		add_child(post)
