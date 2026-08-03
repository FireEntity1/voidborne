extends CharacterBody2D

const ATTACK = preload("res://components/boss/lethos_attack.tscn")

var attack_strength = 1
var health = 80.0

@export var end_timeline: DialogicTimeline

var running = false
var finished = false

var ground = Vector2(24470,-8450)

var move_range = 2000
var move_target = [0,0]
var dir = true

var final_pos: Vector2

@onready var start_position = global_position - Vector2(0,200)

var color = 1.0

func _ready() -> void:
	var tween = create_tween().set_loops()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)
	
	tween.tween_property(self,"position:y",start_position.y - 40.0,1.2)
	tween.tween_property(self,"position:y",start_position.y + 40.0,1.2)
	
	move_target = [position.x-move_range,position.x+move_range]
	Dialogic.connect("signal_event",_signal_event)
	$collision.disabled = true
	$collision2.disabled = true

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
	Global.mod_can_move(false)
	print("DIE")
	$attack.stop()
	running = false
	final_pos = position
	finished = true
	print(final_pos, finished)
	$collision.disabled = true
	$collision2.disabled = true
	$death_particle.emitting = true
	$riser.play()
	get_parent().get_node("lethos_music").stop()
	await $riser.finished
	Global.fadescreen(true,true,true)
	$sprite.hide()
	finished = false
	$end_particle.restart()
	$end_particle.emitting = true
	$death_particle.emitting = false
	Dialogic.emit_signal("signal_event","lethos_end")
	await get_tree().create_timer(0.4).timeout
	$die.play()
	Global.fadescreen(false,true,true)
	Global.mod_can_move(true)
	#Dialogic.start(end_timeline)

func _signal_event(arg):
	if arg == "lethos_start":
		running = true
		$start.stop()
		$collision.disabled = false
		$collision2.disabled = false
		Dialogic.emit_signal("signal_event","title_Lethos")
		$attack.start()
	if arg == "lethos_cam":
		$start.play()
		$bosscam.make_current()

func _on_attack_timeout() -> void:
	$attack_pre.restart()
	var spawn_position := global_position - Vector2(900, 200)
	var aim_direction := spawn_position.direction_to(player().global_position)
	$attack_pre.process_material.direction = Vector3(
		aim_direction.x,
		aim_direction.y,
		0.0
 	)
	$attack_pre.emitting = true
	await get_tree().create_timer(0.5).timeout
	var new = ATTACK.instantiate()
	new.global_position = global_position - Vector2(900,200)
	new.goal = player().global_position
	new.ground = ground.y
	get_parent().add_child(new)
	print("spawning",new.global_position)

func player() -> CharacterBody2D:
	return get_parent().get_node("player_hold").get_node("player")
