extends Area2D

@export var id = ""

func _on_body_entered(body: Node2D) -> void:
	Global.set_voidwell(id)
