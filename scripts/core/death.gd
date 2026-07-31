extends Node2D

var quitting = false

func _on_tryagain_button_up() -> void:
	quitting = true
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://components/main.tscn")

func _on_quit_button_up() -> void:
	quitting = true
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/title.tscn")

func _physics_process(delta: float) -> void:
	if quitting:
		$fade.color.a = move_toward($fade.color.a,1.0,delta*2)
