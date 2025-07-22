extends Node

var save_file = {
	"hearts": 5,
	"damage": 5,
}

const SAVE_DIRECTORY = "user://save.void"

var can_move = true

var fade_scene = preload("res://Components/fade_to.tscn")
var title_scene = preload("res://Components/title_text.tscn")

func _ready():
	load_save()

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

func change_level(level: String):
	get_tree().change_scene_to_file("res://Levels/" + level + ".tscn")

func title(text: String):
	var scene = title_scene.instantiate()
	scene.title = text
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
