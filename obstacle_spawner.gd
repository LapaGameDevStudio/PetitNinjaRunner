extends Node2D

@export var obstacle_scene: PackedScene
@export var spawn_interval := 2.0
var timer := 0.0

var base_speed := 200.0
var speed_increase_rate := 10.0  # Speed increase per second
var current_speed := base_speed
var time_elapsed := 0.0

func _process(delta):
	timer += delta
	time_elapsed += delta

	current_speed = base_speed + time_elapsed * speed_increase_rate  # 🔥 Speed increases over time

	if timer >= spawn_interval:
		spawn_obstacle()
		timer = 0.0

func spawn_obstacle():
	if obstacle_scene:
		var new_obstacle = obstacle_scene.instantiate()
		new_obstacle.position = Vector2(300, -140)
		new_obstacle.speed = current_speed  # ✅ Pass dynamic speed
		new_obstacle.add_to_group("obstacles")
		get_parent().add_child(new_obstacle)
