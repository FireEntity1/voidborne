extends Node2D

var direction: Vector2

var velocity = 1400
var homing = true

var alpha_up = false

func _ready():
	direction = (global.player_pos - global_position).normalized()
	await get_tree().create_timer(0.4).timeout
	homing = false
	await get_tree().create_timer(5).timeout
	queue_free()
	

func _process(delta):
	if homing:
		direction = (global.player_pos - global_position).normalized()
		rotation = direction.angle() - deg_to_rad(175)
	self.position += direction*velocity*delta
	
	if alpha_up:
		$sprite.modulate.a -= delta*25
	else:
		$sprite.modulate.a += delta*25

func _on_area_body_entered(body):
	if body.name == "player":
		body.hit(global_position)
		self.queue_free()

func _on_alpha_timer_timeout():
	if alpha_up:
		alpha_up = false
	else:
		alpha_up = true
