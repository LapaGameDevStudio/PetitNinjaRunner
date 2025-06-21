extends CharacterBody2D

const GRAVITY = 1000.0
const JUMP_FORCE = -500.0
const SPEED = 300.0

signal game_over
var is_dead = false

func _physics_process(delta):
	if is_dead:
		return  # Freeze player control when dead
	velocity.y += GRAVITY * delta
	
	var direction = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	velocity.x = direction * SPEED

	# Play correct animation
	if direction != 0:
		$AnimatedSprite2D.animation = "RUNNING"
		$AnimatedSprite2D.flip_h = direction < 0
	else:
		$AnimatedSprite2D.animation = "IDLE"

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_FORCE
		$AnimatedSprite2D.animation = "JUMP" # !!!! TO BE FIXED !!!!!
		$JumpSound.play()

	move_and_slide()

	var collision = get_last_slide_collision()
	if collision:
		var collider = collision.get_collider()
		if collider and (collider.is_in_group("obstacles") or collider.is_in_group("DeathZone")):
			bye_bye_amigo()

func bye_bye_amigo():
	if is_dead:
		return
	is_dead = true

	# Stop movement
	velocity = Vector2.ZERO
	
	# Play death animation
	$AnimatedSprite2D.animation = "DEATH"
	$AnimatedSprite2D.frame = 0  # Restart animation
	$AnimatedSprite2D.play()

	# Play sound
	$"../GameOver_UI/GameOverSound".play()

	# Delay game over until animation finishes
	var anim_length = $AnimatedSprite2D.sprite_frames.get_frame_count("DEATH") / $AnimatedSprite2D.sprite_frames.get_animation_speed("DEATH")
	await get_tree().create_timer(anim_length).timeout
	emit_signal("game_over")
