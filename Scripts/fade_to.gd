extends Node2D

@export var to = true
@export var timer = 5
@export var black = true

@onready var fade_node = $layer/fade

func _ready():
	if black:
		fade_node.color = Color(0,0,0,1)
	else:
		fade_node.color = Color(1,1,1,1)
	if to:
		fade_node.modulate.a = 0
	else:
		fade_node.modulate.a = 1
	await get_tree().create_timer(timer).timeout
	queue_free()

func _process(delta):
	if to:
		fade_node.modulate.a += delta/5
	else:
		fade_node.modulate.a -= delta/5
