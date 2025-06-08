extends StaticBody2D

const SPEED = 200

func _process(delta):
	position.x -= SPEED * delta

	if position.x < -1000:
		queue_free()
