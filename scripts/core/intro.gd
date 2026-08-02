extends Node2D

var fading = true
var black = true

@export var timeline: DialogicTimeline

func _ready() -> void:
	Dialogic.connect("signal_event",_signal)
	await get_tree().create_timer(1.0).timeout
	fading = false
	await get_tree().create_timer(2.0).timeout
	Dialogic.start(timeline)

func _process(delta: float) -> void:
	if fading:
		$fade.modulate.a = move_toward($fade.modulate.a,1.0,delta/3.0)
	else:
		$fade.modulate.a = move_toward($fade.modulate.a,0.0,delta/3.0)
	
	if black:
		$fade.color = Color(0,0,0)
	else:
		$fade.color = Color(1,1,1)
	
func _signal(arg):
	if arg == "start_game":
		#black = false
		fading = true
		await get_tree().create_timer(5.0).timeout
		get_tree().change_scene_to_file("res://components/main.tscn")
