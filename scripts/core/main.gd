extends Node2D

@onready var vingette = $ui/vingette
@onready var fade = $ui/fade

const PLAYER = preload("res://components/core/player.tscn")

func _ready() -> void:
	#$game/player.connect("player_hit",_on_player_hit)
	Global.root = self
	Global.connect("vingette",_vingette)
	change_area("voidnexus")

func _process(delta: float) -> void:
	fade.modulate.a = move_toward(fade.modulate.a, 1.0, delta/2.0) if Global.fade.active else move_toward(fade.modulate.a, 0.0, delta/2.0)
	fade.color = Color(0,0,0) if Global.fade.black else Color(1,1,1)

func _on_player_hit():
	await get_tree().create_timer(0.3, true, false, true).timeout

func _vingette(show: bool,radius: float) -> void:
	vingette.material.set_shader_parameter("radius", radius)
	if show:
		vingette.show()
	else:
		vingette.hide()

func change_area(area: String):
	for child in $game/loaded_scene.get_children():
		child.queue_free()
	var new = Global.levels[area].scene.instantiate()
	$game/loaded_scene.add_child(new)
	Global.player = PLAYER.instantiate()
	Global.player.global_position = Global.levels[area].startpos
	$game/loaded_scene.get_node(area).get_node("player_hold").add_child(Global.player)
