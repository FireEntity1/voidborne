extends Node2D

@export var timeline: DialogicTimeline

func _ready():
	global.fade(false,5, true)
	await get_tree().create_timer(6).timeout
	print("about to start")
	Dialogic.start(timeline)

func _process(delta):
	pass
