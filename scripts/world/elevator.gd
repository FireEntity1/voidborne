extends Node2D

@export var length: int = 1
@export var close_speed: float = 800.0
@export var segment_height: float = 128.0
@export var visible_segments: int = 2

@export var smoothing_distance: float = 96.0
@export var minimum_speed: float = 40.0

@export var starts_at_top: bool = false

@export var chain_spacing: float = 32.0
@export var chain_hide_offset: float = 512.0

@onready var chain: Sprite2D = $base/chain

var chain_segments: Array[Sprite2D] = []

var player: CharacterBody2D

var moving: bool = false
var is_at_top: bool = false

var departure_y: float
var target_y: float
var top_y: float
var bottom_y: float

var initial_terminal_override: Variant = null

func _ready() -> void:
	var movement_segments: int = max(length - visible_segments, 0)
	var movement_distance: float = movement_segments * segment_height

	#is_at_top = starts_at_top
#
	#if starts_at_top:
		#top_y = global_position.y
		#bottom_y = global_position.y + movement_distance
	#else:
		#bottom_y = global_position.y
		#top_y = global_position.y - movement_distance
	
	bottom_y = global_position.y
	top_y = bottom_y - movement_distance
	
	var initial_at_top = starts_at_top
	if initial_terminal_override != null:
		initial_at_top = initial_terminal_override
	
	if initial_at_top:
		global_position.y = top_y
	
	
	is_at_top = initial_at_top
	

	departure_y = global_position.y
	
	
	target_y = global_position.y

	chain_segments.append(chain)

	for i in range(1, length):
		var new_chain = chain.duplicate() as Sprite2D

		if starts_at_top:
			new_chain.position.y += chain_spacing * i
		else:
			new_chain.position.y -= chain_spacing * i

		$base.add_child(new_chain)
		chain_segments.append(new_chain)

	_update_chain_visibility()


func _physics_process(delta: float) -> void:
	_update_chain_visibility()

	if not moving:
		return

	if (
		$base/trigger.get_overlapping_bodies().has(player)
		and player.is_on_floor()
	):
		player.velocity.y = 5000

	var distance_from_start = abs(global_position.y - departure_y)
	var distance_to_end = abs(global_position.y - target_y)

	var start_factor = clamp(
		distance_from_start / smoothing_distance,
		0.0,
		1.0
	)

	var end_factor = clamp(
		distance_to_end / smoothing_distance,
		0.0,
		1.0
	)

	var speed_factor = min(start_factor, end_factor)
	speed_factor = smoothstep(0.0, 1.0, speed_factor)

	var current_speed = lerp(
		minimum_speed,
		close_speed,
		speed_factor
	)

	global_position.y = move_toward(
		global_position.y,
		target_y,
		current_speed * delta
	)

	_update_chain_visibility()

	if is_equal_approx(global_position.y, target_y):
		global_position.y = target_y
		moving = false
		is_at_top = is_equal_approx(global_position.y, top_y)

		$base/side_l.set_deferred("disabled", true)
		$base/side_r.set_deferred("disabled", true)

		Global.mod_can_move(true)
		$base/base.play_backwards("default")


func _update_chain_visibility() -> void:
	var hide_y = top_y - chain_hide_offset

	for segment in chain_segments:
		segment.visible = segment.global_position.y >= hide_y


func _on_trigger_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	player = body

	if moving:
		return

	begin_trip(body)

	#await get_tree().create_timer(0.02).timeout
	#Global.mod_can_move(false)

func set_initial_terminal(at_top: bool) -> void:
	initial_terminal_override = at_top

func get_boarding_position() -> Vector2:
	return $boarding_position.global_position

func begin_trip(body: CharacterBody2D) -> bool:
	if moving:
		return false
	player = body
	departure_y = global_position.y
	target_y = bottom_y if is_at_top else top_y
	moving = true
	$base/side_l.set_deferred("disabled",false)
	$base/side_r.set_deferred("disabled",false)
	$base/base.play("default")
	Global.mod_can_move(false)
	return true
