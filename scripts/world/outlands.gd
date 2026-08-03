extends Node2D

var timer = Timer.new()

var door_open = false

var lethos_running = false

var fade_audio = false

func _ready() -> void:
	if Global.state.outlands_light == true:
		$underground_cover.queue_free()
		$underground_cover_hit.queue_free()
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
	if not Global.state.visited.has("outlands"):
		Dialogic.emit_signal("signal_event","title_The Outlands")
	
	if Global.state.foundry_unlocked:
		$door_over.play("default")
		$door.get_node("collision").disabled = true
		$door.get_node("sprite").play("open")
		door_open = true

func _process(delta: float) -> void:
	if fade_audio:
		$audio.volume_db = move_toward($audio.volume_db,-5,delta*20)

func _on_signal(arg):
	if arg == "open_foundry" and not door_open:
		Global.mod_can_move(false)
		$door_over.play("open")
		$door.get_node("collision").disabled = true
		$door.get_node("sprite").play("open")
		$door_open.play(0.3)
		await $door_over.animation_finished
		$door_over.play("default")
		Global.mod_can_move(true)
		door_open = true
		Global.state.foundry_unlocked = true
	if arg == "lethos_start":
		$audio.stop()
		$lethos_music.play()
	if arg == "lethos_end":
		$lethos_music.stop()
		$audio.volume_db = -80
		await get_tree().create_timer(16.0).timeout
		$audio.play()
		fade_audio = true

func _col_timeout():
	if get_node_or_null("underground_cover_hit") == null:
		return
	for body in $underground_cover_hit.get_overlapping_bodies():
		if body.is_in_group("player"):
			body.hit(1,true,body.global_position)

func _on_underground_cover_2_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		body.hit(1,true,body.global_position)
