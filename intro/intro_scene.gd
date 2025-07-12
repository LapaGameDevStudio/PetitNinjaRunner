extends Node2D

func _ready():
	$AnimationPlayer.play("IntroAnim")
	$AnimationPlayer.connect("animation_finished", Callable(self, "_on_Animation_finished"))

func _on_Animation_finished(anim_name):
	if anim_name == "IntroAnim":
		get_tree().change_scene_to_file("res://Main.tscn")
