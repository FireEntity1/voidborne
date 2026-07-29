extends Node2D

func _ready() -> void:
	await get_tree().create_timer(0.5).timeout
	if not Global.state.visited.has("outlands_underground"):
		Dialogic.emit_signal("signal_event","title_The Outlands")
