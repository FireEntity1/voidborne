extends Node2D

@export var timeline: DialogicTimeline
@export var automatic: bool = false
@export var text: String = ""
@export var repeat: bool = false

func _ready() -> void:
	$timeline_trigger.timeline = timeline
	$timeline_trigger.automatic = automatic
	$timeline_trigger.repeat = repeat
