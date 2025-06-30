extends StaticBody2D

@export var CannonBall: PackedScene
@export var throw_interval: float = 2.0
@export var fire_direction: int = -1  # -1 = gauche, 1 = droite
@export var spawn_offset: Vector2 = Vector2(-60, -5)  # relatif au canon
@export var cannon_texture: Texture2D
@export var ball_speed: float = 400.0  # 🆕 Vitesse personnalisée

func _ready():
	$Timer.wait_time = throw_interval
	if not $Timer.timeout.is_connected(_on_throw_timer_timeout):
		$Timer.timeout.connect(_on_throw_timer_timeout)
	$Timer.start()
	if cannon_texture:
		$Sprite2D.texture = cannon_texture
		
func _draw():
	draw_circle(spawn_offset, 5, Color.RED)
	draw_line(spawn_offset, spawn_offset + Vector2(20 * fire_direction, 0), Color.YELLOW, 2)

func _on_throw_timer_timeout():
	shoot()

func shoot():
	if not CannonBall:
		printerr("⚠️ CannonBall scene not assigned!")
		return

	var ball = CannonBall.instantiate()
	ball.position = spawn_offset  # position locale
	add_child(ball)  # la balle devient enfant du canon
	ball.launch_rocket(fire_direction, ball_speed)
	#print("💣 CannonBall fired at:", ball.global_position, "→ Direction:", fire_direction, "speed:", ball_speed)
