extends Node2D

@export var fragment_id: String

func _ready():
	if global.save_file.fragments[fragment_id]:
		queue_free()

func _on_area_body_entered(body):
	if body.name == "player":
		if not global.save_file.has_fragment:
			global.save_file.has_fragment = true
		else:
			global.save_file.has_fragment = false
			global.save_file.hearts += 1
			global.save()
			body.health = global.save_file.hearts
			body.update_hearts()
			global.frag_animation()
		$sprite.queue_free()
		$area.queue_free()
		$particles.emitting = true
		global.save_file.fragments[fragment_id] = true
		global.save()
		await get_tree().create_timer(2).timeout
		queue_free()
