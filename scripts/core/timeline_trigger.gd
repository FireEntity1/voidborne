extends Area2D

@export var timeline: DialogicTimeline
@export var automatic: bool = false
@export var repeat: bool = false
@export var distance_above: int = -180

@export var interact_text: String = ""

@export var item_required: String = ""
@export var emit_signal = false
@export var signal_string: String = "" 

var is_player_active = false
var completed = false

var active = false

@onready var confirm = $confirm

func _ready() -> void:
	$confirm.global_position = global_position + Vector2(-161,distance_above)
	if interact_text != "":
		$confirm.text = interact_text

func _process(delta: float) -> void:
	if is_player_active and not automatic:
		confirm.modulate.a = move_toward(confirm.modulate.a,1.0,delta)
	else:
		confirm.modulate.a = move_toward(confirm.modulate.a,0.0,delta)
	if Input.is_action_just_pressed("interact") and is_player_active and not active:
		start()

func _on_body_entered(body) -> void:
	print("ENTERED")
	if completed:
		return
	if body.is_in_group("player"):
		print("ts player")
		is_player_active = true
		
		if automatic:
			
			start()

func start():
	if item_required != "":
		if not Global.items[item_required]:
			return
	if completed and not repeat:
		return
	if emit_signal:
		Dialogic.emit_signal("signal_event",signal_string)
		return
	Dialogic.start(timeline)
	active = true
	await Dialogic.timeline_ended
	print("done!")
	active = false


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		is_player_active = false
