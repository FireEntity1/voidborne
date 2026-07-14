extends Node2D

@onready var heart: AnimatedSprite2D = $heart
@onready var half_heart: AnimatedSprite2D = $half_heart
@onready var container: Node2D = $container
@onready var bg  = $heartbg

var bound_player: Node = null
var heart_slots: Array[AnimatedSprite2D] = []
var previous_health: int = -1
var flash_tween: Tween

const HEART_SPACING := 20

func bind_player(player: Node) -> void:
	if is_instance_valid(bound_player):
		if bound_player.health_changed.is_connected(_on_health_changed):
			bound_player.health_changed.disconnect(_on_health_changed)

	bound_player = player
	bound_player.health_changed.connect(_on_health_changed)
	previous_health = player.health
	_build_heart_slots(player.max_health)
	draw_hearts(player.health)
	
func _on_health_changed(current_health: int, max_health: int) -> void:
	_build_heart_slots(max_health)
	draw_hearts(current_health)
	if previous_health != -1 and current_health != previous_health:
		_flash_hearts(current_health > previous_health)
	previous_health = current_health

func _flash_hearts(healed: bool) -> void:
	if is_instance_valid(flash_tween):
		flash_tween.kill()

	container.modulate = Color.WHITE
	var flash_color := Color(0.75, 1.75, 0.75) if healed else Color(1.9, 0.7, 0.7)
	flash_tween = create_tween()
	flash_tween.tween_property(container, "modulate", flash_color, 0.06)
	flash_tween.tween_property(container, "modulate", Color.WHITE, 0.12)

func _build_heart_slots(max_health: int) -> void:
	heart.visible = false
	half_heart.visible = false

	var required_slots := int(ceil(float(max_health) / 2.0))

	while heart_slots.size() < required_slots:
		var slot := heart.duplicate() as AnimatedSprite2D
		slot.position = Vector2(heart_slots.size() * HEART_SPACING, 0)
		slot.visible = false
		container.add_child(slot)
		heart_slots.append(slot)

	while heart_slots.size() > required_slots:
		var slot := heart_slots.pop_back() as AnimatedSprite2D
		slot.free()

func draw_hearts(current_health: int) -> void:
	var remaining_health := current_health

	for slot in heart_slots:
		if remaining_health >= 2:
			_show_slot(slot, &"full")
			remaining_health -= 2
		elif remaining_health == 1:
			_show_slot(slot, &"half")
			remaining_health = 0
		else:
			slot.visible = false

func _show_slot(slot: AnimatedSprite2D, animation_name: StringName) -> void:
	if slot.animation != animation_name:
		slot.animation = animation_name
	
	slot.frame = 0
	#slot.stop()
	slot.visible = true
