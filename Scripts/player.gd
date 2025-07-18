extends CharacterBody2D

var jumps = 2

const SPEED = 1200.0
const JUMP_VELOCITY = -1600.0

var dashing = false
var can_dash = true

var can_attack = true

var damage = 5

var slashing = false

var slamming = false

var flip = true # right false, left true

var can_take_damage = true

var health = 5
var heart_scene = preload("res://Components/heart.tscn")

var direction = 1

var last_dir = 1

func _ready():
	$land_particles.emitting = false
	update_hearts()

func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		jumps = 2

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jumps = 1
	
	if Input.is_action_just_pressed("jump") and not is_on_floor() and jumps >= 1 and not slamming:
		velocity.y = JUMP_VELOCITY
		jumps = 0
		$land_particles.emitting = true
		await get_tree().create_timer(0.2).timeout
		$land_particles.emitting = false
	
	if Input.is_action_just_pressed("slam") and not is_on_floor():
		self.velocity.y = 8000
		slamming = true
	
	direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = move_toward(velocity.x, direction * SPEED, 8000 * delta)
		if can_dash:
			$sprite.play("walk")
	else:
		velocity.x = move_toward(velocity.x, 0, 8000 * delta)
		if can_dash:
			$sprite.play("idle")
	
	if not is_on_floor() and can_dash:
		if self.velocity.y > 500:
			$sprite.play("falling")
		elif self.velocity.y < -500:
			$sprite.play("jumping")
		else:
			$sprite.play("float")
	
	if Input.is_action_just_pressed("left"):
		flip = true
	if Input.is_action_just_pressed("right"):
		flip = false
	
	$sprite.flip_h = flip
	
	if direction != 0:
		last_dir = direction

	if last_dir == 1 and can_attack:
			$slash.flip_h = false
			$slash.position.x = 90
			$slash.rotation_degrees = 20
	elif last_dir == -1 and can_attack:
		$slash.flip_h = true
		$slash.position.x = -90
		$slash.rotation_degrees = -20
	
	if Input.is_action_just_pressed("attack") and can_attack:
		slashing = true
		can_attack = false
		$slash.play()
		var areas = $slash/slash.get_overlapping_bodies()
		var enemies = []
		for area in areas:
			if area is RigidBody2D:
				area.health -= damage
				area.hit()
				print("hit")
		await get_tree().create_timer(0.2).timeout
		can_attack = true

	if Input.is_action_just_pressed("dash"):
		if can_dash:
			dashing = true
			$sprite.play("dash")
			await get_tree().create_timer(0.08).timeout
			dashing = false
			can_dash = false
			$dash.start()
	if dashing:
		$sprite.play("dash")
		self.velocity.x = last_dir * 3000
		
	if slamming and not is_on_floor():
		$sprite.play("slamming")
	elif slamming and is_on_floor():
		slamming = false
		$land_particles.emitting = true
		await get_tree().create_timer(0.2).timeout
		$land_particles.emitting = false
	
	move_and_slide()

func update_hearts():
	if health > 0:
		for node in $ui.get_children():
			$ui.remove_child(node)
			node.queue_free()
		for i in range(health):
			var heart = heart_scene.instantiate()
			heart.position.x = i*150
			$ui.add_child(heart)

func _on_dash_timeout():
	can_dash = true

func hit(enemy_pos):
	if can_take_damage:
		var dir = position.x - enemy_pos.x
		if dir > 0:
			velocity.x = 3000
		else:
			velocity.x = -3000
		$hit_particles.emitting = true
		health -= 1
		
		add_child(preload("res://Components/damage_flash.tscn").instantiate())
		update_hearts()
		can_take_damage = false
		await get_tree().create_timer(0.5).timeout
		can_take_damage = true
