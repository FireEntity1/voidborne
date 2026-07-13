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

@export var secondary_timeline: DialogicTimeline
@export var secondary_condition: String = ""

func _ready() -> void:
	$timeline_trigger.timeline = timeline
	$timeline_trigger.automatic = automatic
	$timeline_trigger.repeat = repeat
	$sprite.self_modulate = colours.pick_random()
	var s = randf_range(0.92, 1.08)
	$sprite.scale = Vector2(8.0*s, 8.0*s)
	modulate.a = randf_range(0.9, 1.0)
	$sprite.speed_scale = randf_range(0.8,1.2)
