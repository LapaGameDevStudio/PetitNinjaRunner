extends CharacterBody2D

@export var EnemyArrow: PackedScene  # Drag EnemyArrow.tscn here in the inspector
@onready var arrow_spawn = $ArrowSpawnPoint
@onready var sprite = $Sprite2D

func _ready():
	pass  # Or start any shooting timer/logic

func shoot_arrow():
	var arrow = EnemyArrow.instantiate()
	
	# Set position before adding to the scene tree
	arrow.global_position = arrow_spawn.global_position
	
	# Determine facing direction
	var dir = -1 if sprite.flip_h else 1
	arrow.set_direction(dir)
	
	# Add to current scene root, NOT under enemy
	get_tree().current_scene.add_child(arrow)
