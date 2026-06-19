extends CharacterBody2D

const player = true

const SPEED = 900.0
const JUMP_VELOCITY = 1300.0

var jumped = JUMP_VELOCITY

var can_attack = true

var attack_cooldown = 0.2
var was_hit = false
var hit_location = Vector2.ZERO

var invincible = false

var health = 10

@onready var slash = $sprite/slash

signal player_hit

func _ready() -> void:
	Dialogic.signal_event.connect(_dialogic_signal)

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = -jumped
		jumped -= delta*20.0
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y = 5
		jumped = JUMP_VELOCITY
	
	var direction := Input.get_axis("left", "right")
	if direction and not was_hit:
		velocity.x = move_toward(velocity.x, direction * SPEED,delta*30000)
		if is_on_floor():
			$sprite.play("move")
	elif not was_hit:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if Input.is_action_just_pressed("attack") and can_attack:
		attack()
	
	if not slash.is_playing():
		if Input.is_action_pressed("left"):
			$sprite.scale.x = 1
		elif Input.is_action_pressed("right"):
			$sprite.scale.x = -1
	
	if not is_on_floor():
		if velocity.y < 100.0:
			if direction:
				$sprite.play("jump_move")
			else:
				$sprite.play("jump")
		elif velocity.y > 100.0:
			if direction:
				$sprite.play("fall_move")
			else:
				$sprite.play("fall")
	elif not direction:
		$sprite.play("default")
	
	move_and_slide()

func attack() -> void:
	can_attack = false
	slash.stop()
	slash.visible = false
	slash.set_frame_and_progress(0,0.0)
	
	var pogo = false
	
	if Input.is_action_pressed("up"):
		slash.rotation_degrees = 120
	elif Input.is_action_pressed("down") and not is_on_floor():
		pogo = true
		slash.rotation_degrees = -60
	else:
		slash.rotation_degrees = 30
	slash.force_update_transform()
	$sprite/slash/area.force_update_transform()
	
	await get_tree().physics_frame
	
	slash.visible = true
	slash.play()
	
	await get_tree().physics_frame
	
	var enemies: Array = $sprite/slash/area.get_overlapping_bodies()
	for enemy in enemies:
		if enemy.is_in_group("enemy"):
			enemy.damage(2.0)
			if pogo:
				pogo = false
				velocity.y = -JUMP_VELOCITY
	var areas: Array = $sprite/slash/area.get_overlapping_areas()
	for area in areas:
		if area.is_in_group("hittable"):
			area.hit()
			
	
	await slash.animation_finished
	slash.visible = false
	
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func _on_hit_body_entered(body: Node2D) -> void:
	if invincible:
		return
	if body.is_in_group("enemy"):
		hit_location = body.global_position
		invincible = true
		player_hit.emit()
		health -= int(body.attack_strength)
		
		print(health)
		
		$sprite.modulate = Color(0.8,0.8,0.8)
		await get_tree().create_timer(0.1).timeout
		$sprite.modulate = Color(1.4,1.4,1.4)
		
		if health <= 0:
			get_tree().reload_current_scene()
			return
		
		var knockback_direction = sign(global_position.x - body.global_position.x)
		if knockback_direction == 0:
			knockback_direction = -$sprite.scale.x

		velocity.x = knockback_direction * 1000
		velocity.y = -400

		was_hit = true

		await get_tree().create_timer(0.2).timeout
		was_hit = false

		await get_tree().create_timer(0.8).timeout
		invincible = false

func _dialogic_signal(argument: String):
	pass
