extends Control

func _ready():
	$VBoxContainer/StartButton.pressed.connect(_on_start_pressed)
	$VBoxContainer/SettingsButton.pressed.connect(_on_settings_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)

func _on_start_pressed():
	get_tree().change_scene_to_file("res://intro/IntroScene.tscn") # Change to your main game scene

func _on_settings_pressed():
	print("Settings button pressed") # Placeholder – you can later load a settings menu

func _on_quit_pressed():
	get_tree().quit()
