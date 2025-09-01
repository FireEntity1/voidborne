extends Node2D

var playing = true

# Called when the node enters the scene tree for the first time.
func _ready():
	global.lethos_attacking = false
	Dialogic.signal_event.connect(_on_dialogic_signal)
	match global.save_file.checkpoint:
		"spawn":
			$player.position = Vector2(637, 857)
		"outlands_orren":
			$player.position = Vector2(13472,-3116)
		"outlands_boss":
			$player.position = Vector2(4739,-5548)


func _process(delta):
	pass
	
func _on_dialogic_signal(arg):
	if arg == "die":
		$ambience.play()
		playing = true

func _on_ambience_play_body_entered(body):
	if not playing:
		$ambience.play()
		playing = true


func _on_ambience_stop_body_entered(body):
	if body.name == "player":
		$ambience.stop()
		playing = false
