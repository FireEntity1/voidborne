extends Node2D

func _ready() -> void:
	Dialogic.connect("signal_event",_on_signal)

func _on_signal(arg):
	if arg == "open_smog_ridge":
		$door_over.play()
		$door.get_node("collision").disabled = true
