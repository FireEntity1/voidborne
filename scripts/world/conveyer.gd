extends StaticBody2D

var player: Node2D
var active = false

@export var dir: int = 1
@export var length: int = 1

func _ready() -> void:
	constant_linear_velocity = Vector2(700, 0)
	
