extends Node

signal vingette(show:bool, radius:float)
signal focus_vingette(show:bool)

var time_scale = 1.0

var can_move = true

var items = {
	"dash": false,
	"ridge_tablet": true
}

var levels = {
	"voidnexus": {
		"scene": preload("res://areas/void_nexus/void_nexus.tscn"),
		"vingette": true,
		"radial_chromabb": true,
	},
	"outlands": {
		"scene": preload("res://areas/outlands/outlands.tscn"),
		"locations": {
		},
		"vingette": false,
		"radial_chromabb": false,
	},
	"outlands_underground": {
		"scene": preload("res://areas/outlands/underground.tscn"),
		"vingette": true,
		"radial_chromabb": false,
	},
	"outlands_tower": {
		"scene": preload("res://areas/outlands/tower.tscn"),
		"vingette": true,
		"radial_chromabb": false,
	},
	"foundry": {
		"scene": preload("res://areas/foundry/foundry.tscn"),
		"vingette": false,
		"radial_chromabb": false
	}
}

var state = {
	"items": {
		"dash": true,
		"ridge_tablet": false,
		"voidblast": true,
	},
	# basic stuff
	"area": "outlands",
	"voidwell_id":"",
	"health": 10,
	"max_health": 10,
	
	# world states and wtv
	"outlands_light": false,
}

var voidmeter = 12

var fade = {
	"active": false,
	"black": true,
	"instant": false,
}

var player: CharacterBody2D
var root: Node2D

func _ready() -> void:
	save()
	load_save()
	print(state)

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

func screen_focus_vingette(show: bool):
	focus_vingette.emit(show)

func fadescreen(active = false,black = true,instant = false):
	fade.active = active
	fade.black = black
	fade.instant = instant

func mod_can_move(status: bool = true):
	can_move = status

func change_scene(area: String, location: String = "default"):
	root.change_area(area, location)

func set_voidwell(id: String):
	pass

func encode_vector(value: Variant):
	pass 
	# i dont need ts rn 
	# but i might need it if i add vector2s to the save file somewhere 
	# so eh might as well keep it here

func save():
	var string = JSON.stringify(state)
	var file = FileAccess.open("user://save.void",FileAccess.WRITE)
	file.store_string(string)
	file.close()

func load_save():
	if FileAccess.file_exists("user://save.void"):
		var file = FileAccess.open("user://save.void",FileAccess.READ)
		var data = file.get_as_text()
		state = JSON.parse_string(data)
		file.close()
