extends CharacterBody2D

const player = true

const SPEED = 900.0
const JUMP_VELOCITY = 1300.0
const DASH_VELOCITY = 2500.0

var jumped = JUMP_VELOCITY
var previous_direction = 1
var can_attack = true
var can_dash = true
var is_dashing = false

var dash_cooldown = 0.4
var attack_cooldown = 0.2
var was_hit = false
var hit_location = Vector2.ZERO

var hit_stun_time = 0.18
var invincible_time = 0.8

var knockback_x = 1200.0
var knockback_y = -650.0
var knockback_friction = 4500.0

var invincible = false

@export var max_health := 10
var health := 10
signal health_changed(current_health: int, max_health: int)

@onready var slash = $sprite/slash

signal player_hit

func _ready() -> void:
	Dialogic.signal_event.connect(_dialogic_signal)
	Global.player = self
	

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and Global.can_move:
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_pressed("jump") and is_on_floor() and Global.can_move:
		velocity.y = -jumped
		jumped -= delta*20.0
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y = 5
		jumped = JUMP_VELOCITY
	
	var direction := Input.get_axis("left", "right")
		
	if was_hit:
		velocity.x = move_toward(velocity.x, 0, knockback_friction * delta)
	elif direction and Global.can_move:
		previous_direction = direction
		velocity.x = move_toward(velocity.x, direction * SPEED, delta * 30000)
		if is_on_floor():
			$sprite.play("move")
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
	
	if Input.is_action_just_pressed("attack") and can_attack and Global.can_move:
		attack()
	
	if not slash.is_playing():
		if Input.is_action_pressed("left") and Global.can_move:
			$sprite.scale.x = 1
		elif Input.is_action_pressed("right") and Global.can_move:
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
	
	if Input.is_action_just_pressed("dash") and Global.can_move:
		is_dashing = true
		can_dash = false
		await get_tree().create_timer(0.1).timeout
		is_dashing = false
		await get_tree().create_timer(dash_cooldown).timeout
	if is_dashing:
		velocity.x = previous_direction*DASH_VELOCITY
	
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
		was_hit = true
		Global.can_move = false
		
		player_hit.emit()
		take_damage(int(body.attack_strength))
		
		print(health)
		
		var knockback_direction = sign(global_position.x - body.global_position.x)
		if knockback_direction == 0:
			knockback_direction = -$sprite.scale.x
		
		velocity.x = knockback_direction * knockback_x
		velocity.y = knockback_y
		
		flash_hit()
		
		if health <= 0:
			get_tree().reload_current_scene()
			return
		
		await get_tree().create_timer(hit_stun_time).timeout
		Global.can_move = true
		was_hit = false
		
		await get_tree().create_timer(invincible_time - hit_stun_time).timeout
		invincible = false

func flash_hit() -> void:
	$sprite.modulate = Color(4.0,2.4,2.4)
	await get_tree().create_timer(0.02).timeout
	$sprite.modulate = Color(1.4,1.4,1.4)
	await get_tree().create_timer(0.02).timeout
	$sprite.modulate = Color(4.0,2.4,2.4)
	await get_tree().create_timer(0.02).timeout
	$sprite.modulate = Color(1.4,1.4,1.4)

func _dialogic_signal(argument: String):
	print(argument)
 
func set_health(value: int) -> void:
	var old_health = health
	health = clampi(value, 0, max_health)
	if health != old_health:
		health_changed.emit(health, max_health)

func take_damage(amount: int) -> void:
	set_health(health - amount)
