extends Node2D

@export var obstacle_scene: PackedScene
@export var spawn_interval := 2.0
var timer := 0.0

var base_speed := 200.0
var speed_increase_rate := 10.0  # Speed increase per second
var current_speed := base_speed
var time_elapsed := 0.0

@export var spawn_offset_x: float = 500.0
@export var min_y: float = -150.0
@export var max_y: float = 50.0
@export var spawn_from_camera: bool = true
func _process(delta):
	timer += delta
	time_elapsed += delta

	current_speed = base_speed + time_elapsed * speed_increase_rate  # 🔥 Speed increases over time

	if timer >= spawn_interval:
		spawn_obstacle()
		timer = 0.0

func spawn_obstacle():
	if obstacle_scene == null:
		return

	var new_obstacle = obstacle_scene.instantiate()
	new_obstacle.speed = current_speed
	new_obstacle.add_to_group("obstacles")

	# Determine spawn X position
	var camera = get_viewport().get_camera_2d()
	var spawn_x = global_position.x + spawn_offset_x  # Default
	if spawn_from_camera and camera:
		spawn_x = camera.global_position.x + spawn_offset_x

	# Random vertical Y position
	var spawn_y = randf_range(min_y, max_y)

	new_obstacle.position = Vector2(spawn_x, spawn_y)
	get_parent().add_child(new_obstacle)
