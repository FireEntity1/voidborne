extends Area2D

var health = 400

var is_boss = true
var enemy = true

var dist = 0

var finished = false

var progress = 0

var die = false

@export var start_timeline: DialogicTimeline
@export var end_timeline: DialogicTimeline

var ball = preload("res://Components/lethos_attack.tscn")
var beam = preload("res://Components/helis_attack.tscn")

var hover_up = true
var hover_speed = 67

var hover_lim = 100

var move_left = true

var attacks = ['ball', 'beam']

var attack_spawns = [Vector2(0, -3000), Vector2(8500,-3000), Vector2(-8500,-3000)]

var running = false

func _ready():
	Dialogic.signal_event.connect(_on_dialogic_signal)

func _process(delta):
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

func _on_attack_timeout():
	print(running)
	if running and not finished:
		print("condition met")
		hover_lim = 400
		var attack = attacks.pick_random()
		var scene
		if attack == "ball":
			scene = ball.instantiate()
		elif attack == "beam":
			scene = beam.instantiate()
		scene.position = position
		$boss_hitbox.add_child(scene)

func hit():
	$particles.emitting = true
	print("hit!")
	flash_red()

	if health <= 0:
		finished = true
		running = false
		Dialogic.start(end_timeline)
	
func flash_red():
	$sprite.modulate = Color(1,0.5,0.5)
	await get_tree().create_timer(0.1).timeout
	$sprite.modulate = Color(1,1,1)

func _on_dialogic_signal(arg):
	if arg == "die":
		die = true
	if arg == "erythis-attack":
		running = true
		finished = false
		print("attackig")
	if arg == "cam-erythis-intro":
		$bosscam.make_current()
