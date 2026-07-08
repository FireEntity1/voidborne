extends Node2D

@export var start_timeline: DialogicTimeline
@export var boss: Node

var started = false

func _ready() -> void:
	if not Dialogic.signal_event.is_connected(_on_dialogic_signal):
		Dialogic.signal_event.connect(_on_dialogic_signal)

func _on_trigger_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not started:
		Dialogic.start(start_timeline)
		started = true

func _on_dialogic_signal(arg):
	if arg == "start_boss":
		boss.start()
