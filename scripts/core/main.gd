extends Node2D

@onready var vingette = $ui/vingette
@onready var radial_chromabb = $ui/radial_chromabb
@onready var fade = $ui/fade
@onready var health_hud = $ui/healthhud

var loaded_scene: String

const PLAYER = preload("res://components/core/player.tscn")

func _ready() -> void:
	#$game/player.connect("player_hit",_on_player_hit)
	Global.root = self
	Global.connect("vingette",_vingette)
	change_area("outlands_underground")
	#change_location(Global.state.voidwell_id)
	change_location("test")

func _process(delta: float) -> void:
	fade.modulate.a = move_toward(fade.modulate.a, 1.0, delta) if Global.fade.active else move_toward(fade.modulate.a, 0.0, delta)
	fade.color = Color(0,0,0) if Global.fade.black else Color(1,1,1)
	if Global.fade.instant:
		fade.modulate.a = 1.0 if Global.fade.active else 0.0

func _on_player_hit():
	await get_tree().create_timer(0.3, true, false, true).timeout

func _vingette(show: bool,radius: float) -> void:
	vingette.material.set_shader_parameter("radius", radius)
	if show:
		vingette.show()
	else:
		vingette.hide()
 
func change_area(area: String,location: String = "default"):
	loaded_scene = area
	var area_data = Global.levels[area]
	for child in $game/loaded_scene.get_children():
		child.queue_free()
	var new = area_data.scene.instantiate()
	$game/loaded_scene.add_child(new)
	
	if area_data.vingette:
		vingette.show()
	else:
		vingette.hide()
	
	if area_data.radial_chromabb:
		radial_chromabb.show()
	else:
		radial_chromabb.hide()
	
	Global.player = PLAYER.instantiate()
	new.get_node("player_hold").add_child(Global.player)
	health_hud.bind_player(Global.player)
	
	print(Global.levels[area].locations[location])
	Global.player.position = Global.levels[area].locations[location]
	Global.player.velocity.y = 5000
	var camera := Global.player.get_node("camera") as Camera2D
	camera.position_smoothing_enabled = false
	camera.make_current()
	await get_tree().create_timer(0.05).timeout
	camera.position_smoothing_enabled = true

func change_location(id: String):
	var scene = $game/loaded_scene.get_children()[0]
	var player = scene.get_node("player_hold").get_node("player")
	print(scene)
	if id == "":
		#player.position = Global.levels[loaded_scene].locations["default"]
		player.global_position = get_location("default")
	else:
		player.global_position = get_location("default")
	for child in scene.get_node("voidwell_hold").get_children():
		if child.id == id:
			player.position = child.position
	
func get_location(id: String):
	return $game/loaded_scene.get_children()[0].get_node("spawn_pos").get_node(id).global_position
