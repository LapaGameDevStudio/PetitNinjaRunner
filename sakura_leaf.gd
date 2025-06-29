extends Area2D

@export var speed := 150.0
@export var damage := 10

var direction := Vector2.DOWN

func _ready():
	$Timer.start()
	set_physics_process(true)

func _physics_process(delta):
	position += direction * speed * delta

func _on_Timer_timeout():
	queue_free()

func _on_body_entered(body):
	if body.is_in_group("Player"):
		body.take_damage(damage)  # Assuming you have a method like this
		queue_free()
