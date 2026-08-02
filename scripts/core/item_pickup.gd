extends CanvasLayer

@export var item_name = ""
@export var desc = ""

var fading = false

func _ready() -> void:
	$bg.modulate.a = 0.0
	$bg/centre/vbox/name.text = item_name
	$bg/centre/vbox/description.text = desc
	await get_tree().create_timer(5.0).timeout
	fading = true

func _process(delta: float) -> void:
	if not fading:
		$bg.modulate.a = move_toward($bg.modulate.a,1.0,delta*4.0)
	else:
		$bg.modulate.a = move_toward($bg.modulate.a,0.0,delta*2.0)
		if $bg.modulate.a <= 0.0:
			queue_free()
