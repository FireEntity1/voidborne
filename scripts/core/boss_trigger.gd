extends Node2D

@export var start_timeline: DialogicTimeline
@export var boss: Node

@export var use_signal = false
@export var emit: String = ""

var started = false

func _ready() -> void:
	if not Dialogic.signal_event.is_connected(_on_dialogic_signal):
		Dialogic.signal_event.connect(_on_dialogic_signal)

func _on_trigger_body_entered(body: Node2D) -> void:
	print(body)
	if body.is_in_group("player") and not started:
		if start_timeline != null:
			Dialogic.start(start_timeline)
			get_parent().get_node("audio").stop()
		else:
			Dialogic.emit_signal("signal_event","start_boss")
		started = true

func _on_dialogic_signal(arg):
	if arg == "start_boss":
		boss.start()
