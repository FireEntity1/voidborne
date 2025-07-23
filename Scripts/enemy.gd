extends RigidBody2D

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
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC

func _physics_process(delta):
	if chasing and not knocked:
		if player.position.x > self.position.x:
			dir = 1
		else:
			dir = -1
		var target_velocity = Vector2(max_speed * dir, linear_velocity.y)
		var force = (target_velocity - linear_velocity) * mass * 5.0
		apply_central_force(Vector2(force.x, 0))
	
	if dir == -1:
		$sprite.flip_h = false
	elif dir == 1:
		$sprite.flip_h = true
	
	if not knocked:
		$sprite.play("default")
	elif knocked:
		$sprite.play("hit")
	
	if health <= 0:
		$sprite.play("hit")
		if enemy:
			player.add_voidwell(10)
		enemy = false
		await get_tree().create_timer(0.2).timeout
		$sprite.hide()
		self.queue_free()
	
func _on_detection_body_entered(body):
	print("body entered")
	if body is CharacterBody2D and body.name == "player":
		player = body
		chasing = true

func hit():
	knocked = true
	$hit_particles.emitting = true
	if player.position.x < self.position.x:
		linear_velocity = Vector2(1300,0)
		dir = 1
	else:
		linear_velocity = Vector2(-1300,0)
		dir = -1
	await get_tree().create_timer(0.3).timeout
	knocked = false

func _on_hit_collision_body_entered(body):
	if body.name == "player":
		body.hit(self.position)
