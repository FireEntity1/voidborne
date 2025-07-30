extends Node2D

@export var id: String
@export var timeline: DialogicTimeline

func _ready():
	pass

func _on_area_body_entered(body):
	if body.name == "player":
		global.save_file.checkpoint = id
		Dialogic.start(timeline)
