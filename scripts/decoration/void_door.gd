extends StaticBody2D

@export var open_signal = "_door_voidnexus_boss"

func open():
	$sprite.hide()
	$collision.disabled = true

func hit():
	$sprite.play("default")
