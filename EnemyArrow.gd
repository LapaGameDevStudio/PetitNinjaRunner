extends Area2D

func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))

func _physics_process(delta):
	var direction = Vector2.RIGHT.rotated(rotation)
	position +=  direction * 1000 * delta

func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(20)
			queue_free()
