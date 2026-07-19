extends Node2D

@export var waves: Array[Wave] = []
@export var size: Vector2 = Vector2(100,100)
@export var spawnarea: Vector2 = Vector2(300,50)
@export var min_spawn_distance: float = 160.0

@export var spawn_positions: Array[float] = [-1200,-1000,800,800,1000,1200]

@export var particle_colour: Color = Color(1, 1, 1)

@export var onstart: String
@export var onfinish: String

var markers: Array[Marker2D]
var markers_used: Array[bool]

var started = false

func _ready() -> void:
	$collision.shape.size = size
	for child in get_children():
		if child.name.begins_with("marker"):
			markers.append(child)

func start_waves():
	for wave in waves:
		var enemies = spawn_wave(wave)
		
		while enemies_alive(enemies):
			await get_tree().process_frame
		
		await get_tree().create_timer(wave.delay_before_next_wave).timeout
	return OK

func spawn_wave(wave: Wave) -> Array[Node]:
	var spawned_enemies: Array[Node] = []
	
	for enemy_count in wave.enemies:
		if enemy_count.enemy == null:
			continue
		
		for i in range(enemy_count.amount):
			var enemy = enemy_count.enemy.instantiate() as Node2D
			if enemy == null:
				push_warning("ts scene does NOT inherit node2d u dumbass")
				continue
			call_deferred("_add_spawned_enemy", enemy, _get_spawn_position())
			spawned_enemies.append(enemy)
	
	return spawned_enemies

func _get_spawn_position() -> Vector2:
	#var reference_position = Global.player.global_position if is_instance_valid(Global.player) else global_position
	#var max_distance = max(abs(spawnarea.x) * 0.5, min_spawn_distance)
	#var side = -1.0 if randf() < 0.5 else 1.0
	#var x_offset = randf_range(min_spawn_distance, max_distance) * side
	#var y_offset = randf_range(-abs(spawnarea.y) * 0.5, abs(spawnarea.y) * 0.5)
	#return Vector2(reference_position.x + x_offset, global_position.y + y_offset)
	var rand = randi_range(0,markers.size()-1)
	return markers[rand].global_position

func _add_spawned_enemy(enemy: Node2D, spawn_position: Vector2) -> void:
	if not is_instance_valid(enemy):
		return
	var particles = $spawn_ref.duplicate()
	add_child(particles)
	particles.global_position = spawn_position
	var texture = GradientTexture2D.new()
	texture.gradient = Gradient.new()
	texture.gradient.set_color(0,particle_colour)
	texture.gradient.set_color(1,particle_colour)
	texture.width = 16
	texture.height = 16
	particles.texture = texture
	
	particles.show()
	particles.restart()
	particles.emitting = true
	await get_tree().create_timer(1.0).timeout
	add_child(enemy)
	enemy.global_position = spawn_position

func enemies_alive(enemies: Array[Node]) -> bool:
	for enemy in enemies:
		if enemy.alive:
			return true
	
	return false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not started:
		Dialogic.emit_signal("signal_event",onstart)
		started = true
		await start_waves()
		Dialogic.signal_event.emit(onfinish)
