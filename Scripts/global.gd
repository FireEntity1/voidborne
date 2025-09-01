extends Node

var save_file = {
	"hearts": 5,
	"damage": 5,
	"has_fragment": false,
	"checkpoint": "prelude",
	"world": "outlands",
	
	"timelines_done": [],
	
	"fragments": {
		"outlands_a": false,
		"outlands_b": false,
		"outlands_c": false,
		"outlands_d": false,
		"outlands_e": false,
		"solaria_a": false,
		"solaria_b": false,
		"solaria_c": false,
	}
}

var volume = 5

var glitching = false
var shaking = false
var vingetteing = false # i dont think this is a word :skull:

const SAVE_DIRECTORY = "user://save.void"

var player_pos = Vector2(0,0)

var lethos_attacking = false
var helis_attacking = false

var can_move = true

var has_nym = false

@onready var fade_scene = load("res://Components/fade_to.tscn")
@onready var title_scene = load("res://Components/title_text.tscn")
@onready var frag_anim_scene = load("res://Components/void_frag_anim.tscn")
@onready var glitch_scene = load("res://Components/glitch.tscn")
@onready var shake_scene = load("res://Components/screen_shake.tscn")
@onready var vingette_scene = load("res://Components/vingette.tscn")
@onready var portal_scene = load("res://Components/portal.tscn")
@onready var vol_scene = load("res://Components/volume.tscn")

func _ready():
	load_save()
	
	vingette_scene = vingette_scene.instantiate()
	add_child(vingette_scene)
	glitch_scene = glitch_scene.instantiate()
	add_child(glitch_scene)
	shake_scene = shake_scene.instantiate()
	add_child(shake_scene)
	
	vingette(false)
	glitch(false)
	shake(false)

func _process(delta):
	var normalized = 0.5
	if Input.is_action_just_pressed("vol_up"):
		volume += 1
		show_vol()
	elif Input.is_action_just_pressed("vol_down"):
		volume -= 1
		show_vol()
	volume = clamp(volume,0,10)
	normalized = volume/10.0
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(normalized))

func show_vol():
	var scene = vol_scene.instantiate()
	add_child(scene)

func vingette(value = false):
	vingette_scene.is_up = value
	vingetteing = value

func add_finished_timeline(identifier: String):
	save_file.timelines_done.append(identifier)
	print(save_file.timelines_done)
	save()

func glitch(value = false, time = -1):
	glitch_scene.is_glitching = value
	glitch_scene.run()
	if time > 0:
		await get_tree().create_timer(time).timeout
		glitch_scene.is_glitching = false
		glitch_scene.run()

func shake(value = false, time = -1):
	shake_scene.is_shaking = value 
	shake_scene.run()
	if time > 0:
		shake_scene.time = time

func get_finished(identifier: String):
	print(save_file.timelines_done)
	print(identifier)
	for timeline in save_file.timelines_done:
		if timeline == identifier:
			#print("MATCH FOUND")
			return true
	#print("NO MATCH")
	return false
	
func disable_input():
	can_move = false
	
func enable_input():
	can_move = true

func fade(to: bool, time: int, black: bool):
	var scene = fade_scene.instantiate()
	scene.to = to
	scene.timer = time
	scene.black = black
	add_child(scene)

func upgradesword(value):
	save_file.damage = value
	save()

func change_level(level: String):
	get_tree().change_scene_to_file("res://Levels/" + level + ".tscn")

func white_transition():
	var transition = preload("res://Components/white_transition.tscn").instantiate()
	add_child(transition)

func title(text: String, sub = " ", black = false):
	var scene = title_scene.instantiate()
	scene.title = text
	scene.subtitle = sub
	scene.black = black
	get_tree().current_scene.add_child(scene)

func save():
	var file = FileAccess.open(SAVE_DIRECTORY, FileAccess.WRITE)
	file.store_string(JSON.stringify(save_file))
	file.close()

func load_save():
	if FileAccess.file_exists(SAVE_DIRECTORY):
		var file = FileAccess.open(SAVE_DIRECTORY, FileAccess.READ)
		var content = file.get_as_text()
		file.close()
		save_file = JSON.parse_string(content)
	else:
		save()

func frag_animation():
	var scene = frag_anim_scene.instantiate()
	add_child(scene)

func get_spawn_coords():
	match save_file.checkpoint:
		"spawn": return Vector2(597,767)
		"outlands_boss": return Vector2(4739,-5548)

func set_checkpoint(arg):
	save_file.checkpoint = arg
	save()

func set_attacking(boss, value):
	match boss:
		"lethos":
			lethos_attacking = value
		"helis":
			helis_attacking = value
			print("GLOBAL: helis attacking: " + str(value))

func spawn_portal(coords: Vector2, scene: String):
	var portal = portal_scene.instantiate()
	portal.global_position = coords
	portal.dest = scene
	get_tree().current_scene.add_child(portal)
