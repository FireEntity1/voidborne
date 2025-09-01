extends Area2D

@export var timeline: DialogicTimeline

var timeline_name: String

func _on_body_entered(body):
	timeline_name = timeline.resource_path.get_file().split(".")[0]
	print(timeline_name)
	print(global.get_finished(timeline_name))
	if global.get_finished(timeline_name):
		self.monitoring = false
		$talkarea.queue_free()
		return
	if body.name == "player":
		Dialogic.start(timeline)
		$talkarea.queue_free()
