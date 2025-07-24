extends Area2D

@export var timeline: DialogicTimeline

var timeline_name

func _on_body_entered(body):
	timeline_name = timeline.resource_path.get_file().split(".")[0]
	print(timeline_name)
	if global.get_finished(name):
		queue_free()
		return
	if body.name == "player":
		Dialogic.start(timeline)
		$collision.queue_free()
