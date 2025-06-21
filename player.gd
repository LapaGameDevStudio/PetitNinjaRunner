extends CharacterBody2D

const GRAVITY = 1000.0
const JUMP_FORCE = -500.0
const SPEED = 150.0


func _physics_process(delta):
	velocity.y += GRAVITY * delta
	
	var direction = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	velocity.x = direction * SPEED
	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_FORCE
		$JumpSound.play()

	move_and_slide()

	var collision = get_last_slide_collision()
	if collision:
		var collider = collision.get_collider()
		if collider and collider.is_in_group("obstacles"):
			bye_bye_amigo()

func bye_bye_amigo():
	var game_over_ui = get_tree().get_root().get_node("Main/GameOver_UI")  # Adjust path as needed
	game_over_ui.visible = true
	get_tree().paused = true
