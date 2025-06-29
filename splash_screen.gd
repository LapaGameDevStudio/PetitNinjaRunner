extends CanvasLayer

func _ready():
	await get_tree().create_timer(0.1).timeout  # Wait 2.5 seconds (or match your animation)
	get_tree().change_scene_to_file("res://main_menu.tscn")  # Your main menu scene
