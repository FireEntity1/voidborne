extends Node2D

@onready var vingette: ColorRect = $ui/vingette
@onready var radial_chromabb = $ui/radial_chromabb
@onready var fade = $ui/fade
@onready var health_hud = $ui/healthhud
@onready var voidmeter = $ui/voidmeter
@onready var glitch = $ui/glitch

var loaded_scene: String
var area_vingette = false
var focus_vingette = false
var vingette_tween: Tween

var fade_mult = 1.0

var show_title = false

var died = false

const PLAYER = preload("res://components/core/player.tscn")

func _ready() -> void:
	#$game/player.connect("player_hit",_on_player_hit)
	fade_mult = 2.5
	Dialogic.connect("signal_event",_dialogic_signal)
	Global.root = self
	Global.connect("vingette",_vingette)
	Global.connect("focus_vingette",_focus_vingette)
	change_area(Global.state.area,"default",{},Global.state.get("respawn_elevators",[]))
	Global.health = Global.player.health
	#Global.state.voidwell_id = "outlands_boss"
	change_location(Global.state.voidwell_id)
	await get_tree().create_timer(3.0).timeout
	fade_mult = 1.0

func _process(delta: float) -> void:
	fade.modulate.a = move_toward(fade.modulate.a, 1.0, delta/fade_mult) if Global.fade.active else move_toward(fade.modulate.a, 0.0, delta/fade_mult)
	fade.color = Color(0,0,0) if Global.fade.black else Color(1,1,1)
	if Global.fade.instant:
		fade.modulate.a = 1.0 if Global.fade.active else 0.0
	voidmeter.value = Global.voidmeter
	
	if show_title:
		$ui/title.modulate.a = move_toward($ui/title.modulate.a,1.0,delta/3.0)
	else:
		$ui/title.modulate.a = move_toward($ui/title.modulate.a,0.0,delta/3.0)
	
	
	
	if died:
		glitch.material.set_shader_parameter("shake_power",
		lerpf(glitch.material.get_shader_parameter("shake_power"),0.1,delta/2.0))
		
		glitch.material.set_shader_parameter("shake_color_rate",
		lerpf(glitch.material.get_shader_parameter("shake_color_rate"),0.03,delta/2.0))

func _on_player_hit():
	await get_tree().create_timer(0.3, true, false, true).timeout

func _vingette(show: bool,radius: float) -> void:
	area_vingette = show
	_update_vingette(radius)

func _focus_vingette(show: bool) -> void:
	focus_vingette = show
	_update_vingette()

func _update_vingette(radius: float = 0.62) -> void:
	if is_instance_valid(vingette_tween):
		vingette_tween.kill()
	vingette_tween = create_tween().set_parallel()
	if focus_vingette:
		if not vingette.visible:
			vingette.modulate.a = 0.0
			vingette.show()
		vingette_tween.tween_property(vingette,"modulate:a",1.0,1.0)
		vingette_tween.tween_property(vingette.material,"shader_parameter/radius",0.5,1.0)
	elif area_vingette:
		vingette.show()
		vingette_tween.tween_property(vingette,"modulate:a",1.0,1.0)
		vingette_tween.tween_property(vingette.material,"shader_parameter/radius",radius,1.0)
	else:
		vingette_tween.tween_property(vingette,"modulate:a",0.0,1.0)
		vingette_tween.tween_callback(vingette.hide).set_delay(1.0)
 
func change_area(area: String,location: String = "default",elevator_arrival: Dictionary = {},respawn_elevators: Array = []):
	loaded_scene = area
	var area_data = Global.levels[area]
	var new: Node2D = area_data.scene.instantiate()
	for config in respawn_elevators:
		var path = config.get("path", "")
		var elevator = new.get_node_or_null(path)
		if elevator == null:
			push_error("respawn elevator not found buckaroo")
		else:
			elevator.set_initial_terminal(config.get("at_top",false))
	for child in $game/loaded_scene.get_children():
		child.queue_free()
	
	var arrival_elevator: Node2D = null
	
	if not elevator_arrival.is_empty():
		arrival_elevator = new.get_node_or_null(elevator_arrival.path) as Node2D
		if arrival_elevator == null:
			push_error("elevator was not found :pensive:")
		else:
			arrival_elevator.set_initial_terminal(elevator_arrival.at_top)
	

	$game/loaded_scene.add_child(new)
	
	
	area_vingette = area_data.vingette
	_update_vingette()
	
	if area_data.radial_chromabb:
		radial_chromabb.show()
	else:
		radial_chromabb.hide()
	
	Global.player = PLAYER.instantiate()
	new.get_node("player_hold").add_child(Global.player)
	health_hud.bind_player(Global.player)
	
	if arrival_elevator != null:
		Global.player.global_position = arrival_elevator.get_boarding_position()
		Global.player.velocity = Vector2.ZERO
		
		await get_tree().process_frame
		
		if elevator_arrival.auto_depart:
			arrival_elevator.begin_trip(Global.player)
	else:
		Global.player.global_position = new.get_node("spawn_pos").get_node(location).global_position
	Global.state.area = area
	
	#Global.player.position = Global.levels[area].locations[location]
	Global.player.velocity.y = 5000
	var camera := Global.player.get_node("camera") as Camera2D
	camera.position_smoothing_enabled = false
	camera.make_current()
	await get_tree().create_timer(0.05).timeout
	camera.position_smoothing_enabled = true
	
	remove_shards()

func change_location(id: String):
	var scene = $game/loaded_scene.get_children()[0]
	var player = Global.player
	for child in scene.get_node("voidwell_hold").get_children():
		if child.id == id:
			player.position = child.position
			return
	player.global_position = get_location(id)

func get_location(id: String):
	var hold = $game/loaded_scene.get_children()[0].get_node("voidwell_hold").get_children()
	for child: Area2D in hold:
		if child.id == id:
			return child.global_position
	return $game/loaded_scene.get_children()[0].get_node("spawn_pos").get_node("default").global_position

func _dialogic_signal(param:String):
	print(param)
	if param.begins_with("title_"):
		var text = param.split("title_")
		title(text[1])
	elif param == "upgrade_menu":
		$upgrade.popup_centered()

func title(text):
	$ui/title.text = text
	show_title = true
	await get_tree().create_timer(3.0).timeout
	show_title = false

func remove_shards():
	var parent = $game/loaded_scene.get_children()[0].get_node("light_shards").get_children()
	for child in parent:
		for id in Global.state.shards_collected:
			print(id, "child: ", child.id)
			if child.id == id:
				
				child.queue_free()
				continue

func die():
	died = true
	glitch.show()
	await get_tree().create_timer(1.4).timeout
	Global.screen_vingette(true,0.0,0.4)
	Global.fadescreen(true,true,true)
	$game/loaded_scene.get_children()[0].queue_free()
	await get_tree().create_timer(2.0).timeout
	get_tree().change_scene_to_file("res://scenes/death.tscn")
	Global.fadescreen(false,true,false)
	Global.mod_can_move(true)
	
