extends StaticBody2D

@export var open_signal: String = ""
@export var close_signal: String = ""
@export var closed: bool = true

var is_closed: bool

func _ready() -> void:
	Dialogic.signal_event.connect(open)
	is_closed = not closed
	if not closed:
		open(open_signal)
	elif closed:
		open(close_signal)
	is_closed = closed

func open(arg):
	if arg == open_signal and is_closed:
		$sprite.play("open")
		$collision.disabled = true
	elif arg == close_signal and not is_closed:
		$sprite.play("close")
		$collision.disabled = false

func hit():
	$sprite.play("default")
