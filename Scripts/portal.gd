extends Node2D

@export var dest: String

func _ready():
	var level_path = "res://Levels/" + dest + ".tscn"
	dest = level_path

func _process(delta):
	if $area/sprite.modulate.a < 1:
		$area/sprite.modulate.a += delta

func _on_area_body_entered(body):
	if body.name == "player":
		global.white_transition()
		global.disable_input()
		$sfx.play()
		await get_tree().create_timer(2).timeout
		global.enable_input()
		get_tree().change_scene_to_file(dest)
