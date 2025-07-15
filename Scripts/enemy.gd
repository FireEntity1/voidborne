extends RigidBody2D

var player: CharacterBody2D

var chasing = false

const SPEED = 300.0
const JUMP_VELOCITY = -400.0

@export var health = 15
@export var speed = 200

func _ready():
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC

func _physics_process(delta):
	if chasing:
		self.position.x = move_toward(self.position.x,player.position.x,delta*speed)


func _on_detection_body_entered(body):
	if body is CharacterBody2D and body.name == "player":
		player = body
		chasing = true

func hit():
	if player.position.x < self.position.x:
		linear_velocity = Vector2(1300,0)
	else:
		linear_velocity = Vector2(-1300,0)
