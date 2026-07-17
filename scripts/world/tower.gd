extends Node2D

func _ready() -> void:
	$to_outlands/collision.disabled = true
	$to_outlands.monitoring = false
	await get_tree().create_timer(4.0)
	$to_outlands/collision.disabled = false
	$to_outlands.monitoring = true
