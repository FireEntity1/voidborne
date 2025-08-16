extends Area2D

var health = 200

var is_boss = true
var enemy = true

var dist = 0

var finished = false

var progress = 0

var die = false

@export var start_timeline: DialogicTimeline
@export var end_timeline: DialogicTimeline

var attack = preload("res://Components/lethos_attack.tscn")

var hover_up = true
var hover_speed = 67

var hover_lim = 100

var move_left = true

var running = false

func _ready():
	Dialogic.signal_event.connect(_on_dialogic_signal)

func _process(delta):
	running = global.lethos_attacking
	if hover_up:
		position.y -= delta*hover_speed
	else:
		position.y += delta*hover_speed
		
	if move_left and running and not finished:
		self.position.x -= delta*300
		dist -= delta*300
		
	elif running and not finished:
		self.position.x += delta*300
		dist += delta*300
		
	
	if dist < -950:
		move_left = false
	elif dist > 950:
		move_left = true
	
	if finished:
		$hover.wait_time = 0.05
		hover_speed = 400
		$sprite.position.y = 270
	
	if die and finished:
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
		await get_tree().create_timer(0.1).timeout
		$bosscam.make_current()

func _on_attack_timeout():
	if running and not finished:
		hover_lim = 400
		var scene = attack.instantiate()
		self.add_child(scene)

func hit():
	$particles.emitting = true
	print("hit!")
	flash_red()
	if health > 150:
		$sprite.frame = 0
	elif health > 130:
		$sprite.frame = 1
	elif health > 100:
		$sprite.frame = 2
	elif health > 80:
		$sprite.frame = 3
	elif health > 60:
		$sprite.frame = 4
	elif health > 50:
		$sprite.frame = 5
	elif health > 40:
		$sprite.frame = 6
	elif health > 30:
		$sprite.frame = 7
	elif health > 20:
		$sprite.frame = 8
	else:
		$sprite.frame = 9
	
	if health <= 0:
		finished = true
		running = false
		Dialogic.end_timeline()
		Dialogic.start(end_timeline)
		await get_tree().create_timer(0.1).timeout
		$bosscam.make_current()
	
func flash_red():
	$sprite.modulate = Color(1,0.5,0.5)
	await get_tree().create_timer(0.1).timeout
	$sprite.modulate = Color(1,1,1)

func _on_dialogic_signal(arg):
	if arg == "die":
		die = true
		global.spawn_portal(global_position+Vector2(0,-200),"solaria")
