extends CharacterBody2D

@export var attack_interval := 0.2
@export var ambient_leaf_interval := 0.2
@export var leaf_scene = preload("res://SakuraLeaf.tscn")

@onready var spawn_points = [
	$LeafSpawnPoint1, $LeafSpawnPoint2, $LeafSpawnPoint3,
	$LeafSpawnPoint4, $LeafSpawnPoint5, $LeafSpawnPoint6,
	$LeafSpawnPoint7, $LeafSpawnPoint8, $LeafSpawnPoint9,
	$LeafSpawnPoint10, $LeafSpawnPoint12, $LeafSpawnPoint13,
	$LeafSpawnPoint14, $LeafSpawnPoint15, $LeafSpawnPoint16,
	$LeafSpawnPoint17, $LeafSpawnPoint18, $LeafSpawnPoint19,
	$LeafSpawnPoint20, $LeafSpawnPoint21, $LeafSpawnPoint22
]

var target_player: Node2D = null
var ambient_timer := 0.0

func _ready():
	$LeafSpawnTimer.wait_time = attack_interval
	$LeafSpawnTimer.start()

func _process(delta: float) -> void:
	if not target_player:
		ambient_timer += delta
		if ambient_timer >= ambient_leaf_interval:
			ambient_timer = 0.0
			spawn_falling_leaf()

func spawn_falling_leaf():
	var spawn = spawn_points[randi() % spawn_points.size()]
	var new_leaf = leaf_scene.instantiate()
	new_leaf.global_position = spawn.position
	new_leaf.global_rotation = spawn.global_rotation
	new_leaf.speed = 150
	new_leaf.target = null  # Ambient fall
	$".".add_child(new_leaf)

func spawn_tracking_leaf():
	var spawn = spawn_points[randi() % spawn_points.size()]
	var new_leaf = leaf_scene.instantiate()
	new_leaf.global_position = spawn.position
	new_leaf.global_rotation = spawn.global_rotation
	new_leaf.speed = 500
	new_leaf.target = target_player
	$".".add_child(new_leaf)

func _on_detection_area_body_entered(body):
	if body.is_in_group("player"):
		print("Player entered detection area")
		target_player = body
		$LeafSpawnTimer.start()

func _on_detection_area_body_exited(body):
	if body == target_player:
		print("Player exited detection area")
		target_player = null
		$LeafSpawnTimer.stop()

func _on_LeafSpawnTimer_timeout():
	if target_player and is_instance_valid(target_player):
		spawn_tracking_leaf()
