extends Node2D

@export var obstacle_scene: PackedScene
@export var spawn_interval := 2.0  # secondes
var timer := 0.0

func _process(delta):
	timer += delta
	if timer >= spawn_interval:
		spawn_obstacle()
		timer = 0.0  

func spawn_obstacle():
	if obstacle_scene:
		print("Spawning obstacle")
		var new_obstacle = obstacle_scene.instantiate()
		new_obstacle.position = Vector2(300, -100)  # Ajuste selon la hauteur du sol
		get_parent().add_child(new_obstacle)
