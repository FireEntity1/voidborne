extends Node2D

@export var title: String
@export var subtitle = " "

@onready var layer = $layer

@onready var title_node = $layer/label
@onready var sub = $layer/subtitle

var appearing = true
var disappearing = false

var black = false

func _ready():
	$layer/label.text = title
	$layer/subtitle.text = subtitle
	title_node.modulate.a = 0
	sub.modulate.a = 0
	if black:
		$layer/label.modulate.v = 0
		$layer/subtitle.modulate.v = 0

func _process(delta):
	if appearing:
		title_node.modulate.a += delta
		sub.modulate.a += delta
		if title_node.modulate.a >= 1:
			appearing = false
			$timer.start()
		pass
	
	if disappearing:
		title_node.modulate.a -= delta
		sub.modulate.a -= delta
		if title_node.modulate.a <= 0:
			queue_free()

func _on_timer_timeout():
	disappearing = true
