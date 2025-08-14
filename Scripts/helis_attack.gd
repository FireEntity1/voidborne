extends Node2D

var direction: Vector2

var homing = true

func _ready():
	$sprite.speed_scale = 1.0
	direction = (global.player_pos - global_position).normalized()
	rotation = direction.angle() - deg_to_rad(175)
	await get_tree().create_timer(0.2).timeout
	homing = false
	await get_tree().create_timer(5).timeout
	print("spawned attack")
	queue_free()

func _process(delta):
	if homing:
		direction = (global.player_pos - global_position).normalized()
	rotation = direction.angle() - deg_to_rad(175)
	
	if $sprite.frame <= 20:
		$sprite.sprite_frames.set_animation_speed("default", 20)
	else:
		$sprite.sprite_frames.set_animation_speed("default", 40)
	
	if $sprite.frame == 15:
		var check = is_player()
		if check[0]:
			check[1].hit(global_position)

func is_player():
	for body in $area.get_overlapping_bodies():
		if body.name == "player":
			return [true, body]
	return [false,null]
