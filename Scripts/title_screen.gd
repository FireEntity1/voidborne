extends Node2D

var to = true

func _ready():
	await get_tree().create_timer(1).timeout
	to = false

func _physics_process(delta):
	if to and $cover.modulate.a < 1:
		$cover.modulate.a += delta*5
	elif not to and $cover.modulate.a > 0:
		$cover.modulate.a -= delta*5

func _on_start_button_up():
	$startsfx.play()
	global.enable_input()
	to = true

	var tree = get_tree()
	await tree.create_timer(1.5).timeout
	print(global.save_file.checkpoint)
	match global.save_file.checkpoint:
		"prelude":
			tree.change_scene_to_file("res://Levels/prelude.tscn")
		"spawn", "outlands_orren", "outlands_boss":
			tree.change_scene_to_file("res://Levels/outlands.tscn") 
		"solaria_spawn", "solaria_orren", "solaria_boss":
			tree.change_scene_to_file("res://Levels/solaria.tscn")
		"crown":
			tree.change_scene_to_file("res://Levels/crown.tscn")

func _on_try_again_button_up():
	$startsfx.play()
	global.enable_input()
	to = true

	var tree = get_tree()
	await tree.create_timer(1.5).timeout

	match global.save_file.checkpoint:
		"prelude":
			tree.change_scene_to_file("res://Levels/prelude.tscn")
		"spawn", "outlands_orren", "outlands_boss":
			tree.change_scene_to_file("res://Levels/outlands.tscn") 
		"solaria_spawn", "solaria_orren", "solaria_boss":
			tree.change_scene_to_file("res://Levels/solaria.tscn")
		"crown":
			tree.change_scene_to_file("res://Levels/crown.tscn")
