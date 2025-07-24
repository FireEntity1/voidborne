extends CharacterBody2D

var jumps = 2

const SPEED = 1200.0
const JUMP_VELOCITY = -1600.0

var dashing = false
var can_dash = true

var can_attack = true

var damage = 50

var voidwell = 10

var slashing = false

var slamming = false

var flip = true # right false, left true

var can_take_damage = true

var health = 5
var heart_scene = preload("res://Components/heart.tscn")
var heart_damaged_scene = preload("res://Components/heart_damaged.tscn")

var direction = 1

var last_dir = 1

func _ready():
	$land_particles.emitting = false
	add_voidwell(10)
	update_hearts()

func _physics_process(delta):
	global.player_pos = position
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		jumps = 2

	if Input.is_action_just_pressed("jump") and is_on_floor() and global.can_move:
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
	if direction and global.can_move:
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
	
	if Input.is_action_pressed("up") and can_attack:
		$slash.flip_h = false
		$slash.rotation_degrees = 320
		$slash.position.y = -40
		$slash.position.x = 0
	
	elif last_dir == 1 and can_attack:
		$slash.flip_h = false
		$slash.position.x = 90
		$slash.position.y = 30
		$slash.rotation_degrees = 20
	elif last_dir == -1 and can_attack:
		$slash.flip_h = true
		$slash.position.x = -90
		$slash.position.y = 30
		$slash.rotation_degrees = -20
	
	if Input.is_action_just_pressed("attack") and can_attack and global.can_move:
		slashing = true
		can_attack = false
		$slash.play()
		var bodies = $slash/slash.get_overlapping_bodies()
		var areas = $slash/slash.get_overlapping_areas()
		var enemies = []
		for body in bodies:
			print(body.name)
			if body is RigidBody2D:
				body.health -= damage
				body.hit()
				print("hit")
		for area in areas:
			if area.name == "boss":
				area.hit()
				print("hit")
				area.health -= damage
		await get_tree().create_timer(0.2).timeout
		can_attack = true
	
	if Input.is_action_just_pressed("dash") and global.can_move:
		if can_dash:
			dashing = true
			$sprite.play("dash")
			await get_tree().create_timer(0.08).timeout
			dashing = false
			can_dash = false
			$dash.start()
			var anim = preload("res://Components/dash_anim.tscn").instantiate()
			anim.global_position = global_position
			get_tree().current_scene.add_child(anim)
			await get_tree().create_timer(0.6).timeout
			anim.queue_free()
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
	var i = 0
	var extras = global.save_file.hearts - health
	if health > 0:
		for node in $ui_health.get_children():
			if node is not ProgressBar:
				$ui_health.remove_child(node)
				node.queue_free()
		for each_heart in range(health):
			var heart = heart_scene.instantiate()
			heart.position.x = i*150
			i += 1
			$ui_health.add_child(heart)
		for extra_heart in range(extras):
			var heart = heart_damaged_scene.instantiate()
			heart.position.x = i*150
			i += 1
			$ui_health.add_child(heart)

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
		if health <= 0:
			respawn()

func add_voidwell(value: int):
	if not voidwell >= 100:
		voidwell += value
		$ui/voidwell.value = voidwell

func respawn():
	var coords = global.get_spawn_coords()
	self.position = coords
	health = global.save_file.hearts
