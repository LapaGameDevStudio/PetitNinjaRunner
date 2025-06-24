extends Node2D

@onready var game_over_ui = $GameOver_UI
@onready var score_label = $CanvasLayer/ScoreLabel
@onready var health_bar = $CanvasLayer/ProgressBar
@onready var player = get_node("Player")  # adapte le chemin
@onready var ninja = get_node("NinjaEnemy")  # adapte le chemin
var score := 0
var score_timer := 0.0
var is_game_over := false

func setup_health_bar():
	if not health_bar.has_theme_stylebox("fill"):
		var fill_style = StyleBoxFlat.new()
		fill_style.bg_color = Color("00ff00")
		health_bar.add_theme_stylebox_override("fill", fill_style)

func _ready():
	ninja = $NinjaEnemy
	player = $Player
	ninja.player = player
	$DeathZone.add_to_group("DeathZone")
	game_over_ui.visible = false
	game_over_ui.process_mode = Node.PROCESS_MODE_ALWAYS
	score = 0
	score_label.text = "Score: %d" % score
	setup_health_bar()
	update_health_bar(100)
	player.connect("game_over", Callable(self, "_on_game_over"))
	player.connect("health_changed", Callable(self, "_on_health_changed"))

func _process(delta):
	if not is_game_over:
		score_timer += delta
		if score_timer >= 0.5:  # increase score every 0.5 seconds
			score += 1
			score_label.text = "Score: %d" % score
			game_over_ui.get_node("LastScore").text = score_label.text
			score_timer = 0.0

func _on_game_over():
	game_over_ui.visible = true
	score_label.visible = false
	get_tree().paused = true
	
func _on_restart_button_pressed():
	get_tree().paused = false
	game_over_ui.visible = false
	get_tree().reload_current_scene()

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
