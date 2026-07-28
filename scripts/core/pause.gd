extends CanvasLayer

var paused = false
var transitioning = false


func _ready() -> void:
	hide()

func _physics_process(delta: float) -> void:
	if not transitioning:
		return
	if paused:
		$bg.modulate.a = lerp($bg.modulate.a,1.0,delta*10)
	else:
		$bg.modulate.a = lerp($bg.modulate.a,0.0,delta*5)
	$bg/center/vbox/resume.modulate.a = $bg.modulate.a
	$bg/center/vbox/settings.modulate.a = $bg.modulate.a
	$bg/center/vbox/quit.modulate.a = $bg.modulate.a
	if $bg.modulate.a >= 1.0:
		transitioning = false
	if $bg.modulate.a <= 0.0:
		transitioning = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		toggle_pause()
		get_viewport().set_input_as_handled()
		
func toggle_pause() -> void:
	transitioning = true
	paused = not get_tree().paused
	get_tree().paused = paused
	
	if paused:
		show()
	else:
		hide()

func _on_resume_button_up() -> void:
	toggle_pause()

func _on_quit_button_up() -> void:
	get_tree().change_scene_to_file("res://scenes/title.tscn") 

func _on_settings_button_up() -> void:
	$settings.popup_centered()
