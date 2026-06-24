extends Area2D

@export var health: int = 3
@export var onedirection: bool = true
@export var direction: int = -1

func hit():
	if onedirection and not ((direction*Global.player.global_position.x)-(direction*global_position.x) > 0):
		return
	print("wall hit")
	health -= 1
	$sprite.frame = 4-health
	shake()
	if health <= 0:
		$static/collision.disabled = true
		$sprite.hide()
		print("wall gone")

func shake():
	for i in range(10):
		$sprite.position = Vector2(randi_range(-1,1),randi_range(-1,1))
		await get_tree().create_timer(0.01).timeout
	$sprite.position = Vector2.ZERO
	
