extends Area2D

func _ready():
	pass

func _process(delta):
	pass


func _on_body_entered(body):
	if body.name == "player":
		body.velocity.y = -3000
