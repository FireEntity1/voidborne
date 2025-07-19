extends Area2D

@export var timeline: DialogicTimeline

func _on_body_entered(body):
	if body.name == "player":
		Dialogic.start(timeline)
		$talkarea.queue_free()
