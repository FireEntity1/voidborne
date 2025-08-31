extends CharacterBody2D

var jumps = 2

var SPEED = 1200.0
const JUMP_VELOCITY = -1600.0

var dashing = false
var can_dash = true

var can_attack = true

@onready var damage = 8

var is_ground = true

var voidwell = 8

var slashing = false

var slamming = false

var flip = true # right false, left true

var cam_zoom = 0.8

var can_heal = true

var can_take_damage = true

var health = global.save_file.hearts
var heart_scene = preload("res://Components/heart.tscn")
var heart_damaged_scene = preload("res://Components/heart_damaged.tscn")

var direction = 1

var dead = false

var last_dir = 1

func _ready():
	$land_particles.emitting = false
	add_voidwell(1)
	update_hearts()
	Dialogic.signal_event.connect(_on_dialogic_signal)

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
	
	if is_on_floor() and not is_ground and not slamming:
		$land.play()
	is_ground = is_on_floor()
	
	if self.velocity.y < 0:
		slamming = false
	
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
		$Swish.play()
		var bodies = $slash/slash.get_overlapping_bodies()
		var areas = $slash/slash.get_overlapping_areas()
		var enemies = []
		for body in bodies:
			if body is CharacterBody2D:
				body.health -= damage
				body.hit()
		for area in areas:
			if area.name == "boss":
				area.hit()
				area.health -= damage
		await get_tree().create_timer(0.33).timeout
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
			if last_dir < 0:
				anim.get_node("dash_sprite").flip_h = true
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
		$slam_land.play()
		await get_tree().create_timer(0.2).timeout
		$land_particles.emitting = false
		
	
	$camera.zoom = $camera.zoom.move_toward(Vector2(cam_zoom,cam_zoom), delta)

	
	if Input.is_action_just_pressed("heal") and voidwell > 4 and health < global.save_file.hearts and can_heal:
		can_heal = false
		SPEED = 400
		add_voidwell(-4)
		await get_tree().create_timer(1).timeout
		SPEED = 1200
		can_heal = true
		health += 1
		update_hearts()
	
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
	if can_take_damage and not dead:
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
			player_death()

func add_voidwell(value: int):
	voidwell = clamp(voidwell + value, 0, 12)
	$ui/voidwell.value = voidwell

func _on_dialogic_signal(text):
	if text == "cam-zoom-in":
		$camera.make_current()
		cam_zoom = 1.5
	if text == "cam-zoom-out":
		$camera.make_current()
		cam_zoom = 0.6
	if text == "cam-zoom-normal":
		$camera.make_current()
		cam_zoom = 0.8
	if text == "reset-health":
		health = global.save_file.hearts

func player_death():
	dead = true
	print("player died")
	Dialogic.end_timeline()
	Dialogic.start(preload("res://Dialogic/death.dtl"))
