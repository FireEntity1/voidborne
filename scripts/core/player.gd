extends CharacterBody2D

const player = true

const VOIDBLAST = preload("res://components/core/voidblast.tscn")

const SPEED = 900.0
const JUMP_VELOCITY = 1300.0
const DASH_VELOCITY = 2500.0

var blasting = false

var jumped = JUMP_VELOCITY
var previous_direction = 1
var can_attack = true
var can_dash = true
var is_dashing = false

var dash_cooldown = 0.01
var attack_cooldown = 0.2
var was_hit = false
var hit_location = Vector2.ZERO

var damage = 2
var hit_stun_time = 0.18
var invincible_time = 0.8

var knockback_x = 1200.0
var knockback_y = -650.0
var knockback_friction = 4500.0
var moving = false
var velocity_mod = 0.0

var cam_zoom = 1.0
var prev_zoom = cam_zoom

var invincible = false

const CAST_TAP_DURATION = 0.3
const CAST_FIRST_HEAL_DELAY = 1.0
const CAST_HEAL_INTERVAL = 1.0
var cast_held_time: float
var next_heal_time = CAST_FIRST_HEAL_DELAY
var cast_active = false
var is_focusing = false

@export var max_health := 10
var health := 10
signal health_changed(current_health: int, max_health: int)

@onready var slash = $sprite/slash

signal player_hit

func _ready() -> void:
	Dialogic.signal_event.connect(_dialogic_signal)
	Global.player = self
	

func _physics_process(delta: float) -> void:
	velocity.x = clamp(velocity.x - velocity_mod,-3000,3000)
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
	
	_handle_cast(delta)
		
	#$camera.zoom = Vector2(move_toward(
		#$camera.zoom.x, cam_zoom, delta/3.0), move_toward(
			#$camera.zoom.y, cam_zoom, delta/3.0
		#))
	var z
	if not is_focusing:
		z = lerp($camera.zoom.x,cam_zoom, delta)
	else:
		z = lerp($camera.zoom.x,1.5, delta)
	$camera.zoom = Vector2(z,z)
	
	if was_hit:
		velocity.x = move_toward(velocity.x, 0, knockback_friction * delta)
	elif direction and Global.can_move:
		previous_direction = direction
		velocity.x = move_toward(velocity.x, direction * SPEED, delta * 30000)
		if is_on_floor():
			$sprite.play("move")
			moving = true
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		moving = false
	
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
	
	if Input.is_action_just_pressed("dash") and Global.can_move and Global.state["items"]["dash"]:
		is_dashing = true
		can_dash = false
		await get_tree().create_timer(0.1).timeout
		is_dashing = false
		await get_tree().create_timer(dash_cooldown).timeout
	if is_dashing:
		velocity.x = previous_direction*DASH_VELOCITY
	velocity.x = clamp(velocity_mod + velocity.x,-3000,3000)
	
	if blasting:
		velocity = Vector2(0,0)
	
	move_and_slide()

func _handle_cast(delta: float) -> void:
	if Input.is_action_just_pressed("cast") and Global.can_move and Global.voidmeter >= 3:
		cast_active = true
		cast_held_time = 0.0
		next_heal_time = CAST_FIRST_HEAL_DELAY
		is_focusing = false
		
	if cast_active and Input.is_action_pressed("cast"):
		cast_held_time += delta
		if not is_focusing and cast_held_time >= CAST_TAP_DURATION and is_on_floor() and Global.voidmeter >= 3:
			is_focusing = true
			$heal.emitting = true
			Global.screen_focus_vingette(true)
			Global.mod_can_move(false)
		
		if is_focusing or Global.voidmeter < 3:
			if not is_on_floor():
				_cancel_focus()
			elif health < max_health and cast_held_time >= next_heal_time:
				heal(1)
				Global.voidmeter -= 3
				next_heal_time += CAST_HEAL_INTERVAL
				if Global.voidmeter < 3:
					Input.action_release("cast")
					_cancel_focus()

	if cast_active and Input.is_action_just_released("cast"):
		var was_tap = cast_held_time < CAST_TAP_DURATION and not is_focusing
		_cancel_focus()
		cast_active = false
		cast_held_time = 0.0
		next_heal_time = CAST_FIRST_HEAL_DELAY
		
		if was_tap:
			if not Global.state.items.voidblast:
				return
			voidblast()
			Global.voidmeter -= 3

func _cancel_focus():
	if not is_focusing:
		return
	$heal.emitting = false
	is_focusing = false
	Global.mod_can_move(true)
	Global.screen_focus_vingette(false)

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
	
	var did_hit = false
	
	var enemies: Array = $sprite/slash/area.get_overlapping_bodies()
	for enemy in enemies:
		if enemy.is_in_group("enemy"):
			if enemy.has_method("damage"):
				enemy.damage(damage)
				Global.voidmeter += 1
			if pogo:
				pogo = false
				velocity.y = -JUMP_VELOCITY
	var areas: Array = $sprite/slash/area.get_overlapping_areas()
	for area in areas:
		if area.is_in_group("hittable"):
			area.hit()
	$sprite/slash/hit_particles.emitting = did_hit
	
	await slash.animation_finished
	slash.visible = false
	$sprite/slash/hit_particles.emitting = false
	
	await get_tree().create_timer(attack_cooldown).timeout
	can_attack = true

func _on_hit_body_entered(body: Node2D) -> void:
	if invincible:
		return
	
	if body.is_in_group("enemy"):
		hit_location = body.global_position
		hit(int(body.attack_strength),true,hit_location)
		if body.has_method("attack"):
			body.attack()
		

func hit(damage=1, knock:bool = false, hit_location = Vector2.ZERO) -> void:
	if invincible:
		return
	invincible = true
	was_hit = true
	var knockback_direction = sign(global_position.x - hit_location.x)
	if knockback_direction == 0:
		knockback_direction = -$sprite.scale.x
	Global.can_move = false
		
	player_hit.emit()
		
	print(health)
		
	if health <= 0:
		get_tree().reload_current_scene()
		return
	
	take_damage(damage)
	Global.can_move = true
	velocity.x = knockback_direction * knockback_x
	velocity.y = knockback_y
	flash_hit()
	await get_tree().create_timer(hit_stun_time).timeout
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
	if argument.begins_with("cam_zoom_"):
		cam_zoom = float(argument.split("cam_zoom_")[1])
	elif argument == "player_cam":
		$camera.make_current()
 
func set_health(value: int) -> void:
	var old_health = health
	health = clampi(value, 0, max_health)
	if health != old_health:
		health_changed.emit(health, max_health)

func take_damage(amount: int) -> void:
	set_health(health - amount)

func heal(amount: int) -> void:
	set_health(health + amount)

func voidblast():
	blasting = true
	var blast = VOIDBLAST.instantiate()
	blast.position = Vector2(0,-2)
	blast.scale.x *= previous_direction
	blast.scale.y = 1
	$ambient.add_child(blast)
	await get_tree().create_timer(0.2).timeout
	blasting = false
	
