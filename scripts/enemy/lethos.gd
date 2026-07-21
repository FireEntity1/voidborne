extends CharacterBody2D

const ATTACK = preload("res://components/boss/lethos_attack.tscn")

var attack_strength = 1
var health = 80.0

@export var end_timeline: DialogicTimeline

var running = false
var finished = false

var move_range = 2000
var move_target = [0,0]
var dir = true

var final_pos: Vector2

var color = 1.0

func _ready() -> void:
	move_target = [position.x-move_range,position.x+move_range]
	Dialogic.connect("signal_event",_signal_event)

func _process(delta: float) -> void:
	if finished:
		position = Vector2(final_pos.x + randf_range(-5.0,5.0),final_pos.y + randf_range(-5.0,5.0))
		print("FINISHED, SHAKING")
	
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
	var particles: GPUParticles2D = $hit_particle.duplicate()
	add_child(particles)
	particles.emitting = false
	particles.restart()
	health -= amt
	$sprite.modulate = Color(1.0,0.5,0.5)
	particles.emitting = true
	await get_tree().create_timer(0.05).timeout
	color = 0.8 + float(health/80.0) * 0.2
	$sprite.modulate = Color(color,color,color)
	if health <= 0:
		die()
		particles.queue_free()
	await get_tree().create_timer(5.0).timeout
	if is_instance_valid(particles):
		particles.queue_free()

func die():
	print("DIE")
	running = false
	final_pos = position
	finished = true
	print(final_pos, finished)
	$death_particle.emitting = true
	await get_tree().create_timer(4.0).timeout
	$sprite.hide()
	finished = false
	$end_particle.restart()
	$end_particle.emitting = true
	$death_particle.emitting = false
	Dialogic.emit_signal("signal_event","lethos_end")
	#Dialogic.start(end_timeline)

func _signal_event(arg):
	if arg == "lethos_start":
		running = true
		$attack.start()
	if arg == "lethos_cam":
		$bosscam.make_current()

func _on_attack_timeout() -> void:
	var new = ATTACK.instantiate()
	new.global_position = global_position - Vector2(900,200)
	new.goal = player().global_position
	get_parent().add_child(new)
	print("spawning",new.global_position)

func player() -> CharacterBody2D:
	return get_parent().get_node("player_hold").get_node("player")
