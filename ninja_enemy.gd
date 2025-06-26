extends Node2D

@export var EnemyArrow: PackedScene
@export var throw_interval: float = 2.0
@export var arrow_speed: float = 400.0
@export var arrow_test_position: Vector2 = Vector2(500, -150)

var player: Node2D = null

func _ready():
	player = $"../Player"
	$ThrowTimer.wait_time = throw_interval
	if not $ThrowTimer.timeout.is_connected(_on_throw_timer_timeout):
		$ThrowTimer.timeout.connect(_on_throw_timer_timeout)
	$ThrowTimer.start()
	
func _on_throw_timer_timeout():
	print("Timer timeout fired")
	shoot_arrow()

func shoot_arrow():
	if not EnemyArrow:
		print("Arrow scene is not assigned!")
		return

	var arrow = EnemyArrow.instantiate()

	# point fixe où spawn la flèche
	var fixed_pos = arrow_test_position

	# calcul direction : si player est à gauche du point fixe => dir = -1 (gauche), sinon 1 (droite)
	var dir = -1 if player.global_position.x < fixed_pos.x else 1

	# positionne la flèche au point fixe
	arrow.global_position = fixed_pos

	get_tree().current_scene.add_child(arrow)

	# donne la direction à la flèche
	arrow.set_direction(-1)

	print("player.global_position.x:", player.global_position.x)
	print("Arrow spawn position:", fixed_pos)
	print("Arrow direction:", dir)
