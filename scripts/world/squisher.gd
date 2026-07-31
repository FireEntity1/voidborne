extends Area2D

var location = "up"

@export var delay: float = 0.0
@export var time: float = 3.0

func _ready() -> void:
	await get_tree().create_timer(delay).timeout
	$timer.wait_time = time
	$timer.start()

func _physics_process(delta: float) -> void:
	if location == "up":
		$collision.position.y = move_toward($collision.position.y,$top.position.y,delta*48.0)
	else:
		#$collision.position.y = move_toward($collision.position.y,$bottom.position.y,delta*80.0)
		pass

func _on_timer_timeout() -> void:
	if location == "up":
		location = "down"
		$timer.wait_time = 0.5
		$timer.start()
		slam()
	else:
		location = "up"
		$timer.start()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
			body.hit(1,true,global_position)

func slam():
	var tween = create_tween()
	tween.tween_property(
		$collision,
		"position:y",
		$bottom.position.y,
		0.5
	).set_trans(Tween.TRANS_EXPO)
