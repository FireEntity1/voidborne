extends Area2D

@export var timeline: DialogicTimeline
@export var automatic: bool = false
@export var repeat: bool = false

var is_player_active = false
var completed = false

func _on_body_entered(body: Node2D) -> void:
	if completed:
		return
	if body.is_in_group("player"):
		is_player_active = true
		if automatic:
			Dialogic.start_timeline(timeline)
			completed = true
			monitoring = false
		
