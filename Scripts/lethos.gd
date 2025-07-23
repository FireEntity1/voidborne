extends Node2D

var health = 200

@export var start_timeline: DialogicTimeline

var attack = preload("res://Components/lethos_attack.tscn")

var hover_up = true

var running = false

func _ready():
	pass

func _process(delta):
	running = global.lethos_attacking
	if hover_up:
		$sprite.position.y -= delta*25
	else:
		$sprite.position.y += delta*25

func _on_damage_body_entered(body):
	if body.name == "player" and running:
		body.hit(self.position)

func _on_hover_timeout():
	if hover_up:
		hover_up = false
	else:
		hover_up = true

func _on_start_detection_body_entered(body):
	if body.name == "player":
		global.lethos_attacking = false
		Dialogic.start(start_timeline)
		$start_detection.queue_free()

func _on_attack_timeout():
	if running:
		var scene = attack.instantiate()
		self.add_child(scene)
