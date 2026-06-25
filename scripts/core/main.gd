extends Node2D

@onready var vingette = $ui/vingette
@onready var fade = $ui/fade

func _ready() -> void:
	$game/player.connect("player_hit",_on_player_hit)
	Global.root = self
	Global.connect("vingette",_vingette)

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
