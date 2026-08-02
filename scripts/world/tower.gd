extends Node2D

@onready var overlay = $overlay

var switched = false
var col = 0.2

func _ready() -> void:
	$overlay.show()
	$to_outlands/collision.disabled = true
	$to_outlands.monitoring = false
	await get_tree().create_timer(0.8).timeout
	if not Global.state.visited.has("outlands_tower"):
		Dialogic.emit_signal("signal_event","title_The Tower")
	await get_tree().create_timer(3.2).timeout
	$to_outlands/collision.disabled = false
	$to_outlands.monitoring = true
	if Global.state.outlands_light == true:
		$audio.play()

func _physics_process(delta: float) -> void:
	if switched:
		col = lerp(col,0.0,delta*2.0)
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
	$audio.play()
