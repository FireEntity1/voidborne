extends CharacterBody2D

var attack_strength = 1

var running = false

var move_range = 2000

var move_target = [0,0]

var dir = true

func _ready() -> void:
	move_target = [position.x-move_range,position.x+move_range]

func _process(delta: float) -> void:
	if not running:
		return
	var target_x = move_target[0] if dir else move_target[1]
	position.x = move_toward(position.x, target_x, delta * 500)

	if abs(position.x - target_x) < 1.0:
		dir = !dir

func start():
	show()
	running = true
