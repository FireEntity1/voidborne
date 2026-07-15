extends Node2D

@export var length: int = 1

@onready var chain: Sprite2D = $base/chain

var closed = false
var goal: int

func _ready() -> void:
	goal = (length-2)*128
	for i in range(length):
		var new = chain.duplicate()
		new.position.y -= 128
		add_child(new)

func _physics_process(delta: float) -> void:
	if closed:
		position.y -= delta*200

func _on_trigger_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		closed = true
		$base/side_l.disabled = false
		$base/side_r.disabled = false
