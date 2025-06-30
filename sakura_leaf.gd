extends Area2D

@export var speed := 500
@export var damage := 10

var target: Node2D = null
func _ready():
	connect("body_entered", Callable(self, "_on_body_entered"))
	$Timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	$Timer.start()
	set_physics_process(true)

func _physics_process(delta):
	if target and is_instance_valid(target):
		var direction = (target.global_position - global_position).normalized()
		global_position += direction * speed * delta
		rotation = direction.angle()
	else:
		# Fall straight down when no target
		global_position.y += speed * delta
		rotation = deg_to_rad(90)  # Face downward

func _on_timer_timeout():
	print("LEAF TIMEOUT")
	queue_free() #Destroy Leaf after 1sec

func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(damage)  # Assuming you have a method like this
	queue_free()
