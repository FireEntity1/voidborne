extends CharacterBody2D

var mini_prism = preload("res://components/enemies/forsaken_prism.tscn")

var health = 30.0

var running = false
@onready var attack = $attack

var og_pos: Vector2

var attack_strength = 1

func _ready() -> void:
	attack.connect("timeout",_on_attack_timeout)
	og_pos = global_position

func _physics_process(delta: float) -> void:
	pass

func start():
	running = true
	attack.start()
	Dialogic.emit_signal("signal_event","cam_zoom_0.7")
	Dialogic.emit_signal("signal_event","door_forsaken_boss_close")
	print("started")

func _on_attack_timeout():
	spawn_enemy()

func spawn_enemy():
	var enemy = mini_prism.instantiate()
	enemy.position.x = randi_range(-2000,2000)
	enemy.global_position += Vector2(13572,2048)
	enemy.scale = Vector2(4.0,4.0)
	print("spawned")
	get_parent().get_node("enemy_hold").add_child(enemy)
	await get_tree().create_timer(1.0).timeout
	if is_instance_valid(enemy):
		enemy.falling = true

func damage(amt):
	print("HIT")
	$hit_particle.emitting = false
	$hit_particle.restart()
	health -= amt
	$sprite.modulate.r = 1.8
	$hit_particle.emitting = true
	await get_tree().create_timer(0.1).timeout
	$sprite.modulate.r = 1.0
	global_position.x = og_pos.x + randi_range(-1000,1000)
	if health <= 0:
		die()

func die():
	$death_particles.emitting = true
	$sprite.hide()
	$col.disabled = true
	running = false
	Dialogic.emit_signal("signal_event","door_forsaken_boss_open")
