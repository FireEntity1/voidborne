extends Node2D

var mini_prism = preload("res://components/enemies/forsaken_prism.tscn")

var running = false
@onready var attack = $attack

func _ready() -> void:
	attack.connect("timeout",_on_attack_timeout)

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
	enemy.position.x = randi_range(-3000,3000)
