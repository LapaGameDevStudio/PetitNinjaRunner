extends CharacterBody2D

@export var throw_interval: float = 2.0
@export var arrow_speed: float = 400.0

var player: Node2D = null

func _process(delta):
	if player:
		var to_player = player.global_position.x - global_position.x		
		print("Glob pos Player X : ",player.global_position.x)
		print("Glob pos Enemy X : ",global_position.x)
		# Flip the entire enemy (including collision, spawn points, etc.)
		scale.x = -1 if to_player < 0 else 1


func _ready():
	$ThrowTimer.wait_time = throw_interval
	$ThrowTimer.timeout.connect(_on_throw_timer_timeout)
	$ThrowTimer.start()

func _on_throw_timer_timeout():
	shoot_arrow()

func shoot_arrow():
	$AnimatedSprite2D.animation = "ATTACK"
	$AnimatedSprite2D.play()
	var anim_length = $AnimatedSprite2D.sprite_frames.get_frame_count("ATTACK") / $AnimatedSprite2D.sprite_frames.get_animation_speed("ATTACK")
	await get_tree().create_timer(anim_length).timeout
	print("ARROW SHOT")
	const Arrow = preload("res://EnemyArrow.tscn")
	var new_arrow = Arrow.instantiate()
	new_arrow.global_position = $ArrowSpawnPoint.global_position
	new_arrow.global_rotation = $ArrowSpawnPoint.global_rotation
	$ArrowSpawnPoint.add_child(new_arrow)
	$AnimatedSprite2D.stop()
	
