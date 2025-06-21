extends Node2D

@onready var game_over_ui = $GameOver_UI
@onready var score_label = $CanvasLayer/ScoreLabel

var score := 0
var score_timer := 0.0
var is_game_over := false

func _ready():
	$DeathZone.add_to_group("DeathZone")
	game_over_ui.visible = false
	game_over_ui.process_mode = Node.PROCESS_MODE_ALWAYS
	score = 0
	score_label.text = "Score: %d" % score

	var player = $Player
	player.connect("game_over", Callable(self, "_on_game_over"))

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
