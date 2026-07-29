extends Area2D

var damaged = false

func _ready() -> void:
	await get_tree().create_timer(2.0).timeout
	queue_free()

func _process(delta: float) -> void:
	if $sprite.frame == 5 and not damaged:
		for child in get_overlapping_bodies():
			if child.is_in_group("enemy"):
				child.damage(1)
