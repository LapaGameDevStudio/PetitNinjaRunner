extends CharacterBody2D
const GRAVITY = 1000.0
const JUMP_FORCE = -500.0
const SPEED = 300.0
var PROTECTED = false
signal game_over
var is_dead = false
@export var max_health: int = 100
@onready var camera := $Camera2D  # adapte le chemin si besoin
var previous_direction := 0
var direction_hold_time := 0.0
var direction_threshold := 0.3  # temps minimum avant que la caméra suive
var offset_strength := 500

var current_health: int = max_health

signal health_changed(current_health)

func take_damage(amount: int):
	if is_dead:
		return  # Ignore damage when already dead
	if PROTECTED:
		return  # Ignore damage when Protected
	current_health -= amount
	emit_signal("health_changed", current_health)
	print("💔 Player took", amount, "damage. Remaining:", current_health)
	if current_health > 0 and not $HurtSound.playing:
		$HurtSound.play()
	if current_health <= 0:
		bye_bye_amigo()

func _ready():
	add_to_group("player")

func _physics_process(delta):
	if is_dead:
		return
	velocity.y += GRAVITY * delta

	var direction = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	velocity.x = direction * SPEED

	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_FORCE
		$JumpSound.play()

	if Input.is_action_pressed("ui_down"):
		if not PROTECTED:
			PROTECTED = true
			$AnimatedSprite2D.animation = "PROTECT"
			$AnimatedSprite2D.play()
	elif PROTECTED:
		PROTECTED = false

	elif not is_on_floor():
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

	
	## Si direction a changé, on reset le timer
	#if direction != previous_direction:
		#direction_hold_time = 0.0
	#else:
		#direction_hold_time += delta
	#
	#previous_direction = direction
	#
	## Calcul du suivi de la caméra
	#if direction != 0 and direction_hold_time >= direction_threshold:
		#var offset_x = direction * offset_strength
		#camera.offset.x = lerp(camera.offset.x, offset_x, 2 * delta)
	#else:
		## revenir progressivement à un offset neutre
		#camera.offset.x = lerp(camera.offset.x, 0.0, 2 * delta)
		
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
	$GameOverSound.play()
	$Camera2D.shake_camera()
	# Delay game over until animation finishes
	var anim_length = $AnimatedSprite2D.sprite_frames.get_frame_count("DEATH") / $AnimatedSprite2D.sprite_frames.get_animation_speed("DEATH")
	await get_tree().create_timer(anim_length).timeout
	emit_signal("game_over")
