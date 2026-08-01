extends Node

signal vingette(show:bool, radius:float)
signal focus_vingette(show:bool)

var time_scale = 1.0

var can_move = true

var health: int

var items = {
	"dash": false,
	"ridge_tablet": true
}

var upgrade_lookup = {
	"Strength 1": {
		"effect": "damage",
		"amt": 2
	},
	"Strength 2": {
		"effect": "damage",
		"amt": 4
	},
	"Range 1": {
		"effect": "range",
		"amt": 2.0
	},
	"Range 2": {
		"effect": "range",
		"amt": 2.0
	},
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
	"area": "outlands_tower",
	"voidwell_id":"tower",
	"respawn_elevators": [],
	"health": 10,
	"max_health": 6,
	
	"light_shards": 0,
	
	"upgrades": {
		"Strength 1": false,
		"Strength 2": false,
		
		"Range 1": false,
		"Range 2": false,
	},
	
	"visited": [],
	
	"shards_collected": [],
	
	# world states and wtv
	"outlands_light": true,
	"foundry_unlocked": true,
	
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
	load_save()
	health = state.max_health
	print(state)
	

func _process(delta: float) -> void:
	Engine.time_scale = move_toward(Engine.time_scale,time_scale,delta*10.0)
	save()

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

func change_scene(area: String, location: String = "default", elevator_arrival: Dictionary = {}):
	root.change_area(area, location, elevator_arrival)

func set_voidwell(id: String, respawn_elevators: Array = []):
	state.voidwell_id = id
	state.area = root.get_node("game").get_node("loaded_scene").get_children()[0].name
	state.respawn_elevators = respawn_elevators
	print(state.voidwell_id)

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
