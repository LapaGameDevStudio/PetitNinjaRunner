extends StaticBody2D

var speed = 200  # This will be set dynamically

func _process(delta):
	position.x -= speed * delta

	if position.x < -1000:
		queue_free()
