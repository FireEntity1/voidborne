extends Area2D

@onready var parent = get_parent()

var done = false

func hit():
	if done:
		return
	done = true
	$sprite.play()
	await $sprite.animation_finished
	parent.flash()
	Dialogic.emit_signal("signal_event","light_switch")
	Global.state["outlands_light"] = true
