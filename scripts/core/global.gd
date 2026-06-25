extends Node

signal vingette(show:bool, time:float)

var time_scale = 1.0

var can_move = true

var fade = {
	"active": false,
	"black": true
}

var player: CharacterBody2D
var root: Node2D

func _process(delta: float) -> void:
	Engine.time_scale = move_toward(Engine.time_scale,time_scale,delta*10.0)

func pause_frames(time: float):
	time_scale = 0.2
	await get_tree().create_timer(time, true, false, true).timeout
	time_scale = 1.0

func screen_vingette(show: bool, time: float = 0.0, radius: float = 0.62):
	vingette.emit(show,radius)
	if time > 0.0:
		await get_tree().create_timer(time, true, false, true).timeout
		vingette.emit(false, radius)

func fadescreen(active = false,black = true):
	fade.active = active
	fade.black = black

func mod_can_move(status: bool = true):
	can_move = status
