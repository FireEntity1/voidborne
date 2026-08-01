extends Node2D

var quitting = true

func _ready() -> void:
	await get_tree().create_timer(0.2).timeout
	quitting = false

func _on_tryagain_button_up() -> void:
	quitting = true
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://components/main.tscn")

func _on_quit_button_up() -> void:
	quitting = true
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/title.tscn")
	Global.mod_can_move(true)

func _physics_process(delta: float) -> void:
	if quitting:
		$fade.color.a = move_toward($fade.color.a,1.0,delta*2)
	else:
		$fade.color.a = move_toward($fade.color.a,0.0,delta*2)
