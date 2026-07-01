extends Node2D

const colours = [
	Color(1.00, 1.00, 1.00),
	Color(0.90, 0.96, 1.00),
	Color(0.97, 0.92, 1.00),
	Color(1.00, 0.93, 0.95),
	Color(0.92, 1.00, 0.93),
	Color(1.00, 0.98, 0.88),
	Color(0.85, 0.90, 1.00),
	Color(0.93, 0.93, 0.93),
]

@export var timeline: DialogicTimeline
@export var automatic: bool = false
@export var text: String = ""
@export var repeat: bool = false

func _ready() -> void:
	$timeline_trigger.timeline = timeline
	$timeline_trigger.automatic = automatic
	$timeline_trigger.repeat = repeat
	$sprite.self_modulate = colours.pick_random()
