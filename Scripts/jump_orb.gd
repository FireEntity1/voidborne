extends Area2D

var moving_up = true

var dist = 0

const VELOCITY = 40

func _ready():
	pass

func _process(delta):
	if moving_up:
		self.position.y -= delta*VELOCITY
		dist -= delta*VELOCITY
	else:
		self.position.y += delta*VELOCITY
		dist += delta*VELOCITY
	
	if dist > 35:
		moving_up = true
	elif dist < -35:
		moving_up = false

func _on_body_entered(body):
	if body.name == "player":
		body.velocity.y = -3000
		$dashsfx.play()
