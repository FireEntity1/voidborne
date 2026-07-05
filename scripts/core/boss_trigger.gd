extends Node2D

@export var start_timeline: DialogicTimeline
@export var boss: Node

func _on_trigger_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		Dialogic.start(start_timeline)
		await Dialogic.timeline_ended
		boss.start()
