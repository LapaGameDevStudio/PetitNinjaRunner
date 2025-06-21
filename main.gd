extends Node2D

@onready var game_over_ui = $GameOver_UI

func _ready():
	game_over_ui.visible = false
	print("HELOOOOOOOOOOOOOOOOOOOOO")

func _on_restart_button_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()
