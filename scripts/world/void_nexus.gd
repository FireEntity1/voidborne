extends Node2D

@export var tutorial: DialogicTimeline

func _ready() -> void:
	if not Global.state.visited.has("voidnexus"):
		Dialogic.emit_signal("signal_event","title_Void Nexus")
	if Global.state.initial:
		await get_tree().create_timer(2.0).timeout
		Dialogic.start(tutorial)
		Global.state.initial = false
		Global.save()
