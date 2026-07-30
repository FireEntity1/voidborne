extends Area2D

@export var id = ""

func _ready() -> void:
	$timeline_trigger.signal_string = "voidwell" + id

func _on_body_entered(body: Node2D) -> void:
	Global.set_voidwell(id)
