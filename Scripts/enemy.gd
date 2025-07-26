extends CharacterBody2D

var player: CharacterBody2D

var chasing = false

var enemy = true

@export var reverse_flip = false
@export var hover = false

# hover stuff
var is_up = true
@export var hover_max_dist: int
var dist = 0
var speed = 50

var is_boss = false

var dir = 1

var knocked = false

@export var max_speed = 700.0

@export var health = 15


func _ready():
	print(name)
	if name.begins_with("flicker"):
		hover = true
		hover_max_dist = 24
		speed = 100
		max_speed = 100
	if name.begins_with("purgelet"):
		hover = false
		hover_max_dist = 0
		speed = 0

func _physics_process(delta):
	if is_up:
		$sprite.position.y -= delta*speed
		dist -= delta*speed
		max_speed = 2000
	else:
		$sprite.position.y += delta*speed
		dist += delta*speed
	
	if dist > hover_max_dist:
		is_up = true
	elif dist < -hover_max_dist:
		is_up = false
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if knocked:
		velocity.x = dir*600
	
	if chasing and not knocked:
		if player.global_position.x > global_position.x:
			dir = 1
		else:
			dir = -1
		
		var target_velocity_x = dir * max_speed
		velocity.x = move_toward(velocity.x, target_velocity_x, max_speed * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, max_speed * delta)
	
	if dir == -1:
		if reverse_flip:
			$sprite.flip_h = true
		else:
			$sprite.flip_h = false
	elif dir == 1:
		if reverse_flip:
			$sprite.flip_h = false
		else:
			$sprite.flip_h = true
		
	if not knocked:
		$sprite.play("default")
	else:
		$sprite.play("hit")
		
	if health <= 0:
		$sprite.play("hit")
		if enemy:
			player.add_voidwell(10)
		enemy = false
		await get_tree().create_timer(0.2).timeout
		$sprite.hide()
		queue_free()
	
	move_and_slide()


func _on_detection_body_entered(body):
	print("body entered")
	if body is CharacterBody2D and body.name == "player":
		player = body
		chasing = true

func hit():
	knocked = true
	$hit_particles.emitting = true
	if player.position.x < self.position.x:
		velocity.x += 1300
		dir = 1
	else:
		velocity.x += 13000
		dir = -1
	await get_tree().create_timer(0.3).timeout
	knocked = false

func _on_hit_collision_body_entered(body):
	if body.name == "player":
		body.hit(self.position)
