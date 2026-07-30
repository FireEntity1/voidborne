extends Area2D

@export var to: String
@export var location: String
@export var black: bool = true

@export var arrival_elevator_path: String = ""
@export_enum("top", "bottom") var arrival_elevator_terminal = "bottom"
@export var arrival_auto_depart = true

@export var is_elevator_arrival = false

var active = false

func _ready() -> void:
	if is_elevator_arrival:
		await get_tree().create_timer(3.0).timeout
	active = true

func _on_body_entered(body: Node2D) -> void:
	if not active or not body.is_in_group("player"):
		return
	if location.is_empty():
		location = "default"
	Global.mod_can_move(false)
	Global.fadescreen(true,black)
	await get_tree().create_timer(1.4).timeout
	if body.is_in_group("player"):
		Global.health = body.health
		var elevator_arrival = {}
		if not arrival_elevator_path.is_empty():
			elevator_arrival = {
				"path": arrival_elevator_path,
				"at_top": arrival_elevator_terminal == "top",
				"auto_depart": arrival_auto_depart
			}
		Global.change_scene(to, location, elevator_arrival)
	Global.mod_can_move(true)
	Global.fadescreen(false,black)
