extends Area2D

var health = 225

var is_boss = true
var enemy = true

var dist = 0

var finished = false

var progress = 0

var die = false

@export var start_timeline: DialogicTimeline
@export var end_timeline: DialogicTimeline

var attack = preload("res://Components/helis_attack.tscn")

var hover_up = true
var hover_speed = 67

var hover_lim = 100

var move_left = true

var running = false

func _ready():
	Dialogic.signal_event.connect(_on_dialogic_signal)
	$sprite.hide()

func _process(delta):
	running = global.helis_attacking
	if hover_up and running:
		position.y -= delta*hover_speed
	elif running:
		position.y += delta*hover_speed
		
	if move_left and running and not finished:
		self.position.x -= delta*300
		dist -= delta*300
		
	elif running and not finished:
		self.position.x += delta*300
		dist += delta*300
		$hover.wait_time = 2
	
	if dist < -950:
		move_left = false
	elif dist > 950:
		move_left = true
	
	if finished:
		$hover.wait_time = 0.05
		hover_speed = 0
	
	if die and finished:
		$hover.wait_time = 0.01
		progress += delta/8
		$sprite.material.set_shader_parameter("progress", progress)
		if progress > 0.1:
			progress += 0.05
	if not running:
		$hover.wait_time = 0.01

func _on_damage_body_entered(body):
	if body.name == "player" and running:
		body.hit(self.position)

func _on_hover_timeout():
	if hover_up:
		hover_up = false
	else:
		hover_up = true

func _on_start_detection_body_entered(body):
	if body.name == "player":
		global.lethos_attacking = false
		Dialogic.start(start_timeline)
		$start_detection.queue_free()
		await get_tree().create_timer(5).timeout
		$sprite/bosscam.make_current()
		$sprite.show()
func _on_attack_timeout():
	print(running)
	if running and not finished:
		print("condition met")
		hover_lim = 400
		var scene = attack.instantiate()
		$boss_hitbox.add_child(scene)

func hit():
	$particles.emitting = false
	$particles.emitting = true
	print("hit!")
	flash_red()
	
	if health <= 0:
		finished = true
		running = false
		$sprite/bosscam.make_current()
		$Helis.stop()
		Dialogic.start(end_timeline)

func flash_red():
	$sprite.modulate = Color(1,0.5,0.5)
	await get_tree().create_timer(0.1).timeout
	$sprite.modulate = Color(1,1,1)

func _on_dialogic_signal(arg):
	if arg == "start-music":
		print("start music was called")
		$Helis.play()
		$SomethingLooms.stop()
	 
