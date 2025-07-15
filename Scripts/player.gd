extends CharacterBody2D

var jumps = 2

const SPEED = 1200.0
const JUMP_VELOCITY = -1600.0

var dashing = false
var can_dash = true

var flip = true # right false, left true

var direction = 1

func _physics_process(delta):
	if not is_on_floor():
		velocity += get_gravity() * delta
	else:
		jumps = 2

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		jumps = 1
	
	if Input.is_action_just_pressed("jump") and not is_on_floor() and jumps >= 1:
		velocity.y = JUMP_VELOCITY
		jumps = 0
	
	if Input.is_action_just_pressed("slam") and not is_on_floor():
		self.velocity.y = 5000
	
	direction = Input.get_axis("left", "right")
	if direction:
		velocity.x = move_toward(velocity.x, direction * SPEED, 8000 * delta)
		$sprite.play("walk")
	else:
		velocity.x = move_toward(velocity.x, 0, 8000 * delta)
		$sprite.play("idle")
	
	if not is_on_floor():
		if self.velocity.y > 500:
			$sprite.play("falling")
		elif self.velocity.y < -500:
			$sprite.play("jumping")
		else:
			$sprite.play("float")
	
	if Input.is_action_just_pressed("left"):
		flip = true
	if Input.is_action_just_pressed("right"):
		flip = false
	
	$sprite.flip_h = flip
	
	if Input.is_action_just_pressed("dash"):
		dashing = true
		await get_tree().create_timer(0.08).timeout
		dashing = false
	if dashing:
		self.velocity.x = direction * 3000
	
	move_and_slide()
