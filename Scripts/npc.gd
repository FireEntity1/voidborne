extends Area2D

@export var timeline: DialogicTimeline

var timeline_name: String

func _on_body_entered(body):
	timeline_name = timeline.resource_path.get_file().split(".")[0]
	if global.get_finished(timeline_name):
		$talkarea.queue_free()
		return
	if not global.get_finished(timeline_name) and body.name == "player":
		Dialogic.start(timeline)
		$talkarea.queue_free()
