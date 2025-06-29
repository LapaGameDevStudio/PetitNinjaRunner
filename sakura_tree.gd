extends CharacterBody2D

@export var leaf_scene: PackedScene
@export var attack_interval := 2.0

func _ready():
	$LeafSpawnTimer.wait_time = attack_interval
	$LeafSpawnTimer.start()

func _on_DetectionArea_body_entered(body):
	if body.is_in_group("Player"):
		$LeafSpawnTimer.start()

func _on_DetectionArea_body_exited(body):
	if body.is_in_group("Player"):
		$LeafSpawnTimer.stop()

func _on_LeafSpawnTimer_timeout():
	var leaf = leaf_scene.instantiate()
	leaf.position = $LeafSpawnPoint.global_position
	leaf.direction = Vector2.DOWN + Vector2(randf_range(-0.3, 0.3), 0)  # Optional scatter
	get_tree().current_scene.add_child(leaf)
