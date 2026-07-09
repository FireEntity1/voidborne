extends Node

signal vingette(show:bool, time:float)

var time_scale = 1.0

var can_move = true

var items = {
	"dash": false
}

var levels = {
	"voidnexus": {
		"scene": preload("res://areas/void_nexus/void_nexus.tscn"),
		"locations": {
			"default": Vector2(1200,250),
			"to_outlands": Vector2(13000.0,-2343.0),
		},
		"vingette": true,
		"radial_chromabb": true,
	},
	"outlands": {
		"scene": preload("res://areas/outlands/outlands.tscn"),
		"locations": {
			"default": Vector2(-800,-100),
			#"to_underground": Vector2(24000,1100),
			"to_underground": Vector2(24000,-11300),
		},
		"vingette": false,
		"radial_chromabb": false,
	},
	"outlands_underground": {
		"scene": preload("res://areas/outlands/underground.tscn"),
		"locations": {
				"default": Vector2(500,200),
				"to_outlands": Vector2(500,200)
			},
		"vingette": true,
		"radial_chromabb": false,
	}
}

var fade = {
	"active": false,
	"black": true,
	"instant": false,
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

func fadescreen(active = false,black = true,instant = false):
	fade.active = active
	fade.black = black
	fade.instant = instant

func mod_can_move(status: bool = true):
	can_move = status

func change_scene(area: String, location: String = "default"):
	root.change_area(area, location)
