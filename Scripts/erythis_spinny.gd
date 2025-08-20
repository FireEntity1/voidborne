extends Node2D

var is_rotating = true

var is_alpha = true

func _ready():
	$sprite.modulate.a = 0
	print("SPAWNED AT " + str(position))

func _process(delta):
	if is_rotating:
		rotation_degrees += delta*40
	if is_alpha:
		$sprite.modulate.a += delta*10
	if $sprite.modulate.a >= 1:
		is_alpha = false

func _on_spin_timeout():
	is_rotating = false
	$sprite.play("default")
	await get_tree().create_timer(1).timeout
	queue_free()
