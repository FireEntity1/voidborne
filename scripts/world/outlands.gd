extends Node2D

var timer = Timer.new()

func _ready() -> void:
	Dialogic.connect("signal_event",_on_signal)
	await get_tree().create_timer(0.1).timeout
	if Global.state.outlands_light == true:
		Global.screen_vingette(false)
	else:
		Global.screen_vingette(true)
	add_child(timer)
	timer.wait_time = 0.1
	timer.one_shot = false
	timer.connect("timeout",_col_timeout)
	timer.start()

func _on_signal(arg):
	if arg == "open_smog_ridge":
		$door_over.play("open")
		$door.get_node("collision").disabled = true
		$door.get_node("sprite").play("open")
		await $door_over.animation_finished
		$door_over.play("default")

func _col_timeout():
	for body in $underground_cover_hit.get_overlapping_bodies():
		if body.is_in_group("player"):
			body.hit(1,true,body.global_position)

func _on_underground_cover_2_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.hit(1,true,body.global_position)
