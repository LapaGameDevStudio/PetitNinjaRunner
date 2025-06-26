extends Area2D

@export var speed: float = 400.0
var velocity := Vector2.ZERO

func set_direction(dir: int):
	velocity = Vector2(dir, 0) * speed
	#$Sprite2D.flip_h = dir < 0

func _ready():
	print("🟢 CannonBall spawned at: ", global_position)
	connect("body_entered", Callable(self, "_on_body_entered"))

func _process(delta):
	global_position += velocity * delta

func _on_body_entered(body):
	if body.is_in_group("player"):
		print("💥 CannonBall hit the player!")
		if body.has_method("take_damage"):
			body.take_damage(20)
	queue_free()
