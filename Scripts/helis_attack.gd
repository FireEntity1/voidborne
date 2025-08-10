extends Node2D

var direction: Vector2

func _ready():
	direction = (global.player_pos - global_position).normalized()
	await get_tree().create_timer(0.2).timeout
	await get_tree().create_timer(5).timeout
	queue_free()
	

func _process(delta):
	direction = (global.player_pos - global_position).normalized()
	rotation = direction.angle() - deg_to_rad(175)
	if $sprite.frame == 15:
		var check = is_player()
		if check[0]:
			check[1].hit()
			

func is_player():
	for body in $area.get_overlapping_bodies():
		if body.name == "player":
			return [true, body]
	return [false,null]
