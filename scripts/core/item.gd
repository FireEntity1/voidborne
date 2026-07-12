extends Area2D

@export var sprite: SpriteFrames
@export var item_id: String = ""
@export var glow = true

var up = true

func _ready() -> void:
	if not glow:
		$glow.hide()
	$sprite.sprite_frames = sprite
	$sprite.play()

func _process(delta: float) -> void:
	if up:
		$sprite.position.y -= delta*10
		$glow.position.y -= delta*10
	else: 
		$sprite.position.y += delta*10
		$glow.position.y += delta*10

func _on_up_timeout() -> void:
	up = not up

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		Global.items[item_id] = true
		$sprite.hide()
		$glow.hide()
		$collect.emitting = true
		monitoring = false
