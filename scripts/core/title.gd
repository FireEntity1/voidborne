extends Node2D

var fade_active = true

func _ready() -> void:
	$fade.show()
	await get_tree().create_timer(0.5).timeout
	fade_active = false

func _physics_process(delta: float) -> void:
	if fade_active:
		$fade.modulate.a = lerp($fade.modulate.a, 1.0,delta*4.0)
	else:
		$fade.modulate.a = lerp($fade.modulate.a,0.0,delta*4.0)

func _on_play_button_up() -> void:
	fade_active = true
	await get_tree().create_timer(1.0).timeout
	get_tree().change_scene_to_file("res://scenes/main.tscn")

func _on_quit_button_up() -> void:
	fade_active = true
	await get_tree().create_timer(1.0).timeout
	get_tree().quit()

func _on_settings_button_up() -> void:
	$settings.popup_centered()
