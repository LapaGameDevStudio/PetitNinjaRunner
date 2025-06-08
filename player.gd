extends CharacterBody2D

const GRAVITY = 1000.0
const JUMP_FORCE = -500.0
const SPEED = 150.0

func _physics_process(delta):
	velocity.x = SPEED
	velocity.y += GRAVITY * delta

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_FORCE
		$JumpSound.play()

	move_and_slide()  # Pas d'argument ici !

	# Récupérer la collision de la dernière glissade
	var collision = get_last_slide_collision()
	if collision:
		var collider = collision.get_collider()
		if collider and collider.is_in_group("obstacles"):
			print("Spawning obstacle")
			bye_bye_amigo()
			print("bitchhhhh")

func bye_bye_amigo():
	print("Game Over !")
