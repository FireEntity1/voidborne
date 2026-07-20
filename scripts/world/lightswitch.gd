extends Area2D

@onready var parent = get_parent()

func hit():
	$sprite.play()
	parent.flash()
