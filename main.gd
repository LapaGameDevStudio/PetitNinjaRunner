extends Node2D
@onready var game_over_scene = preload("res://GameOver.tscn")
@onready var score_label = $CanvasLayer/ScoreLabel
@onready var health_bar = $CanvasLayer/ProgressBar
@onready var player = get_node("Player")  # adapte le chemin
@onready var parallax := $ParallaxBackground
@onready var mirror_x_spin := $UI/VBoxContainer/MirrorXSpinBox
@onready var mirror_y_spin := $UI/VBoxContainer/MirrorYSpinBox

var game_over_instance: Node = null
var score := 0
var score_timer := 0.0
var is_game_over := false

func setup_health_bar():
	if not health_bar.has_theme_stylebox("fill"):
		var fill_style = StyleBoxFlat.new()
		fill_style.bg_color = Color("00ff00")
		health_bar.add_theme_stylebox_override("fill", fill_style)

func _ready():
	var test_scene = game_over_scene.instantiate()
	if test_scene:
		print("✅ GameOver scene loaded and instantiated")
	else:
		print("❌ Failed to load GameOver scene")
	player = $Player
	$DeathZone.add_to_group("DeathZone")
	#game_over_ui.visible = false
	#game_over_ui.process_mode = Node.PROCESS_MODE_ALWAYS
	score = 0
	score_label.text = "Score: %d" % score
	setup_health_bar()
	update_health_bar(100)
	player.connect("game_over", Callable(self, "_on_game_over"))
	player.connect("health_changed", Callable(self, "_on_health_changed"))
	# ✅ Charge le layout JSON du parallax
	load_parallax_layout("res://tools/parallax_layout.json")
	
func _process(delta):
	if not is_game_over:
		score_timer += delta
		if score_timer >= 0.5:  # increase score every 0.5 seconds
			score += 1
			score_label.text = "Score: %d" % score
			#game_over_ui.get_node("LastScore").text = score_label.text
			score_timer = 0.0

func _on_game_over():
	if game_over_instance == null:
		game_over_instance = game_over_scene.instantiate()
		add_child(game_over_instance)
		game_over_instance.get_node("VBoxContainer/LastScore").text = "Score: %d" % score
		game_over_instance.get_node("VBoxContainer/RestartButton").pressed.connect(_on_restart_button_pressed)
		game_over_instance.get_node("VBoxContainer/MainMenuButton").pressed.connect(_on_main_menu_button_pressed)
	else:
		game_over_instance.visible = true

	score_label.visible = false
	get_tree().paused = true

	
func _on_restart_button_pressed():
	print("_on_restart_button_pressed")
	get_tree().paused = false
	get_tree().reload_current_scene()
	
func _on_main_menu_button_pressed():
	print("_on_main_menu_button_pressed")
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main_menu.tscn")
	
func _on_health_changed(new_health):
	update_health_bar(new_health)

func update_health_bar(value):
	health_bar.value = value
	$CanvasLayer/HealthValue.text = "Health : %d%%" % value
	var fill_style = health_bar.get_theme_stylebox("fill") as StyleBoxFlat
	if value > 70:
		fill_style.bg_color = Color("00ff00")  # vert
	elif value > 30:
		fill_style.bg_color = Color("ffaa00")  # orange
	else:
		fill_style.bg_color = Color("ff0000")  # rouge

func load_parallax_layout(path: String):
	if not FileAccess.file_exists(path):
		print("Fichier JSON introuvable :", path)
		return

	var file = FileAccess.open(path, FileAccess.READ)
	var content = file.get_as_text()
	file.close()

	var data = JSON.parse_string(content)
	if typeof(data) != TYPE_ARRAY:
		print("Le fichier n'est pas un tableau JSON valide.")
		return

	for child in parallax.get_children():
		child.queue_free()

	for layer_data in data:
		if typeof(layer_data) != TYPE_DICTIONARY:
			continue

		var texture_path = layer_data.get("texture_path", "")
		var texture = load(texture_path)
		if not texture:
			print("Échec chargement texture :", texture_path)
			continue

		var layer = ParallaxLayer.new()
		var sprite = Sprite2D.new()
		sprite.texture = texture
		sprite.centered = true

		var pos = layer_data.get("position", [0, 0])
		sprite.position = Vector2(pos[0], pos[1])

		var scale = layer_data.get("motion_scale", [0, 1])
		layer.motion_scale = Vector2(scale[0], scale[1])

		var mirror = layer_data.get("motion_mirroring", [0, 0])
		layer.motion_mirroring = Vector2(mirror[0], mirror[1])

		layer.add_child(sprite)
		parallax.add_child(layer)

	print("✅ Parallax layout chargé depuis :", path)
