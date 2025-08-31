extends Node2D

@onready var sprite = $layer/sprite

var appearing = true
var disappearing = false

func _ready():
	sprite.modulate.a = 0

func _process(delta):
	if $layer/sprite.frame == 3:
		$layer/audio.play()
	if appearing:
		sprite.modulate.a += delta
		if sprite.modulate.a >= 1:
			appearing = false
			$layer/sprite.play()
			$timer.start()
		pass
	if disappearing:
		sprite.modulate.a -= delta
		if sprite.modulate.a <= 0:
			queue_free()

func _on_timer_timeout():
	disappearing = true
