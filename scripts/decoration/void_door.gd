extends StaticBody2D

@export var open_signal: String = ""
@export var closed: bool = true

func _ready() -> void:
	Dialogic.signal_event.connect(open)
	if not closed:
		open(open_signal)

func open(arg):
	if arg == open_signal:
		$sprite.play("open")
		$collision.disabled = true

func hit():
	$sprite.play("default")
