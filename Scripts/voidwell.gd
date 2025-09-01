extends Node2D

@export var id: String
@export var timeline: DialogicTimeline

func _ready():
	pass

func _on_area_body_entered(body):
	if body.name == "player":
		global.set_checkpoint(id)
		global.save()
		Dialogic.start(timeline)
		await get_tree().create_timer(1.4).timeout
		if Dialogic.current_timeline != null:
			Dialogic.end_timeline()
