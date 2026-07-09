extends CharacterBody2D

var attack_strength = 1
var health = 100.0

var running = false

var move_range = 2000
var move_target = [0,0]
var dir = true

func _ready() -> void:
	move_target = [position.x-move_range,position.x+move_range]
	Dialogic.connect("signal_event",_signal_event)

func _process(delta: float) -> void:
	if not running:
		return
	var target_x = move_target[0] if dir else move_target[1]
	position.x = move_toward(position.x, target_x, delta * 500)

	if abs(position.x - target_x) < 1.0:
		dir = !dir

func start(actual = false):
	show()

func damage(amt):
	print("HIT")
	var particles = $hit_particle.duplicate()
	add_child(particles)
	particles.emitting = false
	particles.restart()
	health -= amt
	$sprite.modulate = Color(1.0,0.5,0.5)
	particles.emitting = true
	await get_tree().create_timer(0.05).timeout
	$sprite.modulate = Color(1.0,1.0,1.0)
	if health <= 0:
		die()
	await get_tree().create_timer(5.0).timeout
	particles.queue_free()

func die():
	pass

func _signal_event(arg):
	if arg == "lethos_start":
		running = true
	if arg == "lethos_cam":
		$bosscam.make_current()
