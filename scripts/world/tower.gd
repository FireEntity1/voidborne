extends Node2D

@onready var overlay = $overlay

var switched = false
var col = 0.2

func _ready() -> void:
	$to_outlands/collision.disabled = true
	$to_outlands.monitoring = false
	await get_tree().create_timer(4.0).timeout
	$to_outlands/collision.disabled = false
	$to_outlands.monitoring = true

func _physics_process(delta: float) -> void:
	col = lerp(col,0.0,delta/8.0)
	if switched:
		overlay.texture.gradient.colors = PackedColorArray([
		Color(1,1,1,col),
		Color(1,1,1,0)
	])

func flash():
	Global.screen_vingette(false)
	overlay.texture.gradient.colors = PackedColorArray([
		Color(1,1,1,0.2),
		Color(1,1,1,0)
	])
	switched = true
