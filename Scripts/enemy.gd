extends CharacterBody2D

var player: CharacterBody2D

var chasing = false

var enemy = true

var is_boss = false

var dir = 1

var knocked = false

@export var max_speed = 1400.0

@export var health = 15
var speed = 200

func _ready():
	pass

func _physics_process(delta):
	if chasing and not knocked:
		if player.global_position.x > global_position.x:
			dir = 1
		else:
			dir = -1
		
		var target_velocity_x = dir * max_speed
		velocity.x = move_toward(velocity.x, target_velocity_x, 3000 * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, 3000 * delta)
	
	if dir == -1:
		$sprite.flip_h = false
	elif dir == 1:
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
		velocity = Vector2(1300,0)
		dir = 1
	else:
		velocity = Vector2(-1300,0)
		dir = -1
	await get_tree().create_timer(0.3).timeout
	knocked = false

func _on_hit_collision_body_entered(body):
	if body.name == "player":
		body.hit(self.position)
