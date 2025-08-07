extends Node2D

@export var title: String

@export var subtitle = " "

@onready var label = $layer/label

var appearing = true
var disappearing = false

func _ready():
	label.text = title
	label.modulate.a = 0

func _process(delta):
	if appearing:
		label.modulate.a += delta
		if label.modulate.a >= 1:
			appearing = false
			$timer.start()
		pass
	if disappearing:
		label.modulate.a -= delta
		if label.modulate.a <= 0:
			queue_free()

func _on_timer_timeout():
	disappearing = true
