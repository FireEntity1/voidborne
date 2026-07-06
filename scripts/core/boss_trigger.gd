extends Node2D

@export var start_timeline: DialogicTimeline
@export var boss: Node

var started = false

func _on_trigger_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not started:
		Dialogic.start(start_timeline)
		started = true
		await Dialogic.timeline_ended
		boss.start()
