extends Area2D

@export var speed: float = 400.0
var velocity := Vector2.ZERO

func set_direction(dir: int):
	velocity = Vector2(dir, 0) * speed
	$Sprite2D.flip_h = dir < 0

func _process(delta):
	global_position += velocity * delta
