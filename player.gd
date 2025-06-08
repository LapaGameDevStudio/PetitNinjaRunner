extends CharacterBody2D

const GRAVITY = 1000.0
const JUMP_FORCE = -500.0
const SPEED = 150.0

func _physics_process(delta):
	velocity.x = SPEED
	velocity.y += GRAVITY * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_FORCE
		$JumpSound.play()  # Joue le son de saut

	move_and_slide()
