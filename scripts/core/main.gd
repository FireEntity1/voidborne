extends Node2D

@onready var vingette = $ui/vingette

func _ready() -> void:
	$game/player.connect("player_hit",_on_player_hit)
	Global.connect("vingette",_vingette)

func _on_player_hit():
	await get_tree().create_timer(0.3, true, false, true).timeout

func _vingette(show: bool,radius: float) -> void:
	vingette.material.set_shader_parameter("radius", radius)
	if show:
		vingette.show()
	else:
		vingette.hide()
