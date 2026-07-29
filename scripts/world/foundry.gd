extends Node2D

func _ready() -> void:
	if not Global.state.visited.has("foundry"):
		Dialogic.emit_signal("signal_event","title_The Foundry")
