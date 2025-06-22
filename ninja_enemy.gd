extends Node2D

@export var enemy_arrow_scene: PackedScene
@export var throw_interval: float = 2.0
@export var arrow_speed: float = 400.0

var player: Node2D = null

func _process(delta):
	if player:
		var to_player = player.global_position.x - global_position.x
		#$CharacterBody2D.scale.x = -1 if to_player < 0 else 1
		$CharacterBody2D/AnimatedSprite2D.flip_h = to_player < 0

func _ready():
	$ThrowTimer.wait_time = throw_interval
	$ThrowTimer.timeout.connect(_on_throw_timer_timeout)
	$ThrowTimer.start()

func _on_throw_timer_timeout():
	print("Timer timeout fired")
	shoot_arrow()

func shoot_arrow():
	if not enemy_arrow_scene:
		print("Arrow scene is not assigned!")
		return

	var arrow = enemy_arrow_scene.instantiate()

	var dir = -1 if (player.global_position.x - global_position.x) < 0 else 1
	var spawn_pos = $CharacterBody2D/ArrowSpawnPoint.global_position
	spawn_pos.x += 10 * dir  # small push forward
	arrow.global_position = spawn_pos

	arrow.set_direction(dir)
	get_tree().current_scene.add_child(arrow)

	print("Arrow spawn position:", spawn_pos)
	print("Arrow parent:", arrow.get_parent())
