extends Area2D

const PICKUP_SCENE = preload("res://components/core/item_pickup.tscn")

@export var sprite: SpriteFrames
@export var item_id: String = ""
@export var glow = true

@export var item_name = ""
@export var item_description = ""

var done = false

var up = true

func _ready() -> void:
	if not glow:
		$glow.hide()
	$sprite.sprite_frames = sprite
	$sprite.play()
	await get_tree().create_timer(0.5).timeout
	if Global.state.items[item_id] == true:
		queue_free()

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
	if done:
		return
	if body.is_in_group("player"):
		done = true
		body.velocity = Vector2(0,0)
		var popup = PICKUP_SCENE.instantiate()
		popup.item_name = item_name
		popup.desc = item_description
		add_child(popup)
		Global.mod_can_move(false)
		Global.state.items[item_id] = true
		$sprite.hide()
		$glow.hide()
		$collect.emitting = true
		monitoring = false
		await get_tree().create_timer(2.0).timeout
		Global.mod_can_move(true)
		
