extends Area2D

@export var id = ""

func _ready() -> void:
	$timeline_trigger.signal_string = "voidwell" + id
	$timeline_trigger.is_voidwell = true

func _on_body_entered(body: Node2D) -> void:
	pass
