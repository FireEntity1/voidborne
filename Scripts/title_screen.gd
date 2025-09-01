extends Node2D

func _on_start_button_up():
	$startsfx.play()
	global.enable_input()
	global.fade(true,6,true)
	await get_tree().create_timer(6).timeout
	match global.save_file.checkpoint:
		"prelude":
			get_tree().change_scene_to_file("res://Levels/prelude.tscn")
		"spawn", "outlands_orren", "outlands_boss":
			get_tree().change_scene_to_file("res://Levels/outlands.tscn") 
		"solaria_spawn", "solaria_orren", "solaria_boss":
			get_tree().change_scene_to_file("res://Levels/solaria.tscn")
		"crown":
			get_tree().change_scene_to_file("res://Levels/crown.tscn")
