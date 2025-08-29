extends Area2D

var health = 300

var is_boss = true
var enemy = true

var dist = 0

var finished = false

var progress = 0

var die = false

@export var start_timeline: DialogicTimeline
@export var end_timeline: DialogicTimeline

var ball = preload("res://Components/erythis_ball.tscn")
var beam = preload("res://Components/erythis_beam.tscn")

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
	
	if dist < -1750:
		move_left = false
	elif dist > 1750:
		move_left = true
	
	if finished:
		$hover.wait_time = 0.05
		hover_speed = 400
	
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
		var scenes = []
		if attack == "ball":
			scenes.append(ball.instantiate())
			scenes.append(ball.instantiate())
			scenes.append(ball.instantiate())
			for scene in scenes:
				scene.global_position = global.player_pos
				scene.global_position.x += randi_range(-2,2)*1000
				scene.global_position.y = randi_range(-1000,1000)
				scene.velocity = 1000
				get_tree().root.add_child(scene)
				await get_tree().create_timer(0.2).timeout
		elif attack == "beam":
			scenes.append(beam.instantiate())
			for scene in scenes:
				scene.global_position = global.player_pos
				scene.global_position = Vector2(randi_range(-1,1)*2000 - 3000,randi_range(-1,1)*1000)
				get_tree().root.add_child(scene)

func hit():
	$particles.emitting = true
	print("hit!")
	flash_red()

	if health <= 0:
		finished = true
		running = false
		Dialogic.start(end_timeline)
		$death_particles.emitting = true
	
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
	if arg == "erythis-destroy":
		$SomethingLooms.stop()
	
