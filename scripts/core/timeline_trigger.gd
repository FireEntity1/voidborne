extends Area2D

@export var timeline: DialogicTimeline
@export var automatic: bool = false
@export var repeat: bool = false
@export var distance_above: int = -180

var is_player_active = false
var completed = false

@onready var confirm = $confirm

func _ready() -> void:
	$confirm.global_position = global_position + Vector2(-161,distance_above)

func _process(delta: float) -> void:
	if is_player_active:
		confirm.modulate.a = move_toward(confirm.modulate.a,1.0,delta)
	else:
		confirm.modulate.a = move_toward(confirm.modulate.a,0.0,delta)
	if Input.is_action_just_pressed("interact") and is_player_active:
		Dialogic.start(timeline)

func _on_body_entered(body) -> void:
	print("ENTERED")
	if completed:
		return
	if body.is_in_group("player"):
		print("ts player")
		is_player_active = true
		if automatic:
			Dialogic.start(timeline)
			completed = true if not repeat else false
			set_deferred("monitoring", false)


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_active = false
