extends Node2D

func _ready() -> void:
	if not Global.state.visited.has("voidnexus"):
		Dialogic.emit_signal("signal_event","title_Void Nexus")
