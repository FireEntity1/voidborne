extends Node2D

@export var waves: Array[Wave] = []
@export var size: Vector2 = Vector2(100,100)
@export var spawnarea: Vector2 = Vector2(300,50)

@export var onfinish: DialogicTimeline

var started = false

func _ready() -> void:
	$collision.shape.size = size

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
			var enemy = enemy_count.enemy.instantiate()
			add_child(enemy)
			var sign = [1,-1].pick_random()
			enemy.global_position = global_position + Vector2(randi_range(sign*64,sign*spawnarea.x/2),0)
			spawned_enemies.append(enemy)
	
	return spawned_enemies

func enemies_alive(enemies: Array[Node]) -> bool:
	for enemy in enemies:
		if is_instance_valid(enemy):
			return true
	
	return false

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and not started:
		started = true
		await start_waves()
		Dialogic.start(onfinish)
