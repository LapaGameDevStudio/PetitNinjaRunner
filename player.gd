extends CharacterBody2D
const GRAVITY = 1000.0
const JUMP_FORCE = -500.0
const SPEED = 300.0

signal game_over
var is_dead = false

func _physics_process(delta):
	if is_dead:
		return  # Stop everything when dead
	velocity.y += GRAVITY * delta

	var direction = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	velocity.x = direction * SPEED

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_FORCE
		$JumpSound.play()
	if not is_on_floor():
		$AnimatedSprite2D.animation = "JUMP"
		$AnimatedSprite2D.play()
	elif direction != 0:
		$AnimatedSprite2D.animation = "RUNNING"
		$AnimatedSprite2D.flip_h = direction < 0
		$AnimatedSprite2D.play()
	else:
		$AnimatedSprite2D.animation = "IDLE"
		$AnimatedSprite2D.play()

	move_and_slide()
	var collision = get_last_slide_collision()
	if collision:
		var collider = collision.get_collider()
		if collider and (collider.is_in_group("obstacles") or collider.is_in_group("DeathZone")):
			bye_bye_amigo()

func bye_bye_amigo():
	if is_dead:
		return  # Avoid double death
	is_dead = true
	print("YOU ARE DEAD PITCHOO")
	$AnimatedSprite2D.animation = "DEATH"
	$AnimatedSprite2D.play()
	
	# Optionnel : attendre un peu avant de signaler la fin
	await get_tree().create_timer(1).timeout  # Laisse le temps à l'anim de démarrer

	emit_signal("game_over")
