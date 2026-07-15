extends Node2D

@export var length: int = 1
@export var close_speed: float = 400.0
@export var segment_height: float = 128.0
@export var visible_segments: int = 2

@export var smoothing_distance: float = 96.0
@export var minimum_speed: float = 40.0

@export var starts_at_top: bool = false

@onready var chain: Sprite2D = $base/chain

var player: CharacterBody2D

var moving: bool = false
var is_at_top: bool = false

var departure_y: float
var target_y: float
var top_y: float
var bottom_y: float


func _ready() -> void:
	var movement_segments: int = max(length - visible_segments, 0)
	var movement_distance: float = movement_segments * segment_height

	is_at_top = starts_at_top

	if starts_at_top:
		top_y = global_position.y
		bottom_y = global_position.y + movement_distance
	else:
		bottom_y = global_position.y
		top_y = global_position.y - movement_distance

	departure_y = global_position.y
	target_y = global_position.y

	for i in range(1, length):
		var new_chain: Sprite2D = chain.duplicate() as Sprite2D

		if starts_at_top:
			new_chain.position.y += 32 * i
		else:
			new_chain.position.y -= 32 * i

		$base.add_child(new_chain)


func _physics_process(delta: float) -> void:
	if not moving:
		return
	if $base/trigger.get_overlapping_bodies().has(player) and player.is_on_floor():
		player.velocity.y = 5000
	var distance_from_start: float = abs(global_position.y - departure_y)
	var distance_to_end: float = abs(global_position.y - target_y)

	var start_factor: float = clamp(
		distance_from_start / smoothing_distance,
		0.0,
		1.0
	)

	var end_factor: float = clamp(
		distance_to_end / smoothing_distance,
		0.0,
		1.0
	)

	var speed_factor: float = min(start_factor, end_factor)
	speed_factor = smoothstep(0.0, 1.0, speed_factor)

	var current_speed: float = lerp(
		minimum_speed,
		close_speed,
		speed_factor
	)

	global_position.y = move_toward(
		global_position.y,
		target_y,
		current_speed * delta
	)

	if is_equal_approx(global_position.y, target_y):
		global_position.y = target_y
		moving = false
		is_at_top = global_position.y == top_y
		$base/side_l.set_deferred("disabled", true)
		$base/side_r.set_deferred("disabled", true)
		Global.mod_can_move(true)
		$base/base.play_backwards("default")


func _on_trigger_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	player = body
	if moving:
		return

	departure_y = global_position.y

	if is_at_top:
		target_y = bottom_y
	else:
		target_y = top_y

	moving = true

	$base/side_l.set_deferred("disabled", false)
	$base/side_r.set_deferred("disabled", false)
	$base/base.play("default")
	await get_tree().create_timer(0.02).timeout
	Global.mod_can_move(false)
